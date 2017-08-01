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

package gov.nasa.kepler.fpg;

import static gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType.*;

import gov.nasa.kepler.hibernate.mc.DoubleDbTimeSeries;
import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.util.ArrayList;
import java.util.List;
/**
 * The attitude solution calculated by FPG (using ppa code?).
 * 
 * @author Sean McCauliff
 * @author Forrest Girouard
 * 
 */
@ProxyIgnoreStatics
public class FpgAttitudeSolution implements Persistable {

    private FpgAttitudeTimeSeries ra;
    private FpgAttitudeTimeSeries dec;
    private FpgAttitudeTimeSeries roll;

    /**
     * Don't use this.
     */
    public FpgAttitudeSolution() {
    }

    public FpgAttitudeSolution(FpgAttitudeTimeSeries ra, FpgAttitudeTimeSeries dec, FpgAttitudeTimeSeries roll) {
        this.ra = ra;
        this.dec= dec;
        this.roll = roll;
    }
    
    List<DoubleDbTimeSeries> toDoubleDbTimeSeries(int startCadence, int endCadence, long originator) {
        List<DoubleDbTimeSeries> rv = new ArrayList<DoubleDbTimeSeries>(6);
        rv.addAll(ra.toDoubleDbTimeSeries(FPG_RA, FPG_RA_UNCERT, startCadence, endCadence, originator));
        rv.addAll(dec.toDoubleDbTimeSeries(FPG_DEC, FPG_DEC_UNCERT, startCadence, endCadence, originator));
        rv.addAll(roll.toDoubleDbTimeSeries(FPG_ROLL, FPG_ROLL_UNCERT, startCadence, endCadence, originator));
        return rv;
    }
    
    @Override
    public int hashCode() {
        final int PRIME = 31;
        int result = 1;
        result = PRIME * result + ((dec == null) ? 0 : dec.hashCode());
        result = PRIME * result + ((ra == null) ? 0 : ra.hashCode());
        result = PRIME * result + ((roll == null) ? 0 : roll.hashCode());
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
        final FpgAttitudeSolution other = (FpgAttitudeSolution) obj;
        if (dec == null) {
            if (other.dec != null)
                return false;
        } else if (!dec.equals(other.dec))
            return false;
        if (ra == null) {
            if (other.ra != null)
                return false;
        } else if (!ra.equals(other.ra))
            return false;
        if (roll == null) {
            if (other.roll != null)
                return false;
        } else if (!roll.equals(other.roll))
            return false;
        return true;
    }

    public FpgAttitudeTimeSeries getDec() {
        return dec;
    }

    public void setDec(FpgAttitudeTimeSeries dec) {
        this.dec = dec;
    }

    public FpgAttitudeTimeSeries getRa() {
        return ra;
    }

    public void setRa(FpgAttitudeTimeSeries ra) {
        this.ra = ra;
    }

    public FpgAttitudeTimeSeries getRoll() {
        return roll;
    }

    public void setRoll(FpgAttitudeTimeSeries roll) {
        this.roll = roll;
    }


}
