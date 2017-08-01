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

package gov.nasa.kepler.fs.server.xfiles;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.lang.BaseInvocationHandler;

import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.configuration.Configuration;


/**
 * Intercept the Conifguration so it will return different storage directory
 * properties for the file store data directories.  This is so we can leave the
 * system wide configuration as is.
 * 
 * @author Sean McCauliff
 *
 */
class ConfigurationOverrideHandler extends BaseInvocationHandler {

    private static final Map<String, Class<?>> proxiedMethods;
    static {
        proxiedMethods = new HashMap<String, Class<?>>();
        proxiedMethods.put("getString", String.class);
        proxiedMethods.put("getInteger", Integer.class);
        proxiedMethods.put("getInt", Integer.class);
        proxiedMethods.put("getBoolean", Boolean.class);
        proxiedMethods.put("getLong", Long.class);
    }
    
    private final Configuration wrappedConfig;
    
    private final Map<String, String> overrides;
    
    public static Configuration wrappedConfiguration(Map<String, String> overrides) {
        Configuration wrappedConfig = ConfigurationServiceFactory.getInstance();
        ConfigurationOverrideHandler handler = 
            new ConfigurationOverrideHandler(overrides, wrappedConfig);
        return (Configuration) Proxy.newProxyInstance(
            ConfigurationOverrideHandler.class.getClassLoader(), 
            new Class[] { Configuration.class },
            handler);

    }
    
    private ConfigurationOverrideHandler(Map<String, String> overrides,
        Configuration wrappedConfig) {

        this.overrides = overrides;
        this.wrappedConfig = wrappedConfig;
    }

    @Override
    protected Object invokeOtherMethods(Object proxy, Method method,
            Object[] args) throws IllegalArgumentException,
            IllegalAccessException, InvocationTargetException {

        if (!proxiedMethods.containsKey(method.getName()) ||
                !overrides.containsKey(args[0])) {
            return method.invoke(wrappedConfig, args);
        }
        
        String rv = overrides.get(args[0]);
        if (rv == null) {
            return null;
        }
        Class<?> expectedReturnType = proxiedMethods.get(method.getName());
        if (expectedReturnType == String.class) {
            return rv;
        }
        if (expectedReturnType == Integer.class) {
            return Integer.parseInt(rv);
        }
        if (expectedReturnType == Long.class) {
            return Long.parseLong(rv);
        }
        if (expectedReturnType == Boolean.class) {
            return Boolean.parseBoolean(rv);
        }
        throw new IllegalStateException("Unexpected return type: " + expectedReturnType);
    }

    @Override
    protected int internalHashCode(Object proxy, Method method, Object[] args) {
        return overrides.hashCode() ^ wrappedConfig.hashCode();
    }

    @Override
    protected boolean invocationHandlersEquals(
            BaseInvocationHandler otherBaseInvocationHandler, Object proxy,
            Method method, Object[] args) throws IllegalArgumentException,
            IllegalAccessException, InvocationTargetException {

        ConfigurationOverrideHandler other = 
                (ConfigurationOverrideHandler) otherBaseInvocationHandler;
        return other.overrides.equals(this.overrides) &&
                other.wrappedConfig.equals(this.wrappedConfig);
        
    }

    @Override
    protected String internalToString(Object proxy, Method method, Object[] args)
            throws IllegalArgumentException, IllegalAccessException,
            InvocationTargetException {

        return "Overrides: " + overrides.toString() +
                " wrapped: " + wrappedConfig.toString();
    }

}
