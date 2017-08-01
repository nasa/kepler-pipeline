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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.pdc.FilledCadencesUtil;
import gov.nasa.spiffy.common.intervals.SimpleInterval;

import java.util.Arrays;

/**
 * Utility functions for dealing with actual time stamps and time series used by
 * the exporters.
 * 
 * @author Sean McCauliff
 * 
 */
public class FluxTimeSeriesProcessing {
    
    public static final double JD_TIME_OF_DAY_OFFSET = 0.5;

    /**
     * Used to fill in gaps in the MJD time series.  This function expects the
     * second derivative of the valid data points to be very small relative to the
     * first derivative.
     * 
     * 
     * @param mjdTimes  Original timestamps in increasing order.  This may not be null.
     * @param gaps When gaps[i] is true mjdTimes[i] is undefined.  this must be
     * the same length as mjdTimes.
     * @return A best guess at the valid of gapped mjdTimes.  This may return
     * mjdTimes if 
     */
    public static double[] filledMjdTimeSeries(double[] mjdTimes, boolean[] gaps) {
        if (mjdTimes.length != gaps.length) {
            throw new IllegalArgumentException("mjdTimes.length(" +
                mjdTimes.length + ") != gaps.length(" + gaps.length + ")");
        }
        
        if (gaps.length < 2) {
            throw new IllegalArgumentException("Can't do this for short time series.");
        }
        
        int lastValidIndex = -100;
        double sumDifferences = 0;
        int nValid=0;
        //Compute the mean difference between valid timestamps.
        for (int i=0; i < gaps.length; i++) {
            if (gaps[i]) {
                continue;
            }
            
            if (lastValidIndex == (i-1)) {
                sumDifferences += mjdTimes[i] - mjdTimes[lastValidIndex];
                nValid++;
            }
            
            lastValidIndex = i;
        }
        
        if (sumDifferences == 0) {
            throw new IllegalArgumentException("mjdTimes does not have enough valid points.");
        }
        
        if (nValid == gaps.length) {
            return mjdTimes;
        }
        
        double meanDelta = sumDifferences / nValid;
        double[] filledMjds = Arrays.copyOf(mjdTimes, mjdTimes.length);
        
        
        //Fill gap i by adding delta to i-1.  This won't work if there is a
        //prefix of gaps.
        
        int firstValidIndex = 0; // the first non gapped index
        for (; firstValidIndex < gaps.length && gaps[firstValidIndex]; firstValidIndex++) {
        }
        
        for (int i=firstValidIndex+1; i < gaps.length; i++) {
            if (gaps[i]) {
                filledMjds[i] = filledMjds[i-1] + meanDelta;
            }
        }
        
        //If start of series is gapped compute the prefix
        if (gaps[0]) {
            filledMjds[firstValidIndex] = mjdTimes[firstValidIndex];
            for (int i=firstValidIndex-1; i >= 0; i--) {
                filledMjds[i] = filledMjds[i+1] - meanDelta;
            }
        }
        
        return filledMjds;
        
    }
    /**
     * This estimates the correction for the start of the first cadence given the 
     * barycentric corrections for the mid points of the cadence.
     * 
     * @param correctionTimeSeries The barycentric corrections for the mid points of
     * the cadences.
     * @param firstCadence Use this cadence to override the start cadence of the
     * time series.  It must be equal to or greater than the start of 
     * the time series
     * @param lastCadence Use this cadence to override the end cadence of the time
     * series.  It must be equal to or less than the end cadence of the time series.
     * @return The barycentric correction for the start of the cadence.
     */
    public static float barycentricCorrectionStartOfFirstCadence(final FloatTimeSeries correctionTimeSeries, 
        final int firstCadence, final int lastCadence) {
        final int firstCadenceIndex =  firstCadence - correctionTimeSeries.startCadence();
        final int lastCadenceIndex = lastCadence - correctionTimeSeries.startCadence();
        final float[] midBaryCorrection = correctionTimeSeries.fseries();
        final boolean[] gaps = correctionTimeSeries.getGapIndicators();
        
        if (gaps[firstCadenceIndex]) {
            throw new IllegalArgumentException("Index for cadence is gapped.");
        }
        //single data point, just use the mid point correction.
        if (lastCadenceIndex == firstCadenceIndex) {
            return midBaryCorrection[firstCadenceIndex];
        }
        
        int found = firstCadenceIndex + 1;
        for (; found <= lastCadenceIndex; found++) {
            if (!gaps[found]) {
                break;
            }
        }
        if (found == lastCadenceIndex + 1) {
            //Messy
            return midBaryCorrection[firstCadenceIndex];
        }
        return (float) ((double)midBaryCorrection[firstCadenceIndex] - (( (double)midBaryCorrection[found] - (double)midBaryCorrection[firstCadenceIndex])/(double)(found-firstCadenceIndex))/2.0);
    }
    
    /**
     * This estimates the correction for the end of the last cadence given the mid
     * point of the cadence.
     * 
     * @param correctionTimeSeries The barycentric corrections for the mid points of
     * the cadences.
     * @param firstCadence Use this cadence to override the start cadence of the
     * time series.  It must be equal to or greater than the start of 
     * the time series
     * @param lastCadence Use this cadence to override the end cadence of the time
     * series.  It must be equal to or less than the end cadence of the time series.
     * @return The barycentric correction for the end of the last cadence.
     */
    public static float barycentricCorrectionEndOfLastCadence(FloatTimeSeries correctionTimeSeries,
        final int firstCadence, final int lastCadence) {
        final int firstCadenceIndex = firstCadence - correctionTimeSeries.startCadence();
        final int lastCadenceIndex = lastCadence - correctionTimeSeries.startCadence();
        final float[] midBaryCorrection = correctionTimeSeries.fseries();
        final boolean[] gaps = correctionTimeSeries.getGapIndicators();
            
        if (gaps[lastCadenceIndex]) {
            throw new IllegalArgumentException("Index for cadence is gapped.");
        }
        //single data point, just use the mid point correction.
        if (lastCadenceIndex == firstCadenceIndex) {
            return midBaryCorrection[lastCadenceIndex];
        }
        
        int found = lastCadenceIndex - 1;
        for (; found >= firstCadenceIndex; found--) {
            if (!gaps[found]) {
                break;
            }
        }
        if (firstCadenceIndex - 1 == found) {
            //Messy
            return midBaryCorrection[lastCadenceIndex];
        }
        double last = midBaryCorrection[lastCadenceIndex];
        return (float) (last + ((last - (double)midBaryCorrection[found])/ (double)(lastCadenceIndex-found))/2.0);
    }
    
    /**
     * TODO: might need to distinguish values that where filled because they
     * where missing from the original series vs. cadences that where filled for
     * some other reason.
     * 
     * @param mjdToCadence
     * @param pdcFilled
     * @param pdcOutliers
     * @param pdcTimeSeries
     * @param gapValue
     * @return
     */
    public static float[] correctedUnfilledFlux(MjdToCadence mjdToCadence,
        IntTimeSeries pdcFilled, FloatMjdTimeSeries pdcOutliers,
        FloatTimeSeries pdcTimeSeries, float gapValue) {

        float[] unfillData = Arrays.copyOf(pdcTimeSeries.fseries(),
            pdcTimeSeries.fseries().length);

        unfill(unfillData, gapValue, pdcFilled);
        unoutlie(unfillData, pdcTimeSeries.startCadence(), mjdToCadence,
            pdcOutliers);
        return unfillData;
    }

    public static void unfill(float[] rv, float gapValue, IntTimeSeries fillTimeSeries) {

        int[] filledIndices = 
            FilledCadencesUtil.indicatorsToIndices(fillTimeSeries);
        
        for (int index : filledIndices) {
            rv[index]  = gapValue;
        }
    }

    private static void unoutlie(float[] rv, int startCadence,
        MjdToCadence mjdToCadence, FloatMjdTimeSeries corrections) {

        double[] midMjds = corrections.mjd();
        float[] uncorrectedValues = corrections.values();
        for (int i = 0; i < midMjds.length; i++) {
            int cadence = mjdToCadence.mjdToCadence(midMjds[i]);
            rv[cadence - startCadence] = uncorrectedValues[i];
        }
    }


    public static int[] absoluteCadences(int startCadence, int endCadence,
        TimestampSeries cadenceTimes) {
        final int ncadences = endCadence - startCadence + 1;
        if (cadenceTimes.cadenceNumbers.length == ncadences) {
            return cadenceTimes.cadenceNumbers;
        }

        int[] rv = new int[endCadence - startCadence + 1];
        int startCopyAt = indexForCadence(startCadence, cadenceTimes);
        System.arraycopy(cadenceTimes.cadenceNumbers, startCopyAt, rv, 0,
            rv.length);
        return rv;

    }

    public static int indexForCadence(int cadence, TimestampSeries timestampSeries) {
        return cadence - timestampSeries.cadenceNumbers[0];
    }

    /**
     * It could be that some time series are less than [startCadence,
     * endCadence] in length so create a new array that is the full length
     * padded with the MISSING_DATA_FILL.
     * 
     * @param startCadence
     * @param endCadence
     * @param fts
     * @return
     */
    public static float[] resizeSeries(int startCadence, int endCadence, float fill,
        FloatTimeSeries fts) {
        if (fts == null) {
            float[] empty = new float[endCadence - startCadence + 1];
            Arrays.fill(empty, fill);
            return empty;
        }

        return resizeSeries(startCadence, endCadence, fts.fseries(),
            fts.startCadence(), fts.endCadence(), fill);
    }
    

   public static float[] resizeSeries(final int startCadence, final int endCadence, 
        final float[] orig,
        final int origStartCadence, final int origEndCadence, final float fill) {

        if ((origEndCadence - origStartCadence + 1) != orig.length) {
            throw new IllegalArgumentException("startCadence and endCadence do" +
                    " not match array length.");
        }
        if (startCadence == origStartCadence && endCadence == origEndCadence) {
            return orig;
        }
        
        final float[] rv = new float[endCadence - startCadence + 1];
        int desti = Math.max(origStartCadence - startCadence, 0);
        if (startCadence < origStartCadence) {
            Arrays.fill(rv, 0, desti, fill);
        }
        int srci = Math.max(0, startCadence - origStartCadence);
        //You could do this will System.arraycopy, but it makes the code more
        //complicated.
        for (; desti < rv.length && srci < orig.length; desti++, srci++) {
            rv[desti] = orig[srci];
        }
        for (;desti < rv.length; desti++) {
            rv[desti] = fill;
        }
        
        return rv;
    }
    
    public static double[] resizeSeries(int startCadence, int endCadence, double fill,
        DoubleTimeSeries fts) {
        if (fts == null) {
            double[] empty = new double[endCadence - startCadence + 1];
            Arrays.fill(empty, fill);
            return empty;
        }

        return resizeSeries(startCadence, endCadence, fts.dseries(),
            fts.startCadence(), fts.endCadence(), fill);
    }

    public static double[] resizeSeries(int startCadence, int endCadence, double[] orig,
        int origStartCadence, int origEndCadence, double fill) {
        
        if ((origEndCadence - origStartCadence + 1) != orig.length) {
            throw new IllegalArgumentException("startCadence and endCadence do" +
                    " not match array length.");
        }
        if (startCadence == origStartCadence && endCadence == origEndCadence) {
            return orig;
        }
        
        final double[] rv = new double[endCadence - startCadence + 1];
        int desti = Math.max(origStartCadence - startCadence, 0);
        if (startCadence < origStartCadence) {
            Arrays.fill(rv, 0, desti, fill);
        }
        int srci = Math.max(0, startCadence - origStartCadence);
        //You could do this will System.arraycopy, but it makes the code more
        //complicated.
        for (; desti < rv.length && srci < orig.length; desti++, srci++) {
            rv[desti] = orig[srci];
        }
        for (;desti < rv.length; desti++) {
            rv[desti] = fill;
        }
        
        return rv;
    }
    
    
    /**
     * Converts between decimal hours and decimal degrees.
     * @param decimalHours  Right ascension in decimal hours.
     * @return  Right ascension in decimal degrees.
     */
    public static double decimalHoursToDecimalDegrees(double decimalHours) {
        if (decimalHours < 0.0 || decimalHours >= 24.0) {
            throw new IllegalArgumentException("decimalHours must be >= 0.0 " +
                "and < 24.0 but got " + decimalHours);
        }
        return decimalHours / 24.0 * 360.0;
    }
    
    public static double decimalDegreesToDecimalHours(double decimalDegrees) {
        if (decimalDegrees < 0.0 || decimalDegrees > 360.0) {
            throw new IllegalArgumentException("decimalDegrees must be >= 0.0 "
                + " and < 360.0 got " + decimalDegrees);
        }
        return decimalDegrees / 360.0 * 24.0;
    }
    
    /**
     * 
     * @param mjdTimes The base mjd times for all mod outs.
     * @param gapIndicators Gap indicators for the mjd times.
     * @param barycentricCorrection The TimeSeries that has the corrections.
     * @return A double precision time series with the corrected time series
     * applied.  Units are in days.  Time system is JD - 2400000.0
     */
    public static double[] barycentricCorrectedJDOffsetTimeSeries(double[] mjdTimes,
        boolean[] gapIndicators, FloatTimeSeries barycentricCorrection,
        double gapFill) {
        
        final boolean[] barycentricCorrectionGaps =
            barycentricCorrection.getGapIndicators();
        final float[] correction = barycentricCorrection.fseries();
        double[] corrected = new double[mjdTimes.length];
        for (int i=0; i < corrected.length; i++) {
            if (gapIndicators[i] || barycentricCorrectionGaps[i]) {
                corrected[i] = gapFill;
            } else {
                corrected[i] =  mjdTimes[i] + ((double) correction[i]) + JD_TIME_OF_DAY_OFFSET;
            }
        }
        
        return corrected;
    }
    
    /**
     * Calculates the barycentric corrected kepler julian date from mjd mid times
     * and a barycentric correction time series.
     * 
     * @param mjdTimes
     * @param gapIndicators gap indicators for the mjdTimes
     * @param barycentricCorrection
     * @param gapFill
     * @return
     */
    public static double[] bkjdTimestampSeries(double[] mjdTimes,
        boolean[] gapIndicators, FloatTimeSeries barycentricCorrection,
        double gapFill) {
        
        final boolean[] barycentricCorrectionGaps =
            barycentricCorrection.getGapIndicators();
        final float[] correction = barycentricCorrection.fseries();
        double[] corrected = new double[mjdTimes.length];
        for (int i=0; i < corrected.length; i++) {
            if (gapIndicators[i] || barycentricCorrectionGaps[i]) {
                corrected[i] = gapFill;
            } else {
                corrected[i] =  ModifiedJulianDate.mjdToKjd(mjdTimes[i]) + ((double) correction[i]);
            }
        }
        
        return corrected;
    }
    
    
    public static float[] timeCorrectionSeries(FloatTimeSeries barycentricCorrection,
        float gapFill) {
        
        float[] timeCorrectionInSeconds = 
            new float[barycentricCorrection.cadenceLength()];
        float[] inDays = barycentricCorrection.fseries();
        boolean[] gapIndicators = barycentricCorrection.getGapIndicators();
        for (int i=0; i < timeCorrectionInSeconds.length; i++) {
            if (gapIndicators[i]) {
                timeCorrectionInSeconds[i] = gapFill;
            } else {
                timeCorrectionInSeconds[i] = (float) (((double) inDays[i]) * 24.0 * 60.0 * 60.0);
            }
        }
        
        return timeCorrectionInSeconds;
    }
    
    @SuppressWarnings("unchecked")
    public static <N extends Number> N uniqueValue(TimeSeries timeSeries) {
        if (timeSeries == null || timeSeries.isEmpty() || !timeSeries.exists()) {
            return null;
        }
        if (timeSeries instanceof FloatTimeSeries) {
            return (N) uniqueValue((FloatTimeSeries) timeSeries);
        }
        
        throw new IllegalArgumentException("Unsupported time series type " + timeSeries);
    }
    /**
     * 
     * @param timeSeries  This may be null.
     * @return if timeSeries is null or empty then this returns null else this
     * returns the value stored in all the valid cadences of the time series.
     * if the unique result would be NaN then this returns null.
     * @exception IllegalArgumentException If the value stored in all the valid
     * cadences is not unique.
     */
    public static Float uniqueValue(FloatTimeSeries timeSeries) {
        if (timeSeries == null || timeSeries.isEmpty()) {
            return null;
        }

        FloatTimeSeries resultValueSeries = (FloatTimeSeries) timeSeries;
        float[] fseries = resultValueSeries.fseries();
        int initialIndex = (int)resultValueSeries.validCadences().get(0).start() - resultValueSeries.startCadence();
        boolean initialIsNan = Float.isNaN(fseries[initialIndex]);
        //Use a normalized NaN representation.
        final float initialValue = (initialIsNan) ? Float.NaN : fseries[initialIndex];
        for (SimpleInterval validInterval : resultValueSeries.validCadences()) {
            for (long cadence=validInterval.start(); cadence <= validInterval.end(); cadence++) {
                int index = (int) (cadence - resultValueSeries.startCadence());
                if (fseries[index] != initialValue && !(initialIsNan && Float.isNaN(fseries[index]))) {
                    throw new IllegalArgumentException("Differing values for time series with fsId \"" + timeSeries.id() + "\".  initial: " + 
                        initialValue + " found " + fseries[index] + ". Originators " +
                        resultValueSeries.originators());
                }
            }
        }
        
        if (initialIsNan) {
            return null;
        }
        return initialValue;
    }
}
