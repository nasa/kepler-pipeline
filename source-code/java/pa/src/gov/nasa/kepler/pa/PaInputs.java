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

import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.mc.BackgroundModuleParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.PouModuleParameters;
import gov.nasa.kepler.mc.RollingBandArtifactFlags;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pa.PaPixelTimeSeries;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.StringUtils;

/**
 * Photometric Analysis (PA) pipeline module interface inputs.
 * 
 * @author Forrest Girouard
 * 
 */
public class PaInputs implements Persistable {

    /**
     * CCD module.
     */
    private int ccdModule;

    /**
     * CCD output.
     */
    private int ccdOutput;

    /**
     * Type of cadence ('LONG' or 'SHORT').
     */
    private String cadenceType = "";

    /**
     * Start cadence (inclusive).
     */
    private int startCadence;

    /**
     * End cadence (inclusive).
     */
    private int endCadence;

    /**
     * True iff this is the first MATLAB call for a given pipeline task.
     */
    private boolean firstCall = false;

    /**
     * True iff this is the last MATLAB call for a given pipeline task.
     */
    private boolean lastCall = false;

    private int debugFlag;

    private double duration;
    private String startTime = StringUtils.EMPTY;

    /**
     * Focal plane characteristics constants.
     */
    private final FcConstants fcConstants = new FcConstants();

    /**
     * Active spacecraft configuration maps for the given cadence range.
     */
    private List<ConfigMap> spacecraftConfigMap = new ArrayList<ConfigMap>();

    /**
     * Cadence start, mid, and end mjds along with gap and requant flags.
     */
    private TimestampSeries cadenceTimes = new TimestampSeries();

    /**
     * Long cadence start, mid, and end mjds along with gap and requant flags.
     */
    private TimestampSeries longCadenceTimes = new TimestampSeries();

    /**
     * Ancillary pipeline design matrix parameters.
     */
    private AncillaryDesignMatrixParameters ancillaryDesignMatrixConfigurationStruct = new AncillaryDesignMatrixParameters();

    /**
     * Ancillary pipeline (from SOC pipeline) data parameters.
     */
    private AncillaryPipelineParameters ancillaryPipelineConfigurationStruct = new AncillaryPipelineParameters();

    /**
     * Argabrightening data module parameters.
     */
    private ArgabrighteningModuleParameters argabrighteningConfigurationStruct = new ArgabrighteningModuleParameters();

    /**
     * Background related module parameters.
     */
    private BackgroundModuleParameters backgroundConfigurationStruct = new BackgroundModuleParameters();

    /**
     * Collection of cosmic ray cleaning parameters.
     */
    private PaCosmicRayParameters cosmicRayConfigurationStruct = new PaCosmicRayParameters();

    /**
     * Encircled energy related module parameters.
     */
    private EncircledEnergyModuleParameters encircledEnergyConfigurationStruct = new EncircledEnergyModuleParameters();

    /**
     * Gap fill related module parameters.
     */
    private GapFillModuleParameters gapFillConfigurationStruct = new GapFillModuleParameters();

    private PaHarmonicsIdentificationParameters harmonicsIdentificationConfigurationStruct = new PaHarmonicsIdentificationParameters();

    /**
     * All motion related module parameters.
     */
    private MotionModuleParameters motionConfigurationStruct = new MotionModuleParameters();

    /**
     * OAP related ancillary engineering (from spacecraft) data parameters.
     */
    private OapAncillaryEngineeringParameters oapAncillaryEngineeringConfigurationStruct = new OapAncillaryEngineeringParameters();

    /**
     * PA specific module parameters.
     */
    private PaModuleParameters paConfigurationStruct = new PaModuleParameters();

    private PaCoaModuleParameters paCoaConfigurationStruct = new PaCoaModuleParameters();

    private ApertureModelParameters apertureModelConfigurationStruct = new ApertureModelParameters();

    /**
     * PRF-specific module parameters.
     */
    private PouModuleParameters pouConfigurationStruct = new PouModuleParameters();

    /**
     * Reaction wheel related ancillary engineering (from spacecraft) data
     * parameters.
     */
    private ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringConfigurationStruct = new ReactionWheelAncillaryEngineeringParameters();

    /**
     * Saturation segment module parameters.
     */
    private SaturationSegmentModuleParameters saturationSegmentConfigurationStruct = new SaturationSegmentModuleParameters();

    /**
     * Thruster firing records from ancillary engineering (spacecraft) data
     * parameters.
     */
    private ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringConfigurationStruct = new ThrusterDataAncillaryEngineeringParameters();

    /**
     * Contains the ancillary engineering data for the mnemonics specified in
     * the {@code AncillaryEngineeringParameters}.
     */
    private List<AncillaryEngineeringData> ancillaryEngineeringDataStruct = new ArrayList<AncillaryEngineeringData>();

    /**
     * Contains the ancillary pipeline data for the mnemonics specified in the
     * {@code AncillaryPipelineParameters}.
     */
    private List<AncillaryPipelineData> ancillaryPipelineDataStruct = new ArrayList<AncillaryPipelineData>();

    /**
     * All the background pixel time series data.
     */
    private List<PaPixelTimeSeries> backgroundDataStruct = new ArrayList<PaPixelTimeSeries>();

    /**
     * Targets with all their pixel time series data.
     */
    private List<PaTarget> targetStarDataStruct = new ArrayList<PaTarget>();

    /**
     * Total number of PPA targets.
     */
    private int ppaTargetCount;

    /**
     * Pixel response function model.
     */
    private PrfModel prfModel = new PrfModel();

    /**
     * A RA/Dec to pixel model that covers the interval of time for the old and
     * new data.
     */
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();

    private ReadNoiseModel readNoiseModel = new ReadNoiseModel();
    private GainModel gainModel = new GainModel();
    private LinearityModel linearityModel = new LinearityModel();

    /**
     * Blobs containing input primitives and transformations from CAL.
     */
    private BlobFileSeries calUncertaintyBlobs = new BlobFileSeries();

    /**
     * Blobs containing background coefficients (must be non-null for SHORT
     * cadence).
     */
    private BlobFileSeries backgroundBlobs = new BlobFileSeries();

    /**
     * Blobs containing motion polynomials (must be non-null for SHORT cadence).
     */
    private BlobFileSeries motionBlobs = new BlobFileSeries();

    /**
     * Rolling band artifact flags produced by Dynablack.
     */
    private List<RollingBandArtifactFlags> rollingBandArtifactFlags = new ArrayList<RollingBandArtifactFlags>();

    /**
     * Name of local file containing simulated transit meta-data.
     */
    private String transitInjectionParametersFileName = "";

    /**
     * The processing state for this inputs.
     */
    private String processingState = "";

    /**
     * Only used for testing.
     * 
     */
    public PaInputs() {
    }

    public PaInputs(
        final int ccdModule,
        final int ccdOutput,
        final String cadenceType,
        final int startCadence,
        final int endCadence,
        final TimestampSeries cadenceTimes,
        final List<ConfigMap> configMaps,
        final PrfModel prfModel,
        final RaDec2PixModel raDec2PixModel,
        final ReadNoiseModel readNoiseModel,
        final GainModel gainModel,
        final LinearityModel linearityModel,
        final String transitInjectionParametersFileName,
        final boolean firstCall,
        final AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters,
        final AncillaryPipelineParameters ancillaryPipelineParameters,
        final ApertureModelParameters apertureModelParameters,
        final ArgabrighteningModuleParameters argabrighteningModuleParameters,
        final BackgroundModuleParameters backgroundModuleParameters,
        final PaCosmicRayParameters paCosmicRayParameters,
        final EncircledEnergyModuleParameters encircledEnergyModuleParameters,
        final GapFillModuleParameters gapFillModuleParameters,
        final MotionModuleParameters motionModuleParameters,
        final OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters,
        final PaCoaModuleParameters paCoaModuleParameters,
        final PaHarmonicsIdentificationParameters paHarmonicsIdentificationParameters,
        final PaModuleParameters paModuleParameters,
        final PouModuleParameters pouModuleParameters,
        final ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters,
        final SaturationSegmentModuleParameters saturationSegmentModuleParameters,
        final ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters) {

        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.cadenceType = cadenceType;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceTimes = cadenceTimes;
        spacecraftConfigMap = configMaps;
        this.prfModel = prfModel;
        this.raDec2PixModel = raDec2PixModel;
        this.readNoiseModel = readNoiseModel;
        this.gainModel = gainModel;
        this.linearityModel = linearityModel;
        this.transitInjectionParametersFileName = transitInjectionParametersFileName;
        this.firstCall = firstCall;

        ancillaryPipelineConfigurationStruct = ancillaryPipelineParameters;
        ancillaryDesignMatrixConfigurationStruct = ancillaryDesignMatrixParameters;
        apertureModelConfigurationStruct = apertureModelParameters;
        argabrighteningConfigurationStruct = argabrighteningModuleParameters;
        backgroundConfigurationStruct = backgroundModuleParameters;
        paCoaConfigurationStruct = paCoaModuleParameters;
        cosmicRayConfigurationStruct = paCosmicRayParameters;
        encircledEnergyConfigurationStruct = encircledEnergyModuleParameters;
        gapFillConfigurationStruct = gapFillModuleParameters;
        harmonicsIdentificationConfigurationStruct = paHarmonicsIdentificationParameters;
        motionConfigurationStruct = motionModuleParameters;
        oapAncillaryEngineeringConfigurationStruct = oapAncillaryEngineeringParameters;
        paCoaConfigurationStruct = paCoaModuleParameters;
        paConfigurationStruct = paModuleParameters;
        pouConfigurationStruct = pouModuleParameters;
        reactionWheelAncillaryEngineeringConfigurationStruct = reactionWheelAncillaryEngineeringParameters;
        saturationSegmentConfigurationStruct = saturationSegmentModuleParameters;
        thrusterDataAncillaryEngineeringConfigurationStruct = thrusterDataAncillaryEngineeringParameters;
    }

    public PaInputs(
        final int ccdModule,
        final int ccdOutput,
        final String cadenceType,
        final int startCadence,
        final int endCadence,
        final TimestampSeries cadenceTimes,
        final List<ConfigMap> configMaps,
        final PrfModel prfModel,
        final RaDec2PixModel raDec2PixModel,
        final ReadNoiseModel readNoiseModel,
        final GainModel gainModel,
        final LinearityModel linearityModel,
        final String transitInjectionParametersFileName,
        final boolean firstCall,
        final AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters,
        final AncillaryPipelineParameters ancillaryPipelineParameters,
        final ApertureModelParameters apertureModelParameters,
        final ArgabrighteningModuleParameters argabrighteningModuleParameters,
        final BackgroundModuleParameters backgroundModuleParameters,
        final PaCosmicRayParameters paCosmicRayParameters,
        final EncircledEnergyModuleParameters encircledEnergyModuleParameters,
        final GapFillModuleParameters gapFillModuleParameters,
        final MotionModuleParameters motionModuleParameters,
        final OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters,
        final PaCoaModuleParameters paCoaModuleParameters,
        final PaHarmonicsIdentificationParameters paHarmonicsIdentificationParameters,
        final PaModuleParameters paModuleParameters,
        final PouModuleParameters pouModuleParameters,
        final ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters,
        final SaturationSegmentModuleParameters saturationSegmentModuleParameters,
        final ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters,
        final TimestampSeries longCadenceTimes) {

        this(ccdModule, ccdOutput, cadenceType, startCadence, endCadence,
            cadenceTimes, configMaps, prfModel, raDec2PixModel, readNoiseModel,
            gainModel, linearityModel, transitInjectionParametersFileName,
            firstCall, ancillaryDesignMatrixParameters,
            ancillaryPipelineParameters, apertureModelParameters,
            argabrighteningModuleParameters, backgroundModuleParameters,
            paCosmicRayParameters, encircledEnergyModuleParameters,
            gapFillModuleParameters, motionModuleParameters,
            oapAncillaryEngineeringParameters, paCoaModuleParameters,
            paHarmonicsIdentificationParameters, paModuleParameters,
            pouModuleParameters, reactionWheelAncillaryEngineeringParameters,
            saturationSegmentModuleParameters,
            thrusterDataAncillaryEngineeringParameters);
        this.longCadenceTimes = longCadenceTimes;
    }

    // accessors

    public AncillaryDesignMatrixParameters getAncillaryDesignMatrixParameters() {
        return ancillaryDesignMatrixConfigurationStruct;
    }

    public void setAncillaryDesignMatrixParameters(
        final AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters) {
        ancillaryDesignMatrixConfigurationStruct = ancillaryDesignMatrixParameters;
    }

    public List<AncillaryEngineeringData> getAncillaryEngineeringData() {
        return ancillaryEngineeringDataStruct;
    }

    public void setAncillaryEngineeringData(
        final List<AncillaryEngineeringData> ancillaryEngineeringData) {
        ancillaryEngineeringDataStruct = ancillaryEngineeringData;
    }

    public OapAncillaryEngineeringParameters getOapAncillaryEngineeringParameters() {
        return oapAncillaryEngineeringConfigurationStruct;
    }

    public void setOapAncillaryEngineeringParameters(
        final OapAncillaryEngineeringParameters oapAncillaryEngineeringParameters) {
        oapAncillaryEngineeringConfigurationStruct = oapAncillaryEngineeringParameters;
    }

    public List<AncillaryPipelineData> getAncillaryPipelineData() {
        return ancillaryPipelineDataStruct;
    }

    public void setAncillaryPipelineData(
        final List<AncillaryPipelineData> ancillaryPipelineData) {
        ancillaryPipelineDataStruct = ancillaryPipelineData;
    }

    public AncillaryPipelineParameters getAncillaryPipelineParameters() {
        return ancillaryPipelineConfigurationStruct;
    }

    public void setAncillaryPipelineParameters(
        final AncillaryPipelineParameters ancillaryPipelineParameters) {
        ancillaryPipelineConfigurationStruct = ancillaryPipelineParameters;
    }

    public ArgabrighteningModuleParameters getArgabrighteningModuleParameters() {
        return argabrighteningConfigurationStruct;
    }

    public void setArgabrighteningModuleParameters(
        ArgabrighteningModuleParameters argabrighteningModuleParameters) {
        argabrighteningConfigurationStruct = argabrighteningModuleParameters;
    }

    public BlobFileSeries getBackgroundBlobs() {
        return backgroundBlobs;
    }

    public void setBackgroundBlobs(final BlobFileSeries backgroundBlobs) {
        this.backgroundBlobs = backgroundBlobs;
    }

    public BackgroundModuleParameters getBackgroundModuleParameters() {
        return backgroundConfigurationStruct;
    }

    public void setBackgroundModuleParameters(
        BackgroundModuleParameters backgroundModuleParameters) {
        backgroundConfigurationStruct = backgroundModuleParameters;
    }

    public List<PaPixelTimeSeries> getBackgroundPixels() {
        return backgroundDataStruct;
    }

    public void setBackgroundPixels(
        final List<PaPixelTimeSeries> backgroundPixels) {
        backgroundDataStruct = backgroundPixels;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public String getCadenceType() {
        return cadenceType;
    }

    public BlobFileSeries getCalUncertaintyBlobs() {
        return calUncertaintyBlobs;
    }

    public void setCalUncertaintyBlobs(final BlobFileSeries calUncertaintyBlobs) {
        this.calUncertaintyBlobs = calUncertaintyBlobs;
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public List<ConfigMap> getConfigMaps() {
        return spacecraftConfigMap;
    }

    public PaCosmicRayParameters getPaCosmicRayParameters() {
        return cosmicRayConfigurationStruct;
    }

    public void setPaCosmicRayParameters(
        PaCosmicRayParameters paCosmicRayParameters) {
        cosmicRayConfigurationStruct = paCosmicRayParameters;
    }

    public int getDebugFlag() {
        return debugFlag;
    }

    public void setDebugFlag(int debugFlag) {
        this.debugFlag = debugFlag;
    }

    public double getDuration() {
        return duration;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }

    public EncircledEnergyModuleParameters getEncircledEnergyModuleParameters() {
        return encircledEnergyConfigurationStruct;
    }

    public void setEncircledEnergyModuleParameters(
        final EncircledEnergyModuleParameters encircledEnergyModuleParameters) {
        encircledEnergyConfigurationStruct = encircledEnergyModuleParameters;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public boolean isFirstCall() {
        return firstCall;
    }

    public GapFillModuleParameters getGapFillModuleParameters() {
        return gapFillConfigurationStruct;
    }

    public void setGapFillModuleParameters(
        final GapFillModuleParameters gapFillModuleParameters) {
        gapFillConfigurationStruct = gapFillModuleParameters;
    }

    public PaHarmonicsIdentificationParameters getHarmonicsIdentificationParameters() {
        return harmonicsIdentificationConfigurationStruct;
    }

    public void setHarmonicsIdentificationParameters(
        PaHarmonicsIdentificationParameters harmonicsIdentificationParameters) {
        harmonicsIdentificationConfigurationStruct = harmonicsIdentificationParameters;
    }

    public boolean isLastCall() {
        return lastCall;
    }

    public void setLastCall(final boolean lastCall) {
        this.lastCall = lastCall;
    }

    public TimestampSeries getLongCadenceTimes() {
        return longCadenceTimes;
    }

    public void setLongCadenceTimes(final TimestampSeries longCadenceTimes) {
        this.longCadenceTimes = longCadenceTimes;
    }

    public BlobFileSeries getMotionBlobs() {
        return motionBlobs;
    }

    public void setMotionBlobs(final BlobFileSeries motionBlobs) {
        this.motionBlobs = motionBlobs;
    }

    public MotionModuleParameters getMotionModuleParameters() {
        return motionConfigurationStruct;
    }

    public void setMotionModuleParameters(
        final MotionModuleParameters motionModuleParameters) {
        motionConfigurationStruct = motionModuleParameters;
    }

    public PaModuleParameters getPaModuleParameters() {
        return paConfigurationStruct;
    }

    public void setPaModuleParameters(
        final PaModuleParameters paModuleParameters) {
        paConfigurationStruct = paModuleParameters;
    }

    public PaCoaModuleParameters getPaCoaModuleParameters() {
        return paCoaConfigurationStruct;
    }

    public void setPaCoaModuleParameters(
        PaCoaModuleParameters paCoaModuleParameters) {
        paCoaConfigurationStruct = paCoaModuleParameters;
    }

    public PouModuleParameters getPouModuleParameters() {
        return pouConfigurationStruct;
    }

    public void setPouModuleParameters(
        final PouModuleParameters pouModuleParameters) {
        pouConfigurationStruct = pouModuleParameters;
    }

    public int getPpaTargetCount() {
        return ppaTargetCount;
    }

    public void setPpaTargetCount(int ppaTargetCount) {
        this.ppaTargetCount = ppaTargetCount;
    }

    public PrfModel getPrfModel() {
        return prfModel;
    }

    public void setPrfModel(final PrfModel prfModel) {
        this.prfModel = prfModel;
    }

    public String getProcessingState() {
        return processingState;
    }

    public void setProcessingState(String processingState) {
        this.processingState = processingState;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public ReadNoiseModel getReadNoiseModel() {
        return readNoiseModel;
    }

    public void setReadNoiseModel(ReadNoiseModel readNoiseModel) {
        this.readNoiseModel = readNoiseModel;
    }

    public GainModel getGainModel() {
        return gainModel;
    }

    public void setGainModel(GainModel gainModel) {
        this.gainModel = gainModel;
    }

    public LinearityModel getLinearityModel() {
        return linearityModel;
    }

    public void setLinearityModel(LinearityModel linearityModel) {
        this.linearityModel = linearityModel;
    }

    public ReactionWheelAncillaryEngineeringParameters getReactionWheelAncillaryEngineeringParameters() {
        return reactionWheelAncillaryEngineeringConfigurationStruct;
    }

    public void setReactionWheelAncillaryEngineeringParameters(
        ReactionWheelAncillaryEngineeringParameters reactionWheelAncillaryEngineeringParameters) {
        reactionWheelAncillaryEngineeringConfigurationStruct = reactionWheelAncillaryEngineeringParameters;
    }

    public List<RollingBandArtifactFlags> getRollingBandArtifactFlags() {
        return rollingBandArtifactFlags;
    }

    public void setRollingBandArtifactFlags(
        List<RollingBandArtifactFlags> rollingBandArtifactFlags) {
        this.rollingBandArtifactFlags = rollingBandArtifactFlags;
    }

    public SaturationSegmentModuleParameters getSaturationSegmentModuleParameters() {
        return saturationSegmentConfigurationStruct;
    }

    public void setSaturationSegmentModuleParameters(
        SaturationSegmentModuleParameters saturationSegmentModuleParameters) {
        saturationSegmentConfigurationStruct = saturationSegmentModuleParameters;
    }

    public ThrusterDataAncillaryEngineeringParameters getThrusterDataAncillaryEngineeringParameters() {
        return thrusterDataAncillaryEngineeringConfigurationStruct;
    }

    public void setThrusterDataAncillaryEngineeringParameters(
        ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters) {
        thrusterDataAncillaryEngineeringConfigurationStruct = thrusterDataAncillaryEngineeringParameters;
    }

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public List<PaTarget> getTargets() {
        return targetStarDataStruct;
    }

    public void setTargets(final List<PaTarget> targets) {
        targetStarDataStruct = targets;
    }

    public String getTransitInjectionParametersFileName() {
        return transitInjectionParametersFileName;
    }

    public void setTransitInjectionParametersFileName(
        String transitInjectionParametersFileName) {
        this.transitInjectionParametersFileName = transitInjectionParametersFileName;
    }

    public ApertureModelParameters getApertureModelParameters() {
        return apertureModelConfigurationStruct;
    }

    public void setApertureModelParameters(
        ApertureModelParameters apertureModelConfigurationStruct) {
        this.apertureModelConfigurationStruct = apertureModelConfigurationStruct;
    }

}
