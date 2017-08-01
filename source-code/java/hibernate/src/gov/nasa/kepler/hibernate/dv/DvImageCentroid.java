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
public class DvImageCentroid {

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "COLUMN_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "COLUMN_UNCERT")) })
    @XmlElement
    private DvQuantity column;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "DEC_DEGREES_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "DEC_DEGREES_UNCERT")) })
    @XmlElement
    private DvDoubleQuantity decDegrees;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "RA_HOURS_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "RA_HOURS_UNCERT")) })
    @XmlElement
    private DvDoubleQuantity raHours;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "value", column = @Column(name = "ROW_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "ROW_UNCERT")) })
    @XmlElement
    private DvQuantity row;

    /**
     * Creates a {@link DvImageCentroid}. For use only by mock objects and
     * Hibernate.
     */
    DvImageCentroid() {
    }

    /**
     * Creates a {@link DvImageCentroid} with the given values.
     * 
     * @throws NullPointerException if any of the parameters {@code null}
     */
    public DvImageCentroid(DvQuantity column, DvDoubleQuantity decDegrees,
        DvDoubleQuantity raHours, DvQuantity row) {

        if (column == null) {
            throw new NullPointerException("column can't be null");
        }
        if (decDegrees == null) {
            throw new NullPointerException("decDegrees can't be null");
        }
        if (raHours == null) {
            throw new NullPointerException("raHours can't be null");
        }
        if (row == null) {
            throw new NullPointerException("row can't be null");
        }

        this.column = column;
        this.decDegrees = decDegrees;
        this.raHours = raHours;
        this.row = row;
    }

    public DvQuantity getColumn() {
        return column;
    }

    public DvDoubleQuantity getDecDegrees() {
        return decDegrees;
    }

    public DvDoubleQuantity getRaHours() {
        return raHours;
    }

    public DvQuantity getRow() {
        return row;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (column == null ? 0 : column.hashCode());
        result = prime * result
            + (decDegrees == null ? 0 : decDegrees.hashCode());
        result = prime * result + (raHours == null ? 0 : raHours.hashCode());
        result = prime * result + (row == null ? 0 : row.hashCode());
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
        if (!(obj instanceof DvImageCentroid)) {
            return false;
        }
        DvImageCentroid other = (DvImageCentroid) obj;
        if (column == null) {
            if (other.column != null) {
                return false;
            }
        } else if (!column.equals(other.column)) {
            return false;
        }
        if (decDegrees == null) {
            if (other.decDegrees != null) {
                return false;
            }
        } else if (!decDegrees.equals(other.decDegrees)) {
            return false;
        }
        if (raHours == null) {
            if (other.raHours != null) {
                return false;
            }
        } else if (!raHours.equals(other.raHours)) {
            return false;
        }
        if (row == null) {
            if (other.row != null) {
                return false;
            }
        } else if (!row.equals(other.row)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
