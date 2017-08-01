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

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.PersistentBitSet;
import gov.nasa.kepler.fs.server.index.btree.BtreeNode;
import gov.nasa.kepler.fs.server.raf.RandomAccessIo;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.spiffy.common.collect.Cache;
import gov.nasa.spiffy.common.io.FileUtil;


/**
 * Stores the Btree using the meta data storage for blocks used and the primary data
 * for the tree blocks.
 * 
 * Even though the super class is MT-safe this class is not MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public final class MjdTimeSeriesBtreeIo<K,V> extends AbstractDiskNodeIO<K, V, BtreeNode<K, V>> {

    private RandomAccessIo data;
    private PersistentBitSet allocatedBitSet;
    private final RandomAccessStorage storage;;
    
    public MjdTimeSeriesBtreeIo(KeyValueIO<K, V> kvio, int nodeSize,
        Cache<CacheNodeKey, BtreeNode<K, V>> nodeCache,
        RandomAccessStorage storage) {
        super(kvio, nodeSize, nodeCache, (BtreeNode.Factory<K,V>) BtreeNode.Factory.instance());
        this.storage = storage;
    }

    @Override
    protected PersistentBitSet allocatedBitSet() {
        //Lazy allocation of bit set, because pure reads do not need it.
        if (allocatedBitSet == null) {
            try {
                allocatedBitSet = new PersistentBitSet(storage.metaDataRw());
            } catch (IOException e) {
                throw new IllegalStateException("Failed to open persistent bit set storage for FsId \"" + 
                    storage.fsId() + "\".", e);
            }
        }
        return allocatedBitSet;
    }

    /**
     * This implementation does not track cache performance.
     */
    @Override
    protected void incrementCacheHit() {
        //This does nothing.  
    }

    /**
     * This implementation does not track cache performance.
     */
    @Override
    protected void incrementCacheMiss() {
        //This does nothing.
    }

    @Override
    protected RandomAccessIo storage() {
        if (data == null) {
            try {
                data = storage.dataRw();
            } catch (IOException e) {
                throw new IllegalStateException("Failed to open data storage for FsId \"" +
                            storage.fsId() + "\".", e);
            }
        }
        return data;
    }

    @Override
    protected Object treeId() {
        return storage.fsId();
    }

    @Override
    public void close() throws IOException {
        FileUtil.close(allocatedBitSet);
        allocatedBitSet = null;
        FileUtil.close(data);
        data = null;
    }

    /**
     * Writes the in-memory state to the data stream.
     */
    @Override
    public void flushPendingModifications() throws IOException {
        for (IOOp ioop : ioOps().values()) {
            ioop.doOp();
        }
        clearDirtyState();
    }

    /**
     * Write in-memory state to the specified journal.
     * 
     * @param dout
     * @throws IOException
     */
    public void flushToJournal(DataOutput dout) throws IOException {
        for (IOOp ioop : ioOps().values()) {
            ioop.writeToJournal(dout);
        }
        dout.writeInt(IOOpType.JOURNAL_END.ordinal());
    }
    
    /**
     * Merges the journal with the in-memory state.
     * 
     * @param din
     * @throws IOException
     */
    public void readFromJournal(DataInput din) throws IOException {
        executeOpFromJournal(din);
        clearDirtyState();
    }

    @Override
    public void setRootNodeAddress(long newRootAddress) {
        throw new UnsupportedOperationException();
    }
}
