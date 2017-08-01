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

package gov.nasa.kepler.hibernate.tad;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TimeZone;

import javax.persistence.NonUniqueResultException;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class TargetCrudTest {

    private static final String TLS_NAME = "Important List Set";
    private static final Date START = new Date(1000);
    private static final Date END = new Date(2000);

    private static final String FIND_CATEGORY_1 = "Sean's Worlds!";
    private static final String FIND_CATEGORY_2 = "Star systems visited in ST:NG.";
    private static final int KEPLER_ID = 434343;
    private static final int DROPPED_KEPLER_ID = 666;
    private static final double CROWDING_METRIC = .0333;
    private static final double FLUX_FRACTION_IN_APERTURE = .7;
    private static final double SUPP_CROWDING_METRIC = CROWDING_METRIC + 1;
    private static final double SUPP_SKY_CROWDING_METRIC = CROWDING_METRIC + 2;
    private static final double SUPP_SIGNAL_TO_NOISE_RATIO = CROWDING_METRIC + 3;
    private static final short SHORT_CADENCE_EXTERNAL_ID = 16;
    private static final short BACK_MASK_TABLE_EXTERNAL_ID = 32;
    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;
    private static final int SKY_GROUP_ID = 3;
    private static final int OBSERVING_SEASON = 4;
    private static final int SATURATED_ROW_COUNT = 0;

    private TargetCrud targetCrud;

    private TargetTable targetTable;
    private TargetTable targetTable2;
    private TargetTable targetTable3;

    private List<TargetTableLog> targetTableLogs;
    private List<ObservedTarget> observedTargets;
    private List<TargetDefinition> targetDefs;
    private MaskTable maskTable;
    private List<Mask> masks;
    private TargetListSet targetListSet;

    private DatabaseService databaseService;
    private TargetSelectionCrud targetSelectionCrud;
    private LogCrud logCrud;
    private KicCrud kicCrud;
    private ReflectionEquals reflectionEquals;

    private TargetTable suppTargetTable;
    private TargetListSet suppTls;
    private ObservedTarget suppObservedTarget;
    private List<ObservedTarget> suppObservedTargets;

    private List<ObservedTarget> droppedObservedTargets;

    private PipelineTask pipelineTask;

    private final PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        targetCrud = new TargetCrud(databaseService);
        targetSelectionCrud = new TargetSelectionCrud(databaseService);
        logCrud = new LogCrud(databaseService);
        kicCrud = new KicCrud(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {
        reflectionEquals = new ReflectionEquals();
        reflectionEquals.excludeField(".*\\.tadReport");
        reflectionEquals.excludeField(".*\\.pipelineTask");

        try {
            databaseService.beginTransaction();
            pipelineTask = new PipelineTask();
            pipelineTaskCrud.create(pipelineTask);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        TargetList targetList = new TargetList("Important List");
        targetList.setCategory(FIND_CATEGORY_1);
        targetList.setSource("test");
        targetList.setSourceType(TargetList.SourceType.FILE);

        TargetList targetList2 = new TargetList("More Important List");
        targetList2.setCategory("Miles' Worlds!");
        targetList2.setSource("test");
        targetList2.setSourceType(TargetList.SourceType.FILE);

        TargetList targetList3 = new TargetList("Less important target list.");
        targetList3.setCategory("We don't care");
        targetList3.setSource("test");
        targetList3.setSourceType(TargetList.SourceType.FILE);

        TargetList targetList4 = new TargetList("Star Trek");
        targetList4.setCategory(FIND_CATEGORY_2);
        targetList4.setSource("test");
        targetList4.setSourceType(TargetList.SourceType.FILE);

        // Note that targetList2 is not included
        List<TargetList> targetLists = ImmutableList.of(targetList,
            targetList3, targetList4);

        PlannedTarget plannedTarget = new PlannedTarget(KEPLER_ID, 1, null);
        plannedTarget.setTargetList(targetList);

        PlannedTarget plannedTarget2 = new PlannedTarget(2, 2);
        plannedTarget2.setTargetList(targetList);

        PlannedTarget copyOfPlannedTarget1 = new PlannedTarget(KEPLER_ID, 1,
            null);
        copyOfPlannedTarget1.setTargetList(targetList2);

        PlannedTarget copyOfPlannedTarget2 = new PlannedTarget(2, 2);
        copyOfPlannedTarget2.setTargetList(targetList3);

        PlannedTarget copy2OfPlannedTarget1 = new PlannedTarget(KEPLER_ID, 1);
        copy2OfPlannedTarget1.setTargetList(targetList4);

        List<PlannedTarget> plannedTargets = ImmutableList.of(plannedTarget,
            plannedTarget2, copyOfPlannedTarget1, copyOfPlannedTarget2,
            copy2OfPlannedTarget1);

        targetListSet = new TargetListSet(TLS_NAME);
        targetListSet.setTargetLists(targetLists);

        maskTable = new MaskTable(MaskType.TARGET);
        maskTable.setExternalId(1);
        maskTable.setState(State.UPLINKED);

        List<Offset> offsets = ImmutableList.of(new Offset(1, 1));
        Mask mask = new Mask(maskTable, offsets);
        masks = ImmutableList.of(mask);

        targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setExternalId(1);
        targetTable.setState(State.UPLINKED);
        targetTable.setPlannedStartTime(START);
        targetTable.setPlannedEndTime(END);
        targetTable.setTadReport(new TadReport());
        targetTable.setMaskTable(maskTable);
        targetTable.setObservingSeason(OBSERVING_SEASON);

        targetListSet.setTargetTable(targetTable);

        ObservedTarget observedTarget = new ObservedTarget(targetTable,
            CCD_MODULE, CCD_OUTPUT, KEPLER_ID);
        observedTarget.setPipelineTask(pipelineTask);

        observedTargets = ImmutableList.of(observedTarget);

        TargetDefinition targetDef = new TargetDefinition(observedTarget);
        targetDef.setMask(mask);

        targetDefs = ImmutableList.of(targetDef);

        Aperture aperture = new Aperture();

        observedTarget.setAperture(aperture);
        observedTarget.getTargetDefinitions()
            .add(targetDef);
        observedTarget.addLabel(PlannedTarget.TargetLabel.PDQ_BACKGROUND);
        observedTarget.addLabel(PlannedTarget.TargetLabel.PDQ_DYNAMIC_RANGE);
        observedTarget.setCrowdingMetric(CROWDING_METRIC);

        PixelLog cadenceLog = new PixelLog();
        cadenceLog.setCadenceNumber(50);
        cadenceLog.setCadenceType(Cadence.CADENCE_LONG);
        cadenceLog.setLcTargetTableId((short) 1);
        cadenceLog.setScTargetTableId(SHORT_CADENCE_EXTERNAL_ID);
        cadenceLog.setTargetApertureTableId((short) maskTable.getExternalId());
        cadenceLog.setBackApertureTableId(BACK_MASK_TABLE_EXTERNAL_ID);

        TargetTableLog targetTableLog = new TargetTableLog(targetTable, 50, 50);

        targetTableLogs = ImmutableList.of(targetTableLog);

        SkyGroup skyGroup = new SkyGroup(SKY_GROUP_ID, CCD_MODULE, CCD_OUTPUT,
            OBSERVING_SEASON);

        // Store objects.
        try {
            databaseService.beginTransaction();
            kicCrud.create(skyGroup);
            logCrud.createPixelLog(cadenceLog);
            targetSelectionCrud.create(targetList);
            targetSelectionCrud.create(targetList2);
            targetSelectionCrud.create(targetList3);
            targetSelectionCrud.create(targetList4);
            targetSelectionCrud.create(plannedTargets);
            targetCrud.createMaskTable(maskTable);
            targetCrud.createMasks(masks);
            targetCrud.createTargetTable(targetTable);
            targetSelectionCrud.create(targetListSet);
            targetCrud.createObservedTargets(observedTargets);
            targetCrud.createImage(targetTable, CCD_MODULE, CCD_OUTPUT, null,
                null, -1, -1, -1, -1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private void populateMoreObjects() {
        try {
            databaseService.beginTransaction();

            targetTable2 = createTargetTable(2);
            targetTable3 = createTargetTable(3);

            targetCrud.createTargetTable(targetTable2);
            targetCrud.createTargetTable(targetTable3);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private void populateSupplementalObjects() {
        suppTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        suppTargetTable.setObservingSeason(OBSERVING_SEASON);

        suppTls = new TargetListSet("suppTls");
        suppTls.setTargetTable(suppTargetTable);

        List<Offset> apertureOffsets = ImmutableList.of(new Offset(1, 1));
        Aperture aperture = new Aperture(false, 0, 0, apertureOffsets);

        suppObservedTarget = new ObservedTarget(suppTargetTable, CCD_MODULE,
            CCD_OUTPUT, KEPLER_ID);
        suppObservedTarget.setPipelineTask(pipelineTask);
        suppObservedTarget.setCrowdingMetric(SUPP_CROWDING_METRIC);
        suppObservedTarget.setFluxFractionInAperture(FLUX_FRACTION_IN_APERTURE);
        suppObservedTarget.setSkyCrowdingMetric(SUPP_SKY_CROWDING_METRIC);
        suppObservedTarget.setSaturatedRowCount(SATURATED_ROW_COUNT);
        suppObservedTarget.setSignalToNoiseRatio(SUPP_SIGNAL_TO_NOISE_RATIO);
        suppObservedTarget.setAperture(aperture);

        suppObservedTargets = ImmutableList.of(suppObservedTarget);

        targetListSet = targetSelectionCrud.retrieveTargetListSet(TLS_NAME);
        targetListSet.setSupplementalTls(suppTls);

        try {
            databaseService.beginTransaction();
            targetCrud.createTargetTable(suppTargetTable);
            targetSelectionCrud.create(suppTls);
            targetCrud.createObservedTargets(suppObservedTargets);
            targetCrud.createImage(suppTargetTable, CCD_MODULE, CCD_OUTPUT,
                null, null, -1, -1, -1, -1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    /**
     * This target was on the original target table, but was dropped in the
     * supplemental TAD run. That is an aperture with zero pixels was created by
     * supplemental TAD.
     */
    private void populateDroppedTarget() {
        try {
            databaseService.beginTransaction();

            ObservedTarget droppedTarget = new ObservedTarget(targetTable,
                CCD_MODULE, CCD_OUTPUT, DROPPED_KEPLER_ID);
            droppedTarget.setPipelineTask(pipelineTask);
            droppedTarget.setFluxFractionInAperture(.66);
            droppedTarget.setCrowdingMetric(.99);
            droppedTarget.setSkyCrowdingMetric(0.98);
            droppedTarget.setSaturatedRowCount(1);
            droppedTarget.setSignalToNoiseRatio(0.97);

            List<Offset> maskOffsets0 = ImmutableList.of(new Offset(7, 7));
            Mask mask0 = new Mask(maskTable, maskOffsets0);
            TargetDefinition tdef0 = new TargetDefinition(droppedTarget);
            tdef0.setMask(mask0);
            tdef0.setTargetTable(targetTable);
            List<Offset> maskOffsets1 = ImmutableList.of(new Offset(6, 6));
            Mask mask1 = new Mask(maskTable, maskOffsets1);
            TargetDefinition tdef1 = new TargetDefinition(droppedTarget);
            tdef1.setMask(mask1);
            tdef1.setTargetTable(targetTable);

            droppedTarget.getTargetDefinitions()
                .add(tdef0);
            droppedTarget.getTargetDefinitions()
                .add(tdef1);

            droppedObservedTargets = ImmutableList.of(droppedTarget);

            targetCrud.createObservedTargets(droppedObservedTargets);
            targetCrud.createMask(mask0);
            targetCrud.createMask(mask1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private TargetTable createTargetTable(int i) {
        TargetTable ttable = new TargetTable(TargetType.LONG_CADENCE);
        ttable.setExternalId(i);
        ttable.setState(State.UPLINKED);
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        calendar.setTime(END);
        calendar.add(Calendar.MONTH, i - 1);
        Date startTime = calendar.getTime();
        ttable.setPlannedStartTime(startTime);
        calendar.add(Calendar.MONTH, 1);
        Date endTime = calendar.getTime();
        ttable.setPlannedEndTime(endTime);
        ttable.setTadReport(new TadReport());
        ttable.setMaskTable(maskTable);
        ttable.setObservingSeason(OBSERVING_SEASON);
        return ttable;
    }

    @Test
    public void testRetrieveMaskTableForTargetTable() {
        populateObjects();

        MaskTable backMaskTable = null;
        try {
            databaseService.beginTransaction();
            backMaskTable = new MaskTable(MaskType.BACKGROUND);
            backMaskTable.setExternalId(BACK_MASK_TABLE_EXTERNAL_ID);
            backMaskTable.setState(State.UPLINKED);

            targetCrud.createMaskTable(backMaskTable);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<MaskTable> backgroundMaskTable = targetCrud.retrieveMaskTableForTargetTable(
            targetTable, MaskType.BACKGROUND);
        assertEquals(1, backgroundMaskTable.size());
        assertEquals(backMaskTable, backgroundMaskTable.get(0));

        List<MaskTable> targetMaskTable = targetCrud.retrieveMaskTableForTargetTable(
            targetTable, MaskType.TARGET);
        assertEquals(1, targetMaskTable.size());
        assertEquals(maskTable, targetMaskTable.get(0));
    }

    @Test
    public void testRetrieveTargetTableForTargetTable() {
        populateObjects();
        populateMoreObjects();

        TargetTable shortTargetTable = null;
        try {
            databaseService.beginTransaction();
            shortTargetTable = createTargetTable(SHORT_CADENCE_EXTERNAL_ID);
            shortTargetTable.setType(TargetType.SHORT_CADENCE);
            shortTargetTable.setPlannedStartTime(targetTable.getPlannedStartTime());
            shortTargetTable.setPlannedEndTime(targetTable.getPlannedEndTime());

            targetCrud.createTargetTable(shortTargetTable);

            PixelLog pixelLog = new PixelLog();
            pixelLog.setCadenceNumber(50);
            pixelLog.setLcTargetTableId((short) targetTable.getExternalId());
            pixelLog.setScTargetTableId((short) shortTargetTable.getExternalId());

            logCrud.createPixelLog(pixelLog);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        List<TargetTable> empty = targetCrud.retrieveLongCadenceTargetTable(targetTable2);

        assertEquals(0, empty.size());

        List<TargetTable> shortList = targetCrud.retrieveShortCadenceTargetTable(targetTable);
        assertEquals(1, shortList.size());
        assertEquals(shortTargetTable, shortList.get(0));

        List<TargetTable> longList = targetCrud.retrieveLongCadenceTargetTable(shortTargetTable);
        assertEquals(1, longList.size());
        assertEquals(targetTable, longList.get(0));
    }

    @Test
    public void testRetrieveCrowdingMetricsForTargetTables() {
        populateObjects();
        populateMoreObjects();

        List<TargetTable> ttables = ImmutableList.of(targetTable, targetTable2,
            targetTable3);

        Map<Integer, TargetCrowdingInfo> keplerIdToCrowdingMetrics = targetCrud.retrieveCrowdingMetricInfo(
            ttables, SKY_GROUP_ID);
        assertEquals(1, keplerIdToCrowdingMetrics.size());
        TargetCrowdingInfo metrics = keplerIdToCrowdingMetrics.get(KEPLER_ID);
        assertArrayEquals(metrics.getCrowdingMetric(), new Double[] {
            CROWDING_METRIC, null, null });
    }

    @Test
    public void testRetrieveObservedKeplerIds() {
        populateObjects();

        List<Integer> keplerIds = targetCrud.retrieveObservedKeplerIds(targetTable);
        assertEquals(1, keplerIds.size());
        assertEquals((Integer) KEPLER_ID, keplerIds.get(0));

        keplerIds = targetCrud.retrieveObservedKeplerIds(targetTable,
            CCD_MODULE, CCD_OUTPUT);
        assertEquals(1, keplerIds.size());
        assertEquals((Integer) KEPLER_ID, keplerIds.get(0));

        keplerIds = targetCrud.retrieveObservedKeplerIds(targetTable,
            CCD_MODULE + 1, CCD_OUTPUT);
        assertEquals(0, keplerIds.size());
    }

    @Test
    public void testRetrieveTargetTableLogNoItems() {
        TargetTableLog targetTableLog = targetCrud.retrieveTargetTableLog(
            TargetType.LONG_CADENCE, 1, 100);
        assertNull(targetTableLog);
    }

    @Test
    public void testRetrieveTargetTableLogOneItem() throws Exception {
        populateObjects();
        TargetTableLog targetTableLog = targetCrud.retrieveTargetTableLog(
            TargetType.LONG_CADENCE, 1, 100);
        reflectionEquals.assertEquals(targetTableLogs.get(0), targetTableLog);
    }

    @Test(expected = NonUniqueResultException.class)
    public void testRetrieveTargetTableLogMultipleItems() {

        populateObjects();

        try {
            databaseService.beginTransaction();
            // Add another object in the cadence range.
            PixelLog cadenceLog = new PixelLog();
            cadenceLog.setCadenceNumber(51);
            cadenceLog.setCadenceType(Cadence.CADENCE_LONG);
            cadenceLog.setLcTargetTableId((short) 2);
            logCrud.createPixelLog(cadenceLog);

            targetCrud.retrieveTargetTableLog(TargetType.LONG_CADENCE, 1, 100);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testRetrieveTargetTableLogs() throws Exception {
        populateObjects();

        List<TargetTableLog> result = targetCrud.retrieveTargetTableLogs(
            TargetType.LONG_CADENCE, 1, 100);

        reflectionEquals.assertEquals(targetTableLogs, result);
    }

    @Test
    public void testRetrieveTargetDefinitions() throws Exception {
        populateObjects();

        List<TargetDefinition> result = targetCrud.retrieveTargetDefinitions(
            targetTable, CCD_MODULE, CCD_OUTPUT);

        reflectionEquals.assertEquals(targetDefs, result);
    }

    @Test
    public void testRetrieveTargetTable() throws Exception {
        populateObjects();

        TargetTable result = targetCrud.retrieveTargetTable(targetTable.getId());

        reflectionEquals.assertEquals(targetTable, result);
    }

    @Test
    public void testRetrieveUplinkedTargetTable() throws Exception {
        populateObjects();

        TargetTable result = targetCrud.retrieveUplinkedTargetTable(1,
            TargetType.LONG_CADENCE);

        reflectionEquals.assertEquals(targetTable, result);
    }

    @Test
    public void testRetrieveUplinkedTargetTables() throws Exception {
        populateObjects();

        List<TargetTable> result = targetCrud.retrieveUplinkedTargetTables(
            START, END);

        List<TargetTable> expected = ImmutableList.of(targetTable);
        reflectionEquals.assertEquals(expected, result);
    }

    @Test
    public void testDeleteTargetTable() throws Exception {
        populateObjects();

        long id = targetTable.getId();

        try {
            databaseService.beginTransaction();
            TargetTable oldTable = targetCrud.retrieveTargetTable(id);
            targetSelectionCrud.delete(targetListSet);
            targetCrud.delete(oldTable);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        TargetTable result = targetCrud.retrieveTargetTable(id);

        assertEquals(null, result);
    }

    @Test
    public void testRetrieveUplinkedExternalIdsTargetTable() throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveUplinkedExternalIds(TargetType.LONG_CADENCE);

        assertTrue(result.contains(1));
    }

    @Test
    public void testRetrieveUplinkedExternalIdsNonexistentTargetTable()
        throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveUplinkedExternalIds(TargetType.SHORT_CADENCE);

        assertEquals(0, result.size());
    }

    @Test
    public void testRetrieveExternalIdsInUseTargetTable() throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveExternalIdsInUse(TargetType.LONG_CADENCE);

        assertTrue(result.contains(1));
    }

    @Test
    public void testRetrieveExternalIdsInUseNonexistentTargetTable()
        throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveExternalIdsInUse(TargetType.SHORT_CADENCE);

        assertEquals(0, result.size());
    }

    @Test
    public void testRetrieveMaskTable() throws Exception {
        populateObjects();

        MaskTable result = targetCrud.retrieveMaskTable(maskTable.getId());

        reflectionEquals.assertEquals(maskTable, result);
    }

    @Test
    public void testRetrieveUplinkedMaskTable() throws Exception {
        populateObjects();

        MaskTable result = targetCrud.retrieveUplinkedMaskTable(1,
            MaskType.TARGET);

        reflectionEquals.assertEquals(maskTable, result);
    }

    @Test
    public void testDeleteMaskTable() throws Exception {
        populateObjects();

        long maskTableId = 0;
        try {
            databaseService.beginTransaction();

            TargetListSet targetListSet = targetSelectionCrud.retrieveAllTargetListSets()
                .get(0);

            TargetTable oldTargetTable = targetListSet.getTargetTable();
            MaskTable oldMaskTable = oldTargetTable.getMaskTable();

            TargetTable newTargetTable = new TargetTable(
                TargetType.LONG_CADENCE);
            targetCrud.createTargetTable(newTargetTable);
            targetListSet.setTargetTable(newTargetTable);

            maskTableId = maskTable.getId();

            targetCrud.delete(oldTargetTable);
            targetCrud.deleteSupermasks(oldMaskTable);
            targetCrud.delete(oldMaskTable);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        MaskTable result = targetCrud.retrieveMaskTable(maskTableId);

        assertEquals(null, result);
    }

    @Test
    public void testRetrieveUplinkedExternalIdsMaskTable() throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveUplinkedExternalIds(MaskType.TARGET);

        assertTrue(result.contains(1));
    }

    @Test
    public void testRetrieveUplinkedExternalIdsNonexistentMaskTable()
        throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveUplinkedExternalIds(MaskType.BACKGROUND);

        assertEquals(0, result.size());
    }

    @Test
    public void testRetrieveExternalIdsInUseMaskTable() throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveExternalIdsInUse(MaskType.TARGET);

        assertTrue(result.contains(1));
    }

    @Test
    public void testRetrieveExternalIdsInUseNonexistentMaskTable()
        throws Exception {
        populateObjects();

        Set<Integer> result = targetCrud.retrieveExternalIdsInUse(MaskType.BACKGROUND);

        assertEquals(0, result.size());
    }

    @Test
    public void testRetrieveObservedTargets() throws Exception {
        populateObjects();

        List<ObservedTarget> result = targetCrud.retrieveObservedTargetsPlusRejected(targetTable);

        reflectionEquals.assertEquals(observedTargets, result);
    }

    @Test
    public void testRetrieveObservedTargetsModOut() throws Exception {
        populateObjects();

        List<ObservedTarget> result = targetCrud.retrieveObservedTargetsPlusRejected(
            targetTable, CCD_MODULE, CCD_OUTPUT);

        reflectionEquals.assertEquals(observedTargets, result);
    }

    @Test
    public void testRetrieveObservedTargetsKeplerIds() throws Exception {
        populateObjects();

        List<Integer> keplerIds = ImmutableList.of(KEPLER_ID);

        List<ObservedTarget> result = targetCrud.retrieveObservedTargets(
            targetTable, keplerIds);

        reflectionEquals.assertEquals(observedTargets, result);
    }

    @Test
    public void testRetrieveMasks() throws Exception {
        populateObjects();

        List<Mask> result = targetCrud.retrieveMasks(maskTable);

        reflectionEquals.assertEquals(masks, result);
    }

    @Test
    public void testRetrieveImage() throws Exception {
        populateObjects();

        Image actualImage = targetCrud.retrieveImage(targetTable, CCD_MODULE,
            CCD_OUTPUT);

        assertEquals(targetTable, actualImage.getTargetTable());
        assertEquals(CCD_MODULE, actualImage.getCcdModule());
        assertEquals(CCD_OUTPUT, actualImage.getCcdOutput());
    }

    @Test
    public void testRetrieveKtcInfo() throws Exception {
        populateObjects();

        List<KtcInfo> targets = targetCrud.retrieveKtcInfo(START, END);
        Iterator<KtcInfo> it = targets.iterator();
        assertTrue(it.hasNext());

        KtcInfo ktcInfo = it.next();
        ObservedTarget ot = observedTargets.get(0);
        assertEquals(ot.getKeplerId(), ktcInfo.keplerId);
        assertEquals(ot.getTargetTable()
            .getType(), ktcInfo.type);
        assertEquals(START.getTime(), ktcInfo.start.getTime());
        assertEquals(END.getTime(), ktcInfo.end.getTime());
        assertEquals(1L, ktcInfo.targetId);
    }

    @Test
    public void testRetrieveKtcOrderedTargetTable() throws Exception {
        populateObjects();

        List<Integer> ids = targetCrud.retrieveOrderedExternalIds(TargetType.LONG_CADENCE);
        assertEquals(1, ids.size());
        assertEquals(1, (int) ids.get(0));

    }

    @Test
    public void testRetrieveObservedTargetCategories() throws Exception {
        populateObjects();

        long observedTargetDbId = observedTargets.get(0)
            .getId();
        List<String> categories = targetCrud.retrieveCategoriesForTarget(
            observedTargetDbId, 1);

        assertEquals(2, categories.size());

        Set<String> catSet = ImmutableSet.copyOf(categories);
        assertTrue(catSet.contains(FIND_CATEGORY_1));
        assertTrue(catSet.contains(FIND_CATEGORY_2));
    }

    @Test
    public void testRetrieveAllTargetCategories() throws Exception {

        populateObjects();

        Map<Long, List<String>> targetToCategories = targetCrud.retrieveCategoriesForTargetTable(targetTable);
        assertEquals(1, targetToCategories.size());
        List<String> categories = targetToCategories.get(observedTargets.get(0)
            .getId());
        assertEquals(2, categories.size());
        assertTrue(categories.contains(FIND_CATEGORY_1));
        assertTrue(categories.contains(FIND_CATEGORY_2));
    }

    @Test
    public void testRetrieveObservedTargetLabels() throws Exception {
        populateObjects();

        long observedTargetDbId = observedTargets.get(0)
            .getId();
        List<String> labels = targetCrud.retrieveLabelsForObservedTarget(observedTargetDbId);
        Set<String> expectedLabels = observedTargets.get(0)
            .getLabels();
        List<String> expectedLabelsList = ImmutableList.copyOf(expectedLabels);
        assertEquals(expectedLabelsList, labels);
    }

    @Test
    public void testDeleteSupermasks() {
        MaskTable maskTable = new MaskTable(MaskType.TARGET);
        try {
            databaseService.beginTransaction();
            List<Offset> offsets = ImmutableList.of();
            Mask regularMask = new Mask(maskTable, offsets);
            Mask superMask = new Mask(maskTable, offsets);
            superMask.setSupermask(true);
            List<Mask> masks = ImmutableList.of(regularMask, superMask);
            targetCrud.createMaskTable(maskTable);
            targetCrud.createMasks(masks);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(2, targetCrud.retrieveMasks(maskTable)
            .size());

        try {
            databaseService.beginTransaction();
            targetCrud.deleteSupermasks(maskTable);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(1, targetCrud.retrieveMasks(maskTable)
            .size());
    }

    public void testUpdateOffsets() {
        List<Offset> expectedInputOffsets = ImmutableList.of(new Offset(0, 0));
        List<Offset> expectedOutputOffsets = ImmutableList.of(new Offset(1, 1),
            new Offset(2, 2));

        try {
            databaseService.beginTransaction();
            MaskTable maskTable = new MaskTable(MaskType.TARGET);
            Mask inputMask = new Mask(maskTable, expectedInputOffsets);
            List<Mask> masks = ImmutableList.of(inputMask);
            targetCrud.createMaskTable(maskTable);
            targetCrud.createMasks(masks);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(expectedInputOffsets, targetCrud.retrieveMasks(maskTable)
            .get(0)
            .getOffsets());

        try {
            databaseService.beginTransaction();
            targetCrud.retrieveMasks(maskTable)
                .get(0)
                .setOffsets(expectedOutputOffsets);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(expectedOutputOffsets, targetCrud.retrieveMasks(maskTable)
            .get(0)
            .getOffsets());
    }

    @Test
    public void testRetrieveObservedTargetsWithSupplementalTlsConfigured() {
        populateObjects();
        populateSupplementalObjects();

        List<ObservedTarget> actualObservedTargets = targetCrud.retrieveObservedTargets(targetTable);

        assertTrue(observedTargets.get(0)
            .getId() != 0);
        assertEquals(observedTargets.get(0)
            .getId(), actualObservedTargets.get(0)
            .getId());

        assertTrue(suppObservedTarget.getId() != 0);
        assertEquals(suppObservedTarget.getId(), actualObservedTargets.get(0)
            .getSupplementalObservedTarget()
            .getId());
    }

    @Test
    public void testRetrieveObservedTargetsWithSupplementalTlsConfiguredAndIgnoringSupplemental() {
        populateObjects();
        populateSupplementalObjects();

        List<ObservedTarget> actualObservedTargets = targetCrud.retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            targetTable, CCD_MODULE, CCD_OUTPUT, true);

        assertTrue(observedTargets.get(0)
            .getId() != 0);
        assertEquals(observedTargets.get(0)
            .getId(), actualObservedTargets.get(0)
            .getId());

        assertTrue(suppObservedTarget.getId() != 0);
        assertEquals(null, actualObservedTargets.get(0)
            .getSupplementalObservedTarget());
    }

    @Test
    public void testRetrieveImageWithSupplementalTlsConfigured() {
        populateObjects();
        populateSupplementalObjects();

        Image actualImage = targetCrud.retrieveImage(targetTable, CCD_MODULE,
            CCD_OUTPUT);

        assertEquals(targetTable, actualImage.getTargetTable());
        assertEquals(CCD_MODULE, actualImage.getCcdModule());
        assertEquals(CCD_OUTPUT, actualImage.getCcdOutput());
        assertNotNull(actualImage.getSupplementalImage());
    }

    @Test
    public void testRetrieveCrowdingMetricInfoWithSupplementalTlsConfigured()
        throws IllegalAccessException {
        populateObjects();
        populateSupplementalObjects();

        List<TargetTable> targetTables = ImmutableList.of(targetTable);

        Map<Integer, TargetCrowdingInfo> actualCrowdingMetricInfo = targetCrud.retrieveCrowdingMetricInfo(
            targetTables, SKY_GROUP_ID);

        Map<Integer, TargetCrowdingInfo> expectedCrowdingMetricInfo = ImmutableMap.of(
            KEPLER_ID, new TargetCrowdingInfo(KEPLER_ID,
                new Double[] { SUPP_CROWDING_METRIC },
                new Integer[] { CCD_MODULE }, new Integer[] { CCD_OUTPUT }));

        reflectionEquals.assertEquals(expectedCrowdingMetricInfo,
            actualCrowdingMetricInfo);
        assertTrue(Arrays.equals(expectedCrowdingMetricInfo.get(KEPLER_ID)
            .getGapIndicators(), expectedCrowdingMetricInfo.get(KEPLER_ID)
            .getGapIndicators()));
    }

    @Test
    public void testRetrieveCrowdingMetricsForTargetTablesWithTwoKeplerIds()
        throws IllegalAccessException {
        populateObjects();
        populateMoreObjects();

        int secondKeplerId = 42456;
        double secondCrowdingMetric = 424561;

        try {
            databaseService.beginTransaction();
            ObservedTarget observedTarget = new ObservedTarget(targetTable,
                CCD_MODULE, CCD_OUTPUT, secondKeplerId);
            observedTarget.setCrowdingMetric(secondCrowdingMetric);
            observedTarget.setAperture(new Aperture());
            targetCrud.createObservedTarget(observedTarget);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.clear();

        List<TargetTable> targetTables = ImmutableList.of(targetTable);

        Map<Integer, TargetCrowdingInfo> actualCrowdingMetricInfo = targetCrud.retrieveCrowdingMetricInfo(
            targetTables, SKY_GROUP_ID);

        Map<Integer, TargetCrowdingInfo> expectedCrowdingMetricInfo = ImmutableMap.of(
            KEPLER_ID, new TargetCrowdingInfo(KEPLER_ID,
                new Double[] { CROWDING_METRIC }, new Integer[] { CCD_MODULE },
                new Integer[] { CCD_OUTPUT }), secondKeplerId,
            new TargetCrowdingInfo(secondKeplerId,
                new Double[] { secondCrowdingMetric },
                new Integer[] { CCD_MODULE }, new Integer[] { CCD_OUTPUT }));

        reflectionEquals.assertEquals(expectedCrowdingMetricInfo,
            actualCrowdingMetricInfo);
    }

    @Test
    public void testRetrieveObservedTargetsWithNoApertureAndNoSupplementalTlsConfigured() {
        populateObjects();

        try {
            databaseService.beginTransaction();
            targetCrud.retrieveObservedTargets(targetTable)
                .get(0)
                .setAperture(null);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<ObservedTarget> actualObservedTargets = targetCrud.retrieveObservedTargets(targetTable);

        assertEquals(ImmutableList.of(), actualObservedTargets);
    }

    @Test
    public void testRetrieveObservedTargetsWithNoApertureAndNoSupplementalTlsConfiguredAndIsRejected() {
        populateObjects();

        ObservedTarget observedTarget = null;
        try {
            databaseService.beginTransaction();
            observedTarget = targetCrud.retrieveObservedTargets(targetTable)
                .get(0);
            observedTarget.setAperture(null);
            observedTarget.setRejected(true);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(null, observedTarget.getAperture());
    }

    @Test
    public void testRetrieveAllTargetDefinitionsInOrder() {
        populateObjects();

        // Create new targetDefs in the wrong order.
        TargetDefinition targetDefinition1 = null;
        TargetDefinition targetDefinition2 = null;
        TargetDefinition targetDefinition3 = null;
        TargetDefinition targetDefinition4 = null;
        try {
            databaseService.beginTransaction();
            targetTable = new TargetTable(TargetType.LONG_CADENCE);
            targetCrud.createTargetTable(targetTable);

            targetDefinition1 = createTargetDefinitionInstance(targetTable, 2,
                1, 0);
            targetDefinition2 = createTargetDefinitionInstance(targetTable, 2,
                1, 1);
            targetDefinition3 = createTargetDefinitionInstance(targetTable, 2,
                2, 0);
            targetDefinition4 = createTargetDefinitionInstance(targetTable, 3,
                1, 0);

            ObservedTarget observedTarget = new ObservedTarget(targetTable, 0,
                0, 0);
            observedTarget.setTargetDefinitions(ImmutableList.of(
                targetDefinition4, targetDefinition3, targetDefinition2,
                targetDefinition1));
            targetCrud.createObservedTarget(observedTarget);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        // Verify targetDefs are retrieved in the correct order.
        try {
            databaseService.beginTransaction();
            List<TargetDefinition> actualTargetDefinitions = targetCrud.retrieveTargetDefinitions(targetTable);
            assertEquals(ImmutableList.of(targetDefinition1, targetDefinition2,
                targetDefinition3, targetDefinition4), actualTargetDefinitions);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    @Test
    public void testUnifiedObservedTarget() throws Exception {
        populateObjects();
        populateSupplementalObjects();
        populateDroppedTarget();

        List<Integer> allKeplerIds = ImmutableList.of(KEPLER_ID,
            DROPPED_KEPLER_ID);

        UnifiedObservedTargetCrud uCrud = new UnifiedObservedTargetCrud();
        Map<Integer, UnifiedObservedTarget> targets = uCrud.retrieveUnifiedObservedTargets(
            targetTable, CCD_MODULE, CCD_OUTPUT, allKeplerIds);
        assertEquals(2, targets.size());

        ObservedTarget origObservedTarget = observedTargets.get(0);
        UnifiedObservedTarget okTarget = targets.get(KEPLER_ID);
        assertEquals(suppObservedTarget.getAperture(), okTarget.getAperture());
        assertEquals(suppObservedTarget.getCcdModule(), okTarget.getCcdModule());
        assertEquals(suppObservedTarget.getCcdOutput(), okTarget.getCcdOutput());
        assertEquals(suppObservedTarget.getKeplerId(), okTarget.getKeplerId());
        assertEquals(origObservedTarget.getLabels(), okTarget.getLabels());
        assertEquals(suppObservedTarget.getCrowdingMetric(),
            okTarget.getCrowdingMetric(), 0.0);
        assertEquals(suppObservedTarget.getFluxFractionInAperture(),
            okTarget.getFluxFractionInAperture(), 0.0);
        Set<TargetDefinition> tdefs = new HashSet<TargetDefinition>(
            origObservedTarget.getTargetDefinitions());
        assertEquals(tdefs, okTarget.getTargetDefinitions());
        assertEquals(0, okTarget.getClippedPixelCount());
        assertFalse(okTarget.wasDroppedBySupplementalTad());

        ObservedTarget droppedTarget = droppedObservedTargets.get(0);
        UnifiedObservedTarget droppedUTarget = targets.get(DROPPED_KEPLER_ID);
        assertEquals(new Aperture(), droppedUTarget.getAperture());
        assertEquals(CCD_MODULE, droppedUTarget.getCcdModule());
        assertEquals(CCD_OUTPUT, droppedUTarget.getCcdOutput());
        assertEquals(DROPPED_KEPLER_ID, droppedUTarget.getKeplerId());
        assertEquals(droppedTarget.getLabels(), droppedUTarget.getLabels());
        assertEquals(droppedTarget.getCrowdingMetric(),
            droppedUTarget.getCrowdingMetric(), 0.0);
        assertEquals(droppedTarget.getFluxFractionInAperture(),
            droppedUTarget.getFluxFractionInAperture(), 0.0);
        tdefs = new HashSet<TargetDefinition>(
            droppedTarget.getTargetDefinitions());
        assertEquals(tdefs, droppedUTarget.getTargetDefinitions());
        // This is probably wrong, but this is the same behavior as the
        // old getClippedPixelCount().
        assertEquals(0, droppedUTarget.getClippedPixelCount());
        assertTrue(droppedUTarget.wasDroppedBySupplementalTad());

        List<Integer> uKeplerIds = uCrud.retrieveKeplerIds(targetTable,
            CCD_MODULE, CCD_OUTPUT, 0, Integer.MAX_VALUE);
        assertEquals(ImmutableList.of(DROPPED_KEPLER_ID, KEPLER_ID), uKeplerIds);
    }

    @Test
    public void testUnifiedObservedTargetWithoutSupplemental() {
        populateObjects();

        UnifiedObservedTargetCrud uCrud = new UnifiedObservedTargetCrud();

        Map<Integer, UnifiedObservedTarget> uTargets = uCrud.retrieveUnifiedObservedTargets(
            targetTable, CCD_MODULE, CCD_OUTPUT, ImmutableList.of(KEPLER_ID));

        ObservedTarget srcTarget = observedTargets.get(0);

        UnifiedObservedTarget actual = uTargets.get(KEPLER_ID);
        assertEquals(1, uTargets.size());
        assertEquals(srcTarget.getKeplerId(), actual.getKeplerId());
        assertEquals(srcTarget.getAperture()
            .getOffsets(), actual.getAperture()
            .getOffsets());
        assertEquals(srcTarget.getAperture()
            .getReferenceColumn(), actual.getAperture()
            .getReferenceColumn());
        assertEquals(srcTarget.getAperture()
            .getReferenceRow(), actual.getAperture()
            .getReferenceRow());
        assertEquals(CCD_MODULE, actual.getCcdModule());
        assertEquals(CCD_OUTPUT, actual.getCcdOutput());
        assertEquals(0, actual.getClippedPixelCount());
        assertEquals(srcTarget.getFluxFractionInAperture(),
            actual.getFluxFractionInAperture(), 0.0);
        assertEquals(srcTarget.getCrowdingMetric(), actual.getCrowdingMetric(),
            0.0);
        assertEquals(srcTarget.getLabels(), actual.getLabels());
        assertEquals(srcTarget.getPipelineTask()
            .getId(), actual.getPipelineTask()
            .getId());

        assertEquals(
            new HashSet<TargetDefinition>(srcTarget.getTargetDefinitions()),
            new HashSet<TargetDefinition>(actual.getTargetDefinitions()));
        assertFalse(actual.wasDroppedBySupplementalTad());

    }

    @Test
    public void testRetrieveTargetTableTypeExternalId() {
        populateObjects();

        TargetCrud targetCrud = new TargetCrud();
        TargetTable ttable = targetCrud.retrieveTargetTable(
            TargetType.LONG_CADENCE, 1);
        assertEquals(1, ttable.getExternalId());
        assertEquals(State.UPLINKED, ttable.getState());
        assertEquals(TargetType.LONG_CADENCE, ttable.getType());
    }

    private TargetDefinition createTargetDefinitionInstance(
        TargetTable targetTable, int ccdModule, int ccdOutput,
        int indexInModuleOutput) {
        TargetDefinition targetDefinition = new TargetDefinition();
        targetDefinition.setTargetTable(targetTable);
        targetDefinition.setCcdModule(ccdModule);
        targetDefinition.setCcdOutput(ccdOutput);
        targetDefinition.setIndexInModuleOutput(indexInModuleOutput);

        return targetDefinition;
    }

}
