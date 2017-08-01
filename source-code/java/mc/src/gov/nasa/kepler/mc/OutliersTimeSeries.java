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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;

/**
 * A {@link Persistable} representation of the corrected flux time series
 * outliers.
 * 
 * @author Forrest Girouard
 * @author Jay Gunter
 */
public class OutliersTimeSeries implements Persistable {

    // SOC 126.PDC.3 The values and indices of samples identified as outliers
    // shall be stored.

    /**
     * Outlier corrected flux values.
     */
    private float[] values = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * Uncertainties for outlier corrected flux values.
     */
    private float[] uncertainties = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * Indices of outlier values.
     */
    private int[] indices = ArrayUtils.EMPTY_INT_ARRAY;

    public OutliersTimeSeries() {
    }

    /**
     * Creates a {@link OutliersTimeSeries} object.
     * 
     * @param mjdToCadence required to translate the MJDs to relative cadences.
     * @param startCadence absolute start cadence.
     * @param endCadence absolute end cadence.
     * @param valuesTimeSeries persisted float MJD time series used used to
     * populate the internal contents of this instance.
     * @param uncertaintiesTimeSeries
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public OutliersTimeSeries(MjdToCadence mjdToCadence, int startCadence,
        int endCadence, FloatMjdTimeSeries valuesTimeSeries,
        FloatMjdTimeSeries uncertaintiesTimeSeries) {

        if (mjdToCadence == null) {
            throw new NullPointerException("mjdToCadence can't be null");
        }
        if (valuesTimeSeries == null) {
            throw new NullPointerException("valuesTimeSeries can't be null");
        }
        if (uncertaintiesTimeSeries == null) {
            throw new NullPointerException(
                "uncertaintiesTimeSeries can't be null");
        }
        if (valuesTimeSeries.values().length != uncertaintiesTimeSeries.values().length) {
            throw new IllegalArgumentException(
                "uncertainties length does not match values length");
        }
        values = valuesTimeSeries.values();
        uncertainties = uncertaintiesTimeSeries.values();
        indices = values.length == 0 ? ArrayUtils.EMPTY_INT_ARRAY
            : new int[values.length];
        double[] mjds = valuesTimeSeries.mjd();
        for (int i = 0; i < mjds.length; i++) {
            indices[i] = mjdToCadence.mjdToCadence(mjds[i]) - startCadence;
        }
    }

    /**
     * A {@link List} of {@link FsId}s used to populate and/or persist the
     * contents of an instance of this class.
     * 
     * @param fluxType the {@link FluxType} of interest.
     * @param cadenceType the {@link CadenceType} of interest.
     * @param keplerId corresponding target's Kepler ID.
     * @return a {@link List} of {@link FsId}s.
     */
    public static List<FsId> getAllFloatMjdFsIds(final FluxType fluxType,
        final CadenceType cadenceType, final int keplerId) {

        if (fluxType == null) {
            throw new NullPointerException("fluxType can't be null");
        }
        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }

        List<FsId> fsIds = new ArrayList<FsId>(4);
        fsIds.add(PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIERS, fluxType,
            cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIER_UNCERTAINTIES,
            fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.OUTLIERS, fluxType, cadenceType, keplerId));
        fsIds.add(PdcFsIdFactory.getOutlierTimerSeriesId(
            PdcOutliersTimeSeriesType.OUTLIER_UNCERTAINTIES, fluxType,
            cadenceType, keplerId));

        return fsIds;
    }

    /**
     * Creates a {@link OutliersTimeSeries} object.
     * 
     * @param valueType the {@link PdcOutliersTimeSeriesType} for the value .
     * @param uncertaintiesType the {@link PdcOutliersTimeSeriesType} for the
     * uncertainties.
     * @param fluxType the {@link FluxType} of interest.
     * @param cadenceType the {@link CadenceType} of interest.
     * @param keplerId corresponding target's Kepler ID.
     * @param mjdToCadence required to translate the MJDs to relative cadences.
     * @param startCadence absolute start cadence.
     * @param endCadence absolute end cadence.
     * @param mjdTimeSeries map of {@link FloatMjdTimeSeries} by {@code
     * keplerId}.
     * 
     * @return new {@link OutliersTimeSeries} object.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static OutliersTimeSeries getInstance(
        PdcOutliersTimeSeriesType valueType,
        PdcOutliersTimeSeriesType uncertaintiesType, FluxType fluxType,
        CadenceType cadenceType, int keplerId, MjdToCadence mjdToCadence,
        int startCadence, int endCadence,
        Map<FsId, FloatMjdTimeSeries> mjdTimeSeries) {

        if (fluxType == null) {
            throw new NullPointerException("fluxType can't be null");
        }
        if (cadenceType == null) {
            throw new NullPointerException("cadenceType can't be null");
        }
        if (mjdToCadence == null) {
            throw new NullPointerException("mjdToCadence can't be null");
        }
        if (mjdTimeSeries == null) {
            throw new NullPointerException("mjdTimeSeries can't be null");
        }

        FsId valuesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(valueType,
            fluxType, cadenceType, keplerId);
        FsId uncertaintiesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
            uncertaintiesType, fluxType, cadenceType, keplerId);
        FloatMjdTimeSeries valuesTimeSeries = mjdTimeSeries.get(valuesFsId);
        FloatMjdTimeSeries uncertaintiesTimeSeries = mjdTimeSeries.get(uncertaintiesFsId);
        if (valuesTimeSeries != null && uncertaintiesTimeSeries != null) {
            return new OutliersTimeSeries(mjdToCadence, startCadence,
                endCadence, valuesTimeSeries, uncertaintiesTimeSeries);
        }

        return new OutliersTimeSeries();
    }

    /**
     * Returns a {@link FloatMjdTimeSeries} representation of the contents of
     * this instance using the provided parameters.
     * 
     * @param fluxType the {@link FluxType} of interest.
     * @param cadenceType the {@link CadenceType} of interest.
     * @param keplerId corresponding target's Kepler ID.
     * @param startCadence absolute start cadence.
     * @param startMjd starting MJD for time series.
     * @param endMjd ending MJD for time series.
     * @param originator the {@link PipelineTask} identifier.
     * @param mjdToCadence required to translate the relative cadences to MJDs.
     * @return
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public List<FloatMjdTimeSeries> toTimeSeries(FsId valuesFsId,
        FsId uncertaintiesFsId, int startCadence, double startMjd,
        double endMjd, long originator, MjdToCadence mjdToCadence) {

        if (values.length != indices.length
            || values.length != uncertainties.length) {
            throw new IllegalStateException(String.format(
                "Size mismatch between outlier values, uncertainties, or indices: "
                    + "valuesFsId=%s; uncertaintiesFsId=%s; values.length=%d; "
                    + "uncertainties.length=%d; indices.length=%d", valuesFsId,
                uncertaintiesFsId, values.length, uncertainties.length,
                indices.length));
        }

        double[] mjds = new double[indices.length];
        for (int i = 0; i < indices.length; i++) {
            mjds[i] = mjdToCadence.cadenceToMjd(startCadence + indices[i]);
        }

        List<FloatMjdTimeSeries> timeSeries = new ArrayList<FloatMjdTimeSeries>(
            2);
        timeSeries.add(new FloatMjdTimeSeries(valuesFsId, startMjd, endMjd,
            mjds, values, originator));
        timeSeries.add(new FloatMjdTimeSeries(uncertaintiesFsId, startMjd,
            endMjd, mjds, uncertainties, originator));

        return timeSeries;
    }

    public float[] getValues() {
        return values;
    }

    public void setValues(float[] values) {
        this.values = values;
    }

    public int[] getIndices() {
        return indices;
    }

    public void setIndices(int[] indices) {
        this.indices = indices;
    }

    public float[] getUncertainties() {
        return uncertainties;
    }

    public void setUncertainties(float[] uncertainties) {
        this.uncertainties = uncertainties;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(indices);
        result = prime * result + Arrays.hashCode(uncertainties);
        result = prime * result + Arrays.hashCode(values);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof OutliersTimeSeries)) {
            return false;
        }
        OutliersTimeSeries other = (OutliersTimeSeries) obj;
        if (!Arrays.equals(indices, other.indices)) {
            return false;
        }
        if (!Arrays.equals(uncertainties, other.uncertainties)) {
            return false;
        }
        if (!Arrays.equals(values, other.values)) {
            return false;
        }
        return true;
    }
}
