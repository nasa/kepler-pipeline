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

import java.lang.reflect.Field;
import java.lang.reflect.Modifier;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.Stack;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class uses java reflection to walk through a class hierarchy. It invokes
 * all registered WalkerListeners to notify them of each class and each field
 * within that class that it finds.
 * 
 * Only Java primitives, java.lang.String, java.lang.Enum, java.util.Date,
 * and, if enforcePersistable == true, classes that implement the {@link Persistable} 
 * interface are supported as base types. Also supported are arrays, java.util.List 
 * and java.util.Map collections of these base types. Any other types found will result 
 * in the unknownType callback being called (see below). 
 * 
 * @author Todd Klaus
 * 
 */
public class ClassWalker {
    private static final Log log = LogFactory.getLog(ClassWalker.class);

    private Class<?> rootClass = null;

    private LinkedList<WalkerListener> listeners = new LinkedList<WalkerListener>();

    private HashSet<String> reportedClasses = new HashSet<String>();

    private Stack<String> currentClassName = new Stack<String>();
    private Stack<String> currentFieldName = new Stack<String>();
    private Stack<Boolean> currentProxyIgnoreStaticsState = new Stack<Boolean>();

    private boolean enforcePersistable = true;
    private boolean ignoreStaticsDefault = false;
    
    public ClassWalker(Class<?> rootClass) {
        this.rootClass = rootClass;
    }

    public ClassWalker(Class<?> rootClass, boolean enforcePersistable, boolean ignoreStaticsDefault) {
        this.rootClass = rootClass;
        this.enforcePersistable = enforcePersistable;
        this.ignoreStaticsDefault = ignoreStaticsDefault;
    }

    public void addListener(WalkerListener listener) {
        listeners.add(listener);
    }

    public void removeListener(WalkerListener listener) {
        listeners.remove(listener);
    }

    /**
     * Main entry point. All callbacks made to registered WalkerListeners are
     * made in the context of this method.
     * 
     * @throws Exception
     */
    public void parse() throws Exception {
        try {
            parseClass(rootClass);
        } catch (Exception e) {
            log.error("Caught an exception parsing classes, class stack is as follows:");
            for (String className : currentClassName) {
                log.error("class: " + className);
            }
            throw e;
        }
    }

    /**
     * Parse an individual class in the hierarchy
     * 
     * @param clazz
     * @throws Exception
     */
    private void parseClass(Class<?> clazz) throws Exception {

        fireClassStart(clazz);

        // include all superclasses, as long as they are Persistable (if enforcePersistable)
        Class<?> hClazz = clazz;
        Stack<Class<?>> hierarchy = PersistableUtils.classHierarchy(hClazz, enforcePersistable);
        
        while (!hierarchy.isEmpty()) {
            hClazz = hierarchy.pop();
            currentClassName.push(hClazz.getSimpleName());

            log.debug("processing class = " + hClazz.getName());

            boolean ignoreStatics = ignoreStaticsDefault || hasAnnotation(hClazz, ProxyIgnoreStatics.class);
            currentProxyIgnoreStaticsState.push(ignoreStatics);

            Field[] fields = hClazz.getDeclaredFields();
            for (int i = 0; i < fields.length; i++) {
                if (Modifier.isTransient(fields[i].getModifiers())) {
                    log.debug("skipping field = " + fields[i] + " because it is transient");
                } else {
                    parseField(fields[i]);
                }
            }
            currentClassName.pop();
            currentProxyIgnoreStaticsState.pop();
        }

        fireClassEnd(clazz);
    }

    private boolean isProxyIgnoreStatics(){
        if(!currentProxyIgnoreStaticsState.isEmpty()){
            return currentProxyIgnoreStaticsState.peek();
        }else{
            return false;
        }
    }
    
    /**
     * Parse an individual field in a class
     * 
     * @param field
     * @throws Exception
     */
    private void parseField(Field field) throws Exception {

        if(field.getAnnotation(ProxyIgnore.class) != null){
            // ignore this field
            log.debug("Ignoring field because ProxyIgnore annotation is present, f = " + field);
            return;
        }
        
        if((Modifier.isStatic(field.getModifiers()) && isProxyIgnoreStatics())){
            // ignore this field
            log.debug("Ignoring static field because ProxyIgnoreStatics annotation is present, f = " + field);
            return;
        }

        Class<?> fieldClass = field.getType();
        
        int dimensions = 0;
        ProxyInfo ann = field.getAnnotation(ProxyInfo.class);
        String elementClassSimpleName = null; // elements of Lists
        currentFieldName.push(fieldClass.getSimpleName());

        boolean preservePrecision = false;
        if(ann != null){
            preservePrecision = ann.preservePrecision();
        }

        // allow us to access the value of private fields
        field.setAccessible(true); 

        if (fieldClass.isArray()) {
            // arrays of primitives, Strings, Enum, Date, or Persistable
            Class<?> elementClass = fieldClass;
            while (elementClass.isArray()) {
                dimensions++;
                elementClass = elementClass.getComponentType();
            }
            elementClassSimpleName = elementClass.getSimpleName();

            if(Enum.class.isAssignableFrom(elementClass)){
                elementClassSimpleName = "Enum";
            }
            
            if (isPrimitive(elementClass)) {
                firePrimitiveArrayField(field.getName(), elementClassSimpleName, dimensions, field, preservePrecision);
            } else if (Persistable.class.isAssignableFrom(elementClass)) {
                fireClassArrayField(field, elementClass, dimensions);

                parseNestedClassIfNecessary(elementClass);
            } else {
                fireUnknownType(field);
            }
        } else if (java.util.List.class.isAssignableFrom(fieldClass)) {
            ContainerAttributes listAttrs = PersistableUtils.determineListAttributes(field, enforcePersistable);

            if (listAttrs.elementClass.isPrimitive()) {
                throw new Exception(exceptionMessage("Collections of primitives not supported (try using an array)"));
            }

            if (!enforcePersistable || Persistable.class.isAssignableFrom(listAttrs.elementClass)) {

                elementClassSimpleName = listAttrs.elementClass.getSimpleName();

                fireClassArrayField(field, listAttrs.elementClass, listAttrs.dimensions);

                parseNestedClassIfNecessary(listAttrs.elementClass);
            } else {
                fireUnknownType(field);
            }
        } else if (isPrimitive(fieldClass)) {

            if(Enum.class.isAssignableFrom(fieldClass)){
                firePrimitiveField(field.getName(), "Enum", field, preservePrecision);
            }else{
                firePrimitiveField(field.getName(), fieldClass.getSimpleName(), field, preservePrecision);
            }
        } else if (!enforcePersistable || Persistable.class.isAssignableFrom(fieldClass)) {

            fireClassField(field);

            parseNestedClassIfNecessary(fieldClass);
        } else {
            fireUnknownType(field);
        }
        
        currentFieldName.pop();
    }

    /**
     * Returns true if the specified class is a java primitive,
     * a primitive wrapper class (Integer, Float, etc.), String,
     * or an enumerated type (extends Enum).
     * 
     * @param fieldClass
     * @return
     */
    private boolean isPrimitive(Class<?> fieldClass) {
        if(
            fieldClass.isPrimitive() ||
            String.class.isAssignableFrom(fieldClass) ||
            Enum.class.isAssignableFrom(fieldClass) ||
            fieldClass == java.util.Date.class ||
            fieldClass == Boolean.class ||
            fieldClass == Byte.class ||
            fieldClass == Short.class ||
            fieldClass == Integer.class ||
            fieldClass == Long.class ||
            fieldClass == Float.class ||
            fieldClass == Double.class ||
            fieldClass == Character.class){
            
            return true;
        }else{
            return false;
        }
    }

    /**
     * Parses a nested class in the hierarchy if it has not already been parsed.
     * 
     * @param clazz
     * @throws Exception
     */
    private void parseNestedClassIfNecessary(Class<?> clazz) throws Exception {
        String canonicalClassName = clazz.getCanonicalName();
        if (!reportedClasses.contains(canonicalClassName)) {
            reportedClasses.add(canonicalClassName);
            parseClass(clazz);
        }
    }

    private String exceptionMessage(String error) {
        StringBuilder sb = new StringBuilder(error);
        sb.append("class: ").append(currentClassName.peek()).append(", field: ").append(currentFieldName.peek());
        return sb.toString();
    }

    /**
     * 
     * @param simpleName
     * @param canonicalName
     * @throws Exception
     */
    private void fireClassStart(Class<?> clazz) throws Exception {
        for (WalkerListener listener : listeners) {
            listener.classStart(clazz);
        }
    }

    /**
     * 
     * @param simpleName
     * @param canonicalName
     * @throws Exception
     */
    private void fireClassEnd(Class<?> clazz) throws Exception {
        for (WalkerListener listener : listeners) {
            listener.classEnd(clazz);
        }
    }

    /**
     * 
     * @param name
     * @param type
     * @throws Exception
     */
    private void firePrimitiveField(String name, String type, Field field, boolean preservePrecision) throws Exception {
        for (WalkerListener listener : listeners) {
            listener.primitiveField(name, type, field, preservePrecision);
        }
    }

    /**
     * 
     * @param name
     * @param type
     * @param dimensions
     * @throws Exception
     */
    private void firePrimitiveArrayField(String name, String type, int dimensions, Field field,
        boolean preservePrecision) throws Exception {
        for (WalkerListener listener : listeners) {
            listener.primitiveArrayField(name, type, dimensions, field, preservePrecision);
        }
    }

    /**
     * 
     * @param name
     * @param type
     * @throws Exception
     */
    private void fireClassField(Field field) throws Exception {
        for (WalkerListener listener : listeners) {
            listener.classField(field);
        }
    }

    /**
     * 
     * @param name
     * @param type
     * @param dimensions
     * @throws Exception
     */
    private void fireClassArrayField(Field field, Class<?> elementClazz, int dimensions) throws Exception {
        for (WalkerListener listener : listeners) {
            listener.classArrayField(field, elementClazz, dimensions);
        }
    }

    /**
     * 
     * @param simpleName
     * @param canonicalName
     * @throws Exception
     */
    private void fireUnknownType(Field field) throws Exception {
        log.warn(exceptionMessage("Unknown type found while processing: "));

        for (WalkerListener listener : listeners) {
            listener.unknownType(field);
        }
    }
}
