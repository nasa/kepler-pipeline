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

import org.apache.commons.lang.ArrayUtils;

/**
 * This class contains tad data. This is quarter-specific data.
 * 
 * @author Miles Cote
 * 
 */
public class SbtTadData implements SbtDataContainer {

    private String[] labels = ArrayUtils.EMPTY_STRING_ARRAY;
    private double signalToNoiseRatio;
    private float magnitude;
    private double ra;
    private double dec;
    private float effectiveTemp;
    private int badPixelCount;
    private double crowdingMetric;
    private double skyCrowdingMetric;
    private double fluxFractionInAperture;
    private int distanceFromEdge;
    private int saturatedRowCount;

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString(
            "labels",
            new SbtList(SbtDataContainerListFactory.getInstance(labels)).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtTadData() {
    }

    public SbtTadData(String[] labels, double signalToNoiseRatio,
        float magnitude, double ra, double dec, float effectiveTemp,
        int badPixelCount, double crowdingMetric, double skyCrowdingMetric,
        double fluxFractionInAperture, int distanceFromEdge,
        int saturatedRowCount) {
        this.labels = labels;
        this.signalToNoiseRatio = signalToNoiseRatio;
        this.magnitude = magnitude;
        this.ra = ra;
        this.dec = dec;
        this.effectiveTemp = effectiveTemp;
        this.badPixelCount = badPixelCount;
        this.crowdingMetric = crowdingMetric;
        this.skyCrowdingMetric = skyCrowdingMetric;
        this.fluxFractionInAperture = fluxFractionInAperture;
        this.distanceFromEdge = distanceFromEdge;
        this.saturatedRowCount = saturatedRowCount;
    }

    public String[] getLabels() {
        return labels;
    }

    public void setLabels(String[] labels) {
        this.labels = labels;
    }

    public double getSignalToNoiseRatio() {
        return signalToNoiseRatio;
    }

    public void setSignalToNoiseRatio(double signalToNoiseRatio) {
        this.signalToNoiseRatio = signalToNoiseRatio;
    }

    public float getMagnitude() {
        return magnitude;
    }

    public void setMagnitude(float magnitude) {
        this.magnitude = magnitude;
    }

    public double getRa() {
        return ra;
    }

    public void setRa(double ra) {
        this.ra = ra;
    }

    public double getDec() {
        return dec;
    }

    public void setDec(double dec) {
        this.dec = dec;
    }

    public float getEffectiveTemp() {
        return effectiveTemp;
    }

    public void setEffectiveTemp(float effectiveTemp) {
        this.effectiveTemp = effectiveTemp;
    }

    public int getBadPixelCount() {
        return badPixelCount;
    }

    public void setBadPixelCount(int badPixelCount) {
        this.badPixelCount = badPixelCount;
    }

    public double getCrowdingMetric() {
        return crowdingMetric;
    }

    public void setCrowdingMetric(double crowdingMetric) {
        this.crowdingMetric = crowdingMetric;
    }

    public double getSkyCrowdingMetric() {
        return skyCrowdingMetric;
    }

    public void setSkyCrowdingMetric(double skyCrowdingMetric) {
        this.skyCrowdingMetric = skyCrowdingMetric;
    }

    public double getFluxFractionInAperture() {
        return fluxFractionInAperture;
    }

    public void setFluxFractionInAperture(double fluxFractionInAperture) {
        this.fluxFractionInAperture = fluxFractionInAperture;
    }

    public int getDistanceFromEdge() {
        return distanceFromEdge;
    }

    public void setDistanceFromEdge(int distanceFromEdge) {
        this.distanceFromEdge = distanceFromEdge;
    }

    public int getSaturatedRowCount() {
        return saturatedRowCount;
    }

    public void setSaturatedRowCount(int saturatedRowCount) {
        this.saturatedRowCount = saturatedRowCount;
    }

}
