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

package gov.nasa.spiffy.common.lang;

import static org.junit.Assert.*;

import java.util.Date;

import gov.nasa.spiffy.common.lang.StringUtils;

import org.junit.Test;

/**
 * Tests the {@link StringUtils} class.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class StringUtilsTest {

    @Test(expected = NullPointerException.class)
    public void testConstantToHyphenSeparatedLowercaseNull() {
        StringUtils.constantToHyphenSeparatedLowercase(null);
    }

    @Test
    public void testConstantToHyphenSeparatedLowercase() {
        assertEquals("", StringUtils.constantToHyphenSeparatedLowercase(""));
        assertEquals("foo", StringUtils.constantToHyphenSeparatedLowercase("foo"));
        assertEquals("foo-bar", StringUtils.constantToHyphenSeparatedLowercase("foo_bar"));
        assertEquals("-foo-bar-", StringUtils.constantToHyphenSeparatedLowercase("_foo_bar_"));
        assertEquals("foo", StringUtils.constantToHyphenSeparatedLowercase("FOO"));
        assertEquals("foo-bar", StringUtils.constantToHyphenSeparatedLowercase("FOO_BAR"));
        assertEquals("-foo-bar-", StringUtils.constantToHyphenSeparatedLowercase("_FOO_BAR_"));
    }
    
    @Test
    public void testToHexString() {
        String s = StringUtils.toHexString(new byte[0], 0, 0);
        assertEquals("",s);
        
        byte[] md5 = new byte[] { (byte)0xcd, (byte)0xe1, (byte)0xb9, (byte)0x6c, (byte)0x1b, (byte)0x79, (byte)0xfc, 
            (byte)0x62, (byte)0x18, (byte)0x55, (byte)0x28, (byte)0x3e, (byte)0xae, (byte)0x37, (byte)0x0d, (byte)0x0c};
        assertEquals(16, md5.length);
        s = StringUtils.toHexString(md5, 0, md5.length);
        assertEquals("cde1b96c1b79fc621855283eae370d0c", s);
    }
    
    @Test(expected=java.lang.IllegalArgumentException.class)
    public void testToHexStringBadLen() {
        StringUtils.toHexString(new byte[2], 0, 3);
    }
    
    @Test(expected=java.lang.IllegalArgumentException.class)
    public void testToHexStringBadOff() {
        StringUtils.toHexString(new byte[2], 10, 1);
    }
    
    @Test
    public void testTruncate() {
        assertEquals(null, StringUtils.truncate(null, 10));
        assertSame("s", StringUtils.truncate("s", 10));
        assertEquals("012345", StringUtils.truncate("0123456789", 6));
    }
    
    @Test
    public void testConvertStringArray() {
        String[] array = StringUtils.convertStringArray("a, b, c");
        assertArrayEquals(new String[] {"a", "b", "c"}, array);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testConvertStringArrayWithNullString() {
        StringUtils.convertStringArray(null);
    }
    
    @Test
    public void testConstantToAcronym() {
        String acronym = StringUtils.constantToAcronym("FOO_BAR");
        assertEquals("fb", acronym);
    }
    
    @Test
    public void testConstantToAcronymWithLeadingUnderscore() {
        String acronym = StringUtils.constantToAcronym("_FOO_BAR");
        assertEquals("fb", acronym);
    }
    
    @Test
    public void testConstantToAcronymWithEmptyString() {
        String acronym = StringUtils.constantToAcronym("");
        assertEquals("", acronym);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testConstantToAcronymWithNullString() {
        StringUtils.constantToAcronym(null);
    }

    @Test
    public void testConstantToCamel() {
        String camel = StringUtils.constantToCamel("FOO_BAR");
        assertEquals("FooBar", camel);
    }
    
    @Test
    public void testConstantToCamelWithLeadingUnderscore() {
        String camel = StringUtils.constantToCamel("_FOO_BAR");
        assertEquals("FooBar", camel);
    }
    
    @Test
    public void testConstantToCamelWithEmptyString() {
        String camel = StringUtils.constantToCamel("");
        assertEquals("", camel);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testConstantToCamelWithNullString() {
        StringUtils.constantToCamel(null);
    }
    
    @Test
    public void testConstantToCamelWithSpaces() {
        String camel = StringUtils.constantToCamelWithSpaces("FOO_BAR");
        assertEquals("Foo Bar", camel);
    }
    
    @Test
    public void testConstantToCamelWithSpacesWithLeadingUnderscore() {
        String camel = StringUtils.constantToCamelWithSpaces("_FOO_BAR");
        assertEquals("Foo Bar", camel);
    }
    
    @Test
    public void testConstantToCamelWithSpacesWithEmptyString() {
        String camel = StringUtils.constantToCamelWithSpaces("");
        assertEquals("", camel);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testConstantToCamelWithSpacesWithNullString() {
        StringUtils.constantToCamelWithSpaces(null);
    }
    
    @Test
    public void testElapsedTime() {
        String elapsedTime = StringUtils.elapsedTime(1000, 2000);
        assertEquals("00:00:01", elapsedTime);
    }
    
    @Test
    public void testElapsedTimeFromStartToCurrent() {
        String elapsedTime = StringUtils.elapsedTime(1000, 0);
        
        // The exact string is unknown, so just check that it is something large.
        assertTrue(elapsedTime.length() > 11);
    }
    
    @Test
    public void testElapsedTimeWithUninitializedStartTime() {
        String elapsedTime = StringUtils.elapsedTime(0, 2000);
        assertEquals("-", elapsedTime);
    }
    
    @Test
    public void testElapsedTimeWithDates() {
        String elapsedTime = StringUtils.elapsedTime(new Date(1000), new Date(2000));
        assertEquals("00:00:01", elapsedTime);
    }
    
    @Test(expected = IllegalArgumentException.class)
    public void testElapsedTimeWithDatesWithNullStartTime() {
        StringUtils.elapsedTime(null, new Date(2000));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testElapsedTimeWithDatesWithNullEndTime() {
        StringUtils.elapsedTime(new Date(1000), null);
    }
    
}
