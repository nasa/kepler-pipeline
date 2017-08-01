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

import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.SocEnvVars;
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
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.remote.MultipleAlgorithmResultsIterator;
import gov.nasa.kepler.pi.pipeline.PipelineExecutor;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;

import java.io.File;
import java.lang.reflect.InvocationTargetException;
import java.util.List;

import javax.jms.IllegalStateException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class PipelineTaskDebugger {

    private static final Log log = LogFactory.getLog(PipelineTaskDebugger.class);

    private static final String TASK_DEBUGGER_PREFIX = "ftd.";
    private static final String PIPELINE_TASK_ID_PROP = TASK_DEBUGGER_PREFIX
        + "pipelineTaskId";
    private static final String DEBUG_ASYNC_ENABLED_PROP = TASK_DEBUGGER_PREFIX
        + "debugAsyncEnabled";
    private static final String DEBUG_FROM_START_ENABLED_PROP = TASK_DEBUGGER_PREFIX
        + "debugFromStartEnabled";
    private static final String DEBUG_LAUNCH_TRIGGER_ENABLED_PROP = TASK_DEBUGGER_PREFIX
        + "debugLaunchTriggerEnabled";
    private static final String TASK_DIR_PROP = TASK_DEBUGGER_PREFIX
        + "taskDir";
    private static final String PERSISTABLE_OUTPUT_CLASS_NAME_PROP = TASK_DEBUGGER_PREFIX
        + "persistableClassName";
    private static final String KEPLER_PROPERTIES_PROP = TASK_DEBUGGER_PREFIX
        + "keplerProperties";
    private static final String MODULE_NAME_PROP = TASK_DEBUGGER_PREFIX
        + "moduleName";
    private static final String TRIGGER_NAME_PROP = TASK_DEBUGGER_PREFIX
        + "triggerName";

    private int pipelineTaskId;
    private boolean debugAsyncEnabled;
    private boolean debugFromStartEnabled;
    private boolean debugLaunchTriggerEnabled;
    private String taskDir;
    private String persistableOutputClassName;
    private String keplerProperties;
    private String moduleName;
    private String triggerName;

    // ftd.pipelineTaskId=35
    // ftd.keplerProperties=/path/to/dist/etc/kepler.properties
    // ftd.debugAsyncEnabled=false
    // ftd.debugFromStartEnabled=false
    // ftd.debugLaunchTriggerEnabled=false
    // ftd.taskDir=${pi.worker.moduleExe.dataDir}/pa-matlab-6-35
    // ftd.persistableClassName=gov.nasa.kepler.pa.PaOutputs
    // ftd.moduleName=pa
    // ftd.triggerName=PHOTOMETRY_LC

    /*
     * Either set properties, ftd.*, or provide explicit values as the defaults
     * in the config calls in this constructor.
     */
    public PipelineTaskDebugger(Configuration config) {
        // used by all
        pipelineTaskId = config.getInt(PIPELINE_TASK_ID_PROP, 35);
        keplerProperties = config.getString(KEPLER_PROPERTIES_PROP,
            SocEnvVars.getLocalDistDir() + "/etc/"
                + FilenameConstants.KEPLER_CONFIG);

        debugAsyncEnabled = config.getBoolean(DEBUG_ASYNC_ENABLED_PROP, true);
        debugFromStartEnabled = config.getBoolean(
            DEBUG_FROM_START_ENABLED_PROP, false);
        debugLaunchTriggerEnabled = config.getBoolean(
            DEBUG_LAUNCH_TRIGGER_ENABLED_PROP, false);

        if (isDebugAsyncEnabled()) {
            persistableOutputClassName = config.getString(
                PERSISTABLE_OUTPUT_CLASS_NAME_PROP,
                "gov.nasa.kepler.pa.PaOutputs");
            taskDir = config.getString(TASK_DIR_PROP,
                "/path/to/dev/task-data/pa-matlab-6-35");
        } else if (isDebugLaunchTriggerEnabled()) {
            moduleName = config.getString(MODULE_NAME_PROP, "pa");
            triggerName = config.getString(TRIGGER_NAME_PROP, "PHOTOMETRY_LC");
        }
    }

    public static void main(String[] args) throws Exception {
        PipelineTaskDebugger pipelineTaskDebugger = new PipelineTaskDebugger(
            ConfigurationServiceFactory.getInstance());
        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            pipelineTaskDebugger.getKeplerProperties());
        FileStoreClient fileStoreClient = FileStoreClientFactory.getInstance();
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        try {
            fileStoreClient.beginLocalFsTransaction();
            databaseService.beginTransaction();

            startProcessingThread(pipelineTaskDebugger);

            log.info("Completed.");
        } finally {
            databaseService.rollbackTransactionIfActive();
            fileStoreClient.rollbackLocalFsTransactionIfActive();
        }

        System.exit(0);
    }

    private static void startProcessingThread(final PipelineTaskDebugger pipelineTaskDebugger)
        throws Exception {
        Thread thread = new Thread() {
            @Override
            public void run() {
                try {
                    PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
                    PipelineTask pipelineTask = pipelineTaskCrud.retrieve(pipelineTaskDebugger.getPipelineTaskId());

                    dumpConfig(pipelineTaskDebugger, pipelineTask);
                    if (pipelineTaskDebugger.isDebugAsyncEnabled()) {
                        debugAsyncLocalFromProcessOutputs(pipelineTask);
                    } else if (pipelineTaskDebugger.isDebugFromStartEnabled()) {
                        debugFromStartOfTask(pipelineTask);
                    } else if (pipelineTaskDebugger.isDebugLaunchTriggerEnabled()) {
                        debugLaunchTrigger();
                    } else {
                        debugDoTransition(pipelineTask);
                    }

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

                try {
                    PipelineModule pipelineModule = pipelineTask.getPipelineInstanceNode()
                        .getPipelineModuleDefinition()
                        .getImplementingClass()
                        .newInstance();
                    Object moduleName = pipelineModule.getClass()
                        .getDeclaredMethod("getModuleName")
                        .invoke(pipelineModule);
                    if (!(moduleName instanceof String)) {
                        throw new IllegalStateException(
                            String.format(
                                "%s: invalid class, getModuleName method did not return String",
                                pipelineTask.getPipelineInstanceNode()
                                    .getPipelineModuleDefinition()
                                    .getImplementingClass()
                                    .getClassName()));
                    }
                    MultipleAlgorithmResultsIterator outputs = new MultipleAlgorithmResultsIterator(
                        (String) moduleName,
                        new File(pipelineTaskDebugger.getTaskDir()),
                        Class.forName(pipelineTaskDebugger.getPersistableOutputClassName()));
                    pipelineModule.initialize(pipelineTask);

                    if (pipelineModule instanceof AsyncPipelineModule) {
                        AsyncPipelineModule asyncPipelineModule = (AsyncPipelineModule) pipelineModule;
                        asyncPipelineModule.processOutputs(pipelineTask,
                            outputs);
                    } else {
                        log.error("Configured pipelineModule must implement AsyncPipelineModule.");
                    }
                } catch (NoSuchMethodException nsme) {
                    log.error(nsme.getMessage(), nsme);
                    throw nsme;
                } catch (SecurityException se) {
                    log.error(se.getMessage(), se);
                    throw se;
                } catch (IllegalAccessException iae) {
                    log.error(iae.getMessage(), iae);
                    throw iae;
                } catch (IllegalArgumentException iae) {
                    log.error(iae.getMessage(), iae);
                    throw iae;
                } catch (InvocationTargetException ite) {
                    log.error(ite.getMessage(), ite);
                    throw ite;
                }
            }

            private void debugDoTransition(PipelineTask pipelineTask) {
                PipelineExecutor pipelineExecutor = new PipelineExecutor();
                pipelineExecutor.doTransition(
                    pipelineTask.getPipelineInstance(), pipelineTask,
                    new TaskCounts(0, 0, 0, 0));
            }

            private void debugLaunchTrigger() {
                TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud();
                TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(pipelineTaskDebugger.getTriggerName());

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
                        .equals(pipelineTaskDebugger.getModuleName())) {
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
        e.printStackTrace();
        log.error("Terminated.");
        System.exit(1);
    }

    private static void dumpConfig(PipelineTaskDebugger taskDebugger,
        PipelineTask pipelineTask) {

        log.info(String.format("%s=%s\n", PIPELINE_TASK_ID_PROP,
            taskDebugger.getPipelineTaskId()));
        log.info(String.format("%s=%s\n", DEBUG_ASYNC_ENABLED_PROP,
            taskDebugger.isDebugAsyncEnabled()));
        log.info(String.format("%s=%s\n", DEBUG_FROM_START_ENABLED_PROP,
            taskDebugger.isDebugFromStartEnabled()));
        log.info(String.format("%s=%s\n", DEBUG_LAUNCH_TRIGGER_ENABLED_PROP,
            taskDebugger.isDebugLaunchTriggerEnabled()));
        log.info(String.format("%s=%s\n", TASK_DIR_PROP,
            taskDebugger.getTaskDir()));
        log.info(String.format("%s=%s\n", PERSISTABLE_OUTPUT_CLASS_NAME_PROP,
            taskDebugger.getPersistableOutputClassName()));
        log.info(String.format("%s=%s\n", KEPLER_PROPERTIES_PROP,
            taskDebugger.getKeplerProperties()));
        log.info(String.format("%s=%s\n", MODULE_NAME_PROP,
            taskDebugger.getModuleName()));
        log.info(String.format("%s=%s\n", TRIGGER_NAME_PROP,
            taskDebugger.getTriggerName()));

        log.info(String.format(
            "%s=%s\n",
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_ENV,
            System.getenv(ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_ENV)));

        PipelineModule pipelineModule = pipelineTask.getPipelineInstanceNode()
            .getPipelineModuleDefinition()
            .getImplementingClass()
            .newInstance();
        Object moduleName = null;
        try {
            moduleName = pipelineModule.getClass()
                .getDeclaredMethod("getModuleName")
                .invoke(pipelineModule);
        } catch (IllegalAccessException e) {
            e.printStackTrace();
        } catch (IllegalArgumentException e) {
            e.printStackTrace();
        } catch (InvocationTargetException e) {
            e.printStackTrace();
        } catch (NoSuchMethodException e) {
            e.printStackTrace();
        } catch (SecurityException e) {
            e.printStackTrace();
        }
        if (moduleName instanceof String) {
            log.info(String.format("MODULE_NAME=%s\n", (String) moduleName));
        }
    }

    public int getPipelineTaskId() {
        return pipelineTaskId;
    }

    public boolean isDebugAsyncEnabled() {
        return debugAsyncEnabled;
    }

    public boolean isDebugFromStartEnabled() {
        return debugFromStartEnabled;
    }

    public boolean isDebugLaunchTriggerEnabled() {
        return debugLaunchTriggerEnabled;
    }

    public String getTaskDir() {
        return taskDir;
    }

    public String getPersistableOutputClassName() {
        return persistableOutputClassName;
    }

    public String getKeplerProperties() {
        return keplerProperties;
    }

    public String getModuleName() {
        return moduleName;
    }

    public String getTriggerName() {
        return triggerName;
    }

}
