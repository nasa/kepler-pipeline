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

package gov.nasa.kepler.pa;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Lists.newArrayListWithExpectedSize;
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Maps.newHashMapWithExpectedSize;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.collect.Sets.newHashSetWithExpectedSize;
import static com.google.common.collect.Sets.newTreeSet;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.KeplerSocBranch;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.pi.ModelMetadata;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsLiteDbResult;
import gov.nasa.kepler.mc.CalibratedPixel;
import gov.nasa.kepler.mc.MatlabCallState;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.RollingBandArtifactFlags;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.blob.BlobData;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.RmsCdpp;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.tip.TipImporter;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Retrieves {@link PaInputs}.
 * 
 * @author Forrest Girouard
 * @author Miles Cote
 * 
 */
public class PaInputsRetriever extends PaIoProcessor {

    /**
     * Logger for this class
     */
    static final Log log = LogFactory.getLog(PaInputsRetriever.class);

    private boolean firstCall = true;
    private boolean generateMotionPolynomials;
    private boolean done;

    private PaInputs paInputs;

    private List<ConfigMap> configMaps;
    private PrfModel prfModel;
    private RaDec2PixModel raDec2PixModel;
    private ReadNoiseModel readNoiseModel;
    private GainModel gainModel;
    private LinearityModel linearityModel;

    private int observingSeason;
    private int skyGroupId;
    private String transitInjectionParametersFileName = "";

    private int startLongCadence;
    private int endLongCadence;
    private int ppaTargetCount;
    private PaTargetOperations targetOperations;
    private TargetBatchManager ppaTargetBatchManager;
    private TargetBatchManager targetBatchManager;
    private TimestampSeries longCadenceTimes;

    public PaInputsRetriever(PipelineTask pipelineTask, int ccdModule,
        int ccdOutput) {
        super(pipelineTask, ccdModule, ccdOutput);
    }

    public boolean isEmpty() {
        if (cadenceType == null) {
            cadenceType = CadenceType.valueOf(pipelineTask.getParameters(
                CadenceTypePipelineParameters.class)
                .getCadenceType());
        }

        if (paParameters == null) {
            retrieveParameters();
        }

        if (targetTable == null) {
            initializeTargetTable();
        }

        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, ccdModule, ccdOutput);

        return observedTargets.isEmpty();
    }

    public boolean hasNext() {
        return !done;
    }

    public PaInputs retrieveInputs(File matlabWorkingDir) {

        if (cadenceType == null) {
            cadenceType = CadenceType.valueOf(pipelineTask.getParameters(
                CadenceTypePipelineParameters.class)
                .getCadenceType());
        }

        if (paParameters == null) {
            retrieveParameters();
        }

        if (targetTable == null) {
            initializeTargetTable();
        }

        if (cadenceType == CadenceType.LONG) {

            log.info("paParameters.isPaCoaEnabled(): "
                + paParameters.isPaCoaEnabled());

            if (paParameters.isPaCoaEnabled()) {
                if (targetListSet == null) {
                    initializeTargetListSet();
                }

                validate();

                if (observedTargets == null) {
                    initializeObservedTargets();
                }

                int channel = FcConstants.getChannelNumber(ccdModule, ccdOutput);
                keplerIdToKicEntryData = getKeplerIdToKicEntryData(channel, this);
            }

            processLongCadenceSet(matlabWorkingDir);
        } else {
            processShortCadenceSet(matlabWorkingDir);
        }

        if (paInputs != null) {
            PaPipelineModule.ProcessingState state = PaPipelineModule.ProcessingState.valueOf(paInputs.getProcessingState());
            if (state == PaPipelineModule.ProcessingState.BACKGROUND) {
                localData.getFsIdsStream()
                    .write(DataSetType.Background, matlabWorkingDir,
                        localData.getAllBackgroundCosmicRayFsIds());
            }
            if ((state == PaPipelineModule.ProcessingState.AGGREGATE_RESULTS || state == PaPipelineModule.ProcessingState.GENERATE_MOTION_POLYNOMIALS)
                && paInputs.isLastCall()) {
                localData.getFsIdsStream()
                    .write(DataSetType.Target, matlabWorkingDir,
                        localData.getAllTargetCosmicRayFsIds());
            }
            localData.getTimestampSeriesStream()
                .write(matlabWorkingDir, cadenceTimes);
            localData.getMatlabCallStateStream()
                .write(
                    matlabWorkingDir,
                    new MatlabCallState(paInputs.isFirstCall(),
                        paInputs.isLastCall()));
        }

        return paInputs;
    }

    private void processLongCadenceSet(File matlabWorkingDir) {

        if (done) {
            paInputs = null;

            return;
        }

        if (firstCall) {
            if (paParameters.isSimulatedTransitsEnabled()
                && KeplerSocBranch.isRelease()) {
                throw new ModuleFatalProcessingException(
                    "Can't enable simulated transits for released code.");
            }
            if (paParameters.isSimulatedTransitsEnabled()
                && paParameters.isOnlyProcessPpaTargetsEnabled()) {
                throw new ModuleFatalProcessingException(
                    "Can't enable both simulated transits and only process PPA targets.");
            }
            if (paParameters.isOnlyProcessPpaTargetsEnabled()
                && paParameters.isMotionBlobsInputEnabled()) {
                throw new ModuleFatalProcessingException(
                    "Can't enable both motion blobs input and only process PPA targets.");
            }

            log.info("[" + getModuleName() + "]retrieve cadence times.");
            cadenceTimes = retrieveCadenceTimes(cadenceType,
                task.getStartCadence(), task.getEndCadence());

            retrieveModels();

            log.info("[" + getModuleName() + "]set blob operations directory: "
                + matlabWorkingDir);
            getBlobOperations().setOutputDir(matlabWorkingDir);

            if (paParameters.isSimulatedTransitsEnabled()) {

                log.info("[" + getModuleName()
                    + "]retrieve transit injection parameters.");
                observingSeason = getRollTimeOperations().mjdToSeason(
                    cadenceTimes.startMjd());
                skyGroupId = getKicCrud().retrieveSkyGroupId(ccdModule,
                    ccdOutput, observingSeason);
                transitInjectionParametersFileName = retrieveTransitInjectionParametersFileName();
                log.info("[" + getModuleName()
                    + "]transitInjectionParametersFileName: "
                    + transitInjectionParametersFileName);
            }

            longCadenceTimes = cadenceTimes;

            paInputs = createPaInputs(longCadenceTimes);

            startLongCadence = paInputs.getLongCadenceTimes().cadenceNumbers[0];
            endLongCadence = paInputs.getLongCadenceTimes().cadenceNumbers[paInputs.getLongCadenceTimes().cadenceNumbers.length - 1];

            retrieveAncillaryData();
            retrieveCalUncertainties();

            if (paParameters.isSimulatedTransitsEnabled()) {

                log.info("[" + getModuleName() + "]retrieve background blobs.");
                BlobSeries<String> backgroundBlobs = retrieveBackgroundBlobFileSeries(
                    startLongCadence, endLongCadence);
                paInputs.setBackgroundBlobs(new BlobFileSeries(backgroundBlobs));
            }

            if (paParameters.isSimulatedTransitsEnabled()
                || paParameters.isMotionBlobsInputEnabled()) {

                log.info("[" + getModuleName() + "]retrieve motion blobs.");
                BlobSeries<String> motionBlobs = retrieveMotionBlobFileSeries(
                    startLongCadence, endLongCadence);
                paInputs.setMotionBlobs(new BlobFileSeries(motionBlobs));
            }

            targetOperations = new PaTargetOperations(targetTable,
                backgroundTable == null ? null : backgroundTable, ccdModule,
                ccdOutput, getCelestialObjectOperations());
            targetOperations.setTargetCrud(targetCrud);

            log.info("[" + getModuleName() + "]retrieve background targets.");
            List<PaPixelTimeSeries> backgroundPixelTimeSeries = retrieveBackgroundPixelTimeSeries(
                targetOperations, task.getStartCadence(), task.getEndCadence());
            paInputs.setBackgroundPixels(backgroundPixelTimeSeries);

            firstCall = false;

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.BACKGROUND.toString());

            return;
        }

        if (ppaTargetBatchManager == null) {
            log.info("[" + getModuleName() + "]determine PPA targets.");
            List<PaTarget> targets = targetOperations.getPpaTargets();

            log.info("[" + getModuleName()
                + "]update targets with celestial parameters.");
            targetOperations.updateTargetsWithCelestialParameters(targets);

            log.info("[" + getModuleName()
                + "]update targets with nearby celestial parameters.");
            // targetOperations.updateTargetsWithNearbyCelestialParameters(targets);

            ppaTargetCount = targets.size();

            log.info("[" + getModuleName() + "] PPA target count: "
                + ppaTargetCount);

            ppaTargetBatchManager = new TargetBatchManager(targets,
                paParameters.getMaxPixelSamples(),
                paParameters.getMaxReadFsIds(), ccdModule, ccdOutput,
                task.getStartCadence(), task.getEndCadence());
        }

        paInputs = createPaInputs(longCadenceTimes);

        paInputs.setPpaTargetCount(ppaTargetCount);

        if (ppaTargetBatchManager.hasNext()) {
            List<PaTarget> nextTargets = ppaTargetBatchManager.nextBatch();

            log.info("[" + getModuleName()
                + "] Get rolling band artifacts flags. ");
            List<RollingBandArtifactFlags> rollingBandArtifactFlags = PaCommonInputsRetriever.retrieveRollingBandArtifactFlags(
                ccdModule, ccdOutput, startLongCadence, endLongCadence,
                getAllRows(nextTargets), getAllDurations(),
                getProducerTaskIds());
            paInputs.setRollingBandArtifactFlags(rollingBandArtifactFlags);

            paInputs.setTargets(nextTargets);
            log.info("[" + getModuleName() + "] Current target batch count: "
                + nextTargets.size());
            getProducerTaskIds().addAll(
                ppaTargetBatchManager.latestProducerTaskIds());

            if (paInputs.getPaModuleParameters()
                .isSimulatedTransitsEnabled()) {

                log.info("[" + getModuleName() + "] Retrieve rmsCdpp. ");
                retrieveRmsCdpp(nextTargets);
            }

            generateMotionPolynomials = !ppaTargetBatchManager.hasNext();

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.PPA_TARGETS.toString());

            return;
        }

        if (generateMotionPolynomials) {
            generateMotionPolynomials = false;

            if (paInputs.getPaModuleParameters()
                .isOnlyProcessPpaTargetsEnabled()) {
                done = true;
                paInputs.setLastCall(true);
            }

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.GENERATE_MOTION_POLYNOMIALS.toString());

            return;
        }

        if (targetBatchManager == null) {
            log.info("[" + getModuleName() + "]determine PA targets.");

            List<PaTarget> targets = targetOperations.getAllTargets();
            log.info("[" + getModuleName() + "] Target count: "
                + targets.size());

            log.info("[" + getModuleName()
                + "]update targets with celestial parameters.");
            targetOperations.updateTargetsWithCelestialParameters(targets);

            if (pseudoTargetListParameters.getTargetListNames() != null
                && pseudoTargetListParameters.getTargetListNames().length > 0) {

                log.info("[" + getModuleName() + "]determine pseudo PA targets");
                observingSeason = getRollTimeOperations().mjdToSeason(
                    cadenceTimes.startMjd());
                skyGroupId = getKicCrud().retrieveSkyGroupId(ccdModule,
                    ccdOutput, observingSeason);
                List<PaTarget> pseudoTargets = createPseudoTargets(
                    pseudoTargetListParameters.getTargetListNames(), skyGroupId);
                log.info("[" + getModuleName() + "] Pseudo target count: "
                    + pseudoTargets.size());
                targets.addAll(pseudoTargets);
            }

            targetBatchManager = new TargetBatchManager(targets,
                paParameters.getMaxPixelSamples(),
                paParameters.getMaxReadFsIds(), ccdModule, ccdOutput,
                task.getStartCadence(), task.getEndCadence());
        }

        if (!targetBatchManager.hasNext()) {
            paInputs.setLastCall(true);
            done = true;

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.AGGREGATE_RESULTS.toString());

            return;
        }

        List<PaTarget> nextTargets = targetBatchManager.nextBatch();

        log.info("[" + getModuleName() + "] Get rolling band artifacts flags. ");
        List<RollingBandArtifactFlags> rollingBandArtifactFlags = PaCommonInputsRetriever.retrieveRollingBandArtifactFlags(
            ccdModule, ccdOutput, startLongCadence, endLongCadence,
            getAllRows(nextTargets), getAllDurations(), getProducerTaskIds());
        paInputs.setRollingBandArtifactFlags(rollingBandArtifactFlags);

        if (paParameters.isPaCoaEnabled()) {
            log.info("[" + getModuleName()
                + "] Update targets with nearby KICS. ");
            updateTargetsWithNearbyKics(nextTargets);
            log.info("[" + getModuleName() + "] Update targets with KIC data. ");
            updateTargetsWithKicEntryData(keplerIdToKicEntryData, nextTargets);
        }

        paInputs.setTargets(nextTargets);
        log.info("[" + getModuleName() + "] Current target batch count: "
            + nextTargets.size());
        getProducerTaskIds().addAll(targetBatchManager.latestProducerTaskIds());
        localData.getAllTargetCosmicRayFsIds()
            .addAll(
                PaCommonInputsRetriever.createTargetBatchCosmicRayFsIds(nextTargets));

        if (paInputs.getPaModuleParameters()
            .isSimulatedTransitsEnabled()) {

            log.info("[" + getModuleName() + "] Retrieve rmsCdpp. ");
            retrieveRmsCdpp(nextTargets);
        }

        paInputs.setProcessingState(PaPipelineModule.ProcessingState.TARGETS.toString());

        return;
    }

    private void processShortCadenceSet(File matlabWorkingDir) {

        if (done) {
            paInputs = null;

            return;
        }

        if (firstCall) {
            if (paParameters.isSimulatedTransitsEnabled()) {
                throw new ModuleFatalProcessingException(
                    "Can't enable simulated transits for short cadence.");
            }
            if (paParameters.isOnlyProcessPpaTargetsEnabled()) {
                throw new ModuleFatalProcessingException(
                    "Can't enable only process PPA targets for short cadence.");
            }

            log.info("[" + getModuleName() + "]retrieve cadence times.");
            cadenceTimes = retrieveCadenceTimes(cadenceType,
                task.getStartCadence(), task.getEndCadence());

            retrieveModels();

            log.info("[" + getModuleName() + "]set blob operations directory: "
                + matlabWorkingDir);
            getBlobOperations().setOutputDir(matlabWorkingDir);

            Pair<Integer, Integer> longCadenceInterval = shortCadenceToLongCadence(
                getLogCrud(), task.getStartCadence(), task.getEndCadence());
            startLongCadence = longCadenceInterval.left;
            endLongCadence = longCadenceInterval.right;

            log.info("[" + getModuleName() + "]retrieve long cadence times.");
            longCadenceTimes = retrieveLongCadenceTimes(startLongCadence,
                endLongCadence);

            paInputs = createPaInputs(longCadenceTimes);

            startLongCadence = paInputs.getLongCadenceTimes().cadenceNumbers[0];
            endLongCadence = paInputs.getLongCadenceTimes().cadenceNumbers[paInputs.getLongCadenceTimes().cadenceNumbers.length - 1];

            retrieveAncillaryData();
            retrieveCalUncertainties();

            log.info("[" + getModuleName() + "]retrieve background blobs.");
            BlobSeries<String> backgroundBlobs = retrieveBackgroundBlobFileSeries(
                startLongCadence, endLongCadence);
            paInputs.setBackgroundBlobs(new BlobFileSeries(backgroundBlobs));

            log.info("[" + getModuleName() + "]retrieve motion blobs.");
            BlobSeries<String> motionBlobs = retrieveMotionBlobFileSeries(
                startLongCadence, endLongCadence);
            paInputs.setMotionBlobs(new BlobFileSeries(motionBlobs));
        }

        if (targetBatchManager == null) {
            targetOperations = new PaTargetOperations(targetTable,
                backgroundTable == null ? null : backgroundTable, ccdModule,
                ccdOutput, getCelestialObjectOperations());
            targetOperations.setTargetCrud(targetCrud);

            log.info("[" + getModuleName() + "]determine PA targets.");
            List<PaTarget> targets = targetOperations.getAllTargets();

            log.info("[" + getModuleName() + "] Target count: "
                + targets.size());

            targetBatchManager = new TargetBatchManager(targets,
                paParameters.getMaxPixelSamples(),
                paParameters.getMaxReadFsIds(), ccdModule, ccdOutput,
                task.getStartCadence(), task.getEndCadence());
        }

        if (!firstCall) {
            paInputs = createPaInputs(longCadenceTimes);
        }

        if (!targetBatchManager.hasNext()) {
            paInputs.setLastCall(true);

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.AGGREGATE_RESULTS.toString());
            done = true;

            return;
        }

        List<PaTarget> nextTargets = targetBatchManager.nextBatch();

        log.info("[" + getModuleName()
            + "]update targets with celestial parameters.");
        targetOperations.updateTargetsWithCelestialParameters(nextTargets);

        paInputs.setTargets(nextTargets);
        log.info("[" + getModuleName() + "] Current target batch count: "
            + nextTargets.size());

        if (firstCall) {
            targetBatchManager.reset();
            paInputs.setProcessingState(PaPipelineModule.ProcessingState.MOTION_BACKGROUND_BLOBS.toString());
            firstCall = false;
        } else {
            getProducerTaskIds().addAll(
                targetBatchManager.latestProducerTaskIds());
            localData.getAllTargetCosmicRayFsIds()
                .addAll(
                    PaCommonInputsRetriever.createTargetBatchCosmicRayFsIds(nextTargets));
            paInputs.setProcessingState(PaPipelineModule.ProcessingState.TARGETS.toString());
        }

        return;
    }

    private void retrieveModels() {

        log.info("[" + getModuleName() + "]retrieve config maps.");
        configMaps = retrieveConfigMaps(cadenceTimes);

        log.info("[" + getModuleName() + "]retrieve PRF model.");
        prfModel = getPrfOperations().retrievePrfModel(cadenceTimes.startMjd(),
            ccdModule, ccdOutput);

        log.info("[" + getModuleName() + "]retrieve RaDec2Pix model.");
        raDec2PixModel = getRaDec2PixOperations().retrieveRaDec2PixModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        log.info("[" + getModuleName() + "]retrieve ReadNoise model.");
        readNoiseModel = getReadNoiseOperations().retrieveReadNoiseModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        log.info("[" + getModuleName() + "]retrieve Gain model.");
        gainModel = getGainOperations().retrieveGainModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        log.info("[" + getModuleName() + "]retrieve Linearity model.");
        linearityModel = getLinearityOperations().retrieveLinearityModel(
            ccdModule, ccdOutput, cadenceTimes.startMjd(),
            cadenceTimes.endMjd());
    }

    private TimestampSeries retrieveCadenceTimes(final CadenceType cadenceType,
        final int startCadence, final int endCadence) {

        MjdToCadence.TimestampSeries tsSeries = getMjdToCadence().cadenceTimes(
            startCadence, endCadence);

        return tsSeries;
    }

    /**
     * Used only in the short cadence case to retrieve the long cadence mjds.
     */
    private TimestampSeries retrieveLongCadenceTimes(int startCadence,
        int endCadence) {

        TimestampSeries cadenceTimes = getMjdToLongCadence().cadenceTimes(
            startCadence, endCadence);
        return cadenceTimes;

    }

    private void retrieveCalUncertainties() {
        log.info("[" + getModuleName() + "]retrieve CAL uncertainties blobs.");
        BlobSeries<String> calUncertaintyBlobs = getBlobOperations().retrieveCalUncertaintiesBlobFileSeries(
            ccdModule, ccdOutput, cadenceType, task.getStartCadence(),
            task.getEndCadence());
        paInputs.setCalUncertaintyBlobs(new BlobFileSeries(calUncertaintyBlobs));
        getProducerTaskIds().addAll(
            Arrays.asList(ArrayUtils.toObject(calUncertaintyBlobs.blobOriginators())));
    }

    private List<PaPixelTimeSeries> retrieveBackgroundPixelTimeSeries(
        final SciencePixelOperations timeSeriesOps, final int startCadence,
        final int endCadence) {

        Set<Pixel> backgroundPixels = timeSeriesOps.getBackgroundPixels();
        Set<FsId> fsIds = newTreeSet();
        Pixel maxPixel = new Pixel(0, 0);
        Pixel minPixel = new Pixel(FcConstants.CCD_ROWS,
            FcConstants.CCD_COLUMNS);
        log.debug("background pixel count: " + backgroundPixels.size());
        for (Pixel pixel : backgroundPixels) {
            if (log.isDebugEnabled()) {
                maxPixel = new Pixel(
                    Math.max(maxPixel.getRow(), pixel.getRow()), Math.max(
                        maxPixel.getColumn(), pixel.getColumn()));
                minPixel = new Pixel(
                    Math.min(minPixel.getRow(), pixel.getRow()), Math.min(
                        minPixel.getColumn(), pixel.getColumn()));
            }
            fsIds.addAll(pixel.getFsIds());
            localData.getAllBackgroundCosmicRayFsIds()
                .add(
                    PaFsIdFactory.getCosmicRaySeriesFsId(TargetType.BACKGROUND,
                        ccdModule, ccdOutput, pixel.getRow(), pixel.getColumn()));
        }
        if (log.isDebugEnabled()) {
            log.debug("min pixel: " + minPixel);
            log.debug("max pixel: " + maxPixel);
        }
        FloatTimeSeries[] backgroundTimeSeries = timeSeriesOps.readPixelTimeSeriesAsFloat(
            fsIds.toArray(new FsId[fsIds.size()]), startCadence, endCadence);
        TimeSeriesOperations.addToDataAccountability(backgroundTimeSeries,
            getProducerTaskIds());
        Map<FsId, FloatTimeSeries> timeSeriesByFsId = TimeSeriesOperations.getFloatTimeSeriesByFsId(backgroundTimeSeries);
        List<PaPixelTimeSeries> backgroundPixelTimeSeries = newArrayList();
        for (Pixel pixel : backgroundPixels) {
            PaPixelTimeSeries pixelTimeSeries = new PaPixelTimeSeries(
                pixel.getRow(), pixel.getColumn(), true);
            pixelTimeSeries.setAllTimeSeries(TargetType.BACKGROUND, ccdModule,
                ccdOutput, timeSeriesByFsId);
            if (pixelTimeSeries.size() == 0) {
                log.error("calibrated time series missing: " + pixelTimeSeries);
            } else {
                backgroundPixelTimeSeries.add(pixelTimeSeries);
            }
        }
        if (log.isDebugEnabled()) {
            log.debug("background pixel time series count: "
                + backgroundPixelTimeSeries.size());
            for (PaPixelTimeSeries pixel : backgroundPixelTimeSeries) {
                maxPixel = new Pixel(Math.max(maxPixel.getRow(),
                    pixel.getCcdRow()), Math.max(maxPixel.getColumn(),
                    pixel.getCcdColumn()));
                minPixel = new Pixel(Math.min(minPixel.getRow(),
                    pixel.getCcdRow()), Math.min(minPixel.getColumn(),
                    pixel.getCcdColumn()));
            }
            log.debug("min pixel: " + minPixel);
            log.debug("max pixel: " + maxPixel);
        }

        return backgroundPixelTimeSeries;
    }

    private void retrieveAncillaryData() {
        List<AncillaryEngineeringData> ancillaryEngineeringData = newArrayList();
        if (paInputs.getPaModuleParameters()
            .isOapEnabled()) {
            log.info("[" + getModuleName()
                + "]retrieve OAP ancillary engineering data.");
            ancillaryEngineeringData.addAll(PaCommonInputsRetriever.retrieveAncillaryEngineeringData(
                getAncillaryOperations(), cadenceTimes.startMjd(),
                cadenceTimes.endMjd(), oapAncillaryEngineeringParameters,
                getProducerTaskIds()));

            log.info("[" + getModuleName()
                + "]retrieve ancillary pipeline data.");
            List<AncillaryPipelineData> ancillaryPipelineData = PaCommonInputsRetriever.retrieveAncillaryPipelineData(
                getAncillaryOperations(), targetTable, ccdModule, ccdOutput,
                cadenceTimes, ancillaryPipelineParameters, getProducerTaskIds());
            paInputs.setAncillaryPipelineData(ancillaryPipelineData);
        }

        log.info("[" + getModuleName()
            + "]retrieve reaction wheel ancillary engineering data.");
        ancillaryEngineeringData.addAll(PaCommonInputsRetriever.retrieveAncillaryEngineeringData(
            getAncillaryOperations(), cadenceTimes.startMjd(),
            cadenceTimes.endMjd(), reactionWheelAncillaryEngineeringParameters,
            getProducerTaskIds()));

        log.info("[" + getModuleName()
            + "]retrieve thruster data ancillary engineering data.");
        ancillaryEngineeringData.addAll(PaCommonInputsRetriever.retrieveAncillaryEngineeringData(
            getAncillaryOperations(), cadenceTimes.startMjd(),
            cadenceTimes.endMjd(), thrusterDataAncillaryEngineeringParameters,
            getProducerTaskIds(), false));

        paInputs.setAncillaryEngineeringData(ancillaryEngineeringData);
    }

    private List<ConfigMap> retrieveConfigMaps(
        final TimestampSeries cadenceTimes) {

        List<ConfigMap> configMaps = getConfigMapOperations().retrieveConfigMaps(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        if (configMaps == null || configMaps.isEmpty()) {
            throw new ModuleFatalProcessingException(
                "Need at least one spacecraft config map, but found none.");
        }

        return configMaps;
    }

    private String retrieveTransitInjectionParametersFileName() {

        ModelMetadata tipModelMetadata = getModelMetadataRetrieverPipelineInstance().retrieve(
            TipImporter.MODEL_TYPE);
        if (tipModelMetadata == null) {
            throw new IllegalStateException("TIP model metadata does not exist");
        }

        BlobData<String> retrieveTipBlobFile = getBlobOperations().retrieveTipBlobFile(
            skyGroupId, tipModelMetadata.getImportTime()
                .getTime());

        return retrieveTipBlobFile.getBlobFileName();
    }

    private PaInputs createPaInputs(TimestampSeries longCadenceTimes) {

        PaInputs paInputs = new PaInputs(ccdModule, ccdOutput,
            cadenceType.toString(), task.getStartCadence(),
            task.getEndCadence(), cadenceTimes, configMaps, prfModel,
            raDec2PixModel, readNoiseModel, gainModel, linearityModel,
            transitInjectionParametersFileName, firstCall,
            ancillaryDesignMatrixParameters, ancillaryPipelineParameters,
            apertureModelParameters, argabrighteningParameters,
            backgroundParameters, paCosmicRayParameters,
            encircledEnergyParameters, gapFillParameters,
            motionModuleParameters, oapAncillaryEngineeringParameters,
            paCoaModuleParameters, paHarmonicsIdentificationParameters,
            paParameters, pouParameters,
            reactionWheelAncillaryEngineeringParameters,
            saturationSegmentModuleParameters,
            thrusterDataAncillaryEngineeringParameters, longCadenceTimes);

        if (paParameters.isPaCoaEnabled()
            && !paParameters.isOnlyProcessPpaTargetsEnabled()
            && cadenceType == CadenceType.LONG) {
            paInputs.setStartTime(startTime);
            paInputs.setDuration(durationDays);
        }

        return paInputs;
    }

    private void retrieveRmsCdpp(List<PaTarget> targets) {

        List<Integer> keplerIds = newArrayList();
        for (PaTarget target : targets) {
            keplerIds.add(target.getKeplerId());
        }
        List<TpsLiteDbResult> tpsResults = getTpsCrud().retrieveAllLatestTpsLiteResults(
            keplerIds);

        Map<Integer, List<RmsCdpp>> rmsCdppsByKeplerId = newHashMap();
        for (TpsLiteDbResult tpsResult : tpsResults) {
            if (tpsResult.getRmsCdpp() != null) {
                List<RmsCdpp> rmsCdpps = rmsCdppsByKeplerId.get(tpsResult.getKeplerId());
                if (rmsCdpps == null) {
                    rmsCdpps = newArrayList();
                    rmsCdppsByKeplerId.put(tpsResult.getKeplerId(), rmsCdpps);
                }
                rmsCdpps.add(new RmsCdpp(tpsResult.getRmsCdpp(),
                    tpsResult.getTrialTransitPulseInHours()));
            }
        }

        int count = 0;
        for (PaTarget target : targets) {
            List<RmsCdpp> rmsCdpps = rmsCdppsByKeplerId.get(target.getKeplerId());
            if (rmsCdpps == null || rmsCdpps.size() == 0) {
                log.warn(String.format(
                    "Kepler ID %d does not have TpsLite results",
                    target.getKeplerId()));
                count++;
            } else {
                target.setRmsCdpp(rmsCdpps);
            }
        }
        if (count > 0) {
            log.info(String.format(
                "%d out of %d targets do not have TpsLite results", count,
                targets.size()));
        }
    }

    private static PaTarget createPaTarget(int ccdModule, int ccdOutput,
        PlannedTarget plannedTarget) {

        int keplerId = plannedTarget.getKeplerId();

        String[] labels = ArrayUtils.EMPTY_STRING_ARRAY;
        if (plannedTarget.getLabels() != null && plannedTarget.getLabels()
            .size() > 0) {
            labels = plannedTarget.getLabels()
                .toArray(new String[0]);
        }

        Aperture aperture = plannedTarget.getAperture();
        int referenceRow = aperture.getReferenceRow();
        int referenceColumn = aperture.getReferenceColumn();

        Set<Pixel> pixels = newHashSetWithExpectedSize(aperture.getPixelCount());
        for (Offset offset : aperture.getOffsets()) {
            int row = referenceRow + offset.getRow();
            int column = referenceColumn + offset.getColumn();
            FsId fsId = CalFsIdFactory.getTimeSeriesFsId(
                PixelTimeSeriesType.SOC_CAL, TargetType.LONG_CADENCE,
                ccdModule, ccdOutput, row, column);
            FsId uncertaintiesFsId = CalFsIdFactory.getTimeSeriesFsId(
                PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, row, column);
            FsId cosmicRayEventsFsId = PaFsIdFactory.getCosmicRaySeriesFsId(
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, row, column);

            pixels.add(new CalibratedPixel(row, column, fsId,
                uncertaintiesFsId, cosmicRayEventsFsId, true));
        }

        return new PaTarget(keplerId, referenceRow, referenceColumn, labels,
            DEFAULT_FLUX_FRACTION_IN_APERTURE, DEFAULT_SIGNAL_TO_NOISE_RATIO,
            DEFAULT_CROWDING_METRIC, DEFAULT_SKY_CROWDING_METRIC, 0,
            TargetType.LONG_CADENCE, pixels);
    }

    private List<PaTarget> createPseudoTargets(String[] targetListNames,
        int skyGroupId) {

        if (skyGroupId < 1 || skyGroupId > 84) {
            throw new IllegalArgumentException(skyGroupId
                + ": invalid skyGroupId");
        }

        List<PaTarget> targets = newArrayListWithExpectedSize(1024);
        for (String targetListName : targetListNames) {
            if (targetListName == null) {
                throw new NullPointerException("targetListName can't be null");
            }
            TargetList targetList = targetSelectionCrud.retrieveTargetList(targetListName);
            if (targetList == null) {
                throw new IllegalArgumentException(targetListName
                    + ": invalid targetListName");
            }

            log.info("[" + getModuleName() + "]retrieve pseudo targets from "
                + targetList.getName());
            List<PlannedTarget> plannedTargets = targetSelectionCrud.retrievePlannedTargets(
                targetList, skyGroupId);

            List<Integer> keplerIds = newArrayListWithExpectedSize(plannedTargets.size());
            Map<Integer, PlannedTarget> plannedTargetByKeplerId = newHashMapWithExpectedSize(plannedTargets.size());
            for (PlannedTarget plannedTarget : plannedTargets) {
                keplerIds.add(plannedTarget.getKeplerId());
                plannedTargetByKeplerId.put(plannedTarget.getKeplerId(),
                    plannedTarget);
            }

            for (Integer keplerId : keplerIds) {
                targets.add(createPaTarget(ccdModule, ccdOutput,
                    plannedTargetByKeplerId.get(keplerId)));
            }

            log.info("update pseudo targets with celestial parameters.");
            targetOperations.updateTargetsWithCelestialParameters(targets);

            DatabaseServiceFactory.getInstance()
                .evictAll(plannedTargets);
        }

        return targets;
    }

    private void updateTargetsWithNearbyKics(List<PaTarget> targets) {

        List<Integer> keplerIds = newArrayList();
        for (PaTarget target : targets) {
            keplerIds.add(target.getKeplerId());
        }

        Map<Integer, List<CelestialObjectParameters>> celestialObjectParametersByKeplerId = getCelestialObjectOperations().retrieveCelestialObjectParameters(
            keplerIds, paCoaModuleParameters.getBoundedBoxWidth());

        for (PaTarget target : targets) {
            target.setKics(celestialObjectParametersByKeplerId.get(target.getKeplerId()));
        }
    }

    private static void updateTargetsWithKicEntryData(
        Map<Integer, KicEntryData> keplerIdToKicEntryData,
        List<PaTarget> targets) {

        for (PaTarget target : targets) {
            KicEntryData kicEntryData = keplerIdToKicEntryData.get(target.getKeplerId());
            log.info("kicEntryData: " + kicEntryData);
            if (kicEntryData != null) {
                target.setKicEntryData(kicEntryData);
            }
        }
    }

    private static Pair<Integer, Integer> shortCadenceToLongCadence(
        LogCrud logCrud, final int startShortCadence, final int endShortCadence) {

        // convert short cadence interval to long cadence
        Pair<Integer, Integer> longCadenceInterval = logCrud.shortCadenceToLongCadence(
            startShortCadence, endShortCadence);
        if (longCadenceInterval == null) {
            throw new IllegalStateException(
                String.format(
                    "no long cadence data for given short cadence interval: [%d,%d]",
                    startShortCadence, endShortCadence));
        }

        return longCadenceInterval;
    }

    private BlobSeries<String> retrieveBackgroundBlobFileSeries(
        final int startLongCadence, final int endLongCadence) {

        // retrieve the BlobFileSeries for long cadence
        BlobSeries<String> backgroundBlobs = getBlobOperations().retrieveBackgroundBlobFileSeries(
            ccdModule, ccdOutput, startLongCadence, endLongCadence);
        getProducerTaskIds().addAll(
            Arrays.asList(ArrayUtils.toObject(backgroundBlobs.blobOriginators())));

        return backgroundBlobs;
    }

    private BlobSeries<String> retrieveMotionBlobFileSeries(
        final int startLongCadence, final int endLongCadence) {

        // retrieve the BlobFileSeries for long cadence
        BlobSeries<String> motionBlobs = getBlobOperations().retrieveMotionBlobFileSeries(
            ccdModule, ccdOutput, startLongCadence, endLongCadence);
        getProducerTaskIds().addAll(
            Arrays.asList(ArrayUtils.toObject(motionBlobs.blobOriginators())));

        return motionBlobs;
    }

    private static Set<Integer> getAllRows(List<PaTarget> targets) {

        Set<Integer> rows = newHashSet();
        for (PaTarget target : targets) {
            for (Pixel pixel : target.getPixels()) {
                rows.add(pixel.getRow());
            }
        }

        return rows;
    }

    // accessors (getters/setters)
}
