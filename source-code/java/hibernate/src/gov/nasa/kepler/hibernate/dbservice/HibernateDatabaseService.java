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

import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.AnnotationConfiguration;

/**
 * Implementation of the {@link DatabaseService} for Hibernate.
 * 
 * This class uses {@link AnnotationConfiguration} for configuration,
 * along with {@link AnnotatedPojoList} to auto-scan the class path 
 * for annotated classes
 * 
 * @author tklaus
 *
 */
public final class HibernateDatabaseService 
    extends HibernateDatabaseServiceBase 
    implements DatabaseService, LocalTransactionalResource {
    
    public static final Log log = LogFactory.getLog(HibernateDatabaseService.class);

    private SessionFactory sessionFactory;
    
    protected final ThreadLocal<Session> threadSession = new ThreadLocal<Session>();
    
    /**
     * package-protection to prevent instantiation
     * (use {@link DatabaseServiceFactory} instead)
     *
     */
    HibernateDatabaseService() {
    }

    /**
     * @see gov.nasa.kepler.hibernate.dbservice.DatabaseService#initialize()
     */
    public void initialize() {

        log.info("Hibernate Init: Building configuration");
        hibernateConfig = KeplerHibernateConfiguration.buildHibernateConfiguration(alternatePropertiesSource);

        log.info("Hibernate Init: Initializing SessionFactory");
        sessionFactory = hibernateConfig.buildSessionFactory();

        log.info("Hibernate Init: initialization complete");
    }

    /**
     * Start a new transaction for the current Session
     */
    public void beginLocalTransaction() {
        Session session = null;

        try {
            session = getSession();
            session.beginTransaction();
        } catch (HibernateException e) {
            handleException(e, session);
        }
        
        log.debug("Hibernate transaction started.");
    }

    /**
     * Commit the current transaction and close the Session
     */
    public void commitLocalTransaction() {
        Session session = null;

        try {
            session = getSession();
            session.getTransaction().commit();
        } catch (HibernateException e) {
            handleException(e, session);
        }
    }

    /**
     * Roll back the existing transaction, if any, and close the Session
     */
    public void rollbackLocalTransactionIfActive() {

        Session session = null;

        try {
            session = getSession();

            Transaction transaction = getSession().getTransaction();
            if (transaction != null && transaction.isActive()) {
                transaction.rollback();
                threadSession.remove();
                session.close();
            }
        } catch (HibernateException e) {
            handleException(e, session);
        }
    }

    @Override
    public boolean localTransactionIsActive() {
        Transaction transaction = getSession().getTransaction();
        return transaction != null && transaction.isActive();
    }
    
    public void doSchemaExport() {
        // TODO How do we access the JPA configuration to initialize SchemaExport?
    }

    /**
     * Try to close the current {@link Session} and remove it from the ThreadLocal
     * 
     * @param e
     * @param session
     * @throws PipelineException
     */
    protected void handleException(HibernateException e, Session session) {
        threadSession.remove();
    
        if (session != null) {
            try {
                session.close();
            } catch (Exception e2) {
                log.warn("Failed to close Session after previousfailure", e2);
            }
        }
        throw e;
    }
    
    /**
     * Create a new {@link Session} The lifecycle of a Session spans a single
     * transaction. They should not be cached by the client, used by multiple
     * threads, or used for multiple transactions.
     */
    public Session getSession() {

        Session session = threadSession.get();

        if (session == null) {
            log.info("Creating new Session for Thread: " + Thread.currentThread().getName());
            session = sessionFactory().openSession();
            threadSession.set(session);
        }

        return session;
    }
    
    /**
    * Close the current {@link Session} associated with the calling Thread.
    * It is the responsibility of the caller to close the session
    * (by calling this method) if the session throws a {@link HibernateException}
    * because this invalidates the session. 
    */
   public void closeCurrentSession() {
       Session session = threadSession.get();

       if (session != null) {
           threadSession.remove();
           session.close();
       }
   }
    
    @Deprecated
    public void beginTransaction() {
        beginLocalTransaction();
    }

    @Deprecated
    public void commitTransaction() {
        commitLocalTransaction();
    }

    @Deprecated
    public void rollbackTransactionIfActive() {
        rollbackLocalTransactionIfActive();
    }

    @Override
    protected SessionFactory sessionFactory() {
        return sessionFactory;
    }
}