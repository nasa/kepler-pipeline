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

package gov.nasa.kepler.ar.exporter;

import gov.nasa.kepler.ar.archive.BarycentricCorrection;
import gov.nasa.kepler.ar.archive.DvaTargetSource;
import gov.nasa.kepler.ar.archive.TargetDva;
import gov.nasa.kepler.ar.exporter.tpixel.TargetPixelExporterTest;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.*;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CustomTarget;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.pa.CentroidPixel;
import gov.nasa.kepler.hibernate.pa.TargetAperture;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tps.TpsLiteDbResult;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.SciencePixelOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.DrFsIdFactory;
import gov.nasa.kepler.mc.fs.DynablackFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidTimeSeriesType;
import gov.nasa.kepler.mc.fs.PaFsIdFactory.CentroidType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.pi.OriginatorsModelRegistryChecker;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.*;

import org.hamcrest.Description;
import org.hamcrest.Matcher;
import org.hamcrest.TypeSafeMatcher;
import org.jmock.Expectations;
import org.jmock.Mockery;

import com.google.common.base.Predicate;
import com.google.common.collect.*;

import static gov.nasa.spiffy.common.collect.ArrayUtils.fillCopyOf;

/**
 * Utility methods for testing the TargetPixelExporter and
 * FluxExporter2.
 * 
 * @author Sean McCauliff
 *
 */
public class PerTargetExporterTestUtils extends TestUtils {
    protected static final Integer customTargetKeplerId = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;

    protected static final String TIMESTAMP = "1858339202321";

    protected final Predicate<Pixel> keepOptimalAperture = new Predicate<Pixel>() {
        @Override
        public boolean apply(Pixel px) {
            return px.isInOptimalAperture();
        }
    };
    
    protected final CadenceType cadenceType = CadenceType.LONG;
    protected final Integer keplerId = 123456;
    protected final List<Integer> keplerIds = 
        Arrays.asList(new Integer[] { keplerId,customTargetKeplerId });
    protected final int customTargetRefRow = 66;
    protected final int customTargetRefColumn = 67;
    protected final int ttableExternalId = 34234;

    protected final int skyGroupId = 4;
    protected final DataAnomaly dataAnomaly = new DataAnomaly(
        DataAnomaly.DataAnomalyType.EXCLUDE, cadenceType.intValue(),
        referenceCadence + 1, endCadence);
    
    protected final Date generatedAt = new Date(3453453453L);

   
    protected final int referenceRow = 10;
    protected final int referenceColumn = 17;
    
    protected final Set<Pixel> targetPixels = ImmutableSet.of(
        new Pixel(0 + referenceRow, 1 + referenceColumn),
        new Pixel(0 + referenceRow, 2 + referenceColumn),
        new Pixel(1 + referenceRow, 0 + referenceColumn),
        new Pixel(1 + referenceRow, 1 + referenceColumn, null, true),
        new Pixel(1 + referenceRow, 2 + referenceColumn, null, true),
        new Pixel(1 + referenceRow, 3 + referenceColumn),
        new Pixel(2 + referenceRow, 1 + referenceColumn),
        new Pixel(2 + referenceRow, 2 + referenceColumn));
    
    protected final List<CentroidPixel> targetCentroidPixels =
        ImmutableList.of(new CentroidPixel(referenceRow +1, referenceColumn + 1, false, true));
    
    protected final TargetAperture targetAperture = 
        new TargetAperture.Builder(null, null, keplerId)
        .ccdModule(ccdModule)
        .ccdOutput(ccdOutput)
        .pixels(targetCentroidPixels)
        .build();
    
    @SuppressWarnings("unchecked")
    protected final TargetAperture customTargetAperture = 
        new TargetAperture.Builder(null, null, customTargetKeplerId)
        .ccdModule(ccdModule)
        .ccdOutput(ccdOutput)
        .pixels(Collections.EMPTY_LIST)
        .build();
    
    protected final Map<Integer, TargetAperture> targetApertures = 
        ImmutableMap.of(keplerId, targetAperture, customTargetKeplerId, customTargetAperture);
    
    protected final Pixel customTargetPixel = new Pixel(customTargetRefRow,
        customTargetRefColumn);
    
    @SuppressWarnings({ "rawtypes", "unchecked" })
    protected final SortedSet<Pixel> allTargetPixels = 
        new ImmutableSortedSet.Builder(PixelByRowColumn.INSTANCE)
    .addAll(targetPixels).add(customTargetPixel).build();

    protected final TimestampSeries timestampSeries = createTimestampSeries();
    
    protected final CelestialObject kic = 
        new Kic.Builder(keplerId, 23.1, 42.2).keplerMag((float) (Math.E * 3))
        .skyGroupId(skyGroupId)
        .build();
    
    protected final CelestialObject customTarget = 
        new CustomTarget.Builder(customTargetKeplerId).build();
    
    protected final List<CelestialObject> celestialObjects =
        ImmutableList.of(kic, customTarget);

    private final float[] bcCorrectionArray = 
        fillCopyOf(new float[0], cadenceLength, 1);
    
    private final BarycentricCorrection bcForRegularTarget = 
        new BarycentricCorrection(keplerId, bcCorrectionArray,
            new boolean[cadenceLength], -1, -1);
    
    private final BarycentricCorrection bcForCustomTarget = 
        new BarycentricCorrection( customTargetKeplerId, new float[cadenceLength],
        new boolean[cadenceLength], 7.1, 18.2);
    
    
    protected final Map<Integer, BarycentricCorrection> barycentricCorrections = 
        ImmutableMap.of(customTargetKeplerId, bcForCustomTarget,
             keplerId, bcForRegularTarget);

    private final TargetDva targetDva0 = createTargetDva(0, keplerId, startCadence,
        endCadence);
    private final TargetDva targetDva1 = createTargetDva(2, customTargetKeplerId,
        startCadence, endCadence);
    protected final Map<Integer, TargetDva> keplerIdToTargetDva =
        ImmutableMap.of(keplerId, targetDva0, customTargetKeplerId, targetDva1);
    
    @SuppressWarnings("unchecked")
    protected void commonSourceExpectations(Mockery mockery,
        final SingleQuarterExporterSource source,
        final ConfigMap configMap,
        final File exportDirectory,
        final FileStoreClient fsClient,
        final MjdToCadence mjdToCadence,
        final SciencePixelOperations sciOps,
        final ObservedTarget observedTarget,
        final ObservedTarget customObservedTarget,
        final OriginatorsModelRegistryChecker originatorsModelRegistryChecker,
        final boolean isK2) {

      
      final RollingBandUtils rollingBandUtils = mockery.mock(RollingBandUtils.class);
      mockery.checking(new Expectations() {{
          allowing(rollingBandUtils).rollingBandPulseDurations();
          will(returnValue(new int[] { ROLLING_BAND_TEST_PULSE_DURATION}));
          
          allowing(rollingBandUtils).columnCutoff();
          will(returnValue(1));
          
          allowing(rollingBandUtils).fluxThreshold(with(any(Double.class)));
          will(returnValue(2.7));
          
      }});
      final Matcher<Collection<DvaTargetSource>> customMatcher =
      new DvaTargetListMatcher<DvaTargetSource>();


        mockery.checking(new Expectations() {{
            atLeast(1).of(source).anomalies();
            will(returnValue(Collections.singletonList(dataAnomaly)));
            
            atLeast(1).of(source).ccdModule();
            will(returnValue(2));
            
            atLeast(1).of(source).ccdOutput();
            will(returnValue(1));
            
            atLeast(1).of(source) .configMaps();
            will(returnValue(Collections.singleton(configMap)));
            
            atLeast(1).of(source).dataReleaseNumber();
            will(returnValue(-7));
            
            atLeast(1).of(source) .endCadence();
            will(returnValue(endCadence));
            
            atLeast(1).of(source).exportDirectory();
            will(returnValue(exportDirectory));
            
            atLeast(1).of(source).fsClient();
            will(returnValue(fsClient));
            
            atLeast(1).of(source).gainE();
            will(returnValue(7.1));
            
            atLeast(1).of(source).keplerIds();
            will(returnValue(keplerIds));
            
            atLeast(1).of(source).mjdToCadence();
            will(returnValue(mjdToCadence));
            
            allowing(source).cadenceCount();
            will(returnValue(cadenceLength));
            
            atLeast(1).of(source).pipelineTaskId();
            will(returnValue(994444L));
            
            atLeast(1).of(source).programName();
            will(returnValue(TargetPixelExporterTest.class.getSimpleName()));
            
            if (!isK2) {
                atLeast(1).of(source).quarter();
                will(returnValue(8));
            }
            
            atLeast(1).of(source).readNoiseE();
            will(returnValue(0.75));
            
            atLeast(1).of(source).meanBlackValue();
            will(returnValue(92));
            
            atLeast(1).of(source).sciOps();
            will(returnValue(sciOps));
            
            if (!isK2) {
                atLeast(1).of(source).season();
                will(returnValue(observingSeason));
            }
            
            atLeast(1).of(source).startCadence();
            will(returnValue(startCadence));
            
            atLeast(1).of(source).observedTargets();
            will(returnValue(ImmutableList.of(observedTarget, customObservedTarget)));
            
            atLeast(1).of(source).timestampSeries();
            will(returnValue(timestampSeries));
            
            atLeast(1).of(source).targetTableExternalId();
            will(returnValue(ttableExternalId));
            
            
            allowing(source).barycentricCorrection(
                with(customMatcher),
                (Map<FsId, TimeSeries>) with(anything()));
            will(returnValue(barycentricCorrections));
            
            atLeast(2).of(source).fileTimestamp();
            will(returnValue(TIMESTAMP));
            // TODO: This could be better
            allowing(source).dvaMotion(with(aNonNull(Collection.class)),
                    with(aNonNull(Map.class)));
            will(returnValue(keplerIdToTargetDva));
            
            atLeast(1).of(source).originatorsModelRegistryChecker();
            will(returnValue(originatorsModelRegistryChecker));
            
            atLeast(1).of(source).celestialObjects();
            will(returnValue(celestialObjects));
            
            allowing(source).wasTargetDroppedBySupplementalTad(keplerId);
            will(returnValue(false));
            
            allowing(source).wasTargetDroppedBySupplementalTad(customTargetKeplerId);
            will(returnValue(false));
            
            atLeast(1).of(source).cadenceType();
            will(returnValue(cadenceType));
            
            allowing(source).targetApertures(with(aNonNull(Collection.class)));
            will(returnValue(targetApertures));
            
            atLeast(1).of(source).excludeTargetsWithLabel();
            will(returnValue(Collections.EMPTY_SET));
            
            atLeast(1).of(source).longCadenceTimestampSeries();
            will(returnValue(timestampSeries));
            
            atLeast(1).of(source).longCadenceExternalTargetTableId();
            will(returnValue(ttableExternalId));
            
            atLeast(1).of(source).generatedAt();
            will(returnValue(generatedAt));
            
            allowing(source).isK2();
            will(returnValue(isK2));
            
            allowing(source).rollingBandUtils();
            will(returnValue(rollingBandUtils));
            
            atLeast(1).of(source).cadenceToLongCadence(startCadence);
            will(returnValue(startCadence));
            atLeast(1).of(source).cadenceToLongCadence(endCadence);
            will(returnValue(endCadence));
            
        }});
    }
    
    
    @SuppressWarnings("unchecked")
    protected OriginatorsModelRegistryChecker  createOmrc(Mockery mockery) {
        final OriginatorsModelRegistryChecker originatorsModelRegistryChecker = mockery.mock(OriginatorsModelRegistryChecker.class);
        mockery.checking(new Expectations() {
            {
                exactly(1).of(originatorsModelRegistryChecker)
                    .check(
                        (Pair<Map<FsId, TimeSeries>, Map<FsId, FloatMjdTimeSeries>>) with(anything()));
            }
        });
        
        return originatorsModelRegistryChecker;
    }
    
    protected PipelineTask createPipelineTask(Mockery mockery) {
        final PipelineTask pipelineTask = mockery.mock(PipelineTask.class);
        mockery.checking(new Expectations() {{
                atLeast(2).of(pipelineTask) .getId();
                will(returnValue(originator));
            }
        });
        return pipelineTask;
    }

    protected ObservedTarget createKicObservedTarget(Mockery mockery, final PipelineTask pipelineTask) {
        final ObservedTarget observedTarget = mockery.mock(
            ObservedTarget.class, "kic observed target");
        mockery.checking(new Expectations() {{
                one(observedTarget).getPipelineTask();
                will(returnValue(pipelineTask));
                atLeast(1).of(observedTarget).getKeplerId();
                will(returnValue(keplerId));
                one(observedTarget).getLabels();
                will(returnValue(Collections.EMPTY_SET));
                allowing(observedTarget).getCrowdingMetric();
                will(returnValue(0.1245));
                allowing(observedTarget).getFluxFractionInAperture();
                will(returnValue(0.25));
                one(observedTarget).getClippedPixelCount();
                will(returnValue(1));
            }
        });
        return observedTarget;
    }

    protected ObservedTarget createCustomObservedTarget(Mockery mockery, final PipelineTask pipelineTask) {
        final ObservedTarget customObservedTarget = mockery.mock(
            ObservedTarget.class, "custom observed target");
        mockery.checking(new Expectations() {
            {
                one(customObservedTarget).getPipelineTask();
                will(returnValue(pipelineTask));
                atLeast(1).of(customObservedTarget).getKeplerId();
                will(returnValue(customTargetKeplerId));
                one(customObservedTarget).getLabels();
                will(returnValue(Collections.EMPTY_SET));
                allowing(customObservedTarget).getCrowdingMetric();
                will(returnValue(Double.NaN));
                one(customObservedTarget).getClippedPixelCount();
                will(returnValue(0));
                allowing(customObservedTarget).getFluxFractionInAperture();
                will(returnValue(Double.NaN));
            }
        });
        
        return customObservedTarget;
    }

    protected SciencePixelOperations createSciencePixelOperations(Mockery mockery,
        final ObservedTarget observedTarget,
        final ObservedTarget customObservedTarget) {
        final SciencePixelOperations sciOps = mockery.mock(SciencePixelOperations.class);
        mockery.checking(new Expectations() {
            {
                one(sciOps).loadTargetPixels(observedTarget, ccdModule, ccdOutput);
                will(returnValue(targetPixels));
                one(sciOps).loadTargetPixels(customObservedTarget, ccdModule,ccdOutput);
                will(returnValue(Collections.singleton(customTargetPixel)));
            }
        });
        
        return sciOps;
    }

    private List<TpsLiteDbResult> tpsResults(int keplerId) {
        if (TargetManagementConstants.isCustomTarget(keplerId)) {
            return Collections.emptyList();
        }
        
        PipelineTask task = new PipelineTask();
        //Yes, I mean not to have a 12.0 hour result.
        List<TpsLiteDbResult> tpsResults = 
            ImmutableList.of(
                new TpsLiteDbResult(keplerId, 3.0f, -1f, 3.1f,  startCadence, endCadence, FluxType.SAP, task, true),
                new TpsLiteDbResult(keplerId, 6.0f, -1f, 6.2f,  startCadence, endCadence, FluxType.SAP, task, true),
                new TpsLiteDbResult(keplerId, 6.5f, -1f, 12.3f, startCadence, endCadence, FluxType.SAP, task, false));
        return tpsResults;
    }
    
    protected void pixelMjdTimeSeries(Set<FsId> mjdTimeSeriesIds,
        Map<FsId, FloatMjdTimeSeries> idToMjdTimeSeries,
        double midStartMjd, final double midEndMjd,
        SortedSet<Pixel> targetPixelsByRowCol) {
        
        for (Pixel pixel : targetPixelsByRowCol) {
            FsId cosmicRay = PaFsIdFactory.getCosmicRaySeriesFsId(
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, pixel.getRow(),
                pixel.getColumn());
            FloatMjdTimeSeries crseries = new FloatMjdTimeSeries(cosmicRay,
                midStartMjd, midEndMjd,
                new double[] { timestampSeries.midTimestamps[1] },
                new float[1], originator);
            idToMjdTimeSeries.put(cosmicRay, crseries);
    
            mjdTimeSeriesIds.add(cosmicRay);
        }
    }
    
    protected void qualityAndCentroidRelated(
        int startCadence, int endCadence, List<Integer> keplerIds,
        TimestampSeries timestampSeries, int nCadences, double midStartMjd,
        double midEndMjd, Set<FsId> timeSeriesIds, Set<FsId> mjdTimeSeriesIds,
        Map<FsId, TimeSeries> idToTimeSeries,
        Map<FsId, FloatMjdTimeSeries> idToMjdTimeSeries) {
        
        boolean[] totallyGapped = new boolean[nCadences];
        Arrays.fill(totallyGapped, true);
        
        for (int keplerId : keplerIds) {

            FsId discontinuity = PdcFsIdFactory.getDiscontinuityIndicesFsId(
                FluxType.SAP, CadenceType.LONG, keplerId);
            idToTimeSeries.put(
                discontinuity,
                generateIntTimeSeries(1, discontinuity, originator,
                    startCadence, endCadence));
            FsId pdcOutlierId = PdcFsIdFactory.getOutlierTimerSeriesId(
                PdcOutliersTimeSeriesType.OUTLIERS, FluxType.SAP,
                CadenceType.LONG, keplerId);
            idToMjdTimeSeries.put(pdcOutlierId, new FloatMjdTimeSeries(
                pdcOutlierId, midStartMjd, midEndMjd,
                new double[] { timestampSeries.midTimestamps[1] },
                new float[1], originator));
            mjdTimeSeriesIds.add(pdcOutlierId);
            timeSeriesIds.addAll(Arrays.asList(new FsId[] { discontinuity}));

            // Centroids
            FsId rowCentroidId = PaFsIdFactory.getCentroidTimeSeriesFsId(
                FluxType.SAP, CentroidType.FLUX_WEIGHTED,
                CentroidTimeSeriesType.CENTROID_ROWS, CadenceType.LONG,
                keplerId);
            FsId columnCentroidId = PaFsIdFactory.getCentroidTimeSeriesFsId(
                FluxType.SAP, CentroidType.FLUX_WEIGHTED,
                CentroidTimeSeriesType.CENTROID_COLS, CadenceType.LONG,
                keplerId);
            timeSeriesIds.addAll(Arrays.asList(new FsId[] { rowCentroidId,
                columnCentroidId }));
            if (keplerId >= TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START) {
               
                DoubleTimeSeries emptyCol = new DoubleTimeSeries(
                    columnCentroidId, new double[nCadences], startCadence,
                    endCadence, totallyGapped, 0, false);
                idToTimeSeries.put(columnCentroidId, emptyCol);
                DoubleTimeSeries emptyRow = new DoubleTimeSeries(rowCentroidId,
                    new double[nCadences], startCadence, endCadence,
                    totallyGapped, 0, false);
                idToTimeSeries.put(rowCentroidId, emptyRow);
            } else {
                double[] colCentroids = new double[nCadences];
                Arrays.fill(colCentroids, 77);
                DoubleTimeSeries colCentroid = new DoubleTimeSeries(
                    columnCentroidId, colCentroids, startCadence, endCadence,
                    new boolean[] { true, false, false, false, false, false, true}, originator);
                idToTimeSeries.put(columnCentroidId, colCentroid);

                double[] rowCentroids = new double[nCadences];
                Arrays.fill(rowCentroids, 666);
                DoubleTimeSeries rowCentroid = new DoubleTimeSeries(
                    rowCentroidId, colCentroids, startCadence, endCadence,
                    new boolean[] { true, false, false, false, false, false, true}, originator);
                idToTimeSeries.put(rowCentroidId, rowCentroid);
            }
        }
    }
    
    protected void addTpsResultsExpectations(Mockery mockery, 
        final SingleQuarterExporterSource mockedSource) {
        mockery.checking(new Expectations() {{
            atLeast(1).of(mockedSource).tpsDbResults();
            will(returnValue(tpsResults(keplerId)));
        }});
    }
    
    @SuppressWarnings("unchecked")
    protected void addWcsExpectations(Mockery mockery,
        final SingleQuarterExporterSource mockedSource) {
        mockery.checking(new Expectations() {{
            atLeast(1).of(mockedSource).wcsCoordinates(with(aNonNull(List.class)),
                with(aNonNull(Map.class)));
            will(returnValue(Collections.emptyMap()));
        }});
    }
    
    protected void rollingBandFlagTimeSeries(Set<FsId> rollingBandIds, 
        Map<FsId, TimeSeries> idToTimeSeries, Set<Pixel> pixels) {
    
        for (Pixel pixel : pixels) {
            FsId rollingBandFlagId = DynablackFsIdFactory.getRollingBandArtifactFlagsFsId(ccdModule, ccdOutput, pixel.getRow(), ROLLING_BAND_TEST_PULSE_DURATION);
            idToTimeSeries.put(rollingBandFlagId,
                generateIntTimeSeries(0, rollingBandFlagId, originator, startCadence, endCadence));
            rollingBandIds.add(rollingBandFlagId);
        }
    }
    
    protected void pixelTimeSeries(int ccdModule, int ccdOutput,
        final int startCadence, final int endCadence,
        TimestampSeries timestampSeries, 
        Set<FsId> timeSeriesIds,
        Map<FsId, TimeSeries> idToTimeSeries,
        SortedSet<Pixel> targetPixelsByRowCol,
        boolean rollingBand) {
        
        int timeSeriesi = 0;
        for (Pixel pixel : targetPixelsByRowCol) {
            FsId cal = CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL,
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, pixel.getRow(),
                pixel.getColumn());
            idToTimeSeries.put(
                cal,
                generateFloatTimeSeries(timeSeriesi, cal, originator,
                    startCadence, endCadence));
            FsId umm = CalFsIdFactory.getTimeSeriesFsId(
                CalFsIdFactory.PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES,
                TargetType.LONG_CADENCE, ccdModule, ccdOutput, pixel.getRow(),
                pixel.getColumn());
            idToTimeSeries.put(
                umm,
                generateFloatTimeSeries(timeSeriesi, umm, originator,
                    startCadence, endCadence));
            FsId orig = DrFsIdFactory.getSciencePixelTimeSeries(
                DrFsIdFactory.TimeSeriesType.ORIG, TargetType.LONG_CADENCE,
                ccdModule, ccdOutput, pixel.getRow(), pixel.getColumn());
            
            idToTimeSeries.put(
                orig,
                generateIntTimeSeries(timeSeriesi, orig, originator,
                    startCadence, endCadence));
            
            if (rollingBand) {
                FsId rollingBandFsId = DynablackFsIdFactory
                    .getRollingBandArtifactVariationFsId(ccdModule, ccdOutput, pixel.getRow(), ROLLING_BAND_TEST_PULSE_DURATION);
                idToTimeSeries.put(rollingBandFsId, 
                    generateDoubleTimeSeries(rollingBandFsId, timeSeriesi, false, originator, startCadence, endCadence));
                timeSeriesIds.add(rollingBandFsId);
            }
            timeSeriesIds.addAll(Arrays.asList(new FsId[] { cal, umm, orig }));
            timeSeriesi++;
        }
    }
    
    private final static class DvaTargetListMatcher<T extends DvaTargetSource>
        extends TypeSafeMatcher<Collection<T>> {

        @Override
        public void describeTo(Description arg0) {
            arg0.appendText("dva target list matcher");
        }

        @Override
        public boolean matchesSafely(Collection<T> items) {
            if (items.size() != 2) {
                return false;
            }
            
            for (T dvaTargetSource : items) {
                if (dvaTargetSource == null) {
                    return false;
                }
            }
            return true;
        }
        
}

}
