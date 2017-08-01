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

package gov.nasa.kepler.fs.server.index.blinktree;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.kepler.fs.server.index.AbstractDiskNodeIO.CacheNodeKey;
import gov.nasa.kepler.fs.server.index.DiskNodeIO.BtreeFileVersion;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantLock;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;


import java.io.*;
import java.util.*;
import java.util.Map.Entry;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.lang.StringUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableSortedMap;
import com.trifork.clj_ds.PersistentTreeMap;
import static gov.nasa.kepler.fs.server.index.blinktree.BlinkNodeTest.*;

/**
 * 
 * @author Sean McCauliff
 *
 */
public class BlinkTreeTest {
    
    private NodeLockFactory lockFactory;
    
    
    private File rootDir;

    @Before
    public void setUp() throws Exception {
        rootDir = new File(Filenames.BUILD_TEST,
            "BLinkTreeTest");
        rootDir.mkdirs();
        lockFactory = new NodeLockFactory();
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
    }

    
    @Test
    public void emptyBlinkTree() throws Exception {
        MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        BLinkTree<String, Integer> btree = 
            new BLinkTree<String, Integer>(io, m, m, comp, lockFactory);
        assertEquals(null,btree.find("A"));
        assertFalse(btree.iterator().hasNext());
        
        try {
            btree.iterator().next();
            assertTrue("Should not have reached here.", false);
        } catch (NoSuchElementException nsee) {
            //ok
        }
        
        btree.checkInvariants();
    }
    
    
    @Test
    public void insertSplitLeafRoot() throws Exception {
        MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        final BLinkTree<String, Integer> btree = 
            new BLinkTree<String, Integer>(io, m, m, comp, lockFactory);
        btree.insert("A", 0);
        btree.insert("B", 1);
        btree.insert("C", 2);
        btree.insert("D", 3);
        
        assertEquals(Integer.valueOf(0), btree.find("A"));
        
        lockFactory.nodesLock(0L).lock();
        
        //This tests that the tree can expand while another thread is
        //concurrently modifying the tree.
        final CountDownLatch done = new CountDownLatch(1);
        final AtomicReference<Throwable> error = 
            new AtomicReference<Throwable>();
        Runnable inserter = new Runnable() {
            
            @Override
            public void run() {
                try {
                    btree.insert("EE", 5);
                } catch (Throwable t) {
                    error.set(t);
                } finally {
                    done.countDown();
                }
            }
        };
        
        Thread thread = new Thread(inserter);
        thread.start();
        
        btree.insert("E", 4);
        lockFactory.nodesLock(0L).unlock();
        done.await(2, TimeUnit.SECONDS);
        assertEquals(0, done.getCount());
        assertEquals(null, error.get());
        
        assertEquals(Integer.valueOf(0), btree.find("A"));
        assertEquals(Integer.valueOf(1), btree.find("B"));
        assertEquals(Integer.valueOf(2), btree.find("C"));
        assertEquals(Integer.valueOf(3), btree.find("D"));
        assertEquals(Integer.valueOf(4), btree.find("E"));
        assertEquals(Integer.valueOf(5), btree.find("EE"));
        assertEquals(null, btree.find("F"));
        
        ImmutableSortedMap<String, Integer> expected = 
            new ImmutableSortedMap.Builder<String,Integer>(comp).put("A", 0).put("B", 1).put("C", 2).put("D", 3).put("E", 4).put("EE", 5).build();
        Iterator<Map.Entry<String,Integer>> expectedIt = expected.entrySet().iterator();
        Iterator<Map.Entry<String, Integer>> actualIt = btree.iterator();;
        for (int i=0; i < 6; i++) {
            assertTrue(actualIt.hasNext());
            assertEquals(expectedIt.next(), actualIt.next());
        }
        assertFalse(actualIt.hasNext());
        try {
            actualIt.next();
            assertTrue("Should not have reached here.", false);
        } catch (NoSuchElementException nsee) {
            //ok
        }
        
        btree.checkInvariants();
    }
    
    @Test
    public void insertSplitLeafInternal() throws Exception {
        MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        BLinkTree<String, Integer> btree = 
            new BLinkTree<String, Integer>(io, m, m, comp, lockFactory);
        char value = 'A';
        int n=13;
        for (int i=0; i < n; i++,value++) {
            assertEquals(null,btree.insert(""+value, i));
        }
        
        //System.out.println(btree.toDot());
        value = 'A';
        for (int i=0; i < n; i++, value++) {
            assertEquals(Integer.valueOf(i), btree.find(value + ""));
        }
        btree.checkInvariants();
    }
    
    @Test
    public void updateExistingKey() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = 
            threeLevelTree(io, m, m);
        
        Integer maxInt = Integer.valueOf(Integer.MAX_VALUE);
        assertEquals(Integer.valueOf(0),btree.insert("A", maxInt));
        assertEquals(maxInt, btree.find("A"));

        assertEquals(maxInt, btree.insertIfAbsent("A", Integer.MIN_VALUE));
        assertEquals(Integer.valueOf(7), btree.insertIfAbsent("Z", 7));
        
        //System.out.println(btree.toDot());
        btree.checkInvariants();
    }
    
    /**
     * The middle child in this test has not been added to the parent node and
     * so they only way to get to it is by doing the right traversal.  This
     * also locks the left most leaf in order to show that reading is completely
     * concurrent with inserters.
     * 
     * @throws IOException
     * @throws InterruptedException
     */
    @Test
    public void readTreeInPartiallyModifiedState() throws IOException, InterruptedException {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        final long rootAddress = io.rootNodeAddress();
        DebugReentrantLock rootLock= lockFactory.nodesLock(rootAddress);
        final long child1Address = io.allocateAddress();
        DebugReentrantLock child1Lock = lockFactory.nodesLock(child1Address);
        final long child2Address = io.allocateAddress();
        DebugReentrantLock child2Lock = lockFactory.nodesLock(child2Address);
        final long child3Address = io.allocateAddress();
        DebugReentrantLock child3Lock = lockFactory.nodesLock(child3Address);
        
        PersistentTreeMap<Object, Long> children = 
            PersistentTreeMap.create(InternalNode.buildComparator(comp), PersistentTreeMap.EMPTY.seq());
        children = children.assoc("F", child1Address);
        children = children.assoc(InternalNode.GREATER_THAN_EVERYTHING, child3Address);
        InternalNode<String,Integer> root = 
            new InternalNode<String,Integer>(rootAddress, rootLock,
                 BLinkNode.UNALLOCATED_ADDRESS,
                null, children);
        
        io.writeNode(root);
        
        PersistentTreeMap<String, Integer> child1Values = 
            PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        child1Values = child1Values.assoc("A", 0);
        child1Values = child1Values.assoc("B", 1);
        PersistentTreeMap<String,Integer> child2Values = 
            PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        child2Values = child2Values.assoc("C", 2);
        child2Values = child2Values.assoc("D", 3);
        child2Values = child2Values.assoc("E", 4);
        
        PersistentTreeMap<String,Integer> child3Values =
            PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        child3Values = child3Values.assoc("F", 5);
        child3Values = child3Values.assoc("G", 6);
        
        LeafNode<String, Integer> child1 = 
            new LeafNode<String,Integer>(child1Address, child1Lock, "C",
                child2Address, child1Values);
        io.writeNode(child1);
        LeafNode<String,Integer> child2 = 
            new LeafNode<String,Integer>(child2Address, child2Lock, "F",
                child3Address, child2Values);
        io.writeNode(child2);
        LeafNode<String,Integer> child3 =
            new LeafNode<String,Integer>(child3Address, child3Lock, null,
                BLinkNode.UNALLOCATED_ADDRESS, child3Values);
        io.writeNode(child3);
        
        child1.lock();
        
        final CountDownLatch done = new CountDownLatch(1);
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        Runnable readChild2Values = new Runnable() {

            @Override
            public void run() {
                try {
                    BLinkTree<String, Integer> btree = 
                        new BLinkTree<String, Integer>(io, m, m, comp, lockFactory);
                    assertEquals(Integer.valueOf(2), btree.find("C"));
                    assertEquals(Integer.valueOf(3), btree.find("D"));
                    assertEquals(Integer.valueOf(4), btree.find("E"));
                    
                    btree.insert("FF", 55);
                    assertEquals(Integer.valueOf(55),btree.find("FF"));
                    assertEquals(Integer.valueOf(2), btree.find("C"));
                    //System.out.println(btree.toDot());
                    btree.checkInvariants();
                } catch (Throwable t) {
                    error.set(t);
                } finally {
                    done.countDown();
                }
            }
            
        };
        Thread readerThread = new Thread(readChild2Values);
        readerThread.run();
        assertTrue(done.await(4, TimeUnit.SECONDS));
        assertEquals(null, error.get());
        
        
    }
    
    /**
     * The find stack can become empty when it is unwound and another thread
     * concurrently caused the height of the tree to grow while the first thread
     * was doing its thing.
     * @throws Exception
     */
    @Test
    public void testStackRefill() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = 
            new BLinkTree<String, Integer>(io, m,m, comp, lockFactory);
        btree.insert("A",0);
        btree.insert("B", 1);
        btree.insert("C", 2);
        btree.insert("D", 3);
        btree.insert("E", 4);
        //System.out.println(btree.toDot());
        btree.insert("AA", 100);
        //System.out.println(btree.toDot());
        btree.insert("BB", 111);
        //System.out.println(btree.toDot());
        
        LeafNode<String, Integer> lockedLeaf = 
            (LeafNode<String, Integer>) io.readNode(0);
        lockedLeaf.lock();
        
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        final CountDownLatch done = new CountDownLatch(1);
        Runnable blockedInserter = new Runnable() {
            
            @Override
            public void run() {
                try {
                    btree.insert("AAA", 1000);
                } catch (Throwable t) {
                    error.set(t);
                } finally {
                    done.countDown();
                }
            }
        };
        
        Thread thread = new Thread(blockedInserter);
        thread.start();
        
        btree.insert("F", 5);
        btree.insert("G", 6);
        btree.insert("H", 7);
        btree.insert("I", 8);
        btree.insert("CC", 22);
        btree.insert("CCC",222);
        btree.insert("DD", 33);
        //System.out.println(btree.toDot());
        
        assertEquals(1,done.getCount());
        lockedLeaf.unlock();
        done.await();
        String actualTree = StringUtils.deleteWhitespace(btree.toDot("testStackRefill"));
        String expectedTree = "digraph testStackRefill {\n     node8[shape=record,label=\"<f0>|<f1>CCC|<last>\"];\n      \"node8\":f0->node2:last[label=\"2\"]\n         \"node8\":last->node7:f0[label=\"7\"]\n       node2[shape=record,label=\"<f0>|<f1>AAA|<f2>|<f3>C|<last>\"];\n   \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node6:last[label=\"6\"]\n         \"node2\":last->node1:f0[label=\"1\"]\n         \"node2\":last->node7:f0[style=\"dashed\",label=\"rightLink[CCC]\"]\n node7[shape=record,label=\"<f0>|<f1>E|<f2>|<f3>G|<last>\"];\n     \"node7\":f0->node5:last[label=\"5\"]\n         \"node7\":f2->node3:last[label=\"3\"]\n         \"node7\":last->node4:f0[label=\"4\"]\n       node0[shape=record,style=\"rounded\",label=\"<f0>A|<last>AA\"];\n         \"node0\":last->node6:f0[style=\"dashed\",label=\"rightLink[AAA]\"]\n node6[shape=record,style=\"rounded\",label=\"<f0>AAA|<f1>B|<last>BB\"];\n         \"node6\":last->node1:f0[style=\"dashed\",label=\"rightLink[C]\"]\n   node1[shape=record,style=\"rounded\",label=\"<f0>C|<last>CC\"];\n        \"node1\":last->node5:f0[style=\"dashed\",label=\"rightLink[CCC]\"]\n  node5[shape=record,style=\"rounded\",label=\"<f0>CCC|<f1>D|<last>DD\"];\n         \"node5\":last->node3:f0[style=\"dashed\",label=\"rightLink[E]\"]\n   node3[shape=record,style=\"rounded\",label=\"<f0>E|<last>F\"];\n          \"node3\":last->node4:f0[style=\"dashed\",label=\"rightLink[G]\"]\n   node4[shape=record,style=\"rounded\",label=\"<f0>G|<f1>H|<last>I\"];\n}\n";
        expectedTree = StringUtils.deleteWhitespace(expectedTree);
        assertEquals(null, error.get());
        assertEquals(Integer.valueOf(1000), btree.find("AAA"));
        assertEquals(expectedTree, actualTree);
        
        btree.checkInvariants();
    }
    
    /**
     * Tests that the b-link tree iterator does what it is supposed to do.
     * @throws Exception
     */
    @Test
    public void iteratorTest() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        
        //System.out.println(btree.toDot());
        Iterator<Map.Entry<String, Integer>> it = btree.iterator();
        assertEquals(it.next().getKey(), "A");
        assertEquals(it.next().getKey(), "AA");
        assertEquals(it.next().getKey(), "AAA");
        assertEquals(it.next().getKey(), "B");
        assertEquals(it.next().getKey(), "BB");
        assertEquals(it.next().getKey(), "C");
        assertEquals(it.next().getKey(), "CC");
        assertEquals(it.next().getKey(), "CCC");
        assertEquals(it.next().getKey(), "D");
        assertEquals(it.next().getKey(), "DD");
        assertEquals(it.next().getKey(), "E");
        assertEquals(it.next().getKey(), "F");
        assertEquals(it.next().getKey(), "G");
        assertEquals(it.next().getKey(), "H");
        assertEquals(it.next().getKey(), "I");
        assertFalse(it.hasNext());
        
        btree.checkInvariants();
        String expected = "digraph IteratorTest {\n        node8[shape=record,label=\"<f0>|<f1>CC|<last>\"];\n       \"node8\":f0->node2:last[label=\"2\"]\n         \"node8\":last->node7:f0[label=\"7\"]\n       node2[shape=record,label=\"<f0>|<f1>AAA|<f2>|<f3>BB|<last>\"];\n          \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node1:last[label=\"1\"]\n         \"node2\":last->node3:f0[label=\"3\"]\n        \"node2\":last->node7:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n   node7[shape=record,label=\"<f0>|<f1>D|<f2>|<f3>E|<f4>|<f5>G|<last>\"];\n          \"node7\":f0->node4:last[label=\"4\"]\n         \"node7\":f2->node5:last[label=\"5\"]\n         \"node7\":f4->node6:last[label=\"6\"]\n         \"node7\":last->node9:f0[label=\"9\"]\n       node0[shape=record,style=\"rounded\",label=\"<f0>A|<last>AA\"];\n         \"node0\":last->node1:f0[style=\"dashed\",label=\"rightLink[AAA]\"]\n node1[shape=record,style=\"rounded\",label=\"<f0>AAA|<last>B\"];\n       \"node1\":last->node3:f0[style=\"dashed\",label=\"rightLink[BB]\"]\n   node3[shape=record,style=\"rounded\",label=\"<f0>BB|<last>C\"];\n         \"node3\":last->node4:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n  node4[shape=record,style=\"rounded\",label=\"<f0>CC|<last>CCC\"];\n       \"node4\":last->node5:f0[style=\"dashed\",label=\"rightLink[D]\"]\n   node5[shape=record,style=\"rounded\",label=\"<f0>D|<last>DD\"];\n         \"node5\":last->node6:f0[style=\"dashed\",label=\"rightLink[E]\"]\n   node6[shape=record,style=\"rounded\",label=\"<f0>E|<last>F\"];\n          \"node6\":last->node9:f0[style=\"dashed\",label=\"rightLink[G]\"]\n   node9[shape=record,style=\"rounded\",label=\"<f0>G|<f1>H|<last>I\"];\n}\n";
        expected = StringUtils.deleteWhitespace(expected);
        String actual = StringUtils.deleteWhitespace(btree.toDot("IteratorTest"));
        assertEquals(expected, actual);
    }
    
    
    /**
     * A leaf node is full and a key needs to be delted from it this.  This
     * should be the simplest case if the key is not someone elses' high key.
     * No merges or other key maintenance should be required.  This should 
     * actually be the case about half the time or more in reality.
     */
    @Test
    public void deleteFromFullLeaf() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        
        assertEquals(Integer.valueOf(-14),btree.delete("H"));
        assertEquals(null, btree.find("H"));
        
        String actual = StringUtils.deleteWhitespace(btree.toDot("DeleteFromFullNode"));
        String expected = StringUtils.deleteWhitespace("digraph DeleteFromFullNode {\n  node8[shape=record,label=\"<f0>|<f1>CC|<last>\"];\n       \"node8\":f0->node2:last[label=\"2\"]\n         \"node8\":last->node7:f0[label=\"7\"]\n       node2[shape=record,label=\"<f0>|<f1>AAA|<f2>|<f3>BB|<last>\"];\n          \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node1:last[label=\"1\"]\n         \"node2\":last->node3:f0[label=\"3\"]\n        \"node2\":last->node7:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n   node7[shape=record,label=\"<f0>|<f1>D|<f2>|<f3>E|<f4>|<f5>G|<last>\"];\n          \"node7\":f0->node4:last[label=\"4\"]\n         \"node7\":f2->node5:last[label=\"5\"]\n         \"node7\":f4->node6:last[label=\"6\"]\n         \"node7\":last->node9:f0[label=\"9\"]\n       node0[shape=record,style=\"rounded\",label=\"<f0>A|<last>AA\"];\n         \"node0\":last->node1:f0[style=\"dashed\",label=\"rightLink[AAA]\"]\n node1[shape=record,style=\"rounded\",label=\"<f0>AAA|<last>B\"];\n       \"node1\":last->node3:f0[style=\"dashed\",label=\"rightLink[BB]\"]\n   node3[shape=record,style=\"rounded\",label=\"<f0>BB|<last>C\"];\n         \"node3\":last->node4:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n  node4[shape=record,style=\"rounded\",label=\"<f0>CC|<last>CCC\"];\n       \"node4\":last->node5:f0[style=\"dashed\",label=\"rightLink[D]\"]\n   node5[shape=record,style=\"rounded\",label=\"<f0>D|<last>DD\"];\n         \"node5\":last->node6:f0[style=\"dashed\",label=\"rightLink[E]\"]\n   node6[shape=record,style=\"rounded\",label=\"<f0>E|<last>F\"];\n          \"node6\":last->node9:f0[style=\"dashed\",label=\"rightLink[G]\"]\n   node9[shape=record,style=\"rounded\",label=\"<f0>G|<last>I\"];\n}\n");
        assertEquals(expected, actual);
        btree.checkInvariants();
    }
    
    /**
     * Delete from a leaf node that is full-ish, but the key being deleted is 
     * someone's high key.
     * 
     */
    @Test
    public void leafHighKeyChange() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        
        assertEquals(Integer.valueOf(-13),btree.delete("G"));
        assertEquals(null, btree.find("G"));
        assertEquals("H", io.readNode(6).highKey());
        
        String expected = StringUtils.deleteWhitespace("digraph LeftHighKeyChange {\n   node8[shape=record,label=\"<f0>|<f1>CC|<last>\"];\n       \"node8\":f0->node2:last[label=\"2\"]\n         \"node8\":last->node7:f0[label=\"7\"]\n       node2[shape=record,label=\"<f0>|<f1>AAA|<f2>|<f3>BB|<last>\"];\n          \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node1:last[label=\"1\"]\n         \"node2\":last->node3:f0[label=\"3\"]\n        \"node2\":last->node7:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n   node7[shape=record,label=\"<f0>|<f1>D|<f2>|<f3>E|<f4>|<f5>H|<last>\"];\n          \"node7\":f0->node4:last[label=\"4\"]\n         \"node7\":f2->node5:last[label=\"5\"]\n         \"node7\":f4->node6:last[label=\"6\"]\n         \"node7\":last->node9:f0[label=\"9\"]\n       node0[shape=record,style=\"rounded\",label=\"<f0>A|<last>AA\"];\n         \"node0\":last->node1:f0[style=\"dashed\",label=\"rightLink[AAA]\"]\n node1[shape=record,style=\"rounded\",label=\"<f0>AAA|<last>B\"];\n       \"node1\":last->node3:f0[style=\"dashed\",label=\"rightLink[BB]\"]\n   node3[shape=record,style=\"rounded\",label=\"<f0>BB|<last>C\"];\n         \"node3\":last->node4:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n  node4[shape=record,style=\"rounded\",label=\"<f0>CC|<last>CCC\"];\n       \"node4\":last->node5:f0[style=\"dashed\",label=\"rightLink[D]\"]\n   node5[shape=record,style=\"rounded\",label=\"<f0>D|<last>DD\"];\n         \"node5\":last->node6:f0[style=\"dashed\",label=\"rightLink[E]\"]\n   node6[shape=record,style=\"rounded\",label=\"<f0>E|<last>F\"];\n          \"node6\":last->node9:f0[style=\"dashed\",label=\"rightLink[H]\"]\n   node9[shape=record,style=\"rounded\",label=\"<f0>H|<last>I\"];\n}\n");
        String actual = StringUtils.deleteWhitespace(btree.toDot("LeftHighKeyChange"));
        assertEquals(expected, actual);
        btree.checkInvariants();
    }

    /**
     * This should cause the delete of a leaf node, this leaf node also has the
     * key, value pair which is the high key in another leaf in a different
     * parent and the root node also uses this key as the anchor key.
     */
    @Test
    public void multipleEdgeCaseDeleteTest() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        assertEquals(Integer.valueOf(-6),btree.delete("CC"));
        //System.out.println(btree.toDot());
        
        InternalNode<String,Integer> root = (InternalNode<String, Integer>) io.readNode(io.rootNodeAddress());
        assertEquals("CCC", root.minKey());
        assertEquals("E", io.readNode(7).minKey());
        assertEquals("E",io.readNode(4).highKey());
        assertEquals("CCC", io.readNode(4).minKey());
        assertEquals("CCC", io.readNode(3).highKey());
        try {
            io.readNode(5);
            assertTrue(false);
        } catch (NoSuchElementException nsee) {
            //OK
        }
        btree.checkInvariants();
        
        String expected = StringUtils.deleteWhitespace("digraph MultipleEdgeCaseDelete {\n      node8[shape=record,label=\"<f0>|<f1>CCC|<last>\"];\n      \"node8\":f0->node2:last[label=\"2\"]\n         \"node8\":last->node7:f0[label=\"7\"]\n       node2[shape=record,label=\"<f0>|<f1>AAA|<f2>|<f3>BB|<last>\"];\n          \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node1:last[label=\"1\"]\n         \"node2\":last->node3:f0[label=\"3\"]\n         \"node2\":last->node7:f0[style=\"dashed\",label=\"rightLink[CCC]\"]\nnode7[shape=record,label=\"<f0>|<f1>E|<f2>|<f3>G|<last>\"];\n      \"node7\":f0->node4:last[label=\"4\"]\n         \"node7\":f2->node6:last[label=\"6\"]\n        \"node7\":last->node9:f0[label=\"9\"]\n        node0[shape=record,style=\"rounded\",label=\"<f0>A|<last>AA\"];\n         \"node0\":last->node1:f0[style=\"dashed\",label=\"rightLink[AAA]\"]\n node1[shape=record,style=\"rounded\",label=\"<f0>AAA|<last>B\"];\n        \"node1\":last->node3:f0[style=\"dashed\",label=\"rightLink[BB]\"]\n  node3[shape=record,style=\"rounded\",label=\"<f0>BB|<last>C\"];\n         \"node3\":last->node4:f0[style=\"dashed\",label=\"rightLink[CCC]\"]\nnode4[shape=record,style=\"rounded\",label=\"<f0>CCC|<f1>D|<last>DD\"];\n         \"node4\":last->node6:f0[style=\"dashed\",label=\"rightLink[E]\"]\n    node6[shape=record,style=\"rounded\",label=\"<f0>E|<last>F\"];\n          \"node6\":last->node9:f0[style=\"dashed\",label=\"rightLink[G]\"]\n   node9[shape=record,style=\"rounded\",label=\"<f0>G|<f1>H|<last>I\"];\n}\n");
        String actual = StringUtils.deleteWhitespace(btree.toDot("MultipleEdgeCaseDelete"));
        assertEquals(expected, actual);
    }
    
    /**
     * A leaf node goes below the minimum number of items it is allowed to have,
     * but could be combined with a sibling node to make a larger node.
     * 
     */
    @Test
    public void leafNodeUnderflowTest() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        assertEquals(Integer.valueOf(-12), btree.delete("F"));
        //System.out.println(btree.toDot());
        assertEquals(null, btree.find("F"));
        assertEquals(Integer.valueOf(-14), btree.find("H"));
        
        assertEquals("H", io.readNode(6).highKey());
        assertEquals(Long.valueOf(6), ((InternalNode<String, Integer>)io.readNode(7)).children().get("H"));
        btree.checkInvariants();
        
        //TODO:  look more closely at this test
        String actual = StringUtils.deleteWhitespace(btree.toDot("LeafNodeUnderflowTest"));
        String expected = StringUtils.deleteWhitespace("digraph LeafNodeUnderflowTest {\n       node8[shape=record,label=\"<f0>|<f1>CC|<last>\"];\n       \"node8\":f0->node2:last[label=\"2\"]\n         \"node8\":last->node7:f0[label=\"7\"]\n       node2[shape=record,label=\"<f0>|<f1>AAA|<f2>|<f3>BB|<last>\"];\n          \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node1:last[label=\"1\"]\n         \"node2\":last->node3:f0[label=\"3\"]\n         \"node2\":last->node7:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n node7[shape=record,label=\"<f0>|<f1>D|<f2>|<f3>E|<f4>|<f5>H|<last>\"];\n   \"node7\":f0->node4:last[label=\"4\"]\n         \"node7\":f2->node5:last[label=\"5\"]\n         \"node7\":f4->node6:last[label=\"6\"]\n         \"node7\":last->node9:f0[label=\"9\"]\n       node0[shape=record,style=\"rounded\",label=\"<f0>A|<last>AA\"];\n         \"node0\":last->node1:f0[style=\"dashed\",label=\"rightLink[AAA]\"]\n node1[shape=record,style=\"rounded\",label=\"<f0>AAA|<last>B\"];\n       \"node1\":last->node3:f0[style=\"dashed\",label=\"rightLink[BB]\"]\n   node3[shape=record,style=\"rounded\",label=\"<f0>BB|<last>C\"];\n         \"node3\":last->node4:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n  node4[shape=record,style=\"rounded\",label=\"<f0>CC|<last>CCC\"];\n       \"node4\":last->node5:f0[style=\"dashed\",label=\"rightLink[D]\"]\n   node5[shape=record,style=\"rounded\",label=\"<f0>D|<last>DD\"];\n         \"node5\":last->node6:f0[style=\"dashed\",label=\"rightLink[E]\"]\n   node6[shape=record,style=\"rounded\",label=\"<f0>E|<last>G\"];\n          \"node6\":last->node9:f0[style=\"dashed\",label=\"rightLink[H]\"]\n   node9[shape=record,style=\"rounded\",label=\"<f0>H|<last>I\"];\n}\n");
        assertEquals(expected, actual);
        
    }
    
    
    @Test
    public void internalNodeUnderflowTest() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        assertEquals(Integer.valueOf(-2), btree.delete("AAA"));
        assertEquals(null, btree.find("AAA"));
       // System.out.println(btree.toDot());
        btree.checkInvariants();
    }
    
    /**
     * Deleting "BB" causes the right most child of an internal node to be
     * deleted which has a right sibling in another parent.  This has several
     * corner cases which are very annoying to deal with.
     * 
     * @throws Exception
     */
    @Test
    public void internalNodeUnderflowDontCrossTheStreamsTest() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        assertEquals(Integer.valueOf(-4), btree.delete("BB"));
        assertEquals(null, btree.find("BB"));
        //System.out.println(btree.toDot());
        btree.checkInvariants();
    }
    
    
    /**
     * Deleting several values causes an internal node to fall below half full
     * causing this tree to shrink.
     * 
     * @throws Exception
     */
    @Test
    public void mergeInternalNodesAndShrinkTreeTest() throws Exception {
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        final int m = 4;
        
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        btree.delete("BB");
        assertEquals(Integer.valueOf(-3), btree.delete("B"));
        assertEquals(Integer.valueOf(0), btree.delete("A"));
        String expected = StringUtils.deleteWhitespace("digraph MergeInternalNodesAndShrinkTree {\n     node2[shape=record,label=\"<f0>|<f1>CC|<f2>|<f3>D|<f4>|<f5>E|<f6>|<f7>G|<last>\"];\n      \"node2\":f0->node0:last[label=\"0\"]\n         \"node2\":f2->node4:last[label=\"4\"]\n         \"node2\":f4->node5:last[label=\"5\"]\n         \"node2\":f6->node6:last[label=\"6\"]\n         \"node2\":last->node9:f0[label=\"9\"]\n       node0[shape=record,style=\"rounded\",label=\"<f0>AA|<f1>AAA|<last>C\"];\n         \"node0\":last->node4:f0[style=\"dashed\",label=\"rightLink[CC]\"]\n  node4[shape=record,style=\"rounded\",label=\"<f0>CC|<last>CCC\"];\n       \"node4\":last->node5:f0[style=\"dashed\",label=\"rightLink[D]\"]\n   node5[shape=record,style=\"rounded\",label=\"<f0>D|<last>DD\"];\n         \"node5\":last->node6:f0[style=\"dashed\",label=\"rightLink[E]\"]\n   node6[shape=record,style=\"rounded\",label=\"<f0>E|<last>F\"];\n  \"node6\":last->node9:f0[style=\"dashed\",label=\"rightLink[G]\"]\n   node9[shape=record,style=\"rounded\",label=\"<f0>G|<f1>H|<last>I\"];\n}\n");
        String actual = StringUtils.deleteWhitespace(btree.toDot("MergeInternalNodesAndShrinkTree"));
        assertEquals(expected, actual);
        btree.checkInvariants();
    }
    
    
    /**
     * Generates a 3 level tree assuming m == 4
     * @param io
     * @param m
     * @return
     * @throws IOException
     * @throws InterruptedException
     */
    private BLinkTree<String, Integer> threeLevelTree(
        final NodeIO<String, Integer, BLinkNode<String, Integer>> io,
        final int leafM, final int internalM) throws IOException, InterruptedException {
        final BLinkTree<String, Integer> btree = 
            new BLinkTree<String, Integer>(io, leafM, internalM, comp, lockFactory);
        btree.insert("A",    0);
        btree.insert("AA",  -1);
        btree.insert("AAA", -2);
        btree.insert("B",   -3);
        btree.insert("BB",  -4);
        btree.insert("C",   -5);
        btree.insert("CC",  -6);
        btree.insert("CCC", -7);
        btree.insert("D",   -8);
        btree.insert("DD",  -9);
        //This is an accidental duplication, but since it is not built into all
        //the tests that depend on this, I've decided to leave this
        btree.insert("DD", -10);
        btree.insert("E",  -11);
        btree.insert("F",  -12);
        btree.insert("G",  -13);
        btree.insert("H",  -14);
        btree.insert("I",  -15);
        return btree;
    }
    
    @Test
    public void onDiskTest() throws Exception {
        File btreeFile = new File(this.rootDir, "blinktree");
        TreeNodeFactory<String, Integer, BLinkNode<String, Integer>> nodeFactory =
            BLinkNode.nodeFactory(lockFactory, comp);
        
        ConcurrentLruCache<CacheNodeKey, BLinkNode<String, Integer>> cache =
            new ConcurrentLruCache<CacheNodeKey, BLinkNode<String,Integer>>(3);
        
        final int nodeSize = 1024 * 4;
        
        DiskNodeIO<String, Integer, BLinkNode<String, Integer>> io =
            new DiskNodeIO<String, Integer, BLinkNode<String,Integer>>(
                kvio, btreeFile, nodeSize, cache, nodeFactory, 
                BtreeFileVersion.VERSION_1);
        
        final int m = 4;

        @SuppressWarnings("unused")
        final BLinkTree<String, Integer> btree = threeLevelTree(io, m, m);
        io.flushPendingModifications();
        
        cache.clear();
        
        
        final MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> memIo = 
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();

        
        final BLinkTree<String, Integer> inMemory = threeLevelTree(memIo, m, m);
        
        
        DiskNodeIO<String, Integer, BLinkNode<String, Integer>> newIo =
            new DiskNodeIO<String, Integer, BLinkNode<String,Integer>>(
                kvio, btreeFile, nodeSize, cache, nodeFactory, 
                BtreeFileVersion.VERSION_1);
        final BLinkTree<String, Integer> readTree = 
            new BLinkTree<String, Integer>(newIo,m , m, comp, lockFactory);
        
        for (Map.Entry<String, Integer> entry : inMemory) {
            assertEquals(entry.getValue(), readTree.find(entry.getKey()));
        }
        
        //delete everything
        for (Map.Entry<String, Integer> entry : inMemory) {
            //System.out.println("Deleteing " + entry.getKey());
            assertEquals(entry.getValue(), readTree.delete(entry.getKey()));
            assertEquals(null, readTree.find(entry.getKey()));
        }
        btree.checkInvariants();
    }
    
    @Test
    public void bigBLinkTreeTest() throws Exception {
        File btreeFile = new File(this.rootDir, "blinktree");
        TreeNodeFactory<String, Integer, BLinkNode<String, Integer>> nodeFactory =
            BLinkNode.nodeFactory(lockFactory, comp);
        
        ConcurrentLruCache<CacheNodeKey, BLinkNode<String, Integer>> cache =
            new ConcurrentLruCache<CacheNodeKey, BLinkNode<String,Integer>>(16);
        
        final int nodeSize = 1024;
        
        DiskNodeIO<String, Integer, BLinkNode<String, Integer>> io =
            new DiskNodeIO<String, Integer, BLinkNode<String,Integer>>(
                kvio, btreeFile, nodeSize, cache, nodeFactory, 
                BtreeFileVersion.VERSION_1);
        
        final int leafM = LeafNode.leafM(kvio, nodeSize);
        final int internalM = InternalNode.internalM(kvio, nodeSize);
        
        //System.out.println(leafM + " " + internalM);
        
        final int nKeys = 1024 * 32;
        Random rand = new Random(234324L);
        Map<String, Integer> srcPairs = new ConcurrentHashMap<String, Integer>();
        while (srcPairs.size() < nKeys) {
            int n = rand.nextInt(1024*1024 * 2);
            srcPairs.put(Integer.toString(n), n);
        }
        
        BLinkTree<String, Integer> btree = 
            new BLinkTree<String, Integer>(io, leafM, internalM, comp, lockFactory);
        int count = 0;
        for (Map.Entry<String, Integer> srcEntry : srcPairs.entrySet()) {
            btree.insert(srcEntry.getKey(), srcEntry.getValue());
            count++;
            if (count % 64 == 0) {
                io.flushPendingModifications();
            }
        }
        
        io.flushPendingModifications();
        
        for (Map.Entry<String, Integer> srcEntry : srcPairs.entrySet()) {
            assertEquals(srcEntry.getValue(), btree.find(srcEntry.getKey()));
        }
        
        List<Map.Entry<String, Integer>> listOfAll = 
            new ArrayList<Map.Entry<String, Integer>>(srcPairs.entrySet());
        
        Collections.sort(listOfAll, new Comparator<Map.Entry<String, Integer>>() {

            @Override
            public int compare(Entry<String, Integer> o1,
                Entry<String, Integer> o2) {
                
                return comp.compare(o1.getKey(), o2.getKey());
            }
            
        });
        
        
        Iterator<Map.Entry<String, Integer>> btreeIt = btree.iterator();
        Iterator<Map.Entry<String, Integer>> sortedIt = listOfAll.iterator();
        
        while (sortedIt.hasNext()) {
            Map.Entry<String, Integer> fromSrc = sortedIt.next();
            Map.Entry<String, Integer> fromBtree = btreeIt.next();
            
            assertEquals(fromSrc.getKey(), fromBtree.getKey());
            assertEquals(fromSrc.getValue(), fromBtree.getValue());
        }
        
        assertFalse(btreeIt.hasNext());
     
        
//        BufferedWriter bwrite = new BufferedWriter(new FileWriter("/tmp/big.blinktree.dot"));
//        
//        bwrite.write(btree.toDot());
//        bwrite.close();
          btree.checkInvariants();
    }
}
