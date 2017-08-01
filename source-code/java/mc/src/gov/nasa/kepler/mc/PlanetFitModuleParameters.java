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

package gov.nasa.kepler.mc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;

public class PlanetFitModuleParameters implements Persistable, Parameters {

    private float chiSquareConvergenceTolerance;
    private boolean cotrendingEnabled;
    private boolean deemphasisWeightsEnabled;
    private float defaultAlbedo;
    private int defaultEffectiveTemp;
    private float defaultLog10Metallicity;
    private float defaultLog10SurfaceGravity;
    private float defaultRadius;
    private float eclipsingBinaryAspectRatioDepthLimitPpm;
    private float eclipsingBinaryAspectRatioLimitCadences;
    private float eclipsingBinaryDepthLimitPpm;
    private float fitterTimeoutFraction;
    private int fitterTransitRemovalMethod;
    private float fitterTransitRemovalBufferTransits;
    private float giantTransitDetectionThresholdScaleFactor;
    private float impactParameterSeed;
    private float[] impactParametersForReducedFits = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int iterationToFreezeCadencesForFit;
    private float looseParameterConvergenceTolerance;
    private float looseSecondaryParameterConvergenceTolerance;
    private double minImpactParameterStepSize;
    private double orbitalPeriodStepSizeDays;
    private double planetRadiusStepSizeEarthRadii;
    private float ratioPlanetRadiusToStarRadiusStepSize;
    private float ratioSemiMajorAxisToStarRadiusStepSize;
    private boolean reducedParameterFitsEnabled;
    private float reportSummaryBinsPerTransit;
    private float reportSummaryClippingLevel;
    private boolean robustFitEnabled;
    private float robustWeightThresholdForPlots;
    private boolean saveTimeSeriesEnabled;
    private double semiMajorAxisStepSizeAu;
    private float smallBodyCutoff;
    private float subtractModelTransitRemovalBufferTransits;
    private int subtractModelTransitRemovalMethod;
    private float tightParameterConvergenceTolerance;
    private float tightSecondaryParameterConvergenceTolerance;
    private float tolFun;
    private float tolSigma;
    private float tolX;
    private int transitBufferCadences;
    private float transitDurationMultiplier;
    private double transitEpochStepSizeCadences;
    private int transitSamplesPerCadence;
    private boolean trapezoidalModelFitEnabled;
    private int whitenerFitterMaxIterations;

    public PlanetFitModuleParameters() {
    }

    public float getChiSquareConvergenceTolerance() {
        return chiSquareConvergenceTolerance;
    }

    public void setChiSquareConvergenceTolerance(
        float chiSquareConvergenceTolerance) {
        this.chiSquareConvergenceTolerance = chiSquareConvergenceTolerance;
    }

    public boolean isCotrendingEnabled() {
        return cotrendingEnabled;
    }

    public void setCotrendingEnabled(boolean cotrendingEnabled) {
        this.cotrendingEnabled = cotrendingEnabled;
    }

    public boolean isDeemphasisWeightsEnabled() {
        return deemphasisWeightsEnabled;
    }

    public void setDeemphasisWeightsEnabled(boolean deemphasisWeightsEnabled) {
        this.deemphasisWeightsEnabled = deemphasisWeightsEnabled;
    }

    public float getDefaultAlbedo() {
        return defaultAlbedo;
    }

    public void setDefaultAlbedo(float defaultAlbedo) {
        this.defaultAlbedo = defaultAlbedo;
    }

    public int getDefaultEffectiveTemp() {
        return defaultEffectiveTemp;
    }

    public void setDefaultEffectiveTemp(int defaultEffectiveTemp) {
        this.defaultEffectiveTemp = defaultEffectiveTemp;
    }

    public float getDefaultLog10Metallicity() {
        return defaultLog10Metallicity;
    }

    public void setDefaultLog10Metallicity(float defaultLog10Metallicity) {
        this.defaultLog10Metallicity = defaultLog10Metallicity;
    }

    public float getDefaultLog10SurfaceGravity() {
        return defaultLog10SurfaceGravity;
    }

    public void setDefaultLog10SurfaceGravity(float defaultLog10SurfaceGravity) {
        this.defaultLog10SurfaceGravity = defaultLog10SurfaceGravity;
    }

    public float getDefaultRadius() {
        return defaultRadius;
    }

    public void setDefaultRadius(float defaultRadius) {
        this.defaultRadius = defaultRadius;
    }

    public float getEclipsingBinaryAspectRatioDepthLimitPpm() {
        return eclipsingBinaryAspectRatioDepthLimitPpm;
    }

    public void setEclipsingBinaryAspectRatioDepthLimitPpm(
        float eclipsingBinaryAspectRatioDepthLimitPpm) {
        this.eclipsingBinaryAspectRatioDepthLimitPpm = eclipsingBinaryAspectRatioDepthLimitPpm;
    }

    public float getEclipsingBinaryAspectRatioLimitCadences() {
        return eclipsingBinaryAspectRatioLimitCadences;
    }

    public void setEclipsingBinaryAspectRatioLimitCadences(
        float eclipsingBinaryAspectRatioLimitCadences) {
        this.eclipsingBinaryAspectRatioLimitCadences = eclipsingBinaryAspectRatioLimitCadences;
    }

    public float getEclipsingBinaryDepthLimitPpm() {
        return eclipsingBinaryDepthLimitPpm;
    }

    public void setEclipsingBinaryDepthLimitPpm(
        float eclipsingBinaryDepthLimitPpm) {
        this.eclipsingBinaryDepthLimitPpm = eclipsingBinaryDepthLimitPpm;
    }

    public float getFitterTimeoutFraction() {
        return fitterTimeoutFraction;
    }

    public void setFitterTimeoutFraction(float fitterTimeoutFraction) {
        this.fitterTimeoutFraction = fitterTimeoutFraction;
    }

    public int getFitterTransitRemovalMethod() {
        return fitterTransitRemovalMethod;
    }

    public void setFitterTransitRemovalMethod(int fitterTransitRemovalMethod) {
        this.fitterTransitRemovalMethod = fitterTransitRemovalMethod;
    }

    public float getFitterTransitRemovalBufferTransits() {
        return fitterTransitRemovalBufferTransits;
    }

    public void setFitterTransitRemovalBufferTransits(
        float fitterTransitRemovalBufferTransits) {
        this.fitterTransitRemovalBufferTransits = fitterTransitRemovalBufferTransits;
    }

    public float getGiantTransitDetectionThresholdScaleFactor() {
        return giantTransitDetectionThresholdScaleFactor;
    }

    public void setGiantTransitDetectionThresholdScaleFactor(
        float giantTransitDetectionThresholdScaleFactor) {
        this.giantTransitDetectionThresholdScaleFactor = giantTransitDetectionThresholdScaleFactor;
    }

    public float getImpactParameterSeed() {
        return impactParameterSeed;
    }

    public void setImpactParameterSeed(float impactParameterSeed) {
        this.impactParameterSeed = impactParameterSeed;
    }

    public float[] getImpactParametersForReducedFits() {
        return impactParametersForReducedFits;
    }

    public void setImpactParametersForReducedFits(
        float[] impactParametersForReducedFits) {
        this.impactParametersForReducedFits = impactParametersForReducedFits;
    }

    public int getIterationToFreezeCadencesForFit() {
        return iterationToFreezeCadencesForFit;
    }

    public void setIterationToFreezeCadencesForFit(
        int iterationToFreezeCadencesForFit) {
        this.iterationToFreezeCadencesForFit = iterationToFreezeCadencesForFit;
    }

    public float getLooseParameterConvergenceTolerance() {
        return looseParameterConvergenceTolerance;
    }

    public void setLooseParameterConvergenceTolerance(
        float looseParameterConvergenceTolerance) {
        this.looseParameterConvergenceTolerance = looseParameterConvergenceTolerance;
    }

    public float getLooseSecondaryParameterConvergenceTolerance() {
        return looseSecondaryParameterConvergenceTolerance;
    }

    public void setLooseSecondaryParameterConvergenceTolerance(
        float looseSecondaryParameterConvergenceTolerance) {
        this.looseSecondaryParameterConvergenceTolerance = looseSecondaryParameterConvergenceTolerance;
    }

    public double getMinImpactParameterStepSize() {
        return minImpactParameterStepSize;
    }

    public void setMinImpactParameterStepSize(double minImpactParameterStepSize) {
        this.minImpactParameterStepSize = minImpactParameterStepSize;
    }

    public double getOrbitalPeriodStepSizeDays() {
        return orbitalPeriodStepSizeDays;
    }

    public void setOrbitalPeriodStepSizeDays(double orbitalPeriodStepSizeDays) {
        this.orbitalPeriodStepSizeDays = orbitalPeriodStepSizeDays;
    }

    public double getPlanetRadiusStepSizeEarthRadii() {
        return planetRadiusStepSizeEarthRadii;
    }

    public void setPlanetRadiusStepSizeEarthRadii(
        double planetRadiusStepSizeEarthRadii) {
        this.planetRadiusStepSizeEarthRadii = planetRadiusStepSizeEarthRadii;
    }

    public float getRatioPlanetRadiusToStarRadiusStepSize() {
        return ratioPlanetRadiusToStarRadiusStepSize;
    }

    public void setRatioPlanetRadiusToStarRadiusStepSize(
        float ratioPlanetRadiusToStarRadiusStepSize) {
        this.ratioPlanetRadiusToStarRadiusStepSize = ratioPlanetRadiusToStarRadiusStepSize;
    }

    public float getRatioSemiMajorAxisToStarRadiusStepSize() {
        return ratioSemiMajorAxisToStarRadiusStepSize;
    }

    public void setRatioSemiMajorAxisToStarRadiusStepSize(
        float ratioSemiMajorAxisToStarRadiusStepSize) {
        this.ratioSemiMajorAxisToStarRadiusStepSize = ratioSemiMajorAxisToStarRadiusStepSize;
    }

    public boolean isReducedParameterFitsEnabled() {
        return reducedParameterFitsEnabled;
    }

    public void setReducedParameterFitsEnabled(
        boolean reducedParameterFitsEnabled) {
        this.reducedParameterFitsEnabled = reducedParameterFitsEnabled;
    }

    public float getReportSummaryBinsPerTransit() {
        return reportSummaryBinsPerTransit;
    }

    public void setReportSummaryBinsPerTransit(float reportSummaryBinsPerTransit) {
        this.reportSummaryBinsPerTransit = reportSummaryBinsPerTransit;
    }

    public float getReportSummaryClippingLevel() {
        return reportSummaryClippingLevel;
    }

    public void setReportSummaryClippingLevel(float reportSummaryClippingLevel) {
        this.reportSummaryClippingLevel = reportSummaryClippingLevel;
    }

    public boolean isRobustFitEnabled() {
        return robustFitEnabled;
    }

    public void setRobustFitEnabled(boolean robustFitEnabled) {
        this.robustFitEnabled = robustFitEnabled;
    }

    public float getRobustWeightThresholdForPlots() {
        return robustWeightThresholdForPlots;
    }

    public void setRobustWeightThresholdForPlots(
        float robustWeightThresholdForPlots) {
        this.robustWeightThresholdForPlots = robustWeightThresholdForPlots;
    }

    public boolean isSaveTimeSeriesEnabled() {
        return saveTimeSeriesEnabled;
    }

    public void setSaveTimeSeriesEnabled(boolean saveTimeSeriesEnabled) {
        this.saveTimeSeriesEnabled = saveTimeSeriesEnabled;
    }

    public double getSemiMajorAxisStepSizeAu() {
        return semiMajorAxisStepSizeAu;
    }

    public void setSemiMajorAxisStepSizeAu(double semiMajorAxisStepSizeAu) {
        this.semiMajorAxisStepSizeAu = semiMajorAxisStepSizeAu;
    }

    public float getSmallBodyCutoff() {
        return smallBodyCutoff;
    }

    public void setSmallBodyCutoff(float smallBodyCutoff) {
        this.smallBodyCutoff = smallBodyCutoff;
    }

    public float getSubtractModelTransitRemovalBufferTransits() {
        return subtractModelTransitRemovalBufferTransits;
    }

    public void setSubtractModelTransitRemovalBufferTransits(
        float subtractModelTransitRemovalBufferTransits) {
        this.subtractModelTransitRemovalBufferTransits = subtractModelTransitRemovalBufferTransits;
    }

    public int getSubtractModelTransitRemovalMethod() {
        return subtractModelTransitRemovalMethod;
    }

    public void setSubtractModelTransitRemovalMethod(
        int subtractModelTransitRemovalMethod) {
        this.subtractModelTransitRemovalMethod = subtractModelTransitRemovalMethod;
    }

    public float getTightParameterConvergenceTolerance() {
        return tightParameterConvergenceTolerance;
    }

    public void setTightParameterConvergenceTolerance(
        float tightParameterConvergenceTolerance) {
        this.tightParameterConvergenceTolerance = tightParameterConvergenceTolerance;
    }

    public float getTightSecondaryParameterConvergenceTolerance() {
        return tightSecondaryParameterConvergenceTolerance;
    }

    public void setTightSecondaryParameterConvergenceTolerance(
        float tightSecondaryParameterConvergenceTolerance) {
        this.tightSecondaryParameterConvergenceTolerance = tightSecondaryParameterConvergenceTolerance;
    }

    public float getTolFun() {
        return tolFun;
    }

    public void setTolFun(float tolFun) {
        this.tolFun = tolFun;
    }

    public float getTolSigma() {
        return tolSigma;
    }

    public void setTolSigma(float tolSigma) {
        this.tolSigma = tolSigma;
    }

    public float getTolX() {
        return tolX;
    }

    public void setTolX(float tolX) {
        this.tolX = tolX;
    }

    public int getTransitBufferCadences() {
        return transitBufferCadences;
    }

    public void setTransitBufferCadences(int transitBufferCadences) {
        this.transitBufferCadences = transitBufferCadences;
    }

    public float getTransitDurationMultiplier() {
        return transitDurationMultiplier;
    }

    public void setTransitDurationMultiplier(float transitDurationMultiplier) {
        this.transitDurationMultiplier = transitDurationMultiplier;
    }

    public double getTransitEpochStepSizeCadences() {
        return transitEpochStepSizeCadences;
    }

    public void setTransitEpochStepSizeCadences(
        double transitEpochStepSizeCadences) {
        this.transitEpochStepSizeCadences = transitEpochStepSizeCadences;
    }

    public int getTransitSamplesPerCadence() {
        return transitSamplesPerCadence;
    }

    public void setTransitSamplesPerCadence(int transitSamplesPerCadence) {
        this.transitSamplesPerCadence = transitSamplesPerCadence;
    }

    public boolean isTrapezoidalModelFitEnabled() {
        return trapezoidalModelFitEnabled;
    }

    public void setTrapezoidalModelFitEnabled(boolean trapezoidalModelFitEnabled) {
        this.trapezoidalModelFitEnabled = trapezoidalModelFitEnabled;
    }

    public int getWhitenerFitterMaxIterations() {
        return whitenerFitterMaxIterations;
    }

    public void setWhitenerFitterMaxIterations(int whitenerFitterMaxIterations) {
        this.whitenerFitterMaxIterations = whitenerFitterMaxIterations;
    }
}
