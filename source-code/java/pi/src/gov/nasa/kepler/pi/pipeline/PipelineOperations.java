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

import static com.google.common.collect.Maps.newHashMap;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ModuleName;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNodePath;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNodeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.pi.models.ModelMetadataOperations;
import gov.nasa.kepler.pi.parameters.ParametersUtils;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.apache.log4j.Logger;

public class PipelineOperations {
    private static final Logger log = Logger.getLogger(PipelineOperations.class);

    private static final String CSV_REPORT_DELIMITER = ":";

    public PipelineOperations() {
    }

    /**
     * Create a new {@link TriggerDefinition} for the specified
     * {@link PipelineDefinition}.
     * 
     * Post-conditions: {@link TriggerDefinition} maps for
     * {@link ParameterSetName}s (for both pipeline and module params) will be
     * empty, they must be set before the {@link TriggerDefinition} will pass
     * validation.
     * 
     * @param pipelineDefinition
     * @param triggerName
     * @return
     */
    public TriggerDefinition createTrigger(String triggerName,
        PipelineDefinition pipelineDefinition) {
        TriggerDefinition triggerDefinition = new TriggerDefinition(
            triggerName, pipelineDefinition);

        List<TriggerDefinitionNode> triggerNodes = createTriggerNodes(
            pipelineDefinition, triggerDefinition);

        triggerDefinition.setNodes(triggerNodes);

        return triggerDefinition;
    }

    /**
     * 
     * @param pipelineDefinition
     * @param triggerDefinition
     * @return
     */
    private List<TriggerDefinitionNode> createTriggerNodes(
        PipelineDefinition pipelineDefinition,
        TriggerDefinition triggerDefinition) {

        pipelineDefinition.buildPaths();

        List<TriggerDefinitionNode> triggerNodes = new ArrayList<TriggerDefinitionNode>();
        Set<PipelineDefinitionNode> pipelineNodes = createPipelineNodeSet(pipelineDefinition);

        for (PipelineDefinitionNode pipelineNode : pipelineNodes) {
            PipelineDefinitionNodePath path = pipelineNode.getPath();
            TriggerDefinitionNode triggerNode = new TriggerDefinitionNode(
                triggerDefinition, path, pipelineNode.getModuleName());
            triggerNodes.add(triggerNode);
        }

        return triggerNodes;
    }

    /**
     * Update the specified {@link TriggerDefinition}
     * 
     * Post-conditions: {@link TriggerDefinition} maps for
     * {@link ParameterSetName}s (for both pipeline and module params) will be
     * empty, they must be set before the {@link TriggerDefinition} will pass
     * validation.
     * 
     * @param pipelineDefinition
     * @param triggerName
     * @return
     */
    public void updateTrigger(TriggerDefinition triggerDefinition) {

        PipelineDefinitionCrud crud = new PipelineDefinitionCrud();
        PipelineDefinition latestPipelineDef = crud.retrieveLatestVersionForName(triggerDefinition.getPipelineDefinitionName());

        latestPipelineDef.buildPaths();

        updateTriggerNodes(latestPipelineDef, triggerDefinition);
    }

    /**
     * 
     * @param pipelineDefinition
     * @param triggerDefinition
     * @return
     */
    private void updateTriggerNodes(PipelineDefinition pipelineDefinition,
        TriggerDefinition triggerDefinition) {

        pipelineDefinition.buildPaths();

        List<TriggerDefinitionNode> triggerNodes = triggerDefinition.getNodes();
        triggerNodes.clear();
        Set<PipelineDefinitionNode> pipelineNodes = createPipelineNodeSet(pipelineDefinition);

        // add new trigger nodes for newly added pipeline nodes
        for (PipelineDefinitionNode pipelineNode : pipelineNodes) {
            PipelineDefinitionNodePath path = pipelineNode.getPath();
            TriggerDefinitionNode triggerNode = triggerDefinition.findNodeForPath(path);

            /*
             * If a node with a different module exists at this path, delete it
             * first
             */
            if (triggerNode != null && !triggerNode.getNodeModuleName()
                .equals(pipelineNode.getModuleName())) {
                triggerDefinition.getNodes()
                    .remove(triggerNode);
                triggerNode = null;
            }

            if (triggerNode == null) { // new node in pipeline
                triggerNode = new TriggerDefinitionNode(triggerDefinition,
                    path, pipelineNode.getModuleName());
                triggerNodes.add(triggerNode);
            }
        }

        // Remove invalid paths
        List<TriggerDefinitionNode> nodesToDelete = new ArrayList<TriggerDefinitionNode>();
        for (TriggerDefinitionNode triggerNode : triggerNodes) {
            PipelineDefinitionNode pipelineNode = triggerNode.getPipelineDefinitionNodePath()
                .definitionNodeAt(pipelineDefinition);
            if (pipelineNode == null) {
                // invalid path
                nodesToDelete.add(triggerNode);
            }
        }

        for (TriggerDefinitionNode nodeToDelete : nodesToDelete) {
            triggerDefinition.getNodes()
                .remove(nodeToDelete);
        }
    }

    /**
     * Create a Set of all {@link PipelineDefinitionNode}s in the
     * {@link PipelineDefinition}. Used when creating a new
     * {@link TriggerDefinition} and when validating an existing
     * {@link TriggerDefinition}.
     * 
     * @param pipelineDefinition
     * @return
     */
    private Set<PipelineDefinitionNode> createPipelineNodeSet(
        PipelineDefinition pipelineDefinition) {

        Set<PipelineDefinitionNode> pipelineNodes = new HashSet<PipelineDefinitionNode>();

        addChildrenToPipelineNodeSet(pipelineNodes,
            pipelineDefinition.getRootNodes());

        return pipelineNodes;
    }

    /**
     * Recursive method to create a {@link TriggerNode} for all
     * {@link PipelineDefinitionNode}s.
     * 
     * @param pipelineNodes
     * @param definitionNodes
     */
    private void addChildrenToPipelineNodeSet(
        Set<PipelineDefinitionNode> pipelineNodes,
        List<PipelineDefinitionNode> definitionNodes) {

        for (PipelineDefinitionNode definitionNode : definitionNodes) {

            if (pipelineNodes.contains(definitionNode)) {
                throw new PipelineException(
                    "Circular reference: pipelineNodes Set already contains this node: "
                        + definitionNode);
            }

            pipelineNodes.add(definitionNode);

            addChildrenToPipelineNodeSet(pipelineNodes,
                definitionNode.getNextNodes());
        }

    }

    /**
     * Get the latest version for the specified {@link ModuleName}
     * 
     * @param parameterSetName
     * @return
     */
    public PipelineModuleDefinition retrieveLatestModuleDefinition(
        ModuleName moduleName) {
        PipelineModuleDefinitionCrud crud = new PipelineModuleDefinitionCrud();
        PipelineModuleDefinition latestModuleDef = crud.retrieveLatestVersionForName(moduleName);

        return latestModuleDef;
    }

    /**
     * Get the latest version for the specified parameterSetName
     * 
     * @param parameterSetName
     * @return
     */
    public ParameterSet retrieveLatestParameterSet(String parameterSetName) {
        ParameterSetCrud crud = new ParameterSetCrud();
        ParameterSet latestParameterSet = crud.retrieveLatestVersionForName(parameterSetName);

        return latestParameterSet;
    }

    /**
     * Get the latest version for the specified {@link ParameterSetName}
     * 
     * @param parameterSetName
     * @return
     */
    public ParameterSet retrieveLatestParameterSet(
        ParameterSetName parameterSetName) {
        ParameterSetCrud crud = new ParameterSetCrud();
        ParameterSet latestParameterSet = crud.retrieveLatestVersionForName(parameterSetName);

        return latestParameterSet;
    }

    /**
     * Returns a {@link Set<ClassWrapper<Parameters>>} containing all
     * {@link Parameters} classes required by the specified
     * {@link TriggerDefinitionNode}. This is a union of the Parameters classes
     * required by the PipelineModule itself and the Parameters classes required
     * by the UnitOfWorkTaskGenerator associated with the node.
     * 
     * @param trigger
     * @param triggerNode
     * @return
     */
    public Set<ClassWrapper<Parameters>> retrieveRequiredParameterClassesForNode(
        TriggerDefinition trigger, TriggerDefinitionNode triggerNode) {

        PipelineDefinitionCrud pipelineCrud = new PipelineDefinitionCrud();

        PipelineDefinitionName pipelineDefinitionName = trigger.getPipelineDefinitionName();
        PipelineDefinition pipelineDef = pipelineCrud.retrieveLatestVersionForName(pipelineDefinitionName);
        PipelineDefinitionNode pipelineNode = triggerNode.getPipelineDefinitionNodePath()
            .definitionNodeAt(pipelineDef);

        return retrieveRequiredParameterClassesForNode(trigger, pipelineNode);
    }

    /**
     * Returns a {@link Set<ClassWrapper<Parameters>>} containing all
     * {@link Parameters} classes required by the specified
     * {@link PipelineDefinitionNode}. This is a union of the Parameters classes
     * required by the PipelineModule itself and the Parameters classes required
     * by the UnitOfWorkTaskGenerator associated with the node.
     * 
     * @param trigger
     * @param triggerNode
     * @return
     */
    public Set<ClassWrapper<Parameters>> retrieveRequiredParameterClassesForNode(
        TriggerDefinition trigger, PipelineDefinitionNode pipelineNode) {

        PipelineModuleDefinitionCrud modDefCrud = new PipelineModuleDefinitionCrud();
        PipelineModuleDefinition modDef = modDefCrud.retrieveLatestVersionForName(pipelineNode.getModuleName());

        Set<ClassWrapper<Parameters>> allRequiredParams = new HashSet<ClassWrapper<Parameters>>();

        // if(pipelineNode.hasValidUow()){
        // allRequiredParams.addAll(pipelineNode.getUowRequiredParameterClasses());
        // }else{
        // // get UoW from previous node
        // }

        allRequiredParams.addAll(pipelineNode.getUowRequiredParameterClasses());
        allRequiredParams.addAll(modDef.getRequiredParameterClasses());

        return allRequiredParams;
    }

    /**
     * Update the specified {@link ParameterSetName} with the specified
     * {@link Parameters}.
     * 
     * If if the parameters instance is different than the parameter set, then
     * apply the changes. If locked, first create a new version.
     * 
     * The new ParameterSet version is returned if one was created, otherwise
     * the old one is returned.
     * 
     * @param parameters
     * @param forceSave If true, save the new ParameterSet even if nothing
     * changed
     * @return
     */
    public ParameterSet updateParameterSet(ParameterSetName parameterSetName,
        Parameters parameters, boolean forceSave) {
        ParameterSet parameterSet = retrieveLatestParameterSet(parameterSetName);

        return updateParameterSet(parameterSet, parameters, forceSave);
    }

    /**
     * Update the specified {@link ParameterSet} with the specified
     * {@link Parameters}.
     * 
     * If if the parameters instance is different than the parameter set, then
     * apply the changes. If locked, first create a new version.
     * 
     * The new ParameterSet version is returned if one was created, otherwise
     * the old one is returned.
     * 
     * @param parameters
     * @return
     */
    public ParameterSet updateParameterSet(ParameterSet parameterSet,
        Parameters newParameters, boolean forceSave) {
        return updateParameterSet(parameterSet, newParameters,
            parameterSet.getDescription(), forceSave);
    }

    /**
     * Update the specified {@link ParameterSet} with the specified
     * {@link Parameters}.
     * 
     * If if the parameters instance is different than the parameter set, then
     * apply the changes. If locked, first create a new version.
     * 
     * The new ParameterSet version is returned if one was created, otherwise
     * the old one is returned.
     * 
     * @param newParameters
     * @return
     */
    public ParameterSet updateParameterSet(ParameterSet parameterSet,
        Parameters newParameters, String newDescription, boolean forceSave) {

        BeanWrapper<Parameters> currentParamsBean = parameterSet.getParameters();
        BeanWrapper<Parameters> newParamsBean = new BeanWrapper<Parameters>(
            newParameters);

        String currentDescription = parameterSet.getDescription();

        ParameterSet updatedParameterSet = parameterSet;

        boolean descriptionChanged = false;
        if (currentDescription == null) {
            if (newDescription != null) {
                descriptionChanged = true;
            }
        } else if (!currentDescription.equals(newDescription)) {
            descriptionChanged = true;
        }

        boolean propsChanged = !compareParameters(currentParamsBean,
            newParamsBean);

        if (propsChanged || descriptionChanged || forceSave) {
            if (parameterSet.isLocked()) {
                updatedParameterSet = parameterSet.newVersion();
            }

            updatedParameterSet.setParameters(newParamsBean);
            updatedParameterSet.setDescription(newDescription);
            ParameterSetCrud crud = new ParameterSetCrud();
            crud.create(updatedParameterSet);
        }

        return updatedParameterSet;
    }

    /**
     * Indicates whether the specified beans contain the same parameters and
     * values
     * 
     * @param currentParamsBean
     * @param newParamsBean
     * @return true if same
     */
    public boolean compareParameters(BeanWrapper<Parameters> currentParamsBean,
        BeanWrapper<Parameters> newParamsBean) {
        Map<String, String> currentProps = currentParamsBean.getProps();
        Map<String, String> newProps = newParamsBean.getProps();

        boolean propsSame = true;
        if (currentProps == null) {
            if (newProps != null) {
                propsSame = false;
            }
        } else {
            propsSame = currentProps.equals(newProps);
        }

        log.debug("currentProps.size = " + currentProps.size());
        log.debug("newProps.size = " + newProps.size());

        return propsSame;
    }

    /**
     * Create the launcher and launch a new pipeline instance using the
     * specified {@link TriggerDefinition}
     * 
     * @throws PipelineException
     */
    public PipelineInstance fireTrigger(TriggerDefinition triggerDefinition,
        String instanceName) {

        TriggerValidationResults validationResults = validateTrigger(triggerDefinition);
        if (validationResults.hasErrors()) {
            throw new PipelineException(String.format("Failed to fire trigger: %s, validation failed: %s",
                    triggerDefinition.getName(), validationResults.errorReport()));
        }

        PipelineExecutor pipelineExecutor = new PipelineExecutor();
        PipelineInstance pipelineInstance;

        pipelineInstance = pipelineExecutor.launch(triggerDefinition,
            instanceName);

        return pipelineInstance;
    }

    /**
     * Create the launcher and launch a new pipeline instance using the
     * specified {@link TriggerDefinition} and startNode/endNode
     * 
     * @param startNode Optional start node (default is root of the
     * PipelineDefnition)
     * @param endNode Optional end node (default is leafs of the
     * PipelineDefnition)
     * @throws PipelineException
     */
    public PipelineInstance fireTrigger(TriggerDefinition triggerDefinition,
        String instanceName, PipelineDefinitionNode startNode,
        PipelineDefinitionNode endNode) {

        TriggerValidationResults validationResults = validateTrigger(triggerDefinition);
        if (validationResults.hasErrors()) {
            throw new PipelineException(
                "Failed to fire trigger, validation failed: "
                    + validationResults.errorReport());
        }

        PipelineExecutor pipelineExecutor = new PipelineExecutor();
        PipelineInstance pipelineInstance;

        pipelineInstance = pipelineExecutor.launch(triggerDefinition,
            instanceName, startNode, endNode);

        return pipelineInstance;
    }

    /**
     * Validates that this {@link TriggerDefinition} is valid for firing. Checks
     * that the associated pipeline definition objects have not changed in an
     * incompatible way and that all {@link ParameterSetName}s are set.
     * 
     */
    public TriggerValidationResults validateTrigger(
        TriggerDefinition triggerDefinition) {

        TriggerValidationResults validationResults = new TriggerValidationResults();

        PipelineDefinitionCrud crud = new PipelineDefinitionCrud();
        PipelineDefinition latestPipelineDef = crud.retrieveLatestVersionForName(triggerDefinition.getPipelineDefinitionName());

        latestPipelineDef.buildPaths();

        validateTriggerStructure(triggerDefinition, latestPipelineDef,
            validationResults);
        validateTriggerParameters(triggerDefinition, latestPipelineDef,
            validationResults);

        return validationResults;
    }

    /**
     * Make sure the TriggerDefinition and the PipelineDefinition match
     * structurally
     * 
     * @param latestPipelineDef
     * @param validationResults
     * 
     * @param pipelineDefinition
     * @return
     */
    private void validateTriggerStructure(TriggerDefinition trigger,
        PipelineDefinition latestPipelineDef,
        TriggerValidationResults validationResults) {

        /*
         * for each node find PDN for path verify that moduleNames match
         */
        for (PipelineDefinitionNode rootNode : latestPipelineDef.getRootNodes()) {
            validateTriggerStructureForNode(trigger, rootNode,
                validationResults);
        }
    }

    private void validateTriggerStructureForNode(TriggerDefinition trigger,
        PipelineDefinitionNode node, TriggerValidationResults validationResults) {
        TriggerDefinitionNode triggerNode = trigger.findNodeForPath(node.getPath());
        ModuleName pipelineNodeModuleName = node.getModuleName();

        if (triggerNode == null) {
            validationResults.addError("No parameters found in trigger for node = "
                + pipelineNodeModuleName + ", pdn id=" + node.getId());
        } else {

            ModuleName triggerNodeModuleName = triggerNode.getNodeModuleName();

            if (!triggerNodeModuleName.equals(pipelineNodeModuleName)) {
                validationResults.addError("Trigger is invalid because pipeline node structure has changed.  At path="
                    + node.getPath()
                    + ", expected module="
                    + triggerNodeModuleName
                    + ", but found module="
                    + pipelineNodeModuleName);
            }

            validateUnitOfWork(node, validationResults);
        }

        for (PipelineDefinitionNode childNode : node.getNextNodes()) {
            validateTriggerStructureForNode(trigger, childNode,
                validationResults);
        }
    }

    private void validateUnitOfWork(PipelineDefinitionNode node,
        TriggerValidationResults validationResults) {
        if (node.isStartNewUow()) {
            PipelineModuleDefinitionCrud modDefCrud = new PipelineModuleDefinitionCrud();
            ModuleName moduleName = node.getModuleName();
            PipelineModuleDefinition moduleDef = modDefCrud.retrieveLatestVersionForName(moduleName);

            PipelineModule moduleInstance = moduleDef.getImplementingClass()
                .newInstance();
            Class<? extends UnitOfWorkTask> selectedModuleUowTaskType = moduleInstance.unitOfWorkTaskType();

            ClassWrapper<UnitOfWorkTaskGenerator> bean = (ClassWrapper<UnitOfWorkTaskGenerator>) node.getUnitOfWork();
            UnitOfWorkTaskGenerator selectedUowType = bean.newInstance();
            Class<? extends UnitOfWorkTask> selectedUowTaskType = selectedUowType.unitOfWorkTaskType();

            if (!selectedModuleUowTaskType.equals(selectedUowTaskType)) {
                validationResults.addError(moduleName + " expects "
                    + selectedModuleUowTaskType.getSimpleName()
                    + ", but the selected UOW type: " + selectedUowType
                    + " generates " + selectedUowTaskType.getSimpleName());
            }
        }
    }

    /**
     * Validate that the trigger {@link ParameterSetName}s are all set and match
     * the parameter classes specified in the {@link PipelineDefinition}
     * 
     * @param trigger
     * @param latestPipelineDef
     * @param validationResults
     */
    private void validateTriggerParameters(TriggerDefinition trigger,
        PipelineDefinition latestPipelineDef,
        TriggerValidationResults validationResults) {

        validateParameterClassExists(trigger.getPipelineParameterSetNames(),
            "Pipeline parameters", validationResults);

        for (PipelineDefinitionNode rootNode : latestPipelineDef.getRootNodes()) {
            validateTriggerParametersForNode(trigger, rootNode,
                validationResults);
        }
    }

    /**
     * 
     * @param trigger
     * @param pipelineDefNode
     * @param validationResults
     */
    private void validateTriggerParametersForNode(TriggerDefinition trigger,
        PipelineDefinitionNode pipelineDefNode,
        TriggerValidationResults validationResults) {
        TriggerDefinitionNode triggerNode = trigger.findNodeForPath(pipelineDefNode.getPath());
        String errorLabel = "module: " + pipelineDefNode.getModuleName();

        if (triggerNode != null) {
            Set<ClassWrapper<Parameters>> requiredParameterClasses = retrieveRequiredParameterClassesForNode(
                trigger, pipelineDefNode);

            validateParameterClassExists(
                triggerNode.getModuleParameterSetNames(), errorLabel,
                validationResults);

            validateTriggerParameters(requiredParameterClasses,
                trigger.getPipelineParameterSetNames(),
                triggerNode.getModuleParameterSetNames(), errorLabel,
                validationResults);
        } else {
            validationResults.addError(errorLabel
                + ": trigger does not contain a node for this module");
        }

        for (PipelineDefinitionNode childNode : pipelineDefNode.getNextNodes()) {
            validateTriggerParametersForNode(trigger, childNode,
                validationResults);
        }
    }

    /**
     * Validate that the trigger {@link ParameterSetName}s are all set and match
     * the parameter classes specified in the {@link PipelineDefinition} for a
     * given trigger node (module)
     * 
     * @param validationResults
     */
    private void validateTriggerParameters(
        Set<ClassWrapper<Parameters>> requiredModuleParameterClasses,
        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames,
        Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames,
        String errorLabel, TriggerValidationResults validationResults) {

        ParameterSetName paramSetName = null;

        for (ClassWrapper<Parameters> classWrapper : requiredModuleParameterClasses) {
            boolean found = false;

            // check at the module level first
            if (moduleParameterSetNames.keySet()
                .contains(classWrapper)) {
                paramSetName = moduleParameterSetNames.get(classWrapper);
                found = true;
            } else if (pipelineParameterSetNames.keySet()
                .contains(classWrapper)) {
                // then at the pipeline level
                paramSetName = pipelineParameterSetNames.get(classWrapper);
                found = true;
            } else {
                validationResults.addError(errorLabel
                    + ": Missing Parameter Set: " + classWrapper
                    + " at either the module level or the pipeline level");
            }

            if (found) {
                if (paramSetName == null) {
                    validationResults.addError(errorLabel
                        + ": trigger parameter Map value for class: "
                        + classWrapper
                        + " is null.  Must be set before firing the TriggerDefinition");
                } else {
                    // check for new fields
                    ParameterSet paramSet = retrieveLatestParameterSet(paramSetName);
                    BeanWrapper<Parameters> bean = paramSet.getParameters();
                    if (bean.hasNewUnsavedFields()) {
                        validationResults.addError(errorLabel
                            + ": parameter set: "
                            + paramSetName
                            + " has new fields that have been added since the last time this parameter set was saved.  "
                            + "Please edit the parameter set in the parameter library, verify that it has the correct values, and save it.");
                    }
                }
            }
        }

        /*
         * Make sure the same parameters class does not exist at both the
         * pipeline and module level because this makes the data accountability
         * trace less clear (could possibly support this in the future)
         */
        for (ClassWrapper<Parameters> moduleParameterClass : moduleParameterSetNames.keySet()) {
            if (pipelineParameterSetNames.containsKey(moduleParameterClass)) {
                validationResults.addError("Ambiguous configuration: Module parameter and pipeline parameter Maps both contain a value for parameter class: "
                    + moduleParameterClass);
            }
        }
    }

    /**
     * 
     * @param parameterSetNames
     * @param errorLabel
     * @param validationResults
     */
    private void validateParameterClassExists(
        Map<ClassWrapper<Parameters>, ParameterSetName> parameterSetNames,
        String errorLabel, TriggerValidationResults validationResults) {
        for (ClassWrapper<Parameters> classWrapper : parameterSetNames.keySet()) {
            try {
                classWrapper.getClazz();
            } catch (RuntimeException e) {
                validationResults.addError(errorLabel
                    + ": trigger parameters contain an entry for a Parameter class that no longer exists: "
                    + classWrapper.getClassName());
            }

        }
    }

    /**
     * Generate a text report containing pipeline instance metadata including
     * all parameter sets and their values.
     * 
     * @param instance
     * @return
     */
    public String generatePedigreeReport(PipelineInstance instance) {
        PipelineInstanceNodeCrud pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud();
        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

        String nl = System.getProperty("line.separator");
        StringBuilder report = new StringBuilder();

        report.append("Instance ID: " + instance.getId() + nl);
        report.append("Instance Name: " + instance.getName() + nl);
        report.append("Instance Priority: " + instance.getPriority() + nl);
        report.append("Instance State: " + instance.getState() + nl);
        List<String> instanceSoftwareRevisions = pipelineTaskCrud.distinctSoftwareRevisions(instance);
        report.append("Instance Software Revisions: "
            + instanceSoftwareRevisions + nl);
        report.append(nl);
        report.append("Definition Name: " + instance.getPipelineDefinition()
            .getName() + nl);
        report.append("Definition Version: " + instance.getPipelineDefinition()
            .getVersion() + nl);
        report.append("Definition ID: " + instance.getPipelineDefinition()
            .getId() + nl);

        report.append(nl);
        report.append("Pipeline Parameter Sets" + nl);
        Map<ClassWrapper<Parameters>, ParameterSet> pipelineParamSets = instance.getPipelineParameterSets();
        for (ClassWrapper<Parameters> paramClassWrapper : pipelineParamSets.keySet()) {
            ParameterSet paramSet = pipelineParamSets.get(paramClassWrapper);

            appendParameterSetToReport(report, paramSet, "  ", false);
            report.append(nl);
        }

        report.append(nl);
        report.append("Modules" + nl);

        List<PipelineInstanceNode> pipelineNodes = pipelineInstanceNodeCrud.retrieveAll(instance);

        for (PipelineInstanceNode node : pipelineNodes) {
            PipelineModuleDefinition module = node.getPipelineModuleDefinition();

            appendModule(nl, report, module);

            report.append("    # Tasks (total/completed/failed): "
                + node.getNumTasks() + "/" + node.getNumCompletedTasks() + "/"
                + node.getNumFailedTasks() + nl);
            List<String> nodeSoftwareRevisions = pipelineTaskCrud.distinctSoftwareRevisions(node);
            report.append("    Software Revisions for node:"
                + nodeSoftwareRevisions + nl);

            Map<ClassWrapper<Parameters>, ParameterSet> moduleParamSets = node.getModuleParameterSets();
            for (ClassWrapper<Parameters> paramClassWrapper : moduleParamSets.keySet()) {
                ParameterSet moduleParamSet = moduleParamSets.get(paramClassWrapper);

                appendParameterSetToReport(report, moduleParamSet, "    ",
                    false);
                report.append(nl);
            }
        }

        report.append(nl);
        report.append("Data Model Registry" + nl);
        ModelMetadataOperations modelMetadataOps = new ModelMetadataOperations();
        report.append(modelMetadataOps.report(instance));

        return report.toString();
    }

    /**
     * Generate a text report about the specified {@link TriggerDefinition}
     * including all parameter sets and their values.
     * 
     * @param triggerDefinition
     * @return
     */
    public String generateTriggerReport(TriggerDefinition triggerDefinition) {
        String nl = System.getProperty("line.separator");
        StringBuilder report = new StringBuilder();
        ParameterSetCrud paramSetCrud = new ParameterSetCrud();
        PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud();

        report.append("Trigger ID: " + triggerDefinition.getId() + nl);
        report.append("Trigger Name: " + triggerDefinition.getName() + nl);
        report.append("Trigger Priority: "
            + triggerDefinition.getInstancePriority() + nl);
        report.append(nl);

        TriggerValidationResults validationErrors = validateTrigger(triggerDefinition);
        if (validationErrors.hasErrors()) {
            report.append("*** Trigger Validation Errors ***" + nl);
            report.append(nl);
            report.append(validationErrors.errorReport("  "));
            report.append(nl);
        }

        report.append("Definition Name: "
            + triggerDefinition.getPipelineDefinitionName()
                .getName() + nl);

        report.append("Pipeline Parameter Sets" + nl);
        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParamSets = triggerDefinition.getPipelineParameterSetNames();
        for (ClassWrapper<Parameters> paramClassWrapper : pipelineParamSets.keySet()) {
            ParameterSetName paramSetName = pipelineParamSets.get(paramClassWrapper);
            ParameterSet paramSet = paramSetCrud.retrieveLatestVersionForName(paramSetName);

            appendParameterSetToReport(report, paramSet, "  ", false);
            report.append(nl);
        }

        report.append(nl);
        report.append("Modules" + nl);

        List<TriggerDefinitionNode> nodes = triggerDefinition.getNodes();
        for (TriggerDefinitionNode node : nodes) {
            ModuleName moduleName = node.getNodeModuleName();

            PipelineModuleDefinition modDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(moduleName);

            appendModule(nl, report, modDef);

            Map<ClassWrapper<Parameters>, ParameterSetName> moduleParamSetNames = node.getModuleParameterSetNames();
            for (ClassWrapper<Parameters> paramClassWrapper : moduleParamSetNames.keySet()) {
                ParameterSetName moduleParamSetName = moduleParamSetNames.get(paramClassWrapper);
                ParameterSet moduleParamSet = paramSetCrud.retrieveLatestVersionForName(moduleParamSetName);

                appendParameterSetToReport(report, moduleParamSet, "    ",
                    false);
                report.append(nl);
            }
        }

        return report.toString();
    }

    private void appendModule(String nl, StringBuilder report,
        PipelineModuleDefinition module) {
        report.append(nl);
        report.append("  Module Definition: " + module.getName()
            + ", version=" + module.getVersion() + nl);
        report.append("    Java Classname: " + module.getImplementingClass()
            .getClazz()
            .getSimpleName() + nl);
        report.append("    exe timeout seconds: " + module.getExeTimeoutSecs() + nl);
        report.append("    exe name: " + module.getExeName() + nl);
        report.append("    min memory MB: " + module.getMinMemoryMegaBytes() + nl);
    }

    /**
     * 
     * @param triggerDefinition
     */
    public void exportTriggerParams(TriggerDefinition triggerDefinition,
        File destinationDirectory) {

        if (!destinationDirectory.exists()) {
            try {
                FileUtils.forceMkdir(destinationDirectory);
            } catch (IOException e) {
                throw new PipelineException("failed to create ["
                    + destinationDirectory + "], caught e = " + e, e);
            }
        }

        ParameterSetCrud paramSetCrud = new ParameterSetCrud();
        Map<String, Parameters> paramsToExport = new HashMap<String, Parameters>();

        Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParamSets = triggerDefinition.getPipelineParameterSetNames();
        for (ClassWrapper<Parameters> paramClassWrapper : pipelineParamSets.keySet()) {
            ParameterSetName paramSetName = pipelineParamSets.get(paramClassWrapper);
            ParameterSet paramSet = paramSetCrud.retrieveLatestVersionForName(paramSetName);

            paramsToExport.put(paramSetName.getName(),
                paramSet.parametersInstance());
        }

        List<TriggerDefinitionNode> nodes = triggerDefinition.getNodes();
        for (TriggerDefinitionNode node : nodes) {

            Map<ClassWrapper<Parameters>, ParameterSetName> moduleParamSetNames = node.getModuleParameterSetNames();
            for (ClassWrapper<Parameters> paramClassWrapper : moduleParamSetNames.keySet()) {
                ParameterSetName moduleParamSetName = moduleParamSetNames.get(paramClassWrapper);
                ParameterSet moduleParamSet = paramSetCrud.retrieveLatestVersionForName(moduleParamSetName);

                paramsToExport.put(moduleParamSetName.getName(),
                    moduleParamSet.parametersInstance());
            }
        }

        for (String paramSetName : paramsToExport.keySet()) {
            Parameters params = paramsToExport.get(paramSetName);
            File file = new File(destinationDirectory, paramSetName
                + ".properties");

            try {
                ParametersUtils.exportParameters(file, params);
            } catch (IOException e) {
                throw new PipelineException("failed to export [" + file
                    + "], caught e = " + e, e);
            }
        }
    }

    /**
     * Creates a textual report of all ParameterSets in the Parameter Library,
     * including name, type, keys & values.
     * 
     * @param csvMode
     * @return
     */
    public String generateParameterLibraryReport(boolean csvMode) {
        StringBuilder report = new StringBuilder();

        ParameterSetCrud paramSetCrud = new ParameterSetCrud();
        List<ParameterSet> allParamSets = paramSetCrud.retrieveLatestVersions();

        for (ParameterSet parameterSet : allParamSets) {
            appendParameterSetToReport(report, parameterSet, "", csvMode);
        }

        return report.toString();
    }

    /**
     * Used by generatePedigreeReport
     * 
     * @param report
     * @param paramSet
     * @param indent
     */
    public void appendParameterSetToReport(StringBuilder report,
        ParameterSet paramSet, String indent, boolean csvMode) {
        String nl = System.getProperty("line.separator");
        String paramsIndent = indent + "  ";
        BeanWrapper<Parameters> parameters = paramSet.getParameters();
        String parameterClassName = "";

        try {
            parameterClassName = parameters.getClazz()
                .getSimpleName();
        } catch (RuntimeException e) {
            parameterClassName = " <deleted>: " + parameters.getClassName();
        }

        if (!csvMode) {
            report.append(indent + "Parameter Set: " + paramSet.getName()
                + " (type=" + parameterClassName + ", version="
                + paramSet.getVersion() + ")" + nl);
        }

        Map<String, String> params = parameters.getProps();
        if (params.isEmpty() && !csvMode) {
            report.append(paramsIndent + "(no parameters)" + nl);
        } else {
            List<String> sortedKeys = new LinkedList<String>(params.keySet());
            Collections.sort(sortedKeys);
            for (String key : sortedKeys) {
                String value = params.get(key);

                if (csvMode) {
                    report.append(paramSet.getName() + CSV_REPORT_DELIMITER);
                    report.append(parameterClassName + CSV_REPORT_DELIMITER);
                    report.append(paramSet.getVersion() + CSV_REPORT_DELIMITER);
                    report.append(key + CSV_REPORT_DELIMITER);
                    report.append(value + nl);
                } else {
                    report.append(paramsIndent + key + " = " + value + nl);
                }
            }
        }
    }

    public Map<ClassWrapper<Parameters>, ParameterSet> retrieveParameterSets(
        TriggerDefinition triggerDefinition, String moduleName) {
        Map<ClassWrapper<Parameters>, ParameterSetName> parameterSetNameMap = newHashMap();
        parameterSetNameMap.putAll(triggerDefinition.getPipelineParameterSetNames());

        for (TriggerDefinitionNode triggerDefinitionNode : triggerDefinition.getNodes()) {
            if (triggerDefinitionNode.getNodeModuleName()
                .getName()
                .equals(moduleName)) {
                parameterSetNameMap.putAll(triggerDefinitionNode.getModuleParameterSetNames());
            }
        }

        ParameterSetCrud parameterSetCrud = new ParameterSetCrud();
        Map<ClassWrapper<Parameters>, ParameterSet> parameterSetMap = newHashMap();
        for (Entry<ClassWrapper<Parameters>, ParameterSetName> entry : parameterSetNameMap.entrySet()) {
            ParameterSet parameterSet = parameterSetCrud.retrieveLatestVersionForName(entry.getValue());
            parameterSetMap.put(entry.getKey(), parameterSet);
        }

        return parameterSetMap;
    }
}
