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
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlTransient;
import javax.xml.bind.annotation.XmlType;

import org.apache.commons.lang.builder.ToStringBuilder;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.CollectionOfElements;
import org.hibernate.annotations.IndexColumn;

/**
 * Pixel correlation statistics for a given planet and target table.
 * 
 * @author Forrest Girouard
 */
@Entity
@Table(name = "DV_PIXEL_CORREL_RESULTS")
@XmlType
public class DvPixelCorrelationResults extends DvAbstractTargetTableData {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "DV_PIXEL_CORREL_SEQ")
    @Column(nullable = false)
    private long id;

    @Embedded
    @AttributeOverrides( {
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
    @AttributeOverrides( {
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
    @AttributeOverrides( {
        @AttributeOverride(name = "column.value", column = @Column(name = "DIFF_IMG_COLUMN_VAL")),
        @AttributeOverride(name = "column.uncertainty", column = @Column(name = "DIFF_IMG_COLUMN_UNCERT")),
        @AttributeOverride(name = "decDegrees.value", column = @Column(name = "DIFF_IMG_DEC_DEGREES_VAL")),
        @AttributeOverride(name = "decDegrees.uncertainty", column = @Column(name = "DIFF_IMG_DEC_DEGREES_UNCERT")),
        @AttributeOverride(name = "raHours.value", column = @Column(name = "DIFF_IMG_RA_HOURS_VAL")),
        @AttributeOverride(name = "raHours.uncertainty", column = @Column(name = "DIFF_IMG_RA_HOURS_UNCERT")),
        @AttributeOverride(name = "row.value", column = @Column(name = "DIFF_IMG_ROW_VAL")),
        @AttributeOverride(name = "row.uncertainty", column = @Column(name = "DIFF_IMG_ROW_UNCERT")) })
    @XmlElement
    private DvImageCentroid correlationImageCentroid;

    @Embedded
    @AttributeOverrides( {
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
    @AttributeOverrides( {
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

    @CollectionOfElements
    @Cascade(CascadeType.ALL)
    @JoinTable(name = "DV_PCR_PIXEL_CORREL_STATS")
    @IndexColumn(name = "IDX")
    @XmlElement
    private List<DvPixelStatistic> pixelCorrelationStatistics = new ArrayList<DvPixelStatistic>();

    /**
     * Creates a {@link DvPixelCorrelationResults}. For use only by the inner
     * {@link Builder} class, mock objects, and Hibernate.
     */
    DvPixelCorrelationResults() {
    }

    /**
     * Creates a new {@link DvPixelCorrelationResults} from the given
     * parameters.
     */
    public DvPixelCorrelationResults(Builder builder) {

        super(builder);
        id = builder.id;
        controlCentroidOffsets = builder.controlCentroidOffsets;
        controlImageCentroid = builder.controlImageCentroid;
        correlationImageCentroid = builder.correlationImageCentroid;
        kicCentroidOffsets = builder.kicCentroidOffsets;
        kicReferenceCentroid = builder.kicReferenceCentroid;
        pixelCorrelationStatistics = builder.pixelCorrelationStatistics;
    }

    /**
     * Used to construct a {@link DvPixelCorrelationResults} object. To use this
     * class, a {@link Builder} object is created with the required parameter
     * pipelineTask. Then non-null fields are set using the available builder
     * methods. Finally, a {@link DvPixelCorrelationResults} object is created
     * using the build method. For example:
     * 
     * <pre>
     * DvPixelCorrelationResults pixelCorrelationResults = new DvPixelCorrelationResults(
     *     targetTableId).ccdModule(2)
     *     .ccdOutput(1)
     *     .pixelCorrelationStatistics(statistics)
     *     .build();
     * </pre>
     * 
     * This pattern is based upon <a href=
     * "http://developers.sun.com/learning/javaoneonline/2006/coreplatform/TS-1512.pdf"
     * > Josh Bloch's JavaOne 2006 talk, Effective Java Reloaded, TS-1512</a>.
     * 
     * @author Forrest Girouard
     */
    @XmlTransient
    public static class Builder extends DvAbstractTargetTableData.Builder {

        private long id;
        private DvCentroidOffsets controlCentroidOffsets;
        private DvImageCentroid controlImageCentroid;
        private DvImageCentroid correlationImageCentroid;
        private DvCentroidOffsets kicCentroidOffsets;
        private DvImageCentroid kicReferenceCentroid;
        private List<DvPixelStatistic> pixelCorrelationStatistics;

        /**
         * Creates a {@link Builder} object with the given required parameter.
         * 
         * @param targetTableId the target table ID
         */
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

        public Builder correlationImageCentroid(
            DvImageCentroid correlationImageCentroid) {
            this.correlationImageCentroid = correlationImageCentroid;
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

        public Builder pixelCorrelationStatistics(
            List<DvPixelStatistic> pixelCorrelationStatistics) {
            this.pixelCorrelationStatistics = pixelCorrelationStatistics;
            return this;
        }

        public DvPixelCorrelationResults build() {
            return new DvPixelCorrelationResults(this);
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime
            * result
            + (controlCentroidOffsets == null ? 0
                : controlCentroidOffsets.hashCode());
        result = prime
            * result
            + (controlImageCentroid == null ? 0
                : controlImageCentroid.hashCode());
        result = prime
            * result
            + (correlationImageCentroid == null ? 0
                : correlationImageCentroid.hashCode());
        result = prime * result
            + (kicCentroidOffsets == null ? 0 : kicCentroidOffsets.hashCode());
        result = prime
            * result
            + (kicReferenceCentroid == null ? 0
                : kicReferenceCentroid.hashCode());
        result = prime
            * result
            + (pixelCorrelationStatistics == null ? 0
                : pixelCorrelationStatistics.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (!super.equals(obj)) {
            return false;
        }
        if (!(obj instanceof DvPixelCorrelationResults)) {
            return false;
        }
        DvPixelCorrelationResults other = (DvPixelCorrelationResults) obj;
        if (controlCentroidOffsets == null) {
            if (other.controlCentroidOffsets != null) {
                return false;
            }
        } else if (!controlCentroidOffsets.equals(other.controlCentroidOffsets)) {
            return false;
        }
        if (controlImageCentroid == null) {
            if (other.controlImageCentroid != null) {
                return false;
            }
        } else if (!controlImageCentroid.equals(other.controlImageCentroid)) {
            return false;
        }
        if (correlationImageCentroid == null) {
            if (other.correlationImageCentroid != null) {
                return false;
            }
        } else if (!correlationImageCentroid.equals(other.correlationImageCentroid)) {
            return false;
        }
        if (kicCentroidOffsets == null) {
            if (other.kicCentroidOffsets != null) {
                return false;
            }
        } else if (!kicCentroidOffsets.equals(other.kicCentroidOffsets)) {
            return false;
        }
        if (kicReferenceCentroid == null) {
            if (other.kicReferenceCentroid != null) {
                return false;
            }
        } else if (!kicReferenceCentroid.equals(other.kicReferenceCentroid)) {
            return false;
        }
        if (pixelCorrelationStatistics == null) {
            if (other.pixelCorrelationStatistics != null) {
                return false;
            }
        } else if (!pixelCorrelationStatistics.equals(other.pixelCorrelationStatistics)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return new ToStringBuilder(this).appendSuper("targetTableData")
            .append("controlCentroidOffsets", controlCentroidOffsets)
            .append("controlImageCentroid", controlImageCentroid)
            .append("correlationImageCentroid", correlationImageCentroid)
            .append("kicCentroidOffsets", kicCentroidOffsets)
            .append("kicReferenceCentroid", kicReferenceCentroid)
            .append("pixelCorrelationStatistics", pixelCorrelationStatistics)
            .toString();
    }

    public long getId() {
        return id;
    }

    /**
     * For use by tests only.
     */
    void setId(long id) {
        this.id = id;
    }

    public DvCentroidOffsets getControlCentroidOffsets() {
        return controlCentroidOffsets;
    }

    public DvImageCentroid getControlImageCentroid() {
        return controlImageCentroid;
    }

    public DvImageCentroid getCorrelationImageCentroid() {
        return correlationImageCentroid;
    }

    public DvCentroidOffsets getKicCentroidOffsets() {
        return kicCentroidOffsets;
    }

    public DvImageCentroid getKicReferenceCentroid() {
        return kicReferenceCentroid;
    }

    public List<DvPixelStatistic> getPixelCorrelationStatistics() {
        return pixelCorrelationStatistics;
    }
}
