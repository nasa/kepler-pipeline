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
 * Detected cosmic ray energy and outliers in collateral data.
 * <p>
 * Objects of this class are immutable.
 * </p>
 * 
 * @author Sean McCauliff
 * @author Bill Wohler
 */
@ProxyIgnoreStatics
public class CalCollateralCosmicRay implements Persistable {
    /** The row or column in the coadded collateral data.  Weather this is a row
     * or column depends on if this represents a black or a smear cosmic ray.
     */
    private int rowOrColumn;
    
    /** The timestamp from cadenceTimes.midTimestamps when this cosmic ray
     * occurred.
     */
    private double mjd;
    
    /**  The energy of the cosmic ray or outlier. */
    private float delta;

    /**
     * Do not use. For serialization use only.
     */
    public CalCollateralCosmicRay() {
    }

    /**
     * Creates a {@link CalCollateralCosmicRay} object with the given values.
     * 
     * @param mjd the cadence timstamp for this object.
     * @param rowOrColumn the row (for black) or column (for smear).
     * @param delta the influence of the cosmic ray hit.
     */
    public CalCollateralCosmicRay(double mjd, int rowOrColumn, float delta) {
        this.mjd = mjd;
        this.rowOrColumn = rowOrColumn;
        this.delta = delta;
    }

    // Accessors listed alphabetically.

    public float getDelta() {
        return delta;
    }

    public double getMjd() {
        return mjd;
    }
    
    public int getRowOrColumn() {
        return rowOrColumn;
    }
    
    @Override
    public String toString() {
        return CalCollateralCosmicRay.class.getName() + "" + mjd + " "+ rowOrColumn + " " + delta;
    }
}
