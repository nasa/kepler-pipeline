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

package gov.nasa.kepler.pdq;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Arrays;

import org.apache.commons.lang.builder.ToStringBuilder;

/**
 * Time series for a single reference pixel and all required data associated
 * with this pixel. The <tt>timeSeries</tt> and <tt>gapIndicators</tt> arrays
 * must be the same length.
 * 
 * @author Forrest Girouard
 * 
 */
public class PdqPixelTimeSeries implements Persistable {

    /**
     * CCD row value.
     */
    private int row;

    /**
     * CCD column value.
     */
    private int column;

    /**
     * True if this pixel is in the optimal aperture for it's associated target.
     * TODO: Rename this field to inOptimalAperture to avoid having a field and
     * a method with the same name.
     */
    private boolean isInOptimalAperture;

    /**
     * Raw reference pixel integer values.
     */
    private int[] timeSeries = new int[0];

    /**
     * True iff the reference pixel value is unknown (gapped).
     */
    private boolean[] gapIndicators = new boolean[0];

    public PdqPixelTimeSeries() {
    }

    /**
     * Constructs a partial pixel time series. The array values should be set
     * post-construction.
     * 
     * @param row
     * @param column
     * @param isInOptimalAperture
     */
    PdqPixelTimeSeries(final int row, final int column,
        final boolean isInOptimalAperture) {
        this.row = row;
        this.column = column;
        this.isInOptimalAperture = isInOptimalAperture;
    }

    public int getColumn() {
        return column;
    }

    public boolean[] getGapIndicators() {
        return Arrays.copyOf(gapIndicators, gapIndicators.length);
    }

    public boolean isInOptimalAperture() {
        return isInOptimalAperture;
    }

    public int getRow() {
        return row;
    }

    public int[] getTimeSeries() {
        return Arrays.copyOf(timeSeries, timeSeries.length);
    }

    public void setColumn(final int column) {
        this.column = column;
    }

    public void setGapIndicators(final boolean[] gapIndicators) {
        this.gapIndicators = Arrays.copyOf(gapIndicators, gapIndicators.length);
    }

    public void setInOptimalAperture(final boolean isInOptimalAperture) {
        this.isInOptimalAperture = isInOptimalAperture;
    }

    public void setRow(final int row) {
        this.row = row;
    }

    public void setTimeSeries(final int[] timeSeries) {
        this.timeSeries = Arrays.copyOf(timeSeries, timeSeries.length);
    }

    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + column;
        result = PRIME * result + Arrays.hashCode(gapIndicators);
        result = PRIME * result + (isInOptimalAperture ? 1231 : 1237);
        result = PRIME * result + row;
        result = PRIME * result + Arrays.hashCode(timeSeries);
        return result;
    }

    @Override
    public boolean equals(final Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PdqPixelTimeSeries other = (PdqPixelTimeSeries) obj;
        if (column != other.column) {
            return false;
        }
        if (!Arrays.equals(gapIndicators, other.gapIndicators)) {
            return false;
        }
        if (isInOptimalAperture != other.isInOptimalAperture) {
            return false;
        }
        if (row != other.row) {
            return false;
        }
        if (!Arrays.equals(timeSeries, other.timeSeries)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).append("row", row)
            .append("column", column)
            .append("isInOptimalAperture", isInOptimalAperture)
            .append("timeSeries.length", timeSeries.length)
            .append("gapIndicators.length", gapIndicators.length)
            .toString();
    }
}
