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

import static gov.nasa.kepler.hibernate.dv.DvCentroidResultsTest.createDifferenceImageMotionResults;
import static gov.nasa.kepler.hibernate.dv.DvCentroidResultsTest.createPixelCorrelationMotionResults;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.Marshaller;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DvPlanetResultsSequenceTest {

    private static final int START_CADENCE = 88;
    private static final int END_CADENCE = 888;
    private static final int KEPLER_ID = 8;
    private static final int PLANETNO = 1;
    private static final int TARGET_TABLE_ID = 8;
    private static final String PROVENANCE = "provenance";
    private static final String QUARTERS_OBSERVED = "-OOO----------------------------";
    private static final String EXTERNAL_TCE_MODEL_DESCRIPTION = "";
    private static final String TRANSIT_NAME_MODEL_DESCRIPTION = "";
    private static final String TRANSIT_PARAMETER_MODEL_DESCRIPTION = "";

    private File outputDir;

    @Before
    public void setup() throws Exception {
        outputDir = new File(Filenames.BUILD_TEST, "DvResultsSequenceTest");
        FileUtil.mkdirs(outputDir);
    }

    @After
    public void teardown() throws Exception {
        // FileUtil.cleanDir(outputDir);
    }

    @Test
    public void exportDvXmlTest() throws Exception {

        DvPlanetStatistic shorterPeriodComparisionStatistic = new DvPlanetStatistic(
            1, 4.0f, 10.0f);
        DvPlanetStatistic longerPeriodComparisionStatistic = new DvPlanetStatistic(
            1, 5.0f, 7.0f);
        DvStatistic oddEvenComparisionStatistic = new DvStatistic(3.0f, 1.0f);
        DvStatistic oddEvenTransitDepthStatistic = new DvStatistic(2.0f, 1.0f);
        DvStatistic singleTransitDepthStatistic = new DvStatistic(10.0f, 11.0f);
        DvStatistic singleTransitDurationStatistic = new DvStatistic(12.0f,
            13.0f);
        DvStatistic singleTransitEpochStatistic = new DvStatistic(14.0f, 15.0f);

        DvBinaryDiscriminationResults binaryDesciminationResults = new DvBinaryDiscriminationResults(
            shorterPeriodComparisionStatistic,
            longerPeriodComparisionStatistic, oddEvenComparisionStatistic,
            oddEvenTransitDepthStatistic, singleTransitDepthStatistic,
            singleTransitDurationStatistic, singleTransitEpochStatistic);

        DvCentroidMotionResults fluxWeighted = createCentroidMotionResults(1);
        DvCentroidMotionResults prfWeighted = createCentroidMotionResults(2);
        DvDifferenceImageMotionResults differenceImage = createDifferenceImageMotionResults(3);
        DvPixelCorrelationMotionResults pixelCorrelation = createPixelCorrelationMotionResults(4);

        DvCentroidResults centroidResults = new DvCentroidResults(fluxWeighted,
            prfWeighted, differenceImage, pixelCorrelation);

        DvPlanetModelFit allFit = createPlanetModelFit(4.0f, 89898);
        DvPlanetModelFit oddFit = createPlanetModelFit(7.0f, 34343);
        DvPlanetModelFit evenFit = createPlanetModelFit(8.0f, 444444);
        DvPlanetModelFit trapezoidalFit = createPlanetModelFit(9.0f, 454545);
        List<DvPlanetModelFit> singleTransitFits = Arrays.asList(createPlanetModelFit(
            9.0f, 555555));

        DvGhostDiagnosticResults ghostDiagnosticResults = new DvGhostDiagnosticResults(
            new DvStatistic(20.0F, 20.1F), new DvStatistic(20.5F, 20.6F));

        DvBootstrapHistogram bootstrapHistogram = new DvBootstrapHistogram(
            Collections.singletonList(666.0f), Collections.singletonList(1.1f),
            2);

        DvPlanetCandidate planetCandidate = new DvPlanetCandidate.Builder(
            KEPLER_ID, new PipelineTask()).bootstrapHistogram(
            bootstrapHistogram)
            .bootstrapMesMean(123.456f)
            .bootstrapMesStd(456.789f)
            .bootstrapThresholdForDesiredPfa(9.3F)
            .chiSquare1(42F)
            .chiSquare2(42.1F)
            .chiSquareDof1(43)
            .chiSquareDof2(44.1F)
            .epochMjd(55555.4)
            .expectedTransitCount(3)
            .id(44444)
            .maxMultipleEventSigma(666.0F)
            .maxSingleEventSigma(23.5F)
            .modelChiSquare2(42.3F)
            .modelChiSquareDof2(46)
            .modelChiSquareGof(42.4F)
            .modelChiSquareGofDof(47)
            .observedTransitCount(4)
            .orbitalPeriod(45.0F)
            .planetNumber(PLANETNO)
            .robustStatistic(42.2F)
            .significance(4.0F)
            .trialTransitPulseDuration(3.0F)
            .build();

        PipelineTask pipelineTask = new PipelineTask();
        DvPlanetResults planetResults = new DvPlanetResults.Builder(
            START_CADENCE, END_CADENCE, KEPLER_ID, PLANETNO, pipelineTask).allTransitsFit(
            allFit)
            .binaryDiscriminationResults(binaryDesciminationResults)
            .centroidResults(centroidResults)
            .evenTransitsFit(evenFit)
            .fluxType(FluxType.SAP)
            .ghostDiagnosticResults(ghostDiagnosticResults)
            .id(72)
            .oddTransitsFit(oddFit)
            .planetCandidate(planetCandidate)
            .singleTransitFits(singleTransitFits)
            .trapezoidalFit(trapezoidalFit)
            .build();

        DvLimbDarkeningModel limbDarkeningModel = new DvLimbDarkeningModel.Builder(
            TARGET_TABLE_ID, FluxType.SAP, KEPLER_ID, pipelineTask).build();

        DvTargetResults targetResults = new DvTargetResults.Builder(
            FluxType.SAP, START_CADENCE, END_CADENCE, KEPLER_ID, pipelineTask).effectiveTemp(
            createQuantityWithProvenance(1.0F, PROVENANCE))
            .log10Metallicity(createQuantityWithProvenance(2.0F, PROVENANCE))
            .log10SurfaceGravity(createQuantityWithProvenance(3.0F, PROVENANCE))
            .radius(createQuantityWithProvenance(4.0F, PROVENANCE))
            .quartersObserved(QUARTERS_OBSERVED)
            .build();

        DvExternalTceModelDescription externalTceModelDescription = new DvExternalTceModelDescription(
            pipelineTask, EXTERNAL_TCE_MODEL_DESCRIPTION);

        DvTransitModelDescriptions transitModelDescriptions = new DvTransitModelDescriptions(
            pipelineTask, TRANSIT_NAME_MODEL_DESCRIPTION,
            TRANSIT_PARAMETER_MODEL_DESCRIPTION);

        DvResultsSequence resultsSequence = new DvResultsSequence(
            Collections.singletonList(planetResults),
            Collections.singletonList(limbDarkeningModel),
            Collections.singletonList(targetResults),
            externalTceModelDescription, transitModelDescriptions);
        JAXBContext jaxbContext = JAXBContext.newInstance(DvResultsSequence.class);
        Marshaller marshaller = jaxbContext.createMarshaller();
        marshaller.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT, true);
        marshaller.marshal(resultsSequence, new File(outputDir, "dv.xml"));

        // TODO: unmarshall after schema is automatically generated.

    }

    private static DvPlanetModelFit createPlanetModelFit(float chiSquared,
        int id) {

        DvModelParameter limbDarkeningModelParameters = new DvModelParameter(
            "a model parameter", 34343.0, 4.0f, true);

        return new DvPlanetModelFit.Builder(KEPLER_ID, PLANETNO,
            new PipelineTask()).id(id)
            .limbDarkeningModelName("limb-darkening-default-model")
            .modelChiSquare(2.0f)
            .modelParameterCovariance(Collections.singletonList(4.0f))
            .modelParameters(
                Collections.singletonList(limbDarkeningModelParameters))
            .transitModelName("transit-default-model")
            .build();
    }

    private static DvCentroidMotionResults createCentroidMotionResults(int s) {
        DvDoubleQuantity srcRaHrs = new DvDoubleQuantity(s * 1.0, s * 2.0f);
        DvDoubleQuantity srcDecDeg = new DvDoubleQuantity(s * 2.0, s * 3.0f);
        DvDoubleQuantity ootCntrdRaHrs = new DvDoubleQuantity(s * 2.1, s * 3.1f);
        DvDoubleQuantity ootCntrdDecDeg = new DvDoubleQuantity(s * 2.2,
            s * 3.2f);
        DvQuantity srcRowOffset = new DvQuantity(s * 3.0f, s * 4.0f);
        DvQuantity srcColOffset = new DvQuantity(s * 4.0f, s * 5.0f);
        DvQuantity srcOffsetArcSec = new DvQuantity(s * 11.0f, s * 12.0f);
        DvQuantity peakRowOffset = new DvQuantity(s * 5.0f, s * 6.0f);
        DvQuantity peakColOffset = new DvQuantity(s * 6.0f, s * 7.0f);
        DvQuantity peakOffsetArcSec = new DvQuantity(s * 13.0f, s * 14.0f);
        DvStatistic motionStat = new DvStatistic(s * 10.0f, s * 0.1f);

        return new DvCentroidMotionResults(srcRaHrs, srcDecDeg, ootCntrdRaHrs,
            ootCntrdDecDeg, srcRowOffset, srcColOffset, srcOffsetArcSec,
            peakRowOffset, peakColOffset, peakOffsetArcSec, motionStat);
    }

    private static DvQuantityWithProvenance createQuantityWithProvenance(
        float seed, String provenance) {

        return new DvQuantityWithProvenance(seed, seed / 1000, provenance);
    }
}
