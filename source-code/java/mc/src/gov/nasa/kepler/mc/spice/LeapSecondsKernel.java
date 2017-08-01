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

package gov.nasa.kepler.mc.spice;

import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

/**
 * This class represents a {@link LeapSecondsKernel}. It supports conversion to
 * and from UTC seconds since epoch and ephemeral seconds since epoch.
 * 
 * @author Miles Cote
 * 
 */
public class LeapSecondsKernel {

    /**
     * If it becomes required that the {@link LeapSecondsKernel} support dates
     * larger than 3001-01-01 00:00:000, then simply increase the value of this
     * constant to something reasonable.
     */
    private static final double MAX_YEARS_SINCE_EPOCH = 1000000E0;

    static final String DELTET_DELTA_T_A = "DELTET/DELTA_T_A";
    static final String DELTET_K = "DELTET/K";
    static final String DELTET_EB = "DELTET/EB";
    static final String DELTET_M = "DELTET/M";
    static final String DELTET_DELTA_AT = "DELTET/DELTA_AT";

    private Map<String, String> kernelData = new HashMap<String, String>();
    private double epochMjd;

    public LeapSecondsKernel(Map<String, String> kernelData, double epochMjd) {
        this.kernelData = kernelData;
        this.epochMjd = epochMjd;
    }

    public LeapSecondsKernel(File kernelFile, double epochMjd)
        throws SpiceException {
        SpiceKernelFileReader reader = new SpiceKernelFileReader(kernelFile);
        this.kernelData = reader.getKernelData();

        this.epochMjd = epochMjd;
    }

    public double getUtcSecondsSinceEpoch(double ephemeralSecondsSinceEpoch)
        throws SpiceException {
        double m = getM0() + getM1() * ephemeralSecondsSinceEpoch;
        double e = m + getEb() * Math.sin(m);
        double etMinusTai = getDeltaTa() + getK() * Math.sin(e);
        double utcSecondsSinceEpochWithoutDeltaAt = ephemeralSecondsSinceEpoch
            - etMinusTai;

        double deltaAt = getDeltaAt(utcSecondsSinceEpochWithoutDeltaAt);

        double utcSecondsSinceEpoch = utcSecondsSinceEpochWithoutDeltaAt
            - deltaAt;

        return utcSecondsSinceEpoch;
    }

    public double getEphemeralSecondsSinceEpoch(double utcSecondsSinceEpoch)
        throws SpiceException {
        double ephemeralSecondsSinceEpochLowerBound = -1000E0;
        double ephemeralSecondsSinceEpochUpperBound = SpiceTime.SECONDS_PER_DAY
            * 365E0 * MAX_YEARS_SINCE_EPOCH;

        double ephemeralSecondsSinceEpochTestValue = (ephemeralSecondsSinceEpochUpperBound + ephemeralSecondsSinceEpochLowerBound) / 2E0;

        while (true) {
            if (ephemeralSecondsSinceEpochTestValue == ephemeralSecondsSinceEpochUpperBound
                || ephemeralSecondsSinceEpochTestValue == ephemeralSecondsSinceEpochLowerBound) {
                // Found it.
                return ephemeralSecondsSinceEpochTestValue;
            }

            double utcSecondsSinceEpochTestValue = getUtcSecondsSinceEpoch(ephemeralSecondsSinceEpochTestValue);

            double difference = utcSecondsSinceEpochTestValue
                - utcSecondsSinceEpoch;

            if (difference > 0) {
                // Too big.
                ephemeralSecondsSinceEpochUpperBound = ephemeralSecondsSinceEpochTestValue;
                ephemeralSecondsSinceEpochTestValue = (ephemeralSecondsSinceEpochUpperBound + ephemeralSecondsSinceEpochLowerBound) / 2E0;
            } else if (difference < 0) {
                // Too small.
                ephemeralSecondsSinceEpochLowerBound = ephemeralSecondsSinceEpochTestValue;
                ephemeralSecondsSinceEpochTestValue = (ephemeralSecondsSinceEpochUpperBound + ephemeralSecondsSinceEpochLowerBound) / 2E0;
            } else {
                // Found it.
                return ephemeralSecondsSinceEpochTestValue;
            }
        }
    }

    private double getDeltaTa() {
        return getJavaDoubleFormat(kernelData.get(DELTET_DELTA_T_A));
    }

    private double getK() {
        return getJavaDoubleFormat(kernelData.get(DELTET_K));
    }

    private double getEb() {
        return getJavaDoubleFormat(kernelData.get(DELTET_EB));
    }

    private double getM0() {
        return getJavaDoubleFormat(getM().left);
    }

    private double getM1() {
        return getJavaDoubleFormat(getM().right);
    }

    private Pair<String, String> getM() {
        String m = kernelData.get(DELTET_M);
        m = m.replace("(", " ");
        m = m.replace(")", " ");
        m = m.trim();
        String[] m0AndM1 = m.split("\\s+");

        if (m0AndM1.length != 2) {
            throw new IllegalArgumentException(DELTET_M
                + " must have exactly two elements.\n  " + DELTET_M + ": " + m);
        }

        return Pair.of(m0AndM1[0], m0AndM1[1]);
    }

    private double getDeltaAt(double utcSecondsSinceEpochWithoutDeltaAt)
        throws SpiceException {
        String deltaAt = kernelData.get(DELTET_DELTA_AT);
        deltaAt = deltaAt.replace("(", " ");
        deltaAt = deltaAt.replace(")", " ");
        deltaAt = deltaAt.replace(",", " ");
        deltaAt = deltaAt.replace("@", " ");
        String[] deltaAtRows = deltaAt.split("\n");

        String[] previousLeapSecondsAndDate = null;
        String[] leapSecondsAndDate = null;
        for (String deltaAtRow : deltaAtRows) {
            deltaAtRow = deltaAtRow.trim();
            leapSecondsAndDate = deltaAtRow.split("\\s+");

            if (previousLeapSecondsAndDate == null) {
                previousLeapSecondsAndDate = leapSecondsAndDate;
            }

            if (leapSecondsAndDate.length != 2) {
                if (leapSecondsAndDate.length == 1
                    && leapSecondsAndDate[0].length() == 0) {
                    // Just skip this line because it's blank.
                    continue;
                } else {
                    // This is actually bad and is unparseable.
                    throw new IllegalArgumentException(DELTET_DELTA_AT
                        + " rows must have exactly two elements.\n  "
                        + DELTET_DELTA_AT + ": " + leapSecondsAndDate);
                }
            }

            Date epochDate = ModifiedJulianDate.mjdToDate(epochMjd);

            SimpleDateFormat simpleDateFormat = new SimpleDateFormat(
                "yyyy-MMM-dd");
            simpleDateFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
            Date dateForLeapSecondsRow;
            try {
                dateForLeapSecondsRow = simpleDateFormat.parse(leapSecondsAndDate[1]);
            } catch (ParseException e) {
                throw new SpiceException(
                    "Unable to parse leap seconds date.\n leapSecondsDate: "
                        + leapSecondsAndDate[1]);
            }
            double utcSecondsSinceEpochForLeapSecondsRow = (dateForLeapSecondsRow.getTime() - epochDate.getTime()) / 1000E0;

            if (utcSecondsSinceEpochForLeapSecondsRow > utcSecondsSinceEpochWithoutDeltaAt
                - getJavaDoubleFormat(leapSecondsAndDate[0])) {
                // If the leap seconds row is larger, then use the previous leap
                // seconds row.
                leapSecondsAndDate = previousLeapSecondsAndDate;
                break;
            } else {
                // If the leap seconds row is smaller or equal, then continue
                // until we see a leap seconds row that is larger.
                previousLeapSecondsAndDate = leapSecondsAndDate;
            }
        }

        return getJavaDoubleFormat(leapSecondsAndDate[0]);
    }

    private double getJavaDoubleFormat(String lskDouble) {
        lskDouble = lskDouble.replace("D", "E");
        return Double.parseDouble(lskDouble);
    }

}
