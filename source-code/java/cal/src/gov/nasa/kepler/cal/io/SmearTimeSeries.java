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
 * Smear data for a single column over time.
 * <p>
 * In the case of long cadence, we'll have one of these objects for each column,
 * but for short cadence, we'll only have columns on which targets are found.
 * <p>
 * Objects of this class are immutable.
 * 
 * @author Sean McCauliff
 * @author Bill Wohler
 */
public final class SmearTimeSeries implements Persistable {
    /** The CCD column containing the smear series.  The relevant rows in this
     * column have been coadded to obtain a single value for the column.
     */
    private int column;
    /** The uncalibrated pixel values.  Where values[i] is the value at the 
     * time of cadenceTimes.cadenceNumber[i].
     */
    private int[] values;
    /** When gapIndicators[i] is true the value in values[i] is undefined. */
    private boolean[] gapIndicators;

    /**
     * Do not use. For serialization use only.
     */
    public SmearTimeSeries() {
    }

    /**
     * Creates a {@link SmearTimeSeries} with the given values.
     */
    public SmearTimeSeries(int column, int[] values, boolean[] gapIndicators) {
        this.column = column;
        this.values = values;
        this.gapIndicators = gapIndicators;
    }
    
    public SmearTimeSeries(TimeSeries timeSeries) {
        IntTimeSeries its = timeSeries.asIntTimeSeries();
        Map<String, Object> parameters = DrFsIdFactory.parseCollateralPixelTimeSeries(its.id());
        column = (Integer) parameters.get(PixelFsIdFactory.ROW_OR_COLUMN);
        values = its.iseries();
        gapIndicators = its.getGapIndicators();
    }

    // Accessors listed alphabetically.

    public int getColumn() {
        return column;
    }

    public boolean[] getGapIndicators() {
        return gapIndicators;
    }

    public int[] getValues() {
        return values;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + column;
        result = prime * result + Arrays.hashCode(gapIndicators);
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
        SmearTimeSeries other = (SmearTimeSeries) obj;
        if (column != other.column)
            return false;
        if (!Arrays.equals(gapIndicators, other.gapIndicators))
            return false;
        if (!Arrays.equals(values, other.values))
            return false;
        return true;
    }
    
    
}
