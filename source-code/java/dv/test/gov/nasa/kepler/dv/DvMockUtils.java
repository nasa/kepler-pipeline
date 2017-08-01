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

import static com.google.common.collect.Maps.newHashMap;
import static gov.nasa.spiffy.common.jmock.JMockTest.returnValue;
import gov.nasa.kepler.common.AncillaryPipelineData;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobFileSeries;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.common.pi.FluxTypeParameters.FluxType;
import gov.nasa.kepler.dv.io.DvTarget;
import gov.nasa.kepler.fc.prf.PrfModel;
import gov.nasa.kepler.fc.prf.PrfOperations;
import gov.nasa.kepler.fc.rolltime.RollTimeOperations;
import gov.nasa.kepler.fs.api.DoubleTimeSeries;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.FsIdSet;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.MjdFsIdSet;
import gov.nasa.kepler.fs.api.MjdTimeSeriesBatch;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.api.TimeSeriesBatch;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dv.DvCrud;
import gov.nasa.kepler.hibernate.dv.DvExternalTceModelDescription;
import gov.nasa.kepler.hibernate.dv.DvTransitModelDescriptions;
import gov.nasa.kepler.hibernate.mc.ExternalTce;
import gov.nasa.kepler.hibernate.mc.ExternalTceModel;
import gov.nasa.kepler.hibernate.mc.TransitName;
import gov.nasa.kepler.hibernate.mc.TransitNameModel;
import gov.nasa.kepler.hibernate.mc.TransitParameter;
import gov.nasa.kepler.hibernate.mc.TransitParameterModel;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.hibernate.tps.TpsDbResult;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterImpl;
import gov.nasa.kepler.mc.PlanetaryCandidatesFilterParameters;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.ancillary.AncillaryOperations;
import gov.nasa.kepler.mc.blob.BlobData;
import gov.nasa.kepler.mc.blob.BlobOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.cm.CelestialObjectParameters;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.kepler.mc.fs.PaFsIdFactory;
import gov.nasa.kepler.mc.tps.TpsOperations;
import gov.nasa.kepler.mc.tps.WeakSecondary;
import gov.nasa.kepler.pi.models.ModelOperations;
import gov.nasa.kepler.pi.module.InputsHandler;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Random;
import java.util.Set;
import java.util.TimeZone;

import org.jmock.Expectations;

public class DvMockUtils {

    private static final int SEASON_COUNT = 4;

    static final int[][] CCD_MOD_OUTS = { { 24, 4 }, { 10, 4 }, { 2, 4 },
        { 16, 4 } };

    private static final int MAX_PIXELS_PER_TARGET = 4;

    private static final String UKIRT_PNG_FILENAME = "kplr%s-%09d_ukirt.png";

    private static final String EXTERNAL_TCE_MODEL_DESCRIPTION = "Test external TCE model description";

    private static final String TRANSIT_NAME_MODEL_DESCRIPTION = "Test transit name model description";
    private static final String TRANSIT_PARAMETER_MODEL_DESCRIPTION = "Test transit parameter model description";

    public static final String DATE_FORMAT = "yyyyDDDHHmmss";

    public static List<TimeSeriesBatch> mockReadTimeSeriesBatch(
        JMockTest jMockTest, FileStoreClient fsClient,
        boolean prfCentroidsEnabled, long producerTaskId,
        List<FsIdSet> fsIdSetList) {

        List<TimeSeriesBatch> timeSeriesBatchList = createTimeSeriesBatchList(
            prfCentroidsEnabled, producerTaskId, fsIdSetList);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesBatch(fsIdSetList, false);
            jMockTest.will(returnValue(timeSeriesBatchList));
        }

        return timeSeriesBatchList;
    }

    private static List<TimeSeriesBatch> createTimeSeriesBatchList(
        boolean prfCentroidsEnabled, long producerTaskId, List<FsIdSet> fsIdSets) {

        List<TimeSeriesBatch> timeSeriesBatchList = new ArrayList<TimeSeriesBatch>();

        for (FsIdSet fsIdSet : fsIdSets) {
            Map<FsId, TimeSeries> timeSeriesByFsId = new HashMap<FsId, TimeSeries>();

            for (FsId fsId : fsIdSet.ids()) {
                if (fsId.toString()
                    .contains("FilledIndices/") || fsId.toString()
                    .contains("/DiscontinuityIndices/")) {
                    IntTimeSeries[] intTimeSeriesArray = MockUtils.createIntTimeSeries(
                        fsIdSet.startCadence(), fsIdSet.endCadence(),
                        producerTaskId, new FsId[] { fsId });
                    intTimeSeriesArray[0].iseries()[0] = 1;
                    timeSeriesByFsId.put(fsId, intTimeSeriesArray[0]);
                } else if (!prfCentroidsEnabled && fsId.toString()
                    .contains("/Prf/Centroid")) {
                    timeSeriesByFsId.put(fsId, new IntTimeSeries(fsId,
                        new int[0], TimeSeries.NOT_EXIST_CADENCE,
                        TimeSeries.NOT_EXIST_CADENCE, new int[0], 0L, false));
                } else if (fsId.toString()
                    .contains("/Centroid") && !fsId.toString()
                    .contains("Uncertainties/")) {
                    DoubleTimeSeries[] doubleTimeSeriesArray = MockUtils.createDoubleTimeSeries(
                        fsIdSet.startCadence(), fsIdSet.endCadence(),
                        producerTaskId, new FsId[] { fsId });
                    timeSeriesByFsId.put(fsId, doubleTimeSeriesArray[0]);
                } else {
                    FloatTimeSeries[] floatTimeSeriesArray = MockUtils.createFloatTimeSeries(
                        fsIdSet.startCadence(), fsIdSet.endCadence(),
                        producerTaskId, new FsId[] { fsId });
                    timeSeriesByFsId.put(fsId, floatTimeSeriesArray[0]);
                }
            }
            timeSeriesBatchList.add(new TimeSeriesBatch(fsIdSet.startCadence(),
                fsIdSet.endCadence(), timeSeriesByFsId));
        }

        return timeSeriesBatchList;
    }

    public static List<MjdTimeSeriesBatch> mockMjdTimeSeriesBatchList(
        JMockTest jMockTest, FileStoreClient fsClient, double startMjd,
        double endMjd, long producerTaskId, List<MjdFsIdSet> mjdFsIdSetList,
        double[] outlierMjds) {

        List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList = DvMockUtils.mockReadMjdTimeSeriesBatch(
            jMockTest, fsClient, producerTaskId, mjdFsIdSetList, outlierMjds);

        return mjdTimeSeriesBatchList;
    }

    public static List<MjdTimeSeriesBatch> mockReadMjdTimeSeriesBatch(
        JMockTest jMockTest, FileStoreClient fsClient, long producerTaskId,
        List<MjdFsIdSet> fsIdSetList, double[] outlierMjds) {

        List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList = createMjdTimeSeriesBatchList(
            producerTaskId, fsIdSetList, outlierMjds);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readMjdTimeSeriesBatch(fsIdSetList);
            jMockTest.will(returnValue(mjdTimeSeriesBatchList));
        }
        return mjdTimeSeriesBatchList;
    }

    private static List<MjdTimeSeriesBatch> createMjdTimeSeriesBatchList(
        long producerTaskId, List<MjdFsIdSet> fsIdSetList, double[] outlierMjds) {

        List<MjdTimeSeriesBatch> mjdTimeSeriesBatchList = new ArrayList<MjdTimeSeriesBatch>();
        for (int i = 0; i < fsIdSetList.size(); i++) {
            MjdFsIdSet mjdFsIdSet = fsIdSetList.get(i);
            FloatMjdTimeSeries[] floatMjdTimeSeries = MockUtils.createFloatMjdTimeSeries(
                mjdFsIdSet.startMjd(), mjdFsIdSet.endMjd(), producerTaskId,
                mjdFsIdSet.ids()
                    .toArray(new FsId[0]), outlierMjds);
            Map<FsId, FloatMjdTimeSeries> mjdTimeSeriesByFsId = TimeSeriesOperations.getFloatMjdTimeSeriesByFsId(floatMjdTimeSeries);
            mjdTimeSeriesBatchList.add(new MjdTimeSeriesBatch(
                mjdFsIdSet.startMjd(), mjdFsIdSet.endMjd(), mjdTimeSeriesByFsId));
        }

        return mjdTimeSeriesBatchList;
    }

    public static List<TpsDbResult> mockTpsResult(JMockTest jMockTest,
        TpsOperations tpsOperations, FluxType fluxType, int startCadence,
        int endCadence, PipelineTask originator, int skyGroupId,
        int startKeplerId, int endKeplerId, int candidateCount,
        PlanetaryCandidatesFilterParameters filterParameters) {

        // If the semantics of the mocked method changes so that it returns a
        // sorted list, change the hash set to a tree set.
        Set<Integer> keplerIds = new HashSet<Integer>(candidateCount);
        int kicCount = candidateCount;
        Random random = new Random(kicCount);
        while (keplerIds.size() < kicCount) {
            keplerIds.add(random.nextInt(endKeplerId - startKeplerId + 1)
                + startKeplerId);
        }

        List<TpsDbResult> tpsDbResults = new ArrayList<TpsDbResult>(
            keplerIds.size());
        for (int keplerId : keplerIds) {
            random = new Random(keplerId);
            TpsDbResult tpsDbResult = new TpsDbResult(
                keplerId,
                random.nextFloat(),
                random.nextFloat(),
                random.nextFloat(),
                startCadence,
                endCadence,
                fluxType,
                originator,
                random.nextDouble(),
                true,
                random.nextFloat(),
                random.nextFloat(),
                random.nextDouble(),
                random.nextFloat(),
                random.nextFloat(),
                random.nextFloat(),
                random.nextDouble(),
                random.nextFloat(),
                random.nextBoolean(),
                random.nextFloat(),
                new WeakSecondary(new float[] { random.nextFloat() },
                    new float[] { random.nextFloat() }, random.nextFloat(),
                    random.nextFloat(), random.nextFloat(), random.nextFloat(),
                    random.nextFloat(), random.nextFloat(), random.nextFloat(),
                    random.nextFloat(), random.nextInt(), random.nextFloat()).toDb(),
                random.nextFloat(), random.nextFloat(), random.nextInt(),
                random.nextFloat() /* chiSquareDof2 */, random.nextFloat(), random.nextFloat(),
                random.nextInt(), random.nextFloat());
            tpsDbResults.add(tpsDbResult);
        }

        if (jMockTest != null && tpsOperations != null) {
            jMockTest.allowing(tpsOperations)
                .retrieveLatestTpsResultsWithFileStoreData(skyGroupId,
                    startKeplerId, endKeplerId,
                    new PlanetaryCandidatesFilterImpl(filterParameters));
            jMockTest.will(returnValue(tpsDbResults));
        }

        return tpsDbResults;
    }

    public static Map<Integer, List<CelestialObjectParameters>> mockCelestialObjectParameterLists(
        JMockTest jMockTest,
        CelestialObjectOperations celestialObjectOperations,
        List<Integer> keplerIds, int skyGroupId, float boundedBoxWidth) {

        Map<Integer, List<CelestialObjectParameters>> celestialObjectParametersListByKeplerId = new HashMap<Integer, List<CelestialObjectParameters>>(
            keplerIds.size());
        for (int keplerId : keplerIds) {
            List<CelestialObjectParameters> celestialObjectParametersList = new ArrayList<CelestialObjectParameters>();
            CelestialObject celestialObject = MockUtils.createCelestialObject(
                keplerId, skyGroupId);
            List<CelestialObjectParameters> celestialObjectParameters = Arrays.asList(new CelestialObjectParameters.Builder(
                celestialObject).build());
            celestialObjectParametersList.addAll(celestialObjectParameters);
            celestialObjectParametersListByKeplerId.put(keplerId,
                celestialObjectParameters);
        }

        if (jMockTest != null && celestialObjectOperations != null) {
            jMockTest.allowing(celestialObjectOperations)
                .retrieveCelestialObjectParameters(keplerIds, boundedBoxWidth);
            jMockTest.will(returnValue(celestialObjectParametersListByKeplerId));
        }

        return celestialObjectParametersListByKeplerId;
    }

    public static List<TargetTableLog> mockTargetTables(JMockTest jMockTest,
        TargetCrud targetCrud, TargetType targetType, int startCadence,
        int endCadence, int targetTableCount) {

        if ((endCadence - startCadence + 1) % targetTableCount != 0) {
            throw new IllegalArgumentException(
                String.format(
                    "Cadence count (%d) must be a multiple of targetTableCount (%d)",
                    endCadence - startCadence + 1, targetTableCount));
        }

        List<TargetTableLog> targetTableLogs = new ArrayList<TargetTableLog>(
            targetTableCount);
        for (int i = 0; i < targetTableCount; i++) {
            TargetTable targetTable = new TargetTable(targetType);
            targetTable.setExternalId(i);
            targetTable.setObservingSeason((i + 2) % 4);
            int cadencesPerTable = (endCadence - startCadence + 1)
                / targetTableCount;
            TargetTableLog targetTableLog = new TargetTableLog(targetTable,
                startCadence + i * cadencesPerTable, startCadence + (i + 1)
                    * cadencesPerTable - 1);
            targetTableLogs.add(targetTableLog);
        }

        if (jMockTest != null && targetCrud != null) {
            jMockTest.allowing(targetCrud)
                .retrieveTargetTableLogs(targetType, startCadence, endCadence);
            jMockTest.will(returnValue(targetTableLogs));
        }

        return targetTableLogs;
    }

    public static List<PixelLog> mockPixelLogForCadence(JMockTest jMockTest,
        MjdToCadence mjdToCadence, TimestampSeries cadenceTimes,
        int targetTableId) {

        List<PixelLog> pixelLogs = new ArrayList<PixelLog>();
        if (jMockTest != null && mjdToCadence != null) {
            for (int i = 0; i < cadenceTimes.startTimestamps.length; i++) {
                PixelLog pixelLog = new PixelLog();
                pixelLog.setDataSetType(DataSetType.Target);
                pixelLog.setCadenceType(CadenceType.LONG.intValue());
                pixelLog.setCadenceNumber(cadenceTimes.cadenceNumbers[i]);
                pixelLog.setMjdStartTime(cadenceTimes.startTimestamps[i]);
                pixelLog.setMjdMidTime(cadenceTimes.midTimestamps[i]);
                pixelLog.setMjdEndTime(cadenceTimes.endTimestamps[i]);
                pixelLog.setLcTargetTableId((short) targetTableId);
                pixelLogs.add(pixelLog);

                jMockTest.allowing(mjdToCadence)
                    .pixelLogForCadence(pixelLog.getCadenceNumber());
                jMockTest.will(returnValue(pixelLog));
            }
        }

        return pixelLogs;
    }

    @Deprecated
    public static List<Integer> mockMjdToQuarter(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, int startCadence,
        TimestampSeries cadenceTimes, List<TargetTableLog> targetTableLogs) {

        List<Integer> quarters = new ArrayList<Integer>(targetTableLogs.size());
        double[] startMjds = cadenceTimes.startTimestamps;

        if (jMockTest != null && rollTimeOperations != null) {
            for (int i = 0; i < targetTableLogs.size(); i++) {
                double[] mjd = new double[1];
                mjd[0] = startMjds[targetTableLogs.get(i)
                    .getCadenceStart() - startCadence];
                int[] quarter = new int[] { i + 1 };
                quarters.add(quarter[0]);
                jMockTest.allowing(rollTimeOperations)
                    .mjdToQuarter(mjd);
                jMockTest.will(returnValue(quarter));
            }
        }

        return quarters;
    }

    public static void mockMjdToQuarter(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, TimestampSeries cadenceTimes,
        int quarter) {

        if (jMockTest != null && rollTimeOperations != null) {
            jMockTest.allowing(rollTimeOperations)
                .mjdToQuarter(new double[] { cadenceTimes.startMjd() });
            jMockTest.will(returnValue(new int[] { quarter }));
        }
    }

    public static int[] mockMjdsToQuarters(JMockTest jMockTest,
        RollTimeOperations rollTimeOperations, TimestampSeries cadenceTimes,
        int quarter) {

        int[] quarters = new int[cadenceTimes.startTimestamps.length];
        Arrays.fill(quarters, quarter);

        if (jMockTest != null && rollTimeOperations != null) {
            jMockTest.allowing(rollTimeOperations)
                .mjdToQuarter(cadenceTimes.startTimestamps);
            jMockTest.will(returnValue(quarters));
        }

        return quarters;
    }

    public static void mockMjdToCadenceMjdToCadence(JMockTest jMockTest,
        MjdToCadence mjdToCadence, TimestampSeries cadenceTimes) {

        if (jMockTest != null && mjdToCadence != null) {
            jMockTest.allowing(mjdToCadence)
                .mjdToCadence(cadenceTimes.midTimestamps[0]);
            jMockTest.will(returnValue(cadenceTimes.cadenceNumbers[0]));
            jMockTest.allowing(mjdToCadence)
                .cadenceToMjd(cadenceTimes.cadenceNumbers[0]);
            jMockTest.will(returnValue(cadenceTimes.midTimestamps[0]));
        }
    }

    public static List<SkyGroup> mockSkyGroups(JMockTest jMockTest,
        KicCrud kicCrud, int skyGroupId) {

        List<SkyGroup> skyGroups = new ArrayList<SkyGroup>(4);
        for (int observingSeason = 0; observingSeason < SEASON_COUNT; observingSeason++) {
            SkyGroup skyGroup = new SkyGroup(skyGroupId,
                CCD_MOD_OUTS[observingSeason][0],
                CCD_MOD_OUTS[observingSeason][1], observingSeason);
            skyGroups.add(skyGroup);
            if (jMockTest != null && kicCrud != null) {
                jMockTest.allowing(kicCrud)
                    .retrieveSkyGroup(skyGroupId, observingSeason);
                jMockTest.will(returnValue(skyGroup));
            }
        }

        return skyGroups;
    }

    public static String[] mockPrfModels(JMockTest jMockTest, KicCrud kicCrud,
        PrfOperations prfOperations, int skyGroupId, double startMjd) {

        List<SkyGroup> skyGroups = mockSkyGroups(jMockTest, kicCrud, skyGroupId);
        String[] prfModelFileNames = new String[skyGroups.size()];
        for (int i = 0; i < skyGroups.size(); i++) {
            SkyGroup skyGroup = skyGroups.get(i);
            PrfModel prfModel = MockUtils.mockPrfModel(jMockTest,
                prfOperations, startMjd, skyGroup.getCcdModule(),
                skyGroup.getCcdOutput());
            prfModelFileNames[i] = String.format(
                DvInputsRetriever.PRF_MODEL_SDF_FILENAME,
                prfModel.getCcdModule(), prfModel.getCcdOutput());
        }

        return prfModelFileNames;
    }

    public static Map<Integer, String> mockUkirtImages(JMockTest jMockTest,
        BlobOperations blobOperations, File matlabWorkingDir,
        List<Integer> keplerIds) {

        Map<Integer, String> ukirtImageFileNameByKeplerId = new HashMap<Integer, String>();

        DateFormat dateFormatter = new SimpleDateFormat(DATE_FORMAT);
        dateFormatter.setTimeZone(TimeZone.getTimeZone("UTC"));
        String formattedDate = dateFormatter.format(new Date());

        for (int keplerId : keplerIds) {
            String ukirtImageFileName = String.format(UKIRT_PNG_FILENAME,
                formattedDate, keplerId);
            createImageFile(matlabWorkingDir, ukirtImageFileName);
            BlobData<String> blobData = new BlobData<String>(
                ukirtImageFileName, keplerId);
            ukirtImageFileNameByKeplerId.put(keplerId, ukirtImageFileName);
            if (jMockTest != null && blobOperations != null) {
                jMockTest.allowing(blobOperations)
                    .retrieveUkirtImageBlobFile(keplerId);
                jMockTest.will(returnValue(blobData));
            }
        }
        return ukirtImageFileNameByKeplerId;
    }

    private static void createImageFile(File matlabWorkingDir,
        String ukirtImageFileName) {

        File imageFile = new File(matlabWorkingDir, ukirtImageFileName);
        FileWriter writer = null;
        try {
            writer = new FileWriter(imageFile);
            writer.write(ukirtImageFileName);
        } catch (IOException ioe) {
            // Hmm
        } finally {
            FileUtil.close(writer);
        }
    }

    public static List<List<ObservedTarget>> mockTargets(JMockTest jMockTest,
        TargetCrud targetCrud, List<TargetTableLog> targetTableLogs,
        List<Integer> keplerIds, Set<FsId> allTargetFsIds) {

        List<List<ObservedTarget>> observedTargetLists = new ArrayList<List<ObservedTarget>>();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            TargetTable targetTable = targetTableLog.getTargetTable();
            List<ObservedTarget> observedTargets = MockUtils.mockTargets(
                jMockTest, targetCrud, targetTable, keplerIds,
                new ArrayList<Set<String>>(), MAX_PIXELS_PER_TARGET,
                CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                CCD_MOD_OUTS[targetTable.getObservingSeason()][1],
                new HashSet<Pixel>(), allTargetFsIds);
            mockTargets(jMockTest, targetCrud, targetTable, keplerIds,
                observedTargets);
            observedTargetLists.add(observedTargets);
        }
        return observedTargetLists;
    }

    private static void mockTargets(JMockTest jMockTest, TargetCrud targetCrud,
        TargetTable targetTable, List<Integer> keplerIds,
        List<ObservedTarget> observedTargets) {

        if (targetCrud != null) {
            List<Integer> sortedKeplerIds = new ArrayList<Integer>(keplerIds);
            Collections.sort(sortedKeplerIds);
            jMockTest.allowing(targetCrud)
                .retrieveObservedTargets(targetTable, sortedKeplerIds);
            jMockTest.will(returnValue(observedTargets));
        }
    }

    public static Map<TargetTableLog, List<AncillaryPipelineData>> mockAncillaryPipelineData(
        JMockTest jMockTest, MjdToCadence mjdToCadence,
        RollTimeOperations rollTimeOperations,
        AncillaryOperations ancillaryOperations,
        String[] ancillaryPipelineMnemonics,
        List<TargetTableLog> targetTableLogs, List<Integer> quarters,
        long producerTaskId) {

        Map<TargetTableLog, List<AncillaryPipelineData>> ancillaryPipelineDataListByTargetTableLog = new HashMap<TargetTableLog, List<AncillaryPipelineData>>();

        for (int i = 0; i < targetTableLogs.size(); i++) {

            TargetTableLog targetTableLog = targetTableLogs.get(i);
            TimestampSeries cadenceTimes = MockUtils.mockCadenceTimes(
                jMockTest, mjdToCadence, CadenceType.LONG,
                targetTableLog.getCadenceStart(),
                targetTableLog.getCadenceEnd(), true, false);

            mockMjdToQuarter(jMockTest, rollTimeOperations, cadenceTimes,
                quarters.get(i));

            TargetTable targetTable = targetTableLog.getTargetTable();

            Map<String, Pair<FsId, FsId>> mnemonicToFsIds = AncillaryOperations.getAncillaryMnemonicToTimeSeriesFsIds(
                ancillaryPipelineMnemonics, targetTable,
                CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                CCD_MOD_OUTS[targetTable.getObservingSeason()][1]);

            FloatTimeSeries[] floatTimeSeries = MockUtils.mockAncillaryPipelineData(
                jMockTest, null, ancillaryPipelineMnemonics, targetTable,
                CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                CCD_MOD_OUTS[targetTable.getObservingSeason()][1],
                targetTableLog.getCadenceStart(),
                targetTableLog.getCadenceEnd(), producerTaskId);

            List<AncillaryPipelineData> ancillaryPipelineDataList = createAncillaryPipelineDataList(
                ancillaryPipelineMnemonics, cadenceTimes, mnemonicToFsIds,
                TimeSeriesOperations.getFloatTimeSeriesByFsId(floatTimeSeries));

            ancillaryPipelineDataListByTargetTableLog.put(targetTableLog,
                ancillaryPipelineDataList);

            if (jMockTest != null && ancillaryOperations != null) {
                jMockTest.allowing(ancillaryOperations)
                    .retrieveAncillaryPipelineData(ancillaryPipelineMnemonics,
                        targetTable,
                        CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                        CCD_MOD_OUTS[targetTable.getObservingSeason()][1],
                        cadenceTimes);
                jMockTest.will(returnValue(ancillaryPipelineDataList));

                Set<Long> producerTaskIds = new HashSet<Long>();
                if (ancillaryPipelineMnemonics.length > 0) {
                    producerTaskIds.add(producerTaskId);
                }
                jMockTest.allowing(ancillaryOperations)
                    .producerTaskIds();
                jMockTest.will(returnValue(producerTaskIds));
            }
        }

        return ancillaryPipelineDataListByTargetTableLog;
    }

    private static List<AncillaryPipelineData> createAncillaryPipelineDataList(
        String[] ancillaryPipelineMnemonics, TimestampSeries cadenceTimes,
        Map<String, Pair<FsId, FsId>> mnemonicToFsIds,
        Map<FsId, FloatTimeSeries> timeSeriesByFsId) {

        List<AncillaryPipelineData> ancillaryPipelineDataList = new ArrayList<AncillaryPipelineData>();

        for (String mnemonic : ancillaryPipelineMnemonics) {
            Pair<FsId, FsId> fsIds = mnemonicToFsIds.get(mnemonic);
            AncillaryPipelineData ancillaryPipelineData = AncillaryOperations.createAncillaryPipelineData(
                mnemonic, cadenceTimes, timeSeriesByFsId.get(fsIds.left),
                timeSeriesByFsId.get(fsIds.right));
            ancillaryPipelineDataList.add(ancillaryPipelineData);
        }

        return ancillaryPipelineDataList;
    }

    public static List<BlobFileSeries> mockBackgroundBlobFileSeries(
        JMockTest jMockTest, BlobOperations blobOperations,
        List<TargetTableLog> targetTableLogs, long producerTaskId) {

        List<BlobFileSeries> backgroundBlobFileSeriesList = new ArrayList<BlobFileSeries>();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            TargetTable targetTable = targetTableLog.getTargetTable();
            BlobSeries<String> backgroundBlobFileSeries = MockUtils.mockBackgroundBlobFileSeries(
                jMockTest, blobOperations,
                CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                CCD_MOD_OUTS[targetTable.getObservingSeason()][1],
                targetTableLog.getCadenceStart(),
                targetTableLog.getCadenceEnd(), producerTaskId);
            backgroundBlobFileSeriesList.add(new BlobFileSeries(
                backgroundBlobFileSeries));
        }

        return backgroundBlobFileSeriesList;
    }

    public static List<BlobFileSeries> mockCbvBlobFileSeries(
        JMockTest jMockTest, BlobOperations blobOperations,
        List<TargetTableLog> targetTableLogs, long producerTaskId) {

        List<BlobFileSeries> cbvBlobFileSeriesList = new ArrayList<BlobFileSeries>();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            TargetTable targetTable = targetTableLog.getTargetTable();
            BlobSeries<String> cbvBlobFileSeries = MockUtils.mockCbvBlobFileSeries(
                jMockTest, blobOperations,
                CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                CCD_MOD_OUTS[targetTable.getObservingSeason()][1],
                CadenceType.LONG, targetTableLog.getCadenceStart(),
                targetTableLog.getCadenceEnd(), producerTaskId);
            cbvBlobFileSeriesList.add(new BlobFileSeries(cbvBlobFileSeries));
        }

        return cbvBlobFileSeriesList;
    }

    public static List<BlobFileSeries> mockMotionBlobFileSeries(
        JMockTest jMockTest, BlobOperations blobOperations,
        List<TargetTableLog> targetTableLogs, long producerTaskId) {

        List<BlobFileSeries> motionBlobFileSeriesList = new ArrayList<BlobFileSeries>();
        for (TargetTableLog targetTableLog : targetTableLogs) {
            TargetTable targetTable = targetTableLog.getTargetTable();
            BlobSeries<String> motionBlobFileSeries = MockUtils.mockMotionBlobFileSeries(
                jMockTest, blobOperations,
                CCD_MOD_OUTS[targetTable.getObservingSeason()][0],
                CCD_MOD_OUTS[targetTable.getObservingSeason()][1],
                targetTableLog.getCadenceStart(),
                targetTableLog.getCadenceEnd(), producerTaskId);
            motionBlobFileSeriesList.add(new BlobFileSeries(
                motionBlobFileSeries));
        }

        return motionBlobFileSeriesList;
    }

    public static int[] mockArgabrightening(JMockTest jMockTest,
        FileStoreClient fsClient, int targetTableId, CadenceType cadenceType,
        int ccdModule, int ccdOutput, int startCadence, int endCadence,
        long producerTaskId) {

        int length = endCadence - startCadence + 1;
        int[] indices = new int[] { length / 2 };
        boolean[] gapIndicators = new boolean[length];

        Arrays.fill(gapIndicators, true);
        for (int index : indices) {
            gapIndicators[index] = false;
        }

        FsId fsId = PaFsIdFactory.getArgabrighteningFsId(cadenceType,
            targetTableId, ccdModule, ccdOutput);
        IntTimeSeries intTimeSeries = new IntTimeSeries(fsId, new int[length],
            startCadence, endCadence, gapIndicators, producerTaskId);

        if (jMockTest != null && fsClient != null) {
            jMockTest.allowing(fsClient)
                .readTimeSeriesAsInt(new FsId[] { fsId }, startCadence,
                    endCadence, false);
            jMockTest.will(returnValue(new IntTimeSeries[] { intTimeSeries }));
        }

        return indices;
    }

    public static void mockArgabrighteningIndices(JMockTest jMockTest,
        FileStoreClient fsClient, List<TargetTableLog> targetTableLogs,
        long producerTaskId) {

        for (TargetTableLog targetTableLog : targetTableLogs) {
            DvMockUtils.mockArgabrightening(jMockTest, fsClient,
                targetTableLog.getTargetTable()
                    .getExternalId(), CadenceType.LONG,
                DvMockUtils.CCD_MOD_OUTS[targetTableLog.getTargetTable()
                    .getObservingSeason()][0],
                DvMockUtils.CCD_MOD_OUTS[targetTableLog.getTargetTable()
                    .getObservingSeason()][1],
                targetTableLog.getCadenceStart(),
                targetTableLog.getCadenceEnd(), producerTaskId);
        }
    }

    public static Map<Integer, List<PlannedTarget>> mockPlannedTargets(
        JMockTest jMockTest, TargetSelectionCrud targetSelectionCrud,
        Set<Integer> keplerIds) {

        Map<Integer, List<PlannedTarget>> plannedTargetsByKeplerId = newHashMap();
        for (Integer keplerId : keplerIds) {
            TargetList targetList = new TargetList("Test");
            targetList.setCategory("Test category");
            PlannedTarget plannedTarget = new PlannedTarget(targetList);
            plannedTargetsByKeplerId.put(keplerId, Arrays.asList(plannedTarget));
        }

        if (jMockTest != null && targetSelectionCrud != null) {
            jMockTest.allowing(targetSelectionCrud)
                .retrievePlannedTargets(keplerIds);
            jMockTest.will(returnValue(plannedTargetsByKeplerId));
        }

        return plannedTargetsByKeplerId;
    }

    public static ExternalTceModel mockExternalTceModel(JMockTest jMockTest,
        ModelOperations<ExternalTceModel> externalTceModelOperations,
        int startCadence, int endCadence, int skyGroupId, int startKeplerId,
        int endKeplerId, int candidateCount,
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters) {

        ExternalTceModel externalTceModel = createExternalTceModel(
            startCadence, endCadence, skyGroupId, startKeplerId, endKeplerId,
            candidateCount, planetaryCandidatesFilterParameters);
        if (jMockTest != null && externalTceModelOperations != null) {
            jMockTest.allowing(externalTceModelOperations)
                .retrieveModel();
            jMockTest.will(returnValue(externalTceModel));
            jMockTest.allowing(externalTceModelOperations)
                .getModelDescription();
            jMockTest.will(returnValue(EXTERNAL_TCE_MODEL_DESCRIPTION));
        }
        return externalTceModel;
    }

    public static TransitNameModel mockTransitNameModel(JMockTest jMockTest,
        ModelOperations<TransitNameModel> transitNameModelOperations,
        Collection<DvTarget> targets) {

        TransitNameModel transitNameModel = createTransitNameModel(targets);
        if (jMockTest != null && transitNameModelOperations != null) {
            jMockTest.allowing(transitNameModelOperations)
                .retrieveModel();
            jMockTest.will(returnValue(transitNameModel));
            jMockTest.allowing(transitNameModelOperations)
                .getModelDescription();
            jMockTest.will(returnValue(TRANSIT_NAME_MODEL_DESCRIPTION));
        }
        return transitNameModel;
    }

    public static TransitParameterModel mockTransitParameterModel(
        JMockTest jMockTest,
        ModelOperations<TransitParameterModel> transitParameterModelOperations,
        Collection<DvTarget> targets) {

        TransitParameterModel transitParameterModel = createTransitParameterModel(targets);
        if (jMockTest != null && transitParameterModelOperations != null) {
            jMockTest.allowing(transitParameterModelOperations)
                .retrieveModel();
            jMockTest.will(returnValue(transitParameterModel));
            jMockTest.allowing(transitParameterModelOperations)
                .getModelDescription();
            jMockTest.will(returnValue(TRANSIT_PARAMETER_MODEL_DESCRIPTION));
        }
        return transitParameterModel;
    }

    private static ExternalTceModel createExternalTceModel(int startCadence,
        int endCadence, int skyGroupId, int startKeplerId, int endKeplerId,
        int candidateCount,
        PlanetaryCandidatesFilterParameters planetaryCandidatesFilterParameters) {

        Set<Integer> keplerIds = new HashSet<Integer>(candidateCount);
        int kicCount = candidateCount;
        Random random = new Random(kicCount);
        while (keplerIds.size() < kicCount) {
            keplerIds.add(random.nextInt(endKeplerId - startKeplerId + 1)
                + startKeplerId);
        }

        List<ExternalTce> externalTces = new ArrayList<ExternalTce>(
            keplerIds.size());
        for (int keplerId : keplerIds) {
            random = new Random(keplerId);
            float trialTransitPulseInHours = random.nextFloat();
            float maxSingleEventStatistic = random.nextFloat();
            random.nextFloat();
            float detectedOrbitalPeriodInDays = random.nextFloat();
            float maxMultipleEventStatistic = random.nextFloat();
            random.nextFloat();
            double timeOfFirstTransitInMjd = random.nextDouble();
            random.nextFloat();
            random.nextFloat();
            random.nextFloat();
            random.nextDouble();
            random.nextFloat();
            random.nextBoolean();
            random.nextFloat();
            random.nextFloat();
            random.nextFloat();
            random.nextFloat();
            random.nextFloat();
            random.nextFloat();
            random.nextFloat();
            random.nextInt();
            random.nextInt();

            ExternalTce externalTce = new ExternalTce(keplerId, 1,
                trialTransitPulseInHours, timeOfFirstTransitInMjd,
                detectedOrbitalPeriodInDays, maxSingleEventStatistic,
                maxMultipleEventStatistic);
            externalTces.add(externalTce);
        }
        externalTces.add(new ExternalTce(externalTces.get(0)
            .getKeplerId(), 2, random.nextFloat(), random.nextDouble(),
            random.nextFloat(), random.nextFloat(), random.nextFloat()));

        return new ExternalTceModel(0, externalTces);
    }

    private static TransitNameModel createTransitNameModel(
        Collection<DvTarget> targets) {

        List<TransitName> transitNames = new ArrayList<TransitName>(
            targets.size());
        int count = 0;
        for (DvTarget target : targets) {
            TransitName transitName = new TransitName(target.getKeplerId(),
                String.format("K%05d.01", count), "kepler_name", String.format(
                    "Kepler-%d b", count));
            transitNames.add(transitName);
        }

        return new TransitNameModel(0, transitNames);
    }

    private static TransitParameterModel createTransitParameterModel(
        Collection<DvTarget> targets) {

        List<TransitParameter> transitParameters = new ArrayList<TransitParameter>(
            targets.size());
        int count = 0;
        Random random = new Random(targets.size());
        for (DvTarget target : targets) {
            TransitParameter transitParameter = new TransitParameter(
                target.getKeplerId(), String.format("K%05d.01", count),
                TransitParameterModel.DURATION_NAME, String.format("%f",
                    random.nextFloat()));
            transitParameters.add(transitParameter);
            transitParameter = new TransitParameter(target.getKeplerId(),
                String.format("K%05d.01", count),
                TransitParameterModel.EPOCH_NAME, String.format("%f",
                    random.nextFloat()));
            transitParameters.add(transitParameter);
            transitParameter = new TransitParameter(target.getKeplerId(),
                String.format("K%05d.01", count),
                TransitParameterModel.PERIOD_NAME, String.format("%f",
                    random.nextFloat()));
            transitParameters.add(transitParameter);
        }

        return new TransitParameterModel(0, transitParameters);
    }

    public static String mockExternalTceModelDescription(JMockTest jMockTest,
        DvCrud dvCrud, PipelineTask pipelineTask, boolean externalTcesEnabled) {

        String externalTceModelDescription = "";
        if (externalTcesEnabled) {
            externalTceModelDescription = EXTERNAL_TCE_MODEL_DESCRIPTION;
        }
        DvExternalTceModelDescription dvExternalTceModelDescription = new DvExternalTceModelDescription(
            pipelineTask, externalTceModelDescription);
        if (jMockTest != null && dvCrud != null) {
            jMockTest.oneOf(dvCrud)
                .create(dvExternalTceModelDescription);
        }

        return externalTceModelDescription;
    }

    public static DvTransitModelDescriptions mockTransitModelDescriptions(
        JMockTest jMockTest, DvCrud dvCrud, PipelineTask pipelineTask) {

        DvTransitModelDescriptions dvTransitModelDescriptions = new DvTransitModelDescriptions(
            pipelineTask, TRANSIT_NAME_MODEL_DESCRIPTION,
            TRANSIT_PARAMETER_MODEL_DESCRIPTION);
        if (jMockTest != null && dvCrud != null) {
            jMockTest.allowing(dvCrud)
                .create(dvTransitModelDescriptions);
        }

        return dvTransitModelDescriptions;
    }

    public static void mockSkyGroupIdsForKeplerIds(JMockTest jMockTest,
        CelestialObjectOperations celestialObjectOperations,
        List<Integer> keplerIds, int skyGroupId) {

        Map<Integer, Integer> skyGroupIdsByKeplerIds = new HashMap<Integer, Integer>();
        for (Integer keplerId : keplerIds) {
            skyGroupIdsByKeplerIds.put(keplerId, skyGroupId);
        }
        if (jMockTest != null && celestialObjectOperations != null) {
            jMockTest.allowing(celestialObjectOperations)
                .retrieveSkyGroupIdsForKeplerIds(keplerIds);
            jMockTest.will(returnValue(skyGroupIdsByKeplerIds));
        }
    }

    public static void mockInputsHandler(final DvJMockTest dvJMockTest,
        final InputsHandler inputsHandler, final File subTaskDir) {

        if (dvJMockTest != null && inputsHandler != null) {
            dvJMockTest.atLeast(1)
                .of(inputsHandler)
                .addSubTaskInputs(dvJMockTest.getExpectations()
                    .with(Expectations.any(Persistable.class)));
            dvJMockTest.allowing(inputsHandler)
                .subTaskDirectory();
            dvJMockTest.will(returnValue(subTaskDir));
        }
    }

}
