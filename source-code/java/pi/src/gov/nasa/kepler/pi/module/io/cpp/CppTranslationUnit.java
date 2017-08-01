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

package gov.nasa.kepler.pi.module.io.cpp;

import gov.nasa.spiffy.common.persistable.WalkerListener;

import java.lang.reflect.Field;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class delegates callbacks from {@link WalkerListener} to the matching 
 * {@link CppHeader} and {@link CppFile} objects
 * 
 * @author Todd Klaus
 * 
 */
public class CppTranslationUnit implements WalkerListener {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(CppTranslationUnit.class);

    private CppHeader header;
    private CppCode code;
    private String className = null;

    public CppTranslationUnit(String className) {
        this.className = className;
        header = new CppHeader(className);
        code = new CppCode(className);
    }

    public String header() {
        return header.content();
    }

    public String code() {
        return code.content();
    }

    /**
     * Implements WalkerListener.classStart
     */
    @Override
    public void classStart(Class<?> clazz) {
        throw new IllegalStateException("classStart should never be called on CppTranslationUnit:"
            + " for nested classes, a new CppTranslationUnit instance should have been created");
    }

    /**
     * Implements WalkerListener.classEnd
     */
    @Override
    public void classEnd(Class<?> clazz) {
        throw new IllegalStateException("classStart should never be called on CppTranslationUnit:"
            + " for nested classes, a new CppTranslationUnit instance should have been created");
    }

    /**
     * Implements WalkerListener.primitiveField
     */
    @Override
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision) throws Exception {
        header.addField(name, classSimpleName, true);
        code.addField(name, classSimpleName, true);
    }

    /**
     * Implements WalkerListener.classField
     */
    @Override
    public void classField(Field field) throws Exception {
        String name = field.getName();
        String classSimpleName = field.getType().getSimpleName();
        header.addField(name, classSimpleName, false);
        code.addField(name, classSimpleName, false);
    }

    /**
     * Implements WalkerListener.unknownType
     */
    @Override
    public void unknownType(Field field) throws Exception {
        String name = field.getName();
        String canonicalClassName = field.getType().getCanonicalName();
        throw new UnsupportedOperationException("unknown type = " + canonicalClassName + ", name = " + name);
    }

    /**
     * Implements WalkerListener.primitiveArrayField
     */
    @Override
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field, boolean preservePrecision) throws Exception {
        header.addListField(name, classSimpleName, true, dimensions);
        code.addListField(name, classSimpleName, true, dimensions);
    }

    /**
     * Implements WalkerListener.classArrayField
     */
    @Override
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception {
        String name = field.getName();
        String classSimpleName = elementClass.getSimpleName();
        header.addListField(name, classSimpleName, false, dimensions);
        code.addListField(name, classSimpleName, false, dimensions);
    }

    /**
     * 
     * @return
     */
    public String getClassName() {
        return className;
    }
}
