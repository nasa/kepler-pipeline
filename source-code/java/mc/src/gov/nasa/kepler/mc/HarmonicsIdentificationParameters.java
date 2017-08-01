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
 * Parameters for identifying harmonics in light curves.
 * 
 * @author Sean McCauliff
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public abstract class HarmonicsIdentificationParameters implements Parameters,
    Persistable {

    private float falseDetectionProbabilityForTimeSeries;
    private int maxHarmonicComponents;
    private int medianWindowLengthForPeriodogramSmoothing;
    private int medianWindowLengthForTimeSeriesSmoothing;
    private int minHarmonicSeparationInBins;
    private int movingAverageWindowLength;
    private boolean retainFrequencyCombsEnabled;
    private float timeOutInMinutes;

    public float getFalseDetectionProbabilityForTimeSeries() {
        return falseDetectionProbabilityForTimeSeries;
    }

    public void setFalseDetectionProbabilityForTimeSeries(
        float falseDetectionProbabilityForTimeSeries) {
        this.falseDetectionProbabilityForTimeSeries = falseDetectionProbabilityForTimeSeries;
    }

    public int getMaxHarmonicComponents() {
        return maxHarmonicComponents;
    }

    public void setMaxHarmonicComponents(int maxHarmonicComponents) {
        this.maxHarmonicComponents = maxHarmonicComponents;
    }

    public int getMedianWindowLengthForPeriodogramSmoothing() {
        return medianWindowLengthForPeriodogramSmoothing;
    }

    public void setMedianWindowLengthForPeriodogramSmoothing(
        int medianWindowLengthForPeriodogramSmoothing) {
        this.medianWindowLengthForPeriodogramSmoothing = medianWindowLengthForPeriodogramSmoothing;
    }

    public int getMedianWindowLengthForTimeSeriesSmoothing() {
        return medianWindowLengthForTimeSeriesSmoothing;
    }

    public void setMedianWindowLengthForTimeSeriesSmoothing(
        int medianWindowLengthForTimeSeriesSmoothing) {
        this.medianWindowLengthForTimeSeriesSmoothing = medianWindowLengthForTimeSeriesSmoothing;
    }

    public int getMinHarmonicSeparationInBins() {
        return minHarmonicSeparationInBins;
    }

    public void setMinHarmonicSeparationInBins(int minHarmonicSeparationInBins) {
        this.minHarmonicSeparationInBins = minHarmonicSeparationInBins;
    }

    public int getMovingAverageWindowLength() {
        return movingAverageWindowLength;
    }

    public void setMovingAverageWindowLength(int movingAverageWindowLength) {
        this.movingAverageWindowLength = movingAverageWindowLength;
    }

    public boolean isRetainFrequencyCombsEnabled() {
        return retainFrequencyCombsEnabled;
    }

    public void setRetainFrequencyCombsEnabled(
        boolean retainFrequencyCombsEnabled) {
        this.retainFrequencyCombsEnabled = retainFrequencyCombsEnabled;
    }

    public float getTimeOutInMinutes() {
        return timeOutInMinutes;
    }

    public void setTimeOutInMinutes(float timeOutInMinutes) {
        this.timeOutInMinutes = timeOutInMinutes;
    }
}
