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
import gov.nasa.spiffy.common.pi.PipelineException;

import java.lang.reflect.Proxy;
import java.sql.SQLException;
import java.util.Properties;

import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import javax.sql.XADataSource;
import javax.transaction.TransactionManager;
import javax.transaction.xa.XAResource;

import oracle.jdbc.xa.client.OracleXADataSource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hsqldb.jdbc.JDBCDataSource;

import org.postgresql.xa.PGXADataSource;

/**
 * An implementation of the Hibernate database service, but for XA transactions.
 * 
 * @author Sean McCauliff
 * 
 */
public final class XAHibernateDatabaseService extends HibernateDatabaseServiceBase implements DatabaseService,
    XAService {

    private final static String JNDI_DATA_SOURCE_NAME = "XAHibernateDataSourceName";

    private final static String proxiedDataSourceName = "arjunajdbc";

    private final static Log log = LogFactory.getLog(XAHibernateDatabaseService.class);

    private boolean initComplete = false;

    /**
     * This is so that TMLookup can find the transaction manager. Hackery?
     */
    private static TransactionService transactionService;
    private static SessionFactory sessionFactory;

    /**
     * 
     */
    public XAHibernateDatabaseService() {
    }

    public XAResource getXAResource() {
        return null;

        /*
         * This does not work because Hibernate returns a proxy of connnection
         * which just implements Connection and not XAConnection.
         */
    }

    public void doSchemaExport() {
        // TODO: Hey what is this? Currently even the non-XA version of this
        // does nothing.
    }

    public synchronized void initialize() {
    	if (initComplete) {
    		return;
    	}
    	
    	initialize(TransactionServiceFactory.getInstance(true));
    	
    }

    @SuppressWarnings("static-access")
    public synchronized void initialize(TransactionService transactionService) {

        if (initComplete) {
            return;
        }

        this.transactionService = transactionService;

        log.info("Hibernate Init: Building configuration");
        hibernateConfig = KeplerHibernateConfiguration.buildHibernateConfiguration(alternatePropertiesSource);

        String dialect = getPropertyChecked(HibernateConstants.HIBERNATE_DIALECT_PROP);
        String url = getPropertyChecked(HibernateConstants.HIBERNATE_URL_PROP);
        String driver = getPropertyChecked(HibernateConstants.HIBERNATE_DRIVER_PROP);
        String username = getPropertyChecked(HibernateConstants.HIBERNATE_USERNAME_PROP);
        String password = hibernateConfig.getProperty(HibernateConstants.HIBERNATE_PASSWD_PROP);

        SqlDialect sqlDialect = SqlDialect.fromDialectString(dialect);

        XADataSource dataSource = null;
        String debugInfo = null;
        switch (sqlDialect) {
            case ORACLE:
                dataSource = createOracleXADataSource(url, driver, username, password);
                debugInfo = "oracle xa target";
                break;
            case HSQLDB:
                dataSource = createHsqldbXADataSource(url, driver, username, password);
                debugInfo = "hsqldb target";
                break;
            case POSTGRESQL:
                dataSource = createPostgresqlXaDataSource(url, driver, username, password);
                debugInfo = "postgresql target";
                break;
            default:
                throw new IllegalArgumentException("SQL dialect " + sqlDialect
                    + " not supported yet with XA transactions.");
        }

        registerXADataSource(dataSource, debugInfo);

        InitialContext jndiContext = JndiServiceFactory.getService().initialContext();

        hibernateConfig.setProperty("hibernate.connection.datasource", proxiedDataSourceName)
        // hibernateConfig.setProperty("hibernate.connection.datasource",
        // JNDI_DATA_SOURCE_NAME)
            // Not clear if we need the order_updates property.
            // .setProperty("hibernate.order_updates", "true"
            .setProperty("hibernate.transaction.factory_class",
                org.hibernate.transaction.JTATransactionFactory.class.getName())
            .setProperty("hibernate.transaction.manager_lookup_class", TMLookup.class.getName())
            .setProperty("jta.UserTransaction", transactionService.userTransactionName())
            .setProperty("hibernate.jndi." + InitialContext.INITIAL_CONTEXT_FACTORY,
                JndiServiceFactory.getService().initialContextFactoryName());

        try {
            jndiContext.rebind(proxiedDataSourceName, XADataSourceProxy.newInstance(JNDI_DATA_SOURCE_NAME));
        } catch (NamingException e) {
            throw new PipelineException("Failed to register XA data source.", e);
        }

        try {
            Class.forName("com.arjuna.ats.jdbc.TransactionalDriver");
        } catch (ClassNotFoundException cnfe) {
            throw new PipelineException("Can not load Arjuna JDBC driver.", cnfe);
        }
        log.info("Hibernate Init: Initializing SessionFactory");
        sessionFactory = hibernateConfig.buildSessionFactory();

        log.info("Hibernate Init: initialization complete");
        initComplete = true;
    }

    private XADataSource createPostgresqlXaDataSource(String url, String driver, String username, String password) {
        try {
            Class.forName(driver);
        } catch (ClassNotFoundException cnfe) {
            throw new PipelineException("Failed to load postgresql driver \"" + driver + "\".");
        }
        
        PGXADataSource xaDataSource = new PGXADataSource();
        try {
            xaDataSource.setUrl(url);
        } catch (SQLException sqle) {
            throw new PipelineException(sqle);
        }
        xaDataSource.setUser(username);
        xaDataSource.setPassword(password);
        
        return xaDataSource;
    }
    
    private XADataSource createHsqldbXADataSource(String url, String driver, String username, String password) {

        try {
            Class.forName(driver);
        } catch (ClassNotFoundException cnfe) {
            throw new PipelineException("Failed to load JDBC driver \"" + driver + "\".", cnfe);
        }

        JDBCDataSource nonXaDataSource = new JDBCDataSource();
        nonXaDataSource.setDatabase(url);
        nonXaDataSource.setUser(username);
        nonXaDataSource.setPassword(password);

        XADataSource xaDataSource = null;
        try {
            xaDataSource = LastCommitXADataSource.newXADataSource(nonXaDataSource);
        } catch (ClassNotFoundException e) {
            throw new PipelineException("Could not wrap hsqldb data source" + " with XA wrapper.", e);
        }

        return xaDataSource;
    }

    /**
     * @param dataSource
     * @throws PipelineException
     */
    private void registerXADataSource(XADataSource dataSource, String debugInfo) {
        WrappingInvocationHandler invocationHandler = 
        	new WrappingInvocationHandler(dataSource, debugInfo);
        XADataSource xaDataSource = (XADataSource) Proxy.newProxyInstance(getClass().getClassLoader(), new Class[] {
            XADataSource.class, DataSource.class }, invocationHandler);

        InitialContext initialContext = JndiServiceFactory.getService().initialContext();
        try {
            initialContext.rebind(JNDI_DATA_SOURCE_NAME, xaDataSource);
        } catch (NamingException e) {
            throw new PipelineException("Failed to register XA data source with jndi.", e);
        }
    }

    private XADataSource createOracleXADataSource(String url, String driver, String username, String password) {

        OracleXADataSource oracleXaDataSource = null;
        try {
            oracleXaDataSource = new OracleXADataSource();
        } catch (SQLException e) {
            throw new PipelineException("Failed to create XA data source.", e);
        }

        oracleXaDataSource.setURL(url);
        oracleXaDataSource.setUser(username);
        oracleXaDataSource.setPassword(password);

        WrappingInvocationHandler invocationHandler = 
        	new WrappingInvocationHandler(oracleXaDataSource, "oracle", log);

        // Only expose XADataSource because using all interfaces causes
        // JNDI problems.
        XADataSource xaDataSource = (XADataSource) Proxy.newProxyInstance(getClass().getClassLoader(),
            new Class[] { XADataSource.class }, invocationHandler);

        InitialContext initialContext = JndiServiceFactory.getService().initialContext();
        try {
            initialContext.rebind(JNDI_DATA_SOURCE_NAME, xaDataSource);
        } catch (NamingException e) {
            throw new PipelineException("Failed to register XA data source with jndi.", e);
        }

        return oracleXaDataSource;
    }

    @Deprecated
    public void rollbackTransactionIfActive() {
        throw new IllegalStateException("Can not call " + "DatabaseService.rollbackTransactionIfActive() when"
            + " using XA transactions.");
    }

    @Deprecated
    public void beginTransaction() {
        throw new IllegalStateException("Can not call " + "DatabaseService.beginTransaction() when"
            + " using XA transactions.");

    }

    @Deprecated
    public void commitTransaction() {
        throw new IllegalStateException("Can not call " + "DatabaseService.commitTransaction() when"
            + " using XA transactions.");
    }

    /**
     * Hibernate uses this class to get a reference to the TransactionManager.
     * This class and its constuctor must be public so that HIbernate can
     * instantiate it.
     * 
     * @author Sean McCauliff
     * 
     */
    public static class TMLookup implements org.hibernate.transaction.TransactionManagerLookup {

        /**
         * 
         * @param transactionService The kepler transaction service.
         */
        public TMLookup() {
        }

        public TransactionManager getTransactionManager(Properties p) throws HibernateException {

            return transactionService.transactionManager();
        }

        public String getUserTransactionName() {
            return transactionService.userTransactionName();
        }

    }

    @Override
    protected SessionFactory sessionFactory() {
        return sessionFactory;
    }

    public Session getSession() {
        if (sessionFactory == null) {
            throw new IllegalStateException("Session factory not initialized.  "
                + "Did you remember to start a transaction with the transaction service?");
        }
        return sessionFactory.getCurrentSession();
    }

    public void closeCurrentSession() {
        sessionFactory.getCurrentSession().close();
    }

}
