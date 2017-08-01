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
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

/**
 * Store information on weak secondaries.
 * 
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvWeakSecondary {

    @XmlAttribute
    private float maxMesPhaseInDays;

    @XmlAttribute
    private float maxMes;

    @XmlAttribute
    private float minMesPhaseInDays;

    @XmlAttribute
    private float minMes;

    @XmlAttribute
    private float mesMad;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "WEAK_SECONDARY_DEPTHPPM_VALUE")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "WEAK_SECONDARY_DEPTHPPM_UNCERT")) })
    @XmlElement
    private DvQuantity depthPpm = new DvQuantity();

    @XmlAttribute
    private float medianMes;

    @XmlAttribute
    private int validPhaseCount;

    @Column(name = "WEAK_SECONDARY_ROBUST_STAT")
    @XmlAttribute
    private float robustStatistic;

    public DvWeakSecondary() {
    }

    public DvWeakSecondary(float maxMesPhaseInDays, float maxMes,
        float minMesPhaseInDays, float minMes, float mesMad,
        float depthPpmValue, float depthPpmUncertainty, float medianMes,
        int validPhaseCount, float robustStatistic) {
        this.maxMesPhaseInDays = maxMesPhaseInDays;
        this.maxMes = maxMes;
        this.minMesPhaseInDays = minMesPhaseInDays;
        this.minMes = minMes;
        this.mesMad = mesMad;
        this.medianMes = medianMes;
        this.validPhaseCount = validPhaseCount;
        this.robustStatistic = robustStatistic;
        depthPpm = new DvQuantity(depthPpmValue, depthPpmUncertainty);
    }

    public float getMaxMesPhaseInDays() {
        return maxMesPhaseInDays;
    }

    public float getMaxMes() {
        return maxMes;
    }

    public float getMinMesPhaseInDays() {
        return minMesPhaseInDays;
    }

    public float getMinMes() {
        return minMes;
    }

    public float getMesMad() {
        return mesMad;
    }

    public DvQuantity getDepthPpm() {
        return depthPpm;
    }

    public float getMedianMes() {
        return medianMes;
    }

    public int getValidPhaseCount() {
        return validPhaseCount;
    }

    public float getRobustStatistic() {
        return robustStatistic;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (depthPpm == null ? 0 : depthPpm.hashCode());
        result = prime * result + Float.floatToIntBits(maxMes);
        result = prime * result + Float.floatToIntBits(maxMesPhaseInDays);
        result = prime * result + Float.floatToIntBits(medianMes);
        result = prime * result + Float.floatToIntBits(mesMad);
        result = prime * result + Float.floatToIntBits(minMes);
        result = prime * result + Float.floatToIntBits(minMesPhaseInDays);
        result = prime * result + Float.floatToIntBits(robustStatistic);
        result = prime * result + validPhaseCount;
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
        if (!(obj instanceof DvWeakSecondary)) {
            return false;
        }
        DvWeakSecondary other = (DvWeakSecondary) obj;
        if (depthPpm == null) {
            if (other.depthPpm != null) {
                return false;
            }
        } else if (!depthPpm.equals(other.depthPpm)) {
            return false;
        }
        if (Float.floatToIntBits(maxMes) != Float.floatToIntBits(other.maxMes)) {
            return false;
        }
        if (Float.floatToIntBits(maxMesPhaseInDays) != Float.floatToIntBits(other.maxMesPhaseInDays)) {
            return false;
        }
        if (Float.floatToIntBits(medianMes) != Float.floatToIntBits(other.medianMes)) {
            return false;
        }
        if (Float.floatToIntBits(mesMad) != Float.floatToIntBits(other.mesMad)) {
            return false;
        }
        if (Float.floatToIntBits(minMes) != Float.floatToIntBits(other.minMes)) {
            return false;
        }
        if (Float.floatToIntBits(minMesPhaseInDays) != Float.floatToIntBits(other.minMesPhaseInDays)) {
            return false;
        }
        if (Float.floatToIntBits(robustStatistic) != Float.floatToIntBits(other.robustStatistic)) {
            return false;
        }
        if (validPhaseCount != other.validPhaseCount) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return "DvWeakSecondary [maxMesPhaseInDays=" + maxMesPhaseInDays
            + ", maxMes=" + maxMes + ", minMesPhaseInDays=" + minMesPhaseInDays
            + ", minMes=" + minMes + ", mesMad=" + mesMad + ", depthPpm.value="
            + depthPpm.getValue() + ", depthPpm.uncertainty="
            + depthPpm.getUncertainty() + ", medianMes=" + medianMes
            + ", validPhaseCount=" + validPhaseCount + ", robustStatistic="
            + robustStatistic + "]";
    }
}
