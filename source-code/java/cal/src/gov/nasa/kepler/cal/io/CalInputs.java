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

package gov.nasa.kepler.cal.io;

import gov.nasa.kepler.cal.DataPresentEnum;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.mc.*;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import static gov.nasa.kepler.cal.DataPresentEnum.*;

/**
 * Inputs for the cal pipeline module.
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * @author Bill Wohler
 * @author Jason Brittain
 */
public class CalInputs implements Persistable {

    /**
     * Inputs version information.  Useful for debugging.
     * 
     * <ul>
     * <ul> 19 K2 Campaign.
     * <li> 18 Added season.
     * <li> 17 Added emptyInputs flag.
     * <li> 16 Harmonics identification parameters and gap fill parameters.
     * <li> 15 FFI rows.
     * <li> 14 Smear blob.
     * <li> 13  Add invocation number.
     * <li> 12 - pipeline info
     * <li> 11 - Add dynamic 2d black blob</li>
     * <li> 10 - Add 1D black parameters</li>
     * <li> 9 - Use CosmicRayParameters</li>
     * <li> 8 - FFI cal changes. </li>
     * <li> 7 - Refactor pou parameters.</li>
     * <li> 6 - Added pouDecimation parameters. </li>
     * <li> 5 - Added Bruce/Joe's new input parameters </li>
     * <li> 4 - Add start/end timestamps to Timestamps class. Change debug
     * to integer.</li> 
     * </ul>
     */
    @SuppressWarnings("unused")
    private String version = "CalInputs Version 18";

    /** Debug level for cal-matlab.  Higher levels will produce more verbose
     * logging.  The behavior of this parameter is not well defined. 
     */
    @SuppressWarnings("unused")
    private int debugLevel = 0;
    /**
     * True when this is the first time Cal-matlab module is called.
     */
    private boolean firstCall = true;

    /** True when this is the last time Cal-matlab module is called. */
    private boolean lastCall = true;

    /**
     * When true the inputs to cal are empty.  Cal should generate outputs that
     * can be used to erase any existing inputs.
     */
    private boolean emptyInputs = false;
    
    /**
     * Zero based.
     */
    @SuppressWarnings("unused")
    private int calInvocationNumber;
    
    /**
     * The number of cal invocations for this unit of work.  This includes the
     * collateral and target pixel invocations.
     */
    @SuppressWarnings("unused")
    private int totalCalInvocations;
    
    /**
     * Total number of pixels to expect. This is the whole enchilada. target,
     * background, collateral.
     */
    private int totalPixels = 0;

    /**
     * Type of cadence 'LONG' or 'SHORT' or 'FFI'.
     */
    private String cadenceType;

    /**
     * CCD module for this run of CAL.
     */
    private int ccdModule;

    /**
     * CCD output for this run of CAL.
     */
    private int ccdOutput;

    /**
     * Module parameters.
     */
    private CalModuleParameters moduleParametersStruct;

    /**
     * Cosmic ray identification parameters.
     */
    private CalCosmicRayParameters cosmicRayParametersStruct;
    
    /**
     * Propagation of uncertainty parameters.
     */
    private PouModuleParameters pouModuleParametersStruct;

    /**
     * Needed for autoregressive cosmic ray detection.
     */
    private CalHarmonicsIdentificationParameters harmonicsIdentificationConfigurationStruct;
    
    /**
     * Needed for autoregressive cosmic ray detection.
     */
    private GapFillModuleParameters gapFillConfigurationStruct;
    
    /**
     * Focal plane characteristics constants.
     */
    private FcConstants fcConstants = new FcConstants();

    /**
     * Cadence mid points in mjd.
     */
    private TimestampSeries cadenceTimes;

    /**
     * A gain model that covers the relevant interval of time. 
     * Opaque.  See Focal Plane Characterization SDD.
     */
    private GainModel gainModel;

    /**
     * The flat field model that covers the relevant interval of time.
     * Opaque.  See focal plane characterization SDD.  [1004.CAL.1]
     */
    private FlatFieldModel flatFieldModel;

    /**
     * The 2D black model that covers the relevant interval of time.
     * Opaque.  See focal plane characterization SDD.  CAL1.CAL.3
     */
    private TwoDBlackModel twoDBlackModel;

    /**
     * A linearity model that covers the relevant interval of time.
     * Opaque.  See focal plane characterization SDD.
     */
    private LinearityModel linearityModel;

    /**
     * An undershoot model that covers the relevant interval of time.
     * Opaque.  See focal plane characterization SDD.  [CAL2]
     */
    private UndershootModel undershootModel;

    /**
     * A read noise model that covers the relevant interval of time.
     * Opaque.  See focal plane characterization SDD.
     */
    private ReadNoiseModel readNoiseModel;

    /**
     * Per-pixel time series data for target and background pixels.  If
     * collateral pixels are being calibrated then this will be an empty list of
     * pixels.  Uncalibrated pixels to calibrate.  Cal-java will only send 
     * complete rows of pixels in each Cal-matlab call. [1002.CAL.1]
     */
    private List<CalInputPixelTimeSeries> targetAndBkgPixels = new ArrayList<CalInputPixelTimeSeries>();

    /**
     * Pixel addresses involved in 2D black metrics computations.  
     * Each id contains the pixel addresses for one target.
     */
    @SuppressWarnings("unused")
    private List<TwoDBlackId> twoDBlackIds = new ArrayList<TwoDBlackId>();

    /**
     * Pixel addresses involved in LDE undershoot metrics computations.  Each id
     *  contains the pixel addresses for one target.
     */
    @SuppressWarnings("unused")
    private List<LdeUndershootId> ldeUndershootIds = new ArrayList<LdeUndershootId>();

    /**
     * Per-column masked smear time series data.  Either all the masked smear 
     * pixels or none of them.  For short cadence this will be a subset of 
     * pixels. [1002.CAL.1]
     */
    private List<SmearTimeSeries> maskedSmearPixels = new ArrayList<SmearTimeSeries>();

    /**
     * Per-column virtual smear time series data.
     * Either all the virtual smear pixels or none of them.  For short cadence 
     * this will be a subset of pixels. [1002.CAL.1]
     */
    private List<SmearTimeSeries> virtualSmearPixels = new ArrayList<SmearTimeSeries>();

    /**
     * Per-row black level time series data.
     * Either the leading or trailing black or no black pixels.  For short 
     * cadence this will be a subset of the pixels. [1002.CAL.1]
     */
    private List<BlackTimeSeries> blackPixels = new ArrayList<BlackTimeSeries>();

    /**
     * Per-row masked black time series data.  A list of length zero or one 
     * which is used during short cadence for the black pixel which is
     *  also masked. [1002.CAL.1]
     */
    private List<SingleBlackTimeSeries> maskedBlackPixels = new ArrayList<SingleBlackTimeSeries>();

    /**
     * Per-row virtual black time series data.
     * A list of length zero or one which is used during short cadence for the 
     * black pixel which is also in the virtual smear rows. [1002.CAL.1]
     */
    private List<SingleBlackTimeSeries> virtualBlackPixels = new ArrayList<SingleBlackTimeSeries>();

    /** Spacecraft configmaps that where active during this time interval.
     */
    private List<ConfigMap> spacecraftConfigMap = new ArrayList<ConfigMap>();

    /** The list of active requantization tables that where active during the 
      * time period covered by target tables in effect.  This is described in
      * the Generate Activity Request SDD.
      */
    @SuppressWarnings("unused")
    private List<RequantTable> requantTables = new ArrayList<RequantTable>();

    /** The list of active Huffman tables that where active during the 
     * time period covered by target tables in effect.  This is described in
     * the Generate Activity Request SDD.
     */
    @SuppressWarnings("unused")
    private List<HuffmanTable> huffmanTables = new ArrayList<HuffmanTable>();

    /**
     * This is used for collateral when all the collateral pixels are available
     * not just to co-added columns.  This is the case when an FFI is being
     * calibrated.
     */
    private Cal2DCollateral twoDCollateral = new Cal2DCollateral();
    
    /**
     * The observing season of the target table covering this cadence interval.
     */
    private int season;
    
    private int quarter;
    
    private int k2Campaign;
    
    /**
     * 
     */
    private BlobFileSeries oneDBlackBlobs = new BlobFileSeries();
    
    private BlobFileSeries dynamic2DBlackBlobs = new BlobFileSeries();
    
    /**
     * These are the smear blobs produce by cal long cadence to be used by
     * cal short cadence.  These should only be valid in a short cadence
     * input file.
     */
    private BlobFileSeries smearBlobs = new BlobFileSeries();
    
    @SuppressWarnings("unused")
    private EmbeddedPipelineInfo pipelineInfoStruct;
    
    private List<FitsImage> ffis;
    
    /** Don't use this constructor. It is used by persistable. */
    public CalInputs() {
    }

    private CalInputs(CommonParameters commonParameters, int invocationNumber,
        int totalInvocations, DataPresentEnum hasData) {

        this.ccdModule = commonParameters.ccdModule();
        this.ccdOutput = commonParameters.ccdOutput();
        this.cadenceType = commonParameters.cadenceTypeStr();
        this.moduleParametersStruct = commonParameters.moduleParametersStruct();
        this.pouModuleParametersStruct = commonParameters.pouModuleParametersStruct();
        this.cosmicRayParametersStruct = commonParameters.cosmicRayParametersStruct();
        this.harmonicsIdentificationConfigurationStruct = commonParameters.harmonicsParametersStruct();
        this.gapFillConfigurationStruct = commonParameters.gapFillParametersStruct();
        this.cadenceTimes =  commonParameters.cadenceTimes();
        this.gainModel = commonParameters.gainModel();
        this.flatFieldModel = commonParameters.flatFieldModel();
        this.twoDBlackModel = commonParameters.twoDBlackModel();
        this.linearityModel = commonParameters.linearityModel();
        this.undershootModel = commonParameters.undershootModel();
        this.readNoiseModel = commonParameters.readNoiseModel();
        this.spacecraftConfigMap = commonParameters.spacecraftConfigMap();
        this.huffmanTables = commonParameters.huffmanTables();
        this.requantTables = commonParameters.requantTables();
        this.ldeUndershootIds = commonParameters.ldeUndershootIds();
        this.twoDBlackIds = commonParameters.twoDBlackIds();
        this.season = commonParameters.season();
        this.dynamic2DBlackBlobs = commonParameters.dynamic2DBlackBlobs();
        this.smearBlobs = commonParameters.smearBlobs();
        this.pipelineInfoStruct = commonParameters.embeddedPipelineInfo();
        this.calInvocationNumber = invocationNumber;
        this.totalCalInvocations = totalInvocations;
        this.emptyInputs = commonParameters.emptyParameters() || hasData == DataMissing;
        this.quarter = commonParameters.quarter();
        this.k2Campaign = commonParameters.k2Campaign();
    }

    /**
     * Calibrated target and background pixels.
     */
    public CalInputs(CommonParameters commonParameters,
        int invocationNumber, int totalInvocations,
        List<CalInputPixelTimeSeries> targetAndBkgPixels,
        List<FitsImage> ffis, DataPresentEnum hasData) {

        this(commonParameters, invocationNumber, totalInvocations, hasData);

        this.targetAndBkgPixels = targetAndBkgPixels;
        this.firstCall = false;
        this.ffis = ffis;
    }

    /**
     * Long cadence collateral calibration.
     */
    public CalInputs(CommonParameters commonParameters,
        int totalInvocations,
        List<SmearTimeSeries> maskedSmear, List<SmearTimeSeries> virtualSmear,
        List<BlackTimeSeries> black,
        List<FitsImage> ffis, DataPresentEnum hasData) {

        this(commonParameters,0 /*invocationNumber*/, totalInvocations, hasData);

        this.maskedSmearPixels = maskedSmear;
        this.virtualSmearPixels = virtualSmear;
        this.blackPixels = black;
        this.firstCall = true;
        this.lastCall = false;
        this.ffis = ffis;
    }

    /**
     * Short cadence collateral calibration.
     */
    public CalInputs(CommonParameters commonParameters,
        int totalInvocations,
        List<SmearTimeSeries> maskedSmear, List<SmearTimeSeries> virtualSmear,
        List<BlackTimeSeries> black, List<SingleBlackTimeSeries> maskedBlack,
        List<SingleBlackTimeSeries> virtualBlack,
        List<FitsImage> ffis, DataPresentEnum hasData) {

        this(commonParameters,0 /* invocationNumber*/, totalInvocations, hasData);

        this.maskedSmearPixels = maskedSmear;
        this.virtualSmearPixels = virtualSmear;
        this.blackPixels = black;
        this.virtualBlackPixels = virtualBlack;
        this.maskedBlackPixels = maskedBlack;
        this.firstCall = true;
        this.lastCall = false;
        this.ffis = ffis;

    }

    /**
     * FFI collateral inputs.
     */
    public CalInputs(int ccdModule, int ccdOutput,
        CalModuleParameters calModuleParameters,
        PouModuleParameters pouModuleParameters,
        CalCosmicRayParameters cosmicRayParameters,
        CalHarmonicsIdentificationParameters harmonicsParameters,
        GapFillModuleParameters gapFillParameters,
        TimestampSeries cadenceTimes,
        GainModel gainModel, FlatFieldModel flatFieldModel,
        TwoDBlackModel twoDBlackModel, LinearityModel linearityModel,
        UndershootModel undershootModel, ReadNoiseModel readNoiseModel,
        List<ConfigMap> configMaps, int season, BlobFileSeries dyablobs,
        EmbeddedPipelineInfo pipelineInfo, Cal2DCollateral twoDCollateral) {
        
        this.cadenceType = "FFI";
        this.lastCall = false;
        this.firstCall = true;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.moduleParametersStruct = calModuleParameters;
        this.cadenceTimes = cadenceTimes;
        this.gainModel = gainModel;
        this.flatFieldModel = flatFieldModel;
        this.twoDBlackModel = twoDBlackModel;
        this.linearityModel = linearityModel;
        this.undershootModel = undershootModel;
        this.readNoiseModel = readNoiseModel;
        this.spacecraftConfigMap = configMaps;
        this.season = season;
        this.dynamic2DBlackBlobs = dyablobs;
        this.pipelineInfoStruct = pipelineInfo;
        this.twoDCollateral = twoDCollateral;
        this.calInvocationNumber = 0;
        this.totalCalInvocations = 2;
        this.pouModuleParametersStruct = pouModuleParameters;
        this.ffis = Collections.emptyList();
        this.cosmicRayParametersStruct = cosmicRayParameters;
        this.harmonicsIdentificationConfigurationStruct = harmonicsParameters;
        this.gapFillConfigurationStruct = gapFillParameters;
        this.emptyInputs = false;
        //TODO:  When we get this from the database we will need to get this
        //from somewhere other than calModuleParameters.
        this.k2Campaign = calModuleParameters.getK2Campaign();
    }
    
    /**
     * FFI visible pixel inputs.
     */
    public CalInputs(int ccdModule, int ccdOutput,
        CalModuleParameters calModuleParameters,
        PouModuleParameters pouModuleParameters,
        CalCosmicRayParameters cosmicRayParameters,
        CalHarmonicsIdentificationParameters harmonicsParameters,
        GapFillModuleParameters gapFillParameters,
        TimestampSeries cadenceTimes,
        GainModel gainModel, FlatFieldModel flatFieldModel,
        TwoDBlackModel twoDBlackModel, LinearityModel linearityModel,
        UndershootModel undershootModel, ReadNoiseModel readNoiseModel,
        List<ConfigMap> configMaps, int season,
        BlobFileSeries dyablobs,
        EmbeddedPipelineInfo pipelineInfo, 
        List<CalInputPixelTimeSeries> visiblePixels) {
        
        this.cadenceType = "FFI";
        this.lastCall = true;
        this.firstCall = false;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.moduleParametersStruct = calModuleParameters;
        this.cadenceTimes = cadenceTimes;
        this.gainModel = gainModel;
        this.flatFieldModel = flatFieldModel;
        this.twoDBlackModel = twoDBlackModel;
        this.linearityModel = linearityModel;
        this.undershootModel = undershootModel;
        this.readNoiseModel = readNoiseModel;
        this.spacecraftConfigMap = configMaps;
        this.season = season;
        this.dynamic2DBlackBlobs = dyablobs;
        this.pipelineInfoStruct = pipelineInfo;
        this.targetAndBkgPixels = visiblePixels;
        this.calInvocationNumber = 1;
        this.totalCalInvocations = 2;
        this.pouModuleParametersStruct = pouModuleParameters;
        this.ffis = Collections.emptyList();
        this.cosmicRayParametersStruct = cosmicRayParameters;
        this.harmonicsIdentificationConfigurationStruct = harmonicsParameters;
        this.gapFillConfigurationStruct = gapFillParameters;
        this.emptyInputs = false;
        this.k2Campaign = calModuleParameters.getK2Campaign();
    }
    
    public int season() {
        return season;
    }

    public BlobFileSeries dynamic2DBlackBlobs() {
        return dynamic2DBlackBlobs;
    }

    public CadenceType getCadenceType() {
        return CadenceType.valueOf(cadenceType);
    }

    public void setCadenceType(CadenceType cadenceType) {
        this.cadenceType = cadenceType.name();
    }

    public int getCcdModule() {
        return ccdModule;
    }

    public void setCcdModule(int ccdModule) {
        this.ccdModule = ccdModule;
    }

    public int getCcdOutput() {
        return ccdOutput;
    }

    public void setCcdOutput(int ccdOutput) {
        this.ccdOutput = ccdOutput;
    }

    public CalModuleParameters getModuleParameters() {
        return moduleParametersStruct;
    }

    public void setModuleParameters(CalModuleParameters moduleParameters) {
        this.moduleParametersStruct = moduleParameters;
    }

    public PouModuleParameters getPouModuleParameters() {
        return pouModuleParametersStruct;
    }

    public void setPouModuleParameters(PouModuleParameters pouModuleParameters) {
        this.pouModuleParametersStruct = pouModuleParameters;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public FlatFieldModel getFlatFieldModel() {
        return flatFieldModel;
    }

    public void setFlatFieldModel(FlatFieldModel flatFieldModel) {
        this.flatFieldModel = flatFieldModel;
    }

    public GainModel getGainModel() {
        return gainModel;
    }

    public void setGainModel(GainModel gainModel) {
        this.gainModel = gainModel;
    }

    public List<BlackTimeSeries> getBlackPixels() {
        return blackPixels;
    }

    public void setBlackPixels(List<BlackTimeSeries> blackPixels) {
        this.blackPixels = blackPixels;
    }

    public List<ConfigMap> getSpacecraftConfigMap() {
        return spacecraftConfigMap;
    }

    public void setSpacecraftConfigMap(List<ConfigMap> maps) {
        this.spacecraftConfigMap = maps;
    }

    public LinearityModel getLinearityModel() {
        return linearityModel;
    }

    public void setLinearityModel(LinearityModel linearityModel) {
        this.linearityModel = linearityModel;
    }

    public List<CalInputPixelTimeSeries> getTargetAndBkgPixels() {
        return targetAndBkgPixels;
    }

    public void setTargetAndBkgPixels(List<CalInputPixelTimeSeries> pixels) {
        this.targetAndBkgPixels = pixels;
    }

    public ReadNoiseModel getReadNoiseModel() {
        return readNoiseModel;
    }

    public void setReadNoiseModel(ReadNoiseModel readNoiseModel) {
        this.readNoiseModel = readNoiseModel;
    }

    public List<SmearTimeSeries> getMaskedSmearPixels() {
        return maskedSmearPixels;
    }

    public void setMaskedSmearPixels(List<SmearTimeSeries> maskedSmearPixels) {
        this.maskedSmearPixels = maskedSmearPixels;
    }

    public TwoDBlackModel getTwoDBlackModel() {
        return twoDBlackModel;
    }

    public void setTwoDBlackModel(TwoDBlackModel twoDBlackModel) {
        this.twoDBlackModel = twoDBlackModel;
    }

    public UndershootModel getUndershootModel() {
        return undershootModel;
    }

    public void setUndershootModel(UndershootModel undershootModel) {
        this.undershootModel = undershootModel;
    }

    public List<SmearTimeSeries> getVirtualSmearPixels() {
        return virtualSmearPixels;
    }

    public void setVirtualSmearPixels(List<SmearTimeSeries> virtualSmearPixels) {
        this.virtualSmearPixels = virtualSmearPixels;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public boolean isFirstCall() {
        return firstCall;
    }

    public void setFirstCall(boolean newState) {
        this.firstCall = newState;
    }

    public boolean isLastCall() {
        return lastCall;
    }

    public void setLastCall(boolean newState) {
        this.lastCall = newState;
    }

    public int getTotalPixels() {
        return totalPixels;
    }

    public void setTotalPixels(int totalPixels) {
        this.totalPixels = totalPixels;
    }

    public List<SingleBlackTimeSeries> getMaskedBlackPixels() {
        return maskedBlackPixels;
    }

    public void setMaskedBlackPixels(
        List<SingleBlackTimeSeries> maskedBlackPixels) {
        this.maskedBlackPixels = maskedBlackPixels;
    }

    public List<SingleBlackTimeSeries> getVirtualBlackPixels() {
        return virtualBlackPixels;
    }

    public void setVirtualBlackPixels(
        List<SingleBlackTimeSeries> virtualBlackPixels) {
        this.virtualBlackPixels = virtualBlackPixels;
    }

    public Cal2DCollateral getTwoDCollateral() {
        return twoDCollateral;
    }

    public CalCosmicRayParameters getCalCosmicRayParametersStruct() {
        return cosmicRayParametersStruct;
    }

    public BlobFileSeries getOneDBlackBlobs() {
        return oneDBlackBlobs;
    }

    public void setOneDBlackBlobs(BlobFileSeries oneDBlackBlobs) {
        this.oneDBlackBlobs = oneDBlackBlobs;
    }

    public void setDynamic2DBlackBlobs(BlobFileSeries dynamic2dBlackBlobs) {
        this.dynamic2DBlackBlobs = dynamic2dBlackBlobs;
    }
    
    public  BlobFileSeries getSmearBlobs() {
        return smearBlobs;
    }
    
    public void setSmearBlobs(BlobFileSeries smearBlobs) {
        this.smearBlobs = smearBlobs;
    }

    
}
