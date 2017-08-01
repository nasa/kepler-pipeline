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

import static com.google.common.collect.Maps.newHashMap;
import static gov.nasa.kepler.common.FitsConstants.MISSING_PIXEL_VALUE;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesOperations;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesWriter;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Contains a buffer of time series.
 * 
 * @author Miles Cote
 * 
 */
class TimeSeriesBuffer {

    private static final Log log = LogFactory.getLog(TimeSeriesBuffer.class);

    private int startCadence;
    private int endCadence;

    private int byteCount;
    private int timeSeriesCount;

    private Map<FsId, DrTimeSeries> fsIdToDrTimeSeries = newHashMap();

    private boolean overwriteGaps = false;

    private final PixelTimeSeriesWriter timeSeriesWriter;

    TimeSeriesBuffer(int startCadence, int endCadence, boolean overwriteGaps) {
        this(startCadence, endCadence, overwriteGaps,
            new PixelTimeSeriesOperations());
    }

    TimeSeriesBuffer(int startCadence, int endCadence, boolean overwriteGaps,
        PixelTimeSeriesWriter timeSeriesWriter) {
        this.startCadence = startCadence;
        this.endCadence = endCadence;
        this.overwriteGaps = overwriteGaps;
        this.timeSeriesWriter = timeSeriesWriter;
    }

    void addValue(TimeSeriesEntry timeSeriesEntry) {
        FsId fsId = timeSeriesEntry.getFsId();
        DrTimeSeries drTimeSeries = fsIdToDrTimeSeries.get(fsId);

        if (drTimeSeries == null) {
            drTimeSeries = new DrTimeSeries(fsId);
            fsIdToDrTimeSeries.put(fsId, drTimeSeries);

            timeSeriesCount++;
        }

        drTimeSeries.addValue(timeSeriesEntry.getCadenceNumber(),
            timeSeriesEntry.getValue());
    }

    void flush() {
        log.info("TimeSeriesBuffer.currentSizeKBytes = "
            + getCurrentSizeBytes() / 1024);
        log.info("TimeSeriesBuffer.currentTimeSeriesCount = "
            + getCurrentTimeSeriesCount());

        IntervalMetricKey bufferFlushKey = null;
        try {
            log.info("START flushing timeSeriesBuffer (writing timeseries to filestore)");
            long flushStartTime = System.currentTimeMillis();

            bufferFlushKey = IntervalMetric.start();

            IntTimeSeries[] itsArray = new IntTimeSeries[fsIdToDrTimeSeries.values()
                .size()];
            int i = 0;
            for (DrTimeSeries drTimeSeries : fsIdToDrTimeSeries.values()) {
                IntTimeSeries its = drTimeSeries.getIntTimeSeries();

                itsArray[i] = its;

                i++;
            }

            timeSeriesWriter.write(itsArray, overwriteGaps);

            byteCount = 0;
            timeSeriesCount = 0;

            log.info("DONE flushing timeSeriesBuffer (writing timeseries to filestore)");
            log.info("Time to write timeseries to filestore for this mod/out: "
                + ((System.currentTimeMillis() - flushStartTime) / 1000F)
                + " secs.");
        } finally {
            IntervalMetric.stop("dr.dispatch.pixel.timeSeriesBuffer.flush",
                bufferFlushKey);
        }
    }

    private int getCadenceCount() {
        return (endCadence - startCadence) + 1;
    }

    public int getCurrentSizeBytes() {
        return byteCount;
    }

    public int getCurrentTimeSeriesCount() {
        return timeSeriesCount;
    }

    private class DrTimeSeries {

        private final int[] iseries;
        private final boolean[] gaps;
        private final FsId fsId;

        public DrTimeSeries(FsId fsId) {
            this.fsId = fsId;
            this.iseries = new int[getCadenceCount()];
            this.gaps = new boolean[getCadenceCount()];

            for (int i = 0; i < getCadenceCount(); i++) {
                this.gaps[i] = true;
            }
        }

        public void addValue(int cadenceNumber, int value) {
            if (value != MISSING_PIXEL_VALUE) {
                if (cadenceNumber < startCadence) {
                    throw new PipelineException(
                        "cadenceNumber must not be less than startCadence.\n  cadenceNumber: "
                            + cadenceNumber + "\n  startCadence: "
                            + startCadence);
                }

                if (cadenceNumber > endCadence) {
                    throw new PipelineException(
                        "cadenceNumber must not be greater than endCadence.\n  cadenceNumber: "
                            + cadenceNumber + "\n  endCadence: " + endCadence);
                }

                int i = cadenceNumber - startCadence;
                iseries[i] = value;
                gaps[i] = false;

                byteCount += 4;
            }
        }

        public IntTimeSeries getIntTimeSeries() {
            return new IntTimeSeries(fsId, iseries, startCadence, endCadence,
                gaps, DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID);
        }
    }

}
