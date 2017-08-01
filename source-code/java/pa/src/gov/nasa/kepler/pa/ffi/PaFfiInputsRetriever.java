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

package gov.nasa.kepler.pa.ffi;

import static com.google.common.collect.Lists.newArrayList;
import static com.google.common.collect.Sets.newHashSet;
import static com.google.common.collect.Sets.newTreeSet;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.FfiType;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.common.pi.CalFfiModuleParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.readnoise.ReadNoiseOperations;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverPipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.FsIdsStream;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MatlabCallState;
import gov.nasa.kepler.mc.MatlabCallStateStream;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.TimestampSeriesStream;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fc.RaDec2PixOperations;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.kepler.pa.ApertureModelParameters;
import gov.nasa.kepler.pa.ArgabrighteningModuleParameters;
import gov.nasa.kepler.pa.EncircledEnergyModuleParameters;
import gov.nasa.kepler.pa.MotionModuleParameters;
import gov.nasa.kepler.pa.OapAncillaryEngineeringParameters;
import gov.nasa.kepler.pa.PaCoaModuleParameters;
import gov.nasa.kepler.pa.PaCommonInputsRetriever;
import gov.nasa.kepler.pa.PaCosmicRayParameters;
import gov.nasa.kepler.pa.PaHarmonicsIdentificationParameters;
import gov.nasa.kepler.pa.PaInputs;
import gov.nasa.kepler.pa.PaIoProcessor;
import gov.nasa.kepler.pa.PaModuleParameters;
import gov.nasa.kepler.pa.PaPipelineModule;
import gov.nasa.kepler.pa.PaTargetOperations;
import gov.nasa.kepler.pa.ReactionWheelAncillaryEngineeringParameters;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Set;

import nom.tam.fits.FitsException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Retrieves {@link PaInputs}.
 * 
 * @author Forrest Girouard
 * @author Miles Cote
 * 
 */
public class PaFfiInputsRetriever {

    /**
     * Logger for this class
     */
    public static final Log log = LogFactory.getLog(PaFfiInputsRetriever.class);

    public static final String MODULE_NAME = "paffi";

    private PipelineTask pipelineTask;
    private PipelineInstance pipelineInstance;
    private int ccdModule;
    private int ccdOutput;

    private AncillaryOperations ancillaryOperations = new AncillaryOperations();
    private BlobOperations blobOperations = new BlobOperations();
    private ConfigMapOperations configMapOperations = new ConfigMapOperations();
    private CelestialObjectOperations celestialObjectOperations;
    private PrfOperations prfOperations = new PrfOperations();
    private RaDec2PixOperations raDec2PixOperations = new RaDec2PixOperations();
    private ReadNoiseOperations readNoiseOperations = new ReadNoiseOperations();
    private GainOperations gainOperations = new GainOperations();
    private LinearityOperations linearityOperations = new LinearityOperations();
    private DataAnomalyOperations dataAnomalyOperations;
    private TargetCrud targetCrud = new TargetCrud();

    // private CadenceType cadenceType;

    private final Set<Long> producerTaskIds = newHashSet();
    private final Set<FsId> allBackgroundCosmicRayFsIds = newTreeSet();
    private final Set<FsId> allTargetCosmicRayFsIds = newTreeSet();

    private boolean firstCall = true;
    private boolean done;

    private PaInputs paInputs;
    private PaModuleParameters paParameters;
    private PaFfiModuleParameters paFfiParameters;
    private AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters;
    private AncillaryPipelineParameters ancillaryPipelineParameters;
    private ApertureModelParameters apertureModelParameters;
    private ArgabrighteningModuleParameters argabrighteningParameters;
    private BackgroundModuleParameters backgroundParameters;
    private CalFfiModuleParameters calFfiModuleParameters;
    private PaCosmicRayParameters paCosmicRayParameters;
    private RollingBandArtifactParameters rollingBandArtifactParameters;
    private EncircledEnergyModuleParameters encircledEnergyParameters;
    private GapFillModuleParameters gapFillParameters;
    private MotionModuleParameters motionModuleParameters;
    private OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters;
    private ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters;
    private PaCoaModuleParameters paCoaModuleParameters;

    private PaHarmonicsIdentificationParameters paHarmonicsIdentificationParameters;
    private PouModuleParameters pouParameters;
    private ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters;
    private SaturationSegmentModuleParameters saturationSegmentModuleParameters;
    private TimestampSeries cadenceTimes;
    private List<ConfigMap> configMaps;
    private PrfModel prfModel;
    private RaDec2PixModel raDec2PixModel;
    private ReadNoiseModel readNoiseModel;
    private GainModel gainModel;
    private LinearityModel linearityModel;
    private String transitInjectionParametersFileName = "";

    private FfiModOut ffiModOutValues;
    private FfiModOut ffiModOutUncert;

    private PaFfiTargetOperations targetOperations;
    private int ppaTargetCount;
    private TargetTable targetTable;
    private TargetTable backgroundTable;
    private ProducerTaskIdsStream producerTaskIdsStream = new ProducerTaskIdsStream();
    private FsIdsStream fsIdsStream = new FsIdsStream();
    private TimestampSeriesStream timestampSeriesStream = new TimestampSeriesStream();
    private MatlabCallStateStream matlabCallStateStream = new MatlabCallStateStream();

    private boolean processPpaTargets;
    private boolean generateMotionPolynomials;

    private String getModuleName() {
        return MODULE_NAME;
    }

    public PaFfiInputsRetriever(PipelineTask pipelineTask, int ccdModule,
        int ccdOutput) {
        this.pipelineTask = pipelineTask;
        pipelineInstance = pipelineTask.getPipelineInstance();
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
    }

    public boolean hasNext() {
        return !done;
    }

    public PaInputs retrieveInputs(File matlabWorkingDir) {

        paFfiParameters = pipelineTask.getParameters(PaFfiModuleParameters.class);
        targetTable = targetCrud.retrieveUplinkedTargetTable(
            paFfiParameters.getTargetTableId(), TargetType.LONG_CADENCE);
        backgroundTable = targetCrud.retrieveUplinkedTargetTable(
            paFfiParameters.getBackgroundTableId(), TargetType.BACKGROUND);

        processCadenceSet(matlabWorkingDir);

        if (paInputs != null) {
            PaPipelineModule.ProcessingState state = PaPipelineModule.ProcessingState.valueOf(paInputs.getProcessingState());
            if (state == PaPipelineModule.ProcessingState.BACKGROUND) {
                fsIdsStream.write(DataSetType.Background, matlabWorkingDir,
                    allBackgroundCosmicRayFsIds);
            }
            if ((state == PaPipelineModule.ProcessingState.AGGREGATE_RESULTS || state == PaPipelineModule.ProcessingState.GENERATE_MOTION_POLYNOMIALS)
                && paInputs.isLastCall()) {
                fsIdsStream.write(DataSetType.Target, matlabWorkingDir,
                    allTargetCosmicRayFsIds);
            }
            timestampSeriesStream.write(matlabWorkingDir, cadenceTimes);
            matlabCallStateStream.write(matlabWorkingDir, new MatlabCallState(
                paInputs.isFirstCall(), paInputs.isLastCall()));
        }

        return paInputs;
    }

    public void serializeProducerTaskIds(File workingDir) {
        Set<Long> existingProducerTaskIds = producerTaskIdsStream.read(workingDir);
        log.info("[" + getModuleName() + "]Count of existing producerTaskIds: "
            + existingProducerTaskIds.size());
        producerTaskIds.addAll(existingProducerTaskIds);
        log.info("[" + getModuleName() + "]Total count of producerTaskIds: "
            + producerTaskIds.size());
        log.info("[" + getModuleName() + "]Serializing producerTaskIds...");
        producerTaskIdsStream.write(workingDir, producerTaskIds);
    }

    private void processCadenceSet(File matlabWorkingDir) {

        if (done) {
            paInputs = null;

            return;
        }

        if (firstCall) {
            calFfiModuleParameters = pipelineTask.getParameters(CalFfiModuleParameters.class);
            FsId ffiValuesFsId = CalFsIdFactory.getSingleChannelFfiFile(
                calFfiModuleParameters.getFileTimeStamp(), FfiType.SOC_CAL,
                ccdModule, ccdOutput);
            FsId ffiUncertFsId = CalFsIdFactory.getSingleChannelFfiFile(
                calFfiModuleParameters.getFileTimeStamp(),
                FfiType.SOC_CAL_UNCERTAINTIES, ccdModule, ccdOutput);
            ffiModOutValues = retrieveFfiModOut(ffiValuesFsId);
            ffiModOutUncert = retrieveFfiModOut(ffiUncertFsId);
            producerTaskIds.add(ffiModOutValues.originator);

            paParameters = pipelineTask.getParameters(PaModuleParameters.class);
            if (paParameters.isSimulatedTransitsEnabled()) {
                throw new IllegalArgumentException(
                    "PA FFI does not support simulated transits.");
            }
            if (paParameters.isOnlyProcessPpaTargetsEnabled()) {
                log.info("PA FFI implicitly processes only PPA targets.");
            }
            if (paParameters.isMotionBlobsInputEnabled()) {
                throw new IllegalArgumentException(
                    "PA FFI does not support input motion blobs.");
            }

            log.info("[" + getModuleName() + "]retrieve cadence times.");
            cadenceTimes = ffiModOutValues.getCadenceTimes();

            retrieveParameters();
            retrieveModels();

            log.info("[" + getModuleName() + "]set blob operations directory: "
                + matlabWorkingDir);
            blobOperations.setOutputDir(matlabWorkingDir);

            paInputs = createPaInputs(cadenceTimes);

            retrieveAncillaryData();
            if (pouParameters.isPouEnabled()) {
                retrieveCalUncertainties(matlabWorkingDir);
            }

            targetOperations = new PaFfiTargetOperations(targetTable,
                backgroundTable == null ? null : backgroundTable, ccdModule,
                ccdOutput);
            targetOperations.setTargetCrud(targetCrud);

            log.info("[" + getModuleName() + "]retrieve background targets.");
            List<PaPixelTimeSeries> backgroundPixelTimeSeries = retrieveBackgroundPixelTimeSeries(targetOperations);
            paInputs.setBackgroundPixels(backgroundPixelTimeSeries);

            firstCall = false;
            processPpaTargets = true;

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.BACKGROUND.toString());

            return;
        }

        List<PaTarget> ppaTargets = newArrayList();
        if (processPpaTargets) {
            log.info("[" + getModuleName() + "]determine PPA targets.");
            ppaTargets = targetOperations.getPpaTargets();
            ppaTargetCount = ppaTargets.size();

            log.info("[" + getModuleName()
                + "]update targets with celestial parameters.");
            PaTargetOperations.updateTargetsWithCelestialParameters(ppaTargets,
                getCelestialObjectOperations());

            log.info("[" + getModuleName() + "] PPA target count: "
                + ppaTargetCount);

            FfiModOut.getPixelTimeSeries(ppaTargets, ffiModOutValues,
                ffiModOutUncert);
        }

        paInputs = createPaInputs(cadenceTimes);

        paInputs.setPpaTargetCount(ppaTargetCount);

        if (processPpaTargets) {
            log.info("[" + getModuleName()
                + "] Get rolling band artifacts flags. ");

            paInputs.setTargets(ppaTargets);
            allTargetCosmicRayFsIds.addAll(PaCommonInputsRetriever.createTargetBatchCosmicRayFsIds(ppaTargets));

            generateMotionPolynomials = true;
            processPpaTargets = false;

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.PPA_TARGETS.toString());

            return;
        }

        if (generateMotionPolynomials) {
            generateMotionPolynomials = false;

            paInputs.setProcessingState(PaPipelineModule.ProcessingState.GENERATE_MOTION_POLYNOMIALS.toString());

            return;
        }

        done = true;
        paInputs.setLastCall(true);
        paInputs.setProcessingState(PaPipelineModule.ProcessingState.AGGREGATE_RESULTS.toString());

        return;
    }

    private FfiModOut retrieveFfiModOut(FsId ffiModOutId) {
        FfiReader ffiReader = new FfiReader();
        FfiModOut ffiModOut = null;
        try {
            ffiModOut = ffiReader.readFfiModOut(ffiModOutId);
        } catch (IOException e) {
            throw new ModuleFatalProcessingException(
                "Failed to read FFI file.", e);
        } catch (FitsException e) {
            throw new ModuleFatalProcessingException(
                "Failed to parse FFI file.", e);
        }
        return ffiModOut;
    }

    private void retrieveCalUncertainties(File matlabWorkingDir) {
        log.info("[" + getModuleName() + "]retrieve CAL uncertainties blob.");

        File file = null;
        FsId fsId = null;
        try {
            file = File.createTempFile("blob", "", matlabWorkingDir);
            fsId = CalFsIdFactory.getSingleChannelFfiFile(
                calFfiModuleParameters.getFileTimeStamp(),
                FfiType.SOC_CAL_UNCERTAINTIES_BLOB, ccdModule, ccdOutput);
            FileStoreClientFactory.getInstance()
                .readBlob(fsId, file);
        } catch (IOException ioe) {
            throw new FileStoreException(fsId + ": ", ioe);
        }
        paInputs.setCalUncertaintyBlobs(new BlobFileSeries(new int[] { 0 },
            new boolean[] { false }, new String[] { file.getName() },
            ffiModOutValues.longCadenceNumber,
            ffiModOutValues.longCadenceNumber));
    }

    private void retrieveModels() {
        log.info("[" + getModuleName() + "]retrieve config maps.");
        configMaps = ffiModOutValues.getConfigMaps(configMapOperations);

        log.info("[" + getModuleName() + "]retrieve PRF model.");
        prfModel = prfOperations.retrievePrfModel(cadenceTimes.startMjd(),
            ccdModule, ccdOutput);

        log.info("[" + getModuleName() + "]retrieve RaDec2Pix model.");
        raDec2PixModel = raDec2PixOperations.retrieveRaDec2PixModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        log.info("[" + getModuleName() + "]retrieve ReadNoise model.");
        readNoiseModel = readNoiseOperations.retrieveReadNoiseModel(
            cadenceTimes.startMjd(), cadenceTimes.endMjd());

        log.info("[" + getModuleName() + "]retrieve Gain model.");
        gainModel = gainOperations.retrieveGainModel(cadenceTimes.startMjd(),
            cadenceTimes.endMjd());

        log.info("[" + getModuleName() + "]retrieve Linearity model.");
        linearityModel = linearityOperations.retrieveLinearityModel(ccdModule,
            ccdOutput, cadenceTimes.startMjd(), cadenceTimes.endMjd());
    }

    protected DataAnomalyOperations getDataAnomalyOperations() {
        if (dataAnomalyOperations == null) {
            dataAnomalyOperations = new DataAnomalyOperations(
                new ModelMetadataRetrieverPipelineInstance(pipelineInstance));
        }

        return dataAnomalyOperations;
    }

    private void retrieveParameters() {

        log.info("[" + getModuleName() + "]retrieve module parameters.");

        ancillaryDesignMatrixParameters = pipelineTask.getParameters(AncillaryDesignMatrixParameters.class);
        ancillaryPipelineParameters = PaCommonInputsRetriever.retrieveAncillaryPipelineParameters(pipelineTask);
        apertureModelParameters = pipelineTask.getParameters(ApertureModelParameters.class);
        argabrighteningParameters = pipelineTask.getParameters(ArgabrighteningModuleParameters.class);
        backgroundParameters = pipelineTask.getParameters(BackgroundModuleParameters.class);
        paCoaModuleParameters = pipelineTask.getParameters(PaCoaModuleParameters.class);
        paCosmicRayParameters = pipelineTask.getParameters(PaCosmicRayParameters.class);
        rollingBandArtifactParameters = pipelineTask.getParameters(RollingBandArtifactParameters.class);
        encircledEnergyParameters = pipelineTask.getParameters(EncircledEnergyModuleParameters.class);
        gapFillParameters = pipelineTask.getParameters(GapFillModuleParameters.class);
        motionModuleParameters = pipelineTask.getParameters(MotionModuleParameters.class);
        oapAncillaryEngineeringParameters = PaCommonInputsRetriever.retrieveOapAncillaryEngineeringParameters(pipelineTask);
        paCoaModuleParameters = pipelineTask.getParameters(PaCoaModuleParameters.class);
        paHarmonicsIdentificationParameters = pipelineTask.getParameters(PaHarmonicsIdentificationParameters.class);
        pouParameters = pipelineTask.getParameters(PouModuleParameters.class);
        reactionWheelAncillaryEngineeringParameters = PaCommonInputsRetriever.retrieveReactionWheelAncillaryEngineeringParameters(pipelineTask);
        saturationSegmentModuleParameters = pipelineTask.getParameters(SaturationSegmentModuleParameters.class);
        thrusterDataAncillaryEngineeringParameters = PaCommonInputsRetriever.retrieveThrusterDataAncillaryEngineeringParameters(pipelineTask);
    }

    private PaInputs createPaInputs(TimestampSeries longCadenceTimes) {

        return new PaInputs(ccdModule, ccdOutput, CadenceType.LONG.toString(),
            ffiModOutValues.longCadenceNumber,
            ffiModOutValues.longCadenceNumber, cadenceTimes, configMaps,
            prfModel, raDec2PixModel, readNoiseModel, gainModel,
            linearityModel, transitInjectionParametersFileName, firstCall,
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
    }

    private void retrieveAncillaryData() {
        List<AncillaryEngineeringData> ancillaryEngineeringData = newArrayList();
        if (paInputs.getPaModuleParameters()
            .isOapEnabled()) {
            log.info("[" + getModuleName()
                + "]retrieve OAP ancillary engineering data.");
            ancillaryEngineeringData.addAll(PaCommonInputsRetriever.retrieveAncillaryEngineeringData(
                ancillaryOperations, cadenceTimes.startMjd(),
                cadenceTimes.endMjd(), oapAncillaryEngineeringParameters,
                producerTaskIds));

            log.info("[" + getModuleName()
                + "]retrieve ancillary pipeline data.");
            List<AncillaryPipelineData> ancillaryPipelineData = PaCommonInputsRetriever.retrieveAncillaryPipelineData(
                ancillaryOperations, targetTable, ccdModule, ccdOutput,
                cadenceTimes, ancillaryPipelineParameters, producerTaskIds);
            paInputs.setAncillaryPipelineData(ancillaryPipelineData);
        }

        log.info("[" + getModuleName()
            + "]retrieve reaction wheel ancillary engineering data.");
        ancillaryEngineeringData.addAll(PaCommonInputsRetriever.retrieveAncillaryEngineeringData(
            ancillaryOperations, cadenceTimes.startMjd(),
            cadenceTimes.endMjd(), reactionWheelAncillaryEngineeringParameters,
            producerTaskIds));

        log.info("[" + getModuleName()
            + "]retrieve thruster data ancillary engineering data.");
        ancillaryEngineeringData.addAll(PaCommonInputsRetriever.retrieveAncillaryEngineeringData(
            ancillaryOperations, cadenceTimes.startMjd(),
            cadenceTimes.endMjd(), thrusterDataAncillaryEngineeringParameters,
            producerTaskIds, false));

        paInputs.setAncillaryEngineeringData(ancillaryEngineeringData);
    }

    private Set<Integer> getAllRows(List<PaTarget> targets) {

        Set<Integer> rows = newHashSet();
        for (PaTarget target : targets) {
            for (Pixel pixel : target.getPixels()) {
                rows.add(pixel.getRow());
            }
        }

        return rows;
    }

    protected Set<Integer> getAllDurations() {
        return PaIoProcessor.getAllDurations(rollingBandArtifactParameters.getTestPulseDurations());
    }

    private List<PaPixelTimeSeries> retrieveBackgroundPixelTimeSeries(
        final SciencePixelOperations timeSeriesOps) {

        Set<Pixel> backgroundPixels = timeSeriesOps.getBackgroundPixels();
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
            allBackgroundCosmicRayFsIds.add(PaFsIdFactory.getCosmicRaySeriesFsId(
                TargetType.BACKGROUND, ccdModule, ccdOutput, pixel.getRow(),
                pixel.getColumn()));
        }
        if (log.isDebugEnabled()) {
            log.debug("min pixel: " + minPixel);
            log.debug("max pixel: " + maxPixel);
        }
        List<PaPixelTimeSeries> backgroundPixelTimeSeries = FfiModOut.getPixelTimeSeries(
            backgroundPixels, ffiModOutValues, ffiModOutUncert);
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

    // accessors (getters/setters)

    /**
     * Sets this module's ancillary operations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param ancillaryOperations the ancillary operations.
     */
    protected void setAncillaryOperations(
        final AncillaryOperations ancillaryOperations) {
        this.ancillaryOperations = ancillaryOperations;
    }

    /**
     * Sets this module's blob operations. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param blobOperations the blob operations.
     */
    protected void setBlobOperations(final BlobOperations blobOperations) {
        this.blobOperations = blobOperations;
    }

    /**
     * Sets this module's config map operations. This method isn't used by the
     * module interface, but by tests.
     * 
     * @param configMapOperations the config map operations.
     */
    protected void setConfigMapOperations(
        final ConfigMapOperations configMapOperations) {
        this.configMapOperations = configMapOperations;
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
     * Sets this module's target selection operations. This method isn't used by
     * the module interface, but by tests.
     * 
     * @param celestialObjectOperations the target selection operations.
     */
    protected void setCelestialObjectOperations(
        final CelestialObjectOperations celestialObjectOperations) {
        this.celestialObjectOperations = celestialObjectOperations;
    }

    /**
     * Sets this module's pipeline instance. This is only used internally and by
     * unit tests that aren't calling
     * {@link #processTask(PipelineInstance, PipelineTask)}.
     * 
     * @param pipelineInstance the non-{@code null} pipeline instance.
     * @throws NullPointerException if {@code pipelineInstance} is {@code null}.
     */
    protected void setPipelineInstance(final PipelineInstance pipelineInstance) {

        if (pipelineInstance == null) {
            throw new NullPointerException("pipelineInstance can't be null");
        }

        this.pipelineInstance = pipelineInstance;
        if (pipelineTask != null) {
            pipelineTask.setPipelineInstance(pipelineInstance);
        }
    }

    /**
     * Sets this module's PRF operations. This method isn't used by the module
     * interface, only tests.
     * 
     * @param prfOperations
     */
    protected void setPrfOperations(final PrfOperations prfOperations) {
        this.prfOperations = prfOperations;
    }

    /**
     * Sets this module's RaDec2Pix operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param raDec2PixOperations
     */
    protected void setRaDec2PixOperations(
        final RaDec2PixOperations raDec2PixOperations) {
        this.raDec2PixOperations = raDec2PixOperations;
    }

    /**
     * Sets this module's ReadNoise operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param readNoiseOperations
     */
    protected void setReadNoiseOperations(
        final ReadNoiseOperations readNoiseOperations) {
        this.readNoiseOperations = readNoiseOperations;
    }

    /**
     * Sets this module's Gain operations. This method isn't used by the module
     * interface, only tests.
     * 
     * @param gainOperations
     */
    protected void setGainOperations(final GainOperations gainOperations) {
        this.gainOperations = gainOperations;
    }

    /**
     * Sets this module's Linearity operations. This method isn't used by the
     * module interface, only tests.
     * 
     * @param linearityOperations
     */
    protected void setLinearityOperations(
        final LinearityOperations linearityOperations) {
        this.linearityOperations = linearityOperations;
    }

    /**
     * Sets this module's target CRUD. This method isn't used by the module
     * interface, but by tests.
     * 
     * @param targetCrud the target CRUD.
     */
    protected void setTargetCrud(final TargetCrud targetCrud) {
        this.targetCrud = targetCrud;
    }
}
