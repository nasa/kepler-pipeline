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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics;
import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics.Units;
import gov.nasa.kepler.pi.metrics.report.Memdrone;
import gov.nasa.kepler.pi.module.io.MatlabBinFileUtils;
import gov.nasa.kepler.pi.module.io.matlab.MatlabErrorReturn;
import gov.nasa.kepler.pi.module.remote.MultipleAlgorithmResultsIterator;
import gov.nasa.kepler.pi.module.remote.RemoteCluster;
import gov.nasa.kepler.pi.module.remote.RemoteClusterFactory;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.kepler.pi.module.remote.StateFile;
import gov.nasa.kepler.pi.worker.TaskFileCopy;
import gov.nasa.kepler.pi.worker.TaskFileCopyParameters;
import gov.nasa.kepler.pi.worker.WorkerTaskRequestDispatcher;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.metrics.Metric;
import gov.nasa.spiffy.common.metrics.ValueMetric;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Subclass for modules that invoke a MATLAB process and communicate with it
 * using the standard .bin (Persistable) files.
 *
 * This class is in serious need of a hair cut, but it's a little better now.
 *
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public abstract class MatlabPipelineModule extends
    ExternalProcessPipelineModule {
    private static final Log log = LogFactory.getLog(MatlabPipelineModule.class);

    public static final String MATLAB_SERIALIZATION_METRIC = "pipeline.module.executeAlgorithm.matlab.serializationTime";
    public static final String MATLAB_MATFILE_METRIC = "pipeline.module.executeAlgorithm.matlab.readWriteMatfilesTime";
    public static final String MATLAB_CONTROLLER_EXEC_METRIC = "pipeline.module.executeAlgorithm.matlab.controller.execTime";

    public static final String JAVA_SERIALIZATION_METRIC = "pipeline.module.executeAlgorithm.java.serializationTime";

    public static final String CREATE_INPUTS_METRIC = "pi.module.matlab.createInputs.execTimeMillis";
    public static final String SEND_METRIC = "pi.module.matlab.remote.send.execTimeMillis";
    public static final String REMOTE_WORKER_WAIT_METRIC = "pi.module.matlab.waitForRemoteWorker.elapsedTimeMillis";
    public static final String PLEIADES_QUEUE_METRIC = "pi.module.matlab.pleiadesQueue.elapsedTimeMillis";
    public static final String PLEIADES_WALL_METRIC = "pi.module.matlab.pleiadesWall.elapsedTimeMillis";
    public static final String PENDING_RECEIVE_METRIC = "pi.module.matlab.waitForSoc.elapsedTimeMillis";
    public static final String RECEIVE_METRIC = "pi.module.matlab.remote.receive.execTimeMillis";
    public static final String STORE_OUTPUTS_METRIC = "pi.module.matlab.storeOutputs.execTimeMillis";
    public static final String COPY_TASK_FILES_METRIC = "pi.module.matlab.copyTaskFiles.execTimeMillis";

    public static final String TF_INPUTS_SIZE_METRIC = "pi.module.matlab.taskFiles.inputs.sizeBytes";
    public static final String TF_PFE_OUTPUTS_SIZE_METRIC = "pi.module.matlab.taskFiles.pleiadesOutputs.sizeBytes";
    public static final String TF_ARCHIVE_SIZE_METRIC = "pi.module.matlab.taskFiles.archive.sizeBytes";

    public static final String CREATE_INPUTS_CATEGORY = "CreateInputs";
    public static final String SEND_INPUTS_CATEGORY = "SendInputs";
    public static final String REMOTE_WORKER_CATEGORY = "RemoteWorker";
    public static final String PLEIADES_QUEUE_CATEGORY = "PleiadesQueue";
    public static final String MATLAB_CATEGORY = "Matlab";
    public static final String PENDING_RECEIVE_CATEGORY = "PendingReceive";
    public static final String RECEIVE_OUTPUTS_CATEGORY = "ReceiveOutputs";
    public static final String STORE_OUTPUTS_CATEGORY = "StoreOutputs";
    public static final String COPY_TASK_FILES_CATEGORY = "CopyTaskFiles";
    public static final String COMMIT_CATEGORY = "Commit";

    public static final String TF_INPUTS_SIZE_CATEGORY = "InputsSize";
    public static final String TF_PFE_OUTPUTS_SIZE_CATEGORY = "PleiadesOutputsSize";
    public static final String TF_ARCHIVE_SIZE_CATEGORY = "ArchiveSize";

    private static final String[] REMOTE_CATEGORIES = { CREATE_INPUTS_CATEGORY,
        SEND_INPUTS_CATEGORY, REMOTE_WORKER_CATEGORY, PLEIADES_QUEUE_CATEGORY,
        MATLAB_CATEGORY, PENDING_RECEIVE_CATEGORY, RECEIVE_OUTPUTS_CATEGORY,
        STORE_OUTPUTS_CATEGORY, COPY_TASK_FILES_CATEGORY, COMMIT_CATEGORY,
        TF_INPUTS_SIZE_CATEGORY, TF_PFE_OUTPUTS_SIZE_CATEGORY,
        TF_ARCHIVE_SIZE_CATEGORY };

    private static final String[] REMOTE_METRICS = { CREATE_INPUTS_METRIC,
        SEND_METRIC, REMOTE_WORKER_WAIT_METRIC, PLEIADES_QUEUE_METRIC,
        PLEIADES_WALL_METRIC, PENDING_RECEIVE_METRIC, RECEIVE_METRIC,
        STORE_OUTPUTS_METRIC, COPY_TASK_FILES_METRIC,
        WorkerTaskRequestDispatcher.PIPELINE_MODULE_COMMIT_METRIC,
        TF_INPUTS_SIZE_METRIC, TF_PFE_OUTPUTS_SIZE_METRIC,
        TF_ARCHIVE_SIZE_METRIC };

    private static final Units[] REMOTE_CATEGORY_UNITS = { Units.TIME,
        Units.TIME, Units.TIME, Units.TIME, Units.TIME, Units.TIME, Units.TIME,
        Units.TIME, Units.TIME, Units.TIME, Units.BYTES, Units.BYTES,
        Units.BYTES };

    private static final String[] LOCAL_CATEGORIES = { CREATE_INPUTS_CATEGORY,
        MATLAB_CATEGORY, STORE_OUTPUTS_CATEGORY, COPY_TASK_FILES_CATEGORY,
        COMMIT_CATEGORY, TF_ARCHIVE_SIZE_CATEGORY };

    static final String[] LOCAL_METRICS = { CREATE_INPUTS_METRIC,
        MatlabMcrExecutable.MATLAB_PROCESS_EXEC_METRIC, STORE_OUTPUTS_METRIC,
        COPY_TASK_FILES_METRIC,
        WorkerTaskRequestDispatcher.PIPELINE_MODULE_COMMIT_METRIC,
        TF_ARCHIVE_SIZE_METRIC };

    private static final Units[] LOCAL_CATEGORY_UNITS = { Units.TIME,
        Units.TIME, Units.TIME, Units.TIME, Units.TIME, Units.BYTES };

    private int externalExecSeqNum = 0;
    private PipelineTask pipelineTask;

    private MatlabSerializer serializer = null;

    public MatlabPipelineModule() {
    }

    @Override
    public void initialize(PipelineTask pipelineTask) {
        allocateWorkingDir(pipelineTask);
        serializer = new MatlabSerializerImpl();
    }

    /*
     * (non-Javadoc)
     *
     * @see gov.nasa.kepler.hibernate.pi.PipelineModule#supportedRestartModes()
     */
    @Override
    public String[] supportedRestartModes() {
        return new String[] { AsyncHandler.RERUN_MODE_RESUME_STEP,
            AsyncHandler.RERUN_MODE_RESUME_PBS_MONITORING,
            AsyncHandler.RERUN_MODE_RESUBMIT_TO_PBS, RERUN_MODE_RESET_BEGINNING };
    }

    /**
     * Subclasses that do not implement {@link AsyncPipelineModule} must
     * override this method. This method should never be invoked for modules
     * that implement {@link AsyncPipelineModule}
     */
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws PipelineException {
        throw new IllegalStateException(
            "No processTask() implementation provided by this pipeline module");
    }

    /**
     * Main handler for this module.
     *
     * Calls processTask() for non-AsyncPipelineModules or the
     * AsyncPipelineModule methods
     *
     * @throws Throwable
     */
    @Override
    public boolean process(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) throws Exception {
        this.pipelineTask = pipelineTask;
        boolean taskDone = false;

        if (this instanceof AsyncPipelineModule) {
            log.info("Asynchronous execution");
            AsyncHandler asyncHandler = new AsyncHandler(pipelineTask, this);

            taskDone = asyncHandler.process();
        } else {
            // sync module, subclass takes control and pushes via
            // executeMatlab()
            log.info("Synchronous execution, calling processTask()");
            processTask(pipelineInstance, pipelineTask);
            taskDone = true;
        }

        if (taskDone) {
            generateMemdroneCacheFiles();
            doTaskFileCopy();
        }

        return taskDone;
    }

    private void generateMemdroneCacheFiles() {
        try {
            File srcTaskDir = WorkingDirManager.workingDir(pipelineTask);
            Memdrone memdrone = new Memdrone(srcTaskDir);
            log.info("generating Memdrone stats cache files");
            memdrone.createStatsCache();
            log.info("generating Memdrone pid map cache files");
            memdrone.createPidMapCache();
        } catch (Throwable t) {
            log.warn("Failed to generate Memdrone cache files: " + t);
        }
    }

    private void doTaskFileCopy() throws Exception {
        if (pipelineTask != null) {
            TaskFileCopyParameters copyParams = pipelineTask.getParameters(
                TaskFileCopyParameters.class, false);
            if (copyParams != null && copyParams.isEnabled()) {
                final TaskFileCopy copier = new TaskFileCopy(pipelineTask,
                    copyParams);

                log.info("Starting copy of task files for pipelineTask : "
                    + pipelineTask.getId());

                IntervalMetric.measure(COPY_TASK_FILES_METRIC,
                    new Callable<Void>() {
                        @Override
                        public Void call() throws Exception {
                            copier.copyTaskFiles();
                            return null;
                        }
                    });

                log.info("Finished copy of task files for pipelineTask : "
                    + pipelineTask.getId());
            }
        }
    }

    public static boolean isRemote(PipelineTask task) {
        if (task != null) {
            RemoteExecutionParameters remoteParams = task.getParameters(
                RemoteExecutionParameters.class, false);
            return remoteParams != null && remoteParams.isEnabled();
        }

        return false;
    }

    /*
     * (non-Javadoc)
     *
     * @see
     * gov.nasa.kepler.hibernate.pi.PipelineModule#updateMetrics(gov.nasa.kepler
     * .hibernate.pi.PipelineTask)
     */
    @Override
    public void updateMetrics(PipelineTask pipelineTask,
        Map<String, Metric> threadMetrics, long overallExecTimeMillis) {
        List<PipelineTaskMetrics> summaryMetrics = pipelineTask.getSummaryMetrics();

        log.debug("Thread Metrics:");
        for (String threadMetricName : threadMetrics.keySet()) {
            log.debug("TM: " + threadMetricName + ": "
                + threadMetrics.get(threadMetricName)
                    .getLogString());
        }

        // cross-reference existing summary metrics by category
        Map<String, PipelineTaskMetrics> summaryMetricsByCategory = new HashMap<String, PipelineTaskMetrics>();
        for (PipelineTaskMetrics summaryMetric : summaryMetrics) {
            summaryMetricsByCategory.put(summaryMetric.getCategory(),
                summaryMetric);
        }

        String[] categories;
        String[] metrics;
        Units[] units;

        if (isRemote(pipelineTask)) {
            categories = REMOTE_CATEGORIES;
            metrics = REMOTE_METRICS;
            units = REMOTE_CATEGORY_UNITS;
        } else {
            categories = LOCAL_CATEGORIES;
            metrics = LOCAL_METRICS;
            units = LOCAL_CATEGORY_UNITS;
        }

        for (int i = 0; i < categories.length; i++) {
            String category = categories[i];
            String metricName = metrics[i];
            Units unit = units[i];

            long totalTime = 0;

            Metric metric = threadMetrics.get(metricName);
            if (metric != null && metric instanceof ValueMetric) {
                ValueMetric iMetric = (ValueMetric) metric;
                totalTime = iMetric.getSum();
            } else {
                log.warn("No metric found with name = " + metricName);
            }

            log.info("TaskID: " + pipelineTask.getId() + ", category: "
                + category + ", time(ms): " + totalTime);

            PipelineTaskMetrics m = summaryMetricsByCategory.get(category);
            if (m == null) {
                m = new PipelineTaskMetrics(category, totalTime, unit);
                summaryMetrics.add(m);
            }

            // don't overwrite the existing value if no value was recorded for
            // this category
            // on this invocation
            if (totalTime > 0) {
                m.setValue(totalTime);
            }
        }
        pipelineTask.setSummaryMetrics(summaryMetrics);
    }

    /**
     * Executes the algorithm associated with this pipeline module.
     *
     * This method is used in cases where there is one MATLAB process per task.
     *
     * This default implementation executes the external process defined in the
     * ModuleDefinition, but sub-classes may override this behavior to execute a
     * different algorithm, or substitute other code for testing
     *
     * @param module
     * @param inputs
     * @param outputs
     * @throws PipelineException
     */
    protected void executeAlgorithm(PipelineTask pipelineTask,
        Persistable inputs, Persistable outputs) {

        IntervalMetricKey key = IntervalMetric.start();

        String moduleExeName = pipelineTask.moduleExeName();

        try {
            File workingDir = allocateWorkingDir(
                workingDirPrefix(pipelineTask), pipelineTask);

            executeMatlab(workingDir, inputs, outputs, this, externalExecSeqNum);

            deserializeSingleOutputsFile(outputs, workingDir, moduleExeName,
                externalExecSeqNum);

            externalExecSeqNum++;
        } finally {
            releaseWorkingDir();
            IntervalMetric.stop("pipeline.module.executeAlgorithm."
                + moduleExeName + ".execTime", key);
            IntervalMetric.stop("pipeline.module.executeAlgorithm."
                + moduleExeName + "." + externalExecSeqNum + ".execTime", key);
        }
    }

    /**
     * Convenience function for running arbitrary MATLAB executables that do not
     * use the standard {@link Persistable} inputs and outputs.
     *
     * @param binaryName
     * @param commandLineArgs
     * @param workingDir
     * @param timeoutSecs
     * @return Boolean indicating whether the MATLAB process threw an exception
     */
    protected boolean executeMatlab(String binaryName,
        List<String> commandLineArgs, File workingDir, int timeoutSecs) {
        try {
            MatlabMcrExecutable matlabExe = new MatlabMcrExecutable(binaryName,
                workingDir, timeoutSecs);

            log.info("START " + binaryName + ", args: " + commandLineArgs);

            int rc = matlabExe.execSimple(commandLineArgs);

            if (rc != 0) {
                log.warn(binaryName + " FAILED with retcode=" + rc);
            }

            log.info("FINISHED " + binaryName);
        } catch (Exception e) {
            log.warn("failed to run " + binaryName + ", caught e = " + e, e);
            return false;
        }
        return true;
    }

    /**
     * Executes the MATLAB executable associated with the specified
     * PipelineTask. Assumes that the inputs have already been created in the
     * specified taskWorkingDir.
     *
     * Throws an exception if the MATLAB process fails to run or generates a
     * error .bin file because of a MATLAB exception caught by the _main()
     * auto-generated entry function.
     *
     * @param taskWorkingDir
     * @param pipelineTask
     * @param sequenceNum
     * @throws Exception
     */
    void executeAlgorithmLocal(File taskWorkingDir, PipelineTask pipelineTask,
        int sequenceNum) throws Exception {
        log.info("taskWorkingDir = " + taskWorkingDir);

        String exeName = pipelineTask.moduleExeName();

        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
        attrOps.updateProcessingState(pipelineTask.getId(),
            pipelineTask.getPipelineInstance()
                .getId(), ProcessingState.ALGORITHM_EXECUTING);

        PipelineModuleDefinition module = pipelineTask.getPipelineInstanceNode()
            .getPipelineModuleDefinition();

        // Make sure there are no leftover error files before launching the
        // process.
        MatlabBinFileUtils.clearStaleErrorState(taskWorkingDir, exeName,
            sequenceNum);

        MatlabMcrExecutable matlabExe = new MatlabMcrExecutable(exeName,
            taskWorkingDir, module.getExeTimeoutSecs());
        matlabExe.setLogOutput(true);
        matlabExe.execAlgorithm(sequenceNum);

        File errorFile = MatlabBinFileUtils.errorFile(taskWorkingDir, exeName,
            sequenceNum);
        if (errorFile.exists()) {
            log.warn("MATLAB error file exists in: " + errorFile);
            MatlabBinFileUtils.dumpErrorFile(errorFile);
            throw new ModuleFatalProcessingException(
                "Aborting processing of this task because the MATLAB error file exists in: "
                    + errorFile);
        }
    }

    /**
     * Returns the number of elements that should be included in each
     * Persistable inputs object for remote execution. If remote execution is
     * disabled, this will be the same as numElements, which will result in a
     * single inputs object.
     *
     * @param pipelineTask
     * @param numElements
     * @return
     */
    protected int elementsPerSubTask(PipelineTask pipelineTask, int numElements) {
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(
            RemoteExecutionParameters.class, false);
        double numElementsPerSubTask = numElements;
        double numSubTasks = 1;

        if (remoteParams != null && remoteParams.isEnabled()) {
            numElementsPerSubTask = remoteParams.getNumElementsPerTaskFile();
            numSubTasks = numElements / numElementsPerSubTask;
        }

        log.info("numElements = " + numElements);
        log.info("numElementsPerSubTask = " + numElementsPerSubTask);
        log.info("numSubTasks = " + numSubTasks);

        return (int) Math.ceil(numElementsPerSubTask);
    }

    @Override
    protected File allocateWorkingDir(PipelineTask pipelineTask) {
        return allocateWorkingDir(workingDirPrefix(pipelineTask), pipelineTask);
    }

    /**
     * Execute the MATLAB process synchronously
     *
     * Supports local and remote execution.
     *
     * @param module The ModuleDefinition that contains the name of the exe and
     * the timeout
     * @param inputsList Inputs object that will be passed to the exe
     * @param outputs Outputs object that will be populated with outputs from
     * the exe
     * @throws PipelineException
     */
    private Iterator<AlgorithmResults> executeMatlab(File workingDir,
        Persistable inputs, Persistable outputs,
        ExternalProcessPipelineModule pipelineModule, int sequenceNumber) {

        String moduleExeName = pipelineTask.moduleExeName();
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(
            RemoteExecutionParameters.class, false);
        boolean isRemote = remoteParams != null && remoteParams.isEnabled();

        log.info("moduleName = " + moduleExeName);
        log.info("seqNum = " + sequenceNumber);
        log.info("isRemote = " + isRemote);

        try {
            log.info("Serializing Inputs...");
            serializer.serializeInputsWithSeqNum(pipelineTask, inputs,
                workingDir, sequenceNumber);

            if (isRemote) {
                // execute the MATLAB process on a remote host as a single
                // sub-task
                log.info("Using RemoteExecutor(" + remoteParams.getRemoteHost()
                    + ")");
                RemoteCluster remoteCluster = RemoteClusterFactory.getInstance();

                remoteCluster.submitTask(pipelineTask, workingDir, 1);
                StateFile finalState = remoteCluster.waitForCompletion(pipelineTask);
                remoteCluster.retrieveTaskOutputs(pipelineTask, workingDir,
                    sequenceNumber);

                boolean allSubTasksSuccessful = finalState.getNumComplete() == finalState.getNumTotal();

                if (!allSubTasksSuccessful) {
                    // partial results
                    pipelineModule.setPartialSuccess(true);
                }
            } else {
                // execute the MATLAB process on this host
                log.info("Using LocalExecutor");
                executeAlgorithmLocal(workingDir, pipelineTask, sequenceNumber);
            }
        } catch (Exception e) {
            throw new ModuleFatalProcessingException(
                "failed to execute external program, e = " + e, e);
        }

        log.info("Deserializing Outputs...");
        Iterator<AlgorithmResults> results = deserializeOutputs(moduleExeName,
            workingDir, outputs, isRemote);

        return results;
    }

    private Iterator<AlgorithmResults> deserializeOutputs(String moduleName,
        File taskDir, Persistable outputs, boolean isRemote) {
        if (isRemote) {
            return new MultipleAlgorithmResultsIterator(moduleName, taskDir,
                outputs.getClass());
        }
        deserializeSingleOutputsFile(outputs, taskDir, moduleName, 0);

        return new SingleAlgorithmResultsIterator(new AlgorithmResults(outputs,
            taskDir, taskDir, taskDir, null));
    }

    public void deserializeSingleOutputsFile(Persistable outputs,
        File taskWorkingDir, String moduleName, int sequenceNum) {

        IntervalMetricKey key = IntervalMetric.start();
        try {
            MatlabErrorReturn errorFile = MatlabBinFileUtils.deserializeOutputsFile(
                outputs, taskWorkingDir, moduleName, sequenceNum);
            if (errorFile != null) {
                throw new ModuleFatalProcessingException(errorFile.getMessage());
            }
        } finally {
            IntervalMetric.stop(JAVA_SERIALIZATION_METRIC, key);
        }
    }

    private String workingDirPrefix(PipelineTask pipelineTask) {
        String moduleName = pipelineTask.moduleExeName();

        return moduleName + "-matlab";
    }

    /**
     * For TEST use only
     *
     * @return
     */
    public MatlabSerializer getSerializer() {
        return serializer;
    }

    /**
     * For TEST use only
     *
     * @param serializer
     */
    public void setSerializer(MatlabSerializer serializer) {
        this.serializer = serializer;
    }

    /**
     * Currently, not used in the nominal pipeline context.
     *
     * @param pipelineTask
     */
    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
    }
}
