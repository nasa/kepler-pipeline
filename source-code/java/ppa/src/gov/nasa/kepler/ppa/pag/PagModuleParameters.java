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

package gov.nasa.kepler.ppa.pag;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Represents the complete set of available PAG module parameters.
 * <p>
 * Documentation for these fields can be found in the MATLAB code.
 * 
 * @author Bill Wohler
 */
public class PagModuleParameters implements Parameters, Persistable {

    private float horizonTime;
    private float trendFitTime;
    private float alertTime;
    private float initialAverageSampleCount;
    private float minTrendFitSampleCount;
    private float adaptiveBoundsXFactorForOutlier;

    private float compressionSmoothingFactor;
    private float compressionFixedLowerBound;
    private float compressionFixedUpperBound;
    private float compressionAdaptiveXFactor;

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
