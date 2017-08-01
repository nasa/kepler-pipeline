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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TaskCounts;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.pa.PaOutputs;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.pi.module.remote.MultipleAlgorithmResultsIterator;
import gov.nasa.kepler.pi.pipeline.PipelineExecutor;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;

import java.io.File;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class FailedTaskDebugger {
    private static final Log log = LogFactory.getLog(FailedTaskDebugger.class);

    private static final String CONFIG_PATH = "/path/to/lab.properties";

    // Not needed by debugLaunchTrigger().
    private static final int TASK_ID = 379074;

    // Only needed when using debugLaunchTrigger().
    private static final String TRIGGER_NAME = "Planet Search";
    private static final String MODULE_NAME = "dv";

    public static void main(String[] args) throws Exception {
        setUp();

        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            fileStoreClient.beginLocalFsTransaction();
            databaseService.beginTransaction();

            startProcessingThread(TASK_ID);

            log.info("Completed.");
        } finally {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
            System.exit(0);
        }
    }

    private static void setUp() {
        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            CONFIG_PATH);
    }

    private static void startProcessingThread(final int pipelineTaskId)
        throws Exception {
        Thread thread = new Thread() {
            @Override
            public void run() {
                try {
                    PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
                    PipelineTask pipelineTask = pipelineTaskCrud.retrieve(pipelineTaskId);

                    // Enable one of the following lines.
                    // debugFromStartOfTask(pipelineTask);
                    // debugAsyncLocalFromProcessOutputs(pipelineTask);
                    // debugDoTransition(pipelineTask);
                    // debugLaunchTrigger();

                    DatabaseServiceFactory.getInstance()
                        .flush();
                } catch (Throwable e) {
                    processException(e);
                }
            }

            private void debugFromStartOfTask(PipelineTask pipelineTask)
                throws Exception {
                PipelineModule pipelineModule = pipelineTask.getPipelineInstanceNode()
                    .getPipelineModuleDefinition()
                    .getImplementingClass()
                    .newInstance();
                pipelineModule.initialize(pipelineTask);
                pipelineModule.process(pipelineTask.getPipelineInstance(),
                    pipelineTask);
            }

            private void debugAsyncLocalFromProcessOutputs(
                PipelineTask pipelineTask) throws Exception {
                MultipleAlgorithmResultsIterator outputs = new MultipleAlgorithmResultsIterator(
                    "pa", new File("/path/to/pa-matlab-387-9485/"),
                    PaOutputs.class);

                PaPipelineModule pipelineModule = new PaPipelineModule();
                pipelineModule.processOutputs(pipelineTask, outputs);
            }

            private void debugDoTransition(PipelineTask pipelineTask) {
                PipelineExecutor pipelineExecutor = new PipelineExecutor();
                pipelineExecutor.doTransition(
                    pipelineTask.getPipelineInstance(), pipelineTask,
                    new TaskCounts(0, 0, 0, 0));
            }

            private void debugLaunchTrigger() {
                TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
                TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(TRIGGER_NAME);

                PipelineDefinitionCrud pipelineDefinitionCrud = new PipelineDefinitionCrud();
                PipelineDefinition pipelineDefinition = pipelineDefinitionCrud.retrieveLatestVersionForName(triggerDefinition.getPipelineDefinitionName());

                PipelineDefinitionNode pipelineDefinitionNode = getPipelineDefinitionNode(pipelineDefinition.getRootNodes());

                PipelineOperations pipelineOps = new PipelineOperations();
                pipelineOps.fireTrigger(triggerDefinition, "instanceName",
                    pipelineDefinitionNode, pipelineDefinitionNode);
            }

            private PipelineDefinitionNode getPipelineDefinitionNode(
                List<PipelineDefinitionNode> nodes) {
                PipelineDefinitionNode returnNode = null;
                for (PipelineDefinitionNode node : nodes) {
                    if (node.getModuleName()
                        .getName()
                        .equals(MODULE_NAME)) {
                        returnNode = node;
                    }

                    PipelineDefinitionNode nodeFromRecursiveCall = getPipelineDefinitionNode(node.getNextNodes());
                    if (nodeFromRecursiveCall != null) {
                        returnNode = nodeFromRecursiveCall;
                    }
                }

                return returnNode;
            }
        };
        thread.start();
        thread.join();
    }

    private static void processException(Throwable e) {
        log.error("Caught exception:  ", e);
        log.error("Terminated.");
        System.exit(1);
    }
}
