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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.cal.BlackAlgorithm;
import gov.nasa.kepler.hibernate.cal.CalCrud;
import gov.nasa.kepler.hibernate.cal.CalProcessingCharacteristics;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

/**
 * Some extra stuff to deal with the black algorithm.
 * 
 * @author Sean McCauliff
 *
 */
public final class BlackAlgorithmUtils {

    private BlackAlgorithmUtils() {
    }

    /**
     * Retrieves the BlackAlgorithm used for the specified mod/out and 
     * cadence interval.  Checks that the same algorithm has been used
     * for the entire time period.
     * @return this may return null.
     */
    public static BlackAlgorithm blackAlgorithm(CalCrud calCrud, int ccdModule, int ccdOutput,
        int startCadence, int endCadence, CadenceType cadenceType) {
        List<CalProcessingCharacteristics> unsorted = 
            calCrud.retrieveProcessingCharacteristics(ccdModule, ccdOutput, 
            startCadence, endCadence, cadenceType);
        
        CalProcessingCharacteristics[] sorted = 
            unsorted.toArray(new CalProcessingCharacteristics[0]);
        
        Arrays.sort(sorted, new Comparator<CalProcessingCharacteristics>() {

            @Override
            public int compare(CalProcessingCharacteristics o1,
                CalProcessingCharacteristics o2) {
                    return (int) (o1.getPipelineTask().getId() - o2.getPipelineTask().getId());
            }
        });
        
        //Using the ordinal value of the black algorithm as the tag value.
        IntervalSet<TaggedInterval, TaggedInterval.Factory> cpcIntervals =
                new IntervalSet<TaggedInterval, TaggedInterval.Factory>(new TaggedInterval.Factory());
        for (CalProcessingCharacteristics cpc : sorted) {
            cpcIntervals.mergeInterval(new TaggedInterval(cpc.getStartCadence(),
                cpc.getEndCadence(), cpc.getBlackAlgorithm().ordinal()));
        }

        int blackAlgorithmOrdinal = -1;
        for (TaggedInterval mergedInterval : cpcIntervals.intervals()) {
            if (blackAlgorithmOrdinal != -1) {
                if (blackAlgorithmOrdinal != mergedInterval.tag()) {
                    throw new IllegalStateException("Inconsistent black algorithms.");
                }
            } else {
                blackAlgorithmOrdinal = (int) mergedInterval.tag();
            }
        }
        /** Black algorithm information is not present. */
        if (blackAlgorithmOrdinal == -1) {
            return null;
        }
        return BlackAlgorithm.values()[blackAlgorithmOrdinal];
    }
}
