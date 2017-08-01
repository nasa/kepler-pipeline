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

package gov.nasa.kepler.cal.io;

import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.util.Arrays;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;

/**
 * Compression statistics.
 * 
 * @author Sean McCauliff
 * 
 */
@ProxyIgnoreStatics
public class CalCompressionTimeSeries implements Persistable {

    private float[] values = ArrayUtils.EMPTY_FLOAT_ARRAY;
    /**
     * The number of code symbols used for a particular cadence. This is the
     * same length as values.
     */
    private int[] nCodeSymbols = ArrayUtils.EMPTY_INT_ARRAY;
    /**
     * When gapIndicators[i] is true values[i] and nCodeSymbols[i] is undefined.
     */
    private boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    public CalCompressionTimeSeries() {

    }

    public CalCompressionTimeSeries(float[] values, int[] nCodeSymbols,
        boolean[] gapIndicators) {
        this.values = values;
        this.nCodeSymbols = nCodeSymbols;
        this.gapIndicators = gapIndicators;
    }

    public CalCompressionTimeSeries(FloatTimeSeries values, IntTimeSeries counts) {
        if (values == null) {
            throw new NullPointerException("values is null");
        }
        float[] valuesArray = values.fseries();
        boolean[] gapIndicatorsArray = values.getGapIndicators();

        if (counts == null) {
            throw new NullPointerException("counts is null");
        }
        int[] countsArray = counts.iseries();

        if (gapIndicatorsArray == null) {
            throw new NullPointerException("gapIndicators is null");
        }
        if (valuesArray.length != gapIndicatorsArray.length) {
            throw new IllegalArgumentException(
                "gapIndicators length does not match values length");
        }
        if (valuesArray.length != countsArray.length) {
            throw new IllegalArgumentException(
                "values length does not match counts length");
        }
        if (!Arrays.equals(gapIndicatorsArray, counts.getGapIndicators())) {
            throw new IllegalArgumentException(
                "counts gaps do not match value gaps");
        }

        this.values = valuesArray;
        this.nCodeSymbols = countsArray;
        this.gapIndicators = gapIndicatorsArray;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public int[] getNCodeSymbols() {
        return nCodeSymbols;
    }

    public float[] getValues() {
        return values;
    }

    public static CalCompressionTimeSeries getInstance(FsId valuesFsId,
        FsId countsFsId, Map<FsId, ? extends TimeSeries> timeSeriesByFsId) {
        if (valuesFsId == null) {
            throw new NullPointerException("valuesFsId can't be null");
        }
        if (countsFsId == null) {
            throw new NullPointerException("countsFsId can't be null");
        }
        if (timeSeriesByFsId == null) {
            throw new NullPointerException("timeSeriesByFsId can't be null");
        }

        TimeSeries values = timeSeriesByFsId.get(valuesFsId);
        TimeSeries counts = timeSeriesByFsId.get(countsFsId);
        if (values != null && values.exists() && counts != null
            && counts.exists()) {
            return new CalCompressionTimeSeries((FloatTimeSeries) values,
                (IntTimeSeries) counts);
        }
        return new CalCompressionTimeSeries();
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(gapIndicators);
        result = prime * result + Arrays.hashCode(nCodeSymbols);
        result = prime * result + Arrays.hashCode(values);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        CalCompressionTimeSeries other = (CalCompressionTimeSeries) obj;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (!Arrays.equals(nCodeSymbols, other.nCodeSymbols))
            return false;
        if (!Arrays.equals(values, other.values))
            return false;
        return true;
    }
    
    
}
