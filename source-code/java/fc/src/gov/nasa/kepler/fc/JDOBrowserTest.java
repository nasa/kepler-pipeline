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

//package gov.nasa.kepler.fc;
//
//import java.lang.reflect.Field;
//import java.lang.reflect.Method;
//import java.lang.reflect.Modifier;
//import java.util.Collection;
//
//import javax.jdo.PersistenceManager;
//import javax.jdo.Query;
//
//public class JDOBrowserTest {
//    
//    String m_className;
//    String m_tableName;
//    String m_type;
//    String m_ow;
//    String m_version;
//    
//    public JDOBrowserTest() {
//        m_className = "";
//        m_tableName = "";
//        m_type      = "";
//        m_ow        = "";
//        m_version   = "";
//    }
//    
//    public JDOBrowserTest( String className, String tableName, String type, String ow, String version ) {
//        m_className = className;
//        m_tableName = tableName;
//        m_type      = type;
//        m_ow        = ow;
//        m_version   = version;
//    }
//    
//    public String toString() {
//        return m_className + " " +
//               m_tableName + " " +
//               m_type      + " " +
//               m_ow        + " " +
//               m_version;
//    }
//
//    
//    
//    public static void main(String[] args) {
//        
//        PersistenceManager pm = FC_PersistenceManager.init();
//        
//        JDOBrowserTest theJdo = new JDOBrowserTest();
//        
//        Query query = pm.newQuery( theJdo.getClass(), "" );
//        Collection jdoBack = (Collection) query.execute();
//        
//        
//        System.out.println( jdoBack.size() );
//        for ( Object tmp : jdoBack ) {
//            JDOBrowserTest locJDO = (JDOBrowserTest) tmp;
//            System.out.println( locJDO.toString() );
//            printFieldNames( locJDO );
//        }
//
//    }
//
//    public static void showMethods(Object o) {
//        Class c = o.getClass();
//        Method[] theMethods = c.getMethods();
//        for (int i = 0; i < theMethods.length; i++) {
//            String methodString = theMethods[i].getName();
//            System.out.println("Name: " + methodString);
//            String returnString =
//                theMethods[i].getReturnType().getName();
//            System.out.println("   Return Type: " + returnString);
//            Class[] parameterTypes = theMethods[i].getParameterTypes();
//            System.out.print("   Parameter Types:");
//            for (int k = 0; k < parameterTypes.length; k ++) {
//                String parameterString = parameterTypes[k].getName();
//                System.out.print(" " + parameterString);
//            }
//            System.out.println();
//        }
//    }
//    
//    static void verifyInterface(Class c) {
//        String name = c.getName();
//        if (c.isInterface()) {
//            System.out.println(name + " is an interface.");
//        } else {
//            System.out.println(name + " is a class.");
//        }
//    }
//    
//    static void printFieldNames(Object o) {
//        Class c = o.getClass();
//        Field[] publicFields = c.getFields();
//        for (int i = 0; i < publicFields.length; i++) {
//            String fieldName = publicFields[i].getName();
//            Class typeClass = publicFields[i].getType();
//            String fieldType = typeClass.getName();
//            System.out.println("Name: " + fieldName + 
//                    ", Type: " + fieldType);
//        }
//    }
//    
//    static void printInterfaceNames(Object o) {
//        Class c = o.getClass();
//        Class[] theInterfaces = c.getInterfaces();
//        for (int i = 0; i < theInterfaces.length; i++) {
//            String interfaceName = theInterfaces[i].getName();
//            System.out.println(interfaceName);
//        }
//    }
//    
//    public static void printModifiers( Object o ) {
//        
//        Class theclass = o.getClass();
//        int themods = theclass.getModifiers();
//        
//        System.out.println( themods );
//        
//        if ( ! Modifier.isPublic( themods ) )
//            System.out.println("not");
//        System.out.println("public");
//        
//        if ( ! Modifier.isAbstract( themods ) )
//            System.out.println("not");
//        System.out.println("abstract");
//        
//        if ( ! Modifier.isFinal( themods ) )
//            System.out.println("not");
//        System.out.println("final");
//    }
//    
//    static void printSuperclasses(Object o) {
//        Class subclass = o.getClass();
//        Class superclass = subclass.getSuperclass();
//        while (superclass != null) {
//            String className = superclass.getName();
//            System.out.println(className);
//            subclass = superclass;
//            superclass = subclass.getSuperclass();
//        }
//    }
//
//
//}
