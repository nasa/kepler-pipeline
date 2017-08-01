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

import gov.nasa.kepler.common.FilenameConstants;

import java.io.File;

import org.apache.commons.io.FileUtils;

public class DataSetPackerDebug {

    /**
     * @param args
     * @throws Exception 
     */
    public static void main(String[] args) throws Exception {

        DataSetPacker dataSetPacker = new DataSetPacker();

        /*
         * VTC is represented as 5 bytes. Bytes 0-3 are the seconds and byte 4
         * is fraction of seconds (where LSB is 4.096 msec). fractional part =
         * fractional seconds / SECS_PER_VTC_FRACTIONAL_COUNT
         */

        int photometerTableId = 101;
        double vtcStartSeconds = 330672636.62784; // = 6/24/2010
                                                            // 17:29:36.8448 -
                                                            // J2000 - 30d
        double vtcIncrementSeconds = 59.78304; // one short cadence

        double SECS_PER_VTC_FRACTIONAL_COUNT = 4.096 / 1000.0;

        long vtcStartWholePart = (long) vtcStartSeconds;
        short vtcStartFracPart = (short) ((vtcStartSeconds - Math.floor(vtcStartSeconds)) / SECS_PER_VTC_FRACTIONAL_COUNT);
        long vtcStart = (vtcStartWholePart << 8) + vtcStartFracPart;

        long vtcIncrementWholePart = (long) vtcIncrementSeconds;
        short vtcIncrementFracPart = (short) ((vtcIncrementSeconds - Math.floor(vtcIncrementSeconds)) / SECS_PER_VTC_FRACTIONAL_COUNT);
        long vtcIncrement = (vtcIncrementWholePart << 8) + vtcIncrementFracPart;

        /*
         * Photometer config ID is 8 bytes consisting of: 0 flags 1 long cadence
         * target table id 2 short cadence target table id 3 background target
         * table id 4 background aperture table id 5 science aperture table id 6
         * reference pixel target table id 7 compression table id
         */
        int tableId = 102;
        long photometerConfigId;
        photometerConfigId = 0x08; // all flags = 0, except finePoint = 1
        photometerConfigId = (photometerConfigId << 8) + tableId; // use the
                                                                    // same id
                                                                    // for all
                                                                    // tables
        photometerConfigId = (photometerConfigId << 8) + tableId;
        photometerConfigId = (photometerConfigId << 8) + tableId;
        photometerConfigId = (photometerConfigId << 8) + tableId;
        photometerConfigId = (photometerConfigId << 8) + tableId;
        photometerConfigId = (photometerConfigId << 8) + tableId;
        photometerConfigId = (photometerConfigId << 8) + tableId;

        // public void run(
        // String babbleFlags,
        // String inputDirPath,
        // String outputDirPath,
        //
        // int numShortCadencesPerLongCadence,
        //
        // int numLongCadencesPerBaseline,
        // int startingLongCadenceFileNumber,
        // int numLongCadenceFilesToProcess,
        //
        // String filenameHuffmanTable,
        //
        // long photometerID,
        // long vtcStart,
        // long vtcIncrement

        String flags = "b";

        String etemDataDir = FilenameConstants.SOC_ROOT + "/etem2/debug/test/";
        String outDir = FilenameConstants.SOC_ROOT
            + "/etem2/debug/test/packetized/ccsds";
        String huffmanTableFile = FilenameConstants.SOC_ROOT
            + "/etem2/debug/test/config/huffman_codewords.txt";

        FileUtils.deleteDirectory(new File(outDir));
        FileUtils.forceMkdir(new File(outDir));
        
        dataSetPacker.run(flags, etemDataDir, outDir, "", 30, 48, 0, 48, 1, photometerConfigId, vtcStart, vtcIncrement);
    }

}
