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

import java.io.File;
import java.io.RandomAccessFile;
import java.math.BigInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/*
 * Print the offset of the first and last SCT entries.
 */

class SctChecker {

    // Constants.

    // FSGS ICD 5.3.2.4.1, SCT Log Entry sizes and offsets
    static final int LOG_ENTRY_SIZE = 24; // 24 bytes
    // Dataset Offset field is 15 bytes into the Log Entry
    static final int OFFSET_OF_OFFSET = 15;
    static final int O_O_O = OFFSET_OF_OFFSET; // shorthand
    // Dataset Length field is 15 bytes into the Log Entry
    static final int OFFSET_OF_LENGTH = 19;
    static final int O_O_L = OFFSET_OF_LENGTH; // shorthand

    // static final int LENGTH_OF_OFFSET = 4;
    // static final int END_OF_OFFSET =
    // OFFSET_OF_OFFSET + LENGTH_OF_OFFSET - 1;

    // Logging setup
    private static final Log log = LogFactory.getLog(SctChecker.class);

    // main simply passes arguments to run()
    public static void main(String[] args) throws Exception {
        log.info("SctChecker");

        if (args.length != 1) {
            error("usage:  java SctChecker\n"
                + "                sctCompletePath" );
            throw new Exception("expecting 1 argument, got " + args.length);
        }

        SctChecker s = new SctChecker();
        s.run(args[0] ); 
    } // SctChecker main

    /*
     * run() reads sct.complete file and prints out the first and last log entries
     */
    public void run(String path )
    throws Exception {

        try {

            String sctFilename = null;
            File input;
            int gotBytes;
            byte[] entry = new byte[LOG_ENTRY_SIZE];

                    status("reading " + path);
                    
                    BigInteger lastOffset = null;
                    BigInteger lastLength = null;
                    int lastN = 0;

                    RandomAccessFile in = new RandomAccessFile(path, "r");

                    byte[] intValue = new byte[4];

                    for ( int n = 0; ; n++ ) {
                        gotBytes = in.read(entry);
                        if (-1 == gotBytes) {
                            break;
                        }

                        // get the Data Set SSR Offset field from the Log Entry
                        intValue[0] = entry[O_O_O + 0];
                        intValue[1] = entry[O_O_O + 1];
                        intValue[2] = entry[O_O_O + 2];
                        intValue[3] = entry[O_O_O + 3];
                        BigInteger off = new BigInteger(intValue);
                        lastOffset = off;

                        // get the Data Set Length field from the Log Entry
                        intValue[0] = entry[O_O_L + 0];
                        intValue[1] = entry[O_O_L + 1];
                        intValue[2] = entry[O_O_L + 2];
                        intValue[3] = entry[O_O_L + 3];
                        BigInteger len = new BigInteger(intValue);
                        lastLength = len;
                        lastN = n;
                        
                        if ( n == 0 ) {
                            status( "SCT entry #" + n + ": offset=" + off.intValue() + "  len=" + len.intValue());
                        }
                    }
                    
                    if ( true ) {
                        status( "SCT entry #" + lastN + ": offset=" + lastOffset.intValue() + "  len=" + lastLength.intValue());
                    }

                    in.close();

        } catch (Exception e) {
            error("SctChecker failed");
            e.printStackTrace();
            throw e;
        }

    } // SctChecker run

    public static void debug(String s) {
        log.debug(s);
        System.out.println(s);
    }

    public static void status(String s) {
        log.info(s);
        System.out.println(s);
    }

    public static void error(String s) {
        log.error(s);
        System.out.println(s);
    }

} // class SctChecker

