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

import static gov.nasa.spiffy.common.persistable.PersistableUtils.hasAnnotation;
import static gov.nasa.spiffy.common.persistable.PersistableUtils.isArray;
import static gov.nasa.spiffy.common.persistable.PersistableUtils.isPrimitiveArray;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.IOException;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Base class for all {@link Persistable} readers. Used for serialization of
 * {@link Persistable} classes.
 * 
 * @author tklaus
 * 
 */
public abstract class PersistableInputStream {
    static final Log log = LogFactory.getLog(PersistableInputStream.class);

    protected abstract char readChar() throws IOException;

    protected abstract byte readByte() throws IOException;

    protected abstract short readShort() throws IOException;

    protected abstract int readInt() throws IOException;

    protected abstract long readLong() throws IOException;

    protected abstract float readFloat() throws IOException;

    protected abstract double readDouble() throws IOException;

    protected abstract String readString() throws IOException;

    protected abstract Date readDate() throws Exception;

    protected abstract <T extends Enum<T>> T readEnum(Class<T> clazz)
        throws IOException;

    protected abstract boolean readBoolean() throws IOException;

    /**
     * Loads a {@link Persistable} object.
     * 
     * @param object
     * @throws Exception
     */
    public void load(Object object) throws Exception {
        if (object == null) {
            throw new IllegalArgumentException("object cannot be null.");
        }

        // include all superclasses, as long as they are Persistable
        Class<?> hClazz = object.getClass();
        Stack<Class<?>> hierarchy = PersistableUtils.classHierarchy(hClazz);

        while (!hierarchy.isEmpty()) {
            hClazz = hierarchy.pop();

            boolean ignoreAllStatics = hasAnnotation(hClazz,
                ProxyIgnoreStatics.class);

            Field[] fields = hClazz.getDeclaredFields();
            for (int i = 0; i < fields.length; i++) {
                Field field = fields[i];

                if (!PersistableUtils.isIgnored(field, ignoreAllStatics)) {
                    field.setAccessible(true);
                    Class<?> fieldClass = field.getType();
                    Object value;
                    if (isPrimitiveArray(fieldClass)) {
                        value = loadPrimitiveArray(fieldClass, field);
                    } else if (isArray(fieldClass)) {
                        value = loadArray(fieldClass, field);
                    } else if (java.util.List.class.isAssignableFrom(fieldClass)) {
                        Class<?> containerClass = ArrayList.class;

                        ProxyInfo ann = field.getAnnotation(ProxyInfo.class);
                        if (ann != null) {
                            containerClass = Class.forName(ann.containerClass());
                        }

                        ContainerAttributes listAttrs = PersistableUtils.determineListAttributes(field);

                        List<?> list = (List<?>) containerClass.newInstance();
                        loadList(list, listAttrs.elementClass,
                            listAttrs.dimensions);
                        value = list;
                    } else if (java.util.Set.class.isAssignableFrom(fieldClass)) {
                        Class<?> containerClass = HashSet.class;

                        ProxyInfo ann = field.getAnnotation(ProxyInfo.class);
                        if (ann != null) {
                            containerClass = Class.forName(ann.containerClass());
                        }

                        ContainerAttributes setAttrs = PersistableUtils.determineSetAttributes(field);

                        Set<?> set = (Set<?>) containerClass.newInstance();
                        loadSet(set, setAttrs.elementClass);
                        value = set;
                    } else if (java.util.Map.class.isAssignableFrom(fieldClass)) {
                        Class<?> containerClass = HashMap.class;

                        ProxyInfo ann = field.getAnnotation(ProxyInfo.class);
                        if (ann != null) {
                            containerClass = Class.forName(ann.containerClass());
                        }

                        Pair<ContainerAttributes, ContainerAttributes> mapAttrs = PersistableUtils.determineMapAttributes(field);

                        Map<?, ?> map = (Map<?, ?>) containerClass.newInstance();
                        loadMap(map, mapAttrs.left.elementClass,
                            mapAttrs.right.elementClass);
                        value = map;
                    } else if (Persistable.class.isAssignableFrom(fieldClass)) {
                        value = fieldClass.newInstance();
                        load(value);
                    } else {
                        value = loadPrimitive(fieldClass, field);
                    }

                    boolean isFinal = Modifier.isFinal(field.getModifiers());
                    if (!isFinal) {
                        field.set(object, value);
                    }
                }
            }
        }
    }

    /**
     * Initialize a List field before loading the contents
     * 
     * @param containingObject
     * @param field
     * @throws Exception
     */
    public void loadList(List<?> list, Class<?> elementClazz, int dimensions)
        throws Exception {
        // due to the way java 5 implements generics (with erasure),
        // we are just creating ListType<E>, not a list of a specific type
        loadListComponent(list, elementClazz, dimensions);
    }

    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void loadSet(Set set, Class<?> keyClass) throws Exception {
        int length = readInt();
        for (int i = 0; i < length; i++) {
            Object key = keyClass.newInstance();

            if (keyClass.getName()
                .endsWith("String")) {
                key = readString();
            } else {
                load(key);
            }

            set.add(key);
        }
    }

    /**
     * Load a Map field
     * 
     * @param containingObject
     * @param field
     * @throws Exception
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    public void loadMap(Map map, Class<?> keyClass, Class<?> valueClass)
        throws Exception {
        int length = readInt();

        for (int i = 0; i < length; i++) {
            Object key = keyClass.newInstance();
            Object value = valueClass.newInstance();

            if (keyClass.getName()
                .endsWith("String")) {
                key = readString();
            } else {
                load(key);
            }

            if (valueClass.getName()
                .endsWith("String")) {
                value = readString();
            } else {
                load(value);
            }

            map.put(key, value);
        }
    }

    private Object loadPrimitiveArray(Class<?> clazz, Field field)
        throws IOException {
        final int length = readInt();
        Object object = Array.newInstance(clazz.getComponentType(), length);
        if (ArrayUtils.EMPTY_BOOLEAN_ARRAY.getClass() == clazz) {
            boolean[] data = (boolean[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readBoolean();
            }
        } else if (ArrayUtils.EMPTY_BYTE_ARRAY.getClass() == clazz) {
            // TODO: The underlying stream should really support some kind
            // of direct byte array read.
            byte[] data = (byte[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readByte();
            }
        } else if (ArrayUtils.EMPTY_DOUBLE_ARRAY.getClass() == clazz) {
            boolean oracleDouble = hasAnnotation(field,
                gov.nasa.spiffy.common.persistable.OracleDouble.class);
            double[] data = (double[]) object;
            for (int i = 0; i < length; i++) {
                if (oracleDouble) {
                    data[i] = OracleDouble.valueOf(readDouble());
                } else {
                    data[i] = readDouble();
                }
            }
        } else if (ArrayUtils.EMPTY_FLOAT_ARRAY.getClass() == clazz) {
            float[] data = (float[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readFloat();
            }
        } else if (ArrayUtils.EMPTY_INT_ARRAY.getClass() == clazz) {
            int[] data = (int[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readInt();
            }
        } else if (ArrayUtils.EMPTY_LONG_ARRAY.getClass() == clazz) {
            long[] data = (long[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readLong();
            }
        } else if (ArrayUtils.EMPTY_SHORT_ARRAY.getClass() == clazz) {
            short[] data = (short[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readShort();
            }
        } else if (ArrayUtils.EMPTY_CHAR_ARRAY.getClass() == clazz) {
            char[] data = (char[]) object;
            for (int i = 0; i < length; i++) {
                data[i] = readChar();
            }
        } else {
            throw new IllegalStateException("Class \"" + clazz
                + "\" is not a primitive array.");
        }

        return object;
    }

    /**
     * Initialize an array field before loading the contents
     * 
     * @param containingObject
     * @param field
     * @throws Exception
     */
    public Object loadArray(Class<?> clazz, Field field) throws Exception {
        int length = readInt();
        Object array = Array.newInstance(clazz.getComponentType(), length);
        populateArray(array, field);
        return array;
    }

    private void populateArray(Object array, Field field) throws Exception {

        Class<?> componentType = array.getClass()
            .getComponentType();
        Class<?> nestedComponentType = componentType.getComponentType();

        int length = Array.getLength(array);

        for (int i = 0; i < length; i++) {
            if (componentType.isArray()) {
                int nestedLength = readInt();
                Object nestedArray = Array.newInstance(nestedComponentType,
                    nestedLength);
                Array.set(array, i, nestedArray);
                populateArray(nestedArray, field);
            } else {
                Object arrayElement = null;
                if (Persistable.class.isAssignableFrom(componentType)) {
                    arrayElement = componentType.newInstance();
                    load(arrayElement);
                } else {
                    arrayElement = loadPrimitive(componentType, field);
                }
                Array.set(array, i, arrayElement);
            }
        }
    }

    @SuppressWarnings({ "unchecked", "rawtypes" })
    private void loadListComponent(List list, Class<?> componentType,
        int dimensions) throws Exception {
        int length = readInt();

        if (dimensions > 1) {
            for (int i = 0; i < length; i++) {
                // due to the way java 5 implements generics (with erasure),
                // we are just creating ListType<E>, not a list of a specific
                // type
                List<?> innerList = list.getClass()
                    .newInstance();
                list.add(innerList);
                loadListComponent(innerList, componentType, dimensions - 1);
            }
        } else {
            populateList(list, length, componentType);
        }
    }

    @SuppressWarnings({ "unchecked", "rawtypes" })
    private void populateList(List list, int length, Class<?> componentType)
        throws Exception {
        for (int i = 0; i < length; i++) {
            Object arrayElement = componentType.newInstance();
            if (componentType.equals(String.class)) {
                arrayElement = readString();
            } else {
                load(arrayElement);
            }
            list.add(arrayElement);
        }
    }

    private Object loadPrimitive(Class<?> clazz, Field field) throws Exception {
        Object result = null;

        if (clazz == int.class) {
            result = Integer.valueOf(readInt());
            if (log.isDebugEnabled() && field.getName()
                .equalsIgnoreCase("keplerid")) {
                log.debug(String.format("%s: %d\n", field.getName(), result));
            }
        } else if (clazz == long.class) {
            result = Long.valueOf(readLong());
        } else if (clazz == short.class) {
            result = Short.valueOf(readShort());
        } else if (clazz == byte.class) {
            result = Byte.valueOf(readByte());
        } else if (clazz == double.class) {
            if (hasAnnotation(field,
                gov.nasa.spiffy.common.persistable.OracleDouble.class)) {
                result = OracleDouble.valueOf(readDouble());
            } else {
                result = Double.valueOf(readDouble());
            }
            if (log.isDebugEnabled() && Double.isNaN((Double) result)) {
                log.debug(String.format("%s: Double.isNaN(%e)\n",
                    field.getName(), result));
            }
        } else if (clazz == float.class) {
            result = Float.valueOf(readFloat());
            if (log.isDebugEnabled() && Float.isNaN((Float) result)) {
                log.debug(String.format("%s: Float.isNaN(%e)\n",
                    field.getName(), result));
            }
        } else if (clazz == boolean.class) {
            result = Boolean.valueOf(readBoolean());
        } else if (clazz == String.class) {
            result = readString();
        } else if (clazz == Date.class) {
            result = readDate();
        } else if (Enum.class.isAssignableFrom(clazz)) {
            @SuppressWarnings({ "unchecked", "rawtypes" })
            Class<? extends Enum> c = (Class<? extends Enum<?>>) clazz;
            @SuppressWarnings("unchecked")
            Object o = readEnum(c);
            result = o;
        } else if (clazz == char.class) {
            result = Character.valueOf(readChar());
        } else {
            throw new IOException("not a primitive! class=" + clazz);
        }

        return result;
    }

    private static final class OracleDouble {
        public static final int MIN_EXPONENT = -431;
        public static final int MAX_EXPONENT = 417;
        public static final double MIN_VALUE = -1e125;
        public static final double MAX_VALUE = 1e125;
        public static final double SMALLEST_NEGATIVE_VALUE = -1e-129;
        public static final double SMALLEST_POSITIVE_VALUE = 1e-130;

        public static final Double valueOf(double value) {
            double oracleDouble = value;

            if (log.isDebugEnabled()) {
                log.debug(String.format("OracleDouble(%g)", oracleDouble));
            }
            if (Math.getExponent(value) < MIN_EXPONENT) {
                if (value > 0) {
                    oracleDouble = SMALLEST_POSITIVE_VALUE;
                } else if (value < 0) {
                    oracleDouble = SMALLEST_NEGATIVE_VALUE;
                }
            } else if (Math.getExponent(value) > MAX_EXPONENT) {
                if (value > 0) {
                    oracleDouble = MAX_VALUE;
                } else if (value < 0) {
                    oracleDouble = MIN_VALUE;
                }
            }
            if (log.isDebugEnabled()) {
                log.debug(String.format("OracleDouble(%g) = %g", value,
                    oracleDouble));
            }
            return Double.valueOf(oracleDouble);
        }
    }
}
