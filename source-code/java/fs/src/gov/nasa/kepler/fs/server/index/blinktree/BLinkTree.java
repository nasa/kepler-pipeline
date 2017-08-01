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
import gov.nasa.kepler.fs.server.index.NodeIO;
import gov.nasa.kepler.fs.server.index.blinktree.InternalNode.ChildNodeComparator;
import gov.nasa.kepler.fs.server.index.blinktree.LeafNode.LeafNodeSplit;
import gov.nasa.kepler.fs.server.index.blinktree.TreeDeleteModification.DeleteModType;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantLock;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantReadWriteLock;

import java.io.IOException;
import java.util.*;
import java.util.Map.Entry;
import java.util.concurrent.atomic.AtomicInteger;

import com.google.common.collect.Iterators;
import com.google.common.collect.PeekingIterator;
import com.trifork.clj_ds.PersistentTreeMap;

/**
 * This is a Blink-tree as defined by "Efficient Locking for Concurrent
 * Operations on B-Trees," by PHILIP L. LEHMAN and S. BING YAO. 
 *  Knuth in  For a general overview of B-tree algorithms see
 * _Introduction to Algorithms_, Thomas H. Cormen, Charles E. Leiserson, and
 * Ronald L. Rivest, 1996 and _Sorting and Searching: The Art of
 * Computer Programming vol 3_.by Knuth.  Blink-tree is pronounced as 
 * "B" "link" "tree" not as "blink" "tree".
 * 
 * Unlike some B-tree implementations this does not allow duplicate keys. null
 * is not a valid key. Internal nodes do not duplicate keys among themselves but
 * do share keys with the leaf nodes. 
 * 
 * Keys and values stored in this map should not be mutable. Changing the value
 * of a key returned by this map corrupt the tree. Changing the values of the
 * tree will not corrupt the tree, but changes to them may not be persisted or
 * may accidently be persisted. Changed values may only be partially written to
 * the tree.
 * 
 * The parameter <em>m</em> is used to control the branching factor of the tree
 * as in <em>m</em>-ary tree. This notation differs from Cormen, Leiserson and
 * Rivest which uses <em>t</em> to denote m/2.
 * 
 * @author Sean McCauliff
 * 
 */
public class BLinkTree<K, V> implements Iterable<Map.Entry<K, V>> {

    private final NodeIO<K, V, BLinkNode<K, V>> io;

    private final int leafM;
    private final int internalM;
    private final int leafHalfFull;
    private final int internalHalfFull;
    private final Comparator<K> byKey;
    private final ChildNodeComparator<K> byInternalNode;
    private final NodeLockFactory lockFactory;
    /**
     * A count which indicates to iterators that a leaf node has changed so it
     * can reread the node it is currently iterating from.
     */
    private final AtomicInteger leafNodeRevision  = new AtomicInteger();
    
    /**
     * This only gets locked when a delete needs to reorganize the tree.
     */
    private final DebugReentrantReadWriteLock bigDeleteLock = new DebugReentrantReadWriteLock(
        true);
    

    public BLinkTree(final NodeIO<K, V, BLinkNode<K, V>> io,
        final int leafM, final int internalM, final Comparator<K> byKey,
        final NodeLockFactory lockFactory) throws IOException {
        if (internalM < 2 || leafM < 2) {
            throw new IllegalArgumentException("Tree must be 2-ary or greater.");
        }

        this.leafM = leafM;
        this.leafHalfFull = leafM/2;
        this.internalM = internalM;
        this.internalHalfFull = internalM/2;
        this.byKey = byKey;
        this.io = io;
        this.lockFactory = lockFactory;

        this.byInternalNode = InternalNode.buildComparator(byKey);

        try {
            io.readNode(io.rootNodeAddress());
        } catch (NoSuchElementException nse) {
            @SuppressWarnings("unchecked")
            LeafNode<K,V> root = new LeafNode<K, V>(io.rootNodeAddress(),
                lockFactory.nodesLock(io.rootNodeAddress()), null,
                UNALLOCATED_ADDRESS,
                (PersistentTreeMap<K, V>) LeafNode.empty(byKey));
            io.writeNode(root);
            io.flushPendingModifications();
        }
    }

    private void assertTrue(String msg, boolean condition) {
        if (!condition) {
            throw new IllegalStateException(msg);
        }
    }
    
    /**
     * Checks a single node for consistency.
     * @param node
     * @param isRoot
     */
    private void assertCheck(BLinkNode<K,V> node, boolean isRoot) {
        String checkStr = node.check();
        assertTrue(checkStr, checkStr == null);
        checkStr = node.checkArity(node.isLeaf() ? leafM : internalM, isRoot);
        assertTrue(checkStr, checkStr == null);
    }
    
    public void checkInvariants() throws IOException, InterruptedException {
        bigDeleteLock.readLock().lockInterruptibly();
        try {
            BLinkNode<K,V> root = io.readNode(io.rootNodeAddress());
            checkInvariantsRec(root, true, 0);
        } finally {
            bigDeleteLock.readLock().unlock();
        }
    }
    
    /**
     * Call check on every node.
     * Check that min, max key relationships between nodes hold
     * Check that high keys are present in the tree.
     * This visits the tree in level major order.
     * 
     * @param startNode assume that check has already been called
     * @throws IOException 
     */
    
    private void checkInvariantsRec(final BLinkNode<K, V> startNode, 
        final boolean isRoot, final int nodesAtPrevLevel) throws IOException {
        
        int nodesAtLevel = 0;
        BLinkNode<K,V> prevNode = null;
        for (BLinkNode<K, V> node = startNode; ; ) {
            nodesAtLevel++;
            assertCheck(node, isRoot);

            if (prevNode != null) {
               

                //checking that the high keys exist in the internal nodes is
                //problematic
                if (node.isLeaf()) {
                    assertTrue("Other nodes at level must be leaf nodes.",
                               prevNode.isLeaf());
                    
                    assertTrue("High key from previous node is not equal to the min key of the next node.",
                               byKey.compare(prevNode.highKey(), node.minKey()) == 0);
                } else {
                    assertTrue("Other nodes at level must be internal nodes.", 
                               !prevNode.isLeaf());
                    assertTrue("High key from previous node is greater than min key of the next node.",
                               byKey.compare(prevNode.highKey(), node.minKey()) <= 0);
                }
            }
            
            prevNode = node;
            if (node.rightLink() != UNALLOCATED_ADDRESS) {
                node = io.readNode(node.rightLink());
            } else {
                assertTrue("Last node at level must have null high key.", node.highKey() == null);
                break;
            }
        }

        assertTrue("There are more nodes at the higher level ("+nodesAtPrevLevel + 
                   ")than at the lower level (" + nodesAtLevel + ")",
                   nodesAtLevel > nodesAtPrevLevel);
        
        if (startNode.isLeaf()) {
            return;
        }
        
        InternalNode<K, V> internalNode = (InternalNode<K,V>) startNode;
        BLinkNode<K, V> leftMostChild = io.readNode(internalNode.children().get(internalNode.minKey()));
        checkInvariantsRec(leftMostChild, false, nodesAtLevel);

    }

    /**
     * 
     * @param key a non-null key
     * @param value a non-null value
     * @return the old value stored with key or null if there was nothing
     * stored with that key
     * @throws InterruptedException
     * @throws IOException
     */
    public V insert(K key, V value) throws InterruptedException, IOException {
        bigDeleteLock.readLock().lockInterruptibly();
        try {
            return insertImpl(key, value, true);
        } finally {
            bigDeleteLock.readLock().unlock();
        }
    }
    
    /**
     * Atomically update the value stored at key returning the value that is
     * currently stored.
     * @param key non-null
     * @param value non-null
     * @return non-null
     * @throws InterruptedException
     * @throws IOException
     */
    public V insertIfAbsent(K key, V value) throws InterruptedException, IOException {
        bigDeleteLock.readLock().lockInterruptibly();
        try {
            V old = insertImpl(key, value, false);
            if (old == null) {
                return value;
            }
            return old;
        } finally {
            bigDeleteLock.readLock().unlock();
        }
    }
    
    private V insertImpl(final K key, final V value, final boolean updateOk) throws InterruptedException, IOException {
        
        if (key == null) {
            throw new NullPointerException("tree does not store null keys");
        }
        if (value == null) {
            throw new NullPointerException("tree does not store null values");

        }
        
        Deque<BLinkNode<K, V>> stack = new LinkedList<BLinkNode<K, V>>();
        BLinkNode<K,V> current = io.readNode(io.rootNodeAddress());
        while (!current.isLeaf()) {
            InternalNode<K,V> internalNode = (InternalNode<K,V>) current;
            while (internalNode.highKey() != null && byInternalNode.compare(key, internalNode.highKey()) >= 0) {
                internalNode = (InternalNode<K, V>) io.readNode(internalNode.rightLink());
                
            }

            BLinkNode<K, V> childNode = internalNode.childForKey(key, io);
            stack.push(internalNode);
            current = childNode;
        }
 
        current.lock();
        boolean currentLockHeld = true;

        TreeInsertModification<K, V> treeModification = null;
        try {
            current = io.readNode(current.address());
            if (!current.isLeaf()) {
                //root node converted to internal
                current.unlock();
                currentLockHeld = false;
                return insertImpl(key,value, updateOk);
            }
            current = rightMost(key, current);
            LeafNode<K, V> leaf = (LeafNode<K,V>) current;
            final V oldValue = leaf.keyValuePairs().get(key);
            if (oldValue != null) {
                if (updateOk) {
                    leaf = leaf.insertNonFull(key, value, io);
                }
                return oldValue;
            }
            
            if (leaf.nKeys() < leafM) {
                leaf.insertNonFull(key, value, io);
                return null;
            }
            
            if (leaf.address() == io.rootNodeAddress()) {
                convertRootToInternalNode(key, value, leaf);
                return null;
            }
            
            leafNodeRevision.incrementAndGet();
            leaf = leaf.insertFull(key, value);
            
            long newNodesAddress = io.allocateAddress();
            DebugReentrantLock newLock = lockFactory.nodesLock(newNodesAddress);
            newLock.lock();
            treeModification = leaf.split(newLock, newNodesAddress, io);
            
            while (treeModification != null) {
                if (stack.isEmpty()) {
                    if (current.address() == io.rootNodeAddress()) {
                        //we just split the root.
                        splitInternalRoot(treeModification);
                        return oldValue;
                    } else {
                        //tree grew while we where doing our thing.  refill stack
                        //This is why this function is not recursive.
                        refillStack(stack, treeModification);
                    }
                }
                current = stack.pop();
                current.lock();
                current = io.readNode(current.address());
                current = rightMost(treeModification.leftNode().highKey(), current);
                InternalNode<K,V> internalNode = (InternalNode<K,V>) current;
                if (internalNode.nKeys() < internalM) {
                    internalNode.insertNonFull(treeModification, io);
                    break;
                }
                internalNode = internalNode.insertFull(treeModification);
                
                long newNodeAddress = io.allocateAddress();
                DebugReentrantLock newNodeLock = lockFactory.nodesLock(newNodeAddress);
                newNodeLock.lock();
                TreeInsertModification<K,V> oldModification = treeModification;
                treeModification = internalNode.split(io, newNodeAddress, newNodeLock);
                oldModification.leftNode().unlock();
                oldModification.rightNode().unlock();
            }
        } finally {
            if (currentLockHeld) {
                current.unlock();
            }
            if (treeModification != null) {
                if (treeModification.leftNode().address() != current.address()) {
                    treeModification.leftNode().unlock();
                }
                treeModification.rightNode().unlock();
            }
        }
        return null;
    }

    /**
     * Iteratively follows right link pointers, locking nodes along the way,
     *  until it finds a high key that is either null or less than the
     *  specified key.
     * 
     * @param <N>
     * @param key
     * @param node a locked starting node
     * @return a locked node, which may be a starting node
     * @throws IOException
     */
    @SuppressWarnings("unchecked")
    private <N extends BLinkNode<K, V>> N rightMost(K key, N node) throws IOException {
        while (node.highKey() != null && byKey.compare(key, node.highKey()) >= 0) {
            N oldNode = node;
            DebugReentrantLock rightLock = lockFactory.nodesLock(node.rightLink());
            rightLock.lock();
            node =  (N) io.readNode(node.rightLink());
            oldNode.unlock();
        }
        return node;
    }
    
    
    /**
     * What's happened.  Some other threads have grown the tree while we where
     * away and we just split the last node on our stack and it's not the root.
     * This tracks back down from the current root to the left most node in
     * the modification and refills the stack as it does this.  Now it has found
     * the new insertion point.
     * 
     * @param stack
     * @param treeModification
     */
    private void refillStack(Deque<BLinkNode<K, V>> stack, TreeInsertModification<K, V> treeModification) throws IOException {
        
        //If the root node is not an internal node then we have real problems.
        InternalNode<K, V> current = (InternalNode<K, V>) io.readNode(io.rootNodeAddress());
        
        while (true) {
            while (current.highKey() != null && 
                   byInternalNode.compare(treeModification.leftNode().highKey(), current.highKey()) <= 0 &&
                   current.address() == treeModification.leftNode().address()) {
                current = (InternalNode<K, V>) io.readNode(current.address());
            }
            
            if (current.address() == treeModification.leftNode().address()) {
                return;
            }
            
            stack.push(current);
            
            Iterator<Map.Entry<Object,Long>> childIt = 
                current.children().iteratorFrom(treeModification.leftNode().highKey());
            Map.Entry<Object,Long> child = childIt.next();
            BLinkNode<K, V> childNode = io.readNode(child.getValue());
            if (childNode.isLeaf()) {
                return;
            }
            current = (InternalNode<K,V>) childNode;
        }
    }
    
    /**
     * The root was split, now grow the tree upwards.
     * @throws IOException
     */
    private void splitInternalRoot(TreeInsertModification<K, V> modification) throws IOException {

        PersistentTreeMap<Object,Long> newRootChildren = 
            PersistentTreeMap.create(this.byInternalNode, PersistentTreeMap.EMPTY.seq());
        newRootChildren = newRootChildren.assoc(modification.leftNode().highKey(), modification.leftNode().address());
        newRootChildren = newRootChildren.assoc(GREATER_THAN_EVERYTHING, modification.rightNode().address());
        final long newRootAddress = io.allocateAddress();
        DebugReentrantLock newRootLock = lockFactory.nodesLock(newRootAddress);
        InternalNode<K,V> newRoot = 
            new InternalNode<K,V>(newRootAddress, newRootLock, 
                UNALLOCATED_ADDRESS, null, newRootChildren);
        io.writeNode(newRoot);
        io.setRootNodeAddress(newRootAddress);
    }
    
    /**
     * This gets called when the tree is just a single root node and it
     * overflows. This assumes the calling thread is the lock holder on the.
     * this.root has an updated reference after this is called.
     * 
     * @throws IOException
     */
    private void convertRootToInternalNode(K key, V value, LeafNode<K,V> root) throws IOException {
        final long newLeafAddress = io.allocateAddress();
        
        root = root.insertFull(key, value);
        
        DebugReentrantLock newLeafLock = lockFactory.nodesLock(newLeafAddress);
        newLeafLock.lock();
        try {
        
            LeafNodeSplit<K, V> splitResult = root.split(newLeafLock, newLeafAddress, io);
            PersistentTreeMap<Object,Long> rootChildren = 
                PersistentTreeMap.create(byInternalNode, PersistentTreeMap.EMPTY.seq());
            rootChildren = rootChildren.assoc(splitResult.newLeft.highKey(), root.address());
            rootChildren = rootChildren.assoc(GREATER_THAN_EVERYTHING, newLeafAddress);
            
            final long newRootAddress = io.allocateAddress();
            DebugReentrantLock newRootLock = lockFactory.nodesLock(newRootAddress);
            InternalNode<K,V> rootIsInternalNode = 
                new InternalNode<K, V>(newRootAddress,
                    newRootLock, UNALLOCATED_ADDRESS, null, rootChildren);
            io.writeNode(rootIsInternalNode);
            io.setRootNodeAddress(newRootAddress);
        } finally {
            newLeafLock.unlock();
        }
    }

    /**
     * Removes the (key,value) pair associated with the specified key.
     * 
     * @param key a non-null key.
     * @return The previous value stored with key or null if no value was
     * stored.
     * @throws IOException
     * @throws InterruptedException
     */
    public V delete(K key) throws IOException, InterruptedException {

        bigDeleteLock.readLock().lockInterruptibly();
        try {
            TreeDeleteModification<K, V> treeModification = 
                safeDeleteRec(key,io.readNode(io.rootNodeAddress()));
            if (treeModification.replacementHighKey() != null) {
                throw new IllegalStateException("Deletion of high key outside of writeLock().");
            }
            switch (treeModification.type()) {
                case KEY_NOT_PRESENT:
                    return null;
                case LEAF_DELETE_OK:
                    return treeModification.value();
                case NOT_SAFE:
                    //fall through
                    break;
                default:
                    throw new IllegalStateException("Complex delete performed" +
                            " outside of big delete lock. Tree might be corrupted." +
                            treeModification.type());
            }
        } finally {
            bigDeleteLock.readLock().unlock();
        }

        bigDeleteLock.writeLock().lockInterruptibly();
        try {
            TreeDeleteModification<K, V> treeModification = 
                unsafeDeleteRec(key, io.readNode(io.rootNodeAddress()), null);
            switch (treeModification.type()) {
                case KEY_NOT_PRESENT:
                    return null;
                default:
                    return treeModification.value();
            }
        } finally {
            bigDeleteLock.writeLock().unlock();
        }
    }
    
    /**
     * This is used to try and delete from the tree if the tree concurrently
     * if a key can be removed from a leaf node without other structural
     * modifications to the tree.
     * 
     * @param key key to delete.
     * @param node the node or parent node to delete the key from
     * @return The change state which might be a request to lock the entire
     * tree so structural changes can be made.  In which case don't call this
     * method again.
     * @throws IOException
     * @throws InterruptedException
     */
    private TreeDeleteModification<K, V> safeDeleteRec(K key, BLinkNode<K,V> node) 
     throws IOException, InterruptedException {
        
        if (node.isLeaf()) {
            LeafNode<K, V> leafNode = (LeafNode<K,V>) node;
            try {
                leafNode.lock();
                leafNode = (LeafNode<K, V>) io.readNode(leafNode.address());
                leafNode = rightMost(key, leafNode);
                if (!leafNode.keyValuePairs().containsKey(key)) {
                    return new TreeDeleteModification<K, V>(DeleteModType.KEY_NOT_PRESENT, null);
                }
                
                if (leafNode.nKeys() <= leafHalfFull) {
                    return new TreeDeleteModification<K, V>(DeleteModType.NOT_SAFE, null);
                }
                if (byKey.compare(key, leafNode.minKey()) == 0) {
                    //This is someone's high key
                    return new TreeDeleteModification<K, V>(DeleteModType.NOT_SAFE, null);
                }
                this.leafNodeRevision.getAndIncrement();
                return leafNode.deleteKey(key, io);
            } finally {
                leafNode.unlock();
            }
        }
        
        InternalNode<K,V> internalNode = (InternalNode<K,V>) node;
        while (internalNode.highKey() != null &&
            byInternalNode.compare(key,internalNode.highKey()) >= 0) {
            internalNode = (InternalNode<K, V>) io.readNode(internalNode.rightLink());
        }
        
        
        return safeDeleteRec(key, internalNode.childForKey(key, io));
    }
    
    /**
     * Delete a key from the tree when we think it is unsafe to do so.  That is
     * readers and inserters need to be locked out of the tree while
     * modifications are being made.
     * 
     * @param key the key to delete from the tree
     * @param haveBigDeleteLock
     * @param node
     * @param parentNode this may be null if node is the root.
     * @return
     * @throws IOException
     * @throws InterruptedException
     */
    private TreeDeleteModification<K, V> unsafeDeleteRec(K key,
        BLinkNode<K,V> node, 
        InternalNode<K,V> parentNode) 
        throws IOException, InterruptedException {
       
        assert bigDeleteLock.writeLock().isHeldByCurrentThread();
        
        if (node.isLeaf()) {
            LeafNode<K,V> leafNode = (LeafNode<K,V>) node;
            if (!leafNode.keyValuePairs().containsKey(key)) {
                return new TreeDeleteModification<K, V>(DeleteModType.KEY_NOT_PRESENT, null);
            }

            final LeafNode<K,V> originalLeaf = leafNode;
            TreeDeleteModification<K, V> deleteMod = leafNode.deleteKey(key, io);
            leafNode = (LeafNode<K, V>) io.readNode(leafNode.address());
            this.leafNodeRevision.getAndIncrement();
            
            if (parentNode == null) { //root
                return deleteMod;
            }
            
           
            if (leafNode.nKeys() >= leafHalfFull) {
                return deleteMod;
            }
            
            //Check if underflow can be resolved by taking keys from
            //sibling nodes else merge the nodes.
            LeafNode<K,V> rightSibling = findRightSibling(parentNode, originalLeaf);
            LeafNode<K,V> leftSibling = leafNode;
            if (rightSibling == null) {
                rightSibling = leafNode;
                leftSibling = findLeftSibling(parentNode, originalLeaf);
                if (leftSibling == null) {
                    throw new IllegalStateException("This node can't be both the the left most and right most node unless it is the root and we already checked for that.");
                }
                //Don't propagate the high key change since it is irrelevant for
                //the right most node and screws everything up.
                deleteMod = new TreeDeleteModification<K,V>(DeleteModType.LEAF_DELETE_OK, deleteMod.value());
            }
            
            if (leftSibling.nKeys() + rightSibling.nKeys() >= leafM) {
                return leftSibling.underflow(deleteMod, rightSibling, io);
            }
            return leftSibling.merge(deleteMod, rightSibling, io);
        }
        
        InternalNode<K,V> internalNode = (InternalNode<K,V>) node;
        final InternalNode<K,V> originalInternalNode = internalNode;
        BLinkNode<K, V> child = internalNode.childForKey(key, io);
        TreeDeleteModification<K, V> childModification = 
            unsafeDeleteRec(key, child, internalNode);
        
        boolean needToReplaceHighKey  = 
            childModification.replacementHighKey() != null &&
                internalNode.children().containsKey(key);
        
        if (needToReplaceHighKey) {
            BLinkNode<K,V> replaceHighKeyChild = io.readNode(internalNode.children().get(key));
            replaceHighKey(key, childModification.replacementHighKey(),
                replaceHighKeyChild);
        }
      
      
        if (childModification.type() == DeleteModType.UNDERFLOW ||
            needToReplaceHighKey) {
            internalNode = internalNode.changeAnchorKey(childModification, key, io);
        }
        
        switch (childModification.type()) {
            case LEAF_DELETE_OK:
            case KEY_NOT_PRESENT:
                return childModification;
            case UNDERFLOW:
                return new TreeDeleteModification<K,V>(DeleteModType.LEAF_DELETE_OK, childModification.value(), childModification.replacementHighKey());
            case MERGE:
                NodeMerge<K, V> nodeMerge = (NodeMerge<K, V>) childModification;
                internalNode = internalNode.applyMerge(nodeMerge, io);
                if (parentNode == null) {
                    //at root
                    if (internalNode.nChildren() == 1) {
                        //shrink tree.
                        shrinkTree(internalNode);
                    }
                    return nodeMerge;
                }
                
                if (internalNode.nKeys() >= internalHalfFull) {
                        return new TreeDeleteModification<K,V>(DeleteModType.LEAF_DELETE_OK,
                            nodeMerge.value(), nodeMerge.replacementHighKey());
                }
                
                if (internalNode.rightLink() != UNALLOCATED_ADDRESS) {
                    InternalNode<K,V> rightNode = 
                        (InternalNode<K, V>) io.readNode(internalNode.rightLink());
                    if (rightNode.nKeys() > internalHalfFull) {
                        return internalNode.underflow(nodeMerge, rightNode, io);
                    }
                    return internalNode.merge(nodeMerge,rightNode, io);
                }
                InternalNode<K,V> leftNode = findLeftSibling(parentNode, originalInternalNode);
                if (leftNode == null) {

                    throw new IllegalStateException("Failed to find left node for right most node.  Context: \n" +
                                                     " internalNode.minKey() " + internalNode.minKey() +
                                                     "\n parentNode.children() " + parentNode.children());
                }
                if (leftNode.nKeys() > internalHalfFull) {
                    return leftNode.underflow(nodeMerge,internalNode, io);
                }
                return leftNode.merge(nodeMerge,internalNode, io);
                 
                
            default:
                throw new IllegalStateException("Unhandled state change " +
                    childModification.type());
                
        }
    }

    /**
     * When the internal node containing the high key needing replacement has
     * been reached this gets called to cascade back down the tree and replace
     * the high key in child nodes.
     * @throws IOException 
     */
    private void replaceHighKey(K key, K replacementHighKey,
        BLinkNode<K, V> replaceHighKeyChild) throws IOException {

        if(replaceHighKeyChild.isLeaf()) {
            LeafNode<K,V> leafNode = (LeafNode<K,V>) replaceHighKeyChild;
            if (leafNode.highKey() == null || 
                byKey.compare(leafNode.highKey(), key) != 0) {
               // throw new IllegalStateException("high key not found \"" + key + "\"");
                //may have deleted node with high key
                return;
            }
            leafNode = new LeafNode<K,V>(leafNode.address(), leafNode.lock,replacementHighKey,
                leafNode.rightLink(), leafNode.keyValuePairs());
            io.writeNode(leafNode);
        } else {
            InternalNode<K,V> internalNode = (InternalNode<K,V>) replaceHighKeyChild;
            if (internalNode.highKey() != null && 
                byInternalNode.compare(internalNode.highKey(), key) == 0) {
               
                internalNode = new InternalNode<K,V>(internalNode.address(),
                    internalNode.lock, internalNode.rightLink(), 
                    replacementHighKey, internalNode.children());
                
                io.writeNode(internalNode);
            }
            
            long rightMostChildAddress = 
                internalNode.children().get(GREATER_THAN_EVERYTHING);
            BLinkNode<K,V> rightMostChild = io.readNode(rightMostChildAddress);
            replaceHighKey(key, replacementHighKey, rightMostChild);
        }
        
    }

    private void shrinkTree(InternalNode<K,V> root) throws IOException {
        if (root.children().size() != 1) {
            throw new IllegalStateException("Root must have one child in order to shrink.");
        }
        assert bigDeleteLock.isWriteLockedByCurrentThread();
        
        Long onlyChildAddress = root.children().values().iterator().next();
        io.deleteNode(root);
        io.setRootNodeAddress(onlyChildAddress);
    }
    
    /**
     * 
     * @param <T>
     * @param parentNode
     * @param right must not be the root node.
     * @return
     * @throws IOException
     */
    private <T extends BLinkNode<K,V>> T findLeftSibling(final InternalNode<K,V> parentNode, final T right) throws IOException {
        assert bigDeleteLock.writeLock().isHeldByCurrentThread();
        
        if (parentNode == null) {
            throw new IllegalArgumentException("Can't find left sibling on root node.");
        }
        
        //TODO: likely there is a better way to do this rather than iterating
        //through all the children, but I don't know what that better way
        //might be
        K minKey = right.minKey();
        Iterator<Entry<Object,Long>> parentIt = 
            parentNode.children().entrySet().iterator();
        
        Entry<Object,Long> child = null;
        Entry<Object, Long> prevChild = null;
        while (parentIt.hasNext()) {
            child = parentIt.next();
            if (byInternalNode.compare(child.getKey(), minKey) >= 0) {
                break;
            }
            prevChild = child;
        }
        
        
        if (child.getKey().equals(GREATER_THAN_EVERYTHING) && !right.isLeaf()) {
            //Internal nodes' don't share keys so min key would never be
            //equal to the internal node's previous key
            child = prevChild;
        }
        
        if (child.getValue() == right.address()) {
            throw new IllegalStateException("Node does not have left sibling.");
        }
        
        @SuppressWarnings("unchecked")
        T rv = (T) io.readNode(child.getValue());
        return rv;
    }
    
    /**
     * This won't find the right sibling if it's parent is different.
     * @param <T>
     * @param parentNode
     * @param right
     * @return
     * @throws IOException
     */
    private <T extends BLinkNode<K,V>> T findRightSibling(final InternalNode<K,V> parentNode, final T left) throws IOException {
        if (parentNode == null) {
            return null;
        }
        
        if (left.rightLink() == UNALLOCATED_ADDRESS) {
            return null;
        }
        
        Iterator<Entry<Object, Long>> parentIt = 
            parentNode.children().iteratorFrom(left.highKey());
        Entry<Object, Long> childEntry = parentIt.next();
        if (childEntry.getKey() == GREATER_THAN_EVERYTHING) {
            return null;
        }
        
        @SuppressWarnings("unchecked")
        T rv = (T) io.readNode(left.rightLink());
        return rv;
        
    }
    
    /**
     * Gains exclusive access to this tree.  This is useful for synchronizing
     * with I/O operations.
     * 
     * @throws InterruptedException
     */
    
    public void lock() throws InterruptedException {
        bigDeleteLock.writeLock().lockInterruptibly();
    }
   
    public void unLock() {
        bigDeleteLock.writeLock().unlock();
    }
    
    
    public String toDot() throws InterruptedException, IOException {
        return toDot("BLinkTree");
    }
    
    /**
     * Dumps the current tree structure into the Graphviz directed graph format.
     * See http://graphviz.org. Unlike find() and insert().
     * @return
     * @throws InterruptedException
     * @throws IOException
     */
    public String toDot(String graphName) throws InterruptedException, IOException {
        bigDeleteLock.readLock().lockInterruptibly();
        try {
            StringBuilder bldr = new StringBuilder();
            bldr.append("digraph " + graphName + " {\n");
            toDotRec(bldr, io.readNode(io.rootNodeAddress()));
            bldr.append("}\n");
            return bldr.toString();
        } finally {
            bigDeleteLock.readLock().unlock();
        }
    }

    /**
     * Visits nodes in level order.
     * 
     * @param bldr
     * @param node
     * @throws InterruptedException
     * @throws IOException
     */
    private void toDotRec(final StringBuilder bldr, final BLinkNode<K, V> startNode)
        throws InterruptedException, IOException {
        BLinkNode<K, V> node = startNode;
        node.toDot(bldr);
        while (node.rightLink() != UNALLOCATED_ADDRESS) {
            node = io.readNode(node.rightLink());
            node.toDot(bldr);
        }
        
        //The following code does not seem to render correctly in graphviz.
//        bldr.append("    { rank = same; ");
//        node = startNode;
//        bldr.append("\"node").append(node.address()).append("\"; ");
//        while (node.rightLink() != UNALLOCATED_ADDRESS) {
//            node = io.readNode(node.rightLink());
//            bldr.append("\"node").append(node.address()).append("\"; ");
//        }
//        bldr.append("}\n");
        if (startNode.isLeaf()) {
            return;
        }
        InternalNode<K, V> internalNode = (InternalNode<K, V>) startNode;
        PersistentTreeMap<Object, Long> children = internalNode.children();
        BLinkNode<K, V> childNode = io.readNode(children.get(children.minKey()));
        toDotRec(bldr, childNode);
    }

    /**
     * 
     * @param key
     * @return null if there is not a value paired with the specified key. Else
     * returns the value associated with that key.
     * @throws InterruptedException 
     */
    public V find(K key) throws IOException, InterruptedException {
        bigDeleteLock.readLock().lockInterruptibly();
        try {
            return findRec(key, io.readNode(io.rootNodeAddress()));
        } finally {
            bigDeleteLock.readLock().unlock();
        }
    }

    private V findRec(K key, BLinkNode<K, V> visitingNode)
        throws IOException {
        if (visitingNode.isLeaf()) {
            LeafNode<K, V> leaf = (LeafNode<K, V>) visitingNode;
            V value = leaf.get(key);
            if (value != null) {
                return value;
            }
            if (leaf.highKey() != null
                && byKey.compare(key, leaf.highKey()) >= 0) {
                long rightNodeAddress = leaf.rightLink();
                if (rightNodeAddress == UNALLOCATED_ADDRESS) {
                    return null;
                }
                LeafNode<K, V> rightNode = (LeafNode<K, V>) io.readNode(rightNodeAddress);
                return findRec(key, rightNode);
            }
            return null;
        }
        
        InternalNode<K, V> internal = (InternalNode<K, V>) visitingNode;
        
        if (internal.highKey() != null) {
            if (byInternalNode.compare(key, internal.highKey()) >= 0) {
                if (internal.rightLink() != UNALLOCATED_ADDRESS) {
                    InternalNode<K, V> rightNode = (InternalNode<K, V>) io.readNode(internal.rightLink());
                    return findRec(key, rightNode);
                }
            }
        }

        BLinkNode<K, V> child = internal.childForKey(key, io);
        return findRec(key, child);
    }

    /**
     * The iterator returned is itself not MT-safe, but having more than one
     * iterator is MT-safe.  next() and hasNext() will never throw
     * ConcurrentModificationException, but may not return predictable results
     * if the tree is modified during iteration.
     */
    @Override
    public Iterator<Map.Entry<K, V>> iterator() {
        try {
            return new BLinkTreeIterator();
        } catch (Exception e) {
            throw new IllegalStateException(e);
        }
    }
    
    private final class BLinkTreeIterator implements Iterator<Map.Entry<K, V>> {

        private volatile LeafNode<K, V> currentNode;
        private volatile int myRevision;
        private volatile PeekingIterator<Map.Entry<K, V>> keyValuesIterator;
        
        private BLinkTreeIterator() throws IOException, InterruptedException {
            bigDeleteLock.readLock().lockInterruptibly();
            try {
                BLinkNode<K,V> node = io.readNode(io.rootNodeAddress());
                while (!node.isLeaf()) {
                    InternalNode<K, V> internalNode = (InternalNode<K, V>) node;
                    PersistentTreeMap<Object,Long> children = internalNode.children();
                    long leftMostAddress = children.get(children.minKey());
                    node = io.readNode(leftMostAddress);
                }
                if (node.nKeys() > 0) {
                    currentNode = (LeafNode<K,V>) node;
                    keyValuesIterator = 
                        Iterators.peekingIterator(currentNode.keyValuePairs().entrySet().iterator());
                }
            } finally {
                bigDeleteLock.readLock().unlock();
            }
        }
        
        
        @Override
        public boolean hasNext() {
            return currentNode != null;
        }

        @Override
        public Entry<K, V> next() {
            if (currentNode == null) {
                throw new NoSuchElementException();
            }
            try {
                return nextImpl();
            } catch (Exception e) {
                throw new IllegalStateException(e);
            }
        }
            
        private Entry<K,V> nextImpl() throws IOException, InterruptedException {
            bigDeleteLock.readLock().lockInterruptibly();
            try {
                Entry<K, V> nextEntry = this.keyValuesIterator.next();
                
                //Tree changed, attempt to provide a more uptodate view.
                if (myRevision != leafNodeRevision.get()) {
                    myRevision = leafNodeRevision.get();
                    BLinkNode<K,V> node;
                    try {
                        node  = io.readNode(currentNode.address());
                    } catch (NoSuchElementException nsee) {
                        currentNode = null;
                        keyValuesIterator = null;
                        return nextEntry;
                    }
                    
                    if (!node.isLeaf()) {
                        //Node address has been deleted and reused
                        currentNode = null;
                        keyValuesIterator = null;
                        return nextEntry;
                    }
                    
                    currentNode = (LeafNode<K,V>) node;
                    while (currentNode.highKey() != null && 
                        byKey.compare(nextEntry.getKey(), currentNode.highKey()) >= 0) {
                     currentNode = (LeafNode<K, V>) io.readNode(currentNode.rightLink());
                    }
                    updateIterator(nextEntry);
                }
                
                //Advance to the next entry
                while (!keyValuesIterator.hasNext()) {
                    BLinkNode<K, V> node;
                    if (currentNode.rightLink() == UNALLOCATED_ADDRESS) {
                        noNextNode();
                        return nextEntry;
                    }
                    try { 
                        node = io.readNode(currentNode.rightLink());
                    } catch (NoSuchElementException nse) {
                        noNextNode();
                        return nextEntry;
                    }
                    
                    if (!node.isLeaf()) {
                        //Node address has been deleted and reused
                        noNextNode();
                        return nextEntry;
                    }
                    
                    currentNode = (LeafNode<K, V>) node;
                    
                    while (currentNode.highKey() != null && 
                        byKey.compare(nextEntry.getKey(), currentNode.highKey()) >= 0) {
                     currentNode = (LeafNode<K, V>) io.readNode(currentNode.rightLink());
                    }
                    
                    updateIterator(nextEntry);
                    
                }
                
                return nextEntry;
                
            } finally {
                bigDeleteLock.readLock().unlock();
            }
        }
        
        private void noNextNode() {
            currentNode = null;
            keyValuesIterator = null;
        }


        private void updateIterator(Entry<K, V> nextEntry) {
            keyValuesIterator = 
                Iterators.peekingIterator(currentNode.keyValuePairs().iteratorFrom(nextEntry.getKey()));
            if (keyValuesIterator.hasNext() &&
                keyValuesIterator.peek().getKey().equals(nextEntry.getKey())) {
                keyValuesIterator.next();
            }
        }

        /**
         * This method is not supported.
         */
        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
        
    }

}
