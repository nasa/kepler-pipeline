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

package gov.nasa.kepler.mc.cm;

import gov.nasa.spiffy.common.persistable.Persistable;

/**
 * Target parameter from the KIC including optional uncertainties.
 * 
 * @author Bill Wohler
 * @author Miles Cote
 * 
 */
public class CelestialObjectParameter implements Persistable {

    private double value = Double.NaN;
    private double uncertainty = Double.NaN;
    private String provenance = "";

    public CelestialObjectParameter() {
    }

    private CelestialObjectParameter(Number value) {
        if (value != null) {
            this.value = value.doubleValue();
        }
    }

    /**
     * @param value is primitive because if there is an uncertainty, then the
     * value is not allowed to be null.
     * @param uncertainty the uncertainty
     */
    private CelestialObjectParameter(double value, Number uncertainty) {
        this(value);

        if (uncertainty != null) {
            this.uncertainty = uncertainty.doubleValue();
        }
    }

    public CelestialObjectParameter(String provenance, double value) {
        this(value);

        if (provenance != null) {
            this.provenance = provenance;
        }
    }

    public CelestialObjectParameter(String provenance, Number value) {
        this(value);

        if (provenance != null) {
            this.provenance = provenance;
        }
    }

    public CelestialObjectParameter(String provenance, double value, Number uncertainty) {
        this(value, uncertainty);

        if (provenance != null) {
            this.provenance = provenance;
        }
    }

    public String getProvenance() {
        return provenance;
    }

    public double getValue() {
        return value;
    }

    public double getUncertainty() {
        return uncertainty;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (provenance == null ? 0 : provenance.hashCode());
        long temp;
        temp = Double.doubleToLongBits(uncertainty);
        result = prime * result + (int) (temp ^ temp >>> 32);
        temp = Double.doubleToLongBits(value);
        result = prime * result + (int) (temp ^ temp >>> 32);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (!(obj instanceof CelestialObjectParameter)) {
            return false;
        }
        CelestialObjectParameter other = (CelestialObjectParameter) obj;
        if (provenance == null) {
            if (other.provenance != null) {
                return false;
            }
        } else if (!provenance.equals(other.provenance)) {
            return false;
        }
        if (Double.doubleToLongBits(uncertainty) != Double.doubleToLongBits(other.uncertainty)) {
            return false;
        }
        if (Double.doubleToLongBits(value) != Double.doubleToLongBits(other.value)) {
            return false;
        }
        return true;
    }

}
