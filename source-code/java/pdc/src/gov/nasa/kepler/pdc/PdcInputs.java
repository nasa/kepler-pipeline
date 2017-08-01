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
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.SaturationSegmentModuleParameters;
import gov.nasa.kepler.common.pi.AncillaryDesignMatrixParameters;
import gov.nasa.kepler.common.pi.AncillaryEngineeringParameters;
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.mc.DiscontinuityParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pa.ThrusterDataAncillaryEngineeringParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * @author Forrest Girouard
 * @author jgunter
 * @author Bill Wohler
 */
public class PdcInputs implements Persistable {

    /**
     * "LONG" or "SHORT"
     */
    private String cadenceType = CadenceType.LONG.toString();

    /**
     * Starting cadence number.
     */
    private int startCadence;

    /**
     * Ending cadence number.
     */
    private int endCadence;

    /**
     * Focal plane characterization constants.
     */
    private FcConstants fcConstants = new FcConstants();

    // SOC PDC2.3 inputs: number of short cadences per long cadence.
    /**
     * Spacecraft configuration parameters.
     */
    private List<ConfigMap> spacecraftConfigMap = newArrayList();

    /**
     * Cadence start, mid, and end mjds along with gap and requant flags.
     */
    private PdcTimestampSeries cadenceTimes = new PdcTimestampSeries();

    /**
     * Long cadence start, mid, and end mjds along with gap and requant flags.
     */
    private PdcTimestampSeries longCadenceTimes = new PdcTimestampSeries();

    /**
     * PDC-specific module parameters set by the PIG.
     */
    private PdcModuleParameters pdcModuleParameters = new PdcModuleParameters();

    /**
     * RaDec2PixelModel.
     */
    private RaDec2PixModel raDec2PixModel = new RaDec2PixModel();

    /**
     * Ancillary engineering (from spacecraft) data parameters.
     */
    private AncillaryEngineeringParameters ancillaryEngineeringConfigurationStruct = new AncillaryEngineeringParameters();

    /**
     * Thruster firing records from ancillary engineering (spacecraft) data
     * parameters.
     */
    private ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringConfigurationStruct = new ThrusterDataAncillaryEngineeringParameters();

    /**
     * Contains the ancillary engineering data for the mnemonics specified in
     * the {@code AncillaryEngineeringParameters}.
     */
    // SOC PDC2.5,7: inputs: timestamps for ancillary data is in
    // AncillaryData.timestamps double[].
    private List<AncillaryEngineeringData> ancillaryEngineeringDataStruct = newArrayList();

    /**
     * Ancillary pipeline (from SOC pipeline) data parameters.
     */
    private AncillaryPipelineParameters ancillaryPipelineConfigurationStruct = new AncillaryPipelineParameters();

    /**
     * Ancillary design matrix parameters.
     */
    private AncillaryDesignMatrixParameters ancillaryDesignMatrixConfigurationStruct = new AncillaryDesignMatrixParameters();

    /**
     * Gap fill related module parameters.
     */
    private GapFillModuleParameters gapFillConfigurationStruct = new GapFillModuleParameters();

    /**
     * Saturation segment module parameters.
     */
    private SaturationSegmentModuleParameters saturationSegmentConfigurationStruct = new SaturationSegmentModuleParameters();

    /**
     * Harmonic identification related parameters.
     */
    private PdcHarmonicsIdentificationParameters harmonicsIdentificationConfigurationStruct = new PdcHarmonicsIdentificationParameters();

    /**
     * Discontinuity related parameters.
     */
    private DiscontinuityParameters discontinuityConfigurationStruct = new DiscontinuityParameters();

    /**
     * PDC MAP related parameters.
     */
    private PdcMapParameters mapConfigurationStruct = new PdcMapParameters();

    /**
     * SPSD related parameters.
     */
    private SpsdDetectionParameters spsdDetectionConfigurationStruct = new SpsdDetectionParameters();
    private SpsdDetectorParameters spsdDetectorConfigurationStruct = new SpsdDetectorParameters();
    private SpsdRemovalParameters spsdRemovalConfigurationStruct = new SpsdRemovalParameters();

    /**
     * Parameters related to goodness metric.
     */
    private PdcGoodnessMetricParameters goodnessMetricConfigurationStruct = new PdcGoodnessMetricParameters();

    /**
     * Parameters related to band splitting.
     */
    private BandSplittingParameters bandSplittingConfigurationStruct = new BandSplittingParameters();

    /**
     * Per-channel inputs.
     */
    private List<PdcInputChannelData> channelDataStruct = newArrayList();

    public PdcInputs() {
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public void setFcConstants(FcConstants fcConstants) {
        this.fcConstants = fcConstants;
    }

    public List<ConfigMap> getSpacecraftConfigMap() {
        return spacecraftConfigMap;
    }

    public void setSpacecraftConfigMap(List<ConfigMap> spacecraftConfigMap) {
        this.spacecraftConfigMap = spacecraftConfigMap;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(PdcTimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public PdcModuleParameters getPdcModuleParameters() {
        return pdcModuleParameters;
    }

    public void setPdcModuleParameters(PdcModuleParameters pdcModuleParameters) {
        this.pdcModuleParameters = pdcModuleParameters;
    }

    public AncillaryEngineeringParameters getAncillaryEngineeringParameters() {
        return ancillaryEngineeringConfigurationStruct;
    }

    public void setAncillaryEngineeringParameters(
        AncillaryEngineeringParameters ancillaryEngineeringParameters) {
        ancillaryEngineeringConfigurationStruct = ancillaryEngineeringParameters;
    }

    public ThrusterDataAncillaryEngineeringParameters getThrusterDataAncillaryEngineeringParameters() {
        return thrusterDataAncillaryEngineeringConfigurationStruct;
    }

    public void setThrusterDataAncillaryEngineeringParameters(
        ThrusterDataAncillaryEngineeringParameters thrusterDataAncillaryEngineeringParameters) {
        thrusterDataAncillaryEngineeringConfigurationStruct = thrusterDataAncillaryEngineeringParameters;
    }

    public List<AncillaryEngineeringData> getAncillaryEngineeringData() {
        return ancillaryEngineeringDataStruct;
    }

    public void setAncillaryEngineeringData(
        List<AncillaryEngineeringData> ancillaryEngineeringData) {
        ancillaryEngineeringDataStruct = ancillaryEngineeringData;
    }

    public AncillaryPipelineParameters getAncillaryPipelineParameters() {
        return ancillaryPipelineConfigurationStruct;
    }

    public void setAncillaryPipelineParameters(
        AncillaryPipelineParameters ancillaryPipelineParameters) {
        ancillaryPipelineConfigurationStruct = ancillaryPipelineParameters;
    }

    public int getStartCadence() {
        return startCadence;
    }

    public void setStartCadence(int startCadence) {
        this.startCadence = startCadence;
    }

    public int getEndCadence() {
        return endCadence;
    }

    public void setEndCadence(int endCadence) {
        this.endCadence = endCadence;
    }

    public String getCadenceType() {
        return cadenceType;
    }

    public void setCadenceType(String cadenceType) {
        this.cadenceType = cadenceType;
    }

    public GapFillModuleParameters getGapFillModuleParameters() {
        return gapFillConfigurationStruct;
    }

    public void setGapFillModuleParameters(
        GapFillModuleParameters gapFillModuleParameters) {
        gapFillConfigurationStruct = gapFillModuleParameters;
    }

    public TimestampSeries getLongCadenceTimes() {
        return longCadenceTimes;
    }

    public void setLongCadenceTimes(PdcTimestampSeries longCadenceTimes) {
        this.longCadenceTimes = longCadenceTimes;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public AncillaryDesignMatrixParameters getAncillaryDesignMatrixParameters() {
        return ancillaryDesignMatrixConfigurationStruct;
    }

    public void setAncillaryDesignMatrixParameters(
        AncillaryDesignMatrixParameters ancillaryDesignMatrixParameters) {
        ancillaryDesignMatrixConfigurationStruct = ancillaryDesignMatrixParameters;
    }

    public SaturationSegmentModuleParameters getSaturationSegmentParameters() {
        return saturationSegmentConfigurationStruct;
    }

    public void setSaturationSegmentParameters(
        SaturationSegmentModuleParameters saturationSegmentParameters) {
        saturationSegmentConfigurationStruct = saturationSegmentParameters;
    }

    public PdcHarmonicsIdentificationParameters getHarmonicsIdentificationParameters() {
        return harmonicsIdentificationConfigurationStruct;
    }

    public void setHarmonicsIdentificationParameters(
        PdcHarmonicsIdentificationParameters harmonicsIdentificationParameters) {
        harmonicsIdentificationConfigurationStruct = harmonicsIdentificationParameters;
    }

    public DiscontinuityParameters getDiscontinuityParameters() {
        return discontinuityConfigurationStruct;
    }

    public void setDiscontinuityParameters(
        DiscontinuityParameters discontinuityParameters) {
        discontinuityConfigurationStruct = discontinuityParameters;
    }

    public PdcMapParameters getPdcMapParameters() {
        return mapConfigurationStruct;
    }

    public void setPdcMapParameters(PdcMapParameters pdcMapParameters) {
        mapConfigurationStruct = pdcMapParameters;
    }

    public SpsdDetectionParameters getSpsdDetectionParameters() {
        return spsdDetectionConfigurationStruct;
    }

    public void setSpsdDetectionParameters(
        SpsdDetectionParameters spsdDetectionParameters) {
        spsdDetectionConfigurationStruct = spsdDetectionParameters;
    }

    public SpsdDetectorParameters getSpsdDetectorParameters() {
        return spsdDetectorConfigurationStruct;
    }

    public void setSpsdDetectorParameters(
        SpsdDetectorParameters spsdDetectorParameters) {
        spsdDetectorConfigurationStruct = spsdDetectorParameters;
    }

    public SpsdRemovalParameters getSpsdRemovalParameters() {
        return spsdRemovalConfigurationStruct;
    }

    public void setSpsdRemovalParameters(
        SpsdRemovalParameters spsdRemovalParameters) {
        spsdRemovalConfigurationStruct = spsdRemovalParameters;
    }

    public PdcGoodnessMetricParameters getPdcGoodnessMetricParameters() {
        return goodnessMetricConfigurationStruct;
    }

    public void setPdcGoodnessMetricParameters(
        PdcGoodnessMetricParameters pdcGoodnessMetricParameters) {
        goodnessMetricConfigurationStruct = pdcGoodnessMetricParameters;
    }

    public BandSplittingParameters getBandSplittingParameters() {
        return bandSplittingConfigurationStruct;
    }

    public void setBandSplittingParameters(
        BandSplittingParameters bandSplittingParameters) {
        bandSplittingConfigurationStruct = bandSplittingParameters;
    }

    public List<PdcInputChannelData> getChannelData() {
        return channelDataStruct;
    }

    public void setChannelDataStruct(List<PdcInputChannelData> channelData) {
        channelDataStruct = channelData;
    }
}
