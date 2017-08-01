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

package gov.nasa.kepler.dr.sclk;

import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.hibernate.dr.SclkCoefficients;

import java.io.BufferedReader;
import java.io.EOFException;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.PushbackReader;
import java.io.Reader;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;
import java.util.StringTokenizer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class reads Spice SCLK files
 * 
 * @author tklaus
 * 
 */
public class SclkFileReader {
    /**
     * 
     */
    private static final String BEGINDATA_TAG = "begindata";

    private static final Log log = LogFactory.getLog(SclkFileReader.class);

    private static final String COEFFICIENTS_KEYWORD = "SCLK01_COEFFICIENTS_227";

    /**
     * Parsing position State diagram shown below (values in parenthesis show
     * state transition triggers)
     * 
     * |---------------------------------------------------------- V | NAME
     * (find '=')-> PRE_VALUE (find '(')-> VALUE (find ')')---^
     * 
     * @author Todd Klaus tklaus@arc.nasa.gov
     * 
     */
    private enum ParsePosition {
        NAME, PRE_VALUE, VALUE,
    }

    private File sclkFile;
    private Map<String, String> sclkValues = new HashMap<String, String>();
    private ParsePosition parsePosition = ParsePosition.NAME;

    public SclkFileReader(File sclkFile) {
        this.sclkFile = sclkFile;
    }

    public CoefficientsIterator getCoefficientsIterator() {
        String coefficientsValue = sclkValues.get(COEFFICIENTS_KEYWORD);
        if (coefficientsValue == null) {
            throw new DispatchException("Missing value for "
                + COEFFICIENTS_KEYWORD);
        }
        return new CoefficientsIterator(coefficientsValue);
    }

    public void parse() {
        PushbackReader reader;
        StringBuilder currentName = new StringBuilder();
        StringBuilder currentValue = new StringBuilder();
        char currentChar;
        boolean foundDataSegment = false;

        try {
            reader = new PushbackReader(new BufferedReader(new FileReader(
                sclkFile)));
        } catch (FileNotFoundException e) {
            throw new DispatchException("File not found for: " + sclkFile, e);
        }

        try {
            while (true) {
                currentChar = readCharWithEOFCheck(reader);

                if (currentChar == '\\') {
                    String tag = readPastEol(reader);
                    if (tag.equals(BEGINDATA_TAG)) {
                        foundDataSegment = true;
                    }
                    currentChar = readCharWithEOFCheck(reader);
                }

                /*
                 * Skip any text that comes before the \begindata tag
                 */
                if (foundDataSegment) {
                    if (parsePosition == ParsePosition.NAME) {
                        if (currentChar == '=') {
                            // done with name
                            parsePosition = ParsePosition.PRE_VALUE;
                        } else {
                            currentName.append(currentChar);
                        }
                    } else if (parsePosition == ParsePosition.PRE_VALUE) {
                        if (currentChar == '(') {
                            // done with pre-value
                            parsePosition = ParsePosition.VALUE;
                        }
                    } else if (parsePosition == ParsePosition.VALUE) {
                        if (currentChar == ')') {
                            // done with value
                            String name = currentName.toString()
                                .trim();
                            String value = currentValue.toString()
                                .trim();

                            sclkValues.put(name, value);

                            // reset
                            parsePosition = ParsePosition.NAME;
                            currentName = new StringBuilder();
                            currentValue = new StringBuilder();
                        } else {
                            currentValue.append(currentChar);
                        }
                    } else {
                        throw new DispatchException("Unexpected state: "
                            + parsePosition);
                    }
                }
            }
        } catch (EOFException e) {
            if (parsePosition != ParsePosition.NAME) {
                throw new DispatchException(
                    "Unexpected EOF while reading variable value for name: "
                        + currentName);
            } else {
                return;
            }
        } catch (IOException e) {
            throw new DispatchException("Caught IOException reading: "
                + sclkFile, e);
        }
    }

    private String readPastEol(PushbackReader reader) throws IOException {
        /*
         * Chew up the rest of the line and return what was read. A line is
         * considered to be terminated by any one of a line feed ('\n'), a
         * carriage return ('\r'), or a carriage return followed immediately by
         * a linefeed.
         */
        char currentChar = 0;
        StringBuilder sb = new StringBuilder();

        while (true) {
            currentChar = readCharWithEOFCheck(reader);

            if (currentChar == '\n') {
                return sb.toString();
            } else if (currentChar == '\r') {
                currentChar = (char) reader.read();
                if (currentChar != '\n') {
                    reader.unread((int) currentChar);
                }
                return sb.toString();
            }
            sb.append(currentChar);
        }
    }

    private char readCharWithEOFCheck(Reader reader) throws IOException {
        int i = reader.read();
        if (i == -1) {
            throw new EOFException();
        } else {
            return (char) i;
        }
    }

    /**
     * Iterator that iterates across the triples that make up the
     * SCLK01_COEFFICIENTS_227 keyword
     * 
     * @author Todd Klaus tklaus@arc.nasa.gov
     * 
     */
    public static class CoefficientsIterator implements
        Iterator<SclkCoefficients> {
        private StringTokenizer tokenizer;

        public CoefficientsIterator(String coefficientsValue) {
            tokenizer = new StringTokenizer(coefficientsValue);
        }

        public boolean hasNext() {
            return tokenizer.hasMoreTokens();
        }

        public SclkCoefficients next() {
            double vtcEventTime = Double.parseDouble(tokenizer.nextToken());
            double secondsSinceEpoch = Double.parseDouble(tokenizer.nextToken());
            double clockRate = Double.parseDouble(tokenizer.nextToken());

            SclkCoefficients sclkCoefficients = new SclkCoefficients(
                vtcEventTime, secondsSinceEpoch, clockRate);

            return sclkCoefficients;
        }

        public void remove() {
            throw new UnsupportedOperationException(
                "remove not supported by this Iterator");
        }
    }

    /**
     * @param key
     * @return
     * @see java.util.Map#containsKey(java.lang.Object)
     */
    public boolean containsKey(String key) {
        return sclkValues.containsKey(key);
    }

    /**
     * @param key
     * @return
     * @see java.util.Map#get(java.lang.Object)
     */
    public String get(String key) {
        String value = sclkValues.get(key);
        if (value == null) {
            log.info("No value found for key=" + key);
        }
        return value;
    }

    /**
     * @return
     * @see java.util.Map#size()
     */
    public int size() {
        return sclkValues.size();
    }

    /**
     * @return
     * @see java.util.Map#keySet()
     */
    public Set<String> keySet() {
        return sclkValues.keySet();
    }
}
