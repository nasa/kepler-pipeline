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

package gov.nasa.kepler.dr.lazyfits;

import static gov.nasa.kepler.common.FitsConstants.NAXIS1_KW;
import static gov.nasa.kepler.common.FitsConstants.NAXIS_KW;
import gov.nasa.kepler.services.alert.AlertServiceFactory;

import java.io.EOFException;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.HashMap;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Represents the header of a FITS HDU
 * 
 * @author tklaus
 * 
 */
public class Header {

    private static final Log log = LogFactory.getLog(Header.class);

    private static final char QUOTE_START_CHAR = '\'';
    private static final char COMMENT_START_CHAR = '/';

    private static final int CARD_LENGTH = 80;
    private static final int CARD_KEYWORD_LENGTH = 8;
    private static final int CARD_VALUE_LENGTH = 70;
    private static final int CARD_VALUE_OFFSET = 10;

    private RandomAccessFile fileReader;
    private long fileOffset = 0;
    private byte[] currentCard = new byte[CARD_LENGTH];
    private HashMap<String, String> keywordValuePairs = new HashMap<String, String>();
    private boolean hasData = false;
    private Hdu referenceHdu = null;
    private boolean loaded = false;

    /**
     * The non-reference case. Immediately read the header from the specified
     * RandomAccessFile. The file pointer is assumed to be set to the beginning
     * of this header
     * 
     * @param fileReader
     * @throws LazyFitsException
     * @throws EOFException
     */
    public Header(RandomAccessFile fileReader) throws LazyFitsException,
        EOFException {
        this.fileReader = fileReader;
        read();
    }

    /**
     * The reference case. No data is read from the file until requested.
     * 
     * @param fileReader
     * @param referenceHdu
     */
    public Header(RandomAccessFile fileReader, Hdu referenceHdu) {
        this.fileReader = fileReader;
        this.referenceHdu = referenceHdu;
    }

    /**
     * Read/parse the HDU header. In the non-reference case, this method is
     * called by the constructor. In the reference case, it is called the first
     * time a keyword is read from the header.
     * 
     * @throws LazyFitsException
     * @throws EOFException
     */
    private void read() throws LazyFitsException, EOFException {
        FitsLogicalRecordInputStream fitsInput = null;
        try {
            if (referenceHdu != null) {
                fileOffset = referenceHdu.getHeaderFileOffset();
                fileReader.seek(fileOffset);
            } else {
                fileOffset = fileReader.getFilePointer();
            }

            boolean done = false;
            fitsInput = new FitsLogicalRecordInputStream(fileReader);

            while (!done) {
                int totalBytesRead = fitsInput.read(currentCard);
                if (totalBytesRead == -1) {
                    log.debug("No more bytes available for currentCard.");
                }

                String keyword = new String(currentCard, 0, CARD_KEYWORD_LENGTH);
                String value = new String(currentCard, CARD_VALUE_OFFSET,
                    CARD_VALUE_LENGTH);
                int commentStart = getCommentStart(value);
                if (commentStart != -1) {
                    value = value.substring(0, commentStart); // snip off the
                    // comment
                }

                value = dequoteify(value);

                keyword = keyword.trim();
                value = value.trim();

                keywordValuePairs.put(keyword, value);

                if (keyword.equals(NAXIS_KW)
                    || keyword.equals(NAXIS1_KW)) {
                    int intValue = Integer.parseInt(value);
                    if (intValue > 0) {
                        hasData = true;
                    }
                }

                if (keyword.equals("END")) {
                    done = true;
                }
            }
            loaded = true;

        } catch (EOFException e) {
            throw e;
        } catch (IOException e) {
            throw new LazyFitsException("failed to parse HDU header", e);
        } finally {
            if (fitsInput != null) {
                try {
                    fitsInput.close();
                } catch (IOException e) {
                    AlertServiceFactory.getInstance()
                        .generateAlert(getClass().getName(),
                            "Unable to close stream.\n" + e);
                }
            }
        }
    }

    int getCommentStart(String value) {
        if (value.indexOf(COMMENT_START_CHAR) == -1) {
            return -1;
        } else if (value.indexOf(QUOTE_START_CHAR) == -1) {
            // If there are no single quotes, then the slash is the start of the
            // comment.
            return value.indexOf(COMMENT_START_CHAR);
        } else {
            // Slashes inside of single quotes are not comments.
            boolean insideOfQuotes = false;
            for (int i = 0; i < value.length(); i++) {
                char c = value.charAt(i);
                if (c == QUOTE_START_CHAR) {
                    insideOfQuotes = !insideOfQuotes;
                } else if (c == COMMENT_START_CHAR && !insideOfQuotes) {
                    return i;
                }
            }
            return -1;
        }
    }

    /**
     * <pre>
     * Remove single quotes from FITS keyword value per the FITS spec:
     *   KEYWORD1= ''     / null string
     *   KEYWORD2= '  '   / blank keyword
     *   KEYWORD3=        / undefined keyword
     *   KEYWORD4= 'O''HARA' / O'HARA
     * </pre>
     * 
     * @param value
     */
    private String dequoteify(String string) {
        StringBuilder stringBuilder = new StringBuilder();
        boolean prevWasQuote = false;

        for (int i = 0; i < string.length(); i++) {
            char c = string.charAt(i);
            if (c == '\'') {
                if (prevWasQuote) {
                    stringBuilder.append(c);
                }
                prevWasQuote = !prevWasQuote;
            } else {
                stringBuilder.append(c);
                prevWasQuote = false;
            }
        }

        if (stringBuilder.length() == 0) {
            return null;
        } else {
            return stringBuilder.toString();
        }
    }

    public String getStringValue(String keyword) throws LazyFitsException,
        EOFException {
        if (!loaded) {
            read();
        }

        if (!containsKey(keyword)) {
            throw new LazyFitsException("Requested key: " + keyword
                + " not found in FITS header");
        } else {
            return keywordValuePairs.get(keyword);
        }
    }

    public int getIntValue(String keyword) throws LazyFitsException,
        EOFException {
        if (!loaded) {
            read();
        }
        if (!containsKey(keyword)) {
            throw new LazyFitsException("Requested key: " + keyword
                + " not found in FITS header");
        } else {
            return Integer.parseInt(keywordValuePairs.get(keyword));
        }
    }

    public float getFloatValue(String keyword) throws LazyFitsException,
        EOFException {
        if (!loaded) {
            read();
        }
        if (!containsKey(keyword)) {
            throw new LazyFitsException("Requested key: " + keyword
                + " not found in FITS header");
        } else {
            return Float.parseFloat(keywordValuePairs.get(keyword));
        }
    }

    public double getDoubleValue(String keyword) throws LazyFitsException,
        EOFException {
        if (!loaded) {
            read();
        }
        if (!containsKey(keyword)) {
            throw new LazyFitsException("Requested key: " + keyword
                + " not found in FITS header");
        } else {
            return Double.parseDouble(keywordValuePairs.get(keyword));
        }
    }

    public boolean hasData() {
        return hasData;
    }

    public boolean containsKey(String keyword) throws LazyFitsException,
        EOFException {
        if (!loaded) {
            read();
        }
        return keywordValuePairs.containsKey(keyword);
    }

    public Set<String> keySet() throws LazyFitsException, EOFException {
        if (!loaded) {
            read();
        }
        return keywordValuePairs.keySet();
    }
}
