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

import gov.nasa.kepler.pi.module.AlgorithmStateFile;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.SubTaskClient;
import gov.nasa.kepler.pi.module.SubTaskServer;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.concurrent.Semaphore;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteWatchdog;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class RemoteSubTaskMaster implements Runnable{
    private static final Log log = LogFactory.getLog(RemoteSubTaskMaster.class);

    int threadNumber = -1;
    private String node;
    private String headNode;
    private Semaphore complete;
    private String binaryName;
    private String taskDir;
    private int timeoutSecs;
    private String distDir;
        
    public RemoteSubTaskMaster(int threadNumber, String node, String headNode, Semaphore complete, String binaryName,
        String taskDir, int timeoutSecs, String distDir) {
        
        this.threadNumber = threadNumber;
        this.node = node;
        this.headNode = headNode;
        this.complete = complete;
        this.binaryName = binaryName;
        this.taskDir = taskDir;
        this.timeoutSecs = timeoutSecs;
        this.distDir = distDir;
    }

    @Override
    public void run() {

        try {
            boolean done = false;
            
            while(!done){
                SubTaskClient subTaskClient = null;
                SubTaskServer.Response response = null;

                try {
                    subTaskClient = new SubTaskClient(headNode);
                    response = subTaskClient.getNextSubTask();

                    if(response.successful()){
                        int groupIndex = response.groupIndex;
                        int subTaskIndex = response.subTaskIndex;
                        
                        log.debug(threadNumber + ": Processing sub-task: " + Pair.of(groupIndex, subTaskIndex));
                        
                        File subTaskDir = InputsHandler.subTaskDirectory(new File(taskDir), groupIndex, subTaskIndex);
                        
                        if(!subTaskComplete(subTaskDir)){
                            executeSubTask(subTaskDir, threadNumber, groupIndex, subTaskIndex);
                        }
                        
                        // sleep-hack to flush NFS caches before reporting up the call chain
                        // AlgorithmStateFile and Matlab files have just been created and/or written to
                        try {
                            Thread.sleep(65000);
                        } catch (InterruptedException e) {
                            log.warn("NFS consistency sleep awoken by e:" + e, e);
                        }
                            
                        subTaskClient.reportSubTaskComplete(groupIndex, subTaskIndex);
                    }else{
                        // no more available or error
                        done = true;
                    }
                } catch (Exception e) {
                    log.error(threadNumber + ": Failed to process sub task " + response
                        + ", caught:", e);
                }                
            }
            log.info("Node: " + node + "[" + threadNumber + "]: No more subtasks to process, thread exiting");
        } finally {
            complete.release();
        }
    }


    /**
     * Checks for the existence of an {@link AlgorithmStateFile} from a previous
     * run and reset the state appropriately:
     * 
     * .PROCESSING : Delete metadata files and return false
     * .COMPLETE : Do nothing and return true
     * .FAILED : Delete metadata files and return false
     * No File : do nothing, return false
     *  
     * @param subTaskDir
     * @return
     */
    private boolean subTaskComplete(File subTaskDir) {
        
        AlgorithmStateFile previousAlgorithmState = new AlgorithmStateFile(subTaskDir);
        
        if(!previousAlgorithmState.exists()){
            // no previous run exists
            log.info("No previous algorithm state file found, executing this sub-task");
            return false;
        }
        
        if(previousAlgorithmState.isComplete()){
            log.info("sub-task algorithm state = COMPLETE, skipping this sub-task");
            return true;
        }
        
        if(previousAlgorithmState.isFailed()){
            log.info("sub-task algorithm state = FAILED, re-running this sub-task");
            return false;
        }
        
        if(previousAlgorithmState.isProcessing()){
            log.info("sub-task algorithm state = PROCESSING, re-running this sub-task");
            return false;
        }
        
        log.info("Unexpected sub-task algorithm state = " + previousAlgorithmState.currentState() + ", re-running this sub-task");
        return false;
    }

    private void executeSubTask(File subTaskDir, int threadNumber, int groupIndex, int subTaskIndex) throws IOException {
        TimestampFile.create(subTaskDir, TimestampFile.Event.SUB_TASK_START);
        
        CommandLine commandLine = new CommandLine(distDir + "/bin/nas-job-launcher.sh");
        
        commandLine.addArgument(taskDir);
        commandLine.addArgument(subTaskDir.getAbsolutePath());
        commandLine.addArgument("" + groupIndex);
        commandLine.addArgument("" + subTaskIndex);
        commandLine.addArgument(binaryName);
        commandLine.addArgument("" + timeoutSecs);
        commandLine.addArgument(distDir);
        
        int retCode = 0;
        
        try {
            
            log.info("START sub-task: " + Pair.of(groupIndex, subTaskIndex) + " on " + node + "[" + threadNumber + "]");
            
            DefaultExecutor executor = new DefaultExecutor();
            ExecuteWatchdog timeout = new ExecuteWatchdog(timeoutSecs * 1000);
            executor.setWatchdog(timeout);

            // suppress output to stdout/err so it doesn't go into the overall task log
            // this output already gets logged to the log file in the task dir
            PumpStreamHandler outputHandler = new PumpStreamHandler(new NullLogOutputStream());
            executor.setStreamHandler(outputHandler);

            retCode = executor.execute(commandLine);
            
            log.info("FINISH sub-task " + subTaskIndex + " on " + node + ", rc: " + retCode);
            
            if(executor.isFailure(retCode) && timeout.killedProcess()){
                log.error("sub-task " + subTaskIndex + " on " + node + " was killed due to timeout");
            }
        } catch (Exception e) {
            throw new PipelineException("Failed to run: " + commandLine + ", caught e=" + e, e);
        } finally {
            TimestampFile.create(subTaskDir, TimestampFile.Event.SUB_TASK_FINISH);
        }
        
        if(retCode != 0){
            throw new PipelineException("Failed to run: " + commandLine + ", retCode=" + retCode);
        }
    }
}
