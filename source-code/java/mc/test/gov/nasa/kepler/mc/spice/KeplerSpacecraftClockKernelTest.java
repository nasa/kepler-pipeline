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

import gov.nasa.kepler.mc.spice.KeplerSclkTime;
import gov.nasa.kepler.mc.spice.KeplerSpacecraftClockKernel;
import gov.nasa.kepler.mc.spice.SpiceException;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class KeplerSpacecraftClockKernelTest {

    @SuppressWarnings("serial")
    static final Map<String, String> KERNEL_DATA = new HashMap<String, String>() {
        {
            put("SCLK_KERNEL_ID", "@2008-178T19:38:43");
            put("SCLK_DATA_TYPE_227", "1");
            put("SCLK01_TIME_SYSTEM_227", "1");
            put("SCLK01_N_FIELDS_227", "2");
            put("SCLK01_MODULI_227", "4294967296 1000000");
            put("SCLK01_OFFSETS_227", "0 0");
            put("SCLK01_OUTPUT_DELIM_227", "1");
            put("SCLK_PARTITION_START_227", "0.0000000000000E+00");
            put("SCLK_PARTITION_END_227", "4.9085352651836E+15");
            put("SCLK01_COEFFICIENTS_227",
                "0.0000000000000E+00     0.0000000000000E+01     1.0000000000000E+00\n    "
                    + "2.6815469776334E+14     2.6788326518419E+08     9.9898777615528E-01\n    "
                    + "4.6815469776334E+14     4.6778082041524E+08     1.0010122240000E+00");
        }
    };

    @Test
    public void testGetEphemeralSecondsSinceEpoch() throws SpiceException {

        double expectedEphemeralSecondsSinceEpoch = 3.129707548721596E9;

        KeplerSpacecraftClockKernel clockKernel = new KeplerSpacecraftClockKernel(
            KERNEL_DATA);

        double actualEphemeralSecondsSinceEpoch = clockKernel.getEphemeralSecondsSinceEpoch(new KeplerSclkTime(
            3127389684L, 594386L));

        assertEquals(expectedEphemeralSecondsSinceEpoch,
            actualEphemeralSecondsSinceEpoch,
            SpiceTimeTest.CHRONOS_PRECISION_IN_SECONDS);
    }

}
