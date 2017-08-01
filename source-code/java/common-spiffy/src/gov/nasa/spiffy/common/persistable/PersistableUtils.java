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

import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.lang.annotation.Annotation;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Map;
import java.util.Stack;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Convenience wrappers around BinaryPersistableOutputStream and
 * BinaryPersistableInputStream.
 * 
 * Also contains some utility functions used by the serializers.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 */
public class PersistableUtils {
    private static final Log log = LogFactory.getLog(PersistableUtils.class);

    /**
     * Write the specified {@link Persistable} object to the specified file
     * using {@link BinaryPersistableOutputStream}
     * 
     * @param object
     * @param file
     */
    public static void readBinFile(Persistable object, String file) {
        readBinFile(object, new File(file));
    }

    /**
     * Write the specified {@link Persistable} object to the specified file
     * using {@link BinaryPersistableOutputStream}
     * 
     * @param object
     * @param file
     */
    public static void readBinFile(Persistable object, File file) {
        DataInputStream dis = null;
        try {
            FileInputStream fis = new FileInputStream(file);
            BufferedInputStream bis = new BufferedInputStream(fis);
            dis = new DataInputStream(bis);
            BinaryPersistableInputStream bpis = new BinaryPersistableInputStream(dis);
            bpis.load(object);
        } catch (Exception e) {
            throw new ModuleFatalProcessingException("failed to deserialize/read outputs file[" + file + "], e = " + e, e);
        } finally {
            if (dis != null) {
                try {
                    dis.close();
                } catch (IOException ignore) {
                    log.warn("failed to close " + file);
                }
            }
        }
    }

    /**
     * Read the specified {@link Persistable} object from the specified file
     * using {@link BinaryPersistableInputStream}
     * 
     * @param object
     * @param file
     */
    public static void writeBinFile(Persistable object, String file) {
        writeBinFile(object, new File(file));
    }

    /**
     * Write the specified {@link Persistable} object to the specified file
     * using {@link BinaryPersistableOutputStream}
     * 
     * @param object
     * @param file
     */
    public static void writeBinFile(Persistable object, File file) {
        writeBinFile(object, file, null);
    }

    /**
     * Write the specified {@link Persistable} object to the specified file
     * using {@link BinaryPersistableOutputStream}
     * 
     * @param object
     * @param file
     */
    public static void writeBinFile(Persistable object, File file, BinaryPersistableFilter filter) {
        DataOutputStream dos = null;

        try {
            FileOutputStream fos = new FileOutputStream(file);
            BufferedOutputStream bos = new BufferedOutputStream(fos);
            dos = new DataOutputStream(bos);
            BinaryPersistableOutputStream bpos = new BinaryPersistableOutputStream(dos, filter);
            bpos.save(object);
            dos.flush();
        } catch (Exception e) {
            throw new ModuleFatalProcessingException("failed to serialize/write inputs file[" + file + "], e = " + e, e);
        } finally {
            if (dos != null) {
                try {
                    dos.close();
                } catch (IOException ignore) {
                    log.warn("failed to close " + file);
                }
            }
        }
    }

    /**
     * Use reflection to iteratively dig into the nested List<> elements. The
     * iteration continues as long as type is a {@link ParameterizedType} and
     * the class is a List. The inner-most class must be {@link Persistable}
     * unless enforcePersistable == false.
     * The dimension is the number of iterations.
     * 
     * @param field
     * @return
     */
    public static ContainerAttributes determineListAttributes(Field field, boolean enforcePersistable) {
        ContainerAttributes listAttrs = determineParameterAttributes(field, java.util.List.class, 0, 20, enforcePersistable);

        return listAttrs;
    }

    /**
     * Use reflection to iteratively dig into the nested List<> elements. The
     * iteration continues as long as type is a {@link ParameterizedType} and
     * the class is a List. The inner-most class must be {@link Persistable}.
     * The dimension is the number of iterations.
     * 
     * @param field
     * @return
     */
    public static ContainerAttributes determineListAttributes(Field field) {
        return determineListAttributes(field, true);
    }

    /**
     * Use reflection to iteratively dig into the nested Map<> elements. The
     * iteration continues as long as type is a {@link ParameterizedType} and
     * the class is a Map. The inner-most class must be {@link Persistable}
     * unless enforcePersistable == false. The dimension is the number of iterations.
     * 
     * For Maps, the maxAllowedDimensions is 1, meaning that the key and/or
     * value types of the Map may not be a Map itself (no multi-dimensional
     * maps)
     * 
     * @param field
     * @return
     */
    public static Pair<ContainerAttributes, ContainerAttributes> determineMapAttributes(Field field, boolean enforcePersistable) {
        ContainerAttributes keyAttrs = determineParameterAttributes(field, java.util.Map.class, 0, 1, enforcePersistable);
        ContainerAttributes valueAttrs = determineParameterAttributes(field, java.util.Map.class, 1, 1, enforcePersistable);

        return Pair.of(keyAttrs, valueAttrs);
    }

    /**
     * Use reflection to iteratively dig into the nested Map<> elements. The
     * iteration continues as long as type is a {@link ParameterizedType} and
     * the class is a Map. The inner-most class must be {@link Persistable}. The
     * dimension is the number of iterations.
     * 
     * For Maps, the maxAllowedDimensions is 1, meaning that the key and/or
     * value types of the Map may not be a Map itself (no multi-dimensional
     * maps)
     * 
     * @param field
     * @return
     */
    public static Pair<ContainerAttributes, ContainerAttributes> determineMapAttributes(Field field) {
        return determineMapAttributes(field, true);
    }

    /**
     * Use reflection to iteratively dig into the nested Set<> elements. The
     * iteration continues as long as type is a {@link ParameterizedType} and
     * the class is a Set. The inner-most class must be {@link Persistable}
     * unless enforcePersistable == true. The dimension is the number of iterations.
     * 
     * @param field
     * @return
     */
    public static ContainerAttributes determineSetAttributes(Field field, boolean enforcePersistable) {
        ContainerAttributes listAttrs = determineParameterAttributes(field, java.util.Set.class, 0, 20, enforcePersistable);

        return listAttrs;
    }

    /**
     * Use reflection to iteratively dig into the nested Set<> elements. The
     * iteration continues as long as type is a {@link ParameterizedType} and
     * the class is a Set. The inner-most class must be {@link Persistable}. The
     * dimension is the number of iterations.
     * 
     * @param field
     * @return
     */
    public static ContainerAttributes determineSetAttributes(Field field) {
        return determineSetAttributes(field, true);
    }

    /**
     * Find all super-classes of the specified type, and verify that they are
     * all {@link Persistable} (unless enforcePersistable == false)
     * 
     * @param baseClass
     * @return
     */
    public static Stack<Class<?>> classHierarchy(Class<?> baseClass, boolean enforcePersistable) {
        Stack<Class<?>> hierarchy = new Stack<Class<?>>();
        Class<?> hClazz = baseClass;

        while (!isTopLevelClass(hClazz)) {
            if(enforcePersistable){
                if (Persistable.class.isAssignableFrom(hClazz)) {
                    hierarchy.push(hClazz);
                } else if (hClazz != java.lang.Object.class) {
                    /*
                     * Make sure that the class at the top of the hierarchy is
                     * Object
                     */
                    throw new PipelineException("Super-class does not implement Persistable: " + hClazz.getName());
                }
            }else{
                hierarchy.push(hClazz);
            }

            hClazz = hClazz.getSuperclass();
        }

        return hierarchy;
    }
    
    private static boolean isTopLevelClass(Class<?> c){
        if(c == null || 
            c == Object.class || 
            c == Boolean.class || 
            c == Byte.class || 
            c == Short.class || 
            c == Integer.class || 
            c == Long.class || 
            c == Float.class || 
            c == Double.class || 
            c == Character.class){
            return true;
        }else{
            return false;
        }
    }

    /**
     * Find all super-classes of the specified type, and verify that they are
     * all {@link Persistable}
     * 
     * @param baseClass
     * @return
     */
    public static Stack<Class<?>> classHierarchy(Class<?> baseClass) {
        return classHierarchy(baseClass, true);
    }

    /**
     * Use reflection to iteratively dig into the specified (by index) container
     * parameter. The iteration continues as long as type is a
     * {@link ParameterizedType} and the class is a container (List, Map, or
     * Set) of the specified {@link Class<?>}. The inner-most class must be
     * {@link Persistable}. The dimension is the number of iterations.
     * 
     * @param field
     * @return
     */
    private static ContainerAttributes determineParameterAttributes(Field field, Class<?> containerClass,
        int parameterIndex, int maxAllowedDimensions, boolean enforcePersistable) {
        ContainerAttributes parameterAttrs = new ContainerAttributes();

        Type type = field.getGenericType();
        Class<?> clazz;

        parameterAttrs.dimensions = 0;

        while (true) {
            if (type instanceof ParameterizedType) {
                ParameterizedType parameterizedType = (ParameterizedType) type;
                Type rawType = parameterizedType.getRawType();

                if (rawType instanceof Class<?>) {
                    clazz = (Class<?>) rawType;
                } else {
                    throw new PipelineException("Unexpected type, rawType is not Class<?>, rawType=" + rawType);
                }

                if (clazz == containerClass) {
                    parameterAttrs.dimensions++;
                } else {
                    if (!enforcePersistable || Persistable.class.isAssignableFrom(clazz)) {
                        // done
                        parameterAttrs.elementClass = clazz;
                        break;
                    } else {
                        throw new PipelineException("ElementClass does not implement Persistable, class=" + clazz);
                    }
                }
                type = parameterizedType.getActualTypeArguments()[parameterIndex];
            } else if (type instanceof Class<?>) {
                clazz = (Class<?>) type;
                if (parameterAttrs.dimensions == 0) {
                    // outer type is not a container!
                    throw new PipelineException("Outermost type is not the specified container type (" + containerClass
                        + "), class=" + clazz);
                } else {
                    if (!enforcePersistable || isElementClass(clazz)) {
                        // done
                        parameterAttrs.elementClass = clazz;
                        break;
                    } else {
                        throw new PipelineException("ElementClass does not implement Persistable, class=" + clazz);
                    }
                }
            } else {
                throw new PipelineException("Unexpected type = " + type);
            }

            if (parameterAttrs.dimensions > maxAllowedDimensions) {
                throw new PipelineException("Number of dimensions found (" + parameterAttrs.dimensions
                    + ") exceeds maxAllowedDimensions (" + maxAllowedDimensions + ")");
            }
        }

        return parameterAttrs;
    }

    /**
     * True if the specified class is one of the supported element classes
     * 
     * @param clazz
     * @return
     */
    private static boolean isElementClass(Class<?> clazz) {
        return ((clazz.isPrimitive()) || (clazz == java.lang.String.class) || (Persistable.class.isAssignableFrom(clazz)));
    }

    private static final ConcurrentMap<Class<?>, Boolean> isArrayCache = new ConcurrentHashMap<Class<?>, Boolean>();

    private static final ConcurrentMap<Class<?>, Map<Class<? extends Annotation>, Annotation>> annotationCache = new ConcurrentHashMap<Class<?>, Map<Class<? extends Annotation>, Annotation>>();

    private static final ConcurrentMap<Field, Map<Class<? extends Annotation>, Annotation>> fieldAnnotationCache = new ConcurrentHashMap<Field, Map<Class<? extends Annotation>, Annotation>>();

    public static boolean hasAnnotation(Field field, Class<? extends Annotation> a) {
        Map<Class<? extends Annotation>, Annotation> annoMap = fieldAnnotationCache.get(field);
        if (annoMap != null) {
            return annoMap.containsKey(a);
        }
        Annotation[] all = field.getAnnotations();
        annoMap = new HashMap<Class<? extends Annotation>, Annotation>();
        for (Annotation one : all) {
            annoMap.put(one.annotationType(), one);
        }
        fieldAnnotationCache.put(field, annoMap);
        return annoMap.containsKey(a);
    }

    public static boolean hasAnnotation(Class<?> clazz, Class<? extends Annotation> a) {
        Map<Class<? extends Annotation>, Annotation> annoMap = annotationCache.get(clazz);
        if (annoMap != null) {
            return annoMap.containsKey(a);
        }
        Annotation[] all = clazz.getAnnotations();
        annoMap = new HashMap<Class<? extends Annotation>, Annotation>();
        for (Annotation one : all) {
            annoMap.put(one.annotationType(), one);
        }
        annotationCache.putIfAbsent(clazz, annoMap);
        return annotationCache.get(clazz).containsKey(a);
    }

    /**
     * Uses cached information to determine if a class is an array.
     * 
     * @param clazz
     * @return
     */
    public static boolean isArray(Class<?> clazz) {
        Boolean cachedValue = isArrayCache.get(clazz);
        if (cachedValue != null) {
            return cachedValue;
        }
        isArrayCache.putIfAbsent(clazz, clazz.isArray());
        return isArrayCache.get(clazz);
    }

    /**
     * This method does not return true for all primitive arrays only those
     * which have an accelerated read/write method.
     * 
     * @param clazz
     * @param fieldName
     * @return
     */
    public static boolean isPrimitiveArray(Class<?> clazz) {
        if (ArrayUtils.EMPTY_BOOLEAN_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_BYTE_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_DOUBLE_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_FLOAT_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_INT_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_CHAR_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_LONG_ARRAY.getClass() == clazz) {
            return true;
        }
        if (ArrayUtils.EMPTY_SHORT_ARRAY.getClass() == clazz) {
            return true;
        }
        return false;
    }
    
    public static boolean isIgnored(Field field, boolean ignoreAllStatics) {
        boolean ignored = (ignoreAllStatics && Modifier.isStatic(field.getModifiers()))
            || (hasAnnotation(field, ProxyIgnore.class))
            || (Modifier.isTransient(field.getModifiers()));

        return ignored;
    }
}
