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

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 *
 */
public class WrappingInvocationHandler implements InvocationHandler, Serializable {

    private static final long serialVersionUID = 6058507469569863006L;

    private static final Log log = LogFactory.getLog(WrappingInvocationHandler.class);

    /**
     * This is here because the Spice JNDI provider will bind a 
     * javax.naming.Reference to an object if that object implements that
     * interface instead of binding to the object itself.  This causes
     * problems with Arjuna since it does not fetch the reference, but instead
     * just attempts to cast it to XADataSouce.
     * 
     * This is also a convenient way to log calls into these things for debugging
     * purposes.
     */
    private Object wrapped;
    private String debugInfo;
    private transient Log useLog;

    public WrappingInvocationHandler(Object wrapped, String debugInfo, Log useLog) {
        this.wrapped = wrapped;
        this.debugInfo = debugInfo;
        this.useLog = useLog;
    }

    public WrappingInvocationHandler(Object wrapped, String debugInfo) {
        this(wrapped, debugInfo, log);
    }

    /**
     * Used by serialization.
     */
    private void readObject(ObjectInputStream in) throws IOException, ClassNotFoundException {
        in.defaultReadObject();
        
        useLog = log;
    }
    
    private void writeObject(ObjectOutputStream out) throws IOException {
        out.defaultWriteObject();
    }
    
    @Override
    public Object invoke(Object proxy, Method method, Object[] args) 
    throws Throwable {
        String methodName = method.getName();
        if (useLog.isDebugEnabled()) {
            useLog.debug("PROXIED!" + methodName + " called on " + debugInfo);
        }

        replaceParameterOnEquals(method, args);
        
        Object result;
        try {
            result = method.invoke(wrapped, args);
        } catch (InvocationTargetException e) {
            throw e.getTargetException();
        } catch (Exception e) {
            throw new RuntimeException("unexpected invocation exception.", e);
        }

        return result;
    }

    /**
     * If this is a call to Object.equals(Object p) and p is also proxied by
     * a WrappingInvocationHandler then get the real object from the other
     * handler.
     * 
     * @param method The method called on this wrapped object.
     * @param args  Potentially updates args[0]
     */
    private void replaceParameterOnEquals(Method method, Object[] args) {
        if (!method.getName().equals("equals") || 
            method.getParameterTypes().length != 1 ||
            method.getParameterTypes()[0] != Object.class) {
            return;
        }

        if (args[0] == null || !( args[0] instanceof Proxy)) {
            return;
        }
        InvocationHandler otherHandler = Proxy.getInvocationHandler(args[0]);
        if (!(otherHandler instanceof WrappingInvocationHandler)) {
            return;
        }
        
        WrappingInvocationHandler otherWrappingInvocationHandler = 
            (WrappingInvocationHandler) otherHandler;
        args[0] = otherWrappingInvocationHandler.wrapped;
    }
}
