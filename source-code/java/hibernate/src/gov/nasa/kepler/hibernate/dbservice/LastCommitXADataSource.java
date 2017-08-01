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

import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.sql.ConnectionEvent;
import javax.sql.ConnectionEventListener;
import javax.sql.DataSource;
import javax.sql.StatementEventListener;
import javax.sql.XAConnection;
import javax.sql.XADataSource;
import javax.transaction.xa.XAException;
import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is a wrapper around non-XA data sources to make them look like 
 * XADataSources.  This only works if the transaction manager supports the
 * last resource commit optimization which allows for a single non-XA data
 * source to be included in the distributed transaction.  The JBoos/Arjuna 
 * transaction manager, but the XAResouce being labeled as the last resource
 * must implement the marker interface 
 * com.arjuna.ats.jta.resources.LastResourceCommitOptimisation.
 * 
 * A dynamic proxy is used here because of compilation problems with
 * MacOS.
 * 
 * @author Sean McCauliff
 *
 */
class LastCommitXADataSource implements InvocationHandler, Serializable {

    private static final long serialVersionUID = 2813452345589457337L;
    
    private static final Log log = LogFactory.getLog(LastCommitXADataSource.class);
    
    static XADataSource newXADataSource(DataSource nonXaDataSource) 
        throws ClassNotFoundException {
        
        LastCommitXADataSource handler = 
            new LastCommitXADataSource(nonXaDataSource);
       
        
        return (XADataSource)
            Proxy.newProxyInstance(LastCommitXADataSource.class.getClassLoader(),
                       new Class[] {XADataSource.class},
                       handler);
        
    }
    
    private static XAResource newFakedXAResource(FakedXAConnection xaConnection) throws ClassNotFoundException {
        //Doing a dynamic class lookup so this project need not depend on
        //other projects or the arjuna jars.
        Class<?> lastResourceCommitOptimisationInterface =
            Class.forName("com.arjuna.ats.jta.resources.LastResourceCommitOptimisation");
        
        Class<?>[] proxyClasses = 
            new Class<?>[] { lastResourceCommitOptimisationInterface,
                                   XAResource.class };
        
        FakedXAResource handler = new FakedXAResource(xaConnection);
        
        return (XAResource)
            Proxy.newProxyInstance(LastCommitXADataSource.class.getClassLoader(),
                                                proxyClasses, handler);
    }
    
    static Connection newWrapperConnection(FakedXAConnection xaConnection) {
        ConnectionWrapper handler = new ConnectionWrapper(xaConnection);
        return (Connection) 
            Proxy.newProxyInstance(LastCommitXADataSource.class.getClassLoader(),
                                                         new Class[] {Connection.class},
                                                         handler);
                                                         
    }
    
    private DataSource nonXaDataSource;
    
    private LastCommitXADataSource(DataSource nonXaDataSource) {
        this.nonXaDataSource = nonXaDataSource;
    }
    

    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        String methodName = method.getName();
        
        if (methodName.equals("getXAConnection") ) {
            if (args == null) {
            Connection actualConnection = nonXaDataSource.getConnection();
            return new FakedXAConnection(actualConnection);
            
            } else if (args.length == 2) {
                String username = (String) args[0];
                String password = (String) args[1];
                Connection actualConnection = 
                    nonXaDataSource.getConnection(username, password);
                actualConnection.setAutoCommit(false);
                return new FakedXAConnection(actualConnection);
            
            } else  {
                throw new IllegalArgumentException("Unknown method" +
                        " getXAConnection() #args: " + args.length);
            }
        } else {
            Method targetMethod = 
                nonXaDataSource.getClass().
                getMethod(methodName, method.getParameterTypes());
            return targetMethod.invoke(nonXaDataSource, args);
        }
    }

    /**
     * Makes a non-XA Connection look like an XAConnection.   Hey, I didn't
     * make up all this complexity.  Don't blame me.  See:
     * 
     * http://www.datadirect.com/developer/jdbc/topics/connpooling/index.ssp
     */
    private static class FakedXAConnection implements XAConnection, Serializable {
        private static final long serialVersionUID = 1751812745151358593L;
        private Connection actualConnection;
        private XAResource xaResource;
        private transient List<ConnectionEventListener> connectionListeners =
            new ArrayList<ConnectionEventListener>();
        
        FakedXAConnection(Connection actualConnection) throws ClassNotFoundException {
            this.actualConnection = actualConnection;
            this.xaResource = newFakedXAResource(this);
        }
        
        /** Used by serialization. */
        private void readObject(ObjectInputStream oin) throws IOException, ClassNotFoundException {
            oin.defaultReadObject();
            connectionListeners = new ArrayList<ConnectionEventListener>();
        }
        
        /** Used by serialization. */
        private void writeObject(ObjectOutputStream oout) throws IOException {
            oout.defaultWriteObject();
        }
        
        public XAResource getXAResource() throws SQLException {
            return xaResource;
        }

        public void addConnectionEventListener(ConnectionEventListener listener) {  
            connectionListeners.add(listener);
        }

        public void addStatementEventListener(StatementEventListener listener) {
            throw new IllegalStateException("Not implemented.");
        }

        public void close() throws SQLException {
            actualConnection.close();
        }

        public Connection getConnection() throws SQLException {
            return actualConnection;
        }

        public void removeConnectionEventListener(ConnectionEventListener listener) {
            connectionListeners.remove(listener);
        }

        public void removeStatementEventListener(StatementEventListener listener) {
            throw new IllegalStateException("Not implemented.");
            
        }

    }
    
    /**
     * Implements the last commit interface so the DataSouce can participate
     * in an XA transaction.
     * 
     * @author Sean McCauliff
     *
     */
    private static class FakedXAResource implements InvocationHandler, Serializable {

        private static final long serialVersionUID = -6667528042202717001L;
        private FakedXAConnection xaConnection;
        private int timeout = 60;
        
        /**
         * Only one Xid should be associated with a faked resource.
         */
        private Xid xid = null;
        
        FakedXAResource(FakedXAConnection xaConnection) {
            this.xaConnection = xaConnection;
        }
        
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            String methodName = method.getName();
            
            if (methodName.equals("commit")) {
                try {
                    boolean onePhase = (Boolean) args[1];
                    if (!onePhase) {
                        throw new XAException("Must be single phase commit.");
                    }
                    xaConnection.actualConnection.commit();
                    xid = null;
                    return Void.TYPE;
                } catch (SQLException sqle) {
                    log.error("Hidden SQL exception on XA commit.", sqle);
                    //Not sure if the XA error code should be set here.  Or if it should
                    //what would be the correct code with out parsing the error
                    //message from the database.
                    throw new XAException(sqle.toString());
                }
            } else if (methodName.equals("prepare")) {
                throw new XAException("prepre not valid on LastResouceCommit");
            } else if (methodName.equals("end")){
                return Void.TYPE;
            } else if (methodName.equals("forget")) {
                xid = null;
                return Void.TYPE;
            } else if (methodName.equals("isSameRM")) {
                return proxy == args[0];
            } else if (methodName.equals("recover")) {
                return new Xid[0];
            } else if (methodName.equals("rollback")) {
                try {
                    xaConnection.actualConnection.rollback();
                } catch (SQLException sqle) {
                    log.error("Hidden SQL exception on XA rollback.", sqle);
                    throw new XAException(sqle.toString());
                } finally {
                    xid = null;
                }
            } else if (methodName.equals("start")) {
                Xid newXid = (Xid) args[0];
                if (xid != null && !newXid.equals(xid)) {
                    throw new IllegalArgumentException("Resource already " +
                            "associated with transaction \"" + xid + "\".");
                }
                xid = newXid;
                
                return Void.TYPE;
            } else if (methodName.equals("equals")) {
                return proxy == args[0];
            } else if (methodName.equals("hashCode")) {
                return xaConnection.hashCode();
            } else if (methodName.equals("toString")) {
                return "FakedXAResource " + xaConnection;
            } else if (methodName.equals("getTransactionTimeout")) {
                return timeout;
            } else if (methodName.equals("setTransactionTimeout")) {
                timeout = (Integer) args[0];
                return true;
            } else {
                throw new IllegalArgumentException("Bad XAResouce method \"" 
                    + methodName + "\".");
            }
            return null;   //This should never be reached.
        }

    }
    
    /**
     * Intercepts calls to the actual connection so they agree with the
     * PooledConnection/XAConnection contract.  close() causes events to
     * be sent to all the ConnectionEventListeners.  Any SQLException caused
     * by an actual event will cause events to be sent to all the
     * ConnectionEventListeners.
     *
     */
    private static class ConnectionWrapper implements InvocationHandler {

        private final FakedXAConnection xaConnection;
        
        ConnectionWrapper(FakedXAConnection xaConnection) {
            this.xaConnection = xaConnection;
        }
        
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
            String methodName = method.getName();
            if (methodName.equals("close")) {
                ConnectionEvent closeEvent = new ConnectionEvent(xaConnection);
                for (ConnectionEventListener listener : xaConnection.connectionListeners) {
                    listener.connectionClosed(closeEvent);
                }
                return Void.TYPE;
            } else {
                try {
                    Method actualMethod = 
                        xaConnection.actualConnection.getClass().getDeclaredMethod(methodName, method.getParameterTypes());
                    return actualMethod.invoke(xaConnection.actualConnection, args);
                } catch (Throwable  t) {
                    if (t instanceof SQLException) {
                        SQLException sqle = (SQLException) t;
                        ConnectionEvent connectionEvent = new ConnectionEvent(xaConnection, sqle);
                        for (ConnectionEventListener listener : xaConnection.connectionListeners) {
                            listener.connectionErrorOccurred(connectionEvent);
                        }
                    }
                    throw t;
                }
            }
        }
        
    }
}
