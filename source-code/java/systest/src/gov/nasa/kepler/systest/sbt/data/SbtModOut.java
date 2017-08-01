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

import org.apache.commons.lang.ArrayUtils;

/**
 * This class contains mod/out specific data that applies to the whole mod/out.
 * 
 * @author Miles Cote
 * 
 */
public class SbtModOut implements SbtDataContainer {

    private int ccdModule;
    private int ccdOutput;

    private List<SbtBlobSeries> blobGroups = newArrayList();

    private int[] argabrighteningIndices = ArrayUtils.EMPTY_INT_ARRAY;

    private List<SbtCalCompressionTimeSeries> calCompressionMetricTimeSeriesList = newArrayList();
    private List<SbtCompoundTimeSeries> calMetricTimeSeriesList = newArrayList();
    private List<SbtSimpleTimeSeriesList> calCosmicRayMetricTimeSeriesLists = newArrayList();

    private List<SbtCompoundTimeSeries> paMetricTimeSeriesList = newArrayList();
    private List<SbtSimpleTimeSeriesList> paCosmicRayMetricTimeSeriesLists = newArrayList();

    private List<SbtCompoundTimeSeries> pmdTimeSeriesList = newArrayList();
    private List<SbtCompoundTimeSeriesListList> pmdCdppTimeSeriesLists = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("ccdModule", new SbtNumber(
            ccdModule).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("ccdOutput", new SbtNumber(
            ccdOutput).toMissingDataString(parameters)));
        if (!parameters.isShortCadence()) {
            // blobGroups[2] is gapped because it is the pa uncertainties blob,
            // which will always be gapped unless pou is enabled for pa.
            stringBuilder.append(SbtDataUtils.toString("blobGroups",
                new SbtList(blobGroups, new SbtGapIndicators(new boolean[] {
                    false, false, true })).toMissingDataString(parameters)));
        }
        stringBuilder.append(SbtDataUtils.toString(
            "argabrighteningIndices",
            new SbtList(
                SbtDataContainerListFactory.getInstance(argabrighteningIndices),
                true).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "calCompressionMetricTimeSeriesList",
            new SbtList(calCompressionMetricTimeSeriesList).toMissingDataString(parameters)));
        if (!parameters.isShortCadence()) {
            stringBuilder.append(SbtDataUtils.toString(
                "paMetricTimeSeriesList",
                new SbtList(paMetricTimeSeriesList).toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("pmdTimeSeriesList",
                new SbtList(pmdTimeSeriesList).toMissingDataString(parameters)));
        }

        return stringBuilder.toString();
    }

    public SbtModOut() {
    }

    public SbtModOut(int ccdModule, int ccdOutput,
        List<SbtBlobSeries> blobGroups, int[] argabrighteningIndices,
        List<SbtCalCompressionTimeSeries> calCompressionMetricTimeSeriesList,
        List<SbtCompoundTimeSeries> calMetricTimeSeriesList,
        List<SbtSimpleTimeSeriesList> calCosmicRayMetricTimeSeriesLists,
        List<SbtCompoundTimeSeries> paMetricTimeSeriesList,
        List<SbtSimpleTimeSeriesList> paCosmicRayMetricTimeSeriesLists,
        List<SbtCompoundTimeSeries> pmdTimeSeriesList,
        List<SbtCompoundTimeSeriesListList> pmdCdppTimeSeriesLists) {
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.blobGroups = blobGroups;
        this.argabrighteningIndices = argabrighteningIndices;
        this.calCompressionMetricTimeSeriesList = calCompressionMetricTimeSeriesList;
        this.calMetricTimeSeriesList = calMetricTimeSeriesList;
        this.calCosmicRayMetricTimeSeriesLists = calCosmicRayMetricTimeSeriesLists;
        this.paMetricTimeSeriesList = paMetricTimeSeriesList;
        this.paCosmicRayMetricTimeSeriesLists = paCosmicRayMetricTimeSeriesLists;
        this.pmdTimeSeriesList = pmdTimeSeriesList;
        this.pmdCdppTimeSeriesLists = pmdCdppTimeSeriesLists;
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

    public List<SbtBlobSeries> getBlobGroups() {
        return blobGroups;
    }

    public void setBlobGroups(List<SbtBlobSeries> blobGroups) {
        this.blobGroups = blobGroups;
    }

    public int[] getArgabrighteningIndices() {
        return argabrighteningIndices;
    }

    public void setArgabrighteningIndices(int[] argabrighteningIndices) {
        this.argabrighteningIndices = argabrighteningIndices;
    }

    public List<SbtCalCompressionTimeSeries> getCalCompressionMetricTimeSeriesList() {
        return calCompressionMetricTimeSeriesList;
    }

    public void setCalCompressionMetricTimeSeriesList(
        List<SbtCalCompressionTimeSeries> calCompressionMetricTimeSeriesList) {
        this.calCompressionMetricTimeSeriesList = calCompressionMetricTimeSeriesList;
    }

    public List<SbtCompoundTimeSeries> getCalMetricTimeSeriesList() {
        return calMetricTimeSeriesList;
    }

    public void setCalMetricTimeSeriesList(
        List<SbtCompoundTimeSeries> calMetricTimeSeriesList) {
        this.calMetricTimeSeriesList = calMetricTimeSeriesList;
    }

    public List<SbtSimpleTimeSeriesList> getCalCosmicRayMetricTimeSeriesLists() {
        return calCosmicRayMetricTimeSeriesLists;
    }

    public void setCalCosmicRayMetricTimeSeriesLists(
        List<SbtSimpleTimeSeriesList> calCosmicRayMetricTimeSeriesLists) {
        this.calCosmicRayMetricTimeSeriesLists = calCosmicRayMetricTimeSeriesLists;
    }

    public List<SbtCompoundTimeSeries> getPaMetricTimeSeriesList() {
        return paMetricTimeSeriesList;
    }

    public void setPaMetricTimeSeriesList(
        List<SbtCompoundTimeSeries> paMetricTimeSeriesList) {
        this.paMetricTimeSeriesList = paMetricTimeSeriesList;
    }

    public List<SbtSimpleTimeSeriesList> getPaCosmicRayMetricTimeSeriesLists() {
        return paCosmicRayMetricTimeSeriesLists;
    }

    public void setPaCosmicRayMetricTimeSeriesLists(
        List<SbtSimpleTimeSeriesList> paCosmicRayMetricTimeSeriesLists) {
        this.paCosmicRayMetricTimeSeriesLists = paCosmicRayMetricTimeSeriesLists;
    }

    public List<SbtCompoundTimeSeries> getPmdTimeSeriesList() {
        return pmdTimeSeriesList;
    }

    public void setPmdTimeSeriesList(
        List<SbtCompoundTimeSeries> pmdTimeSeriesList) {
        this.pmdTimeSeriesList = pmdTimeSeriesList;
    }

    public List<SbtCompoundTimeSeriesListList> getPmdCdppTimeSeriesLists() {
        return pmdCdppTimeSeriesLists;
    }

    public void setPmdCdppTimeSeriesLists(
        List<SbtCompoundTimeSeriesListList> pmdCdppTimeSeriesLists) {
        this.pmdCdppTimeSeriesLists = pmdCdppTimeSeriesLists;
    }

}
