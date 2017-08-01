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
import gov.nasa.kepler.hibernate.dr.DispatcherTrigger;
import gov.nasa.kepler.hibernate.dr.DispatcherTriggerCrud;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;
import java.util.concurrent.Callable;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DispatcherTriggerCrudProxy extends CrudProxy {

    /**
     * @param databaseService
     */
    public DispatcherTriggerCrudProxy() {
    }

    /**
     * Persist a new {@link DispatcherTrigger} instance
     * 
     * @param dispatcherTrigger
     * @throws PipelineException
     */
    public void create(final DispatcherTrigger dispatcherTrigger) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                DispatcherTriggerCrud crud = new DispatcherTriggerCrud(databaseService);

                databaseService.beginTransaction();

                crud.create(dispatcherTrigger);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /**
     * Retrieve the {@link DispatcherTrigger} for a given dispatcher class
     * 
     * @throws PipelineException
     */
    public DispatcherTrigger retrieve(final String dispatcherClass) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        DispatcherTrigger result = (DispatcherTrigger) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<DispatcherTrigger>() {
            public DispatcherTrigger call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                DispatcherTriggerCrud crud = new DispatcherTriggerCrud(databaseService);

                databaseService.beginTransaction();

                DispatcherTrigger result = crud.retrieve(dispatcherClass);

                databaseService.flush();
                databaseService.commitTransaction();

                return result;
            }
        });
        return result;
    }

    /**
     * Retrieve all {@link DispatcherTrigger}
     * 
     * @throws PipelineException
     */
    public List<DispatcherTrigger> retrieveAll() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<DispatcherTrigger> results = (List<DispatcherTrigger>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<DispatcherTrigger>>() {
            public List<DispatcherTrigger> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                DispatcherTriggerCrud crud = new DispatcherTriggerCrud(databaseService);

                databaseService.beginTransaction();

                List<DispatcherTrigger> r = crud.retrieveAll();

                databaseService.flush();
                databaseService.commitTransaction();

                return r;
            }
        });
        return results;
    }

    /**
     * 
     * @param dispatcherTrigger
     */
    public void delete(final DispatcherTrigger dispatcherTrigger) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable() {
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                DispatcherTriggerCrud crud = new DispatcherTriggerCrud(databaseService);

                databaseService.beginTransaction();

                crud.delete(dispatcherTrigger);

                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.ui.proxy.CrudProxy#saveChanges()
     */
    @Override
    public void saveChanges() {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        //TODO: update AuditInfo
        super.saveChanges();
    }
}
