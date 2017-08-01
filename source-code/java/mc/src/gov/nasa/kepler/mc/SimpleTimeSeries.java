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
import gov.nasa.kepler.fs.api.FsTimeSeries;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatMjdTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public final class SimpleTimeSeries {

    /**
     * Creates a {@link SimpleFloatTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link FloatTimeSeries}
     * @return a {@link SimpleFloatTimeSeries}, which will contain arrays of
     * size 0 if {@code valuesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static SimpleFloatTimeSeries getFloatInstance(FsId valuesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries timeSeries = timeSeriesByFsId.get(valuesFsId);
        if (timeSeries instanceof FloatTimeSeries) {
            return new SimpleFloatTimeSeries(
                ((FloatTimeSeries) timeSeries).fseries(),
                ((FloatTimeSeries) timeSeries).getGapIndicators());
        }

        return new SimpleFloatTimeSeries();
    }

    public static SimpleFloatTimeSeries getFloatInstance(FsId valuesFsId,
        int length, Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries timeSeries = timeSeriesByFsId.get(valuesFsId);
        if (timeSeries instanceof FloatTimeSeries) {
            return new SimpleFloatTimeSeries(
                ((FloatTimeSeries) timeSeries).fseries(),
                ((FloatTimeSeries) timeSeries).getGapIndicators());
        }

        return new SimpleFloatTimeSeries(length);
    }

    public static FloatTimeSeries toFloatTimeSeries(
        SimpleFloatTimeSeries simpleFloatTimeSeries, FsId valuesFsId,
        int startCadence, int endCadence, long originator) {
        return new FloatTimeSeries(valuesFsId,
            simpleFloatTimeSeries.getValues(), startCadence, endCadence,
            simpleFloatTimeSeries.getGapIndicators(), originator);
    }

    public static FloatTimeSeries toFloatTimeSeries(FsId valuesFsId,
        float[] values, boolean[] gapIndicators, int startCadence,
        int endCadence, long originator) {
        return new FloatTimeSeries(valuesFsId, values, startCadence,
            endCadence, gapIndicators, originator);
    }

    public static List<FloatTimeSeries> toFloatTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, float[] values, float[] uncertainties,
        boolean[] gapIndicators, int startCadence, int endCadence,
        long originator) {
        List<FloatTimeSeries> timeSeries = new ArrayList<FloatTimeSeries>();
        timeSeries.add(toFloatTimeSeries(valuesFsId, values, gapIndicators,
            startCadence, endCadence, originator));
        timeSeries.add(toFloatTimeSeries(uncertaintiesFsId, uncertainties,
            gapIndicators, startCadence, endCadence, originator));
        return timeSeries;
    }

    /**
     * Creates a {@link SimpleIntTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link IntTimeSeries}
     * @return a {@link SimpleIntTimeSeries}, which will contain arrays of size
     * 0 if {@code valuesFsId} was not found in the map, or arrays of the proper
     * size but where the gap indicators are all {@code true} if the time series
     * is empty.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static SimpleIntTimeSeries getIntInstance(FsId valuesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries timeSeries = timeSeriesByFsId.get(valuesFsId);
        if (timeSeries instanceof IntTimeSeries) {
            return new SimpleIntTimeSeries(
                ((IntTimeSeries) timeSeries).iseries(),
                ((IntTimeSeries) timeSeries).getGapIndicators());
        }

        return new SimpleIntTimeSeries();
    }

    /**
     * Returns a {@code IntTimeSeries} representation.
     * 
     * @param values TODO
     * @param gapIndicators TODO
     * @param startCadence starting cadence of time series.
     * @param endCadence ending cadence (inclusive) of the time series.
     * @param originator pipeline task id of originator.
     * @param valuesId time series id.
     * 
     * @return a {@code IntTimeSeries} for this object.
     */
    public static IntTimeSeries toIntTimeSeries(FsId valuesFsId, int[] values,
        boolean[] gapIndicators, int startCadence, int endCadence,
        long originator) {
        return new IntTimeSeries(valuesFsId, values, startCadence, endCadence,
            gapIndicators, originator);
    }

    /**
     * Creates a {@link SimpleFloatTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link FloatTimeSeries}
     * @return a {@link SimpleFloatTimeSeries}, which will contain arrays of
     * size 0 if {@code valuesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static SimpleDoubleTimeSeries getDoubleInstance(FsId valuesFsId,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries timeSeries = timeSeriesByFsId.get(valuesFsId);
        if (timeSeries instanceof DoubleTimeSeries) {
            return new SimpleDoubleTimeSeries(
                ((DoubleTimeSeries) timeSeries).dseries(),
                ((DoubleTimeSeries) timeSeries).getGapIndicators());
        }

        return new SimpleDoubleTimeSeries();
    }

    /**
     * Returns a {@code FloatTimeSeries} representation.
     * 
     * @param values TODO
     * @param gapIndicators TODO
     * @param startCadence starting cadence of time series.
     * @param endCadence ending cadence (inclusive) of the time series.
     * @param originator pipeline task id of originator.
     * @param valuesId time series id.
     * 
     * @return a {@code FloatTimeSeries} for this object.
     */
    public static DoubleTimeSeries toDoubleTimeSeries(FsId valuesFsId,
        double[] values, boolean[] gapIndicators, int startCadence,
        int endCadence, long originator) {
        if (values.length != endCadence - startCadence + 1) {
            throw new IllegalArgumentException(String.format(
                "invalid start and end cadence of %d and %d "
                    + "doesn't match length %d", startCadence, endCadence,
                values.length));
        }
        return new DoubleTimeSeries(valuesFsId, values, startCadence,
            endCadence, gapIndicators, originator);
    }

    public static DoubleTimeSeries toDoubleTimeSeries(
        SimpleDoubleTimeSeries simpleDoubleTimeSeries, FsId valuesFsId,
        int startCadence, int endCadence, long originator) {

        return toDoubleTimeSeries(valuesFsId,
            simpleDoubleTimeSeries.getValues(),
            simpleDoubleTimeSeries.getGapIndicators(), startCadence,
            endCadence, originator);
    }

    /**
     * Creates a {@link SimpleFloatMjdTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param timeSeriesByFsId a map of {@link FsId}s to
     * {@link FloatMjdTimeSeries}
     * @return a {@link SimpleFloatMjdTimeSeries}, which will contain arrays of
     * size 0 if {@code valuesFsId} was not found in the map
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static SimpleFloatMjdTimeSeries getFloatMjdInstance(FsId valuesFsId,
        Map<FsId, FloatMjdTimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        FsTimeSeries timeSeries = timeSeriesByFsId.get(valuesFsId);
        if (timeSeries instanceof FloatMjdTimeSeries) {
            return new SimpleFloatMjdTimeSeries(
                ((FloatMjdTimeSeries) timeSeries).values(),
                ((FloatMjdTimeSeries) timeSeries).mjd());
        }

        return new SimpleFloatMjdTimeSeries();
    }

    /**
     * Returns a {@code FloatMjdTimeSeries} representation.
     * 
     * @param values TODO
     * @param times TODO
     * @param startMjd starting time of time series.
     * @param endMjd ending time of the time series.
     * @param originator pipeline task id of originator.
     * @param valuesId time series id.
     * 
     * @return a {@code FloatMjdTimeSeries} for this object.
     */
    public static FloatMjdTimeSeries toFloatMjdTimeSeries(FsId valuesFsId,
        float[] values, double[] times, int startMjd, int endMjd,
        long originator) {
        return new FloatMjdTimeSeries(valuesFsId, startMjd, endMjd, times,
            values, originator);
    }

}
