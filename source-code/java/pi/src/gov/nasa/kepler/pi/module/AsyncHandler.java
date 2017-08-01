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

package gov.nasa.kepler.pi.module;

import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.pi.module.remote.Manifest;
import gov.nasa.kepler.pi.module.remote.MultipleAlgorithmResultsIterator;
import gov.nasa.kepler.pi.module.remote.RemoteCluster;
import gov.nasa.kepler.pi.module.remote.RemoteClusterFactory;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.kepler.pi.module.remote.StateFile;
import gov.nasa.kepler.pi.module.remote.TimestampFile;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.ValueMetric;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.concurrent.Callable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class AsyncHandler {
    private static final Log log = LogFactory.getLog(AsyncHandler.class);

    protected static final String RERUN_MODE_RESUME_STEP = "Resume current step";
    protected static final String RERUN_MODE_RESUME_PBS_MONITORING = "Resume PBS monitoring";
    protected static final String RERUN_MODE_RESUBMIT_TO_PBS = "Resubmit to PBS";

    private PipelineTask pipelineTask = null;
    private MatlabPipelineModule pipelineModule = null;

    private PipelineTaskAttributes pipelineTaskAttrs;

    public AsyncHandler(PipelineTask pipelineTask,
        MatlabPipelineModule pipelineModule) {
        this.pipelineTask = pipelineTask;
        this.pipelineModule = pipelineModule;
    }

    public boolean process() throws Exception {
        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
        pipelineTaskAttrs = attrCrud.retrieveByTaskId(pipelineTask.getId());
        
        if (MatlabPipelineModule.isRemote(pipelineTask)) {
            return processAsyncRemote();
        }

        return processAsyncLocal();
    }

    private boolean processAsyncRemote() throws Exception {
        final File workingDir = pipelineModule.allocateWorkingDir(pipelineTask);
        String restartMode = pipelineTask.getRestartMode();

        if (restartMode != null && !restartMode.isEmpty()) {
            return processAsyncRemoteRestart(restartMode, workingDir);
        }

        return processAsyncRemoteResumePreviousStep(restartMode, workingDir);
    }

    private boolean processAsyncRemoteRestart(String restartMode,
        File workingDir) throws Exception {
        AsyncPipelineModule asyncModule = (AsyncPipelineModule) pipelineModule;

        // operator specified a restart mode so we use that
        // instead of the previous state
        if (restartMode.equals(PipelineModule.RERUN_MODE_RESET_BEGINNING)) {
            log.info("STEP PROCESSING (rerun mode=" + restartMode
                + ": processAsyncGenerateInputsStep()");
            return processAsyncGenerateInputsStep(asyncModule, workingDir);
        } else if (restartMode.equals(RERUN_MODE_RESUME_PBS_MONITORING)) {
            log.info("STEP PROCESSING (rerun mode=" + restartMode
                + ": processAsyncStartMonitorStep()");
            processAsyncStartMonitorStep();
            return false;
        } else if (restartMode.equals(RERUN_MODE_RESUBMIT_TO_PBS)) {
            log.info("STEP PROCESSING (rerun mode=" + restartMode
                + ": processAsyncResubmitToPbsStep()");
            processAsyncResubmitToPbsStep();
            return false;
        } else if (restartMode.equals(RERUN_MODE_RESUME_STEP)) {
            log.info("STEP PROCESSING (rerun mode=" + restartMode
                + ": processAsyncResubmitToPbsStep()");
            return processAsyncRemoteResumePreviousStep(restartMode, workingDir);
        } else {
            log.info("STEP PROCESSING: processAsyncGenerateInputsStep()");
            return processAsyncGenerateInputsStep(asyncModule, workingDir);
        }
    }

    private boolean processAsyncRemoteResumePreviousStep(String restartMode,
        File workingDir) throws Exception {
        AsyncPipelineModule asyncModule = (AsyncPipelineModule) pipelineModule;
        ProcessingState lastCompletedState = pipelineTaskAttrs.getProcessingState();

        log.info("lastCompletedStep = " + lastCompletedState);

        if (lastCompletedState == ProcessingState.INITIALIZING
            || lastCompletedState == ProcessingState.MARSHALING
            || lastCompletedState == ProcessingState.SENDING) {

            log.info("STEP PROCESSING: processAsyncGenerateInputsStep()");

            // processing for this task is done if there are no inputs
            return processAsyncGenerateInputsStep(asyncModule, workingDir);
        } else if (lastCompletedState == ProcessingState.ALGORITHM_QUEUED
            || lastCompletedState == ProcessingState.ALGORITHM_EXECUTING) {

            log.info("STEP PROCESSING: processAsyncStartMonitorStep()");

            processAsyncStartMonitorStep();
            return false;
        } else if (lastCompletedState == ProcessingState.ALGORITHM_COMPLETE
            || lastCompletedState == ProcessingState.RECEIVING
            || lastCompletedState == ProcessingState.STORING) {

            log.info("STEP PROCESSING: processAsyncProcessOutputsStep()");

            processAsyncProcessOutputsStep(asyncModule, workingDir);
            return true;
        } else {
            throw new PipelineException("Unexpected step: "
                + lastCompletedState);
        }
    }

    private void processAsyncResubmitToPbsStep() throws Exception {
        final RemoteCluster remoteCluster = RemoteClusterFactory.getInstance();
        StateFile stateFile = remoteCluster.generateStateFile(pipelineTask,
            pipelineTaskAttrs.getNumSubTasksTotal());
        remoteCluster.submitToPbs(stateFile, pipelineTask);
        remoteCluster.addToMonitor(pipelineTask);
    }

    private boolean processAsyncLocal() throws Exception {
        String moduleExeName = pipelineTask.moduleExeName();
        final File workingDir = pipelineModule.allocateWorkingDir(pipelineTask);
        final AsyncPipelineModule asyncModule = (AsyncPipelineModule) pipelineModule;

        // async module, local execution
        log.info("Using LocalExecutor");

        final InputsHandler inputsSequence = new InputsHandler(pipelineTask,
            workingDir);
        IntervalMetric.measure(MatlabPipelineModule.CREATE_INPUTS_METRIC,
            new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    asyncModule.generateInputs(inputsSequence, pipelineTask,
                        workingDir);
                    return null;
                }
            });

        inputsSequence.validate();
        
        if (!inputsSequence.isEmpty()) {
            SubTaskUtils.makeSymlinks(workingDir);

            InputsIterator iterator = new InputsIterator(inputsSequence);
            while (iterator.hasNext()) {
                File subTaskWorkingDir = iterator.next();
                log.info("Local executor: Executing MATLAB for sub-task: "
                    + subTaskWorkingDir.getName());
                pipelineModule.executeAlgorithmLocal(subTaskWorkingDir,
                    pipelineTask, 0);
            }

            SubTaskUtils.removeSymlinks(workingDir);

            final MultipleAlgorithmResultsIterator outputs = new MultipleAlgorithmResultsIterator(
                moduleExeName, workingDir, asyncModule.outputsClass());

            if (outputs.hasNext()) {
                IntervalMetric.measure(MatlabPipelineModule.STORE_OUTPUTS_METRIC,
                    new Callable<Void>() {
                    @Override
                    public Void call() throws Exception {
                        // process outputs
                        asyncModule.processOutputs(pipelineTask, outputs);
                        return null;
                    }
                });
            }
        } else {
            log.warn("Local executor: No inputs generated, MATLAB not called");
        }

        return true;
    }

    /**
     * Generate inputs and transfer them to the remote cluster along with the
     * state file
     *
     * @param asyncModule
     * @param workingDir
     * @return
     * @throws Exception
     */
    private boolean processAsyncGenerateInputsStep(
        final AsyncPipelineModule asyncModule, final File workingDir)
        throws Exception {

        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
        attrOps.updateProcessingState(pipelineTask.getId(),
            pipelineTask.getPipelineInstance()
                .getId(), ProcessingState.MARSHALING);

        // generate inputs
        final InputsHandler inputsHandler = new InputsHandler(pipelineTask,
            workingDir);
        IntervalMetric.measure(MatlabPipelineModule.CREATE_INPUTS_METRIC,
            new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    asyncModule.generateInputs(inputsHandler, pipelineTask,
                        workingDir);
                    return null;
                }
            });

        inputsHandler.validate();

        // create manifest files for each group or sub-task to support restarts
        createManifestFiles(inputsHandler);

        if (!inputsHandler.isEmpty()) {
            inputsHandler.persist(workingDir);

            final int numSubTasks = inputsHandler.numSubTasks();

            // execute the MATLAB process on a remote host
            RemoteExecutionParameters remoteParams = pipelineTask.getParameters(
                RemoteExecutionParameters.class, false);
            log.info("Using RemoteExecutor(" + remoteParams.getRemoteHost()
                + ")");
            final RemoteCluster remoteCluster = RemoteClusterFactory.getInstance();

            IntervalMetric.measure(MatlabPipelineModule.SEND_METRIC,
                new Callable<Void>() {
                    @Override
                    public Void call() throws Exception {
                        log.info("Submitting task to remote cluster (taskId="
                            + pipelineTask.getId() + ")");
                        remoteCluster.submitTask(pipelineTask, workingDir,
                            numSubTasks);
                        return null;
                    }
                });

            log.info("Start remote monitoring (taskId=" + pipelineTask.getId()
                + ")");
            remoteCluster.addToMonitor(pipelineTask);

            return false;
        }

        return true;
    }

    private void createManifestFiles(InputsHandler inputsHandler)
        throws IOException {
        if (inputsHandler.hasGroups()) {
            List<File> groupDirs = inputsHandler.allGroupDirectories();
            for (File groupDir : groupDirs) {
                if (groupDir.exists()) {
                    createManifest(groupDir);
                }
            }
        } else {
            List<File> subTaskDirs = inputsHandler.allSubTaskDirectories();
            for (File subTaskDir : subTaskDirs) {
                if (subTaskDir.exists()) {
                    createManifest(subTaskDir);
                }
            }
        }
    }

    private void createManifest(File dir) throws IOException {
        log.info("Creating manifest file for: " + dir);

        Manifest manifest = new Manifest(dir);
        manifest.create();
    }

    /**
     * Start monitoring a job that is already running on the remote cluster.
     * This step is typically only used to restart monitoring of a remote job.
     *
     * @return
     */
    private void processAsyncStartMonitorStep() {
        RemoteCluster remoteCluster = RemoteClusterFactory.getInstance();
        remoteCluster.addToMonitor(pipelineTask);
    }

    /**
     * Transfer output files back from the remote cluster and process/store them
     * This is the final step for {@link AsyncPipelineModule}
     *
     * @return
     * @throws Exception
     */
    private void processAsyncProcessOutputsStep(
        final AsyncPipelineModule asyncModule, final File workingDir)
        throws Exception {
        final RemoteCluster remoteCluster = RemoteClusterFactory.getInstance();

        long startTransferTime = System.currentTimeMillis();

        IntervalMetric.measure(MatlabPipelineModule.RECEIVE_METRIC,
            new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    remoteCluster.retrieveTaskOutputs(pipelineTask, workingDir,
                        0);
                    return null;
                }
            });

        // add metrics for "RemoteWorker", "PleiadesQueue", "Matlab",
        // "PendingReceive"
        long remoteWorkerTime = TimestampFile.elapsedTimeMillis(workingDir,
            TimestampFile.Event.ARRIVE_PFE, TimestampFile.Event.QUEUED_PBS);
        long pleiadesQueueTime = TimestampFile.elapsedTimeMillis(workingDir,
            TimestampFile.Event.QUEUED_PBS, TimestampFile.Event.PBS_JOB_START);
        long pleiadesWallTime = TimestampFile.elapsedTimeMillis(workingDir,
            TimestampFile.Event.PBS_JOB_START,
            TimestampFile.Event.PBS_JOB_FINISH);
        long pendingReceiveTime = startTransferTime
            - TimestampFile.timestamp(workingDir,
                TimestampFile.Event.PBS_JOB_FINISH);

        log.info("remoteWorkerTime = " + remoteWorkerTime);
        log.info("pleiadesQueueTime = " + pleiadesQueueTime);
        log.info("pleiadesWallTime = " + pleiadesWallTime);
        log.info("pendingReceiveTime = " + pendingReceiveTime);

        ValueMetric.addValue(MatlabPipelineModule.REMOTE_WORKER_WAIT_METRIC,
            remoteWorkerTime);
        ValueMetric.addValue(MatlabPipelineModule.PLEIADES_QUEUE_METRIC,
            pleiadesQueueTime);
        ValueMetric.addValue(MatlabPipelineModule.PLEIADES_WALL_METRIC,
            pleiadesWallTime);
        ValueMetric.addValue(MatlabPipelineModule.PENDING_RECEIVE_METRIC,
            pendingReceiveTime);

        String moduleExeName = pipelineTask.moduleExeName();
        final MultipleAlgorithmResultsIterator outputs = new MultipleAlgorithmResultsIterator(
            moduleExeName, workingDir, asyncModule.outputsClass());

        IntervalMetric.measure(MatlabPipelineModule.STORE_OUTPUTS_METRIC,
            new Callable<Void>() {
                @Override
                public Void call() throws Exception {
                    // process outputs
                    asyncModule.processOutputs(pipelineTask, outputs);
                    return null;
                }
            });
    }

}
