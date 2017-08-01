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

import java.util.ArrayList;
import java.util.List;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.Fetch;
import org.hibernate.annotations.FetchMode;
import org.hibernate.annotations.IndexColumn;

/**
 * Difference image results consisting of various flux values and differences
 * per pixel per target table.
 * 
 * @author Bill Wohler
 */
@Entity
@Table(name = "DV_DIFF_IMG_RESULTS")
@XmlType
public class DvDifferenceImageResults extends DvAbstractTargetTableData {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_DIFF_IMG_SEQ")
    @Column(nullable = false)
    private long id;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "rowOffset.value", column = @Column(name = "CNTRL_CNTRD_ROW_OFF_VAL")),
        @AttributeOverride(name = "rowOffset.uncertainty", column = @Column(name = "CNTRL_CNTRD_ROW_OFF_UNCERT")),
        @AttributeOverride(name = "columnOffset.value", column = @Column(name = "CNTRL_CNTRD_COL_OFF_VAL")),
        @AttributeOverride(name = "columnOffset.uncertainty", column = @Column(name = "CNTRL_CNTRD_COL_OFF_UNCERT")),
        @AttributeOverride(name = "focalPlaneOffset.value", column = @Column(name = "CNTRL_CNTRD_FP_OFF_VAL")),
        @AttributeOverride(name = "focalPlaneOffset.uncertainty", column = @Column(name = "CNTRL_CNTRD_FP_OFF_UNCERT")),
        @AttributeOverride(name = "raOffset.value", column = @Column(name = "CNTRL_CNTRD_RA_OFF_VAL")),
        @AttributeOverride(name = "raOffset.uncertainty", column = @Column(name = "CNTRL_CNTRD_RA_OFF_UNCERT")),
        @AttributeOverride(name = "decOffset.value", column = @Column(name = "CNTRL_CNTRD_DEC_OFF_VAL")),
        @AttributeOverride(name = "decOffset.uncertainty", column = @Column(name = "CNTRL_CNTRD_DEC_OFF_UNCERT")),
        @AttributeOverride(name = "skyOffset.value", column = @Column(name = "CNTRL_CNTRD_SKY_OFF_VAL")),
        @AttributeOverride(name = "skyOffset.uncertainty", column = @Column(name = "CNTRL_CNTRD_SKY_OFF_UNCERT")) })
    @XmlElement
    private DvCentroidOffsets controlCentroidOffsets;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "column.value", column = @Column(name = "CNTRL_IMG_COLUMN_VAL")),
        @AttributeOverride(name = "column.uncertainty", column = @Column(name = "CNTRL_IMG_COLUMN_UNCERT")),
        @AttributeOverride(name = "decDegrees.value", column = @Column(name = "CNTRL_IMG_DEC_DEGREES_VAL")),
        @AttributeOverride(name = "decDegrees.uncertainty", column = @Column(name = "CNTRL_IMG_DEC_DEGREES_UNCERT")),
        @AttributeOverride(name = "raHours.value", column = @Column(name = "CNTRL_IMG_RA_HOURS_VAL")),
        @AttributeOverride(name = "raHours.uncertainty", column = @Column(name = "CNTRL_IMG_RA_HOURS_UNCERT")),
        @AttributeOverride(name = "row.value", column = @Column(name = "CNTRL_IMG_ROW_VAL")),
        @AttributeOverride(name = "row.uncertainty", column = @Column(name = "CNTRL_IMG_ROW_UNCERT")) })
    @XmlElement
    private DvImageCentroid controlImageCentroid;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "column.value", column = @Column(name = "DIFF_IMG_COLUMN_VAL")),
        @AttributeOverride(name = "column.uncertainty", column = @Column(name = "DIFF_IMG_COLUMN_UNCERT")),
        @AttributeOverride(name = "decDegrees.value", column = @Column(name = "DIFF_IMG_DEC_DEGREES_VAL")),
        @AttributeOverride(name = "decDegrees.uncertainty", column = @Column(name = "DIFF_IMG_DEC_DEGREES_UNCERT")),
        @AttributeOverride(name = "raHours.value", column = @Column(name = "DIFF_IMG_RA_HOURS_VAL")),
        @AttributeOverride(name = "raHours.uncertainty", column = @Column(name = "DIFF_IMG_RA_HOURS_UNCERT")),
        @AttributeOverride(name = "row.value", column = @Column(name = "DIFF_IMG_ROW_VAL")),
        @AttributeOverride(name = "row.uncertainty", column = @Column(name = "DIFF_IMG_ROW_UNCERT")) })
    @XmlElement
    private DvImageCentroid differenceImageCentroid;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "rowOffset.value", column = @Column(name = "KIC_CNTRD_ROW_OFF_VAL")),
        @AttributeOverride(name = "rowOffset.uncertainty", column = @Column(name = "KIC_CNTRD_ROW_OFF_UNCERT")),
        @AttributeOverride(name = "columnOffset.value", column = @Column(name = "KIC_CNTRD_COL_OFF_VAL")),
        @AttributeOverride(name = "columnOffset.uncertainty", column = @Column(name = "KIC_CNTRD_COL_OFF_UNCERT")),
        @AttributeOverride(name = "focalPlaneOffset.value", column = @Column(name = "KIC_CNTRD_FP_OFF_VAL")),
        @AttributeOverride(name = "focalPlaneOffset.uncertainty", column = @Column(name = "KIC_CNTRD_FP_OFF_UNCERT")),
        @AttributeOverride(name = "raOffset.value", column = @Column(name = "KIC_CNTRD_RA_OFF_VAL")),
        @AttributeOverride(name = "raOffset.uncertainty", column = @Column(name = "KIC_CNTRD_RA_OFF_UNCERT")),
        @AttributeOverride(name = "decOffset.value", column = @Column(name = "KIC_CNTRD_DEC_OFF_VAL")),
        @AttributeOverride(name = "decOffset.uncertainty", column = @Column(name = "KIC_CNTRD_DEC_OFF_UNCERT")),
        @AttributeOverride(name = "skyOffset.value", column = @Column(name = "KIC_CNTRD_SKY_OFF_VAL")),
        @AttributeOverride(name = "skyOffset.uncertainty", column = @Column(name = "KIC_CNTRD_SKY_OFF_UNCERT")) })
    @XmlElement
    private DvCentroidOffsets kicCentroidOffsets;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "column.value", column = @Column(name = "KIC_REF_COLUMN_VAL")),
        @AttributeOverride(name = "column.uncertainty", column = @Column(name = "KIC_REF_COLUMN_UNCERT")),
        @AttributeOverride(name = "decDegrees.value", column = @Column(name = "KIC_REF_DEC_DEGREES_VAL")),
        @AttributeOverride(name = "decDegrees.uncertainty", column = @Column(name = "KIC_REF_DEC_DEGREES_UNCERT")),
        @AttributeOverride(name = "raHours.value", column = @Column(name = "KIC_REF_RA_HOURS_VAL")),
        @AttributeOverride(name = "raHours.uncertainty", column = @Column(name = "KIC_REF_RA_HOURS_UNCERT")),
        @AttributeOverride(name = "row.value", column = @Column(name = "KIC_REF_ROW_VAL")),
        @AttributeOverride(name = "row.uncertainty", column = @Column(name = "KIC_REF_ROW_UNCERT")) })
    @XmlElement
    private DvImageCentroid kicReferenceCentroid;

    @Column(name = "TRANSITS")
    @XmlElement
    private int numberOfTransits;

    @Column(name = "CADENCES_IN_TRANSIT")
    @XmlElement
    private int numberOfCadencesInTransit;

    @Column(name = "CADENCE_GAPS_IN_TRANSIT")
    @XmlElement
    private int numberOfCadenceGapsInTransit;

    @Column(name = "CADENCES_OUT_OF_TRANSIT")
    @XmlElement
    private int numberOfCadencesOutOfTransit;

    @Column(name = "CADENCE_GAPS_OUT_OF_TRANSIT")
    @XmlElement
    private int numberOfCadenceGapsOutOfTransit;
    
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "attempted", column = @Column(name = "QUALITY_METRIC_ATTEMPTED")),
        @AttributeOverride(name = "valid", column = @Column(name = "QUALITY_METRIC_VALID")),
        @AttributeOverride(name = "value", column = @Column(name = "QUALITY_METRIC_VALUE")) })
    @XmlElement
    private DvQualityMetric qualityMetric;
    
    @XmlElement
    private boolean overlappedTransits;

    @OneToMany(fetch = FetchType.EAGER)
    @Fetch(value = FetchMode.SUBSELECT)
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_DIR_DIFF_IMG_PIXEL_DATA")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvDifferenceImagePixelData> differenceImagePixelData = new ArrayList<DvDifferenceImagePixelData>();

    /**
     * Creates a {@link DvDifferenceImageResults}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    DvDifferenceImageResults() {
    }

    /**
     * Creates a new {@link DvDifferenceImageResults} from the given parameters.
     */
    public DvDifferenceImageResults(Builder builder) {
        super(builder);
        id = builder.id;
        controlCentroidOffsets = builder.controlCentroidOffsets;
        controlImageCentroid = builder.controlImageCentroid;
        differenceImageCentroid = builder.differenceImageCentroid;
        kicCentroidOffsets = builder.kicCentroidOffsets;
        kicReferenceCentroid = builder.kicReferenceCentroid;
        numberOfTransits = builder.numberOfTransits;
        numberOfCadencesInTransit = builder.numberOfCadencesInTransit;
        numberOfCadenceGapsInTransit = builder.numberOfCadenceGapsInTransit;
        numberOfCadencesOutOfTransit = builder.numberOfCadencesOutOfTransit;
        numberOfCadenceGapsOutOfTransit = builder.numberOfCadenceGapsOutOfTransit;
        differenceImagePixelData = builder.differenceImagePixelData;
        qualityMetric = builder.qualityMetric;
        overlappedTransits = builder.overlappedTransits;
    }

    /**
     * Used to construct a {@link DvDifferenceImageResults} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvDifferenceImageResults} object is created
     * using the build method. For example:
     * 
     * <pre>
     * DvDifferenceImageResults differenceImageResults = new DvDifferenceImageResults(
     *     targetTableId).ccdModule(2)
     *     .ccdOutput(1)
     *     .differenceImagePixelData(differenceImagePixelData)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Bill Wohler
     */
    @XmlTransient
    public static class Builder extends DvAbstractTargetTableData.Builder {

        private long id;
        private DvCentroidOffsets controlCentroidOffsets;
        private DvImageCentroid controlImageCentroid;
        private DvImageCentroid differenceImageCentroid;
        private DvCentroidOffsets kicCentroidOffsets;
        private DvImageCentroid kicReferenceCentroid;
        private int numberOfTransits;
        private int numberOfCadencesInTransit;
        private int numberOfCadenceGapsInTransit;
        private int numberOfCadencesOutOfTransit;
        private int numberOfCadenceGapsOutOfTransit;
        private DvQualityMetric qualityMetric;
        private boolean overlappedTransits;
        private List<DvDifferenceImagePixelData> differenceImagePixelData;

        public Builder(int targetTableId) {
            super(targetTableId);
        }

        @Override
        public Builder ccdModule(int ccdModule) {
            super.ccdModule(ccdModule);
            return this;
        }

        @Override
        public Builder ccdOutput(int ccdOutput) {
            super.ccdOutput(ccdOutput);
            return this;
        }

        @Override
        public Builder quarter(int quarter) {
            super.quarter(quarter);
            return this;
        }

        @Override
        public Builder startCadence(int startCadence) {
            super.startCadence(startCadence);
            return this;
        }

        @Override
        public Builder endCadence(int endCadence) {
            super.endCadence(endCadence);
            return this;
        }

        /**
         * For use by tests only.
         */
        Builder id(long id) {
            this.id = id;
            return this;
        }

        public Builder controlCentroidOffsets(
            DvCentroidOffsets controlCentroidOffsets) {
            this.controlCentroidOffsets = controlCentroidOffsets;
            return this;
        }

        public Builder controlImageCentroid(DvImageCentroid controlImageCentroid) {
            this.controlImageCentroid = controlImageCentroid;
            return this;
        }

        public Builder differenceImageCentroid(
            DvImageCentroid differenceImageCentroid) {
            this.differenceImageCentroid = differenceImageCentroid;
            return this;
        }

        public Builder kicCentroidOffsets(DvCentroidOffsets kicCentroidOffsets) {
            this.kicCentroidOffsets = kicCentroidOffsets;
            return this;
        }

        public Builder kicReferenceCentroid(DvImageCentroid kicReferenceCentroid) {
            this.kicReferenceCentroid = kicReferenceCentroid;
            return this;
        }

        public Builder numberOfTransits(int numberOfTransits) {
            this.numberOfTransits = numberOfTransits;
            return this;
        }

        public Builder numberOfCadencesInTransit(int numberOfCadencesInTransit) {
            this.numberOfCadencesInTransit = numberOfCadencesInTransit;
            return this;
        }

        public Builder numberOfCadenceGapsInTransit(
            int numberOfCadenceGapsInTransit) {
            this.numberOfCadenceGapsInTransit = numberOfCadenceGapsInTransit;
            return this;
        }

        public Builder numberOfCadencesOutOfTransit(
            int numberOfCadencesOutOfTransit) {
            this.numberOfCadencesOutOfTransit = numberOfCadencesOutOfTransit;
            return this;
        }

        public Builder numberOfCadenceGapsOutOfTransit(
            int numberOfCadenceGapsOutOfTransit) {
            this.numberOfCadenceGapsOutOfTransit = numberOfCadenceGapsOutOfTransit;
            return this;
        }
        
        public Builder qualityMetric(DvQualityMetric qualityMetric) {
            this.qualityMetric = qualityMetric;
            return this;
        }
        
        public Builder overlappedTransits(boolean overlappedTransits) {
            this.overlappedTransits = overlappedTransits;
            return this;
        }

        public Builder differenceImagePixelData(
            List<DvDifferenceImagePixelData> differenceImagePixelData) {
            this.differenceImagePixelData = differenceImagePixelData;
            return this;
        }

        public DvDifferenceImageResults build() {
            return new DvDifferenceImageResults(this);
        }
    }

    public long getId() {
        return id;
    }

    public DvCentroidOffsets getControlCentroidOffsets() {
        return controlCentroidOffsets;
    }

    public DvImageCentroid getControlImageCentroid() {
        return controlImageCentroid;
    }

    public DvImageCentroid getDifferenceImageCentroid() {
        return differenceImageCentroid;
    }

    public DvCentroidOffsets getKicCentroidOffsets() {
        return kicCentroidOffsets;
    }

    public DvImageCentroid getKicReferenceCentroid() {
        return kicReferenceCentroid;
    }

    public int getNumberOfTransits() {
        return numberOfTransits;
    }

    public int getNumberOfCadencesInTransit() {
        return numberOfCadencesInTransit;
    }

    public int getNumberOfCadenceGapsInTransit() {
        return numberOfCadenceGapsInTransit;
    }

    public int getNumberOfCadencesOutOfTransit() {
        return numberOfCadencesOutOfTransit;
    }

    public int getNumberOfCadenceGapsOutOfTransit() {
        return numberOfCadenceGapsOutOfTransit;
    }

    public DvQualityMetric getQualityMetric() {
        return qualityMetric;
    }

    public boolean isOverlappedTransits() {
        return overlappedTransits;
    }

    public List<DvDifferenceImagePixelData> getDifferenceImagePixelData() {
        return differenceImagePixelData;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime
            * result
            + ((controlCentroidOffsets == null) ? 0
                : controlCentroidOffsets.hashCode());
        result = prime
            * result
            + ((controlImageCentroid == null) ? 0
                : controlImageCentroid.hashCode());
        result = prime
            * result
            + ((differenceImageCentroid == null) ? 0
                : differenceImageCentroid.hashCode());
        result = prime
            * result
            + ((differenceImagePixelData == null) ? 0
                : differenceImagePixelData.hashCode());
        result = prime
            * result
            + ((kicCentroidOffsets == null) ? 0 : kicCentroidOffsets.hashCode());
        result = prime
            * result
            + ((kicReferenceCentroid == null) ? 0
                : kicReferenceCentroid.hashCode());
        result = prime * result + numberOfCadenceGapsInTransit;
        result = prime * result + numberOfCadenceGapsOutOfTransit;
        result = prime * result + numberOfCadencesInTransit;
        result = prime * result + numberOfCadencesOutOfTransit;
        result = prime * result + numberOfTransits;
        result = prime * result + (overlappedTransits ? 1231 : 1237);
        result = prime * result
            + ((qualityMetric == null) ? 0 : qualityMetric.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (!(obj instanceof DvDifferenceImageResults))
            return false;
        DvDifferenceImageResults other = (DvDifferenceImageResults) obj;
        if (controlCentroidOffsets == null) {
            if (other.controlCentroidOffsets != null)
                return false;
        } else if (!controlCentroidOffsets.equals(other.controlCentroidOffsets))
            return false;
        if (controlImageCentroid == null) {
            if (other.controlImageCentroid != null)
                return false;
        } else if (!controlImageCentroid.equals(other.controlImageCentroid))
            return false;
        if (differenceImageCentroid == null) {
            if (other.differenceImageCentroid != null)
                return false;
        } else if (!differenceImageCentroid.equals(other.differenceImageCentroid))
            return false;
        if (differenceImagePixelData == null) {
            if (other.differenceImagePixelData != null)
                return false;
        } else if (!differenceImagePixelData.equals(other.differenceImagePixelData))
            return false;
        if (kicCentroidOffsets == null) {
            if (other.kicCentroidOffsets != null)
                return false;
        } else if (!kicCentroidOffsets.equals(other.kicCentroidOffsets))
            return false;
        if (kicReferenceCentroid == null) {
            if (other.kicReferenceCentroid != null)
                return false;
        } else if (!kicReferenceCentroid.equals(other.kicReferenceCentroid))
            return false;
        if (numberOfCadenceGapsInTransit != other.numberOfCadenceGapsInTransit)
            return false;
        if (numberOfCadenceGapsOutOfTransit != other.numberOfCadenceGapsOutOfTransit)
            return false;
        if (numberOfCadencesInTransit != other.numberOfCadencesInTransit)
            return false;
        if (numberOfCadencesOutOfTransit != other.numberOfCadencesOutOfTransit)
            return false;
        if (numberOfTransits != other.numberOfTransits)
            return false;
        if (overlappedTransits != other.overlappedTransits)
            return false;
        if (qualityMetric == null) {
            if (other.qualityMetric != null)
                return false;
        } else if (!qualityMetric.equals(other.qualityMetric))
            return false;
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).appendSuper("targetTableData")
            .append("controlCentroidOffsets", controlCentroidOffsets)
            .append("controlImageCentroid", controlImageCentroid)
            .append("differenceImageCentroid", differenceImageCentroid)
            .append("kicCentroidOffsets", kicCentroidOffsets)
            .append("kicReferenceCentroid", kicReferenceCentroid)
            .append("numberOfCadenceGapsInTransit",
                numberOfCadenceGapsInTransit)
            .append("numberOfCadenceGapsOutOfTransit",
                numberOfCadenceGapsOutOfTransit)
            .append("numberOfCadencesInTransit", numberOfCadencesInTransit)
            .append("numberOfCadencesOutOfTransit",
                numberOfCadencesOutOfTransit)
            .append("numberOfTransits", numberOfTransits)
            .append("qualityMetric", qualityMetric)
            .append("overlappedTransits", overlappedTransits)
            .append("differenceImagePixelData", differenceImagePixelData)
            .toString();
    }
}