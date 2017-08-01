/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * This file is available under the terms of the NASA Open Source Agreement
 * (NOSA). You should have received a copy of this agreement with the
 * Kepler source code; see the file NASA-OPEN-SOURCE-AGREEMENT.doc.
 * 
 * No Warranty: THE SUBJECT SOFTWARE IS PROVIDED "AS IS" WITHOUT ANY
 * WARRANTY OF ANY KIND, EITHER EXPRESSED, IMPLIED, OR STATUTORY,
 * INCLUDING, BUT NOT LIMITED TO, ANY WARRANTY THAT THE SUBJECT SOFTWARE
 * WILL CONFORM TO SPECIFICATIONS, ANY IMPLIED WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, OR FREEDOM FROM
 * INFRINGEMENT, ANY WARRANTY THAT THE SUBJECT SOFTWARE WILL BE ERROR
 * FREE, OR ANY WARRANTY THAT DOCUMENTATION, IF PROVIDED, WILL CONFORM
 * TO THE SUBJECT SOFTWARE. THIS AGREEMENT DOES NOT, IN ANY MANNER,
 * CONSTITUTE AN ENDORSEMENT BY GOVERNMENT AGENCY OR ANY PRIOR RECIPIENT
 * OF ANY RESULTS, RESULTING DESIGNS, HARDWARE, SOFTWARE PRODUCTS OR ANY
 * OTHER APPLICATIONS RESULTING FROM USE OF THE SUBJECT SOFTWARE.
 * FURTHER, GOVERNMENT AGENCY DISCLAIMS ALL WARRANTIES AND LIABILITIES
 * REGARDING THIRD-PARTY SOFTWARE, IF PRESENT IN THE ORIGINAL SOFTWARE,
 * AND DISTRIBUTES IT "AS IS."
 * 
 * Waiver and Indemnity: RECIPIENT AGREES TO WAIVE ANY AND ALL CLAIMS
 * AGAINST THE UNITED STATES GOVERNMENT, ITS CONTRACTORS AND
 * SUBCONTRACTORS, AS WELL AS ANY PRIOR RECIPIENT. IF RECIPIENT'S USE OF
 * THE SUBJECT SOFTWARE RESULTS IN ANY LIABILITIES, DEMANDS, DAMAGES,
 * EXPENSES OR LOSSES ARISING FROM SUCH USE, INCLUDING ANY DAMAGES FROM
 * PRODUCTS BASED ON, OR RESULTING FROM, RECIPIENT'S USE OF THE SUBJECT
 * SOFTWARE, RECIPIENT SHALL INDEMNIFY AND HOLD HARMLESS THE UNITED
 * STATES GOVERNMENT, ITS CONTRACTORS AND SUBCONTRACTORS, AS WELL AS ANY
 * PRIOR RECIPIENT, TO THE EXTENT PERMITTED BY LAW. RECIPIENT'S SOLE
 * REMEDY FOR ANY SUCH MATTER SHALL BE THE IMMEDIATE, UNILATERAL
 * TERMINATION OF THIS AGREEMENT.
 */

package gov.nasa.kepler.fs.server.index;
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import gov.nasa.kepler.fs.server.raf.RandomAccessFileProxy;
import gov.nasa.kepler.fs.server.raf.RandomAccessIo;
import gov.nasa.spiffy.common.collect.Cache;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.concurrent.ConcurrentLinkedQueue;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Handles btree node I/O with on disk storage.  This does buffering 
 * and allocation of space in the btree file.
 * 
 * This class is MT-safe.  This uses an internal R/W lock.  Do not use 
 * synchronized to coordinate with this class.
 * @author Sean McCauliff
 *
 */
public class DiskNodeIO<K,V, T extends TreeNode<K,V>> extends AbstractDiskNodeIO<K,V,T> {

    private final static Log log = LogFactory.getLog(DiskNodeIO.class);

    private final static long MIN_NODE_SIZE = 1024;

    private final static long JOURNAL_MAGIC = 0x19A7789ca71784ebL;

    private final static long ROOT_NODE_ADDRESS_ADDRESS = 5;

    /**
     * This is used to track the btree performance.
     */
    @SuppressWarnings({ "rawtypes" })
    public static final ConcurrentLinkedQueue<DiskNodeIO>
    diskNodeIOs = new ConcurrentLinkedQueue<DiskNodeIO>();

    /**
     * Version 1 has support for the B-link tree which requires a movable root
     * node address.
     */
    public enum BtreeFileVersion {
        VERSION_0,
        VERSION_1;

        byte versionByte() {
            return (byte) ordinal();
        }

        public static BtreeFileVersion valueOf(byte b) {
            if (b >= values().length || b < 0) {
                throw new IllegalStateException("Invalid version number: " + b);
            }
            return values()[b];
        }
    }

    private final File btreeFile;
    private final BtreeFileVersion btreeFileVersion;

    private RandomAccessIo raf;

    /**
     * This is indexed by node address not by file address.
     */
    private final PersistentBitSet allocatedBitSet;

    private final DiskNodeStats stats;

    private final String absolutePath;

    private volatile long rootNodeAddress;

    private volatile boolean syncJournal = false;


    public DiskNodeIO(KeyValueIO<K,V> kvio, File btreeFile, 
        int nodeSize,
        Cache<CacheNodeKey, T> cache, TreeNodeFactory<K,V,T> nodeFactory)
    throws IOException {

        this(kvio, btreeFile, nodeSize,cache, nodeFactory,
            BtreeFileVersion.VERSION_0);
    }

    /**
     * 
     * @param kvio
     * @param btreeFile
     * @param nodeSize
     * @param btreeT Half the branching factor of the btree.
     * @throws IOException
     */
    public DiskNodeIO(KeyValueIO<K,V> kvio, File btreeFile, 
        int nodeSize,  
        Cache<CacheNodeKey, T> cache, TreeNodeFactory<K,V,T> nodeFactory,
        BtreeFileVersion btreeFileVersion)
    throws IOException {

        super(kvio, nodeSize, cache, nodeFactory);

        this.btreeFile = btreeFile;
        this.stats = new DiskNodeStats(btreeFile.getAbsolutePath());
        this.absolutePath = btreeFile.getAbsolutePath();

        File allocationFile = 
            new File(btreeFile.getParentFile(), btreeFile.getName() + ".allocated-nodes");

        if (nodeSize < MIN_NODE_SIZE) {
            throw new IllegalArgumentException("Node size too small.");
        }


        this.allocatedBitSet = new PersistentBitSet(allocationFile);


        if (btreeFile.exists()) {
            raf = new RandomAccessFileProxy(new RandomAccessFile(btreeFile, "rw"));
            byte readVersion = raf.readByte();
            this.btreeFileVersion = BtreeFileVersion.valueOf(readVersion);

            if (journalFile().exists()) {
                recover();
            }
            switch (btreeFileVersion) {
                case VERSION_0:
                    rootNodeAddress = nodeSize;
                    break;
                case VERSION_1:
                    raf.seek(ROOT_NODE_ADDRESS_ADDRESS);
                    rootNodeAddress = raf.readLong();
                    break;
                default:
                    throw new IllegalStateException("Bad file version number " + 
                        btreeFileVersion);
            }

        } else {
            raf = new RandomAccessFileProxy(new RandomAccessFile(btreeFile, "rw"));
            raf.writeByte(btreeFileVersion.versionByte());
            raf.writeInt(nodeSize);
            if (btreeFileVersion == BtreeFileVersion.VERSION_1) {
                raf.writeLong(nodeSize);
            }
            raf.setLength(nodeSize); //align reads/writes to nodeSize boundry.
            this.btreeFileVersion = btreeFileVersion;
            this.rootNodeAddress = nodeSize;
        }

        diskNodeIOs.add(this);


    }

    private void recover() throws IOException {
        log.info("Replaying journal file for B-tree \"" + treeId() + "\".");
        File f = journalFile();
        if (f.length() < 8) {
            if (!f.delete()) {
                log.warn("Failed to delete b-tree journal file \"" + f + "\".");
            }
            log.info("Incomplete journal for B-tree \"" + f + "\".");
            return;
        }

        RandomAccessFile recoveryFile = new RandomAccessFile(f, "rw");
        recoveryFile.seek(recoveryFile.length() - 8);
        long readJournalMagic = recoveryFile.readLong();
        recoveryFile.close();

        if (readJournalMagic != JOURNAL_MAGIC) {
            log.info("Incomplete B-tree journal \"" + btreeFile + "\".");
            if (!f.delete()) {
                log.warn("Failed to delete journal for B-tree \"" + f + "\".");
            }
            return;
        }

        FileInputStream fin = new FileInputStream(f);
        BufferedInputStream bin  = new BufferedInputStream(fin, 1024*1024);
        DataInputStream din = new DataInputStream(bin);
        executeOpFromJournal(din);
        din.close();
        if (!f.delete()) {
            log.warn("Failed to delete journal for B-tree \"" + f + "\".");
        }

        log.info("Completed replaying journal for B-tree \"" + btreeFile + "\".");
    }

    @Override
    protected long currentRootNodeAddress() {
        return rootNodeAddress;
    }

    @Override
    protected RandomAccessIo storage() {
        return raf;
    }

    @Override
    public void setRootNodeAddress(long newAddress) {
        if (btreeFileVersion != BtreeFileVersion.VERSION_1) {
            throw new IllegalStateException("Can't set rot node address when" +
                " using btree file version: " + btreeFileVersion);
        }
        rwLock.writeLock().lock();
        try {
            RootNodeAddressChangedOp rootAddressChange =
                new RootNodeAddressChangedOp(ROOT_NODE_ADDRESS_ADDRESS, rootNodeAddress, newAddress);
            this.rootNodeAddress = newAddress;
            ioOps.put(ROOT_NODE_ADDRESS_ADDRESS, rootAddressChange);
        } finally {
            rwLock.writeLock().unlock();
        }
    }

    public void setJournalSync(boolean newState) {
        syncJournal = newState;
    }
    
    private File journalFile() {
        return new File(btreeFile.getParentFile(), btreeFile.getName() + ".journal");
    }

    /** Write out pending changes to disk.
     */
    public void flushPendingModifications() throws IOException  {
        rwLock.writeLock().lock();
        try {
            writeJournal();

            for (IOOp ioop : ioOps().values()) {
                ioop.doOp();
            }
            clearDirtyState();
            if (!journalFile().delete()) {
                log.warn("Failed to delete b-tree journal file \"" + 
                    journalFile()+ "\".");
            }
        } finally {
            rwLock.writeLock().unlock();
        }
    }

    /**
     * Writes everything to the journal file, but
     * does not merge with the btree file.
     *
     */
    public void writeJournal() throws IOException {
        FileOutputStream fout = new FileOutputStream(journalFile());
        BufferedOutputStream bufout = new BufferedOutputStream(fout, 1024*1024);
        DataOutputStream dout = new DataOutputStream(bufout);

        for (IOOp ioop :  ioOps().values()) {
            ioop.writeToJournal(dout);
        }
        dout.writeInt(IOOpType.JOURNAL_END.ordinal());
        dout.writeLong(JOURNAL_MAGIC);
        if (syncJournal) {
            dout.flush();
            fout.getFD().sync();
        }
        dout.close();
    }



    public void close()  throws IOException {
        rwLock.writeLock().lock();
        try {
            raf.close();
        } finally {
            rwLock.writeLock().unlock();
        }
    }

    public DiskNodeStats stats() {
        return stats;
    }

    @Override
    protected PersistentBitSet allocatedBitSet() {
        return allocatedBitSet;
    }

    @Override
    protected void incrementCacheHit() {
        stats.incrementCacheHit();
    }

    @Override
    protected void incrementCacheMiss() {
        stats.incrementCacheMiss();
    }

    @Override
    protected Object treeId() {
        return absolutePath;
    }

}
