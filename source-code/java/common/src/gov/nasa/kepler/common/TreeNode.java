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

package gov.nasa.kepler.common;

import java.util.ArrayList;
import java.util.List;

/**
 * Represents a node in a Tree. Each node can have multiple children.
 * 
 * @author tklaus
 */
public class TreeNode<T> {

    public T data;
    public List<TreeNode<T>> children;

    /**
     * Default ctor.
     */
    public TreeNode() {
    }

    /**
     * Convenience ctor to create a Node<T> with an instance of T.
     * 
     * @param data an instance of T.
     */
    public TreeNode(T data) {
        this();
        setData(data);
    }

    /**
     * Performs a depth-first search of the tree rooted at this Node for a Node
     * with the specified data object. Comparison is done using equals(). 
     * The first match is returned.
     */
    public TreeNode<T> find(T data) {
        return find(this, data);
    }

    /** 
     * Recursive find
     * 
     * @param root
     * @return
     */
    private TreeNode<T> find(TreeNode<T> root, T data){
        if (this.data.equals(data)) {
            return this;
        } else {
            List<TreeNode<T>> kids = getChildren();
            for (TreeNode<T> node : kids) {
                TreeNode<T> matchingNode = find(node, data);
                if(matchingNode != null){
                    return matchingNode;
                }
            }
        }
        return null;
    }
    
    /**
     * Return the children of Node<T>. The Tree<T> is represented by a single
     * root Node<T> whose children are represented by a List<Node<T>>. Each
     * of these Node<T> elements in the List can have children. The
     * getChildren() method will return the children of a Node<T>.
     * 
     * @return the children of Node<T>
     */
    public List<TreeNode<T>> getChildren() {
        if (this.children == null) {
            return new ArrayList<TreeNode<T>>();
        }
        return this.children;
    }

    /**
     * Sets the children of a Node<T> object. See docs for getChildren() for
     * more information.
     * 
     * @param children the List<Node<T>> to set.
     */
    public void setChildren(List<TreeNode<T>> children) {
        this.children = children;
    }

    /**
     * Returns the number of immediate children of this Node<T>.
     * 
     * @return the number of immediate children.
     */
    public int getNumberOfChildren() {
        if (children == null) {
            return 0;
        }
        return children.size();
    }

    /**
     * Adds a child to the list of children for this Node<T>. The addition of
     * the first child will create a new List<Node<T>>.
     * 
     * @param child a Node<T> object to set.
     */
    public void addChild(TreeNode<T> child) {
        if (children == null) {
            children = new ArrayList<TreeNode<T>>();
        }
        children.add(child);
    }

    /**
     * Inserts a Node<T> at the specified position in the child list. Will *
     * throw an ArrayIndexOutOfBoundsException if the index does not exist.
     * 
     * @param index the position to insert at.
     * @param child the Node<T> object to insert.
     * @throws IndexOutOfBoundsException if thrown.
     */
    public void insertChildAt(int index, TreeNode<T> child) throws IndexOutOfBoundsException {
        if (index == getNumberOfChildren()) {
            // this is really an append
            addChild(child);
            return;
        } else {
            children.get(index); // just to throw the exception, and stop
                                    // here
            children.add(index, child);
        }
    }

    /**
     * Remove the Node<T> element at index index of the List<Node<T>>.
     * 
     * @param index the index of the element to delete.
     * @throws IndexOutOfBoundsException if thrown.
     */
    public void removeChildAt(int index) throws IndexOutOfBoundsException {
        children.remove(index);
    }

    public T getData() {
        return this.data;
    }

    public void setData(T data) {
        this.data = data;
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append("{")
            .append(getData().toString())
            .append(",[");
        int i = 0;
        for (TreeNode<T> e : getChildren()) {
            if (i > 0) {
                sb.append(",");
            }
            sb.append(e.getData()
                .toString());
            i++;
        }
        sb.append("]")
            .append("}");
        return sb.toString();
    }
}
