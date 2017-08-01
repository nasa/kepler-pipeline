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

package gov.nasa.kepler.ppa.pag;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;

import java.util.Arrays;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;

/**
 * A simple time series that includes a code symbol count.
 * 
 * @author Bill Wohler
 */
public class PagCompressionTimeSeries extends SimpleFloatTimeSeries {

    /**
     * A count of the code symbols at each cadence.
     */
    private int[] nCodeSymbols = ArrayUtils.EMPTY_INT_ARRAY;

    /**
     * Creates a {@link PagCompressionTimeSeries}.
     */
    public PagCompressionTimeSeries() {
    }

    /**
     * Creates a {@link PagCompressionTimeSeries} with the given time series and
     * associated code symbol counts.
     * 
     * @param timeSeries the non-{@code null} time series
     * @param codeSymbolCounts the non-{@code null} code symbol counts
     * @throws NullPointerException if either {@code timeSeries} or
     * {@code codeSymbolCounts} are {@code null}
     */
    public PagCompressionTimeSeries(FloatTimeSeries timeSeries,
        IntTimeSeries codeSymbolCounts) {

        super(timeSeries.fseries(), timeSeries.getGapIndicators());

        if (codeSymbolCounts == null) {
            throw new NullPointerException("codeSymbolCounts is null");
        }
        if (timeSeries.fseries().length != codeSymbolCounts.iseries().length) {
            throw new IllegalArgumentException(
                "codeSymbolCounts length does not match timeSeries length");
        }
        nCodeSymbols = codeSymbolCounts.iseries();
    }

    /**
     * Creates a {@link PagCompressionTimeSeries} object.
     * 
     * @param valuesFsId the {@link FsId} for the values
     * @param countsFsId the {@link FsId} for the counts
     * @param intTimeSeriesByFsId a map of {@link FsId}s to
     * {@link IntTimeSeries}
     * @param floatTimeSeriesByFsId a map of {@link FsId}s to
     * {@link FloatTimeSeries}
     * @return a {@link PagCompressionTimeSeries}, which will contain arrays of
     * size 0 if {@code valuesFsId} was not found in the map, or arrays of the
     * proper size but where the gap indicators are all {@code true} if the time
     * series is empty.
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public static PagCompressionTimeSeries getInstance(FsId valuesFsId,
        FsId countsFsId, Map<FsId, IntTimeSeries> intTimeSeriesByFsId,
        Map<FsId, FloatTimeSeries> floatTimeSeriesByFsId) {

        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (countsFsId == null) {
            throw new NullPointerException("countsFsId can't be null");
        }
        if (intTimeSeriesByFsId == null) {
            throw new NullPointerException("intTimeSeriesByFsId can't be null");
        }
        if (floatTimeSeriesByFsId == null) {
            throw new NullPointerException("floatSeriesByFsId can't be null");
        }

        FloatTimeSeries values = floatTimeSeriesByFsId.get(valuesFsId);
        IntTimeSeries codeSymbolCounts = intTimeSeriesByFsId.get(countsFsId);
        if (values != null && codeSymbolCounts != null) {
            return new PagCompressionTimeSeries(values, codeSymbolCounts);
        }

        return new PagCompressionTimeSeries();
    }

    public int[] getCodeSymbolCounts() {
        return nCodeSymbols;
    }

    public void setCodeSymbolCounts(int[] codeSymbolCounts) {
        nCodeSymbols = codeSymbolCounts;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + Arrays.hashCode(nCodeSymbols);
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
        final PagCompressionTimeSeries other = (PagCompressionTimeSeries) obj;
        if (!Arrays.equals(nCodeSymbols, other.nCodeSymbols)) {
            return false;
        }
        return true;
    }
}
