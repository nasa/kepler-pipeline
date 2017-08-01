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

package gov.nasa.kepler.ui.proxy;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.AuditInfo;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Collection;
import java.util.Date;
import java.util.concurrent.Callable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.FlushMode;

/**
 * Base class for all PIG CrudProxy classes.
 * 
 * @author tklaus
 *
 */
public abstract class CrudProxy {
    private static final Log log = LogFactory.getLog(CrudProxy.class);

    public CrudProxy() {
    }
    
    /**
     * Called once at startup.
     * Ensures that the database and messaging services used by the executor
     * thread never use XA in the PIG.
     */
    public static final void initialize(){
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                log.info("Setting messaging and database services to NOT use XA");
                MessagingServiceFactory.setUseXa(false);
                DatabaseServiceFactory.setUseXa(false);
                
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                databaseService.getSession().setFlushMode(FlushMode.MANUAL);
            }
        });
    }
    
    /**
     * Update the specified AuditInfo object with the currently logged
     * in user and the current time.  Should be called by subclasses when
     * creating/updating entities that have AuditInfo.
     * 
     * @param auditInfo
     */
    protected void updateAuditInfo(AuditInfo auditInfo){
        
        if(auditInfo == null){
            log.warn("AuditInfo is null, not updating");
            return;
        }
        
        User user = PipelineConsole.currentUser;
        
        if(user != null){
            auditInfo.setLastChangedUser(user);
            auditInfo.setLastChangedTime(new Date());
        }
    }
    
    /**
     * Verify that the currently-logged in User has the proper
     * Privilege to perform the requested operation.
     * Always returns true if there is no logged in user (dev mode)
     *  
     * @param requestedOperation
     * @return
     */
    public static void verifyPrivileges(Privilege requestedOperation){
        User user = PipelineConsole.currentUser;
        
        if(user != null && !user.hasPrivilege(requestedOperation.toString())){
            throw new PigSecurityException("You do not have permission to perform this action");
        }
    }
    
    /**
     * Persist any dirty objects
     * Protected so that sub-classes van verify the correct privileges
     * 
     * @throws PipelineException
     */
    protected void saveChanges() {
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();

                databaseService.beginTransaction();

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /**
     * Proxy method for DatabaseService.evictAll()
     * Uses {@link CrudProxyExecutor} to invoke the {@link DatabaseService}
     * method from the dedicated database thread
     * 
     * @param collection
     * @throws PipelineException 
     */
    public void evictAll(final Collection<?> collection) throws PipelineException{
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<Object>(){
            public Object call(){
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                databaseService.evictAll(collection);
                return null;
            }
        });
    }

    /**
     * Proxy method for DatabaseService.evict()
     * Uses {@link CrudProxyExecutor} to invoke the {@link DatabaseService}
     * method from the dedicated database thread
     * 
     * @param object
     */
    public void evict(final Object object){
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                databaseService.evict(object);
            }
        });
    }
}
