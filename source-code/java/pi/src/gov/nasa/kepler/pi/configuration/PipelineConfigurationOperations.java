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

package gov.nasa.kepler.pi.configuration;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.KeplerHibernateConfiguration;
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
import gov.nasa.kepler.pi.parameters.ParametersOperations;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Contains methods for importing and exporting pipeline configurations.
 * 
 * For export, a List<TriggerDefinition> is specified.  All of the trigger data
 * is exported, as well as the pipeline and module definitions referenced by the 
 * triggers.  The XML file references parameter sets by name, but does NOT contain the
 * contents of the parameter sets themselves.  The parameter library import/export is 
 * in a separate XML file (see {@link ParametersOperations}
 * 
 * When importing, the imported elements are compared to any existing elements with the same
 * names.  If the existing elements are different, then they are updated to match the imported
 * elements.  A 'dry run' report mode is available that indicates what elements would be changed with
 * an import.  This report also acts as a 'diff' between two environments/clusters.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class PipelineConfigurationOperations {
    private static final Log log = LogFactory.getLog(PipelineConfigurationOperations.class);

    private Map<PipelineDefinitionNode,Integer> pipelineNodeToIdMap = new HashMap<PipelineDefinitionNode, Integer>();
    private Map<Integer,PipelineDefinitionNode> pipelineIdToNodeMap = new HashMap<Integer,PipelineDefinitionNode>();
    private int nextPipelineNodeId = 1;
    
    /**
     * Export the specified triggers and all pipeline and module definitions referenced by those
     * triggers to the specified file.
     * 
     * @param triggers
     * @param destinationPath
     * @throws IOException
     */
    public void exportPipelineConfiguration(List<TriggerDefinition> triggers, String destinationPath) throws IOException {
        File destinationFile = new File(destinationPath);
        if (destinationFile.exists() && destinationFile.isDirectory()) {
            throw new IllegalArgumentException("destinationPath exists and is a directory: " + destinationFile);
        }

        log.info("Exporting " + triggers.size() + " triggers to: " + destinationFile);

        PipelineConfigurationDocument doc = PipelineConfigurationDocument.Factory.newInstance();
        PipelineConfigurationXB configXmlBean = doc.addNewPipelineConfiguration();

        Configuration configSvc = ConfigurationServiceFactory.getInstance();
        configXmlBean.setDatabaseUrl(configSvc.getString(
            KeplerHibernateConfiguration.HIBERNATE_CONNECTION_URL_PROP, "unknown"));
        configXmlBean.setDatabaseUser(configSvc.getString(
            KeplerHibernateConfiguration.HIBERNATE_CONNECTION_USERNAME_PROP, "unknown"));
        
        exportInternal(triggers, configXmlBean);
        
        XmlOptions xmlOptions = new XmlOptions().setSavePrettyPrint()
            .setSavePrettyPrintIndent(2);
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new PipelineException("Export Pipeline Configuration failed: XML validation errors: " + errors);
        }

        doc.save(destinationFile, xmlOptions);
    }

    /**
     * Generates the content for the XML document.
     * 
     * @param triggers
     * @param configXmlBean
     */
    private void exportInternal(List<TriggerDefinition> triggers, PipelineConfigurationXB configXmlBean) {
        TriggerListXB triggerList = configXmlBean.addNewTriggers();
        List<String> pipelineNames = new LinkedList<String>();
        List<String> moduleNames = new LinkedList<String>();

        for (TriggerDefinition trigger : triggers) {
            TriggerXB triggerXmlBean = triggerList.addNewTrigger();
            triggerXmlBean.setName(trigger.getName());
            triggerXmlBean.setInstancePriority(trigger.getInstancePriority());
            String pipelineName = trigger.getPipelineDefinitionName().getName();
            triggerXmlBean.setPipelineName(pipelineName);
            if(!pipelineNames.contains(pipelineName)){
                pipelineNames.add(pipelineName);
            }
            
            // parameters set at the pipeline level
            Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParamNames = trigger.getPipelineParameterSetNames();
            for (ClassWrapper<Parameters> paramClass : pipelineParamNames.keySet()) {
                ParameterSetName paramName = pipelineParamNames.get(paramClass);
                ParameterReferenceXB paramRef = triggerXmlBean.addNewPipelineParameter();
                paramRef.setName(paramName.getName());
                paramRef.setClassname(paramClass.getClassName());
            }
            
            List<TriggerDefinitionNode> nodes = trigger.getNodes();
            for (TriggerDefinitionNode node : nodes) {
                TriggerNodeXB nodeXml = triggerXmlBean.addNewNode();
                String nodeModuleName = node.getNodeModuleName().getName();
                nodeXml.setModuleName(nodeModuleName);
                if(!moduleNames.contains(nodeModuleName)){
                    moduleNames.add(nodeModuleName);
                }
                nodeXml.setNodePath(node.getPipelineDefinitionNodePath().toString());
                
                // parameters set at the module level
                Map<ClassWrapper<Parameters>, ParameterSetName> moduleParamNames = node.getModuleParameterSetNames();
                for (ClassWrapper<Parameters> paramClass : moduleParamNames.keySet()) {
                    ParameterSetName paramName = moduleParamNames.get(paramClass);
                    ParameterReferenceXB paramRef = nodeXml.addNewModuleParameter();
                    paramRef.setName(paramName.getName());
                    paramRef.setClassname(paramClass.getClassName());
                }
            }
        }
        
        Collections.sort(pipelineNames);
        
        PipelineListXB pipelineList = configXmlBean.addNewPipelines();
        PipelineDefinitionCrud pipelineCrud = new PipelineDefinitionCrud();
        for (String pipelineName : pipelineNames) {
            PipelineDefinition pipelineDef = pipelineCrud.retrieveLatestVersionForName(pipelineName);
            PipelineXB pipelineXml = pipelineList.addNewPipeline();
            pipelineXml.setName(pipelineDef.getName().getName());
            pipelineXml.setDescription(pipelineDef.getDescription());

            exportPipelineNodes(pipelineXml, pipelineDef.getRootNodes()/*, moduleNames*/);
            
            pipelineXml.setRootNodeIds(stringifyNodeList(pipelineDef.getRootNodes()));
        }        
        
        ModuleListXB moduleList = configXmlBean.addNewModules();
        
        Collections.sort(moduleNames);
        
        exportModules(moduleList, moduleNames);
    }
    
    private String stringifyNodeList(List<PipelineDefinitionNode> nodes){
        StringBuilder sb = new StringBuilder();
        boolean first = true;
        for (PipelineDefinitionNode node : nodes) {
            if(!first){
                sb.append(",");
            }
            sb.append(pipelineNodeToIdMap.get(node));
            first = false;
        }
        return sb.toString();
    }
    
    /**
     * Recursive function that stores the specified nodes and their children.
     * 
     * @param pipelineXml
     * @param nodes
     */
    private void exportPipelineNodes(PipelineXB pipelineXml, List<PipelineDefinitionNode> nodes/*, List<String> moduleNames */){

        for (PipelineDefinitionNode node : nodes) {
            int id = nextPipelineNodeId++;
            pipelineNodeToIdMap.put(node, id);
            pipelineIdToNodeMap.put(id, node);
            
            PipelineNodeXB nodeXml = pipelineXml.addNewNode();
            String moduleName = node.getModuleName().getName();
            nodeXml.setModuleName(moduleName);
            nodeXml.setStartNewUow(node.isStartNewUow());
            ClassWrapper<UnitOfWorkTaskGenerator> uowTg = node.getUnitOfWork();
            if(uowTg != null){
                nodeXml.setUowGeneratorClass(uowTg.getClassName());
            }
            nodeXml.setNodeId(id);
            
            exportPipelineNodes(pipelineXml, node.getNextNodes()/*, moduleNames*/);
            
            nodeXml.setChildNodeIds(stringifyNodeList(node.getNextNodes()));
        }
    }

    /**
     * Stores the module definitions
     * 
     * @param moduleList
     */
    private void exportModules(ModuleListXB moduleList, List<String> moduleNames) {
        PipelineModuleDefinitionCrud crud = new PipelineModuleDefinitionCrud();
        
        for (String moduleName : moduleNames) {
            PipelineModuleDefinition module = crud.retrieveLatestVersionForName(moduleName);
            ModuleXB moduleXml = moduleList.addNewModule();
            moduleXml.setName(moduleName);
            moduleXml.setDescription(module.getDescription());
            moduleXml.setExeName(module.getExeName());
            moduleXml.setExeTimeoutSecs(module.getExeTimeoutSecs());
            moduleXml.setMinMemoryMegaBytes(module.getMinMemoryMegaBytes());
            moduleXml.setImplementingClass(module.getImplementingClass().getClassName());
        }
    }

    /**
     * Imports the triggers and pipeline and module definitions found in the
     * specified file or directory. Directories are recursed in-order.
     * 
     * @param sourceFile the file or directory to import
     * @throws Exception if there were problems reading the configuration files
     */
    public void importPipelineConfiguration(File sourceFile) throws Exception {
        if (sourceFile.isDirectory()) {
            // Load all of the .xml files in the directory in lexicographic
            // order. Recurse directories in-order.
            File[] files = sourceFile.listFiles(new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return name.endsWith(".xml")
                        || new File(dir, name).isDirectory();
                }
            });
            Arrays.sort(files);
            for (File file : files) {
                if (file.isDirectory()) {
                    importPipelineConfiguration(file);
                } else {
                    importPipelineConfiguration(file.getAbsolutePath());
                }
            }
        } else {
            importPipelineConfiguration(sourceFile.getAbsolutePath());
        }
    }
    
    public void importPipelineConfiguration(String sourcePath) throws Exception  {
        File sourceFile = new File(sourcePath);
        if (!sourceFile.exists() || sourceFile.isDirectory()) {
            throw new IllegalArgumentException("sourcePath does not exist or is a directory: " + sourceFile);
        }

        log.info("Importing pipeline configuration from: " + sourceFile);
        
        PipelineConfigurationDocument pipelineConfigDocument = PipelineConfigurationDocument.Factory.parse(sourceFile);
        PipelineConfigurationXB pipelineConfigXmlBean = pipelineConfigDocument.getPipelineConfiguration();
        
        log.info("Importing Module Definitions");
        importModules(pipelineConfigXmlBean.getModules().getModuleArray());
        log.info("Importing Pipeline Definitions");
        importPipelines(pipelineConfigXmlBean.getPipelines().getPipelineArray());
        log.info("Importing Trigger Definitions");
        importTriggers(pipelineConfigXmlBean.getTriggers().getTriggerArray());

        log.info("DONE importing pipeline configuration from: " + sourceFile);
    }
    
    private void importModules(ModuleXB[] xmlModuleList){
        PipelineModuleDefinitionCrud moduleCrud = new PipelineModuleDefinitionCrud();
        List<PipelineModuleDefinition> existingModules = moduleCrud.retrieveLatestVersions();
        Set<String> existingModuleNames = new HashSet<String>();
        
        for (PipelineModuleDefinition existingModule : existingModules) {
            existingModuleNames.add(existingModule.getName().getName());
        }
        
        for (ModuleXB xmlModule : xmlModuleList) {
            if(existingModuleNames.contains(xmlModule.getName())){
                throw new PipelineException("Module library already contains a module with name: " + xmlModule.getName());
                // TODO: implement merging here!
            }

            log.info("Adding new module to module library: " + xmlModule.getName());

            PipelineModuleDefinition newModule = new PipelineModuleDefinition(xmlModule.getName());
            newModule.setDescription(xmlModule.getDescription());
            newModule.setExeName(xmlModule.getExeName());
            newModule.setExeTimeoutSecs(xmlModule.getExeTimeoutSecs());
            newModule.setMinMemoryMegaBytes(xmlModule.getMinMemoryMegaBytes());

            newModule.setImplementingClass(wrapClass(xmlModule.getImplementingClass(), PipelineModule.class));

            moduleCrud.create(newModule);
        }
    }

    /**
     * Verify that the class specified with className extends the specified Class<T> type
     * and return the ClassWrapper object for this class in a type-safe manner.
     * 
     * @param <T>
     * @param className
     * @param type
     * @return
     */
    private <T> ClassWrapper<T> wrapClass(String className, Class<T> type){
        return new ClassWrapper<T>(createClass(className, type));
    }
    
    private <T> Class<? extends T> createClass(String className, Class<T> type){
        Class<?> clazz;
        try {
            clazz = Class.forName(className);
        } catch (ClassNotFoundException e) {
            throw new PipelineException("Specified class does not exist: " + className, e);
        }
        if(type.isAssignableFrom(clazz)){
            @SuppressWarnings("unchecked")
            Class<? extends T> verifiedClass = (Class<? extends T>) clazz;
            return (Class<? extends T>) verifiedClass;
        }else{
            throw new PipelineException("Specified class does not extend from "+type.getName()+", className: " + className);
        }
    }

    
    private void importPipelines(PipelineXB[] xmlPipelineList) {
        PipelineDefinitionCrud pipelineCrud = new PipelineDefinitionCrud();
        List<PipelineDefinition> existingPipelines = pipelineCrud.retrieveLatestVersions();
        Set<String> existingPipelineNames = new HashSet<String>();
        
        for (PipelineDefinition existingPipeline : existingPipelines) {
            existingPipelineNames.add(existingPipeline.getName().getName());
        }
        
        for (PipelineXB xmlPipeline : xmlPipelineList) {
            if(existingPipelineNames.contains(xmlPipeline.getName())){
                throw new PipelineException("Pipeline library already contains a pipeline with name: " + xmlPipeline.getName());
                // TODO: implement merging here!
            }
            
            log.info("Adding new pipeline to pipeline library: " + xmlPipeline.getName());
            
            PipelineDefinition newPipeline = new PipelineDefinition(xmlPipeline.getName());
            newPipeline.setDescription(xmlPipeline.getDescription());
            
            PipelineNodeXB[] xmlNodes = xmlPipeline.getNodeArray();
            Map<Integer,PipelineNodeXB> xmlNodesById = new HashMap<Integer,PipelineNodeXB>();
            
            for (PipelineNodeXB xmlNode : xmlNodes) {
                xmlNodesById.put(xmlNode.getNodeId(), xmlNode);
            }
            
            List<Integer> rootNodeIds = splitList(xmlPipeline.getRootNodeIds());
            addNodes(newPipeline.getName()
                .getName(), rootNodeIds, newPipeline.getRootNodes(),
                xmlNodesById);
            
            pipelineCrud.create(newPipeline);
        }
    }

    private List<Integer> splitList(String nodeIdList){
        List<Integer> ids = new ArrayList<Integer>();
        String[] stringIds = nodeIdList.split(",");
        for (int i = 0; i < stringIds.length; i++) {
            ids.add(Integer.parseInt(stringIds[i]));
        }
        return ids;
    }

    private void addNodes(String pipelineName, List<Integer> nodeIds, List<PipelineDefinitionNode> parentContainer, Map<Integer,PipelineNodeXB> xmlNodesById){
        PipelineModuleDefinitionCrud moduleCrud = new PipelineModuleDefinitionCrud();
        
        for (int nodeId : nodeIds) {
            PipelineNodeXB xmlNode = xmlNodesById.get(nodeId);
            if (xmlNode == null) {
                throw new PipelineException("No node found for root node ID "
                    + nodeId + " in pipeline " + pipelineName);
            }
            PipelineModuleDefinition module = moduleCrud.retrieveLatestVersionForName(xmlNode.getModuleName());
            if (module == null) {
                throw new PipelineException("No module found for node "
                    + xmlNode.getModuleName() + " in pipeline " + pipelineName);
            }
            
            PipelineDefinitionNode newNode = new PipelineDefinitionNode(module.getName());
            newNode.setStartNewUow(xmlNode.getStartNewUow());

            if(xmlNode.isSetUowGeneratorClass()){
                String uowGeneratorClass = xmlNode.getUowGeneratorClass();
                if(!uowGeneratorClass.isEmpty()){
                    newNode.setUnitOfWork(wrapClass(uowGeneratorClass, UnitOfWorkTaskGenerator.class));
                }
            }
            
            parentContainer.add(newNode);
            
            String childNodeIds = xmlNode.getChildNodeIds();
            
            if(!childNodeIds.isEmpty()){
                addNodes(pipelineName, splitList(childNodeIds),
                    newNode.getNextNodes(), xmlNodesById);
            }
        }
    }
    
    private void importTriggers(TriggerXB[] xmlTriggerList) {
        PipelineDefinitionCrud pipelineCrud = new PipelineDefinitionCrud();
        ParameterSetCrud paramCrud = new ParameterSetCrud();
        TriggerDefinitionCrud triggerCrud = new TriggerDefinitionCrud();
        PipelineOperations pipelineOperations = new PipelineOperations();
        
        List<TriggerDefinition> existingTriggers = triggerCrud.retrieveAll();

        Set<String> existingTriggerNames = new HashSet<String>();
        
        for (TriggerDefinition existingTrigger : existingTriggers) {
            existingTriggerNames.add(existingTrigger.getName());
        }
        
        for (TriggerXB xmlTrigger : xmlTriggerList) {
            if(existingTriggerNames.contains(xmlTrigger.getName())){
                throw new PipelineException("Trigger library already contains a trigger with name: " + xmlTrigger.getName());
                // TODO: implement merging here!
            }
            
            log.info("Adding new trigger to trigger library: " + xmlTrigger.getName());

            PipelineDefinition pipelineDef = pipelineCrud.retrieveLatestVersionForName(xmlTrigger.getPipelineName());
            TriggerDefinition newTrigger = pipelineOperations.createTrigger(xmlTrigger.getName(), pipelineDef);
            newTrigger.setInstancePriority(xmlTrigger.getInstancePriority());
            
            // pipeline-level parameters
            ParameterReferenceXB[] xmlPipelineParams = xmlTrigger.getPipelineParameterArray();
            
            for (ParameterReferenceXB xmlPipelineParam : xmlPipelineParams) {
                String xmlParamName = xmlPipelineParam.getName();
                String xmlParamClassName = xmlPipelineParam.getClassname();
                Class<? extends Parameters> xmlParamClass = createClass(xmlParamClassName, Parameters.class);
                ParameterSet parameterSet = paramCrud.retrieveLatestVersionForName(xmlParamName);
                
                if(parameterSet != null){
                    Class<?> libraryParamClass = parameterSet.getParameters().getClazz();
                    if(!xmlParamClass.equals(libraryParamClass)){
                        throw new PipelineException("Parameter class for " + xmlParamName + " (" + xmlParamClass.getName() 
                            + ") does not match library class (" + libraryParamClass.getName());
                    }
                    
                    newTrigger.addPipelineParameterSetName(xmlParamClass, parameterSet);
                }else{
                    throw new PipelineException("No parameter set found for name: " + xmlParamName);
                }
            }
            
            // module-level parameters
            TriggerNodeXB[] xmlNodes = xmlTrigger.getNodeArray();
            
            for (TriggerNodeXB xmlNode : xmlNodes) {
                List<Integer> splitNodePath = splitList(xmlNode.getNodePath());
                PipelineDefinitionNodePath nodePath = new PipelineDefinitionNodePath(splitNodePath);
                TriggerDefinitionNode triggerNode = newTrigger.findNodeForPath(nodePath);
                
                // verify
                String xmlModuleName = xmlNode.getModuleName();
                String triggerNodeModuleName = triggerNode.getNodeModuleName().getName();
                if(!xmlModuleName.equals(triggerNodeModuleName)){
                    throw new PipelineException("module name in XML (" + xmlModuleName 
                        + ") does not match module name in pipeline def (" + triggerNodeModuleName + ")");
                }
                
                ParameterReferenceXB[] xmlModuleParams = xmlNode.getModuleParameterArray();
                
                for (ParameterReferenceXB xmlModuleParam : xmlModuleParams) {
                    String xmlParamName = xmlModuleParam.getName();
                    String xmlParamClassName = xmlModuleParam.getClassname();
                    Class<? extends Parameters> xmlParamClass = createClass(xmlParamClassName, Parameters.class);
                    ParameterSet parameterSet = paramCrud.retrieveLatestVersionForName(xmlParamName);
                    
                    Class<?> libraryParamClass = parameterSet.getParameters().getClazz();
                    if(!xmlParamClass.equals(libraryParamClass)){
                        throw new PipelineException("Parameter class for " + xmlParamName + " (" + xmlParamClass.getName() 
                            + ") does not match library class (" + libraryParamClass.getName());
                    }
                    
                    triggerNode.putModuleParameterSetName(xmlParamClass, parameterSet.getName());
                }
            }
            triggerCrud.create(newTrigger);
            
            pipelineOperations.validateTrigger(newTrigger);
        }
    }
}
