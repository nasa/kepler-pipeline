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

package gov.nasa.spiffy.common.collect;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.collect.ArrayUtils;

import org.junit.Test;

public class ArrayUtilsTest {

    @Test
    public void testEquals() {
        String[][] a1 = new String[][] { { "a" } };
        String[][] a2 = new String[][] { { "a" } };
        String[][] b = new String[][] { { "b" } };

        assertTrue(ArrayUtils.equals(a1, a2));
        assertFalse(ArrayUtils.equals(a1, b));
        assertTrue(ArrayUtils.equals(null, null));
        assertFalse(ArrayUtils.equals(a1, null));
        assertFalse(ArrayUtils.equals(null, a1));
    }

    @Test
    public void testFillStringArrayArray() {
        String[][] a = null;
        String[] b = null;
        ArrayUtils.fill(a, b);
        
        a = new String[][] {{}};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);

        a = new String[][] {{"foo"}};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);

        a = new String[][] {{"foo", "bar"}};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);

        a = new String[][] {{"foo", "bar"}};
        b = new String[] {};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);

        a = new String[][] {{"foo", "bar"}};
        b = new String[] {"a", "b"};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);

        a = new String[][] {{"foo", "bar"}, {"foo", "bar"}};
        b = new String[] {"a", "b"};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);

        a = new String[42][];
        b = new String[] {"a", "b"};
        ArrayUtils.fill(a, b);
        assertArrayContains(a, b);
    }
    
    private void assertArrayContains(String[][] a, String[] b) {
        for (String[] aprime : a) {
            assertTrue(aprime == b);
        }
    }

    @Test
    public void testHashCode() {
        String[][] a1 = new String[][] { { "a" } };
        String[][] a2 = new String[][] { { "a" } };
        String[][] b = new String[][] { { "b" } };

        assertEquals(0, ArrayUtils.hashCode(null));
        assertEquals(ArrayUtils.hashCode(a1), ArrayUtils.hashCode(a2));
        assertNotSame(ArrayUtils.hashCode(a1), ArrayUtils.hashCode(b));
    }

    @Test
    public void testByteArrayCompare() {
        byte[] ba1 = new byte[0];
        byte[] ba2 = ba1;
    
        assertEquals(0, ArrayUtils.compareArray(ba1, ba2));
        ba1 = new byte[1];
        assertEquals(1, ArrayUtils.compareArray(ba1, ba2));
        ba2 = new byte[1];
        assertEquals(0, ArrayUtils.compareArray(ba1, ba2));
    
        ba1[0] = -1;
        assertEquals(-1, ArrayUtils.compareArray(ba1, ba2));
    }
}
