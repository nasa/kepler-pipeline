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

package gov.nasa.kepler.fs.storage;

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import gnu.trove.TIntHashSet;
import gnu.trove.TIntIterator;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.kepler.fs.server.index.DiskNodeIO.BtreeFileVersion;
import gov.nasa.kepler.fs.server.index.blinktree.*;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;

import java.io.File;
import java.io.IOException;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * A base class for storage allocators. Storage allocators allocate one or more
 * lanes in a file for an FsId.  
 * This class is MT-safe.  Do not use synchronized to coordinate access to this
 * class.
 * 
 * @author Sean McCauliff
 * 
 */
public abstract class AbstractStorageAllocator implements StorageAllocatorInterface  {

    /**
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(AbstractStorageAllocator.class);

    private static final String OLD_INDEX_NAME = "idindex.t69";
    private static final String INDEX_NAME = "idindex.blink";
    private static final String SEQUENCE_NAME = "seq";
    protected static final byte IDS_PER_CONTAINER = (byte) 64;
    public static final int DISK_PTR_SIZE = 8;
    public static final int BTREE_NODE_SIZE = 1024 * 16;

    
    /**
     * The maximum number of nodes to cache in memory.
     */
    
    private final static int MAX_CACHE;
    
    private final static boolean syncBtreeJournal;


    static {
        Configuration config = ConfigurationServiceFactory.getInstance();
        MAX_CACHE = config.getInt(FS_SERVER_MAX_BTREE_NODE_CACHE_PROPERTY,
            FS_SERVER_MAX_BTREE_NODE_CACHE_DEFAULT);

        syncBtreeJournal = config.getBoolean(FS_SERVER_SYNC_BTREE_JOURNAL,
            FS_SERVER_SYNC_BTREE_JOURNAL_DEFAULT);
    }
    
    private final static ConcurrentLruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>> cache =
        new ConcurrentLruCache<CacheNodeKey, BLinkNode<FsId,FsIdInfo>>(MAX_CACHE);

    protected final DirectoryHash dirHash;

    protected final BLinkTree<FsId, FsIdInfo> fsIdToFileName;
    private final NodeLockFactory nodeLockFactory = new NodeLockFactory();
    
    private final DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>> btreeDiskIo;

    protected final PersistentSequence sequence;

    private final AtomicInteger outstandingChanges = new AtomicInteger();

    
    protected AbstractStorageAllocator(DirectoryHash dirHash)
        throws IOException {
        
        this.dirHash = dirHash;
        File oldIndexFile = new File(dirHash.rootDir(), OLD_INDEX_NAME);
        File indexFile = new File(dirHash.rootDir(), INDEX_NAME);
        if (oldIndexFile.exists() && !indexFile.exists()) {
            throw new IllegalStateException("Unconverted index \"" 
                                            + oldIndexFile + "\".");
        }
        File sequenceFile = new File(dirHash.rootDir(), SEQUENCE_NAME);
        sequence = new PersistentSequence(sequenceFile);
        int btreeLeafM = LeafNode.leafM(getKeyValueIo(), BTREE_NODE_SIZE);
        int btreeInternalM = InternalNode.internalM(getKeyValueIo(), BTREE_NODE_SIZE);
        TreeNodeFactory<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>>nodeFactory = 
            BLinkNode.nodeFactory(nodeLockFactory, FsId.comparator);
        btreeDiskIo = new DiskNodeIO<FsId, FsIdInfo,BLinkNode<FsId,FsIdInfo>>(getKeyValueIo(), indexFile,
            BTREE_NODE_SIZE, cache, nodeFactory,
            BtreeFileVersion.VERSION_1);
        
        fsIdToFileName = 
            new BLinkTree<FsId, FsIdInfo>(btreeDiskIo, btreeLeafM, 
                btreeInternalM, FsId.comparator, nodeLockFactory);
        
        btreeDiskIo.setJournalSync(syncBtreeJournal);
    }
    
    protected abstract KeyValueIO<FsId, FsIdInfo> getKeyValueIo();

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#locationFor(gov.nasa.kepler.fs.server.scheduler.FsIdOrder)
	 */
    @Override
	public abstract FsIdLocation locationFor(FsIdOrder id) throws IOException, FileStoreException, InterruptedException;
    
    /**
     * This is here to periodically flush the btree when it is in a consistent
     * state.  Locking the tree completely before flushing ensures that no
     * inserters or deleters are updating the tree during a write to disk.
     * @throws IOException
     * @throws InterruptedException 
     */
    protected final void btreeChange() throws IOException, InterruptedException {
        int changeNumber = outstandingChanges.incrementAndGet();
        if (changeNumber % IDS_PER_CONTAINER != 0) {
            return;
        }
        
        commitPendingModifications();
       
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#close()
	 */
    @Override
	public void close() throws IOException {
        btreeDiskIo.close();
        sequence.close();
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#markIdsPersistent(java.util.Collection)
	 */
    @Override
	public void markIdsPersistent(Collection<FsId> ids) throws IOException, InterruptedException {

        // Sorting is not required, but this will improve disk access time.
        List<FsId> sortedList = new ArrayList<FsId>(ids);
        Collections.sort(sortedList);

        for (FsId id : sortedList) {
            FsIdInfo oldInfo = null;
                oldInfo = fsIdToFileName.find(id);
            if (oldInfo == null) {
                continue;
            }
            if (oldInfo.isNew()) {
                FsIdInfo newInfo = oldInfo.setNew(false);
                fsIdToFileName.insert(id, newInfo);
                btreeChange();
            }
        }
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#commitPendingModifications()
	 */
    @Override
	public final void commitPendingModifications() throws IOException, InterruptedException {
        fsIdToFileName.lock();
        try {
            btreeDiskIo.flushPendingModifications();
        } finally {
            fsIdToFileName.unLock();
        }
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#removeAllNewIds(java.util.Collection)
	 */
    @Override
	public void removeAllNewIds(Collection<FsId> deleteMe)
        throws IOException, InterruptedException {
      
        //Don't delete while we are using an iterator so assemble the list
        //of ids and then delete.
        if (deleteMe == null) {
            deleteMe = new LinkedList<FsId>();
            for (Map.Entry<FsId, FsIdInfo> kvp : fsIdToFileName) {
                if (kvp.getValue().isNew()) {
                    deleteMe.add(kvp.getKey());
                }
            }
        }

        if (deleteMe.isEmpty()) {
            return;
        }
        
        for (FsId id : deleteMe) {
            FsIdInfo info = fsIdToFileName.find(id);
            if (info == null) {
                continue;
            }
            if (!info.isNew()) {
                continue;
            }

            fsIdToFileName.delete(id);
            btreeChange();
        }
        
        commitPendingModifications();
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#removeAllNewIds()
	 */
    @Override
	public void removeAllNewIds() throws IOException, InterruptedException {

        removeAllNewIds(null);
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#findIds()
	 */
    @Override
	public Set<FsId> findIds() {
        Set<FsId> rv = new HashSet<FsId>();
        for (Map.Entry<FsId, FsIdInfo> kv : fsIdToFileName) {
            rv.add(kv.getKey());
        }
        return rv;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#findNewIds()
	 */
    @Override
	public Set<FsId> findNewIds() {

        Set<FsId> rv = new HashSet<FsId>();
        for (Map.Entry<FsId, FsIdInfo> kv : fsIdToFileName) {
            if (kv.getValue().isNew()) {
                rv.add(kv.getKey());
            }
        }
        return rv;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#hasSeries(gov.nasa.kepler.fs.api.FsId)
	 */
    @Override
	public boolean hasSeries(FsId id) throws IOException, InterruptedException {
        return fsIdToFileName.find(id) != null;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#removeId(gov.nasa.kepler.fs.api.FsId)
	 */
    @Override
	public void removeId(FsId id) throws IOException, InterruptedException {

        FsIdInfo fileInfo = fsIdToFileName.find(id);
        if (fileInfo == null) {
            return;
        }

        fsIdToFileName.delete(id);
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#isNew(gov.nasa.kepler.fs.api.FsId)
	 */
    @Override
	public boolean isNew(FsId id) throws IOException, InterruptedException {
        FsIdInfo info = fsIdToFileName.find(id);
        if (info == null || info.isNew()) {
            return true;
        }
        return false;
    }

    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#isAllocated(gov.nasa.kepler.fs.api.FsId)
	 */
    @Override
	public abstract boolean isAllocated(FsId id) throws IOException,
        InterruptedException;

    @Override
    public void setNewState(FsId id, boolean state) throws IOException, InterruptedException {
        FsIdInfo info = fsIdToFileName.find(id);
        if (info == null) {
            throw new IllegalStateException("Can't find id \"" + id + "\".");
        }
        
        info = info.setNew(state);
        fsIdToFileName.insert(id, info);
        btreeChange();
    }

    public static void testClearBtreeCache() {
    	cache.clear();
    }
    
    /* (non-Javadoc)
	 * @see gov.nasa.kepler.fs.storage.StorageAllocatorInterface#gcFiles()
	 */
    @Override
	public void gcFiles() throws IOException, InterruptedException {
        Set<String> strFileIds = dirHash.findAllIds();
        TIntHashSet fileIds = new TIntHashSet();
        for (String s : strFileIds) {
            fileIds.add(Integer.parseInt(s));
        }

        fsIdToFileName.lock();
        try {
            Iterator<Map.Entry<FsId, FsIdInfo>> it = fsIdToFileName.iterator();
            while (it.hasNext()) {
                Map.Entry<FsId, FsIdInfo> pair = it.next();
                int[] idsInUse = pair.getValue().fileIds();
                for (int id : idsInUse) {
                    fileIds.remove(id);
                }
            }
    
            TIntIterator gcIt = fileIds.iterator();
            while (gcIt.hasNext()) {
                int id = gcIt.next();
                File f = dirHash.idToFile(Integer.toString(id));
                if (log.isDebugEnabled()) {
                    log.debug("File \"" + f + "\" is garbage collected.");
                }
                if (!f.delete()) {
                    log.warn("Failed to delete garbage file \"" + f
                        + "\".  This may result in excessive disk usage.");
                }
            }
        } finally {
            fsIdToFileName.unLock();
        }
    }

}
