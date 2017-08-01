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
import gov.nasa.kepler.ui.common.UpdateEvent.Function;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.bushe.swing.event.EventBus;
import org.hibernate.HibernateException;
import org.jdesktop.application.Application;
import org.jdesktop.application.Task;

/**
 * A task which must be used when accessing the database.
 * <p>
 * If the database access results in a {@link HibernateException}, the method
 * {@link #handleFatalError(Throwable)} is called which a subclass should
 * override to log the error and display an error message to the user. A
 * {@code REFRESH UpdateEvent} is then sent on the event bus as a signal that
 * existing data structures are no longer valid and must be replaced with the
 * content of the database.
 * <p>
 * For other errors, the method {@link #handleNonFatalError(Throwable)} is
 * called which subclasses can override to display an informational dialog as
 * well as log the error.
 * <p>
 * In addition, for convenience, the {@link #interrupted(InterruptedException)}
 * method is overridden and simply calls {@link #failed(Throwable)} which is
 * typically what one does anyway.
 * 
 * @author Bill Wohler
 * 
 * @param <T> the result type returned by this Task's {@link #doInBackground()}
 * method
 * @param <V> the type used for carrying out intermediate results by this Task's
 * {@link #publish(Object[])} and {@link #process(java.util.List)} methods
 */
public abstract class DatabaseTask<T, V> extends Task<T, V> {
    private static final Log log = LogFactory.getLog(DatabaseTask.class);

    public DatabaseTask() {
        super(Application.getInstance());
    }

    @Override
    protected final void failed(Throwable e) {
        if (e instanceof HibernateException) {
            handleFatalError(e);

            DatabaseTask<Void, Void> closeDatabaseSessionTask = new DatabaseTask<Void, Void>() {
                @Override
                protected Void doInBackground() throws Exception {
                    DatabaseServiceFactory.getInstance()
                        .closeCurrentSession();
                    return null;
                }

                @Override
                protected void finished() {
                    EventBus.publish(new UpdateEvent<Object>(Function.REFRESH,
                        DatabaseTask.this));
                }
            };
            getApplication().getContext()
                .getTaskService(DatabaseTaskService.NAME)
                .execute(closeDatabaseSessionTask);

        } else {
            handleNonFatalError(e);
        }
    }

    /**
     * Log error and display error message. The default implementation simply
     * logs the error and returns.
     * 
     * @param e the exception that got us into this mess
     */
    protected void handleNonFatalError(Throwable e) {
        log.error(e.getMessage(), e);
    }

    /**
     * Log error and display error message. The default implementation simply
     * logs the error and returns.
     * 
     * @param e the exception that got us into this mess
     */
    protected void handleFatalError(Throwable e) {
        log.fatal(e.getMessage(), e);
    }

    @Override
    protected void interrupted(InterruptedException e) {
        failed(e);
    }
}