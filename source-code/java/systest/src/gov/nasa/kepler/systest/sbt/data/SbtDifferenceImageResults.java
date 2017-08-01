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

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults;
import gov.nasa.kepler.hibernate.dv.DvQualityMetric;

import java.util.ArrayList;
import java.util.List;

/**
 * This class contains difference image results.
 * 
 * @author Miles Cote
 * 
 */
public class SbtDifferenceImageResults implements SbtDataContainer {

    private SbtCentroidOffsets controlCentroidOffsets = new SbtCentroidOffsets();
    private SbtImageCentroid controlImageCentroid = new SbtImageCentroid();
    private SbtImageCentroid differenceImageCentroid = new SbtImageCentroid();
    private SbtCentroidOffsets kicCentroidOffsets = new SbtCentroidOffsets();
    private SbtImageCentroid kicReferenceCentroid = new SbtImageCentroid();
    private int numberOfTransits;
    private int numberOfCadencesInTransit;
    private int numberOfCadenceGapsInTransit;
    private int numberOfCadencesOutOfTransit;
    private int numberOfCadenceGapsOutOfTransit;
    private SbtQualityMetric qualityMetric = new SbtQualityMetric();
    private List<SbtDifferenceImagePixelData> differenceImagePixelData = newArrayList();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {

        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("controlCentroidOffsets",
            controlCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("controlImageCentroid",
            controlImageCentroid.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("differenceImageCentroid",
            differenceImageCentroid.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("kicCentroidOffsets",
            kicCentroidOffsets.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("kicReferenceCentroid",
            kicReferenceCentroid.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("numberOfTransits",
            new SbtNumber(numberOfTransits).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "numberOfCadencesInTransit",
            new SbtNumber(numberOfCadencesInTransit).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "numberOfCadenceGapsInTransit", new SbtNumber(
                numberOfCadenceGapsInTransit).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "numberOfCadencesOutOfTransit", new SbtNumber(
                numberOfCadencesOutOfTransit).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "numberOfCadenceGapsOutOfTransit",
            new SbtNumber(numberOfCadenceGapsOutOfTransit).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("qualityMetric",
            qualityMetric.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "differenceImagePixelData",
            new SbtList(differenceImagePixelData).toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtDifferenceImageResults(
        DvDifferenceImageResults dvDifferenceImageResults) {
        controlCentroidOffsets = new SbtCentroidOffsets(
            dvDifferenceImageResults.getControlCentroidOffsets());
        controlImageCentroid = new SbtImageCentroid(
            dvDifferenceImageResults.getControlImageCentroid());
        differenceImageCentroid = new SbtImageCentroid(
            dvDifferenceImageResults.getDifferenceImageCentroid());
        kicCentroidOffsets = new SbtCentroidOffsets(
            dvDifferenceImageResults.getKicCentroidOffsets());
        kicReferenceCentroid = new SbtImageCentroid(
            dvDifferenceImageResults.getKicReferenceCentroid());
        numberOfTransits = dvDifferenceImageResults.getNumberOfTransits();
        numberOfCadencesInTransit = dvDifferenceImageResults.getNumberOfCadencesInTransit();
        numberOfCadenceGapsInTransit = dvDifferenceImageResults.getNumberOfCadenceGapsInTransit();
        numberOfCadencesOutOfTransit = dvDifferenceImageResults.getNumberOfCadencesOutOfTransit();
        numberOfCadenceGapsOutOfTransit = dvDifferenceImageResults.getNumberOfCadenceGapsOutOfTransit();
        qualityMetric = new SbtQualityMetric(
            dvDifferenceImageResults.getQualityMetric());

        differenceImagePixelData = new ArrayList<SbtDifferenceImagePixelData>();
        for (DvDifferenceImagePixelData dvDifferenceImagePixelData : dvDifferenceImageResults.getDifferenceImagePixelData()) {
            differenceImagePixelData.add(new SbtDifferenceImagePixelData(
                dvDifferenceImagePixelData));
        }
    }

    public SbtDifferenceImageResults() {
    }

    public SbtDifferenceImageResults(SbtCentroidOffsets controlCentroidOffsets,
        SbtImageCentroid controlImageCentroid,
        SbtImageCentroid differenceImageCentroid,
        SbtCentroidOffsets kicCentroidOffsets,
        SbtImageCentroid kicReferenceCentroid, int numberOfTransits,
        int numberOfCadencesInTransit, int numberOfCadenceGapsInTransit,
        int numberOfCadencesOutOfTransit, int numberOfCadenceGapsOutOfTransit,
        SbtQualityMetric qualityMetric,
        List<SbtDifferenceImagePixelData> differenceImagePixelData) {
        this.controlCentroidOffsets = controlCentroidOffsets;
        this.controlImageCentroid = controlImageCentroid;
        this.differenceImageCentroid = differenceImageCentroid;
        this.kicCentroidOffsets = kicCentroidOffsets;
        this.kicReferenceCentroid = kicReferenceCentroid;
        this.numberOfTransits = numberOfTransits;
        this.numberOfCadencesInTransit = numberOfCadencesInTransit;
        this.numberOfCadenceGapsInTransit = numberOfCadenceGapsInTransit;
        this.numberOfCadencesOutOfTransit = numberOfCadencesOutOfTransit;
        this.numberOfCadenceGapsOutOfTransit = numberOfCadenceGapsOutOfTransit;
        this.qualityMetric = qualityMetric;
        this.differenceImagePixelData = differenceImagePixelData;
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

    public SbtImageCentroid getDifferenceImageCentroid() {
        return differenceImageCentroid;
    }

    public void setDifferenceImageCentroid(
        SbtImageCentroid differenceImageCentroid) {
        this.differenceImageCentroid = differenceImageCentroid;
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

    public int getNumberOfTransits() {
        return numberOfTransits;
    }

    public void setNumberOfTransits(int numberOfTransits) {
        this.numberOfTransits = numberOfTransits;
    }

    public int getNumberOfCadencesInTransit() {
        return numberOfCadencesInTransit;
    }

    public void setNumberOfCadencesInTransit(int numberOfCadencesInTransit) {
        this.numberOfCadencesInTransit = numberOfCadencesInTransit;
    }

    public int getNumberOfCadenceGapsInTransit() {
        return numberOfCadenceGapsInTransit;
    }

    public void setNumberOfCadenceGapsInTransit(int numberOfCadenceGapsInTransit) {
        this.numberOfCadenceGapsInTransit = numberOfCadenceGapsInTransit;
    }

    public int getNumberOfCadencesOutOfTransit() {
        return numberOfCadencesOutOfTransit;
    }

    public void setNumberOfCadencesOutOfTransit(int numberOfCadencesOutOfTransit) {
        this.numberOfCadencesOutOfTransit = numberOfCadencesOutOfTransit;
    }

    public int getNumberOfCadenceGapsOutOfTransit() {
        return numberOfCadenceGapsOutOfTransit;
    }

    public void setNumberOfCadenceGapsOutOfTransit(
        int numberOfCadenceGapsOutOfTransit) {
        this.numberOfCadenceGapsOutOfTransit = numberOfCadenceGapsOutOfTransit;
    }

}
