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

package gov.nasa.kepler.mc;

import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesOperations;
import gov.nasa.kepler.mc.dr.PixelTimeSeriesReader;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Operations on {@link FsId}s and {@link TimeSeries}.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class TimeSeriesOperations {

    private static final Log log = LogFactory.getLog(TimeSeriesOperations.class);

    private int readTimeSeriesActual;

    private PixelTimeSeriesReader pixelTimeSeriesReader;

    public TimeSeriesOperations() {
    }

    public TimeSeriesOperations(PixelTimeSeriesReader pixelTimeSeriesReader) {
        this.pixelTimeSeriesReader = pixelTimeSeriesReader;
    }

    public static Map<FsId, IntTimeSeries> getIntTimeSeriesByFsId(
        IntTimeSeries[] timeSeriesArray) {

        return getIntTimeSeriesByFsId(timeSeriesArray, false);
    }

    public static Map<FsId, IntTimeSeries> getIntTimeSeriesByFsId(
        IntTimeSeries[] timeSeriesArray, boolean force) {

        Map<FsId, IntTimeSeries> timeSeriesByFsId = new HashMap<FsId, IntTimeSeries>();
        for (IntTimeSeries timeSeries : timeSeriesArray) {
            if (timeSeries.exists() || force) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            }
        }

        return timeSeriesByFsId;
    }

    public static Map<FsId, FloatTimeSeries> getFloatTimeSeriesByFsId(
        FloatTimeSeries[] timeSeriesArray) {

        return getFloatTimeSeriesByFsId(timeSeriesArray, false);
    }

    public static Map<FsId, FloatTimeSeries> getFloatTimeSeriesByFsId(
        FloatTimeSeries[] timeSeriesArray, boolean force) {

        Map<FsId, FloatTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatTimeSeries>();
        for (FloatTimeSeries timeSeries : timeSeriesArray) {
            if (timeSeries.exists() || force) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            }
        }

        return timeSeriesByFsId;
    }

    public static Map<FsId, FloatMjdTimeSeries> getFloatMjdTimeSeriesByFsId(
        FloatMjdTimeSeries[] floatMjdTimeSeries) {

        Map<FsId, FloatMjdTimeSeries> timeSeriesByFsId = new HashMap<FsId, FloatMjdTimeSeries>();
        for (FloatMjdTimeSeries timeSeries : floatMjdTimeSeries) {
            if (timeSeries.exists()) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            }
        }

        return timeSeriesByFsId;
    }

    public static Map<FsId, DoubleTimeSeries> getDoubleTimeSeriesByFsId(
        DoubleTimeSeries[] doubleTimeSeries) {

        Map<FsId, DoubleTimeSeries> timeSeriesByFsId = new HashMap<FsId, DoubleTimeSeries>();
        for (DoubleTimeSeries timeSeries : doubleTimeSeries) {
            if (timeSeries.exists()) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            }
        }

        return timeSeriesByFsId;
    }

    public static Map<FsId, TimeSeries> getTimeSeriesByFsId(
        TimeSeries[] timeSeriesArray) {

        Map<FsId, TimeSeries> timeSeriesByFsId = new TreeMap<FsId, TimeSeries>();
        
        return getTimeSeriesByFsId(timeSeriesByFsId, timeSeriesArray);
    }

    public static Map<FsId, TimeSeries> getTimeSeriesByFsId(Map<FsId, TimeSeries> timeSeriesByFsId,
        TimeSeries[] timeSeriesArray) {

        for (TimeSeries timeSeries : timeSeriesArray) {
            if (timeSeries.exists()) {
                timeSeriesByFsId.put(timeSeries.id(), timeSeries);
            }
        }

        return timeSeriesByFsId;
    }

    /**
     * Returns the time series for the given {@link FsId}s over the given
     * duration.
     * 
     * @return a non-{@code null} time series.
     * @throws PipelineException if there were problems reading the time series
     * from the file store.
     * @throws NullPointerException if {@code fsIdsPerTarget} is {@code null}.
     */
    public IntTimeSeries[] readPixelTimeSeriesAsInt(FsId[] fsIds,
        int startCadence, int endCadence) {

        IntTimeSeries[] timeSeries = new IntTimeSeries[0];
        if (fsIds.length > 0) {
            log.debug("Reading " + fsIds.length + " time series...");
            timeSeries = getPixelTimeSeriesReader().readTimeSeriesAsInt(fsIds,
                startCadence, endCadence);

            log.debug("Reading " + timeSeries.length + " time series...done");
            if (timeSeries.length != fsIds.length) {
                throw new PipelineException("Expected " + fsIds.length
                    + " time series, got " + timeSeries.length);
            }
            for (int i = 0; i < timeSeries.length; i++) {
                if (timeSeries[i] == null) {
                    throw new IllegalStateException(fsIds[i]
                        + ": time series is null");
                }
            }
            readTimeSeriesActual++;
        }

        return timeSeries;
    }

    /**
     * Returns the time series for the given {@link FsId}s over the given
     * duration.
     * 
     * @return a non-{@code null} time series.
     * @throws PipelineException if there were problems reading the time series
     * from the file store.
     * @throws NullPointerException if {@code fsIdsPerTarget} is {@code null}.
     */
    public FloatTimeSeries[] readPixelTimeSeriesAsFloat(FsId[] fsIds,
        int startCadence, int endCadence) {

        FloatTimeSeries[] timeSeries = new FloatTimeSeries[0];
        if (fsIds.length > 0) {
            log.debug("Reading " + fsIds.length + " time series...");
            timeSeries = FileStoreClientFactory.getInstance()
                .readTimeSeriesAsFloat(fsIds, startCadence, endCadence, false);
            log.debug("Reading " + timeSeries.length + " time series...done");
            if (timeSeries.length != fsIds.length) {
                throw new PipelineException("Expected " + fsIds.length
                    + " time series, got " + timeSeries.length);
            }
            for (int i = 0; i < timeSeries.length; i++) {
                if (timeSeries[i] == null) {
                    throw new IllegalStateException(fsIds[i]
                        + ": time series is null");
                }
            }
            readTimeSeriesActual++;
        }

        return timeSeries;
    }

    /**
     * Converts the given collection of {@link FsId}s to a single array of
     * {@link FsId}s.
     * 
     * @return a non-{@code null} array of distinct {@link FsId}s.
     * @throws NullPointerException if {@code fsIdsPerTarget} is {@code null}.
     */
    public static FsId[] getFsIds(List<Set<FsId>> fsIdsPerTarget) {
        Set<FsId> fsIds = new TreeSet<FsId>();
        for (Set<FsId> targetFsIds : fsIdsPerTarget) {
            fsIds.addAll(targetFsIds);
        }

        return fsIds.toArray(new FsId[0]);
    }

    /**
     * Returns the total number of {@link FsId}s in the given collection.
     * 
     * @throws NullPointerException if {@code fsIdsPerTarget} is {@code null}.
     */
    public static int getFsIdCount(List<Set<FsId>> fsIdsPerTarget) {
        int fsIdsCount = 0;
        for (Set<FsId> targetFsIds : fsIdsPerTarget) {
            fsIdsCount += targetFsIds.size();
        }

        return fsIdsCount;
    }

    /**
     * Returns the number of times that a call to {@code readPixelTimeSeriesAs*}
     * actually went off to the filestore. Useful for testing.
     */
    public int getReadTimeSeriesActual() {
        return readTimeSeriesActual;
    }

    /**
     * Adds every originator in the time series to {@code producerTaskIds}.
     * 
     * @param timeSeries the time series.
     * @param producerTaskIds the producer task IDs.
     * @throws NullPointerException if either {@code timeSeries} or
     * {@code producerTaskIds} is {@code null}.
     */
    public static void addToDataAccountability(TimeSeries timeSeries,
        Set<Long> producerTaskIds) {

        if (timeSeries.exists()) {
            for (TaggedInterval interval : timeSeries.originators()) {
                long taskId = interval.tag();
                producerTaskIds.add(taskId);
            }
        }
    }

    /**
     * Adds every originator for all the time series to {@code producerTaskIds}.
     * 
     * @param timeSeries all the time series.
     * @param producerTaskIds the producer task IDs.
     * @throws NullPointerException if either {@code timeSeries} or
     * {@code producerTaskIds} is {@code null}.
     */
    public static void addToDataAccountability(TimeSeries[] timeSeries,
        Set<Long> producerTaskIds) {

        for (TimeSeries ts : timeSeries) {
            addToDataAccountability(ts, producerTaskIds);
        }
    }

    /**
     * Adds every originator in the mjd time series to {@code producerTaskIds}.
     * 
     * @param mjdTimeSeries the time series.
     * @param producerTaskIds the producer task IDs.
     * @throws NullPointerException if either {@code mjdTimeSeries} or
     * {@code producerTaskIds} is {@code null}.
     */
    public static void addToDataAccountability(
        FloatMjdTimeSeries mjdTimeSeries, Set<Long> producerTaskIds) {

        if (mjdTimeSeries.exists()) {
            for (long taskId : mjdTimeSeries.originators()) {
                producerTaskIds.add(taskId);
            }
        }
    }

    public PixelTimeSeriesReader getPixelTimeSeriesReader() {
        if (pixelTimeSeriesReader == null) {
            pixelTimeSeriesReader = new PixelTimeSeriesOperations();
        }

        return pixelTimeSeriesReader;
    }

}
