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

package gov.nasa.kepler.mc.pdc;

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;

import org.apache.commons.lang.ArrayUtils;

/**
  * Utilities for dealing with the PDC filled indices.
  * 
 * @author Jay Gunter
 * @author Sean McCauliff
 *
 */
public class FilledCadencesUtil {

    /**
     * Unpacks an IntTimeSeries holding the PDC filled indices into
     * an array of ints holding the indices 
     * @param filledTimeSeries
     * @return an array of zero or indicies into the time series.  
     *  Such that rv[i] + startCadence has been filled.
     */
    public static int[] indicatorsToIndices(IntTimeSeries filledTimeSeries) {
        int[] filledIndicators = filledTimeSeries.iseries();
        
        int count=0;
        for (int fillFlag : filledIndicators) {
            if (fillFlag == 1) {
                count++;
            }
        }
        if (count == 0) {
            return ArrayUtils.EMPTY_INT_ARRAY;
        }
        
        int[] filledIndices = new int[count];
        int fi = 0;
        for (int i = 0; i < filledIndicators.length; i++) {
            if (filledIndicators[i] == 1) {
                filledIndices[fi++] = i;
            }
        }
        return filledIndices;
    }
    
    /**
     * Packs an array of cadences into a time series with indicators.
     * filledIndices are zero-based (i.e. an offset from cadenceStart).
     * To store the filledIndices we use an IntTimeSeries.
     * IntTimeSeries length must be endCadence-StartCadence+1,
     * so we use the int values as indicators of filled indices:
     * a value of 0 means that index was not filled,
     * a value of 1 means that index was filled.
     * The IntTimeSeries has a boolean array of gaps,
     * and these are false where the int indicator array has a 1,
     * and true where the int indicator array has a 0.
     * That is, the int values are redundant and inverse of the gaps.
     * @param filledIndices An array of absolute cadence numbers.
     */
    public static IntTimeSeries indicesToIndicators(FsId id, int startCadence, 
        int endCadence, int[] filledIndices, long originator) {

        int numCadences = endCadence - startCadence + 1;
        int[] fillIndicators = new int[numCadences];
        boolean[] gapFillIndicators = new boolean[numCadences];
        int fi = 0;
        for (int i = 0; i < numCadences; i++) {
            if (fi < filledIndices.length && filledIndices[fi] == i) {
                fillIndicators[i] = 1;
                gapFillIndicators[i] = false;
                fi++;
            } else {
                fillIndicators[i] = 0;
                gapFillIndicators[i] = true;
            }
        }
        
        return new IntTimeSeries(id, fillIndicators, startCadence, 
            endCadence, gapFillIndicators, originator);
    }
}
