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

package gov.nasa.kepler.mc.vtc;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.mc.spice.KeplerSclkTime;
import gov.nasa.kepler.mc.spice.SpiceException;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class VtcTimeTest {

    @Test
    public void testGetVtc() throws SpiceException {
        long expectedVtc = 0xFFFFFFFF08L;
        KeplerSclkTime inputKeplerSclkTime = new KeplerSclkTime(0xFFFFFFFFL,
            0x08000L);

        VtcTime vtcOperations = new VtcTime();
        long actualVtc = vtcOperations.getVtc(inputKeplerSclkTime);

        assertEquals(expectedVtc, actualVtc);
    }

    @Test
    public void testGetKeplerSclkTime() throws SpiceException {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(0xFFFFFFFFL,
            0x08000L);
        long inputVtc = 0xFFFFFFFF08L;

        VtcTime vtcOperations = new VtcTime();
        KeplerSclkTime actualKeperSclkTime = vtcOperations.getKeplerSclkTime(inputVtc);

        assertEquals(expectedKeplerSclkTime, actualKeperSclkTime);
    }

    @Test
    public void testRoundTrip() throws SpiceException {
        long expectedVtc = 0xFFFFFFFF0FL;

        VtcTime vtcOperations = new VtcTime();
        KeplerSclkTime keplerSclkTime = vtcOperations.getKeplerSclkTime(expectedVtc);
        long actualVtc = vtcOperations.getVtc(keplerSclkTime);

        assertEquals(expectedVtc, actualVtc);
    }

    @Test
    public void testGetKeplerSclkTimeFromSmokeTest() throws SpiceException {
        KeplerSclkTime expectedKeplerSclkTime = new KeplerSclkTime(293416222L,
            643072L);
        long inputVtc = 75114552989L;

        VtcTime vtcOperations = new VtcTime();
        KeplerSclkTime actualKeperSclkTime = vtcOperations.getKeplerSclkTime(inputVtc);

        assertEquals(expectedKeplerSclkTime, actualKeperSclkTime);
    }

}
