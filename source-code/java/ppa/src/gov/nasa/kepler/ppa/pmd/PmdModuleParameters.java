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

package gov.nasa.kepler.ppa.pmd;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Represents the complete set of available PPA:PMD module parameters.
 * <p>
 * Documentation for these fields can be found in the MATLAB code (see
 * matlab/ppa/mfiles/@ppaScienceClass/ppaScienceClass).
 * 
 * @author Bill Wohler
 * @author Forrest Girouard (fgirouard)
 */
public class PmdModuleParameters implements Parameters, Persistable {

    private float horizonTime;
    private float trendFitTime;
    private float alertTime;
    private float initialAverageSampleCount;
    private float minTrendFitSampleCount;
    private float adaptiveBoundsXFactorForOutlier;

    private float blackLevelSmoothingFactor;
    private float blackLevelFixedLowerBound;
    private float blackLevelFixedUpperBound;
    private float blackLevelAdaptiveXFactor;

    private float smearLevelSmoothingFactor;
    private float smearLevelFixedLowerBound;
    private float smearLevelFixedUpperBound;
    private float smearLevelAdaptiveXFactor;

    private float darkCurrentSmoothingFactor;
    private float darkCurrentFixedLowerBound;
    private float darkCurrentFixedUpperBound;
    private float darkCurrentAdaptiveXFactor;

    private float twoDBlackSmoothingFactor;
    private float twoDBlackFixedLowerBound;
    private float twoDBlackFixedUpperBound;
    private float twoDBlackAdaptiveXFactor;

    private float ldeUndershootSmoothingFactor;
    private float ldeUndershootFixedLowerBound;
    private float ldeUndershootFixedUpperBound;
    private float ldeUndershootAdaptiveXFactor;

    private float compressionSmoothingFactor;
    private float compressionFixedLowerBound;
    private float compressionFixedUpperBound;
    private float compressionAdaptiveXFactor;

    private float blackCosmicRayHitRateSmoothingFactor;
    private float blackCosmicRayHitRateFixedLowerBound;
    private float blackCosmicRayHitRateFixedUpperBound;
    private float blackCosmicRayHitRateAdaptiveXFactor;
    private float blackCosmicRayMeanEnergySmoothingFactor;
    private float blackCosmicRayMeanEnergyFixedLowerBound;
    private float blackCosmicRayMeanEnergyFixedUpperBound;
    private float blackCosmicRayMeanEnergyAdaptiveXFactor;
    private float blackCosmicRayEnergyVarianceSmoothingFactor;
    private float blackCosmicRayEnergyVarianceFixedLowerBound;
    private float blackCosmicRayEnergyVarianceFixedUpperBound;
    private float blackCosmicRayEnergyVarianceAdaptiveXFactor;
    private float blackCosmicRayEnergySkewnessSmoothingFactor;
    private float blackCosmicRayEnergySkewnessFixedLowerBound;
    private float blackCosmicRayEnergySkewnessFixedUpperBound;
    private float blackCosmicRayEnergySkewnessAdaptiveXFactor;
    private float blackCosmicRayEnergyKurtosisSmoothingFactor;
    private float blackCosmicRayEnergyKurtosisFixedLowerBound;
    private float blackCosmicRayEnergyKurtosisFixedUpperBound;
    private float blackCosmicRayEnergyKurtosisAdaptiveXFactor;

    private float maskedSmearCosmicRayHitRateSmoothingFactor;
    private float maskedSmearCosmicRayHitRateFixedLowerBound;
    private float maskedSmearCosmicRayHitRateFixedUpperBound;
    private float maskedSmearCosmicRayHitRateAdaptiveXFactor;
    private float maskedSmearCosmicRayMeanEnergySmoothingFactor;
    private float maskedSmearCosmicRayMeanEnergyFixedLowerBound;
    private float maskedSmearCosmicRayMeanEnergyFixedUpperBound;
    private float maskedSmearCosmicRayMeanEnergyAdaptiveXFactor;
    private float maskedSmearCosmicRayEnergyVarianceSmoothingFactor;
    private float maskedSmearCosmicRayEnergyVarianceFixedLowerBound;
    private float maskedSmearCosmicRayEnergyVarianceFixedUpperBound;
    private float maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor;
    private float maskedSmearCosmicRayEnergySkewnessSmoothingFactor;
    private float maskedSmearCosmicRayEnergySkewnessFixedLowerBound;
    private float maskedSmearCosmicRayEnergySkewnessFixedUpperBound;
    private float maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor;
    private float maskedSmearCosmicRayEnergyKurtosisSmoothingFactor;
    private float maskedSmearCosmicRayEnergyKurtosisFixedLowerBound;
    private float maskedSmearCosmicRayEnergyKurtosisFixedUpperBound;
    private float maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor;

    private float virtualSmearCosmicRayHitRateSmoothingFactor;
    private float virtualSmearCosmicRayHitRateFixedLowerBound;
    private float virtualSmearCosmicRayHitRateFixedUpperBound;
    private float virtualSmearCosmicRayHitRateAdaptiveXFactor;
    private float virtualSmearCosmicRayMeanEnergySmoothingFactor;
    private float virtualSmearCosmicRayMeanEnergyFixedLowerBound;
    private float virtualSmearCosmicRayMeanEnergyFixedUpperBound;
    private float virtualSmearCosmicRayMeanEnergyAdaptiveXFactor;
    private float virtualSmearCosmicRayEnergyVarianceSmoothingFactor;
    private float virtualSmearCosmicRayEnergyVarianceFixedLowerBound;
    private float virtualSmearCosmicRayEnergyVarianceFixedUpperBound;
    private float virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor;
    private float virtualSmearCosmicRayEnergySkewnessSmoothingFactor;
    private float virtualSmearCosmicRayEnergySkewnessFixedLowerBound;
    private float virtualSmearCosmicRayEnergySkewnessFixedUpperBound;
    private float virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor;
    private float virtualSmearCosmicRayEnergyKurtosisSmoothingFactor;
    private float virtualSmearCosmicRayEnergyKurtosisFixedLowerBound;
    private float virtualSmearCosmicRayEnergyKurtosisFixedUpperBound;
    private float virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor;

    private float targetStarCosmicRayHitRateSmoothingFactor;
    private float targetStarCosmicRayHitRateFixedLowerBound;
    private float targetStarCosmicRayHitRateFixedUpperBound;
    private float targetStarCosmicRayHitRateAdaptiveXFactor;
    private float targetStarCosmicRayMeanEnergySmoothingFactor;
    private float targetStarCosmicRayMeanEnergyFixedLowerBound;
    private float targetStarCosmicRayMeanEnergyFixedUpperBound;
    private float targetStarCosmicRayMeanEnergyAdaptiveXFactor;
    private float targetStarCosmicRayEnergyVarianceSmoothingFactor;
    private float targetStarCosmicRayEnergyVarianceFixedLowerBound;
    private float targetStarCosmicRayEnergyVarianceFixedUpperBound;
    private float targetStarCosmicRayEnergyVarianceAdaptiveXFactor;
    private float targetStarCosmicRayEnergySkewnessSmoothingFactor;
    private float targetStarCosmicRayEnergySkewnessFixedLowerBound;
    private float targetStarCosmicRayEnergySkewnessFixedUpperBound;
    private float targetStarCosmicRayEnergySkewnessAdaptiveXFactor;
    private float targetStarCosmicRayEnergyKurtosisSmoothingFactor;
    private float targetStarCosmicRayEnergyKurtosisFixedLowerBound;
    private float targetStarCosmicRayEnergyKurtosisFixedUpperBound;
    private float targetStarCosmicRayEnergyKurtosisAdaptiveXFactor;

    private float backgroundCosmicRayHitRateSmoothingFactor;
    private float backgroundCosmicRayHitRateFixedLowerBound;
    private float backgroundCosmicRayHitRateFixedUpperBound;
    private float backgroundCosmicRayHitRateAdaptiveXFactor;
    private float backgroundCosmicRayMeanEnergySmoothingFactor;
    private float backgroundCosmicRayMeanEnergyFixedLowerBound;
    private float backgroundCosmicRayMeanEnergyFixedUpperBound;
    private float backgroundCosmicRayMeanEnergyAdaptiveXFactor;
    private float backgroundCosmicRayEnergyVarianceSmoothingFactor;
    private float backgroundCosmicRayEnergyVarianceFixedLowerBound;
    private float backgroundCosmicRayEnergyVarianceFixedUpperBound;
    private float backgroundCosmicRayEnergyVarianceAdaptiveXFactor;
    private float backgroundCosmicRayEnergySkewnessSmoothingFactor;
    private float backgroundCosmicRayEnergySkewnessFixedLowerBound;
    private float backgroundCosmicRayEnergySkewnessFixedUpperBound;
    private float backgroundCosmicRayEnergySkewnessAdaptiveXFactor;
    private float backgroundCosmicRayEnergyKurtosisSmoothingFactor;
    private float backgroundCosmicRayEnergyKurtosisFixedLowerBound;
    private float backgroundCosmicRayEnergyKurtosisFixedUpperBound;
    private float backgroundCosmicRayEnergyKurtosisAdaptiveXFactor;

    private float brightnessSmoothingFactor;
    private float brightnessFixedLowerBound;
    private float brightnessFixedUpperBound;
    private float brightnessAdaptiveXFactor;

    private float encircledEnergySmoothingFactor;
    private float encircledEnergyFixedLowerBound;
    private float encircledEnergyFixedUpperBound;
    private float encircledEnergyAdaptiveXFactor;

    private float backgroundLevelSmoothingFactor;
    private float backgroundLevelFixedLowerBound;
    private float backgroundLevelFixedUpperBound;
    private float backgroundLevelAdaptiveXFactor;

    private float centroidsMeanRowSmoothingFactor;
    private float centroidsMeanRowFixedLowerBound;
    private float centroidsMeanRowFixedUpperBound;
    private float centroidsMeanRowAdaptiveXFactor;

    private float centroidsMeanColumnSmoothingFactor;
    private float centroidsMeanColumnFixedLowerBound;
    private float centroidsMeanColumnFixedUpperBound;
    private float centroidsMeanColumnAdaptiveXFactor;

    private float plateScaleSmoothingFactor;
    private float plateScaleFixedLowerBound;
    private float plateScaleFixedUpperBound;
    private float plateScaleAdaptiveXFactor;

    private float cdppExpectedSmoothingFactor;
    private float cdppExpectedFixedLowerBound;
    private float cdppExpectedFixedUpperBound;
    private float cdppExpectedAdaptiveXFactor;

    private float cdppMeasuredSmoothingFactor;
    private float cdppMeasuredFixedLowerBound;
    private float cdppMeasuredFixedUpperBound;
    private float cdppMeasuredAdaptiveXFactor;

    private float cdppRatioSmoothingFactor;
    private float cdppRatioFixedLowerBound;
    private float cdppRatioFixedUpperBound;
    private float cdppRatioAdaptiveXFactor;

    private int debugLevel;
    private boolean plottingEnabled;

    public float getHorizonTime() {
        return horizonTime;
    }

    public void setHorizonTime(float horizonTime) {
        this.horizonTime = horizonTime;
    }

    public float getTrendFitTime() {
        return trendFitTime;
    }

    public void setTrendFitTime(float trendFitTime) {
        this.trendFitTime = trendFitTime;
    }

    public float getAlertTime() {
        return alertTime;
    }

    public void setAlertTime(float alertTime) {
        this.alertTime = alertTime;
    }

    public float getInitialAverageSampleCount() {
        return initialAverageSampleCount;
    }

    public void setInitialAverageSampleCount(float initialAverageSampleCount) {
        this.initialAverageSampleCount = initialAverageSampleCount;
    }

    public float getMinTrendFitSampleCount() {
        return minTrendFitSampleCount;
    }

    public void setMinTrendFitSampleCount(float minTrendFitSampleCount) {
        this.minTrendFitSampleCount = minTrendFitSampleCount;
    }

    public float getAdaptiveBoundsXFactorForOutlier() {
        return adaptiveBoundsXFactorForOutlier;
    }

    public void setAdaptiveBoundsXFactorForOutlier(
        float adaptiveBoundsXFactorForOutlier) {
        this.adaptiveBoundsXFactorForOutlier = adaptiveBoundsXFactorForOutlier;
    }

    public float getBlackLevelSmoothingFactor() {
        return blackLevelSmoothingFactor;
    }

    public void setBlackLevelSmoothingFactor(float blackLevelSmoothingFactor) {
        this.blackLevelSmoothingFactor = blackLevelSmoothingFactor;
    }

    public float getBlackLevelFixedLowerBound() {
        return blackLevelFixedLowerBound;
    }

    public void setBlackLevelFixedLowerBound(float blackLevelFixedLowerBound) {
        this.blackLevelFixedLowerBound = blackLevelFixedLowerBound;
    }

    public float getBlackLevelFixedUpperBound() {
        return blackLevelFixedUpperBound;
    }

    public void setBlackLevelFixedUpperBound(float blackLevelFixedUpperBound) {
        this.blackLevelFixedUpperBound = blackLevelFixedUpperBound;
    }

    public float getBlackLevelAdaptiveXFactor() {
        return blackLevelAdaptiveXFactor;
    }

    public void setBlackLevelAdaptiveXFactor(float blackLevelAdaptiveXFactor) {
        this.blackLevelAdaptiveXFactor = blackLevelAdaptiveXFactor;
    }

    public float getSmearLevelSmoothingFactor() {
        return smearLevelSmoothingFactor;
    }

    public void setSmearLevelSmoothingFactor(float smearLevelSmoothingFactor) {
        this.smearLevelSmoothingFactor = smearLevelSmoothingFactor;
    }

    public float getSmearLevelFixedLowerBound() {
        return smearLevelFixedLowerBound;
    }

    public void setSmearLevelFixedLowerBound(float smearLevelFixedLowerBound) {
        this.smearLevelFixedLowerBound = smearLevelFixedLowerBound;
    }

    public float getSmearLevelFixedUpperBound() {
        return smearLevelFixedUpperBound;
    }

    public void setSmearLevelFixedUpperBound(float smearLevelFixedUpperBound) {
        this.smearLevelFixedUpperBound = smearLevelFixedUpperBound;
    }

    public float getSmearLevelAdaptiveXFactor() {
        return smearLevelAdaptiveXFactor;
    }

    public void setSmearLevelAdaptiveXFactor(float smearLevelAdaptiveXFactor) {
        this.smearLevelAdaptiveXFactor = smearLevelAdaptiveXFactor;
    }

    public float getDarkCurrentSmoothingFactor() {
        return darkCurrentSmoothingFactor;
    }

    public void setDarkCurrentSmoothingFactor(float darkCurrentSmoothingFactor) {
        this.darkCurrentSmoothingFactor = darkCurrentSmoothingFactor;
    }

    public float getDarkCurrentFixedLowerBound() {
        return darkCurrentFixedLowerBound;
    }

    public void setDarkCurrentFixedLowerBound(float darkCurrentFixedLowerBound) {
        this.darkCurrentFixedLowerBound = darkCurrentFixedLowerBound;
    }

    public float getDarkCurrentFixedUpperBound() {
        return darkCurrentFixedUpperBound;
    }

    public void setDarkCurrentFixedUpperBound(float darkCurrentFixedUpperBound) {
        this.darkCurrentFixedUpperBound = darkCurrentFixedUpperBound;
    }

    public float getDarkCurrentAdaptiveXFactor() {
        return darkCurrentAdaptiveXFactor;
    }

    public void setDarkCurrentAdaptiveXFactor(float darkCurrentAdaptiveXFactor) {
        this.darkCurrentAdaptiveXFactor = darkCurrentAdaptiveXFactor;
    }

    public float getTwoDBlackSmoothingFactor() {
        return twoDBlackSmoothingFactor;
    }

    public void setTwoDBlackSmoothingFactor(float twoDBlackSmoothingFactor) {
        this.twoDBlackSmoothingFactor = twoDBlackSmoothingFactor;
    }

    public float getTwoDBlackFixedLowerBound() {
        return twoDBlackFixedLowerBound;
    }

    public void setTwoDBlackFixedLowerBound(float twoDBlackFixedLowerBound) {
        this.twoDBlackFixedLowerBound = twoDBlackFixedLowerBound;
    }

    public float getTwoDBlackFixedUpperBound() {
        return twoDBlackFixedUpperBound;
    }

    public void setTwoDBlackFixedUpperBound(float twoDBlackFixedUpperBound) {
        this.twoDBlackFixedUpperBound = twoDBlackFixedUpperBound;
    }

    public float getTwoDBlackAdaptiveXFactor() {
        return twoDBlackAdaptiveXFactor;
    }

    public void setTwoDBlackAdaptiveXFactor(float twoDBlackAdaptiveXFactor) {
        this.twoDBlackAdaptiveXFactor = twoDBlackAdaptiveXFactor;
    }

    public float getLdeUndershootSmoothingFactor() {
        return ldeUndershootSmoothingFactor;
    }

    public void setLdeUndershootSmoothingFactor(
        float ldeUndershootSmoothingFactor) {
        this.ldeUndershootSmoothingFactor = ldeUndershootSmoothingFactor;
    }

    public float getLdeUndershootFixedLowerBound() {
        return ldeUndershootFixedLowerBound;
    }

    public void setLdeUndershootFixedLowerBound(
        float ldeUndershootFixedLowerBound) {
        this.ldeUndershootFixedLowerBound = ldeUndershootFixedLowerBound;
    }

    public float getLdeUndershootFixedUpperBound() {
        return ldeUndershootFixedUpperBound;
    }

    public void setLdeUndershootFixedUpperBound(
        float ldeUndershootFixedUpperBound) {
        this.ldeUndershootFixedUpperBound = ldeUndershootFixedUpperBound;
    }

    public float getLdeUndershootAdaptiveXFactor() {
        return ldeUndershootAdaptiveXFactor;
    }

    public void setLdeUndershootAdaptiveXFactor(
        float ldeUndershootAdaptiveXFactor) {
        this.ldeUndershootAdaptiveXFactor = ldeUndershootAdaptiveXFactor;
    }

    public float getCompressionSmoothingFactor() {
        return compressionSmoothingFactor;
    }

    public void setCompressionSmoothingFactor(float compressionSmoothingFactor) {
        this.compressionSmoothingFactor = compressionSmoothingFactor;
    }

    public float getCompressionFixedLowerBound() {
        return compressionFixedLowerBound;
    }

    public void setCompressionFixedLowerBound(float compressionFixedLowerBound) {
        this.compressionFixedLowerBound = compressionFixedLowerBound;
    }

    public float getCompressionFixedUpperBound() {
        return compressionFixedUpperBound;
    }

    public void setCompressionFixedUpperBound(float compressionFixedUpperBound) {
        this.compressionFixedUpperBound = compressionFixedUpperBound;
    }

    public float getCompressionAdaptiveXFactor() {
        return compressionAdaptiveXFactor;
    }

    public void setCompressionAdaptiveXFactor(float compressionAdaptiveXFactor) {
        this.compressionAdaptiveXFactor = compressionAdaptiveXFactor;
    }

    public float getBlackCosmicRayHitRateSmoothingFactor() {
        return blackCosmicRayHitRateSmoothingFactor;
    }

    public void setBlackCosmicRayHitRateSmoothingFactor(
        float blackCosmicRayHitRateSmoothingFactor) {
        this.blackCosmicRayHitRateSmoothingFactor = blackCosmicRayHitRateSmoothingFactor;
    }

    public float getBlackCosmicRayHitRateFixedLowerBound() {
        return blackCosmicRayHitRateFixedLowerBound;
    }

    public void setBlackCosmicRayHitRateFixedLowerBound(
        float blackCosmicRayHitRateFixedLowerBound) {
        this.blackCosmicRayHitRateFixedLowerBound = blackCosmicRayHitRateFixedLowerBound;
    }

    public float getBlackCosmicRayHitRateFixedUpperBound() {
        return blackCosmicRayHitRateFixedUpperBound;
    }

    public void setBlackCosmicRayHitRateFixedUpperBound(
        float blackCosmicRayHitRateFixedUpperBound) {
        this.blackCosmicRayHitRateFixedUpperBound = blackCosmicRayHitRateFixedUpperBound;
    }

    public float getBlackCosmicRayAdaptiveXFactor() {
        return blackCosmicRayHitRateAdaptiveXFactor;
    }

    public void setBlackCosmicRayAdaptiveXFactor(
        float blackCosmicRayAdaptiveXFactor) {
        blackCosmicRayHitRateAdaptiveXFactor = blackCosmicRayAdaptiveXFactor;
    }

    public float getBlackCosmicRayMeanEnergySmoothingFactor() {
        return blackCosmicRayMeanEnergySmoothingFactor;
    }

    public void setBlackCosmicRayMeanEnergySmoothingFactor(
        float blackCosmicRayMeanEnergySmoothingFactor) {
        this.blackCosmicRayMeanEnergySmoothingFactor = blackCosmicRayMeanEnergySmoothingFactor;
    }

    public float getBlackCosmicRayMeanEnergyFixedLowerBound() {
        return blackCosmicRayMeanEnergyFixedLowerBound;
    }

    public void setBlackCosmicRayMeanEnergyFixedLowerBound(
        float blackCosmicRayMeanEnergyFixedLowerBound) {
        this.blackCosmicRayMeanEnergyFixedLowerBound = blackCosmicRayMeanEnergyFixedLowerBound;
    }

    public float getBlackCosmicRayMeanEnergyFixedUpperBound() {
        return blackCosmicRayMeanEnergyFixedUpperBound;
    }

    public void setBlackCosmicRayMeanEnergyFixedUpperBound(
        float blackCosmicRayMeanEnergyFixedUpperBound) {
        this.blackCosmicRayMeanEnergyFixedUpperBound = blackCosmicRayMeanEnergyFixedUpperBound;
    }

    public float getBlackCosmicRayMeanEnergyAdaptiveXFactor() {
        return blackCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public void setBlackCosmicRayMeanEnergyAdaptiveXFactor(
        float blackCosmicRayMeanEnergyAdaptiveXFactor) {
        this.blackCosmicRayMeanEnergyAdaptiveXFactor = blackCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public float getBlackCosmicRayEnergyVarianceSmoothingFactor() {
        return blackCosmicRayEnergyVarianceSmoothingFactor;
    }

    public void setBlackCosmicRayEnergyVarianceSmoothingFactor(
        float blackCosmicRayEnergyVarianceSmoothingFactor) {
        this.blackCosmicRayEnergyVarianceSmoothingFactor = blackCosmicRayEnergyVarianceSmoothingFactor;
    }

    public float getBlackCosmicRayEnergyVarianceFixedLowerBound() {
        return blackCosmicRayEnergyVarianceFixedLowerBound;
    }

    public void setBlackCosmicRayEnergyVarianceFixedLowerBound(
        float blackCosmicRayEnergyVarianceFixedLowerBound) {
        this.blackCosmicRayEnergyVarianceFixedLowerBound = blackCosmicRayEnergyVarianceFixedLowerBound;
    }

    public float getBlackCosmicRayEnergyVarianceFixedUpperBound() {
        return blackCosmicRayEnergyVarianceFixedUpperBound;
    }

    public void setBlackCosmicRayEnergyVarianceFixedUpperBound(
        float blackCosmicRayEnergyVarianceFixedUpperBound) {
        this.blackCosmicRayEnergyVarianceFixedUpperBound = blackCosmicRayEnergyVarianceFixedUpperBound;
    }

    public float getBlackCosmicRayEnergyVarianceAdaptiveXFactor() {
        return blackCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public void setBlackCosmicRayEnergyVarianceAdaptiveXFactor(
        float blackCosmicRayEnergyVarianceAdaptiveXFactor) {
        this.blackCosmicRayEnergyVarianceAdaptiveXFactor = blackCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public float getBlackCosmicRayEnergySkewnessSmoothingFactor() {
        return blackCosmicRayEnergySkewnessSmoothingFactor;
    }

    public void setBlackCosmicRayEnergySkewnessSmoothingFactor(
        float blackCosmicRayEnergySkewnessSmoothingFactor) {
        this.blackCosmicRayEnergySkewnessSmoothingFactor = blackCosmicRayEnergySkewnessSmoothingFactor;
    }

    public float getBlackCosmicRayEnergySkewnessFixedLowerBound() {
        return blackCosmicRayEnergySkewnessFixedLowerBound;
    }

    public void setBlackCosmicRayEnergySkewnessFixedLowerBound(
        float blackCosmicRayEnergySkewnessFixedLowerBound) {
        this.blackCosmicRayEnergySkewnessFixedLowerBound = blackCosmicRayEnergySkewnessFixedLowerBound;
    }

    public float getBlackCosmicRayEnergySkewnessFixedUpperBound() {
        return blackCosmicRayEnergySkewnessFixedUpperBound;
    }

    public void setBlackCosmicRayEnergySkewnessFixedUpperBound(
        float blackCosmicRayEnergySkewnessFixedUpperBound) {
        this.blackCosmicRayEnergySkewnessFixedUpperBound = blackCosmicRayEnergySkewnessFixedUpperBound;
    }

    public float getBlackCosmicRayEnergySkewnessAdaptiveXFactor() {
        return blackCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public void setBlackCosmicRayEnergySkewnessAdaptiveXFactor(
        float blackCosmicRayEnergySkewnessAdaptiveXFactor) {
        this.blackCosmicRayEnergySkewnessAdaptiveXFactor = blackCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public float getBlackCosmicRayEnergyKurtosisSmoothingFactor() {
        return blackCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public void setBlackCosmicRayEnergyKurtosisSmoothingFactor(
        float blackCosmicRayEnergyKurtosisSmoothingFactor) {
        this.blackCosmicRayEnergyKurtosisSmoothingFactor = blackCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public float getBlackCosmicRayEnergyKurtosisFixedLowerBound() {
        return blackCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public void setBlackCosmicRayEnergyKurtosisFixedLowerBound(
        float blackCosmicRayEnergyKurtosisFixedLowerBound) {
        this.blackCosmicRayEnergyKurtosisFixedLowerBound = blackCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public float getBlackCosmicRayEnergyKurtosisFixedUpperBound() {
        return blackCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public void setBlackCosmicRayEnergyKurtosisFixedUpperBound(
        float blackCosmicRayEnergyKurtosisFixedUpperBound) {
        this.blackCosmicRayEnergyKurtosisFixedUpperBound = blackCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public float getBlackCosmicRayEnergyKurtosisAdaptiveXFactor() {
        return blackCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public void setBlackCosmicRayEnergyKurtosisAdaptiveXFactor(
        float blackCosmicRayEnergyKurtosisAdaptiveXFactor) {
        this.blackCosmicRayEnergyKurtosisAdaptiveXFactor = blackCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public float getMaskedSmearCosmicRayHitRateSmoothingFactor() {
        return maskedSmearCosmicRayHitRateSmoothingFactor;
    }

    public void setMaskedSmearCosmicRayHitRateSmoothingFactor(
        float maskedSmearCosmicRayHitRateSmoothingFactor) {
        this.maskedSmearCosmicRayHitRateSmoothingFactor = maskedSmearCosmicRayHitRateSmoothingFactor;
    }

    public float getMaskedSmearCosmicRayHitRateFixedLowerBound() {
        return maskedSmearCosmicRayHitRateFixedLowerBound;
    }

    public void setMaskedSmearCosmicRayHitRateFixedLowerBound(
        float maskedSmearCosmicRayHitRateFixedLowerBound) {
        this.maskedSmearCosmicRayHitRateFixedLowerBound = maskedSmearCosmicRayHitRateFixedLowerBound;
    }

    public float getMaskedSmearCosmicRayHitRateFixedUpperBound() {
        return maskedSmearCosmicRayHitRateFixedUpperBound;
    }

    public void setMaskedSmearCosmicRayHitRateFixedUpperBound(
        float maskedSmearCosmicRayHitRateFixedUpperBound) {
        this.maskedSmearCosmicRayHitRateFixedUpperBound = maskedSmearCosmicRayHitRateFixedUpperBound;
    }

    public float getMaskedSmearCosmicRayHitRateAdaptiveXFactor() {
        return maskedSmearCosmicRayHitRateAdaptiveXFactor;
    }

    public void setMaskedSmearCosmicRayHitRateAdaptiveXFactor(
        float maskedSmearCosmicRayHitRateAdaptiveXFactor) {
        this.maskedSmearCosmicRayHitRateAdaptiveXFactor = maskedSmearCosmicRayHitRateAdaptiveXFactor;
    }

    public float getMaskedSmearCosmicRayMeanEnergySmoothingFactor() {
        return maskedSmearCosmicRayMeanEnergySmoothingFactor;
    }

    public void setMaskedSmearCosmicRayMeanEnergySmoothingFactor(
        float maskedSmearCosmicRayMeanEnergySmoothingFactor) {
        this.maskedSmearCosmicRayMeanEnergySmoothingFactor = maskedSmearCosmicRayMeanEnergySmoothingFactor;
    }

    public float getMaskedSmearCosmicRayMeanEnergyFixedLowerBound() {
        return maskedSmearCosmicRayMeanEnergyFixedLowerBound;
    }

    public void setMaskedSmearCosmicRayMeanEnergyFixedLowerBound(
        float maskedSmearCosmicRayMeanEnergyFixedLowerBound) {
        this.maskedSmearCosmicRayMeanEnergyFixedLowerBound = maskedSmearCosmicRayMeanEnergyFixedLowerBound;
    }

    public float getMaskedSmearCosmicRayMeanEnergyFixedUpperBound() {
        return maskedSmearCosmicRayMeanEnergyFixedUpperBound;
    }

    public void setMaskedSmearCosmicRayMeanEnergyFixedUpperBound(
        float maskedSmearCosmicRayMeanEnergyFixedUpperBound) {
        this.maskedSmearCosmicRayMeanEnergyFixedUpperBound = maskedSmearCosmicRayMeanEnergyFixedUpperBound;
    }

    public float getMaskedSmearCosmicRayMeanEnergyAdaptiveXFactor() {
        return maskedSmearCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public void setMaskedSmearCosmicRayMeanEnergyAdaptiveXFactor(
        float maskedSmearCosmicRayMeanEnergyAdaptiveXFactor) {
        this.maskedSmearCosmicRayMeanEnergyAdaptiveXFactor = maskedSmearCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public float getMaskedSmearCosmicRayEnergyVarianceSmoothingFactor() {
        return maskedSmearCosmicRayEnergyVarianceSmoothingFactor;
    }

    public void setMaskedSmearCosmicRayEnergyVarianceSmoothingFactor(
        float maskedSmearCosmicRayEnergyVarianceSmoothingFactor) {
        this.maskedSmearCosmicRayEnergyVarianceSmoothingFactor = maskedSmearCosmicRayEnergyVarianceSmoothingFactor;
    }

    public float getMaskedSmearCosmicRayEnergyVarianceFixedLowerBound() {
        return maskedSmearCosmicRayEnergyVarianceFixedLowerBound;
    }

    public void setMaskedSmearCosmicRayEnergyVarianceFixedLowerBound(
        float maskedSmearCosmicRayEnergyVarianceFixedLowerBound) {
        this.maskedSmearCosmicRayEnergyVarianceFixedLowerBound = maskedSmearCosmicRayEnergyVarianceFixedLowerBound;
    }

    public float getMaskedSmearCosmicRayEnergyVarianceFixedUpperBound() {
        return maskedSmearCosmicRayEnergyVarianceFixedUpperBound;
    }

    public void setMaskedSmearCosmicRayEnergyVarianceFixedUpperBound(
        float maskedSmearCosmicRayEnergyVarianceFixedUpperBound) {
        this.maskedSmearCosmicRayEnergyVarianceFixedUpperBound = maskedSmearCosmicRayEnergyVarianceFixedUpperBound;
    }

    public float getMaskedSmearCosmicRayEnergyVarianceAdaptiveXFactor() {
        return maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public void setMaskedSmearCosmicRayEnergyVarianceAdaptiveXFactor(
        float maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor) {
        this.maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor = maskedSmearCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public float getMaskedSmearCosmicRayEnergySkewnessSmoothingFactor() {
        return maskedSmearCosmicRayEnergySkewnessSmoothingFactor;
    }

    public void setMaskedSmearCosmicRayEnergySkewnessSmoothingFactor(
        float maskedSmearCosmicRayEnergySkewnessSmoothingFactor) {
        this.maskedSmearCosmicRayEnergySkewnessSmoothingFactor = maskedSmearCosmicRayEnergySkewnessSmoothingFactor;
    }

    public float getMaskedSmearCosmicRayEnergySkewnessFixedLowerBound() {
        return maskedSmearCosmicRayEnergySkewnessFixedLowerBound;
    }

    public void setMaskedSmearCosmicRayEnergySkewnessFixedLowerBound(
        float maskedSmearCosmicRayEnergySkewnessFixedLowerBound) {
        this.maskedSmearCosmicRayEnergySkewnessFixedLowerBound = maskedSmearCosmicRayEnergySkewnessFixedLowerBound;
    }

    public float getMaskedSmearCosmicRayEnergySkewnessFixedUpperBound() {
        return maskedSmearCosmicRayEnergySkewnessFixedUpperBound;
    }

    public void setMaskedSmearCosmicRayEnergySkewnessFixedUpperBound(
        float maskedSmearCosmicRayEnergySkewnessFixedUpperBound) {
        this.maskedSmearCosmicRayEnergySkewnessFixedUpperBound = maskedSmearCosmicRayEnergySkewnessFixedUpperBound;
    }

    public float getMaskedSmearCosmicRayEnergySkewnessAdaptiveXFactor() {
        return maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public void setMaskedSmearCosmicRayEnergySkewnessAdaptiveXFactor(
        float maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor) {
        this.maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor = maskedSmearCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public float getMaskedSmearCosmicRayEnergyKurtosisSmoothingFactor() {
        return maskedSmearCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public void setMaskedSmearCosmicRayEnergyKurtosisSmoothingFactor(
        float maskedSmearCosmicRayEnergyKurtosisSmoothingFactor) {
        this.maskedSmearCosmicRayEnergyKurtosisSmoothingFactor = maskedSmearCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public float getMaskedSmearCosmicRayEnergyKurtosisFixedLowerBound() {
        return maskedSmearCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public void setMaskedSmearCosmicRayEnergyKurtosisFixedLowerBound(
        float maskedSmearCosmicRayEnergyKurtosisFixedLowerBound) {
        this.maskedSmearCosmicRayEnergyKurtosisFixedLowerBound = maskedSmearCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public float getMaskedSmearCosmicRayEnergyKurtosisFixedUpperBound() {
        return maskedSmearCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public void setMaskedSmearCosmicRayEnergyKurtosisFixedUpperBound(
        float maskedSmearCosmicRayEnergyKurtosisFixedUpperBound) {
        this.maskedSmearCosmicRayEnergyKurtosisFixedUpperBound = maskedSmearCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public float getMaskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor() {
        return maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public void setMaskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor(
        float maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor) {
        this.maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor = maskedSmearCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public float getVirtualSmearCosmicRayHitRateSmoothingFactor() {
        return virtualSmearCosmicRayHitRateSmoothingFactor;
    }

    public void setVirtualSmearCosmicRayHitRateSmoothingFactor(
        float virtualSmearCosmicRayHitRateSmoothingFactor) {
        this.virtualSmearCosmicRayHitRateSmoothingFactor = virtualSmearCosmicRayHitRateSmoothingFactor;
    }

    public float getVirtualSmearCosmicRayHitRateFixedLowerBound() {
        return virtualSmearCosmicRayHitRateFixedLowerBound;
    }

    public void setVirtualSmearCosmicRayHitRateFixedLowerBound(
        float virtualSmearCosmicRayHitRateFixedLowerBound) {
        this.virtualSmearCosmicRayHitRateFixedLowerBound = virtualSmearCosmicRayHitRateFixedLowerBound;
    }

    public float getVirtualSmearCosmicRayHitRateFixedUpperBound() {
        return virtualSmearCosmicRayHitRateFixedUpperBound;
    }

    public void setVirtualSmearCosmicRayHitRateFixedUpperBound(
        float virtualSmearCosmicRayHitRateFixedUpperBound) {
        this.virtualSmearCosmicRayHitRateFixedUpperBound = virtualSmearCosmicRayHitRateFixedUpperBound;
    }

    public float getVirtualSmearCosmicRayHitRateAdaptiveXFactor() {
        return virtualSmearCosmicRayHitRateAdaptiveXFactor;
    }

    public void setVirtualSmearCosmicRayHitRateAdaptiveXFactor(
        float virtualSmearCosmicRayHitRateAdaptiveXFactor) {
        this.virtualSmearCosmicRayHitRateAdaptiveXFactor = virtualSmearCosmicRayHitRateAdaptiveXFactor;
    }

    public float getVirtualSmearCosmicRayMeanEnergySmoothingFactor() {
        return virtualSmearCosmicRayMeanEnergySmoothingFactor;
    }

    public void setVirtualSmearCosmicRayMeanEnergySmoothingFactor(
        float virtualSmearCosmicRayMeanEnergySmoothingFactor) {
        this.virtualSmearCosmicRayMeanEnergySmoothingFactor = virtualSmearCosmicRayMeanEnergySmoothingFactor;
    }

    public float getVirtualSmearCosmicRayMeanEnergyFixedLowerBound() {
        return virtualSmearCosmicRayMeanEnergyFixedLowerBound;
    }

    public void setVirtualSmearCosmicRayMeanEnergyFixedLowerBound(
        float virtualSmearCosmicRayMeanEnergyFixedLowerBound) {
        this.virtualSmearCosmicRayMeanEnergyFixedLowerBound = virtualSmearCosmicRayMeanEnergyFixedLowerBound;
    }

    public float getVirtualSmearCosmicRayMeanEnergyFixedUpperBound() {
        return virtualSmearCosmicRayMeanEnergyFixedUpperBound;
    }

    public void setVirtualSmearCosmicRayMeanEnergyFixedUpperBound(
        float virtualSmearCosmicRayMeanEnergyFixedUpperBound) {
        this.virtualSmearCosmicRayMeanEnergyFixedUpperBound = virtualSmearCosmicRayMeanEnergyFixedUpperBound;
    }

    public float getVirtualSmearCosmicRayMeanEnergyAdaptiveXFactor() {
        return virtualSmearCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public void setVirtualSmearCosmicRayMeanEnergyAdaptiveXFactor(
        float virtualSmearCosmicRayMeanEnergyAdaptiveXFactor) {
        this.virtualSmearCosmicRayMeanEnergyAdaptiveXFactor = virtualSmearCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public float getVirtualSmearCosmicRayEnergyVarianceSmoothingFactor() {
        return virtualSmearCosmicRayEnergyVarianceSmoothingFactor;
    }

    public void setVirtualSmearCosmicRayEnergyVarianceSmoothingFactor(
        float virtualSmearCosmicRayEnergyVarianceSmoothingFactor) {
        this.virtualSmearCosmicRayEnergyVarianceSmoothingFactor = virtualSmearCosmicRayEnergyVarianceSmoothingFactor;
    }

    public float getVirtualSmearCosmicRayEnergyVarianceFixedLowerBound() {
        return virtualSmearCosmicRayEnergyVarianceFixedLowerBound;
    }

    public void setVirtualSmearCosmicRayEnergyVarianceFixedLowerBound(
        float virtualSmearCosmicRayEnergyVarianceFixedLowerBound) {
        this.virtualSmearCosmicRayEnergyVarianceFixedLowerBound = virtualSmearCosmicRayEnergyVarianceFixedLowerBound;
    }

    public float getVirtualSmearCosmicRayEnergyVarianceFixedUpperBound() {
        return virtualSmearCosmicRayEnergyVarianceFixedUpperBound;
    }

    public void setVirtualSmearCosmicRayEnergyVarianceFixedUpperBound(
        float virtualSmearCosmicRayEnergyVarianceFixedUpperBound) {
        this.virtualSmearCosmicRayEnergyVarianceFixedUpperBound = virtualSmearCosmicRayEnergyVarianceFixedUpperBound;
    }

    public float getVirtualSmearCosmicRayEnergyVarianceAdaptiveXFactor() {
        return virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public void setVirtualSmearCosmicRayEnergyVarianceAdaptiveXFactor(
        float virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor) {
        this.virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor = virtualSmearCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public float getVirtualSmearCosmicRayEnergySkewnessSmoothingFactor() {
        return virtualSmearCosmicRayEnergySkewnessSmoothingFactor;
    }

    public void setVirtualSmearCosmicRayEnergySkewnessSmoothingFactor(
        float virtualSmearCosmicRayEnergySkewnessSmoothingFactor) {
        this.virtualSmearCosmicRayEnergySkewnessSmoothingFactor = virtualSmearCosmicRayEnergySkewnessSmoothingFactor;
    }

    public float getVirtualSmearCosmicRayEnergySkewnessFixedLowerBound() {
        return virtualSmearCosmicRayEnergySkewnessFixedLowerBound;
    }

    public void setVirtualSmearCosmicRayEnergySkewnessFixedLowerBound(
        float virtualSmearCosmicRayEnergySkewnessFixedLowerBound) {
        this.virtualSmearCosmicRayEnergySkewnessFixedLowerBound = virtualSmearCosmicRayEnergySkewnessFixedLowerBound;
    }

    public float getVirtualSmearCosmicRayEnergySkewnessFixedUpperBound() {
        return virtualSmearCosmicRayEnergySkewnessFixedUpperBound;
    }

    public void setVirtualSmearCosmicRayEnergySkewnessFixedUpperBound(
        float virtualSmearCosmicRayEnergySkewnessFixedUpperBound) {
        this.virtualSmearCosmicRayEnergySkewnessFixedUpperBound = virtualSmearCosmicRayEnergySkewnessFixedUpperBound;
    }

    public float getVirtualSmearCosmicRayEnergySkewnessAdaptiveXFactor() {
        return virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public void setVirtualSmearCosmicRayEnergySkewnessAdaptiveXFactor(
        float virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor) {
        this.virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor = virtualSmearCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public float getVirtualSmearCosmicRayEnergyKurtosisSmoothingFactor() {
        return virtualSmearCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public void setVirtualSmearCosmicRayEnergyKurtosisSmoothingFactor(
        float virtualSmearCosmicRayEnergyKurtosisSmoothingFactor) {
        this.virtualSmearCosmicRayEnergyKurtosisSmoothingFactor = virtualSmearCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public float getVirtualSmearCosmicRayEnergyKurtosisFixedLowerBound() {
        return virtualSmearCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public void setVirtualSmearCosmicRayEnergyKurtosisFixedLowerBound(
        float virtualSmearCosmicRayEnergyKurtosisFixedLowerBound) {
        this.virtualSmearCosmicRayEnergyKurtosisFixedLowerBound = virtualSmearCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public float getVirtualSmearCosmicRayEnergyKurtosisFixedUpperBound() {
        return virtualSmearCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public void setVirtualSmearCosmicRayEnergyKurtosisFixedUpperBound(
        float virtualSmearCosmicRayEnergyKurtosisFixedUpperBound) {
        this.virtualSmearCosmicRayEnergyKurtosisFixedUpperBound = virtualSmearCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public float getVirtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor() {
        return virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public void setVirtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor(
        float virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor) {
        this.virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor = virtualSmearCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public float getTargetStarCosmicRayHitRateSmoothingFactor() {
        return targetStarCosmicRayHitRateSmoothingFactor;
    }

    public void setTargetStarCosmicRayHitRateSmoothingFactor(
        float targetStarCosmicRayHitRateSmoothingFactor) {
        this.targetStarCosmicRayHitRateSmoothingFactor = targetStarCosmicRayHitRateSmoothingFactor;
    }

    public float getTargetStarCosmicRayHitRateFixedLowerBound() {
        return targetStarCosmicRayHitRateFixedLowerBound;
    }

    public void setTargetStarCosmicRayHitRateFixedLowerBound(
        float targetStarCosmicRayHitRateFixedLowerBound) {
        this.targetStarCosmicRayHitRateFixedLowerBound = targetStarCosmicRayHitRateFixedLowerBound;
    }

    public float getTargetStarCosmicRayHitRateFixedUpperBound() {
        return targetStarCosmicRayHitRateFixedUpperBound;
    }

    public void setTargetStarCosmicRayHitRateFixedUpperBound(
        float targetStarCosmicRayHitRateFixedUpperBound) {
        this.targetStarCosmicRayHitRateFixedUpperBound = targetStarCosmicRayHitRateFixedUpperBound;
    }

    public float getTargetStarCosmicRayHitRateAdaptiveXFactor() {
        return targetStarCosmicRayHitRateAdaptiveXFactor;
    }

    public void setTargetStarCosmicRayHitRateAdaptiveXFactor(
        float targetStarCosmicRayHitRateAdaptiveXFactor) {
        this.targetStarCosmicRayHitRateAdaptiveXFactor = targetStarCosmicRayHitRateAdaptiveXFactor;
    }

    public float getTargetStarCosmicRayMeanEnergySmoothingFactor() {
        return targetStarCosmicRayMeanEnergySmoothingFactor;
    }

    public void setTargetStarCosmicRayMeanEnergySmoothingFactor(
        float targetStarCosmicRayMeanEnergySmoothingFactor) {
        this.targetStarCosmicRayMeanEnergySmoothingFactor = targetStarCosmicRayMeanEnergySmoothingFactor;
    }

    public float getTargetStarCosmicRayMeanEnergyFixedLowerBound() {
        return targetStarCosmicRayMeanEnergyFixedLowerBound;
    }

    public void setTargetStarCosmicRayMeanEnergyFixedLowerBound(
        float targetStarCosmicRayMeanEnergyFixedLowerBound) {
        this.targetStarCosmicRayMeanEnergyFixedLowerBound = targetStarCosmicRayMeanEnergyFixedLowerBound;
    }

    public float getTargetStarCosmicRayMeanEnergyFixedUpperBound() {
        return targetStarCosmicRayMeanEnergyFixedUpperBound;
    }

    public void setTargetStarCosmicRayMeanEnergyFixedUpperBound(
        float targetStarCosmicRayMeanEnergyFixedUpperBound) {
        this.targetStarCosmicRayMeanEnergyFixedUpperBound = targetStarCosmicRayMeanEnergyFixedUpperBound;
    }

    public float getTargetStarCosmicRayMeanEnergyAdaptiveXFactor() {
        return targetStarCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public void setTargetStarCosmicRayMeanEnergyAdaptiveXFactor(
        float targetStarCosmicRayMeanEnergyAdaptiveXFactor) {
        this.targetStarCosmicRayMeanEnergyAdaptiveXFactor = targetStarCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public float getTargetStarCosmicRayEnergyVarianceSmoothingFactor() {
        return targetStarCosmicRayEnergyVarianceSmoothingFactor;
    }

    public void setTargetStarCosmicRayEnergyVarianceSmoothingFactor(
        float targetStarCosmicRayEnergyVarianceSmoothingFactor) {
        this.targetStarCosmicRayEnergyVarianceSmoothingFactor = targetStarCosmicRayEnergyVarianceSmoothingFactor;
    }

    public float getTargetStarCosmicRayEnergyVarianceFixedLowerBound() {
        return targetStarCosmicRayEnergyVarianceFixedLowerBound;
    }

    public void setTargetStarCosmicRayEnergyVarianceFixedLowerBound(
        float targetStarCosmicRayEnergyVarianceFixedLowerBound) {
        this.targetStarCosmicRayEnergyVarianceFixedLowerBound = targetStarCosmicRayEnergyVarianceFixedLowerBound;
    }

    public float getTargetStarCosmicRayEnergyVarianceFixedUpperBound() {
        return targetStarCosmicRayEnergyVarianceFixedUpperBound;
    }

    public void setTargetStarCosmicRayEnergyVarianceFixedUpperBound(
        float targetStarCosmicRayEnergyVarianceFixedUpperBound) {
        this.targetStarCosmicRayEnergyVarianceFixedUpperBound = targetStarCosmicRayEnergyVarianceFixedUpperBound;
    }

    public float getTargetStarCosmicRayEnergyVarianceAdaptiveXFactor() {
        return targetStarCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public void setTargetStarCosmicRayEnergyVarianceAdaptiveXFactor(
        float targetStarCosmicRayEnergyVarianceAdaptiveXFactor) {
        this.targetStarCosmicRayEnergyVarianceAdaptiveXFactor = targetStarCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public float getTargetStarCosmicRayEnergySkewnessSmoothingFactor() {
        return targetStarCosmicRayEnergySkewnessSmoothingFactor;
    }

    public void setTargetStarCosmicRayEnergySkewnessSmoothingFactor(
        float targetStarCosmicRayEnergySkewnessSmoothingFactor) {
        this.targetStarCosmicRayEnergySkewnessSmoothingFactor = targetStarCosmicRayEnergySkewnessSmoothingFactor;
    }

    public float getTargetStarCosmicRayEnergySkewnessFixedLowerBound() {
        return targetStarCosmicRayEnergySkewnessFixedLowerBound;
    }

    public void setTargetStarCosmicRayEnergySkewnessFixedLowerBound(
        float targetStarCosmicRayEnergySkewnessFixedLowerBound) {
        this.targetStarCosmicRayEnergySkewnessFixedLowerBound = targetStarCosmicRayEnergySkewnessFixedLowerBound;
    }

    public float getTargetStarCosmicRayEnergySkewnessFixedUpperBound() {
        return targetStarCosmicRayEnergySkewnessFixedUpperBound;
    }

    public void setTargetStarCosmicRayEnergySkewnessFixedUpperBound(
        float targetStarCosmicRayEnergySkewnessFixedUpperBound) {
        this.targetStarCosmicRayEnergySkewnessFixedUpperBound = targetStarCosmicRayEnergySkewnessFixedUpperBound;
    }

    public float getTargetStarCosmicRayEnergySkewnessAdaptiveXFactor() {
        return targetStarCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public void setTargetStarCosmicRayEnergySkewnessAdaptiveXFactor(
        float targetStarCosmicRayEnergySkewnessAdaptiveXFactor) {
        this.targetStarCosmicRayEnergySkewnessAdaptiveXFactor = targetStarCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public float getTargetStarCosmicRayEnergyKurtosisSmoothingFactor() {
        return targetStarCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public void setTargetStarCosmicRayEnergyKurtosisSmoothingFactor(
        float targetStarCosmicRayEnergyKurtosisSmoothingFactor) {
        this.targetStarCosmicRayEnergyKurtosisSmoothingFactor = targetStarCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public float getTargetStarCosmicRayEnergyKurtosisFixedLowerBound() {
        return targetStarCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public void setTargetStarCosmicRayEnergyKurtosisFixedLowerBound(
        float targetStarCosmicRayEnergyKurtosisFixedLowerBound) {
        this.targetStarCosmicRayEnergyKurtosisFixedLowerBound = targetStarCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public float getTargetStarCosmicRayEnergyKurtosisFixedUpperBound() {
        return targetStarCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public void setTargetStarCosmicRayEnergyKurtosisFixedUpperBound(
        float targetStarCosmicRayEnergyKurtosisFixedUpperBound) {
        this.targetStarCosmicRayEnergyKurtosisFixedUpperBound = targetStarCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public float getTargetStarCosmicRayEnergyKurtosisAdaptiveXFactor() {
        return targetStarCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public void setTargetStarCosmicRayEnergyKurtosisAdaptiveXFactor(
        float targetStarCosmicRayEnergyKurtosisAdaptiveXFactor) {
        this.targetStarCosmicRayEnergyKurtosisAdaptiveXFactor = targetStarCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public float getBackgroundCosmicRayHitRateSmoothingFactor() {
        return backgroundCosmicRayHitRateSmoothingFactor;
    }

    public void setBackgroundCosmicRayHitRateSmoothingFactor(
        float backgroundCosmicRayHitRateSmoothingFactor) {
        this.backgroundCosmicRayHitRateSmoothingFactor = backgroundCosmicRayHitRateSmoothingFactor;
    }

    public float getBackgroundCosmicRayHitRateFixedLowerBound() {
        return backgroundCosmicRayHitRateFixedLowerBound;
    }

    public void setBackgroundCosmicRayHitRateFixedLowerBound(
        float backgroundCosmicRayHitRateFixedLowerBound) {
        this.backgroundCosmicRayHitRateFixedLowerBound = backgroundCosmicRayHitRateFixedLowerBound;
    }

    public float getBackgroundCosmicRayHitRateFixedUpperBound() {
        return backgroundCosmicRayHitRateFixedUpperBound;
    }

    public void setBackgroundCosmicRayHitRateFixedUpperBound(
        float backgroundCosmicRayHitRateFixedUpperBound) {
        this.backgroundCosmicRayHitRateFixedUpperBound = backgroundCosmicRayHitRateFixedUpperBound;
    }

    public float getBackgroundCosmicRayHitRateAdaptiveXFactor() {
        return backgroundCosmicRayHitRateAdaptiveXFactor;
    }

    public void setBackgroundCosmicRayHitRateAdaptiveXFactor(
        float backgroundCosmicRayHitRateAdaptiveXFactor) {
        this.backgroundCosmicRayHitRateAdaptiveXFactor = backgroundCosmicRayHitRateAdaptiveXFactor;
    }

    public float getBackgroundCosmicRayMeanEnergySmoothingFactor() {
        return backgroundCosmicRayMeanEnergySmoothingFactor;
    }

    public void setBackgroundCosmicRayMeanEnergySmoothingFactor(
        float backgroundCosmicRayMeanEnergySmoothingFactor) {
        this.backgroundCosmicRayMeanEnergySmoothingFactor = backgroundCosmicRayMeanEnergySmoothingFactor;
    }

    public float getBackgroundCosmicRayMeanEnergyFixedLowerBound() {
        return backgroundCosmicRayMeanEnergyFixedLowerBound;
    }

    public void setBackgroundCosmicRayMeanEnergyFixedLowerBound(
        float backgroundCosmicRayMeanEnergyFixedLowerBound) {
        this.backgroundCosmicRayMeanEnergyFixedLowerBound = backgroundCosmicRayMeanEnergyFixedLowerBound;
    }

    public float getBackgroundCosmicRayMeanEnergyFixedUpperBound() {
        return backgroundCosmicRayMeanEnergyFixedUpperBound;
    }

    public void setBackgroundCosmicRayMeanEnergyFixedUpperBound(
        float backgroundCosmicRayMeanEnergyFixedUpperBound) {
        this.backgroundCosmicRayMeanEnergyFixedUpperBound = backgroundCosmicRayMeanEnergyFixedUpperBound;
    }

    public float getBackgroundCosmicRayMeanEnergyAdaptiveXFactor() {
        return backgroundCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public void setBackgroundCosmicRayMeanEnergyAdaptiveXFactor(
        float backgroundCosmicRayMeanEnergyAdaptiveXFactor) {
        this.backgroundCosmicRayMeanEnergyAdaptiveXFactor = backgroundCosmicRayMeanEnergyAdaptiveXFactor;
    }

    public float getBackgroundCosmicRayEnergyVarianceSmoothingFactor() {
        return backgroundCosmicRayEnergyVarianceSmoothingFactor;
    }

    public void setBackgroundCosmicRayEnergyVarianceSmoothingFactor(
        float backgroundCosmicRayEnergyVarianceSmoothingFactor) {
        this.backgroundCosmicRayEnergyVarianceSmoothingFactor = backgroundCosmicRayEnergyVarianceSmoothingFactor;
    }

    public float getBackgroundCosmicRayEnergyVarianceFixedLowerBound() {
        return backgroundCosmicRayEnergyVarianceFixedLowerBound;
    }

    public void setBackgroundCosmicRayEnergyVarianceFixedLowerBound(
        float backgroundCosmicRayEnergyVarianceFixedLowerBound) {
        this.backgroundCosmicRayEnergyVarianceFixedLowerBound = backgroundCosmicRayEnergyVarianceFixedLowerBound;
    }

    public float getBackgroundCosmicRayEnergyVarianceFixedUpperBound() {
        return backgroundCosmicRayEnergyVarianceFixedUpperBound;
    }

    public void setBackgroundCosmicRayEnergyVarianceFixedUpperBound(
        float backgroundCosmicRayEnergyVarianceFixedUpperBound) {
        this.backgroundCosmicRayEnergyVarianceFixedUpperBound = backgroundCosmicRayEnergyVarianceFixedUpperBound;
    }

    public float getBackgroundCosmicRayEnergyVarianceAdaptiveXFactor() {
        return backgroundCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public void setBackgroundCosmicRayEnergyVarianceAdaptiveXFactor(
        float backgroundCosmicRayEnergyVarianceAdaptiveXFactor) {
        this.backgroundCosmicRayEnergyVarianceAdaptiveXFactor = backgroundCosmicRayEnergyVarianceAdaptiveXFactor;
    }

    public float getBackgroundCosmicRayEnergySkewnessSmoothingFactor() {
        return backgroundCosmicRayEnergySkewnessSmoothingFactor;
    }

    public void setBackgroundCosmicRayEnergySkewnessSmoothingFactor(
        float backgroundCosmicRayEnergySkewnessSmoothingFactor) {
        this.backgroundCosmicRayEnergySkewnessSmoothingFactor = backgroundCosmicRayEnergySkewnessSmoothingFactor;
    }

    public float getBackgroundCosmicRayEnergySkewnessFixedLowerBound() {
        return backgroundCosmicRayEnergySkewnessFixedLowerBound;
    }

    public void setBackgroundCosmicRayEnergySkewnessFixedLowerBound(
        float backgroundCosmicRayEnergySkewnessFixedLowerBound) {
        this.backgroundCosmicRayEnergySkewnessFixedLowerBound = backgroundCosmicRayEnergySkewnessFixedLowerBound;
    }

    public float getBackgroundCosmicRayEnergySkewnessFixedUpperBound() {
        return backgroundCosmicRayEnergySkewnessFixedUpperBound;
    }

    public void setBackgroundCosmicRayEnergySkewnessFixedUpperBound(
        float backgroundCosmicRayEnergySkewnessFixedUpperBound) {
        this.backgroundCosmicRayEnergySkewnessFixedUpperBound = backgroundCosmicRayEnergySkewnessFixedUpperBound;
    }

    public float getBackgroundCosmicRayEnergySkewnessAdaptiveXFactor() {
        return backgroundCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public void setBackgroundCosmicRayEnergySkewnessAdaptiveXFactor(
        float backgroundCosmicRayEnergySkewnessAdaptiveXFactor) {
        this.backgroundCosmicRayEnergySkewnessAdaptiveXFactor = backgroundCosmicRayEnergySkewnessAdaptiveXFactor;
    }

    public float getBackgroundCosmicRayEnergyKurtosisSmoothingFactor() {
        return backgroundCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public void setBackgroundCosmicRayEnergyKurtosisSmoothingFactor(
        float backgroundCosmicRayEnergyKurtosisSmoothingFactor) {
        this.backgroundCosmicRayEnergyKurtosisSmoothingFactor = backgroundCosmicRayEnergyKurtosisSmoothingFactor;
    }

    public float getBackgroundCosmicRayEnergyKurtosisFixedLowerBound() {
        return backgroundCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public void setBackgroundCosmicRayEnergyKurtosisFixedLowerBound(
        float backgroundCosmicRayEnergyKurtosisFixedLowerBound) {
        this.backgroundCosmicRayEnergyKurtosisFixedLowerBound = backgroundCosmicRayEnergyKurtosisFixedLowerBound;
    }

    public float getBackgroundCosmicRayEnergyKurtosisFixedUpperBound() {
        return backgroundCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public void setBackgroundCosmicRayEnergyKurtosisFixedUpperBound(
        float backgroundCosmicRayEnergyKurtosisFixedUpperBound) {
        this.backgroundCosmicRayEnergyKurtosisFixedUpperBound = backgroundCosmicRayEnergyKurtosisFixedUpperBound;
    }

    public float getBackgroundCosmicRayEnergyKurtosisAdaptiveXFactor() {
        return backgroundCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public void setBackgroundCosmicRayEnergyKurtosisAdaptiveXFactor(
        float backgroundCosmicRayEnergyKurtosisAdaptiveXFactor) {
        this.backgroundCosmicRayEnergyKurtosisAdaptiveXFactor = backgroundCosmicRayEnergyKurtosisAdaptiveXFactor;
    }

    public float getBrightnessSmoothingFactor() {
        return brightnessSmoothingFactor;
    }

    public void setBrightnessSmoothingFactor(float brightnessSmoothingFactor) {
        this.brightnessSmoothingFactor = brightnessSmoothingFactor;
    }

    public float getBrightnessFixedLowerBound() {
        return brightnessFixedLowerBound;
    }

    public void setBrightnessFixedLowerBound(float brightnessFixedLowerBound) {
        this.brightnessFixedLowerBound = brightnessFixedLowerBound;
    }

    public float getBrightnessFixedUpperBound() {
        return brightnessFixedUpperBound;
    }

    public void setBrightnessFixedUpperBound(float brightnessFixedUpperBound) {
        this.brightnessFixedUpperBound = brightnessFixedUpperBound;
    }

    public float getBrightnessAdaptiveXFactor() {
        return brightnessAdaptiveXFactor;
    }

    public void setBrightnessAdaptiveXFactor(float brightnessAdaptiveXFactor) {
        this.brightnessAdaptiveXFactor = brightnessAdaptiveXFactor;
    }

    public float getEncircledEnergySmoothingFactor() {
        return encircledEnergySmoothingFactor;
    }

    public void setEncircledEnergySmoothingFactor(
        float encircledEnergySmoothingFactor) {
        this.encircledEnergySmoothingFactor = encircledEnergySmoothingFactor;
    }

    public float getEncircledEnergyFixedLowerBound() {
        return encircledEnergyFixedLowerBound;
    }

    public void setEncircledEnergyFixedLowerBound(
        float encircledEnergyFixedLowerBound) {
        this.encircledEnergyFixedLowerBound = encircledEnergyFixedLowerBound;
    }

    public float getEncircledEnergyFixedUpperBound() {
        return encircledEnergyFixedUpperBound;
    }

    public void setEncircledEnergyFixedUpperBound(
        float encircledEnergyFixedUpperBound) {
        this.encircledEnergyFixedUpperBound = encircledEnergyFixedUpperBound;
    }

    public float getEncircledEnergyAdaptiveXFactor() {
        return encircledEnergyAdaptiveXFactor;
    }

    public void setEncircledEnergyAdaptiveXFactor(
        float encircledEnergyAdaptiveXFactor) {
        this.encircledEnergyAdaptiveXFactor = encircledEnergyAdaptiveXFactor;
    }

    public float getBackgroundLevelSmoothingFactor() {
        return backgroundLevelSmoothingFactor;
    }

    public void setBackgroundLevelSmoothingFactor(
        float backgroundLevelSmoothingFactor) {
        this.backgroundLevelSmoothingFactor = backgroundLevelSmoothingFactor;
    }

    public float getBackgroundLevelFixedLowerBound() {
        return backgroundLevelFixedLowerBound;
    }

    public void setBackgroundLevelFixedLowerBound(
        float backgroundLevelFixedLowerBound) {
        this.backgroundLevelFixedLowerBound = backgroundLevelFixedLowerBound;
    }

    public float getBackgroundLevelFixedUpperBound() {
        return backgroundLevelFixedUpperBound;
    }

    public void setBackgroundLevelFixedUpperBound(
        float backgroundLevelFixedUpperBound) {
        this.backgroundLevelFixedUpperBound = backgroundLevelFixedUpperBound;
    }

    public float getBackgroundLevelAdaptiveXFactor() {
        return backgroundLevelAdaptiveXFactor;
    }

    public void setBackgroundLevelAdaptiveXFactor(
        float backgroundLevelAdaptiveXFactor) {
        this.backgroundLevelAdaptiveXFactor = backgroundLevelAdaptiveXFactor;
    }

    public float getCentroidsMeanRowSmoothingFactor() {
        return centroidsMeanRowSmoothingFactor;
    }

    public void setCentroidsMeanRowSmoothingFactor(
        float centroidsMeanRowSmoothingFactor) {
        this.centroidsMeanRowSmoothingFactor = centroidsMeanRowSmoothingFactor;
    }

    public float getCentroidsMeanRowFixedLowerBound() {
        return centroidsMeanRowFixedLowerBound;
    }

    public void setCentroidsMeanRowFixedLowerBound(
        float centroidsMeanRowFixedLowerBound) {
        this.centroidsMeanRowFixedLowerBound = centroidsMeanRowFixedLowerBound;
    }

    public float getCentroidsMeanRowFixedUpperBound() {
        return centroidsMeanRowFixedUpperBound;
    }

    public void setCentroidsMeanRowFixedUpperBound(
        float centroidsMeanRowFixedUpperBound) {
        this.centroidsMeanRowFixedUpperBound = centroidsMeanRowFixedUpperBound;
    }

    public float getCentroidsMeanRowAdaptiveXFactor() {
        return centroidsMeanRowAdaptiveXFactor;
    }

    public void setCentroidsMeanRowAdaptiveXFactor(
        float centroidsMeanRowAdaptiveXFactor) {
        this.centroidsMeanRowAdaptiveXFactor = centroidsMeanRowAdaptiveXFactor;
    }

    public float getCentroidsMeanColumnSmoothingFactor() {
        return centroidsMeanColumnSmoothingFactor;
    }

    public void setCentroidsMeanColumnSmoothingFactor(
        float centroidsMeanColumnSmoothingFactor) {
        this.centroidsMeanColumnSmoothingFactor = centroidsMeanColumnSmoothingFactor;
    }

    public float getCentroidsMeanColumnFixedLowerBound() {
        return centroidsMeanColumnFixedLowerBound;
    }

    public void setCentroidsMeanColumnFixedLowerBound(
        float centroidsMeanColumnFixedLowerBound) {
        this.centroidsMeanColumnFixedLowerBound = centroidsMeanColumnFixedLowerBound;
    }

    public float getCentroidsMeanColumnFixedUpperBound() {
        return centroidsMeanColumnFixedUpperBound;
    }

    public void setCentroidsMeanColumnFixedUpperBound(
        float centroidsMeanColumnFixedUpperBound) {
        this.centroidsMeanColumnFixedUpperBound = centroidsMeanColumnFixedUpperBound;
    }

    public float getCentroidsMeanColumnAdaptiveXFactor() {
        return centroidsMeanColumnAdaptiveXFactor;
    }

    public void setCentroidsMeanColumnAdaptiveXFactor(
        float centroidsMeanColumnAdaptiveXFactor) {
        this.centroidsMeanColumnAdaptiveXFactor = centroidsMeanColumnAdaptiveXFactor;
    }

    public float getPlateScaleSmoothingFactor() {
        return plateScaleSmoothingFactor;
    }

    public void setPlateScaleSmoothingFactor(float plateScaleSmoothingFactor) {
        this.plateScaleSmoothingFactor = plateScaleSmoothingFactor;
    }

    public float getPlateScaleFixedLowerBound() {
        return plateScaleFixedLowerBound;
    }

    public void setPlateScaleFixedLowerBound(float plateScaleFixedLowerBound) {
        this.plateScaleFixedLowerBound = plateScaleFixedLowerBound;
    }

    public float getPlateScaleFixedUpperBound() {
        return plateScaleFixedUpperBound;
    }

    public void setPlateScaleFixedUpperBound(float plateScaleFixedUpperBound) {
        this.plateScaleFixedUpperBound = plateScaleFixedUpperBound;
    }

    public float getPlateScaleAdaptiveXFactor() {
        return plateScaleAdaptiveXFactor;
    }

    public void setPlateScaleAdaptiveXFactor(float plateScaleAdaptiveXFactor) {
        this.plateScaleAdaptiveXFactor = plateScaleAdaptiveXFactor;
    }

    public float getCdppExpectedSmoothingFactor() {
        return cdppExpectedSmoothingFactor;
    }

    public void setCdppExpectedSmoothingFactor(float cdppExpectedSmoothingFactor) {
        this.cdppExpectedSmoothingFactor = cdppExpectedSmoothingFactor;
    }

    public float getCdppExpectedFixedLowerBound() {
        return cdppExpectedFixedLowerBound;
    }

    public void setCdppExpectedFixedLowerBound(float cdppExpectedFixedLowerBound) {
        this.cdppExpectedFixedLowerBound = cdppExpectedFixedLowerBound;
    }

    public float getCdppExpectedFixedUpperBound() {
        return cdppExpectedFixedUpperBound;
    }

    public void setCdppExpectedFixedUpperBound(float cdppExpectedFixedUpperBound) {
        this.cdppExpectedFixedUpperBound = cdppExpectedFixedUpperBound;
    }

    public float getCdppExpectedAdaptiveXFactor() {
        return cdppExpectedAdaptiveXFactor;
    }

    public void setCdppExpectedAdaptiveXFactor(float cdppExpectedAdaptiveXFactor) {
        this.cdppExpectedAdaptiveXFactor = cdppExpectedAdaptiveXFactor;
    }

    public float getCdppMeasuredSmoothingFactor() {
        return cdppMeasuredSmoothingFactor;
    }

    public void setCdppMeasuredSmoothingFactor(float cdppMeasuredSmoothingFactor) {
        this.cdppMeasuredSmoothingFactor = cdppMeasuredSmoothingFactor;
    }

    public float getCdppMeasuredFixedLowerBound() {
        return cdppMeasuredFixedLowerBound;
    }

    public void setCdppMeasuredFixedLowerBound(float cdppMeasuredFixedLowerBound) {
        this.cdppMeasuredFixedLowerBound = cdppMeasuredFixedLowerBound;
    }

    public float getCdppMeasuredFixedUpperBound() {
        return cdppMeasuredFixedUpperBound;
    }

    public void setCdppMeasuredFixedUpperBound(float cdppMeasuredFixedUpperBound) {
        this.cdppMeasuredFixedUpperBound = cdppMeasuredFixedUpperBound;
    }

    public float getCdppMeasuredAdaptiveXFactor() {
        return cdppMeasuredAdaptiveXFactor;
    }

    public void setCdppMeasuredAdaptiveXFactor(float cdppMeasuredAdaptiveXFactor) {
        this.cdppMeasuredAdaptiveXFactor = cdppMeasuredAdaptiveXFactor;
    }

    public float getCdppRatioSmoothingFactor() {
        return cdppRatioSmoothingFactor;
    }

    public void setCdppRatioSmoothingFactor(float cdppRatioSmoothingFactor) {
        this.cdppRatioSmoothingFactor = cdppRatioSmoothingFactor;
    }

    public float getCdppRatioFixedLowerBound() {
        return cdppRatioFixedLowerBound;
    }

    public void setCdppRatioFixedLowerBound(float cdppRatioFixedLowerBound) {
        this.cdppRatioFixedLowerBound = cdppRatioFixedLowerBound;
    }

    public float getCdppRatioFixedUpperBound() {
        return cdppRatioFixedUpperBound;
    }

    public void setCdppRatioFixedUpperBound(float cdppRatioFixedUpperBound) {
        this.cdppRatioFixedUpperBound = cdppRatioFixedUpperBound;
    }

    public float getCdppRatioAdaptiveXFactor() {
        return cdppRatioAdaptiveXFactor;
    }

    public void setCdppRatioAdaptiveXFactor(float cdppRatioAdaptiveXFactor) {
        this.cdppRatioAdaptiveXFactor = cdppRatioAdaptiveXFactor;
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    public boolean isPlottingEnabled() {
        return plottingEnabled;
    }

    public void setPlottingEnabled(boolean plottingEnabled) {
        this.plottingEnabled = plottingEnabled;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
