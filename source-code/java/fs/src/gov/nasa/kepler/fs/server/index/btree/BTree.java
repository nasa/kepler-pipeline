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

import gov.nasa.kepler.fs.server.index.NodeIO;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantReadWriteLock;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;


/**
 *  This btree implementation does not allow duplicate keys.  See
 *  _Introduction to Algorithms_, Thomas H. Cormen, Charles E. Leiserson, 
 *  and Ronald L. Rivest, 1996.
 *  
 *  @author Sean McCauliff
 *
 */

public class BTree<K,V> implements Iterable<Pair<K,V>>{


    private final NodeIO<K,V,BtreeNode<K,V>> io;
    private BtreeNode<K,V> root;
    private final int t;
    private final Comparator<K> comp;
    private final DebugReentrantReadWriteLock rwLock = 
        new DebugReentrantReadWriteLock();
    private int modificationCount = 0;

    public BTree(NodeIO<K,V, BtreeNode<K,V>> io, int t, Comparator<K> comp) throws IOException {
        this.io = io;
        this.t = t;
        this.comp = comp;

        try {
            root = io.readNode(io.rootNodeAddress());
        } catch (NoSuchElementException nsee) {
            root = new BtreeNode<K,V>(io.rootNodeAddress(), io);
            io.writeNode(root);
            io.flushPendingModifications();
        }
    }

    private void insertNonFull(BtreeNode<K,V> x, K key, V value) throws IOException {
        if (x.isLeaf()) {         
            x.add(key, value, comp);
            io.writeNode(x);
        } else {
            int index = Collections.binarySearch(x.keys, key, comp);
            if (index >= 0) {
                //existing key, so update value
                if (!x.values.get(index).equals(value)) {
                    x.add(key, value, comp);
                    io.writeNode(x);
                }
            } else {
                index = (-index) - 1;

                BtreeNode<K,V> childNode = x.child(index);
                if (childNode.nKeys() == (2*t-1)) {
                    childNode.split(t, x, index);
                    index = Collections.binarySearch(x.keys, key, comp);
                    //Recheck because a key could have been added to the parent
                    if (index >= 0) {
                        //existing key so update value
                        x.add(key,value,comp);
                        io.writeNode(x);
                        return;
                    }
                    index = (-index) - 1;
                    childNode = x.child(index);
                }

                insertNonFull(childNode, key, value);	
            }
        }
    }

    /**
     * Add the specified key, value pair to this tree. If the specified key
     * already exists then this will overwrite the existing value with the
     * specified value.
     * 
     * @param key
     * @param value
     * @throws IOException
     */
    public void insert(K key, V value) throws IOException {
        rwLock.writeLock().lock();
        try {
            //See if root node has key to update
            int insertKey = Collections.binarySearch(root.keys, key, comp);
            if (insertKey >= 0 ||root.nKeys() != (t*2-1)) {
                insertNonFull(root, key, value);
                return;
            }
    
            //Root is full, note that this is the only way the tree can grow in height.
            BtreeNode<K,V> newRoot = new BtreeNode<K,V>(io.allocateAddress(), io);
            newRoot.childAddresses.add(root.address());
            root.split(t, newRoot, 0);
            insertNonFull(newRoot, key, value);
    
            //Preserve the root node's address as being the actual root of the tree.
            BtreeNode<K,V> tmp = new BtreeNode<K,V>(newRoot);  
            newRoot.copyFrom(root);
            root.copyFrom(tmp);
            for (int i=0; i < root.childAddresses.size(); i++) {
                long childAddr = root.childAddresses.get(i);
                if (childAddr == root.address()) {
                    root.childAddresses.set(i, newRoot.address());
                    break;
                }
            }
        } finally {
            modificationCount++;
            rwLock.writeLock().unlock();
        }
    }

    /**
     * 
     * @param key
     * @return Null if there is not a value paired with the specified
     * key.  Else returns the value associated with that key.
     * @throws IOException
     */
    public V find(K key) throws IOException {
        rwLock.readLock().lock();
        try {
            if (root == null) {
                return null;
            }
            return find(root, key, null);
        } finally {
            rwLock.readLock().unlock();
        }
    }

    /**
     * Currently this just checks if the right most parent keys are less than
     * the min key of their right most child.
     * @throws InvalidBtreeException 
     * @throws IOException 
     * 
     */
    public void checkTree() throws IOException, InvalidBtreeException {
        rwLock.readLock().lock();
        try {
            checkTree(root);
        } finally {
            rwLock.readLock().unlock();
        }
    }
    
    private void checkTree(BtreeNode<K,V> node) throws IOException, InvalidBtreeException {
        if (node.isLeaf()) {
            //ok
            return;
        }
        BtreeNode<K,V> rightMostChild = node.child(node.nChildren() - 1);
        K maxKey = node.keys.get(node.nKeys() - 1);
        K childNodeMinKey = rightMostChild.keys.get(0);
        if (comp.compare(maxKey, childNodeMinKey) >= 0) {
            throw new InvalidBtreeException("Max parent key \"" + maxKey + 
                "\" is greater than min key \"" + childNodeMinKey +
                "\" of right most child."); 
        }
        checkTree(rightMostChild);
    }
    
    /**
     * @param node
     * @param key
     * @param stack If stack is not null then the nodes along this path are stored.  Else they are not.
     * @return
     * @throws IOException
     */
    private V find(BtreeNode<K,V> node, K key, Deque<StackFrame<K,V>> stack) throws IOException {
        int index = Collections.binarySearch(node.keys, key, comp);
        if (index >=0 ) {
            if (stack != null) {
                stack.push(new StackFrame<K,V>(index, node));
            }
            return node.values.get(index);
        }

        int missedIndex = (-index) - 1;
        if (stack != null && missedIndex != node.keys.size()) {
            stack.push(new StackFrame<K,V>( missedIndex, node));
        }

        if (node.isLeaf()) {
            return null;
        }

        BtreeNode<K,V> child = node.child((-index) - 1);
        return find(child, key, stack);
    }

    public int maxDepth() throws IOException {
        rwLock.readLock().lock();
        try {
            if (root.keys.size() == 0) {
                return 0;
            }
    
            final AtomicInteger depth = new AtomicInteger(1);
    
            PreOrderTraversal<K,V> traversal = new PreOrderTraversal<K, V>() {
    
                @Override
                protected void descend(BtreeNode<K, V> parent, BtreeNode<K, V> child, int level) throws IOException {
                    depth.set(Math.max(depth.get(), level));
                }
    
                @Override
                protected void visit(BtreeNode<K, V> node) throws IOException {
                    //This does nothing.
                }
    
                @Override
                protected void visitKey(K key, V value) {
                    //This does nothing.
                }
    
            };
    
            traversal.traverse(root, 1);
    
            return depth.get();
        } finally {
            rwLock.readLock().unlock();
        }
    }

    /**
     * Removes the specified key from the B-Tree.  If the key does not exist
     * then this does nothing.
     * 
     * @param key
     * @throws IOException
     */
    public void delete(K key) throws IOException {
        rwLock.writeLock().lock();
        try {
            //Find node that key would be in.  We might be able to get rid of this
            //But for now keep this here
            V value = find(key);
            if (value == null) {
                return;
            }
    
            deleteRec(key, root);
            //Check if root needs to be collasped as a result of step 3b
            if (root.keys.size() == 0 && root.childAddresses.size() > 0) {
    
                //Copy the child into the root node, because we don't want the
                //address of the root node to change.
                BtreeNode<K,V> newRoot = root.child(0);
                root.childAddresses.remove(0);
                root.keys.addAll(newRoot.keys);
                root.values.addAll(newRoot.values);
                root.childAddresses.addAll(newRoot.childAddresses);
                io.deleteNode(newRoot);
                io.writeNode(root);
            }
        } finally {
            modificationCount++;
            rwLock.writeLock().unlock();
        }
    }

    private void deleteRec(K key, BtreeNode<K,V> x) throws IOException {

        int keyIndex = Collections.binarySearch(x.keys, key, comp);

        if (x.isLeaf()) {
            //Case 1
            if (keyIndex < 0) {
                throw new IllegalStateException("Should have found key \"" +
                    key + "\" for deletion already.");
            }

            x.keys.remove(keyIndex);
            x.values.remove(keyIndex);
            if (x.keys.size() == 0) {
                if (x == root) {
                    io.writeNode(x);
                } else {
                    //io.deleteNode(x);
                    throw new IllegalStateException("delete() should not have reached here." + toDot());
                } 
            } else {
                io.writeNode(x);
            }
            return;

            //Internal node cases

        } else if (keyIndex >= 0) {
            //Case 2
            //Key is contained in an internal node, need to find replacement key.
            BtreeNode<K,V> nodeBeforeK = x.child(keyIndex);
            BtreeNode<K,V> nodeAfterK = null;  //Get this later to avoid unneed disk access
            if (nodeBeforeK.keys.size() >= t) {
                //Case 2a
                Pair<K,V> replacementKey = findReplacement(nodeBeforeK, true);
                x.keys.set(keyIndex, replacementKey.left);
                x.values.set(keyIndex, replacementKey.right);
                io.writeNode(x);
                deleteRec(replacementKey.left, nodeBeforeK);
            } else {
                nodeAfterK = x.child(keyIndex + 1);
                if (nodeAfterK.keys.size() >= t) {
                    //Case 2b
                    Pair<K,V> replacementKey = findReplacement(nodeAfterK, false);
                    x.keys.set(keyIndex, replacementKey.left);
                    x.values.set(keyIndex, replacementKey.right);
                    io.writeNode(x);
                    deleteRec(replacementKey.left, nodeAfterK);
                } else {
                    //Case 2c
                    //Neither the previous or the next node has enough keys so
                    //so merge them and delete from the new node.
                    nodeBeforeK.merge(nodeAfterK, key, x.values.get(keyIndex));
                    x.keys.remove(keyIndex);
                    x.values.remove(keyIndex);
                    x.childAddresses.remove(keyIndex + 1);
                    io.writeNode(x);
                    //merge does this: io.writeNode(nodeBeforeK);
                    deleteRec(key, nodeBeforeK);
                }
            }
        } else {
            //Key not contained in an internal node.

            keyIndex = (-keyIndex) - 1;
            BtreeNode<K,V> descentChild = x.child(keyIndex);
            if (descentChild.keys.size() >= t) {
                //ok
                deleteRec(key, descentChild);
            } else {
                //Case 3, make sure we ascend to node containing at least t keys
                BtreeNode<K,V> prevChild = (keyIndex == 0) ? null : x.child(keyIndex - 1);
                BtreeNode<K,V> afterChild = null;  //delay so we can reduce some disk access

                if (prevChild != null && prevChild.keys.size() >= t) {
                    //Case 3a
                    repackFromPrevious(x, descentChild, prevChild, keyIndex);
                    deleteRec(key, descentChild);
                } else {
                    //Case 3a
                    afterChild = (keyIndex == x.keys.size()) ? null : x.child(keyIndex + 1);
                    if (afterChild != null && afterChild.keys.size() >= t) {
                        repackFromNext(x, descentChild, afterChild, keyIndex);
                        deleteRec(key, descentChild);
                    } else {
                        //Case 3b
                        //Both siblings have t-1 keys.  Merge siblings
                        if (prevChild != null) {
                            K removedKey = x.keys.remove(keyIndex - 1);
                            V removedValue = x.values.remove(keyIndex - 1);
                            x.childAddresses.remove(keyIndex);
                            prevChild.merge(descentChild, removedKey, removedValue);
                            io.writeNode(x);
                            //merge does this: io.writeNode(prevChild);
                            //merge does this: io.deleteNode(descentChild);
                            deleteRec(key, prevChild);
                        } else {
                            K removedKey = x.keys.remove(keyIndex);
                            V removedValue = x.values.remove(keyIndex);
                            x.childAddresses.remove(keyIndex+1);
                            descentChild.merge(afterChild, removedKey, removedValue);
                            io.writeNode(x);
                            //merge does this: io.writeNode(descentChild);
                            //merge does this: io.deleteNode(afterChild);
                            deleteRec(key, descentChild);
                        }
                    }
                }
            }

        }
    }

    /**
     * See case 3a
     * @param parent The parent of descent and sib.
     * @param descent   The node deletion will descent into, but has less than
     * t keys.
     * @param prevSib A sibling to descent that has at least t keys.
     * @param keyIndex The index in the parent for descent/where k would be
     * if it where in the keys list of parent.
     * @throws IOException 
     * @throws IOException 
     */
    private void repackFromPrevious(BtreeNode<K,V> parent, BtreeNode<K,V> descent, BtreeNode<K,V> prevSib, int keyIndex) throws IOException{
        //Move from parent into child.
        descent.keys.add(0, parent.keys.get(keyIndex - 1));
        descent.values.add(0, parent.values.get(keyIndex -1));
        //Take key from sibling and move up
        K sibKey =  prevSib.keys.remove(prevSib.keys.size() - 1);
        V sibValue = prevSib.values.remove(prevSib.values.size() - 1);
        parent.keys.set(keyIndex - 1, sibKey);
        parent.values.set(keyIndex - 1, sibValue);
        if (prevSib.childAddresses.size() > 0) {
            long moveAddr = prevSib.childAddresses.remove(prevSib.childAddresses.size() - 1);
            descent.childAddresses.add(0, moveAddr);
        }

        io.writeNode(parent);
        io.writeNode(descent);
        io.writeNode(prevSib);
    }

    /**
     * See case 3a
     * @param parent The parent of descent and sib.
     * @param descent   The node deletion will descent into, but has less than
     * t keys.
     * @param nextSib A sibling to descent that has at least t keys.
     * @param keyIndex The index in the parent for descent/where k would be
     * if it where in the keys list of parent.
     * @throws IOException 
     * @throws IOException 
     */
    private void repackFromNext(BtreeNode<K,V> parent, BtreeNode<K,V> descent, BtreeNode<K,V> nextSib, int keyIndex) throws IOException  {
        //Move from parent into child.
        descent.keys.add(parent.keys.get(keyIndex ));
        descent.values.add(parent.values.get(keyIndex));

        //Take key from sibling and move up to parent to replace to key this
        //just took from the parent.
        K sibKey =  nextSib.keys.remove(0);
        V sibValue = nextSib.values.remove(0);
        parent.keys.set(keyIndex , sibKey);
        parent.values.set(keyIndex , sibValue);
        if (nextSib.childAddresses.size() > 0) {
            long moveAddr = nextSib.childAddresses.remove(0);
            descent.childAddresses.add( moveAddr);
        }

        io.writeNode(parent);
        io.writeNode(descent);
        io.writeNode(nextSib);

    }


    /**
     * Looks for the previous or next key in the tree compared with the
     * specified key.  This will always be in a leaf node.  When this key is
     * found it is returned.
     * @return The replacement key,value pair.
     */
    private Pair<K,V> findReplacement(BtreeNode<K,V> x,  boolean before) throws IOException {
        if (x.isLeaf()) {
            if (before) {
                int lastIndex = x.keys.size() - 1;
                return Pair.of(x.keys.get(lastIndex), x.values.get(lastIndex));
            } else {
                return Pair.of(x.keys.get(0), x.values.get(0));
            }
        } else {
            if (before) {
                return findReplacement(x.child(x.childAddresses.size() - 1), before);
            } else {
                return findReplacement(x.child(0), before);
            }
        }
    }

    /**
     * Start iteration from the specified key.  If they key does not exist then this
     * starts the iteration from the point where the key would be inserted.  If it
     * would be inserted at the end then Iterator.hasNext() will return false.
     * @param key
     * @return
     * @throws IOException
     */
    public Iterator<Pair<K,V>> iterateFrom(K key) throws IOException {
        rwLock.readLock().lock();
        try {
            if (root == null) {
                return new Iterator<Pair<K,V>>() {
                    @Override
                    public boolean hasNext() {
                        return false;
                    }
                    @Override
                    public void remove() {
                        throw new IllegalStateException("Iterator is empty.");
                    }
    
                    @Override
                    public Pair<K, V> next() {
                        throw new NoSuchElementException("Iterator is empty.");
                    }
                };
            }
    
            Deque<StackFrame<K, V>> stack = new LinkedList<StackFrame<K,V>>();
            find(root, key, stack);
            return new BTreeIterator(stack);
        } finally {
            rwLock.readLock().unlock();
        }
    }

    public Iterator<Pair<K,V>> iterator() {
        rwLock.readLock().lock();
        try {
            return new BTreeIterator();
        } catch (IOException e) {
            //Can't throw IOException since Iterable does not support it.
            throw new IllegalStateException("Iterator can not be created.", e);
        } finally {
            rwLock.readLock().unlock();
        }
    }

    /**
     * Dumps the current tree structure into the Graphviz directed graph
     * format.  See http://graphviz.org
     * 
     * @return
     * @throws IOException 
     */
    public String toDot() throws IOException {
        rwLock.readLock().lock();
        try {
            StringBuilder bldr = new StringBuilder();
    
            if (root == null) {
                return "digraph BTree {}";
            }
    
            bldr.append("digraph BTree {\n");
    
            List<Pair<String,String>> edges= new ArrayList<Pair<String,String>>();
            toDotRec(bldr, edges, root);
    
            for (Pair<String,String> edge : edges) {
                bldr.append("\t").append(edge.left)
                .append("[label=\"").append(edge.right).append("\"];\n");
            }
            bldr.append("}\n");
            return bldr.toString();
        } finally {
            rwLock.readLock().unlock();
        }
    }

    private void toDotRec(StringBuilder bldr, List<Pair<String,String>> edges, BtreeNode<K,V> x) throws IOException {
        bldr.append("\tnode").append(x.address()).append("[shape=record,label=\"");

        if (x.isLeaf()) {
            if (x.keys.size() > 10) {
                int lastIndex = x.keys.size() - 1;
                bldr.append("<f0>").append(x.keys.get(0))
                .append('|');
                bldr.append("<f1> ... ").append(x.keys.size() - 2).append(" ...|");
                bldr.append("<f").append(lastIndex).append(">").append(x.keys.get(lastIndex)).append("\"];\n");
            } else {
                for (int i=0; i < x.keys.size(); i++) {
                    bldr.append("<f").append(i).append(">").append(x.keys.get(i));
                    bldr.append('|');
                }
                bldr.setLength(bldr.length() - 1);
                bldr.append("\"];\n");
            }

        } else {
            for (int i=0; i < x.keys.size(); i++) {
                bldr.append("<f").append(i*2).append(">|");
                bldr.append("<f").append(2*i+1).append(">")
                .append(x.keys.get(i)).append("|");
            }
            bldr.append("<f").append(x.childAddresses.size() + x.keys.size() - 1).append(">");
            bldr.append("\"];\n");

            for (int i=0; i < x.childAddresses.size(); i++) {
                long child = x.childAddresses.get(i);
                int fieldName =i * 2;
                String edgeName = "\"node"+x.address()+"\":f" + fieldName + "->node"+child;
                String edgeAnnotation = "" + child;
                edges.add(Pair.of(edgeName, edgeAnnotation));

                toDotRec(bldr, edges, x.child(i));
            }
        }
    }

    /**
     * Visits keys in their sorted order (preOrder) 
     */
    abstract private static class PreOrderTraversal<K,V> {


        void traverse(BtreeNode<K,V> startNode, int level) throws IOException {
            if (startNode == null) {
                return;
            }


            if (startNode.isLeaf()) {
                for (int i=0; i < startNode.keys.size(); i++) {
                    visitKey(startNode.keys.get(i), startNode.values.get(i));
                }
            } else {
                for (int i=0; i < startNode.childAddresses.size(); i++) {
                    BtreeNode<K,V> childNode = startNode.child(i);
                    descend(startNode, childNode, level+1);
                    if (i < startNode.keys.size()) {
                        visitKey(startNode.keys.get(i), startNode.values.get(i));
                    }
                    traverse(childNode, level+1);
                }
            } 

        }

        protected abstract void visit(BtreeNode<K,V> node) throws IOException;

        protected abstract void descend(BtreeNode<K,V> parent, BtreeNode<K,V> child, int level) throws IOException;

        protected abstract void visitKey(K key, V value);


    }

    private class BTreeIterator implements Iterator<Pair<K,V>> {
        /**  The integer value must point to the value to return from next().
         */
        private final Deque<StackFrame<K,V>> stack;
        private final int modificationCountAtCreation;

        BTreeIterator() throws IOException {
            this.stack =  new LinkedList<StackFrame<K,V>>();
            this.modificationCountAtCreation = modificationCount;
            init();
        }

        BTreeIterator(Deque<StackFrame<K,V>> stack) {
            this.stack = stack;
            this.modificationCountAtCreation = modificationCount;
        }

        private void init() throws IOException {
            if (root.keys.size() ==0) {
                return; //empty tree
            }

            stack.push(new StackFrame<K,V>(0,root));
            while (!stack.peek().node.isLeaf()) {
                BtreeNode<K,V> node = stack.peek().node.child(0);
                stack.push(new StackFrame<K,V>(0, node));
            }
        }

        public boolean hasNext() {
            //   printStack();
            return !stack.isEmpty();
        }

        public Pair<K,V> next() {
            rwLock.readLock().lock();
            try {
                if (stack.isEmpty()) {
                    throw new NoSuchElementException("End of iteration.");
                }
                
                if (modificationCountAtCreation != modificationCount) {
                    throw new ConcurrentModificationException("btree modified "+
                            "after iterator constructed");
                }
                final StackFrame<K,V> nextValue = stack.pop();
                BtreeNode<K,V>  node = nextValue.node;
                int kvIndex = nextValue.index;
                final Pair<K,V> rv = Pair.of(node.keys.get(kvIndex), node.values.get(kvIndex));
                //advance
                if (node.isLeaf()) {
                    kvIndex++;
                    if (kvIndex != node.keys.size()) {
                        stack.push(new StackFrame<K,V>(kvIndex, node));
                    }
                } else {
                    kvIndex++;
                    if (kvIndex  != node.keys.size()) {
                        StackFrame<K,V> selfBackOnStack = new StackFrame<K,V>(kvIndex, node);
                        stack.push(selfBackOnStack);
                    }
                    try {
                        node = node.child(kvIndex);
                        StackFrame<K,V> nextNode = new StackFrame<K,V>(0, node);
                        stack.push(nextNode);
                        while (!stack.peek().node.isLeaf()) {
                            node = stack.peek().node.child(0);
                            stack.push(new StackFrame<K,V>(0, node));
                        }
                    } catch (IOException ioe) {
                        //Iterator.next() does not allow IOException
                        throw new IllegalStateException("Can not get next node.", ioe);
                    }
                }
    
                return rv;
            } finally {
                rwLock.readLock().unlock();
            }

        }
        //Useful for debugging.
        @SuppressWarnings("unused")
        private void printStack() {
            for (StackFrame<K,V> frame : stack) {
                System.out.println(frame.index + " " + frame.node.keys.get(0));
            }
            System.out.println("");
        }

        public void remove() {
            throw new UnsupportedOperationException("delete() not supported on this iterator.");
        }
    }


    private static final class StackFrame<K,V> {
        public final BtreeNode<K,V> node;
        public final int index;

        StackFrame(int index, BtreeNode<K,V> node) {
            this.index = index;
            this.node = node;
        }
    }

}
