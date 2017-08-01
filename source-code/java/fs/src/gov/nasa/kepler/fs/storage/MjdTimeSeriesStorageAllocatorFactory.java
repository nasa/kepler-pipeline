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

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.fs.storage.DirectoryHashFactory.FoundFsIdPath;

import java.io.File;
import java.io.IOException;
import java.util.*;

/**
 * A factory for CosmicRayStorageAllocators.  There will be one allocator
 * per FsId path part.  This class is MT-safe.
 * 
 * TODO:  This is mostly duplicated code between this class and RandomAccessAllocatorFactory.
 * 
 * @author Sean McCauliff
 *
 */
public class MjdTimeSeriesStorageAllocatorFactory implements StorageAllocatorFactory<MjdTimeSeriesStorageAllocator>{
    
    private final DirectoryHashFactory dirHashFactory;
    /**
     * The key is the path of an FsId.
     */
    private final Map<String, MjdTimeSeriesStorageAllocator> cache =
        new HashMap<String, MjdTimeSeriesStorageAllocator>();
    
    public MjdTimeSeriesStorageAllocatorFactory(DirectoryHashFactory dirHashFactory) {
        this.dirHashFactory = dirHashFactory;
    }
    
    public MjdTimeSeriesStorageAllocator findAllocator(FsId id, boolean create) 
        throws FileStoreException, IOException {
        return findAllocator(id, create, true);
    }
    
    public MjdTimeSeriesStorageAllocator findAllocator(FsId id) throws IOException {
        return findAllocator(id, false, false);
    }
    
    public synchronized MjdTimeSeriesStorageAllocator findAllocator(FsId id, boolean create, boolean recover) 
        throws IOException {
        
        MjdTimeSeriesStorageAllocator allocator = cache.get(id.path());
        if (allocator != null) {
            return allocator;
        }
        
        DirectoryHash dirHash = dirHashFactory.findDirHash(id, create, recover);
        if (dirHash == null) {
            return null;
        }
        
        allocator = new MjdTimeSeriesStorageAllocator(dirHash);
        cache.put(id.path(), allocator);
        return allocator;
    }
    
    /**
     * Removes the in-memory state of the CosmicRayFactory.
     * @throws IOException 
     *
     */
    public synchronized void clear() throws IOException {
        for (MjdTimeSeriesStorageAllocator allocator : cache.values()) {
            allocator.close();
        }
        dirHashFactory.clear();
        cache.clear();
    }
    
    @Override
    public synchronized Collection<MjdTimeSeriesStorageAllocator> accessedAllocators() {
        List<MjdTimeSeriesStorageAllocator> rv = new ArrayList<MjdTimeSeriesStorageAllocator>();
        rv.addAll(cache.values());
        return rv;
    }
    
    public SortedSet<FsId> find(final QueryEvaluator qEval, final boolean recover)
        throws FileStoreException, IOException {
        
        FoundFsIdPath listFsIdsFromBTree = new FoundFsIdPath() {

            @Override
            public void foundDirectoryWithHash(FsId pathId, File dir, Collection<FsId> found)
            throws IOException, FileStoreException, InterruptedException {
                
                RandomAccessAllocator randomAccessAllocator =
                    findAllocator(pathId,  false, recover);
                
                if (qEval == null) {
                    found.addAll(randomAccessAllocator.findIds());
                    return;
                }
                
                //TODO:  could use some information from the name part of the
                //query to seek into the correct node in the b-tree
                Set<FsId> ids = randomAccessAllocator.findIds();
                for (FsId id : ids) {
                    if (qEval.match(id)) {
                        found.add(id);
                    }
                }
            }
        };
       
        return dirHashFactory.find(qEval, recover, listFsIdsFromBTree);
    }

}
