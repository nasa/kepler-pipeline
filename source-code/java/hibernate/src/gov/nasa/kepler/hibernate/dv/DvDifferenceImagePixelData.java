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
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlAttribute;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * A difference image result consisting of various flux values and differences
 * for a single pixel.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "DV_DIFF_IMG_PIXEL_DATA")
@XmlType
public class DvDifferenceImagePixelData {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_DIFF_IMG_PIXEL_DATA_SEQ")
    @Column(nullable = false)
    private long id;

    @XmlAttribute
    private int ccdRow;

    @XmlAttribute
    private int ccdColumn;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_FLUX_IN_TRANSIT_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_FLUX_IN_TRANSIT_UNCERT")) })
    @XmlElement
    private DvQuantity meanFluxInTransit;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_FLUX_OUT_TRANSIT_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_FLUX_OUT_TRANSIT_UNCERT")) })
    @XmlElement
    private DvQuantity meanFluxOutOfTransit;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_FLUX_DIFFERENCE_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_FLUX_DIFFERENCE_UNCERT")) })
    @XmlElement
    private DvQuantity meanFluxDifference;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "MEAN_FLUX_TARGET_TABLE_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "MEAN_FLUX_TARGET_TABLE_UNCERT")) })
    @XmlElement
    private DvQuantity meanFluxForTargetTable;

    /**
     * Creates a {@link DvDifferenceImagePixelData} object. For use only by mock
     * objects and Hibernate.
     */
    DvDifferenceImagePixelData() {
    }

    /**
     * Creates a {@link DvDifferenceImagePixelData} object with the given
     * values.
     */
    public DvDifferenceImagePixelData(int ccdRow, int ccdColumn,
        DvQuantity meanFluxInTransit, DvQuantity meanFluxOutOfTransit,
        DvQuantity meanFluxDifference, DvQuantity meanFluxForTargetTable) {

        this.ccdRow = ccdRow;
        this.ccdColumn = ccdColumn;
        this.meanFluxInTransit = meanFluxInTransit;
        this.meanFluxOutOfTransit = meanFluxOutOfTransit;
        this.meanFluxDifference = meanFluxDifference;
        this.meanFluxForTargetTable = meanFluxForTargetTable;
    }

    public int getCcdRow() {
        return ccdRow;
    }

    public int getCcdColumn() {
        return ccdColumn;
    }

    public DvQuantity getMeanFluxInTransit() {
        return meanFluxInTransit;
    }

    public DvQuantity getMeanFluxOutOfTransit() {
        return meanFluxOutOfTransit;
    }

    public DvQuantity getMeanFluxDifference() {
        return meanFluxDifference;
    }

    public DvQuantity getMeanFluxForTargetTable() {
        return meanFluxForTargetTable;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ccdColumn;
        result = prime * result + ccdRow;
        result = prime * result
            + (meanFluxDifference == null ? 0 : meanFluxDifference.hashCode());
        result = prime
            * result
            + (meanFluxForTargetTable == null ? 0
                : meanFluxForTargetTable.hashCode());
        result = prime * result
            + (meanFluxInTransit == null ? 0 : meanFluxInTransit.hashCode());
        result = prime
            * result
            + (meanFluxOutOfTransit == null ? 0
                : meanFluxOutOfTransit.hashCode());
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
        if (!(obj instanceof DvDifferenceImagePixelData)) {
            return false;
        }
        DvDifferenceImagePixelData other = (DvDifferenceImagePixelData) obj;
        if (ccdColumn != other.ccdColumn) {
            return false;
        }
        if (ccdRow != other.ccdRow) {
            return false;
        }
        if (meanFluxDifference == null) {
            if (other.meanFluxDifference != null) {
                return false;
            }
        } else if (!meanFluxDifference.equals(other.meanFluxDifference)) {
            return false;
        }
        if (meanFluxForTargetTable == null) {
            if (other.meanFluxForTargetTable != null) {
                return false;
            }
        } else if (!meanFluxForTargetTable.equals(other.meanFluxForTargetTable)) {
            return false;
        }
        if (meanFluxInTransit == null) {
            if (other.meanFluxInTransit != null) {
                return false;
            }
        } else if (!meanFluxInTransit.equals(other.meanFluxInTransit)) {
            return false;
        }
        if (meanFluxOutOfTransit == null) {
            if (other.meanFluxOutOfTransit != null) {
                return false;
            }
        } else if (!meanFluxOutOfTransit.equals(other.meanFluxOutOfTransit)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ReflectionToStringBuilder(this).toString();
    }
}
