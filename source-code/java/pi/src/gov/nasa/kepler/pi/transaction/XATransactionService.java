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

package gov.nasa.kepler.pi.transaction;

import static javax.transaction.Status.STATUS_MARKED_ROLLBACK;
import static javax.transaction.Status.STATUS_ROLLEDBACK;
import static javax.transaction.Status.STATUS_ROLLING_BACK;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.JndiServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactory;
import gov.nasa.kepler.hibernate.dbservice.XAService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.BooleanThreadLocal;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.XAConnection;
import javax.transaction.*;
import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.Session;

import com.arjuna.ats.internal.jdbc.drivers.modifiers.ConnectionModifier;
import com.arjuna.ats.internal.jdbc.drivers.modifiers.ModifierFactory;
import com.arjuna.ats.internal.jdbc.drivers.modifiers.extensions;
import com.arjuna.ats.jta.exceptions.NotImplementedException;
import com.arjuna.ats.jta.xa.XAModifier;
import com.arjuna.ats.jta.xa.XidImple;

/**
 * Distributed transaction service. This calls the XA TransactionManager to do
 * its work.
 * 
 * @author Sean McCauliff
 * 
 */
public class XATransactionService implements TransactionService {

    private static final String RECOVERY_ENABLED_PROP = "transactions.xa.recovery-enabled";
    private static final boolean RECOVERY_ENABLED_DEFAULT = true;
    
    /**
     * These properties tell the TM to use the JTA transaction implementation. This is an
     * embedded TM as opposed to the distributed CORBA based TM.
     */
    private static final String USER_TRANSACTION_IMPLEMENTATION = 
        "com.arjuna.ats.internal.jta.transaction.arjunacore.UserTransactionImple";

    private static final String USER_TRANSACTION_IMPLEMENTATION_SYSTEM_PROP = 
        "com.arjuna.ats.jta.jtaUTImplementation";

    private static final String TM_IMPLEMENTATION_JTA = 
        "com.arjuna.ats.internal.jta.transaction.arjunacore.TransactionManagerImple";

    private static final String TM_IMPLEMENTATION_SYSTEM_PROP = 
        "com.arjuna.ats.jta.jtaTMImplementation";

    /** This property is used to set the location of the TMs object store
     * directory.  Where the TM puts its durable data structures.
     */
    private static final String TM_OBJECT_STORE_SYSTEM_PROP = 
        "com.arjuna.ats.arjuna.objectstore.objectStoreDir";

    /**  This is the name of the property in the kepler.properties file that
     * has the name of the object store directory.
     */
    private static final String TM_OBJECT_STORE_KEPLER_PROP = 
        "transactions.xa.object-store";
    
    private static final String TM_OBJECT_STORE_DEFAULT = Filenames.BUILD_TEST
        + "/transactionServiceObjectStore";
    
    /**  The property that controlls the transaction isolation level.  */
    private static final String TM_ISOLATION_LEVEL = 
        "com.arjuna.ats.jdbc.isolationLevel";
    
    /** This is the only isolation level that will work with the File Store and
     * Oracle.
     */
    private static final String TM_ISOLATION_LEVEL_DEFAULT =
        "TRANSACTION_READ_COMMITTED";

    private static final Log log = LogFactory.getLog(XATransactionService.class);

    private static final String XA_TRANSACTION_TIMEOUT_PROP = "transactions.xa.timeout-seconds";
    private static final int XA_TRANSACTION_TIMEOUT_DEFAULT_SECS = 60 * 60;

    private final TransactionManager transactionManager;

    private final BooleanThreadLocal isUsingDatabase = 
        new BooleanThreadLocal(Boolean.FALSE);
    
    
    @SuppressWarnings("unused")
    private final XARecoveryManager recoveryManager;
    
    XATransactionService() {

        // Arjuna seems to need to following property set. I think they
        // have misunderstood constants.
        System.setProperty("Context.INITIAL_CONTEXT_FACTORY",
            JndiServiceFactory.getService().initialContextFactoryName());
        
        XANodeNameFactory xaNodeNameFactory = XANodeNameFactory.instance();
        String nodeName = xaNodeNameFactory.generateNodeName();
        System.setProperty(XANodeNameFactory.TM_NODE_ID_PROPERTY, nodeName);
        log.info("Setting transaction manager node id to \"" + nodeName + "\".");

        System.setProperty(TM_IMPLEMENTATION_SYSTEM_PROP, TM_IMPLEMENTATION_JTA);
        
        System.setProperty(TM_ISOLATION_LEVEL, TM_ISOLATION_LEVEL_DEFAULT);
        System.setProperty(USER_TRANSACTION_IMPLEMENTATION_SYSTEM_PROP,
            USER_TRANSACTION_IMPLEMENTATION);

        Configuration config = ConfigurationServiceFactory.getInstance();
        String objectStoreDirectory = config.getString(
            TM_OBJECT_STORE_KEPLER_PROP, TM_OBJECT_STORE_DEFAULT);

        log.info("Transaction manager will use \"" + objectStoreDirectory
            + "\" for persistent storage.");
        System.setProperty(TM_OBJECT_STORE_SYSTEM_PROP, objectStoreDirectory);

        System.setProperty("com.arjuna.ats.jta.xaRecoveryNode", "*");
        
        if (config.getBoolean(RECOVERY_ENABLED_PROP, RECOVERY_ENABLED_DEFAULT)) {
            recoveryManager = new XARecoveryManager();
            log.info("XA transaction recovery enabled.");
        } else {
            recoveryManager = null;
        }
        
        transactionManager = com.arjuna.ats.jta.TransactionManager.transactionManager();

        UserTransaction userTransaction = com.arjuna.ats.jta.UserTransaction.userTransaction();
        InitialContext jndiContext = JndiServiceFactory.getService()
            .initialContext();
        try {
            jndiContext.rebind("userTransaction", userTransaction);
        } catch (NamingException e) {
            throw new PipelineException("Failed to register UserTransaction "
                + "with naming service.", e);
        }

        //The following is to get around problems where the database
        //connections do not close
        ModifierFactory.putModifier("Oracle JDBC driver", 10, -1,
                                    "gov.nasa.kepler.pi.transaction.XATransactionService$Oracle10GModifier");
    }

    @Override
    public void beginTransaction() {
        beginTransaction(true, true, true);
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.TransactionService#beginTransaction()
     */
    @Override
    public void beginTransaction(boolean db, boolean jms, boolean fs)
        {

        if (!db && !jms && !fs) {
            throw new IllegalArgumentException("At least one service must be "
                + "involved in a transaction.");
        }

        try {
            Configuration config = ConfigurationServiceFactory.getInstance();
            int timeoutSecs = config.getInt(XA_TRANSACTION_TIMEOUT_PROP,
                XA_TRANSACTION_TIMEOUT_DEFAULT_SECS);
            log.debug("Setting XA transaction time out to " + timeoutSecs
                + " seconds.");
            transactionManager.setTransactionTimeout(timeoutSecs);
            com.arjuna.ats.jta.UserTransaction.userTransaction().begin();
        } catch (NotSupportedException e) {
            log.error("Failed to start transaction.");
            throw new PipelineException("Failed to begin transaction.", e);
        } catch (SystemException e) {
            log.error("Failed to start transaction.");
            throw new PipelineException("Failed to start transaction.", e);
        }

        ResultSet rs = null;
        Statement stmt = null;
        Connection conn = null;
        if (db) {  
            try {
            	
            	log.debug("Enlisting database service.");
                DatabaseService dbService = DatabaseServiceFactory.getInstance(true/* xa */);
                enlistService((XAService) dbService);
                conn = dbService.getConnection();
                stmt = conn.createStatement();
                rs = stmt.executeQuery("select count(*) from fc_rolltime"); //TODO: parameterize this
              
                isUsingDatabase.set(Boolean.TRUE);
                final Session session = dbService.getSession();
                transactionManager.getTransaction().registerSynchronization(
                    new Synchronization() {
                        @Override
                        public void beforeCompletion() {
                            //This does nothing.
                        }

                        @Override
                        public void afterCompletion(int status) {
                            if (status == STATUS_ROLLEDBACK
                                || status == STATUS_ROLLING_BACK
                                || status == STATUS_MARKED_ROLLBACK) {
                                log.info("Hibernate synchronization after 2PC complete.  "
                                    + "Transaction status "
                                    + status
                                    + ". Cleaning Hibernate cache.");
                                session.clear();
                            }
                        }
                    });
            } catch (IllegalStateException e) {
                throw new PipelineException(
                    "Failed to register Hibernate flush() synchronization.", e);
            } catch (RollbackException e) {
                throw new PipelineException(
                    "Failed to register Hibernate flush() synchronization.", e);
            } catch (SystemException e) {
                throw new PipelineException(
                    "Failed to register Hibernate flush() synchronization.", e);
            } catch (SQLException sqle) {
            	throw new PipelineException("Failed to check database connection.", sqle);
            } finally {
            	if (rs != null) { try { rs.close(); } catch (SQLException ignored) {}}
            	if (stmt != null) { try { stmt.close();} catch (SQLException ignored) {}}
            	if (conn != null) { try { conn.close(); } catch (SQLException ignored) {}}
            }
        } else {
            DatabaseServiceFactory.markNotUsingService(true);
        }

        if (jms) {
            enlistService((XAService) MessagingServiceFactory.getInstance(true));
        } else {
            MessagingServiceFactory.markNotUsingService(true);
        }

        if (fs) {
            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            fsClient.ping();
            enlistService((XAService) fsClient);
        } else {
            FileStoreClientFactory.markNotUsingService();
        }
    }

    private void enlistService(XAService s) {
        s.initialize(this);
        XAResource resource = s.getXAResource();
        if (resource != null) {
            enlistResource(resource);
        }
    }

    /**
     * If this throws an exception then the transaction should have been 
     * rollback.
     * 
     * @see gov.nasa.kepler.hibernate.dbservice.TransactionService#commitTransaction()
     */
    @Override
    public void commitTransaction() throws
        HeuristicRollbackException, HeuristicMixedException,
        HeuristicCommitException, RollbackException {

        try {
            if (isUsingDatabase.get()) {
                DatabaseServiceFactory.getInstance(true).flush();
                try {
                    DatabaseServiceFactory.getInstance(true).getSession().connection().close();
                } catch (HibernateException e) {
                    log.warn(e);
                } catch (SQLException e) {
                    log.warn(e);
                }
            }
            com.arjuna.ats.jta.UserTransaction.userTransaction().commit();
        } catch (SecurityException e) {
            throw new PipelineException("Failed to commit transaction.", e);
        } catch (IllegalStateException e) {
            throw new PipelineException("Failed to commit transaction.", e);
        } catch (SystemException e) {
            throw new PipelineException("Failed to commit transaction.", e);
        } finally {
            isUsingDatabase.set(Boolean.FALSE);
            DatabaseServiceFactory.clearNotUsingService(true);
            FileStoreClientFactory.clearNotUsingService();
            MessagingServiceFactory.clearNotUsingService(true);
        }
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.TransactionService#enlistResource(javax.transaction.xa.XAResource)
     */
    private void enlistResource(XAResource resource) {
        try {
            transactionManager.getTransaction().enlistResource(resource);
        } catch (IllegalStateException e) {
            throw new PipelineException(e);
        } catch (RollbackException e) {
            throw new PipelineException(e);
        } catch (SystemException e) {
            throw new PipelineException(e);
        }
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.TransactionService#rollbackTransaction()
     */
    @Override
    public void rollbackTransaction() {
        try {
            com.arjuna.ats.jta.UserTransaction.userTransaction().rollback();
        } catch (IllegalStateException e) {
            throw new PipelineException(e);
        } catch (SecurityException e) {
            throw new PipelineException(e);
        } catch (SystemException e) {
            throw new PipelineException(e);
        } finally {
            isUsingDatabase.set(Boolean.FALSE);
            DatabaseServiceFactory.clearNotUsingService(true);
            FileStoreClientFactory.clearNotUsingService();
            MessagingServiceFactory.clearNotUsingService(true);
        }
    }

    @Override
    public TransactionManager transactionManager() {
        return transactionManager;
    }
    
    /**
     * 
     * @return  This will return null if a transaction is not assocated with
     * the current thread.
     * @throws SystemException
     */
    public Transaction currentTransaction() throws SystemException {
        return transactionManager().getTransaction();
    }
    
    public void joinTransaction(Transaction x) throws InvalidTransactionException, IllegalStateException, SystemException {
        transactionManager().resume(x);
    }

    @Override
    public String userTransactionName() {
        return "userTransaction";
    }

    @Override
    public void rollbackTransactionIfActive() {
        try {
            if (transactionManager().getTransaction() == null) {
                return;
            }
        } catch (SystemException e) {
            throw new PipelineException("TransactionManager in bad state.", e);
        }

        rollbackTransaction();
    }

    public static class Oracle10GModifier implements XAModifier, ConnectionModifier {
        
        public Oracle10GModifier() {
        }

        @Override
        public Xid createXid(XidImple xid) throws SQLException, NotImplementedException {
            return xid;
        }

        @Override
        public int xaStartParameters(int level) throws SQLException, NotImplementedException {
            return level;
        }

        @Override
        public XAConnection getConnection(XAConnection conn) throws SQLException, NotImplementedException {
            return null;
        }

        @Override
        public String initialise(String dbName) {
            //This is from the class com.arjuna.ats.internal.jdbc.drivers.modifiers.oracle_jndi
            int index = dbName.indexOf(extensions.reuseConnectionTrue);
            int end = extensions.reuseConnectionTrue.length();
            
            if (index == -1) {
                index = dbName.indexOf(extensions.reuseConnectionFalse);
                end = extensions.reuseConnectionFalse.length();
            }

            /*
             * If at start, then this must be a JNDI URL. So remove component.
             */

            if (index != 0) {
                return dbName;
            } else {
                return dbName.substring(end + 1);  // remember colon
            }
        }

        @Override
        public void setIsolationLevel(Connection conn, int level) throws SQLException, NotImplementedException {
            //This is from the class com.arjuna.ats.internal.jdbc.drivers.modifiers.oracle_jndi
            TransactionManager tm = com.arjuna.ats.jta.TransactionManager.transactionManager();
            Transaction tx = null;

            try {
                tx = tm.getTransaction();
            } catch (javax.transaction.SystemException se) {
                /* Ignore: tx is null already */
            }

            if (tx != null && conn.getTransactionIsolation() != level) {
                conn.setTransactionIsolation(level);
            }
        }

        @Override
        public boolean supportsMultipleConnections() throws SQLException, NotImplementedException {
            return true;
        }
    }

    @Override
    public boolean transactionIsActive() throws PipelineException {
        try {
            return transactionManager.getStatus() != Status.STATUS_NO_TRANSACTION;
        } catch (SystemException e) {
            throw new PipelineException(e);
        }
    }
}
