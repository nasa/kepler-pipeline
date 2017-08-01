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
 * 
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvCentroidOffsets {

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "COLUMN_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "COLUMN_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity columnOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "DEC_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "DEC_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity decOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "FOCALPLANE_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "FOCALPLANE_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity focalPlaneOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "RA_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "RA_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity raOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "ROW_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "ROW_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity rowOffset;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "SKY_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SKY_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity skyOffset;

    /**
     * Creates a {@link DvCentroidOffsets}. For use only by mock objects and
     * Hibernate.
     */
    public DvCentroidOffsets() {
    }

    /**
     * Creates a {@link DvCentroidOffsets} with the given values.
     * 
     * @throws NullPointerException if any of the parameters {@code null}
     */
    public DvCentroidOffsets(DvQuantity columnOffset, DvQuantity decOffset,
        DvQuantity focalPlaneOffset, DvQuantity raOffset, DvQuantity rowOffset,
        DvQuantity skyOffset) {

        if (columnOffset == null) {
            throw new NullPointerException("columnOffset can't be null");
        }
        if (decOffset == null) {
            throw new NullPointerException("decOffset can't be null");
        }
        if (focalPlaneOffset == null) {
            throw new NullPointerException("focalPlaneOffset can't be null");
        }
        if (raOffset == null) {
            throw new NullPointerException("raOffset can't be null");
        }
        if (rowOffset == null) {
            throw new NullPointerException("rowOffset can't be null");
        }
        if (skyOffset == null) {
            throw new NullPointerException("skyOffset can't be null");
        }

        this.columnOffset = columnOffset;
        this.decOffset = decOffset;
        this.focalPlaneOffset = focalPlaneOffset;
        this.raOffset = raOffset;
        this.rowOffset = rowOffset;
        this.skyOffset = skyOffset;
    }

    public DvQuantity getColumnOffset() {
        return columnOffset;
    }

    public DvQuantity getDecOffset() {
        return decOffset;
    }

    public DvQuantity getFocalPlaneOffset() {
        return focalPlaneOffset;
    }

    public DvQuantity getRaOffset() {
        return raOffset;
    }

    public DvQuantity getRowOffset() {
        return rowOffset;
    }

    public DvQuantity getSkyOffset() {
        return skyOffset;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result
            + (columnOffset == null ? 0 : columnOffset.hashCode());
        result = prime * result
            + (decOffset == null ? 0 : decOffset.hashCode());
        result = prime * result
            + (focalPlaneOffset == null ? 0 : focalPlaneOffset.hashCode());
        result = prime * result + (raOffset == null ? 0 : raOffset.hashCode());
        result = prime * result
            + (rowOffset == null ? 0 : rowOffset.hashCode());
        result = prime * result
            + (skyOffset == null ? 0 : skyOffset.hashCode());
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
        if (!(obj instanceof DvCentroidOffsets)) {
            return false;
        }
        DvCentroidOffsets other = (DvCentroidOffsets) obj;
        if (columnOffset == null) {
            if (other.columnOffset != null) {
                return false;
            }
        } else if (!columnOffset.equals(other.columnOffset)) {
            return false;
        }
        if (decOffset == null) {
            if (other.decOffset != null) {
                return false;
            }
        } else if (!decOffset.equals(other.decOffset)) {
            return false;
        }
        if (focalPlaneOffset == null) {
            if (other.focalPlaneOffset != null) {
                return false;
            }
        } else if (!focalPlaneOffset.equals(other.focalPlaneOffset)) {
            return false;
        }
        if (raOffset == null) {
            if (other.raOffset != null) {
                return false;
            }
        } else if (!raOffset.equals(other.raOffset)) {
            return false;
        }
        if (rowOffset == null) {
            if (other.rowOffset != null) {
                return false;
            }
        } else if (!rowOffset.equals(other.rowOffset)) {
            return false;
        }
        if (skyOffset == null) {
            if (other.skyOffset != null) {
                return false;
            }
        } else if (!skyOffset.equals(other.skyOffset)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
