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

/**
 * Parameters associated with DV difference images.
 * 
 * @author Forrest Girouard
 */
public class DifferenceImageParameters implements Parameters, Persistable {

    private float anomalyBufferInDays;
    private boolean badQualityOffsetRemovalEnabled;
    private float boundedBoxWidth;
    private int controlBufferInCadences;
    private int defaultMedianFilterLength;
    private boolean detrendingEnabled;
    private int detrendPolyOrder;
    private int maxSinglePrfFitFailures;
    private int maxSinglePrfFitTrials;
    private float minInTransitDepth;
    private float mqOffsetConstantUncertainty;
    private boolean overlappedTransitExclusionEnabled;
    private float qualityThreshold;
    private boolean singlePrfFitForCentroidPositionsEnabled;
    private float singlePrfFitSnrThreshold;

    public DifferenceImageParameters() {
    }

    public float getAnomalyBufferInDays() {
        return anomalyBufferInDays;
    }

    public void setAnomalyBufferInDays(float anomalyBufferInDays) {
        this.anomalyBufferInDays = anomalyBufferInDays;
    }

    public boolean isBadQualityOffsetRemovalEnabled() {
        return badQualityOffsetRemovalEnabled;
    }

    public void setBadQualityOffsetRemovalEnabled(
        boolean badQualityOffsetRemovalEnabled) {
        this.badQualityOffsetRemovalEnabled = badQualityOffsetRemovalEnabled;
    }

    public float getBoundedBoxWidth() {
        return boundedBoxWidth;
    }

    public void setBoundedBoxWidth(float boundedBoxWidth) {
        this.boundedBoxWidth = boundedBoxWidth;
    }

    public int getControlBufferInCadences() {
        return controlBufferInCadences;
    }

    public void setControlBufferInCadences(int controlBufferInCadences) {
        this.controlBufferInCadences = controlBufferInCadences;
    }

    public int getDefaultMedianFilterLength() {
        return defaultMedianFilterLength;
    }

    public void setDefaultMedianFilterLength(int defaultMedianFilterLength) {
        this.defaultMedianFilterLength = defaultMedianFilterLength;
    }

    public boolean isDetrendingEnabled() {
        return detrendingEnabled;
    }

    public void setDetrendingEnabled(boolean detrendingEnabled) {
        this.detrendingEnabled = detrendingEnabled;
    }

    public int getDetrendPolyOrder() {
        return detrendPolyOrder;
    }

    public void setDetrendPolyOrder(int detrendPolyOrder) {
        this.detrendPolyOrder = detrendPolyOrder;
    }

    public int getMaxSinglePrfFitFailures() {
        return maxSinglePrfFitFailures;
    }

    public void setMaxSinglePrfFitFailures(int maxSinglePrfFitFailures) {
        this.maxSinglePrfFitFailures = maxSinglePrfFitFailures;
    }

    public int getMaxSinglePrfFitTrials() {
        return maxSinglePrfFitTrials;
    }

    public void setMaxSinglePrfFitTrials(int maxSinglePrfFitTrials) {
        this.maxSinglePrfFitTrials = maxSinglePrfFitTrials;
    }

    public float getMinInTransitDepth() {
        return minInTransitDepth;
    }

    public void setMinInTransitDepth(float minInTransitDepth) {
        this.minInTransitDepth = minInTransitDepth;
    }

    public float getMqOffsetConstantUncertainty() {
        return mqOffsetConstantUncertainty;
    }

    public void setMqOffsetConstantUncertainty(float mqOffsetConstantUncertainty) {
        this.mqOffsetConstantUncertainty = mqOffsetConstantUncertainty;
    }

    public boolean isOverlappedTransitExclusionEnabled() {
        return overlappedTransitExclusionEnabled;
    }

    public void setOverlappedTransitExclusionEnabled(
        boolean overlappedTransitExclusionEnabled) {
        this.overlappedTransitExclusionEnabled = overlappedTransitExclusionEnabled;
    }

    public float getQualityThreshold() {
        return qualityThreshold;
    }

    public void setQualityThreshold(float qualityThreshold) {
        this.qualityThreshold = qualityThreshold;
    }

    public boolean isSinglePrfFitForCentroidPositionsEnabled() {
        return singlePrfFitForCentroidPositionsEnabled;
    }

    public void setSinglePrfFitForCentroidPositionsEnabled(
        boolean singlePrfFitForCentroidPositionsEnabled) {
        this.singlePrfFitForCentroidPositionsEnabled = singlePrfFitForCentroidPositionsEnabled;
    }

    public float getSinglePrfFitSnrThreshold() {
        return singlePrfFitSnrThreshold;
    }

    public void setSinglePrfFitSnrThreshold(float singlePrfFitSnrThreshold) {
        this.singlePrfFitSnrThreshold = singlePrfFitSnrThreshold;
    }
}
