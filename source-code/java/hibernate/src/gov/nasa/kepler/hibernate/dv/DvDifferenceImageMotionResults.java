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
public class DvDifferenceImageMotionResults {

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "meanDecOffset.value", column = @Column(name = "CNTRL_MEAN_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "meanDecOffset.uncertainty", column = @Column(name = "CNTRL_MEAN_DEC_OFFSET_UNC")),
        @AttributeOverride(name = "meanRaOffset.value", column = @Column(name = "CNTRL_MEAN_RA_OFFSET_VAL")),
        @AttributeOverride(name = "meanRaOffset.uncertainty", column = @Column(name = "CNTRL_MEAN_RA_OFFSET_UNC")),
        @AttributeOverride(name = "meanSkyOffset.value", column = @Column(name = "CNTRL_MEAN_SKY_OFFSET_VAL")),
        @AttributeOverride(name = "meanSkyOffset.uncertainty", column = @Column(name = "CNTRL_MEAN_SKY_OFFSET_UNC")),
        @AttributeOverride(name = "singleFitDecOffset.value", column = @Column(name = "CNTRL_FIT_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "singleFitDecOffset.uncertainty", column = @Column(name = "CNTRL_FIT_DEC_OFFSET_UNC")),
        @AttributeOverride(name = "singleFitRaOffset.value", column = @Column(name = "CNTRL_FIT_RA_OFFSET_VAL")),
        @AttributeOverride(name = "singleFitRaOffset.uncertainty", column = @Column(name = "CNTRL_FIT_RA_OFFSET_UNC")),
        @AttributeOverride(name = "singleFitSkyOffset.value", column = @Column(name = "CNTRL_FIT_SKY_OFFSET_VAL")),
        @AttributeOverride(name = "singleFitSkyOffset.uncertainty", column = @Column(name = "CNTRL_FIT_SKY_OFFSET_UNC")) })
    @XmlElement
    private DvMqCentroidOffsets mqControlCentroidOffsets;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "meanDecOffset.value", column = @Column(name = "KIC_MEAN_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "meanDecOffset.uncertainty", column = @Column(name = "KIC_MEAN_DEC_OFFSET_UNC")),
        @AttributeOverride(name = "meanRaOffset.value", column = @Column(name = "KIC_MEAN_RA_OFFSET_VAL")),
        @AttributeOverride(name = "meanRaOffset.uncertainty", column = @Column(name = "KIC_MEAN_RA_OFFSET_UNC")),
        @AttributeOverride(name = "meanSkyOffset.value", column = @Column(name = "KIC_MEAN_SKY_OFFSET_VAL")),
        @AttributeOverride(name = "meanSkyOffset.uncertainty", column = @Column(name = "KIC_MEAN_SKY_OFFSET_UNC")),
        @AttributeOverride(name = "singleFitDecOffset.value", column = @Column(name = "KIC_FIT_DEC_OFFSET_VAL")),
        @AttributeOverride(name = "singleFitDecOffset.uncertainty", column = @Column(name = "KIC_FIT_DEC_OFFSET_UNC")),
        @AttributeOverride(name = "singleFitRaOffset.value", column = @Column(name = "KIC_FIT_RA_OFFSET_VAL")),
        @AttributeOverride(name = "singleFitRaOffset.uncertainty", column = @Column(name = "KIC_FIT_RA_OFFSET_UNC")),
        @AttributeOverride(name = "singleFitSkyOffset.value", column = @Column(name = "KIC_FIT_SKY_OFFSET_VAL")),
        @AttributeOverride(name = "singleFitSkyOffset.uncertainty", column = @Column(name = "KIC_FIT_SKY_OFFSET_UNC")) })
    @XmlElement
    private DvMqCentroidOffsets mqKicCentroidOffsets;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "decDegrees.value", column = @Column(name = "CNTRL_IMG_DEC_DEGREES_VAL")),
        @AttributeOverride(name = "decDegrees.uncertainty", column = @Column(name = "CNTRL_IMG_DEC_DEGREES_UNC")),
        @AttributeOverride(name = "raHours.value", column = @Column(name = "CNTRL_IMG_RA_HOURS_VAL")),
        @AttributeOverride(name = "raHours.uncertainty", column = @Column(name = "CNTRL_IMG_RA_HOURS_UNC")) })
    @XmlElement
    private DvMqImageCentroid mqControlImageCentroid;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "decDegrees.value", column = @Column(name = "DIFF_IMG_DEC_DEGREES_VAL")),
        @AttributeOverride(name = "decDegrees.uncertainty", column = @Column(name = "DIFF_IMG_DEC_DEGREES_UNC")),
        @AttributeOverride(name = "raHours.value", column = @Column(name = "DIFF_IMG_RA_HOURS_VAL")),
        @AttributeOverride(name = "raHours.uncertainty", column = @Column(name = "DIFF_IMG_RA_HOURS_UNC")) })
    @XmlElement
    private DvMqImageCentroid mqDifferenceImageCentroid;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "fractionOfGoodMetrics", column = @Column(name = "SUM_METRIC_FRAC_GOOD_METRICS")),
        @AttributeOverride(name = "numberOfAttempts", column = @Column(name = "SUM_METRIC_ATTEMPTS")),
        @AttributeOverride(name = "numberOfGoodMetrics", column = @Column(name = "SUM_METRIC_GOOD_METRICS")),
        @AttributeOverride(name = "numberOfMetrics", column = @Column(name = "SUM_METRIC_METRICS")),
        @AttributeOverride(name = "qualityThreshold", column = @Column(name = "SUM_METRIC_QUALITY_THRESHOLD")) })
    @XmlElement
    private DvSummaryQualityMetric summaryQualityMetric;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "imageCount", column = @Column(name = "SUM_OVLP_IMG_CNT")),
        @AttributeOverride(name = "imageCountNoOverlap", column = @Column(name = "SUM_OVLP_IMG_CNT_NO_OVLP")),
        @AttributeOverride(name = "imageCountFractionNoOverlap", column = @Column(name = "SUM_OVLP_IMG_CNT_FRAC_NO_OVLP")) })
    @XmlElement
    private DvSummaryOverlapMetric summaryOverlapMetric;

    public DvDifferenceImageMotionResults() {
    }

    public DvDifferenceImageMotionResults(
        DvMqCentroidOffsets mqControlCentroidOffsets,
        DvMqCentroidOffsets mqKicCentroidOffsets,
        DvMqImageCentroid mqControlImageCentroid,
        DvMqImageCentroid mqDifferenceImageCentroid,
        DvSummaryQualityMetric summaryQualityMetric,
        DvSummaryOverlapMetric summaryOverlapMetric) {
        this.mqControlCentroidOffsets = mqControlCentroidOffsets;
        this.mqKicCentroidOffsets = mqKicCentroidOffsets;
        this.mqControlImageCentroid = mqControlImageCentroid;
        this.mqDifferenceImageCentroid = mqDifferenceImageCentroid;
        this.summaryQualityMetric = summaryQualityMetric;
        this.summaryOverlapMetric = summaryOverlapMetric;
    }

    public DvMqCentroidOffsets getMqControlCentroidOffsets() {
        return mqControlCentroidOffsets;
    }

    public DvMqCentroidOffsets getMqKicCentroidOffsets() {
        return mqKicCentroidOffsets;
    }

    public DvMqImageCentroid getMqControlImageCentroid() {
        return mqControlImageCentroid;
    }

    public DvMqImageCentroid getMqDifferenceImageCentroid() {
        return mqDifferenceImageCentroid;
    }

    public DvSummaryQualityMetric getSummaryQualityMetric() {
        return summaryQualityMetric;
    }

    public DvSummaryOverlapMetric getSummaryOverlapMetric() {
        return summaryOverlapMetric;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (mqControlCentroidOffsets == null ? 0
                : mqControlCentroidOffsets.hashCode());
        result = prime
            * result
            + (mqControlImageCentroid == null ? 0
                : mqControlImageCentroid.hashCode());
        result = prime
            * result
            + (mqDifferenceImageCentroid == null ? 0
                : mqDifferenceImageCentroid.hashCode());
        result = prime
            * result
            + (mqKicCentroidOffsets == null ? 0
                : mqKicCentroidOffsets.hashCode());
        result = prime
            * result
            + (summaryQualityMetric == null ? 0
                : summaryQualityMetric.hashCode());
        result = prime
            * result
            + (summaryOverlapMetric == null ? 0
                : summaryOverlapMetric.hashCode());
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
        if (!(obj instanceof DvDifferenceImageMotionResults)) {
            return false;
        }
        DvDifferenceImageMotionResults other = (DvDifferenceImageMotionResults) obj;
        if (mqControlCentroidOffsets == null) {
            if (other.mqControlCentroidOffsets != null) {
                return false;
            }
        } else if (!mqControlCentroidOffsets.equals(other.mqControlCentroidOffsets)) {
            return false;
        }
        if (mqControlImageCentroid == null) {
            if (other.mqControlImageCentroid != null) {
                return false;
            }
        } else if (!mqControlImageCentroid.equals(other.mqControlImageCentroid)) {
            return false;
        }
        if (mqDifferenceImageCentroid == null) {
            if (other.mqDifferenceImageCentroid != null) {
                return false;
            }
        } else if (!mqDifferenceImageCentroid.equals(other.mqDifferenceImageCentroid)) {
            return false;
        }
        if (mqKicCentroidOffsets == null) {
            if (other.mqKicCentroidOffsets != null) {
                return false;
            }
        } else if (!mqKicCentroidOffsets.equals(other.mqKicCentroidOffsets)) {
            return false;
        }
        if (summaryQualityMetric == null) {
            if (other.summaryQualityMetric != null) {
                return false;
            }
        } else if (!summaryQualityMetric.equals(other.summaryQualityMetric)) {
            return false;
        }
        if (summaryOverlapMetric == null) {
            if (other.summaryOverlapMetric != null) {
                return false;
            }
        } else if (!summaryOverlapMetric.equals(other.summaryOverlapMetric)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
