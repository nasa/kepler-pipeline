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

package gov.nasa.kepler.ppa.pad;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Represents the complete set of available PAD module parameters.
 * <p>
 * Documentation for these fields can be found in the MATLAB code.
 * 
 * @author Forrest Girouard (fgirouard)
 * 
 */
public class PadModuleParameters implements Parameters, Persistable {

    private boolean plottingEnabled;

    private int gridRowStart;
    private int gridRowEnd;

    private int gridColStart;
    private int gridColEnd;

    private float horizonTime;
    private float trendFitTime;
    private float alertTime;

    private float initialAverageSampleCount;
    private float minTrendFitSampleCount;
    private float adaptiveBoundsXFactorForOutlier;

    private float deltaRaAdaptiveXFactor;
    private float deltaDecAdaptiveXFactor;
    private float deltaRollAdaptiveXFactor;

    private float deltaRaSmoothingFactor;
    private float deltaRaFixedLowerBound;
    private float deltaRaFixedUpperBound;

    private float deltaDecSmoothingFactor;
    private float deltaDecFixedLowerBound;
    private float deltaDecFixedUpperBound;

    private float deltaRollSmoothingFactor;
    private float deltaRollFixedLowerBound;
    private float deltaRollFixedUpperBound;

    private int debugLevel;

    public boolean isPlottingEnabled() {
        return plottingEnabled;
    }

    public void setPlottingEnabled(boolean plottingEnabled) {
        this.plottingEnabled = plottingEnabled;
    }

    public int getGridRowStart() {
        return gridRowStart;
    }

    public void setGridRowStart(int gridRowStart) {
        this.gridRowStart = gridRowStart;
    }

    // public int getGridRowStep() {
    // return gridRowStep;
    // }

    // public void setGridRowStep(int gridRowStep) {
    // this.gridRowStep = gridRowStep;
    // }

    public int getGridRowEnd() {
        return gridRowEnd;
    }

    public void setGridRowEnd(int gridRowEnd) {
        this.gridRowEnd = gridRowEnd;
    }

    public int getGridColStart() {
        return gridColStart;
    }

    public void setGridColStart(int gridColStart) {
        this.gridColStart = gridColStart;
    }

    // public int getGridColStep() {
    // return gridColStep;
    // }

    // public void setGridColStep(int gridColStep) {
    // this.gridColStep = gridColStep;
    // }

    public int getGridColEnd() {
        return gridColEnd;
    }

    public void setGridColEnd(int gridColEnd) {
        this.gridColEnd = gridColEnd;
    }

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

    public float getDeltaRaSmoothingFactor() {
        return deltaRaSmoothingFactor;
    }

    public void setDeltaRaSmoothingFactor(float deltaRaSmoothingFactor) {
        this.deltaRaSmoothingFactor = deltaRaSmoothingFactor;
    }

    public float getDeltaRaFixedLowerBound() {
        return deltaRaFixedLowerBound;
    }

    public void setDeltaRaFixedLowerBound(float deltaRaFixedLowerBound) {
        this.deltaRaFixedLowerBound = deltaRaFixedLowerBound;
    }

    public float getDeltaRaFixedUpperBound() {
        return deltaRaFixedUpperBound;
    }

    public void setDeltaRaFixedUpperBound(float deltaRaFixedUpperBound) {
        this.deltaRaFixedUpperBound = deltaRaFixedUpperBound;
    }

    public float getDeltaDecSmoothingFactor() {
        return deltaDecSmoothingFactor;
    }

    public void setDeltaDecSmoothingFactor(float deltaDecSmoothingFactor) {
        this.deltaDecSmoothingFactor = deltaDecSmoothingFactor;
    }

    public float getDeltaDecFixedLowerBound() {
        return deltaDecFixedLowerBound;
    }

    public void setDeltaDecFixedLowerBound(float deltaDecFixedLowerBound) {
        this.deltaDecFixedLowerBound = deltaDecFixedLowerBound;
    }

    public float getDeltaDecFixedUpperBound() {
        return deltaDecFixedUpperBound;
    }

    public void setDeltaDecFixedUpperBound(float deltaDecFixedUpperBound) {
        this.deltaDecFixedUpperBound = deltaDecFixedUpperBound;
    }

    public float getDeltaRollSmoothingFactor() {
        return deltaRollSmoothingFactor;
    }

    public void setDeltaRollSmoothingFactor(float deltaRollSmoothingFactor) {
        this.deltaRollSmoothingFactor = deltaRollSmoothingFactor;
    }

    public float getDeltaRollFixedLowerBound() {
        return deltaRollFixedLowerBound;
    }

    public void setDeltaRollFixedLowerBound(float deltaRollFixedLowerBound) {
        this.deltaRollFixedLowerBound = deltaRollFixedLowerBound;
    }

    public float getDeltaRollFixedUpperBound() {
        return deltaRollFixedUpperBound;
    }

    public void setDeltaRollFixedUpperBound(float deltaRollFixedUpperBound) {
        this.deltaRollFixedUpperBound = deltaRollFixedUpperBound;
    }

    public int getDebugLevel() {
        return debugLevel;
    }

    public void setDebugLevel(int debugLevel) {
        this.debugLevel = debugLevel;
    }

    public float getAlertTime() {
        return alertTime;
    }

    public void setAlertTime(float alertTime) {
        this.alertTime = alertTime;
    }

    public float getDeltaRaAdaptiveXFactor() {
        return deltaRaAdaptiveXFactor;
    }

    public void setDeltaRaAdaptiveXFactor(float deltaRaAdaptiveXFactor) {
        this.deltaRaAdaptiveXFactor = deltaRaAdaptiveXFactor;
    }

    public float getDeltaDecAdaptiveXFactor() {
        return deltaDecAdaptiveXFactor;
    }

    public void setDeltaDecAdaptiveXFactor(float deltaDecAdaptiveXFactor) {
        this.deltaDecAdaptiveXFactor = deltaDecAdaptiveXFactor;
    }

    public float getDeltaRollAdaptiveXFactor() {
        return deltaRollAdaptiveXFactor;
    }

    public void setDeltaRollAdaptiveXFactor(float deltaRollAdaptiveXFactor) {
        this.deltaRollAdaptiveXFactor = deltaRollAdaptiveXFactor;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
