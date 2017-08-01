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

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.pi.module.AlgorithmStateFile;
import gov.nasa.kepler.pi.module.InputsGroup;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.SubTaskServer;
import gov.nasa.kepler.pi.module.SubTaskUtils;
import gov.nasa.kepler.services.cmdrunner.Log4jLogOutputStream;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.InetAddress;
import java.util.LinkedList;
import java.util.List;
import java.util.concurrent.Semaphore;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class acts as a controller for a task and associated sub-tasks
 * running on a group of remote computing nodes.  
 * 
 * {@link RemoteTaskMaster} distributes the sub-task jobs evenly across
 * the available nodes using the constraints set in the {@link StateFile},
 * monitors those jobs, logs important information about each sub-task life cycle,
 * and rolls up the aggregate status to the task {@link StateFile}.
 * 
 * @author tklaus
 *
 */
public class RemoteTaskMaster {
    private static final Log log = LogFactory.getLog(RemoteTaskMaster.class);

    private static final long SLEEP_INTERVAL_MILLIS = 10000;
    //private static final double MINIMUM_AVAIL_MEMORY_GIGS = 24.0;
    private static final String PBS_NODEFILE_ENV_NAME = "PBS_NODEFILE"; 

    private String workingDir;
    private String distDir;
    private List<String> nodes;
    
    private String headNode;
    private StateFile stateFile;
    private File stateFileDir;
    private File taskDir;
    
    private Semaphore nodeMastersRunning = null;

    private InputsHandler inputsHandler;
    
    /**
     * @param workingDir
     * @param distDir
     * @param stateFilePath
     * @param nodes
     * @throws Exception 
     */
    public RemoteTaskMaster(String workingDir, String distDir, String stateFilePath) throws Exception {
        this.workingDir = workingDir;
        this.distDir = distDir;
        
        log.info("RemoteTaskMaster START");
        log.info(" workingDir = " + workingDir);
        log.info(" distDir = " + distDir);
        log.info(" stateFilePath = " + stateFilePath);
        
        this.stateFile = new StateFile(new File(stateFilePath));
        stateFileDir = new File(stateFilePath).getParentFile();
        taskDir = new File(workingDir);        
    }

    public void go() {

        try {
            log.info(KeplerSocVersion.getProject());
            log.info("  Release: " + KeplerSocVersion.getRelease());
            log.info("  Revision: " + KeplerSocVersion.getRevision());
            log.info("  SVN URL: " + KeplerSocVersion.getUrl());
            log.info("  Build Date: " + KeplerSocVersion.getBuildDate());

            log.info("jvm version:");
            log.info("  java.runtime.name=" + System.getProperty("java.runtime.name"));
            log.info("  sun.boot.library.path=" + System.getProperty("sun.boot.library.path"));
            log.info("  java.vm.version=" + System.getProperty("java.vm.version"));

            updateStateFile();
            
            populateNodeList();
            
            unpackTaskArchive();
            
            if(stateFile.isSymlinksEnabled()){
                SubTaskUtils.makeSymlinks(taskDir);
            }
            
            createTimestamps();
                        
            startSubTaskServer();
            
            log.info("Starting node masters");           
            startNodeMasters();

            RemoteTaskMonitor monitor = new RemoteTaskMonitor(getInputsHandler(), stateFile, stateFileDir, taskDir);
            monitor.updateState();
            
            log.info("Waiting for sub-tasks to complete");
            
            boolean done = false;
            
            while(!done){

                boolean allSubTasksComplete = monitor.updateState();
                boolean nodeMastersStillRunning = nodeCheck();

                if(allSubTasksComplete){
                    log.info("All sub-tasks complete");
                }
                
                if(!nodeMastersStillRunning){
                    log.info("All node masters have exited");
                    log.info("Starting final state update pass");
                    if(monitor.updateState()){
                        // done
                        log.info("All sub-tasks complete");
                    }else{
                        // not done, but no more node masters running.
                        log.warn("Node masters have exited, but not all sub-tasks completed.");
                    }
                }
                
                done = allSubTasksComplete || !nodeMastersStillRunning;

                if(!done){
                    try {
                        Thread.sleep(SLEEP_INTERVAL_MILLIS);
                    } catch (InterruptedException e) {
                        log.warn("rudely awoken by e:" + e, e);
                    }
                }
            }

            log.info("HACK: Sleeping for 100 seconds to allow NFS client cache to update");
            try {
                Thread.sleep(100000);
            } catch (Exception ignore) {
            }
            
            TimestampFile.create(taskDir, TimestampFile.Event.PBS_JOB_FINISH);
            
            log.info("Packaging outputs");
            
            if(stateFile.isSymlinksEnabled()){
                SubTaskUtils.removeSymlinks(taskDir);
            }

            packTaskArchive();
            
            monitor.markStateFileDone();
            
            log.info("RemoteTaskMaster: Done");
        } catch (Exception e) {
            log.fatal("failed in RemoteTaskMaster.go(), caught e = " + e, e );
        }
    }
    
    private void updateStateFile() {
        StateFile previousStateFile = new StateFile(stateFile);
        stateFile.setState(StateFile.State.PROCESSING);
        log.info("Updating state: " + previousStateFile + " -> " + stateFile);

        if(!StateFile.updateStateFile(previousStateFile, stateFile, stateFileDir)){
            log.error("Failed to update state file: " + previousStateFile);
        }        
    }

    private InputsHandler getInputsHandler(){
        if(inputsHandler == null){
            inputsHandler = InputsHandler.restore(taskDir);
        }
        return inputsHandler;
    }

    private void createTimestamps() {
        long arriveTime = stateFile.getProps().getLong(PleiadesDirect.PFE_ARRIVAL_STATEFILE_PROPNAME);
        TimestampFile.create(taskDir, TimestampFile.Event.ARRIVE_PFE, arriveTime);

        long submitTime = stateFile.getProps().getLong(PleiadesDirect.PBS_SUBMIT_STATEFILE_PROPNAME);
        TimestampFile.create(taskDir, TimestampFile.Event.QUEUED_PBS, submitTime);

        TimestampFile.create(taskDir, TimestampFile.Event.PBS_JOB_START);
    }

    private boolean nodeCheck() {
        return(nodeMastersRunning.availablePermits() < nodes.size());
    }

    private void startSubTaskServer() throws Exception {
        new SubTaskServer(headNode, getInputsHandler());
    }

    private void populateNodeList() throws Exception {
        nodes = new LinkedList<String>();
        String nodeFilePath = System.getenv(PBS_NODEFILE_ENV_NAME);
        
        log.info("Reading node list from:" + nodeFilePath);
        
        BufferedReader reader = new BufferedReader(new FileReader(nodeFilePath));

        String node = reader.readLine();
        while(node != null){
            log.info("adding node:" + node);
            nodes.add(node);
            node = reader.readLine();
        }
                
        headNode = InetAddress.getLocalHost().getHostName();
        
        log.info("headNode=" + headNode);
        
        reader.close();
    }

    private void startNodeMasters() throws InterruptedException{
        log.info("Starting node masters");
        
        final int coresPerNode = PbsArchitectures.coresPerNode(stateFile.getRemoteNodeArchitecture(), stateFile.getGigsPerCore()); 

        log.info("coresPerNode = " + coresPerNode);

        nodeMastersRunning = new Semaphore(nodes.size());
        
        for (int nodeIndex = 0; nodeIndex < nodes.size(); nodeIndex++) {
            final String node = nodes.get(nodeIndex);
            final String nodeName = "NodeMaster[" + node + "]";
            
            log.info("Starting node master on node: " + node);
            
            Thread t = new Thread(new Runnable(){
                @Override
                public void run() {

                    log.info("NodeMaster START: " + nodeName);
                    
                    startNodeMaster(node, coresPerNode);            
                    
                    log.info("NodeMaster END: " + nodeName);
                    
                }},nodeName);
            t.start();
            nodeMastersRunning.acquire();
        }
    }

    private void startNodeMaster(String node, int coresPerNode){
        
        CommandLine commandLine = new CommandLine("ssh");
        int timeoutSecs = stateFile.getTimeoutSecs();
        
        commandLine.addArgument(node);
        commandLine.addArgument(distDir + "/bin/runjava");
        commandLine.addArgument("remote-node-master");
        commandLine.addArgument("" + coresPerNode);
        commandLine.addArgument(node);
        commandLine.addArgument(headNode);
        commandLine.addArgument(stateFile.getExeName());
        commandLine.addArgument(workingDir);
        commandLine.addArgument("" + timeoutSecs);
        commandLine.addArgument(distDir);
        commandLine.addArgument("" + stateFile.isMemdroneEnabled());
        
        int retCode = 0;
        
        try {
            
            log.debug("Executing: " + commandLine);
            
            DefaultExecutor executor = new DefaultExecutor();
            PumpStreamHandler outputHandler = new PumpStreamHandler(new Log4jLogOutputStream());
            executor.setStreamHandler(outputHandler);
            
            retCode = executor.execute(commandLine);
            
            log.info("All tasks on node: " + node + " complete , rc=" + retCode);
            
            nodeMastersRunning.release();
        } catch (Exception e) {
            log.fatal("Caught exception executing nodeMaster: " + commandLine + ", caught e=" + e, e);
        }
        
        if(retCode != 0){
            log.fatal("Non-0 return code from nodeMaster: " + commandLine + ", retCode=" + retCode);
        }
    }
    
    private void packTaskArchive() {
        log.info("Packing task archive");

        File cmd = new File(distDir, "/bin/nas-pack-archive.sh");
        CommandLine commandLine = new CommandLine(cmd.getAbsolutePath());
        commandLine.addArgument(workingDir);
        
        execLocalCommand(commandLine);
    }

    private void unpackTaskArchive() throws IOException {
        
        if(new File(workingDir).exists()){
            // restart from previous run
            log.info("Cleaning old output files from previous run");

            cleanTaskDir();
        }else{
            // start from scratch
            log.info("Unpacking task archive");

            File cmd = new File(distDir, "/bin/nas-unpack-archive.sh");
            CommandLine commandLine = new CommandLine(cmd.getAbsolutePath());
            commandLine.addArgument(workingDir);
            
            execLocalCommand(commandLine);
        }
    }
    
    /**
     * Clean the task dirs for partially completed tasks.
     * 
     * if using groups
     *   for each group
     *     if any sub-tasks in group not COMPLETE
     *       clean all sub-tasks in group
     * else NOT using groups
     *   for each sub-task
     *     if not COMPLETE
     *       clean sub-task
     *       
     * @throws IOException
     */
    private void cleanTaskDir() throws IOException {
        InputsHandler ih = getInputsHandler();
        
        if(ih.hasGroups()){
            int numGroups = ih.numGroups();
            for(int groupIndex = 0; groupIndex < numGroups; groupIndex++){
                InputsGroup group = ih.getGroup(groupIndex);
                int numSubTasks = group.numSubTasks();
                if(!isGroupComplete(groupIndex, numSubTasks)){
                    cleanDir(group.groupDirectory());                    
                }
            }
        }else{
            List<File> subTaskDirs = ih.allSubTaskDirectories();
            for (File subTaskDir : subTaskDirs) {
                AlgorithmStateFile currentState = new AlgorithmStateFile(subTaskDir);
                if(currentState.isProcessing() || currentState.isFailed()){
                    cleanDir(subTaskDir);
                }
            }
        }
    }

    /**
     * Determine whether a group is complete by checking the 
     * {@link AlgorithmStateFile} for each sub-task in the group.
     * 
     * @param groupIndex
     * @param numSubTasks
     * @return
     */
    private boolean isGroupComplete(int groupIndex, int numSubTasks){
        for(int subTaskIndex = 0; subTaskIndex < numSubTasks; subTaskIndex++){
            File subTaskDir = InputsHandler.subTaskDirectory(taskDir, groupIndex, subTaskIndex);
            AlgorithmStateFile currentState = new AlgorithmStateFile(subTaskDir);
            if(currentState.isProcessing() || currentState.isFailed()){
                return false;
            }
        }
        return true;
    }
    
    /**
     * Before restarting a sub-task delete all output files
     * generated by the previous run.
     * 
     * @param dir
     * @throws IOException 
     */
    private void cleanDir(File dir) throws IOException {
        Manifest manifest = new Manifest(dir);
        
        if(manifest.exists()){
            log.info("Deleting non-input files from directory: " + dir);
            manifest.deleteNonManifestFiles();
        }else{
            log.info("No manifest file found, not cleaning dir: " + dir);
        }
    }

    private void execLocalCommand(CommandLine commandLine) throws PipelineException{
        int retCode = -1;

        log.info("Running cmd: " + commandLine);
        
        try {
            DefaultExecutor executor = new DefaultExecutor();
            PumpStreamHandler outputHandler = new PumpStreamHandler(new Log4jLogOutputStream());
            executor.setStreamHandler(outputHandler);
            
            retCode = executor.execute(commandLine);
        } catch (Exception e) {
            throw new PipelineException("Failed to run: " + commandLine + ", caught e=" + e, e);
        }
        
        if(retCode != 0){
            throw new PipelineException("Failed to run: " + commandLine + ", retCode=" + retCode);
        }
    }

    public static void main(String[] args) {
        
        if(args.length != 3){
            System.err.println("USAGE: RemoteTaskMaster workingDir distDir stateFilePath");
            System.exit(-1);
        }

        String workingDir = args[0];
        String distDir = args[1];
        String stateFilePath = args[2];

        try {
            RemoteTaskMaster remoteTaskMaster = new RemoteTaskMaster(workingDir, distDir, stateFilePath);
            remoteTaskMaster.go();
        } catch (Exception e) {
            System.err.println("failed, caught e = " + e);
            e.printStackTrace();
        }
    }
}

