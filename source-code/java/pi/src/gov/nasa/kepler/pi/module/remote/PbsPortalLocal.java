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

import gov.nasa.kepler.pi.worker.WorkerEventLog;
import gov.nasa.kepler.services.cmdrunner.StringLogOutputStream;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.StringReader;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteWatchdog;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class provides an interface to the Pleiades
 * scheduler, the Portable Batch System (PBS).
 * 
 * This class uses the PBS 'qsub' and 'qstat' commands
 * running on the local host to submit and monitor jobs.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class PbsPortalLocal {
    private static final Log log = LogFactory.getLog(PbsPortalLocal.class);

    //TODO: move to config, support multiple architectures
    private static final double WESTMERE_MEMORY_GIGS = 24.0;
    private static final long QSTAT_TIMEOUT_MILLIS = 30000;
    
    private File stateFileDir;
    private File taskRootDir;
    private File distDir;
    
    private Map<Long,PbsJob> jobsByTaskId = new HashMap<Long,PbsJob>();
    
    public PbsPortalLocal(File stateFileDir, File taskRootDir, File distDir) {
        this.stateFileDir = stateFileDir;
        this.taskRootDir = taskRootDir;
        this.distDir = distDir;
    }

    public PbsPortalLocal(File stateFileDir, File taskRootDir) {
        this.stateFileDir = stateFileDir;
        this.taskRootDir = taskRootDir;
    }

    public void submit(List<StateFile> stateFiles){
        
        /* for each state file, first check to see whether it's already
         * in the current job list. If not, update the job list and check again
         * (we don't update the list on every submittal in order to reduce the 
         * number of calls to qstat) 
         */
        for (StateFile stateFile : stateFiles) {
            long taskId = stateFile.getPipelineTaskId();
            
            if(!jobsByTaskId.containsKey(taskId)){
                if(updateTaskToJobMap() && !jobsByTaskId.containsKey(taskId)){
                    StateFile previousStateFile = new StateFile(stateFile);
                    
                    stateFile.getProps().addProperty(PleiadesDirect.PBS_SUBMIT_STATEFILE_PROPNAME, 
                        System.currentTimeMillis());
                    try {
                        stateFile.persist(stateFileDir);
                    } catch (Exception e) {
                        log.warn("Failed to persist state file with updated submit time");
                    }

                    stateFile.setState(StateFile.State.QUEUED);
                    
                    log.info("Updating state: " + previousStateFile + " -> " + stateFile);

                    if(!StateFile.updateStateFile(previousStateFile, stateFile, stateFileDir)){
                        log.error("Failed to update state file: " + previousStateFile);
                    }

                    callJobLauncher(stateFile);
                }
            }
        }
    }
    
    private void callJobLauncher(StateFile stateFile) {
        log.info("Launching job for state file: " + stateFile);
        
        final File tarFile = new File(taskRootDir, stateFile.taskArchiveName());
        
        if(!tarFile.exists()){
            throw new PipelineException("tarFile not found: " + tarFile.getAbsolutePath());
        }
        
        double numCores = Math.ceil((double)stateFile.getNumTotal() / stateFile.getTasksPerCore());
        int coresPerNode = (int) Math.floor(WESTMERE_MEMORY_GIGS / stateFile.getGigsPerCore());
        int numNodes = (int) Math.ceil(numCores / coresPerNode);
        
        WorkerEventLog.event("Launching job, name=" + stateFile.invariantPart() 
            + ", numCores=" + numCores 
            + ", coresPerNode=" + coresPerNode 
            + ", numNodes=" + numNodes); 

        JobLauncher launcher = new PleiadesPbsJobLauncher();
        final File taskDir = new File(taskRootDir, stateFile.taskDirName());
        String stateFilePath = new File(stateFileDir, stateFile.name()).getAbsolutePath();
        int retCode = launcher.launchJobsForTask(stateFilePath, taskDir, numNodes, coresPerNode, distDir);

        if(retCode != 0){
            log.error("Failed to launch job for state file: " + stateFile);
        }
    }

    private boolean updateTaskToJobMap(){
        jobsByTaskId = new HashMap<Long,PbsJob>();
        
        String user = System.getProperty("user.name");
        
        // qstat -e -u tklaus -W o=JobID,Jobname,S
        CommandLine commandLine = new CommandLine("qstat");
        commandLine.addArgument("-u");
        commandLine.addArgument(user);
        commandLine.addArgument("-e");
        commandLine.addArgument("-W");
        commandLine.addArgument("o=JobID,Jobname,S");
        
        DefaultExecutor executor = new DefaultExecutor();
        ExecuteWatchdog timeout = new ExecuteWatchdog(QSTAT_TIMEOUT_MILLIS);
        executor.setWatchdog(timeout);

        StringLogOutputStream stdOut = new StringLogOutputStream();
        PumpStreamHandler outputHandler = new PumpStreamHandler(stdOut);
        executor.setStreamHandler(outputHandler);

        try {
            int retCode = executor.execute(commandLine);
            
            if(retCode == 0){
                BufferedReader reader = new BufferedReader(new StringReader(stdOut.contents()));
                int lineno = 0;
                String oneLine = reader.readLine();
                
                while(oneLine != null){
                    if(lineno > 1){ // skip the header lines
                        try {
                            PbsJob pbsJob = new PbsJob(oneLine);
                            jobsByTaskId.put(pbsJob.getTaskId(), pbsJob);
                        } catch (Exception e) {
                            log.warn("Failed to parse qstat output line: " + oneLine);
                        }
                    }
                    
                    oneLine = reader.readLine();
                    lineno++;
                }
            }else{
                log.warn("Failed to run qstat, retCode = " + retCode);
                return false;
            }
        } catch (Exception e) {
            log.warn("Failed to run qstat, caught e = " + e, e);
            return false;
        }
        return true;
    }
}
