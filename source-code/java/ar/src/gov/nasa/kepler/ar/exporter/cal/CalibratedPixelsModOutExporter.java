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

package gov.nasa.kepler.ar.exporter.cal;

import static gov.nasa.kepler.common.FitsConstants.*;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.concurrent.MiniWork;
import gov.nasa.spiffy.common.concurrent.MiniWorkPool;

import java.io.IOException;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import nom.tam.fits.FitsException;

/**
 * Export a single mod/out of pixels, cosmic rays and processing history.
 * @author Sean McCauliff
 *
 */
class CalibratedPixelsModOutExporter {

    private static final Log log = 
        LogFactory.getLog(CalibratedPixelsModOutExporter.class);
    
    private final int ccdModule;
    private final int ccdOutput;
    private final FileStoreClient fileStore;
    private final FileInfoSource fileInfoSource;
    
    CalibratedPixelsModOutExporter(int ccdModule, int ccdOutput, 
        FileStoreClient fileStore, FileInfoSource fileInfoSource) {
        
        this.ccdModule = ccdModule;
        this.ccdOutput = ccdOutput;
        this.fileStore = fileStore;
        this.fileInfoSource = fileInfoSource;
    }
    
    /**
     * Gather a module/output worth of data and then write it into all the Fits
     * files.
     * 
     * @throws InterruptedException
     * 
     */
    public void exportPixelsForModuleOutput(
        int cadenceType, int startCadence, int endCadence,
        MjdToCadence mjdToCadence) throws FitsException, IOException,
        InterruptedException {

        Map<FsId, IntTimeSeries> uncalibratedData = 
            uncalPixelsForOutput(startCadence, endCadence);

        CalibratedPixelExtractor calExtractor = 
            calibratedPixelsForOutput(startCadence, endCadence, mjdToCadence);

        writeOutPixels(uncalibratedData, calExtractor);

        writeOutCosmicRays(mjdToCadence, calExtractor);
    }

    private CalibratedPixelExtractor calibratedPixelsForOutput(int startCadence,
        int endCadence, MjdToCadence mjdToCadence)
        throws FitsException, IOException {

        log.info("Extracting calibrated pixels and cosmic rays.");
        CalibratedPixelExtractor calExtractor = new CalibratedPixelExtractor(
            fileStore, mjdToCadence, startCadence, endCadence, ccdModule, ccdOutput);

        for (OutputFileInfo info : fileInfoSource.calibratedPixelFiles()) {
            calExtractor.addPixels(info, info.pixelDataType());
        }

        calExtractor.loadPixelsAndRays();

        return calExtractor;

    }

    /**
     * Get the all the FsIds and their time series.
     */
    private Map<FsId, IntTimeSeries> uncalPixelsForOutput(int startCadence, 
                                                          int endCadence) 
        throws FitsException, IOException {

        log.info("Getting original pixels.");

        Set<FsId> pixelNames = new LinkedHashSet<FsId>();

        for (OutputFileInfo info : fileInfoSource.calibratedPixelFiles()) {
            List<FsId> calIds = info.pixelDataType()
                .pixelIds(info, ccdModule, ccdOutput, FsIdFactoryType.ORIG);
            pixelNames.addAll(calIds);
        }

        // Ask for the pixels in the same order as they where added to the
        // file store. "We hope."
        FsId[] ids = new FsId[pixelNames.size()];
        Iterator<FsId> it = pixelNames.iterator();
        for (int i = 0; i < ids.length; i++) {
            ids[i] = it.next();
        }

        IntTimeSeries[] series = fileStore.readTimeSeriesAsInt(ids,
            startCadence, endCadence);

        Map<FsId, IntTimeSeries> rv = new HashMap<FsId, IntTimeSeries>();
        for (IntTimeSeries ts : series) {
            ts.fillGaps(MISSING_PIXEL_VALUE);
            rv.put(ts.id(), ts);
        }

        return rv;

    }
  
    private void writeOutPixels(
        final Map<FsId, IntTimeSeries> uncalibratedData,
        final CalibratedPixelExtractor calExtractor) throws FitsException,
        IOException, InterruptedException {

        log.info("Writing pixel data, updating processing history.");

        MiniWork<OutputFileInfo> miniWorker = new MiniWork<OutputFileInfo>() {

            @Override
            protected void doIt(OutputFileInfo info) throws Throwable {
                ProcessingHistoryFile historyFile = 
                    fileInfoSource.processingHistoryFiles()
                    .get(info.processingHistoryFileName());
                info.pixelDataType()
                    .update(info, ccdModule, ccdOutput, uncalibratedData,
                        calExtractor.calibratedPixels(), historyFile);
            }
        };

        MiniWorkPool<OutputFileInfo> pool = 
            new MiniWorkPool<OutputFileInfo>("calibrated pixel exporter",
                fileInfoSource.calibratedPixelFiles(), miniWorker);

        pool.performAllWork();
    }
    
    
    private void writeOutCosmicRays(
        final MjdToCadence mjdToCadence, CalibratedPixelExtractor calExtractor)
        throws FitsException, InterruptedException, IOException {

        log.info("Write out cosmic rays.");

        final short smodule = (short) ccdModule;
        final short soutput = (short) ccdOutput;

        final Map<Double, Set<FloatMjdTimeSeries>> cosmicRaysByMjd = 
            calExtractor.cosmicRaysByMjd();
 

        MiniWork<CosmicRayFileInfo> miniWorker =
            new MiniWork<CosmicRayFileInfo>() {

            @SuppressWarnings("unchecked")
            @Override
            protected void doIt(CosmicRayFileInfo rayFileInfo)
                throws Throwable {
                int cadence = rayFileInfo.writer.cadence();
                double mjd = mjdToCadence.cadenceToMjd(cadence);
                Set<FloatMjdTimeSeries> raySet = cosmicRaysByMjd.get(mjd);
                if (raySet == null) {
                    raySet = Collections.EMPTY_SET;
                }

                if (rayFileInfo.pixelDataType.isCollateral()) {
                    CollateralCosmicRayModuleOutput modOut = new CollateralCosmicRayModuleOutput(
                        smodule, soutput, cadence, mjd);
                    modOut.addCollateralPixels(raySet, 
                        rayFileInfo.processingHistory);
                    synchronized (rayFileInfo.writer) {
                        rayFileInfo.writer.writeModuleOutput(modOut);
                    }
                } else {
                    VisibleCosmicRayModuleOutput modOut = new VisibleCosmicRayModuleOutput(
                        smodule, soutput, cadence, mjd);
                    modOut.addPixels(raySet, rayFileInfo.writer.tnaMap(),
                        rayFileInfo.processingHistory);
                       
                    synchronized (rayFileInfo.writer) {
                        rayFileInfo.writer.writeModuleOutput(modOut);
                    }
                }
            }

        };

        MiniWorkPool<CosmicRayFileInfo> pool = 
            new MiniWorkPool<CosmicRayFileInfo>("cosmic ray export", 
                fileInfoSource.cosmicRayFits().values(), miniWorker);
        pool.performAllWork();
    }

}
