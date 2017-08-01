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
 * Encapsulates the results from DV for a particular type of centroid.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvCentroidMotionResults {

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "SOURCE_RA_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SOURCE_RA_UNCERT")) })
    @XmlElement
    private DvDoubleQuantity sourceRaHours;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "SOURCE_DEC_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SOURCE_DEC_UNCERT")) })
    @XmlElement
    private DvDoubleQuantity sourceDecDegrees;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "OOT_CENTROID_RA_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "OOT_CENTROID_RA_UNCERT")) })
    @XmlElement
    private DvDoubleQuantity outOfTransitCentroidRaHours;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "OOT_CENTROID_DEC_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "OOT_CENTROID_DEC_UNCERT")) })
    @XmlElement
    private DvDoubleQuantity outOfTransitCentroidDecDegrees; 

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "SOURCE_RA_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SOURCE_RA_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity sourceRaOffset;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "SOURCE_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SOURCE_DEC_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity sourceDecOffset;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "SOURCE_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "SOURCE_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity sourceOffsetArcSec;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "PEAK_RA_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "PEAK_RA_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity peakRaOffset;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "PEAK_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "PEAK_DEC_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity peakDecOffset;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "PEAK_OFFSET_VAL")),
        @AttributeOverride(name = "uncertainty", column = @Column(name = "PEAK_OFFSET_UNCERT")) })
    @XmlElement
    private DvQuantity peakOffsetArcSec;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "value", column = @Column(name = "MOTION_DETECTION_VAL")),
        @AttributeOverride(name = "significance", column = @Column(name = "MOTION_DETECTION_SIG")) })
    @XmlElement
    private DvStatistic motionDetectionStatistic;

    /**
     * Creates a {@link DvCentroidMotionResults}. For use only by mock objects
     * and Hibernate.
     */
    DvCentroidMotionResults() {
    }

    /**
     * Creates a {@link DvCentroidMotionResults} with the given values.
     * 
     * @throws NullPointerException if {@code motionDetectionStatistic} is
     * {@code null}
     */
    public DvCentroidMotionResults(DvDoubleQuantity sourceRaHours,
        DvDoubleQuantity sourceDecDegrees,
        DvDoubleQuantity outOfTransitCentroidRaHours,
        DvDoubleQuantity outOfTransitCentroidDecDegrees,
        DvQuantity sourceRaOffset, DvQuantity sourceDecOffset,
        DvQuantity sourceOffsetArcSec, DvQuantity peakRaOffset,
        DvQuantity peakDecOffset, DvQuantity peakOffsetArcSec,
        DvStatistic motionDetectionStatistic) {

        if (sourceRaHours == null) {
            throw new NullPointerException("sourceRaHours can't be null");
        }
        if (sourceDecDegrees == null) {
            throw new NullPointerException("sourceDecDegrees can't be null");
        }
        if (outOfTransitCentroidRaHours == null) {
            throw new NullPointerException(
                "outOfTransitCentroidRaHours can't be null");
        }
        if (outOfTransitCentroidDecDegrees == null) {
            throw new NullPointerException(
                "outOfTransitCentroidDecDegrees can't be null");
        }
        if (sourceRaOffset == null) {
            throw new NullPointerException("sourceRaOffset can't be null");
        }
        if (sourceDecOffset == null) {
            throw new NullPointerException("sourceDecOffset can't be null");
        }
        if (sourceOffsetArcSec == null) {
            throw new NullPointerException("sourceOffsetArcSec can't be null");
        }
        if (peakRaOffset == null) {
            throw new NullPointerException("peakRaOffset can't be null");
        }
        if (peakDecOffset == null) {
            throw new NullPointerException("peakDecOffset can't be null");
        }
        if (peakOffsetArcSec == null) {
            throw new NullPointerException("peakOffsetArcSec can't be null");
        }
        if (motionDetectionStatistic == null) {
            throw new NullPointerException(
                "motionDetectionStatistic can't be null");
        }

        this.sourceRaHours = sourceRaHours;
        this.sourceDecDegrees = sourceDecDegrees;
        this.outOfTransitCentroidRaHours = outOfTransitCentroidRaHours;
        this.outOfTransitCentroidDecDegrees = outOfTransitCentroidDecDegrees;
        this.sourceRaOffset = sourceRaOffset;
        this.sourceDecOffset = sourceDecOffset;
        this.sourceOffsetArcSec = sourceOffsetArcSec;
        this.peakRaOffset = peakRaOffset;
        this.peakDecOffset = peakDecOffset;
        this.peakOffsetArcSec = peakOffsetArcSec;
        this.motionDetectionStatistic = motionDetectionStatistic;
    }

    public DvDoubleQuantity getSourceRaHours() {
        return sourceRaHours;
    }

    public DvDoubleQuantity getSourceDecDegrees() {
        return sourceDecDegrees;
    }

    public DvDoubleQuantity getOutOfTransitCentroidRaHours() {
        return outOfTransitCentroidRaHours;
    }

    public DvDoubleQuantity getOutOfTransitCentroidDecDegrees() {
        return outOfTransitCentroidDecDegrees;
    }

    public DvQuantity getSourceRaOffset() {
        return sourceRaOffset;
    }

    public DvQuantity getSourceDecOffset() {
        return sourceDecOffset;
    }

    public DvQuantity getSourceOffsetArcSec() {
        return sourceOffsetArcSec;
    }

    public DvQuantity getPeakRaOffset() {
        return peakRaOffset;
    }

    public DvQuantity getPeakDecOffset() {
        return peakDecOffset;
    }

    public DvQuantity getPeakOffsetArcSec() {
        return peakOffsetArcSec;
    }

    public DvStatistic getMotionDetectionStatistic() {
        return motionDetectionStatistic;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (motionDetectionStatistic == null ? 0
                : motionDetectionStatistic.hashCode());
        result = prime
            * result
            + (outOfTransitCentroidDecDegrees == null ? 0
                : outOfTransitCentroidDecDegrees.hashCode());
        result = prime
            * result
            + (outOfTransitCentroidRaHours == null ? 0
                : outOfTransitCentroidRaHours.hashCode());
        result = prime * result
            + (peakDecOffset == null ? 0 : peakDecOffset.hashCode());
        result = prime * result
            + (peakOffsetArcSec == null ? 0 : peakOffsetArcSec.hashCode());
        result = prime * result
            + (peakRaOffset == null ? 0 : peakRaOffset.hashCode());
        result = prime * result
            + (sourceDecDegrees == null ? 0 : sourceDecDegrees.hashCode());
        result = prime * result
            + (sourceDecOffset == null ? 0 : sourceDecOffset.hashCode());
        result = prime * result
            + (sourceOffsetArcSec == null ? 0 : sourceOffsetArcSec.hashCode());
        result = prime * result
            + (sourceRaHours == null ? 0 : sourceRaHours.hashCode());
        result = prime * result
            + (sourceRaOffset == null ? 0 : sourceRaOffset.hashCode());
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
        if (!(obj instanceof DvCentroidMotionResults)) {
            return false;
        }
        DvCentroidMotionResults other = (DvCentroidMotionResults) obj;
        if (motionDetectionStatistic == null) {
            if (other.motionDetectionStatistic != null) {
                return false;
            }
        } else if (!motionDetectionStatistic.equals(other.motionDetectionStatistic)) {
            return false;
        }
        if (outOfTransitCentroidDecDegrees == null) {
            if (other.outOfTransitCentroidDecDegrees != null) {
                return false;
            }
        } else if (!outOfTransitCentroidDecDegrees.equals(other.outOfTransitCentroidDecDegrees)) {
            return false;
        }
        if (outOfTransitCentroidRaHours == null) {
            if (other.outOfTransitCentroidRaHours != null) {
                return false;
            }
        } else if (!outOfTransitCentroidRaHours.equals(other.outOfTransitCentroidRaHours)) {
            return false;
        }
        if (peakDecOffset == null) {
            if (other.peakDecOffset != null) {
                return false;
            }
        } else if (!peakDecOffset.equals(other.peakDecOffset)) {
            return false;
        }
        if (peakOffsetArcSec == null) {
            if (other.peakOffsetArcSec != null) {
                return false;
            }
        } else if (!peakOffsetArcSec.equals(other.peakOffsetArcSec)) {
            return false;
        }
        if (peakRaOffset == null) {
            if (other.peakRaOffset != null) {
                return false;
            }
        } else if (!peakRaOffset.equals(other.peakRaOffset)) {
            return false;
        }
        if (sourceDecDegrees == null) {
            if (other.sourceDecDegrees != null) {
                return false;
            }
        } else if (!sourceDecDegrees.equals(other.sourceDecDegrees)) {
            return false;
        }
        if (sourceDecOffset == null) {
            if (other.sourceDecOffset != null) {
                return false;
            }
        } else if (!sourceDecOffset.equals(other.sourceDecOffset)) {
            return false;
        }
        if (sourceOffsetArcSec == null) {
            if (other.sourceOffsetArcSec != null) {
                return false;
            }
        } else if (!sourceOffsetArcSec.equals(other.sourceOffsetArcSec)) {
            return false;
        }
        if (sourceRaHours == null) {
            if (other.sourceRaHours != null) {
                return false;
            }
        } else if (!sourceRaHours.equals(other.sourceRaHours)) {
            return false;
        }
        if (sourceRaOffset == null) {
            if (other.sourceRaOffset != null) {
                return false;
            }
        } else if (!sourceRaOffset.equals(other.sourceRaOffset)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
