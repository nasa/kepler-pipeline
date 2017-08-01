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

import gov.nasa.kepler.common.FcConstants;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class merges the SSR quantized FFI data from multiple ETEM2 runs (one
 * per module/output) into one file per module.
 * 
 * @author tklaus
 * 
 */
public class FfiMerge {
    private static final Log log = LogFactory.getLog(FfiMerge.class);

    private static final String FFI_DATA_FILE_NAME = "ssrOutput/ffiData.dat";
    private File etemOutputDir;
    private File mergeOutputDir;
    private String cadenceType;

    public FfiMerge(File etemOutputDir, File mergeOutputDir, String cadenceType) {
        this.etemOutputDir = etemOutputDir;
        this.mergeOutputDir = mergeOutputDir;
        this.cadenceType = cadenceType;
    }

    public void doMerge() throws IOException {

        mergeOutputDir.mkdirs();

        for (int ccdModule : FcConstants.modulesList) {

            File mergeOutputFile = new File(mergeOutputDir,
                mergedFileName(ccdModule));
            DataOutputStream merged = new DataOutputStream(
                new BufferedOutputStream(new FileOutputStream(mergeOutputFile)));

            for (int ccdOutput : FcConstants.outputsList) {
                File runDir = new File(etemOutputDir, EtemUtils.runDir(
                    ccdModule, ccdOutput, "1", cadenceType));

                if (!runDir.exists()) {
                    log.error("Missing directory: " + runDir.getAbsolutePath());
                    continue;
                }

                File ffiDataFile = new File(runDir, FFI_DATA_FILE_NAME);
                if (!ffiDataFile.exists()) {
                    log.error("Missing file: " + ffiDataFile.getAbsolutePath());
                    continue;
                }
                RandomAccessFile ffiDataReader = new RandomAccessFile(
                    ffiDataFile, "r");

                log.info("processing Module/Output: " + ccdModule + "/"
                    + ccdOutput);
                log.info("runDir: " + runDir);
                log.info("ffiDataFile: " + ffiDataFile);

                long ffiDataFileLength = ffiDataFile.length() / 2;

                for (long i = 0; i < ffiDataFileLength; i++) {
                    merged.writeShort(ffiDataReader.readShort());
                }

                ffiDataReader.close();
            }
            merged.close();
        }
        log.info("Done");
    }

    private String mergedFileName(int ccdModule) {
        return "mergedFfiData" + "-" + ccdModule + ".dat";

    }
    
    public static void main(String[] args) throws IOException {
        FfiMerge ffiMerge = new FfiMerge( new File(args[0]), new File(args[1]), args[2] );
        ffiMerge.doMerge();
    }
}
