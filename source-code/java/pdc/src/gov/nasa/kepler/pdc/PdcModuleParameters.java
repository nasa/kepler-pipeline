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

package gov.nasa.kepler.pdc;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ReflectionToStringBuilder;

public class PdcModuleParameters implements Parameters, Persistable {

    private int debugLevel;
    private float astrophysicalEventBridgeInDays;
    private float attitudeTweakBufferInDays;
    
    /**
     * e.g. "q0:q1,q2:q16,q17"
     */
    private String bandSplittingEnabledQuarters = "";
    
    /**
     * e.g. false,true,false
     */
    private boolean[] bandSplittingEnabled = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
    
    private float coarsePointBufferInDays;
    private float cotrendPerformanceLimit;
    private float cotrendRatioMaxTimeScaleInDays;
    private float earthPointBufferInDays;
    private String[] excludeTargetLabels = ArrayUtils.EMPTY_STRING_ARRAY;
    private int harmonicDetrendOrder;
    private boolean harmonicsRemovalEnabled;
    private boolean mapEnabled;
    private String mapSelectionMethod = "";
    private float mapSelectionMethodCutoff;
    private float mapSelectionMethodMultiscaleBias;
    private boolean stellarVariabilityRemoveEclipsingBinariesEnabled;
    private float thrusterSawtoothRemovalDetectionThreshold;
    private float thrusterSawtoothRemovalMaxDetectionThreshold;
    private int thrusterSawtoothRemovalMaxIterations;

    // SOC PDC2.8 inputs: median filter length.
    // samples in median filter for outlier detection
    private int medianFilterLength;

    private int minHarmonicsForDetrending;
    private int neighborhoodRadiusForAttitudeTweak;

    // normalize quarter to quarter variations in target flux if true
    private boolean normalizationEnabled;

    // SOC PDC2.4 inputs: outlier rejection threshold.
    // number of sigmas from mu to set outlier thresholds
    private float outlierThresholdXFactor;

    private int preMapIterations;

    // robust (vs. SVD LS) fit if true
    private boolean robustCotrendFitFlag;

    private float safeModeBufferInDays;
    private int stellarVariabilityDetrendOrder;
    private float stellarVariabilityThreshold;
    private float thermalRecoveryDurationInDays;

    private int variabilityDetrendPolyOrder;
    private boolean variabilityEpRecoveryMaskEnabled;
    private int variabilityEpRecoveryMaskWindow;

    public PdcModuleParameters() {
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    public float getAstrophysicalEventBridgeInDays() {
        return astrophysicalEventBridgeInDays;
    }

    public void setAstrophysicalEventBridgeInDays(
        float astrophysicalEventBridgeInDays) {
        this.astrophysicalEventBridgeInDays = astrophysicalEventBridgeInDays;
    }

    public float getAttitudeTweakBufferInDays() {
        return attitudeTweakBufferInDays;
    }

    public void setAttitudeTweakBufferInDays(float attitudeTweakBufferInDays) {
        this.attitudeTweakBufferInDays = attitudeTweakBufferInDays;
    }

    public String getBandSplittingEnabledQuarters() {
        return bandSplittingEnabledQuarters;
    }

    public void setBandSplittingEnabledQuarters(String bandSplittingEnabledQuarters) {
        this.bandSplittingEnabledQuarters = bandSplittingEnabledQuarters;
    }

    public boolean[] getBandSplittingEnabled() {
        return bandSplittingEnabled;
    }

    public void setBandSplittingEnabled(boolean[] bandSplittingEnabled) {
        this.bandSplittingEnabled = bandSplittingEnabled;
    }

    public float getCoarsePointBufferInDays() {
        return coarsePointBufferInDays;
    }

    public void setCoarsePointBufferInDays(float coarsePointBufferInDays) {
        this.coarsePointBufferInDays = coarsePointBufferInDays;
    }

    public float getCotrendPerformanceLimit() {
        return cotrendPerformanceLimit;
    }

    public void setCotrendPerformanceLimit(float cotrendPerformanceLimit) {
        this.cotrendPerformanceLimit = cotrendPerformanceLimit;
    }

    public float getCotrendRatioMaxTimeScaleInDays() {
        return cotrendRatioMaxTimeScaleInDays;
    }

    public void setCotrendRatioMaxTimeScaleInDays(
        float cotrendRatioMaxTimeScaleInDays) {
        this.cotrendRatioMaxTimeScaleInDays = cotrendRatioMaxTimeScaleInDays;
    }

    public float getEarthPointBufferInDays() {
        return earthPointBufferInDays;
    }

    public void setEarthPointBufferInDays(float earthPointBufferInDays) {
        this.earthPointBufferInDays = earthPointBufferInDays;
    }

    public boolean isStellarVariabilityRemoveEclipsingBinariesEnabled() {
        return stellarVariabilityRemoveEclipsingBinariesEnabled;
    }

    public void setStellarVariabilityRemoveEclipsingBinariesEnabled(
        boolean stellarVariabilityRemoveEclipsingBinariesEnabled) {
        this.stellarVariabilityRemoveEclipsingBinariesEnabled = stellarVariabilityRemoveEclipsingBinariesEnabled;
    }

    public String[] getExcludeTargetLabels() {
        return excludeTargetLabels;
    }

    public void setExcludeTargetLabels(String[] excludeTargetLabels) {
        this.excludeTargetLabels = excludeTargetLabels;
    }

    public int getHarmonicDetrendOrder() {
        return harmonicDetrendOrder;
    }

    public void setHarmonicDetrendOrder(int harmonicDetrendOrder) {
        this.harmonicDetrendOrder = harmonicDetrendOrder;
    }

    public boolean isHarmonicsRemovalEnabled() {
        return harmonicsRemovalEnabled;
    }

    public void setHarmonicsRemovalEnabled(boolean harmonicsRemovalEnabled) {
        this.harmonicsRemovalEnabled = harmonicsRemovalEnabled;
    }

    public boolean isMapEnabled() {
        return mapEnabled;
    }

    public void setMapEnabled(boolean mapEnabled) {
        this.mapEnabled = mapEnabled;
    }

    public String getMapSelectionMethod() {
        return mapSelectionMethod;
    }

    public void setMapSelectionMethod(String mapSelectionMethod) {
        this.mapSelectionMethod = mapSelectionMethod;
    }

    public float getMapSelectionMethodCutoff() {
        return mapSelectionMethodCutoff;
    }

    public void setMapSelectionMethodCutoff(float mapSelectionMethodCutoff) {
        this.mapSelectionMethodCutoff = mapSelectionMethodCutoff;
    }

    public float getMapSelectionMethodMultiscaleBias() {
        return mapSelectionMethodMultiscaleBias;
    }

    public void setMapSelectionMethodMultiscaleBias(
        float mapSelectionMethodMultiscaleBias) {
        this.mapSelectionMethodMultiscaleBias = mapSelectionMethodMultiscaleBias;
    }

    public int getMedianFilterLength() {
        return medianFilterLength;
    }

    public void setMedianFilterLength(int medianFilterLength) {
        this.medianFilterLength = medianFilterLength;
    }

    public int getMinHarmonicsForDetrending() {
        return minHarmonicsForDetrending;
    }

    public void setMinHarmonicsForDetrending(int minHarmonicsForDetrending) {
        this.minHarmonicsForDetrending = minHarmonicsForDetrending;
    }

    public int getNeighborhoodRadiusForAttitudeTweak() {
        return neighborhoodRadiusForAttitudeTweak;
    }

    public void setNeighborhoodRadiusForAttitudeTweak(
        int neighborhoodRadiusForAttitudeTweak) {
        this.neighborhoodRadiusForAttitudeTweak = neighborhoodRadiusForAttitudeTweak;
    }

    public boolean isNormalizationEnabled() {
        return normalizationEnabled;
    }

    public void setNormalizationEnabled(boolean normalizationEnabled) {
        this.normalizationEnabled = normalizationEnabled;
    }

    public float getOutlierThresholdXFactor() {
        return outlierThresholdXFactor;
    }

    public void setOutlierThresholdXFactor(float outlierThresholdXFactor) {
        this.outlierThresholdXFactor = outlierThresholdXFactor;
    }

    public int getPreMapIterations() {
        return preMapIterations;
    }

    public void setPreMapIterations(int preMapIterations) {
        this.preMapIterations = preMapIterations;
    }

    public boolean isRobustCotrendFitFlag() {
        return robustCotrendFitFlag;
    }

    public void setRobustCotrendFitFlag(boolean robustCotrendFitFlag) {
        this.robustCotrendFitFlag = robustCotrendFitFlag;
    }

    public float getSafeModeBufferInDays() {
        return safeModeBufferInDays;
    }

    public void setSafeModeBufferInDays(float safeModeBufferInDays) {
        this.safeModeBufferInDays = safeModeBufferInDays;
    }

    public int getStellarVariabilityDetrendOrder() {
        return stellarVariabilityDetrendOrder;
    }

    public void setStellarVariabilityDetrendOrder(
        int stellarVariabilityDetrendOrder) {
        this.stellarVariabilityDetrendOrder = stellarVariabilityDetrendOrder;
    }

    public float getStellarVariabilityThreshold() {
        return stellarVariabilityThreshold;
    }

    public void setStellarVariabilityThreshold(float stellarVariabilityThreshold) {
        this.stellarVariabilityThreshold = stellarVariabilityThreshold;
    }

    public float getThermalRecoveryDurationInDays() {
        return thermalRecoveryDurationInDays;
    }

    public void setThermalRecoveryDurationInDays(
        float thermalRecoveryDurationInDays) {
        this.thermalRecoveryDurationInDays = thermalRecoveryDurationInDays;
    }

    public int getVariabilityDetrendPolyOrder() {
        return variabilityDetrendPolyOrder;
    }

    public void setVariabilityDetrendPolyOrder(int variabilityDetrendPolyOrder) {
        this.variabilityDetrendPolyOrder = variabilityDetrendPolyOrder;
    }

    public boolean isVariabilityEpRecoveryMaskEnabled() {
        return variabilityEpRecoveryMaskEnabled;
    }

    public void setVariabilityEpRecoveryMaskEnabled(
        boolean variabilityEpRecoveryMaskEnabled) {
        this.variabilityEpRecoveryMaskEnabled = variabilityEpRecoveryMaskEnabled;
    }

    public int getVariabilityEpRecoveryMaskWindow() {
        return variabilityEpRecoveryMaskWindow;
    }

    public void setVariabilityEpRecoveryMaskWindow(
        int variabilityEpRecoveryMaskWindow) {
        this.variabilityEpRecoveryMaskWindow = variabilityEpRecoveryMaskWindow;
    }
    
    public float getThrusterSawtoothRemovalDetectionThreshold() {
        return thrusterSawtoothRemovalDetectionThreshold;
    }
    
    public void setThrusterSawtoothRemovalDetectionThreshold(
        float thrusterSawtoothRemovalDetectionThreshold) {
        this.thrusterSawtoothRemovalDetectionThreshold =
            thrusterSawtoothRemovalDetectionThreshold;
    }
    
    public float getThrusterSawtoothRemovalMaxDetectionThreshold() {
        return thrusterSawtoothRemovalMaxDetectionThreshold;
    }
    
    public void setThrusterSawtoothRemovalMaxDetectionThreshold(
        float thrusterSawtoothRemovalMaxDetectionThreshold) {
        this.thrusterSawtoothRemovalMaxDetectionThreshold =
            thrusterSawtoothRemovalMaxDetectionThreshold;
    }
    
    public int getThrusterSawtoothRemovalMaxIterations() {
        return thrusterSawtoothRemovalMaxIterations;
    }
    
    public void setThrusterSawtoothRemovalMaxIterations(
        int thrusterSawtoothRemovalMaxIterations) {
        this.thrusterSawtoothRemovalMaxIterations =
            thrusterSawtoothRemovalMaxIterations;
    }
}
