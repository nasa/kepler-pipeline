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
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNodePath;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is a convenience class for creating pipeline and trigger definitions. To
 * keep the API simple, branching nodes are not supported.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class PipelineConfigurator {
    private static final Log log = LogFactory.getLog(PipelineConfigurator.class);

    private DatabaseService databaseService;
    private PipelineDefinitionCrud pipelineDefinitionCrud;
    private TriggerDefinitionCrud triggerDefinitionCrud;
    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
    private ParameterSetCrud parameterSetCrud;

    PipelineDefinition pipeline = null;
    PipelineDefinitionNode currentNode = null;

    TriggerDefinition trigger = null;

    // pipeline params
    private Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNamesMap = new HashMap<ClassWrapper<Parameters>, ParameterSetName>();

    // module params
    private Map<PipelineDefinitionNode, Map<ClassWrapper<Parameters>, ParameterSetName>> moduleParameterSetNamesMap = new HashMap<PipelineDefinitionNode, Map<ClassWrapper<Parameters>, ParameterSetName>>();

    private int exeTimeout = 60 * 60 * 50; // 50 hours

    public PipelineConfigurator() {
        databaseService = DatabaseServiceFactory.getInstance();

        pipelineDefinitionCrud = new PipelineDefinitionCrud(databaseService);
        triggerDefinitionCrud = new TriggerDefinitionCrud(databaseService);
        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud(databaseService);
        parameterSetCrud = new ParameterSetCrud(databaseService);
    }

    /**
     * Create a new pipeline definition. Must be called before nodes are added.
     * 
     * @param name
     * @param description
     */
    public PipelineDefinition createPipeline(String name) {

        // delete old pipeline definition, if it exists
        pipelineDefinitionCrud.deleteAllVersionsForName(name);

        pipeline = new PipelineDefinition(name);
        pipeline.setDescription("Created by PipelineConfigurator");

        return pipeline;
    }

    /**
     * Convenience method to create a new pipeline definition with a single
     * pipeline {@link Parameters} class. More pipeline {@link Parameters}
     * classes can be added with addPipelineParametersClass()
     * 
     * @param name
     * @param description
     * @param parameters
     * @throws PipelineException
     */
    public PipelineDefinition createPipeline(String name, Parameters pipelineParams) {

        createPipeline(name);

        ParameterSet pipelineParamSet = createParamSet(name + "-params", pipelineParams);
        pipelineParamSet.setDescription("default pipeline params created by PipelineConfigurator");

        pipelineParameterSetNamesMap.put(new ClassWrapper<Parameters>(pipelineParams), pipelineParamSet.getName());

        return pipeline;
    }

    /**
     * Add a new {@link Parameters} class this this {@link PipelineDefinition}s
     * list of pipeline parameters classes
     * 
     * @param parametersClass
     */
    public void addPipelineParameters(String name, Parameters pipelineParams) {
        if (pipeline == null) {
            throw new PipelineException("Pipeline not initialized, call createPipeline() first");
        }

        ParameterSet pipelineParamSet = createParamSet(name, pipelineParams);
        pipelineParameterSetNamesMap.put(new ClassWrapper<Parameters>(pipelineParams), pipelineParamSet.getName());
    }

    /**
     * Add a param set to the param set names to be used for the next trigger
     * 
     * @param pipelineParams
     */
    public void addPipelineParameterSet(ParameterSet parameterSet) {
        if (pipeline == null) {
            throw new PipelineException("Pipeline not initialized, call createPipeline() first");
        }

        Class<? extends Parameters> paramSetClass = parameterSet.parametersInstance()
            .getClass();
        
        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(paramSetClass);
        pipelineParameterSetNamesMap.put(classWrapper, parameterSet.getName());
    }

    /**
     * Convenience method to create a new {@link PipelineModuleDefinition} and a
     * new {@link PipelineDefinitionNode} to hold it in one step. This method
     * should only be used if the {@link PipelineModuleDefinition} won't be
     * shared by multiple pipelines. If shared, use createModule() to create it
     * and call addNode(PipelineModuleDefinition moduleDef)
     * 
     * @param name
     * @param description
     * @param clazz
     * @param exeName
     * @param paramSets
     * @param taskGenerator
     * @return
     * @throws PipelineException
     */
    public PipelineDefinitionNode addNode(String name, Class<? extends PipelineModule> clazz, String exeName,
        UnitOfWorkTaskGenerator taskGenerator, Parameters... parametersList) {

        if (pipeline == null) {
            throw new PipelineException("Pipeline not initialized, call createPipeline() first");
        }

        List<ParameterSet> paramSets = new LinkedList<ParameterSet>();
        if (parametersList != null) {
            for (Parameters parameters : parametersList) {
                ParameterSet paramSet = createParamSet(name + "-"
                    + parameters.getClass()
                        .getSimpleName(), parameters);
                paramSet.setDescription("default module params created by PipelineConfigurator");
                paramSets.add(paramSet);
            }
        }

        return createNode(name, clazz, exeName, taskGenerator, paramSets.toArray(new ParameterSet[0]));
    }

    /**
     * 
     * @param name
     * @param clazz
     * @param exeName
     * @param taskGenerator
     * @param paramSets
     * @return
     */
    private PipelineDefinitionNode createNode(String name, Class<? extends PipelineModule> clazz, String exeName,
        UnitOfWorkTaskGenerator taskGenerator, ParameterSet... paramSets) {
        PipelineModuleDefinition moduleDef = createModule(name, clazz, exeName);

        PipelineDefinitionNode node = addNode(moduleDef, taskGenerator);

        Map<ClassWrapper<Parameters>, ParameterSetName> paramSetNamesMap = new HashMap<ClassWrapper<Parameters>, ParameterSetName>();

        for (ParameterSet set : paramSets) {
            ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(set.parametersInstance()
                .getClass());
            paramSetNamesMap.put(classWrapper, set.getName());
        }

        moduleParameterSetNamesMap.put(node, paramSetNamesMap);

        return node;
    }

    /**
     * 
     * @param name
     * @param clazz
     * @param exeName
     * @param taskGenerator
     * @param paramSet
     * @return
     */
    public PipelineDefinitionNode addNode(String name, Class<? extends PipelineModule> clazz, String exeName,
        UnitOfWorkTaskGenerator taskGenerator, ParameterSet... paramSets) {

        return createNode(name, clazz, exeName, taskGenerator, paramSets);
    }

    /**
     * Add a node to the pipeline with the specified
     * {@link PipelineModuleDefinition} and no {@link UnitOfWorkTaskGenerator}.
     * This means that a simple transition will be used using the unit of work
     * from the previous node. Cannot be used for the first node in a pipeline.
     * 
     * TODO: verify that the previous node has the same UOW?
     * 
     * @param moduleDef
     * @return
     * @throws PipelineException
     */
    public PipelineDefinitionNode addNode(PipelineModuleDefinition moduleDef) {
        return addNode(moduleDef, null, new ParameterSet[0]);
    }

    /**
     * Add a node to the pipeline with the specified
     * {@link PipelineModuleDefinition} and {@link UnitOfWorkTaskGenerator}
     * 
     * @param moduleDef
     * @param taskGenerator
     * @return
     * @throws PipelineException
     */
    public PipelineDefinitionNode addNode(PipelineModuleDefinition moduleDef, ParameterSet... parameterSets) {
        return addNode(moduleDef, null, parameterSets);
    }

    /**
     * Add a node to the pipeline with the specified
     * {@link PipelineModuleDefinition} and {@link UnitOfWorkTaskGenerator}
     * 
     * @param moduleDef
     * @param taskGenerator
     * @return
     * @throws PipelineException
     * @deprecated Use varargs version instead
     */
    @Deprecated
    public PipelineDefinitionNode addNode(PipelineModuleDefinition moduleDef, UnitOfWorkTaskGenerator taskGenerator,
        List<ParameterSet> paramSets) {
        
        return addNode(moduleDef, taskGenerator, paramSets.toArray(new ParameterSet[0]));
    }

    /**
     * An alternate version of the above method that uses var args
     * 
     * @param moduleDef
     * @param taskGenerator
     * @param paramSets
     * @return
     */
    public PipelineDefinitionNode addNode(PipelineModuleDefinition moduleDef,
        UnitOfWorkTaskGenerator taskGenerator, ParameterSet... paramSets) {
        
        if (pipeline == null) {
            throw new IllegalStateException("Pipeline not initialized, call createPipeline() first");
        }

        PipelineDefinitionNode node = new PipelineDefinitionNode();
        node.setPipelineModuleDefinition(moduleDef);

        Map<ClassWrapper<Parameters>, ParameterSetName> paramSetNamesMap = new HashMap<ClassWrapper<Parameters>, ParameterSetName>();

        for (ParameterSet set : paramSets) {
            Class<? extends Parameters> paramClass = set.parametersInstance().getClass();
            
            ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(paramClass);
            paramSetNamesMap.put(classWrapper, set.getName());
        }

        moduleParameterSetNamesMap.put(node, paramSetNamesMap);

        if (taskGenerator != null) {
            node.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(taskGenerator));
            node.setStartNewUow(true);
        } else {
            node.setStartNewUow(false);
        }

        if (currentNode != null) {
            currentNode.getNextNodes().add(node);
        } else {
            // first node
            if (taskGenerator == null) {
                throw new IllegalStateException(
                    "UnitOfWorkTaskGenerator for the first node in a pipeline must not be null");
            }
            pipeline.getRootNodes().add(node);
        }

        currentNode = node;

        return node;
    }
    
    /**
     * Create a shared {@link PipelineModuleDefinition}
     * 
     * @param name
     * @param description
     * @param clazz
     * @return
     */
    public PipelineModuleDefinition createModule(String name, Class<? extends PipelineModule> clazz) {
        return createModule(name, clazz, null);
    }

    /**
     * Create a shared {@link PipelineModuleDefinition} with the specified
     * exeName and {@link Parameters} class names
     * 
     * @param name
     * @param description
     * @param clazz
     * @param exeName
     * @param paramClasses
     * @return
     */
    public PipelineModuleDefinition createModule(String name, Class<? extends PipelineModule> clazz, String exeName) {

        // delete any existing pipeline modules with this name
        List<PipelineModuleDefinition> existingModules = pipelineModuleDefinitionCrud.retrieveAllVersionsForName(name);
        for (PipelineModuleDefinition existingModule : existingModules) {
            log.info("deleting existing pipeline module def: " + existingModule);
            pipelineModuleDefinitionCrud.delete(existingModule);
        }

        PipelineModuleDefinition moduleDef = new PipelineModuleDefinition(name);
        moduleDef.setImplementingClass(new ClassWrapper<PipelineModule>(clazz));
        moduleDef.setExeName(exeName);
        moduleDef.setExeTimeoutSecs(exeTimeout);

        pipelineModuleDefinitionCrud.create(moduleDef);

        return moduleDef;
    }

    /**
     * Create a shared {@link ParameterSet}
     * 
     * @param name
     * @param description
     * @param params
     * @return
     * @throws PipelineException
     */
    public ParameterSet createParamSet(String name, Parameters params) {
        // delete any existing PipelineModuleParameterSets
        List<ParameterSet> existingParamSets = parameterSetCrud.retrieveAllVersionsForName(name);
        for (ParameterSet set : existingParamSets) {
            log.info("deleting existing pipeline module param set: " + set);
            parameterSetCrud.delete(set);
        }

        ParameterSet paramSet = new ParameterSet(name);
        paramSet.setDescription("Created by PipelineConfigurator");

        paramSet.setParameters(new BeanWrapper<Parameters>(params));

        parameterSetCrud.create(paramSet);

        return paramSet;
    }

    /**
     * Create a {@link TriggerDefinition} for the current pipeline definition
     * with no {@link Parameters}
     * 
     * @param name
     * @return
     * @throws PipelineException
     */
    public TriggerDefinition createTrigger(String name) {
        if (pipeline == null) {
            throw new IllegalStateException("Pipeline not initialized, call createPipeline() first");
        }

        TriggerDefinition trigger = null;

        // delete any existing trigger
        trigger = triggerDefinitionCrud.retrieve(name);
        if (trigger != null) {
            log.info("deleting existing trigger def: " + trigger);
            triggerDefinitionCrud.delete(trigger);
        }

        PipelineOperations pipelineOps = new PipelineOperations();
        trigger = pipelineOps.createTrigger(name, pipeline);

        trigger.setPipelineParameterSetNames(pipelineParameterSetNamesMap);
        pipelineParameterSetNamesMap = new HashMap<ClassWrapper<Parameters>, ParameterSetName>();

        /* Copy the ParameterSetNames from the moduleParameterSetNamesMap to the
         * corresponding TriggerDefinitionNode */
        List<TriggerDefinitionNode> triggerNodes = trigger.getNodes();
        for (TriggerDefinitionNode triggerNode : triggerNodes) {
            PipelineDefinitionNodePath path = triggerNode.getPipelineDefinitionNodePath();
            PipelineDefinitionNode pipelineNode = path.definitionNodeAt(pipeline);
            Map<ClassWrapper<Parameters>, ParameterSetName> paramsForNode = moduleParameterSetNamesMap.get(pipelineNode);
            if (paramsForNode != null) {
                triggerNode.setModuleParameterSetNames(paramsForNode);
            }
        }

        moduleParameterSetNamesMap = new HashMap<PipelineDefinitionNode, Map<ClassWrapper<Parameters>, ParameterSetName>>();

        triggerDefinitionCrud.create(trigger);

        return trigger;
    }

    /**
     * Set the param set names to be used for the next trigger
     * 
     * @param pipelineParams
     */
    public void setPipelineParamNames(Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParams) {
        pipelineParameterSetNamesMap = pipelineParams;
    }

    public void setModuleParamNames(PipelineDefinitionNode node,
        Map<ClassWrapper<Parameters>, ParameterSetName> moduleParams) {
        moduleParameterSetNamesMap.put(node, moduleParams);
    }

    public void addModuleParamNames(PipelineDefinitionNode node, ParameterSet parameterSet) {
        Map<ClassWrapper<Parameters>, ParameterSetName> moduleParamsForNode = moduleParameterSetNamesMap.get(node);
        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(parameterSet.parametersInstance()
            .getClass());
        moduleParamsForNode.put(classWrapper, parameterSet.getName());
    }

    /**
     * Persist the current pipeline definition and reset for the next pipeline
     * definition.
     * 
     * @throws PipelineException
     */
    public void finalizePipeline() {
        if (pipeline == null) {
            throw new IllegalStateException("Pipeline not initialized, call createPipeline() first");
        }

        if (currentNode == null) {
            throw new IllegalStateException("Pipeline has no nodes, call addNode() at least once");
        }

        pipelineDefinitionCrud.create(pipeline);

        pipeline = null;
        currentNode = null;
    }

    /**
     * @return the exeTimeout
     */
    public int getExeTimeout() {
        return exeTimeout;
    }

    /**
     * @param exeTimeout the exeTimeout to set
     */
    public void setExeTimeout(int exeTimeout) {
        this.exeTimeout = exeTimeout;
    }
}
