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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.DiskNodeIO.BtreeFileVersion;
import gov.nasa.kepler.fs.server.index.blinktree.*;
import gov.nasa.kepler.fs.server.index.btree.BTree;
import gov.nasa.kepler.fs.server.index.btree.BtreeNode;
import gov.nasa.kepler.fs.storage.FsIdInfo;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator.RandomAccessKeyValueIo;
import gov.nasa.spiffy.common.collect.LruCache;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.*;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 *
 */
public class MigrateToBLinkTree {

    private final static Log log = LogFactory.getLog(MigrateToBLinkTree.class);
    private final static int NODE_SIZE = 1024 * 16;
    private final static int BTREE_T = 69;
    
    public void migrate(File srcFile, File destFile) 
        throws IOException, InterruptedException {

        log.info("Migrating index file \"" + srcFile + "\" to \"" + destFile + "\".");
        KeyValueIO<FsId, FsIdInfo> keyValueIo = new RandomAccessKeyValueIo();
        
        LruCache<CacheNodeKey, BtreeNode<FsId, FsIdInfo>> srcCache = 
            new LruCache<CacheNodeKey, BtreeNode<FsId, FsIdInfo>>(256);
        
        BtreeNode.Factory<FsId, FsIdInfo> srcNodeFactory = BtreeNode.Factory.instance();
        
        DiskNodeIO<FsId, FsIdInfo, BtreeNode<FsId,FsIdInfo>> srcIo =
            new DiskNodeIO<FsId, FsIdInfo, BtreeNode<FsId,FsIdInfo>>(
                keyValueIo, srcFile, NODE_SIZE, srcCache, srcNodeFactory);
        
        BTree<FsId,FsIdInfo> srcTree = 
            new BTree<FsId, FsIdInfo>(srcIo, BTREE_T, FsId.comparator);
        
        
        LruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>> destCache = 
            new LruCache<CacheNodeKey, BLinkNode<FsId, FsIdInfo>>(256);
        
        NodeLockFactory lockFactory = new NodeLockFactory();
        TreeNodeFactory<FsId, FsIdInfo, BLinkNode<FsId, FsIdInfo>> destNodeFactory = 
            BLinkNode.nodeFactory(lockFactory, FsId.comparator);
        
        DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>> destIo =
            new DiskNodeIO<FsId, FsIdInfo, BLinkNode<FsId,FsIdInfo>>(
                keyValueIo, destFile, NODE_SIZE, destCache, destNodeFactory,
                BtreeFileVersion.VERSION_1);
        
        final int leafM = LeafNode.leafM(keyValueIo, NODE_SIZE);
        final int internalM = InternalNode.internalM(keyValueIo, NODE_SIZE);
        
        BLinkTree<FsId, FsIdInfo> destTree = 
            new BLinkTree<FsId, FsIdInfo>(destIo, leafM,
                internalM, FsId.comparator, lockFactory);
        
        log.info("Converting btree file \"" + srcFile + "\" to blink file \"" + 
            destFile + "\".");
        double startTime = System.currentTimeMillis();
        int nKeysCopied =0;
        for (Pair<FsId, FsIdInfo> srcPair : srcTree) {
            destTree.insert(srcPair.left, srcPair.right);
            nKeysCopied++;
            if ((nKeysCopied % 177) == 0) {
                destIo.flushPendingModifications();
                log.debug("Copied " + srcPair.left + " " + srcPair.right);
            }
        }
        destIo.flushPendingModifications();
        
        
        double endTime = System.currentTimeMillis();
        double elapsedTimeS= (endTime - startTime)/ 1000.0;
        
        log.info("Copied " + nKeysCopied + " key value pairs in " + elapsedTimeS + " seconds.");
        log.info("Checking that copy has all the key, value pairs in the correct order.");
        
        destCache.clear();
        Iterator<Map.Entry<FsId, FsIdInfo>> destIt = destTree.iterator();
        List<FsId> allIds = new ArrayList<FsId>(nKeysCopied);
        Map<FsId,FsIdInfo> deleteMe = new HashMap<FsId, FsIdInfo>();
        Random random = new Random(3444334L);
        for (Pair<FsId, FsIdInfo> srcPair : srcTree) {
            Map.Entry<FsId, FsIdInfo> destEntry = destIt.next();
            allIds.add(srcPair.left);
            if (random.nextInt(10) == 0) {
                deleteMe.put(srcPair.left, srcPair.right);
            }
            comparePairWithEntry(srcPair, destEntry);
        }
        if (destIt.hasNext()) {
            throw new IllegalStateException("Destination iterator should not have a next.");
        }
        
        log.info("Test deletion.");
        for (Map.Entry<FsId, FsIdInfo> deleteEntry : deleteMe.entrySet()) {
            if (!deleteEntry.getValue().equals(destTree.delete(deleteEntry.getKey()))) {
                throw new IllegalStateException("Attempt to delete key \"" + deleteEntry.getKey() + 
                "\" failed.");
            }
        }
        
        destIo.flushPendingModifications();
        destCache.clear();
        
        Collections.shuffle(allIds, random);
        for (FsId id : allIds) {
            FsIdInfo value = destTree.find(id);
            if (value == null && !deleteMe.containsKey(id)) {
                throw new IllegalStateException("Expected id \"" + id + "\" to be present in the tree after deletion."); 
            }
            if (value != null && !value.equals(srcTree.find(id))) {
                throw new IllegalStateException("Expected id \"" + id + 
                                                "\" to have value \"" + srcTree.find(id) + "\".");
            }
        }
        
        log.info("Restoring deleted keys.");
        for (Map.Entry<FsId, FsIdInfo> deletedEntry : deleteMe.entrySet()) {
            destTree.insert(deletedEntry.getKey(), deletedEntry.getValue());
        }
        
        destIo.flushPendingModifications();
        destCache.clear();
        
        destIt = destTree.iterator();
        for (Pair<FsId, FsIdInfo> pair : srcTree) {
            Map.Entry<FsId, FsIdInfo> entry = destIt.next();
            comparePairWithEntry(pair, entry);
        }
        log.info("Done with b-link tree file\"" + destFile + "\".");
        
    }

    private void comparePairWithEntry(Pair<FsId, FsIdInfo> srcPair,
        Map.Entry<FsId, FsIdInfo> destEntry) {
        if (!srcPair.left.equals(destEntry.getKey())) {
            throw new IllegalStateException("src key \"" + srcPair.left +
                " does not equal dest key \"" + destEntry.getKey() + "\".");
        }
        if (!srcPair.right.equals(destEntry.getValue())) {
            throw new IllegalStateException("src value \"" + srcPair.right +
                "\" does not equal src value \"" + destEntry.getValue() + 
                "\" for key \"" + destEntry.getKey() + "\".");
        }
    }

}
