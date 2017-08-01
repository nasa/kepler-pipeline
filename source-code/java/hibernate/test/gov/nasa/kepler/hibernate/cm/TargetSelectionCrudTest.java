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

package gov.nasa.kepler.hibernate.cm;

import static gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel.TAD_ADD_UNDERSHOOT_COLUMN;
import static gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel.TAD_ONE_HALO;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.cm.TargetList.SourceType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.exception.ConstraintViolationException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link TargetSelectionCrud} class.
 * 
 * @author Bill Wohler
 */
public class TargetSelectionCrudTest {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TargetSelectionCrudTest.class);

    private static final int PLANNED_TARGET_BATCH_SIZE = 20;
    private static final String PLANET_DETECTION_TARGET_LIST = "Planet Detection Targets";
    private static final String PSP_TARGET_LIST = "PSP Targets";

    private KicCrud kicCrud = new KicCrud();
    private TargetCrud targetCrud = new TargetCrud();
    private TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

    private DatabaseService databaseService;

    private TargetList planetDetectionTargetList;
    private TargetList pspTargetList;
    private TargetList pdqTargetList;
    private TargetList goTargetList;
    private TargetList ppaTargetList;
    private TargetList unusedTargetList;
    private ArrayList<TargetList> allTargetLists;

    private TargetListSet longCadenceTargetListSet;
    private TargetListSet shortCadenceTargetListSet;
    private TargetListSet referencePixelTargetListSet;
    private ArrayList<TargetListSet> allTargetListSets;

    private List<Kic> kics;
    private List<PlannedTarget> planetDetectionPlannedTargets;
    private List<PlannedTarget> pspPlannedTargets;
    private int plannedTargetStartingId;

    @Before
    public void setUp() throws Exception {
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        plannedTargetStartingId = 0;
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    // SOC_REQ_IMPL 171.CM.5
    // SOC_REQ_IMPL SOC209
    @Test
    public void testRetrieveAllTargetLists() {
        assertEquals(Collections.EMPTY_LIST,
            targetSelectionCrud.retrieveAllTargetLists());
        populateObjects();

        List<TargetList> targetList = targetSelectionCrud.retrieveAllTargetLists();
        assertEquals(allTargetLists.size(), targetList.size());
        testTargetList(targetList.get(0));
    }

    @Test
    public void testRetrieveTargetListsForUplinkedTargetTables() {
        populateObjects();

        List<TargetList> targetLists = targetSelectionCrud.retrieveTargetListsForUplinkedTargetTables();

        assertEquals(1, targetLists.size());
        assertEquals(pspTargetList, targetLists.get(0));
    }

    @Test
    public void testRetrieveTargetListSetsByNames() throws Exception {
        populateObjects();

        List<String> names = Arrays.asList(new String[] {
            longCadenceTargetListSet.getName(),
            referencePixelTargetListSet.getName() });

        List<TargetListSet> listSets = targetSelectionCrud.retrieveTargetListSets(
            names, TargetTable.TargetType.LONG_CADENCE);
        assertEquals(1, listSets.size());
        assertEquals(longCadenceTargetListSet, listSets.get(0));
    }

    @Test
    public void testRetrieveTargetListKeplerIds() {
        populateObjects();

        List<String> targetListNames = Collections.singletonList(planetDetectionTargetList.getName());
        List<Integer> keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            targetListNames, 0, Integer.MAX_VALUE);
        assertEquals(PLANNED_TARGET_BATCH_SIZE, keplerIds.size());

        targetListNames = Collections.singletonList(pspTargetList.getName());
        keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            targetListNames, 0, Integer.MAX_VALUE);

        int listIndex = 0;
        for (int i = plannedTargetStartingId; i < plannedTargetStartingId
            + PLANNED_TARGET_BATCH_SIZE; i++) {
            assertEquals(i, (int) keplerIds.get(listIndex++));
        }
    }

    @Test
    public void testRetrieveTargetListKeplerIdsWithKeyGroupRestriction() {
        populateObjects();
        List<String> targetListNames = Collections.singletonList(pspTargetList.getName());
        List<Integer> keplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListName(
            targetListNames, 0, 0, Integer.MAX_VALUE);
        assertTrue(keplerIds.size() > 0);
        for (int i = 0; i < plannedTargetStartingId + PLANNED_TARGET_BATCH_SIZE; i++) {
            int skyGroupId = i % 2;
            if (skyGroupId == 0) {
                assertEquals(i, (int) keplerIds.get(i / 2));
            }
        }
    }

    @Test
    public void testTargetListCount() {
        assertEquals(0, targetSelectionCrud.targetListCount());

        populateObjects();

        assertEquals(allTargetLists.size(),
            targetSelectionCrud.targetListCount());
    }

    @Test
    public void testDeleteTargetList() {
        populateObjects();

        assertEquals(allTargetLists.size(),
            targetSelectionCrud.targetListCount());
        databaseService.beginTransaction();
        targetSelectionCrud.delete(unusedTargetList);
        databaseService.commitTransaction();
        assertEquals(allTargetLists.size() - 1,
            targetSelectionCrud.targetListCount());
    }

    // SOC_REQ_IMPL 171.CM.6
    // SOC_REQ_IMPL 172.CM.1
    // SOC_REQ_IMPL 173.CM.1
    // SOC_REQ_IMPL 926.CM.2
    // SOC_REQ_IMPL 926.CM.4
    @Test
    public void testRetrievePlannedTargets() {
        populateObjects();

        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(planetDetectionTargetList);
        testPlannedTargets(targets, plannedTargetStartingId);
    }

    @Test
    public void testRetrievePlannedTargetsByTargetListAndSkyGroupId() {
        populateObjects();

        int skyGroupId = 1;
        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(
            planetDetectionTargetList, skyGroupId);

        assertEquals(planetDetectionPlannedTargets.get(1), targets.get(0));
    }

    @Test
    public void testRetrievePlannedTargetsWithArbitraryKeplerIds() {
        populateObjects();

        Map<Integer, List<PlannedTarget>> targetsByKeplerId = targetSelectionCrud.retrievePlannedTargets(new HashSet<Integer>(
            Arrays.asList(plannedTargetStartingId - 1, plannedTargetStartingId,
                plannedTargetStartingId + 1)));

        assertEquals(2, targetsByKeplerId.size());
        assertNull(targetsByKeplerId.get(plannedTargetStartingId - 1));

        testPlannedTargets(
            planetDetectionPlannedTargets.get(plannedTargetStartingId),
            pspPlannedTargets.get(plannedTargetStartingId),
            plannedTargetStartingId,
            targetsByKeplerId.get(plannedTargetStartingId));

        testPlannedTargets(
            planetDetectionPlannedTargets.get(plannedTargetStartingId + 1),
            pspPlannedTargets.get(plannedTargetStartingId + 1),
            plannedTargetStartingId + 1,
            targetsByKeplerId.get(plannedTargetStartingId + 1));
    }

    private void testPlannedTargets(PlannedTarget target1,
        PlannedTarget target2, int keplerId, List<PlannedTarget> actualTargets) {

        assertEquals(2, actualTargets.size());

        boolean foundTarget1 = false;
        boolean foundTarget2 = false;

        for (PlannedTarget target : actualTargets) {
            if (!foundTarget1 && target.equals(target1)
                && target.getTargetList()
                    .equals(target1.getTargetList())) {
                foundTarget1 = true;
                continue;
            }
            if (!foundTarget2 && target.equals(target2)
                && target.getTargetList()
                    .equals(target2.getTargetList())) {
                foundTarget2 = true;
                continue;
            }
        }
        assertTrue(foundTarget1);
        assertTrue(foundTarget2);
    }

    @Test
    public void testRetrieveRejectedPlannedTargets() throws Exception {
        populateObjects();

        // Create rejected observedTargets.
        databaseService.beginTransaction();

        TargetTable targetTable = new TargetTable(TargetType.LONG_CADENCE);
        longCadenceTargetListSet.setTargetTable(targetTable);

        List<ObservedTarget> observedTargets = new ArrayList<ObservedTarget>();
        for (PlannedTarget plannedTarget : planetDetectionPlannedTargets) {
            ObservedTarget observedTarget = new ObservedTarget(targetTable, 2,
                1, plannedTarget.getKeplerId());
            observedTarget.setRejected(true);
            observedTargets.add(observedTarget);
        }

        targetCrud.createTargetTable(targetTable);
        targetCrud.createObservedTargets(observedTargets);

        databaseService.commitTransaction();

        List<PlannedTarget> targets = targetSelectionCrud.retrieveRejectedPlannedTargets(longCadenceTargetListSet);

        assertEquals(planetDetectionPlannedTargets.size(), targets.size());
        for (int i = 0; i < planetDetectionPlannedTargets.size(); i++) {
            assertEquals(planetDetectionPlannedTargets.get(i), targets.get(i));
        }
    }

    @Test
    public void testRetrievePlannedTargetsOneLabel() {
        populateObjects();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { TAD_ONE_HALO.toString() }),
            Collections.EMPTY_LIST);
        assertEquals(pspPlannedTargets, targets);
    }

    @Test
    public void testRetrievePlannedTargetsTwoLabels() {
        populateObjects();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { TAD_ONE_HALO.toString(),
                TAD_ADD_UNDERSHOOT_COLUMN.toString() }), Collections.EMPTY_LIST);
        assertEquals(pspPlannedTargets, targets);
    }

    @SuppressWarnings("unchecked")
    @Test(expected = IllegalArgumentException.class)
    public void testRetrievePlannedTargetsBadTlsName() {
        populateObjects();

        targetSelectionCrud.retrievePlannedTargets(
            "foo",
            Arrays.asList(new String[] { TAD_ONE_HALO.toString(),
                TAD_ADD_UNDERSHOOT_COLUMN.toString() }), Collections.EMPTY_LIST);
    }

    @Test
    public void testRetrievePlannedTargetsTwoLabelsOnTarget() {
        populateObjects();

        // Put two labels on the planned target.
        try {
            databaseService.beginTransaction();
            List<PlannedTarget> plannedTargets = targetSelectionCrud.retrievePlannedTargets(planetDetectionTargetList);
            for (PlannedTarget plannedTarget : plannedTargets) {
                plannedTarget.addLabel(TAD_ADD_UNDERSHOOT_COLUMN);
            }
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { TAD_ONE_HALO.toString(),
                TAD_ADD_UNDERSHOOT_COLUMN.toString() }), Collections.EMPTY_LIST);
        assertEquals(pspPlannedTargets, targets);
    }

    @Test
    public void testRetrievePlannedTargetsWithExclusionLists() {
        populateObjects();

        // Add an exclude target.
        databaseService.beginTransaction();

        TargetList excludeList = new TargetList("exclude.txt");
        excludeList.setCategory("exclude.txt");
        targetSelectionCrud.create(excludeList);

        PlannedTarget excludeTarget = new PlannedTarget(excludeList);
        excludeTarget.addLabel(TAD_ONE_HALO);
        pspPlannedTargets.add(excludeTarget);

        List<PlannedTarget> excludedTargets = Arrays.asList(new PlannedTarget[] { excludeTarget });
        targetSelectionCrud.create(excludedTargets);

        shortCadenceTargetListSet.getExcludedTargetLists()
            .add(excludeList);
        databaseService.getSession()
            .update(shortCadenceTargetListSet);

        databaseService.commitTransaction();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { TAD_ONE_HALO.toString(),
                TAD_ADD_UNDERSHOOT_COLUMN.toString() }), Collections.EMPTY_LIST);
        assertEquals(pspPlannedTargets, actualPlannedTargets);
    }

    @Test
    public void testRetrievePlannedTargetsEmptyLabelsEmptyCategories() {
        populateObjects();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(), Collections.EMPTY_LIST,
            Collections.EMPTY_LIST);
        assertEquals(pspPlannedTargets, actualPlannedTargets);
    }

    @Test
    public void testRetrievePlannedTargetsOneCategory() {
        populateObjects();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(), Collections.EMPTY_LIST,
            Arrays.asList(new String[] { PSP_TARGET_LIST }));
        assertEquals(pspPlannedTargets, actualPlannedTargets);
    }

    @Test
    public void testRetrievePlannedTargetsOneLabelOneCategory() {
        populateObjects();

        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { TAD_ONE_HALO.toString() }),
            Arrays.asList(new String[] { PSP_TARGET_LIST }));
        assertEquals(pspPlannedTargets, actualPlannedTargets);
    }

    @Test
    public void testRetrievePlannedTargetsTadLabels() {
        populateObjects();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { "TAD" }), Collections.EMPTY_LIST, true);
        assertEquals(pspPlannedTargets, actualPlannedTargets);
    }

    @Test
    public void testRetrievePlannedTargetsHaloLabels() {
        populateObjects();

        @SuppressWarnings("unchecked")
        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(
            TargetType.SHORT_CADENCE.toString(),
            Arrays.asList(new String[] { "HALO" }), Collections.EMPTY_LIST,
            true);
        assertEquals(pspPlannedTargets, actualPlannedTargets);
    }

    @Test
    public void testPlannedTargetCount() {
        populateObjects();

        assertEquals(PLANNED_TARGET_BATCH_SIZE,
            targetSelectionCrud.plannedTargetCount(planetDetectionTargetList));
    }

    @Test
    public void testDeletePlannedTargets() {
        populateObjects();

        assertEquals(PLANNED_TARGET_BATCH_SIZE,
            targetSelectionCrud.plannedTargetCount(planetDetectionTargetList));
        databaseService.beginTransaction();
        targetSelectionCrud.deletePlannedTargets(planetDetectionTargetList);
        databaseService.commitTransaction();
        assertEquals(0,
            targetSelectionCrud.plannedTargetCount(planetDetectionTargetList));
    }

    @Test(expected = ConstraintViolationException.class)
    public void testCreateTargetListSetWithDups() {
        populateObjects();
        populateObjects();
    }

    @Test
    public void testRetrieveTargetListSet() {
        TargetListSet targetListSet = targetSelectionCrud.retrieveTargetListSet("Not in database");
        assertNull(targetListSet);

        populateObjects();

        targetListSet = targetSelectionCrud.retrieveTargetListSet(longCadenceTargetListSet.getName());
        testTargetListSet(targetListSet);
    }

    @Test
    public void testRetrieveTargetListSets() {
        TargetListSet unlockedSet = new TargetListSet("unlocked");
        TargetListSet lockedSet = new TargetListSet("locked");
        lockedSet.setState(State.LOCKED);
        TargetListSet uplinkedSet = new TargetListSet("uplinked");
        uplinkedSet.setState(State.UPLINKED);
        targetSelectionCrud.create(unlockedSet);
        targetSelectionCrud.create(lockedSet);
        targetSelectionCrud.create(uplinkedSet);
        databaseService.closeCurrentSession();

        List<TargetListSet> targetListSets = targetSelectionCrud.retrieveTargetListSets(State.LOCKED);
        assertEquals(1, targetListSets.size());
        assertEquals(lockedSet, targetListSets.get(0));

        targetListSets = targetSelectionCrud.retrieveTargetListSets(
            State.LOCKED, State.UPLINKED);
        assertEquals(2, targetListSets.size());
        for (TargetListSet targetListSet : targetListSets) {
            if (targetListSet.equals(unlockedSet)) {
                unlockedSet = null;
            } else if (targetListSet.equals(lockedSet)) {
                lockedSet = null;
            } else if (targetListSet.equals(uplinkedSet)) {
                uplinkedSet = null;
            }
        }
        assertNotNull("Should not have returned unlocked set", unlockedSet);
        assertNull("Should have returned locked set", lockedSet);
        assertNull("Should have returned uplinked set", uplinkedSet);
    }

    @Test
    public void testRetrieveTargetListSetsWithMask() {
        MaskTable maskTable = new MaskTable(MaskType.TARGET);

        TargetTable targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setMaskTable(maskTable);

        TargetListSet targetListSet = new TargetListSet("set1");
        targetListSet.setTargetTable(targetTable);

        targetCrud.createMaskTable(maskTable);
        targetCrud.createTargetTable(targetTable);
        targetSelectionCrud.create(targetListSet);
        databaseService.closeCurrentSession();

        List<TargetListSet> result = targetSelectionCrud.retrieveTargetListSets(maskTable);
        assertEquals(targetListSet, result.get(0));
    }

    // SOC_REQ_IMPL 680.CM.1
    @Test
    public void referencePixelTest() {
        assert TargetType.REFERENCE_PIXEL != null;
    }

    // SOC_REQ 171.CM.1: J.testRetrieveAllTargetListSets
    // SOC_REQ_IMPL 171.CM.2
    // SOC_REQ_IMPL SOC207
    // SOC_REQ_IMPL SOC208
    // SOC_REQ_IMPL 684.CM.1
    // SOC_REQ_IMPL 684.CM.2
    // SOC_REQ_IMPL 684.CM.3
    // SOC_REQ_IMPL 1055.CM.1
    // SOC_REQ_IMPL 1072.CM.1
    @Test
    public void testRetrieveAllTargetListSets() {
        assertEquals(Collections.EMPTY_LIST,
            targetSelectionCrud.retrieveAllTargetListSets());

        populateObjects();

        List<TargetListSet> targetListSet = targetSelectionCrud.retrieveAllTargetListSets();
        testTargetListSet(targetListSet.get(0));
    }

    @Test
    public void testTargetListSetCount() {
        assertEquals(0, targetSelectionCrud.targetListSetCount());

        populateObjects();

        assertEquals(allTargetListSets.size(),
            targetSelectionCrud.targetListSetCount());
    }

    @Test
    public void testDeleteTargetListSet() {
        populateObjects();

        assertEquals(allTargetListSets.size(),
            targetSelectionCrud.targetListSetCount());
        assertEquals(allTargetLists.size(),
            targetSelectionCrud.targetListCount());
        databaseService.beginTransaction();
        targetSelectionCrud.delete(longCadenceTargetListSet);
        databaseService.commitTransaction();
        assertEquals(allTargetListSets.size() - 1,
            targetSelectionCrud.targetListSetCount());
        assertEquals(allTargetLists.size(),
            targetSelectionCrud.targetListCount());
    }

    /**
     * Test that this can retrieve KeplerIds associated with target lists over
     * multiple quarters.
     */
    @Test
    public void multiQuarterRetrieveKeplerIdsForTargetList() throws Exception {

        databaseService.beginTransaction();
        // log.debug(ConfigurationServiceFactory.getInstance()
        // .getString("hibernate.connection.url"));

        TargetList q1TargetList = createTargetList("Q1");
        targetSelectionCrud.create(q1TargetList);
        TargetList q2TargetList = createTargetList("Q2");
        targetSelectionCrud.create(q2TargetList);

        List<Kic> kics = createKics(1, 10);
        assertTrue(kics.size() >= 3);
        kicCrud.create(kics);
        List<Kic> kicsInQ1 = new LinkedList<Kic>(kics);
        Kic notInQ1 = kicsInQ1.remove(0);
        List<Kic> kicsInQ2 = new ArrayList<Kic>(kics);
        kicsInQ2.remove(kicsInQ2.size() - 1);

        targetSelectionCrud.create(createPlannedTargets(kicsInQ1, q1TargetList));
        targetSelectionCrud.create(createPlannedTargets(kicsInQ2, q2TargetList));

        TargetListSet tlsetQ1 = new TargetListSet("Q1-tlset");
        targetSelectionCrud.create(tlsetQ1);
        tlsetQ1.setTargetLists(Collections.singletonList(q1TargetList));
        TargetTable ttableQ1 = new TargetTable(TargetType.LONG_CADENCE);
        targetCrud.createTargetTable(ttableQ1);
        tlsetQ1.setTargetTable(ttableQ1);
        ttableQ1.setState(State.UPLINKED);
        ttableQ1.setExternalId(1);

        TargetListSet tlsetQ2 = new TargetListSet("Q2-tlset");
        targetSelectionCrud.create(tlsetQ2);
        tlsetQ2.setTargetLists(Collections.singletonList(q2TargetList));
        TargetTable ttableQ2 = new TargetTable(TargetType.LONG_CADENCE);
        targetCrud.createTargetTable(ttableQ2);
        tlsetQ2.setTargetTable(ttableQ2);
        ttableQ2.setState(State.UPLINKED);
        ttableQ2.setExternalId(2);

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<String> targetListNames = Arrays.asList(new String[] { "Q1", "Q2" });
        List<Integer> retrievedKeplerIds = targetSelectionCrud.retrieveKeplerIdsForTargetListName(targetListNames);
        List<Integer> expected = Arrays.asList(new Integer[] { 1, 2, 3, 4, 5,
            6, 7, 8, 9 });
        assertEquals(expected, retrievedKeplerIds);

        List<Integer> justQ1 = targetSelectionCrud.retrieveKeplerIdsForTargetListName(Collections.singletonList("Q1"));
        List<Integer> q1Expected = Arrays.asList(new Integer[] { 2, 3, 4, 5, 6,
            7, 8, 9 });
        assertEquals(q1Expected, justQ1);
        assertFalse(justQ1.contains(notInQ1));

    }

    private void populateObjects() {

        try {
            databaseService.beginTransaction();

            allTargetLists = new ArrayList<TargetList>();
            planetDetectionTargetList = createTargetList(PLANET_DETECTION_TARGET_LIST);
            targetSelectionCrud.create(planetDetectionTargetList);
            allTargetLists.add(planetDetectionTargetList);
            pspTargetList = createTargetList(PSP_TARGET_LIST);
            targetSelectionCrud.create(pspTargetList);
            allTargetLists.add(pspTargetList);
            pdqTargetList = createTargetList("PDQ Targets");
            targetSelectionCrud.create(pdqTargetList);
            allTargetLists.add(pdqTargetList);
            goTargetList = createTargetList("GO Targets");
            targetSelectionCrud.create(goTargetList);
            allTargetLists.add(goTargetList);
            ppaTargetList = createTargetList("PPA Targets");
            targetSelectionCrud.create(ppaTargetList);
            allTargetLists.add(ppaTargetList);
            unusedTargetList = createTargetList("Unused Target List");
            targetSelectionCrud.create(unusedTargetList);
            allTargetLists.add(unusedTargetList);

            kics = createKics();
            kicCrud.create(kics);

            pspPlannedTargets = createPlannedTargets(kics, pspTargetList);
            targetSelectionCrud.create(pspPlannedTargets);
            planetDetectionPlannedTargets = createPlannedTargets(kics,
                planetDetectionTargetList);
            targetSelectionCrud.create(planetDetectionPlannedTargets);

            allTargetListSets = new ArrayList<TargetListSet>();
            longCadenceTargetListSet = createTargetListSet(TargetType.LONG_CADENCE);
            targetSelectionCrud.create(longCadenceTargetListSet);
            allTargetListSets.add(longCadenceTargetListSet);
            shortCadenceTargetListSet = createTargetListSet(TargetType.SHORT_CADENCE);
            targetSelectionCrud.create(shortCadenceTargetListSet);
            allTargetListSets.add(shortCadenceTargetListSet);
            referencePixelTargetListSet = createTargetListSet(TargetType.REFERENCE_PIXEL);
            targetSelectionCrud.create(referencePixelTargetListSet);
            allTargetListSets.add(referencePixelTargetListSet);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    /**
     * Creates targetListSets that have TargetTables associated with them in
     * different states.
     */
    private TargetListSet createTargetListSet(TargetType type) {
        TargetListSet targetListSet = new TargetListSet(type.toString());
        targetListSet.setType(type);
        targetListSet.setState(State.UNLOCKED);
        targetListSet.setStart(new Date(42));
        targetListSet.setEnd(new Date(4242));
        TargetTable ttable = null;
        // Add target lists in reverse order to ensure that retrieve sorting
        // works.
        switch (type) {
            case BACKGROUND:
                break;
            case LONG_CADENCE:
                ttable = createTargetTable(type, ExportTable.State.UNLOCKED);
                targetListSet.getTargetLists()
                    .add(ppaTargetList);
                targetListSet.getTargetLists()
                    .add(planetDetectionTargetList);
                targetListSet.getTargetLists()
                    .add(goTargetList);
                targetListSet.setTargetTable(ttable);
                break;
            case SHORT_CADENCE:
                ttable = createTargetTable(type, ExportTable.State.UPLINKED);
                targetListSet.getTargetLists()
                    .add(pspTargetList);
                targetListSet.setTargetTable(ttable);
                break;
            case REFERENCE_PIXEL:
                targetListSet.getTargetLists()
                    .add(pdqTargetList);
                break;
        }

        return targetListSet;
    }

    private TargetTable createTargetTable(TargetType ttype,
        ExportTable.State state) {
        TargetTable ttable = new TargetTable(ttype);
        ttable.setState(state);

        TargetCrud targetCrud = new TargetCrud();
        targetCrud.createTargetTable(ttable);
        return ttable;
    }

    private TargetList createTargetList(String name) {
        TargetList targetList = new TargetList(name);
        targetList.setCategory(name);
        targetList.setSourceType(SourceType.QUERY);
        targetList.setSource("select * from blah");

        return targetList;
    }

    /**
     * 
     * @param idStart
     * @param idEnd exclusive
     * @return
     */
    private static List<Kic> createKics(int idStart, int idEnd) {
        List<Kic> kics = new ArrayList<Kic>();
        for (int i = idStart; i < idEnd; i++) {
            Kic kic = new Kic.Builder(i, 0, 0).skyGroupId(i % 2)
                .build();
            kics.add(kic);
        }

        return kics;
    }

    private List<Kic> createKics() {
        return createKics(plannedTargetStartingId, plannedTargetStartingId
            + PLANNED_TARGET_BATCH_SIZE);
    }

    private static List<PlannedTarget> createPlannedTargets(List<Kic> kics,
        TargetList targetList) {

        List<PlannedTarget> targets = new ArrayList<PlannedTarget>();
        for (Kic kic : kics) {
            PlannedTarget target = new PlannedTarget(kic.getKeplerId(),
                kic.getSkyGroupId(), targetList);
            target.addLabel(TAD_ONE_HALO);
            List<Offset> offsets = Arrays.asList(new Offset[] { new Offset(0, 0) });
            Aperture aperture = new Aperture(true, 0, 0, offsets);
            // targetCrud.createAperture(aperture);
            target.setAperture(aperture);
            targets.add(target);
        }

        return targets;
    }

    private void testTargetListSet(TargetListSet targetListSet) {
        assertEquals(longCadenceTargetListSet.getId(), targetListSet.getId());
        assertEquals(longCadenceTargetListSet.getName(),
            targetListSet.getName());
        assertEquals(longCadenceTargetListSet.getType(),
            targetListSet.getType());
        assertEquals(longCadenceTargetListSet.getState(),
            targetListSet.getState());
        assertDateEquals(longCadenceTargetListSet.getStart(),
            targetListSet.getStart());
        assertDateEquals(longCadenceTargetListSet.getEnd(),
            targetListSet.getEnd());
        testTargetList(targetListSet.getTargetLists()
            .get(0));
    }

    private void testTargetList(TargetList targetList) {
        assertEquals(goTargetList.getName(), targetList.getName());
        assertEquals(goTargetList.getCategory(), targetList.getCategory());
        assertEquals(goTargetList.getSourceType(), targetList.getSourceType());
        assertEquals(goTargetList.getSource(), targetList.getSource());
        assertDateEquals(goTargetList.getLastModified(),
            targetList.getLastModified());
    }

    private void testPlannedTargets(List<PlannedTarget> targets, int startingId) {
        for (int i = startingId; i < startingId + PLANNED_TARGET_BATCH_SIZE; i++) {
            assertEquals(planetDetectionPlannedTargets.get(i), targets.get(i));
            assertEquals(targets.get(i)
                .getKeplerId(), i);
        }
    }

    // For some reason, there appears to be some rounding when saving dates in
    // the database. The dates are longs, so there shouldn't be rounding, but
    // until we figure out exactly what's going on, let's not worry about
    // differences that are less than a second.
    private void assertDateEquals(Date date1, Date date2) {
        assertTrue(Math.abs(date1.getTime() - date2.getTime()) < 500);
    }

}
