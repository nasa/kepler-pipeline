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

package gov.nasa.kepler.hibernate.dbservice;

import gov.nasa.spiffy.common.lang.WrappingInvocationHandler;

import java.io.Serializable;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;

import javax.sql.DataSource;
import javax.sql.XAConnection;

/**
 * This implements the DataSouce interface.  This is a dynamic proxy 
 * because on MacOS the interface definition is actually different from the
 * Java 6 definitions on other platforms and there has runtime errors or will
 * not compile on MacOS.
 * 
 * This DataSource interface contains Arjuna transaction manager specific
 * logic needed to allow Hibernate to access the Arjuna data source which
 * intercepts the calls to the native data source.
 * 
 * @author Sean McCauliff
 *
 */
class XADataSourceProxy implements InvocationHandler, Serializable {

    private static final long serialVersionUID = 6675622612802372554L;
    /**
     * The name of the Arjuna JDBC Driver.
     */
    private final static String ARJUNA_JDBC_PREFIX = "jdbc:arjuna:";
    
    /**
     * 
     * @param nativeJndiDataSourceName the jndi name where the native
     * data source is registered.
     * @return
     */
    static DataSource newInstance(String nativeJndiDataSourceName) {
        XADataSourceProxy invocationHandler =
            new XADataSourceProxy(nativeJndiDataSourceName);
        
        return (DataSource)
            Proxy.newProxyInstance(XADataSourceProxy.class.getClassLoader(), 
                new Class[] {DataSource.class},  invocationHandler);
    }
    
    private final String nativeJndiDataSourceName;
    
    private XADataSourceProxy(String nativeDataSouceName) {
        this.nativeJndiDataSourceName = nativeDataSouceName;
    }
    
    /**
     * @see java.lang.reflect.InvocationHandler#invoke(java.lang.Object, java.lang.reflect.Method, java.lang.Object[])
     */
    public Object invoke(Object proxy, Method method, Object[] args)
        throws Throwable {

        String mName = method.getName();
        
        if (mName.equals("getConnection") && args == null) {
        	Connection conn = DriverManager.getConnection(ARJUNA_JDBC_PREFIX+nativeJndiDataSourceName);
        	wrapConnection(conn);
            return conn;
           
        } else if (mName.equals("getConnection") && args.length == 2) {
            String username = (String) args[0];
            String password = (String) args[1];
            if (password == null) {
                password  = "";
            }
            Connection conn =DriverManager.getConnection(ARJUNA_JDBC_PREFIX+nativeJndiDataSourceName,
                                                                        username, password);
            return wrapConnection(conn);
        } else if (mName.equals("getLogWriter")) {
            return DriverManager.getLogWriter();
        } else if (mName.equals("getLoginTimeout")) {
            return 60;
        } else if (mName.equals("isWrapperFor")) {
            return false;
        }
        
        if (method.getReturnType().equals(Void.TYPE)) {
            return Void.TYPE;
        } else {
            return null;
        }
    } 
    
	private Object wrapConnection(Connection conn) {
    	Class<?>[] implementedClasses = null;
    	if (conn instanceof XAConnection) {
    		implementedClasses = new Class[] {XAConnection.class};
    	} else {
    		implementedClasses = new Class[] {Connection.class};
    	}
        WrappingInvocationHandler invocationHandler =
        	new WrappingInvocationHandler(conn, "wrappedConnection");
        Connection wrappedConn = (Connection)
        	Proxy.newProxyInstance(getClass().getClassLoader(), 
        						implementedClasses , invocationHandler);
        return wrappedConn;
    }
}
