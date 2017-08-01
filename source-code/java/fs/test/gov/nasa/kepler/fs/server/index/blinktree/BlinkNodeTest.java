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

import static gov.nasa.kepler.fs.server.index.blinktree.BLinkNode.UNALLOCATED_ADDRESS;
import static gov.nasa.kepler.fs.server.index.blinktree.InternalNode.GREATER_THAN_EVERYTHING;
import static org.junit.Assert.*;
import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.kepler.fs.server.index.blinktree.InternalNode.InternalNodeSplit;
import gov.nasa.kepler.fs.server.index.blinktree.LeafNode.LeafNodeSplit;
import gov.nasa.kepler.fs.server.index.blinktree.TreeDeleteModification.DeleteModType;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantLock;
import gov.nasa.kepler.io.DataOutputStream;

import java.io.*;
import java.util.Comparator;
import java.util.NoSuchElementException;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

import com.google.common.collect.ImmutableSortedMap;
import com.google.common.collect.ImmutableSortedMap.Builder;
import com.trifork.clj_ds.PersistentTreeMap;

/**
 * @author Sean McCauliff
 *
 */
@RunWith(JMock.class)
public class BlinkNodeTest {

    public final static Comparator<String> comp = new Comparator<String>() {

        @Override
        public int compare(String o1, String o2) {
            return o1.compareTo(o2);
        }
    };
    
    private static final int MAX_KEY_LENGTH = 7;
    
    public final  static KeyValueIO<String, Integer> kvio = new KeyValueIO<String, Integer>() {
        
        @Override
        public void writeValue(DataOutput dout, Integer value) throws IOException {
            dout.writeInt(value);
        }
        
        @Override
        public void writeKey(DataOutput dout, String key) throws IOException {
            if (key.length() > MAX_KEY_LENGTH) {  //assuming ascii characters
                throw new IllegalArgumentException("key too long");
            }
            dout.writeUTF(key);
        }
        
        @Override
        public int valueSize() {
            return 4;
        }
        
        @Override
        public Integer readValue(DataInput din) throws IOException {
            return din.readInt();
        }
        
        @Override
        public String readKey(DataInput din) throws IOException {
            return din.readUTF();
        }
        
        @Override
        public int keySize() {
            return MAX_KEY_LENGTH + 2 /* utf header */;
        }
    };
    
    private final Comparator<Object> internalNodeComp = InternalNode.buildComparator(comp);
    
    private Mockery mockery;
    
    @Before
    public void setUp() {
        mockery = new Mockery();
        mockery.setImposteriser(ClassImposteriser.INSTANCE);
    }
    
    @Test
    public void internalNodeSplit() throws IOException {
        final long leftNodeAddress = 1;
        final long rightNodeAddress = 3;
        
        
        PersistentTreeMap<Object, Long> children = LeafNode.empty(internalNodeComp);
        children = children.assoc("A", 100L).assoc("B", 101L).assoc("C", 102L)
            .assoc("D", 103L).assoc("E", 104L).assoc("F", 105L)
            .assoc("G", 106L).assoc("H", 107L)
            .assoc(GREATER_THAN_EVERYTHING, 108L);
        
        
        final InternalNode<String,Integer> node = 
            new InternalNode<String, Integer>(leftNodeAddress, new DebugReentrantLock(),
                 7777L, "I", children);


        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io = mockery.mock(NodeIO.class);
        mockery.checking(new Expectations() {{
            //The following assumes that BLinkNode.equals() is only shallow
            //equality; it only checks the address of the nodes.
            one(io).writeNode(node);
            PersistentTreeMap<Object,Long> bogusMap = PersistentTreeMap.create(internalNodeComp, null);
            bogusMap = bogusMap.assoc(GREATER_THAN_EVERYTHING,322L); 
            InternalNode<String,Integer> newNode = 
                new InternalNode<String,Integer>(rightNodeAddress, new DebugReentrantLock(),  UNALLOCATED_ADDRESS, null, bogusMap);
            one(io).writeNode(newNode);
        }});
        
        InternalNodeSplit<String, Integer> splitResult =
            node.split(io, rightNodeAddress,new DebugReentrantLock());
        
        assertEquals(rightNodeAddress, splitResult.newLeft.rightLink());
        assertEquals(node.rightLink(), splitResult.newRight.rightLink());
        
        assertEquals("E", splitResult.newLeft.highKey());
        assertEquals("I", splitResult.newRight.highKey());
   
        Builder<Object, Long> builder = ImmutableSortedMap.orderedBy(internalNodeComp);
        builder.put("A", 100L).put("B", 101L).put("C", 102L).put("D", 103L).put(GREATER_THAN_EVERYTHING, 104L);
        assertEquals(builder.build(), splitResult.newLeft.children());
        
        
        builder = ImmutableSortedMap.orderedBy(internalNodeComp);
        builder.put("F", 105L).put("G", 106L).put("H", 107L).put(GREATER_THAN_EVERYTHING, 108L);
        assertEquals(builder.build(), splitResult.newRight.children());
    }
    
    
    @Test
    public void leafNodeSplit() throws Exception {
        final long leftAddress = 55;
        final long newAddress = 101;
        
        PersistentTreeMap<String,Integer> leftMap = PersistentTreeMap.create(comp,PersistentTreeMap.EMPTY.seq());
        leftMap = leftMap.assoc("A", 0);
        leftMap = leftMap.assoc("B", 1);
        leftMap = leftMap.assoc("C", 2);
        leftMap = leftMap.assoc("D", 3);
        leftMap = leftMap.assoc("E", 4);
        leftMap = leftMap.assoc("F", 5);
        leftMap = leftMap.assoc("G", 6);
        leftMap = leftMap.assoc("H", 7);
        
        final LeafNode<String, Integer> leftNode = 
            new LeafNode<String, Integer>(leftAddress, new DebugReentrantLock(),
                null, UNALLOCATED_ADDRESS,leftMap);
        
        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io = mockery.mock(NodeIO.class);
        mockery.checking( new Expectations() {{
            one(io).writeNode(leftNode);
            @SuppressWarnings("unchecked")
            PersistentTreeMap<String,Integer> emptyMap = PersistentTreeMap.EMPTY;
            one(io).writeNode(new LeafNode<String,Integer>(newAddress, 
                new DebugReentrantLock(), null, UNALLOCATED_ADDRESS, emptyMap));
        }});
        DebugReentrantLock newNodesLock = new DebugReentrantLock();
        newNodesLock.lock();
        leftNode.lock();
        LeafNodeSplit<String,Integer> newNodes = 
            leftNode.split(newNodesLock, newAddress, io);  
        
        LeafNode<String,Integer> newLeft = newNodes.newLeft;
        LeafNode<String,Integer> newRight = newNodes.newRight;
        assertEquals(leftAddress, newLeft.address());
        assertEquals(newAddress, newLeft.rightLink());
        assertEquals(newAddress, newRight.address());
        assertEquals(UNALLOCATED_ADDRESS, newRight.rightLink());
        
        
        assertEquals(ImmutableSortedMap.of("A", 0, "B", 1, "C", 2, "D", 3),  newLeft.keyValuePairs());
        assertEquals(ImmutableSortedMap.of("E",4, "F", 5,"G", 6,"H", 7), newRight.keyValuePairs());
        
    }
    
    @Test
    public void leafNodeInsert() throws Exception {
        
        PersistentTreeMap<String,Integer> leftMap = PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        leftMap = leftMap.assoc("A", 0);
        leftMap = leftMap.assoc("B", 1);
        leftMap = leftMap.assoc("C", 2);
        leftMap = leftMap.assoc("D", 3);
        
        final LeafNode<String, Integer> leftNode = 
            new LeafNode<String, Integer>(88, new DebugReentrantLock(),null,
                UNALLOCATED_ADDRESS,leftMap);
        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io = mockery.mock(NodeIO.class);
        mockery.checking( new Expectations() {{
            one(io).writeNode(leftNode);
        }});
        

        LeafNode<String,Integer> newLeftNode = leftNode.insertNonFull("BB", 11, io);
        assertEquals(ImmutableSortedMap.of("A", 0, "B", 1, "BB",11,"C", 2, "D",3), newLeftNode.keyValuePairs());
    }
    
    @Test
    public void deleteFromLeaf() throws Exception {
        
        PersistentTreeMap<String,Integer> leftMap = PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        leftMap = leftMap.assoc("A", 0);
        leftMap = leftMap.assoc("B", 1);
        leftMap = leftMap.assoc("C", 2);
        leftMap = leftMap.assoc("D", 3);
        
        final LeafNode<String, Integer> leafNode = 
            new LeafNode<String, Integer>(88, new DebugReentrantLock(),null,
                UNALLOCATED_ADDRESS,leftMap);

        MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io =
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        
        TreeDeleteModification<String,Integer> deleteMod = leafNode.deleteKey("B", io);
        assertEquals(Integer.valueOf(1), deleteMod.value());
        assertEquals(DeleteModType.LEAF_DELETE_OK, deleteMod.type());
        assertEquals(null, deleteMod.replacementHighKey());
        
        
        deleteMod = leafNode.deleteKey("A", io);
        
        assertEquals(Integer.valueOf(0), deleteMod.value());
        assertEquals(DeleteModType.LEAF_DELETE_OK, deleteMod.type());
    
        assertEquals(ImmutableSortedMap.of("B", 1, "C", 2, "D", 3), ((LeafNode<String,Integer>)io.readNode(leafNode.address())).keyValuePairs());
        assertEquals("B", deleteMod.replacementHighKey());
    }
    
    
    @Test
    public void leafNodeUnderflowMerge() throws Exception {
        PersistentTreeMap<String,Integer> leftMap = 
            PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        leftMap = leftMap.assoc("A", 0).assoc("B", 1);
        
        final LeafNode<String, Integer> leftNode = 
            new LeafNode<String, Integer>(88, new DebugReentrantLock(),"E",
                99,leftMap);
        
        PersistentTreeMap<String,Integer> rightMap = 
            PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        rightMap = rightMap.assoc("E", 4).assoc("F", 5).assoc("G",6).assoc("H",7);
        
        final LeafNode<String, Integer> rightNode = 
            new LeafNode<String, Integer>(99, new DebugReentrantLock(),null,
                UNALLOCATED_ADDRESS,rightMap);
        
        MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io =
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        

        TreeDeleteModification<String, Integer> shadowedChange = 
            new TreeDeleteModification<String,Integer>(DeleteModType.LEAF_DELETE_OK, 2);
        TreeDeleteModification<String, Integer> deleteMod = leftNode.underflow(shadowedChange, rightNode, io);
        assertEquals(DeleteModType.UNDERFLOW, deleteMod.type());
        assertEquals(null, deleteMod.replacementHighKey());
        NodeUnderflow<String, Integer> underflowChange = (NodeUnderflow<String,Integer>) deleteMod;
        assertEquals(Integer.valueOf(2), underflowChange.value());
        assertEquals("F",underflowChange.leftNodeNewHighKey);
        assertEquals("E", underflowChange.leftNodeOldHighKey);
        
        LeafNode<String,Integer> newLeft = (LeafNode<String,Integer>) io.readNode(leftNode.address());
        assertEquals(ImmutableSortedMap.of("A", 0, "B", 1, "E", 4), newLeft.keyValuePairs());
        assertEquals("F", newLeft.highKey());
        
        LeafNode<String, Integer> newRight = (LeafNode<String,Integer>) io.readNode(rightNode.address());
        assertEquals(ImmutableSortedMap.of("F", 5, "G", 6, "H", 7), newRight.keyValuePairs());

        //merge
        deleteMod = leftNode.merge(shadowedChange,rightNode, io);
        newLeft = (LeafNode<String,Integer>)io.readNode(leftNode.address());
        assertEquals(DeleteModType.MERGE, deleteMod.type());
        assertEquals(null, deleteMod.replacementHighKey());
        NodeMerge<String,Integer> nodeMerge = (NodeMerge<String,Integer>)deleteMod;
        
        assertEquals(shadowedChange.value(), nodeMerge.value());
        assertEquals("E",nodeMerge.oldLeftHighKey);
        assertEquals(rightNode.address(), nodeMerge.deletedRightNode.address());
        assertEquals(new ImmutableSortedMap.Builder<String,Integer>(comp).put("A",0).put("B",1).put("E", 4).put("F", 5).put("G", 6).put("H", 7).build(),
            ((LeafNode<String,Integer>)nodeMerge.leftNode).keyValuePairs());
        assertEquals(null, nodeMerge.leftNode.highKey());
        assertEquals(UNALLOCATED_ADDRESS, newLeft.rightLink());
        
        
    }
    
    /**
     * A lower level has change an anchor/high key
     * @throws Exception
     */
    @Test
    public void internalNodeChangeAnchorKey() throws Exception {
        PersistentTreeMap<Object, Long> children = PersistentTreeMap.create(internalNodeComp, null);
        children = children.assoc("A", 100L).assoc("B", 101L).assoc("C", 102L)
            .assoc("D", 103L).assoc("E", 104L).assoc("F", 105L).assoc("G", 106L)
            .assoc("H", 107L).assoc(GREATER_THAN_EVERYTHING, 108L);
        
        final InternalNode<String,Integer> parentNode =
            new InternalNode<String, Integer>(4, new DebugReentrantLock(),
                UNALLOCATED_ADDRESS, null, children);
        
        TreeDeleteModification<String, Integer> highKeyChange = 
            new TreeDeleteModification<String, Integer>(DeleteModType.LEAF_DELETE_OK, 42, "EE");
        
        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io =
            mockery.mock(NodeIO.class);
        mockery.checking(new Expectations() {{
            one(io).writeNode(parentNode);
        }});
        
        InternalNode<String,Integer> newParentNode = 
            parentNode.changeAnchorKey(highKeyChange, "E", io);
        
        assertEquals(children.without("E").assoc("EE", 104L), newParentNode.children());
    }
    
    /**
     * Two nodes (103L and 104L) have merged at a lower level.
     * @throws Exception
     */
    @Test
    public void internalNodeApplyMerge() throws Exception {
        PersistentTreeMap<Object, Long> children = PersistentTreeMap.create(internalNodeComp, null);
        children = children.assoc("A", 100L).assoc("B", 101L).assoc("C", 102L)
            .assoc("D", 103L).assoc("E", 104L).assoc("F", 105L).assoc("G", 106L)
            .assoc("H", 107L).assoc(GREATER_THAN_EVERYTHING, 108L);
        
        final InternalNode<String,Integer> parentNode =
            new InternalNode<String, Integer>(4, new DebugReentrantLock(),
                UNALLOCATED_ADDRESS, null, children);
        
        PersistentTreeMap<Object, Long> mergedNodesChildren = PersistentTreeMap.create(internalNodeComp, null);
        mergedNodesChildren = mergedNodesChildren.assoc("CC", 999L)
            .assoc("CCC", 888L).assoc("DD", 1000L).assoc(GREATER_THAN_EVERYTHING, 1001L);
        
        InternalNode<String,Integer> mergedNode = 
            new InternalNode<String, Integer>(103L, new DebugReentrantLock(), 
                105L, "E", mergedNodesChildren);
        
        PersistentTreeMap<Object, Long> deletedNodesChildren = PersistentTreeMap.create(internalNodeComp, null);
        deletedNodesChildren = deletedNodesChildren.assoc("DD", 1000L).assoc(GREATER_THAN_EVERYTHING, 1001L);
        
        InternalNode<String,Integer> deletedNode = 
            new InternalNode<String,Integer>(104L, new DebugReentrantLock(),
                105L, "E", deletedNodesChildren);
        
        NodeMerge<String,Integer> nodeMerge = 
            new NodeMerge<String, Integer>(-23, null, mergedNode, "D", deletedNode);
        
        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io =
            mockery.mock(NodeIO.class);
        mockery.checking(new Expectations() {{
            one(io).writeNode(parentNode);
        }});
        InternalNode<String,Integer> newParentNode = 
            parentNode.applyMerge(nodeMerge, io);
        assertEquals(parentNode.address(), newParentNode.address());
        assertEquals(parentNode.rightLink(), newParentNode.rightLink());
        assertEquals(parentNode.highKey(), newParentNode.highKey());
        assertEquals(parentNode.lock, newParentNode.lock);
        assertEquals(children.without("D").assoc("E", 103L), newParentNode.children());
        
    }
    
    @Test
    public void internalNodeMergeAndUnderflow() throws Exception {
        PersistentTreeMap<Object, Long> leftChildren = PersistentTreeMap.create(internalNodeComp, null);
        leftChildren  = leftChildren.assoc("CC", 888L)
            .assoc("CCC", 889L).assoc("CCCC", 890L).assoc(GREATER_THAN_EVERYTHING, 891L);
        
        final InternalNode<String,Integer> leftNode = 
            new InternalNode<String, Integer>(103L, new DebugReentrantLock(), 
                104L, "D", leftChildren);
        
        PersistentTreeMap<Object, Long> rightChildren = PersistentTreeMap.create(internalNodeComp, null);
        rightChildren = rightChildren.assoc("DD", 1000L).assoc(GREATER_THAN_EVERYTHING, 1001L);
        
        
        final InternalNode<String,Integer> rightNode = 
            new InternalNode<String,Integer>(104L, new DebugReentrantLock(),
                105L, "E", rightChildren);
        
        MemoryNodeIO<String, Integer, BLinkNode<String,Integer>> io =
            new MemoryNodeIO<String, Integer, BLinkNode<String,Integer>>();
        
        TreeDeleteModification<String, Integer> shadowedModification =
            new TreeDeleteModification<String, Integer>(DeleteModType.LEAF_DELETE_OK, -33);
        TreeDeleteModification<String,Integer> deleteMod = leftNode.underflow(shadowedModification, rightNode, io);
        assertEquals(DeleteModType.UNDERFLOW, deleteMod.type());
        
        NodeUnderflow<String, Integer> underflow = (NodeUnderflow<String,Integer>) deleteMod;
        
        assertEquals("D", underflow.leftNodeOldHighKey);
        assertEquals("CCCC", underflow.leftNodeNewHighKey);
        assertEquals(Integer.valueOf(-33), underflow.value());
        
        InternalNode<String,Integer> newLeftNode = (InternalNode<String, Integer>) io.readNode(leftNode.address());
        assertEquals(leftNode.address(), newLeftNode.address());
        assertEquals(leftNode.lock, newLeftNode.lock);
        assertEquals("CCCC", newLeftNode.highKey());
        assertEquals(104L, newLeftNode.rightLink());
        assertEquals(leftChildren.without("CCCC").assoc(GREATER_THAN_EVERYTHING, 890L), newLeftNode.children());
        
        InternalNode<String,Integer> newRightNode = (InternalNode<String,Integer>) io.readNode(rightNode.address());
        assertEquals(rightNode.address(), newRightNode.address());
        assertEquals(rightNode.lock, newRightNode.lock);
        assertEquals(rightNode.highKey(), newRightNode.highKey());
        assertEquals(rightNode.rightLink(), newRightNode.rightLink());
        assertEquals(rightChildren.assoc("D", 891L), newRightNode.children());

        
        deleteMod = leftNode.merge(shadowedModification, rightNode, io);
        
        assertEquals(DeleteModType.MERGE, deleteMod.type());
        
        NodeMerge<String, Integer> nodeMerge = (NodeMerge<String, Integer>) deleteMod;
        assertEquals(Integer.valueOf(-33), nodeMerge.value());
        assertEquals("D", nodeMerge.oldLeftHighKey);
        assertEquals(rightNode.address(), nodeMerge.deletedRightNode.address());
        assertEquals(leftNode.address(), nodeMerge.leftNode.address());
        assertEquals(leftNode.lock, nodeMerge.leftNode.lock);
        assertEquals(rightNode.highKey(), nodeMerge.leftNode.highKey());
        assertEquals(rightNode.rightLink(), nodeMerge.leftNode.rightLink());
        
        newLeftNode = (InternalNode<String, Integer>) nodeMerge.leftNode;
        assertEquals(leftChildren.assoc("D", 891L).assoc("DD", 1000L).assoc(GREATER_THAN_EVERYTHING, 1001L), newLeftNode.children());
        
        try {
            io.readNode(rightNode.address());
            assertTrue("Should not have reached here.", false);
        } catch (NoSuchElementException nsee) {
            //OK
        }
    }
    
    @Test
    public void readWriteLeafNode() throws IOException {
        NodeLockFactory lockFactory = new NodeLockFactory();
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);
        PersistentTreeMap<String, Integer> keyValuePairs = LeafNode.empty(comp);
        keyValuePairs = keyValuePairs.assoc("A", 0).assoc("B", 1).assoc("C", 2).assoc("D", 3);
        LeafNode<String, Integer> leafNode = 
            new LeafNode<String, Integer>(0, lockFactory.nodesLock(0L),
                "Z", 999, keyValuePairs);
        
        
        leafNode.write(dout, kvio);
        TreeNodeFactory<String, Integer, BLinkNode<String, Integer>> nodeFactory =
            BLinkNode.nodeFactory(lockFactory, comp);
        
        
        assertEquals(1+1+3+8+2+(3+4)*4, bout.size());
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        DataInputStream din = new DataInputStream (bin);
        
        
        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io = mockery.mock(NodeIO.class);
        mockery.checking(new Expectations() {{
            one(io).keyValueIO();
            will(returnValue(kvio));
        }});
        
        LeafNode<String,Integer> readLeaf = (LeafNode<String, Integer>) nodeFactory.read(0, din, io);
        assertEquals(0L, readLeaf.address());
        assertEquals(leafNode.rightLink(), readLeaf.rightLink());
        assertSame(leafNode.lock, readLeaf.lock);
        assertEquals(leafNode.keyValuePairs(), readLeaf.keyValuePairs());
        assertEquals(leafNode.highKey(), readLeaf.highKey());
        
    }
    
    @Test
    public void readWriteInternalNode() throws IOException {
        NodeLockFactory lockFactory = new NodeLockFactory();
        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        DataOutputStream dout = new DataOutputStream(bout);
        PersistentTreeMap<Object, Long> children = LeafNode.empty(this.internalNodeComp);
        children = children.assoc("A", 0L).assoc("B", 1L).assoc("C", 2L).assoc(GREATER_THAN_EVERYTHING, 3L);
        InternalNode<String, Integer> internalNode = 
            new InternalNode<String, Integer>(0L, lockFactory.nodesLock(0L), UNALLOCATED_ADDRESS,
                null, children);
        
        
        internalNode.write(dout, kvio);
        TreeNodeFactory<String, Integer, BLinkNode<String, Integer>> nodeFactory =
            BLinkNode.nodeFactory(lockFactory, comp);
        
        
        assertEquals(1+1+8+2+(3+8)*3+8, bout.size());
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        DataInputStream din = new DataInputStream (bin);
        
        
        @SuppressWarnings("unchecked")
        final NodeIO<String, Integer, BLinkNode<String,Integer>> io = mockery.mock(NodeIO.class);
        mockery.checking(new Expectations() {{
            one(io).keyValueIO();
            will(returnValue(kvio));
        }});
        
        InternalNode<String,Integer> readInternal = (InternalNode<String, Integer>) nodeFactory.read(0, din, io);
        assertEquals(0L, readInternal.address());
        assertEquals(internalNode.rightLink(), readInternal.rightLink());
        assertSame(internalNode.lock, readInternal.lock);
        assertEquals(internalNode.children(), readInternal.children());
        assertEquals(internalNode.highKey(), readInternal.highKey());
        
    }
    
    @Test
    public void mArynessCalculationTest() throws Exception {
        final int nodeSize = 1024;
        int leafM = LeafNode.leafM(kvio, nodeSize);
        int expectedLeafM = (1024 - 1 - 1 - MAX_KEY_LENGTH - 2 - 8 - 2) / (MAX_KEY_LENGTH + 2 + 4);
        assertEquals(expectedLeafM, leafM);
        
        
        int internalM = InternalNode.internalM(kvio, nodeSize);
        int expectedInternalM = (1024 - 1 -1 - MAX_KEY_LENGTH - 2 - 8 - 2 - 8) / (MAX_KEY_LENGTH + 2 + 8);
        assertEquals(expectedInternalM, internalM);
    }
 
}
