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

package gov.nasa.kepler.hibernate.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotSame;

import org.junit.Test;

/**
 * Tests the CatKey class.
 * 
 * @author Bill Wohler
 */
public class CatKeyTest {

    @Test
    public void testAccessors() {
        CatKey catKey = new CatKey(42, 43, Integer.valueOf(44),
            Integer.valueOf(45), Integer.valueOf(46), "source",
            Integer.valueOf(47), Integer.valueOf(48), Integer.valueOf(49),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        assertEquals(42, catKey.getId());
        assertEquals(43, catKey.getFlag());
        assertEquals(44, (int) catKey.getTychoId());
        assertEquals(45, (int) catKey.getUcacId());
        assertEquals(46, (int) catKey.getGcvsId());
        assertEquals("source", catKey.getSource());
        assertEquals(47, (int) catKey.getSourceId());
        assertEquals(48, (int) catKey.getFirstFlux());
        assertEquals(49, (int) catKey.getSecondFlux());
        assertEquals(50.1, catKey.getRaEpoch(), .0001);
        assertEquals(50.2, catKey.getDecEpoch(), .0001);
        assertEquals(50.3, catKey.getJMag(), .0001);
        assertEquals(50.4, catKey.getHMag(), .0001);
        assertEquals(50.5, catKey.getKMag(), .0001);
    }

    @Test
    public void testEquals() {
        CatKey catKey = new CatKey(42, 43, Integer.valueOf(44),
            Integer.valueOf(45), Integer.valueOf(46), "source",
            Integer.valueOf(47), Integer.valueOf(48), Integer.valueOf(49),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        assertEquals(
            catKey,
            new CatKey(42, 43, Integer.valueOf(44), Integer.valueOf(45),
                Integer.valueOf(46), "source", Integer.valueOf(47),
                Integer.valueOf(48), Integer.valueOf(49),
                Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
                Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
                Float.valueOf((float) 50.5)));
        assertFalse(catKey.equals(new CatKey(422, 43, Integer.valueOf(44),
            Integer.valueOf(45), Integer.valueOf(46), "source",
            Integer.valueOf(47), Integer.valueOf(48), Integer.valueOf(49),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5))));
    }

    @Test
    public void testHashCode() {
        CatKey catKey = new CatKey(42, 43, Integer.valueOf(44),
            Integer.valueOf(45), Integer.valueOf(46), "source",
            Integer.valueOf(47), Integer.valueOf(48), Integer.valueOf(49),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        assertEquals(
            catKey.hashCode(),
            new CatKey(42, 43, Integer.valueOf(44), Integer.valueOf(45),
                Integer.valueOf(46), "source", Integer.valueOf(47),
                Integer.valueOf(48), Integer.valueOf(49),
                Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
                Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
                Float.valueOf((float) 50.5)).hashCode());
        assertNotSame(
            catKey.hashCode(),
            new CatKey(422, 43, Integer.valueOf(44), Integer.valueOf(45),
                Integer.valueOf(46), "source", Integer.valueOf(47),
                Integer.valueOf(48), Integer.valueOf(49),
                Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
                Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
                Float.valueOf((float) 50.5)).hashCode());
    }

    @Test(expected = NullPointerException.class)
    public void testValueOfNull() throws Exception {
        CatKey.valueOf(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValueOfEmptyString() throws Exception {
        CatKey.valueOf(""); // no fields at all
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValueOfNotEnoughFields() throws Exception {
        CatKey.valueOf("|"); // not enough fields
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfMissingRequiredFields1() throws Exception {
        // Right number of fields, but missing required fields.
        CatKey.valueOf("|||||||||||||");
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfMissingRequiredFields2() throws Exception {
        // Right number of fields, but missing required fields.
        CatKey.valueOf("42|||||||||||||");
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfMissingRequiredFields3() throws Exception {
        // Right number of fields, but missing required fields.
        CatKey.valueOf("42|43||||||||||||");
    }

    @Test
    public void testValueOf() throws Exception {
        // Minimum required fields.
        String s = "42|43||||source||||||||";
        assertEquals(s, CatKey.valueOf(s)
            .toString());
        // All fields populated using bogus data.
        s = "42|43|44|45|46|source|47|48|49|50.100|50.200|50.300|50.400|50.500";
        assertEquals(s, CatKey.valueOf(s)
            .toString());
        // Populate as many fields as possible with values from real data.
        s = "6|4100|618568|44506469|93|STAR|2056979|3500||2000.200|2000.200|15.451|14.676|14.126";
        assertEquals(s, CatKey.valueOf(s)
            .toString());
    }
}
