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

import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;

/**
 * A {@link Persistable} representation of a series of index/value pairs.
 * 
 * @author Miles Cote
 * 
 */
public class SimpleIndicesTimeSeries implements Persistable {

    private float[] values = ArrayUtils.EMPTY_FLOAT_ARRAY;
    private int[] indices = ArrayUtils.EMPTY_INT_ARRAY;

    public SimpleIndicesTimeSeries() {
    }

    /**
     * Creates a {@link SimpleIndicesTimeSeries} object.
     * 
     * @param mjdToCadence required to translate the MJDs to relative cadences.
     * @param startCadence absolute start cadence.
     * @param endCadence absolute end cadence.
     * @param valuesTimeSeries persisted float MJD time series used used to
     * populate the internal contents of this instance.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public SimpleIndicesTimeSeries(MjdToCadence mjdToCadence, int startCadence,
        int endCadence, FloatMjdTimeSeries valuesTimeSeries) {

        if (mjdToCadence == null) {
            throw new NullPointerException("mjdToCadence can't be null");
        }
        if (valuesTimeSeries == null) {
            throw new NullPointerException("valuesTimeSeries can't be null");
        }
        values = valuesTimeSeries.values();
        indices = values.length == 0 ? ArrayUtils.EMPTY_INT_ARRAY
            : new int[values.length];
        double[] mjds = valuesTimeSeries.mjd();
        for (int i = 0; i < mjds.length; i++) {
            indices[i] = mjdToCadence.mjdToCadence(mjds[i]) - startCadence;
        }
    }

    /**
     * Creates a {@link SimpleIndicesTimeSeries} object.
     * 
     * @param valuesFsId {@link FsId} of the persisted float MJD time series
     * used used to populate the internal contents of this instance.
     * @param fsIdToMjdTimeSeries a map of {@link FsId}s to
     * {@link FloatMjdTimeSeries}.
     * @param mjdToCadence required to translate the MJDs to relative cadences.
     * @param startCadence absolute start cadence.
     * @param endCadence absolute end cadence.
     * @return the {@link SimpleIndicesTimeSeries}.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static SimpleIndicesTimeSeries getInstance(FsId valuesFsId,
        Map<FsId, ? extends FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        MjdToCadence mjdToCadence, int startCadence, int endCadence) {
        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (fsIdToMjdTimeSeries == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        FloatMjdTimeSeries values = fsIdToMjdTimeSeries.get(valuesFsId);
        if (values != null && values.exists()) {
            return new SimpleIndicesTimeSeries(mjdToCadence, startCadence,
                endCadence, values);
        }

        return new SimpleIndicesTimeSeries();
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

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(indices);
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
        if (!(obj instanceof SimpleIndicesTimeSeries)) {
            return false;
        }
        SimpleIndicesTimeSeries other = (SimpleIndicesTimeSeries) obj;
        if (!Arrays.equals(indices, other.indices)) {
            return false;
        }
        if (!Arrays.equals(values, other.values)) {
            return false;
        }
        return true;
    }

}
