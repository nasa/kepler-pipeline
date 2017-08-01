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

import java.lang.reflect.Method;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

/**
 * Assembles information about a specified interface.
 * 
 * @author Sean McCauliff
 *
 */
class InterfaceData {

    private final Class<?> iface;
    private final Set<MethodData> methods = new TreeSet<MethodData>();
    
    private final ImportGenerator igen = new ImportGenerator();
    
    InterfaceData(Class<?> iface) throws ClassNotFoundException {
        this.iface = iface;
        if (!iface.isInterface()) {
            throw new IllegalArgumentException("\"" + iface.getName() +
                "\"  Java interface");
        }
        
        //Assemble the number of times a method name is used.
        Method[] classMethods = iface.getMethods();
        Map<String, Integer> methodNameTotalCount = new HashMap<String, Integer>();
        for (Method m : classMethods) {
            if (!methodNameTotalCount.containsKey(m.getName())) {
                methodNameTotalCount.put(m.getName(), 1);
            } else {
                methodNameTotalCount.put(m.getName(), methodNameTotalCount.get(m.getName()) + 1);
            }
        }

        //Sort the methods according to signature.
        for (Method m : classMethods) {
            MethodData mdata = new MethodData(m);
            methods.add(mdata);
            igen.addClass(mdata.methodReturnTypeDependences());
            igen.addClass(mdata.method().getExceptionTypes());
            for (ParameterData pdata : mdata.parameters()) {
                igen.addClass(pdata.getParameterClass());
            }
        }
        
        //Assign method indicies to make method names unique.
        Map<String,Integer> methodNameCurrentCount = new HashMap<String,Integer>();
        for (MethodData mdata : methods) {
            String methodName = mdata.method().getName();
            if (methodNameTotalCount.get(methodName) == 1) {
                continue;
            }
            
            if (methodNameCurrentCount.containsKey(methodName)) {
                int currentCount = methodNameCurrentCount.get(methodName);
                mdata.setMethodIndex(++currentCount);
                methodNameCurrentCount.put(methodName, currentCount);
            } else {
                methodNameCurrentCount.put(methodName, 1);
                mdata.setMethodIndex(1);
            }
        }
        
        igen.addClass(iface.getInterfaces());
    }
    
    
    Collection<MethodData> methods() {
        return methods;
    }
    
    ImportGenerator importGenerator() {
        return igen;
    }
    
    Class<?> interfaceClass() {
        return iface;
    }
    
    ImplicitParameterData[] implicitParameters() {
        Set<ImplicitParameterData> set = new HashSet<ImplicitParameterData>();
        
        for (MethodData mdata : methods) {
            if (mdata.implicitParameter() != null) {
                set.add(mdata.implicitParameter());
            }
        }
        
        ImplicitParameterData[] rv = new ImplicitParameterData[set.size()];
        set.toArray(rv);
        return (ImplicitParameterData[]) rv;
    }
}
