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

import java.io.ByteArrayOutputStream;
import java.io.DataInput;
import java.io.IOException;
import java.nio.charset.Charset;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;
import java.util.regex.Pattern;

import nom.tam.fits.*;
import nom.tam.util.BufferedDataOutputStream;
import nom.tam.util.Cursor;
import static gov.nasa.kepler.common.FitsConstants.*;
import static gov.nasa.kepler.common.SipWcsCoordinates.*;

/**
 * FITS utilities
 * 
 * @author tklaus
 * @author Sean McCauliff
 * 
 */
public class FitsUtils {

    private static final Pattern keywordPattern =
        Pattern.compile("[0-9A-Z\\-_]{1,8}");
    private static final Pattern hasNumericValuePattern = 
        Pattern.compile("[0-9A-Z\\-_ ]{8}= +[0-9.E+\\-]+");
    
    private static final int MAX_KEYWORD_LENGTH = 8;
    
    private static final byte ASCII_E = (byte) 'E';
    private static final byte ASCII_N = (byte) 'N';
    private static final byte ASCII_D = (byte) 'D';
    
    private static final TimeZone UTC = TimeZone.getTimeZone("UTC");
    
    enum BinaryTableDataType {
        Single('E', "single precision fp"), 
        Double('D', "double precision fp"), 
        Int32('J', "32 bit signed int");
        
        private BinaryTableDataType(char form, String humanString) {
            this.form = form;
            this.humanString = humanString;
        }
        
        private final char form;
        private final String humanString;
        
        public String humanString() {
            return humanString;
        }
        
        /**
         * 
         * @param fitsForm  This is the contents of the TFORMn field.
         * @return
         */
        public static BinaryTableDataType fromFits(String fitsForm) {
            int formi = 0;
            for (; formi < fitsForm.length(); formi++) {
                if (!Character.isDigit(fitsForm.charAt(formi))) {
                    break;
                }
            }
            if (formi >= fitsForm.length()) {
                throw new IllegalArgumentException("Invalid TFORMn \"" + 
                    fitsForm + "\".");
            }
            for (BinaryTableDataType type : values()) {
                if (type.form == fitsForm.charAt(formi)) {
                    return type;
                }
            }
            throw new IllegalArgumentException("Invalid TFORMn \"" + 
                fitsForm + "\".");
        }
    }
    private FitsUtils() {
    }

    /**
     * Adds or overwrites a keyword to a header with the specified value.  If 
     * value is null then this adds a keyword
     * without a value, but they keyword is still present in the FITS header.
     * 
     * @param header May not be null
     * @param keyWord May not be null
     * @param value  May be null.
     * @param comment  Must not be null.
     * @throws HeaderCardException
     */
    public static void safeAdd(Header header, String keyWord, String value,
        String comment) throws HeaderCardException {

        if (header == null) {
            throw new NullPointerException("header is null");
        }
        if (keyWord == null) {
            throw new NullPointerException("keyWord is null");
        }
        if (comment == null) {
            throw new NullPointerException("comment is null");
        }
        
        try {
            if (value == null) {
                HeaderCard headerCard = formatNullStringHeader(keyWord, comment);
                header.addLine(headerCard);
            } else {
                header.addLine(new HeaderCard(keyWord, value, comment));
            }
        } catch (HeaderCardException hcx) {
            HeaderCardException hcxWithInformation = 
                    new HeaderCardException("keyword \"" + keyWord + "\" value \"" + value);
            hcxWithInformation.initCause(hcx);
            throw hcxWithInformation;
        }
    }

    /**
     * Adds or overwrites a keyword to a header with the specified value.  If 
     * value is null then this adds a keyword
     * without a value, but they keyword is still present in the FITS header.
     * 
     * @param header May not be null
     * @param keyWord May not be null
     * @param value  May be null.
     * @param comment  Must not be null.
     * @throws HeaderCardException
     */
    public static void safeAdd(Header header, String keyWord, Integer value,
        String comment) throws HeaderCardException {
        safeAdd(header, keyWord, value, comment, null);
    }

    /**
     * Adds or overwrites a keyword to a header with the specified value.  If 
     * value is null then this adds a keyword
     * without a value, but they keyword is still present in the FITS header.
     * 
     * @param header May not be null
     * @param keyWord May not be null
     * @param value  May be null.
     * @param comment  Must not be null.
     * @throws HeaderCardException
     */
    public static void safeAdd(Header header, String keyWord, Float value,
        String comment) throws HeaderCardException {

        safeAdd(header, keyWord, value, comment, null);
    }

    /**
     * Like safeAdd(header, keyWord, value, comment, null);
     */
    public static void safeAdd(Header header, String keyWord, Double value,
        String comment) throws HeaderCardException {
        safeAdd(header, keyWord, value, comment, null);
    }
    
    /**
     * Adds or overwrites a keyword to a header with the specified value.  If 
     * value is null then this adds a keyword
     * without a value, but the keyword is still present in the FITS header.
     * 
     * @param header May not be null
     * @param keyWord May not be null
     * @param value  May be null.
     * @param comment  Must not be null.
     * @param format The C-style % format for this value.  This may be null in which
     * case this will use the default formatting as provided by the FITS library.
     * @throws HeaderCardException
     */
    public static void safeAdd(Header header, String keyWord, Double value,
        String comment, String format) throws HeaderCardException {

        if (value == null || value.isNaN()) {
            HeaderCard headerCard = formatNullNumericHeader(keyWord, comment);
            header.addLine(headerCard);
        } else if (value.isInfinite()) {
            throw new IllegalArgumentException("Can't write " + value +
                " as value for keyword \"" + keyWord + "\".");
        } else if (format == null){
            header.addValue(keyWord, value, comment);
        } else {
            HeaderCard headerCard = formatCard(keyWord, value, format, comment);
            header.addLine(headerCard);
        }
    }
    
    /**
     * Adds or overwrites a keyword to a header with the specified value.  If 
     * value is null then this adds a keyword
     * without a value, but the keyword is still present in the FITS header.
     * 
     * @param header May not be null
     * @param keyWord May not be null
     * @param value  May be null.
     * @param comment  Must not be null.
     * @param format The C-style % format for this value.  This may be null in which
     * case this will use the default formatting as provided by the FITS library.
     * @throws HeaderCardException
     */
    public static void safeAdd(Header header, String keyWord, Float value,
        String comment, String format) throws HeaderCardException {

        if (value == null || value.isNaN()) {
            HeaderCard headerCard = formatNullNumericHeader(keyWord, comment);
            header.addLine(headerCard);
        } else if (value.isInfinite()) {
            throw new IllegalArgumentException("Can't write " + value +
                " as value for keyword \"" + keyWord + "\".");
        } else if (format == null){
            header.addValue(keyWord, value, comment);
        } else {
            HeaderCard headerCard = formatCard(keyWord, value, format, comment);
            header.addLine(headerCard);
        }
    }
    
    /**
     * Adds or overwrites a keyword to a header with the specified value.  If 
     * value is null then this adds a keyword
     * without a value, but the keyword is still present in the FITS header.
     * 
     * @param header May not be null
     * @param keyWord May not be null
     * @param value  May be null.
     * @param comment  Must not be null.
     * @param format The C-style % format for this value.  This may be null in which
     * case this will use the default formatting as provided by the FITS library.
     * @throws HeaderCardException
     */
    public static void safeAdd(Header header, String keyWord, Integer value,
        String comment, String format) throws HeaderCardException {

        if (value == null) {
            HeaderCard headerCard = formatNullNumericHeader(keyWord, comment);
            header.addLine(headerCard);
        } else if (format == null){
            header.addValue(keyWord, value, comment);
        } else {
            HeaderCard headerCard = formatCard(keyWord, value, format, comment);
            header.addLine(headerCard);
        }
    }
    
    public static HeaderCard formatCard(String keyWord, Number value, String format, String comment) {
        if (keyWord == null) {
            throw new NullPointerException("keyWord may not be null.");
        }
        if (format == null) {
            throw new NullPointerException("format may not be null");
        }
        
        if (!keywordPattern.matcher(keyWord).matches()) {
            throw new IllegalArgumentException("Invalid FITS keyword \"" 
                + keyWord + "\".");
        }
    
        StringBuilder bldr = new StringBuilder(HEADER_CARD_LENGTH);
        bldr.append(keyWord);
        for (int i=keyWord.length(); i < MAX_KEYWORD_LENGTH; i++) {
            bldr.append(' ');
        }

        if (value != null) {
            bldr.append("= ");
            String formattedValue = String.format(format, value);
            if (formattedValue.length() > 20) {
                throw new IllegalStateException("Too many characters for FITS " +
                        "numeric keyword value: " + formattedValue);
            }
            if (formattedValue.indexOf('e') != -1) {
                throw new IllegalArgumentException("Format \"" + format + 
                    "\" allows for lower case exponent, which is not valid FITS.");
            }
            //right justify
            for (int i=10; i < (30 - formattedValue.length()); i++) {
                bldr.append(' ');
            }
            bldr.append(formattedValue);
        }
        
        if (comment != null) {
            if (comment.length() + bldr.length() > HEADER_CARD_LENGTH) {
                comment = comment.substring(0, HEADER_CARD_LENGTH - bldr.length() - 1);
            }
            bldr.append('/');
            bldr.append(comment);
        }

        //pad end
        for (int i=bldr.length(); i < HEADER_CARD_LENGTH; i++) {
            bldr.append(' ');
        }
        
        if (bldr.length() != HEADER_CARD_LENGTH) {
            throw new IllegalStateException("Internal errors." +
                    "  Malformed header card.");
        }
        
        return new HeaderCard(bldr.toString()); 
    }

    public static HeaderCard formatNullNumericHeader(String keyword, String comment) {
        if (keyword == null) {
            throw new NullPointerException("keyword");
        }
        if (!keywordPattern.matcher(keyword).matches()) {
            throw new IllegalArgumentException("Invalid FITS keyword \"" 
                + keyword + "\".");
        }
        StringBuilder bldr = new StringBuilder(HEADER_CARD_LENGTH);
        bldr.append(keyword);
        for (int i=bldr.length(); i < MAX_KEYWORD_LENGTH; i++) {
            bldr.append(' ');
        }
        bldr.append("= ");
        for (int i=bldr.length(); i <= 31; i++) {
            bldr.append(' ');
        }
        bldr.append("/ ");
        if (comment != null) {
            bldr.append(comment);
        }
        for (int i=bldr.length(); i < HEADER_CARD_LENGTH; i++) {
            bldr.append(' ');
        }
        bldr.setLength(HEADER_CARD_LENGTH);
        return new HeaderCard(bldr.toString());
    }
    
    
    public static HeaderCard formatNullStringHeader(String keyword, String comment) {
        StringBuilder bldr = new StringBuilder(HEADER_CARD_LENGTH);
        bldr.append(keyword);
        for (int i=bldr.length(); i < MAX_KEYWORD_LENGTH; i++) {
            bldr.append(' ');
        }
        bldr.append("= ");
        bldr.append("'' / ");
        bldr.append(comment);
        for (int i=bldr.length(); i < HEADER_CARD_LENGTH; i++) {
            bldr.append(' ');
        }
        bldr.setLength(HEADER_CARD_LENGTH);
        return new HeaderCard(bldr.toString());
    }
    
    /**
     * 
     * @param header
     * @param keyWord
     * @return  May return null if the the HeaderCard does not have a value set.
     */
    public static Float safeGetFloatField(Header header, String keyWord) {
        HeaderCard headerCard = header.findCard(keyWord);
        if (headerCard == null) {
            return null;
        }
        if (!hasNumericValuePattern.matcher(headerCard.toString()).matches()) {
            return null;
        }
        return header.getFloatValue(keyWord);
    }
    
    /**
     * @return May return null if the HeaderCard does not have a value set or does
     * if the string length is zero.
     */
    public static String safeGetStringField(Header header, String keyWord) {
        if (header.findCard(keyWord) == null) return null;
        String s = header.getStringValue(keyWord);
        if (s.length() == 0) {
            return null;
        }
        return s;
    }
    
    /**
     * @return May return null if the HeaderCard does not have a value set.
     */
    public static Integer safeGetIntegerField(Header header, String keyWord) {
        HeaderCard headerCard = header.findCard(keyWord);
        if (headerCard == null) {
            return null;
        }
        if (!hasNumericValuePattern.matcher(headerCard.toString()).find()) {
            return null;
        }
        return header.getIntValue(keyWord);
    }
    
    /**
     * @return May return null if the HeaderCard does not have a value set.
     */
    public static Double safeGetDoubleField(Header header, String keyWord) {
        HeaderCard headerCard = header.findCard(keyWord);
        if (headerCard == null) {
            return null;
        }
        if (!hasNumericValuePattern.matcher(headerCard.toString()).find()) {
            return null;
        }
        return header.getDoubleValue(keyWord);
    }
    
    
    /**
     * Throws an exception if the specified key is not present else returns
     * that value.
     * 
     * @param header
     * @param key
     * @return
     * @throws FitsException
     */
    public static String getHeaderStringValueChecked(Header header, String key)
        throws FitsException {
        if (!header.containsKey(key)) {
            throw new FitsException("Required key: " + key
                + " not found in FITS header");
        }
        return header.getStringValue(key);
    }

    /**
     * Throws an exception if the specified key is not present else returns
     * that value.
     * 
     * @param header
     * @param key
     * @return
     * @throws FitsException
     */
    public static int getHeaderIntValueChecked(Header header, String key)
        throws FitsException {
        if (!header.containsKey(key)) {
            throw new FitsException("Required key: " + key
                + " not found in FITS header");
        }
        return header.getIntValue(key);
    }

    /**
     * Throws an exception if the specified key is not present else returns
     * that value.
     * 
     * @param header
     * @param key
     * @return
     * @throws FitsException
     */
    public static float getHeaderFloatValueChecked(Header header, String key)
        throws FitsException {
        if (!header.containsKey(key)) {
            throw new FitsException("Required key: " + key
                + " not found in FITS header");
        }
        return header.getFloatValue(key);
    }
    
    /**
     * Throws an exception if the specified key is not present else returns
     * that value.
     * 
     * @param header
     * @param key
     * @return
     * @throws FitsException
     */
    public static double getHeaderDoubleValueChecked(Header header, String key)
        throws FitsException {
        if (!header.containsKey(key)) {
            throw new FitsException("Required key: " + key
                + " not found in FITS header");
        }
        return header.getDoubleValue(key);
    }

    /**
     * Throws an exception if the specified key is not present else returns
     * that value.
     * 
     * @param header
     * @param key
     * @return
     * @throws FitsException
     */
    public static boolean getHeaderBooleanValueChecked(Header header, String key)
        throws FitsException {
        if (!header.containsKey(key)) {
            throw new FitsException("Required key: " + key
                + " not found in FITS header");
        }
        return header.getBooleanValue(key);
    }
    
    /**
     * Create header from data without the TXXX fields so they can be inserted
     * manually, at a later time.
     * @param fitsBinaryData
     * @return
     * @throws FitsException
     * @throws HeaderCardException
     */
    @Deprecated
    public static Header manufactureBinaryTableHeader(BinaryTable fitsBinaryData)
        throws FitsException, HeaderCardException {
        Header baseBinaryTableHeader = BinaryTableHDU.manufactureHeader(fitsBinaryData);
        Header binaryTableHeader = new Header();
        binaryTableHeader.setXtension(XTENSION_BINTABLE_VALUE);
        binaryTableHeader.setBitpix(8);
        binaryTableHeader.setNaxes(2);
        binaryTableHeader.addValue(NAXIS1_KW, baseBinaryTableHeader.getIntValue(NAXIS1_KW), "");
        binaryTableHeader.addValue(NAXIS2_KW, baseBinaryTableHeader.getIntValue(NAXIS2_KW), "");
        binaryTableHeader.addValue(PCOUNT_KW, baseBinaryTableHeader.getIntValue(NAXIS2_KW), "");
        binaryTableHeader.addValue(GCOUNT_KW, baseBinaryTableHeader.getIntValue(GCOUNT_KW), "");
        binaryTableHeader.addValue(TFIELDS_KW, baseBinaryTableHeader.getIntValue(TFIELDS_KW), "");
        return binaryTableHeader;
    }
    
    @Deprecated
    public static <T extends Number> void addColumn(Header binaryTableHeader, int colNumber, String type, 
        String typeComment, String form, String display, String units,
        T undefinedValue) throws HeaderCardException {

        binaryTableHeader.addValue("TTYPE" + colNumber, type, nameComment(colNumber, typeComment));
        binaryTableHeader.addValue(TFORM_KW + colNumber, form, formComment(colNumber, form));
        binaryTableHeader.addValue("TDISP" + colNumber, display, displayComment(colNumber));
        binaryTableHeader.addValue("TUNIT" + colNumber, units, unitsComment(colNumber));
    }
    
    @Deprecated
    public static String displayComment(int colNumber) {
        return String.format("format in which field %d is displayed", colNumber);
    }
    
    @Deprecated
    public static String formComment(int colNumber, String tFormN) {
        BinaryTableDataType binTableType = BinaryTableDataType.fromFits(tFormN);
        
        return String.format("data type for field %d: %s", colNumber, binTableType.humanString());
    }
    
    @Deprecated
    public static String unitsComment(int colNumber) {
        return String.format("units of data value for field %d", colNumber);
    }
    
    @Deprecated
    public static String nameComment(int colNumber, String name) {
        return String.format("name of field %d: %s", colNumber, name);
    }
    
    /** Flows a whole line comment into multiple COMMENT keywords if it is too
     * long.
     * @param header
     * @param comment
     * @return
     * @throws HeaderCardException 
     */
    public static void insertComment(Header header, String comment) throws HeaderCardException {
        while (true) {
            if (comment.length() < MAX_COMMENT_LENGTH) {
                header.insertComment(comment);
                return;
            }
            //Comment too long
            int breakAtSpace = comment.lastIndexOf(' ', MAX_COMMENT_LENGTH - 1);
            if (breakAtSpace == -1) {
                breakAtSpace = MAX_COMMENT_LENGTH-1;
            }
            header.insertComment(comment.substring(0, breakAtSpace+1));
            comment = comment.substring(breakAtSpace + 1);
        }
    }
    
    /**
     * Trims trailing blank cards.
     * 
     */
    public static void trimHeader(Header header) {
        Cursor c = header.iterator();
        //Find where the last interesting card is located.
        int lastNonEndNonBlank = 0;
        int i=0;
        while (c.hasNext()) {
            HeaderCard headerCard = (HeaderCard) c.next();
            String headerCardStr = headerCard.toString();
            if (headerCardStr.trim().length() != 0 && !headerCardStr.startsWith("END")) {
                lastNonEndNonBlank = i;
            }
            i++;
        }
        
        //Remove everything after the last interesting card.
        i=0;
        c = header.iterator();
        while (c.hasNext()) {
            c.next();
            if (i > lastNonEndNonBlank) {
                c.remove();
            }
            i++;
        }
        
        //Put end END keyword back into the right place.
        String end = "END                                                                             ";
        c.add(new HeaderCard(end));
    }
    
    /**
     * Makes a deep copy of the Header.
     * @param src
     * @return
     */
    public static Header copyHeader(Header src) {
        Header dest = new Header();
        Cursor c = src.iterator();
        while (c.hasNext()) {
            HeaderCard srcCard = (HeaderCard) c.next();
            dest.addLine(new HeaderCard(srcCard.toString()));
        }
        
        return dest;
    }
    
    /**
     * If you thought Header.toString() did this then you where wrong.  I've been
     * there.
     * 
     * @param header
     * @return  The FITS header in string form.  This is actually a valid FITS
     * header and could be written to a file.
     * @throws FitsException 
     */
    public static String headerToString(Header header) throws FitsException {
        int headerSize = header.getNumberOfCards() * HEADER_CARD_LENGTH;
        headerSize += HDU_BLOCK_SIZE - (headerSize % HDU_BLOCK_SIZE);
        ByteArrayOutputStream byteOut = new ByteArrayOutputStream(headerSize);
        BufferedDataOutputStream bufOut = new BufferedDataOutputStream(byteOut);
        header.write(bufOut);
        try {
            bufOut.flush();
        } catch (IOException e) {
            throw new IllegalStateException(e);
        }
        return new String(byteOut.toByteArray(), Charset.forName("US-ASCII"));
    }
    
    public static void addRaObj(Header header, double raDegrees) throws HeaderCardException {
        safeAdd(header, RA_OBJ_KW, raDegrees, RA_OBJ_COMMENT, "%.6f");
    }

    public static void addDecObj(Header header, double decDegrees) throws HeaderCardException {
        safeAdd(header, DEC_OBJ_KW, decDegrees, DEC_OBJ_COMMENT, "%.6f");
    }
    
    public static void addEquinoxKeyword(Header header) throws HeaderCardException {
        safeAdd(header, EQUINOX, EQUINOX_VALUE, EQUINOX_COMMENT, EQUINOX_FORMAT);
    }
    
    public static void addObjectKeyword(Header header, int keplerId, boolean isK2) throws HeaderCardException {
        if (isK2) {
            header.addValue(OBJECT, "EPIC " + keplerId, OBJECT_COMMENT);
        } else {
            header.addValue(OBJECT, "KIC " + keplerId, OBJECT_COMMENT);
        }
    }
    
    /**
     * 
     * @param header
     * @param checksumStr  This should be the checksum string as specified in
     * the FITS CHECKSUM specification.
     * @param generatedAtDate in local time, this will be converted to Z
     * @throws HeaderCardException
     */
    public static void addChecksum(Header header, String checksumStr, Date generatedAtDate) throws HeaderCardException {
        
        DateFormat isoFormatter = Iso8601Formatter.dateTimeFormatter();
        isoFormatter.setTimeZone(UTC);
        String generatedAtStr = isoFormatter.format(generatedAtDate);
        safeAdd(header, CHECKSUM_KW, checksumStr, String.format(CHECKSUM_COMMENT_FORMAT, generatedAtStr));
       
    }
    
    /**
     * Writes the WCS coordinates into h that are responsible telling the viewer
     * how the image maps onto the CCD coordinates.
     * 
     * @param h The header to add keywords to.
     * @param referenceCcdRow the value of the CCD coordinate at the reference
     * pixel in the image (1,1)
     * @param referenceCcdColumn the value of the CCD coordinate at the reference
     * pixel in the image (1,1)
     * @throws HeaderCardException
     */
    public static void addPhysicalWcs(Header h, int referenceCcdColumn, int referenceCcdRow) throws HeaderCardException {
        safeAdd(h, "WCSNAMEP", "PHYSICAL", "name of world coordinate system alternate P");
        safeAdd(h, "WCSAXESP", 2, "number of WCS physical axes");
        safeAdd(h, "CTYPE1P", WCS_PHYSICAL_CCD_COL_TYPE, "physical WCS axis 1 type CCD col");
        safeAdd(h, "CUNIT1P", "PIXEL", "physical WCS axis 1 unit");
        safeAdd(h, "CRPIX1P", 1, "reference CCD column");
        safeAdd(h, "CRVAL1P", referenceCcdColumn, "value at reference CCD column");
        safeAdd(h, "CDELT1P", 1.0, "physical WCS axis 1 step");
        safeAdd(h, "CTYPE2P", WCS_PHYSICAL_CCD_ROW_TYPE, "physical WCS axis 2 type CCD row");
        safeAdd(h, "CUNIT2P", "PIXEL", "physical WCS axis 2 units");
        safeAdd(h, "CRPIX2P", 1, "reference CCD row");
        safeAdd(h, "CRVAL2P", referenceCcdRow, "value at reference CCD row");
        safeAdd(h, "CDELT2P", 1.0, "physical WCS axis 2 step");
    }
    
    /**
     * This adds the keywords for the celestial WCS that uses the "RA---TAN"
     * and "DEC--TAN" algorithm.
     * 
     * @param h The header to add keywords to.
     * @param referencePixelColumn This may be null.
     * @param referencePixelRow This may be null.
     * @param raDegrees the right ascension at the reference pixel. This may be null.
     * @param decDegrees the declination at the reference pixel.  This may be null.
     * @param raScale the scale in RA.  This may be null.
     * @param decScale the scale in DEC.  This may be null.
     * @param xMatrix This is the PC matrix.  This can not be null, but the 
     * individual array references may be null.
     * @throws HeaderCardException
     */
    public static void addCelestialWcs(Header h, Double referencePixelColumn,
        Double referencePixelRow, Double raDegrees, Double decDegrees,
        Double raScale, Double decScale, Double[][] xMatrix) throws HeaderCardException {
        safeAdd(h, WCSAXES_KW, 2, WCSAXES_COMMENT);
        safeAdd(h, CTYPE1_KW, CTYPE1_RADEC_VALUE, CTYPE1_RADEC_COMMENT);
        safeAdd(h, CTYPE2_KW, CTYPE2_RADEC_VALUE, CTYPE2_RADEC_COMMENT);
        safeAdd(h, CRPIX1_KW, referencePixelColumn, "[pixel] reference pixel along image axis 1");
        safeAdd(h, CRPIX2_KW, referencePixelRow, "[pixel] reference pixel along image axis 2");
        safeAdd(h, CRVAL1_KW, raDegrees, "[deg] right ascension at reference pixel");
        safeAdd(h, CRVAL2_KW, decDegrees, "[deg] declination at reference pixel");
        safeAdd(h, "CUNIT1", "deg", "physical unit in column dimension");
        safeAdd(h, "CUNIT2", "deg", "physical unit in row dimension");
        safeAdd(h, "CDELT1", raScale, "[deg] pixel scale in RA dimension");
        safeAdd(h, "CDELT2", decScale, "[deg] pixel scale in Dec dimension");
        safeAdd(h, "PC1_1", xMatrix[0][0], "linear transformation element cos(th)");
        safeAdd(h, "PC1_2", xMatrix[0][1], "linear transformation element -sin(th)");
        safeAdd(h, "PC2_1", xMatrix[1][0], "linear transformation element sin(th)");
        safeAdd(h, "PC2_2", xMatrix[1][1], "linear transformation element cos(th)");
    }
    
    public static void addDateObsKeywords(Header h, Date startDateUtc, Date endDateUtc) throws HeaderCardException {
        SimpleDateFormat obsFormat = new SimpleDateFormat(DATE_END_FORMAT);
        obsFormat.setTimeZone(TimeZone.getTimeZone("UTC"));
        h.addValue(DATE_OBS_KW, obsFormat.format(startDateUtc), DATE_OBS_COMMENT);
        h.addValue(DATE_END_KW, obsFormat.format(endDateUtc), DATE_END_COMMENT);
    }
    
    public static Double currentOrLegacyValue(Header h, String keyword, String legacyKeyword) {
        return h.containsKey(keyword) ? 
            safeGetDoubleField(h, keyword) : safeGetDoubleField(h, legacyKeyword);
    }
    
    
    private final static String FORWARD_POLYNOMIAL_COMMENT = "distortion coefficient";
    private final static String INVERSE_POLYNOMIAL_COMMENT  = "inv distortion coefficient";
    
    /**
     * This is another celestial WCS coordinate system.  This is more complicated
     * to produce and use, but has the advantage that it accurate over a much
     * larger area.
     * 
     * @param sipWcs non-null
     * @param h non-null
     * @throws HeaderCardException
     */
    public static void addSipWcs(SipWcsCoordinates sipWcs, Header h) throws HeaderCardException {
        h.addValue(WCSAXES_KW, 2, WCSAXES_COMMENT);
        h.addValue(CTYPE1_KW, CTYPE1_SIP_VALUE, CTYPE1_SIP_COMMENT);
        h.addValue(CTYPE2_KW, CTYPE2_SIP_VALUE, CTYPE2_SIP_COMMENT);

        safeAdd(h, CRVAL1_KW, sipWcs.ra(), CRVAL1_SIP_COMMENT);
        safeAdd(h, CRVAL2_KW, sipWcs.dec(), CRVAL2_SIP_COMMENT);
        
        safeAdd(h, CRPIX1_KW, sipWcs.referenceCcdColumn(), CRPIX1_SIP_COMMENT);
        safeAdd(h, CRPIX2_KW, sipWcs.referenceCcdRow(), CRPIX2_SIP_COMMENT);
        
        safeAdd(h, CD1_1_KW, sipWcs.rotationAndScale()[0][0], CD1_1_COMMENT);
        safeAdd(h, CD1_2_KW, sipWcs.rotationAndScale()[0][1], CD1_1_COMMENT);
        safeAdd(h, CD2_1_KW, sipWcs.rotationAndScale()[1][0], CD1_1_COMMENT);
        safeAdd(h, CD2_2_KW, sipWcs.rotationAndScale()[1][1], CD1_1_COMMENT);
        
        safeAdd(h, A_ORDER_KW, sipWcs.forward().a().order(), A_ORDER_COMMENT);
        safeAdd(h, B_ORDER_KW, sipWcs.forward().b().order(), B_ORDER_COMMENT);
        
        addPolynomial(h, sipWcs.forward().a(), "A_", FORWARD_POLYNOMIAL_COMMENT);
        addPolynomial(h, sipWcs.forward().b(), "B_", FORWARD_POLYNOMIAL_COMMENT);
        
        safeAdd(h, AP_ORDER_KW, sipWcs.forward().a().order(), AP_ORDER_COMMENT);
        safeAdd(h, BP_ORDER_KW, sipWcs.forward().b().order(), BP_ORDER_COMMENT);
        addPolynomial(h, sipWcs.inverse().a(), "AP_", INVERSE_POLYNOMIAL_COMMENT);
        addPolynomial(h, sipWcs.inverse().b(), "BP_", INVERSE_POLYNOMIAL_COMMENT);

        safeAdd(h, A_DMAX_KW, sipWcs.maxDistortionA(), A_DMAX_COMMENT);
        safeAdd(h, B_DMAX_KW, sipWcs.maxDistortionB(), B_DMAX_COMMENT);
    }
    
    private static void addPolynomial(Header h, SipPolynomial p, String keywordPrefix, String comment) throws HeaderCardException {
        for (PolynomialPart coeff : p.polynomial()) {
            safeAdd(h, keywordPrefix + coeff.keyword(), coeff.value(), comment);
        }
    }
    
    
    /**
     * Reads to the end of the header.  This is useful if you have a checksum
     * that you want to preserve in the source header and you don't want
     * nom.tam.fits "helping" you parse the header.  This leaves the DataInputStream
     * at the end of the header.  The DataInputStream should start at a FITS
     * block size boundary.
     * 
     * @param din A non-null data input stream.
     * @throws IOException if we have reached the end of the data input.
     */
    public static void advanceToEndOfHeader(DataInput din) throws IOException {
        byte[] block = new byte[HDU_BLOCK_SIZE];
        
        while (true) {
            din.readFully(block);
            
            byte findNext = ASCII_E;
            for (int i=0; i < HDU_BLOCK_SIZE; i++) {
                if (block[i] == findNext) {
                    switch (findNext) {
                        case ASCII_E : 
                            if (i % 80 == 0) {
                                findNext = ASCII_N;
                            }
                            break;
                        case ASCII_N: findNext = ASCII_D; break;
                        case ASCII_D: return;
                        default:
                            throw new IllegalStateException("Unexpected findNext = " + findNext);
                    }
                } else {
                    findNext = ASCII_E;
                }
            }
        } //end while
    }
    
    /**
     * 
     * @param h non-null header.
     * @param dynablackColumnCutoff ?, null ok
     * @param dynablackThreshold ?, null ok
     * @param rollingBandDurationsLc the durations for which rolling bands where calculated
     * in units of long cadence. null ok
     * @throws HeaderCardException
     */
    public static void addCommonRollingBandKeywords(Header h, Integer dynablackColumnCutoff, Float dynablackThreshold, int[] rollingBandDurationsLc) throws HeaderCardException {
        safeAdd(h, DBCOLCO_KW, dynablackColumnCutoff, DBCOLCO_COMMENT);
        safeAdd(h, DBTHRES_KW, dynablackThreshold, DBTHRES_COMMENT);
        
        if (rollingBandDurationsLc != null) {
            for (int i=0; i < rollingBandDurationsLc.length; i++) {
                int duration = rollingBandDurationsLc[i];
                safeAdd(h, String.format(RBTDUR_KW_FORMAT, duration), duration, String.format(RBASNAME_COMMENT, i));
            }
        }
    }
}
