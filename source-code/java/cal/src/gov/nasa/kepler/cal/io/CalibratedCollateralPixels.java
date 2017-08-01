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

import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

/**
 * "Calibrated" collateral pixels.  These are correspond to the collateral pixels
 * on the inputs, but have some calibration performed on them depending on
 * the type of pixel.
 * 
 * @author Sean McCauliff
 *
 */
public class CalibratedCollateralPixels implements Persistable {

    /** The residual of the leading or trailing black rows. */
    private List<BlackResidualTimeSeries> blackResidual = 
            new ArrayList<BlackResidualTimeSeries>();
    
    /** The residual of the black in the masked smear rows.  This is only valid
     * for short cadence. 
     */
    private SingleResidualBlackTimeSeries maskedBlackResidual = 
        new SingleResidualBlackTimeSeries();
    
    /** The residual of the black in the virtual smear rows.  This is only valid
     * for short cadence.
     */
    private SingleResidualBlackTimeSeries virtualBlackResidual = 
        new SingleResidualBlackTimeSeries();
    
    /** The calibrated masked smear columns.  When this is short cadence only a subset
     * of the pixels will be available.
     */
    private List<CalibratedSmearTimeSeries> maskedSmear = 
        new ArrayList<CalibratedSmearTimeSeries>();
    
    /** The calibrated virtual smear columns.  When this is short cadence only a subset
     * of the pixels will be available.
     */
    private List<CalibratedSmearTimeSeries> virtualSmear =
        new ArrayList<CalibratedSmearTimeSeries>();
    
    public CalibratedCollateralPixels() {
        
    }

    public CalibratedCollateralPixels(
        List<BlackResidualTimeSeries> residualBlack,
        SingleResidualBlackTimeSeries residualVirtualBlack,
        SingleResidualBlackTimeSeries residualMaskedBlack,
        List<CalibratedSmearTimeSeries> virtualSmear,
        List<CalibratedSmearTimeSeries> maskedSmear) {

        this.blackResidual = residualBlack;
        this.maskedBlackResidual = residualMaskedBlack;
        this.virtualBlackResidual = residualVirtualBlack;
        this.virtualSmear = virtualSmear;
        this.maskedSmear = maskedSmear;
    }

    /**
     * The total number of pixels returned.
     * @return a non-negative number.
     */
    public int size() {
        return blackResidual.size() + maskedBlackResidual.size() +
        virtualBlackResidual.size() + maskedSmear.size() + virtualSmear.size();
    }
    public List<BlackResidualTimeSeries> getBlackResidual() {
        return blackResidual;
    }

    public void setBlackResidual(List<BlackResidualTimeSeries> blackResidual) {
        this.blackResidual = blackResidual;
    }

    public SingleResidualBlackTimeSeries getMaskedBlackResidual() {
        return maskedBlackResidual;
    }

    public void setMaskedBlackResidual(
        SingleResidualBlackTimeSeries maskedBlackResidual) {
        this.maskedBlackResidual = maskedBlackResidual;
    }

    public SingleResidualBlackTimeSeries getVirtualBlackResidual() {
        return virtualBlackResidual;
    }

    public void setVirtualBlackResidual(
        SingleResidualBlackTimeSeries virtualBlackResidual) {
        this.virtualBlackResidual = virtualBlackResidual;
    }

    public List<CalibratedSmearTimeSeries> getMaskedSmear() {
        return maskedSmear;
    }

    public void setMaskedSmear(List<CalibratedSmearTimeSeries> maskedSmear) {
        this.maskedSmear = maskedSmear;
    }

    public List<CalibratedSmearTimeSeries> getVirtualSmear() {
        return virtualSmear;
    }

    public void setVirtualSmear(List<CalibratedSmearTimeSeries> virtualSmear) {
        this.virtualSmear = virtualSmear;
    }

    public Collection<? extends TimeSeries> toTimeSeries(
        int ccdModule, int ccdOutput, int startCadence, int endCadence, 
        CadenceType cadenceType, long taskId) {

        List<TimeSeries> fileStoreTimeSeries = new ArrayList<TimeSeries>();
        
        for (BlackResidualTimeSeries br : getBlackResidual()) {
            fileStoreTimeSeries.addAll(br.toTimeSeries(ccdModule, ccdOutput, 
                startCadence, endCadence, cadenceType, taskId));
        }
        
        if (maskedBlackResidual.exists()) {
            fileStoreTimeSeries.addAll(maskedBlackResidual.toTimeSeries(CollateralType.BLACK_MASKED, ccdModule, ccdOutput, startCadence, endCadence, cadenceType, taskId));
        }
        
        if (virtualBlackResidual.exists()) {
            fileStoreTimeSeries.addAll(virtualBlackResidual.toTimeSeries(CollateralType.BLACK_VIRTUAL, ccdModule, ccdOutput, startCadence, endCadence, cadenceType, taskId));
        }
        
        for (CalibratedSmearTimeSeries smear : maskedSmear) {
            fileStoreTimeSeries.addAll(smear.toTimeSeries(CollateralType.MASKED_SMEAR, ccdModule, ccdOutput, cadenceType, startCadence, endCadence, taskId));
        }
        
        for (CalibratedSmearTimeSeries smear : virtualSmear) {
            fileStoreTimeSeries.addAll(smear.toTimeSeries(CollateralType.VIRTUAL_SMEAR, ccdModule, ccdOutput, cadenceType, startCadence, endCadence, taskId));
        }

        return fileStoreTimeSeries;
        
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((blackResidual == null) ? 0 : blackResidual.hashCode());
        result = prime
            * result
            + ((maskedBlackResidual == null) ? 0
                : maskedBlackResidual.hashCode());
        result = prime * result
            + ((maskedSmear == null) ? 0 : maskedSmear.hashCode());
        result = prime
            * result
            + ((virtualBlackResidual == null) ? 0
                : virtualBlackResidual.hashCode());
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
        CalibratedCollateralPixels other = (CalibratedCollateralPixels) obj;
        if (blackResidual == null) {
            if (other.blackResidual != null)
                return false;
        } else if (!blackResidual.equals(other.blackResidual))
            return false;
        if (maskedBlackResidual == null) {
            if (other.maskedBlackResidual != null)
                return false;
        } else if (!maskedBlackResidual.equals(other.maskedBlackResidual))
            return false;
        if (maskedSmear == null) {
            if (other.maskedSmear != null)
                return false;
        } else if (!maskedSmear.equals(other.maskedSmear))
            return false;
        if (virtualBlackResidual == null) {
            if (other.virtualBlackResidual != null)
                return false;
        } else if (!virtualBlackResidual.equals(other.virtualBlackResidual))
            return false;
        if (virtualSmear == null) {
            if (other.virtualSmear != null)
                return false;
        } else if (!virtualSmear.equals(other.virtualSmear))
            return false;
        return true;
    }
   
}

   
