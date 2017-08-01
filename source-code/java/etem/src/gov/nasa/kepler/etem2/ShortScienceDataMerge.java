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
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.BufferedOutputStream;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class merges the SSR quantized pixel data from multiple ETEM2 runs (one
 * per module/output) into a single data stream of all mod/out data for the
 * first cadence, followed by all mod/out data for the second cadence, and so
 * on.
 * 
 * TODO: fix this comment! This class now handles Short cadences. The map of a
 * long cadence is ... cadence n-1 ... (start cadence n) nTargetPixels
 * nBackgroundPixels nBlackValues nMaskedSmearValues nVirtualSmearValues (end
 * cadence n) ... cadence n+1 ...
 * 
 * @author tklaus
 * 
 */
public class ShortScienceDataMerge {
    private static final Log log = LogFactory.getLog(ShortScienceDataMerge.class);

    private static final String QUANTIZED_DATA_FILE_NAME = "ssrOutput/quantizedCadenceData.dat";
    private static final int BYTES_PER_PIXEL = 2;

    private File etemOutputDir;
    private File mergeOutputDir;
    private int startCadence;
    private int endCadence;
    private String cadenceType;
    /**
     * The number used in the merge filename is the currentCadence plus this
     * offset (normally zero except in the dithered case)
     */
    private int mergeFilenameCadenceNumberOffset;

    public ShortScienceDataMerge(File etemOutputDir, File mergeOutputDir, int startCadence, int endCadence,
        String cadenceType, int mergeFilenameCadenceNumberOffset) {
        this.etemOutputDir = etemOutputDir;
        this.mergeOutputDir = mergeOutputDir;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceType = cadenceType;
        this.mergeFilenameCadenceNumberOffset = mergeFilenameCadenceNumberOffset;
    }

    public void doMerge() throws IOException {

        Map<String, PixelCounts> pixelCountsCache = new HashMap<String, PixelCounts>();
        Map<String, TargetCounts> targetCountsCache = new HashMap<String, TargetCounts>();

        mergeOutputDir.mkdirs();

        for (int currentCadence = startCadence; currentCadence <= endCadence; currentCadence++) {

            int totalPixelCount = 0;
            int totalStellarPixelCount = 0;
            int totalBkgrndPixelCount = 0;
            int totalCollateralPixelCount = 0;

            int totalStellarTargetCount = 0;
            int totalBkgrndTargetCount = 0;

            File mergeOutputFile = new File(this.mergeOutputDir, mergedFileName(currentCadence
                + mergeFilenameCadenceNumberOffset));
            DataOutputStream merged = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(
                mergeOutputFile)));

            log.info("currentCadence: " + currentCadence);

            for (int ccdModule : FcConstants.modulesList) {
                for (int ccdOutput : FcConstants.outputsList) {
                    String modOut = "" + ccdModule + ":" + ccdOutput;
                    File runDir = new File(etemOutputDir, EtemUtils.runDir(ccdModule, ccdOutput, "1", cadenceType));

                    log.debug("processing Module/Output: " + ccdModule + "/" + ccdOutput);
                    log.debug("runDir: " + runDir);
                    if (!runDir.exists()) {
                        log.error("Missing directory: " + runDir.getAbsolutePath());
                        continue;
                    }

                    PixelCounts pixelCounts = pixelCountsCache.get(modOut);
                    TargetCounts targetCounts = targetCountsCache.get(modOut);

                    if (pixelCounts == null) {
                        pixelCounts = new PixelCounts(runDir, cadenceType);
                        targetCounts = new TargetCounts(runDir);

                        pixelCounts.log();
                        targetCounts.log();

                        pixelCountsCache.put(modOut, pixelCounts);
                        targetCountsCache.put(modOut, targetCounts);
                    }

                    int pixelValuesPerCadence = pixelCounts.getNValuesPerCadence();

                    if (pixelValuesPerCadence == 0) {

                        log.info("No targets on this mod/out, skipping");

                    } else {
                        File quantizedDataFile = new File(runDir, QUANTIZED_DATA_FILE_NAME);
                        RandomAccessFile quantizedDataReader = new RandomAccessFile(quantizedDataFile, "r");

                        log.debug("quantizedDataFile: " + quantizedDataFile);

                        int cadenceCount = pixelCounts.getNCadences();

                        if (currentCadence > cadenceCount) {
                            throw new PipelineException("requested cadence (" + currentCadence
                                + ") exceeds available cadenceCount(" + cadenceCount + ")");
                        }

                        totalPixelCount += pixelValuesPerCadence;
                        totalStellarPixelCount += pixelCounts.getNTargetPixels();
                        totalBkgrndPixelCount += pixelCounts.getNBackgroundPixels();
                        totalCollateralPixelCount += pixelCounts.getNCollateralValues();

                        totalStellarTargetCount += targetCounts.getTargetCount();
                        totalBkgrndTargetCount += targetCounts.getBackgroundCount();

                        // seek to the correct position in this file for the
                        // current cadence
                        long seekOffset = currentCadence * pixelValuesPerCadence * BYTES_PER_PIXEL;
                        quantizedDataReader.seek(seekOffset);

                        byte[] cadenceBytes = new byte[pixelValuesPerCadence * BYTES_PER_PIXEL];
                        quantizedDataReader.readFully(cadenceBytes);
                        merged.write(cadenceBytes);

                        quantizedDataReader.close();
                    }
                }
            }

            if (currentCadence == startCadence) {
                log.info("totalPixelCount = " + totalPixelCount);
                log.info("totalStellarPixelCount = " + totalStellarPixelCount);
                log.info("totalBkgrndPixelCount = " + totalBkgrndPixelCount);
                log.info("totalCollateralPixelCount = " + totalCollateralPixelCount);

                log.info("totalStellarTargetCount = " + totalStellarTargetCount);
                log.info("totalBkgrndTargetCount = " + totalBkgrndTargetCount);
            }

            merged.close();
        }

        log.info("Done");
    }

    private String mergedFileName(int currentCadence) {
        return "mergedCadenceData" + "-" + currentCadence + ".dat";

    }
}
