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

import gov.nasa.spiffy.common.persistable.ClassWalker;
import gov.nasa.spiffy.common.persistable.WalkerListener;

import java.lang.reflect.Field;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

public class ClassWalkerTest implements WalkerListener {
    private static final Log log = LogFactory.getLog(ClassWalkerTest.class);
    private int indent = 0;

    @Test
    public void testParse() throws Exception {
        ClassWalker walker = new ClassWalker(TestPersistable.class);
        walker.addListener(this);
        walker.parse();
    }

    @Override
    public void classStart(Class<?> clazz) {
        indent++;
        log.info(indent() + "START class, sn=" + clazz.getSimpleName() + ", cn=" + clazz.getCanonicalName());
    }

    @Override
    public void classEnd(Class<?> clazz) {
        log.info(indent() + "END class, sn=" + clazz.getSimpleName() + ", cn=" + clazz.getCanonicalName());
        indent--;
    }

    @Override
    public void primitiveField(String name, String classSimpleName, Field field, boolean preservePrecision)
        throws Exception {
        log.info(indent() + "FIELD primitive, n=" + name + ", t=" + classSimpleName);
    }

    @Override
    public void primitiveArrayField(String name, String classSimpleName, int dimensions, Field field,
        boolean preservePrecision) throws Exception {
        log.info(indent() + "FIELD primitive[], n=" + name + ", t=" + classSimpleName + ", d=" + dimensions);
    }

    @Override
    public void classField(Field field) throws Exception {
        String name = field.getName();
        String simpleClassName = field.getType().getSimpleName();
        log.info(indent() + "FIELD class, n=" + name + ", t=" + simpleClassName);
    }

    @Override
    public void classArrayField(Field field, Class<?> elementClass, int dimensions) throws Exception {
        String name = field.getName();
        String simpleClassName = field.getType().getSimpleName();
        log.info(indent() + "FIELD class[], n=" + name + ", t=" + simpleClassName + ", d=" + dimensions);
    }

    @Override
    public void unknownType(Field field) {
        String name = field.getName();
        String simpleClassName = field.getType().getSimpleName();
        String canonicalClassName = field.getType().getCanonicalName();
        log.info(indent() + "UNKNOWN type, n=" + name + ", sn=" + simpleClassName + ", cn=" + canonicalClassName);
    }

    private String indent() {
        StringBuffer b = new StringBuffer();
        for (int i = 0; i < indent; i++) {
            b.append(" ");
        }
        return b.toString();
    }
}
