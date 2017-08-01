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

package gov.nasa.kepler.fs.server.xfiles;

import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;
import gnu.trove.TDoubleArrayList;
import gnu.trove.TFloatArrayList;
import gnu.trove.TLongArrayList;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.btree.BTree;
import gov.nasa.kepler.fs.server.index.btree.BtreeNode;
import gov.nasa.kepler.fs.server.index.btree.InvalidBtreeException;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.journal.RandomAccessJournalReader;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWrite;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.spiffy.common.collect.Cache;
import gov.nasa.spiffy.common.collect.LruCache;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;
import java.util.SortedMap;
import java.util.TreeMap;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.ReentrantLock;

import javax.transaction.xa.Xid;

import org.apache.commons.lang.ArrayUtils;

/**
 * @author Sean McCauliff
 *
 */
public class TransactionalMjdTimeSeriesFile extends TransactionalFile {

    /**
     * The file format version.
     * 1 - Initial format version.
     * 2 - Add delete flag to journal.
     * 3 - Move to btree storage.
     */
    @SuppressWarnings("unused")
    private static final byte VERSION = 3;
    private static final long FILE_IS_DELETED_JENTRY = -1;
    private static final long BTREE_DATA_JENTRY = -2;
    private static final long USER_DATA_JENTRY = -3;
    
    private static final MjdDataPointIo keyValueIo = new MjdDataPointIo();
    private static final int NODE_SIZE = 1024*4;
    private static final int BTREE_CACHE_SIZE = 16;
    private static final int btreeT = 72;
    private static final Comparator<Double> keyComp = new DoubleComparator();
    
    private final SortedMap<Xid, TransactionContext> xactions =
        Collections.synchronizedSortedMap(new TreeMap<Xid,TransactionContext>(XidComparator.INSTANCE));
    
    private final RandomAccessStorage storage;
    /**
     * When true file has been initialized.
     */
    private boolean initDone = false;
    
    /**
     * Create a new instance of a TransactionalMjdTimeSeriesFile.  There should
     * only be one instance of a TransactionalMjdTimeSeriesFile per FsId.
     * 
     * @param rootDir
     * @param id
     * @param storage
     * @return
     * @throws IOException
     */
    static TransactionalMjdTimeSeriesFile loadFile(RandomAccessStorage storage)
        throws IOException {
        
        return new TransactionalMjdTimeSeriesFile(storage);
    }
    

    /**
     * 
     * @param storage non-null
     * @param isCommit When true this this is being used during commit time.
     * @return
     */
    static Recovery recoverFile(RandomAccessStorage storage, boolean isCommit) {
        return new Recovery(storage, isCommit);
    }
    
    /**
     * Non-transactionally read from the cosmic ray file.  This does not read
     * any non-committed data.
     * 
     * @param storage
     * @return
     */
    static MjdTimeSeriesReader readFile(RandomAccessStorage storage) {
        return new MjdTimeSeriesReader(storage);
    }
    
    private TransactionalMjdTimeSeriesFile(RandomAccessStorage storage) {
        super();
        this.storage = storage;
        try {
            initDone = !storage.isNew();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }

    private static Cache<CacheNodeKey, BtreeNode<Double,MjdBtreeValue>> tmpBtreeCache() {
        return new LruCache<CacheNodeKey, BtreeNode<Double,MjdBtreeValue>>(BTREE_CACHE_SIZE);
    }
   
    
    private static BTree<Double,MjdBtreeValue> tmpTree(MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io) throws IOException {
        return new BTree<Double, MjdBtreeValue>(io, btreeT, keyComp);
    }


    private MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> tmpNodeIo() {
        MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io = 
            new MjdTimeSeriesBtreeIo<Double, MjdBtreeValue>(keyValueIo, NODE_SIZE, tmpBtreeCache(), storage);
        return io;
    }
    
    private static FloatMjdTimeSeries seriesFromTree(Iterator<Pair<Double,MjdBtreeValue>> it, double start, double end, FsId id) {
        TDoubleArrayList mjdList = new TDoubleArrayList();
        TLongArrayList originatorList = new TLongArrayList();
        TFloatArrayList valueList = new TFloatArrayList();
     
        while (it.hasNext()) {
            Pair<Double,MjdBtreeValue> kv = it.next();
            if (kv.left > end) {
                break;
            }
            mjdList.add(kv.left);
            originatorList.add(kv.right.originator());
            valueList.add(kv.right.value());
        }
        
        if (mjdList.isEmpty()) {
            return  FloatMjdTimeSeries.emptySeries(id, start, end, true);
        }
        
        return new FloatMjdTimeSeries(id, start, end,
                mjdList.toNativeArray(), valueList.toNativeArray(), originatorList.toNativeArray(), true);
    }
    

    /**
     * Initialize storage to the empty tree.
     * 
     * @throws IOException
     */
    private synchronized void initStorage() throws IOException {
        if (initDone) {
            return;
        }
        
        MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io = null;
        try {
            io = tmpNodeIo();
            @SuppressWarnings("unused")
            BTree<Double, MjdBtreeValue> tree = tmpTree(io);
        } finally {
            FileUtil.close(io);
        }
        initDone = true;
    }
    
    @Override
    public FsId id() {
        return storage.fsId();
    }
    
    @Override
    protected final int lockTimeOutForTransaction(Xid xid) {
        return findContex(xid).timeOutSeconds;
    }
    
    /**
     * Start a transaction with this file.
     * 
     * @param xid This may not be null.
     * @param timeOutSeconds The number of seconds to wait for a busy
     * lock.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    void beginTransaction(Xid xid, JournalWriter journalWriter,  int timeOutSeconds) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        
        acquireReadLock(xid, timeOutSeconds);
        try {
            synchronized (xactions) {
                if (xactions.containsKey(xid)) {
                    return;
                }
                TransactionContext context = new TransactionContext(timeOutSeconds, journalWriter);
                xactions.put(xid, context);
            }
        } finally {
            releaseReadLock(xid);
        }
    }
    
    /**
     * 
     * @param series
     * @param overwrite
     * @param xid
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     * @throws IOException
     */
    public void write(FloatMjdTimeSeries series, boolean overwrite, Xid xid)
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
        if (series == null) {
            throw new NullPointerException("series may not be null");
        }
        if (xid == null) {
            throw new NullPointerException("xid may not be null");
        }
        
        TransactionContext context = findContex(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            initStorage();
            context.write(series, overwrite);
        } finally {
            releaseReadLock(xid);
        }
        
    }


    @Override
    protected void doCommit(Xid xid) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {

        TransactionContext context = findContex(xid);
        NonContiguousReadWrite dataRw = null;
        try {
            context.commit();
            xactions.remove(xid);
            
            if (context.isDeleted) {
                if (xactions.size() == 0) {
                    storage.delete(true);
                } else {
                    boolean realDelete = true;
                    for (TransactionContext other : xactions.values()) {
                        if (!other.isDirty()) {
                            other.delete();
                        } else {
                            realDelete = false;
                        }
                    }

                    storage.delete(realDelete);
                    
                    if (!realDelete) {
                        //outstanding reads will read from cleanly initialized data
                        initDone = false;
                        initStorage();
                    }
                }
            }
        } finally {
            FileUtil.close(dataRw);
        }

    }


    @Override
    boolean knowsTransaction(Xid xid) {
        return xactions.containsKey(xid);
    }

    @Override
    protected final void doPrepare(Xid xid) throws IOException, InterruptedException,
        FileStoreTransactionTimeOut {

        TransactionContext context = findContex(xid);
        initStorage();
        context.prepare();
    }


    @Override
    protected final void doRollback(Xid xid) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {
        findContex(xid);
        
        initStorage();
        xactions.remove(xid);

    }
    
    @Override
    protected final void doCleanRollback(Xid xid) throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext context = findContex(xid);
        if (context.isDirty()) {
            throw new IllegalStateException("Transaction \"" + xid + "\" has dirtied \"" + id() + "\", expected clean.");
        }
        xactions.remove(xid);
    }
    
    @Override
    boolean hasTransactions() {
        return !xactions.isEmpty();
    }
    
    private TransactionContext findContex(Xid xid) {
        TransactionContext context = xactions.get(xid);
        if (context == null) {
            throw new IllegalArgumentException("Transaction \"" + xid  +
                "\" has not been started with fsid \"" + id() + "\".");
        }
        return context;
    }
    
    @Override
    public void delete(Xid xid) throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        if (xid == null) {
            throw new NullPointerException("Xid may not be null.");
        }
        
        TransactionContext context = findContex(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            context.delete();
        } finally {
            releaseReadLock(xid);
        }
    }
    
    public FloatMjdTimeSeries read(double start, double end, Xid xid) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
        if (xid == null) {
            throw new NullPointerException("Xid may not be null.");
        }
        if (end < start) {
            throw new IllegalArgumentException("End may not come before start.");
        }
        
        TransactionContext context = findContex(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io = null;
        try {
            if (context.isDeleted()) {
                throw new FileStoreIdNotFoundException(id(), "FsId has been deleted.");
            }
            initStorage();
            io = tmpNodeIo();
            BTree<Double,MjdBtreeValue> tree = tmpTree(io);
            
            context.doMerge(tree, start, end);
            
            tree.checkTree();
            //System.out.println(tree.toDot());
            return seriesFromTree(tree.iterateFrom(start), start, end, id());
        } catch (InvalidBtreeException bad) {
            throw new InvalidBtreeException(id().toString(), bad);
        } finally {
            FileUtil.close(io);
            releaseReadLock(xid);
        }
    }

    @Override
    boolean isDirty(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext context = findContex(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            return context.isDirty();
        } finally {
            releaseReadLock(xid);
        }
    }
    
    public static void dumpTree(@SuppressWarnings("rawtypes") BTree tree, String fname) throws IOException {
        BufferedWriter bwriter = new BufferedWriter(new FileWriter("/tmp/" + fname));
        bwriter.write(tree.toDot());
        bwriter.close();
    }
    
    private class TransactionContext {
        private final int timeOutSeconds;
        private final ReentrantLock xlock = new ReentrantLock();
        private final TLongArrayList journalLocations = new TLongArrayList(1);
        private final JournalWriter journalWriter;
        private boolean isDeleted = false;
        TransactionContext(int timeOutSeconds, JournalWriter journalWriter) {
        
            this.timeOutSeconds = timeOutSeconds;
            this.journalWriter = journalWriter;
        }
        
        void delete() throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            try {
                if (isDeleted) {
                    return;
                }
                isDeleted = true;
                journalWriter.write(id(), FILE_IS_DELETED_JENTRY, ArrayUtils.EMPTY_BYTE_ARRAY,0, 0);
            } finally {
                releaseLock();
            }
        }

        boolean isDirty() throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                return journalLocations.size() != 0 || isDeleted;
            } finally {
                releaseLock();
            }
        }
        
        
        void prepare() throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            
            DataOutputStream dout = null;
            MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io = null;
            try {
                if (isDeleted) {
                    return;
                }
                if (journalLocations.size() == 0) {
                    return;
                }
                io = tmpNodeIo();
                BTree<Double,MjdBtreeValue> tree = tmpTree(io);
              
                doMerge(tree, -Double.MAX_VALUE, Double.MAX_VALUE);
                
                Pair<Long,DataOutputStream> pair = journalWriter.outputStream(id(), BTREE_DATA_JENTRY);
                dout = pair.right;
                io.flushToJournal(dout);
                dout.flush();
                journalLocations.add(pair.left);
            } finally {
                FileUtil.close(io);
                FileUtil.close(dout);
                releaseLock();
            }
        }
        
        /** Merges changes into the btree without writing them to disk.
         * 
         * @param mergeStart If the journaled writes are not within [mergeStart,mergeEnd] then
         * the entry will not be merged.
         * 
         * @param mergeEnd
         * @throws FileStoreTransactionTimeOut
         * @throws InterruptedException
         * @throws IOException
         */
        void doMerge(BTree<Double,MjdBtreeValue> tree, double mergeStart, double mergeEnd)
            throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            
            RandomAccessJournalReader jReader = null;
            try {
                checkDelete();

                if (journalLocations.isEmpty()) {
                	return;
                }
                journalWriter.flush();
                
                File journalFile = journalWriter.file();
                
                jReader = new RandomAccessJournalReader(journalFile);
                for (int i=0; i < this.journalLocations.size(); i++) {
                    long location = journalLocations.get(i);
                    JournalEntry jentry = jReader.read(location);
                    
                    mergeEntry(tree, jentry, mergeStart, mergeEnd);
                }
            } finally {
                FileUtil.close(jReader);
                releaseLock();
            }
        }

        private void mergeEntry(BTree<Double,MjdBtreeValue> tree, JournalEntry jentry, 
                                double mergeStart, double mergeEnd) throws IOException {
            DataInputStream din = new DataInputStream(new ByteArrayInputStream(jentry.data()));
            final boolean overwrite = din.readBoolean();
            final double dataStart = din.readDouble();
            final double dataEnd = din.readDouble();
            Double lastErasedKey = null;
            if (mergeEnd < dataStart) {
                return;
            }
            if (dataEnd < mergeStart) {
                return;
            }
            
            try {
                if (overwrite) {
                    List<Double> eraseKeys = new ArrayList<Double>();
                    Iterator<Pair<Double,MjdBtreeValue>> it = tree.iterateFrom(dataStart);
                    while (it.hasNext()) {
                        Pair<Double,MjdBtreeValue> point = it.next();
                        if (point.left > mergeEnd || point.left > dataEnd) {
                            break;
                        }
                        eraseKeys.add(point.left);
                    }
                    
                    for (Double mjd : eraseKeys) {
                        lastErasedKey = mjd;
                        tree.delete(mjd);
                    }
                }
    
                tree.checkTree();
                
                final int npoints = din.readInt();
                for (int i=0; i < npoints; i++) {
                    long originator = din.readLong();
                    double mjd = din.readDouble();
                    float value = din.readFloat();
                    
                    if (mjd < mergeStart) {
                        continue;
                    }
                    if (mjd > mergeEnd) {
                        break;
                    }
                    
                    tree.insert(mjd, new MjdBtreeValue(originator, value));
                }
                tree.checkTree();
            } catch (NoSuchElementException first) {
                NoSuchElementException second = 
                        new NoSuchElementException("FsId: " + id() +
                                " dataStart: " + dataStart +
                                " dataEnd: " + dataEnd + "lastErasedPoint: " +
                                " lastErasedKey: " + lastErasedKey);
                second.initCause(first);
                throw second;
            } catch (InvalidBtreeException bad) {
                String fsIdStr = id().toString();
                fsIdStr = fsIdStr.replace('/', 'K');
                FileOutputStream fout = new FileOutputStream("/tmp/invalid-btree-dump-" + fsIdStr);
                fout.write(jentry.data());
                fout.close();
                throw new InvalidBtreeException(id().toString(), bad);
            }
        }
        
        void write(FloatMjdTimeSeries series, boolean overwrite) 
            throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            
            DataOutputStream dout = null;
            try {
                checkDelete();
                Pair<Long,DataOutputStream> pair = 
                    journalWriter.outputStream(id(), USER_DATA_JENTRY);
                dout = pair.right;
                writeSeries(series, dout, overwrite);
                journalLocations.add(pair.left);
            } finally {
                FileUtil.close(dout);
                releaseLock();
            }
        }
        
        
        void commit() throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            try {
                if (isDeleted) {
                    return;
                }
                if (journalLocations.size() == 0) {
                    return;
                }
                storage.markOld();
            } finally {
                releaseLock();
            }
        }
        
     
        boolean isDeleted() throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                return isDeleted;
            } finally {
                releaseLock();
            }
        }
        
        private void acquireLock() throws InterruptedException, FileStoreTransactionTimeOut {
            if (!xlock.tryLock(timeOutSeconds, TimeUnit.SECONDS)) {
                throw new FileStoreTransactionTimeOut("Transactioned timed out waiting for TransactionContext lock.");
            }
        }
        
        private void releaseLock() {
            xlock.unlock();
        }
        
        private void checkDelete() {
            if (isDeleted) {
                throw new FileStoreIdNotFoundException(id(), "Mjd time series has been removed with delete().");
            }
        }
    }
    
    private static class DoubleComparator implements Comparator<Double> {
        public int compare(Double d1, Double d2) {
            return Double.compare(d1, d2);
        }
    }
    
    /**
     * Non-transactional reading. This is useful when the file store server is 
     * not running, but you want to read the data out of the files.
     * 
     * @author Sean McCauliff
     *
     */
    public static class MjdTimeSeriesReader {
        private final RandomAccessStorage storage;
        
        MjdTimeSeriesReader(RandomAccessStorage storage) {
            this.storage = storage;
        }
        
        public FloatMjdTimeSeries readSeries() throws IOException {
            MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io = 
                new MjdTimeSeriesBtreeIo<Double, MjdBtreeValue>(keyValueIo, NODE_SIZE, tmpBtreeCache(), storage);
            BTree<Double, MjdBtreeValue> tree = new BTree<Double, MjdBtreeValue>(io, btreeT, keyComp);
            
            FloatMjdTimeSeries rv = seriesFromTree(tree.iterator(), -Double.MAX_VALUE, Double.MAX_VALUE, storage.fsId());
          
            io.close();
            
            return rv;
        }
    }
    
    /**
     * Use this to restore a TransactionalCosmicRayFile to a consistent state
     * if a commit had been in progress.  This class is not MT-safe.
     * 
     * @author Sean McCauliff
     *
     */
    final static class Recovery implements RandomAccessRecovery {
        private final RandomAccessStorage storage;
        private volatile boolean isDeleted = false;
        private final boolean isCommit;
        private volatile long lastJournalEntryAddress = -1;
        private volatile FsId fsIdFromJournal = null;
            
        
        /**
         * @param storage
         * @param isCommit
         */
        private Recovery(RandomAccessStorage storage, boolean isCommit) {
            if (storage == null) {
                throw new NullPointerException("storage");
            }
            this.storage = storage;
            this.isCommit = isCommit;
        }
        
        /**
         * Merges journal entries into the destination b-tree file.
         * 
         * @param jentry
         * @throws InterruptedException 
         */
        public void mergeRecovery(JournalEntry jentry) throws IOException, InterruptedException {
            
            if (jentry.entryLocation() < lastJournalEntryAddress) {
                throw new IllegalStateException("Attempt to write old journal" +
                    " entry data over new journal entry data. FsId : " + 
                    jentry.fsId() + " current journal entry address: " + 
                    jentry.entryLocation() + " last seen FsId : " + 
                    fsIdFromJournal + " last journal entry address: " +
                    lastJournalEntryAddress );
            }

            lastJournalEntryAddress = jentry.entryLocation();
            if (fsIdFromJournal == null) {
                fsIdFromJournal = jentry.fsId();
            } else if (!fsIdFromJournal.equals(jentry.fsId())) {
                throw new IllegalStateException("Attempt to write data from incorrect fsId " +
                    "My fsId: " + fsIdFromJournal + " journal entry fsid " + 
                    jentry.fsId());
            }
            
            if (jentry.destStart() == USER_DATA_JENTRY) {
                //Nothing to do.
                return;
            }
            
            if (jentry.destStart() == FILE_IS_DELETED_JENTRY) {
                isDeleted = true;
                storage.delete(true);
            } else if ( jentry.destStart() == BTREE_DATA_JENTRY) {
                if (isDeleted) {
                    throw new IllegalStateException("Attempt to add data to a file that has been deleted.");
                }
                
                if (isCommit) {
                    storage.initAlreadyDone();
                }
                MjdTimeSeriesBtreeIo<Double, MjdBtreeValue> io = 
                    new MjdTimeSeriesBtreeIo<Double, MjdBtreeValue>(keyValueIo, NODE_SIZE, tmpBtreeCache(), storage);
                io.readFromJournal(new DataInputStream(new ByteArrayInputStream(jentry.data())));
                io.close();
            }
        }
        
        public void recoveryComplete() throws IOException {
            //ok.
        }
    }

    private static void writeSeries(FloatMjdTimeSeries mts, DataOutput dout, boolean overwrite) 
        throws IOException {
        int len = mts.mjd().length;
        long[] originators = mts.originators();
        double[] mjd = mts.mjd();
        float[] values = mts.values();
        
        dout.writeBoolean(overwrite);
        dout.writeDouble(mts.startMjd());
        dout.writeDouble(mts.endMjd());
        dout.writeInt(len);
        for (int i=0; i < len; i++) {
            dout.writeLong(originators[i]);
            dout.writeDouble(mjd[i]);
            dout.writeFloat(values[i]);
        }
    }

    @Override
    public boolean isDeleted(Xid xid) throws 
        FileStoreTransactionTimeOut, InterruptedException {

        TransactionContext context = findContex(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            return context.isDeleted();
        } finally {
            releaseWriteLock();
        }
    }

}
