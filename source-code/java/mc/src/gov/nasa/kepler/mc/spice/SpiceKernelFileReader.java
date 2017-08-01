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

package gov.nasa.kepler.mc.spice;

import java.io.BufferedReader;
import java.io.EOFException;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.PushbackReader;
import java.io.Reader;
import java.util.HashMap;
import java.util.Map;

/**
 * This class converts SPICE kernel files into {@link Map}s of name/value pairs
 * representing the kernel file. Currently, SPICE text kernels are supported
 * (.tls and .tsc), but binary kernels are not supported (.bsp).
 * 
 * @author Miles Cote
 * 
 */
public class SpiceKernelFileReader {

    private static final String BEGINDATA = "begindata";

    private File spiceKernelFile;

    public SpiceKernelFileReader(File spiceKernelFile) {
        this.spiceKernelFile = spiceKernelFile;
    }

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

    public Map<String, String> getKernelData() throws SpiceException {
        Map<String, String> kernelData = new HashMap<String, String>();

        ParsePosition parsePosition = ParsePosition.NAME;

        boolean parendDelimited = false;

        PushbackReader reader;
        StringBuilder currentName = new StringBuilder();
        StringBuilder currentValue = new StringBuilder();
        char currentChar;
        boolean foundDataSegment = false;

        try {
            reader = new PushbackReader(new BufferedReader(new FileReader(
                spiceKernelFile)));

            try {
                while (true) {
                    currentChar = readCharWithEOFCheck(reader);

                    if (currentChar == '\\') {
                        String tag = readPastEol(reader);
                        if (tag.equals(BEGINDATA)) {
                            foundDataSegment = true;
                        }
                        currentChar = readCharWithEOFCheck(reader);
                    }

                    // Skip any text that comes before the \begindata tag.
                    if (foundDataSegment) {
                        if (parsePosition == ParsePosition.NAME) {
                            if (currentChar == '=') {
                                // Done with name.
                                parsePosition = ParsePosition.PRE_VALUE;
                            } else {
                                currentName.append(currentChar);
                            }
                        } else if (parsePosition == ParsePosition.PRE_VALUE) {
                            if (currentChar != ' ') {
                                // Done with pre-value.
                                parsePosition = ParsePosition.VALUE;

                                if (currentChar == '(') {
                                    parendDelimited = true;
                                } else {
                                    currentValue.append(currentChar);
                                    parendDelimited = false;
                                }
                            }
                        } else if (parsePosition == ParsePosition.VALUE) {
                            char delimiter;
                            if (parendDelimited) {
                                delimiter = ')';
                            } else {
                                // If it's not parend-delimited, then the EOL is
                                // the
                                // delimiter.
                                delimiter = '\n';
                            }

                            if (currentChar == delimiter) {
                                // Done with value.
                                String name = currentName.toString()
                                    .trim();
                                String value = currentValue.toString()
                                    .trim();

                                kernelData.put(name, value);

                                // reset
                                parsePosition = ParsePosition.NAME;
                                currentName = new StringBuilder();
                                currentValue = new StringBuilder();
                            } else {
                                currentValue.append(currentChar);
                            }
                        } else {
                            throw new IllegalStateException(
                                "Unexpected state: " + parsePosition);
                        }
                    }
                }
            } catch (EOFException e) {
                if (parsePosition != ParsePosition.NAME) {
                    throw new IllegalStateException(
                        "Unexpected EOF while reading variable value for name: "
                            + currentName);
                } else {
                    return kernelData;
                }
            }
        } catch (Exception e) {
            throw new SpiceException("Unable to get kernel data.", e);
        }
    }

    private String readPastEol(PushbackReader reader) throws IOException {
        // Chew up the rest of the line and return what was read. A line is
        // considered to be terminated by any one of a line feed ('\n'), a
        // carriage return ('\r'), or a carriage return followed immediately by
        // a linefeed.
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

}
