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

package gov.nasa.kepler.services.database;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.lang.WrappingInvocationHandler;

import java.lang.reflect.Proxy;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Hashtable;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.Session;
import javax.jms.TextMessage;
import javax.jms.Topic;
import javax.jms.TopicConnection;
import javax.jms.TopicPublisher;
import javax.jms.TopicSession;
import javax.jms.TopicSubscriber;
import javax.jms.XATopicConnection;
import javax.jms.XATopicSession;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.sql.XADataSource;
import javax.transaction.Status;
import javax.transaction.TransactionManager;

import oracle.jdbc.xa.client.OracleXADataSource;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.ActiveMQPrefetchPolicy;
import org.apache.activemq.ActiveMQXAConnectionFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DistributedTransactionTest {
    
    private final static String JNDI_DATA_SOURCE_NAME =  "blah";
    
    private final static String JNDI_FACTORY =
        org.codehaus.spice.jndikit.memory.StaticMemoryInitialContextFactory.class.getName();
    private final static String arjunaJDBC = "jdbc:arjuna:";
    
    private TransactionManager transactionManager;
    private Hashtable<Object,Object> jndiProperties = 
            new Hashtable<Object,Object>();
    
    @Before
    public void setUp() throws Exception {
        OracleXADataSource oracleXaDataSource =  new OracleXADataSource();
        oracleXaDataSource.setURL("jdbc:oracle:thin:@darkmatter.arc.nasa.gov:1521:orcl");
        oracleXaDataSource.setUser("smccauliff");
        oracleXaDataSource.setPassword("smccauliff");
        
        WrappingInvocationHandler invocationHandler = 
            new WrappingInvocationHandler(oracleXaDataSource, "oracle");
        //Only expose XADataSource because using all interfaces causes
        //JNDI problems.
        XADataSource xaDataSource = (XADataSource)
            Proxy.newProxyInstance(getClass().getClassLoader(), 
                                   new Class[] {XADataSource.class},
                                   invocationHandler);
        
        
        jndiProperties.put(Context.INITIAL_CONTEXT_FACTORY, JNDI_FACTORY);
        //Arjuna seems to need to following property set.  I think they
        //have misunderstood constants.
        System.setProperty("Context.INITIAL_CONTEXT_FACTORY", JNDI_FACTORY);
        InitialContext initialContext = new InitialContext(jndiProperties);
        initialContext.rebind(JNDI_DATA_SOURCE_NAME, xaDataSource);
        transactionManager = 
            com.arjuna.ats.jta.TransactionManager.transactionManager();
        Class.forName("com.arjuna.ats.jdbc.TransactionalDriver");
        
    }

    @After
    public void tearDown() throws Exception {
    }
    
    @Test
    public void oracleDistributedTransactionTest() throws Exception {
        transactionManager.begin();
        test("B");
        transactionManager.commit();
    }
    
    private void test(String testString) throws Exception {
        
        try {
            Connection sqlConn = 
                DriverManager.getConnection(arjunaJDBC+JNDI_DATA_SOURCE_NAME);
            Statement stmt = sqlConn.createStatement();
            stmt.executeUpdate("insert into blah(A) values ('"+testString+"')");
        } catch (Exception e) {
            if (transactionManager != null) {
                if (transactionManager.getStatus() == Status.STATUS_ACTIVE) {
                    transactionManager.rollback();
                }
            }
            throw e;
        } 
    }
    
    @Test
    public void oracleDistributedTransactionTestMulti() throws Exception {
        final int maxThreads = 32;
        final AtomicBoolean threadOK = new AtomicBoolean(true);
        final CountDownLatch start = new CountDownLatch(1);
        final CountDownLatch done = new CountDownLatch(maxThreads);
        
        for (int i=0; i < maxThreads; i++) {
            final int id = i;
            Thread t = new Thread(new Runnable() {

                @Override
                public void run() {
                    try {
                        start.await();
                        transactionManager.begin();
                        test(Integer.toString(id));
                        transactionManager.commit();
                    } catch (Throwable t) {
                        t.printStackTrace();
                        threadOK.set(false);
                    } finally {
                        done.countDown();
                    }
                }
                
            });
            t.start();
        }
        
        start.countDown();
        done.await();
        assertTrue("A thread encountered an error.", threadOK.get());
    }
    
    @Test
    public void oraclePlusJmsDistributedTransaction() throws Exception {
        final String topicName = "DistributedTransactionTest";
        final String messageTxt = "Hello World.";
        final CountDownLatch messageReceived = new CountDownLatch(1);
        {
        ActiveMQConnectionFactory factory = 
            new ActiveMQConnectionFactory("tcp://host:port");
        ActiveMQPrefetchPolicy prefetchPolicy = new ActiveMQPrefetchPolicy();

        prefetchPolicy.setQueuePrefetch(0); 
        factory.setPrefetchPolicy(prefetchPolicy);
        
        TopicConnection jmsConn = factory.createTopicConnection();
        jmsConn.start();
        TopicSession session = jmsConn.createTopicSession(false, Session.AUTO_ACKNOWLEDGE);
        Topic readTopic = session.createTopic(topicName);
        TopicSubscriber subscriber = session.createSubscriber(readTopic);
        if (true) {
        subscriber.setMessageListener(new MessageListener() {
            @Override
            public void onMessage(Message mess) {
                try {
                    TextMessage txt = (TextMessage) mess;
                    if (messageTxt.equals(txt.getText())) {
                        messageReceived.countDown();
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        });
        }
        }
        
        transactionManager.begin();
        
        ActiveMQXAConnectionFactory xafactory = 
            new ActiveMQXAConnectionFactory("tcp://host:port");

        ActiveMQPrefetchPolicy xaprefetchPolicy = new ActiveMQPrefetchPolicy();
        
        xaprefetchPolicy.setQueuePrefetch(0); 
        xafactory.setPrefetchPolicy(xaprefetchPolicy);
        
        XATopicConnection xajmsConn = xafactory.createXATopicConnection();     
        xajmsConn.start();
        XATopicSession xasession = xajmsConn.createXATopicSession();
        Topic topic = null;
        
        transactionManager.getTransaction().enlistResource(xasession.getXAResource());
        
        Connection sqlConn = 
            DriverManager.getConnection(arjunaJDBC+JNDI_DATA_SOURCE_NAME);
        Statement stmt = sqlConn.createStatement();
        stmt.executeUpdate("insert into blah (A) values ('With JMS')");
        topic = xasession.createTopic(topicName);
        TopicPublisher publisher = xasession.getTopicSession().createPublisher(topic);
        System.out.println("Destination " + publisher.getDestination());
        publisher.publish(topic, xasession.createTextMessage(messageTxt));
        Thread.sleep(1000);
        assertFalse("Message should not have been sent.",
                    messageReceived.await(0, TimeUnit.SECONDS));
        transactionManager.commit();
        
        assertTrue("Message not received.", messageReceived.await(3, TimeUnit.SECONDS));

    }


    /**
    public void testHibernate() throws Exception {
        InitialContext jndiContext = new InitialContext(jndiProperties);
        jndiContext.rebind("arjunajdbc", new DataSource() {

            public Connection getConnection() throws SQLException {
                return DriverManager.getConnection(arjunaJDBC+JNDI_DATA_SOURCE_NAME,
                                            "username","password");
            }

            public Connection getConnection(String username, String password) throws SQLException {
                return DriverManager.getConnection(arjunaJDBC+JNDI_DATA_SOURCE_NAME,
                        username, password);
            }

            public PrintWriter getLogWriter() throws SQLException { 
                return DriverManager.getLogWriter();

            }

            public int getLoginTimeout() throws SQLException {
                return 60;
            }

            public void setLogWriter(PrintWriter out) throws SQLException {
                
                
            }

            public void setLoginTimeout(int seconds) throws SQLException {
                
            }

            public boolean isWrapperFor(Class<?> iface) throws SQLException {
                return false;
            }

            public <T> T unwrap(Class<T> iface) throws SQLException {
                return null;
            }


        });
        
        UserTransaction userTransaction =
            com.arjuna.ats.jta.UserTransaction.userTransaction();
        jndiContext.rebind("userTransaction", userTransaction);
        
        org.hibernate.cfg.Configuration cfg = new org.hibernate.cfg.Configuration();
        cfg.addClass(HibernateMe.class)
        .setProperty("hibernate.connection.datasource", "arjunajdbc")
        .setProperty("hibernate.order_updates", "true")
        .setProperty("hibernate.dialect","org.hibernate.dialect.Oracle9Dialect")
        .setProperty("hibernate.transaction.factory_class", 
            "org.hibernate.transaction.JTATransactionFactory")
        .setProperty("hibernate.transaction.manager_lookup_class",
                      TMLookup.class.getName())
        .setProperty("jta.UserTransaction", "userTransaction")
        .setProperty("hibernate.jndi."+InitialContext.INITIAL_CONTEXT_FACTORY,
                     JNDI_FACTORY);
        
        transactionManager.begin();
        org.hibernate.SessionFactory sessionFactory = cfg.buildSessionFactory();
        org.hibernate.Session hSession = sessionFactory.getCurrentSession();
        
        HibernateMe well = new HibernateMe();
        //well.setId(2342);
        well.setValue("Does this work?");
        hSession.saveOrUpdate(well);
        HibernateMe inserted =(HibernateMe)  hSession.load(HibernateMe.class, new Integer(111));
        assertTrue("Inserted value not read.",
                    inserted.getValue().equals("inserted value"));
        
        transactionManager.commit();
        
        
    }
    
    public void longTransaction() throws Exception {
        transactionManager.begin();
        transactionManager.setTransactionTimeout(60*60); //one hour
        transactionManager.getTransaction().enlistResource(new XAResource() {
            private final int XTO = 60*60;
            
            public void commit(Xid arg0, boolean arg1) throws XAException {
                log.info("Transaction commit.");
                try {
                    Thread.sleep((XTO-1)*1000);
                } catch (InterruptedException ie) {
                    throw new XAException();
                }
                
            }

            public void end(Xid arg0, int arg1) throws XAException {
                log.info("Transaction end called.");
                
            }

            public void forget(Xid arg0) throws XAException {
                log.info("Transaction forget called.");
                
            }

            public int getTransactionTimeout() throws XAException {
                return XTO;
            }

            public boolean isSameRM(XAResource arg0) throws XAException {
                return arg0 == this;
            }

            public int prepare(Xid arg0) throws XAException {
                log.info("Transaction prepare called.");
                try {
                    Thread.sleep((XTO-1)*1000);
                } catch (InterruptedException ie) {
                    
                }
                return XA_OK;
            }

            public Xid[] recover(int arg0) throws XAException {
                return new Xid[0];
            }

            public void rollback(Xid arg0) throws XAException {
                log.info("rollback");
                
            }

            public boolean setTransactionTimeout(int arg0) throws XAException {
                return false;
            }

            public void start(Xid arg0, int arg1) throws XAException {
                log.info("Transaction start called");
            }
            
        });
        
        test("Long time.");
        transactionManager.commit();
    }
    
    public static class TMLookup implements org.hibernate.transaction.TransactionManagerLookup {
        
        public TMLookup() {
            
        }
        
        public TransactionManager getTransactionManager(Properties p) 
            throws org.hibernate.HibernateException {
            
            return com.arjuna.ats.jta.TransactionManager.transactionManager();
        }

        public String getUserTransactionName() {
            return "userTransaction";
        }
        
    }
    */
}
