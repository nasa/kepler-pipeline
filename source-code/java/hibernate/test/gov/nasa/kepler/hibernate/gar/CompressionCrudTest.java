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

package gov.nasa.kepler.hibernate.gar;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.TadReport;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link CompressionCrud} class.
 * 
 * @author Bill Wohler
 */
public class CompressionCrudTest {

    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;

    private DatabaseService databaseService;
    private CompressionCrud compressionCrud;

    private HuffmanTable huffmanTable1;
    private HuffmanTable huffmanTable2;
    private HuffmanTable huffmanTable3;
    private HuffmanTable huffmanTable4;

    private RequantTable requantTable1;
    private RequantTable requantTable2;

    private PipelineInstance pipelineInstance;
    private PipelineTask pipelineTask;

    private HistogramGroup histogramGroup;
    private HistogramGroup histogramGroupForFocalPlane;
    private ReflectionEquals reflectionEquals;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
        compressionCrud = new CompressionCrud(databaseService);

        reflectionEquals = new ReflectionEquals();
        reflectionEquals.excludeField(".*\\.uowTask");
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testCreateHistogram() {
        populateObjects();
    }

    @Test
    public void testCreateHistogramGroup() {
        populateObjects();
    }

    @Test
    public void testRetrieveAllHistogramGroups() throws IllegalAccessException {
        populateObjects();

        List<HistogramGroup> histogramGroups = compressionCrud.retrieveAllHistogramGroups();
        assertEquals(3, histogramGroups.size());
        HistogramGroup hg = histogramGroups.get(1);
        reflectionEquals.assertEquals(histogramGroup, hg);
    }

    @Test
    public void testRetrieveHistogramGroups() throws IllegalAccessException {
        populateObjects();

        List<HistogramGroup> histogramGroups = compressionCrud.retrieveHistogramGroups(pipelineInstance);
        assertEquals(2, histogramGroups.size());
        HistogramGroup hg = histogramGroups.get(0);
        reflectionEquals.assertEquals(histogramGroup, hg);
    }

    @Test
    public void testRetrieveHistogramGroupForEntireFocalPlane()
        throws IllegalAccessException {
        populateObjects();

        HistogramGroup hg = compressionCrud.retrieveHistogramGroupForEntireFocalPlane(pipelineInstance.getId());
        assertNotNull(hg);
        reflectionEquals.assertEquals(histogramGroupForFocalPlane, hg);
    }

    @Test
    public void testRetrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane() {
        long id = compressionCrud.retrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane();
        assertEquals(-1L, id);

        populateObjects();

        id = compressionCrud.retrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane();
        assertEquals(histogramGroupForFocalPlane.getPipelineInstance()
            .getId(), id);
        assertEquals(pipelineInstance.getId(), id);
    }

    @Test
    public void testDeleteHistogram() {
        populateObjects();

        databaseService.beginTransaction();
        List<HistogramGroup> histogramGroups = compressionCrud.retrieveHistogramGroups(pipelineInstance);
        Histogram histogram = histogramGroups.get(0)
            .getHistograms()
            .get(0);
        histogramGroups.get(0)
            .getHistograms()
            .remove(histogram);
        compressionCrud.delete(histogram);
        databaseService.commitTransaction();
    }

    @Test
    public void testDeleteHistogramGroup() {
        populateObjects();

        databaseService.beginTransaction();
        compressionCrud.delete(histogramGroup);
        List<HistogramGroup> histogramGroups = compressionCrud.retrieveHistogramGroups(pipelineInstance);
        assertEquals(1, histogramGroups.size());
        databaseService.commitTransaction();
    }

    @Test
    public void retrieveHuffmanTable() throws Exception {
        populateObjects();

        databaseService.beginTransaction();
        HuffmanTable retrieved = compressionCrud.retrieveHuffmanTable(huffmanTable1.getId());
        reflectionEquals.assertEquals(huffmanTable1, retrieved);
        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveHuffmanTableForTargetTable() {
        populateObjects();

        databaseService.beginTransaction();
        TargetTable targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setExternalId(5);
        targetTable.setTadReport(new TadReport());
        targetTable.setState(State.UPLINKED);

        TargetCrud targetCrud = new TargetCrud();
        targetCrud.createTargetTable(targetTable);

        LogCrud logCrud = new LogCrud();
        PixelLog pixelLog = new PixelLog();
        pixelLog.setLcTargetTableId((short) targetTable.getExternalId());
        pixelLog.setCompressionTableId((short) huffmanTable2.getExternalId());

        logCrud.createPixelLog(pixelLog);

        databaseService.commitTransaction();

        List<HuffmanTable> huffmanTables = compressionCrud.retrieveHuffmanTable(targetTable);
        assertEquals(1, huffmanTables.size());
        assertEquals(huffmanTable2, huffmanTables.get(0));
    }

    @Test
    public void retrieveAllHuffmanTables() throws Exception {
        populateObjects();

        // Add in reverse order since retrieveAllHuffmanTables sorts in reverse
        // chronological order.
        Collection<HuffmanTable> expected = new LinkedList<HuffmanTable>();
        expected.add(huffmanTable4);
        expected.add(huffmanTable3);
        expected.add(huffmanTable2);
        expected.add(huffmanTable1);

        databaseService.beginTransaction();
        Collection<HuffmanTable> retrieved = compressionCrud.retrieveAllHuffmanTables();
        for (HuffmanTable huffmanTable : retrieved) {
            if (huffmanTable.getPipelineTask() != null) {
                huffmanTable.getPipelineTask()
                    .setUowTask(null); // don't care
            }
        }
        reflectionEquals.assertEquals(expected, retrieved);
        databaseService.commitTransaction();
    }

    @Test
    public void retrieveAllHuffmanTableDescriptors() throws Exception {
        populateObjects();

        // Add in reverse order since retrieveAllHuffmanTables sorts in reverse
        // chronological order.
        Collection<HuffmanTableDescriptor> expected = new LinkedList<HuffmanTableDescriptor>();
        expected.add(new HuffmanTableDescriptor(huffmanTable4));
        expected.add(new HuffmanTableDescriptor(huffmanTable3));
        expected.add(new HuffmanTableDescriptor(huffmanTable2));
        expected.add(new HuffmanTableDescriptor(huffmanTable1));

        databaseService.beginTransaction();
        Collection<HuffmanTableDescriptor> retrieved = compressionCrud.retrieveAllHuffmanTableDescriptors();
        reflectionEquals.assertEquals(expected, retrieved);
        databaseService.commitTransaction();
    }

    @Test
    public void retrieveHuffmanByTime() {
        populateObjects();

        List<HuffmanTable> list = compressionCrud.retrieveHuffmanTables(0.0,
            2.0);
        assertEquals(1, list.size());
        assertEquals(huffmanTable2, list.get(0));

        Pair<Double, Double> startStopTimes = compressionCrud.retrieveStartEndTimes(huffmanTable2.getExternalId());
        assertEquals(1.5, startStopTimes.left, 0);
        assertEquals(1.5, startStopTimes.right, 0);

        list = compressionCrud.retrieveHuffmanTables(1.6, 42.0);
        assertEquals(0, list.size());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooSmallRequantEntryCount() {
        RequantTable requantTable = new RequantTable();
        List<RequantEntry> requantEntries = new ArrayList<RequantEntry>();
        requantEntries.add(new RequantEntry(0));
        requantTable.setRequantEntries(requantEntries);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooSmallMeanBlackEntryCount() {
        RequantTable requantTable = new RequantTable();
        List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>();
        meanBlackEntries.add(new MeanBlackEntry(0));
        requantTable.setMeanBlackEntries(meanBlackEntries);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooLargeRequantEntryCount() {
        RequantTable requantTable = new RequantTable();
        List<RequantEntry> requantEntries = new ArrayList<RequantEntry>(
            FcConstants.REQUANT_TABLE_LENGTH + 1);
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH + 1; i++) {
            requantEntries.add(new RequantEntry(0));
        }
        requantTable.setRequantEntries(requantEntries);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooLargeMeanBlackEntryCount() {
        RequantTable requantTable = new RequantTable();
        List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>(
            FcConstants.MEAN_BLACK_TABLE_LENGTH + 1);
        for (int i = 0; i < FcConstants.MEAN_BLACK_TABLE_LENGTH + 1; i++) {
            meanBlackEntries.add(new MeanBlackEntry(0));
        }
        requantTable.setMeanBlackEntries(meanBlackEntries);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooSmallRequantEntryValue() {
        new RequantEntry(FcConstants.REQUANT_TABLE_MIN_VALUE - 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooLargeRequantEntryValue() {
        new RequantEntry(FcConstants.REQUANT_TABLE_MAX_VALUE + 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooSmallMeanBlackEntryValue() {
        new MeanBlackEntry(FcConstants.MEAN_BLACK_TABLE_MIN_VALUE - 1);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testTooLargeMeanBlackEntryValue() {
        new MeanBlackEntry(FcConstants.MEAN_BLACK_TABLE_MAX_VALUE + 1);
    }

    @Test
    public void retrieveRequantTables() throws Exception {
        // Since this method takes a long time to run, combine all of the
        // requant table tests into one.
        populateRequantTableObjects();

        // Retrieve requant table by ID.
        RequantTable retrieved = compressionCrud.retrieveRequantTable(requantTable1.getId());
        reflectionEquals.assertEquals(requantTable1, retrieved);
        retrieved = compressionCrud.retrieveUplinkedRequantTable(requantTable2.getExternalId());
        retrieved.getPipelineTask()
            .setUowTask(null); // don't care
        reflectionEquals.assertEquals(requantTable2, retrieved);

        // Retrieve all requant tables.
        Collection<RequantTable> expected = new ArrayList<RequantTable>();
        expected.add(requantTable2);
        expected.add(requantTable1);

        Collection<RequantTable> retrievedTables = compressionCrud.retrieveAllRequantTables();
        reflectionEquals.assertEquals(expected, retrievedTables);

        // Retrieve requant table descriptors
        Collection<RequantTableDescriptor> expectedTableDescriptors = new ArrayList<RequantTableDescriptor>();
        expectedTableDescriptors.add(new RequantTableDescriptor(requantTable2));
        expectedTableDescriptors.add(new RequantTableDescriptor(requantTable1));

        Collection<RequantTableDescriptor> retrievedTableDescriptors = compressionCrud.retrieveAllRequantTableDescriptors();
        reflectionEquals.assertEquals(expectedTableDescriptors,
            retrievedTableDescriptors);

        // Retrieve requant table by time.
        List<RequantTable> list = compressionCrud.retrieveRequantTables(0.0,
            42.0);
        assertEquals(1, list.size());
        assertEquals(requantTable2, list.get(0));

        list = compressionCrud.retrieveRequantTables(2.0, 2.0);
        assertEquals(0, list.size());
    }

    @Test
    public void testRetrieveRequantTableForTargetTable() {
        populateObjects();
        populateRequantTableObjects();

        databaseService.beginTransaction();
        TargetTable targetTable = new TargetTable(TargetType.SHORT_CADENCE);
        targetTable.setExternalId(5);
        targetTable.setTadReport(new TadReport());
        targetTable.setState(State.UPLINKED);

        TargetCrud targetCrud = new TargetCrud();
        targetCrud.createTargetTable(targetTable);

        LogCrud logCrud = new LogCrud();
        PixelLog pixelLog = new PixelLog();
        pixelLog.setScTargetTableId((short) targetTable.getExternalId());
        pixelLog.setCompressionTableId((short) requantTable2.getExternalId());

        logCrud.createPixelLog(pixelLog);

        databaseService.commitTransaction();

        List<RequantTable> requantTables = compressionCrud.retrieveRequantTable(targetTable);
        assertEquals(1, requantTables.size());
        assertEquals(requantTable2, requantTables.get(0));
    }

    @Test
    public void retrieveUplinkedExternalIds() {
        databaseService.beginTransaction();
        Set<Integer> uplinkedExternalIds = compressionCrud.retrieveUplinkedExternalIds();
        assertEquals(0, uplinkedExternalIds.size());
        databaseService.commitTransaction();

        populateObjects();

        databaseService.beginTransaction();
        uplinkedExternalIds = compressionCrud.retrieveUplinkedExternalIds();
        assertEquals(2, uplinkedExternalIds.size());
        int i = 0;
        for (Integer externalId : uplinkedExternalIds) {
            if (i == 0) {
                assertEquals(42, (int) externalId);
            } else if (i == 1) {
                assertEquals(84, (int) externalId);
            }
            i++;
        }
        databaseService.commitTransaction();
    }

    @Test
    public void retrieveExternalIdsInUse() {
        databaseService.beginTransaction();
        Set<Integer> externalIdsInUse = compressionCrud.retrieveExternalIdsInUse();
        assertEquals(0, externalIdsInUse.size());
        databaseService.commitTransaction();

        populateObjects();

        databaseService.beginTransaction();
        externalIdsInUse = compressionCrud.retrieveExternalIdsInUse();
        assertEquals(3, externalIdsInUse.size());
        int i = 0;
        for (Integer externalId : externalIdsInUse) {
            if (i == 0) {
                assertEquals(42, (int) externalId);
            } else if (i == 1) {
                assertEquals(84, (int) externalId);
            } else if (i == 2) {
                assertEquals(126, (int) externalId);
            }
            i++;
        }
        databaseService.commitTransaction();
    }

    private void populateObjects() {
        populateObjects(false);
    }

    private void populateObjects(boolean transactionOpen) {
        compressionCrud = new CompressionCrud();
        LogCrud logCrud = new LogCrud();

        if (!transactionOpen) {
            databaseService.beginTransaction();
        }

        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud(
            databaseService);
        PipelineInstance dummyPipelineInstance = createPipelineInstance();
        pipelineInstanceCrud.create(dummyPipelineInstance);

        pipelineInstance = createPipelineInstance();
        pipelineInstanceCrud.create(pipelineInstance);

        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud(
            databaseService);
        pipelineTask = createPipelineTask();
        pipelineTask.setPipelineInstance(pipelineInstance);
        pipelineTaskCrud.create(pipelineTask);

        // HuffmanTable and HuffmanEntry.
        List<HuffmanEntry> huffmanEntries = new LinkedList<HuffmanEntry>();
        huffmanEntries.add(new HuffmanEntry("1", 1L));
        huffmanEntries.add(new HuffmanEntry("2", 2L));

        huffmanTable1 = new HuffmanTable();
        huffmanTable1.setEntries(huffmanEntries);
        compressionCrud.createHuffmanTable(huffmanTable1);

        huffmanTable3 = new HuffmanTable();
        huffmanTable3.setExternalId(84);
        huffmanTable3.setState(State.UPLINKED);
        huffmanTable3.setPipelineTask(pipelineTask);
        compressionCrud.createHuffmanTable(huffmanTable3);

        huffmanTable4 = new HuffmanTable();
        huffmanTable4.setExternalId(126);
        compressionCrud.createHuffmanTable(huffmanTable4);

        huffmanTable2 = new HuffmanTable();
        huffmanTable2.setExternalId(42);
        huffmanTable2.setState(State.UPLINKED);
        compressionCrud.createHuffmanTable(huffmanTable2);

        short sv = (short) 1;
        PixelLog pixelLog = new PixelLog(null, 1, 1, "fits", "dsname", 1.0,
            2.0, sv, sv, sv, sv, sv, (short) huffmanTable2.getExternalId());
        logCrud.createPixelLog(pixelLog);

        // Histogram and HistogramGroup.
        // Add dummy HistogramGroup to ensure that
        // retrievePipelineInstanceIdForLatestHistogramGroupForEntireFocalPlane
        // gets the right HistogramGroup.
        Histogram dummyHistogram = createHistogram();
        compressionCrud.create(dummyHistogram);

        HistogramGroup dummyHistogramGroup = createHistogramGroup(
            dummyHistogram, HistogramGroup.CCD_MOD_OUT_ALL,
            HistogramGroup.CCD_MOD_OUT_ALL, 24, dummyPipelineInstance,
            pipelineTask);
        compressionCrud.create(dummyHistogramGroup);

        Histogram histogram = createHistogram();
        compressionCrud.create(histogram);

        histogramGroup = createHistogramGroup(histogram, CCD_MODULE,
            CCD_OUTPUT, 42, pipelineInstance, pipelineTask);
        compressionCrud.create(histogramGroup);

        histogram = createHistogram();
        compressionCrud.create(histogram);
        histogramGroupForFocalPlane = createHistogramGroup(histogram,
            HistogramGroup.CCD_MOD_OUT_ALL, HistogramGroup.CCD_MOD_OUT_ALL, 48,
            pipelineInstance, pipelineTask);
        compressionCrud.create(histogramGroupForFocalPlane);

        if (!transactionOpen) {
            databaseService.commitTransaction();
            databaseService.closeCurrentSession();
        }
    }

    private void populateRequantTableObjects() {
        databaseService.beginTransaction();

        populateObjects(true);

        // RequantTables and RequantEntry.
        List<RequantEntry> requantEntries = new ArrayList<RequantEntry>(
            FcConstants.REQUANT_TABLE_LENGTH);
        for (int i = 0; i < FcConstants.REQUANT_TABLE_LENGTH; i++) {
            requantEntries.add(new RequantEntry(i));
        }
        List<MeanBlackEntry> meanBlackEntries = new ArrayList<MeanBlackEntry>(
            FcConstants.MEAN_BLACK_TABLE_LENGTH);
        for (int i = 0; i < FcConstants.MEAN_BLACK_TABLE_LENGTH; i++) {
            meanBlackEntries.add(new MeanBlackEntry(i));
        }

        requantTable1 = new RequantTable();
        requantTable1.setRequantEntries(requantEntries);
        requantTable1.setMeanBlackEntries(meanBlackEntries);
        requantTable1.setPlannedStartTime(new Date());
        compressionCrud.createRequantTable(requantTable1);

        requantTable2 = new RequantTable();
        requantTable2.setExternalId(42);
        requantTable2.setState(State.UPLINKED);
        requantTable2.setPlannedStartTime(new Date(
            requantTable1.getPlannedStartTime()
                .getTime() + 600));
        requantTable2.setPipelineTask(pipelineTask);
        compressionCrud.createRequantTable(requantTable2);

        short sv = (short) 666;
        PixelLog pixelLog = new PixelLog(null, 1, 1, "fits", "dsname", 1.0,
            2.0, sv, sv, sv, sv, sv, (short) requantTable2.externalId);
        new LogCrud().createPixelLog(pixelLog);

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @SuppressWarnings("serial")
    private Histogram createHistogram() {
        Histogram histogram = new Histogram();
        histogram.setBaselineInterval(42);
        histogram.setTheoreticalCompressionRate(42.0F);
        histogram.setTotalStorageRate(43.0F);
        histogram.setUncompressedBaselineOverheadRate(44.0F);
        histogram.setHistogram(new ArrayList<Long>() {
            {
                add(1L);
                add(2L);
                add(3L);
            }
        });

        return histogram;
    }

    @SuppressWarnings("serial")
    private HistogramGroup createHistogramGroup(final Histogram histogram,
        int ccdModule, int ccdOutput, int baselineInterval,
        PipelineInstance pipelineInstance, PipelineTask pipelineTask) {

        HistogramGroup histogramGroup = new HistogramGroup(pipelineInstance,
            pipelineTask, ccdModule, ccdOutput);
        histogramGroup.setBestStorageRate(43.0F);
        histogramGroup.setBestBaselineInterval(baselineInterval);
        histogramGroup.setHistograms(new ArrayList<Histogram>() {
            {
                add(histogram);
            }
        });

        return histogramGroup;
    }

    private PipelineInstance createPipelineInstance() {
        PipelineInstance pipelineInstance = new PipelineInstance();

        return pipelineInstance;
    }

    private PipelineTask createPipelineTask() {
        PipelineTask pipelineTask = new PipelineTask();

        return pipelineTask;
    }
}
