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

import static com.google.common.base.Preconditions.checkNotNull;
import static com.google.common.collect.Lists.newArrayList;
import static gov.nasa.kepler.mc.fs.PaFsIdFactory.getCentroidTimeSeriesFsId;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.CompoundDoubleTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public final class CompoundTimeSeries {

    /**
     * Creates a {@link CompoundFloatTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param uncertaintiesFsId the {@link FsId} for the uncertainties
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link FloatTimeSeries}
     * @return a {@link CompoundFloatTimeSeries}, which will contain arrays of
     * size 0 if {@code valuesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static CompoundDoubleTimeSeries getDoubleInstance(FsId valuesFsId,
        FsId uncertaintiesFsId, int length,
        Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (uncertaintiesFsId == null) {
            throw new NullPointerException("uncertaintiesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries values = timeSeriesByFsId.get(valuesFsId);
        TimeSeries uncertainties = timeSeriesByFsId.get(uncertaintiesFsId);
        if (values != null && values.exists() && uncertainties != null
            && uncertainties.exists()) {
            if (!(values instanceof DoubleTimeSeries)) {
                throw new IllegalArgumentException(
                    "values must be DoubleTimeSeries");
            }
            if (!(uncertainties instanceof FloatTimeSeries)) {
                throw new IllegalArgumentException(
                    "uncertainties must be FloatTimeSeries");
            }
            return new CompoundDoubleTimeSeries(
                ((DoubleTimeSeries) values).dseries(),
                ((FloatTimeSeries) uncertainties).fseries(),
                values.getGapIndicators());
        }
        return new CompoundDoubleTimeSeries(length);
    }

    /**
     * Returns a representation as a {@code List} of {@code DoubleTimeSeries}.
     * 
     * @param valuesFsId time series id.
     * @param uncertaintiesFsId time series id.
     * @param values 
     * @param uncertainties 
     * @param gapIndicators 
     * @param startCadence starting cadence of time series.
     * @param endCadence ending cadence (inclusive) of the time series.
     * @param originator pipeline task id of originator.
     * @return a {@code List} of {@code FloatTimeSeries} objects.
     */
    public static List<TimeSeries> toDoubleTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, double[] values, float[] uncertainties,
        boolean[] gapIndicators, int startCadence, int endCadence,
        long originator) {
        List<TimeSeries> timeSeries = new ArrayList<TimeSeries>();
        timeSeries.add(SimpleTimeSeries.toDoubleTimeSeries(valuesFsId, values,
            gapIndicators, startCadence, endCadence, originator));
        timeSeries.add(new FloatTimeSeries(uncertaintiesFsId, uncertainties,
            startCadence, endCadence, gapIndicators, originator));
        return timeSeries;
    }

    public static List<TimeSeries> toDoubleTimeSeries(
        CompoundDoubleTimeSeries compoundDoubleTimeSeries, FsId valuesFsId,
        FsId uncertaintiesFsId, int startCadence, int endCadence,
        long originator) {
        List<TimeSeries> timeSeries = new ArrayList<TimeSeries>();
        timeSeries.add(SimpleTimeSeries.toDoubleTimeSeries(valuesFsId,
            compoundDoubleTimeSeries.getValues(),
            compoundDoubleTimeSeries.getGapIndicators(), startCadence,
            endCadence, originator));
        timeSeries.add(new FloatTimeSeries(uncertaintiesFsId,
            compoundDoubleTimeSeries.getUncertainties(), startCadence,
            endCadence, compoundDoubleTimeSeries.getGapIndicators(), originator));
        return timeSeries;
    }

    /**
     * Creates a {@link CompoundFloatTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param uncertaintiesFsId the {@link FsId} for the uncertainties
     * @param timeSeriesByFsId a map of {@link FsId}s to {@link FloatTimeSeries}
     * @return a {@link CompoundFloatTimeSeries}, which will contain arrays of
     * size 0 if {@code valuesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static CompoundFloatTimeSeries getFloatInstance(FsId valuesFsId,
        FsId uncertaintiesFsId, Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (uncertaintiesFsId == null) {
            throw new NullPointerException("uncertaintiesFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries values = timeSeriesByFsId.get(valuesFsId);
        TimeSeries uncertainties = timeSeriesByFsId.get(uncertaintiesFsId);
        if (values != null && values.exists() && uncertainties != null
            && uncertainties.exists()) {
            return new CompoundFloatTimeSeries(
                ((FloatTimeSeries) values).fseries(),
                ((FloatTimeSeries) uncertainties).fseries(),
                ((FloatTimeSeries) values).getGapIndicators());
        }
        return new CompoundFloatTimeSeries();
    }

    /**
     * Returns representation as a {@code List} of {@code FloatTimeSeries}.
     * 
     * @param valuesFsId time series id.
     * @param uncertaintiesFsId time series id.
     * @param values 
     * @param uncertainties 
     * @param gapIndicators 
     * @param startCadence starting cadence of time series.
     * @param endCadence ending cadence (inclusive) of the time series.
     * @param originator pipeline task id of originator.
     * @return a {@code List} of {@code FloatTimeSeries} objects.
     */
    public static List<FloatTimeSeries> toFloatTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, float[] values, float[] uncertainties,
        boolean[] gapIndicators, int startCadence, int endCadence,
        long originator) {
        return SimpleTimeSeries.toFloatTimeSeries(valuesFsId,
            uncertaintiesFsId, values, uncertainties, gapIndicators,
            startCadence, endCadence, originator);
    }

    /**
     * Returns representation as a {@code List} of {@code FloatTimeSeries}.
     * 
     * @param valuesFsId time series id.
     * @param uncertaintiesFsId time series id.
     * @param values 
     * @param uncertainties 
     * @param gapIndicators 
     * @param startCadence starting cadence of time series.
     * @param endCadence ending cadence (inclusive) of the time series.
     * @param originator pipeline task id of originator.
     * @return a {@code List} of {@code FloatTimeSeries} objects.
     */
    public static List<FloatTimeSeries> toFloatTimeSeries(
        CompoundFloatTimeSeries compoundFloatTimeSeries, FsId valuesFsId,
        FsId uncertaintiesFsId, int startCadence, int endCadence,
        long originator) {
        return SimpleTimeSeries.toFloatTimeSeries(valuesFsId,
            uncertaintiesFsId, compoundFloatTimeSeries.getValues(),
            compoundFloatTimeSeries.getUncertainties(),
            compoundFloatTimeSeries.getGapIndicators(), startCadence,
            endCadence, originator);
    }

    /**
     * Returns representation as a {@code List} of {@code FloatTimeSeries}.
     * 
     * @param centroidTimeSeries 
     * @param fluxType the {@link FluxType} of these centroids
     * @param centroidType the {@link CentroidType} of these centroids
     * @param cadenceType the {@link CadenceType} of these centroids
     * @param keplerId the {@code int} Kepler ID of these time centroids
     * @param startCadence starting cadence of time series.
     * @param endCadence ending cadence (inclusive) of the time series.
     * @param originator pipeline task id of originator.
     * 
     * @return a {@code List} of {@code FloatTimeSeries} objects.
     */
    public static List<TimeSeries> toDoubleTimeSeries(
        CentroidTimeSeries centroidTimeSeries, final FluxType fluxType,
        final CentroidType centroidType, final CadenceType cadenceType,
        final int keplerId, int startCadence, int endCadence, long originator) {

        List<TimeSeries> timeSeries = new ArrayList<TimeSeries>();
        timeSeries.addAll(toDoubleTimeSeries(
            centroidTimeSeries.getRowTimeSeries(),
            Centroids.getRowFsId(fluxType, centroidType, cadenceType,
                keplerId), Centroids.getRowUncertaintiesFsId(fluxType,
                centroidType, cadenceType, keplerId), startCadence, endCadence,
            originator));
        timeSeries.addAll(toDoubleTimeSeries(
            centroidTimeSeries.getColumnTimeSeries(),
            Centroids.getColFsId(fluxType, centroidType, cadenceType,
                keplerId), Centroids.getColUncertaintiesFsId(fluxType,
                centroidType, cadenceType, keplerId), startCadence, endCadence,
            originator));
        return timeSeries;
    }

    public static final class Centroids {

        /**
         * Creates a {@link CentroidTimeSeries} object.
         * 
         * @param fluxType the {@link FluxType} of these centroids
         * @param centroidType the {@link CentroidType} of these centroids
         * @param cadenceType the {@link CadenceType} of these centroids
         * @param keplerId the {@code int} Kepler ID of these time centroids
         * @param timeSeries a map of {@link FsId}s to {@link FloatTimeSeries}
         * @return a {@link CentroidTimeSeries}, which will contain two
         * {@link CompoundFloatTimeSeries} which in turn will contain arrays of size
         * 0 if the values {@link FsId} was not found in the map, or arrays of the
         * proper size but where the gap indicators are all {@code true} if the time
         * series is empty.
         * @throws NullPointerException if any of the arguments are {@code null}
         */
        public static CentroidTimeSeries getInstance(
            final FluxType fluxType, final CentroidType centroidType,
            final CadenceType cadenceType, int length, final int keplerId,
            Map<FsId, ? extends TimeSeries> timeSeries) {
        
            checkNotNull(fluxType, "fluxType can't be null");
            checkNotNull(centroidType, "centroidType can't be null");
            checkNotNull(cadenceType, "cadenceType can't be null");
            checkNotNull(timeSeries, "timeSeriesByFsId can't be null");
        
            CompoundDoubleTimeSeries rowTimeSeries = CompoundTimeSeries.getDoubleInstance(
                Centroids.getRowFsId(fluxType, centroidType, cadenceType,
                    keplerId), Centroids.getRowUncertaintiesFsId(fluxType,
                    centroidType, cadenceType, keplerId), length, timeSeries);
            CompoundDoubleTimeSeries columnTimeSeries = CompoundTimeSeries.getDoubleInstance(
                Centroids.getColFsId(fluxType, centroidType, cadenceType,
                    keplerId), Centroids.getColUncertaintiesFsId(fluxType,
                    centroidType, cadenceType, keplerId), length, timeSeries);
        
            return new CentroidTimeSeries(rowTimeSeries, columnTimeSeries);
        }

        public static CentroidTimeSeries getCentroidInstance(FsId rowFsId,
            FsId rowUncertaintiesFsId, FsId colFsId, FsId colUncertaintiesFsId,
            int length, Map<FsId, ? extends TimeSeries> timeSeries) {
        
            checkNotNull(rowFsId, "rowFsId can't be null");
            checkNotNull(rowUncertaintiesFsId, "rowUncertaintiesFsId can't be null");
            checkNotNull(colFsId, "colFsId can't be null");
            checkNotNull(colUncertaintiesFsId, "colUncertaintiesFsId can't be null");
            checkNotNull(timeSeries, "timeSeriesByFsId can't be null");
        
            CompoundDoubleTimeSeries rowTimeSeries = CompoundTimeSeries.getDoubleInstance(rowFsId,
                rowUncertaintiesFsId, length, timeSeries);
            CompoundDoubleTimeSeries columnTimeSeries = CompoundTimeSeries.getDoubleInstance(colFsId,
                colUncertaintiesFsId, length, timeSeries);
        
            return new CentroidTimeSeries(rowTimeSeries, columnTimeSeries);
        }

        static FsId getCentroidFsId(final FluxType fluxType,
            final CentroidType centroidType,
            final CentroidTimeSeriesType centroidTimeSeriesType,
            final CadenceType cadenceType, final int keplerId) {
        
            FsId fsId = getCentroidTimeSeriesFsId(centroidTimeSeriesType,
                cadenceType, keplerId);
            if (fluxType != null) {
                if (centroidType != null) {
                    fsId = getCentroidTimeSeriesFsId(fluxType, centroidType,
                        centroidTimeSeriesType, cadenceType, keplerId);
                } else {
                    fsId = getCentroidTimeSeriesFsId(fluxType,
                        centroidTimeSeriesType, cadenceType, keplerId);
                }
            }
            return fsId;
        }

        public static FsId getRowFsId(final FluxType fluxType,
            final CentroidType centroidType, final CadenceType cadenceType,
            final int keplerId) {
        
            return getCentroidFsId(fluxType, centroidType,
                CentroidTimeSeriesType.CENTROID_ROWS, cadenceType, keplerId);
        }

        public static FsId getRowUncertaintiesFsId(final FluxType fluxType,
            final CentroidType centroidType, final CadenceType cadenceType,
            final int keplerId) {
        
            return getCentroidFsId(fluxType, centroidType,
                CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
                keplerId);
        }

        public static FsId getColFsId(final FluxType fluxType,
            final CentroidType centroidType, final CadenceType cadenceType,
            final int keplerId) {
        
            return getCentroidFsId(fluxType, centroidType,
                CentroidTimeSeriesType.CENTROID_COLS, cadenceType, keplerId);
        }

        public static FsId getColUncertaintiesFsId(final FluxType fluxType,
            final CentroidType centroidType, final CadenceType cadenceType,
            final int keplerId) {
        
            return getCentroidFsId(fluxType, centroidType,
                CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
                keplerId);
        }

        public static List<FsId> getAllFsIds(FluxType fluxType,
            CentroidType centroidType, CadenceType cadenceType, int keplerId) {
        
            List<FsId> fsIds = newArrayList();
            fsIds.addAll(getAllDoubleFsIds(fluxType, centroidType, cadenceType,
                keplerId));
            fsIds.addAll(getAllFloatFsIds(fluxType, centroidType, cadenceType,
                keplerId));
        
            return fsIds;
        }

        public static List<FsId> getAllDoubleFsIds(FluxType fluxType,
            CentroidType centroidType, CadenceType cadenceType, int keplerId) {
        
            List<FsId> fsIds = newArrayList();
            fsIds.add(getRowFsId(fluxType, centroidType, cadenceType, keplerId));
            fsIds.add(getColFsId(fluxType, centroidType, cadenceType, keplerId));
        
            return fsIds;
        }

        public static List<FsId> getAllFloatFsIds(FluxType fluxType,
            CentroidType centroidType, CadenceType cadenceType, int keplerId) {
        
            List<FsId> fsIds = newArrayList();
            fsIds.add(getRowUncertaintiesFsId(fluxType, centroidType, cadenceType,
                keplerId));
            fsIds.add(getColUncertaintiesFsId(fluxType, centroidType, cadenceType,
                keplerId));
        
            return fsIds;
        }
        
    }
}
