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

import static gov.nasa.kepler.common.CollateralType.BLACK_LEVEL;
import static gov.nasa.kepler.common.CollateralType.BLACK_MASKED;
import static gov.nasa.kepler.common.CollateralType.BLACK_VIRTUAL;
import static gov.nasa.kepler.common.CollateralType.MASKED_SMEAR;
import static gov.nasa.kepler.common.CollateralType.VIRTUAL_SMEAR;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


/**
 * All the cosmic ray metrics that might be produced.
 * 
 * @author Sean McCauliff
 *
 */
public class CalCosmicRayMetrics implements Persistable {
    /** Cosmic ray metrics for the masked smear. */
    private CosmicRayMetrics maskedSmearCosmicRayMetrics;
    /** Cosmic ray metrics for the virtual smear. */
    private CosmicRayMetrics virtualSmearCosmicRayMetrics;
    /** Black cosmic ray metrics. */
    private CosmicRayMetrics blackCosmicRayMetrics;
    /** Virtual black cosmic ray metrics.  This will only be valid for short
     * cadence*/
    private CosmicRayMetrics virtualBlackCosmicRayMetrics;
    /** Masked black cosmic ray metrics.  This will only be valid for short
     * cadence
     */
    private CosmicRayMetrics maskedBlackCosmicRayMetrics;
    

    public CalCosmicRayMetrics(CosmicRayMetrics maskedSmearCosmicRayMetrics,
        CosmicRayMetrics virtualSmearCosmicRayMetrics,
        CosmicRayMetrics blackCosmicRayMetrics,
        CosmicRayMetrics virtualBlackCosmicRayMetrics,
        CosmicRayMetrics maskedBlackCosmicRayMetrics) {

        this.maskedSmearCosmicRayMetrics = maskedSmearCosmicRayMetrics;
        this.virtualSmearCosmicRayMetrics = virtualSmearCosmicRayMetrics;
        this.blackCosmicRayMetrics = blackCosmicRayMetrics;
        this.virtualBlackCosmicRayMetrics = virtualBlackCosmicRayMetrics;
        this.maskedBlackCosmicRayMetrics = maskedBlackCosmicRayMetrics;
    }

    public CalCosmicRayMetrics() {
        CosmicRayMetrics empty = new CosmicRayMetrics(false);
        maskedSmearCosmicRayMetrics = empty;
        virtualSmearCosmicRayMetrics = empty;
        blackCosmicRayMetrics = empty;
        virtualBlackCosmicRayMetrics = empty;
        maskedBlackCosmicRayMetrics = empty;
    }

    public List<TimeSeries>toTimeSeries(int ccdModule, int ccdOutput, 
        int startCadence, int endCadence, CadenceType cadenceType, 
        long taskId) {
        
        List<TimeSeries> rv = new ArrayList<TimeSeries>();
        
        if (maskedSmearCosmicRayMetrics.isExists()) {
            rv.addAll(Arrays.asList(maskedSmearCosmicRayMetrics.toTimeSeries(
                cadenceType, MASKED_SMEAR, ccdModule, ccdOutput, startCadence,
                endCadence, taskId)));
        }
        
        if (virtualSmearCosmicRayMetrics.isExists()) {
            rv.addAll(Arrays.asList(virtualSmearCosmicRayMetrics.toTimeSeries(
                cadenceType, VIRTUAL_SMEAR, ccdModule, ccdOutput, startCadence,
                endCadence, taskId)));
        }
        
        if (blackCosmicRayMetrics.isExists()) {
            rv.addAll(Arrays.asList(blackCosmicRayMetrics.toTimeSeries(
                cadenceType, BLACK_LEVEL, ccdModule, ccdOutput, startCadence,
                endCadence, taskId)));
        }
        
        if (virtualBlackCosmicRayMetrics.isExists()) {
            rv.addAll(Arrays.asList(virtualBlackCosmicRayMetrics.toTimeSeries(
                cadenceType, BLACK_VIRTUAL, ccdModule, ccdOutput, startCadence,
                endCadence, taskId)));
        }
        
        if (maskedBlackCosmicRayMetrics.isExists()) {
            rv.addAll(Arrays.asList(maskedBlackCosmicRayMetrics.toTimeSeries(
                cadenceType, BLACK_MASKED, ccdModule, ccdOutput, startCadence,
                endCadence, taskId)));
        }
        
        return rv;
    }

    public CosmicRayMetrics getBlackCosmicRayMetrics() {
        return blackCosmicRayMetrics;
    }


    public void setBlackCosmicRayMetrics(CosmicRayMetrics blackCosmicRayMetrics) {
        this.blackCosmicRayMetrics = blackCosmicRayMetrics;
    }


    public CosmicRayMetrics getMaskedBlackCosmicRayMetrics() {
        return maskedBlackCosmicRayMetrics;
    }


    public void setMaskedBlackCosmicRayMetrics(
        CosmicRayMetrics maskedBlackCosmicRayMetrics) {
        this.maskedBlackCosmicRayMetrics = maskedBlackCosmicRayMetrics;
    }


    public CosmicRayMetrics getMaskedSmearCosmicRayMetrics() {
        return maskedSmearCosmicRayMetrics;
    }


    public void setMaskedSmearCosmicRayMetrics(
        CosmicRayMetrics maskedSmearCosmicRayMetrics) {
        this.maskedSmearCosmicRayMetrics = maskedSmearCosmicRayMetrics;
    }


    public CosmicRayMetrics getVirtualBlackCosmicRayMetrics() {
        return virtualBlackCosmicRayMetrics;
    }


    public void setVirtualBlackCosmicRayMetrics(
        CosmicRayMetrics virtualBlackCosmicRayMetrics) {
        this.virtualBlackCosmicRayMetrics = virtualBlackCosmicRayMetrics;
    }


    public CosmicRayMetrics getVirtualSmearCosmicRayMetrics() {
        return virtualSmearCosmicRayMetrics;
    }


    public void setVirtualSmearCosmicRayMetrics(
        CosmicRayMetrics virtualSmearCosmicRayMetrics) {
        this.virtualSmearCosmicRayMetrics = virtualSmearCosmicRayMetrics;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + ((blackCosmicRayMetrics == null) ? 0
                : blackCosmicRayMetrics.hashCode());
        result = prime
            * result
            + ((maskedBlackCosmicRayMetrics == null) ? 0
                : maskedBlackCosmicRayMetrics.hashCode());
        result = prime
            * result
            + ((maskedSmearCosmicRayMetrics == null) ? 0
                : maskedSmearCosmicRayMetrics.hashCode());
        result = prime
            * result
            + ((virtualBlackCosmicRayMetrics == null) ? 0
                : virtualBlackCosmicRayMetrics.hashCode());
        result = prime
            * result
            + ((virtualSmearCosmicRayMetrics == null) ? 0
                : virtualSmearCosmicRayMetrics.hashCode());
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
        CalCosmicRayMetrics other = (CalCosmicRayMetrics) obj;
        if (blackCosmicRayMetrics == null) {
            if (other.blackCosmicRayMetrics != null)
                return false;
        } else if (!blackCosmicRayMetrics.equals(other.blackCosmicRayMetrics))
            return false;
        if (maskedBlackCosmicRayMetrics == null) {
            if (other.maskedBlackCosmicRayMetrics != null)
                return false;
        } else if (!maskedBlackCosmicRayMetrics.equals(other.maskedBlackCosmicRayMetrics))
            return false;
        if (maskedSmearCosmicRayMetrics == null) {
            if (other.maskedSmearCosmicRayMetrics != null)
                return false;
        } else if (!maskedSmearCosmicRayMetrics.equals(other.maskedSmearCosmicRayMetrics))
            return false;
        if (virtualBlackCosmicRayMetrics == null) {
            if (other.virtualBlackCosmicRayMetrics != null)
                return false;
        } else if (!virtualBlackCosmicRayMetrics.equals(other.virtualBlackCosmicRayMetrics))
            return false;
        if (virtualSmearCosmicRayMetrics == null) {
            if (other.virtualSmearCosmicRayMetrics != null)
                return false;
        } else if (!virtualSmearCosmicRayMetrics.equals(other.virtualSmearCosmicRayMetrics))
            return false;
        return true;
    }
    

}
