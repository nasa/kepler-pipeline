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

import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults;

/**
 * This class contains pixel correlation results.
 * 
 * @author Miles Cote
 * 
 */
public class SbtPixelCorrelationResults implements SbtDataContainer {

    private SbtCentroidOffsets controlCentroidOffsets = new SbtCentroidOffsets();
    private SbtImageCentroid controlImageCentroid = new SbtImageCentroid();
    private SbtImageCentroid correlationImageCentroid = new SbtImageCentroid();
    private SbtCentroidOffsets kicCentroidOffsets = new SbtCentroidOffsets();
    private SbtImageCentroid kicReferenceCentroid = new SbtImageCentroid();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("controlCentroidOffsets",
            controlCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("controlImageCentroid",
            controlImageCentroid.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("correlationImageCentroid",
            correlationImageCentroid.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("kicCentroidOffsets",
            kicCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("kicReferenceCentroid",
            kicReferenceCentroid.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPixelCorrelationResults(
        DvPixelCorrelationResults dvPixelCorrelationResults) {
        controlCentroidOffsets = new SbtCentroidOffsets(
            dvPixelCorrelationResults.getControlCentroidOffsets());
        controlImageCentroid = new SbtImageCentroid(
            dvPixelCorrelationResults.getControlImageCentroid());
        correlationImageCentroid = new SbtImageCentroid(
            dvPixelCorrelationResults.getCorrelationImageCentroid());
        kicCentroidOffsets = new SbtCentroidOffsets(
            dvPixelCorrelationResults.getKicCentroidOffsets());
        kicReferenceCentroid = new SbtImageCentroid(
            dvPixelCorrelationResults.getKicReferenceCentroid());
    }

    public SbtPixelCorrelationResults() {
    }

    public SbtPixelCorrelationResults(
        SbtCentroidOffsets controlCentroidOffsets,
        SbtImageCentroid controlImageCentroid,
        SbtImageCentroid correlationImageCentroid,
        SbtCentroidOffsets kicCentroidOffsets,
        SbtImageCentroid kicReferenceCentroid) {
        this.controlCentroidOffsets = controlCentroidOffsets;
        this.controlImageCentroid = controlImageCentroid;
        this.correlationImageCentroid = correlationImageCentroid;
        this.kicCentroidOffsets = kicCentroidOffsets;
        this.kicReferenceCentroid = kicReferenceCentroid;
    }

    public SbtCentroidOffsets getControlCentroidOffsets() {
        return controlCentroidOffsets;
    }

    public void setControlCentroidOffsets(
        SbtCentroidOffsets controlCentroidOffsets) {
        this.controlCentroidOffsets = controlCentroidOffsets;
    }

    public SbtImageCentroid getControlImageCentroid() {
        return controlImageCentroid;
    }

    public void setControlImageCentroid(SbtImageCentroid controlImageCentroid) {
        this.controlImageCentroid = controlImageCentroid;
    }

    public SbtImageCentroid getCorrelationImageCentroid() {
        return correlationImageCentroid;
    }

    public void setCorrelationImageCentroid(
        SbtImageCentroid correlationImageCentroid) {
        this.correlationImageCentroid = correlationImageCentroid;
    }

    public SbtCentroidOffsets getKicCentroidOffsets() {
        return kicCentroidOffsets;
    }

    public void setKicCentroidOffsets(SbtCentroidOffsets kicCentroidOffsets) {
        this.kicCentroidOffsets = kicCentroidOffsets;
    }

    public SbtImageCentroid getKicReferenceCentroid() {
        return kicReferenceCentroid;
    }

    public void setKicReferenceCentroid(SbtImageCentroid kicReferenceCentroid) {
        this.kicReferenceCentroid = kicReferenceCentroid;
    }

}
