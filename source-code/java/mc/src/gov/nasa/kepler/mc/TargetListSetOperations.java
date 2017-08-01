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

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.spiffy.common.pi.ModuleFatalProcessingException;
import gov.nasa.spiffy.common.pi.PipelineException;

/**
 * Utility methods for {@link TargetListSet}s.
 * 
 * @author Miles Cote
 * 
 */
public class TargetListSetOperations {

    public static void validateNoExistingProducts(TargetListSet targetListSet) {
        // Throw an exception if there's an existing target table. (see
        // KSOC-133).
        if (targetListSet.getTargetTable() != null) {
            throw new PipelineException(
                "The tad merge must run on a targetListSet which has not already run through tad because "
                    + "deleting old tad products is slow (see KSOC-133).  Try creating a new targetListSet."
                    + getTlsInfo(targetListSet));
        }
    }

    public static String getTlsInfo(TargetListSet tls) {
        StringBuffer buffer = new StringBuffer("\n  targetListSet: ").append(tls);

        if (tls != null) {
            buffer.append("\n  type: ")
                .append(tls.getType());
            buffer.append("\n  supplementalTls: ")
                .append(tls.getSupplementalTls());
        }

        return buffer.toString();
    }

    public static String getTlsInfo(TargetListSet tls,
        TargetListSet associatedLcTls) {
        String string = getTlsInfo(tls);

        string = string + "\n  associatedLcTls: " + associatedLcTls;

        if (associatedLcTls != null) {
            string = string + "\n  type: " + associatedLcTls.getType();
        }

        return string;
    }

    public static int validateDates(TargetListSet targetListSet,
        RollTimeOperations rollTimeOperations) {
        ModifiedJulianDate startMjd = new ModifiedJulianDate(
            targetListSet.getStart()
                .getTime());
        int startSeason = rollTimeOperations.mjdToSeason(startMjd.getMjd());

        ModifiedJulianDate endMjd = new ModifiedJulianDate(
            targetListSet.getEnd()
                .getTime());
        int endSeason = rollTimeOperations.mjdToSeason(endMjd.getMjd());

        long durationInMillis = endMjd.getTimeInMillis()
            - startMjd.getTimeInMillis();
        if (durationInMillis <= 0) {
            throw new ModuleFatalProcessingException(
                "The start date must come before the end date.\n  targetListSetName: "
                    + targetListSet.getName() + "\n  startMjd: "
                    + startMjd.getTime() + "\n  endMjd: " + endMjd.getTime()
                    + getTlsInfo(targetListSet));
        }

        if (startSeason != endSeason) {
            throw new ModuleFatalProcessingException(
                "The start and end seasons must be the same.\n  startSeason:"
                    + startSeason + "\n  endSeason:" + endSeason
                    + getTlsInfo(targetListSet));
        }
        return startSeason;
    }

    public static String getNotLockedTlsErrorText(TargetListSet tls) {
        return "The targetListSet cannot be in a state other than LOCKED.\n  targetListSet: "
            + tls
            + "\n  state: "
            + tls.getState()
            + "\n  type: "
            + tls.getType();
    }

}
