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
import gov.nasa.kepler.ui.UiDatabaseException;
import gov.nasa.kepler.ui.models.DatabaseModelRegistry;

import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Contains a single-thread {@link ExecutorService} used by
 * the UI code to invoke the CrudProxy classes.  
 * This ensures that all hibernate calls are made from
 * the same thread, and therefore the same hibernate Session
 * 
 * @author tklaus
 *
 */
public class CrudProxyExecutor {
    private static final Log log = LogFactory.getLog(CrudProxyExecutor.class);

    private ExecutorService executor = Executors.newSingleThreadExecutor();

    public CrudProxyExecutor() {
    }

    /**
     * For tasks that return a result (of type T)
     * 
     * @param <T>
     * @param task
     * @return
     * @throws Exception 
     */
    public <T> T executeSynchronous(Callable<T> task){
        Future<T> result = executor.submit(task);
        
        try {
            return result.get();
        } catch (Exception e) {
            handleError();
            throw new UiDatabaseException(e.getCause());
        }
    }

    /**
     * For tasks that return void
     * 
     * @param task
     */
    public void executeSynchronous(Runnable task){
        Future<?> result = executor.submit(task);
        
        try {
            result.get();
        } catch (Exception e) {
            handleError();
            throw new UiDatabaseException(e.getCause());
        }
    }

    /**
     * Error handler.
     * Close the current Hibernate Session and notify all models
     * 
     */
    private void handleError(){
        executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                log.info("Handling a proxy error, closing session and invalidating all registered models");
                databaseService.closeCurrentSession();
                DatabaseModelRegistry.invalidateModels();
            }
        });
        
    }
}
