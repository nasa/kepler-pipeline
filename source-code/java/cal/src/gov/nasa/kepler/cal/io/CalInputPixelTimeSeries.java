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

import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Time series pixel data for a single row and column for input.
 * <p>
 * Objects of this class are immutable.
 * 
 * @author Bill Wohler
 */
public class CalInputPixelTimeSeries implements Persistable {
    /** CCD row of this pixel time series. */
    private int row;
    /** CCD column of this pixel time series. */
    private int column;
    /** Uncalibrated pixel values. Where value[i] is the value at 
     * cadenceTimes.cadenceNumber[i]
     */
    private int[] values;
    /**  This is the same length as values.  When gapIndicators[i] is true then
     * values[i] is undefined.
     */
    private boolean[] gapIndicators;

    /**
     * Do not use. For serialization use only.
     */
    public CalInputPixelTimeSeries() {
    }

    /**
     * Creates a {@link CalInputPixelTimeSeries} with the given values.
     */
    public CalInputPixelTimeSeries(int row, int column, int[] values,
        boolean[] gapIndicators) {

        this.row = row;
        this.column = column;
        this.values = values;
        this.gapIndicators = gapIndicators;
    }
    
    public CalInputPixelTimeSeries(Pixel pixel, IntTimeSeries timeSeries) {
        this.row = pixel.getRow();
        this.column = pixel.getColumn();
        this.values = timeSeries.iseries();
        this.gapIndicators = timeSeries.getGapIndicators();
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

    public int[] getValues() {
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
        final CalInputPixelTimeSeries other = (CalInputPixelTimeSeries) obj;
        if (column != other.column) {
            return false;
        }
        if (row != other.row) {
            return false;
        }
        return true;
    }
}
