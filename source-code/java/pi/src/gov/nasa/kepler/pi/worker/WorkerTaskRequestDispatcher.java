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

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TaskCounts;
import gov.nasa.kepler.hibernate.pi.TaskExecutionLog;
import gov.nasa.kepler.pi.module.WorkerMemoryManager;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.kepler.pi.pipeline.PipelineExecutor;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.pi.worker.messages.WorkerTaskRequest;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.kepler.services.process.StatusMessage;
import gov.nasa.kepler.services.process.StatusReporter;
import gov.nasa.spiffy.common.metrics.CounterMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.metrics.Metric;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Date;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Coordinates processing of inbound worker task request messages. Manages the
 * database and messaging transaction context, invokes the module, then invokes
 * the transition logic.
 * 
 * This class is not MT-safe, and is intended to be called only by a single,
 * dedicated worker thread ({@link WorkerTaskRequestListener}
 * 
 */
public class WorkerTaskRequestDispatcher implements StatusReporter {
    private static final Log log = LogFactory.getLog(WorkerTaskRequestDispatcher.class);

    public static final String PIPELINE_MODULE_COMMIT_METRIC = "pipeline.module.commitTime";

    private ProcessInfo processInfo;
    private int threadNumber;

    private static ThreadLocal<WorkerThreadContext> threadContext = new ThreadLocal<WorkerThreadContext>(){
        @Override protected WorkerThreadContext initialValue() {
            return new WorkerThreadContext();
        }
    };
    private WorkerThreadContext context = null;

    private WorkerMemoryManager memoryManager = null;
    private String lastErrorMessage = "";

    private boolean useXa = false;

    /**
     * @param processName
     * @param threadNum
     * @param memoryManager
     * @param parentListener
     */
    public WorkerTaskRequestDispatcher(ProcessInfo processInfo, int threadNum, WorkerMemoryManager memoryManager) {
        this.processInfo = processInfo;
        this.threadNumber = threadNum;
        this.memoryManager = memoryManager;
        
        // initialize the context data so that it has valid (non-null) data even if there are no tasks running
        context = threadContext.get();
        
        Configuration config = ConfigurationServiceFactory.getInstance();
        useXa  = config.getBoolean(WorkerTaskRequestListener.USE_XA_PROP, WorkerTaskRequestListener.USE_XA_DEFAULT);
        
        log.info("useXa = " + useXa);
    }

    /**
     * Returns metadata about the currently running task in the calling thread.
     * 
     * @return
     */
    public static WorkerThreadContext currentContext(){
        return threadContext.get();
    }
    
    /**
     * Register the name of the working directory for the current task (if applicable).
     * @param workingDir
     */
    public static void registerWorkingDir(File workingDir){
        WorkerThreadContext currentContext = threadContext.get();
        currentContext.setCurrentTaskWorkingDir(workingDir);
    }
    
    /**
     * True if there is a currently running task and that task is configured to run 
     * on a remote cluster (RemoteExecutionParameters.enabled == true)
     * 
     * @return
     */
    public static boolean currentTaskIsRemote(){
        WorkerThreadContext c = threadContext.get();
        
        if(c != null){
            PipelineTask t = c.getCurrentPipelineTask();
            if(t != null){
                RemoteExecutionParameters rep = t.getParameters(RemoteExecutionParameters.class, false);
                if(rep != null && rep.isEnabled()){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }
        }else{
            return false;
        }
    }
    
    /**
     * Process incoming worker task requests
     * 
     * @throws PipelineException
     */
    public void processMessage(WorkerTaskRequest workerRequest) {

        context = threadContext.get();
        context.setCurrentRequest(workerRequest);

        MessagingService messagingService = MessagingServiceFactory.getInstance(false);

        TaskLog taskLog = initializeTaskLog(workerRequest.getInstanceId(), workerRequest.getTaskId());
        
        IntervalMetricKey key = IntervalMetric.start();

        boolean taskDone = false;

        try {
            taskLog.startLogging();

            context.setCurrentState(WorkerThreadContext.ThreadState.PROCESSING);
            context.setCurrentProcessingStartTimeMillis(System.currentTimeMillis());

            /* Insert a random delay in order to stagger the start times across
             * all workers. Useful for reducing the surge on the database and filestore
             * when a new pipeline starts */
            RandomDelay.randomWait();
            
            log.info("Executing pre-processing for taskId = " + workerRequest.getTaskId() + "...");

            boolean doTransitionOnly = preProcessing(workerRequest.isDoTransitionOnly());

            log.info("DONE executing pre-processing for taskId = " + workerRequest.getTaskId());

            if (!doTransitionOnly) {
                try{
                    Metric.enableThreadMetrics();
                    
                    /* Invoke the module */
                    log.info("Executing processTask for taskId = " + workerRequest.getTaskId() + "...");

                    taskDone = processTask();

                    if(taskDone){
                        log.info("DONE executing processTask for taskId = " + workerRequest.getTaskId());
                        CounterMetric.increment("pipeline.module.execSuccessCount");
                    }else{
                        log.info("DONE executing processTask for current step (more steps remain) for taskId = " + workerRequest.getTaskId());
                    }
                }finally{
                    context.setThreadMetrics(Metric.getThreadMetrics());
                    Metric.disableThreadMetrics();
                }
            }

            /* Update the task status */
            log.info("Executing post-processing for taskId = " + workerRequest.getTaskId() + "...");
            postProcessing(taskDone, true);
            
            if(taskDone){
                /* run the transition logic */
                doTransition(true);
                log.info("DONE executing post-processing for taskId = " + workerRequest.getTaskId());
            }

            messagingService.commitTransaction();

        } catch (Throwable t) {

            lastErrorMessage = t.getMessage();

            log.error("processMessage(): caught exception processing worker task request for "
                + contextString(context), t);

            CounterMetric.increment("pipeline.module.execFailCount");

            if (context.getCurrentPipelineTask() != null) {
                // could be null if it wasn't found in the db
                try {
                    postProcessing(true, false);
                    doTransition(false);
                } catch (Throwable t2) {
                    log.error("Failed in postProcessing for: " + contextString(context), t2);
                }
            }

            // always commit the messaging transaction regardless of what caused
            // the problem.
            try {
                log.info("commit messaging transaction");
                messagingService.commitTransaction();
            } catch (PipelineException commitException) {
                log.error("failed to commit messaging transaction for " + contextString(context), t);
            }
        } finally {
            if (taskLog != null) {
                taskLog.endLogging();
            }

            // this task is done, clear the current state
            threadContext.set(new WorkerThreadContext());
            context = threadContext.get();
            
            IntervalMetric.stop("pipeline.module.processMessage", key);
            
            // make sure any active transaction is cleaned up
            TransactionService transactionService = TransactionServiceFactory.getInstance();
            transactionService.rollbackTransactionIfActive();
        }
    }

    private TaskLog initializeTaskLog(long instanceId, long taskId){
        PipelineTaskCrud crud = new PipelineTaskCrud();
        PipelineTask pipelineTask = crud.retrieve(taskId);

        TaskLog taskLog = new TaskLog(threadNumber, instanceId, taskId, pipelineTask.getExecLog().size());
        context.setTaskLog(taskLog);
        
        return taskLog;
    }
    
    /**
     * Update the PipelineTask in the db to reflect the fact that this worker is
     * now processing the task. This is done with a local transaction (outside
     * of the distributed transaction) and committed immediately so that the PIG
     * will show updated status right away
     * 
     * @return boolean Indicates whether only the transition logic needs to be
     * run
     * @throws PipelineException
     */
    private boolean preProcessing(boolean doTransitionOnlyOverride) throws Exception {

        boolean doTransitionOnly = false;
        DatabaseService databaseService = null;
        PipelineInstanceCrud pipelineInstanceCrud = null;
        PipelineTaskCrud pipelineTaskCrud = null;
        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
        
        try {
            databaseService = DatabaseServiceFactory.getInstance(false);
            pipelineInstanceCrud = new PipelineInstanceCrud(databaseService);
            pipelineTaskCrud = new PipelineTaskCrud(databaseService);

            databaseService.beginTransaction();

            databaseService.clear();

            PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(context.getCurrentRequest().getInstanceId());

            if (pipelineInstance == null) {
                throw new PipelineException("No PipelineInstance found for id=" + context.getCurrentRequest().getInstanceId());
            }

            PipelineTask pipelineTask = pipelineTaskCrud.retrieve(context.getCurrentRequest().getTaskId());

            if (pipelineTask == null) {
                throw new PipelineException("No PipelineTask found for id=" + context.getCurrentRequest().getTaskId());
            }

            PipelineTaskAttributes taskAttrs = attrCrud.retrieveByTaskId(context.getCurrentRequest().getTaskId());

            TaskExecutionLog execLog = new TaskExecutionLog(processInfo.getHost(), threadNumber);
            execLog.setStartProcessingTime(new Date(context.getCurrentProcessingStartTimeMillis()));
            execLog.setInitialState(pipelineTask.getState());
            execLog.setInitialProcessingState(taskAttrs.getProcessingState());
            
            pipelineTask.getExecLog().add(execLog);
            
            if(pipelineTask.getState() == PipelineTask.State.ERROR){
                PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud(databaseService);
                
                pipelineInstanceNodeCrud.decrementFailedTaskCount(context.getCurrentRequest().getInstanceNodeId());
            }
            
            PipelineModuleDefinition moduleDefinition = pipelineTask.getPipelineInstanceNode()
            .getPipelineModuleDefinition();
            context.setCurrentMinMemoryMegaBytes(moduleDefinition.getMinMemoryMegaBytes());

            /*
             * If the user requested that only the transition logic be re-run,
             * or if the transition logic previously failed, then we only need to
             * re-run the transition logic
             */
            doTransitionOnly = (doTransitionOnlyOverride || 
                pipelineTask.getState() == PipelineTask.State.COMPLETED ||
                pipelineTask.getState() == PipelineTask.State.PARTIAL);

            if (!doTransitionOnly) {
                pipelineTask.setState(PipelineTask.State.PROCESSING);
                pipelineTask.setWorkerHost(processInfo.getHost());
                pipelineTask.setWorkerThread(threadNumber);
                pipelineTask.setTransitionComplete(false);
                pipelineTask.setSoftwareRevision(KeplerSocVersion.getUrl() + "@" + KeplerSocVersion.getRevision());

                if(pipelineTask.getStartProcessingTime().getTime() == 0){
                    pipelineTask.setStartProcessingTime(new Date(context.getCurrentProcessingStartTimeMillis()));
                }
            }

            databaseService.commitTransaction();
        } catch (Exception e) {
            databaseService.rollbackTransactionIfActive();
            throw e;
        }

        return doTransitionOnly;
    }

    /**
     * Invoke PipelineModule.processTask() and execute the transition logic (if
     * applicable)
     * 
     * @throws Throwable
     * @returns boolean If true, task is done (no more steps)
     */
    private boolean processTask() throws Throwable {
        IntervalMetricKey key = null;
        String moduleExecMetricPrefix = null;

        WorkerTaskRequest currentRequest;
        try {
            /*
             * Make sure enough memory is available for this task before
             * starting the transaction
             */
            if (memoryManager != null) {
                memoryManager.acquireMemoryMegaBytes(context.getCurrentMinMemoryMegaBytes());
            }

            // reset the file store connection in case it is stale
            try {
                FileStoreClientFactory.getInstance().close();
            } catch (Exception e) {
                log.warn("failed to close filestore connection prior to starting new transaction e = " + e, e );
            }
            FileStoreClientFactory.getInstance().ping();

            beginTransaction();

            PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

            currentRequest = context.getCurrentRequest();
            context.setCurrentPipelineInstance(pipelineInstanceCrud.retrieve(currentRequest.getInstanceId()));
            context.setCurrentPipelineTask(pipelineTaskCrud.retrieve(currentRequest.getTaskId()));
            
            PipelineModuleDefinition moduleDefinition = context.getCurrentPipelineTask().getPipelineInstanceNode()
                .getPipelineModuleDefinition();
            String moduleName = moduleDefinition.getName().getName();
            context.setCurrentModule(moduleName);
            context.setCurrentModuleUow(context.getCurrentPipelineTask().uowTaskInstance().briefState());
            moduleExecMetricPrefix = "pipeline.module." + context.getCurrentModule();

            log.info("processing:" + contextString(context));

            PipelineModule currentPipelineModule = moduleDefinition.getImplementingClass().newInstance();
            currentPipelineModule.initialize(context.getCurrentPipelineTask());
            
            context.setCurrentPipelineModule(currentPipelineModule);

            String moduleSimpleName = context.getCurrentPipelineModule().getClass().getSimpleName();

            log.info("Calling " + moduleSimpleName + ".processTask()");
            
            boolean taskDone = false;
            key = IntervalMetric.start();
            long startTime = System.currentTimeMillis();
            
            try{
                // Hand off control to the PipelineModule implementation
                taskDone = currentPipelineModule.process(context.getCurrentPipelineInstance(), 
                    context.getCurrentPipelineTask());
            }finally{
                IntervalMetric.stop(moduleExecMetricPrefix + ".processTask", key);
                context.setModuleExecTime(System.currentTimeMillis() - startTime);
            }
            
            // clear restart mode
            context.getCurrentPipelineTask().setRestartMode("");
            
            log.info(moduleSimpleName + ".process() completed");

            log.info("Committing distributed transaction...");
            
            key = IntervalMetric.start();
            try{
                commitTransaction();
            }finally{
                IntervalMetric.stop(PIPELINE_MODULE_COMMIT_METRIC, key);
            }
            
            log.info("DONE committing distributed transaction");

            if(taskDone){
                PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
                attrOps.updateProcessingState(context.getCurrentPipelineTask().getId(),
                    context.getCurrentPipelineInstance().getId(),
                    ProcessingState.COMPLETE);
            }
            
            return taskDone;
        } catch (Throwable t) {
            log.error("Failed in PipelineModule.processTask() for: " + contextString(context), t);
            CounterMetric.increment("pipeline.module.execFailCount");

            try {
                rollbackTransaction();
            } catch (Throwable rollbackException) {
                log.error("failed to rollback transactionService transaction for " + contextString(context), t);
            }

            throw t;
        } finally {
            if (memoryManager != null) {
                memoryManager.releaseMemoryMegaBytes(context.getCurrentMinMemoryMegaBytes());
            }

            if (moduleExecMetricPrefix != null) {
                CounterMetric.increment(moduleExecMetricPrefix + ".execCount");
            }
        }
    }

    /**
     * Update the PipelineTask in the db with the results of the processing
     * @param summaryMetrics 
     * 
     * @throws Exception
     * 
     */
    private void postProcessing(boolean done, boolean success) throws Throwable {

        DatabaseService databaseService = null;

        try {
            databaseService = DatabaseServiceFactory.getInstance(false);
            databaseService.clear();
            
            databaseService.beginTransaction();
            
            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud(databaseService);
            long taskId = context.getCurrentRequest().getTaskId();
            PipelineTask pipelineTask = pipelineTaskCrud.retrieve(taskId);

            if (pipelineTask == null) {
                throw new PipelineException("No PipelineTask found for id=" + taskId);
            }

            long processingEndTimeMillis = System.currentTimeMillis();
            long totalProcessingTimeMillis = processingEndTimeMillis - context.getCurrentProcessingStartTimeMillis();

            log.info("Total processing time for this step (minutes): " + ((float) totalProcessingTimeMillis) / 1000.0 / 60.0);

            Date endProcessingTime = new Date(processingEndTimeMillis);

            // Update summary metrics
            context.getCurrentPipelineModule().updateMetrics(pipelineTask, context.getThreadMetrics(), totalProcessingTimeMillis);
            
            if(done){
                pipelineTask.setEndProcessingTime(endProcessingTime);
                if (success) {
                    if(context.getCurrentPipelineModule().isPartialSuccess()){
                        pipelineTask.setState(PipelineTask.State.PARTIAL);
                    }else{
                        pipelineTask.setState(PipelineTask.State.COMPLETED);
                    }
                } else {
                    pipelineTask.setState(PipelineTask.State.ERROR);
                    pipelineTask.incrementFailureCount();

                    try {
                        AlertService alertService = AlertServiceFactory.getInstance();
                        alertService.generateAlert("PI(" + context.getCurrentModule() + ")", pipelineTask.getId(), Severity.INFRASTRUCTURE,
                            lastErrorMessage);
                    } catch (Throwable t) {
                        log.warn("Failed to generate alert for message: " + lastErrorMessage);
                    }
                }
            }

            PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
            PipelineTaskAttributes taskAttrs = attrCrud.retrieveByTaskId(context.getCurrentRequest().getTaskId());
            
            List<TaskExecutionLog> execLog = pipelineTask.getExecLog();
            log.info("execLog = " + execLog.size());

            if (execLog != null && !execLog.isEmpty()) {
                TaskExecutionLog currentExecLog = execLog.get(execLog.size() - 1);
                currentExecLog.setEndProcessingTime(endProcessingTime);
                currentExecLog.setFinalState(pipelineTask.getState());
                currentExecLog.setFinalProcessingState(taskAttrs.getProcessingState());
            } else {
                log.warn("stepLog is missing or empty for taskId: " + taskId);
            }
             
            databaseService.commitTransaction();

        } catch (Throwable t) {
            log.error("Post-processing failed, t=" + t.getMessage(), t);
            databaseService.rollbackTransactionIfActive();
            throw t;
        }
    }

    private void doTransition(boolean success) throws Throwable{
        WorkerTaskRequest currentRequest = context.getCurrentRequest();
        
        String moduleExecMetricPrefix = "pipeline.module." + context.getCurrentModule();
        IntervalMetricKey key = null;

        /*
         * Start a separate transaction to run the transition logic. Do this
         * in a separate transaction so that if it fails, the next worker to
         * get this task only has to re-try the transition logic rather than
         * the whole unit of work (because we set the pipeline task state to
         * COMPLETED in postProcessing)
         */
        TransactionService transactionService = TransactionServiceFactory.getInstance();
        transactionService.beginTransaction(true, false, false);

        try {
            key = IntervalMetric.start();

            /*
             * update pipelineInstance state based on the current task counts of
             * all of the PipelineInstanceNodes
             */
            DatabaseService databaseService = DatabaseServiceFactory.getInstance();
            
            PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud(databaseService);
            PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(currentRequest.getInstanceId());

            if (pipelineInstance == null) {
                throw new PipelineException("No PipelineInstance found for id=" + currentRequest.getInstanceId());
            }

            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud(databaseService);
            PipelineTask pipelineTask = pipelineTaskCrud.retrieve(currentRequest.getTaskId());

            if (pipelineTask == null) {
                throw new PipelineException("No PipelineTask found for id=" + currentRequest.getTaskId());
            }

            PipelineExecutor pipelineExecutor = new PipelineExecutor();            
            PipelineModule currentModule = context.getCurrentPipelineModule();
            
            if( currentModule != null && currentModule.isHaltPipelineOnTaskCompletion()){
                log.info("currentPipelineModule.isHaltPipelineOnTaskCompletion == true, so NOT executing transition logic for " + contextString(context));
            }else{
                log.info("executing transition logic for " + contextString(context));

                // obtains lock on PI_PIPELINE_INST_NODE (select for update)
                TaskCounts taskCountsForCurrentNode = pipelineExecutor.updateTaskCountsForCurrentNode(pipelineTask, success);

                if(success){
                    log.info("Executing transition logic");
                    pipelineExecutor.doTransition(pipelineInstance, pipelineTask, taskCountsForCurrentNode);
                    pipelineTask.setTransitionComplete(true);
                }else{
                    log.info("postProcessing: not executing transition logic because of current task failure");
                }
            }

            log.info("updating instance state for " + contextString(context));
            pipelineExecutor.updateInstanceState(pipelineInstance);

            if(!success){
                MessagingService nonTransactedInstance = MessagingServiceFactory.getNonTransactedInstance();
                nonTransactedInstance.send(MessagingDestinations.PIPELINE_EVENTS_DESTINATION,
                    new PipelineInstanceEvent(PipelineInstanceEvent.Type.FAILURE, pipelineInstance.getId(), pipelineInstance.getPriority()));
            }

            transactionService.commitTransaction();
        } catch (Throwable t) {
            log.error("Failed to execute transition logic after processing for: " + contextString(context), t);
            throw t;
        } finally {
            IntervalMetric.stop(moduleExecMetricPrefix + ".doTransition", key);
        }
    }
    
    /**
     * 
     * @param task
     * @return
     */
    private String contextString(WorkerThreadContext context) {
        WorkerTaskRequest request = context.getCurrentRequest();
        return "IID=" + request.getInstanceId() + ", TID=" + request.getTaskId() + ", M=" + context.getCurrentModule() + ", UOW="
            + context.getCurrentModuleUow();
    }

    private void beginTransaction(){
        if(useXa){
            log.info("Starting XA transaction");
            DatabaseServiceFactory.setUseXa(true);
            TransactionServiceFactory.setXa(true);
            TransactionService transactionService = TransactionServiceFactory.getInstance(true);
            transactionService.beginTransaction(true, false, true);
        }else{
            log.info("Starting NON-XA transaction");
            DatabaseServiceFactory.setUseXa(false);
            DatabaseServiceFactory.getInstance().beginTransaction();
            FileStoreClientFactory.getInstance().beginLocalFsTransaction();
        }
    }
    
    private void commitTransaction() throws Exception {
        if(useXa){
            log.info("Committing XA transaction");
            TransactionService transactionService = TransactionServiceFactory.getInstance(true);
            transactionService.commitTransaction();
        }else{
            log.info("Committing NON-XA transaction");
            FileStoreClientFactory.getInstance().commitLocalFsTransaction();
            DatabaseServiceFactory.getInstance().commitTransaction();
        }
    }
    
    private void rollbackTransaction(){
        if(useXa){
            log.info("Rolling back XA transaction");
            TransactionService transactionService = TransactionServiceFactory.getInstance(true);
            transactionService.rollbackTransactionIfActive();
        }else{
            log.info("Rolling back NON-XA transaction");
            FileStoreClientFactory.getInstance().rollbackLocalFsTransactionIfActive();
            DatabaseServiceFactory.getInstance().rollbackTransactionIfActive();
        }
    }
    
    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.services.process.StatusReporter#reportCurrentStatus()
     */
    @Override
    public synchronized StatusMessage reportCurrentStatus() {
        PipelineInstance currentPipelineInstance = context.getCurrentPipelineInstance();
        PipelineTask currentPipelineTask = context.getCurrentPipelineTask();
        String currentPipelineInstanceId = currentPipelineInstance == null ? "-" : "" + currentPipelineInstance.getId();
        String currentPipelineTaskId = currentPipelineTask == null ? "-" : "" + currentPipelineTask.getId();
        
        return new WorkerStatusMessage(threadNumber, context.getCurrentState()
            .toString(), currentPipelineInstanceId, currentPipelineTaskId, context.getCurrentModule(),
            context.getCurrentModuleUow(), context.getCurrentProcessingStartTimeMillis());
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.services.process.StatusReporter#destination()
     */
    @Override
    public String destination() {
        return MessagingDestinations.PIPELINE_STATUS_DESTINATION;
    }
}
