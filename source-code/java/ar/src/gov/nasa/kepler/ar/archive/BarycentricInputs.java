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

package gov.nasa.kepler.ar.archive;

import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.Collections;
import java.util.List;

/**
 * Archive matlab module inputs for calculating the barycentric correction for
 * targets missing the correction.
 * 
 * @author Sean McCauliff
 *
 */
public class BarycentricInputs implements Persistable {

    private List<BarycentricTarget> barycentricTargets;
    
    /**
     * Use this constructor for Persistable or if you don't want to calculate 
     * any barycentric correction time series.
     */
    public BarycentricInputs() {
        barycentricTargets = Collections.emptyList();
    }
    

    
    public BarycentricInputs(List<BarycentricTarget> barycentricTargets) {
        this.barycentricTargets = barycentricTargets;
    }
    
    
    
    public List<BarycentricTarget> getBarycentricTargets() {
        return barycentricTargets;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + ((barycentricTargets == null) ? 0 : barycentricTargets.hashCode());
        return result;
    }



    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (!(obj instanceof BarycentricInputs))
            return false;
        BarycentricInputs other = (BarycentricInputs) obj;
        if (barycentricTargets == null) {
            if (other.barycentricTargets != null)
                return false;
        } else if (!barycentricTargets.equals(other.barycentricTargets))
            return false;
        return true;
    }



    public static final class BarycentricTarget implements Persistable {
        private int keplerId;
        private int longCadenceReference;
        private double ra;
        private double dec;
        private double centerCcdRow;
        private double centerCcdCol;
        
        /**
         * For Persistable interface.  Don't use this.
         */
        public BarycentricTarget() {
            
        }
        
        public BarycentricTarget(int keplerId, int longReferenceCadence, 
            double centerCcdRow, double centerCcdCol,
            double ra, double dec) {
            this.keplerId = keplerId;
            this.longCadenceReference = longReferenceCadence;
            this.centerCcdRow = centerCcdRow;
            this.centerCcdCol = centerCcdCol;
            this.ra = ra;
            this.dec = dec;
        }
        
        


        @Override
        public int hashCode() {
            final int prime = 31;
            int result = 1;
            long temp;
            temp = Double.doubleToLongBits(centerCcdCol);
            result = prime * result + (int) (temp ^ (temp >>> 32));
            temp = Double.doubleToLongBits(centerCcdRow);
            result = prime * result + (int) (temp ^ (temp >>> 32));
            temp = Double.doubleToLongBits(dec);
            result = prime * result + (int) (temp ^ (temp >>> 32));
            result = prime * result + keplerId;
            result = prime * result + longCadenceReference;
            temp = Double.doubleToLongBits(ra);
            result = prime * result + (int) (temp ^ (temp >>> 32));
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
            BarycentricTarget other = (BarycentricTarget) obj;
            if (Double.doubleToLongBits(centerCcdCol) != Double
                    .doubleToLongBits(other.centerCcdCol))
                return false;
            if (Double.doubleToLongBits(centerCcdRow) != Double
                    .doubleToLongBits(other.centerCcdRow))
                return false;
            if (Double.doubleToLongBits(dec) != Double
                    .doubleToLongBits(other.dec))
                return false;
            if (keplerId != other.keplerId)
                return false;
            if (longCadenceReference != other.longCadenceReference)
                return false;
            if (Double.doubleToLongBits(ra) != Double
                    .doubleToLongBits(other.ra))
                return false;
            return true;
        }

        
        @Override
        public String toString() {
            StringBuilder builder = new StringBuilder();
            builder.append("BarycentricTarget [keplerId=");
            builder.append(keplerId);
            builder.append(", longCadenceReference=");
            builder.append(longCadenceReference);
            builder.append(", ra=");
            builder.append(ra);
            builder.append(", dec=");
            builder.append(dec);
            builder.append(", centerCcdRow=");
            builder.append(centerCcdRow);
            builder.append(", centerCcdCol=");
            builder.append(centerCcdCol);
            builder.append("]");
            return builder.toString();
        }

        public int getKeplerId() {
            return keplerId;
        }
        public double getCenterCcdRow() {
            return centerCcdRow;
        }
        public double getCenterCcdCol() {
            return centerCcdCol;
        }
       

        public int getLongCadenceReference() {
            return longCadenceReference;
        }

        public double getRa() {
            return ra;
        }

        public double getDec() {
            return dec;
        }

    }

}
