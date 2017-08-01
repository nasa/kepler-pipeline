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

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

/**
 * Time series pixel data for a single row and column for output.
 * <p>
 * Objects of this class are immutable.
 * </p>
 * 
 * @author Bill Wohler
 */
@ProxyIgnoreStatics
public class CalOutputPixelTimeSeries implements Persistable {
    /** Visible CCD row where this pixel time series is located. */
    private int row;
    /** Visible CCD column where this pixel time series is located. */
    private int column;
    
    /** The calibrated pixel value.  This must be the same length as the number
     *  of cadences in the unit of work. 
     */
    private float[] values;
    
    /** The uncertainties associated with each pixel value.  This is the same
     * length as values
     * [143.CAL.1] */
    private float[] uncertainties;
    
    /** When gapIndicator[i] is true then the values[i] and uncertainties[i] 
     * are undefined.  This has the same length as values.
     */
    private boolean[] gapIndicators;

    /**
     * Do not use. For serialization use only.
     */
    public CalOutputPixelTimeSeries() {
    }

    /**
     * Creates a {@link CalOutputPixelTimeSeries} with the given values.
     */
    public CalOutputPixelTimeSeries(int row, int column, float[] values,
        float[] uncertainties, boolean[] gapIndicators) {

        this.row = row;
        this.column = column;
        this.values = values;
        this.uncertainties = uncertainties;
        this.gapIndicators = gapIndicators;
    }

    // Accessors listed alphabetically.

    public int getColumn() {
        return column;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public int getRow() {
        return row;
    }

    public float[] getUncertainties() {
        return uncertainties;
    }

    public float[] getValues() {
        return values;
    }

    /**
     * Returns a hash code value for the object. Only the {@code row} and
     * {@code column} fields are considered.
     */
    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + column;
        result = PRIME * result + row;
        return result;
    }

    /**
     * Indicates whether some other object is "equal to" this one. Only the
     * {@code row} and {@code column} fields are considered.
     */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final CalOutputPixelTimeSeries other = (CalOutputPixelTimeSeries) obj;
        if (column != other.column) {
            return false;
        }
        if (row != other.row) {
            return false;
        }
        return true;
    }
}
