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

import static org.jmock.junit4.MockSupporter.eq;
import static org.jmock.junit4.MockSupporter.once;
import static org.jmock.junit4.MockSupporter.returnValue;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotSame;

import org.jmock.Mock;
import org.jmock.cglib.junit4.MockManager;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the Characteristic class.
 * 
 * @author Bill Wohler
 */
public class CharacteristicTest {

    private static final String DEFAULT_FORMAT = "%.3f";
    private MockManager mockManager;
    private Mock mockCharacteristicCrud;
    private CharacteristicCrud characteristicCrud;
    private int referenceKeplerId;

    @Before
    public void mockCharacteristicCrud() {
        mockManager = new MockManager();
        mockCharacteristicCrud = mockManager.mock(CharacteristicCrud.class);
        characteristicCrud = (CharacteristicCrud) mockCharacteristicCrud.proxy();
        referenceKeplerId = 12345;
    }

    public CharacteristicTest() {
    }

    @Test
    public void testConstructorsAndAccessors() {
        CharacteristicType type = new CharacteristicType("type1", "%.3f");
        assertEquals(type.getName(), "type1");
        assertEquals(type.getFormat(), "%.3f");

        Characteristic characteristic = new Characteristic(referenceKeplerId,
            type, 5.000);
        assertEquals(characteristic.getKeplerId(), referenceKeplerId);
        assertEquals(characteristic.getType(), type);
        assertEquals(characteristic.getValue(), 5.000, 0);
    }

    @Test
    public void testEquals() {
        CharacteristicType type1 = new CharacteristicType("type1", "%.3f");
        CharacteristicType type1a = new CharacteristicType("type1", "%.5f");
        CharacteristicType type2 = new CharacteristicType("type2", "%.3f");

        assertEquals(type1, type1a);
        assertFalse(type1.equals(type2));

        Characteristic char1 = new Characteristic(referenceKeplerId, type1,
            5.000);
        Characteristic char1a = new Characteristic(referenceKeplerId, type1,
            5.000);
        Characteristic char1b = new Characteristic(referenceKeplerId, type1a,
            5.000);
        Characteristic char2 = new Characteristic(referenceKeplerId, type1,
            6.000);

        assertEquals(char1, char1a);
        assertEquals(char1, char1b);
        assertFalse(char1.equals(char2));
    }

    @Test
    public void testHashCode() {
        CharacteristicType type1 = new CharacteristicType("type1", "%.3f");
        CharacteristicType type2 = new CharacteristicType("type1", "%.5f");
        CharacteristicType type3 = new CharacteristicType("type2", "%.3f");

        assertEquals(type1.hashCode(), type2.hashCode());
        assertNotSame(type1.hashCode(), type3.hashCode());

        Characteristic char1 = new Characteristic(referenceKeplerId, type1,
            5.000);
        Characteristic char2 = new Characteristic(referenceKeplerId, type1,
            5.000);
        Characteristic char3 = new Characteristic(referenceKeplerId, type2,
            5.000);
        Characteristic char4 = new Characteristic(referenceKeplerId, type1,
            6.000);

        assertEquals(char1.hashCode(), char2.hashCode());
        assertNotSame(char1.hashCode(), char3.hashCode());
        assertNotSame(char1.hashCode(), char4.hashCode());
    }

    @Test(expected = NullPointerException.class)
    public void testValueOfNull() throws Exception {
        Characteristic.valueOf(null, characteristicCrud);
        mockManager.verify();
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfEmptyString() throws Exception {
        Characteristic.valueOf("", characteristicCrud); // no fields at all
        mockManager.verify();
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfNotEnoughFields() throws Exception {
        Characteristic.valueOf("|", characteristicCrud); // not enough fields
        mockManager.verify();
    }

    @Test(expected = ArrayIndexOutOfBoundsException.class)
    public void testValueOfMissingRequiredFields() throws Exception {
        // Right number of fields, but missing required fields.
        Characteristic.valueOf("||", characteristicCrud);
        Characteristic.valueOf("12345||", characteristicCrud);
        Characteristic.valueOf("12345|Some type|", characteristicCrud);
        mockManager.verify();
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValueOfUnknownCharacteristicType() throws Exception {
        mockCharacteristicCrud.expects(once())
            .method("retrieveCharacteristicType")
            .with(eq("Not in database"))
            .will(returnValue(null));
        Characteristic.valueOf("12345|Not in database|5.0", characteristicCrud);
        mockManager.verify();
    }

    @Test
    public void testValueOf() throws Exception {
        mockCharacteristicCrud.expects(once())
            .method("retrieveCharacteristicType")
            .will(
                returnValue(new CharacteristicType("Some type", DEFAULT_FORMAT)));

        // Format for 5.000 matches DEFAULT_FORMAT.
        String s = "12345|Some type|5.000";
        assertEquals(s, Characteristic.valueOf(s, characteristicCrud)
            .toString());
        mockManager.verify();
    }

    @Test
    public void testToString() throws Exception {
        String[] expected = { "1|c|12345678", "1|c|10.1", "1|c|+1.23E-10" };
        float[] value = { 12345678.1f, 10.1111f, .0000000001234f };
        String[] format = { "%d", "%3.1f", "%+3.2E" };
        for (int i = 0; i < expected.length; i++) {
            testToString(expected[i], value[i], format[i]);
        }
    }

    private void testToString(String expected, float value, String format) {
        CharacteristicType cType = new CharacteristicType("c", format);
        Characteristic characteristic = new Characteristic(1, cType, value);
        String actual = characteristic.toString();
        assertEquals("format " + format, expected, actual);
    }
}
