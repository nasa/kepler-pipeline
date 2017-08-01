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

package gov.nasa.kepler.systest.sbt;

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.common.TicToc;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dv.DvBinaryDiscriminationResults;
import gov.nasa.kepler.hibernate.dv.DvBootstrapHistogram;
import gov.nasa.kepler.hibernate.dv.DvCentroidMotionResults;
import gov.nasa.kepler.hibernate.dv.DvCentroidOffsets;
import gov.nasa.kepler.hibernate.dv.DvCentroidResults;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageMotionResults;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImagePixelData;
import gov.nasa.kepler.hibernate.dv.DvDifferenceImageResults;
import gov.nasa.kepler.hibernate.dv.DvDoubleQuantity;
import gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults;
import gov.nasa.kepler.hibernate.dv.DvImageCentroid;
import gov.nasa.kepler.hibernate.dv.DvModelParameter;
import gov.nasa.kepler.hibernate.dv.DvMqCentroidOffsets;
import gov.nasa.kepler.hibernate.dv.DvMqImageCentroid;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationMotionResults;
import gov.nasa.kepler.hibernate.dv.DvPixelCorrelationResults;
import gov.nasa.kepler.hibernate.dv.DvPixelStatistic;
import gov.nasa.kepler.hibernate.dv.DvPlanetCandidate;
import gov.nasa.kepler.hibernate.dv.DvPlanetModelFit;
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvPlanetStatistic;
import gov.nasa.kepler.hibernate.dv.DvQualityMetric;
import gov.nasa.kepler.hibernate.dv.DvQuantity;
import gov.nasa.kepler.hibernate.dv.DvStatistic;
import gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.ArrayUtils;

import com.google.common.primitives.Floats;

public class SbtRetrieveDvPlanetResults extends AbstractSbt {

    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-dv-planet-results.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public static class DvContainer implements Persistable {
        public List<OneDvResult> results;

        public DvContainer() {
            results = new ArrayList<OneDvResult>();
        }
    }

    public static class OneDvResult implements Persistable {
        public int startCadence;
        public int endCadence;
        public int keplerId;
        public int planetNumber;
        public long pipelineId;
        public CentroidContainer centroidResults = new CentroidContainer();
        public PlanetCandidateContainer planetCandidate = new PlanetCandidateContainer();

        public PlanetModelFitContainer allTransitFits = new PlanetModelFitContainer();
        public PlanetModelFitContainer evenTransitFits = new PlanetModelFitContainer();
        public PlanetModelFitContainer oddTransitFits = new PlanetModelFitContainer();
        public PlanetModelFitContainer trapezoidalFit = new PlanetModelFitContainer();
        public List<PlanetModelFitContainer> singleTransitFits = newArrayList();

        public BinaryDiscriminationContainer binaryDiscriminationResults = new BinaryDiscriminationContainer();

        public List<PlanetModelFitContainer> reducedParameterFits = newArrayList();

        public GhostDiagnosticContainer ghostDiagnosticResults = new GhostDiagnosticContainer();

        public List<PixelCorrelationContainer> pixelCorrelationResults = newArrayList();

        public List<DifferenceImageContainer> differenceImageResults = newArrayList();

        public OneDvResult(DvPlanetResults dvPlanetResult) {
            startCadence = dvPlanetResult.getStartCadence();
            endCadence = dvPlanetResult.getEndCadence();
            keplerId = dvPlanetResult.getKeplerId();
            planetNumber = dvPlanetResult.getPlanetNumber();
            pipelineId = dvPlanetResult.getPipelineTask()
                .getId();

            centroidResults = new CentroidContainer(
                dvPlanetResult.getCentroidResults());

            planetCandidate = new PlanetCandidateContainer(
                dvPlanetResult.getPlanetCandidate());

            allTransitFits = new PlanetModelFitContainer(
                dvPlanetResult.getAllTransitsFit());
            evenTransitFits = new PlanetModelFitContainer(
                dvPlanetResult.getEvenTransitsFit());
            oddTransitFits = new PlanetModelFitContainer(
                dvPlanetResult.getOddTransitsFit());
            trapezoidalFit = new PlanetModelFitContainer(
                dvPlanetResult.getTrapezoidalFit());

            singleTransitFits = new ArrayList<PlanetModelFitContainer>();
            for (DvPlanetModelFit dvPlanetModelFit : dvPlanetResult.getSingleTransitFits()) {
                singleTransitFits.add(new PlanetModelFitContainer(
                    dvPlanetModelFit));
            }

            binaryDiscriminationResults = new BinaryDiscriminationContainer(
                dvPlanetResult.getBinaryDiscriminationResults());

            reducedParameterFits = new ArrayList<PlanetModelFitContainer>();
            for (DvPlanetModelFit dvPlanetModelFit : dvPlanetResult.getReducedParameterFits()) {
                reducedParameterFits.add(new PlanetModelFitContainer(
                    dvPlanetModelFit));
            }

            pixelCorrelationResults = new ArrayList<PixelCorrelationContainer>();
            for (DvPixelCorrelationResults dvPixelCorrelationResults : dvPlanetResult.getPixelCorrelationResults()) {
                pixelCorrelationResults.add(new PixelCorrelationContainer(
                    dvPixelCorrelationResults));
            }

            differenceImageResults = new ArrayList<DifferenceImageContainer>();
            for (DvDifferenceImageResults dvDifferenceImageResults : dvPlanetResult.getDifferenceImageResults()) {
                differenceImageResults.add(new DifferenceImageContainer(
                    dvDifferenceImageResults));
            }
        }
    }

    public static class BinaryDiscriminationContainer implements Persistable {
        public PlanetStatisticContainer shorterPeriodComparisonStatistic = new PlanetStatisticContainer();
        public PlanetStatisticContainer longerPeriodComparisonStatistic = new PlanetStatisticContainer();
        public StatisticContainer oddEvenTransitEpochComparisonStatistic = new StatisticContainer();
        public StatisticContainer oddEvenTransitDepthComparisonStatistic = new StatisticContainer();
        public StatisticContainer singleTransitDepthComparisonStatistic = new StatisticContainer();
        public StatisticContainer singleTransitDurationComparisonStatistic = new StatisticContainer();
        public StatisticContainer singleTransitEpochComparisonStatistic = new StatisticContainer();

        public BinaryDiscriminationContainer() {
        }

        public BinaryDiscriminationContainer(
            DvBinaryDiscriminationResults dvBinaryDiscriminationResults) {

            shorterPeriodComparisonStatistic = new PlanetStatisticContainer(
                dvBinaryDiscriminationResults.getShorterPeriodComparisonStatistic());
            longerPeriodComparisonStatistic = new PlanetStatisticContainer(
                dvBinaryDiscriminationResults.getLongerPeriodComparisonStatistic());
            oddEvenTransitEpochComparisonStatistic = new StatisticContainer(
                dvBinaryDiscriminationResults.getOddEvenTransitEpochComparisonStatistic());
            oddEvenTransitDepthComparisonStatistic = new StatisticContainer(
                dvBinaryDiscriminationResults.getOddEvenTransitDepthComparisonStatistic());
            singleTransitDepthComparisonStatistic = new StatisticContainer(
                dvBinaryDiscriminationResults.getSingleTransitDepthComparisonStatistic());
            singleTransitDurationComparisonStatistic = new StatisticContainer(
                dvBinaryDiscriminationResults.getSingleTransitDurationComparisonStatistic());
            singleTransitEpochComparisonStatistic = new StatisticContainer(
                dvBinaryDiscriminationResults.getSingleTransitEpochComparisonStatistic());
        }
    }

    public static class PlanetStatisticContainer implements Persistable {
        public int planetNumber;
        public float value = Float.NaN;
        public double significance = Double.NaN;

        public PlanetStatisticContainer() {
        }

        public PlanetStatisticContainer(DvPlanetStatistic dvPlanetStatistic) {
            planetNumber = dvPlanetStatistic.getPlanetNumber();
            value = dvPlanetStatistic.getValue();
            significance = dvPlanetStatistic.getSignificance();
        }
    }

    public static class StatisticContainer implements Persistable {
        public float value = Float.NaN;
        public double significance = Double.NaN;

        public StatisticContainer() {
        }

        public StatisticContainer(DvStatistic dvStatistic) {
            value = dvStatistic.getValue();
            significance = dvStatistic.getSignificance();
        }
    }

    public static class PlanetModelFitContainer implements Persistable {
        public String limbDarkeningModelName = "";
        public float modelChiSquare = Float.NaN;
        public float modelDegreesOfFreedom = Float.NaN;
        public float[] modelParametersCovariance = ArrayUtils.EMPTY_FLOAT_ARRAY;
        public int planetNumber;
        public String transitModelName = "";
        public String planetModelFitType = "";
        public List<ModelParameterContainer> modelParameters = newArrayList();

        public PlanetModelFitContainer() {
        }

        public PlanetModelFitContainer(DvPlanetModelFit dvPlanetModelFit) {
            // For trapezoidal fit, the limb-darkening model name is NULL in the database
            final String ldmn = dvPlanetModelFit.getLimbDarkeningModelName();
            limbDarkeningModelName = (ldmn == null) ? "N/A" : ldmn; 
            modelChiSquare = dvPlanetModelFit.getModelChiSquare();
            modelDegreesOfFreedom = dvPlanetModelFit.getModelDegreesOfFreedom();
            modelParametersCovariance = Floats.toArray(dvPlanetModelFit.getModelParameterCovariance());
            planetNumber = dvPlanetModelFit.getPlanetNumber();
            transitModelName = dvPlanetModelFit.getTransitModelName();
            planetModelFitType = dvPlanetModelFit.getType()
                .getName();
            modelParameters = new ArrayList<ModelParameterContainer>();
            for (DvModelParameter dvModelParameter : dvPlanetModelFit.getModelParameters()) {
                modelParameters.add(new ModelParameterContainer(
                    dvModelParameter));
            }
        }
    }

    public static class ModelParameterContainer implements Persistable {
        public String name = "";
        public double value = Double.NaN;
        public float uncertainty = Float.NaN;
        public boolean fitted;

        public ModelParameterContainer() {
        }

        public ModelParameterContainer(DvModelParameter dvModelParameter) {
            name = dvModelParameter.getName();
            value = dvModelParameter.getValue();
            uncertainty = dvModelParameter.getUncertainty();
            fitted = dvModelParameter.isFitted();
        }
    }

    public static class CentroidContainer implements Persistable {
        public CentroidMotionContainer fluxWeightedCentroidResults = new CentroidMotionContainer();
        public CentroidMotionContainer prfMotionCentroidResults = new CentroidMotionContainer();
        public DifferenceImageMotionContainer differenceImageMotionResults = new DifferenceImageMotionContainer();
        public PixelCorrelationMotionContainer pixelCorrelationMotionResults = new PixelCorrelationMotionContainer();

        public CentroidContainer() {
        }

        public CentroidContainer(DvCentroidResults dvCentroidResults) {
            DvCentroidMotionResults dvCentroidMotionResults = dvCentroidResults.getFluxWeightedMotionResults();
            if (dvCentroidMotionResults != null) {
                fluxWeightedCentroidResults = new CentroidMotionContainer(
                    dvCentroidMotionResults);
            }
            dvCentroidMotionResults = dvCentroidResults.getPrfMotionResults();
            if (dvCentroidMotionResults != null) {
                prfMotionCentroidResults = new CentroidMotionContainer(
                    dvCentroidMotionResults);
            }
            DvDifferenceImageMotionResults dvDifferenceImageMotionResults = dvCentroidResults.getDifferenceImageMotionResults();
            if (dvDifferenceImageMotionResults != null) {
                differenceImageMotionResults = new DifferenceImageMotionContainer(
                    dvDifferenceImageMotionResults);
            }
            DvPixelCorrelationMotionResults dvPixelCorrelationMotionResults = dvCentroidResults.getPixelCorrelationMotionResults();
            if (dvPixelCorrelationMotionResults != null) {
                pixelCorrelationMotionResults = new PixelCorrelationMotionContainer(
                    dvPixelCorrelationMotionResults);
            }
        }
    }

    public static class CentroidMotionContainer implements Persistable {
        public float motionDetectionStatisticValue = Float.NaN;
        public float motionDetectionStatisticSignificance = Float.NaN;
        public float peakDecOffsetValue = Float.NaN;
        public float peakDecOffsetUncertainty = Float.NaN;
        public float peakRaOffsetValue = Float.NaN;
        public float peakRaOffsetUncertainty = Float.NaN;
        public double sourceDecDegreesValue = Double.NaN;
        public float sourceDecDegreesUncertainty = Float.NaN;
        public float sourceDecOffsetValue = Float.NaN;
        public float sourceDecOffsetUncertainty = Float.NaN;
        public double sourceRaHoursValue = Double.NaN;
        public float sourceRaHoursUncertainty = Float.NaN;
        public float sourceRaOffsetValue = Float.NaN;
        public float sourceRaOffsetUncertainty = Float.NaN;

        public CentroidMotionContainer() {
        }

        public CentroidMotionContainer(
            DvCentroidMotionResults dvCentroidMotionResults) {
            motionDetectionStatisticValue = dvCentroidMotionResults.getMotionDetectionStatistic()
                .getValue();
            motionDetectionStatisticSignificance = dvCentroidMotionResults.getMotionDetectionStatistic()
                .getSignificance();

            sourceRaHoursValue = dvCentroidMotionResults.getSourceRaHours()
                .getValue();
            sourceRaHoursUncertainty = dvCentroidMotionResults.getSourceRaHours()
                .getUncertainty();

            sourceDecDegreesValue = dvCentroidMotionResults.getSourceDecDegrees()
                .getValue();
            sourceDecDegreesUncertainty = dvCentroidMotionResults.getSourceDecDegrees()
                .getUncertainty();

            DvQuantity sourceRaOffset = dvCentroidMotionResults.getSourceRaOffset();
            if (sourceRaOffset != null) {
                sourceRaOffsetValue = sourceRaOffset.getValue();
                sourceRaOffsetUncertainty = sourceRaOffset.getUncertainty();
            }

            DvQuantity sourceDecOffset = dvCentroidMotionResults.getSourceDecOffset();
            if (sourceDecOffset != null) {
                sourceDecOffsetValue = sourceDecOffset.getValue();
                sourceDecOffsetUncertainty = sourceDecOffset.getUncertainty();
            }

            DvQuantity peakRaOffset = dvCentroidMotionResults.getPeakRaOffset();
            if (peakRaOffset != null) {
                peakRaOffsetValue = peakRaOffset.getValue();
                peakRaOffsetUncertainty = peakRaOffset.getUncertainty();
            }

            DvQuantity peakDecOffset = dvCentroidMotionResults.getPeakDecOffset();
            if (peakDecOffset != null) {
                peakDecOffsetValue = peakDecOffset.getValue();
                peakDecOffsetUncertainty = peakDecOffset.getUncertainty();
            }
        }
    }

    public static class DifferenceImageMotionContainer implements Persistable {
        public MqCentroidOffsetsContainer mqControlCentroidOffsets = new MqCentroidOffsetsContainer();
        public MqCentroidOffsetsContainer mqKicCentroidOffsets = new MqCentroidOffsetsContainer();
        public MqImageCentroidContainer mqControlImageCentroid = new MqImageCentroidContainer();
        public MqImageCentroidContainer mqDifferenceImageCentroid = new MqImageCentroidContainer();
        public SummaryQualityMetricContainer summaryQualityMetric = new SummaryQualityMetricContainer();

        public DifferenceImageMotionContainer() {
        }

        public DifferenceImageMotionContainer(
            DvDifferenceImageMotionResults dvDifferenceImageMotionResults) {

            DvMqCentroidOffsets dvMqCentroidOffsets = dvDifferenceImageMotionResults.getMqControlCentroidOffsets();
            if (dvMqCentroidOffsets != null) {
                mqControlCentroidOffsets = new MqCentroidOffsetsContainer(
                    dvMqCentroidOffsets);
            }
            dvMqCentroidOffsets = dvDifferenceImageMotionResults.getMqKicCentroidOffsets();
            if (dvMqCentroidOffsets != null) {
                mqKicCentroidOffsets = new MqCentroidOffsetsContainer(
                    dvMqCentroidOffsets);
            }
            DvMqImageCentroid dvMqImageCentroid = dvDifferenceImageMotionResults.getMqControlImageCentroid();
            if (dvMqImageCentroid != null) {
                mqControlImageCentroid = new MqImageCentroidContainer(
                    dvMqImageCentroid);
            }
            dvMqImageCentroid = dvDifferenceImageMotionResults.getMqDifferenceImageCentroid();
            if (dvMqImageCentroid != null) {
                mqDifferenceImageCentroid = new MqImageCentroidContainer(
                    dvMqImageCentroid);
            }
            DvSummaryQualityMetric dvSummaryQualityMetric = dvDifferenceImageMotionResults.getSummaryQualityMetric();
            if (dvSummaryQualityMetric != null) {
                summaryQualityMetric = new SummaryQualityMetricContainer(
                    dvSummaryQualityMetric);
            }
        }
    }

    public static class MqCentroidOffsetsContainer implements Persistable {
        public float meanDecOffsetValue = Float.NaN;
        public float meanDecOffsetUncertainty = Float.NaN;
        public float meanRaOffsetValue = Float.NaN;
        public float meanRaOffsetUncertainty = Float.NaN;
        public float meanSkyOffsetValue = Float.NaN;
        public float meanSkyOffsetUncertainty = Float.NaN;
        public float singleFitDecOffsetValue = Float.NaN;
        public float singleFitDecOffsetUncertainty = Float.NaN;
        public float singleFitRaOffsetValue = Float.NaN;
        public float singleFitRaOffsetUncertainty = Float.NaN;
        public float singleFitSkyOffsetValue = Float.NaN;
        public float singleFitSkyOffsetUncertainty = Float.NaN;

        public MqCentroidOffsetsContainer() {
        }

        public MqCentroidOffsetsContainer(
            DvMqCentroidOffsets dvMqCentroidOffsets) {
            DvQuantity meanDecOffset = dvMqCentroidOffsets.getMeanDecOffset();
            if (meanDecOffset != null) {
                meanDecOffsetValue = meanDecOffset.getValue();
                meanDecOffsetUncertainty = meanDecOffset.getUncertainty();
            }
            DvQuantity meanRaOffset = dvMqCentroidOffsets.getMeanRaOffset();
            if (meanRaOffset != null) {
                meanRaOffsetValue = meanRaOffset.getValue();
                meanRaOffsetUncertainty = meanRaOffset.getUncertainty();
            }
            DvQuantity meanSkyOffset = dvMqCentroidOffsets.getMeanSkyOffset();
            if (meanSkyOffset != null) {
                meanSkyOffsetValue = meanSkyOffset.getValue();
                meanSkyOffsetUncertainty = meanSkyOffset.getUncertainty();
            }
            DvQuantity singleFitDecOffset = dvMqCentroidOffsets.getSingleFitDecOffset();
            if (singleFitDecOffset != null) {
                singleFitDecOffsetValue = singleFitDecOffset.getValue();
                singleFitDecOffsetUncertainty = singleFitDecOffset.getUncertainty();
            }
            DvQuantity singleFitRaOffset = dvMqCentroidOffsets.getSingleFitRaOffset();
            if (singleFitRaOffset != null) {
                singleFitRaOffsetValue = singleFitRaOffset.getValue();
                singleFitRaOffsetUncertainty = singleFitRaOffset.getUncertainty();
            }
            DvQuantity singleFitSkyOffset = dvMqCentroidOffsets.getSingleFitSkyOffset();
            if (singleFitSkyOffset != null) {
                singleFitSkyOffsetValue = singleFitSkyOffset.getValue();
                singleFitSkyOffsetUncertainty = singleFitSkyOffset.getUncertainty();
            }
        }
    }

    public static class MqImageCentroidContainer implements Persistable {
        public double decDegreesValue;
        public float decDegreesUncertainty = Float.NaN;
        public double raHoursValue;
        public float raHoursUncertainty = Float.NaN;

        public MqImageCentroidContainer() {
        }

        public MqImageCentroidContainer(DvMqImageCentroid dvMqImageCentroid) {
            DvDoubleQuantity decDegrees = dvMqImageCentroid.getDecDegrees();
            if (decDegrees != null) {
                decDegreesValue = decDegrees.getValue();
                decDegreesUncertainty = decDegrees.getUncertainty();
            }
            DvDoubleQuantity raHours = dvMqImageCentroid.getRaHours();
            if (raHours != null) {
                raHoursValue = raHours.getValue();
                raHoursUncertainty = raHours.getUncertainty();
            }
        }
    }

    public static class SummaryQualityMetricContainer implements Persistable {
        public float fractionOfGoodMetrics = Float.NaN;
        public int numberOfAttempts;
        public int numberOfGoodMetrics;
        public int numberOfMetrics;
        public float qualityThreshold = Float.NaN;

        public SummaryQualityMetricContainer() {
        }

        public SummaryQualityMetricContainer(
            DvSummaryQualityMetric dvSummaryQualityMetric) {
            fractionOfGoodMetrics = dvSummaryQualityMetric.getFractionOfGoodMetrics();
            numberOfAttempts = dvSummaryQualityMetric.getNumberOfAttempts();
            numberOfGoodMetrics = dvSummaryQualityMetric.getNumberOfGoodMetrics();
            numberOfMetrics = dvSummaryQualityMetric.getNumberOfMetrics();
            qualityThreshold = dvSummaryQualityMetric.getQualityThreshold();
        }
    }

    public static class GhostDiagnosticContainer implements Persistable {
        public StatisticContainer coreApertureCorrelationStatistic = new StatisticContainer();
        public StatisticContainer haloApertureCorrelationStatistic = new StatisticContainer();

        public GhostDiagnosticContainer() {
        }

        public GhostDiagnosticContainer(
            DvGhostDiagnosticResults dvGhostDiagnosticResults) {
            DvStatistic dvStatistic = dvGhostDiagnosticResults.getCoreApertureCorrelationStatistic();
            if (dvStatistic != null) {
                coreApertureCorrelationStatistic = new StatisticContainer(
                    dvStatistic);
            }
            dvStatistic = dvGhostDiagnosticResults.getHaloApertureCorrelationStatistic();
            if (dvStatistic != null) {
                haloApertureCorrelationStatistic = new StatisticContainer(
                    dvStatistic);
            }
        }
    }

    public static class PixelCorrelationMotionContainer implements Persistable {
        public MqCentroidOffsetsContainer mqControlCentroidOffsets = new MqCentroidOffsetsContainer();
        public MqCentroidOffsetsContainer mqKicCentroidOffsets = new MqCentroidOffsetsContainer();
        public MqImageCentroidContainer mqControlImageCentroid = new MqImageCentroidContainer();
        public MqImageCentroidContainer mqCorrelationImageCentroid = new MqImageCentroidContainer();

        public PixelCorrelationMotionContainer() {
        }

        public PixelCorrelationMotionContainer(
            DvPixelCorrelationMotionResults dvPixelCorrelationMotionResults) {
            DvMqCentroidOffsets dvMqCentroidOffsets = dvPixelCorrelationMotionResults.getMqControlCentroidOffsets();
            if (dvMqCentroidOffsets != null) {
                mqControlCentroidOffsets = new MqCentroidOffsetsContainer(
                    dvMqCentroidOffsets);
            }
            dvMqCentroidOffsets = dvPixelCorrelationMotionResults.getMqKicCentroidOffsets();
            if (dvMqCentroidOffsets != null) {
                mqKicCentroidOffsets = new MqCentroidOffsetsContainer(
                    dvMqCentroidOffsets);
            }
            DvMqImageCentroid dvMqImageCentroid = dvPixelCorrelationMotionResults.getMqControlImageCentroid();
            if (dvMqImageCentroid != null) {
                mqControlImageCentroid = new MqImageCentroidContainer(
                    dvMqImageCentroid);
            }
            dvMqImageCentroid = dvPixelCorrelationMotionResults.getMqCorrelationImageCentroid();
            if (dvMqImageCentroid != null) {
                mqCorrelationImageCentroid = new MqImageCentroidContainer(
                    dvMqImageCentroid);
            }
        }
    }

    public static class PlanetCandidateContainer implements Persistable {
        public int planetNumber;
        public int expectedTransitCount;
        public int observedTransitCount;
        public boolean suspectedEclipsingBinary;
        public double significance = Double.NaN;
        public double epochMjd = Double.NaN;
        public int keplerId;
        public float maxMultipleEventSigma = Float.NaN;
        public float maxSingleEventSigma = Float.NaN;
        public float modelChiSquare2 = Float.NaN;
        public int modelChiSquareDof2;
        public float modelChiSquareGof = Float.NaN;
        public int modelChiSquareGofDof;
        public double orbitalPeriod = Float.NaN;
        public float trialTransitPulseDuration = Float.NaN;
        public int bootstrapFinalSkipCount;
        public List<Float> bootstrapHistogramStatistics = newArrayList();
        public List<Float> bootstrapHistogramProbabilities = newArrayList();

        public PlanetCandidateContainer() {
        }

        public PlanetCandidateContainer(DvPlanetCandidate dvPlanetCandidate) {
            planetNumber = dvPlanetCandidate.getPlanetNumber();
            expectedTransitCount = dvPlanetCandidate.getExpectedTransitCount();
            observedTransitCount = dvPlanetCandidate.getObservedTransitCount();
            suspectedEclipsingBinary = dvPlanetCandidate.isSuspectedEclipsingBinary();
            significance = dvPlanetCandidate.getSignificance();
            epochMjd = dvPlanetCandidate.getEpochMjd();
            keplerId = dvPlanetCandidate.getKeplerId();
            maxMultipleEventSigma = dvPlanetCandidate.getMaxMultipleEventSigma();
            maxSingleEventSigma = dvPlanetCandidate.getMaxSingleEventSigma();
            modelChiSquare2 = dvPlanetCandidate.getModelChiSquare2();
            modelChiSquareDof2 = dvPlanetCandidate.getModelChiSquareDof2();
            modelChiSquareGof = dvPlanetCandidate.getModelChiSquareGof();
            modelChiSquareGofDof = dvPlanetCandidate.getModelChiSquareGofDof();
            orbitalPeriod = dvPlanetCandidate.getOrbitalPeriod();
            trialTransitPulseDuration = dvPlanetCandidate.getTrialTransitPulseDuration();

            DvBootstrapHistogram bsHist = dvPlanetCandidate.getBootstrapHistogram();
            bootstrapFinalSkipCount = bsHist.getFinalSkipCount();
            bootstrapHistogramProbabilities = bsHist.getProbabilities();
            bootstrapHistogramStatistics = bsHist.getStatistics();

        }
    }

    public static class PixelCorrelationContainer implements Persistable {
        public CentroidOffsetsContainer controlCentroidOffsets = new CentroidOffsetsContainer();
        public ImageCentroidContainer controlImageCentroid = new ImageCentroidContainer();
        public ImageCentroidContainer correlationImageCentroid = new ImageCentroidContainer();
        public CentroidOffsetsContainer kicCentroidOffsets = new CentroidOffsetsContainer();
        public ImageCentroidContainer kicReferenceCentroid = new ImageCentroidContainer();
        public List<PixelStatisticContainer> pixelCorrelationStatistics = newArrayList();

        public PixelCorrelationContainer() {
        }

        public PixelCorrelationContainer(
            DvPixelCorrelationResults dvPixelCorrelationResults) {
            DvCentroidOffsets dvCentroidOffsets = dvPixelCorrelationResults.getControlCentroidOffsets();
            if (dvCentroidOffsets != null) {
                controlCentroidOffsets = new CentroidOffsetsContainer(
                    dvCentroidOffsets);
            }
            DvImageCentroid dvImageCentroid = dvPixelCorrelationResults.getControlImageCentroid();
            if (dvImageCentroid != null) {
                controlImageCentroid = new ImageCentroidContainer(
                    dvImageCentroid);
            }
            dvImageCentroid = dvPixelCorrelationResults.getCorrelationImageCentroid();
            if (dvImageCentroid != null) {
                correlationImageCentroid = new ImageCentroidContainer(
                    dvImageCentroid);
            }
            dvCentroidOffsets = dvPixelCorrelationResults.getKicCentroidOffsets();
            if (dvCentroidOffsets != null) {
                kicCentroidOffsets = new CentroidOffsetsContainer(
                    dvCentroidOffsets);
            }
            dvImageCentroid = dvPixelCorrelationResults.getKicReferenceCentroid();
            if (dvImageCentroid != null) {
                kicReferenceCentroid = new ImageCentroidContainer(
                    dvImageCentroid);
            }
            pixelCorrelationStatistics = new ArrayList<PixelStatisticContainer>();
            for (DvPixelStatistic dvPixelStatistic : dvPixelCorrelationResults.getPixelCorrelationStatistics()) {
                pixelCorrelationStatistics.add(new PixelStatisticContainer(
                    dvPixelStatistic));
            }
        }
    }

    public static class CentroidOffsetsContainer implements Persistable {
        public float rowOffsetValue = Float.NaN;
        public float rowOffsetUncertainty = Float.NaN;
        public float columnOffsetValue = Float.NaN;
        public float columnOffsetUncertainty = Float.NaN;
        public float focalPlaneOffsetValue = Float.NaN;
        public float focalPlaneOffsetUncertainty = Float.NaN;
        public float raOffsetValue = Float.NaN;
        public float raOffsetUncertainty = Float.NaN;
        public float decOffsetValue = Float.NaN;
        public float decOffsetUncertainty = Float.NaN;
        public float skyOffsetValue = Float.NaN;
        public float skyOffsetUncertainty = Float.NaN;

        public CentroidOffsetsContainer() {
        }

        public CentroidOffsetsContainer(DvCentroidOffsets centroidOffsets) {
            DvQuantity rowOffset = centroidOffsets.getRowOffset();
            if (rowOffset != null) {
                rowOffsetValue = rowOffset.getValue();
                rowOffsetUncertainty = rowOffset.getUncertainty();
            }
            DvQuantity columnOffset = centroidOffsets.getColumnOffset();
            if (columnOffset != null) {
                columnOffsetValue = columnOffset.getValue();
                columnOffsetUncertainty = columnOffset.getUncertainty();
            }
            DvQuantity focalPlaneOffset = centroidOffsets.getFocalPlaneOffset();
            if (focalPlaneOffset != null) {
                focalPlaneOffsetValue = focalPlaneOffset.getValue();
                focalPlaneOffsetUncertainty = focalPlaneOffset.getUncertainty();
            }
            DvQuantity raOffset = centroidOffsets.getRaOffset();
            if (raOffset != null) {
                raOffsetValue = raOffset.getValue();
                raOffsetUncertainty = raOffset.getUncertainty();
            }
            DvQuantity decOffset = centroidOffsets.getDecOffset();
            if (decOffset != null) {
                decOffsetValue = decOffset.getValue();
                decOffsetUncertainty = decOffset.getUncertainty();
            }
            DvQuantity skyOffset = centroidOffsets.getSkyOffset();
            if (skyOffset != null) {
                skyOffsetValue = skyOffset.getValue();
                skyOffsetUncertainty = skyOffset.getUncertainty();
            }
        }
    }

    public static class ImageCentroidContainer implements Persistable {
        public float columnValue = Float.NaN;
        public float columnUncertainty = Float.NaN;
        public double decDegreesValue = Double.NaN;
        public float decDegreesUncertainty = Float.NaN;
        public double raHoursValue = Double.NaN;
        public float raHoursUncertainty = Float.NaN;
        public float rowValue = Float.NaN;
        public float rowUncertainty = Float.NaN;

        public ImageCentroidContainer() {
        }

        public ImageCentroidContainer(DvImageCentroid imageCentroid) {
            DvQuantity column = imageCentroid.getColumn();
            if (column != null) {
                columnValue = column.getValue();
                columnUncertainty = column.getUncertainty();
            }
            DvDoubleQuantity decDegrees = imageCentroid.getDecDegrees();
            if (decDegrees != null) {
                decDegreesValue = decDegrees.getValue();
                decDegreesUncertainty = decDegrees.getUncertainty();
            }
            DvDoubleQuantity raHours = imageCentroid.getRaHours();
            if (raHours != null) {
                raHoursValue = raHours.getValue();
                raHoursUncertainty = raHours.getUncertainty();
            }
            DvQuantity row = imageCentroid.getRow();
            if (row != null) {
                rowValue = row.getValue();
                rowUncertainty = row.getUncertainty();
            }
        }
    }

    public static class PixelStatisticContainer implements Persistable {
        public int ccdRow;
        public int ccdColumn;
        public float value = Float.NaN;
        public float significance = Float.NaN;

        public PixelStatisticContainer(DvPixelStatistic dvPixelStatistic) {
            ccdRow = dvPixelStatistic.getCcdRow();
            ccdColumn = dvPixelStatistic.getCcdColumn();
            value = dvPixelStatistic.getValue();
            significance = dvPixelStatistic.getSignificance();
        }
    }

    public static class DifferenceImageContainer implements Persistable {
        public CentroidOffsetsContainer controlCentroidOffsets = new CentroidOffsetsContainer();
        public ImageCentroidContainer controlImageCentroid = new ImageCentroidContainer();
        public ImageCentroidContainer differenceImageCentroid = new ImageCentroidContainer();
        public CentroidOffsetsContainer kicCentroidOffsets = new CentroidOffsetsContainer();
        public ImageCentroidContainer kicReferenceCentroid = new ImageCentroidContainer();
        public int numberOfTransits;
        public int numberOfCadencesInTransit;
        public int numberOfCadenceGapsInTransit;
        public int numberOfCadencesOutOfTransit;
        public int numberOfCadenceGapsOutOfTransit;
        public QualityMetricContainer qualityMetric = new QualityMetricContainer();
        public List<DifferenceImagePixelDataContainer> differenceImagePixelData;

        public DifferenceImageContainer(
            DvDifferenceImageResults dvDifferenceImageResults) {
            DvCentroidOffsets dvCentroidOffsets = dvDifferenceImageResults.getControlCentroidOffsets();
            if (dvCentroidOffsets != null) {
                controlCentroidOffsets = new CentroidOffsetsContainer(
                    dvCentroidOffsets);
            }
            DvImageCentroid dvImageCentroid = dvDifferenceImageResults.getControlImageCentroid();
            if (dvImageCentroid != null) {
                controlImageCentroid = new ImageCentroidContainer(
                    dvImageCentroid);
            }
            dvImageCentroid = dvDifferenceImageResults.getDifferenceImageCentroid();
            if (dvImageCentroid != null) {
                differenceImageCentroid = new ImageCentroidContainer(
                    dvImageCentroid);
            }
            dvCentroidOffsets = dvDifferenceImageResults.getKicCentroidOffsets();
            if (dvCentroidOffsets != null) {
                kicCentroidOffsets = new CentroidOffsetsContainer(
                    dvCentroidOffsets);
            }
            dvImageCentroid = dvDifferenceImageResults.getKicReferenceCentroid();
            if (dvImageCentroid != null) {
                kicReferenceCentroid = new ImageCentroidContainer(
                    dvImageCentroid);
            }
            numberOfTransits = dvDifferenceImageResults.getNumberOfTransits();
            numberOfCadencesInTransit = dvDifferenceImageResults.getNumberOfCadencesInTransit();
            numberOfCadenceGapsInTransit = dvDifferenceImageResults.getNumberOfCadenceGapsInTransit();
            numberOfCadencesOutOfTransit = dvDifferenceImageResults.getNumberOfCadencesOutOfTransit();
            numberOfCadenceGapsOutOfTransit = dvDifferenceImageResults.getNumberOfCadenceGapsOutOfTransit();
            qualityMetric = new QualityMetricContainer(
                dvDifferenceImageResults.getQualityMetric());

            differenceImagePixelData = new ArrayList<DifferenceImagePixelDataContainer>();
            for (DvDifferenceImagePixelData dvDifferenceImagePixelData : dvDifferenceImageResults.getDifferenceImagePixelData()) {
                differenceImagePixelData.add(new DifferenceImagePixelDataContainer(
                    dvDifferenceImagePixelData));
            }
        }
    }

    public static class QualityMetricContainer implements Persistable {
        public boolean attempted;
        public boolean valid;
        public float value = Float.NaN;

        public QualityMetricContainer() {
        }

        public QualityMetricContainer(DvQualityMetric qualityMetric) {
            attempted = qualityMetric.isAttempted();
            valid = qualityMetric.isValid();
            value = qualityMetric.getValue();
        }
    }

    public static class DifferenceImagePixelDataContainer implements
        Persistable {
        public int ccdRow;
        public int ccdColumn;
        public float meanFluxInTransitValue = Float.NaN;
        public float meanFluxInTransitUncertainty = Float.NaN;
        public float meanFluxOutOfTransitValue = Float.NaN;
        public float meanFluxOutOfTransitUncertainty = Float.NaN;
        public float meanFluxDifferenceValue = Float.NaN;
        public float meanFluxDifferenceUncertainty = Float.NaN;
        public float meanFluxForTargetTableValue = Float.NaN;
        public float meanFluxForTargetTableUncertainty = Float.NaN;

        public DifferenceImagePixelDataContainer(
            DvDifferenceImagePixelData dvDifferenceImagePixelData) {
            ccdRow = dvDifferenceImagePixelData.getCcdRow();
            ccdColumn = dvDifferenceImagePixelData.getCcdColumn();
            DvQuantity dvQuantity = dvDifferenceImagePixelData.getMeanFluxInTransit();
            if (dvQuantity != null) {
                meanFluxInTransitValue = dvQuantity.getValue();
                meanFluxInTransitUncertainty = dvQuantity.getUncertainty();
            }
            dvQuantity = dvDifferenceImagePixelData.getMeanFluxOutOfTransit();
            if (dvQuantity != null) {
                meanFluxOutOfTransitValue = dvQuantity.getValue();
                meanFluxOutOfTransitUncertainty = dvQuantity.getUncertainty();
            }
            dvQuantity = dvDifferenceImagePixelData.getMeanFluxDifference();
            if (dvQuantity != null) {
                meanFluxDifferenceValue = dvQuantity.getValue();
                meanFluxDifferenceUncertainty = dvQuantity.getUncertainty();
            }
            dvQuantity = dvDifferenceImagePixelData.getMeanFluxForTargetTable();
            if (dvQuantity != null) {
                meanFluxForTargetTableValue = dvQuantity.getValue();
                meanFluxForTargetTableUncertainty = dvQuantity.getUncertainty();
            }
        }
    }

    public SbtRetrieveDvPlanetResults() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveDvPlanetResults(List<Integer> keplerIds)
        throws Exception {
        if (!validateDatastores()) {
            return "";
        }

        TicToc.tic("Retrieving DV planet results...");

        DatabaseService dbInstance = DatabaseServiceFactory.getInstance();
        DvCrud dvCrud = new DvCrud(dbInstance);
        DvContainer dvContainer = new DvContainer();

        List<DvPlanetResults> dvPlanetResults = dvCrud.retrieveLatestPlanetResults(keplerIds);
        int i = 0;
        for (DvPlanetResults dvPlanetResult : dvPlanetResults) {
            System.out.println("Test of dv loop: " + ++i + ": "
                + dvPlanetResult.toString());
            OneDvResult oneDvResult = new OneDvResult(dvPlanetResult);
            dvContainer.results.add(oneDvResult);
        }

        TicToc.toc();
        return makeSdf(dvContainer, SDF_FILE_NAME);
    }

    public String retrieveDvPlanetResults(int[] keplerIds) throws Exception {
        List<Integer> keplerIdsList = new ArrayList<Integer>();
        for (int keplerId : keplerIds) {
            keplerIdsList.add(keplerId);
        }
        return retrieveDvPlanetResults(keplerIdsList);
    }

    public static void main(String[] args) throws Exception {
        SbtRetrieveDvPlanetResults sbt = new SbtRetrieveDvPlanetResults();
        List<Integer> keplerIds = new ArrayList<Integer>();
        keplerIds.add(7875476);
        keplerIds.add(8218649);
        keplerIds.add(8150327);
        String path = sbt.retrieveDvPlanetResults(keplerIds);
        System.out.println(path);
    }

}
