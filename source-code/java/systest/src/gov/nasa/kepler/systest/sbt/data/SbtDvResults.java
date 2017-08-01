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
 * This class contains dv results.
 * 
 * @author Miles Cote
 * 
 */
public class SbtDvResults implements SbtDataContainer {

    private List<SbtPlanetResults> planetResults = newArrayList();

    private SbtCorrectedFluxTimeSeries residualFluxTimeSeries = new SbtCorrectedFluxTimeSeries();

    private List<SbtSingleEventStatistics> singleEventStatistics = newArrayList();

    private double[] barycentricCorrectedTimestamps = ArrayUtils.EMPTY_DOUBLE_ARRAY;

    private SbtQuantityWithProvenance effectiveTemp = new SbtQuantityWithProvenance();
    private SbtQuantityWithProvenance log10Metallicity = new SbtQuantityWithProvenance();
    private SbtQuantityWithProvenance log10SurfaceGravity = new SbtQuantityWithProvenance();
    private SbtQuantityWithProvenance radius = new SbtQuantityWithProvenance();
    private SbtDoubleQuantityWithProvenance decDegrees = new SbtDoubleQuantityWithProvenance();
    private SbtQuantityWithProvenance keplerMag = new SbtQuantityWithProvenance();
    private SbtDoubleQuantityWithProvenance raHours = new SbtDoubleQuantityWithProvenance();

    private SbtString quartersObserved = new SbtString("");

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        if (parameters.isConfirmedPlanet()) {
            stringBuilder.append(SbtDataUtils.toString(
                "residualFluxTimeSeries",
                residualFluxTimeSeries.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("planetResults",
                new SbtList(planetResults).toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString(
                "singleEventStatistics",
                new SbtList(singleEventStatistics).toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("effectiveTemp",
                effectiveTemp.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("log10Metallicity",
                log10Metallicity.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("log10SurfaceGravity",
                log10SurfaceGravity.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("radius",
                radius.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("decDegrees",
                decDegrees.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("keplerMag",
                keplerMag.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("raHours",
                raHours.toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("quartersObserved",
                quartersObserved.toMissingDataString(parameters)));
        }

        return stringBuilder.toString();
    }

    public SbtDvResults() {
    }

    public SbtDvResults(List<SbtPlanetResults> planetResults,
        SbtCorrectedFluxTimeSeries residualFluxTimeSeries,
        List<SbtSingleEventStatistics> singleEventStatistics,
        double[] barycentricCorrectedTimestamps,
        SbtQuantityWithProvenance effectiveTemp,
        SbtQuantityWithProvenance log10Metallicity,
        SbtQuantityWithProvenance log10SurfaceGravity,
        SbtQuantityWithProvenance radius,
        SbtDoubleQuantityWithProvenance decDegrees,
        SbtQuantityWithProvenance keplerMag,
        SbtDoubleQuantityWithProvenance raHours, SbtString quartersObserved) {
        this.planetResults = planetResults;
        this.residualFluxTimeSeries = residualFluxTimeSeries;
        this.singleEventStatistics = singleEventStatistics;
        this.barycentricCorrectedTimestamps = barycentricCorrectedTimestamps;
        this.effectiveTemp = effectiveTemp;
        this.log10Metallicity = log10Metallicity;
        this.log10SurfaceGravity = log10SurfaceGravity;
        this.radius = radius;
        this.decDegrees = decDegrees;
        this.keplerMag = keplerMag;
        this.raHours = raHours;
        this.quartersObserved = quartersObserved;
    }

    public List<SbtPlanetResults> getPlanetResults() {
        return planetResults;
    }

    public void setPlanetResults(List<SbtPlanetResults> planetResults) {
        this.planetResults = planetResults;
    }

    public SbtCorrectedFluxTimeSeries getResidualFluxTimeSeries() {
        return residualFluxTimeSeries;
    }

    public void setResidualFluxTimeSeries(
        SbtCorrectedFluxTimeSeries residualFluxTimeSeries) {
        this.residualFluxTimeSeries = residualFluxTimeSeries;
    }

    public List<SbtSingleEventStatistics> getSingleEventStatistics() {
        return singleEventStatistics;
    }

    public void setSingleEventStatistics(
        List<SbtSingleEventStatistics> singleEventStatistics) {
        this.singleEventStatistics = singleEventStatistics;
    }

    public double[] getBarycentricCorrectedTimestamps() {
        return barycentricCorrectedTimestamps;
    }

    public void setBarycentricCorrectedTimestamps(
        double[] barycentricCorrectedTimestamps) {
        this.barycentricCorrectedTimestamps = barycentricCorrectedTimestamps;
    }

    public SbtQuantityWithProvenance getEffectiveTemp() {
        return effectiveTemp;
    }

    public void setEffectiveTemp(SbtQuantityWithProvenance effectiveTemp) {
        this.effectiveTemp = effectiveTemp;
    }

    public SbtQuantityWithProvenance getLog10Metallicity() {
        return log10Metallicity;
    }

    public void setLog10Metallicity(SbtQuantityWithProvenance log10Metallicity) {
        this.log10Metallicity = log10Metallicity;
    }

    public SbtQuantityWithProvenance getLog10SurfaceGravity() {
        return log10SurfaceGravity;
    }

    public void setLog10SurfaceGravity(
        SbtQuantityWithProvenance log10SurfaceGravity) {
        this.log10SurfaceGravity = log10SurfaceGravity;
    }

    public SbtQuantityWithProvenance getRadius() {
        return radius;
    }

    public void setRadius(SbtQuantityWithProvenance radius) {
        this.radius = radius;
    }

    public SbtDoubleQuantityWithProvenance getDecDegrees() {
        return decDegrees;
    }

    public void setDecDegrees(SbtDoubleQuantityWithProvenance decDegrees) {
        this.decDegrees = decDegrees;
    }

    public SbtQuantityWithProvenance getKeplerMag() {
        return keplerMag;
    }

    public void setKeplerMag(SbtQuantityWithProvenance keplerMag) {
        this.keplerMag = keplerMag;
    }

    public SbtDoubleQuantityWithProvenance getRaHours() {
        return raHours;
    }

    public void setRaHours(SbtDoubleQuantityWithProvenance raHours) {
        this.raHours = raHours;
    }

    public SbtString getQuartersObserved() {
        return quartersObserved;
    }

    public void setQuartersObserved(SbtString quartersObserved) {
        this.quartersObserved = quartersObserved;
    }

}
