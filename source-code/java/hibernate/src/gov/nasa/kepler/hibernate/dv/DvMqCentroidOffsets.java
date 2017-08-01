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

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Multi-quarter centroid offsets.
 * 
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvMqCentroidOffsets {

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_DEC_OFFSET_UNC")) })
    @XmlElement
    private DvQuantity meanDecOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_RA_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_RA_OFFSET_UNC")) })
    @XmlElement
    private DvQuantity meanRaOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_SKY_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_SKY_OFFSET_UNC")) })
    @XmlElement
    private DvQuantity meanSkyOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SINGLE_FIT_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SINGLE_FIT_DEC_OFFSET_UNC")) })
    @XmlElement
    private DvQuantity singleFitDecOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SINGLE_FIT_RA_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SINGLE_FIT_RA_OFFSET_UNC")) })
    @XmlElement
    private DvQuantity singleFitRaOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SINGLE_FIT_SKY_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SINGLE_FIT_SKY_OFFSET_UNC")) })
    @XmlElement
    private DvQuantity singleFitSkyOffset;

    public DvMqCentroidOffsets() {
    }

    public DvMqCentroidOffsets(DvQuantity meanDecOffset,
        DvQuantity meanRaOffset, DvQuantity meanSkyOffset,
        DvQuantity singleFitDecOffset, DvQuantity singleFitRaOffset,
        DvQuantity singleFitSkyOffset) {

        this.meanDecOffset = meanDecOffset;
        this.meanRaOffset = meanRaOffset;
        this.meanSkyOffset = meanSkyOffset;
        this.singleFitDecOffset = singleFitDecOffset;
        this.singleFitRaOffset = singleFitRaOffset;
        this.singleFitSkyOffset = singleFitSkyOffset;
    }

    public DvQuantity getMeanDecOffset() {
        return meanDecOffset;
    }

    public DvQuantity getMeanRaOffset() {
        return meanRaOffset;
    }

    public DvQuantity getMeanSkyOffset() {
        return meanSkyOffset;
    }

    public DvQuantity getSingleFitDecOffset() {
        return singleFitDecOffset;
    }

    public DvQuantity getSingleFitRaOffset() {
        return singleFitRaOffset;
    }

    public DvQuantity getSingleFitSkyOffset() {
        return singleFitSkyOffset;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (meanDecOffset == null ? 0 : meanDecOffset.hashCode());
        result = prime * result
            + (meanRaOffset == null ? 0 : meanRaOffset.hashCode());
        result = prime * result
            + (meanSkyOffset == null ? 0 : meanSkyOffset.hashCode());
        result = prime * result
            + (singleFitDecOffset == null ? 0 : singleFitDecOffset.hashCode());
        result = prime * result
            + (singleFitRaOffset == null ? 0 : singleFitRaOffset.hashCode());
        result = prime * result
            + (singleFitSkyOffset == null ? 0 : singleFitSkyOffset.hashCode());
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
        if (!(obj instanceof DvMqCentroidOffsets)) {
            return false;
        }
        DvMqCentroidOffsets other = (DvMqCentroidOffsets) obj;
        if (meanDecOffset == null) {
            if (other.meanDecOffset != null) {
                return false;
            }
        } else if (!meanDecOffset.equals(other.meanDecOffset)) {
            return false;
        }
        if (meanRaOffset == null) {
            if (other.meanRaOffset != null) {
                return false;
            }
        } else if (!meanRaOffset.equals(other.meanRaOffset)) {
            return false;
        }
        if (meanSkyOffset == null) {
            if (other.meanSkyOffset != null) {
                return false;
            }
        } else if (!meanSkyOffset.equals(other.meanSkyOffset)) {
            return false;
        }
        if (singleFitDecOffset == null) {
            if (other.singleFitDecOffset != null) {
                return false;
            }
        } else if (!singleFitDecOffset.equals(other.singleFitDecOffset)) {
            return false;
        }
        if (singleFitRaOffset == null) {
            if (other.singleFitRaOffset != null) {
                return false;
            }
        } else if (!singleFitRaOffset.equals(other.singleFitRaOffset)) {
            return false;
        }
        if (singleFitSkyOffset == null) {
            if (other.singleFitSkyOffset != null) {
                return false;
            }
        } else if (!singleFitSkyOffset.equals(other.singleFitSkyOffset)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
