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
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PipelineConsole;

import java.util.Map;
import java.util.concurrent.Callable;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PipelineTaskAttrOpsProxy extends CrudProxy {

    public PipelineTaskAttrOpsProxy() {
    }

    public PipelineTaskAttributes retrieveByTaskId(final long taskId) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        PipelineTaskAttributes result = (PipelineTaskAttributes) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<PipelineTaskAttributes>(){
            public PipelineTaskAttributes call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                
                databaseService.evict("gov.nasa.kepler.hibernate.pi.PipelineTaskAttribute");

                PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                
                databaseService.beginTransaction();
                
                PipelineTaskAttributes r = attrCrud.retrieveByTaskId(taskId);
                
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }

    public Map<Long,PipelineTaskAttributes> retrieveByInstanceId(final long instanceId) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        Map<Long,PipelineTaskAttributes> result = (Map<Long,PipelineTaskAttributes>) PipelineConsole.crudProxyExecutor.
            executeSynchronous(new Callable<Map<Long,PipelineTaskAttributes>>(){
            public Map<Long,PipelineTaskAttributes> call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();

                databaseService.evict("gov.nasa.kepler.hibernate.pi.PipelineTaskAttribute");

                PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                
                databaseService.beginTransaction();
                
                Map<Long, PipelineTaskAttributes> r = attrCrud.retrieveByInstanceId(instanceId);
                
                databaseService.commitTransaction();
                
                return r;
            }
        });
        return result;
    }
}
