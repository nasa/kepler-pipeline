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

package gov.nasa.kepler.pi.pipeline;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ModelMetadataCrud;
import gov.nasa.kepler.hibernate.pi.ModelRegistry;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceAggregateState;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TaskCounts;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.pi.worker.messages.WorkerTaskRequest;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Encapsulates the launch and transition logic for pipelines
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class PipelineExecutor {
    private static final Log log = LogFactory.getLog(PipelineExecutor.class);

    private MessagingService messagingService;
    private DatabaseService databaseService;

    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
    private ParameterSetCrud parameterSetCrud;
    private PipelineDefinitionCrud pipelineDefinitionCrud;
    private PipelineInstanceCrud pipelineInstanceCrud;
    private PipelineInstanceNodeCrud pipelineInstanceNodeCrud;
    private PipelineTaskCrud pipelineTaskCrud;

    public PipelineExecutor() {
        messagingService = MessagingServiceFactory.getInstance();
        databaseService = DatabaseServiceFactory.getInstance();

        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud(databaseService);
        parameterSetCrud = new ParameterSetCrud(databaseService);
        pipelineDefinitionCrud = new PipelineDefinitionCrud(databaseService);
        pipelineInstanceCrud = new PipelineInstanceCrud(databaseService);
        pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud(databaseService);
        pipelineTaskCrud = new PipelineTaskCrud(databaseService);
    }

    /**
     * Launch a new {@link PipelineInstance} for this {@link PipelineDefinition}
     * 
     * @param trigger
     * @param instanceName
     * @return
     */
    public PipelineInstance launch(TriggerDefinition trigger, String instanceName) {
        return launch(trigger, instanceName, null, null);
    }

    /**
     * Launch a new {@link PipelineInstance} for this {@link PipelineDefinition}
     * with optional startNode and/or endNode.
     * 
     * @param startNode Optional start node (default is root of the
     * PipelineDefnition)
     * @param endNode Optional end node (default is leafs of the
     * PipelineDefnition)
     * @throws PipelineException
     */
    public PipelineInstance launch(TriggerDefinition trigger, String instanceName, PipelineDefinitionNode startNode,
        PipelineDefinitionNode endNode) {

        PipelineDefinition pipelineDefinition = pipelineDefinitionCrud.retrieveLatestVersionForName(trigger.getPipelineDefinitionName());
        pipelineDefinition.buildPaths();

        /*
         * Lock the definition so it can't be changed once it is referred to by
         * a PipelineInstance This preserves the pipeline configuration and all
         * parameter sets for the data accountability record
         */
        pipelineDefinition.lock();

        /* Lock the current version of the model registry and associate
         * it with this pipeline instance. */
        ModelMetadataCrud modelMetadataCrud = new ModelMetadataCrud();
        ModelRegistry modelRegistry = modelMetadataCrud.lockCurrentRegistry();

        int priority = trigger.getInstancePriority();

        if(priority < PipelineInstance.HIGHEST_PRIORITY){
            priority = PipelineInstance.HIGHEST_PRIORITY;
        }
        
        if(priority > PipelineInstance.LOWEST_PRIORITY){
            priority = PipelineInstance.LOWEST_PRIORITY;
        }

        PipelineInstance instance = new PipelineInstance();
        instance.setName(instanceName);
        instance.setPipelineDefinition(pipelineDefinition);
        instance.setState(PipelineInstance.State.PROCESSING);
        instance.setStartProcessingTime(new Date(System.currentTimeMillis()));
        instance.setTriggerName(trigger.getName());
        instance.setPriority(priority);
        instance.setModelRegistry(modelRegistry);
        
        /*
         * Set the pipeline instance params to the latest version of the name
         * specified in the trigger and lock the param set
         */

        Map<ClassWrapper<Parameters>, ParameterSetName> triggerParamNames = trigger.getPipelineParameterSetNames();
        Map<ClassWrapper<Parameters>, ParameterSet> instanceParams = instance.getPipelineParameterSets();

        bindParameters(triggerParamNames, instanceParams);

        instance.setPipelineParameterSets(instanceParams);

        pipelineInstanceCrud.create(instance);

        // create the queue and alert the workers
        String queueName = MessagingDestinations.WORKER_TASK_REQUEST_QUEUE_NAMES[instance.getPriority()];
        
        messagingService.createQueue(queueName);
        messagingService.send(MessagingDestinations.PIPELINE_EVENTS_DESTINATION, new PipelineInstanceEvent(
            PipelineInstanceEvent.Type.START, instance.getId(), instance.getPriority()));

        if (startNode == null) {
            // start at the root
            log.info("Creating instance nodes (starting at root because startNode not set)");

            List<PipelineInstanceNode> rootInstanceNodes = new LinkedList<PipelineInstanceNode>();

            for (PipelineDefinitionNode definitionRootNode : pipelineDefinition.getRootNodes()) {
                PipelineInstanceNode rootInstanceNode = createInstanceNodes(instance, trigger, definitionRootNode,
                    endNode);
                rootInstanceNodes.add(rootInstanceNode);
            }

            // make sure the new PipelineInstanceNodes are in the db for
            // launchNode, below
            databaseService.flush();

            for (PipelineInstanceNode instanceNode : rootInstanceNodes) {
                launchNode(instanceNode, queueName);
            }
        } else {
            // start at the specified startNode
            log.info("Creating instance nodes (startNode set, so starting there instead of root)");

            PipelineInstanceNode startInstanceNode = createInstanceNodes(instance, trigger, startNode, endNode);
            instance.setStartNode(startInstanceNode);

            PipelineDefinitionNode taskGeneratorNode = taskGeneratorNode(startInstanceNode.getPipelineDefinitionNode());

            Map<ClassWrapper<Parameters>, ParameterSetName> uowModuleParamNames = triggerNodeParameters(trigger,
                taskGeneratorNode);
            Map<ClassWrapper<Parameters>, ParameterSet> uowModuleParams = new HashMap<ClassWrapper<Parameters>, ParameterSet>();
            bindParameters(uowModuleParamNames, uowModuleParams);

            // make sure the new PipelineInstanceNodes are in the db for
            // launchNode, below
            databaseService.flush();

            launchNode(startInstanceNode, queueName, taskGeneratorNode, uowModuleParams);
        }

        return instance;
    }

    public TaskCounts updateTaskCountsForCurrentNode(PipelineTask task, boolean currentTaskSuccessful) {

        log.info("currentTaskSuccessful: " + currentTaskSuccessful);

        long pipelineInstanceNodeId = task.getPipelineInstanceNode()
            .getId();
        TaskCounts newTaskCounts;

        // This code obtains the lock on PI_PIPELINE_INST_NODE with 'select for
        // update'.
        // The lock is held until the next commit
        if (currentTaskSuccessful) {
            newTaskCounts = pipelineInstanceNodeCrud.incrementCompletedTaskCount(pipelineInstanceNodeId);
        } else {
            newTaskCounts = pipelineInstanceNodeCrud.incrementFailedTaskCount(pipelineInstanceNodeId);
        }

        return newTaskCounts;
    }

    /**
     * The transition logic generates the worker task request messages for the
     * next module in this pipeline.
     * 
     * This method should only be called if the current task completed
     * successfully.
     * 
     * @param workerTaskRequest
     * @param instance
     * @param task
     * @throws PipelineException
     */
    public void doTransition(PipelineInstance instance, PipelineTask task, TaskCounts currentNodeTaskCounts) {
        log.debug("doTransition(WorkerTaskRequest, PipelineInstanceNode) - start");

        String queueName = MessagingDestinations.WORKER_TASK_REQUEST_QUEUE_NAMES[instance.getPriority()];

        log.debug("doTransition: current task = " + task.getId());

        log.info("task.isRetried(): " + task.isRetry());

        PipelineInstanceNode instanceNode = pipelineInstanceNodeCrud.retrieve(instance,
            task.getPipelineDefinitionNode());

        log.info("doTransition: instanceNode " + currentNodeTaskCounts.log());

        /**
         * (using javadoc-style comments to keep eclipse from munging
         * formatting)
         * 
         * <pre>
         * 
         * if there is another node in this pipeline, 
         *   for each nextNode 
         *     if nextNode.isStartNewUow() == true 
         *       if all tasks for this node are complete 
         *         use the task generator for nextNode to generate the next set of tasks 
         *       else 
         *         create a new task with the same uowTask as the last task 
         * else 
         *   pipeline complete for this UOW
         * 
         * </pre>
         */

        // true if the user specified an optional end node (not null and equal
        // to the current node)
        PipelineInstanceNode endNode = instance.getEndNode();
        boolean isEndNode = (endNode != null && instanceNode.getId() == endNode.getId());

        if (!isEndNode && task.getPipelineDefinitionNode()
            .getNextNodes()
            .size() > 0) {
            log.debug("more nodes remaining for this pipeline");
            for (PipelineDefinitionNode nextDefinitionNode : task.getPipelineDefinitionNode()
                .getNextNodes()) {

                PipelineInstanceNode nextInstanceNode = pipelineInstanceNodeCrud.retrieve(instance, nextDefinitionNode);

                if (nextDefinitionNode.isStartNewUow()) { // synchronized
                    // transition
                    log.debug("isWaitForPreviousTasks == true, checking to see if all tasks for this node are complete");

                    if (currentNodeTaskCounts.isInstanceNodeComplete()) {
                        log.info("doTransition: all tasks for this node done, launching the next node with a new UOW");

                        launchNode(nextInstanceNode, queueName);
                    } else {
                        log.info("doTransition: there are uncompleted tasks remaining for this node, doing nothing");
                    }
                } else {
                    /*
                     * Simple transition: just propagate the last task to the
                     * nextNode
                     */

                    log.info("doTransition: nextNode uses the same UOW, just creating a single task with the UOW from this task");

                    BeanWrapper<UnitOfWorkTask> nextUowTask = null;

                    if (task.getUowTask() != null) {
                        nextUowTask = new BeanWrapper<UnitOfWorkTask>(task.getUowTask());
                    }

                    launchTask(nextInstanceNode, queueName, instance, nextDefinitionNode, nextUowTask);
                    pipelineInstanceNodeCrud.incrementSubmittedTaskCount(nextInstanceNode.getId());
                }
            }
        } else {
            if (isEndNode) {
                log.info("doTransition: end of pipeline reached for this UOW (reached specified endNode)");
            }

            log.info("doTransition: end of pipeline reached for this UOW");
        }
    }

    /**
     * Updates the PipelineInstance state based on the aggregate
     * PipelineInstanceNode task counts. Called after the transition logic runs.
     * 
     * @param instance
     */
    public void updateInstanceState(PipelineInstance instance) {

        PipelineInstanceAggregateState state = pipelineInstanceCrud.instanceState(instance);

        if (state.getNumCompletedTasks()
            .equals(state.getNumTasks())) {
            // completed successfully
            instance.setState(PipelineInstance.State.COMPLETED);
            instance.setEndProcessingTime(new Date(System.currentTimeMillis()));
            messagingService.send(MessagingDestinations.PIPELINE_EVENTS_DESTINATION, new PipelineInstanceEvent(
                PipelineInstanceEvent.Type.FINISH, instance.getId(), instance.getPriority()));
        } else {
            if (state.getNumFailedTasks() > 0) {
                if (state.getNumFailedTasks() + state.getNumCompletedTasks() == state.getNumSubmittedTasks()) {
                    instance.setState(PipelineInstance.State.ERRORS_STALLED);
                    instance.setEndProcessingTime(new Date(System.currentTimeMillis()));
                } else {
                    instance.setState(PipelineInstance.State.ERRORS_RUNNING);
                }
            } else {
                // situation normal
                instance.setState(PipelineInstance.State.PROCESSING);
            }
        }

        log.info("updateInstanceState: all nodes: numTasks/numSubmittedTasks/numCompletedTasks/numFailedTasks =  "
            + state.getNumTasks() + "/" + state.getNumSubmittedTasks() + "/" + state.getNumCompletedTasks() + "/"
            + state.getNumFailedTasks());

        log.info("updateInstanceState: updated PipelineInstance.state = " + instance.getState() + " for id: "
            + instance.getId());
    }

    /**
     * Re-run a PipelineTask in the ERROR state. Usually called from the PIG.
     * 
     * @param task
     * @param doTransitionOnly
     */
    public void reRunFailedTask(PipelineTask task, boolean doTransitionOnly) {
        log.debug("runTask(long) - start");

        PipelineTask.State oldState = task.getState();

        log.info("Re-running failed task id=" + task.getId() + ", oldState : " + oldState);

        if (oldState != PipelineTask.State.ERROR) {
            throw new PipelineException("Can only re-run ERROR tasks!  state = " + oldState);
        }

        task.setState(PipelineTask.State.SUBMITTED);
        task.setStartProcessingTime(new Date(0));
        task.setEndProcessingTime(new Date(0));
        task.setRetry(true);

        PipelineInstance instance = task.getPipelineInstance();
        PipelineInstanceNode instanceNode = pipelineInstanceNodeCrud.retrieve(instance,
            task.getPipelineDefinitionNode());

        log.info("reRunFailedTask: currentNode: numTasks/numSubmittedTasks/numCompletedTasks/numFailedTasks =  "
            + instanceNode.getNumTasks() + "/" + instanceNode.getNumSubmittedTasks() + "/"
            + instanceNode.getNumCompletedTasks() + "/" + instanceNode.getNumFailedTasks());

        pipelineInstanceNodeCrud.decrementFailedTaskCount(instanceNode.getId());

        updateInstanceState(instance);

        reRunTask(task, doTransitionOnly);
    }

    /**
     * Re-submit a task to the worker queue without making any changes to the {@link PipelineTask}
     * object in the database. Typically used for multi-step tasks, like {@link AsyncPipelineModule}
     * 
     * @param task
     * @param doTransitionOnly
     */
    public void reRunTask(PipelineTask task, boolean doTransitionOnly) {
        PipelineTask.State oldState = task.getState();

        log.info("Re-running task id=" + task.getId() + ", oldState : " + oldState);

        String queueName = MessagingDestinations.WORKER_TASK_REQUEST_QUEUE_NAMES[task.getPipelineInstance().getPriority()];

        sendWorkerMessageForTask(task, queueName, doTransitionOnly);

        // alert the workers to listen up
        PipelineInstance instance = task.getPipelineInstance();
        messagingService.send(MessagingDestinations.PIPELINE_EVENTS_DESTINATION, new PipelineInstanceEvent(
            PipelineInstanceEvent.Type.START, instance.getId(), instance.getPriority()));
    }

    /**
     * Re-submit a task to the worker queue without making any changes to the {@link PipelineTask}
     * object in the database. Typically used for multi-step tasks, like {@link AsyncPipelineModule}
     * 
     * @param task
     */
    public void reRunTask(PipelineTask task) {
        reRunTask(task, false);
    }

    /**
     * Generate and send out the tasks for the specified node.
     * 
     * @param instanceNode
     * @param queueName
     */
    private void launchNode(PipelineInstanceNode instanceNode, String queueName) {
        Map<ClassWrapper<Parameters>, ParameterSet> uowModuleParameterSets = instanceNode.getModuleParameterSets();
        PipelineDefinitionNode taskGeneratorNode = taskGeneratorNode(instanceNode.getPipelineDefinitionNode());

        launchNode(instanceNode, queueName, taskGeneratorNode, uowModuleParameterSets);
    }

    /**
     * Generate and send out the tasks for the specified node.
     * 
     * @param instanceNode
     * @param queueName
     * @param uowModuleParameterSets
     */
    private void launchNode(PipelineInstanceNode instanceNode, String queueName,
        PipelineDefinitionNode taskGeneratorNode, Map<ClassWrapper<Parameters>, ParameterSet> uowModuleParameterSets) {

        PipelineInstance instance = instanceNode.getPipelineInstance();
        PipelineDefinitionNode definitionNode = instanceNode.getPipelineDefinitionNode();
        ClassWrapper<UnitOfWorkTaskGenerator> unitOfWork = taskGeneratorNode.getUnitOfWork();

        if (!unitOfWork.isInitialized()) {
            throw new PipelineException(
                "Configuration Error: Unable to launch node because no UnitOfWork class is defined");
        }

        Map<ClassWrapper<Parameters>, ParameterSet> pipelineParameterSets = instance.getPipelineParameterSets();

        /*
         * Create a Map containing all of the entries from the pipeline
         * parameters plus the module parameters for this node for use by the
         * UnitOfWorkTaskGenerator. This allows the UOW parameters to be
         * specified at either the pipeline or module level.
         */
        Map<ClassWrapper<Parameters>, ParameterSet> compositeParameterSets = new HashMap<ClassWrapper<Parameters>, ParameterSet>(
            pipelineParameterSets);

        for (ClassWrapper<Parameters> moduleParameterClass : uowModuleParameterSets.keySet()) {
            if (!compositeParameterSets.containsKey(moduleParameterClass)) {
                compositeParameterSets.put(moduleParameterClass, uowModuleParameterSets.get(moduleParameterClass));
            } else {
                throw new PipelineException(
                    "Configuration Error: Module parameter and pipeline parameter Maps both contain a value for parameter class: "
                        + moduleParameterClass);
            }
        }

        Map<Class<? extends Parameters>, Parameters> uowParams = new HashMap<Class<? extends Parameters>, Parameters>();

        for (ClassWrapper<Parameters> parametersClass : compositeParameterSets.keySet()) {
            ParameterSet parameterSet = compositeParameterSets.get(parametersClass);
            Class<? extends Parameters> clazz = parametersClass.getClazz();
            uowParams.put(clazz, parameterSet.parametersInstance());
        }

        UnitOfWorkTaskGenerator taskGenerator = unitOfWork.newInstance();

        List<? extends UnitOfWorkTask> tasks = taskGenerator.generateTasks(uowParams);

        if (tasks.size() == 0) {
            throw new PipelineException("Task generator did not generate any tasks!  TaskGenerator: "
                + taskGenerator.getClass()
                    .getSimpleName());
        }

        for (UnitOfWorkTask task : tasks) {
            launchTask(instanceNode, queueName, instance, definitionNode, new BeanWrapper<UnitOfWorkTask>(task));
        }

        instanceNode.setNumTasks(tasks.size());
        instanceNode.setNumSubmittedTasks(tasks.size());

        PipelineInstanceNode endNode = instance.getEndNode();
        if (endNode == null || instanceNode.getId() != endNode.getId()) {
            propagateTaskCount(instance, definitionNode.getNextNodes(), tasks.size());
        }
    }

    /**
     * Recursive method to create a {@link PipelineInstanceNode} for all
     * subsequent {@link PipelineDefinitionNode}s
     * 
     * This is later used by PipelineInstanceCrud.isNodeComplete() to determine
     * if all tasks are complete for a given node.
     * 
     * @param instance
     * @param trigger
     * @param definitionNodes
     * @param taskCount
     * @throws PipelineException
     */
    private PipelineInstanceNode createInstanceNodes(PipelineInstance instance, TriggerDefinition trigger,
        PipelineDefinitionNode node, PipelineDefinitionNode endNode) {

        PipelineModuleDefinition moduleDefinition = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(node.getModuleName());
        moduleDefinition.lock();

        PipelineInstanceNode instanceNode = new PipelineInstanceNode(instance, node, moduleDefinition);
        pipelineInstanceNodeCrud.create(instanceNode);

        Map<ClassWrapper<Parameters>, ParameterSetName> triggerNodeNames = triggerNodeParameters(trigger, node);
        Map<ClassWrapper<Parameters>, ParameterSet> instanceNodeParams = instanceNode.getModuleParameterSets();

        bindParameters(triggerNodeNames, instanceNodeParams);

        if (endNode != null && endNode.getId() == node.getId()) {
            log.info("Reached optional endNode, not creating any more PipelineInstanceNodes");
            instance.setEndNode(instanceNode);
        } else {
            for (PipelineDefinitionNode nextNode : node.getNextNodes()) {
                createInstanceNodes(instance, trigger, nextNode, endNode);
            }
        }

        return instanceNode;
    }

    private Map<ClassWrapper<Parameters>, ParameterSetName> triggerNodeParameters(TriggerDefinition trigger,
        PipelineDefinitionNode node) {
        TriggerDefinitionNode triggerNode = trigger.findNodeForPath(node.getPath());

        Map<ClassWrapper<Parameters>, ParameterSetName> triggerNodeNames = triggerNode.getModuleParameterSetNames();
        return triggerNodeNames;
    }

    /**
     * For each {@link ParamSetName}, retrieve the latest version of the
     * {@link ParamSet}, lock it, and put it into the params map. Used for both
     * pipeline params and module params.
     * 
     * @param paramNames
     * @param params
     */
    private void bindParameters(Map<ClassWrapper<Parameters>, ParameterSetName> paramNames,
        Map<ClassWrapper<Parameters>, ParameterSet> params) {

        for (ClassWrapper<Parameters> paramClass : paramNames.keySet()) {
            ParameterSetName pipelineParamName = paramNames.get(paramClass);
            ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(pipelineParamName);
            params.put(paramClass, paramSet);
            paramSet.lock();
        }
    }

    /**
     * Find the task generator of the specified node. if startNewUow is false
     * for this node, walk back up the tree until with find a node with
     * startNewUow == true
     * 
     * Assumes that the back pointers have been built with
     * PipelineDefinition.buildPaths()
     * 
     * @param definitionNode
     * @return
     */
    private PipelineDefinitionNode taskGeneratorNode(PipelineDefinitionNode definitionNode) {
        PipelineDefinitionNode currentNode = definitionNode;

        while (!currentNode.isStartNewUow()) {
            currentNode = currentNode.getParentNode();
            if (currentNode == null) {
                throw new PipelineException(
                    "Configuration Error: Current node and all parent nodes have startNewUow == false");
            }
        }
        return currentNode;
    }

    /**
     * Create a new {@link PipelineTask} and the corresponding
     * {@link WorkerTaskRequest} message.
     * 
     * @param instanceNode
     * @param queueName
     * @param instance
     * @param definitionNode
     * @param task
     */
    private void launchTask(PipelineInstanceNode instanceNode, String queueName, PipelineInstance instance,
        PipelineDefinitionNode definitionNode, BeanWrapper<UnitOfWorkTask> task) {

        PipelineTask pipelineTask = new PipelineTask(instance, definitionNode, instanceNode);
        pipelineTask.setState(PipelineTask.State.SUBMITTED);
        pipelineTask.setUowTask(task);

        pipelineTaskCrud.create(pipelineTask);

        sendWorkerMessageForTask(pipelineTask, queueName, false);
    }

    /**
     * Propagate numTasks to later instance nodes that share the same UOW
     * 
     * @param nextDefinitionNodes
     * @param numTasks
     */
    private void propagateTaskCount(PipelineInstance instance, List<PipelineDefinitionNode> nextDefinitionNodes,
        int numTasks) {

        for (PipelineDefinitionNode nextDefinitionNode : nextDefinitionNodes) {
            if (!nextDefinitionNode.isStartNewUow()) {
                PipelineInstanceNode instanceNode = pipelineInstanceNodeCrud.retrieve(instance, nextDefinitionNode);
                instanceNode.setNumTasks(numTasks);

                PipelineInstanceNode endNode = instance.getEndNode();
                if (endNode == null || instanceNode.getId() != endNode.getId()) {
                    propagateTaskCount(instance, nextDefinitionNode.getNextNodes(), numTasks);
                }
            }
        }
    }

    /**
     * @param task
     * @throws PipelineException
     */
    private void sendWorkerMessageForTask(PipelineTask task, String destinationQueueName, boolean doTransitionOnly) {

        // generate the worker task messages
        log.debug("Generating worker task message for task=" + task.getId() + ", module="
            + task.getPipelineInstanceNode()
                .getPipelineModuleDefinition()
                .getName());

        WorkerTaskRequest workerTaskRequest = new WorkerTaskRequest(task.getPipelineInstance()
            .getId(), task.getPipelineInstanceNode()
            .getId(), task.getId(), doTransitionOnly);

        messagingService.send(destinationQueueName, workerTaskRequest);
    }

    /**
     * For mocking purposes only
     * 
     * @param databaseService the databaseService to set
     */
    void setDatabaseService(DatabaseService databaseService) {
        this.databaseService = databaseService;
    }

    /**
     * For mocking purposes only
     * 
     * @param messagingService the messagingService to set
     */
    void setMessagingService(MessagingService messagingService) {
        this.messagingService = messagingService;
    }

    /**
     * For mocking purposes only
     * 
     * @param pipelineInstanceCrud the pipelineInstanceCrud to set
     */
    void setPipelineInstanceCrud(PipelineInstanceCrud pipelineInstanceCrud) {
        this.pipelineInstanceCrud = pipelineInstanceCrud;
    }

    /**
     * For mocking purposes only
     * 
     * @param pipelineTaskCrud the pipelineTaskCrud to set
     */
    void setPipelineTaskCrud(PipelineTaskCrud pipelineTaskCrud) {
        this.pipelineTaskCrud = pipelineTaskCrud;
    }

    void setPipelineInstanceNodeCrud(PipelineInstanceNodeCrud pipelineInstanceNodeCrud) {
        this.pipelineInstanceNodeCrud = pipelineInstanceNodeCrud;
    }

    void setPipelineModuleDefinitionCrud(PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud) {
        this.pipelineModuleDefinitionCrud = pipelineModuleDefinitionCrud;
    }

    void setPipelineModuleParameterSetCrud(ParameterSetCrud parameterSetCrud) {
        this.parameterSetCrud = parameterSetCrud;
    }
}
