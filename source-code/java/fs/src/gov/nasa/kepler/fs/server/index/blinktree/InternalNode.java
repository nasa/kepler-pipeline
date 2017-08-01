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

import gnu.trove.TLongHashSet;
import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.NodeIO;
import gov.nasa.kepler.fs.server.index.blinktree.TreeDeleteModification.DeleteModType;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantLock;

import java.io.DataOutput;
import java.io.IOException;
import java.util.*;

import com.google.common.collect.Iterators;
import com.google.common.collect.PeekingIterator;
import com.trifork.clj_ds.PersistentTreeMap;

/**
 * This is an internal node in the B-link tree.  It has only keys, and children,
 * but not values.  This class is MT-safe and immutable, it must be locked
 * before using a method which requires io.  This is to insure the structure of
 * the tree is not damaged.  Readers to not lock.  
 * Internal nodes in the B-link tree do not allow duplicate keys
 * among the internal nodes with the exception of the highKey.
 * Internal nodes will share keys with Internal nodes.
 * 
 * @author Sean McCauliff
 *
 */ 
public final class InternalNode<K,V> extends BLinkNode<K, V>{

    /**
     * This represents the greatest key.  This is here because there are 
     * nKey() + 1 child node pointers.  So the last child node pointer needs
     * to be paired with something.  This is that something.
     */
    static final Object GREATER_THAN_EVERYTHING = new GreatestKey();
    
    static <K> ChildNodeComparator<K> buildComparator(final Comparator<K> baseComparator) {
        return new ChildNodeComparator<K>(baseComparator);
    }
    
    private static final int CHILD_COUNT_SIZE = 2;
    private static final int HEADER_SIZE = 1;
    
    public static <K,V> int internalM(KeyValueIO<K, V> keyValueIo, int nodeSize) {
        int keySize = keyValueIo.keySize();
        
        int highKeyStorage = keySize + FILE_PTR_SIZE + 1; //the +1 is for the key exists byte
        int internalM = (nodeSize - HEADER_SIZE - highKeyStorage - CHILD_COUNT_SIZE - FILE_PTR_SIZE) /
            (keySize + FILE_PTR_SIZE);
        if (internalM-1 > Short.MAX_VALUE) {
            throw new IllegalStateException("internalM may not exceed " + (Short.MAX_VALUE - 1));
        }
        return  internalM;
    }
    
    private final PersistentTreeMap<Object, Long> children;

    /**
     * 
     * @param address
     * @param lock
     * @param rightLink
     * @param highKey  This may be null.
     * @param children
     */
    InternalNode(long address, DebugReentrantLock lock,
        long rightLink, K highKey, PersistentTreeMap<Object,Long> children) {
        super(address, lock, highKey, rightLink);
        
        if (children.maxKey() != GREATER_THAN_EVERYTHING) {
            throw new IllegalArgumentException("The children map must have as it's max key GREATER_THAN_EVERYTHING");
        }
        this.children = children;
        
        if (!(children.comparator() instanceof ChildNodeComparator)) {
            throw new IllegalArgumentException("The children map comparator must be an instance of ChildNodeComparator");
        }
        
        assert check() == null : check();
        
    }

    @Override
    String check() {
        
        TLongHashSet addressSet = new TLongHashSet(2 * children.size());
        for (Map.Entry<Object, Long> entry : children.entrySet()) {
            Object key = entry.getKey();
            Long childAddress = entry.getValue();
            if (key == null) {
                //I don't think this can happen, but I'm just checking
                return this + "entry has null key.";
            }
            if (childAddress == null) {
                return this + "entry with key " + key + "\" has null child address.";
            }
            if (addressSet.contains(childAddress)) {
                return this + "duplicate child address (\"" + key +
                ", " + childAddress + ").";
            }
            
            if (entry.getKey() != GREATER_THAN_EVERYTHING &&
                highKey() != null &&
                children.comparator().compare(highKey(), entry.getKey()) <= 0) {
                return this + " has child key \"" + entry.getKey() + 
                "\" greater than or equal to its high key \"" + highKey() + "\".";
            }
            
            if (childAddress  < 0 ) {
                return this + " key \"" + key + "\" has bad child address " + 
                    childAddress + ".";
            }
            
            if (childAddress > 1024 && childAddress % 1024 != 0) {
                return this + " key \"" + key + "\" has unaligned child address " + 
                    childAddress;
            }
            
        }
        return null;
    }
    
    @Override
    public int nChildren() {
        return children.size();
    }

    @Override
    public boolean isLeaf() {
        return false;
    }

    @Override
    public int nKeys() {
        return children.size() - 1;
    }

    @SuppressWarnings("unchecked")
    @Override
    K minKey() {
        return (K) children.minKey();
    }
    
    @Override
    public String toString() {
        return "[B-link tree internal node " + address() + "]";
    }
    
    @Override
    public boolean equals(Object o) {
        if (!(o instanceof InternalNode)) {
            return false;
        }
        if (o == this) {
            return true;
        }
        @SuppressWarnings("rawtypes")
        InternalNode other = (InternalNode) o;
        return other.address() == this.address();
    }
    
    @Override
    public int hashCode() {
        int hc = (int) (address() >>> 32);
        return hc ^ (int) (address() & 0xffffffff);
    }
    
    @Override
    public void write(DataOutput dout, KeyValueIO<K, V> kvio) throws IOException {
        dout.writeByte(INTERNAL_MAGIC);
        writeRightLink(kvio, dout);
        dout.writeShort(nChildren());
        for (Map.Entry<Object,Long> entry : children) {
            if (entry.getKey() != GREATER_THAN_EVERYTHING) {
                @SuppressWarnings("unchecked")
                K key = (K)entry.getKey();
                kvio.writeKey(dout, key);
                dout.writeLong(entry.getValue());
            } else {
                dout.writeLong(entry.getValue());
            }
        }
    }

    PersistentTreeMap<Object, Long> children() {
        return children;
    }
    
    /**
     * This should only be called if all nodes share the same parent.
     * 
     * @return Returns the keys which should flank the pointer to the new node.
     * These keys will not appear in any of the three nodes.   Also new versions
     * of the nodes are returned.
     * @throws IOException 
     */
    InternalNodeSplit<K,V> split(NodeIO<K, V, BLinkNode<K,V>> io,
        long newNodeAddress, 
        DebugReentrantLock newLock) throws IOException {
        
        Iterator<Map.Entry<Object,Long>> allIt = this.children.entrySet().iterator();
        
       
        final int thisNKeys = this.nKeys() >> 1;
        
        
        PersistentTreeMap<Object,Long> newThisChildren = 
            copyFrom(null, thisNKeys, allIt, this.children.comparator());
        

        @SuppressWarnings("unchecked")
        final Map.Entry<K, Long> parentKey = (Map.Entry<K,Long>) allIt.next();
        newThisChildren = newThisChildren.assoc(GREATER_THAN_EVERYTHING, parentKey.getValue());
        
  
        PersistentTreeMap<Object, Long> newNodeChildren = 
            copyFrom(null, Integer.MAX_VALUE, allIt, this.children.comparator());

        InternalNode<K,V> newThisNode = 
            new InternalNode<K,V>(this.address(), this.lock,
                newNodeAddress, parentKey.getKey(), 
                 newThisChildren);
        
        InternalNode<K,V> newNode =
            new InternalNode<K,V>(newNodeAddress, newLock, this.rightLink(),
                this.highKey(), newNodeChildren);
        io.writeNode(newNode);
        io.writeNode(newThisNode);
        
        return new InternalNodeSplit<K,V>(newThisNode, newNode);
    }
    
    /**
     * This methods assumes that:
     * <ul>
     *  <li> the lock on this has already been acquired </li>
     *  <li> this is the parent </li>
     *  <li> merging the modification would not result in a split to this node </li>
     * </ul>
     * 
     * @param treeModification 
     * @return
     */
    InternalNode<K,V> insertNonFull(TreeInsertModification<K, V> treeMod, NodeIO<K, V, BLinkNode<K,V>> io) throws IOException {
        
        assert this.lock.isHeldByCurrentThread();
        assert (!treeMod.leftNode().isLeaf()) ||
                children.comparator().compare(treeMod.leftNode().highKey(), 
                                             treeMod.rightNode().minKey()) == 0;
        
        BLinkNode<K, V> leftNode = treeMod.leftNode();
        BLinkNode<K, V> rightNode = treeMod.rightNode();
        PersistentTreeMap<Object,Long> newChildren = children;
        
        if (rightNode.highKey() == null) {
            newChildren = newChildren.assoc(leftNode.highKey(), leftNode.address());
            newChildren = newChildren.assoc(GREATER_THAN_EVERYTHING, rightNode.address());
        } else if (newChildren.iteratorFrom(rightNode.highKey()).next().getKey() == GREATER_THAN_EVERYTHING) {
            newChildren = newChildren.assoc(GREATER_THAN_EVERYTHING, rightNode.address());
            newChildren = newChildren.assoc(leftNode.highKey(), leftNode.address());
        } else {
            newChildren = newChildren.assoc(leftNode.highKey(), leftNode.address());
            newChildren = newChildren.assoc(rightNode.highKey(), rightNode.address());
        }
        
        InternalNode<K,V> updatedNode = 
            new InternalNode<K,V>(this.address(), this.lock, 
                this.rightLink(), this.highKey(), newChildren);
        if (io != null) {
            io.writeNode(updatedNode);
        }
        return updatedNode;
    }
    
    InternalNode<K,V> insertFull(TreeInsertModification<K, V> treeModification) {
        try {
            return insertNonFull(treeModification, null);
        } catch (IOException ioe) {
            throw new IllegalStateException("This can't happen.", ioe);
        }
    }
    
    /**
     * This node's high key should be null or greater than the specified key.
     * 
     * @param key
     * @param io
     * @return
     * @throws IOException
     */
    BLinkNode<K,V> childForKey(K key, NodeIO<K, V, BLinkNode<K,V>> io) throws IOException {
        Iterator<Map.Entry<Object,Long>> childIt = children.iteratorFrom(key);
        Map.Entry<Object, Long> child = childIt.next();
        if (children.comparator().compare(key, child.getKey()) == 0) {
            child = childIt.next();
        }
        return io.readNode(child.getValue());
    }
    
    /**
     * 
     * @param deleteModification This should be a underflow or high key change.
     * @param deleteKey the key that was being deleted from the tree
     * @param io
     * @return
     * @throws IOException
     */
    InternalNode<K,V> changeAnchorKey(TreeDeleteModification<K, V> deleteModification,
        K deleteKey,
        NodeIO<K, V, BLinkNode<K,V>> io) throws IOException {

        PersistentTreeMap<Object, Long> changedChildren = null;
        if (deleteModification.type() == DeleteModType.UNDERFLOW) {
            NodeUnderflow<K, V> underflow = (NodeUnderflow<K,V>) deleteModification;
            Long childAddress = this.children.get(underflow.leftNodeOldHighKey);
            changedChildren = children.without(underflow.leftNodeOldHighKey).assoc(underflow.leftNodeNewHighKey,childAddress);
        }
        if (deleteModification.replacementHighKey() != null &&
            children.containsKey(deleteKey)) {
            if (changedChildren == null) {
                changedChildren = this.children;
            }
            Long childAddress = this.children.get(deleteKey);
            changedChildren = changedChildren.without(deleteKey).assoc(deleteModification.replacementHighKey(), childAddress);
        }
        
        if (changedChildren == null) {
            return this;
        }
        
        InternalNode<K,V> newInternalNode = 
            new InternalNode<K,V>(this.address(),
                    this.lock, this.rightLink(), 
                    this.highKey(), changedChildren);
        io.writeNode(newInternalNode);
        return newInternalNode;
    }
    
    InternalNode<K,V> applyMerge(NodeMerge<K, V> nodeMerge, NodeIO<K, V, BLinkNode<K,V>> io) throws IOException {
        PersistentTreeMap<Object,Long> newChildren = 
            children.without(nodeMerge.oldLeftHighKey);
        if (nodeMerge.deletedRightNode.highKey() != nodeMerge.leftNode.highKey()) {
            throw new IllegalStateException("Merged nodes: new left's high key should be old right's high key.");
        }
        if (newChildren.iteratorFrom(nodeMerge.oldLeftHighKey).next().getKey() != GREATER_THAN_EVERYTHING) {
            newChildren = newChildren.assoc(nodeMerge.leftNode.highKey(), nodeMerge.leftNode.address());
        } else {
            newChildren = newChildren.assoc(GREATER_THAN_EVERYTHING, nodeMerge.leftNode.address());
        }
        InternalNode<K,V> newInternalNode = 
            new InternalNode<K,V>(this.address(), this.lock,
                this.rightLink(), this.highKey(), newChildren);
        io.writeNode(newInternalNode);
        return newInternalNode;
    }
    
    
    TreeDeleteModification<K, V> merge(TreeDeleteModification<K,V> shadowedModification,
        InternalNode<K,V> rightNode, NodeIO<K, V, BLinkNode<K,V>> io) throws IOException {
        checkRightNode(rightNode);
        
        Long maxChild = this.children.get(GREATER_THAN_EVERYTHING);
        PersistentTreeMap<Object, Long> mergedChildren = 
            this.children.without(GREATER_THAN_EVERYTHING).assoc(this.highKey(), maxChild);
        mergedChildren = copyFrom(mergedChildren, Integer.MAX_VALUE, 
            rightNode.children.entrySet().iterator(), children.comparator());
        
        InternalNode<K,V> newLeft = 
            new InternalNode<K,V>(this.address(), this.lock, rightNode.rightLink(), 
                rightNode.highKey(), mergedChildren);
        io.deleteNode(rightNode);
        io.writeNode(newLeft);
        return new NodeMerge<K,V>(shadowedModification.value(),
            shadowedModification.replacementHighKey(),
            newLeft, this.highKey(), rightNode);

    }
    
    TreeDeleteModification<K,V> underflow(TreeDeleteModification<K,V> shadowedModification,
        InternalNode<K,V> rightNode, NodeIO<K, V, BLinkNode<K,V>> io) throws IOException {
        checkRightNode(rightNode);
        
        Long maxChild = this.children.get(GREATER_THAN_EVERYTHING);
        PersistentTreeMap<Object, Long> editedChildren = 
            this.children.without(GREATER_THAN_EVERYTHING).assoc(this.highKey(), maxChild);
        
        Iterator<Map.Entry<Object,Long>> allIt = 
            Iterators.concat(editedChildren.entrySet().iterator(), 
                rightNode.children.entrySet().iterator());
        
        
        final int thisNKeys = (this.nKeys() + rightNode.nKeys()) >>> 1;
        
        
        PersistentTreeMap<Object,Long> newThisChildren = 
            copyFrom(null, thisNKeys, allIt, this.children.comparator());
        

        @SuppressWarnings("unchecked")
        final Map.Entry<K, Long> parentKey = (Map.Entry<K,Long>) allIt.next();
        newThisChildren = newThisChildren.assoc(GREATER_THAN_EVERYTHING, parentKey.getValue());
        
  
        PersistentTreeMap<Object, Long> newRightChildren = 
            copyFrom(null, Integer.MAX_VALUE, allIt, this.children.comparator());
        
        InternalNode<K,V> newLeftNode = 
            new InternalNode<K,V>(this.address(), this.lock, this.rightLink(),
                parentKey.getKey(), newThisChildren);
        
        InternalNode<K,V> newRightNode = 
            new InternalNode<K,V>(rightNode.address(), rightNode.lock,
                rightNode.rightLink(), rightNode.highKey(), newRightChildren);
        
        io.writeNode(newLeftNode);
        io.writeNode(newRightNode);
        
//        return new HighKeyChange<K,V>(oldValue, parentKey.getKey(), this.highKey(), newLeftNode);
        return new NodeUnderflow<K, V>(shadowedModification.value(), 
            shadowedModification.replacementHighKey(),
            this.highKey(), newLeftNode.highKey());
    }
    
    
    @Override
    void toDot(StringBuilder bldr) {
        bldr.append("\tnode").append(address()).append("[shape=record,label=\"");
        int i=0;
        for (Object o : children.keySet()) {
            if (o == GREATER_THAN_EVERYTHING) {
                break;
            }
            @SuppressWarnings("unchecked")
            K key  = (K) o;
            bldr.append("<f").append(i*2).append(">|");
            bldr.append("<f").append(2*i+1).append(">").append(key).append("|");
            i++;
        }
        bldr.append("<last>");
        bldr.append("\"];\n");
        
        i=0;
        for (Long childAddress : children.values()) {
            String srcPort =  (i != children.size() - 1) ? "f" + i * 2 : "last";
            String destPort = (!srcPort.equals("last")) ? "last" : "f0";
            bldr.append("\t  \"node").append(address()).append("\":").append(srcPort)
                .append("->node").append(childAddress).append(":").append(destPort).append("[label=\"").append(childAddress).append("\"]\n");
            i++;
        }
        linksToDot(bldr);
    }

    static PersistentTreeMap<Object, Long> assocChild(Object newKey, 
            Long child, PersistentTreeMap<Object,Long> orig) {
     
        if (orig.size() == 0 || orig.size() == 1) {
            throw new IllegalStateException("Don't initialize map this way.");
        }

        if (newKey == null ||
            orig.iteratorFrom(newKey).next().getKey().equals(GREATER_THAN_EVERYTHING)) {
            return orig.assoc(GREATER_THAN_EVERYTHING, child);
        }
        return orig.assoc(newKey, child);
    }
    
    static final class ChildNodeComparator<K> implements Comparator<Object> {

        private final Comparator<K> baseComparator;
        
        
        public ChildNodeComparator(Comparator<K> baseComparator) {
            this.baseComparator = baseComparator;
        }


        @SuppressWarnings("unchecked")
        @Override
        public int compare(Object o1, Object o2) {
            if (o1 == GREATER_THAN_EVERYTHING) {
                if (o2 == GREATER_THAN_EVERYTHING) {
                    return 0;  //This should never happen in a single map, but could happen when comparing maps
                }
                return 1;
            }
            else if (o2 == GREATER_THAN_EVERYTHING) {
                return -1;
            }
            return baseComparator.compare((K)o1, (K)o2);
        }
        
    }
    
    static final class InternalNodeSplit<K,V> extends TreeInsertModification<K,V> {
        final InternalNode<K,V> newLeft;
        final InternalNode<K,V> newRight;
        
        public InternalNodeSplit(
            InternalNode<K, V> newLeft, 
            InternalNode<K, V> newRight) {
            super(InsertModType.INTERNAL_SPLIT);
            this.newLeft = newLeft;
            this.newRight = newRight;
        }

        @Override
        BLinkNode<K, V> leftNode() {
            return newLeft;
        }

        @Override
        BLinkNode<K, V> rightNode() {
            return newRight;
        }
    }
    
    private static final class GreatestKey {
        private GreatestKey() {
            
        }
        
        @Override
        public String toString() {
            return "[Internal node GREATEST_KEY]";
        }
        
        @Override
        public int hashCode() {
            return 1;
        }
        
        @Override
        public boolean equals(Object o) {
            return o.getClass() == GreatestKey.class;
        }
    }
}
