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

package gov.nasa.kepler.pa;

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnore;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Configuration parameters for PA.
 * 
 * @author Forrest Girouard
 * 
 */
public class PaModuleParameters implements Parameters, Persistable {

    /**
     * Debugging flag used by the algorithm.
     */
    private int debugLevel;

    /**
     * Clean cosmic rays when value is true.
     */
    private boolean cosmicRayCleaningEnabled;

    /**
     * True iff PRF-based centroiding is enabled for non-PPA targets.
     */
    private boolean targetPrfCentroidingEnabled;

    /**
     * True iff PRF-based centroiding is enabled for PPA targets.
     */
    private boolean ppaTargetPrfCentroidingEnabled;

    /**
     * Perform optimal aperture photometry instead of simply aperture photometry
     * when value is true.
     */
    private boolean oapEnabled;

    /**
     * True iff injecting simulated transits.
     */
    private boolean simulatedTransitsEnabled;

    private float brightRobustThreshold;

    private int minimumBrightTargets;

    private float madThresholdForCentroidOutliers;

    private float thresholdMultiplierForPositiveCentroidOutliers;

    private int stellarVariabilityDetrendOrder;

    private float stellarVariabilityThreshold;

    private float reactionWheelMedianFilterLength;

    private boolean discretePrfCentroidingEnabled;

    private int discretePrfOversampleFactor;

    private boolean onlyProcessPpaTargetsEnabled;

    private boolean motionBlobsInputEnabled;

    private boolean rollingBandContaminationFlagsEnabled;

    private boolean removeMedianSimulatedFlux;

    private boolean paCoaEnabled;

    private boolean k2TrimAperturesEnabled;

    private float k2TrimRadiusInPrfWidths;

    private int k2TrimMinSizeInPixels;

    private boolean k2GapIfNotFinePntData;

    private boolean k2GapPreTweakData;
    
    /**
     * Repetitions are not allowed. Order is not important. (It is a set.)
     * Each element must be an element of the set of test pulse durations.
     * (It is a subset.)
     */
    private int[] testPulseDurations = ArrayUtils.EMPTY_INT_ARRAY;
    
    @ProxyIgnore
    private int maxReadFsIds = 6000;

    /**
     * Note that this can never be less than the number of pixel samples in a
     * complete target.
     */
    @ProxyIgnore
    private int maxPixelSamples = 25000000;

    /**
     * Default constructor, required by {@link Persistable} interface.
     */
    public PaModuleParameters() {
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public float getBrightRobustThreshold() {
        return brightRobustThreshold;
    }

    public void setBrightRobustThreshold(final float brightRobustThreshold) {
        this.brightRobustThreshold = brightRobustThreshold;
    }

    public boolean isCosmicRayCleaningEnabled() {
        return cosmicRayCleaningEnabled;
    }

    public void setCosmicRayCleaningEnabled(
        final boolean cosmicRayCleaningEnabled) {
        this.cosmicRayCleaningEnabled = cosmicRayCleaningEnabled;
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(final int debugFlag) {
        debugLevel = debugFlag;
    }

    public boolean isDiscretePrfCentroidingEnabled() {
        return discretePrfCentroidingEnabled;
    }

    public void setDiscretePrfCentroidingEnabled(
        boolean discretePrfCentroidingEnabled) {
        this.discretePrfCentroidingEnabled = discretePrfCentroidingEnabled;
    }

    public int getDiscretePrfOversampleFactor() {
        return discretePrfOversampleFactor;
    }

    public void setDiscretePrfOversampleFactor(int discretePrfOversampleFactor) {
        this.discretePrfOversampleFactor = discretePrfOversampleFactor;
    }

    public float getMadThresholdForCentroidOutliers() {
        return madThresholdForCentroidOutliers;
    }

    public void setMadThresholdForCentroidOutliers(
        float madThresholdForCentroidOutliers) {
        this.madThresholdForCentroidOutliers = madThresholdForCentroidOutliers;
    }

    public int getMaxPixelSamples() {
        return maxPixelSamples;
    }

    public void setMaxPixelSamples(final int maxPixelSamples) {
        this.maxPixelSamples = maxPixelSamples;
    }

    public int getMaxReadFsIds() {
        return maxReadFsIds;
    }

    public void setMaxReadFsIds(final int maxReadFsIds) {
        this.maxReadFsIds = maxReadFsIds;
    }

    public int getMinimumBrightTargets() {
        return minimumBrightTargets;
    }

    public void setMinimumBrightTargets(final int minimumBrightTargets) {
        this.minimumBrightTargets = minimumBrightTargets;
    }

    public boolean isPpaTargetPrfCentroidingEnabled() {
        return ppaTargetPrfCentroidingEnabled;
    }

    public void setPpaTargetPrfCentroidingEnabled(
        final boolean ppaTargetPrfCentroidingEnabled) {
        this.ppaTargetPrfCentroidingEnabled = ppaTargetPrfCentroidingEnabled;
    }

    public boolean isOapEnabled() {
        return oapEnabled;
    }

    public void setOapEnabled(final boolean oapEnabled) {
        this.oapEnabled = oapEnabled;
    }

    public boolean isPaCoaEnabled() {
        return paCoaEnabled;
    }

    public void setPaCoaEnabled(boolean paCoaEnabled) {
        this.paCoaEnabled = paCoaEnabled;
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

    public boolean isTargetPrfCentroidingEnabled() {
        return targetPrfCentroidingEnabled;
    }

    public void setTargetPrfCentroidingEnabled(
        final boolean targetPrfCentroidingEnabled) {
        this.targetPrfCentroidingEnabled = targetPrfCentroidingEnabled;
    }

    public float getThresholdMultiplierForPositiveCentroidOutliers() {
        return thresholdMultiplierForPositiveCentroidOutliers;
    }

    public void setThresholdMultiplierForPositiveCentroidOutliers(
        float thresholdMultiplierForPositiveCentroidOutliers) {
        this.thresholdMultiplierForPositiveCentroidOutliers = thresholdMultiplierForPositiveCentroidOutliers;
    }

    public float getReactionWheelMedianFilterLength() {
        return reactionWheelMedianFilterLength;
    }

    public void setReactionWheelMedianFilterLength(
        float reactionWheelMedianFilterLength) {
        this.reactionWheelMedianFilterLength = reactionWheelMedianFilterLength;
    }

    public boolean isSimulatedTransitsEnabled() {
        return simulatedTransitsEnabled;
    }

    public void setSimulatedTransitsEnabled(boolean simulatedTransitsEnabled) {
        this.simulatedTransitsEnabled = simulatedTransitsEnabled;
    }

    public boolean isOnlyProcessPpaTargetsEnabled() {
        return onlyProcessPpaTargetsEnabled;
    }

    public void setOnlyProcessPpaTargetsEnabled(
        boolean onlyProcessPpaTargetsEnabled) {
        this.onlyProcessPpaTargetsEnabled = onlyProcessPpaTargetsEnabled;
    }

    public boolean isMotionBlobsInputEnabled() {
        return motionBlobsInputEnabled;
    }

    public void setMotionBlobsInputEnabled(boolean motionBlobsInputEnabled) {
        this.motionBlobsInputEnabled = motionBlobsInputEnabled;
    }

    public boolean isRollingBandContaminationFlagsEnabled() {
        return rollingBandContaminationFlagsEnabled;
    }

    public void setRollingBandContaminationFlagsEnabled(
        boolean rollingBandContaminationFlagsEnabled) {
        this.rollingBandContaminationFlagsEnabled = rollingBandContaminationFlagsEnabled;
    }

    public boolean isRemoveMedianSimulatedFlux() {
        return removeMedianSimulatedFlux;
    }

    public void setRemoveMedianSimulatedFlux(boolean removeMedianSimulatedFlux) {
        this.removeMedianSimulatedFlux = removeMedianSimulatedFlux;
    }

    public boolean isK2TrimAperturesEnabled() {
        return k2TrimAperturesEnabled;
    }

    public void setK2TrimAperturesEnabled(boolean k2TrimAperturesEnabled) {
        this.k2TrimAperturesEnabled = k2TrimAperturesEnabled;
    }

    public float getK2TrimRadiusInPrfWidths() {
        return k2TrimRadiusInPrfWidths;
    }

    public void setK2TrimRadiusInPrfWidths(float k2TrimRadiusInPrfWidths) {
        this.k2TrimRadiusInPrfWidths = k2TrimRadiusInPrfWidths;
    }

    public int getK2TrimMinSizeInPixels() {
        return k2TrimMinSizeInPixels;
    }

    public void setK2TrimMinSizeInPixels(int k2TrimMinSizeInPixels) {
        this.k2TrimMinSizeInPixels = k2TrimMinSizeInPixels;
    }

    public boolean isK2GapIfNotFinePntData() {
        return k2GapIfNotFinePntData;
    }

    public void setK2GapIfNotFinePntData(boolean k2GapIfNotFinePntData) {
        this.k2GapIfNotFinePntData = k2GapIfNotFinePntData;
    }

    public boolean isK2GapPreTweakData() {
        return k2GapPreTweakData;
    }

    public void setK2GapPreTweakData(boolean k2GapPreTweakData) {
        this.k2GapPreTweakData = k2GapPreTweakData;
    }
    
    public int[] getTestPulseDurations() {
        return testPulseDurations;
    }
    
    /** @throws NullPointerException if testPulseDurations is null. */
    public void setTestPulseDurations(int[] testPulseDurations) {
        checkNotNull(testPulseDurations, "testPulseDurations can't be null");
        this.testPulseDurations = testPulseDurations;
    }
}
