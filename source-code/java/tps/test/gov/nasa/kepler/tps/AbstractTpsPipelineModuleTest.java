/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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

package gov.nasa.kepler.tps;

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.common.utils.ReflectionEqualsMatcher;
import gov.nasa.kepler.fc.RollTimeModel;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesByFsId;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.pdc.PdcCrud;
import gov.nasa.kepler.hibernate.pdc.PdcProcessingCharacteristics;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrail;
import gov.nasa.kepler.hibernate.pi.DataAccountabilityTrailCrud;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.tad.TargetCrowdingInfo;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.hibernate.tps.WeakSecondaryDb;
import gov.nasa.kepler.mc.BootstrapModuleParameters;
import gov.nasa.kepler.mc.CustomTargetParameters;
import gov.nasa.kepler.mc.GapFillModuleParameters;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.ModuleAlert;
import gov.nasa.kepler.mc.ProducerTaskIdsStream;
import gov.nasa.kepler.mc.SetOfFsIdsMatcher;
import gov.nasa.kepler.mc.TargetListParameters;
import gov.nasa.kepler.mc.Transit;
import gov.nasa.kepler.mc.TransitOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcFilledIndicesTimeSeriesType;
import gov.nasa.kepler.mc.fs.PdcFsIdFactory.PdcOutliersTimeSeriesType;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.mc.uow.TargetListChunkUowTask;
import gov.nasa.kepler.pi.module.remote.RemoteExecutionParameters;
import gov.nasa.kepler.services.alert.AlertService;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.collections.map.DefaultedMap;
import org.jmock.Expectations;
import org.jmock.Mockery;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;
import com.google.common.collect.Iterators;
import com.google.common.collect.Lists;
import com.google.common.collect.Maps;

/**
 * Test data notes: Every odd cadence has been modified by PDC. There is one
 * keplerId for a custom target which should be ignored by TPS.
 * 
 * @author Sean McCauliff
 * 
 */
abstract class AbstractTpsPipelineModuleTest {

    private static final FluxType FLUX_TYPE = FluxType.SAP;
    private static final float MAX_SINGLE_EVENT_STAT = 1.0f;
    private static final float RMS_CDPP = 2.0f;
    private static final double ORBITAL_PEROID = 3.0;
    private static final float MAX_MULTI_EVENT_STAT = 4.0f;
    private static final boolean IS_PLANET_CANDIDATE = true;
    private static final double TIME_OF_FIRST_TRANSIT = 6.0;
    private static final float TIME_TO_FIRST_TRANSIT = 7.0f;
    private static final int START_CADENCE = 100;
    private static final int END_CADENCE = 500;
    private static final double START_MJD = 55555.0;
    private static final double END_MJD = 60000.0;
    private static final Float timeToFirstMicrolensInDays = 7.0f;
    private static final Double timeOfFirstMicrolensInMjd = 55555.0;
    private static final Float detectedMicrolensOrbitalPeriodInDays = 33.0f;
    private static final Boolean isShortPeriodEclipsingBinary = false;
    private static final Float minMultipleEventStatistic = 5.7f;
    private static final Float minSingleEventStatistic = 7.1f;
    private static final Float robustStatistic = 66.6f;
    private static final WeakSecondary weakSecondary = new WeakSecondary(
        new float[] { 1.0f }, new float[] { 2.0f }, 1.0f, 2.0f, 3.0f, 4.0f,
        5.0f, 6.0f, 7.0f, 8.0f, 9, 10.0f);
    private static final WeakSecondaryDb weakSecondaryDb = new WeakSecondaryDb(
        weakSecondary.maxMesPhaseInDays(), weakSecondary.maxMes(),
        weakSecondary.mes(), weakSecondary.phaseInDays(),
        weakSecondary.minMesPhaseInDays(), weakSecondary.minMes(),
        weakSecondary.mesMad(), weakSecondary.depthPpm(),
        weakSecondary.depthUncert(), weakSecondary.medianMes(),
        weakSecondary.nValidPhases(), weakSecondary.robustStatistic());
    private static final float chi1 = 1.0f;
    private static final float chi2 = 2.0f;
    private static final int chiDof1 = 3;
    private static final float chiDof2 = 4.1f; /* chiSquareDof2 */
    private static final float maxSesInMes = 15.5f;
    private static final float chiSquareGof = 16.5f;
    private static final int chiSquareGofDof = 17;
    private static final float sesProbability = 18.5f;
    private static final int sesProbabilityDof = 19;
    private static final float thresholdForDesiredPfa = 20.0f;
    private static final List<Integer> keplerIds = ImmutableList.of(1, 2, 3, 4);
    private static final List<Integer> excludedKeplerIds = ImmutableList.of(5);
    private static final List<Integer> keplerIdsIncludingExcluded = ImmutableList.of(
        1, 2, 3, 4, 5);

    private static final long PIPELINE_TASK_ID = 777382;
    private static final long PIPELINE_INSTANCE_ID = 98098304853904L;
    private static final long ORIGINATOR_1 = 66666661;
    private static final long ORIGINATOR_2 = 66666662;
    private static final FloatTimeSeries[] CDPP_TIME_SERIES;
    private static final FloatTimeSeries[] deemphasizedNormalizationTimeSeries;
    private static final FloatTimeSeries[] deemphasisWeight;
    private static final Double ALERT_TIME = START_MJD;
    private static final String ALERT_MESSAGE = "shields up";
    private static final Severity ALERT_SEVERITY = Severity.WARNING;
    private static final String[] TARGET_LIST_NAMES = { "planetary", "weird" };
    private static final String[] EXCLUDED_TARGET_LIST_NAMES = { "Nooooooo..." };
    private static final float[] TRIAL_TRAINSIT_PULSES = new float[] { 3.0f,
        6.0f, 12.0f };

    private static final int DISCONTINUITY_CADENCE = START_CADENCE + 1;
    private static final int SKY_GROUP_ID = 7;
    private static final TargetTable ttable1 = new TargetTable(
        TargetTable.TargetType.LONG_CADENCE) {
        {
            testSetId(1);
        }
    };
    private static final TargetTableLog ttableLog1 = new TargetTableLog(
        ttable1, START_CADENCE, (END_CADENCE - START_CADENCE) / 2);
    private static final TargetTable ttable2 = new TargetTable(
        TargetTable.TargetType.LONG_CADENCE) {
        {
            testSetId(2);
        }
    };
    private static final TargetTableLog ttableLog2 = new TargetTableLog(
        ttable2, (END_CADENCE - START_CADENCE) / 2 + 1, END_CADENCE);
    private static final List<TargetTableLog> ttableLogs = ImmutableList.of(
        ttableLog1, ttableLog2);

    static {
        int i = 0;
        FsId[] cdppIds = new FsId[keplerIds.size() * 3];
        FsId[] deemphasizedNormalizationIds = new FsId[cdppIds.length];
        FsId[] deemphasisWeightIds = new FsId[cdppIds.length];
        for (int keplerId : keplerIds) {
            for (int ttpIndex = 0; ttpIndex < TRIAL_TRAINSIT_PULSES.length; ttpIndex++, i++) {
                float ttp = TRIAL_TRAINSIT_PULSES[ttpIndex];
                cdppIds[i] = TpsFsIdFactory.getCdppId(PIPELINE_INSTANCE_ID, keplerId, ttp,
                    TpsType.TPS_FULL, FLUX_TYPE);
                deemphasizedNormalizationIds[i] = TpsFsIdFactory.getDeemphasizedNormalizationTimeSeriesId(
                    PIPELINE_INSTANCE_ID, keplerId, ttp);
                deemphasisWeightIds[i] = TpsFsIdFactory.getDeemphasisWeightsId(PIPELINE_INSTANCE_ID,
                    keplerId, ttp);
            }
        }
        CDPP_TIME_SERIES = MockUtils.createFloatTimeSeries(START_CADENCE,
            END_CADENCE, PIPELINE_TASK_ID, cdppIds);
        deemphasizedNormalizationTimeSeries = MockUtils.createFloatTimeSeries(
            START_CADENCE, END_CADENCE, PIPELINE_TASK_ID,
            deemphasizedNormalizationIds);
        deemphasisWeight = MockUtils.createFloatTimeSeries(START_CADENCE, END_CADENCE,
            PIPELINE_TASK_ID, deemphasisWeightIds);
        
    }

    private final PipelineTask pipelineTask = createPipelineTask();

    protected abstract Mockery getMockery();

    protected PipelineTask getPipelineTask() {
        return pipelineTask;
    }

    private RollTimeModel createRollTimeModel() {
        RollTimeModel rtModel = new RollTimeModel(new double[] { 1.0 },
            new int[] { 1 });
        return rtModel;
    }

    protected RollTimeOperations createRollTimeOperations() {
        final RollTimeOperations rtOps = getMockery().mock(
            RollTimeOperations.class);
        final TimestampSeries cadenceTimes = createTimestampSeries();
        getMockery().checking(new Expectations() {
            {
                one(rtOps).retrieveRollTimeModelAll();
                will(returnValue(createRollTimeModel()));

                one(rtOps).mjdToQuarter(
                    with(equal(cadenceTimes.startTimestamps)));
                will(returnValue(new int[cadenceTimes.startTimestamps.length]));
            }
        });

        return rtOps;

    }

    protected TransitOperations createTransitOps() {
        final TransitOperations transitOps = getMockery().mock(
            TransitOperations.class);

        @SuppressWarnings("unchecked")
        final Map<Integer, List<Transit>> transits = DefaultedMap.decorate(
            Maps.newHashMap(), Collections.emptyList());
        for (Integer keplerId : keplerIds) {
            transits.put(keplerId, ImmutableList.of(new Transit(keplerId,
                "KOI-000" + keplerId, false, 0, 0, 0)));
        }
        getMockery().checking(new Expectations() {
            {
                one(transitOps).getTransits(
                    ImmutableSet.copyOf(keplerIdsIncludingExcluded));
                will(returnValue(transits));
            }
        });

        return transitOps;
    }

    private static TimestampSeries createTimestampSeries() {
        double[] startMjd = new double[END_CADENCE - START_CADENCE + 1];
        double[] endMjd = new double[startMjd.length];
        double[] midMjd = new double[startMjd.length];
        int[] cadenceNumber = new int[startMjd.length];

        double mjdDeltaPerCadence = (END_MJD - START_MJD)
            / cadenceNumber.length;
        for (int i = 0; i < startMjd.length; i++) {
            midMjd[i] = mjdDeltaPerCadence * i + START_MJD;
            cadenceNumber[i] = i + START_CADENCE;
            startMjd[i] = midMjd[i] - mjdDeltaPerCadence / 2.0;
            endMjd[i] = midMjd[i] + mjdDeltaPerCadence / 2.0;

        }
        midMjd[midMjd.length - 1] = END_MJD;

        boolean[] gaps = new boolean[startMjd.length];
        boolean[] requantization = new boolean[startMjd.length];
        boolean[] weirdFlags = new boolean[startMjd.length];

        TimestampSeries timestampSeries = new TimestampSeries(startMjd, midMjd,
            endMjd, gaps, requantization, cadenceNumber, weirdFlags,
            weirdFlags, weirdFlags, weirdFlags, weirdFlags, weirdFlags,
            weirdFlags);

        return timestampSeries;
    }

    protected MjdToCadence createMjdToCadence() {
        final MjdToCadence mjdToCadence = getMockery().mock(MjdToCadence.class);
        final TimestampSeries cadenceTimes = createTimestampSeries();
        getMockery().checking(new Expectations() {
            {
                one(mjdToCadence).cadenceTimes(START_CADENCE, END_CADENCE,
                    true, false);
                will(returnValue(cadenceTimes));

                for (int cadence = START_CADENCE; cadence <= END_CADENCE; cadence++) {
                    if (cadence % 2 == 1) {
                        exactly(keplerIds.size()).of(mjdToCadence)
                            .mjdToCadence(
                                cadenceTimes.midTimestamps[cadence
                                    - START_CADENCE]);
                        will(returnValue(cadence));
                    }
                    one(mjdToCadence).pixelLogForCadence(cadence);
                    will(returnValue(null));
                }

                allowing(mjdToCadence).cadenceType();
                will(returnValue(CadenceType.LONG));
            }
        });

        return mjdToCadence;
    }

    protected CelestialObjectOperations createCelestialObjectOperations() {
        final CelestialObjectOperations celestialObjectOperations = getMockery().mock(
            CelestialObjectOperations.class);

        final List<CelestialObject> celestialObjects = new ArrayList<CelestialObject>();
        for (int keplerId : keplerIdsIncludingExcluded) {
            celestialObjects.add(new Kic.Builder(keplerId, keplerId + 1,
                keplerId + 2).build());
        }

        final List<CelestialObjectParameters> celestialObjectParametersList = new ArrayList<CelestialObjectParameters>();
        for (CelestialObject celestialObject : celestialObjects) {
            celestialObjectParametersList.add(new CelestialObjectParameters.Builder(
                celestialObject).build());
        }

        getMockery().checking(new Expectations() {
            {
                Set<Integer> keplerIdsAsSet = ImmutableSet.copyOf(keplerIdsIncludingExcluded);
                one(celestialObjectOperations).retrieveCelestialObjectParameters(
                    keplerIdsAsSet);
                will(returnValue(celestialObjectParametersList));
            }
        });

        return celestialObjectOperations;
    }

    protected TpsCrud createTpsCrud() {
        final TpsCrud tpsCrud = getMockery().mock(TpsCrud.class);
        final Set<Integer> keplerIdsSet = new HashSet<Integer>();
        for (int keplerId : keplerIds) {
            keplerIdsSet.add(keplerId);
        }

        for (int keplerId : keplerIds) {
            for (float trialTransitPulse : TRIAL_TRAINSIT_PULSES) {
                final TpsDbResult tpsDbResult = new TpsDbResult(keplerId,
                    trialTransitPulse, MAX_SINGLE_EVENT_STAT, RMS_CDPP,
                    START_CADENCE, END_CADENCE, FLUX_TYPE, getPipelineTask(),
                    ORBITAL_PEROID, IS_PLANET_CANDIDATE, MAX_MULTI_EVENT_STAT,
                    TIME_TO_FIRST_TRANSIT, TIME_OF_FIRST_TRANSIT,
                    minSingleEventStatistic, minMultipleEventStatistic,
                    timeToFirstMicrolensInDays, timeOfFirstMicrolensInMjd,
                    detectedMicrolensOrbitalPeriodInDays,
                    isShortPeriodEclipsingBinary, robustStatistic,
                    weakSecondaryDb, chi1, chi2, chiDof1, chiDof2, maxSesInMes,
                    chiSquareGof, chiSquareGofDof, thresholdForDesiredPfa);

                final ReflectionEquals reflectEq = new ReflectionEquals();
                reflectEq.excludeField(".*originator");
                getMockery().checking(new Expectations() {
                    {
                        one(tpsCrud).create(
                            with(ReflectionEqualsMatcher.reflectionEquals(
                                reflectEq, tpsDbResult)));
                    }
                });
            }
        }

        return tpsCrud;
    }

    protected LogCrud createLogCrud() {
        final LogCrud logCrud = getMockery().mock(LogCrud.class);

        getMockery().checking(new Expectations() {
            {
                atLeast(1).of(logCrud)
                    .retrieveFirstAndLastCadences(Cadence.CADENCE_LONG);
                will(returnValue(Pair.of(START_CADENCE, END_CADENCE)));
            }
        });

        return logCrud;
    }

    protected TargetCrud createTargetCrud() {

        final TargetCrud targetCrud = getMockery().mock(TargetCrud.class);
        getMockery().checking(new Expectations() {
            {
                one(targetCrud).retrieveTargetTableLogs(
                    TargetTable.TargetType.LONG_CADENCE, START_CADENCE,
                    END_CADENCE);
                will(returnValue(ttableLogs));
            }
        });

        final List<TargetTable> ttableList = new ArrayList<TargetTable>();
        ttableList.add(ttable1);
        ttableList.add(ttable2);

        final Map<Integer, TargetCrowdingInfo> crowdingMetrics = new HashMap<Integer, TargetCrowdingInfo>();
        for (int keplerId : keplerIds) {
            TargetCrowdingInfo info = new TargetCrowdingInfo(keplerId,
                new Double[] { 0.5, null }, new Integer[] { 2, null },
                new Integer[] { 1, null });
            crowdingMetrics.put(keplerId, info);
        }
        getMockery().checking(new Expectations() {
            {
                one(targetCrud).retrieveCrowdingMetricInfo(ttableList,
                    SKY_GROUP_ID);
                will(returnValue(crowdingMetrics));
            }
        });
        return targetCrud;
    }

    protected ProducerTaskIdsStream createProducerTaskIdsStream() {
        final Set<Long> taskIdSet = ImmutableSet.of(ORIGINATOR_1, ORIGINATOR_2);
        final ProducerTaskIdsStream ptis = getMockery().mock(
            ProducerTaskIdsStream.class);
        getMockery().checking(new Expectations() {
            {
                one(ptis).write(with(aNonNull(File.class)),
                    with(equal(taskIdSet)));
                one(ptis).read(with(aNonNull(File.class)));
                will(returnValue(taskIdSet));
            }
        });
        return ptis;
    }

    protected DataAccountabilityTrailCrud createDaTrailCrud() {

        final DataAccountabilityTrail daTrail = new DataAccountabilityTrail(
            PIPELINE_TASK_ID);
        daTrail.addProducerTaskId(ORIGINATOR_1);
        daTrail.addProducerTaskId(ORIGINATOR_2);
        final DataAccountabilityTrailCrud daTrailCrud = getMockery().mock(
            DataAccountabilityTrailCrud.class);
        getMockery().checking(new Expectations() {
            {
                one(daTrailCrud).create(daTrail);
            }
        });
        return daTrailCrud;
    }

    protected FileStoreClient createFileStoreClient() {
        // Read light curve series.
        final Map<FsId, TimeSeries> allTimeSeries = Maps.newHashMap();
        for (int keplerId : keplerIds) {
            FsId lightCurveId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX, FLUX_TYPE,
                Cadence.CadenceType.LONG, keplerId);

            FloatTimeSeries[] lightCurveTimeSeries = MockUtils.createFloatTimeSeries(
                START_CADENCE, END_CADENCE, ORIGINATOR_1,
                new FsId[] { lightCurveId });
            allTimeSeries.put(lightCurveId, lightCurveTimeSeries[0]);

            FsId uncertId = PdcFsIdFactory.getFluxTimeSeriesFsId(
                PdcFsIdFactory.PdcFluxTimeSeriesType.CORRECTED_FLUX_UNCERTAINTIES,
                FLUX_TYPE, Cadence.CadenceType.LONG, keplerId);
            FloatTimeSeries[] lightCurveUncertTimeSeries = MockUtils.createFloatTimeSeries(
                START_CADENCE, END_CADENCE, ORIGINATOR_1,
                new FsId[] { uncertId });
            allTimeSeries.put(uncertId, lightCurveUncertTimeSeries[0]);
        }

        final TimestampSeries timestampSeries = createTimestampSeries();
        final FileStoreClient fsClient = getMockery().mock(
            FileStoreClient.class);

        // fill indices and outlier time series.
        final List<FsId> filledIndicesIds = new ArrayList<FsId>();
        for (int keplerId : keplerIds) {
            filledIndicesIds.add(PdcFsIdFactory.getFilledIndicesFsId(
                PdcFilledIndicesTimeSeriesType.FILLED_INDICES, FLUX_TYPE,
                Cadence.CadenceType.LONG, keplerId));
        }
        int[] indices = new int[END_CADENCE - START_CADENCE + 1];
        boolean[] gaps = new boolean[indices.length];

        final double[] outliersMjdArray = new double[indices.length / 2];
        final float[] outliers = new float[outliersMjdArray.length];
        int outliersIndex = 0;
        for (int cadence = START_CADENCE; cadence <= END_CADENCE; cadence++) {
            if (cadence % 2 == 1) {
                indices[cadence - START_CADENCE] = cadence;
                outliersMjdArray[outliersIndex++] = timestampSeries.midTimestamps[cadence
                    - START_CADENCE];
            } else {
                gaps[cadence - START_CADENCE] = true;
            }
        }
        if (outliersIndex != outliersMjdArray.length) {
            throw new IllegalStateException("Too many/few timestamps.");
        }

        for (FsId filledId : filledIndicesIds) {
            IntTimeSeries filledIndicesTs = new IntTimeSeries(filledId,
                indices, START_CADENCE, END_CADENCE, gaps, ORIGINATOR_1);
            allTimeSeries.put(filledId, filledIndicesTs);
        }

        for (int keplerId : keplerIds) {
            int[] discontinuities = new int[END_CADENCE - START_CADENCE + 1];
            discontinuities[DISCONTINUITY_CADENCE] = 1;
            boolean[] disGaps = new boolean[discontinuities.length];
            Arrays.fill(disGaps, true);
            disGaps[DISCONTINUITY_CADENCE] = false;
            FsId discontinuityFsId = PdcFsIdFactory.getDiscontinuityIndicesFsId(
                FLUX_TYPE, CadenceType.LONG, keplerId);
            IntTimeSeries discontinutyTimeSeries = new IntTimeSeries(
                discontinuityFsId, discontinuities, START_CADENCE, END_CADENCE,
                disGaps, ORIGINATOR_1);
            allTimeSeries.put(discontinuityFsId, discontinutyTimeSeries);
        }

        final SetOfFsIdsMatcher timeSeriesIdMatcher = new SetOfFsIdsMatcher(
            allTimeSeries.keySet());

        getMockery().checking(new Expectations() {
            {
                one(fsClient).readTimeSeries(with(timeSeriesIdMatcher),
                    with(START_CADENCE), with(END_CADENCE), with(false));
                will(returnValue(allTimeSeries));
            }
        });

        // outlier MJD time series.
        final Map<FsId, FloatMjdTimeSeries> outlierSeries = Maps.newHashMap();
        for (int keplerId : keplerIds) {
            FsId outlierFsId = PdcFsIdFactory.getOutlierTimerSeriesId(
                PdcOutliersTimeSeriesType.OUTLIERS, FLUX_TYPE,
                Cadence.CadenceType.LONG, keplerId);

            FloatMjdTimeSeries outlierTimeSeries = new FloatMjdTimeSeries(
                outlierFsId, timestampSeries.startMjd(),
                timestampSeries.endMjd(), outliersMjdArray, outliers,
                ORIGINATOR_2);
            outlierSeries.put(outlierFsId, outlierTimeSeries);
        }

        getMockery().checking(new Expectations() {
            {
                one(fsClient).readMjdTimeSeries(outlierSeries.keySet(),
                    timestampSeries.startMjd(), timestampSeries.endMjd());
                will(returnValue(outlierSeries));
            }
        });

        // Write
        // Assemble expected CDPP time series.
        final List<FloatTimeSeries> cdppToWrite = Lists.newArrayList();
        for (int i = 0; i < CDPP_TIME_SERIES.length; i++) {
            cdppToWrite.add(CDPP_TIME_SERIES[i]);
        }

        // Weak secondary interactions
        // The first weak secondary time series will have an existing time
        // series
        // so that it needs to change its end time series.
        List<FloatTimeSeries> weakSecondaryTimeSeries = Lists.newArrayList();
        for (int keplerId : keplerIds) {
            for (float trialTransitPulse : TRIAL_TRAINSIT_PULSES) {
                // putArrays() has been tested elsewhere.
                weakSecondary.putArrays(PIPELINE_INSTANCE_ID, weakSecondaryTimeSeries, keplerId,
                    trialTransitPulse, pipelineTask);
            }
        }

        final FsId[] weakSecondaryIds = new FsId[weakSecondaryTimeSeries.size()];
        for (int i = 0; i < weakSecondaryIds.length; i++) {
            weakSecondaryIds[i] = weakSecondaryTimeSeries.get(i)
                .id();
        }

        @SuppressWarnings("rawtypes")
        final List[] existingIntervals = new List[weakSecondaryIds.length];
        existingIntervals[0] = ImmutableList.of(new SimpleInterval(0, 100));
        for (int i = 1; i < existingIntervals.length; i++) {
            existingIntervals[i] = Collections.emptyList();
        }

        FloatTimeSeries orig = weakSecondaryTimeSeries.get(0);
        float[] paddedSeries = Arrays.copyOf(orig.fseries(), 101);
        FloatTimeSeries newEndWeakTimeSeries = new FloatTimeSeries(orig.id(),
            paddedSeries, orig.startCadence(), 100, orig.validCadences(),
            orig.originators());
        weakSecondaryTimeSeries.set(0, newEndWeakTimeSeries);

        //I hate this. I really need to have a write(Collection) method in the file store.
        final TimeSeries[] writeMe = Lists.newArrayList(
            Iterators.concat(
                Arrays.asList(deemphasizedNormalizationTimeSeries).iterator(),
                cdppToWrite.iterator(),
                Arrays.asList(deemphasisWeight).iterator(),
                weakSecondaryTimeSeries.iterator()))
            .toArray(new TimeSeries[0]);
        Arrays.sort(writeMe, TimeSeriesByFsId.INSTANCE);
        getMockery().checking(new Expectations() {{
            one(fsClient).getCadenceIntervalsForId(weakSecondaryIds);
            will(returnValue(existingIntervals));

            one(fsClient).writeTimeSeries(writeMe);
            }
        });

        return fsClient;
    }

    protected PdcCrud createPdcCrud() {
        final PdcCrud pdcCrud = getMockery().mock(PdcCrud.class);
        getMockery().checking(new Expectations() {
            {
                for (TargetTableLog ttableLog : ttableLogs) {
                    List<PdcProcessingCharacteristics> allDbPpcs = Lists.newArrayList();
                    for (int keplerId : keplerIds) {

                        PdcProcessingCharacteristics dbppc = new PdcProcessingCharacteristics();
                        dbppc.setKeplerId(keplerId);
                        allDbPpcs.add(dbppc);
                    }
                    Set<Integer> keplerIdsAsSet = ImmutableSet.copyOf(keplerIds);
                    atLeast(1).of(pdcCrud)
                        .retrievePdcProcessingCharacteristics(FluxType.SAP,
                            CadenceType.LONG, keplerIdsAsSet,
                            ttableLog.getCadenceStart(),
                            ttableLog.getCadenceEnd());
                    will(returnValue(allDbPpcs));
                }
            }
        });

        return pdcCrud;
    }

    protected AlertService createAlertService() {
        final AlertService alertService = getMockery().mock(AlertService.class);
        getMockery().checking(new Expectations() {
            {
                one(alertService).generateAlert(
                    TpsPipelineModule.MODULE_NAME,
                    PIPELINE_TASK_ID,
                    ALERT_SEVERITY,
                    String.format(TpsPipelineModule.ALERT_MESSAGE_FORMAT,
                        ALERT_MESSAGE, ALERT_TIME));
                ;
            }
        });
        return alertService;
    }

    protected TargetSelectionCrud createTargetSelectionCrud() {
        final TargetSelectionCrud targetSelectionCrud = getMockery().mock(
            TargetSelectionCrud.class);
        final List<Integer> preFilteredKeplerIds = Lists.newArrayList();
        preFilteredKeplerIds.addAll(keplerIds);
        preFilteredKeplerIds.addAll(excludedKeplerIds);

        getMockery().checking(new Expectations() {
            {
                one(targetSelectionCrud).retrieveKeplerIdsForTargetListName(
                    Arrays.asList(TARGET_LIST_NAMES), SKY_GROUP_ID,
                    keplerIds.get(0), keplerIds.get(keplerIds.size() - 1));
                will(returnValue(preFilteredKeplerIds));
                one(targetSelectionCrud).retrieveKeplerIdsForTargetListName(
                    Arrays.asList(EXCLUDED_TARGET_LIST_NAMES), SKY_GROUP_ID,
                    keplerIds.get(0), keplerIds.get(keplerIds.size() - 1));
                will(returnValue(excludedKeplerIds));
            }
        });
        return targetSelectionCrud;
    }

    protected void initTpsOutputs(TpsOutputs tpsOutputs) {

        List<TpsResult> tpsResults = new ArrayList<TpsResult>();
        int cdppIndex = 0;
        for (int keplerId : keplerIds) {
            for (float trialTransitPulse : TRIAL_TRAINSIT_PULSES) {
                TpsResult tpsResult = new TpsResult();
                tpsResult.setCdppTimeSeries(CDPP_TIME_SERIES[cdppIndex].fseries());
                tpsResult.setDetectedOrbitalPeriodInDays(ORBITAL_PEROID);
                tpsResult.setKeplerId(keplerId);
                tpsResult.setMaxMultipleEventStatistic(MAX_MULTI_EVENT_STAT);
                tpsResult.setMaxSingleEventStatistic(MAX_SINGLE_EVENT_STAT);
                tpsResult.setPlanetACandidate(IS_PLANET_CANDIDATE);
                tpsResult.setRmsCdpp(RMS_CDPP);
                tpsResult.setTimeOfFirstTransitInMjd(TIME_OF_FIRST_TRANSIT);
                tpsResult.setTimeToFirstTransitInDays(TIME_TO_FIRST_TRANSIT);
                tpsResult.setTrialTransitPulseInHours(trialTransitPulse);
                tpsResult.setMinMultipleEventStatistic(minMultipleEventStatistic);
                tpsResult.setTimeOfFirstMicrolensInMjd(timeOfFirstMicrolensInMjd);
                tpsResult.setTimeToFirstMicrolensInDays(timeToFirstMicrolensInDays);
                tpsResult.setDetectedMicrolensOrbitalPeriodInDays(detectedMicrolensOrbitalPeriodInDays);
                tpsResult.setMinSingleEventStatistic(minSingleEventStatistic);
                tpsResult.setShortPeriodEclipsingBinary(isShortPeriodEclipsingBinary);
                tpsResult.setRobustStatistic(robustStatistic);
                tpsResult.setWeakSecondary(weakSecondary);
                tpsResult.setChiSquare1(chi1);
                tpsResult.setChiSquare2(chi2);
                tpsResult.setChiSquareDof1(chiDof1);
                tpsResult.setChiSquareDof2(chiDof2);
                tpsResult.setMaxSesInMes(maxSesInMes);
                tpsResult.setDeemphasizedNormalizationTimeSeries(deemphasizedNormalizationTimeSeries[cdppIndex].fseries());
                tpsResult.setChiSquareGof(chiSquareGof);
                tpsResult.setChiSquareGofDof(chiSquareGofDof);
                tpsResult.setSesProbability(sesProbability);
                tpsResult.setSesProbabilityDof(sesProbabilityDof);
                tpsResult.setThresholdForDesiredPfa(thresholdForDesiredPfa);
                tpsResult.setDeemphasisWeight(deemphasisWeight[cdppIndex].fseries());
                tpsResults.add(tpsResult);
                cdppIndex++;
            }
        }

        tpsOutputs.setTpsResults(tpsResults);
        ModuleAlert moduleAlert = new ModuleAlert(ALERT_TIME, ALERT_SEVERITY,
            ALERT_MESSAGE);
        tpsOutputs.setAlerts(Collections.singletonList(moduleAlert));
    }

    private static void addTargetListParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        TargetListParameters targetListP = new TargetListParameters(1,
            TARGET_LIST_NAMES, EXCLUDED_TARGET_LIST_NAMES);
        ParameterSet pSet = new ParameterSet("targetList");
        pSet.setParameters(new BeanWrapper<Parameters>(targetListP));

        pipelineInstanceNode.putModuleParameterSet(TargetListParameters.class,
            pSet);
    }

    private static void addCadenceRangeParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        CadenceRangeParameters cadenceRangeP = new CadenceRangeParameters(
            0 /* calculate the first cadence */, END_CADENCE);
        ParameterSet pSet = new ParameterSet("cadence");
        pSet.setParameters(new BeanWrapper<Parameters>(cadenceRangeP));

        pipelineInstanceNode.putModuleParameterSet(
            CadenceRangeParameters.class, pSet);
    }

    private static void addTpsModuleParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        TpsModuleParameters tpsModuleParameters = new TpsModuleParameters();
        tpsModuleParameters.setTpsLiteEnabled(false);
        tpsModuleParameters.setRequiredTrialTransitPulseInHours(TRIAL_TRAINSIT_PULSES);

        ParameterSet pSet = new ParameterSet("tps");
        pSet.setParameters(new BeanWrapper<Parameters>(tpsModuleParameters));

        pipelineInstanceNode.putModuleParameterSet(TpsModuleParameters.class,
            pSet);
    }

    private static void addHarmonicsParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        TpsHarmonicsIdentificationParameters hIdentP = new TpsHarmonicsIdentificationParameters();
        ParameterSet pSet = new ParameterSet("hident");
        pSet.setParameters(new BeanWrapper<Parameters>(hIdentP));
        pipelineInstanceNode.putModuleParameterSet(
            TpsHarmonicsIdentificationParameters.class, pSet);
    }

    private static void addCustomTargetParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        ParameterSet pSet = new ParameterSet("custom target");
        pSet.setParameters(new BeanWrapper<Parameters>(
            new CustomTargetParameters()));
        pipelineInstanceNode.putModuleParameterSet(
            CustomTargetParameters.class, pSet);
    }

    private static void addGapFillModuleParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        GapFillModuleParameters gapFillP = new GapFillModuleParameters();
        ParameterSet pSet = new ParameterSet("gap");
        pSet.setParameters(new BeanWrapper<Parameters>(gapFillP));

        pipelineInstanceNode.putModuleParameterSet(
            GapFillModuleParameters.class, pSet);
    }
    
    private static void addBootstrapModuleParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        BootstrapModuleParameters bootstrapParameters = new BootstrapModuleParameters();
        ParameterSet pSet = new ParameterSet("bootstrap");
        pSet.setParameters(new BeanWrapper<Parameters>(bootstrapParameters));
        pipelineInstanceNode.putModuleParameterSet(BootstrapModuleParameters.class, pSet);
    }

    private static void addFluxTypeParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        FluxTypeParameters fluxTypeP = new FluxTypeParameters();
        fluxTypeP.setFluxType(FLUX_TYPE.name());
        ParameterSet pSet = new ParameterSet("flux");
        pSet.setParameters(new BeanWrapper<Parameters>(fluxTypeP));

        pipelineInstanceNode.putModuleParameterSet(FluxTypeParameters.class,
            pSet);
    }

    private static void addRemoteExecutionParameters(
        PipelineInstanceNode pipelineInstanceNode) {
        RemoteExecutionParameters remoteExecutionParameters = new RemoteExecutionParameters();
        ParameterSet pSet = new ParameterSet("remoteExecution");
        pSet.setParameters(new BeanWrapper<Parameters>(remoteExecutionParameters));
        pipelineInstanceNode.putModuleParameterSet(RemoteExecutionParameters.class, pSet);
    }
    
    private static TargetListChunkUowTask createUoW() {
        TargetListChunkUowTask uowTask = new TargetListChunkUowTask(
            SKY_GROUP_ID, keplerIds.get(0), keplerIds.get(keplerIds.size() - 1));
        return uowTask;
    }

    private static PipelineInstance createPipelineInstance() {

        PipelineInstance instance = new PipelineInstance();
        instance.setId(PIPELINE_INSTANCE_ID);
        return instance;
    }

    private static PipelineDefinitionNode createPipelineDefinitionNode(
        PipelineModuleDefinition moduleDefinition) {
        return new PipelineDefinitionNode(moduleDefinition.getName());
    }

    private static PipelineInstanceNode createPipelineInstanceNode() {
        PipelineModuleDefinition moduleDefinition = createPipelineModuleDefinition();
        PipelineDefinitionNode moduleDefinitionNode = createPipelineDefinitionNode(moduleDefinition);

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            createPipelineInstance(), moduleDefinitionNode, moduleDefinition);

        addTargetListParameters(pipelineInstanceNode);
        addCadenceRangeParameters(pipelineInstanceNode);
        addFluxTypeParameters(pipelineInstanceNode);
        addGapFillModuleParameters(pipelineInstanceNode);
        addTpsModuleParameters(pipelineInstanceNode);
        addHarmonicsParameters(pipelineInstanceNode);
        addCustomTargetParameters(pipelineInstanceNode);
        addBootstrapModuleParameters(pipelineInstanceNode);
        addRemoteExecutionParameters(pipelineInstanceNode);

        return pipelineInstanceNode;
    }

    private static PipelineModuleDefinition createPipelineModuleDefinition() {

        PipelineModuleDefinition pipelineModuleDefinition = new PipelineModuleDefinition(
            "Tps");
        pipelineModuleDefinition.setDescription("Transiting planet search.");
        pipelineModuleDefinition.setExeTimeoutSecs(10);
        pipelineModuleDefinition.setImplementingClass(new ClassWrapper<PipelineModule>(
            TpsPipelineModule.class));
        pipelineModuleDefinition.setExeName("tps");

        return pipelineModuleDefinition;
    }

    private static PipelineTask createPipelineTask() {

        PipelineInstance pipelineInstance = createPipelineInstance();
        PipelineInstanceNode instanceNode = createPipelineInstanceNode();

        PipelineTask task = new PipelineTask(pipelineInstance,
            instanceNode.getPipelineDefinitionNode(), instanceNode);
        task.setId(PIPELINE_TASK_ID);
        task.setUowTask(new BeanWrapper<UnitOfWorkTask>(createUoW()));
        task.setPipelineDefinitionNode(instanceNode.getPipelineDefinitionNode());

        return task;
    }
}
