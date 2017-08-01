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

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.Comparator;
import java.util.Iterator;
import java.util.Map;

import com.trifork.clj_ds.PersistentTreeMap;

import gov.nasa.kepler.fs.server.index.*;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantLock;


/**
 * Common stuff for B-link tree nodes. b-link nodes have an extra "max" key
 * after the last pointer which is the greater than the maximum key in the
 * greatest child or in the case of leaf nodes.  This class and its descendants
 * should be MT-safe and immutable (with the exception of the lock).  The lock
 * is used by writers which can't corrupt and individual node, but could corrupt
 * the tree structure without locking.
 * 
 * @author Sean McCauliff
 * @param <K> key type
 * @param <V> value type
 *
 */
public abstract class BLinkNode<K,V> implements TreeNode<K,V> {

    final static byte LEAF_MAGIC = 42;
    final static byte INTERNAL_MAGIC = 55;
    
    final static long UNALLOCATED_ADDRESS = -1;
    
    public static <K,V> TreeNodeFactory<K, V, BLinkNode<K,V>> nodeFactory(NodeLockFactory lockFactory, Comparator<K> byKey) {
        return new BLinkNodeFactory<K, V>(lockFactory, byKey);
    }
    
    protected static final int FILE_PTR_SIZE = 8;
    
    private final long address;
    private final long rightLink;
    
    protected final DebugReentrantLock lock;
    
    /**
     * The high key is higher than every real key (not the GREATER_THAN_EVERYTHING key)
     * in this node.  This is actually a copy of the next key stored in the
     * parent internal node.  The high key may be null if this is the root node
     * or this is the last node on a level.
     */
    private final K highKey;
 
    
    /**
     * 
     * @param address
     * @param lock
     * @param highKey this may be be null
     * @param rightLink
     */
    BLinkNode(long address, DebugReentrantLock lock, K highKey,
        long rightLink) {
        if (lock == null) {
            throw new NullPointerException("lock may not be null");
        }
        if (address < 0) {
            throw new IllegalArgumentException("Adddress must be non-negative.  " + address);
        }
        this.address = address;
        this.lock = lock;
        this.rightLink = rightLink;
        this.highKey = highKey;
        if (rightLink == UNALLOCATED_ADDRESS ^ highKey == null) {
            throw new IllegalStateException("high key \"" + highKey + "\" must be null iff " +
                    "rightLink \"" + rightLink + "\" is UNALLOCATED_ADDRESS");
        }
    }
    

    void lock() throws InterruptedException {
        lock.lockInterruptibly();
    }
    void unlock() {
        lock.unlock();
    }
    
    
    /**
     * This is used to implement the link in the B-link tree.
     * 
     * @return If there are no more nodes at this level then this returns 
     * UNALLOCATED_ADDRESS else this returns the address of the node on the
     * same level who's minimum key is greater than the maximum key of this node.
     */
    long rightLink() {
        return rightLink;
    }
    
    @Override
    public long address() {
        return address;
    }
    
    final protected void checkRightNode(BLinkNode<K, V> rightNode) {
        if (rightLink() != rightNode.address()) {
            throw new IllegalStateException("rightNode " + rightNode + 
                " is not the correct right node of this node " + this);
        }
        
    }
    
    protected void linksToDot(StringBuilder bldr) {
        if (rightLink() != UNALLOCATED_ADDRESS) {
            bldr.append("\t  \"node").append(address()).append("\":last").append("->node").append(rightLink())
            .append(":f0[style=\"dashed\",label=\"rightLink[" + highKey() + "]\"]\n");
        }
    }
    
    
    protected static <K,V> PersistentTreeMap<K,V> copyFrom(
        PersistentTreeMap<K,V> rv, 
        int nItems, Iterator<Map.Entry<K, V>> it, Comparator<K> comp) {
        if (rv == null) {
            rv = (PersistentTreeMap<K, V>) PersistentTreeMap.create(comp, PersistentTreeMap.EMPTY.seq());
        }
        for (int i=0; i < nItems && it.hasNext(); i++) {
            Map.Entry<K, V> entry = it.next();
            rv = rv.assoc(entry.getKey(), entry.getValue());
        }
        return rv;
    }
    
    /**
     * Generate a description of this node and it's out going connections in
     * graphviz directed graph format.  This is just a fragment and not an
     * entire digraph structure.
     */
    abstract void toDot(StringBuilder bldr);
    
    /**
     * 
     * @return The minimum key stored in this node.
     */
    abstract K minKey();
    
    /**The the arity of the node to make sure it complies with m.
     * @param m The m-aryness of the node.
     * @param isRoot if this is the root node
     * @return null else a string describing the problem
     */
    String checkArity(int m, boolean isRoot) {
        if (nKeys() > m ) {
            return this + " is in overflow state with key count" + nKeys();
        }
        if (!isRoot && nKeys() < m/2) {
            return this + " is in underflow state with key count" + nKeys();
        }
        return null;
    }
    
    /**
     * * Checks the validity of the node.  This check may be very expensive.
     * @return null else a string describing the problem
     */
    abstract String check();
    
    /**
     * Return the high key which is greater than any key stored in this node.
     * @return
     */
    final K highKey() {
        return highKey;
    }
    
    protected void writeRightLink(KeyValueIO<K, V> kvio, DataOutput dout) throws IOException {
        if (highKey() != null) {
            dout.writeBoolean(true);
            kvio.writeKey(dout, highKey());
        } else {
            dout.writeBoolean(false);
        }
        dout.writeLong(rightLink());
    }
    
    private static final class BLinkNodeFactory<K,V> implements TreeNodeFactory<K, V, BLinkNode<K,V>> {
        
        private final NodeLockFactory lockFactory;
        private final Comparator<K> byKey;
        private final Comparator<Object> byInternalNode;
        
        BLinkNodeFactory(NodeLockFactory lockFactory, Comparator<K> byKey) {
            this.lockFactory = lockFactory;
            this.byKey = byKey;
            this.byInternalNode = InternalNode.buildComparator(byKey);
        }
        
        @Override
        public BLinkNode<K,V> read(long address, DataInput din, NodeIO<K, V, BLinkNode<K,V>> io)
            throws IOException {

            DebugReentrantLock lock = lockFactory.nodesLock(address);
            final byte nodeType = din.readByte();
            final boolean hasHighKey = din.readBoolean();
            final KeyValueIO<K, V> kvio = io.keyValueIO();
            final K highKey = (hasHighKey) ? kvio.readKey(din) : null;

            final long rightLink = din.readLong();
            final int nItems = din.readShort();
            if (nItems < 0) {
                throw new IllegalStateException ("Bad node.  Too few items to read in." + nItems);
            }
            switch (nodeType) {
                case INTERNAL_MAGIC:
                    //TODO:  There might be a more efficient way to do this
                    //since what we are reading in is already sorted.
                    PersistentTreeMap<Object, Long> children = 
                        LeafNode.empty(byInternalNode);
                    for (int i=0; i < (nItems -1); i++) {
                        Object key = kvio.readKey(din);
                        long childPtr = din.readLong();
                        children = children.assoc(key, childPtr);
                    }
                    children = children.assoc(InternalNode.GREATER_THAN_EVERYTHING, din.readLong());
                    return new InternalNode<K, V>(address, lock, rightLink,
                        highKey, children);
                case LEAF_MAGIC:
                    PersistentTreeMap<K,V> keyValuePairs = LeafNode.empty(byKey);
                    for (int i=0; i < nItems; i++) {
                        K key = kvio.readKey(din);
                        V value = kvio.readValue(din);
                        keyValuePairs = keyValuePairs.assoc(key, value);
                    }
                    return new LeafNode<K,V>(address, lock , highKey, rightLink, keyValuePairs);
                default:
                    throw new IllegalStateException("Bad b-link node magic " + nodeType);
            }
        }
        
        
    }
}
