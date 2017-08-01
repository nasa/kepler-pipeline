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

package gov.nasa.spiffy.common.lang;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

/**
 * Useful methods for any invocation handler that needs to handle toString(),
 * hashCode(), or equals().
 *  
 * @author Sean McCauliff
 *
 */
public abstract class BaseInvocationHandler implements InvocationHandler {

    /**
     * Checks if toString(), hashCode(), or equals(Object) is being called and
     * forwards the call to the correct abstract method.
     */
    @Override
    public Object invoke(Object proxy, Method method, Object[] args)
            throws Throwable {
        try {
            Class<?>[] parameterTypes = method.getParameterTypes();
            
            if (method.getName().equals("equals") && parameterTypes.length == 1 &&
                    parameterTypes[0].equals(Object.class)) {
                return internalEquals(proxy, method, args); 
            }
            
            if (method.getName().equals("hashCode") && parameterTypes.length == 0) {
                return internalHashCode(proxy, method, args);
            }
            
            if (method.getName().equals("toString") && parameterTypes.length == 0) {
                return internalToString(proxy, method, args);
            }
            
            return invokeOtherMethods(proxy, method, args);
        } catch (InvocationTargetException x) {
            if (x.getTargetException() != null) {
                throw x.getTargetException();
            }
            throw x;
        }
    }
    
    protected abstract Object invokeOtherMethods(Object proxy, Method method, Object[] args)
            throws Throwable;

    protected abstract String internalToString(Object proxy, Method method, Object[] args)
            throws IllegalArgumentException, IllegalAccessException, InvocationTargetException;

    /**
     * 
     * @param proxy
     * @param method
     * @param args
     * @return return a hash code.
     */
    protected abstract int internalHashCode(Object proxy, Method method, Object[] args);

    protected boolean internalEquals(Object proxy, Method method, Object[] args) 
            throws IllegalArgumentException, IllegalAccessException, InvocationTargetException {
        Object other = args[0];
        if (other == proxy) {
            return true;
        }
        if (!Proxy.isProxyClass(other.getClass())) {
            return false;
        }
        InvocationHandler otherInvocationHandler = Proxy.getInvocationHandler(other);
        if (otherInvocationHandler == null) {
            return false;
        }
        if (!(otherInvocationHandler instanceof BaseInvocationHandler)) {
            return false;
        }
        if (otherInvocationHandler.getClass() != this.getClass()) {
            return false;
        }
        
        BaseInvocationHandler otherBaseInvocationHandler = 
        		(BaseInvocationHandler) other;
        return invocationHandlersEquals(otherBaseInvocationHandler,
                proxy, method, args);
    }

    /**
     * Compare the two invocation handlers.  Or the proxied object to it's other
     * object.
     * 
     * @param baseInvocationHandler
     * @param otherBaseInvocationHandler
     * @param proxy
     * @param method
     * @param args
     * @return
     */
    protected abstract boolean invocationHandlersEquals(
            BaseInvocationHandler otherBaseInvocationHandler,
            Object proxy,
            Method method, Object[] args)
        throws IllegalArgumentException, IllegalAccessException, InvocationTargetException;
}
