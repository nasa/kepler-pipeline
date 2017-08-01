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

import java.util.Arrays;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;

/**
 * A {@link SimpleIndicesTimeSeries} with uncertainties.
 * 
 * @author Miles Cote
 * 
 */
public class CompoundIndicesTimeSeries extends SimpleIndicesTimeSeries {

    private float[] uncertainties = ArrayUtils.EMPTY_FLOAT_ARRAY;

    public CompoundIndicesTimeSeries() {
    }

    /**
     * Creates a {@link CompoundIndicesTimeSeries} object.
     * 
     * @param mjdToCadence required to translate the MJDs to relative cadences.
     * @param startCadence absolute start cadence.
     * @param endCadence absolute end cadence.
     * @param valuesTimeSeries persisted float MJD time series used used to
     * populate the internal contents of this instance.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public CompoundIndicesTimeSeries(MjdToCadence mjdToCadence,
        int startCadence, int endCadence, FloatMjdTimeSeries valuesTimeSeries,
        FloatMjdTimeSeries uncertaintiesTimeSeries) {
        super(mjdToCadence, startCadence, endCadence, valuesTimeSeries);

        if (uncertaintiesTimeSeries == null) {
            throw new NullPointerException(
                "uncertaintiesTimeSeries can't be null");
        }
        if (valuesTimeSeries.values().length != uncertaintiesTimeSeries.values().length) {
            throw new IllegalArgumentException(
                "uncertainties length does not match values length");
        }

        this.uncertainties = uncertaintiesTimeSeries.values();
    }

    /**
     * Creates a {@link CompoundIndicesTimeSeries} object.
     * 
     * @param valuesFsId {@link FsId} of the persisted float MJD time series
     * used used to populate the internal contents of this instance.
     * @param fsIdToMjdTimeSeries a map of {@link FsId}s to
     * {@link FloatMjdTimeSeries}.
     * @param mjdToCadence required to translate the MJDs to relative cadences.
     * @param startCadence absolute start cadence.
     * @param endCadence absolute end cadence.
     * @return the {@link CompoundIndicesTimeSeries}.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static CompoundIndicesTimeSeries getInstance(FsId valuesFsId,
        FsId uncertaintiesFsId,
        Map<FsId, ? extends FloatMjdTimeSeries> fsIdToMjdTimeSeries,
        MjdToCadence mjdToCadence, int startCadence, int endCadence) {
        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (uncertaintiesFsId == null) {
            throw new NullPointerException("uncertaintiesFsId can't be null");
        }
        if (fsIdToMjdTimeSeries == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        FloatMjdTimeSeries values = fsIdToMjdTimeSeries.get(valuesFsId);
        FloatMjdTimeSeries uncertainties = fsIdToMjdTimeSeries.get(uncertaintiesFsId);
        if (values != null && values.exists() && uncertainties != null
            && uncertainties.exists()) {
            return new CompoundIndicesTimeSeries(mjdToCadence, startCadence,
                endCadence, (FloatMjdTimeSeries) values,
                (FloatMjdTimeSeries) uncertainties);
        }

        return new CompoundIndicesTimeSeries();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(uncertainties);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        CompoundIndicesTimeSeries other = (CompoundIndicesTimeSeries) obj;
        if (!Arrays.equals(uncertainties, other.uncertainties)) {
            return false;
        }
        return true;
    }

    public float[] getUncertainties() {
        return uncertainties;
    }

    public void setUncertainties(float[] uncertainties) {
        this.uncertainties = uncertainties;
    }

}
