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

import java.io.File;
import java.util.HashMap;
import java.util.Map;

/**
 * This class represents a {@link KeplerSpacecraftClockKernel}. It supports
 * conversion to and from ephemeral seconds since epoch and
 * {@link KeplerSclkTime}.
 * 
 * @author Miles Cote
 * 
 */
public class KeplerSpacecraftClockKernel {

    static final String SCLK01_COEFFICIENTS_227 = "SCLK01_COEFFICIENTS_227";

    private Map<String, String> kernelData = new HashMap<String, String>();

    public KeplerSpacecraftClockKernel(Map<String, String> kernelData) {
        this.kernelData = kernelData;
    }

    public KeplerSpacecraftClockKernel(File kernelFile) throws SpiceException {
        SpiceKernelFileReader reader = new SpiceKernelFileReader(kernelFile);
        this.kernelData = reader.getKernelData();
    }

    public double getEphemeralSecondsSinceEpoch(KeplerSclkTime keplerSclkTime)
        throws SpiceException {
        KeplerSclkTime keplerSclkEventTime = getKeplerSclkEventTime(keplerSclkTime);
        double secondsSinceEpoch = getSecondsSinceEpoch(keplerSclkTime);
        double clockRate = getClockRate(keplerSclkTime);

        double ephemeralSecondsSinceEpoch = secondsSinceEpoch + clockRate
            * (keplerSclkTime.getSeconds() - keplerSclkEventTime.getSeconds());

        return ephemeralSecondsSinceEpoch;
    }

    public KeplerSclkTime getKeplerSclkTime(double ephemeralSecondsSinceEpoch)
        throws SpiceException {
        if (ephemeralSecondsSinceEpoch < 0) {
            throw new SpiceException(
                "ephemeralSecondsSinceEpoch must not be less than 0.\n  ephemeralSecondsSinceEpoch: "
                    + ephemeralSecondsSinceEpoch);
        }

        KeplerSclkTime keplerSclkEventTime = getKeplerSclkEventTime(ephemeralSecondsSinceEpoch);
        double secondsSinceEpoch = getSecondsSinceEpoch(ephemeralSecondsSinceEpoch);
        double clockRate = getClockRate(ephemeralSecondsSinceEpoch);

        double keplerSclkSeconds = (ephemeralSecondsSinceEpoch - secondsSinceEpoch)
            / clockRate + keplerSclkEventTime.getSeconds();
        long secondsIncrements = (long) keplerSclkSeconds;
        long microsecondsIncrements = (long) ((keplerSclkSeconds - secondsIncrements) * 1000000);

        KeplerSclkTime keplerSclkTime = new KeplerSclkTime(secondsIncrements,
            microsecondsIncrements);

        return keplerSclkTime;
    }

    private KeplerSclkTime getKeplerSclkEventTime(KeplerSclkTime keplerSclkTime)
        throws SpiceException {
        return getKeplerSclkEventTime(getSclkCoeffs(keplerSclkTime)[0]);
    }

    private double getSecondsSinceEpoch(KeplerSclkTime keplerSclkTime)
        throws SpiceException {
        return getJavaDoubleFormat(getSclkCoeffs(keplerSclkTime)[1]);
    }

    private double getClockRate(KeplerSclkTime keplerSclkTime)
        throws SpiceException {
        return getJavaDoubleFormat(getSclkCoeffs(keplerSclkTime)[2]);
    }

    private KeplerSclkTime getKeplerSclkEventTime(
        double ephemeralSecondsSinceEpoch) throws SpiceException {
        String[] sclkCoeffs = getSclkCoeffs(ephemeralSecondsSinceEpoch);
        return getKeplerSclkEventTime(sclkCoeffs[0]);
    }

    private double getSecondsSinceEpoch(double ephemeralSecondsSinceEpoch) {
        return getJavaDoubleFormat(getSclkCoeffs(ephemeralSecondsSinceEpoch)[1]);
    }

    private double getClockRate(double ephemeralSecondsSinceEpoch) {
        return getJavaDoubleFormat(getSclkCoeffs(ephemeralSecondsSinceEpoch)[2]);
    }

    private String[] getSclkCoeffs(KeplerSclkTime keplerSclkTime)
        throws SpiceException {
        String sclkCoeffsMapValue = kernelData.get(SCLK01_COEFFICIENTS_227);
        sclkCoeffsMapValue = sclkCoeffsMapValue.replace("(", " ");
        sclkCoeffsMapValue = sclkCoeffsMapValue.replace(")", " ");
        String[] sclkCoeffsRows = sclkCoeffsMapValue.split("\n");

        String[] previousSclkCoeffs = null;
        String[] sclkCoeffs = null;
        for (String sclkCoeffsRow : sclkCoeffsRows) {
            sclkCoeffsRow = sclkCoeffsRow.trim();
            sclkCoeffs = sclkCoeffsRow.split("\\s+");

            if (sclkCoeffs.length != 3) {
                if (sclkCoeffs.length == 1 && sclkCoeffs[0].length() == 0) {
                    // Just skip this line because it's blank.
                    continue;
                } else {
                    // This is actually bad and is unparseable.
                    throw new IllegalArgumentException(SCLK01_COEFFICIENTS_227
                        + " rows must have exactly three elements.\n  "
                        + SCLK01_COEFFICIENTS_227 + ": " + sclkCoeffs);
                }
            }

            KeplerSclkTime keplerSclkEventTime = getKeplerSclkEventTime(sclkCoeffs[0]);

            if (keplerSclkEventTime.getSeconds() > keplerSclkTime.getSeconds()) {
                // If the sclk coeffs row is larger, then use the previous
                // row.
                sclkCoeffs = previousSclkCoeffs;
                break;
            } else {
                // If the sclk coeffs row is smaller or equal, then continue
                // until we see a row that is larger.
                previousSclkCoeffs = sclkCoeffs;
            }
        }

        return sclkCoeffs;
    }

    private String[] getSclkCoeffs(double ephemeralSecondsSinceEpoch) {
        String sclkCoeffsMapValue = kernelData.get(SCLK01_COEFFICIENTS_227);
        sclkCoeffsMapValue = sclkCoeffsMapValue.replace("(", " ");
        sclkCoeffsMapValue = sclkCoeffsMapValue.replace(")", " ");
        String[] sclkCoeffsRows = sclkCoeffsMapValue.split("\n");

        String[] previousSclkCoeffs = null;
        String[] sclkCoeffs = null;
        for (String sclkCoeffsRow : sclkCoeffsRows) {
            sclkCoeffsRow = sclkCoeffsRow.trim();
            sclkCoeffs = sclkCoeffsRow.split("\\s+");

            if (previousSclkCoeffs == null) {
                previousSclkCoeffs = sclkCoeffs;
            }

            if (sclkCoeffs.length != 3) {
                if (sclkCoeffs.length == 1 && sclkCoeffs[0].length() == 0) {
                    // Just skip this line because it's blank.
                    continue;
                } else {
                    // This is actually bad and is unparseable.
                    throw new IllegalArgumentException(SCLK01_COEFFICIENTS_227
                        + " rows must have exactly three elements.\n  "
                        + SCLK01_COEFFICIENTS_227 + ": " + sclkCoeffs);
                }
            }

            double eventTimeSecondsSinceEpoch = Double.parseDouble(sclkCoeffs[1]);

            if (eventTimeSecondsSinceEpoch > ephemeralSecondsSinceEpoch) {
                // If the sclk coeffs row is larger, then use the previous
                // row.
                sclkCoeffs = previousSclkCoeffs;
                break;
            } else {
                // If the sclk coeffs row is smaller or equal, then continue
                // until we see a row that is larger.
                previousSclkCoeffs = sclkCoeffs;
            }
        }

        return sclkCoeffs;
    }

    private KeplerSclkTime getKeplerSclkEventTime(String sclkCoeff)
        throws SpiceException {
        long totalMicrosecondTicks = (long) Double.parseDouble(sclkCoeff);
        long secondsIncrements = totalMicrosecondTicks / 1000000;
        long microsecondsIncrements = totalMicrosecondTicks - secondsIncrements
            * 1000000;

        KeplerSclkTime keplerSclkEventTime = new KeplerSclkTime(
            Long.valueOf(secondsIncrements),
            Long.valueOf(microsecondsIncrements));
        return keplerSclkEventTime;
    }

    private double getJavaDoubleFormat(String lskDouble) {
        lskDouble = lskDouble.replace("D", "E");
        return Double.parseDouble(lskDouble);
    }

}
