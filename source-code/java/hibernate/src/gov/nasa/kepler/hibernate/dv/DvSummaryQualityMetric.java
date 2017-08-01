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

import javax.persistence.Embeddable;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * 
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvSummaryQualityMetric {

    @XmlAttribute
    private float fractionOfGoodMetrics;

    @XmlAttribute
    private int numberOfAttempts;

    @XmlAttribute
    private int numberOfGoodMetrics;

    @XmlAttribute
    private int numberOfMetrics;

    @XmlAttribute
    private float qualityThreshold;

    public DvSummaryQualityMetric() {

    }

    public DvSummaryQualityMetric(float fractionOfGoodMetrics,
        int numberOfAttempts, int numberOfGoodMetrics, int numberOfMetrics,
        float qualityThreshold) {
        this.fractionOfGoodMetrics = fractionOfGoodMetrics;
        this.numberOfAttempts = numberOfAttempts;
        this.numberOfGoodMetrics = numberOfGoodMetrics;
        this.numberOfMetrics = numberOfMetrics;
        this.qualityThreshold = qualityThreshold;
    }

    public float getFractionOfGoodMetrics() {
        return fractionOfGoodMetrics;
    }

    public int getNumberOfAttempts() {
        return numberOfAttempts;
    }

    public int getNumberOfGoodMetrics() {
        return numberOfGoodMetrics;
    }

    public int getNumberOfMetrics() {
        return numberOfMetrics;
    }

    public float getQualityThreshold() {
        return qualityThreshold;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + Float.floatToIntBits(fractionOfGoodMetrics);
        result = prime * result + numberOfAttempts;
        result = prime * result + numberOfGoodMetrics;
        result = prime * result + numberOfMetrics;
        result = prime * result + Float.floatToIntBits(qualityThreshold);
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
        if (!(obj instanceof DvSummaryQualityMetric)) {
            return false;
        }
        DvSummaryQualityMetric other = (DvSummaryQualityMetric) obj;
        if (Float.floatToIntBits(fractionOfGoodMetrics) != Float.floatToIntBits(other.fractionOfGoodMetrics)) {
            return false;
        }
        if (numberOfAttempts != other.numberOfAttempts) {
            return false;
        }
        if (numberOfGoodMetrics != other.numberOfGoodMetrics) {
            return false;
        }
        if (numberOfMetrics != other.numberOfMetrics) {
            return false;
        }
        if (Float.floatToIntBits(qualityThreshold) != Float.floatToIntBits(other.qualityThreshold)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
