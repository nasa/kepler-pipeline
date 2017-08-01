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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.mc.spice.LeapSecondsKernel;
import gov.nasa.kepler.mc.spice.SpiceException;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class LeapSecondsKernelTest {

    @SuppressWarnings("serial")
    static final Map<String, String> KERNEL_DATA = new HashMap<String, String>() {
        {
            put("DELTET/DELTA_T_A", "32.184");
            put("DELTET/K", "1.657D-3");
            put("DELTET/EB", "1.671D-2");
            put("DELTET/M", "6.239996D0   1.99096871D-7");
            put("DELTET/DELTA_AT",
                "10,   @1972-JAN-1\n                           "
                    + "11,   @1972-JUL-1     \n                           "
                    + "12,   @1973-JAN-1     \n                           "
                    + "13,   @1974-JAN-1     \n                           "
                    + "14,   @1975-JAN-1          \n                           "
                    + "15,   @1976-JAN-1          \n                           "
                    + "16,   @1977-JAN-1          \n                           "
                    + "17,   @1978-JAN-1          \n                           "
                    + "18,   @1979-JAN-1          \n                           "
                    + "19,   @1980-JAN-1          \n                           "
                    + "20,   @1981-JUL-1          \n                           "
                    + "21,   @1982-JUL-1          \n                           "
                    + "22,   @1983-JUL-1          \n                           "
                    + "23,   @1985-JUL-1          \n                           "
                    + "24,   @1988-JAN-1 \n                           "
                    + "25,   @1990-JAN-1\n                           "
                    + "26,   @1991-JAN-1 \n                           "
                    + "27,   @1992-JUL-1\n                           "
                    + "28,   @1993-JUL-1\n                           "
                    + "29,   @1994-JUL-1\n                           "
                    + "30,   @1996-JAN-1 \n                           "
                    + "31,   @1997-JUL-1\n                           "
                    + "32,   @1999-JAN-1\n                           "
                    + "33,   @2006-JAN-1\n                           "
                    + "34,   @2009-JAN-1");
        }
    };

    @Test
    public void testGetUtcSecondsSinceEpoch() throws SpiceException {
        double expectedUtcSecondsSinceEpoch = 3.124224000000001E9;

        LeapSecondsKernel leapSecondsKernel = new LeapSecondsKernel(
            KERNEL_DATA, FcConstants.J2000_MJD);

        double actualUtcSecondsSinceEpoch = leapSecondsKernel.getUtcSecondsSinceEpoch(3.124224066183908E9);

        assertEquals(expectedUtcSecondsSinceEpoch, actualUtcSecondsSinceEpoch,
            SpiceTimeTest.CHRONOS_PRECISION_IN_SECONDS);
    }

}
