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
 * Parameters that control cosmic ray identification and removal.
 * 
 * @author Forrest Girouard
 * 
 */
public abstract class CosmicRayParameters implements Parameters, Persistable {

    private int detrendOrder;
    private int medianFilterLength;
    private float madThreshold;
    private float thresholdMultiplierForNegativeEvents;
    private boolean consecutiveCosmicRayCleaningEnabled;
    private boolean twoSidedFinalThresholdingEnabled;
    private int madWindowLength; // Not currently used, but could be used
                                 // shortly to solve CR problems with
                                 // non-uniform noise

    private int gapLengthThreshold;
    private int longMedianFilterLength;
    private int shortMedianFilterLength;
    private int arOrder;
    private float detectionThreshold;

    public int getDetrendOrder() {
        return detrendOrder;
    }

    public void setDetrendOrder(int detrendOrder) {
        this.detrendOrder = detrendOrder;
    }

    public int getMedianFilterLength() {
        return medianFilterLength;
    }

    public void setMedianFilterLength(int medianFilterLength) {
        this.medianFilterLength = medianFilterLength;
    }

    public float getMadThreshold() {
        return madThreshold;
    }

    public void setMadThreshold(float madThreshold) {
        this.madThreshold = madThreshold;
    }

    public float getThresholdMultiplierForNegativeEvents() {
        return thresholdMultiplierForNegativeEvents;
    }

    public void setThresholdMultiplierForNegativeEvents(
        float thresholdMultiplierForNegativeEvents) {
        this.thresholdMultiplierForNegativeEvents = thresholdMultiplierForNegativeEvents;
    }

    public boolean isConsecutiveCosmicRayCleaningEnabled() {
        return consecutiveCosmicRayCleaningEnabled;
    }

    public void setConsecutiveCosmicRayCleaningEnabled(
        boolean consecutiveCosmicRayCleaningEnabled) {
        this.consecutiveCosmicRayCleaningEnabled = consecutiveCosmicRayCleaningEnabled;
    }

    public boolean isTwoSidedFinalThresholdingEnabled() {
        return twoSidedFinalThresholdingEnabled;
    }

    public void setTwoSidedFinalThresholdingEnabled(
        boolean twoSidedFinalThresholdingEnabled) {
        this.twoSidedFinalThresholdingEnabled = twoSidedFinalThresholdingEnabled;
    }

    public int getMadWindowLength() {
        return madWindowLength;
    }

    public void setMadWindowLength(int madWindowLength) {
        this.madWindowLength = madWindowLength;
    }

    public int getGapLengthThreshold() {
        return gapLengthThreshold;
    }

    public void setGapLengthThreshold(int gapLengthThreshold) {
        this.gapLengthThreshold = gapLengthThreshold;
    }

    public int getLongMedianFilterLength() {
        return longMedianFilterLength;
    }

    public void setLongMedianFilterLength(int longMedianFilterLength) {
        this.longMedianFilterLength = longMedianFilterLength;
    }

    public int getShortMedianFilterLength() {
        return shortMedianFilterLength;
    }

    public void setShortMedianFilterLength(int shortMedianFilterLength) {
        this.shortMedianFilterLength = shortMedianFilterLength;
    }

    public int getArOrder() {
        return arOrder;
    }

    public void setArOrder(int arOrder) {
        this.arOrder = arOrder;
    }

    public float getDetectionThreshold() {
        return detectionThreshold;
    }

    public void setDetectionThreshold(float detectionThreshold) {
        this.detectionThreshold = detectionThreshold;
    }

}
