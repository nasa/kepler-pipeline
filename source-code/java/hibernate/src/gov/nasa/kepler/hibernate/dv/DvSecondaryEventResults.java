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
public class DvSecondaryEventResults {

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "geometricAlbedo.value", column = @Column(name = "PLANET_PARAMS_GEO_ALBEDO_VAL")),
        @AttributeOverride(name = "geometricAlbedo.uncertainty", column = @Column(name = "PLANET_PARAMS_GEO_ALBEDO_UNC")),
        @AttributeOverride(name = "planetEffectiveTemp.value", column = @Column(name = "PLANET_PARAMS_EFFECT_TEMP_VAL")),
        @AttributeOverride(name = "planetEffectiveTemp.uncertainty", column = @Column(name = "PLANET_PARAMS_EFFECT_TEMP_UNC")) })
    @XmlElement
    private DvPlanetParameters planetParameters = new DvPlanetParameters();

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "albedoComparisonStatistic.value", column = @Column(name = "COMP_TESTS_ALBEDO_COMP_VAL")),
        @AttributeOverride(name = "albedoComparisonStatistic.significance", column = @Column(name = "COMP_TESTS_ALBEDO_COMP_UNC")),
        @AttributeOverride(name = "tempComparisonStatistic.value", column = @Column(name = "COMP_TESTS_TEMP_COMP_VAL")),
        @AttributeOverride(name = "tempComparisonStatistic.significance", column = @Column(name = "COMP_TESTS_TEMP_COMP_UNC")) })
    @XmlElement
    private DvComparisonTests comparisonTests = new DvComparisonTests();

    DvSecondaryEventResults() {
    }

    public DvSecondaryEventResults(DvPlanetParameters planetParameters,
        DvComparisonTests comparisonTests) {
        this.planetParameters = planetParameters;
        this.comparisonTests = comparisonTests;
    }

    public DvPlanetParameters getPlanetParameters() {
        return planetParameters;
    }

    public DvComparisonTests getComparisonTests() {
        return comparisonTests;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + ((comparisonTests == null) ? 0 : comparisonTests.hashCode());
        result = prime * result
            + ((planetParameters == null) ? 0 : planetParameters.hashCode());
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
        if (!(obj instanceof DvSecondaryEventResults)) {
            return false;
        }
        DvSecondaryEventResults other = (DvSecondaryEventResults) obj;
        if (comparisonTests == null) {
            if (other.comparisonTests != null) {
                return false;
            }
        } else if (!comparisonTests.equals(other.comparisonTests)) {
            return false;
        }
        if (planetParameters == null) {
            if (other.planetParameters != null) {
                return false;
            }
        } else if (!planetParameters.equals(other.planetParameters)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "DvSecondaryEventResults [planetParameters=" + planetParameters
            + ", comparisonTests=" + comparisonTests + "]";
    }
}
