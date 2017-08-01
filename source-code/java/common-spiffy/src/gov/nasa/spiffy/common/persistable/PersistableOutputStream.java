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

import java.io.IOException;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Stack;

import org.apache.commons.lang.ArrayUtils;

/**
 * Base class for all {@link Persistable} writers. Used for serialization of
 * {@link Persistable} classes.
 * 
 * @author tklaus
 * 
 */
public abstract class PersistableOutputStream {
    protected abstract void writeBoolean(String fieldName, boolean v)
        throws IOException;

    protected abstract void writeByte(String fieldName, byte v)
        throws IOException;

    protected abstract void writeDouble(String fieldName, double v)
        throws IOException;

    protected abstract void writeFloat(String fieldName, float v)
        throws IOException;

    protected abstract void writeInt(String fieldName, int v)
        throws IOException;

    protected abstract void writeLong(String fieldName, long v)
        throws IOException;

    protected abstract void writeShort(String fieldName, short v)
        throws IOException;

    protected abstract void writeChar(String fieldName, char v)
        throws IOException;

    protected abstract void writeBooleanArray(String fieldName, boolean[] v)
        throws IOException;

    protected abstract void writeByteArray(String fieldName, byte[] v)
        throws IOException;

    protected abstract void writeDoubleArray(String fieldName, double[] v)
        throws IOException;

    protected abstract void writeFloatArray(String fieldName, float[] v)
        throws IOException;

    protected abstract void writeIntArray(String fieldName, int[] v)
        throws IOException;

    protected abstract void writeLongArray(String fieldName, long[] v)
        throws IOException;

    protected abstract void writeShortArray(String fieldName, short[] v)
        throws IOException;

    protected abstract void writeCharArray(String fieldName, char[] v)
        throws IOException;

    protected abstract void writeString(String fieldName, String v)
        throws IOException;

    protected abstract void writeDate(String fieldName, Date v)
        throws IOException;

    protected abstract void writeEnum(String fieldName, Enum<?> v)
        throws IOException;

    protected abstract void beginNonPrimitiveArray(String fieldName,
        Class<?> clazz, int length) throws IOException;

    protected abstract void endNonPrimitiveArray(String fieldName)
        throws IOException;

    protected abstract void beginClass(String fieldName,
        Class<? extends Object> clazz) throws IOException;

    protected abstract void endClass(String fieldName) throws IOException;

    protected abstract void saveEmpty(String fieldName) throws IOException;

    protected abstract void saveEmptyPrimitive(Class<?> clazz,
        String fieldName, String containingClassName) throws IOException;

    private final boolean enforcePersistable;
    private final boolean ignoreStaticsDefault;

    public PersistableOutputStream() {
        this(true, false);
    }

    public PersistableOutputStream(boolean enforcePersistable,
        boolean ignoreStaticsDefault) {
        this.enforcePersistable = enforcePersistable;
        this.ignoreStaticsDefault = ignoreStaticsDefault;
    }

    /**
     * Saves an object tree.
     */
    public void save(Object rootObject) throws Exception {
        if (rootObject == null) {
            throw new IllegalArgumentException("rootObject cannot be null");
        }

        saveObject(rootObject, rootObject.getClass(), null);
    }

    /**
     * Saves an object.
     */
    private void saveObject(Object object, Class<?> clazz, String fieldName)
        throws Exception {
        if (ArrayUtils.EMPTY_BOOLEAN_ARRAY.getClass() == clazz) {
            writeBooleanArray(fieldName, (boolean[]) object);
        } else if (ArrayUtils.EMPTY_BYTE_ARRAY.getClass() == clazz) {
            writeByteArray(fieldName, (byte[]) object);
        } else if (ArrayUtils.EMPTY_DOUBLE_ARRAY.getClass() == clazz) {
            writeDoubleArray(fieldName, (double[]) object);
        } else if (ArrayUtils.EMPTY_FLOAT_ARRAY.getClass() == clazz) {
            writeFloatArray(fieldName, (float[]) object);
        } else if (ArrayUtils.EMPTY_INT_ARRAY.getClass() == clazz) {
            writeIntArray(fieldName, (int[]) object);
        } else if (ArrayUtils.EMPTY_LONG_ARRAY.getClass() == clazz) {
            writeLongArray(fieldName, (long[]) object);
        } else if (ArrayUtils.EMPTY_SHORT_ARRAY.getClass() == clazz) {
            writeShortArray(fieldName, (short[]) object);
        } else if (ArrayUtils.EMPTY_CHAR_ARRAY.getClass() == clazz) {
            writeCharArray(fieldName, (char[]) object);
        } else if (isArray(clazz)) {
            saveClassArray(fieldName, object);
        } else if (java.util.List.class.isAssignableFrom(clazz)) {
            saveList(fieldName, object);
        } else if (java.util.Set.class.isAssignableFrom(clazz)) {
            saveSet(fieldName, object);
        } else if (java.util.Map.class.isAssignableFrom(clazz)) {
            saveMap(fieldName, object);
        } else if (Persistable.class.isAssignableFrom(clazz)) {
            saveClass(fieldName, object);
        } else if (isPrimitive(clazz)) {
            savePrimitive(fieldName, object);
        } else {
            if (enforcePersistable) {
                throw new IllegalArgumentException("Unexpected class: " + clazz);
            } else {
                saveClass(fieldName, object);
            }
        }
    }

    /**
     * Save a single Persistable
     * 
     * @param object
     * @throws Exception
     */
    private void saveClass(String fieldName, Object object) throws Exception {

        beginClass(fieldName, object.getClass());

        // include all superclasses, as long as they are Persistable (if
        // enforcePersistable)
        Class<?> hClazz = object.getClass();
        Stack<Class<?>> hierarchy = PersistableUtils.classHierarchy(hClazz,
            enforcePersistable);

        while (!hierarchy.isEmpty()) {
            hClazz = hierarchy.pop();

            boolean ignoreAllStatics = ignoreStaticsDefault
                || hasAnnotation(hClazz, ProxyIgnoreStatics.class);

            Field[] fields = hClazz.getDeclaredFields();
            for (Field field : fields) {
                if (!PersistableUtils.isIgnored(field, ignoreAllStatics)) {
                    field.setAccessible(true);
                    Object o = field.get(object);
                    if (o == null) {
                        throw new IllegalArgumentException(
                            "field cannot be null." + "\n  class: "
                                + hClazz.getName() + "\n  field: "
                                + field.getName());
                    }
                    saveObject(o, field.getType(), field.getName());
                }
            }
        }

        endClass(fieldName);
    }

    /**
     * Save an array
     * 
     * @param object
     * @param field
     * @throws Exception
     */
    private void saveClassArray(String fieldName, Object object)
        throws Exception {
        int length = Array.getLength(object);
        if (length == 0) {
            saveEmpty(fieldName);
        } else {
            Object firstElement = Array.get(object, 0);
            Class<?> c = firstElement.getClass();

            beginNonPrimitiveArray(fieldName, c, length);
            for (int i = 0; i < length; i++) {
                Object element = Array.get(object, i);
                saveObject(element, element.getClass(), fieldName);
            }
            endNonPrimitiveArray(fieldName);
        }
    }

    /**
     * Save a java.util.List
     * 
     * @param object
     * @throws Exception
     */
    private void saveList(String fieldName, Object object) throws Exception {
        List<?> list = (List<?>) object;
        int length = list.size();

        if (length == 0) {
            saveEmpty(fieldName);
        } else {
            Class<?> c = list.get(0)
                .getClass();

            beginNonPrimitiveArray(fieldName, c, length);
            for (Object element : list) {
                saveObject(element, element.getClass(), fieldName);
            }
            endNonPrimitiveArray(fieldName);
        }
    }

    /**
     * Save a java.util.Set
     * 
     * @param object
     * @throws Exception
     */
    private void saveSet(String fieldName, Object object) throws Exception {
        Set<?> set = (Set<?>) object;
        int length = set.size();

        if (length == 0) {
            saveEmpty(fieldName);
        } else {
            boolean first = true;
            for (Object element : set) {
                if (first) {
                    Class<?> c = element.getClass();

                    beginNonPrimitiveArray(fieldName, c, length);
                    first = false;
                }
                saveObject(element, element.getClass(), fieldName);
            }
            endNonPrimitiveArray(fieldName);
        }
    }

    /**
     * Save a java.util.Map
     * 
     * @param object
     * @throws Exception
     */
    private void saveMap(String fieldName, Object object) throws Exception {
        Map<?, ?> map = (Map<?, ?>) object;
        int length = map.size();

        if (length == 0) {
            saveEmpty(fieldName);
        } else {
            boolean first = true;

            for (Map.Entry<?, ?> entry : map.entrySet()) {
                Object value = entry.getValue();
                Object key = entry.getKey();

                if (first) {
                    Class<?> c = key.getClass();

                    beginNonPrimitiveArray(fieldName, c, length);
                    first = false;
                }

                saveObject(key, key.getClass(), fieldName);
                if (value != null) {
                    saveObject(value, value.getClass(), fieldName);
                } else {
                    throw new IllegalArgumentException("value cannot be null."
                        + "\n  key: " + key);
                }
            }
        }
    }

    private boolean isPrimitive(Class<?> clazz) {
        return (clazz == Integer.TYPE || clazz == Long.TYPE
            || clazz == Short.TYPE || clazz == Byte.TYPE
            || clazz == Double.TYPE || clazz == Float.TYPE
            || clazz == Boolean.TYPE || clazz == Character.TYPE
            || clazz == String.class || clazz == Date.class || Enum.class.isAssignableFrom(clazz));
    }

    /**
     * Save a primitive (including java.lang.String) Uses the abstract methods
     * for each primitive type (implemented by subclasses)
     * 
     * @param value
     * @throws IOException
     */
    private void savePrimitive(String fieldName, Object value)
        throws IOException {
        if (value instanceof Integer) {
            int v = ((Integer) value).intValue();
            writeInt(fieldName, v);
        } else if (value instanceof Long) {
            long v = ((Long) value).longValue();
            writeLong(fieldName, v);
        } else if (value instanceof Short) {
            short v = ((Short) value).shortValue();
            writeShort(fieldName, v);
        } else if (value instanceof Byte) {
            byte v = ((Byte) value).byteValue();
            writeByte(fieldName, v);
        } else if (value instanceof Double) {
            double dv = ((Double) value).doubleValue();
            writeDouble(fieldName, dv);
        } else if (value instanceof Float) {
            float fv = ((Float) value).floatValue();
            writeFloat(fieldName, fv);
        } else if (value instanceof Boolean) {
            boolean v = ((Boolean) value).booleanValue();
            writeBoolean(fieldName, v);
        } else if (value instanceof String) {
            String v = (String) value;
            writeString(fieldName, v);
        } else if (value instanceof Character) {
            char v = ((Character) value).charValue();
            writeChar(fieldName, v);
        } else if (value instanceof Date) {
            Date v = ((Date) value);
            writeDate(fieldName, v);
        } else if (value instanceof Enum<?>) {
            Enum<?> v = ((Enum<?>) value);
            writeEnum(fieldName, v);
        } else {
            throw new IOException("not a primitive! class=" + value.getClass());
        }
    }
}
