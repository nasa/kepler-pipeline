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
import static com.google.common.collect.Maps.newLinkedHashMap;
import static com.google.common.collect.Sets.newLinkedHashSet;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.DETRENDED;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvCorrectedFluxType.INITIAL;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.TRAPEZOIDAL_MODEL_LIGHT_CURVE;
import static gov.nasa.kepler.mc.fs.DvFsIdFactory.DvLightCurveType.WHITENED_MODEL_LIGHT_CURVE;
import gov.nasa.kepler.cal.io.CalCompressionTimeSeries;
import gov.nasa.kepler.cal.io.HuffmanTable;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.CollateralType;
import gov.nasa.kepler.common.ConfigMap;
import gov.nasa.kepler.common.EnumList;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.common.utils.ReflectionEqualsMatcher;
import gov.nasa.kepler.fc.invalidpixels.PixelOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.FsIdSetMatcher;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
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
import gov.nasa.kepler.hibernate.dv.DvDoubleQuantityWithProvenance;
import gov.nasa.kepler.hibernate.dv.DvGhostDiagnosticResults;
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
import gov.nasa.kepler.hibernate.dv.DvPlanetResults;
import gov.nasa.kepler.hibernate.dv.DvPlanetStatistic;
import gov.nasa.kepler.hibernate.dv.DvQualityMetric;
import gov.nasa.kepler.hibernate.dv.DvQuantity;
import gov.nasa.kepler.hibernate.dv.DvQuantityWithProvenance;
import gov.nasa.kepler.hibernate.dv.DvStatistic;
import gov.nasa.kepler.hibernate.dv.DvSummaryOverlapMetric;
import gov.nasa.kepler.hibernate.dv.DvSummaryQualityMetric;
import gov.nasa.kepler.hibernate.dv.DvTargetResults;
import gov.nasa.kepler.hibernate.dv.DvWeakSecondary;
import gov.nasa.kepler.hibernate.fc.PixelType;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.kepler.hibernate.mc.DoubleTimeSeriesType;
import gov.nasa.kepler.hibernate.pdc.PdcBand;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppDuration;
import gov.nasa.kepler.hibernate.ppa.PmdMetricReport.CdppMagnitude;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.hibernate.tps.WeakSecondaryDb;
import gov.nasa.kepler.mc.CompoundIndicesTimeSeries;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.MqTimestampSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SimpleIndicesTimeSeries;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.configmap.ConfigMapOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.MetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.TargetMetricsTimeSeriesType;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvSingleEventStatisticsType;
import gov.nasa.kepler.mc.fs.DvFsIdFactory.DvTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.BlobSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CosmicRayMetricType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.MetricTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFluxTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory;
import gov.nasa.kepler.mc.fs.PpaFsIdFactory.TimeSeriesType;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.gar.RequantTable;
import gov.nasa.kepler.mc.tps.TpsOperations;
import gov.nasa.spiffy.common.CentroidTimeSeries;
import gov.nasa.spiffy.common.CompoundFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleDoubleTimeSeries;
import gov.nasa.spiffy.common.SimpleFloatTimeSeries;
import gov.nasa.spiffy.common.SimpleIntTimeSeries;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.hamcrest.TypeSafeMatcher;
import org.hamcrest.core.IsAnything;
import org.hamcrest.core.IsEqual;
import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Test;

public class SbtDataOperationsTest extends JMockTest {

    private Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    @Test
    public void testRetrieve() throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, 4, 6, false, false, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveInvalidKeplerId() throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, 4, 6, true, false, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveInvalidStartCadence() throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, -1, 6, false, false, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveInvalidEndCadence() throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, 4, -1, false, false, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveEndCadenceLessThanStartCadence()
        throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, 6, 4, false, false, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveMissingStartCadence() throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, 4, 6, false, true, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveMissingEndCadence() throws IllegalAccessException {
        testRetrieveInternal(CadenceType.LONG, 4, 6, false, false, true);
    }

    @SuppressWarnings("unchecked")
    private void testRetrieveInternal(final CadenceType cadenceType,
        final int startCadenceMultiQuarter, final int endCadence,
        final boolean clearKics, final boolean missingStartCadenceMultiQuarter,
        final boolean missingEndCadence) throws IllegalAccessException {
        final int keplerId = 1;
        final List<Integer> keplerIds = newArrayList();
        keplerIds.add(keplerId);

        final int ccdModule = 2;
        final int ccdOutput = 3;

        final int startCadenceTargetTable = 5;

        final TargetType targetType = TargetType.LONG_CADENCE;
        final List<TargetType> targetTypes = newArrayList();
        targetTypes.add(targetType);

        final int targetTableId = 7;
        final int quarter = 8;
        final int season = 9;
        final int row = 10;
        final int column = 11;
        final boolean inOptimalAperture = true;

        final int skyGroupId = 12;
        final List<Integer> skyGroupIds = newArrayList();
        skyGroupIds.add(skyGroupId);

        final double startMjdTargetTable = 13;
        final double[] startMjdsTargetTable = new double[] { startMjdTargetTable };

        final double startMjdMultiQuarter = 13.5;

        final String label = "label";
        final Set<String> labels = new TreeSet<String>();
        labels.add(label);

        final double signalToNoiseRatio = 14;
        final float magnitude = 15;
        final double ra = 15.1;
        final double dec = 15.2;
        final float effectiveTemp = 15.3F;
        final float log10Metallicity = 15.4F;
        final float log10SurfaceGravity = 15.5F;
        final float radius = 15.6F;
        final String quartersObserved = "                                ";
        final int badPixelCount = 16;
        final double crowdingMetric = 17;
        final double skyCrowdingMetric = 18;
        final double fluxFractionInAperture = 19;
        final int distanceFromEdge = 20;
        final int saturatedRowCount = 2;

        final float trialTransitPulseInHours = 21;
        final double detectedOrbitalPeriodInDays = 22;
        final boolean isPlanetACandidate = true;
        final float maxSingleEventStatistic = 24;
        final float maxMultipleEventStatistic = 25;
        final float timeToFirstTransitInDays = 26;
        final float rmsCdpp = 27;
        final double timeOfFirstTransitInMjd = 28;

        final int planetNumber = 29;
        final String limbDarkeningModelName = "limbDarkeningModelName";
        final boolean fullConvergence = false;
        final float modelChiSquare = 30.30F;
        final float modelDegreesOfFreedom = 31.31F;
        final float modelFitSnr = 31.81F;

        final float modelParameterCovariance = 32.32F;

        final float[] modelParameterCovarianceArray = { modelParameterCovariance };

        final List<Float> modelParameterCovarianceList = newArrayList();
        modelParameterCovarianceList.add(modelParameterCovariance);

        final boolean seededWithPriorFit = true;
        final String transitModelName = "transitModelName";
        final String name = "name";
        final boolean fitted = true;
        final double valueDouble = 34.34;
        final float uncertainty = 35.35F;

        final float bootstrapMesMean = 123.456f;
        final float bootstrapMesStd = 456.789f;
        final float bootstrapThresholdForDesiredPfa = 9.3F;
        final float chiSquare1 = 35.36F;
        final float chiSquare2 = 35.37F;
        final int chiSquareDof1 = 35;
        final float chiSquareDof2 = 36.1F;
        final float robustStatistic = 35.38F;
        final float modelChiSquare2 = 35.39F;
        final int modelChiSquareDof2 = 37;
        final double epochMjd = 36.36;
        final float maxMultipleEventSigma = 37.37F;
        final float maxSingleEventSigma = 38.38F;
        final float modelChiSquareGof = 38.3838F;
        final int modelChiSquareGofDof = 3838;
        final float orbitalPeriod = 39.39F;
        final float trialTransitPulseDuration = 40.40F;
        final int expectedTransitCount = 41;
        final int observedTransitCount = 42;
        final float significance = 43.43F;
        final boolean statisticRatioBelowThreshold = true;
        final boolean suspectedEclipsingBinary = true;

        final int finalSkipCount = 44;

        final float probability = 45.45F;

        final float[] probabilitiesArray = { probability };

        final List<Float> probabilitiesList = newArrayList();
        probabilitiesList.add(probability);

        final float statistic = 46.46F;

        final float[] statisticsArray = { statistic };

        final List<Float> statisticsList = newArrayList();
        statisticsList.add(statistic);

        final float valueFloat = 47.47F;

        final long pipelineInstanceId = 48;
        final long pipelineTaskId = 49;

        final double badPixelValue = 50.50;

        final double endMjd = 51.51;

        final float minSingleEventStatistic = 42.23F;
        final float minMultipleEventStatistic = 52.52F;
        final float timeToFirstMicrolensInDays = 53.53F;
        final double timeOfFirstMicrolensInMjd = 54.54;
        final float detectedMicrolensOrbitalPeriodInDays = 55.55F;

        final double[] barycentricCorrectedTimestamps = new double[] { 56.56 };

        final int numberOfTransits = 57;
        final int numberOfCadencesInTransit = 58;
        final int numberOfCadenceGapsInTransit = 59;
        final int numberOfCadencesOutOfTransit = 60;
        final int numberOfCadenceGapsOutOfTransit = 61;

        final boolean attempted = true;
        final boolean valid = true;

        final String modelName = "modelName";
        final float coefficient1 = 62.62F;
        final float coefficient2 = 63.63F;
        final float coefficient3 = 64.64F;
        final float coefficient4 = 65.65F;

        final String pdcMethod = "regularMap";
        final int numDiscontinuitiesDetected = 3;
        final int numDiscontinuitiesRemoved = 2;
        final boolean harmonicsFitted = true;
        final boolean harmonicsRestored = false;
        final float targetVariability = 1.0F;
        final String fitType = "prior";
        final float priorWeight = 0.42F;
        final float priorGoodness = 1.0F;

        final DoubleTimeSeriesType attitudeSolutionDoubleTimeSeriesType = DoubleTimeSeriesType.PPA_RA;
        final List<DoubleTimeSeriesType> attitudeSolutionDoubleTimeSeriesTypeList = newArrayList();
        attitudeSolutionDoubleTimeSeriesTypeList.add(attitudeSolutionDoubleTimeSeriesType);

        final TimeSeriesType attitudeSolutionFloatTimeSeriesType = TimeSeriesType.COVARIANCE_MATRIX_1_1;
        final List<TimeSeriesType> attitudeSolutionFloatTimeSeriesTypeList = newArrayList();
        attitudeSolutionFloatTimeSeriesTypeList.add(attitudeSolutionFloatTimeSeriesType);

        final MetricsTimeSeriesType calMetricTimeSeriesType = MetricsTimeSeriesType.BLACK_LEVEL;
        final MetricsTimeSeriesType calMetricTimeSeriesTypeUncertainties = MetricsTimeSeriesType.BLACK_LEVEL_UNCERTAINTIES;
        final MetricsTimeSeriesType calCompressionMetricTimeSeriesType = MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY;
        final MetricsTimeSeriesType calCompressionMetricTimeSeriesTypeCounts = MetricsTimeSeriesType.ACHIEVED_COMPRESSION_EFFICIENCY_COUNTS;
        final List<MetricsTimeSeriesType> calMetricTimeSeriesTypes = newArrayList();
        calMetricTimeSeriesTypes.add(calMetricTimeSeriesType);
        calMetricTimeSeriesTypes.add(calMetricTimeSeriesTypeUncertainties);
        calMetricTimeSeriesTypes.add(calCompressionMetricTimeSeriesType);
        calMetricTimeSeriesTypes.add(calCompressionMetricTimeSeriesTypeCounts);

        final MetricTimeSeriesType paMetricTimeSeriesType = MetricTimeSeriesType.BRIGHTNESS;
        final MetricTimeSeriesType paMetricTimeSeriesTypeUncertainties = MetricTimeSeriesType.BRIGHTNESS_UNCERTAINTIES;
        final List<MetricTimeSeriesType> paMetricTimeSeriesTypes = newArrayList();
        paMetricTimeSeriesTypes.add(paMetricTimeSeriesType);
        paMetricTimeSeriesTypes.add(paMetricTimeSeriesTypeUncertainties);

        final TargetMetricsTimeSeriesType calTargetMetricTimeSeriesType = TargetMetricsTimeSeriesType.TWOD_BLACK;
        final TargetMetricsTimeSeriesType calTargetMetricTimeSeriesTypeUncertainties = TargetMetricsTimeSeriesType.TWOD_BLACK_UNCERTAINTIES;
        final List<TargetMetricsTimeSeriesType> calTargetMetricTimeSeriesTypes = newArrayList();
        calTargetMetricTimeSeriesTypes.add(calTargetMetricTimeSeriesType);
        calTargetMetricTimeSeriesTypes.add(calTargetMetricTimeSeriesTypeUncertainties);

        final gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType calCosmicRayMetricType = gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType.MEAN_ENERGY;
        final List<gov.nasa.kepler.mc.fs.CalFsIdFactory.CosmicRayMetricType> calCosmicRayMetricTypes = newArrayList();
        calCosmicRayMetricTypes.add(calCosmicRayMetricType);

        final CosmicRayMetricType paCosmicRayMetricType = CosmicRayMetricType.ENERGY_KURTOSIS;
        final List<CosmicRayMetricType> paCosmicRayMetricTypes = newArrayList();
        paCosmicRayMetricTypes.add(paCosmicRayMetricType);

        final TimeSeriesType pmdTimeSeriesType = TimeSeriesType.PLATE_SCALE;
        final TimeSeriesType pmdTimeSeriesTypeUncertainties = TimeSeriesType.PLATE_SCALE_UNCERTAINTIES;
        final List<TimeSeriesType> pmdTimeSeriesTypes = newArrayList();
        pmdTimeSeriesTypes.add(pmdTimeSeriesType);
        pmdTimeSeriesTypes.add(pmdTimeSeriesTypeUncertainties);

        final TimeSeriesType pagTimeSeriesType = TimeSeriesType.THEORETICAL_COMPRESSION_EFFICIENCY;
        final List<TimeSeriesType> pagTimeSeriesTypes = newArrayList();
        pagTimeSeriesTypes.add(pagTimeSeriesType);

        final TimeSeriesType pmdCdppTimeSeriesType = TimeSeriesType.CDPP_MEASURED_VALUES;
        final TimeSeriesType pmdCdppTimeSeriesTypeUncertainties = TimeSeriesType.CDPP_MEASURED_UNCERTAINTIES;
        final List<TimeSeriesType> pmdCdppTimeSeriesTypes = newArrayList();
        pmdCdppTimeSeriesTypes.add(pmdCdppTimeSeriesType);
        pmdCdppTimeSeriesTypes.add(pmdCdppTimeSeriesTypeUncertainties);

        final CdppMagnitude cdppMagnitude = CdppMagnitude.MAG12;
        final List<CdppMagnitude> cdppMagnitudes = newArrayList();
        cdppMagnitudes.add(cdppMagnitude);

        final CdppDuration cdppDuration = CdppDuration.THREE_HOUR;
        final List<CdppDuration> cdppDurations = newArrayList();
        cdppDurations.add(cdppDuration);

        final CentroidType centroidType = CentroidType.FLUX_WEIGHTED;
        final List<CentroidType> centroidTypes = newArrayList();
        centroidTypes.add(centroidType);

        final BlobSeriesType blobSeriesType = BlobSeriesType.MOTION;
        final List<BlobSeriesType> blobSeriesTypes = newArrayList();
        blobSeriesTypes.add(blobSeriesType);

        final CollateralType collateralType = CollateralType.VIRTUAL_SMEAR;
        final List<CollateralType> collateralTypes = newArrayList();
        collateralTypes.add(collateralType);

        final DvSingleEventStatisticsType dvSingleEventStatisticsType = DvSingleEventStatisticsType.CORRELATION;
        final List<DvSingleEventStatisticsType> dvSingleEventStatisticsTypes = newArrayList();
        dvSingleEventStatisticsTypes.add(dvSingleEventStatisticsType);

        final CorrectedFluxType correctedFluxType = CorrectedFluxType.HARMONIC_FREE;
        final List<CorrectedFluxType> correctedFluxTypes = newArrayList();
        correctedFluxTypes.add(correctedFluxType);

        final PdcFluxTimeSeriesType pdcFluxTimeSeriesType = correctedFluxType.getPdcFluxTimeSeriesType();
        final PdcFluxTimeSeriesType pdcFluxTimeSeriesTypeUncertainties = PdcFluxTimeSeriesType.HARMONIC_FREE_CORRECTED_FLUX_UNCERTAINTIES;
        final List<PdcFluxTimeSeriesType> pdcFluxTimeSeriesTypes = newArrayList();
        pdcFluxTimeSeriesTypes.add(pdcFluxTimeSeriesType);
        pdcFluxTimeSeriesTypes.add(pdcFluxTimeSeriesTypeUncertainties);

        final PdcOutliersTimeSeriesType pdcOutliersTimeSeriesType = correctedFluxType.getPdcOutliersTimeSeriesType();
        final PdcOutliersTimeSeriesType pdcOutliersTimeSeriesTypeUncertainties = PdcOutliersTimeSeriesType.HARMONIC_FREE_OUTLIER_UNCERTAINTIES;
        final List<PdcOutliersTimeSeriesType> pdcOutliersTimeSeriesTypes = newArrayList();
        pdcOutliersTimeSeriesTypes.add(pdcOutliersTimeSeriesType);
        pdcOutliersTimeSeriesTypes.add(pdcOutliersTimeSeriesTypeUncertainties);

        final List<PipelineProduct> pipelineProducts = newArrayList();
        for (PipelineProduct pipelineProduct : PipelineProduct.values()) {
            if (!pipelineProduct.equals(PipelineProduct.BACKGROUND_BLOBS)) {
                pipelineProducts.add(pipelineProduct);
            }
        }

        final PipelineProductLists pipelineProductLists = new PipelineProductLists();
        pipelineProductLists.setPipelineProductIncludeList(pipelineProducts);

        final PixelType pixelType = PixelType.GHOST;

        final PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(pipelineInstanceId);

        final PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(pipelineTaskId);
        pipelineTask.setPipelineInstance(pipelineInstance);

        final gov.nasa.kepler.hibernate.fc.Pixel badPixel = new gov.nasa.kepler.hibernate.fc.Pixel(
            ccdModule, ccdOutput, row, column, pixelType, startMjdTargetTable,
            endMjd, badPixelValue);
        final List<gov.nasa.kepler.hibernate.fc.Pixel> badPixels = newArrayList();
        badPixels.add(badPixel);

        final String baseDescription = "baseDescription";

        final boolean[] argabrighteningGapIndicators = new boolean[] { true,
            true, false };
        final int[] argabrighteningIndices = new int[] { 2 };

        final boolean[] discontinuityGapIndicators = new boolean[] { true,
            true, false };
        final int[] discontinuityIndices = new int[] { 2 };

        final FluxType fluxType = FluxType.SAP;
        final List<FluxType> fluxTypes = newArrayList();
        fluxTypes.add(fluxType);

        final List<PdcBand> bands = Arrays.asList(new PdcBand(fitType,
            priorWeight, priorGoodness));
        final PdcProcessingCharacteristics pdcProcessingCharacteristics = new PdcProcessingCharacteristics.Builder(
            pipelineTask.getId(), fluxType, cadenceType, keplerId).startCadence(
            startCadenceMultiQuarter)
            .endCadence(endCadence)
            .pdcMethod(pdcMethod)
            .numDiscontinuitiesDetected(numDiscontinuitiesDetected)
            .numDiscontinuitiesRemoved(numDiscontinuitiesRemoved)
            .harmonicsFitted(harmonicsFitted)
            .harmonicsRestored(harmonicsRestored)
            .targetVariability(targetVariability)
            .bands(bands)
            .build();

        final TpsType tpsType = TpsType.TPS_FULL;

        final MqTimestampSeries mqTimestampSeries = mockery.mock(MqTimestampSeries.class);

        final TimestampSeries timestampSeries = mockery.mock(TimestampSeries.class);

        final MjdToCadence mjdToCadence = mockery.mock(MjdToCadence.class);

        final TargetTable targetTable = new TargetTable(targetType);
        targetTable.setExternalId(targetTableId);

        final TargetTableLog targetTableLog = new TargetTableLog(targetTable,
            startCadenceTargetTable, endCadence);
        final List<TargetTableLog> targetTableLogs = newArrayList();
        targetTableLogs.add(targetTableLog);

        final Map<Integer, Integer> keplerIdToSkyGroupId = newLinkedHashMap();
        keplerIdToSkyGroupId.put(keplerId, skyGroupId);

        final SkyGroup skyGroup = new SkyGroup(skyGroupId, ccdModule,
            ccdOutput, season);

        final ObservedTarget observedTarget = new ObservedTarget(keplerId);
        observedTarget.setLabels(labels);
        observedTarget.setSignalToNoiseRatio(signalToNoiseRatio);
        observedTarget.setMagnitude(magnitude);
        observedTarget.setRa(ra);
        observedTarget.setDec(dec);
        observedTarget.setEffectiveTemp(effectiveTemp);
        observedTarget.setBadPixelCount(badPixelCount);
        observedTarget.setCrowdingMetric(crowdingMetric);
        observedTarget.setSkyCrowdingMetric(skyCrowdingMetric);
        observedTarget.setFluxFractionInAperture(fluxFractionInAperture);
        observedTarget.setDistanceFromEdge(distanceFromEdge);
        observedTarget.setSaturatedRowCount(saturatedRowCount);

        final List<ObservedTarget> observedTargets = newArrayList();
        observedTargets.add(observedTarget);

        final Pixel pixel = new Pixel(row, column, null, inOptimalAperture);
        final Set<Pixel> pixels = newLinkedHashSet();
        pixels.add(pixel);

        final CelestialObjectParameters celestialObjectParameters = mockery.mock(CelestialObjectParameters.class);
        final List<CelestialObjectParameters> celestialObjectParametersList = newArrayList();
        celestialObjectParametersList.add(celestialObjectParameters);

        final WeakSecondaryDb weakSecondary = new WeakSecondaryDb(1.0f, 2.0f,
            new float[] { 1.0f }, new float[] { 2.0f }, 3.0f, 4.0f, 5.0f, 6.0f,
            7.0f, 8.0f, 9, 10.0f);
        final TpsDbResult tpsDbResult = new TpsDbResult(keplerId,
            trialTransitPulseInHours, maxSingleEventStatistic, rmsCdpp,
            startCadenceMultiQuarter, endCadence, fluxType, pipelineTask,
            detectedOrbitalPeriodInDays, isPlanetACandidate,
            maxMultipleEventStatistic, timeToFirstTransitInDays,
            timeOfFirstTransitInMjd, minSingleEventStatistic,
            minMultipleEventStatistic, timeToFirstMicrolensInDays,
            timeOfFirstMicrolensInMjd, detectedMicrolensOrbitalPeriodInDays,
            true, 1.14f, weakSecondary, 5f, 6f, 7, 8.1f /* chiSquareDof2 */, 9.9f, 10.9f, 11, 12.0f);

        final List<TpsDbResult> tpsDbResults = newArrayList();
        tpsDbResults.add(tpsDbResult);

        final DvQuantity dvQuantity = new DvQuantity(valueFloat, uncertainty);

        final DvDoubleQuantity dvDoubleQuantity = new DvDoubleQuantity(
            valueDouble, uncertainty);

        final DvStatistic dvStatistic = new DvStatistic(valueFloat,
            significance);

        final DvPlanetStatistic dvPlanetStatistic = new DvPlanetStatistic(
            planetNumber, valueFloat, significance);

        final DvCentroidMotionResults dvCentroidMotionResults = new DvCentroidMotionResults(
            dvDoubleQuantity, dvDoubleQuantity, dvDoubleQuantity,
            dvDoubleQuantity, dvQuantity, dvQuantity, dvQuantity, dvQuantity,
            dvQuantity, dvQuantity, dvStatistic);

        final DvMqCentroidOffsets dvMqCentroidOffsets = new DvMqCentroidOffsets(
            dvQuantity, dvQuantity, dvQuantity, dvQuantity, dvQuantity,
            dvQuantity);

        final DvMqImageCentroid dvMqImageCentroid = new DvMqImageCentroid(
            dvDoubleQuantity, dvDoubleQuantity);

        final DvDifferenceImageMotionResults dvDifferenceImageMotionResults = new DvDifferenceImageMotionResults(
            dvMqCentroidOffsets, dvMqCentroidOffsets, dvMqImageCentroid,
            dvMqImageCentroid, new DvSummaryQualityMetric(),
            new DvSummaryOverlapMetric());

        final DvPixelCorrelationMotionResults dvPixelCorrelationMotionResults = new DvPixelCorrelationMotionResults(
            dvMqCentroidOffsets, dvMqCentroidOffsets, dvMqImageCentroid,
            dvMqImageCentroid);

        final DvBootstrapHistogram dvBootstrapHistogram = new DvBootstrapHistogram(
            statisticsList, probabilitiesList, finalSkipCount);

        final DvModelParameter dvModelParameter = new DvModelParameter(name,
            valueDouble, uncertainty, fitted);

        final List<DvModelParameter> dvModelParameters = newArrayList();
        dvModelParameters.add(dvModelParameter);

        final DvBinaryDiscriminationResults dvBinaryDiscriminationResults = new DvBinaryDiscriminationResults(
            dvPlanetStatistic, dvPlanetStatistic, dvStatistic, dvStatistic,
            dvStatistic, dvStatistic, dvStatistic);

        final DvCentroidResults dvCentroidResults = new DvCentroidResults(
            dvCentroidMotionResults, dvCentroidMotionResults,
            dvDifferenceImageMotionResults, dvPixelCorrelationMotionResults);

        final DvWeakSecondary dvWeakSecondary = new DvWeakSecondary();

        final DvPlanetCandidate dvPlanetCandidate = new DvPlanetCandidate.Builder(
            keplerId, pipelineTask).chiSquare1(chiSquare1)
            .chiSquare2(chiSquare2)
            .chiSquareDof1(chiSquareDof1)
            .chiSquareDof2(chiSquareDof2)
            .epochMjd(epochMjd)
            .maxMultipleEventSigma(maxMultipleEventSigma)
            .maxSingleEventSigma(maxSingleEventSigma)
            .orbitalPeriod(orbitalPeriod)
            .robustStatistic(robustStatistic)
            .trialTransitPulseDuration(trialTransitPulseDuration)
            .weakSecondary(dvWeakSecondary)
            .bootstrapHistogram(dvBootstrapHistogram)
            .bootstrapMesMean(bootstrapMesMean)
            .bootstrapMesStd(bootstrapMesStd)
            .bootstrapThresholdForDesiredPfa(bootstrapThresholdForDesiredPfa)
            .expectedTransitCount(expectedTransitCount)
            .modelChiSquare2(modelChiSquare2)
            .modelChiSquareDof2(modelChiSquareDof2)
            .modelChiSquareGof(modelChiSquareGof)
            .modelChiSquareGofDof(modelChiSquareGofDof)
            .observedTransitCount(observedTransitCount)
            .planetNumber(planetNumber)
            .significance(significance)
            .statisticRatioBelowThreshold(statisticRatioBelowThreshold)
            .suspectedEclipsingBinary(suspectedEclipsingBinary)
            .build();

        final DvPlanetModelFit dvPlanetModelFit = new DvPlanetModelFit.Builder(
            keplerId, planetNumber, pipelineTask).limbDarkeningModelName(
            limbDarkeningModelName)
            .modelChiSquare(modelChiSquare)
            .modelDegreesOfFreedom(modelDegreesOfFreedom)
            .modelFitSnr(modelFitSnr)
            .modelParameterCovariance(modelParameterCovarianceList)
            .transitModelName(transitModelName)
            .modelParameters(dvModelParameters)
            .build();

        final List<DvPlanetModelFit> dvPlanetModelFits = newArrayList();
        dvPlanetModelFits.add(dvPlanetModelFit);

        final DvPixelStatistic dvPixelStatistic = new DvPixelStatistic(row,
            column, valueFloat, significance);

        final List<DvPixelStatistic> dvPixelCorrelationStatistics = newArrayList();
        dvPixelCorrelationStatistics.add(dvPixelStatistic);

        final DvDifferenceImagePixelData dvDifferenceImagePixelData = new DvDifferenceImagePixelData(
            row, column, dvQuantity, dvQuantity, dvQuantity, dvQuantity);

        final List<DvDifferenceImagePixelData> differenceImagePixelData = newArrayList();
        differenceImagePixelData.add(dvDifferenceImagePixelData);

        final DvCentroidOffsets dvCentroidOffsets = new DvCentroidOffsets(
            dvQuantity, dvQuantity, dvQuantity, dvQuantity, dvQuantity,
            dvQuantity);

        final DvImageCentroid dvImageCentroid = new DvImageCentroid(dvQuantity,
            dvDoubleQuantity, dvDoubleQuantity, dvQuantity);

        final DvGhostDiagnosticResults dvGhostDiagnosticResults = new DvGhostDiagnosticResults(
            dvStatistic, dvStatistic);

        final DvPixelCorrelationResults dvPixelCorrelationResults = new DvPixelCorrelationResults.Builder(
            targetTableId).ccdModule(ccdModule)
            .ccdOutput(ccdOutput)
            .pixelCorrelationStatistics(dvPixelCorrelationStatistics)
            .controlCentroidOffsets(dvCentroidOffsets)
            .controlImageCentroid(dvImageCentroid)
            .correlationImageCentroid(dvImageCentroid)
            .kicCentroidOffsets(dvCentroidOffsets)
            .kicReferenceCentroid(dvImageCentroid)
            .build();

        final List<DvPixelCorrelationResults> dvPixelCorrelationResultsList = newArrayList();
        dvPixelCorrelationResultsList.add(dvPixelCorrelationResults);

        final DvQualityMetric dvQualityMetric = new DvQualityMetric(attempted,
            valid, valueFloat);

        final DvDifferenceImageResults dvDifferenceImageResults = new DvDifferenceImageResults.Builder(
            targetTableId).ccdModule(ccdModule)
            .ccdOutput(ccdOutput)
            .differenceImagePixelData(differenceImagePixelData)
            .numberOfTransits(numberOfTransits)
            .numberOfCadencesInTransit(numberOfCadencesInTransit)
            .numberOfCadenceGapsInTransit(numberOfCadenceGapsInTransit)
            .numberOfCadencesOutOfTransit(numberOfCadencesOutOfTransit)
            .numberOfCadenceGapsOutOfTransit(numberOfCadenceGapsOutOfTransit)
            .controlCentroidOffsets(dvCentroidOffsets)
            .controlImageCentroid(dvImageCentroid)
            .differenceImageCentroid(dvImageCentroid)
            .kicCentroidOffsets(dvCentroidOffsets)
            .kicReferenceCentroid(dvImageCentroid)
            .qualityMetric(dvQualityMetric)
            .build();

        final List<DvDifferenceImageResults> dvDifferenceImageResultsList = newArrayList();
        dvDifferenceImageResultsList.add(dvDifferenceImageResults);

        final DvPlanetResults dvPlanetResults = new DvPlanetResults.Builder(
            startCadenceMultiQuarter, endCadence, keplerId, planetNumber,
            pipelineTask).allTransitsFit(dvPlanetModelFit)
            .binaryDiscriminationResults(dvBinaryDiscriminationResults)
            .centroidResults(dvCentroidResults)
            .evenTransitsFit(dvPlanetModelFit)
            .oddTransitsFit(dvPlanetModelFit)
            .ghostDiagnosticResults(dvGhostDiagnosticResults)
            .planetCandidate(dvPlanetCandidate)
            .singleTransitFits(dvPlanetModelFits)
            .reducedParameterFits(dvPlanetModelFits)
            .pixelCorrelationResults(dvPixelCorrelationResultsList)
            .differenceImageResults(dvDifferenceImageResultsList)
            .trapezoidalFit(dvPlanetModelFit)
            .build();

        final List<DvPlanetResults> dvPlanetResultsList = newArrayList();
        dvPlanetResultsList.add(dvPlanetResults);

        final DvLimbDarkeningModel dvLimbDarkeningModel = new DvLimbDarkeningModel.Builder(
            targetTableId, fluxType, keplerId, pipelineTask).modelName(
            modelName)
            .ccdModule(ccdModule)
            .ccdOutput(ccdOutput)
            .coefficient1(coefficient1)
            .coefficient2(coefficient2)
            .coefficient3(coefficient3)
            .coefficient4(coefficient4)
            .build();

        final List<DvLimbDarkeningModel> dvLimbDarkeningModels = newArrayList();
        dvLimbDarkeningModels.add(dvLimbDarkeningModel);

        final DvTargetResults dvTargetResults = new DvTargetResults.Builder(
            fluxType, 0, endCadence, keplerId, pipelineTask).decDegrees(
            new DvDoubleQuantityWithProvenance(dec, 0.0F, "KIC"))
            .raHours(new DvDoubleQuantityWithProvenance(ra, 0.0F, "KIC"))
            .keplerMag(new DvQuantityWithProvenance(magnitude, 0.0F, "KIC"))
            .radius(new DvQuantityWithProvenance(radius, 0.0F, "KIC"))
            .effectiveTemp(
                new DvQuantityWithProvenance(effectiveTemp, 0.0F, "KIC"))
            .log10Metallicity(
                new DvQuantityWithProvenance(log10Metallicity, 0.0F, "KIC"))
            .log10SurfaceGravity(
                new DvQuantityWithProvenance(log10SurfaceGravity, 0.0F, "KIC"))
            .quartersObserved(quartersObserved)
            .build();
        final List<DvTargetResults> dvTargetResultsList = newArrayList();
        dvTargetResultsList.add(dvTargetResults);

        final SbtCsci sbtCsci = mockery.mock(SbtCsci.class);
        final List<SbtCsci> sbtCscis = newArrayList();
        sbtCscis.add(sbtCsci);

        final ConfigMap configMap = mockery.mock(ConfigMap.class);
        final List<ConfigMap> configMaps = newArrayList();
        configMaps.add(configMap);

        final RequantTable requantTable = mockery.mock(RequantTable.class);
        final List<RequantTable> requantTables = newArrayList();
        requantTables.add(requantTable);

        final HuffmanTable huffmanTable = mockery.mock(HuffmanTable.class);
        final List<HuffmanTable> huffmanTables = newArrayList();
        huffmanTables.add(huffmanTable);

        final gov.nasa.kepler.hibernate.gar.RequantTable requantTableFromDatabase = mockery.mock(
            gov.nasa.kepler.hibernate.gar.RequantTable.class,
            "requantTableFromDatabase");
        final List<gov.nasa.kepler.hibernate.gar.RequantTable> requantTablesFromDatabase = newArrayList();
        requantTablesFromDatabase.add(requantTableFromDatabase);

        final gov.nasa.kepler.hibernate.gar.HuffmanTable huffmanTableFromDatabase = mockery.mock(
            gov.nasa.kepler.hibernate.gar.HuffmanTable.class,
            "huffmanTableFromDatabase");
        final List<gov.nasa.kepler.hibernate.gar.HuffmanTable> huffmanTablesFromDatabase = newArrayList();
        huffmanTablesFromDatabase.add(huffmanTableFromDatabase);

        final SbtSpacecraftMetadata sbtSpacecraftMetadata = new SbtSpacecraftMetadata(
            configMaps, requantTables, huffmanTables);

        final SbtAncillaryData sbtAncillaryData = mockery.mock(SbtAncillaryData.class);
        final List<SbtAncillaryData> sbtAncillaryDataList = newArrayList();
        sbtAncillaryDataList.add(sbtAncillaryData);

        final FsId argabrighteningFsId = PaFsIdFactory.getArgabrighteningFsId(
            cadenceType, targetTableLog.getTargetTable()
                .getExternalId(), ccdModule, ccdOutput);

        final FsId discontinuityFsId = PdcFsIdFactory.getDiscontinuityIndicesFsId(
            fluxType, cadenceType, keplerId);

        final FsId attitudeSolutionFloatValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(attitudeSolutionFloatTimeSeriesType);

        final FsId calCompressionMetricValuesFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
            cadenceType, calCompressionMetricTimeSeriesType, ccdModule,
            ccdOutput);
        final FsId calCompressionMetricCountsFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
            cadenceType, calCompressionMetricTimeSeriesTypeCounts, ccdModule,
            ccdOutput);

        final FsId calMetricValuesFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
            cadenceType, calMetricTimeSeriesType, ccdModule, ccdOutput);
        final FsId calMetricUncertaintiesFsId = CalFsIdFactory.getMetricsTimeSeriesFsId(
            cadenceType, calMetricTimeSeriesTypeUncertainties, ccdModule,
            ccdOutput);

        final FsId paMetricValuesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
            paMetricTimeSeriesType, ccdModule, ccdOutput);
        final FsId paMetricUncertaintiesFsId = PaFsIdFactory.getMetricTimeSeriesFsId(
            paMetricTimeSeriesTypeUncertainties, ccdModule, ccdOutput);

        final FsId calTargetMetricValuesFsId = CalFsIdFactory.getTargetMetricsTimeSeriesFsId(
            cadenceType, calTargetMetricTimeSeriesType, ccdModule, ccdOutput,
            keplerId);
        final FsId calTargetMetricUncertaintiesFsId = CalFsIdFactory.getTargetMetricsTimeSeriesFsId(
            cadenceType, calTargetMetricTimeSeriesTypeUncertainties, ccdModule,
            ccdOutput, keplerId);

        final FsId calCosmicRayMetricValuesFsId = CalFsIdFactory.getCosmicRayMetricFsId(
            cadenceType, collateralType, calCosmicRayMetricType, ccdModule,
            ccdOutput);

        final FsId paCosmicRayMetricValuesFsId = PaFsIdFactory.getCosmicRayMetricFsId(
            paCosmicRayMetricType, targetType, ccdModule, ccdOutput);

        final FsId pmdValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(
            pmdTimeSeriesType, ccdModule, ccdOutput);
        final FsId pmdUncertaintiesFsId = PpaFsIdFactory.getTimeSeriesFsId(
            pmdTimeSeriesTypeUncertainties, ccdModule, ccdOutput);

        final FsId pagValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(pagTimeSeriesType);

        final FsId pmdCdppValuesFsId = PpaFsIdFactory.getTimeSeriesFsId(
            pmdCdppTimeSeriesType, ccdModule, ccdOutput,
            cdppMagnitude.getValue(), cdppDuration.getValue());
        final FsId pmdCdppUncertaintiesFsId = PpaFsIdFactory.getTimeSeriesFsId(
            pmdCdppTimeSeriesTypeUncertainties, ccdModule, ccdOutput,
            cdppMagnitude.getValue(), cdppDuration.getValue());

        final FsId rawPixelValuesFsId = DrFsIdFactory.getSciencePixelTimeSeries(
            DrFsIdFactory.TimeSeriesType.ORIG, targetType, ccdModule,
            ccdOutput, pixel.getRow(), pixel.getColumn());

        final FsId calPixelValuesFsId = CalFsIdFactory.getTimeSeriesFsId(
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL, targetType, ccdModule,
            ccdOutput, pixel.getRow(), pixel.getColumn());
        final FsId calPixelUncertaintiesFsId = CalFsIdFactory.getTimeSeriesFsId(
            CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
            targetType, ccdModule, ccdOutput, pixel.getRow(), pixel.getColumn());

        final FsId cosmicRayEventsValuesFsId = PaFsIdFactory.getCosmicRaySeriesFsId(
            targetType, ccdModule, ccdOutput, row, column);

        final FsId barycentricTimeOffsetsFsId = PaFsIdFactory.getBarcentricTimeOffsetFsId(
            cadenceType, keplerId);

        final FsId rawFluxValuesFsId = PaFsIdFactory.getTimeSeriesFsId(
            PaFsIdFactory.TimeSeriesType.RAW_FLUX, fluxType, cadenceType,
            keplerId);
        final FsId rawFluxUncertaintiesFsId = PaFsIdFactory.getTimeSeriesFsId(
            PaFsIdFactory.TimeSeriesType.RAW_FLUX_UNCERTAINTIES, fluxType,
            cadenceType, keplerId);

        final FsId correctedFluxValuesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
            pdcFluxTimeSeriesType, fluxType, cadenceType, keplerId);
        final FsId correctedFluxUncertaintiesFsId = PdcFsIdFactory.getFluxTimeSeriesFsId(
            pdcFluxTimeSeriesTypeUncertainties, fluxType, cadenceType, keplerId);
        final FsId correctedFluxFilledIndicesFsId = PdcFsIdFactory.getFilledIndicesFsId(
            correctedFluxType.getPdcFilledIndicesTimeSeriesType(), fluxType,
            cadenceType, keplerId);

        final FsId outliersValuesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
            pdcOutliersTimeSeriesType, fluxType, cadenceType, keplerId);
        final FsId outliersUncertaintiesFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
            pdcOutliersTimeSeriesTypeUncertainties, fluxType, cadenceType,
            keplerId);

        final FsId centroidRowFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            fluxType, centroidType, CentroidTimeSeriesType.CENTROID_ROWS,
            cadenceType, keplerId);
        final FsId centroidRowUncertaintiesFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            fluxType, centroidType,
            CentroidTimeSeriesType.CENTROID_ROWS_UNCERTAINTIES, cadenceType,
            keplerId);
        final FsId centroidColFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            fluxType, centroidType, CentroidTimeSeriesType.CENTROID_COLS,
            cadenceType, keplerId);
        final FsId centroidColUncertaintiesFsId = PaFsIdFactory.getCentroidTimeSeriesFsId(
            fluxType, centroidType,
            CentroidTimeSeriesType.CENTROID_COLS_UNCERTAINTIES, cadenceType,
            keplerId);

        final FsId initialFluxValuesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, INITIAL, DvTimeSeriesType.FLUX, pipelineInstance.getId(),
            keplerId, planetNumber);
        final FsId initialFluxUncertaintiesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, INITIAL, DvTimeSeriesType.UNCERTAINTIES,
            pipelineInstance.getId(), keplerId, planetNumber);
        final FsId initialFluxFilledIndicesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, INITIAL, DvTimeSeriesType.FILLED_INDICES,
            pipelineInstance.getId(), keplerId, planetNumber);

        final FsId modelLightCurveFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
            fluxType, MODEL_LIGHT_CURVE, pipelineInstance.getId(), keplerId,
            planetNumber);

        final FsId whitenedModelLightCurveFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
            fluxType, WHITENED_MODEL_LIGHT_CURVE, pipelineInstance.getId(),
            keplerId, planetNumber);

        final FsId trapezoidalModelLightCurveFsId = DvFsIdFactory.getLightCurveTimeSeriesFsId(
            fluxType, TRAPEZOIDAL_MODEL_LIGHT_CURVE, pipelineInstance.getId(),
            keplerId, planetNumber);

        final FsId whitenedFluxTimeSeriesFsId = DvFsIdFactory.getFluxTimeSeriesFsId(
            fluxType, "WhitenedFlux", pipelineInstance.getId(), keplerId,
            planetNumber);

        final FsId detrendedFluxValuesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, DETRENDED, DvTimeSeriesType.FLUX,
            pipelineInstance.getId(), keplerId, planetNumber);
        final FsId detrendedFluxUncertaintiesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, DETRENDED, DvTimeSeriesType.UNCERTAINTIES,
            pipelineInstance.getId(), keplerId, planetNumber);
        final FsId detrendedFluxFilledIndicesFsId = DvFsIdFactory.getCorrectedFluxTimeSeriesFsId(
            fluxType, DETRENDED, DvTimeSeriesType.FILLED_INDICES,
            pipelineInstance.getId(), keplerId, planetNumber);

        final FsId residualFluxValuesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            fluxType, DvTimeSeriesType.FLUX, pipelineInstanceId, keplerId);
        final FsId residualFluxUncertaintiesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            fluxType, DvTimeSeriesType.UNCERTAINTIES, pipelineInstanceId,
            keplerId);
        final FsId residualFluxFilledIndicesFsId = DvFsIdFactory.getResidualTimeSeriesFsId(
            fluxType, DvTimeSeriesType.FILLED_INDICES, pipelineInstanceId,
            keplerId);

        final FsId barycentricCorrectedTimestampsFsId = DvFsIdFactory.getBarycentricCorrectedTimestampsFsId(
            fluxType, pipelineInstance.getId(), keplerId);

        final FsId cdppFsId = TpsFsIdFactory.getCdppId(pipelineInstanceId,
            keplerId, trialTransitPulseInHours, tpsType, fluxType);

        final FsId dvSingleEvenStatisticsFsId = DvFsIdFactory.getSingleEventStatisticsFsId(
            fluxType, dvSingleEventStatisticsType, pipelineInstanceId,
            keplerId, trialTransitPulseDuration);

        final Set<FsId> fsIdsFov = newLinkedHashSet();
        fsIdsFov.add(attitudeSolutionFloatValuesFsId);
        fsIdsFov.add(pagValuesFsId);

        final Set<FsId> fsIdsTargetTableModOut = newLinkedHashSet();
        fsIdsTargetTableModOut.add(argabrighteningFsId);
        fsIdsTargetTableModOut.add(calCompressionMetricValuesFsId);
        fsIdsTargetTableModOut.add(calCompressionMetricCountsFsId);
        fsIdsTargetTableModOut.add(calMetricValuesFsId);
        fsIdsTargetTableModOut.add(calMetricUncertaintiesFsId);
        fsIdsTargetTableModOut.add(calCosmicRayMetricValuesFsId);
        fsIdsTargetTableModOut.add(paMetricValuesFsId);
        fsIdsTargetTableModOut.add(paMetricUncertaintiesFsId);
        fsIdsTargetTableModOut.add(paCosmicRayMetricValuesFsId);
        fsIdsTargetTableModOut.add(pmdValuesFsId);
        fsIdsTargetTableModOut.add(pmdUncertaintiesFsId);
        fsIdsTargetTableModOut.add(pmdCdppValuesFsId);
        fsIdsTargetTableModOut.add(pmdCdppUncertaintiesFsId);

        final Set<FsId> mjdFsIdsTargetTableModOut = newLinkedHashSet();

        final Set<FsId> fsIdsTargetTable = newLinkedHashSet();
        fsIdsTargetTable.add(rawPixelValuesFsId);
        fsIdsTargetTable.add(calPixelValuesFsId);
        fsIdsTargetTable.add(calPixelUncertaintiesFsId);
        fsIdsTargetTable.add(calTargetMetricValuesFsId);
        fsIdsTargetTable.add(calTargetMetricUncertaintiesFsId);

        final Set<FsId> mjdFsIdsTargetTable = newLinkedHashSet();
        mjdFsIdsTargetTable.add(cosmicRayEventsValuesFsId);

        final Set<FsId> fsIdsMultiQuarter = newLinkedHashSet();
        fsIdsMultiQuarter.add(discontinuityFsId);
        fsIdsMultiQuarter.add(barycentricTimeOffsetsFsId);
        fsIdsMultiQuarter.add(rawFluxValuesFsId);
        fsIdsMultiQuarter.add(rawFluxUncertaintiesFsId);
        fsIdsMultiQuarter.add(correctedFluxValuesFsId);
        fsIdsMultiQuarter.add(correctedFluxUncertaintiesFsId);
        fsIdsMultiQuarter.add(correctedFluxFilledIndicesFsId);
        fsIdsMultiQuarter.add(centroidRowFsId);
        fsIdsMultiQuarter.add(centroidRowUncertaintiesFsId);
        fsIdsMultiQuarter.add(centroidColFsId);
        fsIdsMultiQuarter.add(centroidColUncertaintiesFsId);
        fsIdsMultiQuarter.add(cdppFsId);
        fsIdsMultiQuarter.add(initialFluxValuesFsId);
        fsIdsMultiQuarter.add(initialFluxUncertaintiesFsId);
        fsIdsMultiQuarter.add(initialFluxFilledIndicesFsId);
        fsIdsMultiQuarter.add(residualFluxValuesFsId);
        fsIdsMultiQuarter.add(residualFluxUncertaintiesFsId);
        fsIdsMultiQuarter.add(residualFluxFilledIndicesFsId);
        fsIdsMultiQuarter.add(dvSingleEvenStatisticsFsId);
        fsIdsMultiQuarter.add(barycentricCorrectedTimestampsFsId);
        fsIdsMultiQuarter.add(modelLightCurveFsId);
        fsIdsMultiQuarter.add(whitenedModelLightCurveFsId);
        fsIdsMultiQuarter.add(trapezoidalModelLightCurveFsId);
        fsIdsMultiQuarter.add(whitenedFluxTimeSeriesFsId);
        fsIdsMultiQuarter.add(detrendedFluxValuesFsId);
        fsIdsMultiQuarter.add(detrendedFluxUncertaintiesFsId);
        fsIdsMultiQuarter.add(detrendedFluxFilledIndicesFsId);

        final Set<FsId> mjdFsIdsMultiQuarter = newLinkedHashSet();
        mjdFsIdsMultiQuarter.add(outliersValuesFsId);
        mjdFsIdsMultiQuarter.add(outliersUncertaintiesFsId);

        final Set<FsId> fsIdsMultiQuarterSingleEvent = newLinkedHashSet();
        fsIdsMultiQuarterSingleEvent.add(dvSingleEvenStatisticsFsId);

        final FsIdSet fsIdSetFov = new FsIdSet(startCadenceMultiQuarter,
            endCadence, fsIdsFov);

        final FsIdSet fsIdSetTargetTableModOut = new FsIdSet(
            startCadenceTargetTable, endCadence, fsIdsTargetTableModOut);

        final FsIdSet fsIdSetTargetTable = new FsIdSet(startCadenceTargetTable,
            endCadence, fsIdsTargetTable);

        final FsIdSet fsIdSetMultiQuarter = new FsIdSet(
            startCadenceMultiQuarter, endCadence, fsIdsMultiQuarter);

        final List<FsIdSet> fsIdSets = newArrayList();
        fsIdSets.add(fsIdSetTargetTableModOut);
        fsIdSets.add(fsIdSetTargetTable);
        fsIdSets.add(fsIdSetMultiQuarter);
        fsIdSets.add(fsIdSetFov);

        final MjdFsIdSet mjdFsIdSetTargetTableModOut = new MjdFsIdSet(
            startMjdTargetTable, endMjd, mjdFsIdsTargetTableModOut);

        final MjdFsIdSet mjdFsIdSetTargetTable = new MjdFsIdSet(
            startMjdTargetTable, endMjd, mjdFsIdsTargetTable);

        final MjdFsIdSet mjdFsIdSetMultiQuarter = new MjdFsIdSet(
            startMjdMultiQuarter, endMjd, mjdFsIdsMultiQuarter);

        final List<MjdFsIdSet> mjdFsIdSets = newArrayList();
        mjdFsIdSets.add(mjdFsIdSetTargetTableModOut);
        mjdFsIdSets.add(mjdFsIdSetTargetTable);
        mjdFsIdSets.add(mjdFsIdSetMultiQuarter);

        final SbtBlobSeries blobSeries = mockery.mock(SbtBlobSeries.class,
            "blobSeries");

        final SimpleIntTimeSeries argabrighteningTimeSeries = mockery.mock(
            SimpleIntTimeSeries.class, "argabrighteningTimeSeries");

        final SimpleIntTimeSeries discontinuityTimeSeries = mockery.mock(
            SimpleIntTimeSeries.class, "discontinuityTimeSeries");

        final SimpleFloatTimeSeries attitudeSolutionFloatTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "attitudeSolutionFloatTimeSeries");

        final SimpleDoubleTimeSeries attitudeSolutionDoubleTimeSeries = mockery.mock(
            SimpleDoubleTimeSeries.class, "attitudeSolutionDoubleTimeSeries");

        final CalCompressionTimeSeries calCompressionMetricTimeSeries = mockery.mock(
            CalCompressionTimeSeries.class, "calCompressionMetricTimeSeries");

        final CompoundFloatTimeSeries calMetricTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "calMetricTimeSeries");

        final CompoundFloatTimeSeries paMetricTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "paMetricTimeSeries");

        final CompoundFloatTimeSeries calTargetMetricTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "calTargetMetricTimeSeries");

        final CompoundFloatTimeSeries pmdTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "pmdTimeSeries");

        final CompoundFloatTimeSeries pmdCdppTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "pmdCdppTimeSeries");

        final SimpleFloatTimeSeries pagTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "pagTimeSeries");

        final SimpleFloatTimeSeries calCosmicRayMetricTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "calCosmicRayMetricTimeSeries");

        final SimpleFloatTimeSeries paCosmicRayMetricTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "paCosmicRayMetricTimeSeries");

        final SimpleIntTimeSeries rawPixelTimeSeries = mockery.mock(
            SimpleIntTimeSeries.class, "rawPixelTimeSeries");

        final CompoundFloatTimeSeries calPixelTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "calPixelTimeSeries");

        // Commented out because cosmicRayEvent mjds are no longer related
        // to PixelLog, so MjdToCadence cannot be used to convert the
        // cosmicRay mjd into a cadence number.
        // final SimpleIndicesTimeSeries cosmicRayEventsTimeSeries =
        // mockery.mock(
        // SimpleIndicesTimeSeries.class, "cosmicRayEventsTimeSeries");
        final SimpleIndicesTimeSeries cosmicRayEventsTimeSeries = new SimpleIndicesTimeSeries();

        final SimpleFloatTimeSeries barycentricTimeOffsetsTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "barycentricTimeOffsetsTimeSeries");

        final CompoundFloatTimeSeries rawFluxTimeSeries = mockery.mock(
            CompoundFloatTimeSeries.class, "rawFluxTimeSeries");

        final CorrectedFluxTimeSeries correctedFluxTimeSeries = mockery.mock(
            CorrectedFluxTimeSeries.class, "correctedFluxTimeSeries");

        final CompoundIndicesTimeSeries outliersTimeSeries = mockery.mock(
            CompoundIndicesTimeSeries.class, "outliersTimeSeries");

        final CorrectedFluxTimeSeries initialFluxTimeSeries = mockery.mock(
            CorrectedFluxTimeSeries.class, "initialFluxTimeSeries");

        final CorrectedFluxTimeSeries residualFluxTimeSeries = mockery.mock(
            CorrectedFluxTimeSeries.class, "residualFluxTimeSeries");

        final SimpleDoubleTimeSeries barycentricCorrectedTimestampsTimeSeries = mockery.mock(
            SimpleDoubleTimeSeries.class,
            "barycentricCorrectedTimestampsTimeSeries");

        final SimpleFloatTimeSeries modelLightCurveTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "modelLightCurveTimeSeries");

        final SimpleFloatTimeSeries whitenedModelLightCurveTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "whitenedModelLightCurveTimeSeries");

        final SimpleFloatTimeSeries trapezoidalModelLightCurveTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "trapezoidalModelLightCurveTimeSeries");

        final SimpleFloatTimeSeries whitenedFluxTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "whitenedFluxTimeSeries");

        final CorrectedFluxTimeSeries detrendedFluxTimeSeries = mockery.mock(
            CorrectedFluxTimeSeries.class, "detrendedFluxTimeSeries");

        final CentroidTimeSeries centroids = mockery.mock(
            CentroidTimeSeries.class, "centroids");

        final SimpleFloatTimeSeries cdppTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "cdppTimeSeries");

        final SimpleFloatTimeSeries dvSingleEvenStatisticsTimeSeries = mockery.mock(
            SimpleFloatTimeSeries.class, "dvSingleEvenStatisticsTimeSeries");

        final Map<FsId, TimeSeries> fsIdToTimeSeries = mockery.mock(Map.class,
            "fsIdToTimeSeries");

        final Map<FsId, FloatMjdTimeSeries> fsIdToMjdTimeSeries = mockery.mock(
            Map.class, "fsIdToMjdTimeSeries");

        TimeSeriesBatch timeSeriesBatchTargetTable = new TimeSeriesBatch(
            startCadenceTargetTable, endCadence, fsIdToTimeSeries);
        TimeSeriesBatch timeSeriesBatchMultiQuarter = new TimeSeriesBatch(
            startCadenceMultiQuarter, endCadence, fsIdToTimeSeries);

        final List<TimeSeriesBatch> timeSeriesBatches = newArrayList();
        timeSeriesBatches.add(timeSeriesBatchMultiQuarter);
        timeSeriesBatches.add(timeSeriesBatchTargetTable);

        final MqTimestampSeriesFactory mqTimestampSeriesFactory = mockery.mock(MqTimestampSeriesFactory.class);
        final MjdToCadenceFactory mjdToCadenceFactory = mockery.mock(MjdToCadenceFactory.class);
        final RollTimeOperations rollTimeOperations = mockery.mock(RollTimeOperations.class);
        final TargetCrud targetCrud = mockery.mock(TargetCrud.class);
        final KicCrud kicCrud = mockery.mock(KicCrud.class);
        final SbtBlobSeriesOperations sbtBlobSeriesOperations = mockery.mock(SbtBlobSeriesOperations.class);
        final PixelSetFactory pixelSetFactory = mockery.mock(PixelSetFactory.class);
        final FsIdToTimeSeriesMapFactory fsIdToTimeSeriesMapFactory = mockery.mock(FsIdToTimeSeriesMapFactory.class);
        final PersistableTimeSeriesFactory persistableTimeSeriesFactory = mockery.mock(PersistableTimeSeriesFactory.class);
        final CelestialObjectOperations celestialObjectOperations = mockery.mock(CelestialObjectOperations.class);
        final IndexingSchemeConverter indexingSchemeConverter = mockery.mock(IndexingSchemeConverter.class);
        final PixelCoordinateSystemConverter pixelCoordinateSystemConverter = mockery.mock(PixelCoordinateSystemConverter.class);
        final TpsOperations tpsOps = mockery.mock(TpsOperations.class);
        final DvCrud dvCrud = mockery.mock(DvCrud.class);
        final FileStoreClient fileStoreClient = mockery.mock(FileStoreClient.class);
        final SbtTargetTypesFactory sbtTargetTypesFactory = mockery.mock(SbtTargetTypesFactory.class);
        final PixelOperations pixelOperations = mockery.mock(PixelOperations.class);
        final TypesFactory typesFactory = mockery.mock(TypesFactory.class);
        final EnumMapFactory enumMapFactory = new EnumMapFactory();
        final FsIdPipelineProductFilter fsIdCsciFilter = mockery.mock(FsIdPipelineProductFilter.class);
        final ConfigMapOperations configMapOperations = mockery.mock(ConfigMapOperations.class);
        final CompressionCrud compressionCrud = mockery.mock(CompressionCrud.class);
        final CompressionTableFactory compressionTableFactory = mockery.mock(CompressionTableFactory.class);
        final SbtCadenceRangeDataMerger sbtCadenceRangeDataMerger = new SbtCadenceRangeDataMerger();
        final PdcCrud pdcCrud = mockery.mock(PdcCrud.class);

        mockery.checking(new Expectations() {
            {
                allowing(mjdToCadenceFactory).create(cadenceType);
                will(returnValue(mjdToCadence));

                allowing(mjdToCadence).hasCadence(startCadenceMultiQuarter);
                will(returnValue(!missingStartCadenceMultiQuarter));

                allowing(mjdToCadence).hasCadence(endCadence);
                will(returnValue(!missingEndCadence));

                allowing(mqTimestampSeriesFactory).create(rollTimeOperations,
                    mjdToCadence, startCadenceMultiQuarter, endCadence);
                will(returnValue(mqTimestampSeries));

                allowing(mqTimestampSeries).startMjd();
                will(returnValue(startMjdMultiQuarter));

                allowing(mqTimestampSeries).endMjd();
                will(returnValue(endMjd));

                allowing(targetCrud).retrieveTargetTableLogs(targetType,
                    startCadenceMultiQuarter, endCadence);
                will(returnValue(targetTableLogs));

                allowing(kicCrud).retrieveSkyGroupIdsForKeplerIds(keplerIds);
                will(returnValue(keplerIdToSkyGroupId));

                allowing(mjdToCadence).cadenceToMjd(startCadenceTargetTable);
                will(returnValue(startMjdTargetTable));

                allowing(mjdToCadence).cadenceToMjd(startCadenceMultiQuarter);
                will(returnValue(startMjdMultiQuarter));

                allowing(mjdToCadence).cadenceToMjd(endCadence);
                will(returnValue(endMjd));

                allowing(rollTimeOperations).mjdToQuarter(
                    with(new ReflectionEqualsMatcher<double[]>(
                        new ReflectionEquals(), startMjdsTargetTable)));
                will(returnValue(new int[] { quarter }));

                allowing(rollTimeOperations).mjdToSeason(startMjdTargetTable);
                will(returnValue(season));

                allowing(kicCrud).retrieveSkyGroup(skyGroupId, season);
                will(returnValue(skyGroup));

                allowing(sbtBlobSeriesOperations).retrieveSbtBlobSeries(
                    blobSeriesType, ccdModule, ccdOutput, cadenceType,
                    startCadenceTargetTable, endCadence);
                will(returnValue(blobSeries));

                allowing(targetCrud).retrieveObservedTargets(targetTable,
                    keplerIds);
                will(returnValue(observedTargets));

                allowing(pixelSetFactory).create(observedTarget, null,
                    ccdModule, ccdOutput);
                will(returnValue(pixels));

                // You need to set log4j logging in order to see the detailed
                // error messages.
                TypeSafeMatcher<List<FsIdSet>> fsIdSetsMatcher = new FsIdSetMatcher(
                    fsIdSets);

                allowing(fsIdToTimeSeriesMapFactory).createForFsIds(
                    with(fsIdSetsMatcher));
                will(returnValue(fsIdToTimeSeries));

                allowing(fsIdToTimeSeriesMapFactory).createForMjdFsIds(
                    mjdFsIdSets);
                will(returnValue(fsIdToMjdTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleIntTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getSimpleDoubleTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getCalCompressionTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getCorrectedFluxTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getSimpleIndicesTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, FloatMjdTimeSeries>>(
                        Collections.EMPTY_MAP)),
                    with(new IsAnything<MjdToCadence>()),
                    with(new IsAnything<Integer>()),
                    with(new IsAnything<Integer>()));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getCompoundIndicesTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, FloatMjdTimeSeries>>(
                        Collections.EMPTY_MAP)),
                    with(new IsAnything<MjdToCadence>()),
                    with(new IsAnything<Integer>()),
                    with(new IsAnything<Integer>()));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getCentroidTimeSeries(
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsAnything<FsId>()),
                    with(new IsEqual<Map<FsId, TimeSeries>>(
                        Collections.EMPTY_MAP)));
                will(returnValue(null));

                allowing(persistableTimeSeriesFactory).getSimpleIntTimeSeries(
                    discontinuityFsId, fsIdToTimeSeries);
                will(returnValue(discontinuityTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleIntTimeSeries(
                    argabrighteningFsId, fsIdToTimeSeries);
                will(returnValue(argabrighteningTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    attitudeSolutionFloatValuesFsId, fsIdToTimeSeries);
                will(returnValue(attitudeSolutionFloatTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleDoubleTimeSeriesFromDatabase(
                    attitudeSolutionDoubleTimeSeriesType,
                    startCadenceMultiQuarter, endCadence);
                will(returnValue(attitudeSolutionDoubleTimeSeries));

                allowing(persistableTimeSeriesFactory).getCalCompressionTimeSeries(
                    calCompressionMetricValuesFsId,
                    calCompressionMetricCountsFsId, fsIdToTimeSeries);
                will(returnValue(calCompressionMetricTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    calMetricValuesFsId, calMetricUncertaintiesFsId,
                    fsIdToTimeSeries);
                will(returnValue(calMetricTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    paMetricValuesFsId, paMetricUncertaintiesFsId,
                    fsIdToTimeSeries);
                will(returnValue(paMetricTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    calTargetMetricValuesFsId,
                    calTargetMetricUncertaintiesFsId, fsIdToTimeSeries);
                will(returnValue(calTargetMetricTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    pmdValuesFsId, pmdUncertaintiesFsId, fsIdToTimeSeries);
                will(returnValue(pmdTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    pmdCdppValuesFsId, pmdCdppUncertaintiesFsId,
                    fsIdToTimeSeries);
                will(returnValue(pmdCdppTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    pagValuesFsId, fsIdToTimeSeries);
                will(returnValue(pagTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    calCosmicRayMetricValuesFsId, fsIdToTimeSeries);
                will(returnValue(calCosmicRayMetricTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    paCosmicRayMetricValuesFsId, fsIdToTimeSeries);
                will(returnValue(paCosmicRayMetricTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleIntTimeSeries(
                    rawPixelValuesFsId, fsIdToTimeSeries);
                will(returnValue(rawPixelTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    calPixelValuesFsId, calPixelUncertaintiesFsId,
                    fsIdToTimeSeries);
                will(returnValue(calPixelTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleIndicesTimeSeries(
                    cosmicRayEventsValuesFsId, fsIdToMjdTimeSeries,
                    mjdToCadence, startCadenceTargetTable, endCadence);
                will(returnValue(cosmicRayEventsTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    barycentricTimeOffsetsFsId, fsIdToTimeSeries);
                will(returnValue(barycentricTimeOffsetsTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundTimeSeries(
                    rawFluxValuesFsId, rawFluxUncertaintiesFsId,
                    fsIdToTimeSeries);
                will(returnValue(rawFluxTimeSeries));

                allowing(persistableTimeSeriesFactory).getCorrectedFluxTimeSeries(
                    correctedFluxValuesFsId, correctedFluxUncertaintiesFsId,
                    correctedFluxFilledIndicesFsId, fsIdToTimeSeries);
                will(returnValue(correctedFluxTimeSeries));

                allowing(persistableTimeSeriesFactory).getCompoundIndicesTimeSeries(
                    outliersValuesFsId, outliersUncertaintiesFsId,
                    fsIdToMjdTimeSeries, mjdToCadence,
                    startCadenceMultiQuarter, endCadence);
                will(returnValue(outliersTimeSeries));

                allowing(persistableTimeSeriesFactory).getCentroidTimeSeries(
                    centroidRowFsId, centroidRowUncertaintiesFsId,
                    centroidColFsId, centroidColUncertaintiesFsId,
                    fsIdToTimeSeries);
                will(returnValue(centroids));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    cdppFsId, fsIdToTimeSeries);
                will(returnValue(cdppTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    dvSingleEvenStatisticsFsId, fsIdToTimeSeries);
                will(returnValue(dvSingleEvenStatisticsTimeSeries));

                allowing(persistableTimeSeriesFactory).getCorrectedFluxTimeSeries(
                    initialFluxValuesFsId, initialFluxUncertaintiesFsId,
                    initialFluxFilledIndicesFsId, fsIdToTimeSeries);
                will(returnValue(initialFluxTimeSeries));

                allowing(persistableTimeSeriesFactory).getCorrectedFluxTimeSeries(
                    residualFluxValuesFsId, residualFluxUncertaintiesFsId,
                    residualFluxFilledIndicesFsId, fsIdToTimeSeries);
                will(returnValue(residualFluxTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleDoubleTimeSeries(
                    barycentricCorrectedTimestampsFsId, fsIdToTimeSeries);
                will(returnValue(barycentricCorrectedTimestampsTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    modelLightCurveFsId, fsIdToTimeSeries);
                will(returnValue(modelLightCurveTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    whitenedModelLightCurveFsId, fsIdToTimeSeries);
                will(returnValue(whitenedModelLightCurveTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    trapezoidalModelLightCurveFsId, fsIdToTimeSeries);
                will(returnValue(trapezoidalModelLightCurveTimeSeries));

                allowing(persistableTimeSeriesFactory).getSimpleTimeSeries(
                    whitenedFluxTimeSeriesFsId, fsIdToTimeSeries);
                will(returnValue(whitenedFluxTimeSeries));

                allowing(persistableTimeSeriesFactory).getCorrectedFluxTimeSeries(
                    detrendedFluxValuesFsId, detrendedFluxUncertaintiesFsId,
                    detrendedFluxFilledIndicesFsId, fsIdToTimeSeries);
                will(returnValue(detrendedFluxTimeSeries));

                // WTF?!
                // allowing(fsIdToTimeSeries).size();
                // will(returnValue(-42));

                // allowing(fsIdToMjdTimeSeries).size();
                // will(returnValue(-43));

                allowing(fsIdToTimeSeries).isEmpty();
                will(returnValue(false));

                allowing(fsIdToMjdTimeSeries).isEmpty();
                will(returnValue(false));

                allowing(typesFactory).getFluxTypes();
                will(returnValue(fluxTypes));

                allowing(celestialObjectOperations).retrieveCelestialObjectParameters(
                    keplerIds);
                will(returnValue(celestialObjectParametersList));

                allowing(celestialObjectParameters).getKeplerId();
                will(returnValue(keplerId));

                allowing(mjdToCadence).cachedCadenceTimes(
                    startCadenceTargetTable, endCadence);
                will(returnValue(timestampSeries));

                allowing(mjdToCadence).cadenceType();
                will(returnValue(cadenceType));

                allowing(indexingSchemeConverter).convert(
                    with(new IsAnything<SbtData>()));

                allowing(pixelCoordinateSystemConverter).convert(
                    with(new IsAnything<SbtData>()));

                allowing(discontinuityTimeSeries).getGapIndicators();
                will(returnValue(discontinuityGapIndicators));

                allowing(argabrighteningTimeSeries).getGapIndicators();
                will(returnValue(argabrighteningGapIndicators));

                allowing(celestialObjectParameters).getSkyGroupId();
                will(returnValue(skyGroupId));

                allowing(pixelCoordinateSystemConverter).getBaseDescription();
                will(returnValue(baseDescription));

                allowing(tpsOps).retrieveSbtResultsWithFileStoreData(keplerIds);
                will(returnValue(tpsDbResults));

                allowing(dvCrud).retrieveLatestPlanetResults(
                    Arrays.asList(keplerId));
                will(returnValue(dvPlanetResultsList));

                allowing(dvCrud).retrieveLatestLimbDarkeningModels(
                    Arrays.asList(keplerId));
                will(returnValue(dvLimbDarkeningModels));

                allowing(dvCrud).retrieveLatestTargetResults(
                    Arrays.asList(keplerId));
                will(returnValue(dvTargetResultsList));

                allowing(fileStoreClient).queryIds2(
                    "TimeSeries@/dv/Sap/SingleEventStatistics/[Correlation,Normalization]/[48]/[1-1]:\\d");
                will(returnValue(fsIdsMultiQuarterSingleEvent));

                allowing(typesFactory).getAttitudeSolutionDoubleTypes();
                will(returnValue(attitudeSolutionDoubleTimeSeriesTypeList));

                allowing(typesFactory).getAttitudeSolutionFloatTypes();
                will(returnValue(attitudeSolutionFloatTimeSeriesTypeList));

                allowing(typesFactory).getCalMetricsTimeSeriesTypes();
                will(returnValue(calMetricTimeSeriesTypes));

                allowing(typesFactory).getCalMetricsTimeSeriesTypes();
                will(returnValue(calMetricTimeSeriesTypes));

                allowing(typesFactory).getPaMetricTypes();
                will(returnValue(paMetricTimeSeriesTypes));

                allowing(typesFactory).getCalTargetMetricsTimeSeriesTypes();
                will(returnValue(calTargetMetricTimeSeriesTypes));

                allowing(typesFactory).getPmdTimeSeriesTypes();
                will(returnValue(pmdTimeSeriesTypes));

                allowing(typesFactory).getPmdCdppTimeSeriesTypes();
                will(returnValue(pmdCdppTimeSeriesTypes));

                allowing(typesFactory).getPagTimeSeriesTypes();
                will(returnValue(pagTimeSeriesTypes));

                allowing(sbtTargetTypesFactory).create(cadenceType);
                will(returnValue(targetTypes));

                allowing(typesFactory).getCalCosmicRayMetricsTypes();
                will(returnValue(calCosmicRayMetricTypes));

                allowing(typesFactory).getPaCosmicRayMetricTypes();
                will(returnValue(paCosmicRayMetricTypes));

                allowing(typesFactory).getCentroidTypes();
                will(returnValue(centroidTypes));

                allowing(typesFactory).getBlobSeriesTypes();
                will(returnValue(blobSeriesTypes));

                allowing(typesFactory).getDvSingleEventStatisticsTypes();
                will(returnValue(dvSingleEventStatisticsTypes));

                allowing(pixelOperations).retrievePixelRange(ccdModule,
                    ccdOutput, startMjdTargetTable, endMjd);
                will(returnValue(badPixels.toArray(new gov.nasa.kepler.hibernate.fc.Pixel[0])));

                allowing(typesFactory).getCorrectedFluxTypes();
                will(returnValue(correctedFluxTypes));

                allowing(typesFactory).getPdcFluxTimeSeriesTypes();
                will(returnValue(pdcFluxTimeSeriesTypes));

                allowing(typesFactory).getPdcOutliersTimeSeriesTypes();
                will(returnValue(pdcOutliersTimeSeriesTypes));

                allowing(typesFactory).getCollateralTypes();
                will(returnValue(collateralTypes));

                allowing(typesFactory).getCdppMagnitudes();
                will(returnValue(cdppMagnitudes));

                allowing(typesFactory).getCdppDurations();
                will(returnValue(cdppDurations));

                allowing(fsIdCsciFilter).filter(
                    with(new IsAnything<Set<FsId>>()),
                    with(new IsAnything<List<PipelineProduct>>()));

                allowing(typesFactory).getPipelineProducts();
                will(returnValue(pipelineProducts));

                allowing(configMapOperations).retrieveConfigMapsUsingPixelLog(
                    startMjdMultiQuarter, endMjd);
                will(returnValue(configMaps));

                allowing(compressionCrud).retrieveRequantTables(
                    startMjdMultiQuarter, endMjd);
                will(returnValue(requantTablesFromDatabase));

                allowing(compressionCrud).retrieveHuffmanTables(
                    startMjdMultiQuarter, endMjd);
                will(returnValue(huffmanTablesFromDatabase));

                allowing(requantTableFromDatabase).getExternalId();
                will(returnValue(targetTableId));

                allowing(huffmanTableFromDatabase).getExternalId();
                will(returnValue(targetTableId));

                allowing(compressionCrud).retrieveStartEndTimes(targetTableId);
                will(returnValue(Pair.of(startMjdMultiQuarter, endMjd)));

                allowing(compressionTableFactory).create(
                    requantTableFromDatabase, startMjdMultiQuarter);
                will(returnValue(requantTable));

                allowing(compressionTableFactory).create(
                    huffmanTableFromDatabase, startMjdMultiQuarter);
                will(returnValue(huffmanTable));

                allowing(barycentricCorrectedTimestampsTimeSeries).getValues();
                will(returnValue(barycentricCorrectedTimestamps));

                allowing(pdcCrud).retrievePdcProcessingCharacteristics(
                    fluxType, cadenceType, keplerId, startCadenceMultiQuarter,
                    endCadence);
                will(returnValue(Arrays.asList(pdcProcessingCharacteristics)));
            }
        });

        if (clearKics) {
            celestialObjectParametersList.clear();
        }

        SbtDataOperations sbtDataOperations = new SbtDataOperations(
            mqTimestampSeriesFactory, mjdToCadenceFactory, rollTimeOperations,
            targetCrud, kicCrud, pixelSetFactory, fsIdToTimeSeriesMapFactory,
            persistableTimeSeriesFactory, sbtBlobSeriesOperations,
            celestialObjectOperations, indexingSchemeConverter, tpsOps, dvCrud,
            fileStoreClient, sbtTargetTypesFactory, pixelOperations,
            typesFactory, enumMapFactory, fsIdCsciFilter, configMapOperations,
            compressionCrud, compressionTableFactory,
            sbtCadenceRangeDataMerger, pdcCrud);
        SbtData actualSbtData = sbtDataOperations.retrieveSbtData(keplerIds,
            cadenceType, startCadenceMultiQuarter, endCadence,
            pixelCoordinateSystemConverter, pipelineProductLists);

        List<SbtCalCompressionTimeSeries> expectedSbtCalCompressionMetricTimeSeriesList = newArrayList();
        expectedSbtCalCompressionMetricTimeSeriesList.add(new SbtCalCompressionTimeSeries(
            calCompressionMetricTimeSeriesType.toString(),
            calCompressionMetricTimeSeries));

        List<SbtCompoundTimeSeries> expectedSbtCalMetricTimeSeriesList = newArrayList();
        expectedSbtCalMetricTimeSeriesList.add(new SbtCompoundTimeSeries(
            calMetricTimeSeriesType.toString(), calMetricTimeSeries));

        List<SbtCompoundTimeSeries> expectedSbtPaMetricTimeSeriesList = newArrayList();
        expectedSbtPaMetricTimeSeriesList.add(new SbtCompoundTimeSeries(
            paMetricTimeSeriesType.toString(), paMetricTimeSeries));

        List<SbtSimpleTimeSeries> expectedSbtCalCosmicRayMetricTimeSeriesList = newArrayList();
        expectedSbtCalCosmicRayMetricTimeSeriesList.add(new SbtSimpleTimeSeries(
            calCosmicRayMetricType.toString(), calCosmicRayMetricTimeSeries));

        List<SbtSimpleTimeSeriesList> expectedSbtCalCosmicRayMetricGroups = newArrayList();
        expectedSbtCalCosmicRayMetricGroups.add(new SbtSimpleTimeSeriesList(
            collateralType.toString(),
            expectedSbtCalCosmicRayMetricTimeSeriesList));

        List<SbtSimpleTimeSeries> expectedSbtPaCosmicRayMetricTimeSeriesList = newArrayList();
        expectedSbtPaCosmicRayMetricTimeSeriesList.add(new SbtSimpleTimeSeries(
            paCosmicRayMetricType.toString(), paCosmicRayMetricTimeSeries));

        List<SbtSimpleTimeSeriesList> expectedSbtPaCosmicRayMetricGroups = newArrayList();
        expectedSbtPaCosmicRayMetricGroups.add(new SbtSimpleTimeSeriesList(
            targetType.toString(), expectedSbtPaCosmicRayMetricTimeSeriesList));

        List<SbtBlobSeries> expectedBlobGroups = newArrayList();
        expectedBlobGroups.add(blobSeries);

        List<SbtCompoundTimeSeries> expectedSbtPmdTimeSeriesList = newArrayList();
        expectedSbtPmdTimeSeriesList.add(new SbtCompoundTimeSeries(
            pmdTimeSeriesType.toString(), pmdTimeSeries));

        List<SbtCompoundTimeSeries> expectedSbtPmdCdppTimeSeriesList = newArrayList();
        expectedSbtPmdCdppTimeSeriesList.add(new SbtCompoundTimeSeries(
            cdppDuration.toString(), pmdCdppTimeSeries));

        List<SbtCompoundTimeSeriesList> expectedPmdCdppTimeSeriesLists = newArrayList();
        expectedPmdCdppTimeSeriesLists.add(new SbtCompoundTimeSeriesList(
            cdppMagnitude.toString(), expectedSbtPmdCdppTimeSeriesList));

        List<SbtCompoundTimeSeriesListList> expectedPmdCdppTimeSeriesListLists = newArrayList();
        expectedPmdCdppTimeSeriesListLists.add(new SbtCompoundTimeSeriesListList(
            pmdCdppTimeSeriesType.toString(), expectedPmdCdppTimeSeriesLists));

        List<SbtSimpleTimeSeries> expectedSbtPagTimeSeriesList = newArrayList();
        expectedSbtPagTimeSeriesList.add(new SbtSimpleTimeSeries(
            pagTimeSeriesType.toString(), pagTimeSeries));

        List<SbtModOut> expectedSbtModOuts = newArrayList();
        expectedSbtModOuts.add(new SbtModOut(ccdModule, ccdOutput,
            expectedBlobGroups, argabrighteningIndices,
            expectedSbtCalCompressionMetricTimeSeriesList,
            expectedSbtCalMetricTimeSeriesList,
            expectedSbtCalCosmicRayMetricGroups,
            expectedSbtPaMetricTimeSeriesList,
            expectedSbtPaCosmicRayMetricGroups, expectedSbtPmdTimeSeriesList,
            expectedPmdCdppTimeSeriesListLists));

        List<SbtSimpleDoubleTimeSeries> expectedSbtAttitudeSolutionDoubleTimeSeriesList = newArrayList();
        expectedSbtAttitudeSolutionDoubleTimeSeriesList.add(new SbtSimpleDoubleTimeSeries(
            attitudeSolutionDoubleTimeSeriesType.toString(),
            attitudeSolutionDoubleTimeSeries));

        List<SbtSimpleTimeSeries> expectedSbtAttitudeSolutionFloatTimeSeriesList = newArrayList();
        expectedSbtAttitudeSolutionFloatTimeSeriesList.add(new SbtSimpleTimeSeries(
            attitudeSolutionFloatTimeSeriesType.toString(),
            attitudeSolutionFloatTimeSeries));

        SbtAttitudeSolution expectedSbtAttitudeSolution = new SbtAttitudeSolution(
            expectedSbtAttitudeSolutionDoubleTimeSeriesList,
            expectedSbtAttitudeSolutionFloatTimeSeriesList);

        List<SbtTargetTable> expectedSbtTargetTables = newArrayList();
        expectedSbtTargetTables.add(new SbtTargetTable(targetTableId, quarter,
            startCadenceTargetTable, endCadence, timestampSeries,
            expectedSbtModOuts));

        List<SbtBadPixelInterval> expectedSbtBadPixelIntervals = newArrayList();
        expectedSbtBadPixelIntervals.add(new SbtBadPixelInterval(
            startMjdTargetTable, endMjd, pixelType.toString(), badPixelValue));

        SbtStatistic expectedPixelCorrelationStatistic = new SbtStatistic(
            valueFloat, significance);

        SbtQuantity expectedSbtQuantity = new SbtQuantity(valueFloat,
            uncertainty);

        SbtDoubleQuantity expectedSbtDoubleQuantity = new SbtDoubleQuantity(
            valueDouble, uncertainty);

        SbtDifferenceImagePixelData expectedDifferenceImagePixelData = new SbtDifferenceImagePixelData(
            row, column, expectedSbtQuantity, expectedSbtQuantity,
            expectedSbtQuantity, expectedSbtQuantity);

        List<SbtPixelPlanetResults> expectedPlanetResults = newArrayList();
        expectedPlanetResults.add(new SbtPixelPlanetResults(planetNumber,
            expectedPixelCorrelationStatistic, expectedDifferenceImagePixelData));

        List<SbtPixel> expectedSbtPixels = newArrayList();
        expectedSbtPixels.add(new SbtPixel(row, column, inOptimalAperture,
            rawPixelTimeSeries, calPixelTimeSeries, cosmicRayEventsTimeSeries,
            expectedSbtBadPixelIntervals, expectedPlanetResults));

        SbtTadData expectedSbtTadData = new SbtTadData(
            labels.toArray(new String[0]), signalToNoiseRatio, magnitude, ra,
            dec, effectiveTemp, badPixelCount, crowdingMetric,
            skyCrowdingMetric, fluxFractionInAperture, distanceFromEdge,
            saturatedRowCount);

        List<SbtCompoundTimeSeries> expectedSbtCalTargetMetricTimeSeriesList = newArrayList();
        expectedSbtCalTargetMetricTimeSeriesList.add(new SbtCompoundTimeSeries(
            calTargetMetricTimeSeriesType.toString(), calTargetMetricTimeSeries));

        SbtCentroidOffsets expectedCentroidOffsets = new SbtCentroidOffsets(
            expectedSbtQuantity, expectedSbtQuantity, expectedSbtQuantity,
            expectedSbtQuantity, expectedSbtQuantity, expectedSbtQuantity);

        SbtImageCentroid expectedImageCentroid = new SbtImageCentroid(
            expectedSbtQuantity, expectedSbtDoubleQuantity,
            expectedSbtDoubleQuantity, expectedSbtQuantity);

        SbtQualityMetric expectedQualityMetric = new SbtQualityMetric(
            attempted, valid, valueFloat);

        List<SbtDifferenceImagePixelData> expectedDifferenceImagePixelDataList = newArrayList();
        expectedDifferenceImagePixelDataList.add(expectedDifferenceImagePixelData);

        SbtPixelCorrelationResults expectedPixelCorrelationResults = new SbtPixelCorrelationResults(
            expectedCentroidOffsets, expectedImageCentroid,
            expectedImageCentroid, expectedCentroidOffsets,
            expectedImageCentroid);

        SbtDifferenceImageResults expectedDifferenceImageResults = new SbtDifferenceImageResults(
            expectedCentroidOffsets, expectedImageCentroid,
            expectedImageCentroid, expectedCentroidOffsets,
            expectedImageCentroid, numberOfTransits, numberOfCadencesInTransit,
            numberOfCadenceGapsInTransit, numberOfCadencesOutOfTransit,
            numberOfCadenceGapsOutOfTransit, expectedQualityMetric,
            expectedDifferenceImagePixelDataList);

        List<SbtAperturePlanetResults> expectedAperturePlanetResults = newArrayList();
        expectedAperturePlanetResults.add(new SbtAperturePlanetResults(
            planetNumber, expectedPixelCorrelationResults,
            expectedDifferenceImageResults));

        SbtLimbDarkeningModel expectedLimbDarkeningModel = new SbtLimbDarkeningModel(
            modelName, coefficient1, coefficient2, coefficient3, coefficient4);

        List<SbtAperture> expectedSbtApertures = newArrayList();
        expectedSbtApertures.add(new SbtAperture(targetTableId, quarter,
            startCadenceTargetTable, endCadence, ccdModule, ccdOutput,
            expectedSbtTadData, expectedSbtPixels,
            expectedSbtCalTargetMetricTimeSeriesList,
            expectedAperturePlanetResults, expectedLimbDarkeningModel));

        SbtTpsResult expectedSbtTpsResult = new SbtTpsResult(
            trialTransitPulseInHours, detectedOrbitalPeriodInDays,
            isPlanetACandidate, maxSingleEventStatistic,
            maxMultipleEventStatistic, timeToFirstTransitInDays, rmsCdpp,
            timeOfFirstTransitInMjd, cdppTimeSeries, minMultipleEventStatistic,
            timeToFirstMicrolensInDays, timeOfFirstMicrolensInMjd,
            detectedMicrolensOrbitalPeriodInDays);

        List<SbtTpsResult> expectedTpsResultsList = newArrayList();
        expectedTpsResultsList.add(expectedSbtTpsResult);

        SbtStatistic expectedSbtStatistic = new SbtStatistic(valueFloat,
            significance);

        SbtPlanetStatistic expectedSbtPlanetStatistic = new SbtPlanetStatistic(
            valueFloat, significance, planetNumber);

        SbtCentroidMotionResults expectedSbtCentroidMotionResults = new SbtCentroidMotionResults(
            expectedSbtStatistic, expectedSbtDoubleQuantity,
            expectedSbtDoubleQuantity, expectedSbtQuantity,
            expectedSbtQuantity, expectedSbtQuantity, expectedSbtQuantity);

        SbtBootstrapHistogram expectedSbtBootstrapHistogram = new SbtBootstrapHistogram(
            finalSkipCount, probabilitiesArray, statisticsArray);

        SbtModelParameter expectedSbtModelParameter = new SbtModelParameter(
            name, valueDouble, uncertainty, fitted);

        List<SbtModelParameter> expectedSbtModelParameters = newArrayList();
        expectedSbtModelParameters.add(expectedSbtModelParameter);

        SbtBinaryDiscriminationResults expectedSbtBinaryDiscriminationResults = new SbtBinaryDiscriminationResults(
            expectedSbtPlanetStatistic, expectedSbtPlanetStatistic,
            expectedSbtStatistic, expectedSbtStatistic, expectedSbtStatistic,
            expectedSbtStatistic, expectedSbtStatistic);

        SbtMqCentroidOffsets expectedMqCentroidOffsets = new SbtMqCentroidOffsets(
            expectedSbtQuantity, expectedSbtQuantity, expectedSbtQuantity,
            expectedSbtQuantity, expectedSbtQuantity, expectedSbtQuantity);

        SbtMqImageCentroid expectedMqImageCentroid = new SbtMqImageCentroid(
            expectedSbtDoubleQuantity, expectedSbtDoubleQuantity);

        SbtSummaryQualityMetric expectedSummaryQualityMetric = new SbtSummaryQualityMetric();

        SbtDifferenceImageMotionResults expectedDifferenceImageMotionResults = new SbtDifferenceImageMotionResults(
            expectedMqCentroidOffsets, expectedMqCentroidOffsets,
            expectedMqImageCentroid, expectedMqImageCentroid,
            expectedSummaryQualityMetric);

        SbtPixelCorrelationMotionResults expectedPixelCorrelationMotionResults = new SbtPixelCorrelationMotionResults(
            expectedMqCentroidOffsets, expectedMqCentroidOffsets,
            expectedMqImageCentroid, expectedMqImageCentroid);

        SbtCentroidResults expectedSbtCentroidResults = new SbtCentroidResults(
            expectedSbtCentroidMotionResults, expectedSbtCentroidMotionResults,
            expectedDifferenceImageMotionResults,
            expectedPixelCorrelationMotionResults);

        SbtWeakSecondary expectedWeakSecondary = new SbtWeakSecondary();

        SbtPlanetCandidate expectedPlanetCandidate = new SbtPlanetCandidate(
            epochMjd, maxMultipleEventSigma, maxSingleEventSigma,
            modelChiSquare2, modelChiSquareDof2, modelChiSquareGof,
            modelChiSquareGofDof, orbitalPeriod, trialTransitPulseDuration,
            expectedWeakSecondary, expectedSbtBootstrapHistogram,
            expectedTransitCount, observedTransitCount, planetNumber,
            significance, statisticRatioBelowThreshold,
            suspectedEclipsingBinary, initialFluxTimeSeries);

        SbtPlanetModelFit expectedSbtPlanetModelFit = new SbtPlanetModelFit(
            fullConvergence, limbDarkeningModelName, modelChiSquare,
            modelDegreesOfFreedom, modelFitSnr, modelParameterCovarianceArray,
            expectedSbtModelParameters, planetNumber, seededWithPriorFit,
            transitModelName);

        List<SbtPlanetModelFit> expectedSbtPlanetModelFits = newArrayList();
        expectedSbtPlanetModelFits.add(expectedSbtPlanetModelFit);

        List<SbtDifferenceImageResults> expectedSbtDifferenceImageResults = newArrayList();
        expectedSbtDifferenceImageResults.add(expectedDifferenceImageResults);

        SbtGhostDiagnosticResults expectedGhostDiagnosticResults = new SbtGhostDiagnosticResults(
            expectedSbtStatistic, expectedSbtStatistic);

        List<SbtPixelCorrelationResults> expectedSbtPixelCorrelationResults = newArrayList();
        expectedSbtPixelCorrelationResults.add(expectedPixelCorrelationResults);

        SbtPlanetResults expectedSbtPlanetResults = new SbtPlanetResults(
            expectedSbtPlanetModelFit, expectedSbtBinaryDiscriminationResults,
            expectedSbtCentroidResults, expectedSbtDifferenceImageResults,
            expectedSbtPlanetModelFit, expectedSbtPlanetModelFit,
            expectedGhostDiagnosticResults, expectedSbtPixelCorrelationResults,
            expectedPlanetCandidate, planetNumber, expectedSbtPlanetModelFits,
            expectedSbtPlanetModelFits, expectedSbtPlanetModelFit,
            modelLightCurveTimeSeries, whitenedModelLightCurveTimeSeries,
            trapezoidalModelLightCurveTimeSeries, whitenedFluxTimeSeries,
            detrendedFluxTimeSeries);

        List<SbtPlanetResults> expectedSbtPlanetResultsList = newArrayList();
        expectedSbtPlanetResultsList.add(expectedSbtPlanetResults);

        List<SbtSimpleTimeSeries> expectedSbtSingleEventStatisticsGroups = newArrayList();
        expectedSbtSingleEventStatisticsGroups.add(new SbtSimpleTimeSeries(
            dvSingleEventStatisticsType.toString(),
            dvSingleEvenStatisticsTimeSeries));

        SbtSingleEventStatistics sbtSingleEventStatistics = new SbtSingleEventStatistics(
            trialTransitPulseDuration, expectedSbtSingleEventStatisticsGroups);

        List<SbtSingleEventStatistics> expectedSbtSingleEventStatisticsList = newArrayList();
        expectedSbtSingleEventStatisticsList.add(sbtSingleEventStatistics);

        List<SbtCentroidTimeSeries> expectedSbtCentroidGroups = newArrayList();
        expectedSbtCentroidGroups.add(new SbtCentroidTimeSeries(
            centroidType.toString(), centroids));

        List<SbtCorrectedFluxAndOutliersTimeSeries> expectedSbtCorrectedFluxTimeSeriesList = newArrayList();
        expectedSbtCorrectedFluxTimeSeriesList.add(new SbtCorrectedFluxAndOutliersTimeSeries(
            correctedFluxType.toString(), correctedFluxTimeSeries,
            outliersTimeSeries));

        List<SbtPdcProcessingCharacteristics> expectedSbtProcessingCharacteristics = newArrayList();
        expectedSbtProcessingCharacteristics.add(new SbtPdcProcessingCharacteristics(
            keplerId, startCadenceMultiQuarter, endCadence,
            pdcProcessingCharacteristics));

        SbtCorrectedFluxTimeSeries sbtResidualFluxTimeSeries = new SbtCorrectedFluxTimeSeries(
            residualFluxTimeSeries);
        SbtQuantityWithProvenance sbtEffectiveTemp = new SbtQuantityWithProvenance(
            dvTargetResults.getEffectiveTemp());
        SbtQuantityWithProvenance sbtLog10Metallicity = new SbtQuantityWithProvenance(
            dvTargetResults.getLog10Metallicity());
        SbtQuantityWithProvenance sbtLog10SurfaceGravity = new SbtQuantityWithProvenance(
            dvTargetResults.getLog10SurfaceGravity());
        SbtQuantityWithProvenance sbtRadius = new SbtQuantityWithProvenance(
            dvTargetResults.getRadius());
        SbtDoubleQuantityWithProvenance sbtDecDegrees = new SbtDoubleQuantityWithProvenance(
            dvTargetResults.getDecDegrees());
        SbtQuantityWithProvenance sbtKeplerMag = new SbtQuantityWithProvenance(
            dvTargetResults.getKeplerMag());
        SbtDoubleQuantityWithProvenance sbtRaHours = new SbtDoubleQuantityWithProvenance(
            dvTargetResults.getRaHours());
        SbtString sbtQuartersObserved = new SbtString(quartersObserved);

        List<SbtFluxGroup> expectedSbtFluxGroups = newArrayList();
        expectedSbtFluxGroups.add(new SbtFluxGroup(fluxType.toString(),
            rawFluxTimeSeries, expectedSbtCorrectedFluxTimeSeriesList,
            expectedSbtCentroidGroups, discontinuityIndices,
            expectedSbtProcessingCharacteristics, expectedTpsResultsList,
            new SbtDvResults(expectedSbtPlanetResultsList,
                sbtResidualFluxTimeSeries,
                expectedSbtSingleEventStatisticsList,
                barycentricCorrectedTimestamps, sbtEffectiveTemp,
                sbtLog10Metallicity, sbtLog10SurfaceGravity, sbtRadius,
                sbtDecDegrees, sbtKeplerMag, sbtRaHours, sbtQuartersObserved)));

        List<SbtTarget> expectedSbtTargets = newArrayList();
        expectedSbtTargets.add(new SbtTarget(keplerId,
            celestialObjectParameters, barycentricTimeOffsetsTimeSeries,
            expectedSbtFluxGroups, expectedSbtApertures));

        SbtData expectedSbtData = new SbtData(cadenceType.toString(),
            startCadenceMultiQuarter, endCadence, baseDescription,
            EnumList.valueOf(pipelineProducts), mqTimestampSeries,
            expectedSbtAttitudeSolution, expectedSbtPagTimeSeriesList,
            expectedSbtTargetTables, expectedSbtTargets,
            new ArrayList<SbtCsci>(), sbtSpacecraftMetadata,
            new ArrayList<SbtAncillaryData>());

        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(expectedSbtData, actualSbtData);
    }
}
