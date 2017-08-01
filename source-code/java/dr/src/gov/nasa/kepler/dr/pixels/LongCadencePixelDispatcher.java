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
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.PixelLogCrud;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesOperations;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesWriter;
import gov.nasa.kepler.mc.pmrf.PmrfCache;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.Future;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Dispatches long cadence pixel fits files.
 * 
 * @author Miles Cote
 * 
 */
public class LongCadencePixelDispatcher extends PixelDispatcher {

    private static final Log log = LogFactory.getLog(LongCadencePixelDispatcher.class);

    /**
     * Only one TimeSeriesBuffer is flushed at a time. If a buffer is currently
     * already being flushed, a call to submit() will block until it finishes.
     * NOTE: These constants should not be changed without changing the code in
     * extractAndStoreTimeSeriesData(), which assumes only one background
     * flusher task at a time.
     */
    private static final int FLUSHER_QUEUE_MAX_SIZE = 1;
    private static final int FLUSHER_THREAD_COUNT = 1;

    public LongCadencePixelDispatcher() {
        this(new LogCrud());
    }

    LongCadencePixelDispatcher(PixelLogCrud pixelLogCrud) {
        super(pixelLogCrud);

        cadenceType = Cadence.CADENCE_LONG;
    }

    /**
     * Extracts the pixel values from the cadence FITS files, turns them into
     * time series, and stores them in the file store
     * 
     * The file store call to store the time series (the flusher task) is done
     * in a background thread using java.util.concurrent.ThreadPoolExecutor so
     * that the next module/output can be read while the previous one is writing
     * to the file store. Only one flusher task is allowed to run at a time.
     */
    @Override
    protected void extractAndStoreTimeSeriesData(List<String> fileNames,
        String sourceDirectory) {
        ThreadPoolExecutor flusherThread = new ThreadPoolExecutor(
            FLUSHER_THREAD_COUNT, FLUSHER_THREAD_COUNT, 0, TimeUnit.SECONDS,
            new ArrayBlockingQueue<Runnable>(FLUSHER_QUEUE_MAX_SIZE));
        Future<?> flusherTaskResult = null;

        pmrfCache = new PmrfCache(CadenceType.valueOf(cadenceType));

        long startTime = System.currentTimeMillis();
        long modOutStartTime;

        for (int ccdModule : FcConstants.modulesList) {
            for (int ccdOutput : FcConstants.outputsList) {
                modOutStartTime = System.currentTimeMillis();

                log.info("Processing (module/output/dataset/table) = ("
                    + ccdModule + "/" + ccdOutput + "/" + dataSetType + "/"
                    + targetTableType + ")");

                timeSeriesBuffer = new TimeSeriesBuffer(startCadence,
                    endCadence, overwriteGaps, createPixelTimeSeriesWriter(
                        dataSetType, ccdModule, ccdOutput));

                IntervalMetricKey allCadenceKey = null;
                try {
                    allCadenceKey = IntervalMetric.start();
                    for (String fitsFileName : fileNames) {
                        if (!ignoredFilenames.contains(fitsFileName)) {
                            CadenceFitsPair fitsFiles = new CadenceFitsPair(
                                sourceDirectory, fitsFileName, dataSetType,
                                targetTableType, pmrfCache, fitsMetadataCache);
                            fitsFiles.setCurrentModuleOutput(ccdModule,
                                ccdOutput);

                            processCadenceForModuleOutput(fitsFiles, ccdModule,
                                ccdOutput);

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
                        "dr.dispatch.pixel.oneModuleOutput.process",
                        allCadenceKey);
                }

                log.info("Time to process files for this mod/out: "
                    + ((System.currentTimeMillis() - modOutStartTime) / 1000F)
                    + " secs.");

                flusherTaskResult = checkAndFlush(flusherThread,
                    flusherTaskResult);
            }
        }

        check(flusherTaskResult);

        log.info("total time = "
            + ((System.currentTimeMillis() - startTime) / 1000F) + " secs.");
    }

    protected Future<?> checkAndFlush(ThreadPoolExecutor flusherThread,
        Future<?> flusherTaskResult) {
        // Make sure the previous flusher task finished successfully
        // before starting the next one. If the flusher task threw
        // an expection, the call below will throw it.
        checkFlusherTaskResult(flusherTaskResult);

        log.info("submitting TimeSeriesBuffer.flush() task to flusher thread");
        flusherTaskResult = flusherThread.submit(new FlusherTask(
            timeSeriesBuffer));

        return flusherTaskResult;
    }

    protected void check(Future<?> flusherTaskResult) {
        // wait for the last flusher task to complete
        log.info("Checking to see if the last flusher task is complete");
        checkFlusherTaskResult(flusherTaskResult);
    }

    protected PixelTimeSeriesWriter createPixelTimeSeriesWriter(
        DataSetType dataSetType, int ccdModule, int ccdOutput) {
        return new PixelTimeSeriesOperations();
    }

    private static class FlusherTask implements Callable<Object> {
        private TimeSeriesBuffer bufferToFlush = null;

        private FlusherTask(TimeSeriesBuffer bufferToFlush) {
            this.bufferToFlush = bufferToFlush;
        }

        public Object call() throws Exception {
            bufferToFlush.flush();
            return null;
        }
    }

    /**
     * Blocks until the flusher task completes.
     */
    private void checkFlusherTaskResult(Future<?> flusherTaskResult) {
        if (flusherTaskResult != null) {
            log.info("Waiting for flusher task to complete");
            IntervalMetricKey flusherWaitKey = IntervalMetric.start();
            try {
                flusherTaskResult.get();
            } catch (InterruptedException e) {
                throw new DispatchException("Flusher tasked failed", e);
            } catch (ExecutionException e) {
                throw new DispatchException("Flusher tasked failed", e);
            } finally {
                IntervalMetric.stop("dr.dispatch.pixel.flusher.waitTime",
                    flusherWaitKey);
            }
        }
    }

}
