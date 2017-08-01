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
import java.io.FileNotFoundException;
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
 * <pre>
 * The map of a long cadence is 
 *   ... 
 *   cadence n-1 
 *   ... 
 *   (start cadence n)
 *   nTargetPixels (all mod/outs) 
 *   nBackgroundPixels (all mod/outs) 
 *   nBlackValues (all mod/outs) 
 *   nMaskedSmearValues (all mod/outs) 
 *   nVirtualSmearValues (all mod/outs) 
 *   (end cadence n) 
 *   ... 
 *   cadence n+1 
 *   ...
 * </pre>
 * 
 * @author tklaus
 * 
 */
public class ScienceDataMerge {
    private static final Log log = LogFactory.getLog(ScienceDataMerge.class);

    /**
     * These are the pixel types as defined in the FS-GS ICD (FG673)
     * 
     * @author Todd Klaus tklaus@arc.nasa.gov
     * 
     */
    private enum PixelType {
        TARGET, BACKGROUND, COLLATERAL
    }

    private static final String QUANTIZED_DATA_FILE_NAME = "ssrOutput/quantizedCadenceData.dat";
    private static final int BYTES_PER_PIXEL = 2;

    private File etemOutputDir;
    private File mergeOutputDir;
    private String observingSeason;
    private int startCadence;
    private int endCadence;
    private String cadenceType;

    private int totalPixelCount;
    private int totalStellarPixelCount;
    private int totalBkgrndPixelCount;
    private int totalCollateralPixelCount;
    private int totalStellarTargetCount;
    private int totalBkgrndTargetCount;

    private Map<String, PixelCounts> pixelCountsCache;
    private Map<String, TargetCounts> targetCountsCache;

    public ScienceDataMerge(File etemOutputDir, File mergeOutputDir, String observingSeason, int startCadence,
        int endCadence, String cadenceType) {
        this.etemOutputDir = etemOutputDir;
        this.mergeOutputDir = mergeOutputDir;
        this.observingSeason = observingSeason;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.cadenceType = cadenceType;
    }

    public void doMerge() throws IOException {

        pixelCountsCache = new HashMap<String, PixelCounts>();
        targetCountsCache = new HashMap<String, TargetCounts>();

        mergeOutputDir.mkdirs();

        for (int currentCadence = startCadence; currentCadence <= endCadence; currentCadence++) {

            totalPixelCount = 0;
            totalStellarPixelCount = 0;
            totalBkgrndPixelCount = 0;
            totalCollateralPixelCount = 0;
            totalStellarTargetCount = 0;
            totalBkgrndTargetCount = 0;

            File mergeOutputFile = new File(this.mergeOutputDir, mergedFileName(currentCadence));
            DataOutputStream merged = new DataOutputStream(new BufferedOutputStream(new FileOutputStream(
                mergeOutputFile)));

            log.info("currentCadence: " + currentCadence);

            mergeDataSet(PixelType.TARGET, currentCadence, merged);
            mergeDataSet(PixelType.BACKGROUND, currentCadence, merged);
            mergeDataSet(PixelType.COLLATERAL, currentCadence, merged);

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

    /**
     * Merge the data for all module/outputs for the specified data set type.
     * 
     * @param currentCadence
     * @param merged
     * @throws FileNotFoundException
     * @throws IOException
     * @throws PipelineException
     */
    private void mergeDataSet(PixelType pixelType, int currentCadence, DataOutputStream merged)
        throws FileNotFoundException, IOException {

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                String modOut = "" + ccdModule + ":" + ccdOutput;
                File runDir = new File(etemOutputDir, EtemUtils.runDir(ccdModule, ccdOutput, observingSeason,
                    cadenceType));

                log.debug("processing Module/Output: " + ccdModule + "/" + ccdOutput);
                log.debug("runDir: " + runDir);

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
                int targetPixelCount = pixelCounts.getNTargetPixels();
                int backgroundPixelCount = pixelCounts.getNBackgroundPixels();
                int collateralPixelCount = pixelCounts.getNCollateralValues();

                if(pixelValuesPerCadence == 0){
                	
                	log.info("No targets on this mod/out, skipping");
                	
                }else{

                	int cadenceCount = pixelCounts.getNCadences();

                    if (currentCadence > cadenceCount) {
                        throw new PipelineException("requested cadence (" + currentCadence
                            + ") exceeds available cadenceCount(" + cadenceCount + ")");
                    }

                    File quantizedDataFile = new File(runDir, QUANTIZED_DATA_FILE_NAME);
                    RandomAccessFile quantizedDataReader = new RandomAccessFile(quantizedDataFile, "r");

                    log.debug("quantizedDataFile: " + quantizedDataFile);

                    long seekOffset = (currentCadence * pixelValuesPerCadence * BYTES_PER_PIXEL);
                    int numBytes = 0;
                    
                    switch (pixelType) {
                        case TARGET:
                            numBytes = targetPixelCount * BYTES_PER_PIXEL;
                            break;

                        case BACKGROUND:
                            numBytes = backgroundPixelCount * BYTES_PER_PIXEL;
                            seekOffset += targetPixelCount * BYTES_PER_PIXEL;
                            break;

                        case COLLATERAL:
                            numBytes = collateralPixelCount * BYTES_PER_PIXEL;
                            seekOffset += targetPixelCount * BYTES_PER_PIXEL;
                            seekOffset += backgroundPixelCount * BYTES_PER_PIXEL;
                            break;

                        default:
                            throw new PipelineException("unknown pixel type: " + pixelType);
                    }

                    // seek to the correct position in this file for the current
                    // cadence and pixel type
                    quantizedDataReader.seek(seekOffset);

                    byte[] cadenceBytes = new byte[numBytes];
                    quantizedDataReader.readFully(cadenceBytes);
                    merged.write(cadenceBytes);

                    quantizedDataReader.close();

                    if(pixelType == PixelType.TARGET){
                        totalPixelCount += pixelValuesPerCadence;
                        totalStellarPixelCount += targetPixelCount;
                        totalBkgrndPixelCount += backgroundPixelCount;
                        totalCollateralPixelCount += collateralPixelCount;

                        totalStellarTargetCount += targetCounts.getTargetCount();
                        totalBkgrndTargetCount += targetCounts.getBackgroundCount();
                    }
                }
            }
        }
    }

    private String mergedFileName(int currentCadence) {
        return "mergedCadenceData" + "-" + currentCadence + ".dat";

    }
}
