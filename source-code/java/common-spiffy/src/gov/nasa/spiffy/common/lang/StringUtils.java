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

import java.util.Date;
import java.util.StringTokenizer;

import org.apache.commons.beanutils.ConversionException;
import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Contains utility functions for {@link String}s.
 * 
 * @author Forrest Girouard
 * @author Sean McCauliff
 * @author Todd Klaus
 * @author Thomas Han (than)
 */
public class StringUtils {
	private static final Log log = LogFactory.getLog(StringUtils.class);

	/**
	 * Convert a string to array of String
	 * 
	 * @param input
	 * @return
	 * @throws ConversionException
	 */
	public static String[] convertStringArray(String input) throws ConversionException {
	    if (input == null) {
	        throw new IllegalArgumentException("input cannot be null.");
	    }
	    
		log.debug("convertStringArray got " + input);
	    StringTokenizer st = new StringTokenizer(input, ",");
	    String[] results = new String[st.countTokens()];
	    int i = 0;
	    while (st.hasMoreTokens()) {
	        results[i++] = st.nextToken().trim();
	    }
	    return results;
	}

    /**
     * Translate a constant field name to an acronym (for example, FOO_BAR -> fb).
     * 
     * @param value the name of the constant field (uppercase and underscores)
     * @return representation of input value in camel case
     */
    public static String constantToAcronym(String value) {
        if (value == null) {
            throw new IllegalArgumentException("value cannot be null.");
        }
        
        StringBuilder builder = new StringBuilder();
        int index = 0;
        while (index < value.length()) {
            int underscore = value.indexOf('_', index);
            if (underscore != 0) {
                builder.append(value.substring(index, index+1).toLowerCase());
            }
            if (underscore == -1) {
                index = value.length();
            } else {
                index = underscore + 1;
            }
        }
        return (builder.length() > 0 ? builder.toString() : value);
    }

    /**
     * Translate a constant field name to camel case.
     * 
     * @param value the name of the constant field (uppercase and underscores)
     * @return representation of input value in camel case
     */
    public static String constantToCamel(String value) {
        if (value == null) {
            throw new IllegalArgumentException("value cannot be null.");
        }
        
        StringBuilder builder = new StringBuilder();
        int index = 0;
        while (index < value.length()) {
            int underscore = value.indexOf('_', index);
            if (underscore == -1) {
                underscore = value.length();
            }
            if (index != underscore) {
                builder.append(value.substring(index, index + 1).toUpperCase());
                index++;
                builder
                    .append(value.substring(index, underscore).toLowerCase());
                index += underscore - index;
            }
            index++;
        }
        return (builder.length() > 0 ? builder.toString() : value);
    }

    /**
     * Translate a constant field name to camel case with spaces.
     * 
     * @param value the name of the constant field (uppercase and underscores)
     * @return representation of input value in camel case with spaces.
     */
    public static String constantToCamelWithSpaces(String value) {
        if (value == null) {
            throw new IllegalArgumentException("value cannot be null.");
        }
        
        StringBuilder builder = new StringBuilder();
        int index = 0;
        while (index < value.length()) {
            int underscore = value.indexOf('_', index);
            if (underscore == -1) {
                underscore = value.length();
            }
            if (index != underscore) {
                builder.append(value.substring(index, index + 1).toUpperCase());
                index++;
                builder
                    .append(value.substring(index, underscore).toLowerCase());
                index += underscore - index;
                if (underscore < value.length()) {
                    builder.append(" ");
                }
            }
            index++;
        }
        return (builder.length() > 0 ? builder.toString() : value);
    }
    
    /**
     * Translate a constant field name to a lowercase, hyphen-separated string
     * (for example, FOO_BAR -> foo-bar). This is useful when converting enums
     * values to command-line commands.
     * 
     * @param value the name of the constant field (uppercase and underscores)
     * @return hyphen-separated, lowercase string
     */
    public static String constantToHyphenSeparatedLowercase(String value) {
        String s = value.replace('_', '-');

        return s.toLowerCase();
    }
    
    /**
     * Return an elapsed time in display form.
     * If endTime <= startTime, endTime is assumed to be
     * uninitialized and elapsed time is computed from startTime
     * to current time.
     * 
     * @param startTime
     * @param endTime
     * @return
     */
    public static String elapsedTime(long startTime, long endTime) {
        long current = System.currentTimeMillis();
        long duration;
        
        if(startTime == 0){
            return "-";
        }
        
        if(endTime > startTime){
            // completed
            duration = endTime - startTime;
        }else{
            // still going
            duration = current - startTime;
        }
        
        return DurationFormatUtils.formatDuration(duration, "HH:mm:ss");
    }

    public static String elapsedTime(Date startTime, Date endTime) {
        if (startTime == null) {
            throw new IllegalArgumentException("startTime cannot be null.");
        }

        if (endTime == null) {
            throw new IllegalArgumentException("endTime cannot be null.");
        }

        return elapsedTime(startTime.getTime(), endTime.getTime());
    }    

    public static String pad(String s, int desiredLength){
        StringBuilder sb = new StringBuilder(s);
        int length = s.length();
        while(length < desiredLength){
            sb.append(" ");
            length++;
        }
        String result = sb.toString();
        return result;
    }
    
    /**
     * Converts the buffer to a string in hex with the correct padding that is
     * a byte with a value of 12 is converted to the string "0c" not "c".
     * @param buf A byte buffer.  Must not be null.
     * @param off The offset into the byte array to start conversion.
     * @param len The number of bytes to convert.
     * @return A string of length zero of more.
     */
    public static String toHexString(byte[] buf, int off, int len) {
        if (buf == null) {
            throw new NullPointerException("buf may not be null.");
        }
        if (off < 0) {
            throw new IllegalArgumentException("off must be non-negative.");
        }
        if (len < 0) {
            throw new IllegalArgumentException("len must be non-negative");
        }
        final int nbytes = buf.length - off;
        if (off > buf.length-1) {
            if (off == buf.length && nbytes != 0) {
                throw new IllegalArgumentException("Offset is larger than array.");
            }
        }
       
        if (len > nbytes) {
            throw new IllegalArgumentException("Len is too long.");
        }
        
        StringBuilder bldr = new StringBuilder(nbytes * 2);
        for (int i=off; i < (off + len); i++) {
            //Could make this faster with lookup table.
            bldr.append(String.format("%02x", buf[i]));
        }
        return bldr.toString();
    }
    
    /**
     * Truncates a string.
     * 
     * @param s A string.  This may be null.
     * @param len The new length.  If len greater or equal to s.length() then this will
     * return s.  Otherwise the string will contain the characters in indices
     * [0,len).
     * @return If s null then the return value will be null.
     */
    public static String truncate(String s, int len) {
        if (len < 0) {
            throw new IllegalArgumentException("len must be non-negative");
        }
        if (s == null) {
            return null;
        }
        if (s.length() <= len) {
            return s;
        }
        return s.substring(0, len);
    }
    
    /**
     * Break a string into an 80 characters per line.  
     * @param s Assumes input string is not null and does not already contain
     * line breaks.
     */
    public static String breakAt80Characters(String s) {
        StringBuilder bldr = new StringBuilder(s.length() + s.length()/80 + 1);
        for (int i=0; i < s.length(); i+=80) {
            bldr.append(s.substring(i, Math.min(i+80, s.length())));
            bldr.append('\n');
        }
        return bldr.toString();
    }
}

