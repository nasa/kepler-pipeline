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

package gov.nasa.kepler.ui.proxy;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.pi.pipeline.TriggerValidationResults;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.models.DatabaseModelRegistry;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Set;
import java.util.concurrent.Callable;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class PipelineOperationsProxy extends CrudProxy {
    private static final Log log = LogFactory.getLog(PipelineOperationsProxy.class);

    /**
     * @param databaseService
     */
    public PipelineOperationsProxy() {
    }

    public TriggerDefinition createTrigger(final String triggerName, final PipelineDefinition pipelineDefinition){
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        TriggerDefinition result = (TriggerDefinition) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<TriggerDefinition>(){
            public TriggerDefinition call() {

                PipelineOperations pipelineOps = new PipelineOperations();
                TriggerDefinition newTrigger = pipelineOps.createTrigger(triggerName, pipelineDefinition);

                return newTrigger;
            }
        });
        return result;
    }

    public ParameterSet retrieveLatestParameterSet(final ParameterSetName parameterSetName){
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        ParameterSet result = (ParameterSet) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<ParameterSet>(){
            public ParameterSet call() {

                PipelineOperations pipelineOps = new PipelineOperations();
                ParameterSet paramSet = pipelineOps.retrieveLatestParameterSet(parameterSetName);

                return paramSet;
            }
        });
        return result;
    }
    
    /**
     * Returns a {@link Set<ClassWrapper<Parameters>>} containing all {@link Parameters} classes
     * required by the specified node.  This is a union of the Parameters classes required by the
     * PipelineModule itself and the Parameters classes required by the UnitOfWorkTaskGenerator
     * associated with the node.
     *  
     * @param trigger
     * @param triggerNode
     * @return
     */
    public Set<ClassWrapper<Parameters>> retrieveRequiredParameterClassesForNode(final TriggerDefinition trigger,
        final TriggerDefinitionNode triggerNode) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        Set<ClassWrapper<Parameters>> result = (Set<ClassWrapper<Parameters>>) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<Set<ClassWrapper<Parameters>>>(){
            public Set<ClassWrapper<Parameters>> call() {

                PipelineOperations pipelineOps = new PipelineOperations();
                Set<ClassWrapper<Parameters>> requiredParams = pipelineOps.retrieveRequiredParameterClassesForNode(trigger, triggerNode);

                return requiredParams;
            }
        });
        return result;
    }
    
    /**
     * 
     * @param instance
     * @return
     */
    public String generatePedigreeReport(final PipelineInstance instance){
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        String result = (String) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<String>(){
            public String call() {

                PipelineOperations pipelineOps = new PipelineOperations();
                String report = pipelineOps.generatePedigreeReport(instance);

                return report;
            }
        });
        return result;
    }
    
    /**
     * 
     * @param triggerDefinition
     * @param destinationDirectory
     */
    public void exportTriggerParams(final TriggerDefinition triggerDefinition, final File destinationDirectory){
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<Object>(){
            public Object call() throws PipelineException{

                PipelineOperations pipelineOps = new PipelineOperations();
                pipelineOps.exportTriggerParams(triggerDefinition, destinationDirectory);

                return null;
            }
        });
    }
    
    /**
     * 
     * @param triggerDefinition
     * @return
     */
    public String generateTriggerReport(final TriggerDefinition triggerDefinition){
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        String result = (String) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<String>(){
            public String call() {

                PipelineOperations pipelineOps = new PipelineOperations();
                String report = pipelineOps.generateTriggerReport(triggerDefinition);

                return report;
            }
        });
        return result;
    }
    
    /**
     * Creates a textual report of all ParameterSets in the Parameter Library,
     * including name, type, keys & values.
     * 
     * @param csvMode
     * @return
     */
    public String generateParameterLibraryReport(final boolean csvMode){
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        String result = (String) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<String>(){
            public String call() {

                PipelineOperations pipelineOps = new PipelineOperations();
                String report = pipelineOps.generateParameterLibraryReport(csvMode);

                return report;
            }
        });
        return result;
    }
    
    public ParameterSet updateParameterSet(final ParameterSet parameterSet, final Parameters newParameters, final boolean forceSave){
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        ParameterSet result = (ParameterSet) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<ParameterSet>(){
            public ParameterSet call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();

                databaseService.beginTransaction();

                PipelineOperations pipelineOps = new PipelineOperations();
                ParameterSet updatedParamSet = pipelineOps.updateParameterSet(parameterSet, newParameters, forceSave);

                // need a flush here since we have auto-flush turned off
                databaseService.flush();
                databaseService.commitTransaction();
                
                return updatedParamSet;
            }
        });
        return result;
    }
    
    public ParameterSet updateParameterSet(final ParameterSet parameterSet, final Parameters newParameters, final String newDescription, final boolean forceSave){
        verifyPrivileges(Privilege.PIPELINE_CONFIG);
        ParameterSet result = (ParameterSet) PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<ParameterSet>(){
            public ParameterSet call() {
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();

                databaseService.beginTransaction();

                PipelineOperations pipelineOps = new PipelineOperations();
                ParameterSet updatedParamSet = pipelineOps.updateParameterSet(parameterSet, newParameters, newDescription, forceSave);

                // need a flush here since we have auto-flush turned off
                databaseService.flush();
                databaseService.commitTransaction();
                
                return updatedParamSet;
            }
        });
        return result;
    }
    
    /**
     * @param trigger
     * @throws Exception 
     */
    public void fireTrigger(final String triggerName, final String instanceName) throws Exception {
        verifyPrivileges(Privilege.PIPELINE_OPERATIONS);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<Object>(){
            public Object call() throws PipelineException{
                
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();
                
                /* clear the current session before launching the pipeline
                 * to protect against stale objects in the Hibernate cache */
                databaseService.clear();
                
                MessagingServiceFactory.setUseXa(false);
                DatabaseServiceFactory.setUseXa(false);
                
                TransactionService transactionService = TransactionServiceFactory.getInstance(false);
                
                transactionService.beginTransaction(true, true, false);
                
                try {
                    TriggerDefinitionCrud triggerCrud = new TriggerDefinitionCrud();
                    TriggerDefinition trigger = triggerCrud.retrieve(triggerName);
                    
                    PipelineOperations pipelineOps = new PipelineOperations();
                    pipelineOps.fireTrigger(trigger, instanceName);
                    
                    // need a flush here since we have auto-flush turned off
                    databaseService.flush();
                    
                    transactionService.commitTransaction();
                } catch (Exception e) {
                    log.error("TriggerDefinitionCrudProxy failed", e);
                    transactionService.rollbackTransactionIfActive();
                    throw new PipelineException(e.getMessage(), e.getCause());
                }                
                
                return null;
            }
        });
        // invalidate the models since firing a trigger can change the locked state of versioned database objects
        DatabaseModelRegistry.invalidateModels();
    }

    /**
     * 
     * @param triggerName
     * @param instanceName
     * @param startNode
     * @param endNode
     * @throws Exception
     */
    public void fireTrigger(final String triggerName, final String instanceName,
        final PipelineDefinitionNode startNode, final PipelineDefinitionNode endNode) throws Exception{
        verifyPrivileges(Privilege.PIPELINE_OPERATIONS);
        PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<Object>(){
            public Object call() throws PipelineException{
                
                DatabaseService databaseService = DatabaseServiceFactory.getInstance();

                /* clear the current session before launching the pipeline
                 * to protect against stale objects in the Hibernate cache */
                databaseService.clear();

                MessagingServiceFactory.setUseXa(false);
                DatabaseServiceFactory.setUseXa(false);
                
                TransactionService transactionService = TransactionServiceFactory.getInstance(false);
                
                transactionService.beginTransaction(true, true, false);
                
                try {
                    TriggerDefinitionCrud triggerCrud = new TriggerDefinitionCrud();
                    TriggerDefinition trigger = triggerCrud.retrieve(triggerName);
                    
                    PipelineOperations pipelineOps = new PipelineOperations();
                    pipelineOps.fireTrigger(trigger, instanceName, startNode, endNode);
                    
                    // need a flush here since we have auto-flush turned off
                    databaseService.flush();
                    
                    transactionService.commitTransaction();
                } catch (Exception e) {
                    log.error("TriggerDefinitionCrudProxy failed", e);
                    transactionService.rollbackTransactionIfActive();
                    throw new PipelineException(e.getMessage(), e.getCause());
                }                
                
                return null;
            }
        });
        // invalidate the models since firing a trigger can change the locked state of versioned database objects
        DatabaseModelRegistry.invalidateModels();
    }
    
    /**
     * Validates that this {@link TriggerDefinition} is valid for firing. Checks
     * that the associated pipeline definition objects have not changed in an
     * incompatible way and that all {@link ParameterSetName}s are set.
     * 
     */
    public TriggerValidationResults validateTrigger(final TriggerDefinition triggerDefinition) {
        verifyPrivileges(Privilege.PIPELINE_MONITOR);
        TriggerValidationResults result = PipelineConsole.crudProxyExecutor.executeSynchronous(new Callable<TriggerValidationResults>(){
            public TriggerValidationResults call() throws PipelineException{
                
                PipelineOperations pipelineOps = new PipelineOperations();
                return pipelineOps.validateTrigger(triggerDefinition);
            }
        });
        return result;
    }    
}
