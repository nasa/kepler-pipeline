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

package gov.nasa.kepler.hibernate.dv;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embeddable;
import javax.persistence.Embedded;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * 
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvPlanetParameters {

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "GEOMETRIC_ALBEDO_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "GEOMETRIC_ALBEDO_UNCERT")) })
    @XmlElement
    private DvQuantity geometricAlbedo = new DvQuantity();

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "PLANET_EFFECTIVE_TEMP_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "PLANET_EFFECTIVE_TEMP_UNCERT")) })
    @XmlElement
    private DvQuantity planetEffectiveTemp = new DvQuantity();

    DvPlanetParameters() {
    }

    public DvPlanetParameters(DvQuantity geometricAlbedo,
        DvQuantity planetEffectiveTemp) {

        if (geometricAlbedo == null) {
            throw new NullPointerException("geometricAlbedo can't be null");
        }
        if (planetEffectiveTemp == null) {
            throw new NullPointerException("planetEffectiveTemp can't be null");
        }

        this.geometricAlbedo = geometricAlbedo;
        this.planetEffectiveTemp = planetEffectiveTemp;
    }

    public DvQuantity getGeometricAlbedo() {
        return geometricAlbedo;
    }

    public DvQuantity getPlanetEffectiveTemp() {
        return planetEffectiveTemp;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((geometricAlbedo == null) ? 0 : geometricAlbedo.hashCode());
        result = prime
            * result
            + ((planetEffectiveTemp == null) ? 0
                : planetEffectiveTemp.hashCode());
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
        if (!(obj instanceof DvPlanetParameters)) {
            return false;
        }
        DvPlanetParameters other = (DvPlanetParameters) obj;
        if (geometricAlbedo == null) {
            if (other.geometricAlbedo != null) {
                return false;
            }
        } else if (!geometricAlbedo.equals(other.geometricAlbedo)) {
            return false;
        }
        if (planetEffectiveTemp == null) {
            if (other.planetEffectiveTemp != null) {
                return false;
            }
        } else if (!planetEffectiveTemp.equals(other.planetEffectiveTemp)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "DvPlanetParameters [geometricAlbedo=" + geometricAlbedo
            + ", planetEffectiveTemp=" + planetEffectiveTemp + "]";
    }
}
