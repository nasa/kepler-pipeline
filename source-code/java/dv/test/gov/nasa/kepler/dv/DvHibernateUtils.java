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

package gov.nasa.kepler.dv;

import static com.google.common.base.Preconditions.checkNotNull;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.BOOTSTRAP_MES_MEAN;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.BOOTSTRAP_MES_STD;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.CONTROL_CENTROID_OFFSETS_OFFSET;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.CONTROL_IMAGE_CENTROID_OFFSET;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.DETREND_FILTER_LENGTH;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.DIFFERENCE_IMAGE_CENTROID_OFFSET;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.KIC_CENTROID_OFFSETS_OFFSET;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.KIC_REFERENCE_CENTROID_OFFSET;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.MODEL_CHI_SQUARE_GOF;
import static gov.nasa.kepler.dv.AbstractDvPipelineModuleTest.MODEL_CHI_SQUARE_GOF_DOF;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults;
import gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram;
import gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults;
import gov.nasa.kepler.hibernate.dv.DvCentroidOffsets;
import gov.nasa.kepler.hibernate.dv.DvCentroidResults;
import gov.nasa.kepler.hibernate.dv.DvComparisonTests;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults;
import gov.nasa.kepler.hibernate.dv.DvDoubleQuantity;
import gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenance;
import gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults;
import gov.nasa.kepler.hibernate.dv.DvImageArtifactResults;
import gov.nasa.kepler.hibernate.dv.DvImageCentroid;
import gov.nasa.kepler.hibernate.dv.DvLimbDarkeningModel;
import gov.nasa.kepler.hibernate.dv.DvModelParameter;
import gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets;
import gov.nasa.kepler.hibernate.dv.DvMqImageCentroid;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults;
import gov.nasa.kepler.hibernate.dv.DvPixelStatistic;
import gov.nasa.kepler.hibernate.dv.DvPlanetCandidate;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit.PlanetModelFitType;
import gov.nasa.kepler.hibernate.dv.DvPlanetParameters;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvPlanetStatistic;
import gov.nasa.kepler.hibernate.dv.DvQualityMetric;
import gov.nasa.kepler.hibernate.dv.DvQuantity;
import gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenance;
import gov.nasa.kepler.hibernate.dv.DvRollingBandContaminationHistogram;
import gov.nasa.kepler.hibernate.dv.DvSecondaryEventResults;
import gov.nasa.kepler.hibernate.dv.DvStatistic;
import gov.nasa.kepler.hibernate.dv.DvSummaryOverlapMetric;
import gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.dv.DvWeakSecondary;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

/**
 * Creates and mocks DV Hibernate classes and CRUD.
 * 
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DvHibernateUtils {

    private static final String IMPACT_PARAMETER = "impactParameter";
    private static final int TEST_PULSE_DURATION_LC = 10;

    /**
     * Create a list containing one DvPlanetResults for each supplied Kepler ID.
     * 
     * @param jMockTest
     * @param dvCrud
     * @param unitTestDescriptor must not be null
     * @param pipelineTask
     * @param keplerIds a collection of Kepler IDs (preferable unique); must not
     * be null
     * @return a List containing one DvPlanetReults for each Kepler ID supplied
     * in keplerIds; will not be null
     * @throws NullPointerException if keplerIds is null
     */
    public static List<DvPlanetResults> mockPlanetResults(JMockTest jMockTest,
        final DvCrud dvCrud, UnitTestDescriptor unitTestDescriptor,
        PipelineTask pipelineTask, List<Integer> keplerIds) {

        checkNotNull(unitTestDescriptor, "unitTestDescriptor can't be null");
        checkNotNull(keplerIds, "keplerIds can't be null");

        final List<DvPlanetResults> planetResultsList = new ArrayList<DvPlanetResults>(
            unitTestDescriptor.getPlanetCount());

        for (int keplerId : keplerIds) {
            for (int planetNumber = 1; planetNumber <= unitTestDescriptor.getPlanetCount(); planetNumber++) {

                DvPlanetModelFit allTransitsFit = createPlanetModelFit(
                    unitTestDescriptor, keplerId, planetNumber,
                    PlanetModelFitType.ALL, pipelineTask);

                DvBinaryDiscriminationResults binaryDiscriminationResults = new DvBinaryDiscriminationResults(
                    new DvPlanetStatistic(planetNumber, 0, 0),
                    new DvPlanetStatistic(planetNumber, 0, 0), new DvStatistic(
                        0, 0), new DvStatistic(0, 0), new DvStatistic(0, 0),
                    new DvStatistic(0, 0), new DvStatistic(0, 0));

                DvCentroidMotionResults fluxWeightedMotionResults = new DvCentroidMotionResults(
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0),
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0),
                    new DvQuantity(0, 0), new DvQuantity(0, 0), new DvQuantity(
                        0, 0), new DvQuantity(0, 0), new DvQuantity(0, 0),
                    new DvQuantity(0, 0), new DvStatistic(0, 0));
                DvCentroidMotionResults prfMotionResults = new DvCentroidMotionResults(
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0),
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0),
                    new DvQuantity(0, 0), new DvQuantity(0, 0), new DvQuantity(
                        0, 0), new DvQuantity(0, 0), new DvQuantity(0, 0),
                    new DvQuantity(0, 0), new DvStatistic(0, 0));
                DvMqCentroidOffsets mqControlCentroidOffsets = new DvMqCentroidOffsets(
                    new DvQuantity(0, 0), new DvQuantity(0, 0), new DvQuantity(
                        0, 0), new DvQuantity(0, 0), new DvQuantity(0, 0),
                    new DvQuantity(0, 0));
                DvMqCentroidOffsets mqKicCentroidOffsets = new DvMqCentroidOffsets(
                    new DvQuantity(0, 0), new DvQuantity(0, 0), new DvQuantity(
                        0, 0), new DvQuantity(0, 0), new DvQuantity(0, 0),
                    new DvQuantity(0, 0));
                DvMqImageCentroid mqControlImageCentroid = new DvMqImageCentroid(
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0));
                DvMqImageCentroid mqDifferenceImageCentroid = new DvMqImageCentroid(
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0));
                DvMqImageCentroid mqCorrelationImageCentroid = new DvMqImageCentroid(
                    new DvDoubleQuantity(0, 0), new DvDoubleQuantity(0, 0));
                DvDifferenceImageMotionResults differenceImageMotionResults = new DvDifferenceImageMotionResults(
                    mqControlCentroidOffsets, mqKicCentroidOffsets,
                    mqControlImageCentroid, mqDifferenceImageCentroid,
                    new DvSummaryQualityMetric(), new DvSummaryOverlapMetric());
                DvPixelCorrelationMotionResults pixelCorrelationMotionResults = new DvPixelCorrelationMotionResults(
                    mqControlCentroidOffsets, mqKicCentroidOffsets,
                    mqControlImageCentroid, mqCorrelationImageCentroid);

                DvCentroidResults centroidResults = new DvCentroidResults(
                    fluxWeightedMotionResults, prfMotionResults,
                    differenceImageMotionResults, pixelCorrelationMotionResults);

                DvPlanetModelFit evenTransitsFit = createPlanetModelFit(
                    unitTestDescriptor, keplerId, planetNumber,
                    PlanetModelFitType.EVEN, pipelineTask);
                DvPlanetModelFit oddTransitsFit = createPlanetModelFit(
                    unitTestDescriptor, keplerId, planetNumber,
                    PlanetModelFitType.ODD, pipelineTask);

                DvBootstrapHistogram bootstrapHistogram = new DvBootstrapHistogram(
                    Arrays.asList(0F), Arrays.asList(0F), 0);
                DvPlanetCandidate planetCandidate = new DvPlanetCandidate.Builder(
                    keplerId, pipelineTask).bootstrapHistogram(
                    bootstrapHistogram)
                    .bootstrapMesMean(BOOTSTRAP_MES_MEAN)
                    .bootstrapMesStd(BOOTSTRAP_MES_STD)
                    .bootstrapThresholdForDesiredPfa(
                        BOOTSTRAP_THRESHOLD_FOR_DESIRED_PFA)
                    .modelChiSquareGof(MODEL_CHI_SQUARE_GOF)
                    .modelChiSquareGofDof(MODEL_CHI_SQUARE_GOF_DOF)
                    .planetNumber(planetNumber)
                    .weakSecondary(new DvWeakSecondary())
                    .build();

                List<DvPlanetModelFit> reducedParameterFits = Arrays.asList(createPlanetModelFit(
                    unitTestDescriptor, keplerId, planetNumber,
                    PlanetModelFitType.REDUCED_PARAMETER, pipelineTask));

                List<DvDifferenceImagePixelData> differenceImagePixelData = new ArrayList<DvDifferenceImagePixelData>();
                differenceImagePixelData.add(new DvDifferenceImagePixelData(
                    unitTestDescriptor.getCcdRow(),
                    unitTestDescriptor.getCcdColumn(), new DvQuantity(0, 0),
                    new DvQuantity(0, 0), new DvQuantity(0, 0), new DvQuantity(
                        0, 0)));
                List<DvDifferenceImageResults> differenceImageResults = new ArrayList<DvDifferenceImageResults>();
                differenceImageResults.add(new DvDifferenceImageResults.Builder(
                    unitTestDescriptor.getTargetTableId()).ccdModule(
                    unitTestDescriptor.getCcdModule())
                    .ccdOutput(unitTestDescriptor.getCcdOutput())
                    .startCadence(unitTestDescriptor.getStartCadence())
                    .endCadence(unitTestDescriptor.getEndCadence())
                    .quarter(unitTestDescriptor.getQuarter())
                    .controlCentroidOffsets(
                        createCentroidOffsets(CONTROL_CENTROID_OFFSETS_OFFSET))
                    .controlImageCentroid(
                        createImageCentroid(CONTROL_IMAGE_CENTROID_OFFSET))
                    .differenceImageCentroid(
                        createImageCentroid(DIFFERENCE_IMAGE_CENTROID_OFFSET))
                    .kicCentroidOffsets(
                        createCentroidOffsets(KIC_CENTROID_OFFSETS_OFFSET))
                    .kicReferenceCentroid(
                        createImageCentroid(KIC_REFERENCE_CENTROID_OFFSET))
                    .numberOfTransits(unitTestDescriptor.getNumberOfTransits())
                    .numberOfCadencesInTransit(
                        unitTestDescriptor.getNumberOfCadencesInTransit())
                    .numberOfCadenceGapsInTransit(
                        unitTestDescriptor.getNumberOfCadenceGapsInTransit())
                    .numberOfCadencesOutOfTransit(
                        unitTestDescriptor.getNumberOfCadencesOutOfTransit())
                    .numberOfCadenceGapsOutOfTransit(
                        unitTestDescriptor.getNumberOfCadenceGapsOutOfTransit())
                    .qualityMetric(createQualityMetric())
                    .overlappedTransits(
                        unitTestDescriptor.isOverlappedTransits())
                    .differenceImagePixelData(differenceImagePixelData)
                    .build());

                DvGhostDiagnosticResults ghostDiagnosticResults = new DvGhostDiagnosticResults(
                    new DvStatistic(0, 0), new DvStatistic(0, 0));

                List<DvPixelStatistic> pixelCorrelationStatistics = new ArrayList<DvPixelStatistic>();
                pixelCorrelationStatistics.add(new DvPixelStatistic(
                    unitTestDescriptor.getCcdRow(),
                    unitTestDescriptor.getCcdColumn(), 0, 0));
                List<DvPixelCorrelationResults> pixelCorrelationResults = new ArrayList<DvPixelCorrelationResults>();
                pixelCorrelationResults.add(new DvPixelCorrelationResults.Builder(
                    unitTestDescriptor.getTargetTableId()).ccdModule(
                    unitTestDescriptor.getCcdModule())
                    .ccdOutput(unitTestDescriptor.getCcdOutput())
                    .endCadence(unitTestDescriptor.getEndCadence())
                    .quarter(unitTestDescriptor.getQuarter())
                    .startCadence(unitTestDescriptor.getStartCadence())
                    .controlCentroidOffsets(
                        createCentroidOffsets(CONTROL_CENTROID_OFFSETS_OFFSET))
                    .controlImageCentroid(
                        createImageCentroid(CONTROL_IMAGE_CENTROID_OFFSET))
                    .correlationImageCentroid(
                        createImageCentroid(DIFFERENCE_IMAGE_CENTROID_OFFSET))
                    .kicCentroidOffsets(
                        createCentroidOffsets(KIC_CENTROID_OFFSETS_OFFSET))
                    .kicReferenceCentroid(
                        createImageCentroid(KIC_REFERENCE_CENTROID_OFFSET))
                    .pixelCorrelationStatistics(pixelCorrelationStatistics)
                    .build());
                DvImageArtifactResults imageArtifactResults = createDvImageArtifactResults();
                DvSecondaryEventResults secondaryEventResults = createDvSecondaryEventResults();

                DvPlanetModelFit trapezoidalFit = createPlanetModelFit(
                    unitTestDescriptor, keplerId, planetNumber,
                    PlanetModelFitType.TRAPEZOIDAL, pipelineTask);

                planetResultsList.add(new DvPlanetResults.Builder(
                    unitTestDescriptor.getStartCadence(),
                    unitTestDescriptor.getEndCadence(), keplerId, planetNumber,
                    pipelineTask).allTransitsFit(allTransitsFit)
                    .binaryDiscriminationResults(binaryDiscriminationResults)
                    .centroidResults(centroidResults)
                    .detrendFilterLength(DETREND_FILTER_LENGTH)
                    .differenceImageResults(differenceImageResults)
                    .evenTransitsFit(evenTransitsFit)
                    .fluxType(FluxType.SAP)
                    .oddTransitsFit(oddTransitsFit)
                    .ghostDiagnosticResults(ghostDiagnosticResults)
                    .pixelCorrelationResults(pixelCorrelationResults)
                    .planetCandidate(planetCandidate)
                    .reducedParameterFits(reducedParameterFits)
                    .imageArtifactResults(imageArtifactResults)
                    .secondaryEventResults(secondaryEventResults)
                    .trapezoidalFit(trapezoidalFit)
                    .build());
            }
        }

        if (jMockTest != null && dvCrud != null) {
            jMockTest.oneOf(dvCrud)
                .createPlanetResultsCollection(planetResultsList);
        }

        return planetResultsList;
    }

    private static DvSecondaryEventResults createDvSecondaryEventResults() {

        return new DvSecondaryEventResults(new DvPlanetParameters(
            new DvQuantity(0F, 0F), new DvQuantity(0F, 0F)),
            new DvComparisonTests(new DvStatistic(0F, 0F), new DvStatistic(0F,
                0F)));
    }

    private static DvImageArtifactResults createDvImageArtifactResults() {

        return new DvImageArtifactResults(
            createRollingBandContaminationHistogram());
    }

    private static DvRollingBandContaminationHistogram createRollingBandContaminationHistogram() {

        final int testPulseDurationLc = TEST_PULSE_DURATION_LC;
        return new DvRollingBandContaminationHistogram(testPulseDurationLc,
            new ArrayList<Float>(),
            new ArrayList<Integer>(), new ArrayList<Float>());
    }

    private static DvCentroidOffsets createCentroidOffsets(int offset) {

        return new DvCentroidOffsets(new DvQuantity(1.0F + offset, 0.0001F),
            new DvQuantity(2.0F + offset, 0.0002F), new DvQuantity(
                3.0F + offset, 0.0003F),
            new DvQuantity(4.0F + offset, 0.0004F), new DvQuantity(
                5.0F + offset, 0.0005F), new DvQuantity(6.0F + offset, 0.0006F));
    }

    private static DvImageCentroid createImageCentroid(int offset) {

        return new DvImageCentroid(new DvQuantity(1.0F + offset, 0.0001F),
            new DvDoubleQuantity(2.0 + offset, 0.0002F), new DvDoubleQuantity(
                3.0 + offset, 0.0003F), new DvQuantity(4.0F + offset, 0.0004F));
    }

    private static DvQualityMetric createQualityMetric() {

        return new DvQualityMetric(true, true, 0.1F);
    }

    private static DvPlanetModelFit createPlanetModelFit(
        UnitTestDescriptor unitTestDescriptor, int keplerId, int planetNumber,
        PlanetModelFitType type, PipelineTask pipelineTask) {

        List<DvModelParameter> modelParameters = null;
        if (type == PlanetModelFitType.REDUCED_PARAMETER) {
            modelParameters = Arrays.asList(new DvModelParameter(
                IMPACT_PARAMETER, 0, 0, false));
        } else {
            modelParameters = Arrays.asList(new DvModelParameter("foo", 0, 0,
                false));
        }

        return new DvPlanetModelFit.Builder(keplerId, planetNumber,
            pipelineTask).fullConvergence(true)
            .limbDarkeningModelName(
                unitTestDescriptor.getLimbDarkeningModelName())
            .modelChiSquare(0)
            .modelDegreesOfFreedom(1.0F)
            .modelFitSnr(2.0F)
            .modelParameterCovariance(Arrays.asList(0F))
            .modelParameters(modelParameters)
            .transitModelName(unitTestDescriptor.getTransitModelName())
            .type(type)
            .build();
    }

    public static List<DvLimbDarkeningModel> mockLimbDarkeningModels(
        JMockTest jMockTest, final DvCrud dvCrud,
        UnitTestDescriptor unitTestDescriptor, PipelineTask pipelineTask,
        List<Integer> keplerIds) {

        List<DvLimbDarkeningModel> limbDarkeningModels = new ArrayList<DvLimbDarkeningModel>();

        for (int keplerId : keplerIds) {
            limbDarkeningModels.add(new DvLimbDarkeningModel.Builder(
                unitTestDescriptor.getTargetTableId(), FluxType.SAP, keplerId,
                pipelineTask).ccdModule(unitTestDescriptor.getCcdModule())
                .ccdOutput(unitTestDescriptor.getCcdOutput())
                .startCadence(unitTestDescriptor.getStartCadence())
                .endCadence(unitTestDescriptor.getEndCadence())
                .quarter(unitTestDescriptor.getQuarter())
                .modelName("kepler_nonlinear_limb_darkening_model")
                .coefficient1(1.0F)
                .coefficient2(2.0F)
                .coefficient3(3.0F)
                .coefficient4(4.0F)
                .build());
        }

        if (jMockTest != null && dvCrud != null) {
            jMockTest.oneOf(dvCrud)
                .createLimbDarkeningModelsCollection(limbDarkeningModels);
        }

        return limbDarkeningModels;
    }

    public static List<DvTargetResults> mockTargetResults(JMockTest jMockTest,
        final DvCrud dvCrud, UnitTestDescriptor unitTestDescriptor,
        PipelineTask pipelineTask,
        List<gov.nasa.kepler.dv.io.DvTargetResults> targetResultsList) {

        List<DvTargetResults> targetResults = new ArrayList<DvTargetResults>();

        for (gov.nasa.kepler.dv.io.DvTargetResults dvTargetResults : targetResultsList) {
            targetResults.add(new DvTargetResults.Builder(FluxType.SAP,
                unitTestDescriptor.getStartCadence(),
                unitTestDescriptor.getEndCadence(),
                dvTargetResults.getKeplerId(), pipelineTask).planetCandidateCount(
                dvTargetResults.getPlanetResults()
                    .size())
                .quartersObserved(dvTargetResults.getQuartersObserved())
                .radius(
                    createDvQuantityWithProvenance(dvTargetResults.getRadius()))
                .effectiveTemp(
                    createDvQuantityWithProvenance(dvTargetResults.getEffectiveTemp()))
                .log10SurfaceGravity(
                    createDvQuantityWithProvenance(dvTargetResults.getLog10SurfaceGravity()))
                .log10Metallicity(
                    createDvQuantityWithProvenance(dvTargetResults.getLog10Metallicity()))
                .decDegrees(
                    createDvDoubleQuantityWithProvenance(dvTargetResults.getDecDegrees()))
                .keplerMag(
                    createDvQuantityWithProvenance(dvTargetResults.getKeplerMag()))
                .raHours(
                    createDvDoubleQuantityWithProvenance(dvTargetResults.getRaHours()))
                .koiId(dvTargetResults.getKoiId())
                .keplerName(dvTargetResults.getKeplerName())
                .matchedKoiIds(
                    Arrays.asList(dvTargetResults.getMatchedKoiIds()))
                .unmatchedKoiIds(
                    Arrays.asList(dvTargetResults.getUnmatchedKoiIds()))
                .build());
        }

        if (jMockTest != null && dvCrud != null) {
            jMockTest.oneOf(dvCrud)
                .createTargetResultsCollection(targetResults);
        }

        return targetResults;
    }

    private static DvQuantityWithProvenance createDvQuantityWithProvenance(
        gov.nasa.kepler.dv.io.DvQuantityWithProvenance dvQuantityWithProvenance) {

        return new DvQuantityWithProvenance(
            dvQuantityWithProvenance.getValue(),
            dvQuantityWithProvenance.getUncertainty(),
            dvQuantityWithProvenance.getProvenance());
    }

    private static DvDoubleQuantityWithProvenance createDvDoubleQuantityWithProvenance(
        gov.nasa.kepler.dv.io.DvDoubleQuantityWithProvenance dvDoubleQuantityWithProvenance) {

        return new DvDoubleQuantityWithProvenance(
            dvDoubleQuantityWithProvenance.getValue(),
            dvDoubleQuantityWithProvenance.getUncertainty(),
            dvDoubleQuantityWithProvenance.getProvenance());
    }
}
