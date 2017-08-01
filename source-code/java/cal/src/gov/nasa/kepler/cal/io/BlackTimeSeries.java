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

import java.util.Arrays;
import java.util.Map;

import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.PixelFsIdFactory;
import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Black time series data for a single row.
 * <p>
 * Objects of this class are immutable.
 * </p>
 * 
 * @author Bill Wohler
 */
public final class BlackTimeSeries implements Persistable {
    /** The CCD row containing the smear series.  The relevant columns in this
     * row have been coadded to obtain a single value for the row. */
    private int row;
    /** The uncalibrated pixel value.   Where values[i] is the value at the 
     * time of cadenceTimes.cadenceNumber[i]. */
    private int[] values;
    /** This is the same length as values.  When gapIndicators[i] is true then
     * value value in values[i] is undefined.
     */
    private boolean[] gapIndicators;

    /**
     * Do not use. For serialization use only.
     */
    public BlackTimeSeries() {
    }

    /**
     * Creates a {@link BlackTimeSeries} with the given values.
     */
    public BlackTimeSeries(int row, int[] leadingValues, boolean[] gapIndicators) {
        this.row = row;
        this.values = leadingValues;
        this.gapIndicators = gapIndicators;
    }
    
    public BlackTimeSeries(TimeSeries timeSeries) {
        IntTimeSeries its = (IntTimeSeries) timeSeries;
        Map<String, Object> parameters = DrFsIdFactory.parseCollateralPixelTimeSeries(its.id());
        row = (Integer) parameters.get(PixelFsIdFactory.ROW_OR_COLUMN);
        values = its.iseries();
        gapIndicators = its.getGapIndicators();
    }

    // Accessors listed alphabetically.

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public int[] getValues() {
        return values;
    }

    public int getRow() {
        return row;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Arrays.hashCode(gapIndicators);
        result = prime * result + row;
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
        BlackTimeSeries other = (BlackTimeSeries) obj;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (row != other.row)
            return false;
        if (!Arrays.equals(values, other.values))
            return false;
        return true;
    }
    
    
}
