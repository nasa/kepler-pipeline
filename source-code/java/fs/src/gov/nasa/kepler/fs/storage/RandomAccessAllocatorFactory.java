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
 * @author Sean McCauliff
 *
 */
public class RandomAccessAllocatorFactory implements StorageAllocatorFactory<RandomAccessAllocator> {

    private final DirectoryHashFactory dirHashFactory;
    /**
     * Maps the path part of the FsId to a TimeSeriesDirectoryHash.
     */
    private final Map<String, RandomAccessAllocator> cache = 
        new HashMap<String, RandomAccessAllocator>();
    

    public RandomAccessAllocatorFactory(DirectoryHashFactory dirHashFactory) {
        this.dirHashFactory = dirHashFactory;
    }
    

    /**
     * 
     * @param id  This uses the pathPart of the id to identify hashes.
     * @param timeOutSeconds  The number of seconds to wait.
     * @param create When true create new directory hashes has needed.
     * @param recover When true attempt to correct damaged hash 
     * directory structures.
     * @throws IOException 
     * @throws FileStoreException 

     */
    public synchronized RandomAccessAllocator findAllocator(FsId id, 
        boolean create, boolean recover) 
        throws IOException {
        
        String pathPart = id.path();
        RandomAccessAllocator allocator = cache.get(pathPart);
        if (allocator != null) {
            return allocator;
        }
        
        DirectoryHash dirHash = dirHashFactory.findDirHash(id,  create, recover);
        if (dirHash == null) {
            return null;
        }
        
        allocator = new RandomAccessAllocator(dirHash);
        cache.put(pathPart, allocator);
        return allocator;
    }
    
    public RandomAccessAllocator findAllocator(FsId id, boolean create)
        throws IOException {
        return findAllocator(id, create, false);
    }
    
    public RandomAccessAllocator findAllocator(FsId id) throws FileStoreException, IOException {
        return findAllocator(id,  false, false);
    }
    
    /**
     *  This is useful for testing.
     *   Removes all in-memory state.
     * @throws IOException 
     *
     */
    public synchronized void clear() throws IOException {
        for (RandomAccessAllocator allocator : cache.values()) {
            allocator.close();
        }
        cache.clear();
        dirHashFactory.clear();
    }
    
    @Override
    public synchronized Collection<RandomAccessAllocator> accessedAllocators() {
        List<RandomAccessAllocator> rv = new ArrayList<RandomAccessAllocator>();
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
