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

package gov.nasa.kepler.ui.common;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.ui.proxy.ConversationUtils;

import java.util.concurrent.Executors;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.bushe.swing.event.EventBus;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.Task;
import org.jdesktop.application.TaskService;

/**
 * A {@link TaskService} that provides single-threaded access to the database.
 * This is necessary since we need to share one thread-local session for
 * flushing objects. To use, first register this service with the application
 * framework:
 * 
 * <pre>
 * ApplicationContext.getInstance()
 *     .addTaskService(new DatabaseTaskService());
 * </pre>
 * 
 * Then, assign tasks to it as in the following example:
 * 
 * <pre>
 * &#064;Action(taskService = DatabaseTaskService.NAME)
 * public Task doSomethingWithDatabase() {...}
 * </pre>
 * 
 * @author Bill Wohler
 */
public class DatabaseTaskService extends TaskService {
    private static final Log log = LogFactory.getLog(DatabaseTaskService.class);
    private final ResourceMap resourceMap = Application.getInstance()
        .getContext()
        .getResourceMap(getClass());

    /**
     * Name of thread or TaskService used for database operations. This is used
     * in the taskService parameter of the Action annotation.
     */
    public static final String NAME = "database";

    public DatabaseTaskService() {
        super(NAME, Executors.newSingleThreadExecutor());

        // Initialize database thread. Tasks will call
        // ConversationUtils.save() as needed.
        execute(new Task<Void, Void>(Application.getInstance()) {
            @Override
            protected Void doInBackground() throws Exception {
                log.debug(resourceMap.getString("execute.start"));
                EventBus.publish(new StatusEvent(DatabaseTaskService.this).message(
                    resourceMap.getString("execute.start"))
                    .started());

                log.info("Setting messaging and database services to NOT use XA");
                MessagingServiceFactory.setUseXa(false);
                DatabaseServiceFactory.setUseXa(false);

                ConversationUtils.initialize();

                log.debug(resourceMap.getString("execute.done"));
                // Yes, we mean execute.start here so we see
                // Initializing database...done in the status bar.
                EventBus.publish(new StatusEvent(DatabaseTaskService.this).message(
                    resourceMap.getString("execute.start"))
                    .done());

                return null;
            }
        });
    }
}
