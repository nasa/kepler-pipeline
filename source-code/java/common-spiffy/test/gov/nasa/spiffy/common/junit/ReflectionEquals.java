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

package gov.nasa.spiffy.common.junit;

import static org.junit.Assert.fail;

import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.Stack;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Utility class for unit tests that uses reflection to do a deep compare of two
 * object trees. It is intended to overcome 2 limitations with the JUnit
 * assertEquals method: 1- Allows deep compare of Hibernate Collections and
 * Maps, or any other classes which only provide identity equals() 2- Provides
 * better feedback on what the differences were when object trees don't match
 * 
 * Calls assertEquals() on primitives and non-gov.nasa.kepler types.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class ReflectionEquals {
    private static final Log log = LogFactory.getLog(ReflectionEquals.class);

    private Set<Pattern> excludedFieldPatterns = new HashSet<Pattern>();

    public ReflectionEquals() {
        super();
    }

    /**
     * Exclude fields whose fully qualified name matches the specified regular
     * expression pattern.
     * 
     * Fully-qualified field names are of the form:
     * PipelineDefinition.auditInfo.lastChangedUser.loginName
     * 
     * For example: excludeField(".*\\.id"); excludes fields named id for any
     * object in the object tree
     * 
     * @param fullyQualifiedFieldNamePattern
     */
    public void excludeField(String fullyQualifiedFieldNamePattern) {

        excludedFieldPatterns.add(Pattern.compile(fullyQualifiedFieldNamePattern));
    }

    public void assertEquals(String message, Object expectedObject,
        Object actualObject) throws IllegalAccessException {

        compareObjects(message, "", expectedObject, actualObject);
    }

    public void assertEquals(Object expectedObject, Object actualObject)
        throws IllegalAccessException {

        compareObjects(expectedObject.getClass()
            .toString(), "", expectedObject, actualObject);
    }

    private void compareObjects(String message, String fullyQualifiedFieldName,
        Object expectedObject, Object actualObject)
        throws IllegalAccessException {

        if (matchesExcludeFilter(fullyQualifiedFieldName)) {
            log.debug("skipping:" + message
                + " because it's on the exclude list");
            return;
        }

        log.debug("comparing: " + message);
        // log.debug("fqfn=" + fullyQualifiedFieldName);

        if (expectedObject == actualObject) {
            // same object, must be equal!
            return;
        }

        if (expectedObject == null || actualObject == null) {
            if (expectedObject == null && actualObject == null) {
                // both null, so they're equal -- don't continue checking this
                // branch
                return;
            }
            if (expectedObject == null) {
                fail(message
                    + ": expectedObject is null, but actualObject is not!");
            } else {
                fail(message
                    + ": actualObject is null, but expectedObject is not!");
            }
        }

        Class<?> expectedClass = expectedObject.getClass();
        Class<?> actualClass = actualObject.getClass();

        if (expectedClass.isArray()) {
            if (!actualClass.isArray()) {
                fail(message
                    + ": expectedObject isArray, but actualObject is not!");
            }

            Object[] expectedArray = null;
            Object[] actualArray = null;

            if (expectedObject instanceof Object[]) {
                expectedArray = (Object[]) expectedObject;
                actualArray = (Object[]) actualObject;
            } else {
                if (expectedObject instanceof boolean[]) {
                    expectedArray = ArrayUtils.toObject((boolean[]) expectedObject);
                    actualArray = ArrayUtils.toObject((boolean[]) actualObject);
                } else if (expectedObject instanceof byte[]) {
                    expectedArray = ArrayUtils.toObject((byte[]) expectedObject);
                    actualArray = ArrayUtils.toObject((byte[]) actualObject);
                } else if (expectedObject instanceof char[]) {
                    expectedArray = ArrayUtils.toObject((char[]) expectedObject);
                    actualArray = ArrayUtils.toObject((char[]) actualObject);
                } else if (expectedObject instanceof double[]) {
                    expectedArray = ArrayUtils.toObject((double[]) expectedObject);
                    actualArray = ArrayUtils.toObject((double[]) actualObject);
                } else if (expectedObject instanceof float[]) {
                    expectedArray = ArrayUtils.toObject((float[]) expectedObject);
                    actualArray = ArrayUtils.toObject((float[]) actualObject);
                } else if (expectedObject instanceof int[]) {
                    expectedArray = ArrayUtils.toObject((int[]) expectedObject);
                    actualArray = ArrayUtils.toObject((int[]) actualObject);
                } else if (expectedObject instanceof long[]) {
                    expectedArray = ArrayUtils.toObject((long[]) expectedObject);
                    actualArray = ArrayUtils.toObject((long[]) actualObject);
                } else if (expectedObject instanceof short[]) {
                    expectedArray = ArrayUtils.toObject((short[]) expectedObject);
                    actualArray = ArrayUtils.toObject((short[]) actualObject);
                } else {
                    fail(message + ": unknown array type");
                }
            }

            compareArrays(message, fullyQualifiedFieldName, expectedArray,
                actualArray);
        } else if (java.util.Collection.class.isAssignableFrom(expectedClass)) {
            if (!java.util.Collection.class.isAssignableFrom(actualClass)) {
                fail(message
                    + ": expectedObject is a Collection, but actualObject is not!");
            }

            Collection<?> expectedCollection = (Collection<?>) expectedObject;
            Collection<?> actualCollection = (Collection<?>) actualObject;

            compareCollections(message, fullyQualifiedFieldName,
                expectedCollection, actualCollection);
        } else if (java.util.Map.class.isAssignableFrom(expectedClass)) {
            if (!java.util.Map.class.isAssignableFrom(actualClass)) {
                fail(message
                    + ": expectedObject is a Map, but actualObject is not!");
            }

            Map<?, ?> expectedMap = (Map<?, ?>) expectedObject;
            Map<?, ?> actualMap = (Map<?, ?>) actualObject;

            compareMaps(message, fullyQualifiedFieldName, expectedMap,
                actualMap);
        } else if (expectedClass.isPrimitive()) {
            // just use assertEquals
            org.junit.Assert.assertEquals(message, expectedObject, actualObject);
        } else if (!expectedClass.getName()
            .startsWith("gov.nasa")) {
            // for non-NASA classes, just use JUnit assertEquals
            org.junit.Assert.assertEquals(message, expectedObject, actualObject);
        } else {
            /*
             * Commenting this out for now because it doesn't work with
             * Hibernate CGLIB-generated classes. If the classes really don't
             * match, then the fields won't match and the comparison will fail
             * below
             */
            // if (!expectedClass.isAssignableFrom(actualClass)) {
            // fail("Class of expectedObject(" + expectedClass +
            // ") does not match class of actualObject("
            // + actualClass + ")");
            // }
            // walk through all the fields, including all superclasses
            Stack<Class<?>> hierarchy = new Stack<Class<?>>();
            Class<?> hClazz = expectedClass;
            while (hClazz != null) {
                hierarchy.push(hClazz);
                hClazz = hClazz.getSuperclass();
            }

            while (!hierarchy.isEmpty()) {
                hClazz = hierarchy.pop();

                Field[] fields = hClazz.getDeclaredFields();
                for (int i = 0; i < fields.length; i++) {
                    Field field = fields[i];

                    if (!Modifier.isTransient(field.getModifiers())) {
                        // allow us to access the value of private fields
                        field.setAccessible(true);

                        compareObjects(message + "." + field.getName(),
                            fullyQualifiedFieldName + "." + field.getName(),
                            getFieldValue(field, expectedObject),
                            getFieldValue(field, actualObject));
                        // field.get(expectedObject), field.get(actualObject));
                    }
                }
            }
        }
    }

    /**
     * Get the value of the field. The easiest way is to just use Field.get(),
     * but this doesn't work with Hibernate proxies because they never actually
     * fill in the fields, they just contain an instance of the actual class and
     * delegate all method calls to the target. This means we need to use the
     * getter, if available, to fetch the object. If there is no getter, we
     * fallback to direct field access.
     * 
     * Note that this *still* doesn't work for proxies of a superclass. The
     * proxy only contains the methods of the superclass,
     * 
     * @param field
     * @param object
     * @return
     */
    private Object getFieldValue(Field field, Object object)
        throws IllegalAccessException {

        String getGetterName = getGetterName("get", field.getName());
        String isGetterName = getGetterName("is", field.getName());
        Method getterMethod;

        // first try getX
        try {
            getterMethod = object.getClass()
                .getMethod(getGetterName, new Class[0]);
            getterMethod.setAccessible(true);
            Object value = getterMethod.invoke(object, new Object[0]);
            return value;
        } catch (Exception e) {
            log.debug("No getter method found for field: " + field.getName());
        }

        // then try isX
        try {
            getterMethod = object.getClass()
                .getMethod(isGetterName, new Class[0]);
            getterMethod.setAccessible(true);
            Object value = getterMethod.invoke(object, new Object[0]);
            return value;
        } catch (Exception e) {
            log.debug("No getter method found for field: " + field.getName());
        }

        return field.get(object);
    }

    private String getGetterName(String prefix, String fieldName) {

        StringBuilder getBuffer = new StringBuilder(prefix);
        getBuffer.append(fieldName.substring(0, 1)
            .toUpperCase());
        getBuffer.append(fieldName.substring(1));
        String getterName = getBuffer.toString();

        return getterName;
    }

    private boolean matchesExcludeFilter(String fieldName) {

        for (Pattern pattern : excludedFieldPatterns) {
            Matcher matcher = pattern.matcher(fieldName);
            if (matcher.matches()) {
                return true;
            }
        }
        return false;
    }

    /**
     * @param message
     * @param fullyQualifiedFieldName
     * @param expectedArray
     * @param actualArray
     * @throws Exception
     */
    private void compareArrays(String message, String fullyQualifiedFieldName,
        Object[] expectedArray, Object[] actualArray)
        throws IllegalAccessException {

        org.junit.Assert.assertEquals(message + ".length",
            expectedArray.length, actualArray.length);

        for (int i = 0; i < expectedArray.length; i++) {
            Object expectedElement = expectedArray[i];
            Object actualElement = actualArray[i];

            compareObjects(message + "[" + i + "]", fullyQualifiedFieldName,
                expectedElement, actualElement);
        }
    }

    /**
     * @param message
     * @param fullyQualifiedFieldName
     * @param expectedCollection
     * @param actualCollection
     * @throws Exception
     */
    private void compareCollections(String message,
        String fullyQualifiedFieldName, Collection<?> expectedCollection,
        Collection<?> actualCollection) throws IllegalAccessException {

        org.junit.Assert.assertEquals(message + ".size()",
            expectedCollection.size(), actualCollection.size());

        Iterator<?> expectedIterator = expectedCollection.iterator();
        Iterator<?> actualIterator = actualCollection.iterator();
        int index = 0;

        while (expectedIterator.hasNext()) {
            Object expectedElement = expectedIterator.next();
            Object actualElement = actualIterator.next();

            compareObjects(message + "[" + index + "]",
                fullyQualifiedFieldName, expectedElement, actualElement);
            index++;
        }
    }

    /**
     * @param message
     * @param fullyQualifiedFieldName
     * @param expectedMap
     * @param actualMap
     * @throws Exception
     */
    private void compareMaps(String message, String fullyQualifiedFieldName,
        Map<?, ?> expectedMap, Map<?, ?> actualMap)
        throws IllegalAccessException {

        org.junit.Assert.assertEquals(message + ".size()", expectedMap.size(),
            actualMap.size());

        Iterator<?> expectedKeyIterator = expectedMap.keySet()
            .iterator();

        while (expectedKeyIterator.hasNext()) {
            Object key = expectedKeyIterator.next();
            Object expectedValue = expectedMap.get(key);
            Object actualValue = actualMap.get(key);

            compareObjects(message + "(" + key + ")", fullyQualifiedFieldName,
                expectedValue, actualValue);
        }
    }
}
