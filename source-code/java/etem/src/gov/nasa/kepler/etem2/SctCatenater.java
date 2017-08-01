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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.RandomAccessFile;
import java.math.BigInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/*
 * This class reads files containing Log Entries for the Storage Correlation
 * Table, and produces a single output file containing the whole SCT. 
 * For Log Entries in the second through Nth input file,
 * the Data Set SSR Offset field is updated so that 
 * the output SCT represents a contiguous set of entries.
 */

class SctCatenater {

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
    private static final Log log = LogFactory.getLog(SctCatenater.class);

    // main simply passes arguments to run()
    public static void main(String[] args) throws Exception {

        if (args.length < 5) {
            error("usage:   java SctCatenater\n"
                + "                sctOutputFilePath\n"
                + "                startingOffsetInputFilePath\n"
                + "                endingOffsetOutputFilePath\n"
                + "                longCadencesPerInputFile\n"
                + "                inputDirs...\n"
                + "example: java SctCatenater\n"
                + "                /blah/ort4b/sct.complete.dat\n"
                + "                \"\"\n"
                + "                /blah/ort4b/sct.offset\n"
                + "                1640\n"
                + "                /blah/ort4b/p-fpg\n"
                + "                /blah/ort4b/p-s1\n"
                + "                /blah/ort4b/p-s2\n"
                + "                /blah/ort4b/p-g1\n"
                + "                /blah/ort4b/p-g2\n"
                + "                /blah/ort4b/p-dithered\n");
            throw new Exception("expecting at least 5 arguments, got "
                + args.length);
        }

        String[] inDir = new String[args.length - 4];
        for (int i = 4; i < args.length; i++) {
            inDir[i - 4] = args[i];
        }

        SctCatenater s = new SctCatenater();
        s.run(args[0], 
            ( args[1].length() == 0 ? null : args[1] ), args[2], Integer.valueOf(args[3]), inDir);
    } // SctCatenater main

    /*
     * run() reads cadence files and generates the output file
     * 
     * Example:  Making an sct.complete.dat file for 3 datasets in a given "period1":
     * run() arguments: 
     *      sctOutputFilePath:              "/path/to/etem2/auto/gsit5a/period1/sct.complete.dat"
     *      startingOffsetInputFilePath:    null
     *      endingOffsetOutputFilePath:     "/path/to/etem2/auto/gsit5a/period1/sct.offset"
     *      longCadencesPerInputFile;       1440
     *      inputDir array:                 "/path/to/etem2/auto/gsit5a/period1/vc15",
     *                                      "/path/to/etem2/auto/gsit5a/period1/7d-1",
     *                                      "/path/to/etem2/auto/gsit5a/period1/30d"
     * 
     * Further example:  Making an sct.complete.dat file for 2 datasets in a subsequent "period2": 
     * run() arguments: 
     *      sctOutputFilePath:              "/path/to/etem2/auto/gsit5a/period2/sct.complete.dat"
     *      startingOffsetInputFilePath:    "/path/to/etem2/auto/gsit5a/period1/sct.offset"
     *      endingOffsetOutputFilePath:     "/path/to/etem2/auto/gsit5a/period2/sct.offset"
     *      longCadencesPerInputFile;       1440
     *      inputDir array:                 "/path/to/etem2/auto/gsit5a/period2/ffi",
     *                                      "/path/to/etem2/auto/gsit5a/period2/30d"
     * 
     * We concatenate all sct.dat files in the packetized/ccsds subdir under
     * each inputDir, adjusting the SSR offsets for sct.dat files after the
     * first one.
     */
    public void run(String sctOutputFilePath,
        String startingOffsetInputFilePath,
        String endingOffsetOutputFilePath,
        int longCadencesPerInputFile,
        String[] inputDir) 
    throws Exception {

        try {

            String sctFilename = null;
            File input;
            long inLength;
            int gotBytes;
            int startOffset = 0;
            int thisOffset = 0;
            int lastOffset = 0;
            int lastLength = 0;
            int ssrOffset = 0;
            byte[] entry = new byte[LOG_ENTRY_SIZE];

            File[] inDir = new File[inputDir.length];
            for (int i = 0; i < inputDir.length; i++) {
                String dir = inputDir[i] + "/packetized/ccsds";
                inDir[i] = new File(dir);
                if (!inDir[i].exists()) {
                    throw new Exception("missing input dir:" + dir);
                }
            }

            DataOutputStream sctOutput = new DataOutputStream(
                new FileOutputStream(sctOutputFilePath));

            if (null != startingOffsetInputFilePath) {
                File startingOffsetInputFile = new File(
                    startingOffsetInputFilePath);
                if (startingOffsetInputFile.exists()) {
					status("reading starting offset from file " + startingOffsetInputFilePath );
                    try {
                        BufferedReader startingOffsetInput = new BufferedReader(
                            new FileReader(
                                new File(startingOffsetInputFilePath)));
                        String val = startingOffsetInput.readLine();
                        startOffset = Integer.parseInt(val);
                    } catch (Exception e) {
                        throw new Exception("cannot read offset from "
                            + startingOffsetInputFilePath);
                    }
                } else {
                    throw new Exception("missing input file "
                        + startingOffsetInputFilePath);
                }
            }
			status("startOffset= " + startOffset);
            ssrOffset = startOffset;

            for (int dirNum = 0; dirNum < inDir.length; dirNum++) {
                status("processing input directory " + inputDir[dirNum]);

                int startCadence = 0;
                int endCadence = longCadencesPerInputFile - 1;

                boolean moreInputFiles = true;
                while (moreInputFiles) {
                    sctFilename = "sct." + startCadence + "-" + endCadence
                        + ".dat";
                    input = new File(inDir[dirNum], sctFilename);
                    if (!input.exists()) {
                        // the final sct file may contain a shortened range,
                        // e.g. sct.0-95.dat    (96)
                        //      sct.96-191.dat  (96)
                        //      sct.192-199.dat (only 8)
                        // so when sct.192-287.dat isn't found, we search for
                        //      sct.192-192.dat
                        //      sct.192-193.dat
                        //      sct.192-194.dat
                        //      ...
                        // until we find the final file or we count through
                        // the range of possibilities.
                        for (int i = startCadence; i < startCadence
                            + longCadencesPerInputFile; i++) {
                            sctFilename = "sct." + startCadence + "-" + i
                                + ".dat";
                            input = new File(inDir[dirNum], sctFilename);
                            if (input.exists()) {
                                // found e.g. sct.192-199.dat
                                break;
                            }
                        }
                        if (input.exists()) {
                            // we process it, and then stop
                            moreInputFiles = false;
                        } else {
                            // didn't find a file, so we exit the loop now
							status("did not find an sct file in " + inDir[dirNum]);
                            break;
                        }
                    }

                    status("reading " + sctFilename);
                    //status("thisOffset= " + thisOffset);

                    RandomAccessFile in = new RandomAccessFile(input, "r");

                    byte[] intValue = new byte[4];

                    while (true) {
                        gotBytes = in.read(entry);
                        if (-1 == gotBytes) {
                            break;
                        }

                        // get the Data Set SSR Offset field from the Log Entry
                        intValue[0] = entry[O_O_O + 0];
                        intValue[1] = entry[O_O_O + 1];
                        intValue[2] = entry[O_O_O + 2];
                        intValue[3] = entry[O_O_O + 3];
                        BigInteger b = new BigInteger(intValue);
                        thisOffset = b.intValue();
                        status("entry thisOffset= " + thisOffset);

                        // remember the last offset we saw.
                        // when we're done with this chunk of the SCT
                        // we use this value to bump the ssrOffset
                        lastOffset = thisOffset;

                        /*
                         * add to the field the growing ssrOffset 
                         *     Example:
                         *          sct.0-3.dat has Log Entries for Long Cadences but
                         *          not Short Cadences. Shown are sample Log Entries
                         *          (Long Cadence offsets and lengths in the SSR). In
                         *          brackets are shown nonexistent Log Entries for Short
                         *          Cadences to help illustrate how they affect the
                         *          offsets of the Long Cadences.
                         * 
                         *          SSR Offset     Dataset Length 
                         *          ----------     -------------- 
                         *                   0     5     (Long Cadence) 
                         *                {  5     1 }   (Short Cadence, not in table) 
                         *                {  6     2 }   (Short Cadence, not in table) 
                         *                   8     5     (Long Cadence) 
                         *                { 13     1 }   (Short Cadence, not in table) 
                         *                { 14     2 }   (Short Cadence, not in table) 
                         *                  16     5     (Long Cadence) 
                         *                { 21     1 }   (Short Cadence, not in table) 
                         *                { 22     2 }   (Short Cadence, not in table) 
                         *                  24     5     (Long Cadence)
                         * 
                         *     DataSetPacker makes files with entries like this:
                         *          sct.0-2.dat: 
                         *                   0     5     (Long Cadence) 
                         *                   8     5     (Long Cadence) 
                         *                  16     5     (Long Cadence) 
                         *          sct.3-3.dat: 
                         *                   3     5     (Long Cadence)
                         * 
                         *     We must adjust the SSR offset in each Log Entry to
                         *     reachieve the correct values. 
                         *     The first entry from sct.3-3.dat should have its offset changed from 0 to 24. 
                         *     To do this, we remember the last offset and length 
                         *     seen while processing the previous file (sct.0-2.dat). 
                         *     This remembered value is added to a
                         *     growing SSR offset that is added to the offset field
                         *     in Log Entries as subsequent sct files are processed.
                         *     So, in the example, after processing sct.0-2.dat, 
                         *     the growing SSR offset is 16+5=21. 
                         *     And when processing sct.3-3.dat, we add that value 
                         *     to the offset field in * the Log Entry, 
                         *     so 21+3=24 and the Log Entries written
                         *     to sct.complete.dat are: 
                         *          sct.complete.dat: 
                         *                   0     5    (Long Cadence) 
                         *                   8     5    (Long Cadence) 
                         *                  16     5    (Long Cadence) 
                         *                  24     5    (Long Cadence)
                         */
                        thisOffset += ssrOffset; // TODO handle wrapping past
                                                    // end of SSR?
                        status("adjusted entry thisOffset= " + thisOffset);

                        // prepare to put the new offset back into the Log Entry
                        // (do as a separate step to allow checking new value
                        // using BigInteger)
                        intValue[0] = (byte) (thisOffset       >>> 24);
                        intValue[1] = (byte) (thisOffset <<  8 >>> 24);
                        intValue[2] = (byte) (thisOffset << 16 >>> 24);
                        intValue[3] = (byte) (thisOffset << 24 >>> 24);
                        /*
                         * b = new BigInteger( intValue ); int i = b.intValue();
                         * debug( "offset was="+lastOffset+", now=" + i );
                         */

                        // put the field back into the Log Entry
                        entry[O_O_O + 0] = intValue[0];
                        entry[O_O_O + 1] = intValue[1];
                        entry[O_O_O + 2] = intValue[2];
                        entry[O_O_O + 3] = intValue[3];

                        // write the updated Log Entry to the catenated output
                        // file
                        sctOutput.write(entry, 0, LOG_ENTRY_SIZE);

                        // get the Data Set Length field from the Log Entry
                        intValue[0] = entry[O_O_L + 0];
                        intValue[1] = entry[O_O_L + 1];
                        intValue[2] = entry[O_O_L + 2];
                        intValue[3] = entry[O_O_L + 3];
                        b = new BigInteger(intValue);
                        lastLength = b.intValue();

                        // debug( "ssrOffset=" + ssrOffset + ", thisOffset=" +
                        // thisOffset + ", lastOffset=" + lastOffset+ ",
                        // lastLength=" + lastLength );
                    }

                    in.close();

                    // add to the growing ssrOffset that Data Set Length
                    ssrOffset += lastOffset + lastLength; // TODO handle wrapping past end of SSR?
                    // debug( "ssrOffset ='" + ssrOffset + "'" );

                    startCadence += longCadencesPerInputFile;
                    endCadence += longCadencesPerInputFile;
                } // end processing sct.dat files in current inputDir
            } // end looping through inputDirs

            sctOutput.close();

            BufferedWriter endingOffsetOutput = new BufferedWriter(
                new FileWriter(new File(endingOffsetOutputFilePath)));
            endingOffsetOutput.write(ssrOffset + "\n");
            endingOffsetOutput.close();

        } catch (Exception e) {
            error("SctCatenater failed");
            e.printStackTrace();
            throw e;
        }

    } // SctCatenater run

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

} // class SctCatenater
