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

package gov.nasa.kepler.pi.worker;

import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.KeplerHibernateConfiguration;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.kepler.services.process.PipelineProcessAdminOperations;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.util.Date;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class creates a report {@link File} for the given {@link PipelineTask}
 * in the given output directory.
 * 
 * @author Miles Cote
 * 
 */
public class TaskReporter {

    public static final String FS_WRAPPER_LOG = "fs.wrapper.log";

    public static final String getFsWrapperLogFileName(PipelineTask pipelineTask) {
        return FS_WRAPPER_LOG + "-" + pipelineTask.getId();
    }

    private static final int REQUEST_TIMEOUT_MILLIS = 60 * 60 * 1000;
    private static final Log log = LogFactory.getLog(TaskReporter.class);

    /**
     * @param pipelineTask
     * @param outputDir
     * @return the {@link File} that contains the report of the input
     * {@link PipelineTask}
     * @throws Exception
     */
    public File report(PipelineTask pipelineTask, File outputDir)
        throws Exception {
        // Copy fs.wrapper.log, if it exists.
        File fsWrapperLog = new File(SocEnvVars.getLocalDistDir() + "/logs",
            FS_WRAPPER_LOG);
        if (fsWrapperLog.exists()) {
            File fsWrapperLogCopy = new File(outputDir,
                getFsWrapperLogFileName(pipelineTask));
            FileUtils.copyFile(fsWrapperLog, fsWrapperLogCopy);
        }

        if (pipelineTask == null) {
            throw new IllegalArgumentException("pipelineTask must not be null.");
        }

        if (outputDir == null) {
            throw new IllegalArgumentException("outputDir must not be null.");
        }

        outputDir.mkdirs();

        log.info("Retrieve task log.");
        WorkerOperations workerOps = new WorkerOperations();
        String taskLogContents = workerOps.retrieveTaskLog(pipelineTask);

        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();

        log.info("Retrieve disk use info.");
        WorkerDiskUseResponse diskUseResponse = (WorkerDiskUseResponse) ops.adminRequest(
            WorkerPipelineProcess.NAME, pipelineTask.getWorkerHost(),
            new WorkerDiskUseRequest());

        log.info("Copy task file dir.");
        String taskFileStatus = copyTaskFiles(pipelineTask, outputDir);

        File reportFile = report(pipelineTask, outputDir, taskLogContents,
            taskFileStatus, diskUseResponse);

        return reportFile;
    }

    private String copyTaskFiles(PipelineTask pipelineTask, File outputDir) {
        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();
        WorkerTaskWorkingDirResponse response = ops.adminRequest(
            WorkerPipelineProcess.NAME, pipelineTask.getWorkerHost(),
            new WorkerTaskWorkingDirRequest(pipelineTask.getPipelineInstance()
                .getId(), pipelineTask.getId(), outputDir, true, false),
            REQUEST_TIMEOUT_MILLIS);

        return response.getStatus();
    }

    /**
     * @param pipelineTask must not be null
     * @param outputDir must not be null
     * @param response must not be null
     * @param taskFileStatus
     * @param diskUseResponse
     * @return the report {@link File}
     * @throws IOException
     */
    public File report(PipelineTask pipelineTask, File outputDir,
        String taskLogContents, String taskFileStatus,
        WorkerDiskUseResponse diskUseResponse) throws IOException {
        if (pipelineTask == null) {
            throw new IllegalArgumentException("pipelineTask must not be null.");
        }

        if (outputDir == null) {
            throw new IllegalArgumentException("outputDir must not be null.");
        }
        outputDir.mkdirs();

        if (taskLogContents == null) {
            throw new IllegalArgumentException(
                "taskLogContents must not be null.");
        }

        if (taskFileStatus == null) {
            taskFileStatus = "";
        }

        long taskId = pipelineTask.getId();
        long instanceId = pipelineTask.getPipelineInstance()
            .getId();

        log.info("Generate report.");
        File reportFile = new File(outputDir, "task-" + instanceId + "-"
            + taskId + "-report.txt");
        reportFile.delete();

        Configuration configService = ConfigurationServiceFactory.getInstance();
        UnitOfWorkTask uowTask = pipelineTask.uowTaskInstance();

        StringBuilder builder = new StringBuilder();

        builder.append("state: " + pipelineTask.getState() + "\n\n");

        builder.append("pegRevision: " + pipelineTask.getSoftwareRevision()
            + "\n\n");

        builder.append("fsUrl: "
            + configService.getString(FileStoreConstants.FS_FSTP_URL) + "\n");
        builder.append("databaseUrl: "
            + configService.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_URL_PROP)
            + "\n");
        builder.append("databaseUser: "
            + configService.getString(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_USERNAME_PROP)
            + "\n\n");

        builder.append("module: " + pipelineTask.getPipelineDefinitionNode()
            .getModuleName()
            .getName() + "\n");
        builder.append("instanceId: " + pipelineTask.getPipelineInstance()
            .getId() + "\n");
        builder.append("taskId: " + pipelineTask.getId() + "\n");
        builder.append("uowTask: " + uowTask.getClass()
            .getSimpleName() + ":" + uowTask.briefState() + "\n");
        builder.append("totalProcessingHours: "
            + getProcessingHours(pipelineTask.getStartProcessingTime(),
                pipelineTask.getEndProcessingTime()) + "\n\n");

        builder.append("workerHost: " + pipelineTask.getWorkerHost() + "\n");
        builder.append("diskUsePercent: " + diskUseResponse.getUsePercent()
            + "\n\n");

        builder.append("matlabVersion: " + getMatlabVersion() + "\n");
        builder.append("taskFileDir: " + taskFileStatus + "\n\n");

        File fsWrapperLog = new File(outputDir,
            getFsWrapperLogFileName(pipelineTask));
        String fsWrapperLogStatus = null;
        if (fsWrapperLog.exists()) {
            fsWrapperLogStatus = fsWrapperLog.getAbsolutePath();
        } else {
            fsWrapperLogStatus = "not copied";
        }
        builder.append(FS_WRAPPER_LOG + ": " + fsWrapperLogStatus + "\n\n");

        builder.append("log:\n" + taskLogContents);

        String errorReport = builder.toString();

        FileUtils.writeStringToFile(reportFile, errorReport);
        return reportFile;
    }

    private String getMatlabVersion() throws IOException {
        String matlabVersion = "unknown";

        String mcrRoot = ConfigurationServiceFactory.getInstance()
            .getString(MatlabMcrExecutable.MODULE_EXE_MCRROOT_PROPERTY_NAME);
        File versionFile = new File(mcrRoot, ".VERSION");
        BufferedReader br = new BufferedReader(new FileReader(versionFile));
        try {
            matlabVersion = br.readLine();
        } finally {
            br.close();
        }

        return matlabVersion;
    }

    private double getProcessingHours(Date start, Date end) {
        double processingMillis = end.getTime() - start.getTime();
        double processingHours = processingMillis / (1000.0 * 60.0 * 60.0);

        return processingHours;
    }

    public static void main(String[] args) throws Exception {
        if (args.length != 2) {
            System.err.println("USAGE: report-task PIPELINE_TASK_ID OUTPUT_DIR");
            System.err.println("  EXAMPLE: report-task 100 output-dir");
            System.err.println("  NOTE: if a taskFileDir exists, then it will be copied into OUPTUT_DIR");
            System.exit(-1);
        }

        int pipelineTaskId = Integer.parseInt(args[0]);
        String outputDirPath = args[1];

        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
        PipelineTask pipelineTask = pipelineTaskCrud.retrieve(pipelineTaskId);

        File outputDir = new File(outputDirPath);

        TaskReporter reporter = new TaskReporter();
        File reportFile = reporter.report(pipelineTask, outputDir);

        System.out.println("reportFile: " + reportFile);
        System.exit(0);
    }

}
