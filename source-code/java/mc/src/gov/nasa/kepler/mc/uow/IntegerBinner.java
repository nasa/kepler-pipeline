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

package gov.nasa.kepler.mc.uow;

import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class IntegerBinner {

    /**
     * Subdivides the given pair of {@code Integer}s into a list of pairs whose
     * difference does not exceed {@code maxDifference}.
     * 
     * @param pair the pair to subdivide.
     * @param maxDifference the maximum difference between the pairs. If 0, or
     * larger than the difference between {@code pair.left} and
     * {@code pair.right}, a list containing a single pair is returned that
     * spans from {@code pair.left} to {@code pair.right}.
     * @return a non-{@code null} list of pairs.
     * @throws IllegalArgumentException if {@code pair.left} or
     * {@code pair.right} are negative, or if {@code pair.right} is less than
     * {@code pair.left}.
     */
    public static List<Pair<Integer, Integer>> subdivide(Pair<Integer, Integer> pair, int maxDifference) {
    
        if (pair.left < 0) {
            throw new IllegalArgumentException("start can't be negative");
        }
        if (pair.right < 0) {
            throw new IllegalArgumentException("end can't be negative");
        }
        if (pair.right < pair.left) {
            throw new IllegalArgumentException(
                "end must be greater than or equal to start");
        }
    
        List<Pair<Integer, Integer>> pairs = new ArrayList<Pair<Integer, Integer>>();
    
        if (maxDifference == 0) {
            pairs.add(Pair.of(pair.left, pair.right));
            return pairs;
        }
    
        double size = pair.right - pair.left + 1;
    
        int numBins = (int) Math.ceil(size / maxDifference);
        int nextStart = pair.left;
        for (int bin = 0; bin < numBins; bin++) {
            int binEnd = (nextStart + maxDifference - 1);
            if (binEnd > pair.right) {
                binEnd = pair.right;
            }
    
            pairs.add(Pair.of(nextStart, binEnd));
    
            nextStart = binEnd + 1;
        }
    
        return pairs;
    }

}
