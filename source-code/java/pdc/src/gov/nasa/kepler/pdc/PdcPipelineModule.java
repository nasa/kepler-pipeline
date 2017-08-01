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

package gov.nasa.kepler.pdc;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.ModuleOutputListsParameters;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.DiscontinuityParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.PseudoTargetListParameters;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.Iterator;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is the Pre-Search Data Conditioning pipeline module. It uses relative
 * flux time series to create corrected flux time series.
 * 
 * @author jgunter
 * @author Forrest Girouard
 * @author Bill Wohler
 * @author Miles Cote
 */
public class PdcPipelineModule extends MatlabPipelineModule implements
    AsyncPipelineModule {

    private static final Log log = LogFactory.getLog(PdcPipelineModule.class);

    public static final String MODULE_NAME = "pdc";

    private final PdcInputsRetriever pdcInputsRetriever;
    private final PdcOutputsStorer pdcOutputsStorer;

    public PdcPipelineModule() {
        this(new PdcInputsRetriever(), new PdcOutputsStorer());
    }

    PdcPipelineModule(PdcInputsRetriever pdcInputsRetriever,
        PdcOutputsStorer pdcOutputsStorer) {
        this.pdcInputsRetriever = pdcInputsRetriever;
        this.pdcOutputsStorer = pdcOutputsStorer;
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
        List<Class<? extends Parameters>> requiredParams = newArrayList();
        requiredParams.add(AncillaryDesignMatrixParameters.class);
        requiredParams.add(AncillaryEngineeringParameters.class);
        requiredParams.add(AncillaryPipelineParameters.class);
        requiredParams.add(BandSplittingParameters.class);
        requiredParams.add(CadenceRangeParameters.class);
        requiredParams.add(CadenceTypePipelineParameters.class);
        requiredParams.add(CustomTargetParameters.class);
        requiredParams.add(DiscontinuityParameters.class);
        requiredParams.add(FluxTypeParameters.class);
        requiredParams.add(GapFillModuleParameters.class);
        requiredParams.add(ModuleOutputListsParameters.class);
        requiredParams.add(PdcGoodnessMetricParameters.class);
        requiredParams.add(PdcHarmonicsIdentificationParameters.class);
        requiredParams.add(PdcMapParameters.class);
        requiredParams.add(PdcModuleParameters.class);
        requiredParams.add(PseudoTargetListParameters.class);
        requiredParams.add(SaturationSegmentModuleParameters.class);
        requiredParams.add(SpsdDetectionParameters.class);
        requiredParams.add(SpsdDetectorParameters.class);
        requiredParams.add(SpsdRemovalParameters.class);
        requiredParams.add(ThrusterDataAncillaryEngineeringParameters.class);

        return requiredParams;
    }

    @Override
    public void generateInputs(InputsHandler inputsHandler,
        PipelineTask pipelineTask, File taskWorkingDir) throws Exception {

        ModOutCadenceUowTask task = pipelineTask.uowTaskInstance();
        ModuleOutputListsParameters moduleOutputListsParameters = pipelineTask.getParameters(ModuleOutputListsParameters.class);

        if (moduleOutputListsParameters.isChannelGroupsEnabled()) {
            PdcInputs inputs = pdcInputsRetriever.retrieveInputs(pipelineTask,
                inputsHandler.subTaskDirectory(), task.getChannels());

            for (PdcInputChannelData channelData : inputs.getChannelData()) {
                if (!channelData.getTargetData()
                    .isEmpty()) {
                    inputsHandler.addSubTaskInputs(inputs);
                    break;
                }
            }
        } else {
            for (int channel : task.getChannels()) {
                PdcInputs inputs = new PdcInputs();
                
                pdcInputsRetriever.retrieveInputs(pipelineTask, inputs,
                    inputsHandler.subTaskDirectory(), channel);

                if (!inputs.getChannelData()
                    .get(0)
                    .getTargetData()
                    .isEmpty()) {
                    inputsHandler.addSubTaskInputs(inputs);
                }
            }
        }
        pdcInputsRetriever.serializeProducerTaskIds(taskWorkingDir);
    }

    @Override
    public Class<?> outputsClass() {
        return PdcOutputs.class;
    }

    @Override
    public void processOutputs(PipelineTask pipelineTask,
        Iterator<AlgorithmResults> outputs) throws Exception {
        AlgorithmResults algorithmResults = null;

        while (outputs.hasNext()) {
            algorithmResults = outputs.next();

            if (!algorithmResults.successful()) {
                log.warn("Skipping failed sub-task due to MATLAB error for sub-task "
                    + algorithmResults.getResultsDir());
                continue;
            }

            File matlabWorkingDir = algorithmResults.getResultsDir();
            PdcOutputs pdcOutputs = (PdcOutputs) algorithmResults.getOutputs();

            pdcOutputsStorer.storeOutputs(pipelineTask, matlabWorkingDir,
                pdcOutputs);
        }

        if (algorithmResults != null) {
            pdcOutputsStorer.storeProducerTaskIds(algorithmResults.getTaskDir());
        }
    }

}
