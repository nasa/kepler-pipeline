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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.pi.worker.WorkerPipelineProcess;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirRequest;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirResponse;
import gov.nasa.kepler.services.process.PipelineProcessAdminOperations;

import java.io.File;
import java.util.Arrays;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.apache.commons.cli.CommandLine;
import org.apache.commons.cli.CommandLineParser;
import org.apache.commons.cli.GnuParser;
import org.apache.commons.cli.HelpFormatter;
import org.apache.commons.cli.Options;
import org.apache.commons.cli.ParseException;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Use PipelineProcessAdminOperations to request that the workers 
 * copy the intermediate products for the specified {@link PipelineInstanceNode}s
 * from local disk to the NFS volume.
 * 
 * User can specify a start and end node
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class WorkerTaskFileCopier {
    private static final Log log = LogFactory.getLog(WorkerTaskFileCopier.class);
    protected static final long REQUEST_TIMEOUT_MILLIS = 0; // no timeout

    private static final String INSTANCE_ID_OPT = "i";
    private static final String OUTPUT_DIR_OPT = "o";
    private static final String START_NODE_OPT = "sn";
    private static final String END_NODE_OPT = "en";
    private static final String START_TASK_OPT = "st";
    private static final String END_TASK_OPT = "et";
    private static final String WORKERS_OPT = "w";
    private static final String COPYBIN_OPT = "copybin";
    private static final String BINONLY_OPT = "binonly";

    private long instanceId;
    private int startNode;
    private int endNode;
    private long startTaskId;
    private long endTaskId;
    private String outputDir;
    private String[] workers;
    private boolean copyBinFiles = false;
    private boolean binFilesOnly = false;
    
    public WorkerTaskFileCopier(long instanceId, int startNode, int endNode, long startTaskId, long endTaskId, 
        String outputDir, String[] workers, boolean copyBinFiles, boolean binFilesOnly) {
        this.instanceId = instanceId;
        this.startNode = startNode;
        this.endNode = endNode;
        this.startTaskId = startTaskId;
        this.endTaskId = endTaskId;
        this.outputDir = outputDir;
        this.workers = workers;
        this.copyBinFiles = copyBinFiles;
        this.binFilesOnly = binFilesOnly;
    }

    private void go() throws Exception {
        PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud();
        PipelineInstanceNodeCrud instanceNodeCrud = new PipelineInstanceNodeCrud();
        PipelineTaskCrud taskCrud = new PipelineTaskCrud();

        PipelineInstance instance = instanceCrud.retrieve(instanceId);
        if (instance == null) {
            throw new Exception("No instance found for ID=" + instanceId);
        }

        List<PipelineInstanceNode> instanceNodes = instanceNodeCrud.retrieveAll(instance);
        
        if (instanceNodes.size() == 0) {
            throw new Exception("No nodes found for instanceId=" + instanceId);
        }
        
        if(startNode == -1){
            startNode = 1;
        }
        
        if(endNode == -1){
            endNode = instanceNodes.size();
        }
        
        if (startNode > endNode) {
            throw new Exception("Error: startNode > endNode");
        }

        if (startNode < 1) {
            throw new Exception("Error: startNode must be >= 1");
        }

        if (instanceNodes.size() < endNode) {
            throw new Exception("Only found " + instanceNodes.size() + " for instanceId=" + instanceId);
        }

        Map<String, List<WorkerTaskWorkingDirRequest>> workerRequestMap = new HashMap<String, List<WorkerTaskWorkingDirRequest>>();

        int currentNode = startNode;

        while (currentNode <= endNode) {
            // nodes are 1-based, from user input
            PipelineInstanceNode node = instanceNodes.get(currentNode - 1);
            List<PipelineTask> tasks = taskCrud.retrieveAll(node);

            for (PipelineTask task : tasks) {
                if(taskIncluded(task.getId())){
                    String workerHost = task.getWorkerHost();
                    
                    if(workerHost != null && workerHost.length() > 0){
                        if(workerIncluded(workerHost)){
                            List<WorkerTaskWorkingDirRequest> workerRequestList = workerRequestMap.get(workerHost);
                            if(workerRequestList == null){
                                workerRequestList = new LinkedList<WorkerTaskWorkingDirRequest>();
                                workerRequestMap.put(workerHost, workerRequestList);
                            }
                            
                            WorkerTaskWorkingDirRequest request = new WorkerTaskWorkingDirRequest(instanceId, task.getId(),
                                new File(outputDir), copyBinFiles, binFilesOnly);
                            workerRequestList.add(request);
                        }else{
                            log.info("Ignoring worker: " + workerHost);
                        }
                    }
                }else{
                    log.info("Ignoring task ID: " + task.getId());
                }
            }
            currentNode++;
        }
        
        List<Future<?>> tasks = new LinkedList<Future<?>>();
        ExecutorService executor = Executors.newFixedThreadPool(workerRequestMap.keySet().size()+1);
        for (String workerHost : workerRequestMap.keySet()) {
            Future<?> task = executor.submit(new Requestor(workerHost, workerRequestMap.get(workerHost)));
            tasks.add(task);
        }
        
        // wait for completion
        log.info("Waiting for all tasks to complete...");
        for (Future<?> task : tasks) {
            task.get(); // block waiting for completion
        }
        
        log.info("All tasks complete, exiting");
        System.exit(1);
    }
    
    private boolean taskIncluded(long taskId){
        boolean included = true;
        
        if(startTaskId > 0 && taskId < startTaskId){
            included = false;
        }
        if(endTaskId > 0 && taskId > endTaskId){
            included = false;
        }
        return included;
    }

    private boolean workerIncluded(String workerHost){
        if(workers.length == 0){
            return true;
        }
        
        if(Arrays.binarySearch(workers, workerHost) >= 0){
            return true;
        }else{
            return false;
        }
    }
    
    private class Requestor implements Runnable{
        private final String workerHost;
        private final List<WorkerTaskWorkingDirRequest> requests;
        
        public Requestor(String workerHost, List<WorkerTaskWorkingDirRequest> requests) {
            this.workerHost = workerHost;
            this.requests = requests;
        }

        @Override
        public void run() {
            log.info("Processing requests for worker: " + workerHost);
            PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();
            int successCount = 0;
            
            for (WorkerTaskWorkingDirRequest request : requests) {
                WorkerTaskWorkingDirResponse response = null;
                String requestDesc = "Worker: " + workerHost + ", taskId: " + request.getTaskId();
                log.info("Sending request: " + requestDesc);
                try {
                    response = ops.adminRequest(
                        WorkerPipelineProcess.NAME, workerHost, request, REQUEST_TIMEOUT_MILLIS);
                    log.info("Got response: " + requestDesc + ", status: " + response.getStatus());
                    successCount++;
                } catch (Exception e) {
                    log.warn("Request TIMED OUT: " + requestDesc);
                }
            }
            log.info("Worker: " + workerHost + ": " + successCount + "/" + requests.size() + " succeeded");
        }
    }
    
    private static void usageAndExit(Options options) {
        HelpFormatter formatter = new HelpFormatter();
        formatter.printHelp("task-copy", options);
        System.exit(-1);
    }

    public static void main(String[] args) throws Exception {

        Options options = new Options();
        options.addOption(INSTANCE_ID_OPT, true, "pipeline instance ID");
        options.addOption(OUTPUT_DIR_OPT, true, "output directory");
        options.addOption(START_NODE_OPT, true, "start node (first node is '1')");
        options.addOption(END_NODE_OPT, true, "end node");
        options.addOption(START_TASK_OPT, true, "start pipeline task ID");
        options.addOption(END_TASK_OPT, true, "end pipeline task ID");
        options.addOption(WORKERS_OPT, true, "worker hostnames (comma-separated, optional)");
        options.addOption(COPYBIN_OPT, false, "include .bin files (default false)");
        options.addOption(BINONLY_OPT, false, "copy ONLY .bin files (default false)");
        CommandLineParser parser = new GnuParser();
        CommandLine cmdLine = null;
        try {
            cmdLine = parser.parse(options, args);
        } catch (ParseException e) {
            System.err.println("Illegal argument: " + e.getMessage());
            usageAndExit(options);
        }

        long instanceId = 0;
        int startNode = 0;
        int endNode = 0;
        long startTaskId = 0;
        long endTaskId = 0;
        String outputDir = null;
        String[] workers = new String[0];
        boolean copyBin = false;
        boolean binOnly = false;
        
        if (cmdLine.hasOption(INSTANCE_ID_OPT)) {
            instanceId = Long.parseLong(cmdLine.getOptionValue(INSTANCE_ID_OPT));
        } else {
            usageAndExit(options);
        }
        if (cmdLine.hasOption(START_NODE_OPT)) {
            startNode = Integer.parseInt(cmdLine.getOptionValue(START_NODE_OPT));
        } else {
            startNode = -1;
        }
        if (cmdLine.hasOption(END_NODE_OPT)) {
            endNode = Integer.parseInt(cmdLine.getOptionValue(END_NODE_OPT));
        } else {
            endNode = -1;
        }
        if (cmdLine.hasOption(START_TASK_OPT)) {
            startTaskId = Long.parseLong(cmdLine.getOptionValue(START_TASK_OPT));
        } else {
            startTaskId = -1;
        }
        if (cmdLine.hasOption(END_TASK_OPT)) {
            endTaskId = Long.parseLong(cmdLine.getOptionValue(END_TASK_OPT));
        } else {
            endTaskId = -1;
        }
        if (cmdLine.hasOption(OUTPUT_DIR_OPT)) {
            outputDir = cmdLine.getOptionValue(OUTPUT_DIR_OPT);
        } else {
            usageAndExit(options);
        }
        if (cmdLine.hasOption(WORKERS_OPT)) {
            String workersList = cmdLine.getOptionValue(WORKERS_OPT);
            workers = workersList.split(",");
        }
        if (cmdLine.hasOption(COPYBIN_OPT)) {
            copyBin = true;
        }
        if (cmdLine.hasOption(BINONLY_OPT)) {
            binOnly = true;
        }

        WorkerTaskFileCopier o = new WorkerTaskFileCopier(instanceId, startNode, endNode, startTaskId, endTaskId, 
            outputDir, workers, copyBin, binOnly);
        o.go();
    }
}
