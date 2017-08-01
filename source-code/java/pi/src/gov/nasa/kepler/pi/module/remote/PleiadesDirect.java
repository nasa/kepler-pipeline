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

package gov.nasa.kepler.pi.module.remote;

import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.pi.module.AlgorithmStateFile;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.module.TaskDirectoryIterator;
import gov.nasa.kepler.pi.module.remote.sup.SupCommandResults;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.metrics.Metric;
import gov.nasa.spiffy.common.metrics.ValueMetric;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.compress.archivers.ArchiveException;
import org.apache.commons.compress.archivers.ArchiveStreamFactory;
import org.apache.commons.compress.archivers.tar.TarArchiveEntry;
import org.apache.commons.compress.archivers.tar.TarArchiveInputStream;
import org.apache.commons.compress.utils.IOUtils;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Implements the {@link RemoteCluster} interface using {@link PbsPortalSup}
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class PleiadesDirect implements RemoteCluster {
    private static final Log log = LogFactory.getLog(PleiadesDirect.class);

    public static final String PFE_ARRIVAL_STATEFILE_PROPNAME = "pfeArrivalTimeMillis";
    public static final String PBS_SUBMIT_STATEFILE_PROPNAME = "pbsSubmitTimeMillis";

    /** Multiplier used to determine the overall timeout for remote execution.
     * The overall timeout is module exe timeout from the module definition
     * times the TK_FACTOR. */
    private static final int TK_FACTOR = 6;
    private static final String JAVA_IO_TMPDIR = "java.io.tmpdir";

    private static final int REMOTE_TRANSFER_MAX_RETRIES = 20;
    protected static final int REMOTE_TRANSFER_TIMEOUT_MILLIS = 5 * 60 * 60 * 1000; // 5 hours
        
    private static final String PULL_TASK_FILES_METRIC_NAME = "pi.remoteExec.local.pullTaskFiles.timeMillis";
    private static final String PUSH_TASK_FILES_METRIC_NAME = "pi.remoteExec.local.pushTaskFiles.timeMillis";

    private static final String BIN2MAT_EXE_NAME = "bin_to_mat";
    private static final int BIN2MAT_EXE_TIMEOUT_SECS = 10 * 60 * 60; // 10 hrs

    public PleiadesDirect(){
    }
    
    /**
     * Submit the specified {@link PipelineTask} to the remote cluster.
     * 
     * This method returns as soon as the task files and state file have been
     * successfully transfered to the remote cluster and qsub has been called
     * or an error occurs.
     * 
     * @param pipelineTask
     * @param taskWorkingDir
     * @return
     * @throws Exception
     */
    @Override
    public File submitTask(PipelineTask pipelineTask, File taskWorkingDir, int numSubTasks) throws Exception{
    
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, true);    
        
        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
        long instanceId = pipelineTask.getPipelineInstance().getId();
        attrOps.updateSubTaskCounts(pipelineTask.getId(), instanceId, numSubTasks, 0, 0); 
    
        StateFile initialState = generateStateFile(pipelineTask, numSubTasks);

        // create a .tar of the input task files
        log.info("Creating .tar archive for: " + initialState);
        final File archiveFile = FileUtil.createArchive(taskWorkingDir);
        
        try {
            ValueMetric.addValue(MatlabPipelineModule.TF_INPUTS_SIZE_METRIC, archiveFile.length());
        } catch (Exception e) {
            log.warn("Failed to measure input task file size, caught e: " + e);
        }
        
        // scp files to remote cluster
        String[] remoteHost = remoteParams.getRemoteHost();
        String remoteUser = remoteParams.getRemoteUser();
        String remoteTaskFilePath = remoteParams.getRemoteTaskFilePath();
    
        final SupPortal taskFilesSupPortal = new SupPortal(remoteHost, remoteUser);
        taskFilesSupPortal.setBbftpEnabled(remoteParams.isBbftpEnabled());
        taskFilesSupPortal.setUseArcFourCiphers(remoteParams.isUseArcFourCiphers());
        
        IntervalMetricKey key = IntervalMetric.start();
        try{
            log.info("Pushing task files for: " + initialState);
            
            attrOps.updateProcessingState(pipelineTask.getId(), instanceId, ProcessingState.SENDING);
            
            SupCommandResults r = taskFilesSupPortal.putFiles(archiveFile.getCanonicalPath(), 
                remoteTaskFilePath, true, 0, REMOTE_TRANSFER_MAX_RETRIES);
            if(r.failed()){
                String msg = "failed to push task files, r=" + r;
                log.error(msg);
                
                throw new ModuleFatalProcessingException(msg);
            }
        }finally{
            IntervalMetric.stop(PUSH_TASK_FILES_METRIC_NAME, key);
            
            try {
                // delete task files and tar file
                log.info("deleting: " + archiveFile);
                FileUtils.deleteQuietly(archiveFile);
                log.info("deleting: " + taskWorkingDir);
                FileUtils.deleteQuietly(taskWorkingDir);
            } catch (Exception e) {
                log.info("Failed to delete task files and/or .tar file, caught e = " + e, e);
            }
        }
                    
        submitToPbs(initialState, pipelineTask);
        
        return archiveFile;
    }

	private void pushStateFile(RemoteExecutionParameters remoteParams,
			StateFile initialState, String[] remoteHost, String remoteUser,
			String remoteStateFilePath) throws Exception {

		long now = System.currentTimeMillis();
    
		SupPortal stateFileSupPortal = new SupPortal(remoteHost, remoteUser);
        stateFileSupPortal.setBbftpEnabled(false); // inefficient for small files
        stateFileSupPortal.setUseArcFourCiphers(remoteParams.isUseArcFourCiphers());
    
        initialState.getProps().addProperty(PBS_SUBMIT_STATEFILE_PROPNAME, now);
        initialState.getProps().addProperty(PFE_ARRIVAL_STATEFILE_PROPNAME, now);
        
        // Remove existing state file for this task, if it exists
        String existingPath = new File(remoteStateFilePath, initialState.invariantPart() + "*").getAbsolutePath();
        SupCommandResults result = stateFileSupPortal.removeFile(existingPath);
        if(result.failed()){
            log.info("removeFile result = " + result);
        }
        
        // create state file on remote host
        log.info("Pushing state file for: " + initialState);
        initialState.getProps().addProperty(PFE_ARRIVAL_STATEFILE_PROPNAME, System.currentTimeMillis());
        
        final File tmpFile = initialState.persist(new File(System.getProperty(JAVA_IO_TMPDIR)));
    
        try {
            SupCommandResults results = stateFileSupPortal.putFiles(tmpFile.getAbsolutePath(), 
                remoteStateFilePath, true, REMOTE_TRANSFER_TIMEOUT_MILLIS, REMOTE_TRANSFER_MAX_RETRIES);
            
            log.info("putFiles result = " + results);
            
            if (results.failed()) {
                String msg = "failed to scp initial state file to remote server, " + results;
                log.error(msg);
                throw new ModuleFatalProcessingException(msg);
            }
        } catch (Exception e) {
            String remoteStateFile = remoteStateFilePath + File.separator + initialState.name();
            String msg = "failed to create remote state file (" + remoteStateFile + "), caught e = " + e;
            log.error(msg);
            throw new ModuleFatalProcessingException(msg, e);
        } finally {
            if(tmpFile != null){
                tmpFile.delete();
            }
        }
	}

    public StateFile generateStateFile(PipelineTask pipelineTask, int numSubTasks){
        PipelineModuleDefinition module = pipelineTask.getPipelineInstanceNode()
        .getPipelineModuleDefinition();
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, true);    

        StateFile state = new StateFile(pipelineTask.getPipelineInstance().getId(), 
            pipelineTask.getId(), module.getExeName(),  
            module.getExeTimeoutSecs(), 
            remoteParams.getGigsPerCore(),
            remoteParams.getTasksPerCore(),
            selectArch(remoteParams.getRemoteNodeArchitectures()),
            remoteParams.isLocalBinToMatEnabled(),
            remoteParams.getRequestedWallTime(),
            remoteParams.isMemdroneEnabled(),
            remoteParams.getRemoteGroup(),
            remoteParams.getQueueName(),
            remoteParams.isReRunnable(),
            numSubTasks,
            remoteParams.isSymlinksEnabled());
        
        state.setState(StateFile.State.QUEUED);
        
        return state;
    }
    
    public void submitToPbs(StateFile initialState, PipelineTask pipelineTask) throws Exception{

        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, true);    
        String[] remoteHost = remoteParams.getRemoteHost();
        String remoteUser = remoteParams.getRemoteUser();
        String remoteTaskFilePath = remoteParams.getRemoteTaskFilePath();
        String remoteStateFilePath = remoteParams.getRemoteStateFilePath();
        
        SupPortal qsubSupPortal = new SupPortal(remoteHost, remoteUser);
        
        File remoteDistDirPath = new File(new File(remoteTaskFilePath).getParent(), "/path/to/dist"); 
        PbsPortalSup pbsPortal = new PbsPortalSup(qsubSupPortal, new File(remoteStateFilePath), 
            new File(remoteTaskFilePath), remoteDistDirPath);

        pushStateFile(remoteParams, initialState, remoteHost, remoteUser,
				remoteStateFilePath);
        
        pbsPortal.submit(initialState);
        
        // update processing state
        log.info("Updating processing state -> " + ProcessingState.ALGORITHM_QUEUED);
        
        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
        long instanceId = pipelineTask.getPipelineInstance().getId();

        attrOps.updateProcessingState(pipelineTask.getId(), instanceId, ProcessingState.ALGORITHM_QUEUED);
    }
    
    /**
     * @param remoteNodeArchitectures
     * @return
     */
    private String selectArch(String[] remoteNodeArchitectures) {
        if(remoteNodeArchitectures.length == 0){
            throw new PipelineException("No architecture specified");
        }else if(remoteNodeArchitectures.length == 1){
            return remoteNodeArchitectures[0];
        }else{
            // randomly select
            int index = (int) Math.floor(Math.random() * remoteNodeArchitectures.length);
            return remoteNodeArchitectures[index];
        }
    }

    /**
     * Add the specified task to this worker's {@link RemoteMonitor}. 
     * 
     * This method returns immediately.
     * 
     * @param pipelineTask
     */
    @Override
    public void addToMonitor(PipelineTask pipelineTask){
        PipelineModuleDefinition module = pipelineTask.getPipelineInstanceNode()
        .getPipelineModuleDefinition();
    
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, true);
    
        StateFile stateFile = new StateFile(pipelineTask.getPipelineInstance().getId(), 
            pipelineTask.getId(), module.getExeName());
        
        RemoteMonitor remoteMonitor = RemoteMonitor.getInstance(remoteParams);
        remoteMonitor.startMonitoring(stateFile);
    }

    /**
     * Block until the specified task completes on the remote cluster.
     * 
     * Used only when running {@link AsyncPipelineModule}s in local mode.
     * 
     * @param pipelineTask
     * @return
     */
    @Override
    public StateFile waitForCompletion(PipelineTask pipelineTask){
        PipelineModuleDefinition module = pipelineTask.getPipelineInstanceNode()
        .getPipelineModuleDefinition();
    
        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, true);
        String[] remoteHost = remoteParams.getRemoteHost();
        String remoteUser = remoteParams.getRemoteUser();
        String remoteStateFilePath = remoteParams.getRemoteStateFilePath();
    
        StateFile stateFile = new StateFile(pipelineTask.getPipelineInstance().getId(), 
            pipelineTask.getId(), module.getExeName());
        
        // poll & update PipelineTask state until complete or failed
        long timeoutMillis = module.getExeTimeoutSecs() * 1000 * TK_FACTOR;
        RemotePoller poller = RemotePollerFactory.getInstance(remoteHost[0], remoteUser, remoteStateFilePath);
        StateFile finalState = poller.waitForCompletion(stateFile, timeoutMillis);
        
        return finalState;
    }

    @Override
    public void retrieveTaskOutputs(PipelineTask pipelineTask, File taskWorkingDir, int sequenceNum) throws Exception{

        RemoteExecutionParameters remoteParams = pipelineTask.getParameters(RemoteExecutionParameters.class, true);
        String[] remoteHost = remoteParams.getRemoteHost();
        String remoteUser = remoteParams.getRemoteUser();
        String remoteTaskFilePath = remoteParams.getRemoteTaskFilePath();

        PipelineModuleDefinition module = pipelineTask.getPipelineInstanceNode()
        .getPipelineModuleDefinition();
        SupPortal supPortal = new SupPortal(remoteHost, remoteUser);
        supPortal.setBbftpEnabled(remoteParams.isBbftpEnabled());
        supPortal.setUseArcFourCiphers(remoteParams.isUseArcFourCiphers());

        // scp results back (merge outputs into original task dir)

        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
        long instanceId = pipelineTask.getPipelineInstance().getId();

        attrOps.updateProcessingState(pipelineTask.getId(), instanceId, ProcessingState.RECEIVING);

        log.info("Pulling task files for: " + taskWorkingDir.getName());
        
        File archiveFile = new File(taskWorkingDir.getParent(), taskWorkingDir.getName() + ".tar");
        
        final String source = remoteTaskFilePath + File.separator 
            + archiveFile.getName();
        
        IntervalMetricKey key = IntervalMetric.start();
        
        try{
            SupCommandResults getResult = supPortal.getFiles(source, archiveFile.getParentFile().getCanonicalPath(), 
                true, 0, REMOTE_TRANSFER_MAX_RETRIES);
            if(getResult.failed()){
                throw new ModuleFatalProcessingException("failed to retrieve task files, r=" + getResult);
            }               
        }finally{
            IntervalMetric.stop(PULL_TASK_FILES_METRIC_NAME, key);
        }
        
        try {
            ValueMetric.addValue(MatlabPipelineModule.TF_PFE_OUTPUTS_SIZE_METRIC, archiveFile.length());
        } catch (Exception e) {
            log.warn("Failed to measure pleiades outputs task file size, caught e: " + e);
        }
        
        // Unpack the .tar archive
        //FileUtil.extractArchive(taskWorkingDir.getParentFile(), archiveFile);
        unTar(archiveFile, taskWorkingDir.getParentFile());
        
        // remove the tar file to save disk space
        FileUtils.deleteQuietly(archiveFile);
        
        // count failures and merge in metrics for completed sub-tasks
        TaskDirectoryIterator directoryIterator = new TaskDirectoryIterator(taskWorkingDir);
//        int numSubTasks = MatlabPipelineModule.countSubTasks(taskWorkingDir);        
        int numFailures = 0;

        while(directoryIterator.hasNext()){
            // merge in metrics generated by the MATLAB process
            try {
                File subTaskDir = directoryIterator.next().right;
                
                AlgorithmStateFile subTaskState = new AlgorithmStateFile(subTaskDir);
                if(subTaskState.isFailed()){
                    numFailures++;
                }
                
                File metricsFile = new File(subTaskDir, "metrics-" + sequenceNum + ".ser");
                if(metricsFile.exists()){
                    Metric.merge(metricsFile.getAbsolutePath());
                }
            } catch (Exception e) {
                log.warn("Failed to merge metrics from the MATLAB process, e=" + e);
            }
        }
        
        log.info("numFailures: " + numFailures);
        
        attrOps.updateProcessingState(pipelineTask.getId(), instanceId, ProcessingState.STORING);

        // Convert .bin files to .mat files if necessary
        if(remoteParams.isLocalBinToMatEnabled()){
            MatlabMcrExecutable matlabExe = new MatlabMcrExecutable(BIN2MAT_EXE_NAME, taskWorkingDir,
                BIN2MAT_EXE_TIMEOUT_SECS);
            
            String moduleExeName = module.getExeName();
            String taskDirPath = taskWorkingDir.getAbsolutePath();
            
            List<String> commandLineArgs = new LinkedList<String>();
            commandLineArgs.add(moduleExeName);
            commandLineArgs.add(taskDirPath);

            log.info("START bin_to_mat for: " + moduleExeName + " in dir: " + taskDirPath);
            
            int rc = matlabExe.execSimple(commandLineArgs);
            
            if(rc != 0){
                log.warn("bin_to_mat FAILED with retcode=" + rc);
            }
            
            log.info("FINISHED bin_to_mat for: " + moduleExeName + " in dir: " + taskDirPath);
        }
    }

    /** Untar an input file into an output file.

     * The output file is created in the output folder, having the same name
     * as the input file, minus the '.tar' extension. 
     * 
     * @param inputFile     the input .tar file
     * @param outputDir     the output directory file. 
     * @throws IOException 
     * @throws FileNotFoundException
     *  
     * @return  The {@link List} of {@link File}s with the untared content.
     * @throws ArchiveException 
     */
    private List<File> unTar(final File inputFile, final File outputDir) throws IOException, ArchiveException {

        log.info(String.format("Untaring %s to dir %s.", inputFile.getAbsolutePath(), outputDir.getAbsolutePath()));

        final List<File> untaredFiles = new LinkedList<File>();
        final InputStream is = new FileInputStream(inputFile); 
        final TarArchiveInputStream tarInputStream = (TarArchiveInputStream) new ArchiveStreamFactory().createArchiveInputStream("tar", is);
        TarArchiveEntry entry = null; 

        while ((entry = (TarArchiveEntry)tarInputStream.getNextEntry()) != null) {
            final File outputFile = new File(outputDir, entry.getName());
            if (entry.isDirectory()) {
                
                log.debug(String.format("Attempting to write output directory %s.", outputFile.getAbsolutePath()));
                if (!outputFile.exists()) {
                    log.debug(String.format("Attempting to create output directory %s.", outputFile.getAbsolutePath()));
                    if (!outputFile.mkdirs()) {
                        throw new IllegalStateException(String.format("Couldn't create directory %s.", outputFile.getAbsolutePath()));
                    }
                }
            } else {
                log.debug(String.format("Creating output file %s.", outputFile.getAbsolutePath()));
                final OutputStream outputFileStream = new FileOutputStream(outputFile); 
                IOUtils.copy(tarInputStream, outputFileStream);
                outputFileStream.close();
            }
            untaredFiles.add(outputFile);
        }
        tarInputStream.close(); 

        return untaredFiles;
    }
}
