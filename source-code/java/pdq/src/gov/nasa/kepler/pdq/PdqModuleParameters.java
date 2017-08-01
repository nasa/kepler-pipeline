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

package gov.nasa.kepler.pdq;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Represents the complete set of available PDQ module parameters.
 * <p>
 * Documentation for these fields can be found in the MATLAB code (see
 * matlab/pdq/mfiles/@pdqScienceClass/pdqScienceClass).
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PdqModuleParameters implements Parameters, Persistable {

    private int maxBlackPolyOrder;
    private float eeFluxFraction;
    private int maxFzeroIterations;
    private int encircledEnergyPolyOrderMax;
    private float sigmaGaussianRollOff;
    private int immediateNeighborhoodRadiusInPixel;
    private float madSigmaThresholdForBleedingColumns;
    private float horizonTime;
    private int minTrendFitSampleCount;
    private float exponentialSmoothingFactor;
    private float adaptiveBoundsXFactor;
    private float trendFitTime;
    private int haloAroundOptimalApertureInPixels;
    private float sigmaForRejectingBadTargets;
    private float madThresholdForCentroidOutliers;

    private float backgroundLevelFixedLowerBound;
    private float backgroundLevelFixedUpperBound;
    private float blackLevelFixedLowerBound;
    private float blackLevelFixedUpperBound;
    private float centroidsMeanColFixedLowerBound;
    private float centroidsMeanColFixedUpperBound;
    private float centroidsMeanRowFixedLowerBound;
    private float centroidsMeanRowFixedUpperBound;
    private float darkCurrentFixedLowerBound;
    private float darkCurrentFixedUpperBound;
    private float deltaAttitudeDecFixedLowerBound;
    private float deltaAttitudeDecFixedUpperBound;
    private float deltaAttitudeRaFixedLowerBound;
    private float deltaAttitudeRaFixedUpperBound;
    private float deltaAttitudeRollFixedLowerBound;
    private float deltaAttitudeRollFixedUpperBound;
    private float dynamicRangeFixedLowerBound;
    private float dynamicRangeFixedUpperBound;
    private float encircledEnergyFixedLowerBound;
    private float encircledEnergyFixedUpperBound;
    private float meanFluxFixedLowerBound;
    private float meanFluxFixedUpperBound;
    private float plateScaleFixedLowerBound;
    private float plateScaleFixedUpperBound;
    private float smearLevelFixedLowerBound;
    private float smearLevelFixedUpperBound;
    private float maxAttitudeResidualInPixelsFixedLowerBound;
    private float maxAttitudeResidualInPixelsFixedUpperBound;

    /**
     * Generate a generic mission report iff this is true.
     */
    private boolean reportEnabled;

    private int debugLevel;
    private boolean forceReprocessing;

    /**
     * Sorted list of indexes (pseudo-cadences in ascending order starting from
     * zero) of reference pixel files to be excluded from processing.
     */
    private int[] excludeCadences = ArrayUtils.EMPTY_INT_ARRAY;
    
    /**
     * Control call to MatlabPipelineModule.executeAlgorithm.
     */
    private boolean executeAlgorithmEnabled;

    public PdqModuleParameters() {
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public int getMaxBlackPolyOrder() {
        return maxBlackPolyOrder;
    }

    public void setMaxBlackPolyOrder(final int maxBlackPolyOrder) {
        this.maxBlackPolyOrder = maxBlackPolyOrder;
    }

    public float getEeFluxFraction() {
        return eeFluxFraction;
    }

    public void setEeFluxFraction(final float eeFluxFraction) {
        this.eeFluxFraction = eeFluxFraction;
    }

    public int getMaxFzeroIterations() {
        return maxFzeroIterations;
    }

    public void setMaxFzeroIterations(final int maxFzeroIterations) {
        this.maxFzeroIterations = maxFzeroIterations;
    }

    public int getEncircledEnergyPolyOrderMax() {
        return encircledEnergyPolyOrderMax;
    }

    public void setEncircledEnergyPolyOrderMax(
        final int encircledEnergyPolyOrderMax) {
        this.encircledEnergyPolyOrderMax = encircledEnergyPolyOrderMax;
    }

    public float getSigmaGaussianRollOff() {
        return sigmaGaussianRollOff;
    }

    public void setSigmaGaussianRollOff(final float sigmaGaussianRollOff) {
        this.sigmaGaussianRollOff = sigmaGaussianRollOff;
    }

    public int getImmediateNeighborhoodRadiusInPixel() {
        return immediateNeighborhoodRadiusInPixel;
    }

    public void setImmediateNeighborhoodRadiusInPixel(
        final int immediateNeighborhoodRadiusInPixel) {
        this.immediateNeighborhoodRadiusInPixel = immediateNeighborhoodRadiusInPixel;
    }

    public float getMadSigmaThresholdForBleedingColumns() {
        return madSigmaThresholdForBleedingColumns;
    }

    public void setMadSigmaThresholdForBleedingColumns(
        final float madSigmaThresholdForBleedingColumns) {
        this.madSigmaThresholdForBleedingColumns = madSigmaThresholdForBleedingColumns;
    }

    public float getHorizonTime() {
        return horizonTime;
    }

    public void setHorizonTime(final float horizonTime) {
        this.horizonTime = horizonTime;
    }

    public int getMinTrendFitSampleCount() {
        return minTrendFitSampleCount;
    }

    public void setMinTrendFitSampleCount(final int minTrendFitSampleCount) {
        this.minTrendFitSampleCount = minTrendFitSampleCount;
    }

    public float getExponentialSmoothingFactor() {
        return exponentialSmoothingFactor;
    }

    public void setExponentialSmoothingFactor(
        final float exponentialSmoothingFactor) {
        this.exponentialSmoothingFactor = exponentialSmoothingFactor;
    }

    public float getAdaptiveBoundsXFactor() {
        return adaptiveBoundsXFactor;
    }

    public void setAdaptiveBoundsXFactor(final float adaptiveBoundsXFactor) {
        this.adaptiveBoundsXFactor = adaptiveBoundsXFactor;
    }

    public float getTrendFitTime() {
        return trendFitTime;
    }

    public void setTrendFitTime(final float trendFitTime) {
        this.trendFitTime = trendFitTime;
    }

    public int getHaloAroundOptimalApertureInPixels() {
        return haloAroundOptimalApertureInPixels;
    }

    public void setHaloAroundOptimalApertureInPixels(
        final int haloAroundOptimalApertureInPixels) {
        this.haloAroundOptimalApertureInPixels = haloAroundOptimalApertureInPixels;
    }

    public float getSigmaForRejectingBadTargets() {
        return sigmaForRejectingBadTargets;
    }

    public void setSigmaForRejectingBadTargets(float sigmaForRejectingBadTargets) {
        this.sigmaForRejectingBadTargets = sigmaForRejectingBadTargets;
    }

    public float getMadThresholdForCentroidOutliers() {
        return madThresholdForCentroidOutliers;
    }

    public void setMadThresholdForCentroidOutliers(
        float madThresholdForCentroidOutliers) {
        this.madThresholdForCentroidOutliers = madThresholdForCentroidOutliers;
    }

    public float getBackgroundLevelFixedLowerBound() {
        return backgroundLevelFixedLowerBound;
    }

    public void setBackgroundLevelFixedLowerBound(
        final float backgroundLevelFixedLowerBound) {
        this.backgroundLevelFixedLowerBound = backgroundLevelFixedLowerBound;
    }

    public float getBackgroundLevelFixedUpperBound() {
        return backgroundLevelFixedUpperBound;
    }

    public void setBackgroundLevelFixedUpperBound(
        final float backgroundLevelFixedUpperBound) {
        this.backgroundLevelFixedUpperBound = backgroundLevelFixedUpperBound;
    }

    public float getBlackLevelFixedLowerBound() {
        return blackLevelFixedLowerBound;
    }

    public void setBlackLevelFixedLowerBound(
        final float blackLevelFixedLowerBound) {
        this.blackLevelFixedLowerBound = blackLevelFixedLowerBound;
    }

    public float getBlackLevelFixedUpperBound() {
        return blackLevelFixedUpperBound;
    }

    public void setBlackLevelFixedUpperBound(
        final float blackLevelFixedUpperBound) {
        this.blackLevelFixedUpperBound = blackLevelFixedUpperBound;
    }

    public float getCentroidsMeanColFixedLowerBound() {
        return centroidsMeanColFixedLowerBound;
    }

    public void setCentroidsMeanColFixedLowerBound(
        final float centroidsMeanColFixedLowerBound) {
        this.centroidsMeanColFixedLowerBound = centroidsMeanColFixedLowerBound;
    }

    public float getCentroidsMeanColFixedUpperBound() {
        return centroidsMeanColFixedUpperBound;
    }

    public void setCentroidsMeanColFixedUpperBound(
        final float centroidsMeanColFixedUpperBound) {
        this.centroidsMeanColFixedUpperBound = centroidsMeanColFixedUpperBound;
    }

    public float getCentroidsMeanRowFixedLowerBound() {
        return centroidsMeanRowFixedLowerBound;
    }

    public void setCentroidsMeanRowFixedLowerBound(
        final float centroidsMeanRowFixedLowerBound) {
        this.centroidsMeanRowFixedLowerBound = centroidsMeanRowFixedLowerBound;
    }

    public float getCentroidsMeanRowFixedUpperBound() {
        return centroidsMeanRowFixedUpperBound;
    }

    public void setCentroidsMeanRowFixedUpperBound(
        final float centroidsMeanRowFixedUpperBound) {
        this.centroidsMeanRowFixedUpperBound = centroidsMeanRowFixedUpperBound;
    }

    public float getDarkCurrentFixedLowerBound() {
        return darkCurrentFixedLowerBound;
    }

    public void setDarkCurrentFixedLowerBound(
        final float darkCurrentFixedLowerBound) {
        this.darkCurrentFixedLowerBound = darkCurrentFixedLowerBound;
    }

    public float getDarkCurrentFixedUpperBound() {
        return darkCurrentFixedUpperBound;
    }

    public void setDarkCurrentFixedUpperBound(
        final float darkCurrentFixedUpperBound) {
        this.darkCurrentFixedUpperBound = darkCurrentFixedUpperBound;
    }

    public float getDeltaAttitudeDecFixedLowerBound() {
        return deltaAttitudeDecFixedLowerBound;
    }

    public void setDeltaAttitudeDecFixedLowerBound(
        final float deltaAttitudeDecFixedLowerBound) {
        this.deltaAttitudeDecFixedLowerBound = deltaAttitudeDecFixedLowerBound;
    }

    public float getDeltaAttitudeDecFixedUpperBound() {
        return deltaAttitudeDecFixedUpperBound;
    }

    public void setDeltaAttitudeDecFixedUpperBound(
        final float deltaAttitudeDecFixedUpperBound) {
        this.deltaAttitudeDecFixedUpperBound = deltaAttitudeDecFixedUpperBound;
    }

    public float getDeltaAttitudeRaFixedLowerBound() {
        return deltaAttitudeRaFixedLowerBound;
    }

    public void setDeltaAttitudeRaFixedLowerBound(
        final float deltaAttitudeRaFixedLowerBound) {
        this.deltaAttitudeRaFixedLowerBound = deltaAttitudeRaFixedLowerBound;
    }

    public float getDeltaAttitudeRaFixedUpperBound() {
        return deltaAttitudeRaFixedUpperBound;
    }

    public void setDeltaAttitudeRaFixedUpperBound(
        final float deltaAttitudeRaFixedUpperBound) {
        this.deltaAttitudeRaFixedUpperBound = deltaAttitudeRaFixedUpperBound;
    }

    public float getDeltaAttitudeRollFixedLowerBound() {
        return deltaAttitudeRollFixedLowerBound;
    }

    public void setDeltaAttitudeRollFixedLowerBound(
        final float deltaAttitudeRollFixedLowerBound) {
        this.deltaAttitudeRollFixedLowerBound = deltaAttitudeRollFixedLowerBound;
    }

    public float getDeltaAttitudeRollFixedUpperBound() {
        return deltaAttitudeRollFixedUpperBound;
    }

    public void setDeltaAttitudeRollFixedUpperBound(
        final float deltaAttitudeRollFixedUpperBound) {
        this.deltaAttitudeRollFixedUpperBound = deltaAttitudeRollFixedUpperBound;
    }

    public float getDynamicRangeFixedLowerBound() {
        return dynamicRangeFixedLowerBound;
    }

    public void setDynamicRangeFixedLowerBound(
        final float dynamicRangeFixedLowerBound) {
        this.dynamicRangeFixedLowerBound = dynamicRangeFixedLowerBound;
    }

    public float getDynamicRangeFixedUpperBound() {
        return dynamicRangeFixedUpperBound;
    }

    public void setDynamicRangeFixedUpperBound(
        final float dynamicRangeFixedUpperBound) {
        this.dynamicRangeFixedUpperBound = dynamicRangeFixedUpperBound;
    }

    public float getEncircledEnergyFixedLowerBound() {
        return encircledEnergyFixedLowerBound;
    }

    public void setEncircledEnergyFixedLowerBound(
        final float encircledEnergyFixedLowerBound) {
        this.encircledEnergyFixedLowerBound = encircledEnergyFixedLowerBound;
    }

    public float getEncircledEnergyFixedUpperBound() {
        return encircledEnergyFixedUpperBound;
    }

    public void setEncircledEnergyFixedUpperBound(
        final float encircledEnergyFixedUpperBound) {
        this.encircledEnergyFixedUpperBound = encircledEnergyFixedUpperBound;
    }

    public float getMeanFluxFixedLowerBound() {
        return meanFluxFixedLowerBound;
    }

    public void setMeanFluxFixedLowerBound(final float meanFluxFixedLowerBound) {
        this.meanFluxFixedLowerBound = meanFluxFixedLowerBound;
    }

    public float getMeanFluxFixedUpperBound() {
        return meanFluxFixedUpperBound;
    }

    public void setMeanFluxFixedUpperBound(final float meanFluxFixedUpperBound) {
        this.meanFluxFixedUpperBound = meanFluxFixedUpperBound;
    }

    public float getPlateScaleFixedLowerBound() {
        return plateScaleFixedLowerBound;
    }

    public void setPlateScaleFixedLowerBound(
        final float plateScaleFixedLowerBound) {
        this.plateScaleFixedLowerBound = plateScaleFixedLowerBound;
    }

    public float getPlateScaleFixedUpperBound() {
        return plateScaleFixedUpperBound;
    }

    public void setPlateScaleFixedUpperBound(
        final float plateScaleFixedUpperBound) {
        this.plateScaleFixedUpperBound = plateScaleFixedUpperBound;
    }

    public float getSmearLevelFixedLowerBound() {
        return smearLevelFixedLowerBound;
    }

    public void setSmearLevelFixedLowerBound(
        final float smearLevelFixedLowerBound) {
        this.smearLevelFixedLowerBound = smearLevelFixedLowerBound;
    }

    public float getSmearLevelFixedUpperBound() {
        return smearLevelFixedUpperBound;
    }

    public void setSmearLevelFixedUpperBound(
        final float smearLevelFixedUpperBound) {
        this.smearLevelFixedUpperBound = smearLevelFixedUpperBound;
    }

    public float getMaxAttitudeResidualInPixelsFixedLowerBound() {
        return maxAttitudeResidualInPixelsFixedLowerBound;
    }

    public void setMaxAttitudeResidualInPixelsFixedLowerBound(
        final float maxAttitudeResidualInPixelsFixedLowerBound) {
        this.maxAttitudeResidualInPixelsFixedLowerBound = maxAttitudeResidualInPixelsFixedLowerBound;
    }

    public float getMaxAttitudeResidualInPixelsFixedUpperBound() {
        return maxAttitudeResidualInPixelsFixedUpperBound;
    }

    public void setMaxAttitudeResidualInPixelsFixedUpperBound(
        final float maxAttitudeResidualInPixelsFixedUpperBound) {
        this.maxAttitudeResidualInPixelsFixedUpperBound = maxAttitudeResidualInPixelsFixedUpperBound;
    }

    public boolean isReportEnabled() {
        return reportEnabled;
    }

    public void setReportEnabled(final boolean reportEnabled) {
        this.reportEnabled = reportEnabled;
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(final int debugLevel) {
        this.debugLevel = debugLevel;
    }

    public boolean isForceReprocessing() {
        return forceReprocessing;
    }

    public void setForceReprocessing(final boolean forceReprocessing) {
        this.forceReprocessing = forceReprocessing;
    }

    public int[] getExcludeCadences() {
        return excludeCadences;
    }

    public void setExcludeCadences(int[] excludeCadences) {
        this.excludeCadences = excludeCadences;
    }

    public boolean isExecuteAlgorithmEnabled() {
        return executeAlgorithmEnabled;
    }

    public void setExecuteAlgorithmEnabled(boolean executeAlgorithmEnabled) {
        this.executeAlgorithmEnabled = executeAlgorithmEnabled;
    }

}
