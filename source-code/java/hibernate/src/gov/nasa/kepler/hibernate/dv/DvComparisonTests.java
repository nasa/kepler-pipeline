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
public class DvComparisonTests {

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "ALBEDO_COMPARISON_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "ALBEDO_COMPARISON_SIG")) })
    @XmlElement
    private DvStatistic albedoComparisonStatistic = new DvStatistic();

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "TEMP_COMPARISON_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "TEMP_COMPARISON_SIG")) })
    @XmlElement
    private DvStatistic tempComparisonStatistic = new DvStatistic();

    DvComparisonTests() {
    }

    public DvComparisonTests(DvStatistic albedoComparisonStatistic,
        DvStatistic tempComparisonStatistic) {
        this.albedoComparisonStatistic = albedoComparisonStatistic;
        this.tempComparisonStatistic = tempComparisonStatistic;
    }

    public DvStatistic getAlbedoComparisonStatistic() {
        return albedoComparisonStatistic;
    }

    public DvStatistic getTempComparisonStatistic() {
        return tempComparisonStatistic;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + ((albedoComparisonStatistic == null) ? 0
                : albedoComparisonStatistic.hashCode());
        result = prime
            * result
            + ((tempComparisonStatistic == null) ? 0
                : tempComparisonStatistic.hashCode());
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
        if (!(obj instanceof DvComparisonTests)) {
            return false;
        }
        DvComparisonTests other = (DvComparisonTests) obj;
        if (albedoComparisonStatistic == null) {
            if (other.albedoComparisonStatistic != null) {
                return false;
            }
        } else if (!albedoComparisonStatistic.equals(other.albedoComparisonStatistic)) {
            return false;
        }
        if (tempComparisonStatistic == null) {
            if (other.tempComparisonStatistic != null) {
                return false;
            }
        } else if (!tempComparisonStatistic.equals(other.tempComparisonStatistic)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "DvComparisonTests [albedoComparisonStatistic="
            + albedoComparisonStatistic + ", tempComparisonStatistic="
            + tempComparisonStatistic + "]";
    }

}
