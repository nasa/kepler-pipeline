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

package gov.nasa.kepler.common;

import java.io.ByteArrayInputStream;
import java.io.DataInputStream;
import java.io.IOException;

import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;
import nom.tam.fits.HeaderCardException;
import nom.tam.util.BufferedDataOutputStream;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.junit.Test;

import com.google.common.io.CountingInputStream;

import static gov.nasa.kepler.common.FitsUtils.*;
import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.*;

/**
 * @author Sean McCauliff
 *
 */
public class FitsUtilsTest {

    @Test
    public void safeAddTest() throws Exception {
        Header header = new Header();
        safeAdd(header, "D", Math.PI, "no comment");
        double storedValue = header.getDoubleValue("D");
        assertEquals(Math.PI, storedValue, 0.0);
        
        safeAdd(header, "F", (float) Math.PI, "no comment");
        float floatStoredValue = header.getFloatValue("F");
        assertEquals((float)Math.PI, floatStoredValue, 0.0);
    }
    
    @Test
    public void addEmpty() throws Exception {
        Header header = new Header();
        safeAdd(header, "D", (Double) null, "no comment");
        Double nullDouble = safeGetDoubleField(header, "D");
        assertEquals(null, nullDouble);
        
        safeAdd(header, "F", (Float) null, "no comment");
        Float nullFloat = safeGetFloatField(header, "F");
        assertEquals(null, nullFloat);
        
        safeAdd(header, "S", (String) null, "no comment");
        String nullString = safeGetStringField(header, "S");
        assertEquals(null, nullString);
    }
    
    @Test
    public void formatCardWithIntegers() {
        HeaderCard headerCard = formatCard("K", 7, "%d", "no comment");
        String cardStr = headerCard.toString();
        assertEquals("K       =                    7 / no comment                                     ",
            cardStr);
        
        String truncateMe = "A very long comment which should be truncated in order to test that comment truncation works correctly, which I believe it will.";
        headerCard = formatCard("K", Long.MAX_VALUE, "%d", truncateMe);
        assertEquals(("K       =  9223372036854775807 / " + truncateMe).substring(0, 80), headerCard.toString());
    }
    
    @Test
    public void formatCardWithFloatingPoint() {
        HeaderCard headerCard = formatCard("K2345678", Math.PI, "%10.8f", "PI");
        String cardStr = headerCard.toString();
        
        assertEquals("K2345678=           3.14159265 / PI                                             ",
            cardStr);
        
        headerCard = formatCard("KE", Math.PI, "%+17.13E", "PI");
        cardStr = headerCard.toString();
        assertEquals("KE      = +3.1415926535898E+00 / PI                                             ",
            cardStr);
    }
    
    @Test(expected=IllegalStateException.class)
    public void formatTooLong() {
        formatCard("X", Math.PI, "%+19.15E", "A comment");
    }
    
    @Test(expected=IllegalArgumentException.class)
    public void badCharacterInFormat() {
        formatCard("X", Math.PI, "%e", "Another comment.");
    }
    
    @SuppressWarnings("deprecation")
    @Test
    public void dontFormatDoubleNaN() throws HeaderCardException {
        Header header = new Header();
        safeAdd(header, "K", Double.NaN, "c", "%g");;
        assertEquals("K       =                      / c                                              ",
            header.getCard(0).toString());
    }
    
    @SuppressWarnings("deprecation")
    @Test
    public void dontFormatFloatNaN() throws HeaderCardException {
        Header header = new Header();
        safeAdd(header, "K", Float.NaN, "c", "%g");
        assertEquals("K       =                      / c                                              ",
            header.getCard(0).toString());
    }
    
    @Test(expected=IllegalArgumentException.class)
    public void dontFormatFloatInf() throws HeaderCardException {
        Header header = new Header();
        safeAdd(header, "K", Float.POSITIVE_INFINITY, "c", "%g");
    }
    
    @Test(expected=IllegalArgumentException.class)
    public void dontFormatDoubleInf() throws HeaderCardException {
        Header header = new Header();
        safeAdd(header, "K", Double.POSITIVE_INFINITY, "c", "%g");
    }
    
    /** What a great test name. */
    @Test(expected=IllegalArgumentException.class)
    public void dontFormatDoubleNegativeInf() throws HeaderCardException {
        Header header = new Header();
        safeAdd(header, "K", Double.NEGATIVE_INFINITY, "c", "%g");
    }
    @Test(expected=IllegalArgumentException.class)
    public void dontFormatFloatNegativeInf() throws HeaderCardException {
        Header header = new Header();
        safeAdd(header, "K", Float.NEGATIVE_INFINITY, "c", "%g");
    }
    
    @Test
    public void formatNullHeaderCard() throws Exception {
        Header h = new Header();
        safeAdd(h, "K", (Double)null, "blah blah blah", "%f");
        
        double actual = h.getDoubleValue("K", Math.PI);
        assertEquals(Math.PI, actual, 0.0);
        
        HeaderCard hc = formatNullNumericHeader("K", "blah blah blah");
        assertEquals(
"K       =                      / blah blah blah                                 ",
hc.toString());
    }
    
    private Header generateHeader(int nCards) throws HeaderCardException {
        if (nCards < 3) {
            throw new IllegalArgumentException();
        }
        Header h = new Header();
        h.addValue(SIMPLE_KW, SIMPLE_VALUE, SIMPLE_COMMENT);
        h.addValue(BITPIX_KW, -8, BITPIX_COMMENT);
        h.addValue(NAXIS_KW, 0, NAXIS_COMMENT);
        for (int i=3; i < nCards; i++) {
            switch (i % 3) {
                case 0: h.addValue("BS" + i, i, "test that this is not the END"); break;
                case 1: h.addValue("E"+i, i, "test E is not the END"); break;
                case 2: h.addValue("EN"+i, i, "test EN is not the END"); break;
                default: throw new IllegalStateException();
            }
            
        }
        
        return h;
    }
    
    @Test
    public void testAdvanceToEndOfHeader() throws Exception {
        Header shortHeader = generateHeader(5);
        Header longHeader = generateHeader(1024);
        ByteArrayOutputStream bout = new ByteArrayOutputStream(1024*64);
        BufferedDataOutputStream fitsOut = new BufferedDataOutputStream(bout);
        
        //Write short header.  Data.  Then long header.
        shortHeader.write(fitsOut);
        for (int i=0; i < HDU_BLOCK_SIZE; i++) {
            fitsOut.writeByte((byte) 'A');
        }
        longHeader.write(fitsOut);
        fitsOut.close();
        
        ByteArrayInputStream bin = new ByteArrayInputStream(bout.toByteArray());
        CountingInputStream countIn = new CountingInputStream(bin);
        DataInputStream din = new DataInputStream(countIn);
        advanceToEndOfHeader(din);
        assertEquals(HDU_BLOCK_SIZE, countIn.getCount());
        advanceToEndOfHeader(din);
        assertEquals(HDU_BLOCK_SIZE * 31, countIn.getCount());
        
        try {
            advanceToEndOfHeader(din);
        } catch (IOException good) {
            
        }
    }
}
