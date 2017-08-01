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
import gov.nasa.kepler.pi.module.io.MatlabBinFileUtils;
import gov.nasa.kepler.pi.worker.WorkerTaskRequestDispatcher;
import gov.nasa.kepler.services.process.ExternalProcess;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Subclass for modules that invoke an arbitrary external command line
 * executable to perform work.
 *
 * This class provides for working directory management and launching and
 * monitoring of the external process.
 *
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public abstract class ExternalProcessPipelineModule extends PipelineModule {
    private static final Log log = LogFactory.getLog(ExternalProcessPipelineModule.class);

    private static WorkingDirManager workingDirManager = null;
    private File defaultWorkingDir = null;

    public static final String MODULE_EXE_WORKING_DIR_PROPERTY_NAME = "pi.worker.moduleExe.workingDir";

    private static final String PROCESS_EXEC_METRIC_PREFIX = "pipeline.module.genericProcess.";
    private static final int DEFAULT_TIMEOUT_SECS = 60 * 5; // 5 mins

    public ExternalProcessPipelineModule() {
    }

    /**
     * Allocate the working directory using the default naming convention:
     * BINARYNAME-INSTANCEID-TASKID
     *
     * @param pipelineTask
     * @return
     */
    protected File allocateWorkingDir(PipelineTask pipelineTask) {
        String moduleName = pipelineTask.getPipelineInstanceNode()
            .getPipelineModuleDefinition()
            .getName()
            .getName();

        return allocateWorkingDir(moduleName, pipelineTask);
    }

    /**
     * Allocate the working directory using the specified prefix.
     *
     * @param workingDirNamePrefix
     * @param pipelineTask
     * @return
     */
    protected File allocateWorkingDir(String workingDirNamePrefix,
        PipelineTask pipelineTask) {
        synchronized (ExternalProcessPipelineModule.class) {
            if (workingDirManager == null) {
                workingDirManager = new WorkingDirManager();
            }
        }

        if (defaultWorkingDir == null) {
            try {
                defaultWorkingDir = workingDirManager.allocateWorkingDir(
                    workingDirNamePrefix, pipelineTask.getPipelineInstance()
                        .getId(), pipelineTask.getId());
                log.info("defaultWorkingDir = " + defaultWorkingDir);

                // register the working dir
                WorkerTaskRequestDispatcher.registerWorkingDir(defaultWorkingDir);
            } catch (IOException e) {
                throw new ModuleFatalProcessingException(
                    "failed to execute external program, e = " + e);
            }
        }
        return defaultWorkingDir;
    }

    protected void releaseWorkingDir() {
        if (defaultWorkingDir != null) {
            try {
                workingDirManager.releaseWorkingDir();
            } catch (IOException e) {
                log.warn("failed to release working dir", e);
            }
        }
    }

    /**
     * Return the currently allocated working directory.
     *
     * Returns null if the directory has not been allocated
     *
     * @return
     */
    protected File getCurrentWorkingDir() {
        return defaultWorkingDir;
    }

    /**
     * Execute the specified binary with the specified arguments.
     *
     * The working directory for the binary will be created under DIST/tmp
     *
     * The default timeout (5 mins) will be used
     *
     * @param binary
     * @param commandLineArgs
     * @return
     */
    protected int executeExternalProcess(File binary,
        List<String> commandLineArgs) {
        return executeExternalProcess(binary, commandLineArgs,
            DEFAULT_TIMEOUT_SECS, defaultWorkingDir,
            new HashMap<String, String>());
    }

    /**
     * Execute the specified binary with the specified arguments and specified
     * timeout (in seconds).
     *
     * The working directory for the binary will be created under DIST/tmp
     *
     * @param binary
     * @param commandLineArgs
     * @param timeoutSecs
     * @return
     */
    protected int executeExternalProcess(File binary,
        List<String> commandLineArgs, int timeoutSecs) {
        return executeExternalProcess(binary, commandLineArgs, timeoutSecs,
            defaultWorkingDir, new HashMap<String, String>());
    }

    /**
     * Execute the specified binary with the specified arguments and specified
     * timeout (in seconds).
     *
     * The specified working directory will be used and is assumed to already
     * exist
     *
     * @param binary
     * @param commandLineArgs
     * @param timeoutSecs
     * @param workingDir
     * @return
     */
    protected int executeExternalProcess(File binary,
        List<String> commandLineArgs, int timeoutSecs, File workingDir) {
        return executeExternalProcess(binary, commandLineArgs, timeoutSecs,
            workingDir, new HashMap<String, String>());
    }

    /**
     * Execute the specified binary with the specified arguments, specified
     * timeout (in seconds), and specified environment variables (which will be
     * merged with the existing environment variables).
     *
     * The specified working directory will be used and is assumed to already
     * exist
     *
     * @param binary
     * @param commandLineArgs
     * @param timeoutSecs
     * @param workingDir
     * @param environmentVariables
     * @return
     */
    protected int executeExternalProcess(File binary,
        List<String> commandLineArgs, int timeoutSecs, File workingDir,
        Map<String, String> environmentVariables) {

        if (!workingDir.exists()) {
            throw new ModuleFatalProcessingException(
                "workingDir does not exist [" + workingDir.getAbsolutePath()
                    + "]");
        }

        String binaryName = binary.getName();
        int retCode = -1;

        try {
            retCode = runCommandLine(binary, commandLineArgs, timeoutSecs,
                workingDir, environmentVariables, binaryName + "-");

            if (retCode != 0) {
                throw new ModuleFatalProcessingException(
                    "failed to execute external program [" + binaryName
                        + "], retCode = " + retCode);
            }

            log.info("external process completed, retCode=" + retCode);
        } catch (Exception e) {
            throw new ModuleFatalProcessingException(
                "failed to execute external program [" + binaryName
                    + "], caught e = " + e);
        }

        return retCode;
    }

    /**
     * Execute, log and monitor the external program.
     *
     * @param binary
     * @param commandlineArgs
     * @param timeoutSecs
     * @param workingDir
     * @param environmentVariables
     * @param logPrefix
     * @return
     * @throws Exception
     */
    private int runCommandLine(File binary, List<String> commandlineArgs,
        int timeoutSecs, File workingDir,
        Map<String, String> environmentVariables, String logPrefix)
        throws Exception {
        FileWriter stdOutWriter = null;
        FileWriter stdErrWriter = null;
        String binaryName = binary.getName();

        try {
            log.info("executing " + binary);

            List<String> command = new LinkedList<String>();
            command.add(binary.getCanonicalPath());
            if (commandlineArgs != null) {
                command.addAll(commandlineArgs);
            }

            ExternalProcess p = new ExternalProcess(command);
            p.setThreadLabel(Thread.currentThread()
                .getName());
            p.directory(workingDir);

            // log to stdout/stderr. Output will go to the external log
            // files as well as the worker task log.
            p.setLogStdOut(true);
            p.setLogStdErr(true);

            stdOutWriter = new FileWriter(new File(workingDir, logPrefix
                + "stdout-.log"));
            stdErrWriter = new FileWriter(new File(workingDir, logPrefix
                + "stderr-.log"));

            p.setUserDefinedStdOutWriter(stdOutWriter);
            p.setUserDefinedStdErrWriter(stdErrWriter);

            // Make sure there are no leftover error files before launching the
            // process.
            MatlabBinFileUtils.clearStaleErrorState(workingDir,
                binary.getName(), 0);

            Map<String, String> env = p.environment();
            env.putAll(environmentVariables);

            int retCode = 0;
            IntervalMetricKey key = IntervalMetric.start();

            try {
                retCode = p.run(true, timeoutSecs * 1000);
            } finally {
                try {
                    stdOutWriter.close();
                } catch (Exception e) {
                }
                try {
                    stdErrWriter.close();
                } catch (Exception e) {
                }
                IntervalMetric.stop(PROCESS_EXEC_METRIC_PREFIX + binaryName
                    + ".execTimeMillis", key);
            }

            return retCode;
        } finally {
            if (stdOutWriter != null) {
                try {
                    stdOutWriter.close();
                } catch (IOException e) {
                    log.warn("failed to close stdOutWriter", e);
                }
            }
            if (stdErrWriter != null) {
                try {
                    stdErrWriter.close();
                } catch (IOException e) {
                    log.warn("failed to close stdErrWriter", e);
                }
            }
        }
    }

    /**
     * For testing purposes only.
     */
    public void setWorkingDirManager(WorkingDirManager workingDirManager) {
        ExternalProcessPipelineModule.workingDirManager = workingDirManager;
    }
}
