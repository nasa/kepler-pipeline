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

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.common.pi.TpsType;
import gov.nasa.kepler.dv.io.DvCentroidData;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.dv.io.DvTargetData;
import gov.nasa.kepler.dv.io.DvTargetTableData;
import gov.nasa.kepler.dv.io.DvThresholdCrossingEvent;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsCrud;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.CorrectedFluxTimeSeries;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.OutliersTimeSeries;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.TpsFsIdFactory;
import gov.nasa.kepler.mc.tps.TpsOperations;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.pi.models.ModelOperations;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Test the {@link TargetTableOperations} class.
 *
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class TargetTableOperationsTest extends DvJMockTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TargetTableOperationsTest.class);

    private static final long TPS_TASK_ID = 100;
    private static final long TPS_INSTANCE_ID = 9848957349573957L;
    private static final long ANCILLARY_TASK_ID = 101;
    private static final long BACKGROUND_BLOB_TASK_ID = 102;
    private static final long MOTION_BLOB_TASK_ID = 103;
    private static final long ARGABRIGHTENING_TASK_ID = 104;
    private static final long CBV_BLOB_TASK_ID = 105;

    private final Set<Long> producerTaskIds = new HashSet<Long>();

    private AncillaryOperations ancillaryOperations;
    private BlobOperations blobOperations;
    private DataAnomalyOperations dataAnomalyOperations;
    private FileStoreClient fsClient;
    private LogCrud logCrud;
    private KicCrud kicCrud;
    private TpsCrud tpsCrud;
    private CelestialObjectOperations celestialObjectOperations;
    private RollTimeOperations rollTimeOperations;
    private TargetCrud targetCrud;
    private TargetSelectionCrud targetSelectionCrud;
    private TpsOperations tpsOperations;
    private ModelOperations<ExternalTceModel> externalTceModelOperations;

    private File matlabWorkingDir;

    private List<Integer> keplerIds = new ArrayList<Integer>();
    private Map<Integer, List<CelestialObjectParameters>> celestialObjectParametersListByKeplerId = new HashMap<Integer, List<CelestialObjectParameters>>();
    private List<TargetTableLog> targetTableLogs = new ArrayList<TargetTableLog>();
    private List<List<ObservedTarget>> observedTargetsList;
    private Set<FsId> allTargetFsIds = new TreeSet<FsId>();
    private MjdToCadence mjdToCadence;
    private TimestampSeries cadenceTimes;
    private List<TpsDbResult> tpsDbResults;
    private ExternalTceModel externalTceModel;
    private Map<TargetTableLog, List<AncillaryPipelineData>> ancillaryPipelineDataByTargetTableLog;
    private List<BlobFileSeries> backgroundBlobFileSeriesList;
    private List<BlobFileSeries> cbvBlobFileSeriesList;
    private List<BlobFileSeries> motionBlobFileSeriesList;
    private List<SkyGroup> skyGroups;
    private List<Integer> quarters;

    private DvJMockTest dvJMockTest = this;

    @Test
    public void testGetAllTargets() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        createMockObjects();
        populateObjects(unitTestDescriptor);

        validateAllTargets(unitTestDescriptor,
            getAllTargets(unitTestDescriptor));
    }

    @Test
    public void testGetAllTargetTableData() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        getAllTargetTableDataTest(unitTestDescriptor);
    }

    @Test
    public void testGetAllTargetTableDataWithAncillaryData() {
        UnitTestDescriptor unitTestDescriptor = new UnitTestDescriptor();
        unitTestDescriptor.setTargetTableCount(5);
        unitTestDescriptor.setAncillaryPipelineMnemonics(new String[] {
            "SOC_PA_ENCIRCLED_ENERGY", "SOC_PPA_BACKGROUND_LEVEL" });
        getAllTargetTableDataTest(unitTestDescriptor);
    }

    private void getAllTargetTableDataTest(UnitTestDescriptor unitTestDescriptor) {
        createMockObjects();
        populateObjects(unitTestDescriptor);

        TargetTableOperations targetTableOperations = createTargetTableOperations(unitTestDescriptor);
        List<DvTargetTableData> allTargetTableData = targetTableOperations.getAllTargetTableData();
        validateAllTargetTableData(unitTestDescriptor, allTargetTableData);
    }

    private void validateAllTargets(UnitTestDescriptor unitTestDescriptor,
        List<DvTarget> allTargets) {

        assertNotNull(allTargets);
        assertEquals(unitTestDescriptor.getTargetTableCount()
            * unitTestDescriptor.getTargetsPerTable(), allTargets.size());

        for (int i = 0; i < allTargets.size(); i++) {
            DvTarget dvTarget = allTargets.get(i);

            int keplerId = dvTarget.getKeplerId();
            List<CelestialObjectParameters> celestialObjectParametersList = celestialObjectParametersListByKeplerId.get(keplerId);
            assertNotNull(celestialObjectParametersList);
            assertEquals(1, celestialObjectParametersList.size());

            CelestialObjectParameters celestialObjectParameters = celestialObjectParametersList.get(0);
            assertNotNull(dvTarget.getCentroids());
            assertEquals(new DvCentroidData(), dvTarget.getCentroids());
            assertNotNull(dvTarget.getCorrectedFluxTimeSeries());
            assertEquals(new CorrectedFluxTimeSeries(),
                dvTarget.getCorrectedFluxTimeSeries());
            assertEquals(celestialObjectParameters.getDec(),
                dvTarget.getDecDegrees());
            assertEquals(celestialObjectParameters.getEffectiveTemp(),
                dvTarget.getEffectiveTemp());
            assertTrue(keplerIds.contains(dvTarget.getKeplerId()));
            assertEquals(celestialObjectParameters.getKeplerMag(),
                dvTarget.getKeplerMag());
            assertEquals(celestialObjectParameters.getLog10SurfaceGravity(),
                dvTarget.getLog10SurfaceGravity());
            assertNotNull(dvTarget.getOutliers());
            assertEquals(new OutliersTimeSeries(), dvTarget.getOutliers());
            assertEquals(celestialObjectParameters.getRadius(),
                dvTarget.getRadius());
            assertEquals(celestialObjectParameters.getRa(),
                dvTarget.getRaHours());
            assertNotNull(dvTarget.getTargetData());
            assertEquals(unitTestDescriptor.getTargetTableCount(),
                dvTarget.getTargetData()
                    .size());
            assertEquals(targetTableLogs.size(), dvTarget.getTargetData()
                .size());
            assertNotNull(dvTarget.getUkirtImageFileName());
            assertEquals(dvTarget.getUkirtImageFileName(), "");

            TpsDbResult tpsDbResult = maxTpsResult(dvTarget.getKeplerId());
            assertNotNull(tpsDbResult);
            validate(tpsDbResult, dvTarget.getThresholdCrossingEvent());
        }

        for (int i = 0; i < targetTableLogs.size(); i++) {
            List<ObservedTarget> observedTargets = observedTargetsList.get(i);
            for (int j = 0; j < allTargets.size(); j++) {
                ObservedTarget observedTarget = observedTargets.get(j);
                assertNotNull(observedTarget);
                DvTarget dvTarget = allTargets.get(j);
                DvTargetData targetData = dvTarget.getTargetData()
                    .get(i);
                validate(unitTestDescriptor, targetTableLogs.get(i), i + 1,
                    observedTarget, targetData);
            }
        }
    }

    private TpsDbResult maxTpsResult(int keplerId) {

        TpsDbResult maxTpsResult = null;

        for (TpsDbResult tpsResult : tpsDbResults) {
            if (tpsResult.getKeplerId() == keplerId) {
                if (maxTpsResult == null
                    || tpsResult.getMaxMultipleEventStatistic() > maxTpsResult.getMaxMultipleEventStatistic()) {
                    maxTpsResult = tpsResult;
                }
            }
        }

        return maxTpsResult;
    }

    private void validate(UnitTestDescriptor unitTestDescriptor,
        TargetTableLog targetTableLog, int quarter,
        ObservedTarget observedTarget, DvTargetData targetData) {

        assertNotNull(targetTableLogs);
        assertNotNull(targetData);

        assertEquals(DvMockUtils.CCD_MOD_OUTS[targetTableLog.getTargetTable()
            .getObservingSeason()][0], targetData.getCcdModule());
        assertEquals(DvMockUtils.CCD_MOD_OUTS[targetTableLog.getTargetTable()
            .getObservingSeason()][1], targetData.getCcdOutput());
        assertEquals(observedTarget.getCrowdingMetric(),
            targetData.getCrowdingMetric(), 0);
        assertEquals(targetTableLog.getCadenceEnd(), targetData.getEndCadence());
        assertEquals(observedTarget.getFluxFractionInAperture(),
            targetData.getFluxFractionInAperture(), 0);
        assertNotNull(targetData.getLabels());
        assertEquals(observedTarget.getLabels(),
            new HashSet<String>(Arrays.asList(targetData.getLabels())));
        assertNotNull(targetData.getPixelData());
        assertEquals(0, targetData.getPixelData()
            .size());
        assertNotNull(targetData.getPixels());
        assertEquals(pixelCountInOptimalAperture(targetData.getPixels()),
            targetData.getPixels()
                .size());
        assertEquals(quarter, targetData.getQuarter());
        assertEquals(targetTableLog.getCadenceStart(),
            targetData.getStartCadence());
        assertEquals(targetTableLog.getTargetTable()
            .getId(), targetData.getTargetTableId());
    }

    static int pixelCountInOptimalAperture(Set<Pixel> pixels) {
        int count = 0;

        for (Pixel pixel : pixels) {
            if (pixel.isInOptimalAperture()) {
                count++;
            }
        }

        return count;
    }

    private void validate(TpsDbResult tpsDbResult,
        List<DvThresholdCrossingEvent> thresholdCrossingEvent) {

        assertNotNull(thresholdCrossingEvent);
        assertNotNull(tpsDbResult);

        DvThresholdCrossingEvent tce = thresholdCrossingEvent.get(0);

        assertEquals(tpsDbResult.getDetectedOrbitalPeriodInDays(),
            tce.getOrbitalPeriod());
        assertEquals(tpsDbResult.getMaxMultipleEventStatistic(),
            tce.getMaxMultipleEventSigma());
        assertEquals(tpsDbResult.getMaxSingleEventStatistic(),
            tce.getMaxSingleEventSigma());
        assertEquals(tpsDbResult.timeOfFirstTransitInMjd(), tce.getEpochMjd());
        assertEquals(tpsDbResult.getThresholdForDesiredPfa(),
            tce.getThresholdForDesiredPfa());
        assertEquals(tpsDbResult.getTrialTransitPulseInHours(),
            tce.getTrialTransitPulseDuration());
        assertEquals(new WeakSecondary(tpsDbResult.getWeakSecondary()),
            tce.getWeakSecondary());
    }

    void validateAllTargetTableData(UnitTestDescriptor unitTestDescriptor,
        List<DvTargetTableData> allTargetTableData) {

        assertNotNull(allTargetTableData);
        assertEquals(unitTestDescriptor.getTargetTableCount(),
            allTargetTableData.size());

        for (int i = 0; i < allTargetTableData.size(); i++) {
            DvTargetTableData dvTargetTableData = allTargetTableData.get(i);
            assertNotNull(dvTargetTableData.getBackgroundBlobs());
            assertNotNull(dvTargetTableData.getCbvBlobs());
            assertEquals(
                ancillaryPipelineDataByTargetTableLog.get(targetTableLogs.get(i)),
                dvTargetTableData.getAncillaryPipelineData());
            assertEquals(backgroundBlobFileSeriesList.get(i),
                dvTargetTableData.getBackgroundBlobs());
            assertEquals(cbvBlobFileSeriesList.get(i),
                dvTargetTableData.getCbvBlobs());
            assertEquals(DvMockUtils.CCD_MOD_OUTS[targetTableLogs.get(i)
                .getTargetTable()
                .getObservingSeason()][0], dvTargetTableData.getCcdModule());
            assertEquals(DvMockUtils.CCD_MOD_OUTS[targetTableLogs.get(i)
                .getTargetTable()
                .getObservingSeason()][1], dvTargetTableData.getCcdOutput());
            int cadencesPerTable = (unitTestDescriptor.getEndCadence()
                - unitTestDescriptor.getStartCadence() + 1)
                / unitTestDescriptor.getTargetTableCount();
            assertEquals(unitTestDescriptor.getStartCadence() + (i + 1)
                * cadencesPerTable - 1, dvTargetTableData.getEndCadence());
            assertNotNull(dvTargetTableData.getMotionBlobs());
            assertEquals(motionBlobFileSeriesList.get(i),
                dvTargetTableData.getMotionBlobs());
            assertEquals(i + 1, dvTargetTableData.getQuarter());
            assertEquals(unitTestDescriptor.getStartCadence() + i
                * cadencesPerTable, dvTargetTableData.getStartCadence());
            assertEquals(i, dvTargetTableData.getTargetTableId());
        }
    }

    TargetTableOperations createTargetTableOperations(
        UnitTestDescriptor unitTestDescriptor) {

        TargetTableOperations targetTableOperations = new TargetTableOperations(
            mjdToCadence, FluxType.SAP, unitTestDescriptor.getSkyGroupId(),
            unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(),
            unitTestDescriptor.getStartKeplerId(),
            unitTestDescriptor.getEndKeplerId(),
            unitTestDescriptor.getBoundedBoxWidth(),
            unitTestDescriptor.getPlanetaryCandidatesFilterParameters(),
            unitTestDescriptor.getAncillaryPipelineMnemonics(),
            unitTestDescriptor.isExternalTcesEnabled());
        targetTableOperations.setAncillaryOperations(ancillaryOperations);
        targetTableOperations.setBlobOperations(blobOperations);
        targetTableOperations.setKicCrud(kicCrud);
        targetTableOperations.setTpsCrud(tpsCrud);
        targetTableOperations.setCelestialObjectOperations(celestialObjectOperations);
        targetTableOperations.setRollTimeOperations(rollTimeOperations);
        targetTableOperations.setTargetCrud(targetCrud);
        targetTableOperations.setTargetSelectionCrud(targetSelectionCrud);
        targetTableOperations.setTpsOperations(tpsOperations);
        targetTableOperations.setExternalTceModelOperations(externalTceModelOperations);

        return targetTableOperations;
    }

    /**
     * This function may get called more than once in the same test.
     * @param unitTestDescriptor non-null
     */
    void populateObjects(UnitTestDescriptor unitTestDescriptor) {
        if (!unitTestDescriptor.isExternalTcesEnabled()) {
            PipelineTask tpsPipelineTask = createPipelineTask(TPS_TASK_ID, TPS_INSTANCE_ID);
            tpsDbResults = DvMockUtils.mockTpsResult(dvJMockTest,
                tpsOperations, FluxType.SAP,
                unitTestDescriptor.getStartCadence(),
                unitTestDescriptor.getEndCadence(),
                tpsPipelineTask,
                unitTestDescriptor.getSkyGroupId(),
                unitTestDescriptor.getStartKeplerId(),
                unitTestDescriptor.getEndKeplerId(),
                unitTestDescriptor.getTargetsPerTable(),
                unitTestDescriptor.getPlanetaryCandidatesFilterParameters());
            keplerIds.clear();
            List<FsId> fsIdList = new ArrayList<FsId>(tpsDbResults.size());
            for (TpsDbResult tpsDbResult : tpsDbResults) {
                fsIdList.add(TpsFsIdFactory.getDeemphasizedNormalizationTimeSeriesId(
                    TPS_INSTANCE_ID,
                    tpsDbResult.getKeplerId(),
                    tpsDbResult.getTrialTransitPulseInHours()));
                keplerIds.add(tpsDbResult.getKeplerId());
            }
            if (tpsDbResults.size() > 0) {
                producerTaskIds.add(TPS_TASK_ID);
                MockUtils.mockReadFloatTimeSeries(dvJMockTest, getFsClient(),
                    unitTestDescriptor.getStartCadence(),
                    unitTestDescriptor.getEndCadence(), TPS_TASK_ID,
                    fsIdList.toArray(new FsId[fsIdList.size()]), false);
            }
            dvJMockTest.allowing(tpsCrud).retrieveLatestTpsRun(TpsType.TPS_FULL);
            dvJMockTest.will(returnValue(tpsPipelineTask.getPipelineInstance()));
        } else {
            externalTceModel = DvMockUtils.mockExternalTceModel(dvJMockTest,
                externalTceModelOperations,
                unitTestDescriptor.getStartCadence(),
                unitTestDescriptor.getEndCadence(),
                unitTestDescriptor.getSkyGroupId(),
                unitTestDescriptor.getStartKeplerId(),
                unitTestDescriptor.getEndKeplerId(),
                unitTestDescriptor.getTargetsPerTable(),
                unitTestDescriptor.getPlanetaryCandidatesFilterParameters());
            keplerIds.clear();
            for (ExternalTce tce : externalTceModel.getExternalTces()) {
                if (!keplerIds.contains(tce.getKeplerId())) {
                    keplerIds.add(tce.getKeplerId());
                }
            }
            DvMockUtils.mockSkyGroupIdsForKeplerIds(dvJMockTest,
                celestialObjectOperations, keplerIds,
                unitTestDescriptor.getSkyGroupId());
        }
        celestialObjectParametersListByKeplerId = DvMockUtils.mockCelestialObjectParameterLists(
            dvJMockTest, celestialObjectOperations, keplerIds,
            unitTestDescriptor.getSkyGroupId(),
            unitTestDescriptor.getBoundedBoxWidth());
        targetTableLogs = DvMockUtils.mockTargetTables(dvJMockTest, targetCrud,
            TargetType.LONG_CADENCE, unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(),
            unitTestDescriptor.getTargetTableCount());
        cadenceTimes = MockUtils.mockCadenceTimes(dvJMockTest, mjdToCadence,
            CadenceType.LONG, unitTestDescriptor.getStartCadence(),
            unitTestDescriptor.getEndCadence(), true, false);
        quarters = new ArrayList<Integer>(targetTableLogs.size());
        for (int i = 0; i < targetTableLogs.size(); i++) {
            quarters.add(i + 1);
        }
        skyGroups = DvMockUtils.mockSkyGroups(dvJMockTest, kicCrud,
            unitTestDescriptor.getSkyGroupId());
        observedTargetsList = DvMockUtils.mockTargets(dvJMockTest, targetCrud,
            targetTableLogs, keplerIds, allTargetFsIds);

        ancillaryPipelineDataByTargetTableLog = DvMockUtils.mockAncillaryPipelineData(
            dvJMockTest, mjdToCadence, rollTimeOperations, ancillaryOperations,
            unitTestDescriptor.getAncillaryPipelineMnemonics(),
            targetTableLogs, quarters, ANCILLARY_TASK_ID);
        if (unitTestDescriptor.getAncillaryPipelineMnemonics().length > 0) {
            producerTaskIds.add(ANCILLARY_TASK_ID);
        }
        DvMockUtils.mockArgabrighteningIndices(dvJMockTest, fsClient,
            targetTableLogs, ARGABRIGHTENING_TASK_ID);
        producerTaskIds.add(ARGABRIGHTENING_TASK_ID);
        backgroundBlobFileSeriesList = DvMockUtils.mockBackgroundBlobFileSeries(
            dvJMockTest, blobOperations, targetTableLogs,
            BACKGROUND_BLOB_TASK_ID);
        if (backgroundBlobFileSeriesList.size() > 0) {
            producerTaskIds.add(BACKGROUND_BLOB_TASK_ID);
        }
        motionBlobFileSeriesList = DvMockUtils.mockMotionBlobFileSeries(
            dvJMockTest, blobOperations, targetTableLogs, MOTION_BLOB_TASK_ID);
        if (motionBlobFileSeriesList.size() > 0) {
            producerTaskIds.add(MOTION_BLOB_TASK_ID);
        }
        cbvBlobFileSeriesList = DvMockUtils.mockCbvBlobFileSeries(dvJMockTest,
            blobOperations, targetTableLogs, CBV_BLOB_TASK_ID);
        if (cbvBlobFileSeriesList.size() > 0) {
            producerTaskIds.add(CBV_BLOB_TASK_ID);
        }

        DvMockUtils.mockUkirtImages(dvJMockTest, blobOperations,
            AbstractDvPipelineModuleTest.MATLAB_WORKING_DIR, keplerIds);

        DvMockUtils.mockPlannedTargets(dvJMockTest, targetSelectionCrud,
            new HashSet<Integer>(keplerIds));
    }

    private static PipelineTask createPipelineTask(long taskId, long pipelineInstanceId) {
        PipelineTask pipelineTask = new PipelineTask();
        pipelineTask.setId(taskId);
        
        PipelineInstance pipelineInstance = new PipelineInstance();
        pipelineTask.setPipelineInstance(pipelineInstance);
        
        pipelineInstance.setId(pipelineInstanceId);

        return pipelineTask;
    }

    @SuppressWarnings("unchecked")
    void createMockObjects() {
        ancillaryOperations = dvJMockTest.mock(AncillaryOperations.class);
        blobOperations = dvJMockTest.mock(BlobOperations.class);
        dataAnomalyOperations = dvJMockTest.mock(DataAnomalyOperations.class);
        fsClient = dvJMockTest.mock(FileStoreClient.class);
        logCrud = dvJMockTest.mock(LogCrud.class);
        kicCrud = dvJMockTest.mock(KicCrud.class);
        celestialObjectOperations = dvJMockTest.mock(CelestialObjectOperations.class);
        rollTimeOperations = dvJMockTest.mock(RollTimeOperations.class);
        targetCrud = dvJMockTest.mock(TargetCrud.class);
        targetSelectionCrud = dvJMockTest.mock(TargetSelectionCrud.class);
        tpsCrud = dvJMockTest.mock(TpsCrud.class);
        tpsOperations = dvJMockTest.mock(TpsOperations.class);
        externalTceModelOperations = dvJMockTest.mock(ModelOperations.class);
        mjdToCadence = dvJMockTest.mock(MjdToCadence.class);

        FileStoreClientFactory.setInstance(fsClient);
    }

    List<TargetTableLog> getTargetTableLogs() {
        return targetTableLogs;
    }

    List<SkyGroup> getSkyGroups() {
        return skyGroups;
    }

    List<Integer> getQuarters() {
        return quarters;
    }

    List<List<ObservedTarget>> getObservedTargetsList() {
        return observedTargetsList;
    }

    List<DvTarget> getAllTargets(UnitTestDescriptor unitTestDescriptor) {
        TargetTableOperations targetTableOperations = createTargetTableOperations(unitTestDescriptor);
        List<DvTarget> allTargets = targetTableOperations.getAllTargets();

        return allTargets;
    }

    MjdToCadence getMjdToCadence() {
        return mjdToCadence;
    }

    TimestampSeries getCadenceTimes() {
        return cadenceTimes;
    }

    double getStartMjd() {
        return cadenceTimes.startMjd();
    }

    double getEndMjd() {
        return cadenceTimes.endMjd();
    }

    Set<FsId> getAllTargetFsIds() {
        return allTargetFsIds;
    }

    AncillaryOperations getAncillaryOperations() {
        return ancillaryOperations;
    }

    BlobOperations getBlobOperations() {
        return blobOperations;
    }

    LogCrud getLogCrud() {
        return logCrud;
    }

    DataAnomalyOperations getDataAnomalyOperations() {
        return dataAnomalyOperations;
    }

    KicCrud getKicCrud() {
        return kicCrud;
    }

    FileStoreClient getFsClient() {
        return fsClient;
    }

    CelestialObjectOperations getCelestialObjectOperations() {
        return celestialObjectOperations;
    }

    RollTimeOperations getRollTimeOperations() {
        return rollTimeOperations;
    }

    TargetCrud getTargetCrud() {
        return targetCrud;
    }

    TargetSelectionCrud getTargetSelectionCrud() {
        return targetSelectionCrud;
    }

    TpsOperations getTpsOperations() {
        return tpsOperations;
    }
    
    TpsCrud getTpsCrud() {
        return tpsCrud;
    }

    ModelOperations<ExternalTceModel> getExternalTceModelOperations() {
        return externalTceModelOperations;
    }

    Set<Long> latestProducerTaskIds() {
        return producerTaskIds;
    }

    File getMatlabWorkingDir() {
        return matlabWorkingDir;
    }

    void setMatlabWorkingDir(File matlabWorkingDir) {
        this.matlabWorkingDir = matlabWorkingDir;
        dvJMockTest.oneOf(blobOperations)
            .setOutputDir(matlabWorkingDir);
    }

    void setDvJMockTest(DvJMockTest dvJMockTest) {
        this.dvJMockTest = dvJMockTest;
    }
}
