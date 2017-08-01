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

package gov.nasa.kepler.systest.sbt.data;

import static com.google.common.collect.Lists.newArrayList;

import java.util.List;

/**
 * This class contains target-table-specific data for a target.
 * 
 * @author Miles Cote
 * 
 */
public class SbtAperture implements SbtDataContainer {

    private int targetTableId;
    private int quarter;
    private int startCadence;
    private int endCadence;
    private int ccdModule;
    private int ccdOutput;

    private SbtTadData tadData = new SbtTadData();

    private List<SbtPixel> pixels = newArrayList();

    private List<SbtCompoundTimeSeries> calMetricTimeSeriesList = newArrayList();

    private List<SbtAperturePlanetResults> planetResults = newArrayList();

    private SbtLimbDarkeningModel limbDarkeningModel = new SbtLimbDarkeningModel();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("targetTableId",
            new SbtNumber(targetTableId).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("quarter", new SbtNumber(
            quarter).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("startCadence",
            new SbtNumber(startCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("endCadence", new SbtNumber(
            endCadence).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("ccdModule", new SbtNumber(
            ccdModule).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("ccdOutput", new SbtNumber(
            ccdOutput).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("tadData",
            tadData.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("pixels",
            new SbtList(pixels).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtAperture() {
    }

    public SbtAperture(int targetTableId, int quarter, int startCadence,
        int endCadence, int ccdModule, int ccdOutput, SbtTadData tadData,
        List<SbtPixel> pixels,
        List<SbtCompoundTimeSeries> calMetricTimeSeriesList,
        List<SbtAperturePlanetResults> planetResults,
        SbtLimbDarkeningModel limbDarkeningModel) {
        this.targetTableId = targetTableId;
        this.quarter = quarter;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.tadData = tadData;
        this.pixels = pixels;
        this.calMetricTimeSeriesList = calMetricTimeSeriesList;
        this.planetResults = planetResults;
        this.limbDarkeningModel = limbDarkeningModel;
    }

    public int getTargetTableId() {
        return targetTableId;
    }

    public void setTargetTableId(int targetTableId) {
        this.targetTableId = targetTableId;
    }

    public int getQuarter() {
        return quarter;
    }

    public void setQuarter(int quarter) {
        this.quarter = quarter;
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

    public SbtTadData getTadData() {
        return tadData;
    }

    public void setTadData(SbtTadData tadData) {
        this.tadData = tadData;
    }

    public List<SbtPixel> getPixels() {
        return pixels;
    }

    public void setPixels(List<SbtPixel> pixels) {
        this.pixels = pixels;
    }

    public List<SbtCompoundTimeSeries> getCalMetricTimeSeriesList() {
        return calMetricTimeSeriesList;
    }

    public void setCalMetricTimeSeriesList(
        List<SbtCompoundTimeSeries> calMetricTimeSeriesList) {
        this.calMetricTimeSeriesList = calMetricTimeSeriesList;
    }

    public List<SbtAperturePlanetResults> getPlanetResults() {
        return planetResults;
    }

    public void setPlanetResults(List<SbtAperturePlanetResults> planetResults) {
        this.planetResults = planetResults;
    }

    public SbtLimbDarkeningModel getLimbDarkeningModel() {
        return limbDarkeningModel;
    }

    public void setLimbDarkeningModel(SbtLimbDarkeningModel limbDarkeningModel) {
        this.limbDarkeningModel = limbDarkeningModel;
    }

}
