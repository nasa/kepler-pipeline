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

package gov.nasa.kepler.dv;

import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.dv.io.CentroidTestParameters;
import gov.nasa.kepler.dv.io.DvOutputs;
import gov.nasa.kepler.dv.io.PixelCorrelationParameters;
import gov.nasa.kepler.dv.io.TrapezoidalFitParameters;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.DifferenceImageParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.PlanetFitModuleParameters;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.dv.DvModuleParameters;
import gov.nasa.kepler.mc.pi.NumberOfElementsPerSubTask;
import gov.nasa.kepler.mc.uow.PlanetaryCandidatesChunkUowTask;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pdc.PdcHarmonicsIdentificationParameters;
import gov.nasa.kepler.pdc.PdcModuleParameters;
import gov.nasa.kepler.pi.module.AlgorithmResults;
import gov.nasa.kepler.pi.module.AsyncPipelineModule;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.kepler.tps.TpsHarmonicsIdentificationParameters;
import gov.nasa.kepler.tps.TpsModuleParameters;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The DV pipeline module.
 * 
 * @author Forrest Girouard
 */
public class DvPipelineModule extends MatlabPipelineModule implements
    AsyncPipelineModule {
    private static final Log log = LogFactory.getLog(DvPipelineModule.class);

    public static final String MODULE_NAME = "dv";

    private static final String DV_DOM_EXE_NAME = "dv_dom";
    private static final int DV_DOM_EXE_TIMEOUT_SECS = 2 * 60 * 60;// 2 hours

    private final DvInputsRetriever dvInputsRetriever;
    private final DvOutputsStorer dvOutputsStorer;

    public DvPipelineModule() {
        this(new DvInputsRetriever(), new DvOutputsStorer());
    }

    DvPipelineModule(DvInputsRetriever dvInputsRetriever,
        DvOutputsStorer dvOutputsStorer) {
        this.dvInputsRetriever = dvInputsRetriever;
        this.dvOutputsStorer = dvOutputsStorer;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return PlanetaryCandidatesChunkUowTask.class;
    }
    
    /**
     * When the set of required input parameters undergoes a change, edit this
     * method to add the required parameter(s) or to no longer add the
     * no-longer-required parameter(s)
     */
    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();

        requiredParameters.add(AncillaryDesignMatrixParameters.class);
        requiredParameters.add(AncillaryEngineeringParameters.class);
        requiredParameters.add(AncillaryPipelineParameters.class);
        requiredParameters.add(BootstrapModuleParameters.class);
        requiredParameters.add(CadenceRangeParameters.class);
        requiredParameters.add(CentroidTestParameters.class);
        requiredParameters.add(CustomTargetParameters.class);
        requiredParameters.add(DifferenceImageParameters.class);
        requiredParameters.add(DvModuleParameters.class);
        requiredParameters.add(FluxTypeParameters.class);
        requiredParameters.add(GapFillModuleParameters.class);
        requiredParameters.add(PdcHarmonicsIdentificationParameters.class);
        requiredParameters.add(PdcModuleParameters.class);
        requiredParameters.add(PixelCorrelationParameters.class);
        requiredParameters.add(PlanetaryCandidatesFilterParameters.class);
        requiredParameters.add(PlanetFitModuleParameters.class);
        requiredParameters.add(RemoteExecutionParameters.class);
        requiredParameters.add(SaturationSegmentModuleParameters.class);
        requiredParameters.add(TpsHarmonicsIdentificationParameters.class);
        requiredParameters.add(TpsModuleParameters.class);
        requiredParameters.add(TrapezoidalFitParameters.class);
        requiredParameters.add(PaModuleParameters.class);

        return requiredParameters;
    }

    @Override
    public void generateInputs(InputsHandler inputsHandler,
        final PipelineTask pipelineTask, File workingDirectory)
        throws Exception {

        dvInputsRetriever.retrieveInputs(pipelineTask, workingDirectory,
            inputsHandler, new NumberOfElementsPerSubTask() {

                @Override
                public int numberOfElementsPerSubTask(int totalNumberOfElements) {
                    return elementsPerSubTask(pipelineTask,
                        totalNumberOfElements);
                }
            });

    }

    @Override
    public Class<?> outputsClass() {
        return DvOutputs.class;
    }

    @Override
    public void processOutputs(PipelineTask pipelineTask,
        Iterator<AlgorithmResults> outputs) throws Exception {
        dvOutputsStorer.storeOutputs(pipelineTask, outputs);

        executeDvDomScript();
    }

    private void executeDvDomScript() {
        File dir = getCurrentWorkingDir();
        if (dir != null) {
            IntervalMetricKey key = IntervalMetric.start();
            try {
                log.info("Running dv_dom script for dir: " + dir);

                List<String> commandLineArgs = new LinkedList<String>();
                commandLineArgs.add(dir.getAbsolutePath());

                executeMatlab(DV_DOM_EXE_NAME, commandLineArgs, dir,
                    DV_DOM_EXE_TIMEOUT_SECS);
            } finally {
                IntervalMetric.stop("tps.dawg.execTime", key);
            }
        } else {
            log.info("No working dir, not running dv_dom script");
        }
    }

}
