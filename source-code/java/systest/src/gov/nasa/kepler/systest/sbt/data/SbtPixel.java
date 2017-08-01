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
import gov.nasa.kepler.mc.SimpleIndicesTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;

import java.util.List;

/**
 * This class contains pixel data. This is quarter-specific data.
 * 
 * @author Miles Cote
 * 
 */
public class SbtPixel implements SbtDataContainer {

    private int ccdRow;
    private int ccdColumn;
    private boolean inOptimalAperture;

    private SimpleIntTimeSeries rawPixelTimeSeries = new SimpleIntTimeSeries();
    private CompoundFloatTimeSeries calPixelTimeSeries = new CompoundFloatTimeSeries();
    private SimpleIndicesTimeSeries cosmicRayEvents = new SimpleIndicesTimeSeries();

    private List<SbtBadPixelInterval> badPixelIntervals = newArrayList();

    private List<SbtPixelPlanetResults> planetResults = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();

        if (!parameters.isCustomTarget()) {
            stringBuilder.append(SbtDataUtils.toString("ccdRow", new SbtNumber(
                ccdRow).toMissingDataString(parameters)));
            stringBuilder.append(SbtDataUtils.toString("ccdColumn",
                new SbtNumber(ccdColumn).toMissingDataString(parameters)));
        }

        stringBuilder.append(SbtDataUtils.toString(
            "rawPixelTimeSeries",
            new SbtSimpleIntTimeSeries(rawPixelTimeSeries).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "calPixelTimeSeries",
            new SbtCompoundTimeSeries(calPixelTimeSeries).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "cosmicRayEvents",
            new SbtSimpleIndicesTimeSeries(cosmicRayEvents).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "badPixelIntervals",
            new SbtList(badPixelIntervals, true).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPixel() {
    }

    public SbtPixel(int ccdRow, int ccdColumn, boolean inOptimalAperture,
        SimpleIntTimeSeries rawPixelTimeSeries,
        CompoundFloatTimeSeries calPixelTimeSeries,
        SimpleIndicesTimeSeries cosmicRayEvents,
        List<SbtBadPixelInterval> badPixelIntervals,
        List<SbtPixelPlanetResults> planetResults) {
        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.inOptimalAperture = inOptimalAperture;
        this.rawPixelTimeSeries = rawPixelTimeSeries;
        this.calPixelTimeSeries = calPixelTimeSeries;
        this.cosmicRayEvents = cosmicRayEvents;
        this.badPixelIntervals = badPixelIntervals;
        this.planetResults = planetResults;
    }

    public int getCcdRow() {
        return ccdRow;
    }

    public void setCcdRow(int ccdRow) {
        this.ccdRow = ccdRow;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public void setCcdColumn(int ccdColumn) {
        this.ccdColumn = ccdColumn;
    }

    public boolean isInOptimalAperture() {
        return inOptimalAperture;
    }

    public void setInOptimalAperture(boolean inOptimalAperture) {
        this.inOptimalAperture = inOptimalAperture;
    }

    public SimpleIntTimeSeries getRawPixelTimeSeries() {
        return rawPixelTimeSeries;
    }

    public void setRawPixelTimeSeries(SimpleIntTimeSeries rawPixelTimeSeries) {
        this.rawPixelTimeSeries = rawPixelTimeSeries;
    }

    public CompoundFloatTimeSeries getCalPixelTimeSeries() {
        return calPixelTimeSeries;
    }

    public void setCalPixelTimeSeries(CompoundFloatTimeSeries calPixelTimeSeries) {
        this.calPixelTimeSeries = calPixelTimeSeries;
    }

    public SimpleIndicesTimeSeries getCosmicRayEvents() {
        return cosmicRayEvents;
    }

    public void setCosmicRayEvents(SimpleIndicesTimeSeries cosmicRayEvents) {
        this.cosmicRayEvents = cosmicRayEvents;
    }

    public List<SbtBadPixelInterval> getBadPixelIntervals() {
        return badPixelIntervals;
    }

    public void setBadPixelIntervals(List<SbtBadPixelInterval> badPixelIntervals) {
        this.badPixelIntervals = badPixelIntervals;
    }

    public List<SbtPixelPlanetResults> getPlanetResults() {
        return planetResults;
    }

    public void setPlanetResults(List<SbtPixelPlanetResults> planetResults) {
        this.planetResults = planetResults;
    }

}
