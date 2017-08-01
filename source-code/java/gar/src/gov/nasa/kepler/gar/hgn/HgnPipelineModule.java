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

package gov.nasa.kepler.gar.hgn;

import static gov.nasa.kepler.mc.TimeSeriesOperations.addToDataAccountability;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.gar.CadencePixelValues;
import gov.nasa.kepler.gar.Histogram;
import gov.nasa.kepler.gar.HistogramPipelineParameters;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.gar.HistogramGroup;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.CollateralTimeSeriesOperations;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.pmrf.PmrfOperations;
import gov.nasa.kepler.mc.uow.IntegerBinner;
import gov.nasa.kepler.mc.uow.ModOutUowTask;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.collect.Pair;
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
 * The hgn pipeline module.
 * 
 * @author Bill Wohler
 */
public class HgnPipelineModule extends MatlabPipelineModule {

    private static final Log log = LogFactory.getLog(HgnPipelineModule.class);

    public static final String MODULE_NAME = "hgn";
    public static final String MODULE_DESCRIPTION = "Histogram generator";

    /**
     * Ensures that {@link #processTask(PipelineInstance, PipelineTask)} is only
     * called once on this instance.
     */
    private boolean processTaskCalled;

    /** The module parameters to pass into the inputs. */
    private HgnModuleParameters moduleParams;

    /** The requant table in a form that is suitable for the inputs. */
    private RequantTable requantTable;

    private Set<Long> producerTaskIds = new HashSet<Long>();
    private CadenceType cadenceType;
    private int ccdModule;
    private int ccdOutput;
    private PipelineInstance pipelineInstance;

    private CompressionCrud compressionCrud = new CompressionCrud();
    private DataAccountabilityTrailCrud daCrud = new DataAccountabilityTrailCrud();
    private MjdToCadence mjdToCadence;
    private PmrfOperations pmrfOperations = new PmrfOperations();
    private TargetCrud targetCrud = new TargetCrud();
    private TimeSeriesOperations timeSeriesOperations = new TimeSeriesOperations();

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> requiredParameters = new ArrayList<Class<? extends Parameters>>();
        requiredParameters.add(CadenceRangeParameters.class);
        requiredParameters.add(CadenceTypePipelineParameters.class);
        requiredParameters.add(HgnModuleParameters.class);
        requiredParameters.add(HistogramPipelineParameters.class);

        return requiredParameters;
    }

    /**
     * Performs a unit of work for the given hgn task.
     * <p>
     * This method reads the requant table and all of the pixel time series for
     * this unit of work. It then makes per-cadence slices of the time series.
     * It then bins the slices up according to the {@code maxMatlabCadences}
     * parameter and calls
     * {@link #executeAlgorithm(PipelineTask, gov.nasa.kepler.common.persistable.Persistable, gov.nasa.kepler.common.persistable.Persistable)}
     * for each bin.
     * <p>
     * It is an error to call this method more than once on an instance.
     * 
     * @throws PipelineException if the data store could not be accessed or
     * there was an error in the science.
     */
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {
        this.pipelineInstance = pipelineInstance;

        assertInvokedOnce();

        extractParameterInfo(pipelineTask);

        CadenceRangeParameters cadenceRangePipelineParams = pipelineTask.getParameters(CadenceRangeParameters.class);
        int startCadence = cadenceRangePipelineParams.getStartCadence();
        int endCadence = cadenceRangePipelineParams.getEndCadence();

        requantTable = retrieveRequantTable(startCadence, endCadence);

        FsId[] fsIds = getFsIds(startCadence, endCadence);

        HistogramPipelineParameters histogramPipelineParams = pipelineTask.getParameters(HistogramPipelineParameters.class);

        List<Pair<Integer, Integer>> cadenceRanges = IntegerBinner.subdivide(
            Pair.of(startCadence, endCadence),
            histogramPipelineParams.getMaxReadCadences());
        HgnOutputs hgnOutputs = null;
        for (Pair<Integer, Integer> cadenceRange : cadenceRanges) {

            // Outputs ignored until last run.
            hgnOutputs = runHistogramGenerator(pipelineTask, fsIds,
                cadenceRange.left, cadenceRange.right,
                histogramPipelineParams.getMaxMatlabCadences());
        }

        storeOutputs(pipelineInstance, pipelineTask, hgnOutputs);

        daCrud.create(pipelineTask, producerTaskIds);
    }

    /**
     * Extracts various variables needed by the inputs.
     * 
     * @param pipelineTask the pipeline task.
     */
    private void extractParameterInfo(PipelineTask pipelineTask) {
        ModOutUowTask task = (ModOutUowTask) pipelineTask.uowTaskInstance();
        ccdModule = task.getCcdModule();
        ccdOutput = task.getCcdOutput();

        moduleParams = pipelineTask.getParameters(HgnModuleParameters.class);
        CadenceTypePipelineParameters cadenceTypePipelineParams = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
        cadenceType = CadenceType.valueOf(cadenceTypePipelineParams.getCadenceType());
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
     * Retrieves the requant table in effect and returns its contents.
     * 
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @return a non-{@code null} requant table.
     * @throws ModuleFatalProcessingException if there isn't a single requant
     * table in the database active during the given period.
     */
    private RequantTable retrieveRequantTable(int startCadence, int endCadence) {
        log.info("Retrieving requantization table...");
        double startMjd = getMjdToCadence().cadenceToMjd(startCadence);
        double endMjd = getMjdToCadence().cadenceToMjd(endCadence);
        List<gov.nasa.kepler.hibernate.gar.RequantTable> tables = compressionCrud.retrieveRequantTables(
            startMjd, endMjd);
        if (tables.size() == 0) {
            throw new ModuleFatalProcessingException(
                "No requant table found between " + startCadence + " ("
                    + startMjd + ") and " + endCadence + " (" + endMjd + ")");
        } else if (tables.size() > 1) {
            throw new ModuleFatalProcessingException(
                "Multiple requant tables found between " + startCadence + " ("
                    + startMjd + ") and " + endCadence + " (" + endMjd + ")");
        }
        log.info("Retrieving requantization table...done; " + tables.get(0)
            .getRequantEntries()
            .size() + " requant entries, " + tables.get(0)
            .getMeanBlackEntries()
            .size() + " mean black entries");

        RequantTable requantTable = new RequantTable(tables.get(0), startMjd);

        return requantTable;
    }

    /**
     * Returns {@link FsId}s for all science pixels, background pixels, and
     * collateral pixels.
     * 
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @throws NullPointerException if either {@code pipelineParams} or
     * {@code cadenceType} are {@code null}.
     */
    private FsId[] getFsIds(int startCadence, int endCadence) {

        log.info("Generating fsids...");

        // Retrieve target table logs.
        TargetType targetTableType = TargetType.valueOf(cadenceType);
        TargetTableLog targetTableLog = targetCrud.retrieveTargetTableLog(
            targetTableType, startCadence, endCadence);
        TargetTableLog bgTargetTableLog = null;
        if (targetTableType == TargetType.LONG_CADENCE) {
            bgTargetTableLog = targetCrud.retrieveTargetTableLog(
                TargetType.BACKGROUND, startCadence, endCadence);
        }

        // Calculate science target FsIds.
        List<Set<FsId>> fsIdsPerTarget = new ArrayList<Set<FsId>>();
        SciencePixelOperations sciencePixelOperations = new SciencePixelOperations(
            targetTableLog.getTargetTable(),
            bgTargetTableLog != null ? bgTargetTableLog.getTargetTable() : null,
            ccdModule, ccdOutput);
        sciencePixelOperations.setTargetCrud(targetCrud);
        fsIdsPerTarget.addAll(sciencePixelOperations.getFsIdsPerTarget());

        // Append collateral FsIds.
        CollateralTimeSeriesOperations collateralTimeSeriesOperations = new CollateralTimeSeriesOperations(
            cadenceType, targetTableLog.getTargetTable()
                .getExternalId(), ccdModule, ccdOutput);
        collateralTimeSeriesOperations.setPmrfOperations(pmrfOperations);
        fsIdsPerTarget.add(collateralTimeSeriesOperations.getCollateralFsIds());

        // Merge the FsIds into a single array.
        FsId[] fsIds = TimeSeriesOperations.getFsIds(fsIdsPerTarget);

        log.info("Generating fsids...done; " + fsIds.length + " fsids");

        return fsIds;
    }

    /**
     * Runs the MATLAB pipeline module for the given {@link FsId}s.
     * 
     * @param pipelineTask the pipeline task.
     * @param fsIds the {@link FsId}s.
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @param maxMatlabCadences the maximum number of cadences that should be
     * passed to MATLAB at any one time. If 0, all cadences are passed through.
     * 
     * @throws PipelineException if there was a problem running MATLAB.
     */
    private HgnOutputs runHistogramGenerator(PipelineTask pipelineTask,
        FsId[] fsIds, int startCadence, int endCadence, int maxMatlabCadences) {

        List<Pair<Integer, Integer>> cadenceRanges = IntegerBinner.subdivide(
            Pair.of(startCadence, endCadence), maxMatlabCadences);
        boolean firstTime = true;
        HgnOutputs hgnOutputs = null;

        for (Pair<Integer, Integer> cadenceRange : cadenceRanges) {
            List<CadencePixelValues> cadencePixels = createCadenceSlices(fsIds,
                cadenceRange.left, cadenceRange.right);

            // Outputs ignored until last run.
            hgnOutputs = runHistogramGenerator(pipelineTask, cadenceRange.left,
                cadenceRange.right, firstTime, cadencePixels);

            firstTime = false;
        }

        return hgnOutputs;
    }

    /**
     * Reads the pixel time series for the given {@link FsId}s over the given
     * duration and creates a per-cadence slice of them.
     * 
     * @param fsIds the FsIds.
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @return a non-{@code null} list of cadence slices.
     * @throws PipelineException if there were problems reading the time series
     * from the file store.
     * @throws NullPointerException if {@code fsIds} is {@code null};
     */
    private List<CadencePixelValues> createCadenceSlices(FsId[] fsIds,
        int startCadence, int endCadence) {

        // The total number of cadences is end - start, inclusive.
        int cadenceCount = endCadence - startCadence + 1;

        String s = String.format(
            "Reading time series for %d pixels from %d to %d...", fsIds.length,
            startCadence, endCadence);
        log.info(s);
        IntTimeSeries[] allTimeSeries = timeSeriesOperations.readPixelTimeSeriesAsInt(
            fsIds, startCadence, endCadence);
        for (IntTimeSeries timeSeries : allTimeSeries) {
            addToDataAccountability(timeSeries, producerTaskIds);
        }
        log.info(s + "done");

        log.info("Generating " + cadenceCount + " cadence slices...");
        List<CadencePixelValues> cadencePixelValues = new ArrayList<CadencePixelValues>(
            cadenceCount);

        for (int i = 0; i < cadenceCount; i++) {
            int[] pixelValues = new int[fsIds.length];
            boolean[] gapIndicators = new boolean[fsIds.length];
            int j = 0;
            for (IntTimeSeries timeSeries : allTimeSeries) {
                if (timeSeries.exists()) {
                    pixelValues[j] = timeSeries.iseries()[i];
                    gapIndicators[j] = timeSeries.getGapIndicators()[i];
                } else {
                    pixelValues[j] = 0;
                    gapIndicators[j] = true;
                }
                j++;
            }
            CadencePixelValues values = new CadencePixelValues();
            values.setCadence(startCadence + i);
            values.setGapIndicators(gapIndicators);
            values.setPixelValues(pixelValues);
            cadencePixelValues.add(values);
        }

        // Use the actual size of the array to ensure that we picked the right
        // size to begin with.
        log.info("Generating " + cadencePixelValues.size()
            + " cadence slices...done");

        return cadencePixelValues;
    }

    /**
     * Runs the MATLAB pipeline module for the given cadence pixels.
     * 
     * @param pipelineTask the pipeline task.
     * @param startCadence the starting cadence.
     * @param endCadence the ending cadence.
     * @param firstTime {@code true}, if this is the first time this method has
     * been called; otherwise, {@code false}.
     * @param cadencePixels the cadence pixels.
     * 
     * @return the pipeline module's outputs.
     * @throws PipelineException if there was a problem running MATLAB.
     */
    private HgnOutputs runHistogramGenerator(PipelineTask pipelineTask,
        int startCadence, int endCadence, boolean firstTime,
        List<CadencePixelValues> cadencePixels) {

        HgnInputs hgnInputs = new HgnInputs();
        hgnInputs.setHgnModuleParameters(moduleParams);
        hgnInputs.setCcdModule(ccdModule);
        hgnInputs.setCcdOutput(ccdOutput);
        hgnInputs.setInvocationCadenceStart(startCadence);
        hgnInputs.setInvocationCadenceEnd(endCadence);
        hgnInputs.setFirstMatlabInvocation(firstTime);
        hgnInputs.setRequantTable(requantTable);
        hgnInputs.setCadencePixels(cadencePixels);

        log.info("Running HGN with inputs=" + hgnInputs);

        HgnOutputs hgnOutputs = new HgnOutputs();
        executeAlgorithm(pipelineTask, hgnInputs, hgnOutputs);

        return hgnOutputs;
    }

    private void storeOutputs(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask, HgnOutputs hgnOutputs) {

        log.info("Storing HGN outputs=" + hgnOutputs);

        if (hgnOutputs.getHistograms()
            .isEmpty()) {
            throw new ModuleFatalProcessingException(
                "No histograms were generated");
        }

        HistogramGroup histogramGroup = new HistogramGroup(pipelineInstance,
            pipelineTask, ccdModule, ccdOutput);

        histogramGroup.setBestBaselineInterval(hgnOutputs.getModOutBestBaselineInterval());
        histogramGroup.setBestStorageRate(hgnOutputs.getModOutBestStorageRate());

        List<Histogram> histogramsIn = hgnOutputs.getHistograms();
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

    void setMjdCadence(MjdToCadence mjdToCadence) {
        this.mjdToCadence = mjdToCadence;
    }

    private MjdToCadence getMjdToCadence() {
        if (mjdToCadence == null) {
            mjdToCadence = new MjdToCadence(cadenceType,
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }

        return mjdToCadence;
    }

    void setPmrfOperations(PmrfOperations pmrfOperations) {
        this.pmrfOperations = pmrfOperations;
    }

    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }
}
