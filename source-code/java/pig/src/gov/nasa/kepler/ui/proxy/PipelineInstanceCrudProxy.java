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
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceFilter;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PipelineConsole;

import java.util.List;
import java.util.concurrent.Callable;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class PipelineInstanceCrudProxy extends CrudProxy{

    /**
     * @param databaseService
     */
    public PipelineInstanceCrudProxy() {
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud#create(gov.nasa.kepler.hibernate.pi.PipelineInstance)
     */
    public void save(final PipelineInstance instance) {
        verifyPrivileges(Privilege.PIPELINE_OPERATIONS);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                crud.create(instance);
                
                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /**
     * Update the name of a pipeline instance (normally by the operator in the PIG)
     * This is done with SQL update rather than via the Hibernate object because we
     * don't want to perturb the other fields which can be set by the worker processes.
     * 
     * @param id
     * @param newName
     */
    public void updateName(final long id, final String newName) {
        verifyPrivileges(Privilege.PIPELINE_OPERATIONS);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                crud.updateName(id, newName);
                
                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud#delete(gov.nasa.kepler.hibernate.pi.PipelineInstance)
     */
    public void delete(final PipelineInstance instance) {
        verifyPrivileges(Privilege.PIPELINE_OPERATIONS);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                crud.delete(instance);
                
                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud#retrieve(long)
     */
    public PipelineInstance retrieve(final long id) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        PipelineInstance result = (PipelineInstance) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<PipelineInstance>(){
            public PipelineInstance call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                PipelineInstance r = crud.retrieve(id);
                
                databaseService.flush();
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud#retrieveAll()
     */
    public List<PipelineInstance> retrieve() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<PipelineInstance> result = (List<PipelineInstance>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<PipelineInstance>>(){
            public List<PipelineInstance> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                List<PipelineInstance> r = crud.retrieveAll();
                
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud#retrieve(PipelineInstanceFilter filter)
     */
    public List<PipelineInstance> retrieve(final PipelineInstanceFilter filter) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<PipelineInstance> result = (List<PipelineInstance>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<PipelineInstance>>(){
            public List<PipelineInstance> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                List<PipelineInstance> r = crud.retrieve(filter);
                
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud#retrieveAllActive()
     */
    public List<PipelineInstance> retrieveAllActive() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<PipelineInstance> result = (List<PipelineInstance>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<PipelineInstance>>(){
            public List<PipelineInstance> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                PipelineInstanceCrud crud = new PipelineInstanceCrud(databaseService);

                databaseService.beginTransaction();
                
                List<PipelineInstance> r = crud.retrieveAllActive();

                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }
}
