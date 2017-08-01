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

package gov.nasa.kepler.etem2;

import static gov.nasa.kepler.common.FitsConstants.*;

import java.io.File;
import java.io.IOException;
import java.util.HashMap;

import nom.tam.fits.BasicHDU;
import nom.tam.fits.BinaryTable;
import nom.tam.fits.Data;
import nom.tam.fits.Fits;
import nom.tam.fits.Header;
import nom.tam.fits.HeaderCard;
import nom.tam.fits.ImageData;
import nom.tam.util.Cursor;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * 
 * @author tklaus
 * 
 */
public class FitsDiff {

    private class SSIS {
        short[] a1;
        short[] a2;
        int[] a3;
        short[] a4;
    }

    /**
     * Logger for this class
     */
    private static final Log log = LogFactory.getLog(FitsDiff.class);

    /*
     * private Fits[] fits = new Fits[ 2 ]; private BasicHDU[] hdu = new
     * BasicHDU[ 2 ]; private ImageData[] img = new ImageData[ 2 ];
     */

    private static String okMissingKeys = ",,"; // ",SCTPMTAB,";
    private static String okDifferentValuesForKeys = ",,"; // ",FILENAME,";

    /**
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws Exception {
        Logger logger = Logger.getLogger(FitsDiff.class);
        logger.setLevel(Level.INFO);
        org.apache.log4j.BasicConfigurator.configure();

        String filename1 = args[0];
        String filename2 = args[1];

        log.info("File 1: " + filename1);
        log.info("File 2: " + filename2);

        File file1 = new File(filename1);
        File file2 = new File(filename2);

        Fits fits1 = new Fits(filename1);
        Fits fits2 = new Fits(filename2);

        long len1 = file1.length();
        long len2 = file2.length();
        if (len1 != len2) {
            log.info("File lengths differ:  " + len1 + " <> " + len2);
        }

        for (int i = 2; i < args.length; i++) {
        }

        boolean stopOnHeaderMismatch = false;
        boolean dumpFirstRows = false;
        boolean dumpAllRows = false;
        boolean ignoreHeaderDiffs = false;
        boolean dumpHeader = false;
        boolean quiet = false;
        boolean allowDataDiffs = false;
        boolean allowTypeAndCountMismatch = false;
        boolean allowChannelMismatch = false;
        boolean ignoreDataDiffs = false;
        if (args.length > 2) {
            stopOnHeaderMismatch = (-1 != args[2].indexOf("s"));
            allowDataDiffs = (-1 != args[2].indexOf("a"));
            allowChannelMismatch = (-1 != args[2].indexOf("c"));
            dumpFirstRows = (-1 != args[2].indexOf("d"));
            dumpAllRows = (-1 != args[2].indexOf("D"));
            ignoreHeaderDiffs = (-1 != args[2].indexOf("i"));
            ignoreDataDiffs = (-1 != args[2].indexOf("I"));
            dumpHeader = (-1 != args[2].indexOf("h"));
            allowTypeAndCountMismatch = (-1 != args[2].indexOf("r"));
            quiet = (-1 != args[2].indexOf("q"));
        }

        BasicHDU hdu1 = fits1.readHDU();
        BasicHDU hdu2 = fits2.readHDU();

        boolean reportedColumnTypes = false;

        int max = (0 == 1 ? 3 : 85);
        for (int h = 0; hdu1 != null && hdu2 != null && h < max; h++) {
            // hdu1.info();
            // hdu2.info();

            Header hdr1 = hdu1.getHeader();
            Header hdr2 = hdu2.getHeader();

            int channel1 = hdr1.getIntValue(CHANNEL_KW);
            int channel2 = hdr2.getIntValue(CHANNEL_KW);

            if (channel1 != channel2) {
                error(allowChannelMismatch, "HDU#" + h
                    + ": Different channel numbers: " + channel1 + " versus "
                    + channel2);
            }

            if (!ignoreHeaderDiffs) {
                HashMap map1 = new HashMap();
                HashMap map2 = new HashMap();

                HeaderCard card1;
                HeaderCard card2;

                int numKeys1 = 0;
                int numKeys2 = 0;

                boolean headersMatch = true;
                String key;
                String keyMark;
                String value1;
                String value2;

                Cursor iter = hdr1.iterator();
                while (iter.hasNext()) {
                    card1 = (HeaderCard) iter.next();
                    if (card1.isKeyValuePair()) {
                        numKeys1++;
                        key = card1.getKey();
                        keyMark = "," + key + ",";
                        value1 = card1.getValue();
                        if (dumpHeader) {
                            log.info("HDU#" + h + ": " + key + "=" + value1);
                        }
                        card2 = hdr2.findCard(key);
                        if (null == card2) {
                            if (-1 == okMissingKeys.indexOf(keyMark)) {
                                log.error("HDU#" + h + ": file2 missing key "
                                    + key + "=" + value1);
                                headersMatch = false;
                            }
                        } else {
                            numKeys2++;
                            value2 = card2.getValue();
                            if (!value1.equals(value2)) {
                                if (-1 == okDifferentValuesForKeys.indexOf(keyMark)) {
                                    log.error("HDU#" + h + ": " + key
                                        + " has different values: " + value1
                                        + " versus " + value2);
                                    headersMatch = false;
                                }
                            }
                        }
                        hdr1.deleteKey(key);
                        hdr2.deleteKey(key);
                        iter = hdr1.iterator();
                    }
                }

                iter = hdr2.iterator();
                while (iter.hasNext()) {
                    card2 = (HeaderCard) iter.next();
                    if (card2.isKeyValuePair()) {
                        numKeys2++;
                        key = card2.getKey();
                        keyMark = "," + key + ",";
                        value2 = card2.getValue();
                        card1 = hdr1.findCard(key);
                        if (null == card1) {
                            log.error("HDU#" + h + ": file1 missing key " + key
                                + "=" + value2);
                            if (-1 == okMissingKeys.indexOf(keyMark)) {
                                headersMatch = false;
                            }
                        }
                    }
                }

                if (!headersMatch) {
                    log.info("HDU#" + h + ": #keys: " + numKeys1
                        + (numKeys1 == numKeys2 ? " == " : " <> ") + numKeys2);
                }

                if (!headersMatch && stopOnHeaderMismatch) {
                    return;
                }
            } // if ! ignoreHeaderDiffs

            Data data1 = hdu1.getData();
            if (data1 instanceof BinaryTable) {
                /*
                 * BinaryTable[] tab = new BinaryTable[ 2 ]; tab[0] =
                 * (BinaryTable) hdu1.getData(); tab[1] = (BinaryTable)
                 * hdu2.getData();
                 */
                BinaryTable tab1 = (BinaryTable) hdu1.getData();
                BinaryTable tab2 = (BinaryTable) hdu2.getData();

                if (!sizesAllOne(tab1, 1) || !sizesAllOne(tab2, 2)) {
                    return;
                }

                String colTypes1 = getColumnTypes(tab1, 1);
                String colTypes2 = getColumnTypes(tab2, 2);

                String typeErrMsg = "";

                if (!colTypes1.equals(colTypes2)) {
                    typeErrMsg = "HDU#" + h + ": types differ: " + colTypes1
                        + " versus " + colTypes2;
                }

                int nrows1 = tab1.getNRows();
                int nrows2 = tab2.getNRows();

                if (nrows1 != nrows2) {
                    if (0 != typeErrMsg.length()) {
                        typeErrMsg += "\n";
                    }
                    typeErrMsg += "HDU#" + h + ": row counts differ: " + nrows1
                        + " versus " + nrows2;
                }

                if (0 != typeErrMsg.length()) {
                    if (allowTypeAndCountMismatch) {
                        warning(typeErrMsg);
                    } else {
                        error(typeErrMsg);
                    }
                }

                if (!quiet) {
                    log.info("HDU#" + h + ": #rows: " + nrows1);
                }

                if (!reportedColumnTypes) {
                    log.info("HDU#" + h + ": column types: " + colTypes1);
                    reportedColumnTypes = true;
                }

                for (int r = 0; r < nrows1; r++) {
                    String vals1 = getRowValues(tab1, r, colTypes1, 1, h);
                    String vals2 = getRowValues(tab2, r, colTypes1, 2, h);

                    // log.info( "row " + r + ": vals1=" + vals1 + " vals2=" +
                    // vals2 );

                    if (!ignoreDataDiffs && !vals1.equals(vals2)) {
                        String s = "HDU#" + h + ": row#" + r + " differs: "
                            + vals1 + " versus " + vals2;
                        error(allowDataDiffs, s);
                    } else {
                        if (dumpAllRows || (dumpFirstRows && r < 10)) {
                            log.info("HDU#" + h + ": row#" + r + " values: "
                                + vals1);
                        }
                    }
                }
            } else if (data1 instanceof ImageData) {
                ImageData img1 = (ImageData) hdu1.getData();
                ImageData img2 = (ImageData) hdu2.getData();

                long size1 = img1.getSize();
                long size2 = img2.getSize();

                log.info("HDU#" + h + ": file1, image data size = " + size1);
                log.info("HDU#" + h + ": file2, image data size = " + size2);

                if (size1 != size2) {
                    error("HDU#" + h + ": diff data sizes: " + size1
                        + " versus " + size2);
                }

                Object d1 = img1.getData();
                Object d2 = img2.getData();
//                log.info("img1=" + img1 + ", img2=" + img2);
//                log.info("d1=" + d1 + ", d2=" + d2);
                if (null == d1) {
                    log.info("HDU#" + h + ": data for file1 is null");
                }
                if (null == d2) {
                    log.info("HDU#" + h + ": data for file2 is null");
                }

                if ((d1 == null && d1 != null) || (d1 != null && d2 == null)) {
                    error("HDU#" + h + ": missing data");
                    continue;
                }
                if (d1 == null && d2 == null) {
                    log.info("no data for either file1 or file2");
                } else {
//                    log.info("float[][].class = " + float[][].class);
//                    log.info("img1.getData().getClass() = " + d1.getClass());

                    if (float[][].class == d1.getClass()) {

                        float[][] aaf1 = (float[][]) d1; // img1.getData();
                        float[][] aaf2 = (float[][]) d2; // img2.getData();

                        log.info("HDU#" + h
                            + ": float data for file1 has length = "
                            + aaf1.length);
                        log.info("HDU#" + h
                            + ": float data for file2 has length = "
                            + aaf2.length);

                        int offset = 0;
                        for (int i = 0; i < aaf1.length; i++) {
                            float[] f1 = aaf1[i];
                            float[] f2 = aaf2[i];
                            size1 = f1.length;
                            size2 = f2.length;
                            if (size1 != size2) {
                                error("HDU#" + h + ": data row " + i
                                    + ": diff number of columns: " + size1
                                    + " versus " + size2);
                            }
                            for (int j = 0; j < f1.length; j++) {
                                if (j < 0)
                                    System.err.println("f1["
                                        + j
                                        + "]="
                                        + f1[j]
                                        + "=0x"
                                        + Integer.toHexString(Float.floatToIntBits(f1[j]))
                                        + ", f2["
                                        + j
                                        + "]="
                                        + f2[j]
                                        + "=0x"
                                        + Integer.toHexString(Float.floatToIntBits(f2[j])));
                                if (f1[j] != f2[j]) {
                                    System.err.println("f1[" + j + "]=" + f1[j]
                                        + ", f2[" + j + "]=" + f2[j]);
                                    Float x1 = new Float(f1[j]);
                                    Float x2 = new Float(f2[j]);
                                    error(
                                        allowDataDiffs,
                                        "HDU#"
                                            + h
                                            + ": offset="
                                            + offset
                                            + ": data row "
                                            + i
                                            + ", column "
                                            + j
                                            + ": diff int values: "
                                            + "0x"
                                            + Integer.toHexString(Float.floatToIntBits(f1[j]))
                                            + " versus "
                                            + "0x"
                                            + Integer.toHexString(Float.floatToIntBits(f2[j])));
                                }
                                offset += 4;
                            }
                        }
                    } else if ((new int[0][0]).getClass() == img1.getData()
                        .getClass()) {

                        int[][] aai1 = (int[][]) d1; // img1.getData();
                        int[][] aai2 = (int[][]) d2; // img2.getData();

                        log.info("HDU#" + h
                            + ": int data for file1 has length = "
                            + aai1.length);
                        log.info("HDU#" + h
                            + ": int data for file2 has length = "
                            + aai2.length);

                        int offset = 0;
                        for (int i = 0; i < aai1.length; i++) {
                            int[] i1 = aai1[i];
                            int[] i2 = aai2[i];
                            size1 = i1.length;
                            size2 = i2.length;
                            if (size1 != size2) {
                                error("HDU#" + h + ": data row " + i
                                    + ": diff number of columns: " + size1
                                    + " versus " + size2);
                            }
                            for (int j = 0; j < i1.length; j++) {
                                if (j < 0)
                                    System.err.println("i1[" + j + "]=" + i1[j]
                                        + "=0x" + Integer.toHexString(i1[j])
                                        + ", i2[" + j + "]=" + i2[j] + "=0x"
                                        + Integer.toHexString(i2[j]));
                                if (i1[j] != i2[j]) {
                                    System.err.println("i1[" + j + "]=" + i1[j]
                                        + ", i2[" + j + "]=" + i2[j]);
                                    error(allowDataDiffs, "HDU#" + h
                                        + ": offset=" + offset + ": data row "
                                        + i + ", column " + j
                                        + ": diff int values: " + "0x"
                                        + Integer.toHexString(i1[j])
                                        + " versus " + "0x"
                                        + Integer.toHexString(i2[j]));
                                }
                                offset += 4;
                            }
                        }

                    } else {
                        error("unhandled image data type: " + img1.getData()
                            .getClass());
                    }
                }
            }

            hdu1 = fits1.readHDU();
            hdu2 = fits2.readHDU();
        }
    }

    private static boolean sizesAllOne(BinaryTable tab, int f) {
        int[] sizes = tab.getSizes();
        String s = "";
        boolean ret = true;
        for (int j = 0; j < sizes.length; j++) {
            s += sizes[j] + ",";
            if (1 != sizes[j]) {
                ret = false;
            }
        }
        if (!ret) {
            warning("table " + f + " has a size != 1: " + s);
        }
        return ret;
    }

    private static String getColumnTypes(BinaryTable tab, int f) {
        String t = "";
        char[] types = tab.getTypes();
        for (int j = 0; j < types.length; j++) {
            t += types[j];
        }
        int nrows = tab.getNRows();
        int ncols = tab.getNCols();
        // log.info( "tab" + f + ": types=" + t +
        // " nrows=" + nrows + " ncols=" + ncols );
        return t;
    }

    private static String getRowValues(BinaryTable table, int r,
        String colTypes, int f, int h) throws Exception {
        String vals = "";
        Object[] row = table.getRow(r);
        // log.info( "row = " + row );
        // log.info( "row[0] = " + row[0] );
        byte[] ba;
        short[] sa;
        int[] ia;
        float[] fa;
        String comma = "";
        for (int t = 0; t < colTypes.length(); t++) {
            char ct = colTypes.charAt(t);
            switch (ct) {
                case 'B':
                    ba = (byte[]) row[t];
                    vals += comma + ba[0];
                    break;
                case 'S':
                    sa = (short[]) row[t];
                    vals += comma + sa[0];
                    break;
                case 'I':
                    ia = (int[]) row[t];
                    vals += comma + ia[0];
                    break;
                case 'F':
                    fa = (float[]) row[t];
                    vals += comma + fa[0];
                    break;
                default:
                    error("HDU#" + h + ": unhandled type " + ct + " in types "
                        + colTypes);
            }
            comma = ",";
        }
        return vals;
    }

    private static void error(String msg) throws Exception {
        log.error(msg);
        throw new Exception("\n" + msg);
    }

    private static void error(boolean allowable, String msg) throws Exception {
        log.error(msg);
        if (!allowable) {
            throw new Exception("\n" + msg);
        }
    }

    private static void warning(String msg) {
        log.error(msg);
    }

}
