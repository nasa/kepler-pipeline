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

import gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets;

/**
 * Contains mq centroid offsets.
 * 
 * @author Miles Cote
 * 
 */
public class SbtMqCentroidOffsets implements SbtDataContainer {

    private SbtQuantity meanDecOffset = new SbtQuantity();
    private SbtQuantity meanRaOffset = new SbtQuantity();
    private SbtQuantity meanSkyOffset = new SbtQuantity();
    private SbtQuantity singleFitDecOffset = new SbtQuantity();
    private SbtQuantity singleFitRaOffset = new SbtQuantity();
    private SbtQuantity singleFitSkyOffset = new SbtQuantity();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("meanDecOffset",
            meanDecOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("meanRaOffset",
            meanRaOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("meanSkyOffset",
            meanSkyOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("singleFitDecOffset",
            singleFitDecOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("singleFitRaOffset",
            singleFitRaOffset.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("singleFitSkyOffset",
            singleFitSkyOffset.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtMqCentroidOffsets() {
    }

    public SbtMqCentroidOffsets(DvMqCentroidOffsets dvMqCentroidOffsets) {
        meanDecOffset = new SbtQuantity(dvMqCentroidOffsets.getMeanDecOffset());
        meanRaOffset = new SbtQuantity(dvMqCentroidOffsets.getMeanRaOffset());
        meanSkyOffset = new SbtQuantity(dvMqCentroidOffsets.getMeanSkyOffset());
        singleFitDecOffset = new SbtQuantity(
            dvMqCentroidOffsets.getSingleFitDecOffset());
        singleFitRaOffset = new SbtQuantity(
            dvMqCentroidOffsets.getSingleFitRaOffset());
        singleFitSkyOffset = new SbtQuantity(
            dvMqCentroidOffsets.getSingleFitSkyOffset());
    }

    public SbtMqCentroidOffsets(SbtQuantity meanDecOffset,
        SbtQuantity meanRaOffset, SbtQuantity meanSkyOffset,
        SbtQuantity singleFitDecOffset, SbtQuantity singleFitRaOffset,
        SbtQuantity singleFitSkyOffset) {
        this.meanDecOffset = meanDecOffset;
        this.meanRaOffset = meanRaOffset;
        this.meanSkyOffset = meanSkyOffset;
        this.singleFitDecOffset = singleFitDecOffset;
        this.singleFitRaOffset = singleFitRaOffset;
        this.singleFitSkyOffset = singleFitSkyOffset;
    }

    public SbtQuantity getMeanDecOffset() {
        return meanDecOffset;
    }

    public void setMeanDecOffset(SbtQuantity meanDecOffset) {
        this.meanDecOffset = meanDecOffset;
    }

    public SbtQuantity getMeanRaOffset() {
        return meanRaOffset;
    }

    public void setMeanRaOffset(SbtQuantity meanRaOffset) {
        this.meanRaOffset = meanRaOffset;
    }

    public SbtQuantity getMeanSkyOffset() {
        return meanSkyOffset;
    }

    public void setMeanSkyOffset(SbtQuantity meanSkyOffset) {
        this.meanSkyOffset = meanSkyOffset;
    }

    public SbtQuantity getSingleFitDecOffset() {
        return singleFitDecOffset;
    }

    public void setSingleFitDecOffset(SbtQuantity singleFitDecOffset) {
        this.singleFitDecOffset = singleFitDecOffset;
    }

    public SbtQuantity getSingleFitRaOffset() {
        return singleFitRaOffset;
    }

    public void setSingleFitRaOffset(SbtQuantity singleFitRaOffset) {
        this.singleFitRaOffset = singleFitRaOffset;
    }

    public SbtQuantity getSingleFitSkyOffset() {
        return singleFitSkyOffset;
    }

    public void setSingleFitSkyOffset(SbtQuantity singleFitSkyOffset) {
        this.singleFitSkyOffset = singleFitSkyOffset;
    }

}
