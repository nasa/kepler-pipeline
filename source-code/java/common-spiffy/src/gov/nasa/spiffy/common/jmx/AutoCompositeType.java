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

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.SortedMap;
import java.util.TreeMap;

import javax.management.ObjectName;
import javax.management.openmbean.CompositeData;
import javax.management.openmbean.CompositeType;
import javax.management.openmbean.OpenDataException;
import javax.management.openmbean.SimpleType;

/**
 * Automatically generate CompsiteType information and helper 
 * information needed by AbstractCompositeData.
 * 
 * @author Sean McCauliff
 *
 */
public class AutoCompositeType {
    private static Map<Class<?>,AutoCompositeType> cache =
        new HashMap<Class<?>,AutoCompositeType>();
    
    final static Map<Class<?>, SimpleType<?>>
        javaTypeToSimpleType = new HashMap<Class<?>,SimpleType<?>>();
    
    static {
        initJavaTypeToSimpleType();
    }
    
    private static void initJavaTypeToSimpleType() {
        javaTypeToSimpleType.put(Boolean.TYPE, SimpleType.BOOLEAN);
        javaTypeToSimpleType.put(Boolean.class, SimpleType.BOOLEAN);
        javaTypeToSimpleType.put(Byte.TYPE, SimpleType.BYTE);
        javaTypeToSimpleType.put(Byte.class, SimpleType.BYTE);
        javaTypeToSimpleType.put(Character.TYPE, SimpleType.CHARACTER);
        javaTypeToSimpleType.put(Character.class, SimpleType.CHARACTER);
        javaTypeToSimpleType.put(Short.TYPE, SimpleType.SHORT);
        javaTypeToSimpleType.put(Short.class, SimpleType.SHORT);
        javaTypeToSimpleType.put(Integer.TYPE, SimpleType.INTEGER);
        javaTypeToSimpleType.put(Integer.class, SimpleType.INTEGER);
        javaTypeToSimpleType.put(Long.TYPE, SimpleType.LONG);
        javaTypeToSimpleType.put(Long.class, SimpleType.LONG);
        javaTypeToSimpleType.put(BigInteger.class, SimpleType.BIGINTEGER);
        javaTypeToSimpleType.put(BigDecimal.class, SimpleType.BIGDECIMAL);
        javaTypeToSimpleType.put(Float.TYPE, SimpleType.FLOAT);
        javaTypeToSimpleType.put(Float.class, SimpleType.FLOAT);
        javaTypeToSimpleType.put(Double.TYPE, SimpleType.DOUBLE);
        javaTypeToSimpleType.put(Double.class, SimpleType.DOUBLE);
        javaTypeToSimpleType.put(String.class, SimpleType.STRING);
        javaTypeToSimpleType.put(Date.class, SimpleType.DATE);
        javaTypeToSimpleType.put(ObjectName.class, SimpleType.OBJECTNAME);
        javaTypeToSimpleType.put(Void.TYPE, SimpleType.VOID);
    }
    
    /**
     * 
     * @param name Must use CompositeTypeDescription and ItemDescription
     * annotations.
     * @return
     * @throws OpenDataException
     */
    public synchronized static AutoCompositeType 
        newAutoCompositeType(Class<? extends CompositeData> name) 
        throws OpenDataException {

        AutoCompositeType auto = cache.get(name);
        if (auto != null) {
            return auto;
        }
        auto = new AutoCompositeType(name);
        cache.put(name,auto);
        return auto;
    }
    

    protected final CompositeType compositeType;
    protected final Map<String,Method> itemGetters;
    protected final SortedMap<Integer,String> indexItems;
    
    private AutoCompositeType(Class<? extends CompositeData> c) 
                                                            throws OpenDataException {
        
        CompositeTypeDescription compositeDescription =
            c.getAnnotation(CompositeTypeDescription.class);
        
        String classDescription = null;
        if (compositeDescription != null) {
            classDescription = compositeDescription.value();
        } else {
            throw new IllegalArgumentException("Class \"" + c + 
                "\" does not have a TabularTypeDescription nor" +
                " a CompsiteTypeDescription.");
        }
       
       Map<String,Method> itemGetters = new HashMap<String,Method>();
       List<String> itemNames = new ArrayList<String>();
       List<String> itemDescriptions = new ArrayList<String>();
       List<SimpleType<?>> itemTypes = new ArrayList<SimpleType<?>>();
       SortedMap<Integer,String> indexItems = new TreeMap<Integer, String>();
       
       Method[] methods = c.getDeclaredMethods();
       for (Method m : methods) {
           if (!Modifier.isPublic(m.getModifiers())){
               continue;
           }
           
           ItemDescription itemDescription =
               m.getAnnotation(ItemDescription.class);
           if (itemDescription == null) {
               continue;
           }
           
           if (m.getParameterTypes().length != 0) {
               continue;
           }
           
           String methodName = m.getName();
           String itemName = null;
           if (methodName.startsWith("get")) {
               itemName = methodName.substring("get".length());
           } else if (methodName.startsWith("is")) {
               itemName = methodName.substring("is".length());
           } else {
               continue;
           }
           
           if (m.getParameterTypes().length != 0) {
               continue;
           }
           
           SimpleType<?> simpleType = 
               javaTypeToSimpleType.get(m.getReturnType());
           if (simpleType == null) {
               throw new OpenDataException("Can't find SimpleType" +
                    " for method return type \"" + m.getReturnType() + "\"." );
           }
           
           if (m.isAnnotationPresent(TableIndex.class)) {
               TableIndex tableIndex = m.getAnnotation(TableIndex.class);
               indexItems.put(tableIndex.value(), itemName);
           }
           itemGetters.put(itemName, m);
           itemNames.add(itemName);
           itemDescriptions.add(itemDescription.value());
           itemTypes.add(simpleType);
           
       }
       
       
       String[] strArrayType = new String[0];
       SimpleType<?>[] simpleArrayType = new SimpleType[0];
        compositeType =
            new CompositeType(c.getName(), classDescription,
                itemNames.toArray(strArrayType), 
                itemDescriptions.toArray(strArrayType),
                itemTypes.toArray(simpleArrayType));
        
        this.itemGetters = Collections.unmodifiableMap(itemGetters);
        this.indexItems = Collections.unmodifiableSortedMap(indexItems);
    }
    
    CompositeType compositeType() {
        return compositeType;
    }

    Map<String,Method> itemGetters() {
        return itemGetters;
    }
    
    String[] tableIndices() {
        String[]  rv = new String[indexItems.size()];
        Iterator<String> it = indexItems.values().iterator();
        for (int i=0; i < rv.length; i++)  {
            rv[i] = it.next();
        }
        return rv;
    }
    
}
