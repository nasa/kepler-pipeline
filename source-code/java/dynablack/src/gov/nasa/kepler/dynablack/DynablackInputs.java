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

package gov.nasa.kepler.dynablack;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.cal.io.BlackTimeSeries;
import gov.nasa.kepler.cal.io.CalInputPixelTimeSeries;
import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.cal.io.SmearTimeSeries;
import gov.nasa.kepler.common.AncillaryEngineeringData;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.mc.FitsImage;
import gov.nasa.kepler.mc.RollingBandArtifactParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * Inputs for the {@link DynablackPipelineModule}.
 * 
 * @author Miles Cote
 * 
 */
public class DynablackInputs implements Persistable {

    private int ccdModule;
    private int ccdOutput;

    /**
     * The observing season of the target table covering this cadence interval.
     */
    private int season;

    private DynablackModuleParameters dynablackModuleParameters = new DynablackModuleParameters();
    private RollingBandArtifactParameters rbaFlagConfigurationStruct = new RollingBandArtifactParameters();

    private List<AncillaryEngineeringData> ancillaryEngineeringDataStruct = newArrayList();

    private List<FitsImage> rawFfis = newArrayList();

    private TimestampSeries cadenceTimes = new TimestampSeries();
    private List<BlackTimeSeries> blackPixels = newArrayList();
    private List<SmearTimeSeries> maskedSmearPixels = newArrayList();
    private List<SmearTimeSeries> virtualSmearPixels = newArrayList();
    private List<CalInputPixelTimeSeries> backgroundPixels = newArrayList();
    private List<CalInputPixelTimeSeries> arpTargetPixels = newArrayList();

    private TimestampSeries reverseClockedCadenceTimes = new TimestampSeries();
    private List<BlackTimeSeries> reverseClockedBlackPixels = newArrayList();
    private List<SmearTimeSeries> reverseClockedMaskedSmearPixels = newArrayList();
    private List<SmearTimeSeries> reverseClockedVirtualSmearPixels = newArrayList();
    private List<CalInputPixelTimeSeries> reverseClockedBackgroundPixels = newArrayList();
    private List<CalInputPixelTimeSeries> reverseClockedTargetPixels = newArrayList();

    private TwoDBlackModel twoDBlackModel = new TwoDBlackModel();
    private UndershootModel undershootModel = new UndershootModel();
    private GainModel gainModel = new GainModel();
    private FlatFieldModel flatFieldModel = new FlatFieldModel();
    private LinearityModel linearityModel = new LinearityModel();
    private ReadNoiseModel readNoiseModel = new ReadNoiseModel();

    private List<ConfigMap> spacecraftConfigMap = newArrayList();
    private List<RequantTable> requantTables = newArrayList();
    private List<HuffmanTable> huffmanTables = newArrayList();

    private FcConstants fcConstants = new FcConstants();

    public DynablackInputs() {
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

    public int getSeason() {
        return season;
    }

    public void setSeason(int season) {
        this.season = season;
    }

    public DynablackModuleParameters getDynablackModuleParameters() {
        return dynablackModuleParameters;
    }

    public void setDynablackModuleParameters(
        DynablackModuleParameters dynablackModuleParameters) {
        this.dynablackModuleParameters = dynablackModuleParameters;
    }

    public RollingBandArtifactParameters getRollingBandArtifactParameters() {
        return rbaFlagConfigurationStruct;
    }

    public void setRollingBandArtifactParameters(
        RollingBandArtifactParameters rollingBandArtifactParameters) {
        rbaFlagConfigurationStruct = rollingBandArtifactParameters;
    }

    public List<AncillaryEngineeringData> getAncillaryEngineeringDataStruct() {
        return ancillaryEngineeringDataStruct;
    }

    public void setAncillaryEngineeringDataStruct(
        List<AncillaryEngineeringData> ancillaryEngineeringDataStruct) {
        this.ancillaryEngineeringDataStruct = ancillaryEngineeringDataStruct;
    }

    public List<FitsImage> getRawFfis() {
        return rawFfis;
    }

    public void setRawFfis(List<FitsImage> rawFfis) {
        this.rawFfis = rawFfis;
    }

    public TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    public void setCadenceTimes(TimestampSeries cadenceTimes) {
        this.cadenceTimes = cadenceTimes;
    }

    public List<BlackTimeSeries> getBlackPixels() {
        return blackPixels;
    }

    public void setBlackPixels(List<BlackTimeSeries> blackPixels) {
        this.blackPixels = blackPixels;
    }

    public List<SmearTimeSeries> getMaskedSmearPixels() {
        return maskedSmearPixels;
    }

    public void setMaskedSmearPixels(List<SmearTimeSeries> maskedSmearPixels) {
        this.maskedSmearPixels = maskedSmearPixels;
    }

    public List<SmearTimeSeries> getVirtualSmearPixels() {
        return virtualSmearPixels;
    }

    public void setVirtualSmearPixels(List<SmearTimeSeries> virtualSmearPixels) {
        this.virtualSmearPixels = virtualSmearPixels;
    }

    public List<CalInputPixelTimeSeries> getBackgroundPixels() {
        return backgroundPixels;
    }

    public void setBackgroundPixels(
        List<CalInputPixelTimeSeries> backgroundPixels) {
        this.backgroundPixels = backgroundPixels;
    }

    public List<CalInputPixelTimeSeries> getArpTargetPixels() {
        return arpTargetPixels;
    }

    public void setArpTargetPixels(List<CalInputPixelTimeSeries> arpTargetPixels) {
        this.arpTargetPixels = arpTargetPixels;
    }

    public TimestampSeries getReverseClockedCadenceTimes() {
        return reverseClockedCadenceTimes;
    }

    public void setReverseClockedCadenceTimes(
        TimestampSeries reverseClockedCadenceTimes) {
        this.reverseClockedCadenceTimes = reverseClockedCadenceTimes;
    }

    public List<BlackTimeSeries> getReverseClockedBlackPixels() {
        return reverseClockedBlackPixels;
    }

    public void setReverseClockedBlackPixels(
        List<BlackTimeSeries> reverseClockedBlackPixels) {
        this.reverseClockedBlackPixels = reverseClockedBlackPixels;
    }

    public List<SmearTimeSeries> getReverseClockedMaskedSmearPixels() {
        return reverseClockedMaskedSmearPixels;
    }

    public void setReverseClockedMaskedSmearPixels(
        List<SmearTimeSeries> reverseClockedMaskedSmearPixels) {
        this.reverseClockedMaskedSmearPixels = reverseClockedMaskedSmearPixels;
    }

    public List<SmearTimeSeries> getReverseClockedVirtualSmearPixels() {
        return reverseClockedVirtualSmearPixels;
    }

    public void setReverseClockedVirtualSmearPixels(
        List<SmearTimeSeries> reverseClockedVirtualSmearPixels) {
        this.reverseClockedVirtualSmearPixels = reverseClockedVirtualSmearPixels;
    }

    public List<CalInputPixelTimeSeries> getReverseClockedBackgroundPixels() {
        return reverseClockedBackgroundPixels;
    }

    public void setReverseClockedBackgroundPixels(
        List<CalInputPixelTimeSeries> reverseClockedBackgroundPixels) {
        this.reverseClockedBackgroundPixels = reverseClockedBackgroundPixels;
    }

    public List<CalInputPixelTimeSeries> getReverseClockedTargetPixels() {
        return reverseClockedTargetPixels;
    }

    public void setReverseClockedTargetPixels(
        List<CalInputPixelTimeSeries> reverseClockedTargetPixels) {
        this.reverseClockedTargetPixels = reverseClockedTargetPixels;
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

    public GainModel getGainModel() {
        return gainModel;
    }

    public void setGainModel(GainModel gainModel) {
        this.gainModel = gainModel;
    }

    public FlatFieldModel getFlatFieldModel() {
        return flatFieldModel;
    }

    public void setFlatFieldModel(FlatFieldModel flatFieldModel) {
        this.flatFieldModel = flatFieldModel;
    }

    public LinearityModel getLinearityModel() {
        return linearityModel;
    }

    public void setLinearityModel(LinearityModel linearityModel) {
        this.linearityModel = linearityModel;
    }

    public ReadNoiseModel getReadNoiseModel() {
        return readNoiseModel;
    }

    public void setReadNoiseModel(ReadNoiseModel readNoiseModel) {
        this.readNoiseModel = readNoiseModel;
    }

    public List<ConfigMap> getSpacecraftConfigMap() {
        return spacecraftConfigMap;
    }

    public void setSpacecraftConfigMap(List<ConfigMap> spacecraftConfigMap) {
        this.spacecraftConfigMap = spacecraftConfigMap;
    }

    public List<RequantTable> getRequantTables() {
        return requantTables;
    }

    public void setRequantTables(List<RequantTable> requantTables) {
        this.requantTables = requantTables;
    }

    public List<HuffmanTable> getHuffmanTables() {
        return huffmanTables;
    }

    public void setHuffmanTables(List<HuffmanTable> huffmanTables) {
        this.huffmanTables = huffmanTables;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public void setFcConstants(FcConstants fcConstants) {
        this.fcConstants = fcConstants;
    }

}
