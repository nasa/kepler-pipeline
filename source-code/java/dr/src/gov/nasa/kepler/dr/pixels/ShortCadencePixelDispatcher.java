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

package gov.nasa.kepler.dr.pixels;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.dr.dispatch.DispatchException;
import gov.nasa.kepler.mc.pmrf.PmrfCache;

import java.io.IOException;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Dispatches short cadence pixel fits files.
 * 
 * @author Miles Cote
 * 
 */
public class ShortCadencePixelDispatcher extends PixelDispatcher {

    private static final Log log = LogFactory.getLog(ShortCadencePixelDispatcher.class);

    public ShortCadencePixelDispatcher() {
        cadenceType = Cadence.CADENCE_SHORT;
    }

    @Override
    protected void extractAndStoreTimeSeriesData(List<String> fileNames,
        String sourceDirectory) {
        pmrfCache = new PmrfCache(CadenceType.valueOf(cadenceType));

        long startTime = System.currentTimeMillis();

        timeSeriesBuffer = new TimeSeriesBuffer(startCadence, endCadence,
            overwriteGaps);

        int fileCount = 0;
        for (String fitsFileName : fileNames) {
            if (!ignoredFilenames.contains(fitsFileName)) {
                if (fileCount % 1000 == 0) {
                    log.info("Processed " + fileCount + " of "
                        + fileNames.size() + " files for "
                        + "(dataset/table) = (" + dataSetType + "/"
                        + targetTableType + ")");
                }

                CadenceFitsPair fitsFiles = new CadenceFitsPair(
                    sourceDirectory, fitsFileName, dataSetType,
                    targetTableType, pmrfCache, fitsMetadataCache);

                for (int ccdModule : FcConstants.modulesList) {
                    for (int ccdOutput : FcConstants.outputsList) {
                        fitsFiles.setCurrentModuleOutput(ccdModule, ccdOutput);
                        processCadenceForModuleOutput(fitsFiles, ccdModule,
                            ccdOutput);
                    }
                }

                try {
                    fitsFiles.close();
                } catch (IOException e) {
                    throw new DispatchException("Unable to close.  ", e);
                }

                fileCount++;
            }
        }

        timeSeriesBuffer.flush();

        log.info("total time = "
            + ((System.currentTimeMillis() - startTime) / 1000F) + " secs.");
    }

}
