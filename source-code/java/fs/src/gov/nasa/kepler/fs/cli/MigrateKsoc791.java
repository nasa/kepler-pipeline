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

package gov.nasa.kepler.fs.cli;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.btree.BTree;
import gov.nasa.kepler.fs.server.index.btree.BtreeNode;
import gov.nasa.kepler.fs.storage.FsIdInfo;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator.RandomAccessKeyValueIo;
import gov.nasa.spiffy.common.collect.LruCache;
import gov.nasa.spiffy.common.collect.Pair;

import static gov.nasa.kepler.fs.storage.AbstractStorageAllocator.BTREE_NODE_SIZE;

/**
 *  Moves btree with a T=0 to a btree with T=69.
 *  
 * @author Sean McCauliff
 *
 */
public class MigrateKsoc791 {

    private static final Log log = LogFactory.getLog(MigrateKsoc791.class);
    private static final int BAD_T = 0;
    private static final int GOOD_T = 69;

    
    public void migrate(File srcFile, File destFile) throws IOException {
        DiskNodeIO<FsId, FsIdInfo,BtreeNode<FsId,FsIdInfo>> srcIo = createDiskNodeIo(BAD_T, srcFile);
        BTree<FsId, FsIdInfo> srcTree = createBTree(BAD_T, srcIo);
        DiskNodeIO<FsId, FsIdInfo,BtreeNode<FsId,FsIdInfo>> destIo = createDiskNodeIo(GOOD_T, destFile);
        BTree<FsId, FsIdInfo> destTree = createBTree(GOOD_T, destIo);
        
        int nKeysCopied =0;
        for (Pair<FsId, FsIdInfo> pair : srcTree) {
            destTree.insert(pair.left, pair.right);
            nKeysCopied++;
            if ((nKeysCopied % 77) == 0) {
                destIo.flushPendingModifications();
            }
        }
        destIo.flushPendingModifications();
        log.info("Copied " + nKeysCopied + " pairs.");
        
        Iterator<Pair<FsId,FsIdInfo>> srcIt = srcTree.iterator();
        Iterator<Pair<FsId,FsIdInfo>> destIt = destTree.iterator();
        List<Pair<FsId,FsIdInfo>> allPairs = new ArrayList<Pair<FsId,FsIdInfo>>();
        while (srcIt.hasNext()) {
            Pair<FsId, FsIdInfo> srcPair = srcIt.next();
            Pair<FsId, FsIdInfo> destPair = destIt.next();
            if (!srcPair.equals(destPair)) {
                throw new IllegalStateException("Source pair \"" + srcPair + 
                    "\" does not match desitnation pair \"" + destPair + "\"." +
                    "  For source index file \"" + srcFile + "\".");
            }
            allPairs.add(destPair);
        }
        
        if (destIt.hasNext()) {
            throw new IllegalStateException("Destination has too many key,value" +
                    " pairs in file \"" + destFile + "\".");
        }
        
        log.info("Verified all pairs present in destination.");
        
        Random rand = new Random(78237843L);
        Collections.shuffle(allPairs, rand);
        for (Pair<FsId,FsIdInfo> knownPair : allPairs) {
            FsIdInfo value = destTree.find(knownPair.left);
            if (!value.equals(knownPair.right)) {
                throw new IllegalStateException("Known pair not found in " +
                        "destination index file \"" + destFile + "\".");
            }
        }
        log.info("Random access on destination works correctly.");
        DiskNodeIO.diskNodeIOs.clear();
    }
    
    private DiskNodeIO<FsId,FsIdInfo,BtreeNode<FsId,FsIdInfo>> createDiskNodeIo(int t, File indexFile) throws IOException {
        KeyValueIO<FsId, FsIdInfo> keyValueIo = new RandomAccessKeyValueIo();
        LruCache<CacheNodeKey, BtreeNode<FsId, FsIdInfo>> cache = 
            new LruCache<CacheNodeKey, BtreeNode<FsId, FsIdInfo>>(256);
        
        BtreeNode.Factory<FsId, FsIdInfo> nodeFactory = BtreeNode.Factory.instance();
        DiskNodeIO<FsId, FsIdInfo, BtreeNode<FsId,FsIdInfo>> btreeDiskIo = 
            new DiskNodeIO<FsId, FsIdInfo,BtreeNode<FsId,FsIdInfo>>(keyValueIo, indexFile,
            BTREE_NODE_SIZE,cache, nodeFactory);
        return btreeDiskIo;
    }
    
    private BTree<FsId,FsIdInfo> createBTree(int t, DiskNodeIO<FsId,FsIdInfo,BtreeNode<FsId,FsIdInfo>> btreeDiskIo) throws IOException {
       
        
        BTree<FsId,FsIdInfo> btree = 
            new BTree<FsId, FsIdInfo>(btreeDiskIo, t, FsId.comparator);
        
        return btree;
    }
    
    public BTree<FsId,FsIdInfo> createBadBTree(File indexFile) throws IOException {
        DiskNodeIO<FsId, FsIdInfo,BtreeNode<FsId,FsIdInfo>> srcIo = createDiskNodeIo(BAD_T, indexFile);
        BTree<FsId, FsIdInfo> tree = createBTree(BAD_T, srcIo);
        return tree;
    }
    
    public BTree<FsId,FsIdInfo> createGoodBTree(File indexFile) throws IOException {
        DiskNodeIO<FsId, FsIdInfo,BtreeNode<FsId,FsIdInfo>> srcIo = createDiskNodeIo(GOOD_T, indexFile);
        BTree<FsId, FsIdInfo> tree = createBTree(GOOD_T, srcIo);
        return tree;
    }
}
