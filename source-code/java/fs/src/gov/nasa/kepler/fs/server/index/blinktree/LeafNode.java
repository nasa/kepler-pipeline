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

import gov.nasa.kepler.fs.server.index.KeyValueIO;
import gov.nasa.kepler.fs.server.index.NodeIO;
import gov.nasa.kepler.fs.server.index.blinktree.TreeDeleteModification.DeleteModType;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantLock;

import java.io.DataOutput;
import java.io.IOException;
import java.util.*;

import com.google.common.collect.*;
import com.trifork.clj_ds.PersistentTreeMap;


/**
 * This is a leaf node in the B-link tree.  It only has keys and values, but not
 * children.  This class is immutable (except for the lock) and MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public final class LeafNode<K,V> extends BLinkNode<K, V>{

    static <K,V> PersistentTreeMap<K,V> empty(Comparator<K> comp) {
        return PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
    }
    
    private final PersistentTreeMap<K, V> keyValuePairs;

    private final static int KEY_COUNT_SIZE = 2;
    private final static int HEADER_SIZE = 1;
    
    /**
     * 
     * @param <K>
     * @param <V>
     * @param keyValueIo
     * @param nodeSize
     * @return an internal node has m+1 children
     */
    public static <K,V> int leafM(KeyValueIO<K, V> keyValueIo, int nodeSize) {
        int keySize = keyValueIo.keySize();
        int valueSize = keyValueIo.valueSize();
        
        int highKeySize = keySize + FILE_PTR_SIZE + 1;
        int leafM = (nodeSize - highKeySize - HEADER_SIZE - KEY_COUNT_SIZE) /
            (keySize + valueSize);
        if (leafM > Short.MAX_VALUE) {
            throw new IllegalStateException("leafM exceeds " + Short.MAX_VALUE);
        }
        return leafM;
    }
    
    /**
     * 
     * @param address
     * @param lock
     * @param highKey  This may be null
     * @param rightLink
     * @param keyValuePairs
     */
    @SuppressWarnings("unchecked")
    LeafNode(long address, DebugReentrantLock lock, K highKey,
        long rightLink, PersistentTreeMap<K,V> keyValuePairs) {
        super(address, lock, highKey, rightLink);

        if (highKey != null && keyValuePairs.comparator().compare((K)keyValuePairs.maxKey(), highKey) > 0) {
            throw new IllegalArgumentException("highkey \"" + highKey +
                "\" is less than or equal to the maximum key " +
                "\"" + keyValuePairs.maxKey() + "\"");
        }
        this.keyValuePairs = keyValuePairs;
        
        assert check() == null;
    }
    
    @Override
    String check() {
        return null;
    }
    
    @Override
    public int nChildren() {
        return 0;
    }

    @Override
    public int nKeys() {
        return keyValuePairs.size();
    }

    @Override
    public boolean isLeaf() {
        return true;
    }
    
    V get(K key) {
        return keyValuePairs.get(key);
    }
    
    @SuppressWarnings("unchecked")
    @Override
    K minKey() {
        return (K) keyValuePairs.minKey();
    }

    PersistentTreeMap<K,V> keyValuePairs() {
        return keyValuePairs;
    }
    
    @Override
    public String toString() {
        return "[B-link tree LeafNode " + address()+ "]";
    }
    
    @Override
    public int hashCode() {
        long addr = address();
        long hc =  addr&  0xffffffff;
        return (int) (hc ^ (addr >>> 32));
    }
    
    /**
     * This is not a deep comparison.
     * @param o
     * @return
     */
    @Override
    public boolean equals(Object o) {
        if (o == this) {
            return true;
        }
        if (!(o instanceof LeafNode)) {
            return false;
        }
        
        LeafNode<?,?> other = (LeafNode<?,?>) o;
        return other.address() == this.address();
    }
    
    @Override
    public void write(final DataOutput dout, final KeyValueIO<K, V> kvio) throws IOException {
        dout.writeByte(LEAF_MAGIC);
        writeRightLink(kvio, dout);
        dout.writeShort(nKeys());
        for (Map.Entry<K,V> entry : keyValuePairs.entrySet()) {
            kvio.writeKey(dout, entry.getKey());
            kvio.writeValue(dout, entry.getValue());
        }
    }

    /**
     * Fills new node and rebalanced keys and values between the three nodes.
     * This ensures nodes stay about 2/3 full.  This node should be the left
     * most node in the chain of nodes.  Check the first key of rightNode and
     * newNode for the new keys which should be propagated into their parents.
     * 
     * @param rightNode The node to the right of this one.  The caller must hold
     * the lock on this address.
     * @param newLock for the new node.
     * @param newAddress for the new node.
     * @param newKey This key should have logically been inserted into the 
     * this node had not it been full.
     * @return a list of length 3 where index 0 is the new this node, index 1
     * is the new new node and index 2 is the new rightNode.
     * @throws IOException 
     */
    LeafNodeSplit<K,V> split(DebugReentrantLock newLock, long newAddress, 
        NodeIO<K,V,BLinkNode<K, V>> io) 
            throws IOException {
        
        assert newLock.isHeldByCurrentThread();
        assert this.lock.isHeldByCurrentThread();
        
        PeekingIterator<Map.Entry<K, V>> it = 
            Iterators.peekingIterator(this.keyValuePairs.entrySet().iterator());
 
        final int newNKeys = nKeys() >> 1;
        PersistentTreeMap<K,V> leftMap = 
            copyFrom(null, newNKeys, it, keyValuePairs.comp);
        
        LeafNode<K,V> newThisNode = 
            new LeafNode<K, V>(address(), lock, it.peek().getKey(), newAddress,leftMap);
        
        
        PersistentTreeMap<K,V> rightMap = copyFrom(null, Integer.MAX_VALUE, it, keyValuePairs.comp);
 
        LeafNode<K,V> newRightNode = 
            new LeafNode<K,V>(newAddress, newLock, this.highKey(),
                this.rightLink(),rightMap);
        io.writeNode(newRightNode);
        io.writeNode(newThisNode); //this must come after the right node
        return new LeafNodeSplit<K,V>(newThisNode, newRightNode);
    }
    
    LeafNode<K,V> insertNonFull(K key, V value, NodeIO<K,V,BLinkNode<K, V>> io) throws IOException {
        
        PersistentTreeMap<K, V> newPairs = keyValuePairs.assoc(key, value);
        LeafNode<K,V> newNode = 
            new LeafNode<K,V>(this.address(), this.lock, this.highKey(), rightLink(), newPairs);
        if (io != null) {
            io.writeNode(newNode);
        }
        return newNode;
    }
    
    LeafNode<K,V> insertFull(K key, V value) {
        try {
            return insertNonFull(key, value, null);
        } catch (IOException ioe) {
            throw new IllegalStateException("This can't happen.", ioe);
        }
    }
    
    TreeDeleteModification<K, V> deleteKey(K key, NodeIO<K,V,BLinkNode<K, V>> io) throws IOException {
        V oldValue = this.keyValuePairs.get(key);
        if (oldValue == null) {
            throw new IllegalArgumentException("key \"" + key + "\"is not present in this node.");
        }
        PersistentTreeMap<K,V> newKeyValues = this.keyValuePairs.without(key);
        LeafNode<K,V> newLeaf = new LeafNode<K,V>(this.address(), this.lock, this.highKey(), this.rightLink(), newKeyValues);
        io.writeNode(newLeaf);
        if (keyValuePairs.comparator().compare(key, this.minKey()) == 0) {
            return new TreeDeleteModification<K,V>(DeleteModType.LEAF_DELETE_OK, oldValue, newLeaf.minKey());
        }
        return new TreeDeleteModification<K, V>(DeleteModType.LEAF_DELETE_OK, oldValue);
    }
    
    
    TreeDeleteModification<K, V> merge(TreeDeleteModification<K,V> shadowedModification,
        LeafNode<K,V> rightNode, NodeIO<K,V, BLinkNode<K,V>> io) throws IOException {
        checkRightNode(rightNode);
        
        
        Iterator<Map.Entry<K, V>> allIt =
            Iterators.concat(this.keyValuePairs.entrySet().iterator(), 
                rightNode.keyValuePairs.entrySet().iterator());
        PersistentTreeMap<K, V> mergedKeyValuePairs = 
            copyFrom(null, Integer.MAX_VALUE, allIt,
                 this.keyValuePairs.comparator());
        LeafNode<K,V> newLeaf = new LeafNode<K,V>(this.address(), 
            this.lock, rightNode.highKey(), 
            rightNode.rightLink(), mergedKeyValuePairs);
        io.deleteNode(rightNode);
        io.writeNode(newLeaf);
        return new NodeMerge<K,V>(shadowedModification.value(), 
            shadowedModification.replacementHighKey(), 
            newLeaf, this.highKey(), rightNode);
    }
    
    TreeDeleteModification<K, V> underflow(TreeDeleteModification<K,V> shadowedModification,
        LeafNode<K,V> rightNode,
        NodeIO<K,V, BLinkNode<K,V>> io) throws IOException {
        checkRightNode(rightNode);
        
        if (this.highKey() == null) {
            throw new NullPointerException("this.highKey may not be null");
        }
        
        PeekingIterator<Map.Entry<K,V>> all = 
            Iterators.peekingIterator(Iterators.concat(this.keyValuePairs.entrySet().iterator(), 
                rightNode.keyValuePairs.entrySet().iterator()));
        final int half = (nKeys() + rightNode.nKeys()) >>> 1;
        
        PersistentTreeMap<K,V> newLeftKeyValuePairs =
            copyFrom(null, half, all, this.keyValuePairs.comparator());
        K newLeftHighKey = all.peek().getKey();
        
        PersistentTreeMap<K,V> newRightKeyValuePairs = 
            copyFrom(null, Integer.MAX_VALUE, all, this.keyValuePairs.comparator());
        
        LeafNode<K,V> newLeftLeaf = new LeafNode<K,V>(this.address(),
            this.lock, newLeftHighKey, this.rightLink(), newLeftKeyValuePairs);
        
        LeafNode<K,V> newRightLeaf = new LeafNode<K,V>(rightNode.address(),
            rightNode.lock, rightNode.highKey(), rightNode.rightLink(),
            newRightKeyValuePairs);
        
        io.writeNode(newLeftLeaf);
        
        io.writeNode(newRightLeaf);
        
//        return new HighKeyChange<K, V>(oldValue, newLeftHighKey,this.highKey(), newRightLeaf);
        return new NodeUnderflow<K, V>(shadowedModification.value(),
            shadowedModification.replacementHighKey(),
            this.highKey(), newLeftHighKey);
    }
    
    /**
     * 
     * @return A graphviz fragment that describes this node.
     */
    @Override
    void toDot(StringBuilder bldr) {
        bldr.append("\tnode").append(address()).append("[shape=record,style=\"rounded\",label=\"");
        if (nKeys() > 10) {
            //too many keys to display
            int lastIndex = nKeys() - 1;
            @SuppressWarnings("unchecked")
            K firstKey = (K) keyValuePairs.minKey();
            @SuppressWarnings("unchecked")
            K lastKey = (K) keyValuePairs.maxKey();
            bldr.append("<f0>").append(firstKey).append('|');
            bldr.append("<f1> ... ").append(lastIndex - 1).append(" ...|");
            bldr.append("<last>").append(lastKey).append("\"];\n");
        } else {
            int i=0;
            for (K key : keyValuePairs().keySet()) {
                String portName = (i != nKeys() - 1) ? "f" + (i++) : "last";
                bldr.append("<").append(portName).append(">").append(key);
                bldr.append('|');
            }
            bldr.setLength(bldr.length() - 1);
            bldr.append("\"];\n");
        }
        linksToDot(bldr);
    }
    
    static final class SimpleLeafDelete<K,V> extends TreeDeleteModification<K, V> {
        final LeafNode<K,V> newLeaf;
       
        public SimpleLeafDelete(V value, LeafNode<K,V> newLeaf) {
            super(DeleteModType.LEAF_DELETE_OK, value);
            
            this.newLeaf = newLeaf;
        }
    }
    
    static final class LeafNodeSplit<K,V> extends TreeInsertModification<K,V> {
        final LeafNode<K,V> newLeft;
        final LeafNode<K,V> newRight;
        
        private LeafNodeSplit(
            LeafNode<K, V> newLeft, 
            LeafNode<K, V> newRight) {
            super(InsertModType.LEAF_SPLIT);
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
    
}
