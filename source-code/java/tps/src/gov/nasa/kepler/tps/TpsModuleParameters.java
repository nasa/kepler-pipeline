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

package gov.nasa.kepler.tps;

import org.apache.commons.lang.ArrayUtils;

import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;
import gov.nasa.spiffy.common.pi.Parameters;

/**
 * Module parameters specific to TPS.  This class is a Java Bean so all
 * properties need getters and setters.
 * 
 * This class has never contained an equals() or hashCode() method.
 * It was decided to leave it this way, in case any client depends on
 * pointer equality.
 * 
 * @author Sean McCauliff
 * 
 */
@ProxyIgnoreStatics
public class TpsModuleParameters implements Persistable, Parameters {

    private int debugLevel = 0;

    /** The time periods to calculate CDPP. */
    private float[] requiredTrialTransitPulseInHours = 
                    ArrayUtils.EMPTY_FLOAT_ARRAY;

    private float searchPeriodStepControlFactor;
    
    private float varianceWindowLengthMultiplier;
    private float minimumSearchPeriodInDays;
    private float searchTransitThreshold;

    private float maximumSearchPeriodInDays;
    private String waveletFamily = "";
    private int waveletFilterLength ;
    /** When true tps-matlab should use the TPS-lite processing path else it
     * should do TPS-full.
     */
    private boolean tpsLiteEnabled;
    private int superResolutionFactor;
    private float deemphasizePeriodAfterSafeModeInDays;
    private int deemphasizePeriodAfterTweakInCadences;

    private float minTrialTransitPulseInHours;
    private float maxTrialTransitPulseInHours;
    private float searchTrialTransitPulseDurationStepControlFactor;
    private int   maxFoldingsInPeriodSearch;
    private boolean performQuarterStitching;
    
    private float pixelSensitivityDropoutThreshold;
    private int clusterProximity;
    private float medfiltWindowLengthDays;
    private float medfiltStandoffDays;
    
    private float robustStatisticThreshold;
    private float robustWeightGappingThreshold;
    private float robustStatisticConvergenceTolerance;
    
    
    private int minSesInMesCount; 
    private float maxDutyCycle;
    private float maxPeriodParameter;
    private boolean applyAttitudeTweakCorrection;
    private float chiSquare2Threshold; // float, default 6.4
    private int maxRemovedFeatureCount; // int, default 1
    private boolean deweightReactionWheelZeroCrossingCadences;
    private int maxFoldingLoopCount;
    private float weakSecondaryPeakRangeMultiplier;
    private boolean usePolyFitTransitModel;
    
    private boolean positiveOutlierHaircutEnabled;
    
    private float looperMaxWallTimeFraction;
    private float chiSquareGofThreshold; 
    private float bootstrapGaussianEquivalentThreshold;
    
    private boolean performWeakSecondaryTest;
    
    private float bootstrapLowMesCutoff;
    private float bootstrapThresholdReductionFactor;

    private boolean noiseEstimationByQuarterEnabled;
    private float positiveOutlierHaircutThreshold;
    
    private double maxSesInMesStatisticThreshold;
    private double maxSesInMesStatisticPeriodCutoff;
    
    private int vetoDiagnosticsMaxNumIterationsToRecord;
    
    public float getMesHistogramMinMes() {
        return mesHistogramMinMes;
    }


    public void setMesHistogramMinMes(float mesHistogramMinMes) {
        this.mesHistogramMinMes = mesHistogramMinMes;
    }


    public float getMesHistogramMaxMes() {
        return mesHistogramMaxMes;
    }


    public void setMesHistogramMaxMes(float mesHistogramMaxMes) {
        this.mesHistogramMaxMes = mesHistogramMaxMes;
    }


    public float getMesHistogramBinSize() {
        return mesHistogramBinSize;
    }


    public void setMesHistogramBinSize(float mesHistogramBinSize) {
        this.mesHistogramBinSize = mesHistogramBinSize;
    }

    private float mesHistogramMinMes; //(float, default value of -10)
    private float mesHistogramMaxMes; //(float, default value of 20)
    private float mesHistogramBinSize; //(float, default value of 0.2) 
    
    public TpsModuleParameters() {

    }

    
    public TpsType tpsType() {
        return isTpsLiteEnabled() ? TpsType.TPS_LITE : TpsType.TPS_FULL;
    }
    
    public float getRobustStatisticThreshold() {
        return robustStatisticThreshold;
    }

    public void setRobustStatisticThreshold(float robustStatisticThreshold) {
        this.robustStatisticThreshold = robustStatisticThreshold;
    }


    public float getRobustWeightGappingThreshold() {
        return robustWeightGappingThreshold;
    }

    public void setRobustWeightGappingThreshold(float robustWeightGappingThreshold) {
        this.robustWeightGappingThreshold = robustWeightGappingThreshold;
    }

    public float getPixelSensitivityDropoutThreshold() {
        return pixelSensitivityDropoutThreshold;
    }

    public void setPixelSensitivityDropoutThreshold(float pixelSensitivityDropoutThreshold) {
        this.pixelSensitivityDropoutThreshold = pixelSensitivityDropoutThreshold;
    }

    public int getClusterProximity() {
        return clusterProximity;
    }

    public void setClusterProximity(int clusterProximity) {
        this.clusterProximity = clusterProximity;
    }

    public float getMedfiltWindowLengthDays() {
        return medfiltWindowLengthDays;
    }

    public void setMedfiltWindowLengthDays(float medfiltWindowLengthDays) {
        this.medfiltWindowLengthDays = medfiltWindowLengthDays;
    }

    public float getMedfiltStandoffDays() {
        return medfiltStandoffDays;
    }

    public void setMedfiltStandoffDays(float medfiltStandoffDays) {
        this.medfiltStandoffDays = medfiltStandoffDays;
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    public float[] getRequiredTrialTransitPulseInHours() {
        return requiredTrialTransitPulseInHours;
    }

    public void setRequiredTrialTransitPulseInHours(float[] trialTransitPulseInHours) {
        this.requiredTrialTransitPulseInHours = trialTransitPulseInHours;
    }

    public float getVarianceWindowLengthMultiplier() {
        return varianceWindowLengthMultiplier;
    }

    public void setVarianceWindowLengthMultiplier(
        float varianceWindowLengthMultiplier) {
        this.varianceWindowLengthMultiplier = varianceWindowLengthMultiplier;
    }

    public float getSearchTransitThreshold() {
        return searchTransitThreshold;
    }

    public void setSearchTransitThreshold(float searchTransitThreshold) {
        this.searchTransitThreshold = searchTransitThreshold;
    }

    public boolean isTpsLiteEnabled() {
        return tpsLiteEnabled;
    }

    public void setTpsLiteEnabled(boolean tpsLiteEnabled) {
        this.tpsLiteEnabled = tpsLiteEnabled;
    }

    public float getSearchPeriodStepControlFactor() {
        return searchPeriodStepControlFactor;
    }

    public void setSearchPeriodStepControlFactor(
        float searchPeriodStepControlFactor) {
        this.searchPeriodStepControlFactor = searchPeriodStepControlFactor;
    }

    public float getMinimumSearchPeriodInDays() {
        return minimumSearchPeriodInDays;
    }

    public void setMinimumSearchPeriodInDays(float minimumSearchPeriodInDays) {
        this.minimumSearchPeriodInDays = minimumSearchPeriodInDays;
    }

    public String getWaveletFamily() {
        return waveletFamily;
    }

    public void setWaveletFamily(String waveletFamily) {
        this.waveletFamily = waveletFamily;
    }

    public float getMaximumSearchPeriodInDays() {
        return maximumSearchPeriodInDays;
    }

    public void setMaximumSearchPeriodInDays(float maximumSearchPeriodInDays) {
        this.maximumSearchPeriodInDays = maximumSearchPeriodInDays;
    }

    public int getWaveletFilterLength() {
        return waveletFilterLength;
    }

    public void setWaveletFilterLength(int waveletFilterLength) {
        this.waveletFilterLength = waveletFilterLength;
    }

    public int getSuperResolutionFactor() {
        return superResolutionFactor;
    }

    public void setSuperResolutionFactor(int superResolutionFactor) {
        this.superResolutionFactor = superResolutionFactor;
    }

    public float getDeemphasizePeriodAfterSafeModeInDays() {
        return deemphasizePeriodAfterSafeModeInDays;
    }

    public void setDeemphasizePeriodAfterSafeModeInDays(
        float deemphasizePeriodAfterSafeModeInDays) {
        this.deemphasizePeriodAfterSafeModeInDays = deemphasizePeriodAfterSafeModeInDays;
    }

    public int getDeemphasizePeriodAfterTweakInCadences() {
        return deemphasizePeriodAfterTweakInCadences;
    }

    public void setDeemphasizePeriodAfterTweakInCadences(
        int deemphasizePeriodAfterTweakInCadences) {
        this.deemphasizePeriodAfterTweakInCadences = deemphasizePeriodAfterTweakInCadences;
    }

    public float getMinTrialTransitPulseInHours() {
        return minTrialTransitPulseInHours;
    }

    public void setMinTrialTransitPulseInHours(float minTrialTransitPulseInHours) {
        this.minTrialTransitPulseInHours = minTrialTransitPulseInHours;
    }

    public float getMaxTrialTransitPulseInHours() {
        return maxTrialTransitPulseInHours;
    }

    public void setMaxTrialTransitPulseInHours(float maxTrialTransitPulseInHours) {
        this.maxTrialTransitPulseInHours = maxTrialTransitPulseInHours;
    }

    public float getSearchTrialTransitPulseDurationStepControlFactor() {
        return searchTrialTransitPulseDurationStepControlFactor;
    }

    public void setSearchTrialTransitPulseDurationStepControlFactor(
        float searchTrialTransitPulseDurationStepControlFactor) {
        this.searchTrialTransitPulseDurationStepControlFactor = searchTrialTransitPulseDurationStepControlFactor;
    }

    public int getMaxFoldingsInPeriodSearch() {
        return maxFoldingsInPeriodSearch;
    }

    public void setMaxFoldingsInPeriodSearch(int maxFoldingsInPeriodSearch) {
        this.maxFoldingsInPeriodSearch = maxFoldingsInPeriodSearch;
    }

    public boolean isPerformQuarterStitching() {
        return performQuarterStitching;
    }

    public void setPerformQuarterStitching(boolean performQuarterStitching) {
        this.performQuarterStitching = performQuarterStitching;
    }

    public float getRobustStatisticConvergenceTolerance() {
        return robustStatisticConvergenceTolerance;
    }


    public void setRobustStatisticConvergenceTolerance(float robustStatisticConvergenceTolerance) {
        this.robustStatisticConvergenceTolerance = robustStatisticConvergenceTolerance;
    }


    public int getMinSesInMesCount() {
        return minSesInMesCount;
    }

    public void setMinSesInMesCount(int minSesInMesCount) {
        this.minSesInMesCount = minSesInMesCount;
    }

    public boolean isApplyAttitudeTweakCorrection() {
        return applyAttitudeTweakCorrection;
    }


    public void setApplyAttitudeTweakCorrection(boolean applyAttitudeTweakCorrection) {
        this.applyAttitudeTweakCorrection = applyAttitudeTweakCorrection;
    }


    public float getMaxDutyCycle() {
        return maxDutyCycle;
    }


    public void setMaxDutyCycle(float maxDutyCycle) {
        this.maxDutyCycle = maxDutyCycle;
    }

    public float getChiSquare2Threshold() {
        return chiSquare2Threshold;
    }

    public void setChiSquare2Threshold(float chiSquare2Threshold) {
        this.chiSquare2Threshold = chiSquare2Threshold;
    }

    public int getMaxRemovedFeatureCount() {
        return maxRemovedFeatureCount;
    }

    public void setMaxRemovedFeatureCount(int maxRemovedFeatureCount) {
        this.maxRemovedFeatureCount = maxRemovedFeatureCount;
    }

    public boolean isDeweightReactionWheelZeroCrossingCadences() {
        return deweightReactionWheelZeroCrossingCadences;
    }


    public void setDeweightReactionWheelZeroCrossingCadences(
            boolean deweightReactionWheelZeroCrossingCadences) {
        this.deweightReactionWheelZeroCrossingCadences = deweightReactionWheelZeroCrossingCadences;
    }

    public int getMaxFoldingLoopCount() {
        return maxFoldingLoopCount;
    }

    public void setMaxFoldingLoopCount(int maxFoldingLoopCount) {
        this.maxFoldingLoopCount = maxFoldingLoopCount;
    }


    public float getWeakSecondaryPeakRangeMultiplier() {
        return weakSecondaryPeakRangeMultiplier;
    }


    public void setWeakSecondaryPeakRangeMultiplier(
            float weakSecondaryPeakRangeMultiplier) {
        this.weakSecondaryPeakRangeMultiplier = weakSecondaryPeakRangeMultiplier;
    }


    public boolean isUsePolyFitTransitModel() {
        return usePolyFitTransitModel;
    }


    public void setUsePolyFitTransitModel(boolean usePolyFitTransitModel) {
        this.usePolyFitTransitModel = usePolyFitTransitModel;
    }


    public boolean isPositiveOutlierHaircutEnabled() {
        return positiveOutlierHaircutEnabled;
    }


    public void setPositiveOutlierHaircutEnabled(
            boolean positiveOutlierHaircutEnabled) {
        this.positiveOutlierHaircutEnabled = positiveOutlierHaircutEnabled;
    }


    public float getLooperMaxWallTimeFraction() {
        return looperMaxWallTimeFraction;
    }


    public void setLooperMaxWallTimeFraction(float looperMaxWallTimeFraction) {
        this.looperMaxWallTimeFraction = looperMaxWallTimeFraction;
    }


    public float getMaxPeriodParameter() {
        return maxPeriodParameter;
    }


    public void setMaxPeriodParameter(float maxPeriodParameter) {
        this.maxPeriodParameter = maxPeriodParameter;
    }
    

    public float getChiSquareGofThreshold() {
        return chiSquareGofThreshold;
    }


    public void setChiSquareGofThreshold(float chiSquareGofThreshold) {
        this.chiSquareGofThreshold = chiSquareGofThreshold;
    }

    
    public float getBootstrapGaussianEquivalentThreshold() {
        return bootstrapGaussianEquivalentThreshold;
    }


    public void setBootstrapGaussianEquivalentThreshold(
            float bootstrapGaussianEquivalentThreshold) {
        this.bootstrapGaussianEquivalentThreshold = bootstrapGaussianEquivalentThreshold;
    }

    
    public boolean isPerformWeakSecondaryTest() {
        return performWeakSecondaryTest;
    }


    public void setPerformWeakSecondaryTest(boolean performWeakSecondaryTest) {
        this.performWeakSecondaryTest = performWeakSecondaryTest;
    }


    public float getBootstrapLowMesCutoff() {
        return bootstrapLowMesCutoff;
    }


    public void setBootstrapLowMesCutoff(float bootstrapLowMesCutoff) {
        this.bootstrapLowMesCutoff = bootstrapLowMesCutoff;
    }


    public float getBootstrapThresholdReductionFactor() {
        return bootstrapThresholdReductionFactor;
    }


    public void setBootstrapThresholdReductionFactor(
        float bootstrapThresholdReductionFactor) {
           this.bootstrapThresholdReductionFactor = bootstrapThresholdReductionFactor;
   }
    
    public boolean isNoiseEstimationByQuarterEnabled() {
        return noiseEstimationByQuarterEnabled;
    }
    
    public void setNoiseEstimationByQuarterEnabled(
        boolean noiseEstimationByQuarterEnabled ) {
        this.noiseEstimationByQuarterEnabled = noiseEstimationByQuarterEnabled;
    }
    
    public float getPositiveOutlierHaircutThreshold() {
        return positiveOutlierHaircutThreshold;
    }
    
    public void setpositiveOutlierHaircutThreshold(
        float positiveOutlierHaircutThreshold) {
        this.positiveOutlierHaircutThreshold = positiveOutlierHaircutThreshold;
    }
    
    public double getMaxSesInMesStatisticThreshold() {
        return maxSesInMesStatisticThreshold;
    }
    
    public void setMaxSesInMesStatisticThreshold(
        double maxSesInMesStatisticThreshold) {
        this.maxSesInMesStatisticThreshold = maxSesInMesStatisticThreshold;
    }
    
    public double getMaxSesInMesStatisticPeriodCutoff() {
        return maxSesInMesStatisticPeriodCutoff;
    }
    
    public void setMaxSesInMesStatisticPeriodCutoff(
        double maxSesInMesStatisticPeriodCutoff) {
        this.maxSesInMesStatisticPeriodCutoff = maxSesInMesStatisticPeriodCutoff;
    }
    
    public int getVetoDiagnosticsMaxNumIterationsToRecord() {
        return vetoDiagnosticsMaxNumIterationsToRecord;
    }
    
    public void setVetoDiagnosticsMaxNumIterationsToRecord(
        int vetoDiagnosticsMaxNumIterationsToRecord) {
        this.vetoDiagnosticsMaxNumIterationsToRecord =
            vetoDiagnosticsMaxNumIterationsToRecord;
    }
}
