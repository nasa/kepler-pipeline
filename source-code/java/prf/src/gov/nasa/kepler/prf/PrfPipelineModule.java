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

package gov.nasa.kepler.prf;

import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.FPG_DEC;
import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.FPG_DEC_UNCERT;
import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.FPG_RA;
import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.FPG_RA_UNCERT;
import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.FPG_ROLL;
import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.FPG_ROLL_UNCERT;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fpg.FpgAttitudeSolution;
import gov.nasa.kepler.fpg.FpgAttitudeTimeSeries;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeriesCrud;
import gov.nasa.kepler.hibernate.pa.MotionBlobMetadata;
import gov.nasa.kepler.hibernate.pa.PaCrud;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.prf.PrfBlobMetadata;
import gov.nasa.kepler.hibernate.prf.PrfConvergence;
import gov.nasa.kepler.hibernate.prf.PrfCrud;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.BrysonianCosmicRayModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PrfFsIdFactory;
import gov.nasa.kepler.mc.uow.ModOutCadenceUowTask;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FilenameUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 * @author Forrest Girouard (forrest.girouard@nasa.gov)
 * 
 */
public class PrfPipelineModule extends MatlabPipelineModule {

    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(PrfPipelineModule.class);

    public static final String MODULE_NAME = "prf";

    private PrfInputs inputs;
    private PrfOutputs outputs;

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private ModOutCadenceUowTask task;

    private CadenceType cadenceType;

    private BlobOperations blobOperations;
    private ConfigMapOperations configMapOperations;
    private DataAccountabilityTrailCrud daCrud;
    private CelestialObjectOperations celestialObjectOperations;
    private PaCrud paCrud;
    private PrfCrud prfCrud;
    private RaDec2PixOperations raDec2PixOperations;
    private TargetCrud targetCrud;
    private DoubleDbTimeSeriesCrud doubleTsCrud;

    private Set<Long> producerTaskIds = new HashSet<Long>();

    private File matlabWorkingDir;

    public PrfPipelineModule() {
    }

    @Override
    public Class<? extends UnitOfWorkTask> unitOfWorkTaskType() {
        return ModOutCadenceUowTask.class;
    }

    @Override
    public List<Class<? extends Parameters>> requiredParameters() {
        List<Class<? extends Parameters>> rv = new ArrayList<Class<? extends Parameters>>();
        rv.add(PrfModuleParameters.class);
        rv.add(PouModuleParameters.class);
        rv.add(BackgroundModuleParameters.class);
        rv.add(BrysonianCosmicRayModuleParameters.class);
        rv.add(MotionModuleParameters.class);
        rv.add(CustomTargetParameters.class);
        return rv;
    }

    @Override
    public String getModuleName() {
        return MODULE_NAME;
    }

    /**
     * Normal entry point for module.
     * 
     * @param pipelineInstance
     * @param pipelineTask
     */
    @Override
    public void processTask(PipelineInstance pipelineInstance,
        PipelineTask pipelineTask) {

        this.pipelineInstance = pipelineInstance;
        this.pipelineTask = pipelineTask;
        task = pipelineTask.uowTaskInstance();

        log.info("[" + getModuleName() + "]instance node uow = " + task);

        initializeTask();

        log.info("[" + getModuleName() + "]retrieve target table logs.");

        List<TargetTableLog> targetTableLogs = getTargetCrud().retrieveTargetTableLogs(
            TargetType.valueOf(cadenceType), task.getStartCadence(),
            task.getEndCadence());
        DatabaseServiceFactory.getInstance()
            .evictAll(targetTableLogs);

        if (targetTableLogs == null || targetTableLogs.size() < 1) {
            throw new ModuleFatalProcessingException(
                "No available target tables for given cadence range: ["
                    + task.getStartCadence() + ", " + task.getEndCadence()
                    + "].");
        } else if (targetTableLogs.size() > 1) {
            throw new ModuleFatalProcessingException(
                "More than 1 target table for given cadence range: ["
                    + task.getStartCadence() + ", " + task.getEndCadence()
                    + "].");
        }

        processTask(targetTableLogs.get(0));
    }

    void processTask(TargetTableLog targetTableLog) {

        retrieveInputs(targetTableLog);

        outputs = new PrfOutputs();

        executeAlgorithm(pipelineTask, inputs, outputs);

        // GC
        inputs = null;

        storeOutputs(targetTableLog);

    }

    void initializeTask() {

        CadenceTypePipelineParameters pipelineParams = pipelineTask.getParameters(CadenceTypePipelineParameters.class);
        cadenceType = CadenceType.valueOf(pipelineParams.getCadenceType());

        if (cadenceType != CadenceType.LONG) {
            throw new ModuleFatalProcessingException(
                "Cadence type must be LONG: [" + cadenceType + "].");
        }
    }

    void retrieveInputs(TargetTableLog targetTableLog) {

        log.info("[" + getModuleName() + "]start retrieve inputs");

        IntervalMetricKey metricKey = IntervalMetric.start();
        try {

            BrysonianCosmicRayModuleParameters cosmicRayParameters = pipelineTask.getParameters(BrysonianCosmicRayModuleParameters.class);
            PrfModuleParameters prfParameters = pipelineTask.getParameters(PrfModuleParameters.class);
            PouModuleParameters pouParameters = pipelineTask.getParameters(PouModuleParameters.class);
            MotionModuleParameters motionParameters = pipelineTask.getParameters(MotionModuleParameters.class);

            int ccdModule = task.getCcdModule();
            int ccdOutput = task.getCcdOutput();
            int startCadence = task.getStartCadence();
            int endCadence = task.getEndCadence();

            log.debug("[" + getModuleName() + "]retrieve cadence times.");
            TimestampSeries cadenceTimes = retrieveCadenceTimes(cadenceType,
                task.getStartCadence(), task.getEndCadence());

            log.debug("[" + getModuleName()
                + "]retrieve the spacecraft configuration maps");
            List<ConfigMap> configMaps = getConfigMapOperations().retrieveConfigMaps(
                cadenceTimes.startMjd(), cadenceTimes.endMjd());

            log.debug("[" + getModuleName() + "]retrieve the raDec2Pix model");
            RaDec2PixModel raDec2PixModel = getRaDec2PixOperations().retrieveRaDec2PixModel(
                cadenceTimes.startMjd(), cadenceTimes.endMjd());

            TargetTable targetTable = targetTableLog.getTargetTable();
            DatabaseServiceFactory.getInstance()
                .evict(targetTable);

            // determine targets
            log.debug("[" + getModuleName() + "]retrieve observed targets.");
            List<ObservedTarget> targets = getTargetCrud().retrieveObservedTargets(
                targetTable, task.getCcdModule(), task.getCcdOutput());

            DatabaseServiceFactory.getInstance()
                .evictAll(targets);

            log.debug("[" + getModuleName() + "]create prf targets.");
            List<PrfTarget> prfTargets = createPrfTargets(task.getCcdModule(),
                task.getCcdOutput(), task.getStartCadence(),
                task.getEndCadence(), targets);

            // assemble complete list of FsIds
            List<FsId> fsIds = getAllPixelFsIds(prfTargets);
            // fsIds.addAll(PrfAttitudeSolution.getAllTimeSeriesFsIds(targetTable.getExternalId()));

            // read all time series data
            log.debug("[" + getModuleName() + "]retrieve all time series.");
            Map<FsId, FloatTimeSeries> timeSeriesByFsId = retrieveTimeSeries(
                fsIds, task.getStartCadence(), task.getEndCadence());

            // populate prfTargets
            setAllPixelTimeSeries(prfTargets, timeSeriesByFsId);

            List<PrfCentroidTimeSeries> centroids = createPrfCentroidTimeSeries(
                prfTargets, timeSeriesByFsId);

            // populate prfAttitudeSolution
            FpgAttitudeSolution fpgAttitudeSolution = getAttitudeSolution(
                startCadence, endCadence);

            log.debug("[" + getModuleName()
                + "]retrieve background coeff blobs.");

            BlobSeries<String> backgroundBlobs = getBlobOperations().retrieveBackgroundBlobFileSeries(
                task.getCcdModule(), task.getCcdOutput(),
                task.getStartCadence(), task.getEndCadence());
            BlobFileSeries backgroundBlobSeries = new BlobFileSeries(
                backgroundBlobs);
            producerTaskIds.addAll(backgroundBlobs.blobOriginatorsSet());

            log.debug("[" + getModuleName() + "]retrieve motion blobs.");
            BlobSeries<String> motionBlobs = getBlobOperations().retrieveMotionBlobFileSeries(
                task.getCcdModule(), task.getCcdOutput(),
                task.getStartCadence(), task.getEndCadence());
            BlobFileSeries motionBlobSeries = new BlobFileSeries(motionBlobs);
            producerTaskIds.addAll(motionBlobs.blobOriginatorsSet());

            log.debug("[" + getModuleName() + "]retrieve fpg geometry blobs.");
            BlobSeries<String> fpgGeometryBlobs = getBlobOperations().retrieveFpgGeometryBlob(
                startCadence, endCadence);

            BlobFileSeries fpgGeometryBlobSeries = new BlobFileSeries(
                fpgGeometryBlobs);
            producerTaskIds.addAll(fpgGeometryBlobs.blobOriginatorsSet());

            log.debug("[" + getModuleName() + "]retrieve Cal uncertainty blob.");
            BlobSeries<String> calUncertaintyBlobs = blobOperations.retrieveCalUncertaintiesBlobFileSeries(
                task.getCcdModule(), task.getCcdOutput(), cadenceType,
                startCadence, endCadence);
            BlobFileSeries calUncertaintyBlobSeries = new BlobFileSeries(
                calUncertaintyBlobs);

            inputs = new PrfInputs(ccdModule, ccdOutput, startCadence,
                endCadence, cadenceTimes, configMaps, prfParameters,
                pouParameters, cosmicRayParameters, motionParameters,
                raDec2PixModel, backgroundBlobSeries, motionBlobSeries,
                fpgGeometryBlobSeries, fpgAttitudeSolution, prfTargets,
                calUncertaintyBlobSeries, centroids);

        } catch (IllegalArgumentException iae) {
            throw new ModuleFatalProcessingException(iae.getMessage(), iae);
        } finally {
            IntervalMetric.stop("prf.PrfPipelineModule.retrieveInputs",
                metricKey);
        }
    }

    private List<PrfCentroidTimeSeries> createPrfCentroidTimeSeries(
        List<PrfTarget> prfTargets, Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        List<PrfCentroidTimeSeries> centroids = new ArrayList<PrfCentroidTimeSeries>(
            prfTargets.size());

        for (PrfTarget target : prfTargets) {
            centroids.add(new PrfCentroidTimeSeries(target.getKeplerId(),
                timeSeriesByFsId));
        }

        return centroids;
    }

    private FpgAttitudeSolution getAttitudeSolution(int startCadence,
        int endCadence) {
        DoubleDbTimeSeriesCrud crud = getDoubleDbTimeSeriesCrud();
        DoubleDbTimeSeries fpgRa = crud.retrieve(FPG_RA, startCadence,
            endCadence);
        DoubleDbTimeSeries fpgRaUncert = crud.retrieve(FPG_RA_UNCERT,
            startCadence, endCadence);
        FpgAttitudeTimeSeries raTimeSeries = new FpgAttitudeTimeSeries(
            fpgRa.getValues(), fpgRaUncert.getValues(), fpgRa.getGapIndices());
        DoubleDbTimeSeries fpgDec = crud.retrieve(FPG_DEC, startCadence,
            endCadence);
        DoubleDbTimeSeries fpgDecUncert = crud.retrieve(FPG_DEC_UNCERT,
            startCadence, endCadence);
        FpgAttitudeTimeSeries decTimeSeries = new FpgAttitudeTimeSeries(
            fpgDec.getValues(), fpgDecUncert.getValues(),
            fpgDec.getGapIndices());
        DoubleDbTimeSeries fpgRoll = crud.retrieve(FPG_ROLL, startCadence,
            endCadence);
        DoubleDbTimeSeries fpgRollUncert = crud.retrieve(FPG_ROLL_UNCERT,
            startCadence, endCadence);
        FpgAttitudeTimeSeries rollTimeSeries = new FpgAttitudeTimeSeries(
            fpgRoll.getValues(), fpgRollUncert.getValues(),
            fpgRoll.getGapIndices());

        FpgAttitudeSolution att = new FpgAttitudeSolution(raTimeSeries,
            decTimeSeries, rollTimeSeries);
        return att;
    }

    private void storeOutputs(TargetTableLog targetTableLog) {

        IntervalMetricKey metricKey = IntervalMetric.start();
        try {

            log.debug("[" + getModuleName() + "]store centroids.");
            storePrfCentroidTimeSeries(outputs.getCentroids());

            log.debug("[" + getModuleName() + "]store motion blob.");
            storeMotionPolyBlob(outputs.getMotionBlobFileName());

            log.debug("[" + getModuleName() + "]store prf blob.");
            storePrfBlob(outputs.getPrfBlobFileName());

            storeConvergence(outputs);

            // Update the data accountability trail.
            log.debug("[" + getModuleName()
                + "]create data accountability trail.");
            getDaCrud().create(pipelineTask, producerTaskIds);
        } finally {
            IntervalMetric.stop("prf.PrfPipelineModule.storeOutputs", metricKey);
        }
    }

    private void storeConvergence(PrfOutputs prfOutputs) {
        PrfConvergence prfConvergence = new PrfConvergence(
            prfOutputs.isCentroidsConverged(), getPipelineTask(),
            prfOutputs.getDeltaCentroidNorm());
        getPrfCrud().create(prfConvergence);
        log.info(prfConvergence);
    }

    private TimestampSeries retrieveCadenceTimes(CadenceType cadenceType,
        int startCadence, int endCadence) {

        MjdToCadence mjdToCadence = new MjdToCadence(cadenceType,
            new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        return mjdToCadence.cadenceTimes(task.getStartCadence(),
            task.getEndCadence());
    }

    private List<PrfTarget> createPrfTargets(int ccdModule, int ccdOutput,
        int startCadence, int endCadence, List<ObservedTarget> targets) {

        List<PrfTarget> prfTargets = new ArrayList<PrfTarget>();

        int totalTargets = 0;
        for (ObservedTarget target : targets) {
            CelestialObjectParameters celestialObjectParameters = getCelestialObjectOperations().retrieveCelestialObjectParameters(
                target.getKeplerId());
            if (celestialObjectParameters != null) {
                float keplerMag = (float) celestialObjectParameters.getKeplerMag()
                    .getValue();
                PrfTarget prfTarget = new PrfTarget(target.getKeplerId(),
                    keplerMag, celestialObjectParameters.getRa()
                        .getValue(), celestialObjectParameters.getDec()
                        .getValue(), target.getAperture()
                        .getReferenceRow(), target.getAperture()
                        .getReferenceColumn(),
                    (float) target.getCrowdingMetric(),
                    (float) target.getFluxFractionInAperture());

                // Get the absolute optimal aperture offsets for use later
                // in determining which pixels are in the optimal aperture.
                Set<Offset> absOptimalPixels = new HashSet<Offset>();
                for (Offset pixel : target.getAperture()
                    .getOffsets()) {
                    absOptimalPixels.add(new Offset(prfTarget.getReferenceRow()
                        + pixel.getRow(), prfTarget.getReferenceColumn()
                        + pixel.getColumn()));
                }

                List<PrfPixelTimeSeries> pixels = new ArrayList<PrfPixelTimeSeries>();

                Collection<TargetDefinition> targetDefinitions = target.getTargetDefinitions();
                // Loop through all TargetDefinitions for this Target.
                for (TargetDefinition targetDefinition : targetDefinitions) {

                    // create a pixel time series for each pixel in the target.
                    for (Offset offset : targetDefinition.getMask()
                        .getOffsets()) {

                        Offset absOffset = new Offset(
                            targetDefinition.getReferenceRow()
                                + offset.getRow(),
                            targetDefinition.getReferenceColumn()
                                + offset.getColumn());
                        PrfPixelTimeSeries pixel = new PrfPixelTimeSeries(
                            absOffset.getRow(), absOffset.getColumn(),
                            absOptimalPixels.contains(absOffset));

                        pixels.add(pixel);
                    }
                }
                DatabaseServiceFactory.getInstance()
                    .evictAll(targetDefinitions);
                prfTarget.setPrfPixelTimeSeries(pixels);

                prfTargets.add(prfTarget);

                totalTargets++;
                if (totalTargets % 100 == 0) {
                    log.debug("Targets complete: " + totalTargets);
                }
            }
        }
        return prfTargets;
    }

    private List<FsId> getAllPixelFsIds(List<PrfTarget> targets) {

        List<FsId> fsIds = new ArrayList<FsId>();
        for (PrfTarget target : targets) {
            fsIds.addAll(PrfCentroidTimeSeries.fsIdsFor(target.getKeplerId()));
            for (PrfPixelTimeSeries pixel : target.getPrfPixelTimeSeries()) {

                fsIds.addAll(pixel.getAllTimeSeriesFsIds(task.getCcdModule(),
                    task.getCcdOutput()));
            }
        }
        return fsIds;
    }

    private void setAllPixelTimeSeries(List<PrfTarget> targets,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        for (PrfTarget target : targets) {
            target.setAllTimeSeries(task.getCcdModule(), task.getCcdOutput(),
                task.getStartCadence(), task.getEndCadence(), timeSeriesByFsId);

        }
    }

    protected Map<FsId, FloatTimeSeries> retrieveTimeSeries(List<FsId> fsIds,
        int startCadence, int endCadence) {

        if (log.isDebugEnabled()) {
            log.debug("readTimeSeriesAsFloat(): fsIds[0]=" + fsIds.get(0)
                + "; fsIds.length=" + fsIds.size() + "; startCadence="
                + startCadence + "; endCadence=" + endCadence);
        }
        FloatTimeSeries[] timeSeriesArray = FileStoreClientFactory.getInstance()
            .readTimeSeriesAsFloat(fsIds.toArray(new FsId[0]), startCadence,
                endCadence);
        addToDataAccountability(timeSeriesArray, producerTaskIds);
        return getTimeSeriesByFsId(timeSeriesArray);
    }

    private void storePrfBlob(String prfBlobFileName) {

        log.debug("[" + getModuleName() + "]store prf metadata.");
        // Create and populate the MATLAB blob's metadata object.
        PrfBlobMetadata metadata = new PrfBlobMetadata(pipelineTask.getId(),
            task.getCcdModule(), task.getCcdOutput(), task.getStartCadence(),
            task.getEndCadence(), FilenameUtils.getExtension(prfBlobFileName));

        // Store the MATLAB blob's metadata in the database.
        getPrfCrud().createPrfBlobMetadata(metadata);

        log.debug("[" + getModuleName() + "]store prf blob.");
        // Write the MATLAB blob to the file store.
        FsId blobFsId = PrfFsIdFactory.getMatlabBlobFsId(
            PrfFsIdFactory.BlobSeriesType.PRF_COLLECTION, task.getCcdModule(),
            task.getCcdOutput(), task.getStartCadence(), pipelineTask.getId());
        File prfBlobFile = new File(getMatlabWorkingDir(), prfBlobFileName);
        FileStoreClientFactory.getInstance()
            .writeBlob(blobFsId, pipelineTask.getId(), prfBlobFile);

        // do not remove overlapped metadata - need to retain history
    }

    private void storeMotionPolyBlob(String motionBlobFileName) {

        log.debug("[" + getModuleName() + "]store motion  metadata.");
        // Create and populate the MATLAB blob's metadata object.
        MotionBlobMetadata metadata = new MotionBlobMetadata(
            pipelineTask.getId(), task.getCcdModule(), task.getCcdOutput(),
            task.getStartCadence(), task.getEndCadence(),
            FilenameUtils.getExtension(motionBlobFileName));

        // Store the MATLAB blob's metadata in the database.
        getPaCrud().createMotionBlobMetadata(metadata);

        log.debug("[" + getModuleName() + "]store motion blob.");
        // Write the MATLAB blob to the file store.
        FsId blobFsId = PaFsIdFactory.getMatlabBlobFsId(
            PaFsIdFactory.BlobSeriesType.MOTION, task.getCcdModule(),
            task.getCcdOutput(), pipelineTask.getId());
        File motionBlobFile = new File(getMatlabWorkingDir(),
            motionBlobFileName);
        FileStoreClientFactory.getInstance()
            .writeBlob(blobFsId, pipelineTask.getId(), motionBlobFile);

        // do not remove overlapped metadata - need to retain history
    }

    private void storePrfCentroidTimeSeries(
        List<PrfCentroidTimeSeries> centroids) {

        List<FloatTimeSeries> allTimeSeries = new ArrayList<FloatTimeSeries>();

        for (PrfCentroidTimeSeries centroid : centroids) {

            allTimeSeries.addAll(centroid.getAllFloatTimeSeries(
                task.getStartCadence(), task.getEndCadence(),
                pipelineTask.getId()));
        }

        if (allTimeSeries.size() > 0) {
            FloatTimeSeries[] timeSeries = allTimeSeries.toArray(new FloatTimeSeries[0]);
            FileStoreClientFactory.getInstance()
                .writeTimeSeries(timeSeries);
        }

    }

    private static Map<FsId, FloatTimeSeries> getTimeSeriesByFsId(
        FloatTimeSeries[] timeSeriesArray) {

        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>();
        for (FloatTimeSeries timeSeries : timeSeriesArray) {
            if (timeSeries.exists()) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            }
        }
        return timeSeriesByFsId;
    }

    /**
     * Add originator in the blob result to {@code producerTaskIds}.
     * 
     * @param blobResult the blob result.
     * @param producerTaskIds the producer task IDs.
     * @throws NullPointerException if either {@code timeSeries} or
     * {@code producerTaskIds} is {@code null}.
     */
    static void addToDataAccountability(BlobResult blobResult,
        Set<Long> producerTaskIds) {

        producerTaskIds.add(blobResult.originator());
    }

    /**
     * Add originator in the time series to {@code producerTaskIds}.
     * 
     * @param timeSeries the time series.
     * @param producerTaskIds the producer task IDs.
     * @throws NullPointerException if either {@code timeSeries} or
     * {@code producerTaskIds} is {@code null}.
     */
    static void addToDataAccountability(TimeSeries timeSeries,
        Set<Long> producerTaskIds) {

        producerTaskIds.addAll(timeSeries.uniqueOriginators());
    }

    /**
     * Adds every originator for all the time series to {@code producerTaskIds}.
     * 
     * @param timeSeries all the time series.
     * @param producerTaskIds the producer task IDs.
     * @throws NullPointerException if either {@code timeSeries} or
     * {@code producerTaskIds} is {@code null}.
     */
    private static void addToDataAccountability(TimeSeries[] timeSeries,
        Set<Long> producerTaskIds) {

        for (TimeSeries ts : timeSeries) {
            addToDataAccountability(ts, producerTaskIds);
        }
    }

    private BlobOperations getBlobOperations() {
        if (blobOperations == null) {
            blobOperations = new BlobOperations(getMatlabWorkingDir());
        }
        return blobOperations;
    }

    /**
     * Only used for mocking.
     */
    void setBlobOperations(BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    private ConfigMapOperations getConfigMapOperations() {
        if (configMapOperations == null) {
            configMapOperations = new ConfigMapOperations();
        }
        return configMapOperations;
    }

    /**
     * Only used for mocking.
     */
    void setConfigMapOperations(ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
    }

    private DataAccountabilityTrailCrud getDaCrud() {
        if (daCrud == null) {
            daCrud = new DataAccountabilityTrailCrud(
                DatabaseServiceFactory.getInstance());
        }
        return daCrud;
    }

    /**
     * Only used for mocking.
     */
    void setDaCrud(DataAccountabilityTrailCrud daCrud) {
        this.daCrud = daCrud;
    }

    PrfInputs getInputs() {
        return inputs;
    }

    PrfOutputs getOutputs() {
        return outputs;
    }

    private CelestialObjectOperations getCelestialObjectOperations() {
        if (celestialObjectOperations == null) {
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance),
                !pipelineTask.getParameters(CustomTargetParameters.class)
                    .isProcessingEnabled());
        }
        return celestialObjectOperations;
    }

    /**
     * Only used for mocking.
     */
    void setCelestialObjectOperations(
        CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    protected File getMatlabWorkingDir() {
        if (matlabWorkingDir == null) {
            matlabWorkingDir = allocateWorkingDir(pipelineTask);
        }
        return matlabWorkingDir;
    }

    void setMatlabWorkingDir(File workingDir) {
        matlabWorkingDir = workingDir;
    }

    private PaCrud getPaCrud() {
        if (paCrud == null) {
            paCrud = new PaCrud();
        }
        return paCrud;
    }

    /**
     * Only used for mocking.
     */
    public void setPaCrud(PaCrud paCrud) {
        this.paCrud = paCrud;
    }

    /**
     * Sets this module's pipeline instance. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    void setPipelineInstance(PipelineInstance pipelineInstance) {
        if (pipelineInstance == null) {
            throw new NullPointerException("pipelineInstance can't be null");
        }

        this.pipelineInstance = pipelineInstance;
        if (pipelineTask != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    /**
     * Sets this module's pipeline task. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineTask the non-{@code null} pipeline task.
     * @throws PipelineException if {@code UowTask} could not be extracted from
     * {@link PipelineTask}.
     */
    public void setPipelineTask(PipelineTask pipelineTask) {
        this.pipelineTask = pipelineTask;
        task = pipelineTask.uowTaskInstance();
        if (pipelineInstance != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    private PrfCrud getPrfCrud() {
        if (prfCrud == null) {
            prfCrud = new PrfCrud();
        }
        return prfCrud;
    }

    /**
     * Only used for mocking.
     */
    void setPrfCrud(PrfCrud prfCrud) {
        this.prfCrud = prfCrud;
    }

    private RaDec2PixOperations getRaDec2PixOperations() {
        if (raDec2PixOperations == null) {
            raDec2PixOperations = new RaDec2PixOperations();
        }
        return raDec2PixOperations;
    }

    /**
     * Only used for mocking.
     */
    void setRaDec2PixOperations(RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    private TargetCrud getTargetCrud() {
        if (targetCrud == null) {
            targetCrud = new TargetCrud();
        }
        return targetCrud;
    }

    /**
     * Only used for mocking.
     */
    void setTargetCrud(TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }

    void setDoubleDbTimeSeriesCrud(DoubleDbTimeSeriesCrud ddtsc) {
        doubleTsCrud = ddtsc;
    }

    private DoubleDbTimeSeriesCrud getDoubleDbTimeSeriesCrud() {
        if (doubleTsCrud == null) {
            doubleTsCrud = new DoubleDbTimeSeriesCrud();
        }
        return doubleTsCrud;
    }

}
