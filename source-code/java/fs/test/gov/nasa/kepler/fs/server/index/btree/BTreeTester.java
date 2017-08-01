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

package gov.nasa.kepler.fs.server.index.btree;

import java.io.File;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.storage.FsIdInfo;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator.RandomAccessKeyValueIo;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import static gov.nasa.kepler.fs.storage.AbstractStorageAllocator.*;
/**
 * Load an existing Btree and print some statistics about it.
 * @author Sean McCauliff
 *
 */
public class BTreeTester {

    /**
     * @param argv
     */
    public static void main(String[] argv) throws Exception {
        int maxCache = Integer.parseInt(argv[0]);
        ConcurrentLruCache<CacheNodeKey, BtreeNode<FsId, FsIdInfo>> cache =
            new ConcurrentLruCache<CacheNodeKey, BtreeNode<FsId,FsIdInfo>>(maxCache);
        File indexFile = new File(argv[1]);
        KeyValueIO<FsId, FsIdInfo> keyValueIo = new RandomAccessKeyValueIo();
        // Where 8 is the size of a disk node pointer. And 16 is the s
        int nEntries = (keyValueIo.keySize() + keyValueIo.valueSize() + DISK_PTR_SIZE)
            / (BTREE_NODE_SIZE - DISK_PTR_SIZE - BtreeNode.HEADER_SIZE);
        int btreeT = nEntries / 2;
        BtreeNode.Factory<FsId, FsIdInfo> nodeFactory = BtreeNode.Factory.instance();
        NodeIO<FsId, FsIdInfo,BtreeNode<FsId, FsIdInfo>> btreeDiskIo = new DiskNodeIO<FsId, FsIdInfo,BtreeNode<FsId,FsIdInfo>>(keyValueIo, indexFile,
            BTREE_NODE_SIZE, cache, nodeFactory);
        BTree<FsId, FsIdInfo>fsIdToFileName = new BTree<FsId, FsIdInfo>(btreeDiskIo, btreeT,
            FsId.comparator);

        double startTimeMs = System.currentTimeMillis();
        List<Pair<FsId, FsIdInfo>> all = new ArrayList<Pair<FsId, FsIdInfo>>(600000);
        for (Pair<FsId, FsIdInfo> pair : fsIdToFileName) {
                  all.add(pair);
        }
        double endTimeMs = System.currentTimeMillis();
        double elaspedTimeSec = (endTimeMs - startTimeMs) / 1000.0;
        System.out.println("Contains " + all.size() + " (key, value) pairs.");
        System.out.println("Time to iterate over all pairs: " + elaspedTimeSec + " seconds.");
        
        cache.clear();
        
        Random rand = new Random(887877);
        Collections.shuffle(all, rand);
        startTimeMs = System.currentTimeMillis();
        for (Pair<FsId, FsIdInfo> pair : all) {
            fsIdToFileName.find(pair.left);
        }
        endTimeMs = System.currentTimeMillis();
        elaspedTimeSec = (endTimeMs - startTimeMs) / 1000.0;
        double timePerAccessMs = (endTimeMs - startTimeMs) / (double) all.size();
        System.out.println("Random access over all pairs is " + elaspedTimeSec + " seconds.");
        System.out.println("Time per pair " + timePerAccessMs + " ms.");
    }

}
