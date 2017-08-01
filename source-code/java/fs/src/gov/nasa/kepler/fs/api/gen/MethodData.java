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

package gov.nasa.kepler.fs.api.gen;

import gov.nasa.kepler.fs.api.FileStoreException;

import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.lang.reflect.Type;
import java.util.HashMap;
import java.util.Map;

/**
 * Encapsulates information about a method.  This does not handle parameteritized
 * types (well) or inner classes.
 * 
 * @author Sean McCauliff
 *
 */
class MethodData implements Comparable<MethodData> {
    private final Method method;
    private final ParameterData[] parameters;
    private  int methodIndex = INDEX_UNIQUE;
    private final ImplicitParameterData implicit;
    private final String signatureStr;
    
    final static int INDEX_UNIQUE = -1;
    
    /**
     * 
     * @param method
     * @param methodIndex When the same method name is used more than once
     * this is used to disambiguate the names of the methods.  When this is
     * assigned the value of INDEX_UNIQUE then this is the only method the has
     * the name.
     * @throws ClassNotFoundException
     */
    MethodData(Method method) throws ClassNotFoundException {
        this.method = method;
        Class<?>[] parameterClasses = method.getParameterTypes();
        Type[] genericTypes = method.getGenericParameterTypes();
        if (method.getAnnotation(ImplicitParameter.class) != null) {
            implicit = new ImplicitParameterData(method.getAnnotation(ImplicitParameter.class));
        } else {
            implicit = null;
        }
        
        parameters = new ParameterData[parameterClasses.length];
        
        Map<Class<?>,Integer> parameterCount = new HashMap<Class<?>,Integer>();
        for (int i=0; i < parameterClasses.length; i++) {
            Integer count = parameterCount.get(parameterClasses[i]);
            if (count == null) {
                count = 1;
            } else {
                count++;
            }
            parameterCount.put(parameterClasses[i], count);
            parameters[i] = new ParameterData(parameterClasses[i], genericTypes[i], count);
        }
        
        signatureStr = generateSignature();
    }
    
    ImplicitParameterData implicitParameter() {
        return implicit;
    }
    
    void setMethodIndex(int newIndex) {
        this.methodIndex = newIndex;
    }
    
    /**
     * 
     * @return A string that may be neded to make a method name unique.
     */
    String methodIndex() {
        if (methodIndex == INDEX_UNIQUE) {
            return "";
        }
        return Integer.toString(methodIndex);
    }
    
    String signature() {
        return this.signatureStr;
    }
    
    private String generateSignature() {
        StringBuilder bldr = new StringBuilder();
        String methodName = method.getName();
        Type genericType = method.getGenericReturnType();
        String returnType = null;
        //I can't find a better way to determine if this is actually
        //a generic type or not.
        if (genericType.toString().indexOf('<') != -1) {
            returnType = genericType.toString();
        } else {
            returnType = method.getReturnType().getSimpleName();
        }
        
        int modifiers = method.getModifiers();
        modifiers = modifiers & ~Modifier.ABSTRACT;
        bldr.append(Modifier.toString(modifiers));
        bldr.append(' ');
        bldr.append(returnType);
        bldr.append(" ");
        bldr.append(methodName);
        bldr.append("(");
        for (ParameterData parameter : parameters) {

            bldr.append(parameter.signature());
            bldr.append(" ");

            bldr.append(parameter.parameterName());

            bldr.append(',');
        }
       
        if (parameters.length > 0) {
            bldr.setLength(bldr.length() - 1);
        }
        
        bldr.append(") ");
        
        Class<?>[] exceptions = method.getExceptionTypes();
        if (exceptions.length > 0) {
            bldr.append("throws ");
        }
        for (Class<?> ex : exceptions) {
            bldr.append(ex.getSimpleName());
            bldr.append(",");
        }
        bldr.setLength(bldr.length() - 1);
        
        return bldr.toString();
    }
    
   
    ParameterData[] parameters() {
        return parameters;
    }
    
    
    Method method() {
        return method;
    }

    boolean ignoreClientGeneration() {
        return method.getAnnotation(IgnoreClientGeneration.class) != null;
    }
    
    boolean ignoreServerGeneration() {
        return method.getAnnotation(IgnoreServerGeneration.class) != null;
    }
    
    boolean needServerDecode() {
        return method.getAnnotation(NeedServerDecoding.class) != null;
    }
    
    boolean throwsFileStoreException() {
        Class<?>[] exceptionClasses = method.getExceptionTypes();
       // System.out.println("method " + method.getName());
        for (Class<?> ex : exceptionClasses) {
          //  System.out.println("Exception class : " + ex);
            if (ex == FileStoreException.class) {
                return true;
            }
        }
        
        return false;
    }

    /**
     * All the classes that the return type depends upon.  Complicated types 
     * such as arrays or containers may refer to more than one type.
     * @return an array of dependent classes, with at least length one.
     */
    Class<?>[] methodReturnTypeDependences() throws ClassNotFoundException {
         
        String genericTypeStr = method.getGenericReturnType().toString();
        if (genericTypeStr.indexOf('<')  != -1) {
        
            String cleanedTypeString = genericTypeStr.replaceAll("<|>|,|\\[\\]", " ");
            String[] types = cleanedTypeString.split("\\s+");
            Class<?>[] rv = new Class[types.length];
            for (int i=0; i < rv.length; i++) {
                rv[i] = Class.forName(types[i]);
            }
            return rv;
        }
        
        Class<?> returnType = method.getReturnType();
        if (returnType.isArray()) {
            return new Class[] {returnType.getComponentType(), returnType};
        }
        
        return new Class[] { returnType};
    }
    
    /**
     * The implementor must provide a wire format.
     * @return
     */
    public boolean needClientEncoding() {
        return method.getAnnotation(NeedClientEncoding.class) != null;
    }
    
    public int compareTo(MethodData o) {
        return this.signatureStr.compareTo(o.signatureStr);
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        
        if (o == null) {
            return false;
        }
        
        if (o.getClass() != this.getClass()) {
            return false;
        }
        MethodData other = (MethodData) o;
        return this.signatureStr.equals(other.signatureStr);
    }
    
    @Override
    public int hashCode() {
        return this.signatureStr.hashCode();
    }
    
    /**
     * Checks if a method throws an exception or a superclass of the
     * specified exception.
     * 
     * @param exception  This class should extend from Exception
     * @return true if this method throws that exception false other wise.
     */
    @SuppressWarnings("unchecked")
    public boolean throwsException(Class exceptionClass) {
        for (Class<?> x : method.getExceptionTypes()) {
            if (x.isAssignableFrom(exceptionClass)) {
                return true;
            }
        }
        
        return false;
    }

}
