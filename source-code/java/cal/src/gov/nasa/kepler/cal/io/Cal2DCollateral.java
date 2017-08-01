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

/**
 * 2D Arrays of collateral pixels for when we have all the collateral pixels
 * available.
 * 
 * @author Sean McCauliff
 *
 */
public class Cal2DCollateral implements Persistable {

    /** Black pixel region.  This may be either the leading or trailing black,
     * but not both.  It depends on the ConfigMap state at the time the data
     * was collected.
     */
    private Cal2DCollateralRegion blackStruct = new Cal2DCollateralRegion();
    /** Virtual smear region. */
    private Cal2DCollateralRegion virtualSmearStruct = new Cal2DCollateralRegion();
    /** Masked smear region. */
    private Cal2DCollateralRegion maskedSmearStruct = new Cal2DCollateralRegion();
    
    /**
     * For when you want an empty collateral object.
     */
    public Cal2DCollateral() {
        
    }
    
    /**
     * @param leadingBlackStruct
     * @param trailingBlackStruct
     * @param virtualSmearStruct
     * @param maskedSmearStruct
     */
    public Cal2DCollateral(Cal2DCollateralRegion blackStruct,
        Cal2DCollateralRegion virtualSmearStruct,
        Cal2DCollateralRegion maskedSmearStruct) {

        this.blackStruct = blackStruct;
        this.virtualSmearStruct = virtualSmearStruct;
        this.maskedSmearStruct = maskedSmearStruct;
        
        
    }
    public Cal2DCollateralRegion getBlackStruct() {
        return blackStruct;
    }
    public Cal2DCollateralRegion getVirtualSmearStruct() {
        return virtualSmearStruct;
    }
    public Cal2DCollateralRegion getMaskedSmearStruct() {
        return maskedSmearStruct;
    }
    
    public int collateralPixelCount() {
        return blackStruct.pixelCount() + virtualSmearStruct.pixelCount() +
               maskedSmearStruct.pixelCount();
    }
}
