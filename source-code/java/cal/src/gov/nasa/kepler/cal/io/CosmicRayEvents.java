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

import java.util.ArrayList;
import java.util.List;

/**
 * The detected cosmic rays and outliers in the collateral regions.
 * 
 * @author Sean McCauliff
 *
 */
public class CosmicRayEvents implements Persistable {

    /**
     * Detected cosmic ray energy in virtual smear collateral data.
     * There can be zero or more of these.  [317.CAL.1]
     */
    private List<CalCollateralCosmicRay> virtualSmear = new ArrayList<CalCollateralCosmicRay>();

    /** Detected cosmic ray energy in the masked smear region.  There may be
     * zero or more of these.  [317.CAL.1]
     */
    private List<CalCollateralCosmicRay> maskedSmear = new ArrayList<CalCollateralCosmicRay>();
    
    /**
     * Detected cosmic ray energy in the black level collateral data.  There may
     * be zero or more of these.  [317.CAL.1]
     */
    private List<CalCollateralCosmicRay> black = new ArrayList<CalCollateralCosmicRay>();
    
    
    /**
     * Detected cosmic ray energy in the black masked collateral data.  There may
     * be zero or more of these.  They should only exist for short cadence data.
     * [317.CAL.1]
     */
    private List<CalCollateralCosmicRay> maskedBlack = new ArrayList<CalCollateralCosmicRay>();
    
    /**
     * Detected cosmic ray energy in the black virtual collateral data.  There
     * may be zero or more of these.  They should only exist for short cadence
     * data. [317.CAL.1]
     */
    private List<CalCollateralCosmicRay> virtualBlack = new ArrayList<CalCollateralCosmicRay>();

    
    public CosmicRayEvents() {
        
    }
    
    public CosmicRayEvents(List<CalCollateralCosmicRay> virtualSmear,
        List<CalCollateralCosmicRay> maskedSmear,
        List<CalCollateralCosmicRay> black,
        List<CalCollateralCosmicRay> maskedBlack,
        List<CalCollateralCosmicRay> virtualBlack) {
        super();
        this.virtualSmear = virtualSmear;
        this.maskedSmear = maskedSmear;
        this.black = black;
        this.maskedBlack = maskedBlack;
        this.virtualBlack = virtualBlack;
    }

    ///////////
    
    public List<CalCollateralCosmicRay> getVirtualSmear() {
        return virtualSmear;
    }

    public List<CalCollateralCosmicRay> getBlack() {
        return black;
    }

    public List<CalCollateralCosmicRay> getMaskedBlack() {
        return maskedBlack;
    }

    public List<CalCollateralCosmicRay> getVirtualBlack() {
        return virtualBlack;
    }

    public List<CalCollateralCosmicRay> getMaskedSmear() {
        return maskedSmear;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((black == null) ? 0 : black.hashCode());
        result = prime * result
            + ((maskedBlack == null) ? 0 : maskedBlack.hashCode());
        result = prime * result
            + ((maskedSmear == null) ? 0 : maskedSmear.hashCode());
        result = prime * result
            + ((virtualBlack == null) ? 0 : virtualBlack.hashCode());
        result = prime * result
            + ((virtualSmear == null) ? 0 : virtualSmear.hashCode());
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
        CosmicRayEvents other = (CosmicRayEvents) obj;
        if (black == null) {
            if (other.black != null)
                return false;
        } else if (!black.equals(other.black))
            return false;
        if (maskedBlack == null) {
            if (other.maskedBlack != null)
                return false;
        } else if (!maskedBlack.equals(other.maskedBlack))
            return false;
        if (maskedSmear == null) {
            if (other.maskedSmear != null)
                return false;
        } else if (!maskedSmear.equals(other.maskedSmear))
            return false;
        if (virtualBlack == null) {
            if (other.virtualBlack != null)
                return false;
        } else if (!virtualBlack.equals(other.virtualBlack))
            return false;
        if (virtualSmear == null) {
            if (other.virtualSmear != null)
                return false;
        } else if (!virtualSmear.equals(other.virtualSmear))
            return false;
        return true;
    }

}
