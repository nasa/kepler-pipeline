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

package gov.nasa.spiffy.common;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * A simple persistable time series (no uncertainties).
 * 
 * @author Forrest Girouard
 * 
 */
public class SimpleFloatTimeSeries implements Persistable {

    /**
     * Time series values.
     */
    private float[] values = ArrayUtils.EMPTY_FLOAT_ARRAY;

    /**
     * True values represent gaps in the time series. The values and
     * uncertainties for gaps are unspecified.
     */
    private boolean[] gapIndicators = ArrayUtils.EMPTY_BOOLEAN_ARRAY;

    public SimpleFloatTimeSeries() {
    }

    public SimpleFloatTimeSeries(int length) {
        if (length > 0) {
            values = new float[length];

            boolean[] gapIndicators = new boolean[length];
            Arrays.fill(gapIndicators, true);
            this.gapIndicators = gapIndicators;
        }
    }

    public SimpleFloatTimeSeries(float[] values, boolean[] gapIndicators) {

        if (values == null) {
            throw new NullPointerException("values is null");
        }
        if (gapIndicators == null) {
            throw new NullPointerException("gapIndicators is null");
        }
        if (values.length != gapIndicators.length) {
            throw new IllegalArgumentException(String.format(
                "gapIndicators length, %d, does not match values length, %d",
                gapIndicators.length, values.length));
        }
        this.values = values;
        this.gapIndicators = gapIndicators;
    }

    public boolean isEmpty() {
        return values.length == 0;
    }

    public int size() {
        return values.length;
    }

    public boolean isAllGaps() {
        return !ArrayUtils.contains(gapIndicators, false);
    }

    public int gapCount() {
        int gapCount = 0;
        for (boolean isGap : gapIndicators) {
            if (isGap) {
                gapCount++;
            }
        }
        return gapCount;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public void setGapIndicators(boolean[] gapIndicators) {
        this.gapIndicators = gapIndicators;
    }

    public float[] getValues() {
        return values;
    }

    public void setValues(float[] values) {
        this.values = values;
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + Arrays.hashCode(gapIndicators);
        result = PRIME * result + Arrays.hashCode(values);
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
        if (!(obj instanceof SimpleFloatTimeSeries)) {
            return false;
        }
        final SimpleFloatTimeSeries other = (SimpleFloatTimeSeries) obj;
        if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
            return false;
        }
        if (!Arrays.equals(values, other.values)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("values.length", values.length)
            .append("gapIndicators.length", gapIndicators.length)
            .toString();
    }
}
