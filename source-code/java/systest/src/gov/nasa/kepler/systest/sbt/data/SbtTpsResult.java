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

import gov.nasa.spiffy.common.SimpleFloatTimeSeries;

/**
 * This class contains tps result data.
 * 
 * @author Miles Cote
 * 
 */
public class SbtTpsResult implements SbtDataContainer {

    private float trialTransitPulseInHours;

    private double detectedOrbitalPeriodInDays;
    private boolean isPlanetACandidate;
    private float maxSingleEventStatistic;
    private float maxMultipleEventStatistic;
    private float timeToFirstTransitInDays;
    private float rmsCdpp;
    private double timeOfFirstTransitInMjd;
    private boolean matchedFilterUsed;

    private SimpleFloatTimeSeries cdppTimeSeries = new SimpleFloatTimeSeries();

    private float minMultipleEventStatistic;
    private float timeToFirstMicrolensInDays;
    private double timeOfFirstMicrolensInMjd;
    private float detectedMicrolensOrbitalPeriodInDays;

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString(
            "trialTransitPulseInHours",
            new SbtNumber(trialTransitPulseInHours).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "detectedOrbitalPeriodInDays", new SbtNumber(
                detectedOrbitalPeriodInDays).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "maxSingleEventStatistic",
            new SbtNumber(maxSingleEventStatistic).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "maxMultipleEventStatistic",
            new SbtNumber(maxMultipleEventStatistic).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "timeToFirstTransitInDays",
            new SbtNumber(timeToFirstTransitInDays).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("rmsCdpp", new SbtNumber(
            rmsCdpp).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "timeOfFirstTransitInMjd",
            new SbtNumber(timeOfFirstTransitInMjd).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "cdppTimeSeries",
            new SbtSimpleTimeSeries(cdppTimeSeries).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtTpsResult() {
    }

    public SbtTpsResult(float trialTransitPulseInHours,
        double detectedOrbitalPeriodInDays, boolean isPlanetACandidate,
        float maxSingleEventStatistic, float maxMultipleEventStatistic,
        float timeToFirstTransitInDays, float rmsCdpp,
        double timeOfFirstTransitInMjd, SimpleFloatTimeSeries cdppTimeSeries,
        float minMultipleEventStatistic, float timeToFirstMicrolensInDays,
        double timeOfFirstMicrolensInMjd,
        float detectedMicrolensOrbitalPeriodInDays) {
        this.trialTransitPulseInHours = trialTransitPulseInHours;
        this.detectedOrbitalPeriodInDays = detectedOrbitalPeriodInDays;
        this.isPlanetACandidate = isPlanetACandidate;
        this.maxSingleEventStatistic = maxSingleEventStatistic;
        this.maxMultipleEventStatistic = maxMultipleEventStatistic;
        this.timeToFirstTransitInDays = timeToFirstTransitInDays;
        this.rmsCdpp = rmsCdpp;
        this.timeOfFirstTransitInMjd = timeOfFirstTransitInMjd;
        this.cdppTimeSeries = cdppTimeSeries;
        this.minMultipleEventStatistic = minMultipleEventStatistic;
        this.timeToFirstMicrolensInDays = timeToFirstMicrolensInDays;
        this.timeOfFirstMicrolensInMjd = timeOfFirstMicrolensInMjd;
        this.detectedMicrolensOrbitalPeriodInDays = detectedMicrolensOrbitalPeriodInDays;
    }

    public float getTrialTransitPulseInHours() {
        return trialTransitPulseInHours;
    }

    public void setTrialTransitPulseInHours(float trialTransitPulseInHours) {
        this.trialTransitPulseInHours = trialTransitPulseInHours;
    }

    public double getDetectedOrbitalPeriodInDays() {
        return detectedOrbitalPeriodInDays;
    }

    public void setDetectedOrbitalPeriodInDays(
        double detectedOrbitalPeriodInDays) {
        this.detectedOrbitalPeriodInDays = detectedOrbitalPeriodInDays;
    }

    public boolean isPlanetACandidate() {
        return isPlanetACandidate;
    }

    public void setPlanetACandidate(boolean isPlanetACandidate) {
        this.isPlanetACandidate = isPlanetACandidate;
    }

    public float getMaxSingleEventStatistic() {
        return maxSingleEventStatistic;
    }

    public void setMaxSingleEventStatistic(float maxSingleEventStatistic) {
        this.maxSingleEventStatistic = maxSingleEventStatistic;
    }

    public float getMaxMultipleEventStatistic() {
        return maxMultipleEventStatistic;
    }

    public void setMaxMultipleEventStatistic(float maxMultipleEventStatistic) {
        this.maxMultipleEventStatistic = maxMultipleEventStatistic;
    }

    public float getTimeToFirstTransitInDays() {
        return timeToFirstTransitInDays;
    }

    public void setTimeToFirstTransitInDays(float timeToFirstTransitInDays) {
        this.timeToFirstTransitInDays = timeToFirstTransitInDays;
    }

    public float getRmsCdpp() {
        return rmsCdpp;
    }

    public void setRmsCdpp(float rmsCdpp) {
        this.rmsCdpp = rmsCdpp;
    }

    public double getTimeOfFirstTransitInMjd() {
        return timeOfFirstTransitInMjd;
    }

    public void setTimeOfFirstTransitInMjd(double timeOfFirstTransitInMjd) {
        this.timeOfFirstTransitInMjd = timeOfFirstTransitInMjd;
    }

    public boolean isMatchedFilterUsed() {
        return matchedFilterUsed;
    }

    public void setMatchedFilterUsed(boolean matchedFilterUsed) {
        this.matchedFilterUsed = matchedFilterUsed;
    }

    public SimpleFloatTimeSeries getCdppTimeSeries() {
        return cdppTimeSeries;
    }

    public void setCdppTimeSeries(SimpleFloatTimeSeries cdppTimeSeries) {
        this.cdppTimeSeries = cdppTimeSeries;
    }

    public float getMinMultipleEventStatistic() {
        return minMultipleEventStatistic;
    }

    public void setMinMultipleEventStatistic(float minMultipleEventStatistic) {
        this.minMultipleEventStatistic = minMultipleEventStatistic;
    }

    public float getTimeToFirstMicrolensInDays() {
        return timeToFirstMicrolensInDays;
    }

    public void setTimeToFirstMicrolensInDays(float timeToFirstMicrolensInDays) {
        this.timeToFirstMicrolensInDays = timeToFirstMicrolensInDays;
    }

    public double getTimeOfFirstMicrolensInMjd() {
        return timeOfFirstMicrolensInMjd;
    }

    public void setTimeOfFirstMicrolensInMjd(double timeOfFirstMicrolensInMjd) {
        this.timeOfFirstMicrolensInMjd = timeOfFirstMicrolensInMjd;
    }

    public float getDetectedMicrolensOrbitalPeriodInDays() {
        return detectedMicrolensOrbitalPeriodInDays;
    }

    public void setDetectedMicrolensOrbitalPeriodInDays(
        float detectedMicrolensOrbitalPeriodInDays) {
        this.detectedMicrolensOrbitalPeriodInDays = detectedMicrolensOrbitalPeriodInDays;
    }

}
