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

package gov.nasa.kepler.common.file;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

/**
 * Converts the a listing of files in <file> <d | size> format into an XML tree
 * supported by jTreeMap.
 * 
 * @author Sean McCauliff
 *
 */
class FileSizesToTreeMapXml {

    private static final Appendable indent(Appendable out, int level) throws IOException {
        for (int i=0; i < level; i++) {
            out.append("\t");
        }
        return out;
    }
    
    private static final class DirNode {
        private final String dirName;
        private final DirNode parent;
        private final boolean leaf;
        
        private Set<DirNode> children;
        
        private long sizeInBytes = 0;
        
        /**
         * 
         * @param dirName this should be the full path else hashCode() and equals()
         * will fail.
         * @param parent this may be null if this is the root node
         */
        public DirNode(String dirName, DirNode parent, boolean leaf) {
            this.dirName = dirName;
            this.parent = parent;
            this.leaf = leaf;
        }
        
        public String dirName() {
            return dirName;
        }
        
        public void addToSizeCount(long count) {
            sizeInBytes += count;
        }
        
        public DirNode parent() {
            return parent;
        }
        
        public boolean isLeaf() {
            return leaf;
        }
        
        public void addChild(DirNode child) {
            if (children == null) {
                children = new HashSet<DirNode>();
            }
            children.add(child);
        }
        
        public void toXml(Appendable out, int indentLevel) throws IOException {
            if (leaf) {
                String doubleSizeStr = String.format("%g",(double)sizeInBytes);
                indent(out, indentLevel).append("<leaf> <label>")
                    .append(dirName).append("</label><weight>")
                    .append(doubleSizeStr).append("</weight>")
                    .append("<value>").append(doubleSizeStr)
                    .append("</value> </leaf>\n");
            } else {
                indent(out, indentLevel).append("<branch><label>").append(dirName).append("</label>\n");
            }
        }

        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            result = prime * result
                + ((dirName == null) ? 0 : dirName.hashCode());
            result = prime * result
                + ((parent == null) ? 0 : parent.hashCode());
            result = prime * result
                + (int) (sizeInBytes ^ (sizeInBytes >>> 32));
            return result;
        }

        @Override
        public boolean equals(Object obj) {
            if (this == obj)
                return true;
            if (obj == null)
                return false;
            if (getClass() != obj.getClass())
                return false;
            DirNode other = (DirNode) obj;
            if (dirName == null) {
                if (other.dirName != null)
                    return false;
            } else if (!dirName.equals(other.dirName))
                return false;
            if (parent == null) {
                if (other.parent != null)
                    return false;
            } else if (!parent.equals(other.parent))
                return false;
            if (sizeInBytes != other.sizeInBytes)
                return false;
            return true;
        }
        
        
    }
    
    public void convert(BufferedReader in, Appendable out) 
        throws NumberFormatException, IOException {
        
        Map<String, DirNode> nodeNameToNode = new HashMap<String, DirNode>();

        for (String line = in.readLine(); line != null; line = in.readLine()) {
            String[] parts = line.split("\\s+");
            String path = parts[0];
            String sizeStr = parts[1];
            if (sizeStr.equals("d")) {
                continue;
            }
            
            if (path.endsWith("/")) {
                throw new IllegalStateException("Directory \"" + path + "\" has size.");
            }
            long size = Long.parseLong(sizeStr);
            
            //TODO:  if there is not a single root then this may fail.
            addSize(nodeNameToNode, path, 0, null, size);
        }
        
        
        DirNode rootNode = findRoot(nodeNameToNode);
        out.append("<?xml version='1.0' encoding='UTF-8'?>\n");
        out.append("<!DOCTYPE root SYSTEM \"TreeMap.dtd\" >\n");
        out.append("<root>\n");
        out.append("  <label>").append(rootNode.dirName()).append("</label>\n");
        
        appendNodes(out, rootNode, 1);
        
        out.append("</root>\n");
        
    }

    
    private static void appendNodes(Appendable out, DirNode branchNode, int level) throws IOException {
        branchNode.toXml(out, level);
        if (!branchNode.isLeaf()) {
            for (DirNode child : branchNode.children) {
                appendNodes(out, child, level + 1);
            }
            indent(out, level).append("</branch>\n");
        }
    }
    
    private static DirNode findRoot(Map<String, DirNode> nodes) {
        DirNode root = null;
        for (DirNode dirNode : nodes.values()) {
            if (dirNode.parent() != null) {
                continue;
            }
            
            if (root != null) {
                throw new IllegalStateException("Found more than one root.");
            }
            
            root = dirNode;
        }
        
        if (root == null) {
            throw new IllegalStateException("Did not find root.");
        }
        return root;
    }
    
   /**
    * Traverse the paths from root to leaf, creating directory nodes as needed
    * and adding size to the nodes.
    * 
    * @param nodeNameToNode
    * @param path
    * @param startFromPathIndex
    * @param parent
    * @param size
    */
    private static void addSize(Map<String, DirNode> nodeNameToNode,
        String path, int startFromPathIndex, DirNode parent, long size) {
        int firstSlash = path.indexOf('/', startFromPathIndex);
        if (firstSlash == 0) {
            addSize(nodeNameToNode, path, 1, parent, size);
            return;
        }
        
        boolean isLeaf = firstSlash == -1;
        String pathFromRoot = isLeaf ? path : path.substring(0, firstSlash);

        
        DirNode node = nodeNameToNode.get(pathFromRoot);
        if (node == null) {
            node = new DirNode(pathFromRoot, parent, isLeaf);
            nodeNameToNode.put(pathFromRoot, node);
        }
        node.addToSizeCount(size);
        
        if (parent != null) {
            parent.addChild(node);
        }
        
        if (firstSlash == -1) {
            return;
        }
        addSize(nodeNameToNode, path, firstSlash + 1, node, size);
    }
}
