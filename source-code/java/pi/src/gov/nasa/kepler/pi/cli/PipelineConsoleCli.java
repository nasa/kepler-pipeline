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

package gov.nasa.kepler.pi.cli;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.pi.common.AlertLogDisplayModel;
import gov.nasa.kepler.pi.common.InstancesDisplayModel;
import gov.nasa.kepler.pi.common.PipelineStatsDisplayModel;
import gov.nasa.kepler.pi.common.TaskMetricsDisplayModel;
import gov.nasa.kepler.pi.common.TaskSummaryDisplayModel;
import gov.nasa.kepler.pi.common.TasksDisplayModel;
import gov.nasa.kepler.pi.common.TasksStates;
import gov.nasa.kepler.pi.models.ModelMetadataOperations;
import gov.nasa.kepler.pi.pipeline.PipelineExecutor;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.pi.worker.WorkerOperations;
import gov.nasa.kepler.pi.worker.WorkerPipelineProcess;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirRequest;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirResponse;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.process.PipelineProcessAdminOperations;
import gov.nasa.kepler.services.process.ProcessStatusMessage;
import gov.nasa.kepler.services.process.StatusMessage;
import gov.nasa.kepler.services.process.StatusMessageHandler;
import gov.nasa.kepler.services.process.StatusMessageListener;

import java.io.File;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Command-line interface that offers a minimal set of the functionality
 * provided by the PIG.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class PipelineConsoleCli implements StatusMessageHandler {

    private static final int DEFAULT_STATUS_WAIT_MILLIS = 10000;
    private static final long REQUEST_TIMEOUT_MILLIS = 60*60*1000; // 1hr

    private Set<String> processesSeen = Collections.synchronizedSet(new HashSet<String>());
    
    public PipelineConsoleCli() {
    }

    public void processCommand(String[] args) throws Exception {
        String command = args[0];
        if (command.equals("instance") || command.equals("i")) {
            processInstanceCommand(args);
        } else if (command.equals("task") || command.equals("t")) {
            processTaskCommand(args);
        } else if (command.equals("worker") || command.equals("w")) {
            processWorkerCommand(args);
        } else if (command.equals("reports") || command.equals("r")) {
            processReportsCommand(args);
        } else if (command.equals("fire") || command.equals("f")) {
            fireTriggerCommand(args);
        } else {
            System.err.println("Unknown command: " + printCommandLine(args));
            usage();
            System.exit(-1);
        }
    }

    private void processInstanceCommand(String[] args) throws Exception {
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();

        if(args.length == 1){
            // i[nstance] : display status of all pipeline instances
            List<PipelineInstance> instances = pipelineInstanceCrud.retrieveAll();
            InstancesDisplayModel instancesDisplayModel = new InstancesDisplayModel(instances);
            
            instancesDisplayModel.print(System.out, "Pipeline Instances");
        }else{
        	if(args[1].equals("c")){
        		List<PipelineInstance> activeInstances = pipelineInstanceCrud.retrieveAllActive();
        		System.out.println("Cancelling Active Instances:");
        		for (PipelineInstance instance : activeInstances) {
					System.out.println(" " + instance.getName());
				}
        		pipelineInstanceCrud.cancelAllActive();
        	}else{
                long id = -1;
                try {
                    id = Long.parseLong(args[1]);
                } catch (NumberFormatException e) {
                    System.err.println("Invalid ID: " + args[1]);
                    usage();
                    System.exit(-1);
                }
                
                PipelineInstance instance = pipelineInstanceCrud.retrieve(id);
                
                if(instance == null){
                    System.err.println("No instance found with ID = " + id);
                    System.exit(-1);
                }
                
                InstancesDisplayModel instancesDisplayModel = new InstancesDisplayModel(instance);
                instancesDisplayModel.print(System.out, "Instance Summary");
                System.out.println();

                if(args.length == 2){
                    // i[nstance] ID : display status and task count summary of
                    // specified pipeline instance

                    PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
                    List<PipelineTask> tasks = pipelineTaskCrud.retrieveAll(instance);

                    PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                    Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());

                    displayTaskSummary(tasks, taskAttrs);
                    
                }else{
                    String subCommand = args[2];
                    
                    if(subCommand.equals("full") || subCommand.equals("f")){
                        // i[nstance] ID f[ull]: display status of all tasks for
                        // specified pipeline instance
                        
                        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
                        List<PipelineTask> tasks = pipelineTaskCrud.retrieveAll(instance);
                        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                        Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());
                        
                        displayTaskSummary(tasks, taskAttrs);
                        TasksDisplayModel tasksDisplayModel = new TasksDisplayModel(tasks, taskAttrs);
                        tasksDisplayModel.print(System.out, "Pipeline Tasks");
                        
                    }else if(subCommand.equals("reset")) {
                        if(args.length < 4){
                            System.err.println("The reset command requires an additional arg: " + printCommandLine(args));
                            usage();
                            System.exit(-1);
                        }
                        
                        String taskType = args[3];
                        
                        if(taskType.equals("s")){
                            resetPipelineInstance(instance, false, null);                            
                        }else if(taskType.equals("a")){
                            resetPipelineInstance(instance, true, null);
                        }else if(taskType.matches(".*\\d.*")){
                            // If the arg contains a digit, then assume it's a list of taskIds
                            resetPipelineInstance(instance, true, taskType);
                        }else{
                            System.err.println("Unknown reset arg: " + printCommandLine(args));
                            usage();
                            System.exit(-1);
                        }
                    }else if(subCommand.equals("report") || subCommand.equals("r")){
                        // i[nstance] ID r[eport]: display report for specified
                        // pipeline instance
                        
                        PipelineOperations ops = new PipelineOperations();
                        String report = ops.generatePedigreeReport(instance);
                        System.out.println(report);

                    }else if(subCommand.equals("alerts") || subCommand.equals("a")){
                        // i[nstance] ID a[lerts]: display alerts for specified
                        // pipeline instance
                        
                        AlertLogCrud alertLogCrud = new AlertLogCrud();
                        List<AlertLog> alerts = alertLogCrud.retrieveForPipelineInstance(instance.getId());
                        AlertLogDisplayModel alertLogDisplayModel = new AlertLogDisplayModel(alerts);
                        alertLogDisplayModel.print(System.out, "Alerts");

                    }else if(subCommand.equals("statistics") || subCommand.equals("s")){
                        // i[nstance] ID s[statistics]: display processing time statistics for specified pipeline instance
                        
                        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
                        List<PipelineTask> tasks = pipelineTaskCrud.retrieveAll(instance);
                        
                        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                        Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());
                        
                        TasksStates tasksStates = displayTaskSummary(tasks, taskAttrs);
                        List<String> orderedModuleNames = tasksStates.getModuleNames();
                        
                        PipelineStatsDisplayModel pipelineStatsDisplayModel = new PipelineStatsDisplayModel(tasks, orderedModuleNames);
                        pipelineStatsDisplayModel.print(System.out, "Processing Time Statistics");
                        
                        TaskMetricsDisplayModel taskMetricsDisplayModel = new TaskMetricsDisplayModel(tasks, orderedModuleNames);
                        taskMetricsDisplayModel.print(System.out, "Processing Time Breakdown (completed tasks only)");

                    }else if(subCommand.equals("errors") || subCommand.equals("e")){
                        // i[nstance] ID e[rrors]: display status and worker logs for all failed tasks for specified pipeline instance
                        
                        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
                        List<PipelineTask> tasks = pipelineTaskCrud.retrieveAll(instance, PipelineTask.State.ERROR);
                        
                        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                        Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());

                        for (PipelineTask task : tasks) {
                            TasksDisplayModel tasksDisplayModel = new TasksDisplayModel(task, taskAttrs.get(task.getId()));
                            tasksDisplayModel.print(System.out, "Task Summary");
                            
                            System.out.println();
                            System.out.println("Worker log: ");
                            
                            WorkerOperations ops = new WorkerOperations();
                            System.out.println(ops.retrieveTaskLog(task));
                        }
                    } else {
                        System.err.println("Unknown instance subcommand: " + printCommandLine(args));
                        usage();
                        System.exit(-1);
                    }
                }
            }
        }
    }

    /**
     * @param instance
     * @param allStalledTasks If true, reset SUBMITTED and PROCESSING tasks, else just SUBMITTED tasks
     */
    private void resetPipelineInstance(PipelineInstance instance, boolean allStalledTasks, String taskIds) {
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        long instanceId = instance.getId();
        
        /* Set the pipeline task state to ERROR for any tasks assigned to this
         * worker that are in the PROCESSING state.  This condition indicates that
         * the previous instance of the worker process on this host died abnormally */
        try {
            databaseService.beginTransaction();

            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
            pipelineTaskCrud.resetTaskStates(instanceId, allStalledTasks, taskIds);
            
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        
        /* Update the pipeline instance state for the instances associated with the stale
         * tasks from above since that change may result in a change to the instances */
        try {
            databaseService.beginTransaction();

            PipelineExecutor pe = new PipelineExecutor();
            pe.updateInstanceState(instance);
            
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private TasksStates displayTaskSummary(List<PipelineTask> tasks, Map<Long, PipelineTaskAttributes> taskAttrs) throws Exception {
        TaskSummaryDisplayModel taskSummaryDisplayModel = new TaskSummaryDisplayModel(new TasksStates(tasks, taskAttrs));
        taskSummaryDisplayModel.print(System.out, "Instance Task Summary");
        return taskSummaryDisplayModel.getTaskStates();
    }

    private void processTaskCommand(String[] args) throws Exception {
        if(args.length == 2 || args.length == 3 || args.length == 4){
            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
            long id = -1;
            try {
                id = Long.parseLong(args[1]);
            } catch (NumberFormatException e) {
                System.err.println("Invalid ID: " + args[1]);
                usage();
                System.exit(-1);
            }

            PipelineTask task = pipelineTaskCrud.retrieve(id);
            
            PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
            PipelineTaskAttributes taskAttr = attrCrud.retrieveByTaskId(id);
            
            if(task == null){
                System.err.println("No task found with ID = " + id);
                System.exit(-1);
            }
            
            TasksDisplayModel tasksDisplayModel = new TasksDisplayModel(task, taskAttr);
            tasksDisplayModel.print(System.out, "Task Summary");
            System.out.println();

            if(args.length >= 3){
                String subCommand = args[2];
                
                if(subCommand.equals("log") || subCommand.equals("l")){
                    // t[ask] ID l[og] : display status and log (fetched from worker) for selected task
                    
                    System.out.println("Requesting log from worker...");
                    
                    WorkerOperations ops = new WorkerOperations();
                    System.out.println(ops.retrieveTaskLog(task));

                }else if(subCommand.equals("copy") || subCommand.equals("c")){
                    // t[ask] ID c[opy] DESTINATION_PATH: display status and log (fetched from worker) for selected task
                    
                    if(args.length == 4){
                        String destDir = args[3];
                        PipelineProcessAdminOperations adminOps = new PipelineProcessAdminOperations();

                        System.out.println("Sending requesting to worker to copy task files to: " + destDir + "...");
                        
                        WorkerTaskWorkingDirResponse response = adminOps.adminRequest(
                            WorkerPipelineProcess.NAME, task.getWorkerHost(), new WorkerTaskWorkingDirRequest(task.getPipelineInstance().getId(), task.getId(),
                                new File(destDir)), REQUEST_TIMEOUT_MILLIS);
                        
                        System.out.println("Worker Response: " + response.getStatus());
                    }else{
                        System.err.println("Destination path not specified: " + printCommandLine(args));
                        usage();
                        System.exit(-1);            
                    }
                }else{
                    System.err.println("Unknown task subcommand: " + printCommandLine(args));
                    usage();
                    System.exit(-1);            
                }
            }
        }else{
            System.err.println("Too many arguments: " + printCommandLine(args));
            usage();
            System.exit(-1);            
        }
    }

    private String printCommandLine(String[] args) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < args.length; i++) {
            sb.append(args[i] + " ");
        }
        return sb.toString();
    }

    private void processWorkerCommand(String[] args) {
        int waitTimeMillis = DEFAULT_STATUS_WAIT_MILLIS;
        
        if(args.length == 2){
            try {
                waitTimeMillis = Integer.parseInt(args[1]) * 1000;
            } catch (NumberFormatException e) {
                System.err.println("Invalid Wait time: " + args[1]);
                usage();
                System.exit(-1);
            }
        }
        
        StatusMessageListener listener = new StatusMessageListener(MessagingDestinations.PIPELINE_STATUS_DESTINATION);
        listener.addProcessStatusHandler(this);
        listener.start();
        
        try {
            Thread.sleep(waitTimeMillis);
        } catch (InterruptedException e) {
        }
        
        System.exit(0);
    }

    @Override
    public void handleMessage(StatusMessage statusMessage) {
        if(statusMessage instanceof ProcessStatusMessage){
            String source = statusMessage.source();
            
            if(!processesSeen.contains(source)){
                System.out.println("  " + statusMessage.briefStatus());
                processesSeen.add(source);
            }
        }
    }

    private void processReportsCommand(String[] args) {
        if(args.length == 2){
            String reportType = args[1];
            PipelineOperations pipelineOps = new PipelineOperations();
            if(reportType.equals("i") || reportType.equals("instance")){
                PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud();
                List<PipelineInstance> instances = instanceCrud.retrieveAll();

                System.out.println("***** Pipeline Instance Reports *****");
                
                for (PipelineInstance instance : instances) {
                    String instanceReport = pipelineOps.generatePedigreeReport(instance);
                    System.out.println(instanceReport);
                    System.out.println();
                    System.out.println();
                }
            }else if(reportType.equals("t") || reportType.equals("trigger")){
                TriggerDefinitionCrud triggerCrud = new TriggerDefinitionCrud();
                List<TriggerDefinition> triggers = triggerCrud.retrieveAll();
                
                System.out.println("***** Trigger Reports *****");
                
                for (TriggerDefinition trigger : triggers) {
                    String triggerReport = pipelineOps.generateTriggerReport(trigger);
                    System.out.println(triggerReport);
                    System.out.println();
                    System.out.println();
                }
            }else if(reportType.equals("d") || reportType.equals("data-model-registry")){
                System.out.println("Data Model Registry");
                System.out.println();
                ModelMetadataOperations modelMetadataOps = new ModelMetadataOperations();
                System.out.println(modelMetadataOps.report());
            }else{
                System.err.println("Unrecognized report type: " + reportType);
                usage();
                System.exit(-1);
            }
        }else{
            System.err.println("Report type not specified (instance or trigger)");
            usage();
            System.exit(-1);
        }
        
        System.exit(0);
    }

    private void fireTriggerCommand(String[] args) {
        if(args.length == 3){
            String triggerName = args[1];
            String instanceName = args[2];
            fireTrigger(triggerName, instanceName);
        }else{
            System.err.println("Report type not specified (instance or trigger)");
            usage();
            System.exit(-1);
        }
        
        System.exit(0);
    }
    
    private void fireTrigger(final String triggerName, String instanceName){
        System.out.println("Launching " + triggerName);

        MessagingServiceFactory.setUseXa(false);
        DatabaseServiceFactory.setUseXa(false);

        TransactionService transactionService = TransactionServiceFactory.getInstance(false);

        try {
            transactionService.beginTransaction(true, true, false);

            TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud(
                DatabaseServiceFactory.getInstance());
            TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(triggerName);
            PipelineOperations pipelineOperations = new PipelineOperations();
            pipelineOperations.fireTrigger(triggerDefinition, instanceName);

            transactionService.commitTransaction();
        } catch (Exception e) {
            System.out.println("Unable to fire trigger, caught e = " + e);
            System.exit(1);
        } finally {
            transactionService.rollbackTransactionIfActive();
        }

        System.out.println("Done launching " + triggerName);
    }
    
    private static void usage() {
        System.out.println("picli COMMAND ARGS");
        System.out.println("  Examples:");
        System.out.println("    i[nstance] : display status of all pipeline instances");
        System.out.println("    i[nstance] ID : display status and task count summary of specified pipeline instance");
        System.out.println("    i[nstance] ID f[ull]: display status of all tasks for specified pipeline instance");
        System.out.println("    i[nstance] ID r[eport]: display report for specified pipeline instance");
        System.out.println("    i[nstance] ID a[lerts]: display alerts for specified pipeline instance");
        System.out.println("    i[nstance] ID s[statistics]: display processing time statistics for specified pipeline instance");
        System.out.println("    i[nstance] ID e[rrors]: display status and worker logs for all failed tasks for specified pipeline instance");       
        System.out.println("    i[nstance] ID reset s: (reset submitted): Puts all SUBMITTED tasks in the specified pipeline instance in the ERROR state so that they can be re-run");       
        System.out.println("    i[nstance] ID reset a: (reset all): Puts all SUBMITTED or PROCESSING tasks in the specified pipeline instance in the ERROR state so that they can be re-run");       
        System.out.println("    i[nstance] ID reset task_IDs: (reset task_IDs): Puts all SUBMITTED or PROCESSING tasks in the specified pipeline instance and on the supplied list of task_IDs in the ERROR state so that they can be re-run. task_IDs is a comma-separated list of task IDs with no spaces (For example, 10000 or 100,101,105)");       
        System.out.println("    i[nstance] c[ancel]: Puts all running instances in the STOPPED state");       
        System.out.println("    t[ask] ID : display status for selected task");
        System.out.println("    t[ask] ID l[og] : display status and log (fetched from worker) for selected task");
        System.out.println("    t[ask] ID c[opy] DESTINATION_PATH : display status and log (fetched from worker) for selected task");
        System.out.println("    w[orker] : display worker health status (10 second wait)");
        System.out.println("    w[orker] WAIT : display worker health status (WAIT seconds wait)");
        System.out.println("    r[eports] d[ata-model-registry] : current state of the data model registry");
        System.out.println("    r[eports] i[instance] : dump all pipeline instance reports (WARNING: could be big & slow!)");
        System.out.println("    r[eports] t[rigger] : dump all trigger reports (WARNING: could be big & slow!)");
        System.out.println("    f[ire] TRIGGER_NAME INSTANCE_NAME : Fire the specified trigger and assign INSTANCE_NAME as the name of the new pipeline instance");
    }

    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            usage();
            System.exit(-1);
        }

        PipelineConsoleCli cli = new PipelineConsoleCli();
        cli.processCommand(args);
        
        System.exit(0);
    }
}
