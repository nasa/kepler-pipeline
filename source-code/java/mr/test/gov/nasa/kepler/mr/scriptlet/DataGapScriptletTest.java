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

package gov.nasa.kepler.mr.scriptlet;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.mr.scriptlet.DataGapScriptlet.GapFacade;

import org.junit.Test;

/**
 * Tests the {@link DataGapScriptlet} class.
 * 
 * @author Bill Wohler
 */
public class DataGapScriptletTest {

    GapFacade gap[] = new GapFacade[] { new GapFacade(0, false), // 0
        new GapFacade(0, false), // 1
        new GapFacade(1, true), // 2
        new GapFacade(1, true), // 3

        new GapFacade(0, 0, 0, false), // 4
        new GapFacade(0, 0, 0, false), // 5
        new GapFacade(1, 0, 0, false), // 6
        new GapFacade(0, 1, 0, false), // 7
        new GapFacade(0, 0, 1, false), // 8
        new GapFacade(0, 0, 0, true), // 9

        new GapFacade(0, 0, 0, 0, false), // 10
        new GapFacade(1, 0, 0, 0, false), // 11
        new GapFacade(0, 1, 0, 0, false), // 12
        new GapFacade(0, 0, 1, 0, false), // 13
        new GapFacade(0, 0, 0, 1, false), // 14
        new GapFacade(0, 0, 0, 0, true), // 15

        new GapFacade(0, 0, 0, 0, 0, 0, false), // 16
        new GapFacade(0, 0, 0, 0, 0, 0, false), // 17
        new GapFacade(1, 0, 0, 0, 0, 0, false), // 18
        new GapFacade(0, 1, 0, 0, 0, 0, false), // 19
        new GapFacade(0, 0, 1, 0, 0, 0, false), // 20
        new GapFacade(0, 0, 0, 1, 0, 0, false), // 21
        new GapFacade(0, 0, 0, 0, 1, 0, false), // 22
        new GapFacade(0, 0, 0, 0, 0, 1, false), // 23
        new GapFacade(0, 0, 0, 0, 0, 0, true), // 24
        new GapFacade(0, 0, 0, 0, 0, 0, true), // 25

        new GapFacade(0, 0, 0, 0, 2, 0, false), // 26
    };

    @Test
    public void testGapFacadeEquals() {
        assertEquals(gap[0], gap[1]);
        assertFalse(gap[1].equals(gap[2]));
        assertEquals(gap[2], gap[3]);

        assertEquals(gap[4], gap[5]);
        assertFalse(gap[4].equals(gap[6]));
        assertFalse(gap[4].equals(gap[7]));
        assertFalse(gap[4].equals(gap[8]));
        assertFalse(gap[4].equals(gap[9]));

        assertFalse(gap[10].equals(gap[11]));
        assertFalse(gap[10].equals(gap[12]));
        assertFalse(gap[10].equals(gap[13]));
        assertFalse(gap[10].equals(gap[14]));
        assertFalse(gap[10].equals(gap[15]));

        assertEquals(gap[16], gap[17]);
        assertFalse(gap[16].equals(gap[18]));
        assertFalse(gap[16].equals(gap[19]));
        assertFalse(gap[16].equals(gap[20]));
        assertFalse(gap[16].equals(gap[21]));
        assertFalse(gap[16].equals(gap[22]));
        assertFalse(gap[16].equals(gap[23]));
        assertFalse(gap[16].equals(gap[24]));
        assertEquals(gap[24], gap[25]);

        assertFalse(gap[0].equals(gap[4]));
        assertFalse(gap[0].equals(gap[10]));
        assertFalse(gap[0].equals(gap[16]));
    }

    @Test
    public void testGapFacadeHashcode() {
        assertEquals(gap[0].hashCode(), gap[1].hashCode());
        assertFalse(gap[1].hashCode() == gap[2].hashCode());
        assertEquals(gap[2].hashCode(), gap[3].hashCode());

        assertEquals(gap[4].hashCode(), gap[5].hashCode());
        assertFalse(gap[4].hashCode() == gap[6].hashCode());
        assertFalse(gap[4].hashCode() == gap[7].hashCode());
        assertFalse(gap[4].hashCode() == gap[8].hashCode());
        assertFalse(gap[4].hashCode() == gap[9].hashCode());

        assertFalse(gap[10].hashCode() == gap[11].hashCode());
        assertFalse(gap[10].hashCode() == gap[12].hashCode());
        assertFalse(gap[10].hashCode() == gap[13].hashCode());
        assertFalse(gap[10].hashCode() == gap[14].hashCode());
        assertFalse(gap[10].hashCode() == gap[15].hashCode());

        assertEquals(gap[16].hashCode(), gap[17].hashCode());
        assertFalse(gap[16].hashCode() == gap[18].hashCode());
        assertFalse(gap[16].hashCode() == gap[19].hashCode());
        assertFalse(gap[16].hashCode() == gap[20].hashCode());
        assertFalse(gap[16].hashCode() == gap[21].hashCode());
        assertFalse(gap[16].hashCode() == gap[22].hashCode());
        assertFalse(gap[16].hashCode() == gap[23].hashCode());
        assertFalse(gap[16].hashCode() == gap[24].hashCode());
        assertEquals(gap[24].hashCode(), gap[25].hashCode());

        assertFalse(gap[0].hashCode() == gap[4].hashCode());
        assertFalse(gap[0].hashCode() == gap[10].hashCode());
        assertFalse(gap[0].hashCode() == gap[16].hashCode());
    }

    @Test
    public void testGapFacadeCompareTo() {
        assertEquals(0, gap[0].compareTo(gap[1]));
        assertTrue(gap[1].compareTo(gap[2]) < 0);
        assertEquals(0, gap[2].compareTo(gap[3]));

        assertEquals(0, gap[4].compareTo(gap[5]));
        assertTrue(gap[4].compareTo(gap[6]) < 0);
        assertTrue(gap[4].compareTo(gap[7]) < 0);
        assertTrue(gap[4].compareTo(gap[8]) < 0);
        assertTrue(gap[4].compareTo(gap[9]) < 0);

        assertTrue(gap[10].compareTo(gap[11]) < 0);
        assertTrue(gap[10].compareTo(gap[12]) < 0);
        assertTrue(gap[10].compareTo(gap[13]) < 0);
        assertTrue(gap[10].compareTo(gap[14]) < 0);
        assertTrue(gap[10].compareTo(gap[15]) < 0);

        assertEquals(0, gap[16].compareTo(gap[17]));
        assertTrue(gap[16].compareTo(gap[18]) < 0);
        assertTrue(gap[16].compareTo(gap[19]) < 0);
        assertTrue(gap[16].compareTo(gap[20]) < 0);
        assertTrue(gap[16].compareTo(gap[21]) < 0);
        assertTrue(gap[16].compareTo(gap[22]) < 0);
        assertTrue(gap[16].compareTo(gap[23]) < 0);
        assertTrue(gap[16].compareTo(gap[24]) < 0);
        assertEquals(0, gap[24].compareTo(gap[25]));

        assertTrue(gap[22].compareTo(gap[26]) < 0);
    }

    @Test(expected = NullPointerException.class)
    public void testGapFacadeCompareTo1() {
        gap[0].compareTo(gap[4]);
    }

    @Test(expected = NullPointerException.class)
    public void testGapFacadeCompareTo2() {
        gap[0].compareTo(gap[10]);
    }

    @Test(expected = NullPointerException.class)
    public void testGapFacadeCompareTo3() {
        gap[0].compareTo(gap[16]);
    }
}
