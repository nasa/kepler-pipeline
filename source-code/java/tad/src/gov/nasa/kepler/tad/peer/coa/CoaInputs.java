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

package gov.nasa.kepler.tad.peer.coa;

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.RaDec2PixModel;
import gov.nasa.kepler.fc.ReadNoiseModel;
import gov.nasa.kepler.fc.SaturationModel;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.UndershootModel;
import gov.nasa.kepler.mc.tad.KicEntryData;
import gov.nasa.kepler.tad.peer.CoaModuleParameters;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.List;

/**
 * Contains the data that is required by COA MATLAB.
 * 
 * @author Miles Cote
 */
public class CoaInputs implements Persistable {

    private List<KicEntryData> kicEntryDataStruct;

    private int[] targetKeplerIDList;

    private String startTime;
    private double duration;

    private RaDec2PixModel raDec2PixModel;
    private ReadNoiseModel readNoiseModel;
    private GainModel gainModel;
    private TwoDBlackModel twoDBlackModel;
    private LinearityModel linearityModel;
    private UndershootModel undershootModel;
    private FlatFieldModel flatFieldModel;
    private SaturationModel saturationModel;
    // private PixelModel pixelModel;

    private byte[] prfBlob;

    private FcConstants fcConstants = new FcConstants();

    private PlannedSpacecraftConfigParameters spacecraftConfigurationStruct;
    private CoaModuleParameters coaConfigurationStruct;

    private int module;
    private int output;
    private int debugFlag;

    private BlobFileSeries motionBlobs = new BlobFileSeries();
    private BlobFileSeries backgroundBlobs = new BlobFileSeries();

    public CoaInputs() {
    }

    public CoaModuleParameters getCoaConfigurationStruct() {
        return coaConfigurationStruct;
    }

    public void setCoaConfigurationStruct(
        CoaModuleParameters coaConfigurationStruct) {
        this.coaConfigurationStruct = coaConfigurationStruct;
    }

    public List<KicEntryData> getKicEntryData() {
        return kicEntryDataStruct;
    }

    public List<KicEntryData> getKicEntryDataStruct() {
        return getKicEntryData();
    }

    public void setKicEntryData(List<KicEntryData> kicEntryData) {
        this.kicEntryDataStruct = kicEntryData;
    }

    public void setKicEntryDataStruct(List<KicEntryData> kicEntryData) {
        setKicEntryData(kicEntryData);
    }

    public int getModule() {
        return module;
    }

    public void setModule(int module) {
        this.module = module;
    }

    public int getOutput() {
        return output;
    }

    public void setOutput(int output) {
        this.output = output;
    }

    public int[] getTargetKeplerIDList() {
        return targetKeplerIDList;
    }

    public void setTargetKeplerIDList(int[] targetKeplerIDList) {
        this.targetKeplerIDList = targetKeplerIDList;
    }

    public int getDebugFlag() {
        return debugFlag;
    }

    public void setDebugFlag(int debugFlag) {
        this.debugFlag = debugFlag;
    }

    public byte[] getPrfBlob() {
        return prfBlob;
    }

    public void setPrfBlob(byte[] prfBlob) {
        this.prfBlob = prfBlob;
    }

    public RaDec2PixModel getRaDec2PixModel() {
        return raDec2PixModel;
    }

    public void setRaDec2PixModel(RaDec2PixModel raDec2PixModel) {
        this.raDec2PixModel = raDec2PixModel;
    }

    public FlatFieldModel getFlatFieldModel() {
        return flatFieldModel;
    }

    public void setFlatFieldModel(FlatFieldModel flatFieldModel) {
        this.flatFieldModel = flatFieldModel;
    }

    // public PixelModel getPixelModel() {
    // return pixelModel;
    // }
    //
    // public void setPixelModel(PixelModel pixelModel) {
    // this.pixelModel = pixelModel;
    // }

    public GainModel getGainModel() {
        return gainModel;
    }

    public void setGainModel(GainModel gainModel) {
        this.gainModel = gainModel;
    }

    public SaturationModel getSaturationModel() {
        return saturationModel;
    }

    public void setSaturationModel(SaturationModel saturationModel) {
        this.saturationModel = saturationModel;
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

    public String getStartTime() {
        return startTime;
    }

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public double getDuration() {
        return duration;
    }

    public void setDuration(double duration) {
        this.duration = duration;
    }

    public FcConstants getFcConstants() {
        return fcConstants;
    }

    public void setFcConstants(FcConstants fcConstants) {
        this.fcConstants = fcConstants;
    }

    public PlannedSpacecraftConfigParameters getSpacecraftConfigurationStruct() {
        return spacecraftConfigurationStruct;
    }

    public void setSpacecraftConfigurationStruct(
        PlannedSpacecraftConfigParameters spacecraftConfigurationStruct) {
        this.spacecraftConfigurationStruct = spacecraftConfigurationStruct;
    }

    public BlobFileSeries getMotionBlobs() {
        return motionBlobs;
    }

    public void setMotionBlobs(BlobFileSeries motionBlobs) {
        this.motionBlobs = motionBlobs;
    }

    public BlobFileSeries getBackgroundBlobs() {
        return backgroundBlobs;
    }

    public void setBackgroundBlobs(BlobFileSeries backgroundBlobs) {
        this.backgroundBlobs = backgroundBlobs;
    }

}
