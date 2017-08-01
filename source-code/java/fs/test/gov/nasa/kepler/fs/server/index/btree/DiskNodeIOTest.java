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


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.NoSuchElementException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DiskNodeIOTest {

    private final File testRoot = 
        new File(Filenames.BUILD_TEST, "DiskNodeIOTest.test");
    private final KeyValueIO<String,Integer> kvio = new StringIntKeyValueIO();
    private final int nodeSize = 1024;
    private int t;
    private ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>> cache;
    private final BtreeNode.Factory<String, Integer> nodeFactory = BtreeNode.Factory.instance();
    @Before
    public void setUp() throws Exception {
        int tripletSize = kvio.keySize() + kvio.valueSize() + 8;
        int tripletsPerNode = nodeSize/ tripletSize;
        if ( (1024 % tripletsPerNode) < 8) {
            tripletsPerNode--;
        }
        t = tripletsPerNode /2;
        //System.out.println("t="+t);
        
        if (!testRoot.mkdirs()) {
            throw new IOException("Can not make directory \"" + testRoot + "\".");
        }
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>>(1);
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }
    
    @Test
    public void simpleDiskNodeIO() throws Exception {
        simpleTest(true);
    }
    
    @Test
    public void simpleDiskNodeIORecovery() throws Exception {
        simpleTest(false);
    }

    private void simpleTest(boolean commit) throws Exception {
        File btreeFile = new File(testRoot, "btree");
        
        BtreeNode.Factory<String, Integer> nodeFactory = BtreeNode.Factory.instance();
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> dio = 
            new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        long newNodeAddress = dio.allocateAddress();
        BtreeNode<String, Integer> node = new BtreeNode<String, Integer>(newNodeAddress, dio);
        fillNode(node);
        dio.writeNode(node);
        BtreeNode<String,Integer> cachedNode = dio.readNode(node.address());
        assertTrue(cachedNode == node);
        if (commit) {
            dio.flushPendingModifications();
        } else {
            dio.writeJournal();
        }
        cachedNode = dio.readNode(node.address());
        assertTrue(cachedNode == node);
        
        dio =  new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        BtreeNode<String, Integer> readNode = dio.readNode(newNodeAddress);
        assertEquals(node, readNode);
    }

    
    @Test
    public void deleteAllocated() throws Exception {
        File btreeFile = new File(testRoot, "btree");
        
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> dio =
            new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        long newNodeAddress = dio.allocateAddress();
        BtreeNode<String, Integer> node = new BtreeNode<String, Integer>(newNodeAddress, dio);
        fillNode(node);
        dio.writeNode(node);
        dio.deleteNode(node);
        dio.flushPendingModifications();
       
        try {
            dio.readNode(node.address());
            assertTrue("Should not have reached here." , false);
        } catch (NoSuchElementException x) {
            //ok
        }
        
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>>(2);
        dio = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        try {
            dio.readNode(node.address());
            assertTrue("Should not have reached here." , false);
        } catch (NoSuchElementException x) {
            //ok
        }
        
    }
    
    @Test
    public void deleteTest() throws Exception {
        deleteTest(true);
    }
    
    @Test
    public void deleteTestRecover() throws Exception {
        deleteTest(false);
    }
    
    private void deleteTest(boolean commit) throws Exception {
        File btreeFile = new File(testRoot, "btree");
        
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> dio =
            new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        long newNodeAddress = dio.allocateAddress();
        BtreeNode<String, Integer> node = new BtreeNode<String, Integer>(newNodeAddress, dio);
        fillNode(node);
        dio.writeNode(node);
        dio.flushPendingModifications();
        
        dio.deleteNode(node);
        if (commit) {
            dio.flushPendingModifications();
        } else {
            dio.writeJournal();
        }
        
        try {
            dio.readNode(node.address());
            assertTrue("Should not have reached here." , false);
        } catch (NoSuchElementException x) {
            //ok
        }
        
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>>(2);
        dio = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        try {
            dio.readNode(node.address());
            assertTrue("Should not have reached here." , false);
        } catch (NoSuchElementException x) {
            //ok
        }
   
    }
    
    @Test
    public void deleteInMiddle() throws Exception {
        File btreeFile = new File(testRoot, "btree");
        
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>>(64);
        DiskNodeIO<String, Integer,BtreeNode<String,Integer>> dio =
            new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        
        List<BtreeNode<String,Integer>> createdNodes = new ArrayList<BtreeNode<String,Integer>>();
        for (int i=0; i < 32; i++) {
            long newNodeAddress = dio.allocateAddress();
            BtreeNode<String, Integer> node = new BtreeNode<String, Integer>(newNodeAddress, dio);
            fillNode(node,(int) newNodeAddress);
            createdNodes.add(node);
            dio.writeNode(node);
        }
        
        dio.flushPendingModifications();
        
        for (BtreeNode<String,Integer> node : createdNodes) {
            assertTrue(node == dio.readNode(node.address()));
        }
        
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>>(2);
        dio = new DiskNodeIO<String, Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        for (BtreeNode<String,Integer> node : createdNodes) {
            assertEquals(node, dio.readNode(node.address()));
        }
        
        dio.deleteNode(createdNodes.get(7));
        try {
            dio.readNode(createdNodes.get(7).address());
            assertTrue("Should not have reached here.", false);
        } catch (NoSuchElementException x) {
            
        }
        dio.flushPendingModifications();
        try {
            dio.readNode(createdNodes.get(7).address());
            assertTrue("Should not have reached here.", false);
        } catch (NoSuchElementException x) {
            
        }    
        
        cache = new ConcurrentLruCache<CacheNodeKey, BtreeNode<String,Integer>>(2);
        dio  = new DiskNodeIO<String,Integer,BtreeNode<String,Integer>>(kvio, btreeFile, nodeSize, cache, nodeFactory);
        try {
            dio.readNode(createdNodes.get(7).address());
            assertTrue("Should not have reached here.", false);
        } catch (NoSuchElementException x) {
            
        }
        
        //Allocate a node in the hole
        long holeAddress = dio.allocateAddress();
        assertEquals(createdNodes.get(7).address(), holeAddress);
        
    }
    
    
    private void fillNode(BtreeNode<String,Integer> node) {
        fillNode(node, 1);
    }
    
    private void fillNode(BtreeNode<String, Integer> node, int fillOffset) {
        for (int i=0; i < (t*2-1); i++) {
            int fillValue = (i+1) * fillOffset;
            node.keys.add(""+ fillValue);
            node.values.add(fillValue);
            node.childAddresses.add(new Long(fillValue+1));
        }
        node.childAddresses.add(new Long(t*2*fillOffset+1));
    }
    
}
