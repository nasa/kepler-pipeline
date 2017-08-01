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

package gov.nasa.spiffy.common.jmx;

import static javax.management.MBeanOperationInfo.UNKNOWN;

import java.lang.annotation.Annotation;
import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.management.Attribute;
import javax.management.AttributeList;
import javax.management.AttributeNotFoundException;
import javax.management.DynamicMBean;
import javax.management.InvalidAttributeValueException;
import javax.management.MBeanException;
import javax.management.MBeanInfo;
import javax.management.MBeanNotificationInfo;
import javax.management.ReflectionException;
import javax.management.openmbean.CompositeData;
import javax.management.openmbean.CompositeDataSupport;
import javax.management.openmbean.OpenDataException;
import javax.management.openmbean.OpenMBeanAttributeInfo;
import javax.management.openmbean.OpenMBeanAttributeInfoSupport;
import javax.management.openmbean.OpenMBeanConstructorInfo;
import javax.management.openmbean.OpenMBeanConstructorInfoSupport;
import javax.management.openmbean.OpenMBeanInfoSupport;
import javax.management.openmbean.OpenMBeanOperationInfo;
import javax.management.openmbean.OpenMBeanOperationInfoSupport;
import javax.management.openmbean.OpenMBeanParameterInfo;
import javax.management.openmbean.OpenMBeanParameterInfoSupport;
import javax.management.openmbean.OpenType;
import javax.management.openmbean.TabularData;
import javax.management.openmbean.TabularDataSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Reads the annotations on mbean interfaces to provide human readable
 * descriptions.  MBean implementations should wrap themselves in this
 * class.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class AnnotationMBean implements DynamicMBean {
    private static final Log log = LogFactory.getLog(AnnotationMBean.class);
    
    private final OpenMBeanInfoSupport mbeanInfo;
    
    private final Map<String, Method> accessorMethod = 
        new HashMap<String, Method>();
    private final Map<String,Method> operationMethod = 
        new HashMap<String,Method>();
    
    protected AnnotationMBean() {
        MBeanDescription mbeanDescription = 
            getClass().getAnnotation(MBeanDescription.class); 
        
        List<OpenMBeanAttributeInfo> attrInfoList = 
            new ArrayList<OpenMBeanAttributeInfo>();
        
        Method[] methods = getClass().getDeclaredMethods();
        for (Method m : methods) {
            AttributeDescription attrDescription =
                m.getAnnotation(AttributeDescription.class);
            
            if (attrDescription == null) {
                continue;
            }
            
            String prefix = null;
            if (m.getName().startsWith("get")) {
                prefix = "get";
            }
            if (m.getName().startsWith("is")) {
                prefix = "is";
            }
            if (prefix == null) {
                throw new IllegalArgumentException("Attribute must start with get or is.");
            }
            
            if (m.getParameterTypes().length != 0) {
                throw new IllegalArgumentException("Attribute must not take arguments.");
            }
            
            String attrName = m.getName().substring(prefix.length());
            OpenType<?> attrType = null;
            attrType = convertToOpenType(m.getReturnType());

            OpenMBeanAttributeInfo attrInfo = 
                new OpenMBeanAttributeInfoSupport(attrName,
                                                                            attrDescription.value(),
                                                                            attrType, true, false, 
                                                                            prefix.equals("is"));
            attrInfoList.add(attrInfo);
            addAttribute(attrName, m);
        }
        
        List<OpenMBeanOperationInfo> operationList =
            new ArrayList<OpenMBeanOperationInfo>();
        for (Method m : methods) {
            OperationDescription opDescription = 
                m.getAnnotation(OperationDescription.class);
            
            if (opDescription == null) {
                continue;
            }
            
            Annotation[][] allParameterAnnotations = m.getParameterAnnotations();      
            Class<?>[] parameterTypes = m.getParameterTypes();
            
            List<OpenMBeanParameterInfo> parameterList =
                new ArrayList<OpenMBeanParameterInfo>();
            
            for (int i=0; i < parameterTypes.length; i++) {
                OpenType<?> openType = convertToOpenType(parameterTypes[i]);

                ParameterDescription paramDescription = 
                    getParameterAnnotation(allParameterAnnotations[i], ParameterDescription.class);
                
                String name = paramDescription.name();
                String description = paramDescription.desc();
                OpenMBeanParameterInfo paramInfo = 
                    new OpenMBeanParameterInfoSupport(name,description, openType);
                parameterList.add(paramInfo);
            }
            
            OpenType<?> returnType = convertToOpenType(m.getReturnType());
            
            OpenMBeanParameterInfo[] paramArray =
                new OpenMBeanParameterInfo[parameterList.size()];
            parameterList.toArray(paramArray);
            OpenMBeanOperationInfo opInfo = 
                new OpenMBeanOperationInfoSupport(m.getName(), 
                                                                              opDescription.value(), 
                                                                              paramArray, returnType, 
                                                                              UNKNOWN);
            operationList.add(opInfo);
            addOperation(m.getName(), m);
            
        }
        
        List<OpenMBeanConstructorInfo> constructorList =
            new ArrayList<OpenMBeanConstructorInfo>();
        Constructor<?>[] constructors = getClass().getConstructors();
        for (Constructor<?> c : constructors) {
            ConstructorDescription constructorDescription = 
                c.getAnnotation(ConstructorDescription.class);
            
            if (constructorDescription == null) {
                continue;
            }
            
            List<OpenMBeanParameterInfo> paramList = new ArrayList<OpenMBeanParameterInfo>();
            Annotation[][] allParamAnnotations = c.getParameterAnnotations();
            Class<?>[] paramTypes = c.getParameterTypes();
            for (int i=0; i < paramTypes.length; i++) {
                OpenType<?> openType = convertToOpenType(paramTypes[i]);
                ParameterDescription paramDescription =
                    getParameterAnnotation(allParamAnnotations[i], ParameterDescription.class);
                String name = paramDescription.name();
                String description = paramDescription.desc();
                OpenMBeanParameterInfo paramInfoSupport = 
                    new OpenMBeanParameterInfoSupport(name, description, openType);
                paramList.add(paramInfoSupport);
            }
            
            OpenMBeanParameterInfo[] paramArray = new OpenMBeanParameterInfo[paramList.size()];
            paramList.toArray(paramArray);
            OpenMBeanConstructorInfo constructorInfo =
                new OpenMBeanConstructorInfoSupport(c.getName(), 
                             constructorDescription.value(), paramArray);
            constructorList.add(constructorInfo);
        }
        
        OpenMBeanAttributeInfo[] attrArray= new OpenMBeanAttributeInfo[attrInfoList.size()];
        attrInfoList.toArray(attrArray);
        OpenMBeanOperationInfo[] opArray = new OpenMBeanOperationInfo[operationList.size()];
        operationList.toArray(opArray);
        OpenMBeanConstructorInfo[] constructorArray = new OpenMBeanConstructorInfo[constructorList.size()];
        constructorList.toArray(constructorArray);
        
        mbeanInfo = new OpenMBeanInfoSupport(getClass().getName(), 
                                                                            mbeanDescription.value(),
                                                                            attrArray, 
                                                                            constructorArray,  
                                                                            opArray,
                                                                            new  MBeanNotificationInfo[0]);
        
    }
    
    @SuppressWarnings("unchecked")
    private static OpenType<?> convertToOpenType(Class<?> javaType) {
        if (TabularData.class.isAssignableFrom(javaType)) {
            try {
                return AutoTabularType.newAutoTabularType((Class<? extends TabularData>) javaType).tabularType();
            } catch (OpenDataException e) {
                throw new IllegalArgumentException("Can not calculate " +
                        "OpenType for TabularData \"" + javaType + "\".");
            }
        } else if (CompositeData.class.isAssignableFrom(javaType)) {
            try {
                return AutoCompositeType.newAutoCompositeType((Class<? extends CompositeData>) javaType).compositeType();
            } catch (OpenDataException e) {
                throw new IllegalArgumentException("Can not calculate OpenType.", e);
            }
        } else {
            OpenType<?> oType = AutoCompositeType.javaTypeToSimpleType.get(javaType);
            if (oType != null) {
                return oType;
            }
            
            throw new IllegalArgumentException("Java type can not be " +
                    "converted into OpenType.");
        }
    }

    @SuppressWarnings("unchecked")
    private static <T extends Annotation> T getParameterAnnotation(Annotation[] paramAnnotations, 
                                                                                             Class<T> annotation) {
        
        for (Annotation a : paramAnnotations) {
            if (a.annotationType() == annotation) {
                return (T)a;
            }
        }
        return null;
    }

    private void addAttribute(String attrName, Method attrMethod) {
        if (this.accessorMethod.containsKey(attrName)) {
            throw new IllegalArgumentException("Attribute names must be unique.");
        }
        accessorMethod.put(attrName, attrMethod);
    }
    
    /**
     * This does not allow multiple operaitons with the same name.
     * @param opName
     * @param opMethod
     */
    private void addOperation(String opName, Method opMethod) {
        if (this.operationMethod.containsKey(opName)) {
            throw new IllegalArgumentException("Operation name must be unique.");
        }
        operationMethod.put(opName, opMethod);
    }
    
    @Override
    public Object getAttribute(String attribute)
        throws AttributeNotFoundException, MBeanException, ReflectionException {
        Method m = accessorMethod.get(attribute);
        if (m == null) {
            throw new AttributeNotFoundException("Attribute \"" + attribute +
                "\" not found.");
        }
        try {
            Object rv = m.invoke(this, new Object[0]);
            rv  = convertReturnValue(rv);
            return rv;
        } catch (IllegalAccessException iae) {
            throw new ReflectionException(iae);
        } catch (InvocationTargetException ite) {
            throw new ReflectionException(ite);
        } catch (OpenDataException e) {
            throw new MBeanException(e);
        }
    }

    @Override
    public AttributeList getAttributes(String[] attributes) {
        AttributeList rv  = new AttributeList(attributes.length);
        for (String attrName : attributes) {
            Object attrValue;
            try {
                attrValue = getAttribute(attrName);
            } catch (AttributeNotFoundException e) {
                log.error("Failed to get attribute \"" + attrName + "\".", e);
                continue;
            } catch (MBeanException e) {
                log.error("Failed to get attribute \"" + attrName + "\".", e);
                continue;
            } catch (ReflectionException e) {
                log.error("Failed to get attribute \"" + attrName + "\".", e);
                continue;
            }
            Attribute attribute = new Attribute(attrName, attrValue);
            rv.add(attribute);
        }
        return rv;
    }

    @Override
    public MBeanInfo getMBeanInfo() {
        return mbeanInfo;
    }

    /**
     * This does not allow operations with the same name.
     */
    @Override
    public Object invoke(String actionName, Object[] params, String[] signature)
        throws MBeanException, ReflectionException {
        
        Method m = operationMethod.get(actionName);
        if (m == null) {
            throw new IllegalArgumentException("Operation \"" + actionName 
                                                                          + "\" does not exist.");
        }
        
        try {
            Object rv = m.invoke(this, params);
            return convertReturnValue(rv);
        } catch (IllegalArgumentException e) {
            throw new ReflectionException(e);
        } catch (IllegalAccessException e) {
            throw new ReflectionException(e);
        } catch (InvocationTargetException e) {
            throw new MBeanException(e);
        } catch (OpenDataException e) {
            throw new MBeanException(e);
        }
       
    }

    @Override
    public void setAttribute(Attribute attribute) throws AttributeNotFoundException, InvalidAttributeValueException, MBeanException, ReflectionException {
        Method m = accessorMethod.get(attribute.getName());
        if (m == null) {
            throw new AttributeNotFoundException("Attribute \"" + 
                attribute.getName() + "\" not found.");
        }
        
        throw new IllegalStateException("Not implemented.");
        
    }

    @Override
    public AttributeList setAttributes(AttributeList attributes) {
        throw new IllegalStateException("Not implemented.");
    }
    
    /**
     * Recursitely converts the specified value object into it's equivelent Support type
     * for CompositeData and TabularData objects.  This is needed because 
     * jconsole does not completely support OpenMBeans.
     * 
     * @param originalValue  The value of some OpenType.
     * @return The original value or CompositeDataSupport or TabularDataSupport.
     * @throws OpenDataException
     */
    private Object convertReturnValue(Object originalValue) throws OpenDataException {
        if (originalValue == null) {
            return null;
        }
        
        if (originalValue instanceof CompositeData) {
            CompositeData originalCompositeData = (CompositeData) originalValue;
            Map<String, Object> itemValues = new HashMap<String, Object>();
            for (String itemName : originalCompositeData.getCompositeType().keySet()) {
                Object value = convertReturnValue(originalCompositeData.get(itemName));
                itemValues.put(itemName, value);
            }
            
            CompositeDataSupport cSupport = 
                new CompositeDataSupport(originalCompositeData.getCompositeType(),
                                                             itemValues);
            return cSupport;
        }

        if (originalValue instanceof TabularData ) {
             TabularData originalTabularData = (TabularData) originalValue;
             TabularDataSupport tSupport = 
                 new TabularDataSupport(originalTabularData.getTabularType());
          
             for (Object oEntry :  originalTabularData.values()) {
                 CompositeData entry = (CompositeData) oEntry;
                 entry =(CompositeData) convertReturnValue(entry);
                 tSupport.put(entry);
             }
             
             return tSupport;
        }

        return originalValue;
    }
}
