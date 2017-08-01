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

import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

import static gov.nasa.kepler.ar.exporter.QualityFieldCalculator.*;

/**
 * Figures out the a good mid point of the time series with respect to data anomaly
 * flags and gaps.
 * 
 * @author Sean McCauliff
 *
 */
public class ReferenceCadenceCalculator {

    /**
     * If one of these quality flags are set then we start looking at other times
     * for a good cadence.
     */
    public static final int BAD_QUALITY_FLAGS = 
        ATTITUDE_TWEAK | SAFE_MODE | COARSE_POINT | EARTH_POINT | DESAT |
        ARGABRIGHTENING | MANUAL_EXCLUDE | PA_ARGABRIGHTENING |
        REACTION_WHEEL_0_CROSSING | DETECTOR_ELECTRONICS_ANOMALY |
        THRUSTER_FIRE | POSSIBLE_THRUSTER_FIRE;
        
    
    /**
     * 
     * @param startCadence
     * @param targetStartCadence
     * @param targetEndCadence
     * @param timestampSeries
     * @param dataQualityFlags
     * @param rowCentroids This may be null.
     * @param columnCentroids This may be null.
     * @param dataQualityFlagMask For example BAD_QUALITY_FLAGS.  Cadences anded with
     * an element of dataQualityFlags that produce a non-zero number are not considered
     * as a good cadence.
     * @return a reference cadence number or throws an exception if one can not be found.
     */
    public int referenceCadence(int startCadence, int targetStartCadence,
        int targetEndCadence, TimestampSeries timestampSeries,
        int[] dataQualityFlags, DoubleTimeSeries rowCentroids,
        DoubleTimeSeries columnCentroids,
        int dataQualityFlagMask) {
        
        if (targetStartCadence > targetEndCadence) {
            throw new IllegalArgumentException("Target's start cadence " +
                targetStartCadence + " comes after end cadence " + 
                targetEndCadence);
        }
        
        if (timestampSeries == null) {
            throw new NullPointerException("timestampSeries");
        }
        if (dataQualityFlags == null) {
            throw new NullPointerException("dataQualityFlags");
        }
        
        if (timestampSeries.cadenceNumbers.length != dataQualityFlags.length) {
            throw new IllegalStateException("timestampSeries array lengths " +
                timestampSeries.cadenceNumbers.length +
                " do not equal data quality length " +
                dataQualityFlags.length);
        }
        
        
        if (timestampSeries.cadenceNumbers[0] != startCadence) {
            throw new IllegalStateException("bad start cadence");
        }
        //Start in the middle and work outwards
        final int middleCadence = (targetEndCadence + targetStartCadence) / 2;
        
        int upper = findGoodCadence(middleCadence, startCadence, 1, 
            targetStartCadence, targetEndCadence, timestampSeries, 
            dataQualityFlags, Integer.MAX_VALUE, rowCentroids, columnCentroids,
            dataQualityFlagMask);
        int lower = findGoodCadence(middleCadence, startCadence, -1, 
            targetStartCadence, targetEndCadence, timestampSeries, 
            dataQualityFlags, Integer.MAX_VALUE, rowCentroids, columnCentroids,
            dataQualityFlagMask);
        if (upper == Integer.MAX_VALUE && lower == Integer.MAX_VALUE) {
            throw new IllegalStateException(
                "Could not find reference cadence in " + targetStartCadence
                    + "-" + targetEndCadence);
        }
        if (upper == Integer.MAX_VALUE) {
            return lower;
        }
        if (lower == Integer.MAX_VALUE) {
            return upper;
        }
        int lowerDiff = middleCadence - lower;
        int upperDiff = upper - middleCadence;
        if (lowerDiff < upperDiff) {
            return lower;
        }
        return upper;
        
    }
    public int referenceCadence(int startCadence, int targetStartCadence,
        int targetEndCadence, TimestampSeries timestampSeries, int[] dataQualityFlags,
        int dataQualityFlagsMask) {

        
        return referenceCadence(startCadence, targetStartCadence, targetEndCadence,
            timestampSeries, dataQualityFlags, null, null, dataQualityFlagsMask);
    }
    
    private int findGoodCadence(final int middleCadence, final int startCadence,
        final int increment,
        final int targetStartCadence, final int targetEndCadence,
        final TimestampSeries timestampSeries, final int[] dataQualityFlags,
        final int failValue, DoubleTimeSeries rowCentroids, 
        DoubleTimeSeries columnCentroids, final int dataQualityFlagsMask) {

        for (int foundCadence=middleCadence; 
             foundCadence >= targetStartCadence && foundCadence <= targetEndCadence; 
             foundCadence += increment) {
            
            final int cadenceIndex = foundCadence - startCadence;
            if (timestampSeries.gapIndicators[cadenceIndex]) {
                continue;
            }
            
            if ((dataQualityFlagsMask & dataQualityFlags[cadenceIndex]) != 0) {
                continue;
            }
            
            if (rowCentroids != null && rowCentroids.originatorByCadence(foundCadence) == -1) {
                continue;
            }
            if (columnCentroids != null && columnCentroids.originatorByCadence(foundCadence) == -1) {
                continue;
            }
            return foundCadence;
        }
        
        return failValue;
    }


}
