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

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.TreeNodeFactory;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.DiskNodeIO.BtreeFileVersion;
import gov.nasa.kepler.fs.server.index.blinktree.BLinkNode;
import gov.nasa.kepler.fs.server.index.blinktree.BLinkTree;
import gov.nasa.kepler.fs.server.index.blinktree.InternalNode;
import gov.nasa.kepler.fs.server.index.blinktree.LeafNode;
import gov.nasa.kepler.fs.server.index.blinktree.NodeLockFactory;
import gov.nasa.kepler.fs.server.journal.ConcurrentJournalWriter;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;
import gov.nasa.kepler.fs.storage.DirectoryHash;
import gov.nasa.kepler.fs.storage.DirectoryHashFactory;
import gov.nasa.kepler.fs.storage.FsIdInfo;
import gov.nasa.kepler.fs.storage.LaneAddressSpace;
import gov.nasa.kepler.fs.storage.MjdContainerFileStorage;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator.RandomAccessFsIdInfo;
import gov.nasa.kepler.fs.storage.StorageAllocatorInterface;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator.RandomAccessKeyValueIo;
import gov.nasa.spiffy.common.collect.LruCache;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.atomic.AtomicReference;

public class MjdTimeSeriesChecker {

	private final static int INDEX_FILE_NODE_SIZE = 1024 * 16;
	private static final int LOG_MOD = 1024;

	private static final StorageAllocatorInterface fakeAllocator = new StorageAllocatorInterface() {
		
		@Override
		public void setNewState(FsId id, boolean b) throws IOException,
				InterruptedException {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public void removeId(FsId id) throws IOException, InterruptedException {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public void removeAllNewIds() throws IOException, InterruptedException {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public void removeAllNewIds(Collection<FsId> ids) throws IOException,
				InterruptedException {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public void markIdsPersistent(Collection<FsId> ids) throws IOException,
				InterruptedException {

			//ignored
		}
		
		@Override
		public FsIdLocation locationFor(FsIdOrder id) throws IOException,
				FileStoreException, InterruptedException {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public boolean isNew(FsId id) throws IOException, InterruptedException {
			return false;
		}
		
		@Override
		public boolean isAllocated(FsId id) throws IOException,
				InterruptedException {
			return true;
		}
		
		@Override
		public boolean hasSeries(FsId id) throws IOException, InterruptedException {
			return true;
		}
		
		@Override
		public void gcFiles() throws IOException, InterruptedException {
			throw new UnsupportedOperationException();
		}
		
		@Override
		public Set<FsId> findNewIds() {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public Set<FsId> findIds() {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public boolean doesStorageTrackLength() {
			return true;
		}
		
		@Override
		public void commitPendingModifications() throws IOException,
				InterruptedException {

			throw new UnsupportedOperationException();
		}
		
		@Override
		public void close() throws IOException {

			throw new UnsupportedOperationException();
		}
	};
	
	private static File dataDir;
	private static File metaDir;
	private static RandomAccessFsIdInfo lastFsIdInfo = null;
	
    public static void main(String[] argv) throws Exception {
        File indexFile = new File(argv[0]);
        
        LruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>> destCache = 
            new LruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>>(256);
        
        KeyValueIO<FsId, FsIdInfo> keyValueIo = new RandomAccessKeyValueIo();
        NodeLockFactory lockFactory = new NodeLockFactory();
        TreeNodeFactory<FsId, FsIdInfo, BLinkNode<FsId, FsIdInfo>> destNodeFactory = 
            BLinkNode.nodeFactory(lockFactory, FsId.comparator);
        
        DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>> destIo =
            new DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>>(
                keyValueIo, indexFile, INDEX_FILE_NODE_SIZE, destCache, destNodeFactory,
                BtreeFileVersion.VERSION_1);
        
        final int leafM = LeafNode.leafM(keyValueIo, INDEX_FILE_NODE_SIZE);
        final int internalM = InternalNode.internalM(keyValueIo, INDEX_FILE_NODE_SIZE);
        
        BLinkTree<FsId, FsIdInfo> srcTree = 
            new BLinkTree<FsId, FsIdInfo>(destIo, leafM,
                internalM, FsId.comparator, lockFactory);
        
        int nthSeries = 0;
        for (Map.Entry<FsId, FsIdInfo> entry : srcTree) {
           try {
        	   if ((nthSeries % LOG_MOD) == 0) {
        		   System.out.println("Processing series " + (nthSeries + 1));
        	   }
        	   RandomAccessFsIdInfo fsIdInfo = (RandomAccessFsIdInfo) entry.getValue();
        	   readAll(indexFile.getParentFile(), entry.getKey(), fsIdInfo);
        	   
           } catch (Throwable t) {
        	   System.err.println(entry.getKey() + "->" + entry.getValue());
        	   t.printStackTrace();
           } finally {
        	   nthSeries++;
           }
        }
    }
    
    private static void readAll(File baseDir, FsId id, final RandomAccessFsIdInfo fsIdInfo) throws Exception {
    	if (lastFsIdInfo == null || lastFsIdInfo.dataFileId != fsIdInfo.dataFileId ||
    			lastFsIdInfo.metaFileId == fsIdInfo.metaFileId) {
	    	final String dataName = fsIdInfo.dataFileId + ".data";
	    	final String metaName = fsIdInfo.metaFileId + ".data";
	
	    	List<File> files = FileUtil.find(new FileFilter() {
				
				@Override
				public boolean accept(File pathname)  {
						return pathname.getName().equals(dataName) ||
							pathname.getName().equals(metaName);
				}
			}, baseDir);
	    	
	    	
	    	for (File f : files) {
	    		if (f.getName().equals(dataName)) {
	    			dataDir = f.getParentFile();
	    		} else if (f.getName().equals(metaName)) {
	    			metaDir = f.getParentFile();
	    		}
	    	}
    		lastFsIdInfo = fsIdInfo;
    	}
     	LaneAddressSpace dataSpace =
     		new LaneAddressSpace(fsIdInfo.dataLane, RandomAccessAllocator.HEADER_SIZE, 64,  dataDir, fsIdInfo.dataFileId);
     	LaneAddressSpace metaSpace = new LaneAddressSpace(fsIdInfo.metaLane, RandomAccessAllocator.HEADER_SIZE, 64, metaDir, fsIdInfo.metaFileId);
     		
     	FakeXid fakeXid = new FakeXid(23423423, 4);
     	
     	RandomAccessStorage storage =
				new MjdContainerFileStorage(id, dataSpace, metaSpace, false, fakeAllocator);
		TransactionalMjdTimeSeriesFile xfile = 
				TransactionalMjdTimeSeriesFile.loadFile(storage);
		
		xfile.beginTransaction(fakeXid, null /* journalWriter */, 2);
		xfile.read(0, Double.MAX_VALUE, fakeXid);
		xfile.rollbackTransaction(fakeXid);

        
    }
}
