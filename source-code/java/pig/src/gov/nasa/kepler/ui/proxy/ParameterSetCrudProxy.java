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
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PipelineConsole;

import java.util.List;
import java.util.concurrent.Callable;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class ParameterSetCrudProxy extends CrudProxy{

    /**
     * @param databaseService
     */
    public ParameterSetCrudProxy() {
    }

    public void save(final ParameterSet moduleParameterSet) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                updateAuditInfo(moduleParameterSet.getAuditInfo());
                
                crud.create(moduleParameterSet);
                
                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    public void rename(final ParameterSet parameterSet, final String newName) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                updateAuditInfo(parameterSet.getAuditInfo());
                
                crud.rename(parameterSet, newName);
                
                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }

    public List<ParameterSet> retrieveAll() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<ParameterSet> result = (List<ParameterSet>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<ParameterSet>>(){
            public List<ParameterSet> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                List<ParameterSet> r = crud.retrieveAll();
                
                databaseService.flush();
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    public List<ParameterSet> retrieveAllVersionsForName(final String name) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<ParameterSet> result = (List<ParameterSet>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<ParameterSet>>(){
            public List<ParameterSet> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                List<ParameterSet> r = crud.retrieveAllVersionsForName(name);
                
                databaseService.flush();
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    public ParameterSet retrieveLatestVersionForName(final ParameterSetName name) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        ParameterSet result = (ParameterSet) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<ParameterSet>(){
            public ParameterSet call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                ParameterSet r = crud.retrieveLatestVersionForName(name);
                
                databaseService.flush();
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    public List<ParameterSet> retrieveLatestVersions() {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        List<ParameterSet> result = (List<ParameterSet>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<List<ParameterSet>>(){
            public List<ParameterSet> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                List<ParameterSet> r = crud.retrieveLatestVersions();
                
                databaseService.flush();
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.hibernate.pi.ParameterSetCrud#delete(gov.nasa.kepler.hibernate.pi.ParameterSet)
     */
    public void delete(final ParameterSet moduleParameterSet) {
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Runnable(){
            public void run() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                ParameterSetCrud crud = new ParameterSetCrud(databaseService);

                databaseService.beginTransaction();
                
                crud.delete(moduleParameterSet);
                
                databaseService.flush();
                databaseService.commitTransaction();
            }
        });
    }
}
