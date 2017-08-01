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

package gov.nasa.kepler.common.intervals;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.lang.ArrayUtils;

/**
 * A time series that represents which data to use for a specific cadence.
 * 
 * {@code dataIndices} is an array of {@code endCadence - startCadence + 1}
 * length, as is {@code gapIndicators}. If {@code gapIndicators[i]} is
 * {@code true} then {@code dataIndices[i]} is undefined.
 * {@code data.[dataIndices[i]]} is the data to use for cadence
 * {@code startCadence + i}.
 * 
 * @author Forrest Girouard
 * @author Sean McCauliff
 * 
 */
public class DataSeries<T> {

    private int[] dataIndices;
    private boolean[] gapIndicators;
    private T[] data;
    private long[] dataOriginators;
    private int startCadence;
    private int endCadence;

    /**
     * Create an an empty data series. This is useful for testing or as a place
     * holder in a Matlab structure.
     * 
     * @param <T>
     * @param startCadence
     * @param endCadence
     * @return
     */
    @SuppressWarnings("unchecked")
    public static <T> DataSeries<T> empty(int startCadence, int endCadence) {
        DataSeries<T> emptyDataSeries = new DataSeries<T>();
        emptyDataSeries.dataIndices = ArrayUtils.EMPTY_INT_ARRAY;
        emptyDataSeries.gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;
        emptyDataSeries.data = (T[]) ArrayUtils.EMPTY_OBJECT_ARRAY;
        emptyDataSeries.dataOriginators = ArrayUtils.EMPTY_LONG_ARRAY;
        emptyDataSeries.startCadence = startCadence;
        emptyDataSeries.endCadence = endCadence;
        return emptyDataSeries;
    }

    protected DataSeries() {
    }

    public DataSeries(int[] dataIndices, boolean[] gapIndicators,
        T[] data, long[] dataOriginators, int startCadence,
        int endCadence) {

        if (dataIndices.length != gapIndicators.length) {
            throw new IllegalArgumentException(
                "dataIndices.length must match gapIndicators.length");
        }
        if (data.length != dataOriginators.length) {
            throw new IllegalArgumentException(
                "data.length must match dataOriginators.length");
        }
        this.dataIndices = dataIndices;
        this.data = data;
        this.gapIndicators = gapIndicators;
        this.dataOriginators = dataOriginators;
        this.startCadence = startCadence;
        this.endCadence = endCadence;
    }

    public T dataForCadence(int cadence, int startCadence) {

        int i = cadence - startCadence;
        if (gapIndicators[i]) {
            return null;
        }
        return data[dataIndices[i]];
    }

    public int[] dataIndices() {
        return dataIndices;
    }

    public boolean[] gapIndicators() {
        return gapIndicators;
    }

    public int startCadence() {
        return startCadence;
    }

    public int endCadence() {
        return endCadence;
    }

    public long[] dataOriginators() {
        return dataOriginators;
    }

    public Set<Long> dataOriginatorsSet() {
        Set<Long> rv = new HashSet<Long>();
        for (int i = 0; i < dataOriginators.length; i++) {
            if (!gapIndicators[i]) {
                rv.add(dataOriginators[i]);
            }
        }
        return rv;
    }

    // Unfortunately, returning T[] results in a runtime class cast exception
    // when T is a primitive array (for example, byte[]). In other words,
    // (byte[][])Object[] results in a ClassCastException at runtime which is
    // probably because byte[0][] is not the same as Object[0].
    public Object[] data() {
        return data;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(data);
        result = prime * result + Arrays.hashCode(dataIndices);
        result = prime * result + Arrays.hashCode(dataOriginators);
        result = prime * result + endCadence;
        result = prime * result + Arrays.hashCode(gapIndicators);
        result = prime * result + startCadence;
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
        if (!(obj instanceof DataSeries)) {
            return false;
        }
        @SuppressWarnings("unchecked")
        DataSeries<T> other = (DataSeries<T>) obj;
        if (!Arrays.equals(data, other.data)) {
            return false;
        }
        if (!Arrays.equals(dataIndices, other.dataIndices)) {
            return false;
        }
        if (!Arrays.equals(dataOriginators, other.dataOriginators)) {
            return false;
        }
        if (endCadence != other.endCadence) {
            return false;
        }
        if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
            return false;
        }
        if (startCadence != other.startCadence) {
            return false;
        }
        return true;
    }

}
