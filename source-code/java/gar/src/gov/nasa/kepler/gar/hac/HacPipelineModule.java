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

package gov.nasa.kepler.gar.hac;

import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.gar.Histogram;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.mc.uow.SingleUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The hac pipeline module.
 * 
 * @author Bill Wohler
 */
public class HacPipelineModule extends MatlabPipelineModule {
    private static final Log log = LogFactory.getLog(HacPipelineModule.class);

    public static final String MODULE_NAME = "hac";
    public static String MODULE_DESCRIPTION = "Histogram accumulator";

    /**
     * Ensures that {@link #processTask(PipelineInstance, PipelineTask)} is only
     * called once on this instance.
     */
    private boolean processTaskCalled;

    private int startCadence;
    private int endCadence;
    private Set<Long> producerTaskIds = new HashSet<Long>();

    private CompressionCrud compressionCrud = new CompressionCrud();
    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();

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
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(CadenceRangeParameters.class);

        return requiredParameters;
    }

    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        assertInvokedOnce();

        extractParameterInfo(pipelineTask);

        HacOutputs hacOutputs = runAccumulatorPipeline(pipelineInstance,
            pipelineTask);

        storeOutputs(pipelineInstance, pipelineTask, hacOutputs);

        daCrud.create(pipelineTask, producerTaskIds);
    }

    /**
     * Extracts various variables needed by the inputs.
     * 
     * @param pipelineTask the pipeline task.
     */
    private void extractParameterInfo(PipelineTask pipelineTask) {
        CadenceRangeParameters cadenceRangePipelineParams = pipelineTask.getParameters(CadenceRangeParameters.class);
        startCadence = cadenceRangePipelineParams.getStartCadence();
        endCadence = cadenceRangePipelineParams.getEndCadence();
    }

    /**
     * Ensures that this pipeline is only invoked once per instance.
     * 
     * @throws PipelineException upon re-entry.
     */
    private void assertInvokedOnce() {
        if (processTaskCalled) {
            throw new PipelineException(
                "processTask may only be called once per instance");
        }
        processTaskCalled = true;
    }

    /**
     * Runs the MATLAB pipeline module for each module/output.
     * 
     * @param pipelineInstance the pipeline instance.
     * @param pipelineTask the pipeline task.
     * 
     * @throws PipelineException if there was a problem running MATLAB.
     */
    private HacOutputs runAccumulatorPipeline(
        PipelineInstance pipelineInstance, PipelineTask pipelineTask) {

        List<HistogramGroup> histogramGroups = compressionCrud.retrieveHistogramGroups(pipelineInstance);
        if (histogramGroups.isEmpty()) {
            log.warn("No histograms for pipeline instance "
                + pipelineInstance.getId());
            return null;
        }

        boolean firstTime = true;
        HacOutputs hacOutputs = null;
        for (HistogramGroup histogramGroup : histogramGroups) {
            producerTaskIds.add(histogramGroup.getPipelineTask()
                .getId());

            List<Histogram> histogramsOut = new ArrayList<Histogram>(
                histogramGroup.getHistograms()
                    .size());
            for (gov.nasa.kepler.hibernate.gar.Histogram histogramIn : histogramGroup.getHistograms()) {
                Histogram histogramOut = new Histogram(
                    histogramIn.getBaselineInterval());
                histogramOut.setTheoreticalCompressionRate(histogramIn.getTheoreticalCompressionRate());
                histogramOut.setTotalStorageRate(histogramIn.getTotalStorageRate());
                histogramOut.setUncompressedBaselineOverheadRate(histogramIn.getUncompressedBaselineOverheadRate());
                List<Long> valuesIn = histogramIn.getHistogram();
                long[] valuesOut = new long[valuesIn.size()];
                int i = 0;
                for (long valueIn : valuesIn) {
                    valuesOut[i++] = valueIn;
                }
                histogramOut.setHistogram(valuesOut);
                histogramsOut.add(histogramOut);
            }

            // Outputs ignored until last run.
            hacOutputs = runAccumulatorPipeline(pipelineTask,
                histogramGroup.getCcdModule(), histogramGroup.getCcdOutput(),
                firstTime, histogramsOut);

            firstTime = false;
        }

        return hacOutputs;
    }

    /**
     * Runs the MATLAB pipeline module for the given {@link Histogram}s.
     * 
     * @param pipelineTask the pipeline task.
     * @param ccdModule the CCD module.
     * @param ccdOutput the CCD output.
     * @param firstTime {@code true}, if this is the first time this method has
     * been called; otherwise, {@code false}.
     * @param histograms the histograms for this CCD module/output.
     * @return the pipeline module's outputs.
     * @throws PipelineException if there was a problem running MATLAB.
     */
    private HacOutputs runAccumulatorPipeline(PipelineTask pipelineTask,
        int ccdModule, int ccdOutput, boolean firstTime,
        List<Histogram> histograms) {

        HacInputs hacInputs = new HacInputs();
        hacInputs.setCadenceStart(startCadence);
        hacInputs.setCadenceEnd(endCadence);
        hacInputs.setInvocationCcdModule(ccdModule);
        hacInputs.setInvocationCcdOutput(ccdOutput);
        hacInputs.setFirstMatlabInvocation(firstTime);
        hacInputs.setHistograms(histograms);

        log.info("Running HAC with inputs=" + hacInputs);

        HacOutputs hacOutputs = new HacOutputs();
        executeAlgorithm(pipelineTask, hacInputs, hacOutputs);

        return hacOutputs;
    }

    private void storeOutputs(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask, HacOutputs hacOutputs) {

        log.info("Storing HAC outputs=" + hacOutputs);

        if (hacOutputs == null || hacOutputs.getHistograms()
            .isEmpty()) {
            throw new ModuleFatalProcessingException(
                "No histograms were generated");
        }

        HistogramGroup histogramGroup = new HistogramGroup(pipelineInstance,
            pipelineTask);
        histogramGroup.setBestBaselineInterval(hacOutputs.getOverallBestBaselineInterval());
        histogramGroup.setBestStorageRate(hacOutputs.getOverallBestStorageRate());

        List<Histogram> histogramsIn = hacOutputs.getHistograms();
        List<gov.nasa.kepler.hibernate.gar.Histogram> histogramsOut = new ArrayList<gov.nasa.kepler.hibernate.gar.Histogram>(
            histogramsIn.size());
        for (Histogram histogramIn : histogramsIn) {
            gov.nasa.kepler.hibernate.gar.Histogram histogramOut = new gov.nasa.kepler.hibernate.gar.Histogram(
                histogramIn.getBaselineInterval());
            histogramOut.setTheoreticalCompressionRate(histogramIn.getTheoreticalCompressionRate());
            histogramOut.setTotalStorageRate(histogramIn.getTotalStorageRate());
            histogramOut.setUncompressedBaselineOverheadRate(histogramIn.getUncompressedBaselineOverheadRate());
            long[] valuesIn = histogramIn.getHistogram();
            List<Long> valuesOut = new ArrayList<Long>(valuesIn.length);
            for (long valueIn : valuesIn) {
                valuesOut.add(valueIn);
            }
            histogramOut.setHistogram(valuesOut);
            compressionCrud.create(histogramOut);
            histogramsOut.add(histogramOut);
        }
        histogramGroup.setHistograms(histogramsOut);
        compressionCrud.create(histogramGroup);
    }

    void setCompressionCrud(CompressionCrud compressionCrud) {
        this.compressionCrud = compressionCrud;
    }

    void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }
}
