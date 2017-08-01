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

import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults;

public class SbtPixelCorrelationMotionResults implements SbtDataContainer {

    private SbtMqCentroidOffsets mqControlCentroidOffsets = new SbtMqCentroidOffsets();
    private SbtMqCentroidOffsets mqKicCentroidOffsets = new SbtMqCentroidOffsets();
    private SbtMqImageCentroid mqControlImageCentroid = new SbtMqImageCentroid();
    private SbtMqImageCentroid mqCorrelationImageCentroid = new SbtMqImageCentroid();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("mqControlCentroidOffsets",
            mqControlCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("mqKicCentroidOffsets",
            mqKicCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("mqKicCentroidOffsets",
            mqKicCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "mqCorrelationImageCentroid",
            mqCorrelationImageCentroid.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPixelCorrelationMotionResults() {
    }

    public SbtPixelCorrelationMotionResults(
        DvPixelCorrelationMotionResults dvPixelCorrelationMotionResults) {
        mqControlCentroidOffsets = new SbtMqCentroidOffsets(
            dvPixelCorrelationMotionResults.getMqControlCentroidOffsets());
        mqKicCentroidOffsets = new SbtMqCentroidOffsets(
            dvPixelCorrelationMotionResults.getMqKicCentroidOffsets());
        mqControlImageCentroid = new SbtMqImageCentroid(
            dvPixelCorrelationMotionResults.getMqControlImageCentroid());
        mqCorrelationImageCentroid = new SbtMqImageCentroid(
            dvPixelCorrelationMotionResults.getMqCorrelationImageCentroid());
    }

    public SbtPixelCorrelationMotionResults(
        SbtMqCentroidOffsets mqControlCentroidOffsets,
        SbtMqCentroidOffsets mqKicCentroidOffsets,
        SbtMqImageCentroid mqControlImageCentroid,
        SbtMqImageCentroid mqCorrelationImageCentroid) {
        this.mqControlCentroidOffsets = mqControlCentroidOffsets;
        this.mqKicCentroidOffsets = mqKicCentroidOffsets;
        this.mqControlImageCentroid = mqControlImageCentroid;
        this.mqCorrelationImageCentroid = mqCorrelationImageCentroid;
    }

    public SbtMqCentroidOffsets getMqControlCentroidOffsets() {
        return mqControlCentroidOffsets;
    }

    public void setMqControlCentroidOffsets(
        SbtMqCentroidOffsets mqControlCentroidOffsets) {
        this.mqControlCentroidOffsets = mqControlCentroidOffsets;
    }

    public SbtMqCentroidOffsets getMqKicCentroidOffsets() {
        return mqKicCentroidOffsets;
    }

    public void setMqKicCentroidOffsets(
        SbtMqCentroidOffsets mqKicCentroidOffsets) {
        this.mqKicCentroidOffsets = mqKicCentroidOffsets;
    }

    public SbtMqImageCentroid getMqControlImageCentroid() {
        return mqControlImageCentroid;
    }

    public void setMqControlImageCentroid(
        SbtMqImageCentroid mqControlImageCentroid) {
        this.mqControlImageCentroid = mqControlImageCentroid;
    }

    public SbtMqImageCentroid getMqCorrelationImageCentroid() {
        return mqCorrelationImageCentroid;
    }

    public void setMqCorrelationImageCentroid(
        SbtMqImageCentroid mqCorrelationImageCentroid) {
        this.mqCorrelationImageCentroid = mqCorrelationImageCentroid;
    }

}
