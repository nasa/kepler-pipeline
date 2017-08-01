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

package gov.nasa.kepler.hibernate.pi;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Date;

/**
 * Creates a debug pipeline task object. This is useful for testing hibernate
 * objects that need a pipeline task for referential integrity.
 * 
 * @author Sean McCauliff
 * 
 */
public class FakePipelineTaskFactory {

    /**
     * 
     * @return A pipeline task object that exists in the database.  non-null.
     */
    public PipelineTask newTask() {
        return newTask(true);
    }

    /**
     * 
     * @param inDb When false this returns a non-persisted, but otherwise valid object.
     * @return non-null.
     */
    public PipelineTask newTask(boolean inDb) {
        UserCrud userCrud = new UserCrud();

        PipelineDefinitionCrud pipelineDefinitionCrud = new PipelineDefinitionCrud();

        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

        PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud();
        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();

        PipelineTask pipelineTask = null;

        try {
            DatabaseServiceFactory.getInstance()
                .beginTransaction();
            // create users
            User testUser = new User("unit-test", "Unit-Test", "unit-test",
                "unit-test@kepler.nasa.gov", "x111");
            if (inDb) {
                userCrud.createUser(testUser);
            }

            // create a module param set def
            ParameterSet parameterSet = new ParameterSet(new AuditInfo(
                testUser, new Date()), "test mps1");
            parameterSet.setParameters(new BeanWrapper<Parameters>(
                new TestModuleParameters()));
            if (inDb) {
                parameterSetCrud.create(parameterSet);
            }

            // create a module def
            PipelineModuleDefinition moduleDef = new PipelineModuleDefinition(
                "Test-1");
            if (inDb) {
                pipelineModuleDefinitionCrud.create(moduleDef);
            }

            // create some pipeline def nodes
            PipelineDefinitionNode pipelineDefNode1 = new PipelineDefinitionNode(
                moduleDef.getName());
            pipelineDefNode1.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
                new TestUowTaskGenerator()));
            pipelineDefNode1.setStartNewUow(true);

            PipelineDefinition pipelineDef = new PipelineDefinition(
                new AuditInfo(testUser, new Date()), "test pipeline name");

            pipelineDef.getRootNodes()
                .add(pipelineDefNode1);
            if (inDb) {
                pipelineDefinitionCrud.create(pipelineDef);
            }

            PipelineInstance pipelineInstance = new PipelineInstance(
                pipelineDef);
            pipelineInstance.putParameterSet(new ClassWrapper<Parameters>(
                new TestPipelineParameters()), parameterSet);
            if (inDb) {
                pipelineInstanceCrud.create(pipelineInstance);
            }

            PipelineInstanceNode pipelineInstanceNode1 = new PipelineInstanceNode(
                pipelineInstance, pipelineDefNode1, moduleDef);
            if (inDb) {
                pipelineInstanceNodeCrud.create(pipelineInstanceNode1);
            }

            pipelineTask = new PipelineTask(pipelineInstance, pipelineDefNode1,
                pipelineInstanceNode1);
            pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(
                new TestUowTask()));
            pipelineTask.setWorkerHost("test worker name");
            pipelineTask.setSoftwareRevision("42");
            pipelineTask.setState(PipelineTask.State.COMPLETED);
            if (inDb) {
                pipelineTaskCrud.create(pipelineTask);
            }
            DatabaseServiceFactory.getInstance()
                .commitTransaction();
        } finally {
            DatabaseServiceFactory.getInstance()
                .rollbackTransactionIfActive();
        }

        return pipelineTask;
    }

    public static void main(String[] argv) throws Exception {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        PipelineTask task = null;
        try {
            dbService.beginTransaction();
            FakePipelineTaskFactory me = new FakePipelineTaskFactory();
            task = me.newTask();
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }

        System.out.println("Created task with id " + task.getId());

    }
}
