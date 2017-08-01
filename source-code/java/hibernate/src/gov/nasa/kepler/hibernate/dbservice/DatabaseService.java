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

import java.sql.Connection;
import java.util.Collection;
import java.util.Properties;

import org.hibernate.HibernateException;
import org.hibernate.Session;

/**
 * Interface used by CRUD classes to initialize and access
 * the persistence layer.
 * 
 * @author tklaus
 *
 */
public interface DatabaseService {

    public static final String DATABASE_HOST_PROPERTY_NAME = "database.host";
    public static final String DATABASE_PORT_PROPERTY_NAME = "database.port";
    public static final String DATABASE_SID_PROPERTY_NAME = "database.sid";
    public static final String DATABASE_URL_PROPERTY_NAME = "database.jdbc.url";
    public static final String DATABASE_DRIVER_PROPERTY_NAME = "database.jdbc.driver";
    public static final String DATABASE_USER_PROPERTY_NAME = "database.user";
    public static final String DATABASE_PASSWORD_PROPERTY_NAME = "database.password";

    /**
     * String in {@link #DATABASE_URL_PROPERTY_NAME} that designates an HSQLDB
     * database.
     */
    public static final String HSQLDB = "hsqldb";

    /**
     * String in {@link #DATABASE_URL_PROPERTY_NAME} that designates a Derby
     * database.
     */
    public static final String DERBY = "derby";

    /**
     * String in {@link #DATABASE_URL_PROPERTY_NAME} that designates an Oracle
     * database.
     */
    public static final String ORACLE = "oracle";
    
    /**
     * Initialize the {@link DatabaseService} implementation.
     * This method should only be called by the {@link DatabaseServiceFactory}
     * @throws PipelineException 
     *
     */
    void initialize() throws PipelineException;
    
    /**
     * Set an alternate source for the Hibernate properties.
     * The default is to use the configuration service.
     * 
     * Used only for testing
     * 
     * @param properties
     */
    void setPropertiesSource(Properties properties);

    /**
     * Start a new {@link Session}/local transaction for the current thread
     *
     */
    void beginTransaction();

    /**
     * Commit the existing local transaction for the current {@link Session}
     *
     */
    void commitTransaction();

    /**
     * Rollback the existing local transaction for the 
     * current {@link Session}, if active
     *
     */
    void rollbackTransactionIfActive();
    
    /**
     * Turns auto-flushing of SQL to the underlying database on or off.
     * This is necessary if you plan to modify persisted objects
     * outside of the context of a transaction (UIs).  If auto-flush
     * is off, the caller is responsible for calling flush() explicitly
     * within the context of a transaction.
     *
     */
    void setAutoFlush(boolean active);

    /**
     * Manually flush SQL to the underlying database.
     * Must be called within the context of a transaction.
     * Only necessary if auto-flush is turned OFF.
     *
     */
    void flush();
    
    /**
     * Evict the specified objects from the Session.
     * This ensures that subsequent queries for these objects
     * will go to the database instead of possibly retrieving them from the cache.
     * Use this method before executing a query if it is possible that another 
     * process or thread has updated the objects in the database.
     * A transaction context is not required.
     *  
     * @param objects
     */
    void evictAll(Collection<?> collection);
    
    /**
     * Evict the specified object from the Session.
     * This ensures that subsequent queries for this object
     * will go to the database instead of possibly retrieving it from the cache.
     * Use this method before executing a query if it is possible that another 
     * process or thread has updated the object in the database.
     * A transaction context is not required.
     *  
     * @param objects
     */
    void evict(Object object);
    
    /** 
     * Completely clear the session. Evict all loaded instances and cancel all 
     * pending saves, updates and deletions. Do not close open iterators or
     *  instances of ScrollableResults.
     *  
     *  This is useful for removing any stale cached results from a previous
     *  session.
     */
    void clear();
    
    /**
     * Returns a {@link DdlInitializer} for the currently configured database
     * 
     * @return
     * @throws PipelineException
     */
    DdlInitializer getDdlInitializer() throws PipelineException;
    
    /**
     * Returns the SQL dialect configured for Hibernate
     * @return
     */
    SqlDialect getSqlDialect();
    
    /**
     * Export the metadata model to the current database (not yet implemented for Hibernate,
     * use DdlInitializer instead)
     *
     */
    void doSchemaExport();

    /**
     * Get the underlying JDBC Connection for the current Hibernate {@link Session}
     * 
     * @return
     */
    Connection getConnection();

    /**
     * Create a new {@link Session} The lifecycle of a Session spans a single
     * transaction. They should not be cached by the client, used by multiple
     * threads, or used for multiple transactions.
     */
    Session getSession();

    /**
     * Close the current {@link Session} associated with the calling Thread.
     * It is the responsibility of the caller to close the session
     * (by calling this method) if the session throws a {@link HibernateException}
     * because this invalidates the session. 
     */
    void closeCurrentSession();
}
