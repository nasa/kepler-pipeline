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
 * Encapsulates the output centroids from DV.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
@Embeddable
@XmlType
public class DvCentroidResults {

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "sourceRaHours.value", column = @Column(name = "FLUX_WEIGHTED_SRC_RA_VAL")),
        @AttributeOverride(name = "sourceRaHours.uncertainty", column = @Column(name = "FLUX_WEIGHTED_SRC_RA_UNCERT")),
        @AttributeOverride(name = "sourceDecDegrees.value", column = @Column(name = "FLUX_WEIGHTED_SRC_DEC_VAL")),
        @AttributeOverride(name = "sourceDecDegrees.uncertainty", column = @Column(name = "FLUX_WEIGHTED_SRC_DEC_UNCERT")),
        @AttributeOverride(name = "outOfTransitCentroidRaHours.value", column = @Column(name = "FLUX_WGHTD_OOT_CNTRD_RA_VAL")),
        @AttributeOverride(name = "outOfTransitCentroidRaHours.uncertainty", column = @Column(name = "FLUX_WGHTD_OOT_CNTRD_RA_UNC")),
        @AttributeOverride(name = "outOfTransitCentroidDecDegrees.value", column = @Column(name = "FLUX_WGHTD_OOT_CNTRD_DEC_VAL")),
        @AttributeOverride(name = "outOfTransitCentroidDecDegrees.uncertainty", column = @Column(name = "FLUX_WGHTD_OOT_CNTRD_DEC_UNC")),
        @AttributeOverride(name = "sourceRaOffset.value", column = @Column(name = "FLUX_WEIGHTED_SRC_RA_OFF_VAL")),
        @AttributeOverride(name = "sourceRaOffset.uncertainty", column = @Column(name = "FLUX_WEIGHTED_SRC_RA_OFF_UNC")),
        @AttributeOverride(name = "sourceDecOffset.value", column = @Column(name = "FLUX_WEIGHTED_SRC_DEC_OFF_VAL")),
        @AttributeOverride(name = "sourceDecOffset.uncertainty", column = @Column(name = "FLUX_WEIGHTED_SRC_DEC_OFF_UNC")),
        @AttributeOverride(name = "sourceOffsetArcSec.value", column = @Column(name = "FLUX_WEIGHTED_SRC_OFF_VAL")),
        @AttributeOverride(name = "sourceOffsetArcSec.uncertainty", column = @Column(name = "FLUX_WEIGHTED_SRC_OFF_UNC")),
        @AttributeOverride(name = "peakRaOffset.value", column = @Column(name = "FLUX_WEIGHTED_PEAK_RA_OFF_VAL")),
        @AttributeOverride(name = "peakRaOffset.uncertainty", column = @Column(name = "FLUX_WEIGHTED_PEAK_RA_OFF_UNC")),
        @AttributeOverride(name = "peakDecOffset.value", column = @Column(name = "FLUX_WEIGHTED_PEAK_DEC_OFF_VAL")),
        @AttributeOverride(name = "peakDecOffset.uncertainty", column = @Column(name = "FLUX_WEIGHTED_PEAK_DEC_OFF_UNC")),
        @AttributeOverride(name = "peakOffsetArcSec.value", column = @Column(name = "FLUX_WEIGHTED_PEAK_OFF_VAL")),
        @AttributeOverride(name = "peakOffsetArcSec.uncertainty", column = @Column(name = "FLUX_WEIGHTED_PEAK_OFF_UNC")),
        @AttributeOverride(name = "motionDetectionStatistic.value", column = @Column(name = "FLUX_WEIGHTED_MOTION_VAL")),
        @AttributeOverride(name = "motionDetectionStatistic.significance", column = @Column(name = "FLUX_WEIGHTED_MOTION_SIG")) })
    @XmlElement
    private DvCentroidMotionResults fluxWeightedMotionResults;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "sourceRaHours.value", column = @Column(name = "PRF_SRC_RA_VAL")),
        @AttributeOverride(name = "sourceRaHours.uncertainty", column = @Column(name = "PRF_SRC_RA_UNCERT")),
        @AttributeOverride(name = "sourceDecDegrees.value", column = @Column(name = "PRF_SRC_DEC_VAL")),
        @AttributeOverride(name = "sourceDecDegrees.uncertainty", column = @Column(name = "PRF_SRC_DEC_UNCERT")),
        @AttributeOverride(name = "outOfTransitCentroidRaHours.value", column = @Column(name = "PRF_OOT_CNTRD_RA_VAL")),
        @AttributeOverride(name = "outOfTransitCentroidRaHours.uncertainty", column = @Column(name = "PRF_OOT_CNTRD_RA_UNC")),
        @AttributeOverride(name = "outOfTransitCentroidDecDegrees.value", column = @Column(name = "PRF_OOT_CNTRD_DEC_VAL")),
        @AttributeOverride(name = "outOfTransitCentroidDecDegrees.uncertainty", column = @Column(name = "PRF_OOT_CNTRD_DEC_UNC")), 
        @AttributeOverride(name = "sourceRaOffset.value", column = @Column(name = "PRF_SRC_RA_OFF_VAL")),
        @AttributeOverride(name = "sourceRaOffset.uncertainty", column = @Column(name = "PRF_SRC_RA_OFF_UNC")),
        @AttributeOverride(name = "sourceDecOffset.value", column = @Column(name = "PRF_SRC_DEC_OFF_VAL")),
        @AttributeOverride(name = "sourceDecOffset.uncertainty", column = @Column(name = "PRF_SRC_DEC_OFF_UNC")),
        @AttributeOverride(name = "sourceOffsetArcSec.value", column = @Column(name = "PRF_SRC_OFF_VAL")),
        @AttributeOverride(name = "sourceOffsetArcSec.uncertainty", column = @Column(name = "PRF_SRC_OFF_UNC")),
        @AttributeOverride(name = "peakRaOffset.value", column = @Column(name = "PRF_PEAK_RA_OFF_VAL")),
        @AttributeOverride(name = "peakRaOffset.uncertainty", column = @Column(name = "PRF_PEAK_RA_OFF_UNC")),
        @AttributeOverride(name = "peakDecOffset.value", column = @Column(name = "PRF_PEAK_DEC_OFF_VAL")),
        @AttributeOverride(name = "peakDecOffset.uncertainty", column = @Column(name = "PRF_PEAK_DEC_OFF_UNC")),
        @AttributeOverride(name = "peakOffsetArcSec.value", column = @Column(name = "PRF_PEAK_OFF_VAL")),
        @AttributeOverride(name = "peakOffsetArcSec.uncertainty", column = @Column(name = "PRF_PEAK_OFF_UNC")),
        @AttributeOverride(name = "motionDetectionStatistic.value", column = @Column(name = "PRF_MOTION_VAL")),
        @AttributeOverride(name = "motionDetectionStatistic.significance", column = @Column(name = "PRF_MOTION_SIG")) })
    @XmlElement
    private DvCentroidMotionResults prfMotionResults;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "mqControlCentroidOffsets.meanDecOffset.value", column = @Column(name = "DIFF_IMG_CNTRL_MEAN_DEC_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanDecOffset.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_MEAN_DEC_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanRaOffset.value", column = @Column(name = "DIFF_IMG_CNTRL_MEAN_RA_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanRaOffset.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_MEAN_RA_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanSkyOffset.value", column = @Column(name = "DIFF_IMG_CNTRL_MEAN_SKY_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanSkyOffset.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_MEAN_SKY_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitDecOffset.value", column = @Column(name = "DIFF_IMG_CNTRL_FIT_DEC_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitDecOffset.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_FIT_DEC_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitRaOffset.value", column = @Column(name = "DIFF_IMG_CNTRL_FIT_RA_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitRaOffset.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_FIT_RA_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitSkyOffset.value", column = @Column(name = "DIFF_IMG_CNTRL_FIT_SKY_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitSkyOffset.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_FIT_SKY_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanDecOffset.value", column = @Column(name = "DIFF_IMG_KIC_MEAN_DEC_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanDecOffset.uncertainty", column = @Column(name = "DIFF_IMG_KIC_MEAN_DEC_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanRaOffset.value", column = @Column(name = "DIFF_IMG_KIC_MEAN_RA_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanRaOffset.uncertainty", column = @Column(name = "DIFF_IMG_KIC_MEAN_RA_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanSkyOffset.value", column = @Column(name = "DIFF_IMG_KIC_MEAN_SKY_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanSkyOffset.uncertainty", column = @Column(name = "DIFF_IMG_KIC_MEAN_SKY_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitDecOffset.value", column = @Column(name = "DIFF_IMG_KIC_FIT_DEC_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitDecOffset.uncertainty", column = @Column(name = "DIFF_IMG_KIC_FIT_DEC_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitRaOffset.value", column = @Column(name = "DIFF_IMG_KIC_FIT_RA_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitRaOffset.uncertainty", column = @Column(name = "DIFF_IMG_KIC_FIT_RA_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitSkyOffset.value", column = @Column(name = "DIFF_IMG_KIC_FIT_SKY_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitSkyOffset.uncertainty", column = @Column(name = "DIFF_IMG_KIC_FIT_SKY_UNC")),
        @AttributeOverride(name = "mqControlImageCentroid.decDegrees.value", column = @Column(name = "DIFF_IMG_CNTRL_IMG_DEC_VAL")),
        @AttributeOverride(name = "mqControlImageCentroid.decDegrees.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_IMG_DEC_UNC")),
        @AttributeOverride(name = "mqControlImageCentroid.raHours.value", column = @Column(name = "DIFF_IMG_CNTRL_IMG_RA_VAL")),
        @AttributeOverride(name = "mqControlImageCentroid.raHours.uncertainty", column = @Column(name = "DIFF_IMG_CNTRL_IMG_RA_UNC")),
        @AttributeOverride(name = "mqDifferenceImageCentroid.decDegrees.value", column = @Column(name = "DIFF_IMG_DIFF_IMG_DEC_VAL")),
        @AttributeOverride(name = "mqDifferenceImageCentroid.decDegrees.uncertainty", column = @Column(name = "DIFF_IMG_DIFF_IMG_DEC_UNC")),
        @AttributeOverride(name = "mqDifferenceImageCentroid.raHours.value", column = @Column(name = "DIFF_IMG_DIFF_IMG_RA_VAL")),
        @AttributeOverride(name = "mqDifferenceImageCentroid.raHours.uncertainty", column = @Column(name = "DIFF_IMG_DIFF_IMG_RA_UNC")) })
    @XmlElement
    private DvDifferenceImageMotionResults differenceImageMotionResults;

    @Embedded
    @AttributeOverrides( {
        @AttributeOverride(name = "mqControlCentroidOffsets.meanDecOffset.value", column = @Column(name = "PIX_CORR_CNTRL_MEAN_DEC_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanDecOffset.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_MEAN_DEC_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanRaOffset.value", column = @Column(name = "PIX_CORR_CNTRL_MEAN_RA_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanRaOffset.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_MEAN_RA_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanSkyOffset.value", column = @Column(name = "PIX_CORR_CNTRL_MEAN_SKY_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.meanSkyOffset.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_MEAN_SKY_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitDecOffset.value", column = @Column(name = "PIX_CORR_CNTRL_FIT_DEC_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitDecOffset.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_FIT_DEC_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitRaOffset.value", column = @Column(name = "PIX_CORR_CNTRL_FIT_RA_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitRaOffset.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_FIT_RA_UNC")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitSkyOffset.value", column = @Column(name = "PIX_CORR_CNTRL_FIT_SKY_VAL")),
        @AttributeOverride(name = "mqControlCentroidOffsets.singleFitSkyOffset.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_FIT_SKY_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanDecOffset.value", column = @Column(name = "PIX_CORR_KIC_MEAN_DEC_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanDecOffset.uncertainty", column = @Column(name = "PIX_CORR_KIC_MEAN_DEC_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanRaOffset.value", column = @Column(name = "PIX_CORR_KIC_MEAN_RA_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanRaOffset.uncertainty", column = @Column(name = "PIX_CORR_KIC_MEAN_RA_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanSkyOffset.value", column = @Column(name = "PIX_CORR_KIC_MEAN_SKY_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.meanSkyOffset.uncertainty", column = @Column(name = "PIX_CORR_KIC_MEAN_SKY_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitDecOffset.value", column = @Column(name = "PIX_CORR_KIC_FIT_DEC_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitDecOffset.uncertainty", column = @Column(name = "PIX_CORR_KIC_FIT_DEC_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitRaOffset.value", column = @Column(name = "PIX_CORR_KIC_FIT_RA_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitRaOffset.uncertainty", column = @Column(name = "PIX_CORR_KIC_FIT_RA_UNC")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitSkyOffset.value", column = @Column(name = "PIX_CORR_KIC_FIT_SKY_VAL")),
        @AttributeOverride(name = "mqKicCentroidOffsets.singleFitSkyOffset.uncertainty", column = @Column(name = "PIX_CORR_KIC_FIT_SKY_UNC")),
        @AttributeOverride(name = "mqControlImageCentroid.decDegrees.value", column = @Column(name = "PIX_CORR_CNTRL_IMG_DEC_VAL")),
        @AttributeOverride(name = "mqControlImageCentroid.decDegrees.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_IMG_DEC_UNC")),
        @AttributeOverride(name = "mqControlImageCentroid.raHours.value", column = @Column(name = "PIX_CORR_CNTRL_IMG_RA_VAL")),
        @AttributeOverride(name = "mqControlImageCentroid.raHours.uncertainty", column = @Column(name = "PIX_CORR_CNTRL_IMG_RA_UNC")),
        @AttributeOverride(name = "mqCorrelationImageCentroid.decDegrees.value", column = @Column(name = "PIX_CORR_CORR_IMG_DEC_VAL")),
        @AttributeOverride(name = "mqCorrelationImageCentroid.decDegrees.uncertainty", column = @Column(name = "PIX_CORR_CORR_IMG_DEC_UNC")),
        @AttributeOverride(name = "mqCorrelationImageCentroid.raHours.value", column = @Column(name = "PIX_CORR_CORR_IMG_RA_VAL")),
        @AttributeOverride(name = "mqCorrelationImageCentroid.raHours.uncertainty", column = @Column(name = "PIX_CORR_CORR_IMG_RA_UNC")) })
    @XmlElement
    private DvPixelCorrelationMotionResults pixelCorrelationMotionResults;

    /**
     * Creates a {@link DvCentroidResults} object. For use only by mock objects
     * and Hibernate.
     */
    DvCentroidResults() {
    }

    /**
     * Creates a new {@link DvCentroidResults} from the given parameters.
     * 
     * @throws NullPointerException if any of the arguments are {@code null}
     */
    public DvCentroidResults(DvCentroidMotionResults fluxWeightedMotionResults,
        DvCentroidMotionResults prfMotionResults,
        DvDifferenceImageMotionResults differenceImageMotionResults,
        DvPixelCorrelationMotionResults pixelCorrelationMotionResults) {

        if (fluxWeightedMotionResults == null) {
            throw new NullPointerException(
                "fluxWeightedMotionResults can't be null");
        }
        if (prfMotionResults == null) {
            throw new NullPointerException("prfMotionResults can't be null");
        }
        if (differenceImageMotionResults == null) {
            throw new NullPointerException(
                "differenceImageMotionResults can't be null");
        }
        if (pixelCorrelationMotionResults == null) {
            throw new NullPointerException(
                "pixelCorrelationMotionResults can't be null");
        }

        this.fluxWeightedMotionResults = fluxWeightedMotionResults;
        this.prfMotionResults = prfMotionResults;
        this.differenceImageMotionResults = differenceImageMotionResults;
        this.pixelCorrelationMotionResults = pixelCorrelationMotionResults;
    }

    public DvCentroidMotionResults getFluxWeightedMotionResults() {
        return fluxWeightedMotionResults;
    }

    public DvCentroidMotionResults getPrfMotionResults() {
        return prfMotionResults;
    }

    public DvDifferenceImageMotionResults getDifferenceImageMotionResults() {
        return differenceImageMotionResults;
    }

    public DvPixelCorrelationMotionResults getPixelCorrelationMotionResults() {
        return pixelCorrelationMotionResults;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime
            * result
            + (differenceImageMotionResults == null ? 0
                : differenceImageMotionResults.hashCode());
        result = prime
            * result
            + (fluxWeightedMotionResults == null ? 0
                : fluxWeightedMotionResults.hashCode());
        result = prime
            * result
            + (pixelCorrelationMotionResults == null ? 0
                : pixelCorrelationMotionResults.hashCode());
        result = prime * result
            + (prfMotionResults == null ? 0 : prfMotionResults.hashCode());
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
        if (!(obj instanceof DvCentroidResults)) {
            return false;
        }
        DvCentroidResults other = (DvCentroidResults) obj;
        if (differenceImageMotionResults == null) {
            if (other.differenceImageMotionResults != null) {
                return false;
            }
        } else if (!differenceImageMotionResults.equals(other.differenceImageMotionResults)) {
            return false;
        }
        if (fluxWeightedMotionResults == null) {
            if (other.fluxWeightedMotionResults != null) {
                return false;
            }
        } else if (!fluxWeightedMotionResults.equals(other.fluxWeightedMotionResults)) {
            return false;
        }
        if (pixelCorrelationMotionResults == null) {
            if (other.pixelCorrelationMotionResults != null) {
                return false;
            }
        } else if (!pixelCorrelationMotionResults.equals(other.pixelCorrelationMotionResults)) {
            return false;
        }
        if (prfMotionResults == null) {
            if (other.prfMotionResults != null) {
                return false;
            }
        } else if (!prfMotionResults.equals(other.prfMotionResults)) {
            return false;
        }
        return true;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }
}
