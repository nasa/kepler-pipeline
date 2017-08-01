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

package gov.nasa.kepler.systest.sbt.data;

import gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults;

/**
 * This class contains centroid motion results.
 * 
 * @author Miles Cote
 * 
 */
public class SbtCentroidMotionResults implements SbtDataContainer {

    private SbtStatistic motionDetectionStatistic = new SbtStatistic();
    private SbtDoubleQuantity sourceRaHours = new SbtDoubleQuantity();
    private SbtDoubleQuantity sourceDecDegrees = new SbtDoubleQuantity();
    private SbtQuantity sourceRaOffset = new SbtQuantity();
    private SbtQuantity sourceDecOffset = new SbtQuantity();
    private SbtQuantity peakRaOffset = new SbtQuantity();
    private SbtQuantity peakDecOffset = new SbtQuantity();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("motionDetectionStatistic",
            motionDetectionStatistic.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtCentroidMotionResults() {
    }

    public SbtCentroidMotionResults(
        DvCentroidMotionResults dvCentroidMotionResults) {
        this.motionDetectionStatistic = new SbtStatistic(
            dvCentroidMotionResults.getMotionDetectionStatistic());
        this.sourceRaHours = new SbtDoubleQuantity(
            dvCentroidMotionResults.getSourceRaHours());
        this.sourceDecDegrees = new SbtDoubleQuantity(
            dvCentroidMotionResults.getSourceDecDegrees());
        this.sourceRaOffset = new SbtQuantity(
            dvCentroidMotionResults.getSourceRaOffset());
        this.sourceDecOffset = new SbtQuantity(
            dvCentroidMotionResults.getSourceDecOffset());
        this.peakRaOffset = new SbtQuantity(
            dvCentroidMotionResults.getPeakRaOffset());
        this.peakDecOffset = new SbtQuantity(
            dvCentroidMotionResults.getPeakDecOffset());
    }

    public SbtCentroidMotionResults(SbtStatistic motionDetectionStatistic,
        SbtDoubleQuantity sourceRaHours, SbtDoubleQuantity sourceDecDegrees,
        SbtQuantity sourceRaOffset, SbtQuantity sourceDecOffset,
        SbtQuantity peakRaOffset, SbtQuantity peakDecOffset) {
        this.motionDetectionStatistic = motionDetectionStatistic;
        this.sourceRaHours = sourceRaHours;
        this.sourceDecDegrees = sourceDecDegrees;
        this.sourceRaOffset = sourceRaOffset;
        this.sourceDecOffset = sourceDecOffset;
        this.peakRaOffset = peakRaOffset;
        this.peakDecOffset = peakDecOffset;
    }

    public SbtStatistic getMotionDetectionStatistic() {
        return motionDetectionStatistic;
    }

    public void setMotionDetectionStatistic(
        SbtStatistic motionDetectionStatistic) {
        this.motionDetectionStatistic = motionDetectionStatistic;
    }

    public SbtDoubleQuantity getSourceRaHours() {
        return sourceRaHours;
    }

    public void setSourceRaHours(SbtDoubleQuantity sourceRaHours) {
        this.sourceRaHours = sourceRaHours;
    }

    public SbtDoubleQuantity getSourceDecDegrees() {
        return sourceDecDegrees;
    }

    public void setSourceDecDegrees(SbtDoubleQuantity sourceDecDegrees) {
        this.sourceDecDegrees = sourceDecDegrees;
    }

    public SbtQuantity getSourceRaOffset() {
        return sourceRaOffset;
    }

    public void setSourceRaOffset(SbtQuantity sourceRaOffset) {
        this.sourceRaOffset = sourceRaOffset;
    }

    public SbtQuantity getSourceDecOffset() {
        return sourceDecOffset;
    }

    public void setSourceDecOffset(SbtQuantity sourceDecOffset) {
        this.sourceDecOffset = sourceDecOffset;
    }

    public SbtQuantity getPeakRaOffset() {
        return peakRaOffset;
    }

    public void setPeakRaOffset(SbtQuantity peakRaOffset) {
        this.peakRaOffset = peakRaOffset;
    }

    public SbtQuantity getPeakDecOffset() {
        return peakDecOffset;
    }

    public void setPeakDecOffset(SbtQuantity peakDecOffset) {
        this.peakDecOffset = peakDecOffset;
    }

}
