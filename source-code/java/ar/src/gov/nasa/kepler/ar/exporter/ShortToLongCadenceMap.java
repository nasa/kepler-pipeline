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

import java.util.Arrays;

import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;

/**
 * 
 * Maps short to long cadence.
 * 
 * @author Sean McCauliff
 *
 */
public class ShortToLongCadenceMap {

    /**
     * Index into this with short cadence.
     */
    private final int[] coveringLongCadence;
    private int startShortCadence;
    
    public ShortToLongCadenceMap(TimestampSeries lcCadenceTimes, TimestampSeries scCadenceTimes) {
        startShortCadence = scCadenceTimes.cadenceNumbers[0];
        int nLongCadences = lcCadenceTimes.cadenceNumbers.length;
        int nShortCadences = scCadenceTimes.cadenceNumbers.length;
        coveringLongCadence = new int[nShortCadences];
        Arrays.fill(coveringLongCadence, -1);
        
        double[] shortMidTimes = scCadenceTimes.midTimestamps;
        double[] longStartTimes = lcCadenceTimes.startTimestamps;
        double[] longEndTimes = lcCadenceTimes.endTimestamps;
        int[] longCadences = lcCadenceTimes.cadenceNumbers;
        boolean[] shortGaps = scCadenceTimes.gapIndicators;
        boolean[] longGaps = lcCadenceTimes.gapIndicators;
        

        int shortIndex=0;
        int longIndex=0;
        while (shortIndex < nShortCadences && longIndex < nLongCadences) {
            if (longGaps[longIndex]) {
                longIndex++;
            } else if (shortGaps[shortIndex]) {
                shortIndex++;
            } else if (
                shortMidTimes[shortIndex] >= longStartTimes[longIndex] &&
                shortMidTimes[shortIndex] < longEndTimes[longIndex]) {
                
                coveringLongCadence[shortIndex] = longCadences[longIndex];
                shortIndex++;
            } else if (shortMidTimes[shortIndex] < longStartTimes[longIndex]) {
                shortIndex++;
            } else {
                longIndex++;
            }
        }

    }

    /**
     * 
     * @param shortCadence
     * @return -1 if the covering long cadence is not known
     * @throws ArrayIndexOutOfBoundsException if shortCadence is not
     * within the mapped interval.
     */
    public int coveringLongCadence(int shortCadence) {
        return coveringLongCadence[shortCadence - startShortCadence];
    }
}
