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
 * Tests the ScpKey class.
 * 
 * @author Bill Wohler
 */
public class ScpKeyTest {

    @Test
    public void testAccessors() {
        ScpKey scpKey = new ScpKey(42, Double.valueOf(42.1),
            Double.valueOf(42.2), Integer.valueOf(45), Integer.valueOf(46),
            Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
            Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        assertEquals(42, scpKey.getId());
        assertEquals(42.1, scpKey.getFiberRa(), 0);
        assertEquals(42.2, scpKey.getFiberDec(), 0);
        assertEquals(45, (int) scpKey.getEffectiveTemp());
        assertEquals(46, (int) scpKey.getEffectiveTempErr());
        assertEquals(42.3, scpKey.getLog10SurfaceGravity(), .0001);
        assertEquals(42.4, scpKey.getLog10SurfaceGravityErr(), .0001);
        assertEquals(42.5, scpKey.getLog10Metallicity(), .0001);
        assertEquals(42.6, scpKey.getLog10MetallicityErr(), .0001);
        assertEquals(50.1, scpKey.getRotationalVelocitySin(), .0001);
        assertEquals(50.2, scpKey.getRotationalVelocitySinErr(), .0001);
        assertEquals(50.3, scpKey.getRadialVelocity(), .0001);
        assertEquals(50.4, scpKey.getRadialVelocityErr(), .0001);
        assertEquals(50.5, scpKey.getCrossCorrelationPeak(), .0001);
    }

    @Test
    public void testEquals() {
        ScpKey scpKey = new ScpKey(42, Double.valueOf(42.1),
            Double.valueOf(42.2), Integer.valueOf(45), Integer.valueOf(46),
            Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
            Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        assertEquals(
            scpKey,
            new ScpKey(42, Double.valueOf(42.1), Double.valueOf(42.2),
                Integer.valueOf(45), Integer.valueOf(46),
                Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
                Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
                Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
                Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
                Float.valueOf((float) 50.5)));
        assertFalse(scpKey.equals(new ScpKey(422, Double.valueOf(42.1),
            Double.valueOf(42.2), Integer.valueOf(45), Integer.valueOf(46),
            Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
            Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5))));
    }

    @Test
    public void testHashCode() {
        ScpKey scpKey = new ScpKey(42, Double.valueOf(42.1),
            Double.valueOf(42.2), Integer.valueOf(45), Integer.valueOf(46),
            Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
            Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        assertEquals(
            scpKey.hashCode(),
            new ScpKey(42, Double.valueOf(42.1), Double.valueOf(42.2),
                Integer.valueOf(45), Integer.valueOf(46),
                Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
                Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
                Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
                Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
                Float.valueOf((float) 50.5)).hashCode());
        assertNotSame(
            scpKey.hashCode(),
            new ScpKey(422, Double.valueOf(42.1), Double.valueOf(42.2),
                Integer.valueOf(45), Integer.valueOf(46),
                Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
                Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
                Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
                Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
                Float.valueOf((float) 50.5)).hashCode());
    }

    @Test(expected = NullPointerException.class)
    public void testValueOfNull() throws Exception {
        ScpKey.valueOf(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValueOfEmptyString() throws Exception {
        ScpKey.valueOf(""); // no fields at all
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValueOfNotEnoughFields() throws Exception {
        ScpKey.valueOf("|"); // not enough fields
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfMissingRequiredFields() throws Exception {
        // Right number of fields, but missing required fields.
        ScpKey.valueOf("|||||||||||||");
    }

    @Test
    public void testValueOf() throws Exception {
        // Minimum required fields.
        String s = "42|||||||||||||";
        assertEquals(s, ScpKey.valueOf(s)
            .toString());
        // All fields populated using bogus data.
        s = "42|42.1000000|42.200000|45|46|42.300|42.400|42.500|42.600|50.10|50.200|50.300|50.400|50.500";
        assertEquals(s, ScpKey.valueOf(s)
            .toString());
        // Populate as many fields as possible with values from real data.
        s = "262005541|18.7058315|42.856918|5984||4.660||0.000||9.16||||0.990";
        assertEquals(s, ScpKey.valueOf(s)
            .toString());
    }
}
