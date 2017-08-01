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

package gov.nasa.kepler.debug;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.debug.DebugMetadata;
import gov.nasa.kepler.hibernate.debug.DebugMetadataCrud;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class DebugSingleTaskPipelineModule extends DebugPipelineModule {
    static final Log log = LogFactory.getLog(DebugSingleTaskPipelineModule.class);

    public static final String MODULE_NAME = "debug-single";

    public DebugSingleTaskPipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return SingleUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        
        List<Class<? extends Parameters>> requiredParams = new LinkedList<Class<? extends Parameters>>();
        requiredParams.add(DebugSimplePipelineParameters.class);
        
        return requiredParams;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) {

        // Store something in the db so we can test rollbacks, deadlocks, etc.
        DebugMetadataCrud debugMetadataCrud = new DebugMetadataCrud(DatabaseServiceFactory.getInstance());
        debugMetadataCrud.create(new DebugMetadata(getModuleName(), pipelineTask));
        
        AlertService alertsService = AlertServiceFactory.getInstance();
        alertsService.generateAlert("debug-single", pipelineTask.getId(), Severity.WARNING, "debug-single was here");
        
        DebugSimplePipelineParameters debugSimpleParams = (DebugSimplePipelineParameters) pipelineInstance.getPipelineParameters(DebugSimplePipelineParameters.class);
        
        if(debugSimpleParams.isFail()){
            throw new ModuleFatalProcessingException("Throwing exception because fail == true");
        }
        
        sleep(debugSimpleParams);
        
        if(debugSimpleParams.isLaunchAnotherInstance()){
            log.info("Launching a new instance of this pipeline because launchAnotherInstance == true");
            
            TriggerDefinitionCrud triggerCrud = new TriggerDefinitionCrud();
            ParameterSetCrud paramCrud = new ParameterSetCrud();
            PipelineOperations pipelineOps = new PipelineOperations();

            // update the parameters so that there will only be one rerun
            String triggerName = pipelineInstance.getTriggerName();
            
            log.info("Updating params for trigger: " + triggerName);
            
            TriggerDefinition trigger = triggerCrud.retrieve(triggerName);
            
            Map<ClassWrapper<Parameters>, ParameterSetName> triggerParams = trigger.getPipelineParameterSetNames();
            Set<ClassWrapper<Parameters>> triggerParamClasses = triggerParams.keySet();
            for (ClassWrapper<Parameters> paramClass : triggerParamClasses) {
                log.info("paramClass = " + paramClass.getClassName());
            }
            
            ParameterSetName simplePsName = trigger.getPipelineParameterSetName(DebugSimplePipelineParameters.class);
            ParameterSet simplePs = paramCrud.retrieveLatestVersionForName(simplePsName);
            DebugSimplePipelineParameters simpleParams = simplePs.parametersInstance();
            simpleParams.setLaunchAnotherInstance(false);
            pipelineOps.updateParameterSet(simplePs, simpleParams, false);
            
            // launch a new instance of this pipeline (debug simple)
            String instanceName = "rerun";
            log.info("firing trigger: " + triggerName + " with instanceName: " + instanceName);
            pipelineOps.fireTrigger(trigger, instanceName + " launching pipeline instance = " + pipelineInstance.getId());
        }else{
            log.info("Not launching a new instance of this pipeline because launchAnotherInstance == false");
        }
    }
}
