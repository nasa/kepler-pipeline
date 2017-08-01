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

package gov.nasa.kepler.fs.client;

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.lang.BaseInvocationHandler;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;

import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.util.ArrayList;
import java.util.ConcurrentModificationException;
import java.util.List;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Sets;

import static gov.nasa.spiffy.common.lang.ReflectionUtils.*;

/**
 * Wraps calls to any the FileStoreClient in logging and timing.  This could be
 * used for any object actually.
 * 
 * See <A href="http://java.sun.com/j2se/1.3/docs/guide/reflection/proxy.html" 
 * http://java.sun.com/j2se/1.3/docs/guide/reflection/proxy.html </A> for more
 * information.
 * 
 * @author Sean McCaulilff
 * 
 */
class FileStoreClientInvocationHandler extends BaseInvocationHandler implements InvocationHandler {

    private final FileStoreClient wrappedObject;
    private final Log log;
    private final boolean performCheckStreamInUse;
    
    private final static Set<String> noStreamCheckMethodNames = 
         ImmutableSet.of("getXAResource", "xidForCurrentThread", "close", "isStreamOpen");
    
    public static Object newInstance(FileStoreClient obj) {
        return Proxy.newProxyInstance(obj.getClass()
            .getClassLoader(), implementMe(obj), new FileStoreClientInvocationHandler(
            obj));
    }

    private static Class<?>[] implementMe(Object obj) {
        Class<?>[] implementMe = allInterfaces(obj);
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        boolean cleanupAllowed = 
            config.getBoolean(FS_ALLOW_CLEANUP, FS_ALLOW_CLEANUP_DEFAULT);
        if (cleanupAllowed) {
            return implementMe;
        }
        
        List<Class<?>> withoutTestInterface = 
            new ArrayList<Class<?>>(implementMe.length - 1);
        for (int i=0; i < implementMe.length; i++) {
            if (implementMe[i] != FileStoreTestInterface.class) {
                withoutTestInterface.add(implementMe[i]);
            }
        }
        
        return withoutTestInterface.toArray(ArrayUtils.EMPTY_CLASS_ARRAY);
        
    }
    
    private FileStoreClientInvocationHandler(FileStoreClient obj) {
        this.wrappedObject = obj;
        this.log = LogFactory.getLog(obj.getClass());
        this.performCheckStreamInUse = 
            ConfigurationServiceFactory.getInstance()
            .getBoolean(FS_CLIENT_CHECK_STREAM_IN_USE, FS_CLIENT_CHECK_STREAM_IN_USE_DEFAULT);
    }

    /**
     * Adds the logging and timing before calling the invoked method.
     * 
     * @see java.lang.reflect.InvocationHandler#invoke(java.lang.Object,
     * java.lang.reflect.Method, java.lang.Object[])
     */
    @Override
    protected Object invokeOtherMethods(Object proxy, Method method,
            Object[] args) throws Throwable {
        
        String methodName = method.getName();
        if (log.isDebugEnabled()) {
            log.debug("[" + CSCI_NAME + "] " + methodName + "()");
        }
        // Start the metric clock.
        IntervalMetricKey key = IntervalMetric.start();
        
        checkStreamInUse(method);
        
        Object result;
        try {
            result = method.invoke(wrappedObject, args);
        } catch (InvocationTargetException e) {
            throw e.getTargetException();
        } catch (Exception e) {
            throw new RuntimeException("unexpected invocation exception.", e);
        } finally {
            IntervalMetric.stop(FS_METRICS_PREFIX + ".client." + methodName, key);
        }
        
        return result;
    }

    @Override
    protected String internalToString(Object proxy, Method method, Object[] args)
            throws IllegalArgumentException, IllegalAccessException,
            InvocationTargetException {

        return "FileStoreClientInvocationHandler " + wrappedObject.toString();
    }

    @Override
    protected int internalHashCode(Object proxy, Method method, Object[] args) {
        return wrappedObject.hashCode();
    }

    @Override
    protected boolean invocationHandlersEquals(
            BaseInvocationHandler otherBaseInvocationHandler, Object proxy,
            Method method, Object[] args) throws IllegalArgumentException,
            IllegalAccessException, InvocationTargetException {

        FileStoreClientInvocationHandler other = 
                (FileStoreClientInvocationHandler) otherBaseInvocationHandler;
        return other.wrappedObject.equals(this.wrappedObject);
    }
    
    private void checkStreamInUse(Method method) {
        if (!performCheckStreamInUse) {
            return;
        }
        
        if (noStreamCheckMethodNames.contains(method.getName())) {
            return;
        }
        if (wrappedObject.isStreamOpen()) {
            throw new ConcurrentModificationException("Attempt to call FileStoreClient " +
                "method while blob input/output stream is open.");
        }
    }
    
}
