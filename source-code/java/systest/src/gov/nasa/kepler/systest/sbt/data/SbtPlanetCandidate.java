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

import gov.nasa.kepler.hibernate.dv.DvPlanetCandidate;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;

/**
 * This class contains a planet candidate.
 * 
 * @author Miles Cote
 * 
 */
public class SbtPlanetCandidate implements SbtDataContainer {

    private double epochMjd = Double.NaN;
    private float maxMultipleEventSigma = Float.NaN;
    private float maxSingleEventSigma = Float.NaN;
    private float modelChiSquare2 = Float.NaN;
    private int modelChiSquareDof2;
    private float modelChiSquareGof = Float.NaN;
    private int modelChiSquareGofDof;
    private double orbitalPeriod = Double.NaN;
    private float trialTransitPulseDuration = Float.NaN;
    private SbtWeakSecondary weakSecondary = new SbtWeakSecondary();

    private SbtBootstrapHistogram bootstrapHistogram = new SbtBootstrapHistogram();
    private int expectedTransitCount;
    private int observedTransitCount;
    private int planetNumber;
    private double significance = Double.NaN;
    private boolean statisticRatioBelowThreshold;
    private boolean suspectedEclipsingBinary;

    private CorrectedFluxTimeSeries initialFluxTimeSeries = new CorrectedFluxTimeSeries();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("epochMjd", new SbtNumber(
            epochMjd).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "maxMultipleEventSigma",
            new SbtNumber(maxMultipleEventSigma).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("maxSingleEventSigma",
            new SbtNumber(maxSingleEventSigma).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("modelChiSquare2",
            new SbtNumber(modelChiSquare2).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("modelChiSquareDof2",
            new SbtNumber(modelChiSquareDof2).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("modelChiSquareGof",
            new SbtNumber(modelChiSquareGof).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("modelChiSquareGofDof",
            new SbtNumber(modelChiSquareGofDof).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("orbitalPeriod",
            new SbtNumber(orbitalPeriod).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "trialTransitPulseDuration",
            new SbtNumber(trialTransitPulseDuration).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("weakSecondary",
            weakSecondary.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("bootstrapHistogram",
            bootstrapHistogram.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("expectedTransitCount",
            new SbtNumber(expectedTransitCount).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("observedTransitCount",
            new SbtNumber(observedTransitCount).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("planetNumber",
            new SbtNumber(planetNumber).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("significance",
            new SbtNumber(significance).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPlanetCandidate() {
    }

    public SbtPlanetCandidate(DvPlanetCandidate dvPlanetCandidate,
        CorrectedFluxTimeSeries initialFluxTimeSeries) {
        epochMjd = dvPlanetCandidate.getEpochMjd();
        maxMultipleEventSigma = dvPlanetCandidate.getMaxMultipleEventSigma();
        maxSingleEventSigma = dvPlanetCandidate.getMaxSingleEventSigma();
        modelChiSquare2 = dvPlanetCandidate.getModelChiSquare2();
        modelChiSquareDof2 = dvPlanetCandidate.getModelChiSquareDof2();
        modelChiSquareGof = dvPlanetCandidate.getModelChiSquareGof();
        modelChiSquareGofDof = dvPlanetCandidate.getModelChiSquareGofDof();
        orbitalPeriod = dvPlanetCandidate.getOrbitalPeriod();
        trialTransitPulseDuration = dvPlanetCandidate.getTrialTransitPulseDuration();
        weakSecondary = new SbtWeakSecondary(
            dvPlanetCandidate.getWeakSecondary());
        bootstrapHistogram = new SbtBootstrapHistogram(
            dvPlanetCandidate.getBootstrapHistogram());
        expectedTransitCount = dvPlanetCandidate.getExpectedTransitCount();
        observedTransitCount = dvPlanetCandidate.getObservedTransitCount();
        planetNumber = dvPlanetCandidate.getPlanetNumber();
        significance = dvPlanetCandidate.getSignificance();
        statisticRatioBelowThreshold = dvPlanetCandidate.isStatisticRatioBelowThreshold();
        suspectedEclipsingBinary = dvPlanetCandidate.isSuspectedEclipsingBinary();
        this.initialFluxTimeSeries = initialFluxTimeSeries;
    }

    public SbtPlanetCandidate(double epochMjd, float maxMultipleEventSigma,
        float maxSingleEventSigma, float modelChiSquare2,
        int modelChiSquareDof2, float modelChiSquareGof,
        int modelChiSquareGofDof, float orbitalPeriod,
        float trialTransitPulseDuration, SbtWeakSecondary weakSecondary,
        SbtBootstrapHistogram bootstrapHistogram, int expectedTransitCount,
        int observedTransitCount, int planetNumber, double significance,
        boolean statisticRatioBelowThreshold, boolean suspectedEclipsingBinary,
        CorrectedFluxTimeSeries initialFluxTimeSeries) {
        this.epochMjd = epochMjd;
        this.maxMultipleEventSigma = maxMultipleEventSigma;
        this.maxSingleEventSigma = maxSingleEventSigma;
        this.modelChiSquare2 = modelChiSquare2;
        this.modelChiSquareDof2 = modelChiSquareDof2;
        this.modelChiSquareGof = modelChiSquareGof;
        this.modelChiSquareGofDof = modelChiSquareGofDof;
        this.orbitalPeriod = orbitalPeriod;
        this.trialTransitPulseDuration = trialTransitPulseDuration;
        this.weakSecondary = weakSecondary;
        this.bootstrapHistogram = bootstrapHistogram;
        this.expectedTransitCount = expectedTransitCount;
        this.observedTransitCount = observedTransitCount;
        this.planetNumber = planetNumber;
        this.significance = significance;
        this.statisticRatioBelowThreshold = statisticRatioBelowThreshold;
        this.suspectedEclipsingBinary = suspectedEclipsingBinary;
        this.initialFluxTimeSeries = initialFluxTimeSeries;
    }

    public double getEpochMjd() {
        return epochMjd;
    }

    public void setEpochMjd(double epochMjd) {
        this.epochMjd = epochMjd;
    }

    public float getMaxMultipleEventSigma() {
        return maxMultipleEventSigma;
    }

    public void setMaxMultipleEventSigma(float maxMultipleEventSigma) {
        this.maxMultipleEventSigma = maxMultipleEventSigma;
    }

    public float getMaxSingleEventSigma() {
        return maxSingleEventSigma;
    }

    public void setMaxSingleEventSigma(float maxSingleEventSigma) {
        this.maxSingleEventSigma = maxSingleEventSigma;
    }

    public float getModelChiSquare2() {
        return modelChiSquare2;
    }

    public void setModelChiSquare2(float modelChiSquare2) {
        this.modelChiSquare2 = modelChiSquare2;
    }

    public int getModelChiSquareDof2() {
        return modelChiSquareDof2;
    }

    public void setModelChiSquareDof2(int modelChiSquareDof2) {
        this.modelChiSquareDof2 = modelChiSquareDof2;
    }

    public float getModelChiSquareGof() {
        return modelChiSquareGof;
    }

    public void setModelChiSquareGof(float modelChiSquareGof) {
        this.modelChiSquareGof = modelChiSquareGof;
    }

    public int getModelChiSquareGofDof() {
        return modelChiSquareGofDof;
    }

    public void setModelChiSquareGofDof(int modelChiSquareGofDof) {
        this.modelChiSquareGofDof = modelChiSquareGofDof;
    }

    public double getOrbitalPeriod() {
        return orbitalPeriod;
    }

    public void setOrbitalPeriod(float orbitalPeriod) {
        this.orbitalPeriod = orbitalPeriod;
    }

    public float getTrialTransitPulseDuration() {
        return trialTransitPulseDuration;
    }

    public void setTrialTransitPulseDuration(float trialTransitPulseDuration) {
        this.trialTransitPulseDuration = trialTransitPulseDuration;
    }

    public SbtWeakSecondary getWeakSecondary() {
        return weakSecondary;
    }

    public void setWeakSecondary(SbtWeakSecondary weakSecondary) {
        this.weakSecondary = weakSecondary;
    }

    public SbtBootstrapHistogram getBootstrapHistogram() {
        return bootstrapHistogram;
    }

    public void setBootstrapHistogram(SbtBootstrapHistogram bootstrapHistogram) {
        this.bootstrapHistogram = bootstrapHistogram;
    }

    public int getExpectedTransitCount() {
        return expectedTransitCount;
    }

    public void setExpectedTransitCount(int expectedTransitCount) {
        this.expectedTransitCount = expectedTransitCount;
    }

    public int getObservedTransitCount() {
        return observedTransitCount;
    }

    public void setObservedTransitCount(int observedTransitCount) {
        this.observedTransitCount = observedTransitCount;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public void setPlanetNumber(int planetNumber) {
        this.planetNumber = planetNumber;
    }

    public double getSignificance() {
        return significance;
    }

    public void setSignificance(double significance) {
        this.significance = significance;
    }

    public boolean isStatisticRatioBelowThreshold() {
        return statisticRatioBelowThreshold;
    }

    public void setStatisticRatioBelowThreshold(
        boolean statisticRatioBelowThreshold) {
        this.statisticRatioBelowThreshold = statisticRatioBelowThreshold;
    }

    public boolean isSuspectedEclipsingBinary() {
        return suspectedEclipsingBinary;
    }

    public void setSuspectedEclipsingBinary(boolean suspectedEclipsingBinary) {
        this.suspectedEclipsingBinary = suspectedEclipsingBinary;
    }

    public CorrectedFluxTimeSeries getInitialFluxTimeSeries() {
        return initialFluxTimeSeries;
    }

    public void setInitialFluxTimeSeries(
        CorrectedFluxTimeSeries initialFluxTimeSeries) {
        this.initialFluxTimeSeries = initialFluxTimeSeries;
    }

}
