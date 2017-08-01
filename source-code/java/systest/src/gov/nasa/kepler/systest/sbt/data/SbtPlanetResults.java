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
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;

import java.util.List;

/**
 * This class contains planet results.
 * 
 * @author Miles Cote
 * @author Bill Wohler
 */
public class SbtPlanetResults implements SbtDataContainer {

    private SbtPlanetModelFit allTransitsFit = new SbtPlanetModelFit();
    private SbtBinaryDiscriminationResults binaryDiscriminationResults = new SbtBinaryDiscriminationResults();
    private SbtCentroidResults centroidResults = new SbtCentroidResults();
    private List<SbtDifferenceImageResults> differenceImageResults = newArrayList();
    private SbtPlanetModelFit evenTransitsFit = new SbtPlanetModelFit();
    private SbtPlanetModelFit oddTransitsFit = new SbtPlanetModelFit();
    private SbtGhostDiagnosticResults ghostDiagnosticResults = new SbtGhostDiagnosticResults();
    private List<SbtPixelCorrelationResults> pixelCorrelationResults = newArrayList();
    private SbtPlanetCandidate planetCandidate = new SbtPlanetCandidate();
    private int planetNumber;
    private List<SbtPlanetModelFit> reducedParameterFits = newArrayList();
    private List<SbtPlanetModelFit> singleTransitFits = newArrayList();
    private SbtPlanetModelFit trapezoidalFit = new SbtPlanetModelFit();
    private SimpleFloatTimeSeries modelLightCurve = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries whitenedModelLightCurve = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries trapezoidalModelLightCurve = new SimpleFloatTimeSeries();
    private SimpleFloatTimeSeries whitenedFluxTimeSeries = new SimpleFloatTimeSeries();
    private CorrectedFluxTimeSeries detrendedFluxTimeSeries = new CorrectedFluxTimeSeries();

    @Override
    public String toMissingDataString(ToMissingDataStringParameters parameters) {
        StringBuilder stringBuilder = new StringBuilder();
        stringBuilder.append(SbtDataUtils.toString("allTransitsFit",
            allTransitsFit.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "binaryDiscriminationResults",
            binaryDiscriminationResults.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("centroidResults",
            centroidResults.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "differenceImageResults",
            new SbtList(differenceImageResults, true).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("evenTransitsFit",
            evenTransitsFit.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("oddTransitsFit",
            oddTransitsFit.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("ghostDiagnosticResults",
            getGhostDiagnosticResults().toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "pixelCorrelationResults",
            new SbtList(pixelCorrelationResults, true).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("planetCandidate",
            planetCandidate.toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("planetNumber",
            new SbtNumber(planetNumber).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "reducedParameterFits",
            new SbtList(reducedParameterFits, true).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString(
            "singleTransitFits",
            new SbtList(singleTransitFits, true).toMissingDataString(parameters)));
        stringBuilder.append(SbtDataUtils.toString("trapezoidalFit",
            trapezoidalFit.toMissingDataString(parameters)));

        return stringBuilder.toString();
    }

    public SbtPlanetResults() {
    }

    public SbtPlanetResults(DvPlanetResults dvPlanetResults,
        CorrectedFluxTimeSeries initialFluxTimeSeries,
        SimpleFloatTimeSeries modelLightCurve,
        SimpleFloatTimeSeries whitenedModelLightCurve,
        SimpleFloatTimeSeries trapezoidalModelLightCurve,
        SimpleFloatTimeSeries whitenedFluxTimeSeries,
        CorrectedFluxTimeSeries detrendedFluxTimeSeries) {
        allTransitsFit = new SbtPlanetModelFit(
            dvPlanetResults.getAllTransitsFit());
        binaryDiscriminationResults = new SbtBinaryDiscriminationResults(
            dvPlanetResults.getBinaryDiscriminationResults());
        centroidResults = new SbtCentroidResults(
            dvPlanetResults.getCentroidResults());

        List<SbtDifferenceImageResults> sbtDifferenceImageResults = newArrayList();
        for (DvDifferenceImageResults dvDifferenceImageResult : dvPlanetResults.getDifferenceImageResults()) {
            sbtDifferenceImageResults.add(new SbtDifferenceImageResults(
                dvDifferenceImageResult));
        }
        differenceImageResults = sbtDifferenceImageResults;

        evenTransitsFit = new SbtPlanetModelFit(
            dvPlanetResults.getEvenTransitsFit());
        oddTransitsFit = new SbtPlanetModelFit(
            dvPlanetResults.getOddTransitsFit());

        ghostDiagnosticResults = new SbtGhostDiagnosticResults(
            dvPlanetResults.getGhostDiagnosticResults());

        List<SbtPixelCorrelationResults> sbtPixelCorrelationResults = newArrayList();
        for (DvPixelCorrelationResults dvPlanetModelFit : dvPlanetResults.getPixelCorrelationResults()) {
            sbtPixelCorrelationResults.add(new SbtPixelCorrelationResults(
                dvPlanetModelFit));
        }
        pixelCorrelationResults = sbtPixelCorrelationResults;

        planetCandidate = new SbtPlanetCandidate(
            dvPlanetResults.getPlanetCandidate(), initialFluxTimeSeries);
        planetNumber = dvPlanetResults.getPlanetNumber();

        List<SbtPlanetModelFit> sbtPlanetModelFits = newArrayList();
        for (DvPlanetModelFit dvPlanetModelFit : dvPlanetResults.getReducedParameterFits()) {
            sbtPlanetModelFits.add(new SbtPlanetModelFit(dvPlanetModelFit));
        }
        reducedParameterFits = sbtPlanetModelFits;

        sbtPlanetModelFits = newArrayList();
        for (DvPlanetModelFit dvPlanetModelFit : dvPlanetResults.getSingleTransitFits()) {
            sbtPlanetModelFits.add(new SbtPlanetModelFit(dvPlanetModelFit));
        }
        singleTransitFits = sbtPlanetModelFits;

        trapezoidalFit = new SbtPlanetModelFit(
            dvPlanetResults.getTrapezoidalFit());

        this.modelLightCurve = modelLightCurve;
        this.whitenedModelLightCurve = whitenedModelLightCurve;
        this.trapezoidalModelLightCurve = trapezoidalModelLightCurve;
        this.whitenedFluxTimeSeries = whitenedFluxTimeSeries;
        this.detrendedFluxTimeSeries = detrendedFluxTimeSeries;
    }

    public SbtPlanetResults(SbtPlanetModelFit allTransitsFit,
        SbtBinaryDiscriminationResults binaryDiscriminationResults,
        SbtCentroidResults centroidResults,
        List<SbtDifferenceImageResults> differenceImageResults,
        SbtPlanetModelFit evenTransitsFit, SbtPlanetModelFit oddTransitsFit,
        SbtGhostDiagnosticResults ghostDiagnosticResults,
        List<SbtPixelCorrelationResults> pixelCorrelationResults,
        SbtPlanetCandidate planetCandidate, int planetNumber,
        List<SbtPlanetModelFit> reducedParameterFits,
        List<SbtPlanetModelFit> singleTransitFits,
        SbtPlanetModelFit trapezoidalFit,
        SimpleFloatTimeSeries modelLightCurve,
        SimpleFloatTimeSeries whitenedModelLightCurve,
        SimpleFloatTimeSeries trapezoidalModelLightCurve,
        SimpleFloatTimeSeries whitenedFluxTimeSeries,
        CorrectedFluxTimeSeries detrendedFluxTimeSeries) {
        this.allTransitsFit = allTransitsFit;
        this.binaryDiscriminationResults = binaryDiscriminationResults;
        this.centroidResults = centroidResults;
        this.differenceImageResults = differenceImageResults;
        this.evenTransitsFit = evenTransitsFit;
        this.oddTransitsFit = oddTransitsFit;
        this.ghostDiagnosticResults = ghostDiagnosticResults;
        this.pixelCorrelationResults = pixelCorrelationResults;
        this.planetCandidate = planetCandidate;
        this.planetNumber = planetNumber;
        this.reducedParameterFits = reducedParameterFits;
        this.singleTransitFits = singleTransitFits;
        this.trapezoidalFit = trapezoidalFit;
        this.modelLightCurve = modelLightCurve;
        this.whitenedModelLightCurve = whitenedModelLightCurve;
        this.trapezoidalModelLightCurve = trapezoidalModelLightCurve;
        this.whitenedFluxTimeSeries = whitenedFluxTimeSeries;
        this.detrendedFluxTimeSeries = detrendedFluxTimeSeries;
    }

    public SbtPlanetModelFit getAllTransitsFit() {
        return allTransitsFit;
    }

    public void setAllTransitsFit(SbtPlanetModelFit allTransitsFit) {
        this.allTransitsFit = allTransitsFit;
    }

    public SbtBinaryDiscriminationResults getBinaryDiscriminationResults() {
        return binaryDiscriminationResults;
    }

    public void setBinaryDiscriminationResults(
        SbtBinaryDiscriminationResults binaryDiscriminationResults) {
        this.binaryDiscriminationResults = binaryDiscriminationResults;
    }

    public SbtCentroidResults getCentroidResults() {
        return centroidResults;
    }

    public void setCentroidResults(SbtCentroidResults centroidResults) {
        this.centroidResults = centroidResults;
    }

    public List<SbtDifferenceImageResults> getDifferenceImageResults() {
        return differenceImageResults;
    }

    public void setDifferenceImageResults(
        List<SbtDifferenceImageResults> differenceImageResults) {
        this.differenceImageResults = differenceImageResults;
    }

    public SbtPlanetModelFit getEvenTransitsFit() {
        return evenTransitsFit;
    }

    public void setEvenTransitsFit(SbtPlanetModelFit evenTransitsFit) {
        this.evenTransitsFit = evenTransitsFit;
    }

    public SbtPlanetModelFit getOddTransitsFit() {
        return oddTransitsFit;
    }

    public void setOddTransitsFit(SbtPlanetModelFit oddTransitsFit) {
        this.oddTransitsFit = oddTransitsFit;
    }

    public SbtGhostDiagnosticResults getGhostDiagnosticResults() {
        return ghostDiagnosticResults;
    }

    public void setGhostDiagnosticResults(
        SbtGhostDiagnosticResults ghostDiagnosticResults) {
        this.ghostDiagnosticResults = ghostDiagnosticResults;
    }

    public List<SbtPixelCorrelationResults> getPixelCorrelationResults() {
        return pixelCorrelationResults;
    }

    public void setPixelCorrelationResults(
        List<SbtPixelCorrelationResults> pixelCorrelationResults) {
        this.pixelCorrelationResults = pixelCorrelationResults;
    }

    public SbtPlanetCandidate getPlanetCandidate() {
        return planetCandidate;
    }

    public void setPlanetCandidate(SbtPlanetCandidate planetCandidate) {
        this.planetCandidate = planetCandidate;
    }

    public int getPlanetNumber() {
        return planetNumber;
    }

    public void setPlanetNumber(int planetNumber) {
        this.planetNumber = planetNumber;
    }

    public List<SbtPlanetModelFit> getReducedParameterFits() {
        return reducedParameterFits;
    }

    public void setReducedParameterFits(
        List<SbtPlanetModelFit> reducedParameterFits) {
        this.reducedParameterFits = reducedParameterFits;
    }

    public List<SbtPlanetModelFit> getSingleTransitFits() {
        return singleTransitFits;
    }

    public void setSingleTransitFits(List<SbtPlanetModelFit> singleTransitFits) {
        this.singleTransitFits = singleTransitFits;
    }

    public SbtPlanetModelFit getTrapezoidalFit() {
        return trapezoidalFit;
    }

    public void setTrapezoidalFit(SbtPlanetModelFit trapezoidalFit) {
        this.trapezoidalFit = trapezoidalFit;
    }

    public SimpleFloatTimeSeries getModelLightCurve() {
        return modelLightCurve;
    }

    public void setModelLightCurve(SimpleFloatTimeSeries modelLightCurve) {
        this.modelLightCurve = modelLightCurve;
    }

    public SimpleFloatTimeSeries getWhitenedModelLightCurve() {
        return whitenedModelLightCurve;
    }

    public void setWhitenedModelLightCurve(
        SimpleFloatTimeSeries whitenedModelLightCurve) {
        this.whitenedModelLightCurve = whitenedModelLightCurve;
    }

    public SimpleFloatTimeSeries getTrapezoidalModelLightCurve() {
        return trapezoidalModelLightCurve;
    }

    public void setTrapezoidalModelLightCurve(
        SimpleFloatTimeSeries trapezoidalModelLightCurve) {
        this.trapezoidalModelLightCurve = trapezoidalModelLightCurve;
    }

    public SimpleFloatTimeSeries getWhitenedFluxTimeSeries() {
        return whitenedFluxTimeSeries;
    }

    public void setWhitenedFluxTimeSeries(
        SimpleFloatTimeSeries whitenedFluxTimeSeries) {
        this.whitenedFluxTimeSeries = whitenedFluxTimeSeries;
    }

    public CorrectedFluxTimeSeries getDetrendedFluxTimeSeries() {
        return detrendedFluxTimeSeries;
    }

    public void setDetrendedFluxTimeSeries(
        CorrectedFluxTimeSeries detrendedFluxTimeSeries) {
        this.detrendedFluxTimeSeries = detrendedFluxTimeSeries;
    }

}
