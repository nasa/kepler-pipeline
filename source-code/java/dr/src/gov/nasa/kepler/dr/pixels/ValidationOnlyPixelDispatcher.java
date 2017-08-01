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
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.mc.pmrf.PmrfCache;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.util.List;
import java.util.TreeSet;

import nom.tam.fits.Fits;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class mimics {@link LongCadencePixelDispatcher}, except that this class
 * doesn not store time series in the file store. Therefore, this class is to be
 * used for validating cadence fits files without storing them in the filestore,
 * which takes much longer than the validation.
 * 
 * @author Miles Cote
 * 
 */
public class ValidationOnlyPixelDispatcher extends PixelDispatcher {

    private static final String CHECK_FOR_MULTIPLE_TARGET_TABLES_PROP_NAME = "validationOnlyPixelDispatcher.checkForMultipleTargetTables";

    private static final Log log = LogFactory.getLog(ValidationOnlyPixelDispatcher.class);

    private boolean checkForMultipleTargetTables;

    public ValidationOnlyPixelDispatcher(DispatcherType dispatcherType) {
        switch (dispatcherType) {
            case LONG_CADENCE_PIXEL:
                cadenceType = Cadence.CADENCE_LONG;
                break;
            case SHORT_CADENCE_PIXEL:
                cadenceType = Cadence.CADENCE_SHORT;
                break;
        }

        checkForMultipleTargetTables = ConfigurationServiceFactory.getInstance()
            .getBoolean(CHECK_FOR_MULTIPLE_TARGET_TABLES_PROP_NAME, true);
    }

    @Override
    protected void extractAndStoreTimeSeriesData(List<String> fileNames,
        String sourceDirectory) {
        pmrfCache = new PmrfCache(CadenceType.valueOf(cadenceType));

        long startTime = System.currentTimeMillis();
        long modOutStartTime;
        IntervalMetricKey oneModOutKey = null;

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                try {
                    oneModOutKey = IntervalMetric.start();
                    modOutStartTime = System.currentTimeMillis();

                    log.info("Processing (module/output/dataset/table) = ("
                        + ccdModule + "/" + ccdOutput + "/" + dataSetType + "/"
                        + targetTableType + ")");

                    timeSeriesBuffer = new TimeSeriesBuffer(startCadence,
                        endCadence, overwriteGaps);

                    IntervalMetricKey allCadenceKey = null;
                    try {
                        allCadenceKey = IntervalMetric.start();
                        for (String fitsFileName : fileNames) {
                            if (!ignoredFilenames.contains(fitsFileName)) {
                                CadenceFitsPair fitsFiles = new CadenceFitsPair(
                                    sourceDirectory, fitsFileName, dataSetType,
                                    targetTableType, pmrfCache,
                                    fitsMetadataCache);
                                fitsFiles.setCurrentModuleOutput(ccdModule,
                                    ccdOutput);

                                processCadenceForModuleOutput(fitsFiles,
                                    ccdModule, ccdOutput);

                                try {
                                    fitsFiles.close();
                                } catch (IOException e) {
                                    throw new DispatchException(
                                        "Unable to close.  ", e);
                                }
                            }
                        }
                    } finally {
                        IntervalMetric.stop(
                            "dr.dispatch.pixel.allCadences.process",
                            allCadenceKey);
                    }

                    log.info("mod/out time = "
                        + ((System.currentTimeMillis() - modOutStartTime) / 1000F)
                        + " secs.");
                } finally {
                    IntervalMetric.stop(
                        "dr.dispatch.pixel.oneModuleOutput.process",
                        oneModOutKey);
                }
            }
        }

        log.info("total time = "
            + ((System.currentTimeMillis() - startTime) / 1000F) + " secs.");
    }

    @Override
    protected void storeFitsHeaders(String fitsFileName, Fits fits)
        throws Exception {
        // Don't store any fits headers because this is validation only.
    }

    @Override
    protected void flush() {
        // Don't flush because this is validation only.
    }

    @Override
    protected void validatePixelLog(TreeSet<PixelLog> pixelLogsByCadenceNumber,
        PixelLog pixelLog) {
        super.validatePixelLog(pixelLogsByCadenceNumber, pixelLog);

        if (checkForMultipleTargetTables) {
            if (!pixelLogsByCadenceNumber.isEmpty()) {
                PixelLog last = pixelLogsByCadenceNumber.last();
                if (last.getLcTargetTableId() != pixelLog.getLcTargetTableId()) {
                    throw new PipelineException(
                        "Incoming files should contain only one lc target table id."
                            + "\n  fitsFile " + last.getFitsFilename()
                            + " has lcTargetTableId "
                            + last.getLcTargetTableId() + "\n  fitsFile "
                            + pixelLog.getFitsFilename()
                            + " has lcTargetTableId "
                            + pixelLog.getLcTargetTableId() + ".");
                }

                if (last.getScTargetTableId() != pixelLog.getScTargetTableId()) {
                    throw new PipelineException(
                        "Incoming files should contain only one sc target table id."
                            + "\n  fitsFile " + last.getFitsFilename()
                            + " has scTargetTableId "
                            + last.getScTargetTableId() + "\n  fitsFile "
                            + pixelLog.getFitsFilename()
                            + " has scTargetTableId "
                            + pixelLog.getScTargetTableId() + ".");
                }

                if (last.getBackTargetTableId() != pixelLog.getBackTargetTableId()) {
                    throw new PipelineException(
                        "Incoming files should contain only one background target table id."
                            + "\n  fitsFile " + last.getFitsFilename()
                            + " has backgroundTargetTableId "
                            + last.getBackTargetTableId() + "\n  fitsFile "
                            + pixelLog.getFitsFilename()
                            + " has backgroundTargetTableId "
                            + pixelLog.getBackTargetTableId() + ".");
                }

                if (last.getTargetApertureTableId() != pixelLog.getTargetApertureTableId()) {
                    throw new PipelineException(
                        "Incoming files should contain only one target aperture table id."
                            + "\n  fitsFile " + last.getFitsFilename()
                            + " has targetApertureTableId "
                            + last.getTargetApertureTableId() + "\n  fitsFile "
                            + pixelLog.getFitsFilename()
                            + " has targetApertureTableId "
                            + pixelLog.getTargetApertureTableId() + ".");
                }

                if (last.getBackApertureTableId() != pixelLog.getBackApertureTableId()) {
                    throw new PipelineException(
                        "Incoming files should contain only one background aperture table id."
                            + "\n  fitsFile " + last.getFitsFilename()
                            + " has backgroundApertureTableId "
                            + last.getBackApertureTableId() + "\n  fitsFile "
                            + pixelLog.getFitsFilename()
                            + " has backgroundApertureTableId "
                            + pixelLog.getBackApertureTableId() + ".");
                }
            }
        }
    }

}
