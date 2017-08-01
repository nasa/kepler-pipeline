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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTableLog;
import gov.nasa.kepler.mc.TimeSeriesOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.fs.CalFsIdFactory;
import gov.nasa.kepler.mc.fs.CalFsIdFactory.PixelTimeSeriesType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.persistable.Persistable;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class SbtRetrieveTargetTimeSeries extends AbstractSbt {
    private static final String SDF_FILE_NAME = "/tmp/sbt-retrieve-target-time-series.sdf";
    private static final boolean REQUIRES_DATABASE = true;
    private static final boolean REQUIRES_FILESTORE = true;

    public static class TargetTimeSeriesContainer implements Persistable {
        List<ChannelContainer> channels;

        public TargetTimeSeriesContainer() {
            channels = new ArrayList<ChannelContainer>();
        }
    }

    public static class ChannelContainer implements Persistable {
        public int module;
        public int output;
        public double[] mjdArray;
        public boolean isLongCadence;
        public boolean isOriginalData;
        public List<TargetContainer> targetContainers;

        public ChannelContainer() {
            targetContainers = new ArrayList<TargetContainer>();
        }
    }

    public static class TargetContainer implements Persistable {
        public int keplerId;
        public int[] rows;
        public int[] columns;
        public float[][] timeSeries;
        public float[][] uncertainty;
        public boolean[][] gapIndicators;

        public TargetContainer(int arrayLength) {
            rows = new int[arrayLength];
            columns = new int[arrayLength];
            timeSeries = new float[arrayLength][];
            uncertainty = new float[arrayLength][];
            gapIndicators = new boolean[arrayLength][];
        }

    }

    public SbtRetrieveTargetTimeSeries() {
        super(REQUIRES_DATABASE, REQUIRES_FILESTORE);
    }

    public String retrieveTargetTimeSeries(int[] ccdModules, int[] ccdOutputs,
        int startCadence, int endCadence, boolean isLongCadence,
        boolean isCalibrated) throws Exception {

        if (! validateDatastores()) {
            return "";
        }

        if (ccdModules.length != ccdOutputs.length) {
            throw new IllegalArgumentException(
                "ccdModules and ccdOutputs must have equal lenghts");
        }

        TargetTimeSeriesContainer container = new TargetTimeSeriesContainer();
        for (int ii = 0; ii < ccdModules.length; ++ii) {
            ChannelContainer singleChannel = retrieveSingleChannelTimeSeries(
                ccdModules[ii], ccdOutputs[ii], startCadence, endCadence,
                isLongCadence, isCalibrated);
            container.channels.add(singleChannel);
        }

        return makeSdf(container, SDF_FILE_NAME);
    }

    public String retrieveTargetTimeSeries(int[] ccdModules, int[] ccdOutputs,
        int startCadence, int endCadence) throws Exception {
        return retrieveTargetTimeSeries(ccdModules, ccdOutputs, startCadence,
            endCadence, true, true);
    }

    private ChannelContainer retrieveSingleChannelTimeSeries(int ccdModule,
        int ccdOutput, int startCadence, int endCadence, boolean isLongCadence,
        boolean isCalibrated) {

        TargetCrud targetCrud = new TargetCrud();
        TargetTable.TargetType targetTableType = isLongCadence ? TargetTable.TargetType.LONG_CADENCE
            : TargetTable.TargetType.SHORT_CADENCE;

        List<TargetTableLog> targetTableLogs = targetCrud.retrieveTargetTableLogs(
            targetTableType, startCadence, endCadence);

        ChannelContainer channelContainer = new ChannelContainer();
        channelContainer.isLongCadence = isLongCadence;
        channelContainer.isOriginalData = !isCalibrated;
        channelContainer.module = ccdModule;
        channelContainer.output = ccdOutput;
        channelContainer.mjdArray = new MjdToCadence(
            CadenceType.LONG, new ModelMetadataRetrieverLatest()).cadenceTimes(
            startCadence, endCadence).midTimestamps;

        TimeSeriesOperations timeSeriesOperations = new TimeSeriesOperations();

        for (int itargettablelog = 0; itargettablelog < targetTableLogs.size(); ++itargettablelog) {
            TargetTableLog targetTableLog = targetTableLogs.get(itargettablelog);
            TargetTable targetTable = targetTableLog.getTargetTable();

            List<TargetDefinition> targetDefinitions = targetCrud.retrieveTargetDefinitions(
                targetTable, ccdModule, ccdOutput);
            List<TargetContainer> targetContainers = initializeTargetContainers(targetDefinitions);

            FsId[] allDataFsIds = getUniqueFsIds(targetDefinitions,
                targetTableType, ccdModule, ccdOutput, true);
            Map<Pair<Integer, Integer>, Integer> rowColToFsIdIndex = makeRowColToFsIdIndex(
                targetDefinitions, targetTableType, ccdModule, ccdOutput,
                allDataFsIds);

            FloatTimeSeries[] allDataTimeSeries = timeSeriesOperations.readPixelTimeSeriesAsFloat(
                allDataFsIds, startCadence, endCadence);
            FloatTimeSeries[] allUncertTimeSeries = null;
            if (isCalibrated) {
                FsId[] allUncertFsIds = getUniqueFsIds(targetDefinitions,
                    targetTableType, ccdModule, ccdOutput, false);
                allUncertTimeSeries = timeSeriesOperations.readPixelTimeSeriesAsFloat(
                    allUncertFsIds, startCadence, endCadence);
            }

            for (int itargetcontainer = 0; itargetcontainer < targetContainers.size(); ++itargetcontainer) {
                TargetContainer targetContainer = targetContainers.get(itargetcontainer);
                targetContainer = putDataInTargetContainer(targetContainer,
                    rowColToFsIdIndex, allDataTimeSeries, allUncertTimeSeries,
                    isCalibrated);
                targetContainers.set(itargetcontainer, targetContainer);
            }
            channelContainer.targetContainers.addAll(targetContainers);
        }

        return channelContainer;
    }

    private TargetContainer putDataInTargetContainer(
        TargetContainer targetContainer,
        Map<Pair<Integer, Integer>, Integer> rowColToFsIdIndex,
        FloatTimeSeries[] allDataTimeSeries,
        FloatTimeSeries[] allUncertTimeSeries, boolean isCalibrated) {

        for (int ipixel = 0; ipixel < targetContainer.rows.length; ++ipixel) {

            int row = targetContainer.rows[ipixel];
            int column = targetContainer.columns[ipixel];
            int index = rowColToFsIdIndex.get(Pair.of(row, column));

            float[] dataArray = allDataTimeSeries[index].fseries();
            boolean[] gapArray = allDataTimeSeries[index].getGapIndicators();
            float[] uncertaintyArray = new float[dataArray.length];
            if (isCalibrated) {
                uncertaintyArray = allUncertTimeSeries[index].fseries();
            } else {
                Arrays.fill(uncertaintyArray, 0.0f);
            }

            targetContainer.timeSeries[ipixel] = dataArray;
            targetContainer.uncertainty[ipixel] = uncertaintyArray;
            targetContainer.gapIndicators[ipixel] = gapArray;
        }
        return targetContainer;
    }

    private List<TargetContainer> initializeTargetContainers(
        List<TargetDefinition> targetDefinitions) {

        List<TargetContainer> targets = new ArrayList<TargetContainer>();

        for (TargetDefinition targetDefinition : targetDefinitions) {
            List<Offset> offsets = targetDefinition.getMask()
                .getOffsets();

            int offsetCount = offsets.size();
            TargetContainer targetContainer = new TargetContainer(offsetCount);
            targetContainer.keplerId = targetDefinition.getKeplerId();

            for (int ipixel = 0; ipixel < offsetCount; ++ipixel) {
                Offset offset = offsets.get(ipixel);

                int row = offset.getRow() + targetDefinition.getReferenceRow();
                int column = offset.getColumn()
                    + targetDefinition.getReferenceColumn();

                targetContainer.rows[ipixel] = row;
                targetContainer.columns[ipixel] = column;
            }
            targets.add(targetContainer);
        }
        return targets;
    }

    /**
     * Create the mapping of pixel address (Pair.of(row, col)) to the index into
     * the fsIds list. This cumbersome data structure is necessary because fsIds
     * is a list of unique fsIds, to avoid the "Duplicate FsId" exception from
     * FileStore.
     */
    private Map<Pair<Integer, Integer>, Integer> makeRowColToFsIdIndex(
        List<TargetDefinition> targetDefinitions,
        TargetTable.TargetType targetTableType, int ccdModule, int ccdOutput,
        FsId[] fsIdsArray) {

        List<FsId> fsIds = new ArrayList<FsId>(Arrays.asList(fsIdsArray));

        Map<Pair<Integer, Integer>, Integer> rowColToFsIdIndex = new HashMap<Pair<Integer, Integer>, Integer>();

        CalFsIdFactory.PixelTimeSeriesType timeSeriesType = PixelTimeSeriesType.SOC_CAL;

        for (TargetDefinition targetDefinition : targetDefinitions) {
            for (Offset offset : targetDefinition.getMask()
                .getOffsets()) {

                int row = offset.getRow() + targetDefinition.getReferenceRow();
                int column = offset.getColumn()
                    + targetDefinition.getReferenceColumn();

                FsId fsId = CalFsIdFactory.getTimeSeriesFsId(timeSeriesType,
                    targetTableType, ccdModule, ccdOutput, row, column);

                Integer index = fsIds.indexOf(fsId);
                Pair<Integer, Integer> rowCol = Pair.of(row, column);
                rowColToFsIdIndex.put(rowCol, index);
            }
        }

        return rowColToFsIdIndex;
    }

    private FsId[] getUniqueFsIds(List<TargetDefinition> targetDefinitions,
        TargetTable.TargetType targetTableType, int ccdModule, int ccdOutput,
        boolean isData) {

        CalFsIdFactory.PixelTimeSeriesType timeSeriesType = isData ? PixelTimeSeriesType.SOC_CAL
            : PixelTimeSeriesType.SOC_CAL_UNCERTAINTIES;
        List<FsId> fsIds = new ArrayList<FsId>();

        int count = 0;
        for (TargetDefinition targetDefinition : targetDefinitions) {
            ++count;
            if (count % 250 == 0) {
                System.out.println("Fetching target data " + count + " of "
                    + targetDefinitions.size());
            }

            for (Offset offset : targetDefinition.getMask()
                .getOffsets()) {
                int row = offset.getRow() + targetDefinition.getReferenceRow();
                int column = offset.getColumn()
                    + targetDefinition.getReferenceColumn();

                // Only add new FsIds to the list. This avoids the
                // gov.nasa.kepler.fs.api.FileStoreException: Duplicate fsids
                // not permitted.
                // problem.
                //
                FsId fsId = CalFsIdFactory.getTimeSeriesFsId(timeSeriesType,
                    targetTableType, ccdModule, ccdOutput, row, column);
                if (!fsIds.contains(fsId)) {
                    fsIds.add(fsId);
                }
            }
        }

        return fsIds.toArray(new FsId[0]);
    }

    /**
     * @param args
     * @throws Exception
     */
    public static void main(String[] args) throws Exception {
        int startCadence = 3160; // double startMjd = 55006.0;
        int endCadence = 3307; // double endMjd = 55009.0;
        int[] ccdModules = { 7 };
        int[] ccdOutputs = { 2 };
        SbtRetrieveTargetTimeSeries sbt = new SbtRetrieveTargetTimeSeries();
        String path = sbt.retrieveTargetTimeSeries(ccdModules, ccdOutputs,
            startCadence, endCadence);
        System.out.println(path);
    }

}
