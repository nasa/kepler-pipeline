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

import gov.nasa.spiffy.common.persistable.BinFieldNode.CollectionType;
import gov.nasa.spiffy.common.persistable.BinFieldNode.Type;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.lang.reflect.Field;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Provides the logic to build a tree of {@link BinFieldNode}s from
 * an object tree using the {@link ClassWalker}
 * 
 * @author tklaus
 *
 */
public class BinFieldTree implements WalkerListener {
    private static final Log log = LogFactory.getLog(BinFieldTree.class);

    private BinFieldNode root;
    private BinFieldNode currentContainerNode;
    private BinFieldNode previousFieldNode;
    private byte nextTag = 1;

    public BinFieldTree() {
    }

    public void buildTree(Object rootObject) throws Exception {
        ClassWalker walker = new ClassWalker(rootObject.getClass());
        walker.addListener(this);
        walker.parse();
    }

    private void addNode(String name, Type type, CollectionType collectionType) throws IllegalArgumentException {
        BinFieldNode newNode = new BinFieldNode(name, nextTag++, type, collectionType);
        currentContainerNode.addChild(newNode);
        previousFieldNode = newNode;
    }

    @Override
    public void classStart(Class<?> clazz) throws Exception {
        String simpleName = clazz.getSimpleName();
        log.debug("classStart: " + simpleName);
        if (root == null) {
            // this is the root
            root = new BinFieldNode(simpleName, nextTag++, BinFieldNode.Type.PERSISTABLE, BinFieldNode.CollectionType.NONE);
            currentContainerNode = root;
        } else {
            // this new class is the class of the previously seen field
            currentContainerNode = previousFieldNode;
        }
    }

    @Override
    public void classEnd(Class<?> clazz) throws Exception {
        String simpleName = clazz.getSimpleName();
        log.debug("classEnd: " + simpleName);
        currentContainerNode = currentContainerNode.getParent();
    }

    @Override
    public void classField(Field field) throws Exception {
        String name = field.getName();
        log.debug("classField: " + name);
        addNode(name, BinFieldNode.Type.PERSISTABLE, BinFieldNode.CollectionType.NONE);
    }

    @Override
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision) throws Exception {
        log.debug("primitiveField: " + name);
        addNode(name, type(classSimpleName), BinFieldNode.CollectionType.NONE);
    }

    @Override
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception {
        String name = field.getName();
        log.debug("classArrayField: " + name);
        addNode(name, BinFieldNode.Type.PERSISTABLE, BinFieldNode.CollectionType.LIST);
    }

    @Override
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field, boolean preservePrecision) throws Exception {
        log.debug("primitiveArrayField: " + name);
        addNode(name, type(classSimpleName), BinFieldNode.CollectionType.LIST);
    }

    @Override
    public void unknownType(Field field) throws Exception {
        String name = field.getName();
        log.debug("unknownType: " + name);
        throw new PipelineException("Unknown type:" + field.getType().getCanonicalName());
    }

    private BinFieldNode.Type type(String typeName){
        return BinFieldNode.Type.valueOf(typeName.toUpperCase());
    }
    
    public void dump() {
        String tabs = "";
        dumpNode(tabs, root);
    }

    private void dumpNode(String tabs, BinFieldNode node) {
        log.info(tabs + "name: " + node.getName() + ", tag: " + node.getTag() + ", type: " + node.getType());
        for (BinFieldNode child : node.getChildren()) {
            dumpNode(tabs + " ", child);
        }
    }
}
