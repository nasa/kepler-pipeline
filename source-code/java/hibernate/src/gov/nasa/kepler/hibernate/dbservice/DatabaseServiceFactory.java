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

import gov.nasa.spiffy.common.lang.BooleanThreadLocal;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 *
 */
public class DatabaseServiceFactory {

    private static DatabaseService localInstance = null;
    private static DatabaseService xaInstance = null;
    private static final Log log = LogFactory.getLog(DatabaseServiceFactory.class);
    
    /** When true getInstance() can be called because it is involved
     * with a transaction associated with the current thread (or could be)
     * else an exception should be thrown.
     */
    private static final ThreadLocal<Boolean> usingLocalService =
        new BooleanThreadLocal(Boolean.TRUE);
        
    private static final ThreadLocal<Boolean> usingXaService =
        new BooleanThreadLocal(Boolean.TRUE);
    
    /**
     * When true getInstance() will return the XA version of this service
     * else it will return the local version of this service.
     */
    private static final BooleanThreadLocal isXa = 
        new BooleanThreadLocal(Boolean.FALSE);
    
    private  DatabaseServiceFactory() {
    }
    

    public static synchronized void setUseXa(boolean useXaForThisThread) {
        isXa.set(useXaForThisThread);

    }
    
    public static synchronized DatabaseService getInstance(){
        if (log.isTraceEnabled()) {
            log.trace("Returning " + ((isXa.get()) ? "xa" : "local") + " DatabaseService");
        }
        return getInstance(isXa.get());
    }
    
    public static synchronized DatabaseService getInstance(boolean xa){
        
        if (xa) {
            
            if (!usingXaService.get()) {
                throw new PipelineException("A transaction was started but the " +
                                                                "DatabaseService was not included.");
            }
            
            if (xaInstance != null) {
                return xaInstance;
            }
            
            xaInstance = new XAHibernateDatabaseService();
            xaInstance.initialize();
            return xaInstance;
        } else {
            if (!usingLocalService.get()) {
                throw new PipelineException("A transaction was started but the " +
                                                                "DatabaseService was not included.");
            }
            
            if (localInstance != null) {
                return localInstance;
            }
            
            localInstance = new HibernateDatabaseService();
            localInstance.initialize();
            return localInstance;
        }
    }
    
    /**
     * Create an instance using the specified Hibernate properties.
     * This instance is not cached, so a new instance will be returned
     * each time.
     * 
     * This is only intended to be used by test code that keeps a reference
     * to the returned instance.  The use case is to allow tools that read from
     * one database and write to another.  If the destination is hsqldb, this
     * provides a small-scale export capability since hsqldb can be configured to persist
     * it's state as txt files containing sql insert statements (very useful for seeding
     * test databases used for automated tests).  
     * 
     * Another use case is to verify user-entered credentials.
     * 
     * XA is not supported for these instances
     * 
     * @param alternatePropertiesSource
     * @return
     * @throws PipelineException
     */
    public static synchronized DatabaseService getInstance(Properties alternatePropertiesSource){
        
        if(alternatePropertiesSource == null){
            throw new PipelineException("alternatePropertiesSource must not be null!");
        }

        HibernateDatabaseService instance = new HibernateDatabaseService();
        instance.setPropertiesSource(alternatePropertiesSource);
        instance.initialize();
        return instance;
    }
    
    /**
     * Marks the current thread as being involved in a transaction, but not
     * utilizing this service.
     *
     */
    public static synchronized void markNotUsingService(boolean xa) {
        if (xa) {
            usingXaService.set(Boolean.FALSE);
        } else {
            usingLocalService.set(Boolean.FALSE);
        }
    }
    
    public static synchronized void clearNotUsingService(boolean xa) {
        if (xa) {
            usingXaService.set(Boolean.TRUE);
        } else {
            usingLocalService.set(Boolean.TRUE);
        }
    }
    
    /**
     * Clears the cached handles so that the next call to {@link #getInstance()}
     * will initialize the database system. This is usually just useful for
     * feature tests which actually restart the database server.
     */
    public static synchronized void reset() {
        localInstance = null;
        xaInstance = null;
    }
}
