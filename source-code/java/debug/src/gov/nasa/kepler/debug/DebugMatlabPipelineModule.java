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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.debug.uow.DebugMatlabPipelineParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.hibernate.debug.DebugMetadata;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.DebugFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Sample/Debug pipeline module. Used for testing interaction with matlab (via
 * the matlab debug module), the database ({@link DebugMetadata}), and the
 * filestore {@link DebugFsIdFactory})
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class DebugMatlabPipelineModule extends MatlabPipelineModule implements AsyncPipelineModule{
    public static final String MODULE_NAME = "debug-matlab";

    private static final Log log = LogFactory.getLog(DebugMatlabPipelineModule.class);

    public DebugMatlabPipelineModule() {
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        
        List<Class<? extends Parameters>> requiredParams = new LinkedList<Class<? extends Parameters>>();
        requiredParams.add(DebugMatlabPipelineParameters.class);
        requiredParams.add(DebugModuleParams.class);
        
        return requiredParams;
    }

    @Override
    public void generateInputs(InputsHandler sequence, PipelineTask pipelineTask, File workingDirectory) throws PipelineException {         
        log.info("Generating inputs");
        
        PipelineInstance pipelineInstance = pipelineTask.getPipelineInstance();
        
        log.info("[" + getModuleName() + "]instance id = " + pipelineInstance.getId());
        log.info("[" + getModuleName() + "]instance node id = " + pipelineTask.getId());
        log.info("[" + getModuleName() + "]instance node uow = " + pipelineTask.getUowTask());

        ModOutCadenceUowTask uow = pipelineTask.uowTaskInstance();
        DebugMatlabPipelineParameters pipelineParameters = 
            (DebugMatlabPipelineParameters) pipelineTask.getParameters(DebugMatlabPipelineParameters.class);

        log.info("startCadence: " + uow.getStartCadence());
        log.info("endCadence: " + uow.getEndCadence());
        
        log.info("callMatlab: " + pipelineParameters.isCallMatlab());
        log.info("sleepTimeJavaSecs: " + pipelineParameters.getSleepTimeJavaSecs());

        log.info("channels.length: " + uow.getChannels().length);
        log.info("channels: " + uow.getChannels());

        int[] channels = uow.getChannels();
//        int numSubTasks = 0;
        
        for (int channelIndex = 0; channelIndex < channels.length; channelIndex++) {
            int channel = channels[channelIndex];
            Pair<Integer, Integer> ccdModOut = FcConstants.getModuleOutput(channel);
            
            log.info("channel: " + channel);
            log.info("  module: " + ccdModOut.left);
            log.info("  output: " + ccdModOut.right);
            
            DebugInputs inputs = new DebugInputs();        
            DebugModuleParams params = pipelineTask.getParameters(DebugModuleParams.class);
            
            inputs.setModuleParameters(params);
            inputs.setUseOldRaDec2Pix(pipelineParameters.isUseOldRaDec2Pix());
            inputs.setRa(290.0);
            inputs.setDec(45.0);
            inputs.setJulianDate(2455144);

            if(pipelineParameters.isCallMatlab()){
                RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
                RaDec2PixModel raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel(55100, 55200);
                inputs.setRaDec2PixModel(raDec2PixModel);
            }

            sequence.addSubTaskInputs(inputs);
//            numSubTasks ++;
        }
//        return InputsHandler.parallel(numSubTasks);
    }

    @Override
    public void processOutputs(PipelineTask pipelineTask, Iterator<AlgorithmResults> outputs) throws PipelineException {
        while(outputs.hasNext()) {
            log.info("Processing outputs");
            AlgorithmResults r = outputs.next();

            if (!r.successful()) {
                log.warn("Skipping failed sub-task due to MATLAB error for sub-task "
                    + r.getResultsDir());
                continue;
            }
            
            DebugOutputs o = (DebugOutputs) r.getOutputs();

            log.info("debugOutputs.[morc] = [" + o.getModule() + ":" + o.getOutput() + ":" + o.getRow() + ":" + o.getColumn());
            
            DebugModuleParams params = pipelineTask.getParameters(DebugModuleParams.class);
            DebugMatlabPipelineParameters pipelineParameters = 
                (DebugMatlabPipelineParameters) pipelineTask.getParameters(DebugMatlabPipelineParameters.class);
            
            if (params.isGenerateError()) {
                throw new ModuleFatalProcessingException("generateError == true");
            }

            int sleepTimeSecs = pipelineParameters.getSleepTimeJavaSecs();
            if (sleepTimeSecs > 0) {
                log.info("Sleeping for " + sleepTimeSecs + " secs.");
                try {
                    Thread.sleep(sleepTimeSecs * 1000);
                } catch (InterruptedException e) {
                    throw new PipelineException("caught InterruptedException");
                }
            } else {
                log.info("No sleep time (Java-side) specified");
            }
        }
    }

    @Override
    public Class<?> outputsClass(){
        return DebugOutputs.class;
    }

    protected void storeOutputs(PipelineTask pipelineTask, DebugOutputs debugOutputs){
    }
}
