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

package gov.nasa.spiffy.common.persistable;

import java.util.ArrayList;
import java.util.List;

/**
 * A tree node that represents a single field in a class.
 * If that field is a class (non-primitive), then the children
 * of the node are the fields of that class.
 * 
 * Used by the serializers and the code generators to tag the 
 * field values as they are written with their tag value (unique
 * value for each node in the tree) so they can be cross-checked when
 * reading to provide better error diagnostics and detect invalid .bin files.
 *  
 * @author tklaus
 *
 */
public class BinFieldNode {

    public enum Type{
        CHAR((byte)1),
        BYTE((byte)2),
        SHORT((byte)3),
        INT((byte)4),
        LONG((byte)5),
        FLOAT((byte)6),
        DOUBLE((byte)7),
        STRING((byte)8),
        BOOLEAN((byte)9),
        PERSISTABLE((byte)10);
        
        /** Value stored in the bin file for the type */
        private byte value;

        private Type(byte value) {
            this.value = value;
        }

        public byte getValue() {
            return value;
        }
    }
    
    public enum CollectionType{
        NONE((byte)1),
        LIST((byte)2),
        SET((byte)3),
        MAP((byte)4);

        /** Value stored in the bin file for the type */
        private byte value;

        private CollectionType(byte value) {
            this.value = value;
        }

        public byte getValue() {
            return value;
        }
    }

    private String name;
    private byte tag;
    private CollectionType collectionType;
    private Type type;
    
    private BinFieldNode parent = null;
    private List<BinFieldNode> children = new ArrayList<BinFieldNode>();
    
    public BinFieldNode(String name, byte tag, Type type, CollectionType collectionType) {
        this.name = name;
        this.tag = tag;
        this.type = type;
        this.collectionType = collectionType;
    }

    public boolean addChild(BinFieldNode child) {
        child.setParent(this);
        return children.add(child);
    }

    public void clearChildren() {
        children.clear();
    }

    public boolean removeChild(BinFieldNode child) {
        child.setParent(null);
        return children.remove(child);
    }

    public List<BinFieldNode> getChildren() {
        return children;
    }

    public BinFieldNode findChild(String name) {
        for (BinFieldNode child : children) {
            if(child.getName().equals(name)){
                return child;
            }
        }
        return null;
    }

    public String getName() {
        return name;
    }

    public BinFieldNode getParent() {
        return parent;
    }

    public byte getTag() {
        return tag;
    }

    public Type getType() {
        return type;
    }

    public CollectionType getCollectionType() {
        return collectionType;
    }

    public void setCollectionType(CollectionType collectionType) {
        this.collectionType = collectionType;
    }

    public void setChildren(List<BinFieldNode> children) {
        this.children = children;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setParent(BinFieldNode parent) {
        this.parent = parent;
    }

    public void setType(Type type) {
        this.type = type;
    }

    public void setTag(byte tag) {
        this.tag = tag;
    }
}
