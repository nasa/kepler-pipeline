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
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.util.List;

import org.apache.commons.lang.ArrayUtils;

/**
 * This class contains multi-quarter target data for a {@link FluxType}.
 * 
 * @author Miles Cote
 * 
 */
public class SbtFluxGroup implements SbtDataContainer {

    private String fluxType = "";

    private CompoundFloatTimeSeries rawFluxTimeSeries = new CompoundFloatTimeSeries();

    private List<SbtCorrectedFluxAndOutliersTimeSeries> correctedFluxTimeSeriesList = newArrayList();

    private List<SbtCentroidTimeSeries> centroidTimeSeriesList = newArrayList();

    private int[] discontinuityIndices = ArrayUtils.EMPTY_INT_ARRAY;

    private List<SbtPdcProcessingCharacteristics> pdcProcessingCharacteristics = newArrayList();

    private List<SbtTpsResult> tpsResults = newArrayList();

    private SbtDvResults dvResults = new SbtDvResults();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("fluxType", new SbtString(
            fluxType).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "rawFluxTimeSeries",
            new SbtCompoundTimeSeries(rawFluxTimeSeries).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "correctedFluxTimeSeriesList", new SbtList(
                correctedFluxTimeSeriesList).toMissingDataString(parameters)));
        // centroidTimeSeriesList[1] is gapped because it is the PRF type, which
        // does not exist for many targets.
        stringBuilder.append(SbtDataUtils.toString("centroidTimeSeriesList",
            new SbtList(centroidTimeSeriesList, new SbtGapIndicators(
                new boolean[] { false, true })).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "discontinuityIndices",
            new SbtList(
                SbtDataContainerListFactory.getInstance(discontinuityIndices),
                true).toMissingDataString(parameters)));
        if (parameters.isConfirmedPlanet()) {
            stringBuilder.append(SbtDataUtils.toString("tpsResults",
                new SbtList(tpsResults).toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("dvResults",
                dvResults.toMissingDataString(parameters)));
        }

        return stringBuilder.toString();
    }

    public SbtFluxGroup() {
    }

    public SbtFluxGroup(
        String fluxType,
        CompoundFloatTimeSeries rawFluxTimeSeries,
        List<SbtCorrectedFluxAndOutliersTimeSeries> correctedFluxTimeSeriesList,
        List<SbtCentroidTimeSeries> centroidTimeSeriesList,
        int[] discontinuityIndices,
        List<SbtPdcProcessingCharacteristics> pdcProcessingCharacteristics,
        List<SbtTpsResult> tpsResults, SbtDvResults dvResults) {
        this.fluxType = fluxType;
        this.rawFluxTimeSeries = rawFluxTimeSeries;
        this.correctedFluxTimeSeriesList = correctedFluxTimeSeriesList;
        this.centroidTimeSeriesList = centroidTimeSeriesList;
        this.discontinuityIndices = discontinuityIndices;
        this.pdcProcessingCharacteristics = pdcProcessingCharacteristics;
        this.tpsResults = tpsResults;
        this.dvResults = dvResults;
    }

    public String getFluxType() {
        return fluxType;
    }

    public void setFluxType(String fluxType) {
        this.fluxType = fluxType;
    }

    public CompoundFloatTimeSeries getRawFluxTimeSeries() {
        return rawFluxTimeSeries;
    }

    public void setRawFluxTimeSeries(CompoundFloatTimeSeries rawFluxTimeSeries) {
        this.rawFluxTimeSeries = rawFluxTimeSeries;
    }

    public List<SbtCorrectedFluxAndOutliersTimeSeries> getCorrectedFluxTimeSeriesList() {
        return correctedFluxTimeSeriesList;
    }

    public void setCorrectedFluxTimeSeriesList(
        List<SbtCorrectedFluxAndOutliersTimeSeries> correctedFluxTimeSeriesList) {
        this.correctedFluxTimeSeriesList = correctedFluxTimeSeriesList;
    }

    public List<SbtCentroidTimeSeries> getCentroidTimeSeriesList() {
        return centroidTimeSeriesList;
    }

    public void setCentroidTimeSeriesList(
        List<SbtCentroidTimeSeries> centroidTimeSeriesList) {
        this.centroidTimeSeriesList = centroidTimeSeriesList;
    }

    public int[] getDiscontinuityIndices() {
        return discontinuityIndices;
    }

    public void setDiscontinuityIndices(int[] discontinuityIndices) {
        this.discontinuityIndices = discontinuityIndices;
    }

    public List<SbtPdcProcessingCharacteristics> getPdcProcessingCharacteristics() {
        return pdcProcessingCharacteristics;
    }

    public void setPdcProcessingCharacteristics(
        List<SbtPdcProcessingCharacteristics> pdcProcessingCharacteristics) {
        this.pdcProcessingCharacteristics = pdcProcessingCharacteristics;
    }

    public List<SbtTpsResult> getTpsResults() {
        return tpsResults;
    }

    public void setTpsResults(List<SbtTpsResult> tpsResults) {
        this.tpsResults = tpsResults;
    }

    public SbtDvResults getDvResults() {
        return dvResults;
    }

    public void setDvResults(SbtDvResults dvResults) {
        this.dvResults = dvResults;
    }

}
