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

package gov.nasa.kepler.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.cm.TargetListImporter.ProgressHandler;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link TargetListImporter} class.
 * 
 * @author Bill Wohler
 * @author Sean McCauliff
 */
public class TargetListImporterTest extends JMockTest {

    private static final String CATEGORY = "Planetary";

    private static final boolean DEFAULT_TREAT_CUSTOM_TARGETS_AS_NEW = false;
    private static final boolean DEFAULT_IMPORTING_TARGET_LIST = true;
    private static final boolean DEFAULT_SKIP_MISSING_KEPLER_IDS = false;
    private static final boolean DEFAULT_CANCELED = false;
    private static final ProgressHandler DEFAULT_PROGRESS_HANDLER = null;

    private static final File testRoot = new File(Filenames.BUILD_TEST,
        "TargetListImporterTest");

    private TargetSelectionOperations targetSelectionOperations;

    private int lastCustomKeplerId = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;

    private TargetListImporter targetListImporter;

    @Before
    public void setUp() throws Exception {
        if (!testRoot.mkdirs()) {
            // Ignore return value; if this directory already exists, mkdirs
            // returns false!
            ;
        }
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.cleanDir(testRoot);
    }

    @Test
    public void testCanceled() throws IOException, ParseException {
        File targetListFile = new File(testRoot, "target-list1.txt");
        TargetList targetList = new TargetList("target-list1");
        createPlannedTargets(
            Arrays.asList(new Target(42, 42, null, -1, -1, null)), targetList,
            CATEGORY, targetListFile);
        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            CATEGORY, targetListFile, DEFAULT_TREAT_CUSTOM_TARGETS_AS_NEW,
            DEFAULT_IMPORTING_TARGET_LIST, DEFAULT_SKIP_MISSING_KEPLER_IDS,
            true, DEFAULT_PROGRESS_HANDLER);
        assertEquals(null, plannedTargets);
    }

    @Test
    public void testProgress() throws IOException, ParseException {
        File targetListFile = new File(testRoot, "target-list1.txt");
        TargetList targetList = new TargetList("target-list1");
        // Need at least ten targets to tickle progress.
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(new Target(42, 42, null, -1, -1, null), new Target(
                43, 42, null, -1, -1, null), new Target(44, 42, null, -1, -1,
                null), new Target(45, 42, null, -1, -1, null), new Target(46,
                42, null, -1, -1, null),
                new Target(47, 42, null, -1, -1, null), new Target(48, 42,
                    null, -1, -1, null), new Target(49, 42, null, -1, -1, null)),
            targetList, CATEGORY, targetListFile);
        ProgressHandler progressHandler = mock(ProgressHandler.class);
        // Run in debugger to determine charsRead (90) and length (100) of
        // target-list1.txt.
        oneOf(progressHandler).setProgress((float) 90 / 100);
        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            CATEGORY, targetListFile, DEFAULT_TREAT_CUSTOM_TARGETS_AS_NEW,
            DEFAULT_IMPORTING_TARGET_LIST, DEFAULT_SKIP_MISSING_KEPLER_IDS,
            DEFAULT_CANCELED, progressHandler);
        assertEquals(expectedPlannedTargets, plannedTargets);
    }

    @SuppressWarnings("unchecked")
    @Test(expected = IllegalStateException.class)
    public void testZeroCategories() throws IOException, ParseException {
        createPlannedTargets(Collections.EMPTY_LIST);
    }

    @Test
    public void testOneCategory() throws IOException, ParseException {
        createPlannedTargets(Arrays.asList(CATEGORY));
        assertEquals(CATEGORY, targetListImporter.getCategory());
    }

    @Test(expected = IllegalStateException.class)
    public void testTwoDifferentCategories() throws IOException, ParseException {
        createPlannedTargets(Arrays.asList(CATEGORY, "different" + CATEGORY));
    }

    @Test(expected = IllegalStateException.class)
    public void testTwoDifferentCaseOnlyCategories() throws IOException,
        ParseException {
        createPlannedTargets(Arrays.asList(CATEGORY, CATEGORY.toUpperCase()));
    }

    @Test
    public void testTwoSameCategories() throws IOException, ParseException {
        createPlannedTargets(Arrays.asList(CATEGORY, CATEGORY));
        assertEquals(CATEGORY, targetListImporter.getCategory());
    }

    @Test
    public void ingestSameCustomTargetWithFirstMissingAperture()
        throws IOException, ParseException {

        File customTargetListFile = new File(testRoot, "target-list1.txt");
        TargetList targetList = new TargetList("target-list1");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(
                new Target(lastCustomKeplerId, 42, null, -1, -1, null),
                new Target(lastCustomKeplerId, 42, null, 436, 0, Arrays.asList(
                    new Offset(0, 0), new Offset(2, 2)))), targetList,
            "Custom", customTargetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "Custom", customTargetListFile);
        assertEquals(expectedPlannedTargets, plannedTargets);
    }

    @Test
    public void ingestSameCustomTargetWithSecondMissingAperture()
        throws IOException, ParseException {

        File customTargetListFile = new File(testRoot, "target-list1.txt");
        TargetList targetList = new TargetList("target-list1");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(new Target(lastCustomKeplerId, 42, null, 436, 0,
                Arrays.asList(new Offset(0, 0), new Offset(2, 2))), new Target(
                lastCustomKeplerId, 42, null, -1, -1, null)), targetList,
            "Custom", customTargetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "Custom", customTargetListFile);
        assertEquals(expectedPlannedTargets, plannedTargets);
    }

    @Test
    public void ingestSameCustomTargetWithTwoMissingApertures()
        throws IOException, ParseException {

        File customTargetListFile = new File(testRoot, "target-list1.txt");
        TargetList targetList = new TargetList("target-list1");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(
                new Target(lastCustomKeplerId, 42, null, -1, -1, null),
                new Target(lastCustomKeplerId, 42, null, -1, -1, null)),
            targetList, "Custom", customTargetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "Custom", customTargetListFile);
        assertEquals(expectedPlannedTargets, plannedTargets);
    }

    @Test(expected = ParseException.class)
    public void ingestSameCustomTargetWithDifferentApertures()
        throws IOException, ParseException {

        File customTargetListFile = new File(testRoot, "target-list1.txt");
        TargetList targetList = new TargetList("target-list1");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(
                new Target(lastCustomKeplerId, 42, null, 436, 0, Arrays.asList(
                    new Offset(0, 0), new Offset(1, 1))),
                new Target(lastCustomKeplerId, 42, null, 436, 0, Arrays.asList(
                    new Offset(0, 0), new Offset(2, 2)))), targetList,
            "Custom", customTargetListFile, false);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "Custom", customTargetListFile);
        assertEquals(expectedPlannedTargets, plannedTargets);
    }

    @Test
    public void testBlankLine() throws IOException, ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<Target> targets = new ArrayList<Target>();
        int targetCount = 3;
        for (int i = 0; i < targetCount; i++) {
            targets.add(new Target(i, i, new HashSet<String>(
                Arrays.asList(Integer.toString(i))), -1, -1, null));
        }
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            targets, targetList, "PPA_STELLAR", targetListFile, true, false,
            true);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile);

        assertEquals(targetCount, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);
    }

    @Test
    public void testOrderedKics() throws IOException, ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<Target> targets = new ArrayList<Target>();
        int targetCount = 3;
        for (int i = 0; i < targetCount; i++) {
            targets.add(new Target(i, i, new HashSet<String>(
                Arrays.asList(Integer.toString(i))), -1, -1, null));
        }
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            targets, targetList, "PPA_STELLAR", targetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile);

        assertEquals(targetCount, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);

        for (int i = 0; i < targetCount; i++) {
            PlannedTarget plannedTarget = plannedTargets.get(i);
            assertEquals(i, plannedTarget.getKeplerId());
            assertEquals(i, plannedTarget.getSkyGroupId());
            assertEquals(targetList, plannedTarget.getTargetList());

            Set<String> labels = plannedTarget.getLabels();
            assertEquals(1, labels.size());
            assertTrue(labels.contains(Integer.toString(i)));
        }
    }

    @Test
    public void testOrderedCustomTargets() throws IOException, ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<Target> targets = new ArrayList<Target>();
        int targetCount = 3;
        for (int i = 0; i < targetCount; i++) {
            targets.add(new Target(TargetManagementConstants.INVALID_KEPLER_ID,
                i, new HashSet<String>(Arrays.asList(Integer.toString(i))), i,
                i, Arrays.asList(new Offset(i, i))));
        }
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            targets, targetList, "PPA_STELLAR", targetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile);

        assertEquals(targetCount, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);

        for (int i = 0; i < targetCount; i++) {
            PlannedTarget plannedTarget = plannedTargets.get(i);
            assertEquals(TargetManagementConstants.INVALID_KEPLER_ID,
                plannedTarget.getKeplerId());
            assertEquals(i, plannedTarget.getSkyGroupId());
            assertEquals(targetList, plannedTarget.getTargetList());

            Set<String> labels = plannedTarget.getLabels();
            assertEquals(1, labels.size());
            assertTrue(labels.contains(Integer.toString(i)));
        }
    }

    @Test
    public void testOrderedKicsAndCustomTargets() throws IOException,
        ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<Target> targets = new ArrayList<Target>();
        int targetPairCount = 3;
        for (int i = 0; i < targetPairCount; i++) {
            targets.add(new Target(i, i, new HashSet<String>(
                Arrays.asList(Integer.toString(i))), -1, -1, null));
            targets.add(new Target(TargetManagementConstants.INVALID_KEPLER_ID,
                i, new HashSet<String>(Arrays.asList(Integer.toString(i))), i,
                i, Arrays.asList(new Offset(i, i))));
        }
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            targets, targetList, "PPA_STELLAR", targetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile);

        assertEquals(2 * targetPairCount, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);

        for (int i = 0; i < targetPairCount; i++) {
            PlannedTarget plannedTarget = plannedTargets.get(2 * i);
            assertEquals(i, plannedTarget.getKeplerId());
            assertEquals(i, plannedTarget.getSkyGroupId());
            assertEquals(targetList, plannedTarget.getTargetList());

            Set<String> labels = plannedTarget.getLabels();
            assertEquals(1, labels.size());
            assertTrue(labels.contains(Integer.toString(i)));

            plannedTarget = plannedTargets.get(2 * i + 1);
            assertEquals(TargetManagementConstants.INVALID_KEPLER_ID,
                plannedTarget.getKeplerId());
            assertEquals(i, plannedTarget.getSkyGroupId());
            assertEquals(targetList, plannedTarget.getTargetList());

            labels = plannedTarget.getLabels();
            assertEquals(1, labels.size());
            assertTrue(labels.contains(Integer.toString(i)));

        }
    }

    @Test
    public void ingestTargetFileWithDuplicateKeplerIds() throws IOException,
        ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(
                new Target(9497294, 42, new HashSet<String>(
                    Arrays.asList("PPA_STELLAR")), -1, -1, null), new Target(
                    9497294, 42,
                    new HashSet<String>(Arrays.asList("PLANETARY")), -1, -1,
                    null)), targetList, "PPA_STELLAR", targetListFile);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile);

        assertEquals(1, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);
        PlannedTarget plannedTarget = plannedTargets.get(0);

        assertEquals(9497294, plannedTarget.getKeplerId());
        assertEquals(42, plannedTarget.getSkyGroupId());
        assertEquals(targetList, plannedTarget.getTargetList());

        Set<String> labels = plannedTarget.getLabels();
        assertEquals(2, labels.size());
        assertTrue(labels.contains("PPA_STELLAR"));
        assertTrue(labels.contains("PLANETARY"));
    }

    @Test
    public void ingestTargetFileTreatCustomTargetsAsNew() throws IOException,
        ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(
                new Target(TargetManagementConstants.INVALID_KEPLER_ID, 0,
                    new HashSet<String>(Arrays.asList(Integer.toString(0))), 0,
                    0, Arrays.asList(new Offset(0, 0))),
                new Target(100000000, 42, new HashSet<String>(
                    Arrays.asList("PPA_STELLAR")), 1, 1,
                    Arrays.asList(new Offset(0, 0)))), targetList,
            "PPA_STELLAR", targetListFile, true, true, false);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile, true, DEFAULT_IMPORTING_TARGET_LIST,
            DEFAULT_SKIP_MISSING_KEPLER_IDS, DEFAULT_CANCELED,
            DEFAULT_PROGRESS_HANDLER);

        assertEquals(2, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);

        PlannedTarget plannedTarget = plannedTargets.get(0);
        assertEquals(TargetManagementConstants.INVALID_KEPLER_ID,
            plannedTarget.getKeplerId());
        assertEquals(0, plannedTarget.getSkyGroupId());
        assertEquals(targetList, plannedTarget.getTargetList());

        plannedTarget = plannedTargets.get(1);
        assertEquals(TargetManagementConstants.INVALID_KEPLER_ID,
            plannedTarget.getKeplerId());
        assertEquals(42, plannedTarget.getSkyGroupId());
        assertEquals(targetList, plannedTarget.getTargetList());
    }

    @Test
    public void ingestTargetFileNotForImport() throws IOException,
        ParseException {

        File targetListFile = new File(testRoot, "target-list.txt");
        TargetList targetList = new TargetList("target-list");
        List<PlannedTarget> expectedPlannedTargets = createPlannedTargets(
            Arrays.asList(
                new Target(TargetManagementConstants.INVALID_KEPLER_ID, 0,
                    new HashSet<String>(Arrays.asList(Integer.toString(0))), 0,
                    0, Arrays.asList(new Offset(0, 0))),
                new Target(100000000, 42, new HashSet<String>(
                    Arrays.asList("PPA_STELLAR")), 1, 1,
                    Arrays.asList(new Offset(0, 0)))), targetList,
            "PPA_STELLAR", targetListFile, false);

        List<PlannedTarget> plannedTargets = ingestTargetFile(targetList,
            "PPA_STELLAR", targetListFile, DEFAULT_TREAT_CUSTOM_TARGETS_AS_NEW,
            false, DEFAULT_SKIP_MISSING_KEPLER_IDS, DEFAULT_CANCELED,
            DEFAULT_PROGRESS_HANDLER);

        assertEquals(2, plannedTargets.size());
        assertEquals(expectedPlannedTargets, plannedTargets);

        PlannedTarget plannedTarget = plannedTargets.get(0);
        assertEquals(TargetManagementConstants.INVALID_KEPLER_ID,
            plannedTarget.getKeplerId());
        assertEquals(0, plannedTarget.getSkyGroupId());
        assertEquals(targetList, plannedTarget.getTargetList());

        plannedTarget = plannedTargets.get(1);
        assertEquals(100000000, plannedTarget.getKeplerId());
        assertEquals(42, plannedTarget.getSkyGroupId());
        assertEquals(targetList, plannedTarget.getTargetList());
    }

    @Test
    public void keplerIdsFromFile() throws IOException {
        File targetListFile = new File(testRoot, "ppa-stars.txt");
        String content = "# test comment.\n"
            + "Category: PPA_STARS\n"
            + "9497294||PPA_STELLAR|||\n"
            + "9644867||PPA_STELLAR|||\n"
            + "NEW|3|PPA_2DBLACK,FGS_XTALK_PARALLEL|436|0|0,0;0,1;0,2;0,3;0,4;0,5;0,6;0,7;0,8;0,9;0,10;0,11\n";
        createTargetListFile(targetListFile, content);

        TargetListImporter importer = new TargetListImporter();
        Set<Integer> keplerIds = importer.keplerIdsFromFile(targetListFile.getAbsolutePath());
        assertEquals(2, keplerIds.size());
        assertTrue(keplerIds.contains(9497294));
        assertTrue(keplerIds.contains(9644867));
        assertEquals("PPA_STARS", importer.getCategory());
    }

    private List<PlannedTarget> createPlannedTargets(List<String> categories)
        throws IOException, ParseException {
        return createPlannedTargets(categories, false);
    }

    private List<PlannedTarget> createPlannedTargets(List<String> categories,
        boolean skipMissingKeplerIds) throws IOException, ParseException {
        // TODO Update other createPlannedTargets methods in the same way as
        // those in TargetListMergerTest to simplify the tests themselves.
        // This method uses the same pattern, but only handles categories at
        // this time.
        final boolean validate = true;
        final TargetList targetList = new TargetList("target-list");
        final List<PlannedTarget> mergedPlannedTargets = Collections.emptyList();
        File targetListFile = new File(testRoot, "target-list.txt");

        String lastCategory = null;
        StringBuilder content = new StringBuilder();
        for (String category : categories) {
            content.append("Category: ")
                .append(category)
                .append("\n");
            lastCategory = category;
        }

        createTargetListFile(targetListFile, content.toString());

        if (categoriesValid(categories)) {
            if (validate) {
                allowing(getTargetSelectionOperations()).validatePlannedTargets(
                    targetList, mergedPlannedTargets, skipMissingKeplerIds);
                will(returnValue(mergedPlannedTargets));
            }
        }

        ingestTargetFile(targetList, lastCategory, targetListFile,
            DEFAULT_TREAT_CUSTOM_TARGETS_AS_NEW, DEFAULT_IMPORTING_TARGET_LIST,
            skipMissingKeplerIds, DEFAULT_CANCELED, DEFAULT_PROGRESS_HANDLER);

        return mergedPlannedTargets;
    }

    /**
     * Returns true if there is only one unique non-{@code null} and non-empty
     * category in the list.
     */
    private boolean categoriesValid(List<String> categories) {
        if (categories == null || categories.size() == 0) {
            return false;
        }
        String previousCategory = null;
        for (String category : categories) {
            if (previousCategory == null) {
                if (category == null || category.length() == 0) {
                    return false;
                }
                previousCategory = category;
            } else {
                if (!previousCategory.equals(category)) {
                    return false;
                }
            }
        }

        return true;
    }

    List<PlannedTarget> createPlannedTargets(List<Target> targets,
        TargetList targetList, String category, File targetListFile)
        throws IOException {
        return createPlannedTargets(targets, targetList, category,
            targetListFile, true, false, false);
    }

    List<PlannedTarget> createPlannedTargets(List<Target> targets,
        TargetList targetList, String category, File targetListFile,
        boolean validate) throws IOException {
        return createPlannedTargets(targets, targetList, category,
            targetListFile, validate, false, false);
    }

    private List<PlannedTarget> createPlannedTargets(List<Target> targets,
        final TargetList targetList, String category, File targetListFile,
        final boolean validate, boolean treatCustomTargetsAsNew, 
        boolean appendBlankLine)
        throws IOException {

        final List<String> targetStrings = new ArrayList<String>();
        for (Target target : targets) {
            StringBuilder targetString = new StringBuilder().append(
                target.keplerId == TargetManagementConstants.INVALID_KEPLER_ID ? "NEW"
                    : target.keplerId)
                .append("|")
                .append(
                    target.skyGroupId >= 0
                        && (TargetManagementConstants.isCustomTarget(target.keplerId) || target.keplerId == TargetManagementConstants.INVALID_KEPLER_ID) ? target.skyGroupId
                        : "")
                .append("|");
            if (target.labels != null && target.labels.size() > 0) {
                for (String label : target.labels) {
                    targetString.append(label)
                        .append(",");
                }
                targetString.deleteCharAt(targetString.length() - 1);
            }
            targetString.append("|")
                .append(target.ccdRow >= 0 ? target.ccdRow : "")
                .append("|")
                .append(target.ccdColumn >= 0 ? target.ccdColumn : "")
                .append("|");
            if (target.offsets != null && target.offsets.size() > 0) {
                for (Offset offset : target.offsets) {
                    targetString.append(offset.getRow())
                        .append(",")
                        .append(offset.getColumn())
                        .append(";");
                }
                targetString.deleteCharAt(targetString.length() - 1);
            }
            targetStrings.add(targetString.toString());
        }

        StringBuilder content = new StringBuilder().append(
            "# test comment.\nCategory: ")
            .append(category)
            .append("\n");
        if (appendBlankLine) {
            content.append("\n");
        }
        for (String targetString : targetStrings) {
            content.append(targetString.toString())
                .append("\n");
        }
        createTargetListFile(targetListFile, content.toString());

        final List<PlannedTarget> plannedTargets = new ArrayList<PlannedTarget>();
        for (Target target : targets) {
            PlannedTarget plannedTarget = new PlannedTarget(target.keplerId,
                target.skyGroupId);
            if (target.labels != null) {
                plannedTarget.setLabels(target.labels);
            }
            if (target.offsets != null) {
                plannedTarget.setAperture(new Aperture(true, target.ccdRow,
                    target.ccdColumn, target.offsets));
            }
            plannedTarget.setTargetList(targetList);
            plannedTargets.add(plannedTarget);
        }

        int temporaryCustomTargetId = -1;
        Map<Integer, PlannedTarget> targetByKeplerId = new LinkedHashMap<Integer, PlannedTarget>();
        for (PlannedTarget plannedTarget : plannedTargets) {
            int keplerId = plannedTarget.getKeplerId();
            if (TargetManagementConstants.isCustomTarget(keplerId)
                && treatCustomTargetsAsNew) {
                plannedTarget.setKeplerId(TargetManagementConstants.INVALID_KEPLER_ID);
            }
            if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                keplerId = temporaryCustomTargetId--;
            }
            merge(targetByKeplerId, keplerId, plannedTarget);
        }
        final List<PlannedTarget> mergedPlannedTargets = new ArrayList<PlannedTarget>(
            targetByKeplerId.values());

        if (validate) {
            allowing(getTargetSelectionOperations()).validatePlannedTargets(
                targetList, mergedPlannedTargets, false);
            will(returnValue(mergedPlannedTargets));
        }

        return mergedPlannedTargets;
    }

    private void merge(Map<Integer, PlannedTarget> targetByKeplerId,
        int keplerId, PlannedTarget plannedTarget) {

        PlannedTarget target = targetByKeplerId.get(keplerId);
        if (target == null) {
            targetByKeplerId.put(keplerId, new PlannedTarget(plannedTarget));
        } else {
            if (target.getAperture() == null) {
                target.setAperture(plannedTarget.getAperture());
            }
            target.getLabels()
                .addAll(plannedTarget.getLabels());
        }
    }

    private List<PlannedTarget> ingestTargetFile(TargetList targetList,
        String category, File targetListFile) throws IOException,
        ParseException {

        return ingestTargetFile(targetList, category, targetListFile,
            DEFAULT_TREAT_CUSTOM_TARGETS_AS_NEW, DEFAULT_IMPORTING_TARGET_LIST,
            DEFAULT_SKIP_MISSING_KEPLER_IDS, DEFAULT_CANCELED,
            DEFAULT_PROGRESS_HANDLER);
    }

    private List<PlannedTarget> ingestTargetFile(TargetList targetList,
        String category, File targetListFile, boolean treatCustomTargetsAsNew,
        boolean importingTargetList, boolean skipMissingKeplerIds,
        boolean canceled, ProgressHandler progressHandler) throws IOException,
        ParseException {

        targetListImporter = new TargetListImporter(targetList);
        targetListImporter.setTargetSelectionOperations(getTargetSelectionOperations());
        targetListImporter.setTreatCustomTargetsAsNew(treatCustomTargetsAsNew);
        targetListImporter.setImportingTargetList(importingTargetList);
        targetListImporter.setSkipMissingKeplerIds(skipMissingKeplerIds);
        targetListImporter.setCanceled(canceled);
        targetListImporter.setProgressHandler(progressHandler);
        List<PlannedTarget> plannedTargets = targetListImporter.ingestTargetFile(targetListFile.getAbsolutePath());

        assertNotNull(targetListImporter.getCategory());
        assertEquals(category, targetListImporter.getCategory());

        return plannedTargets;
    }

    private void createTargetListFile(File targetListFile, String content)
        throws IOException {

        BufferedWriter writer = new BufferedWriter(new FileWriter(
            targetListFile));
        writer.append(content);
        writer.close();
    }

    TargetSelectionOperations getTargetSelectionOperations() {
        if (targetSelectionOperations == null) {
            targetSelectionOperations = mock(TargetSelectionOperations.class);
        }

        return targetSelectionOperations;
    }

    public static class Target {
        public int keplerId;
        public int skyGroupId;
        public Set<String> labels;
        public int ccdRow;
        public int ccdColumn;
        public List<Offset> offsets;

        public Target(Target target) {
            this(target.keplerId, target.skyGroupId, target.labels,
                target.ccdRow, target.ccdColumn, target.offsets);
        }

        Target(int keplerId, int skyGroupId, Set<String> labels, int ccdRow,
            int ccdColumn, List<Offset> offsets) {

            this.keplerId = keplerId;
            this.skyGroupId = skyGroupId;
            this.labels = labels == null ? new HashSet<String>() : labels;
            this.ccdRow = ccdRow;
            this.ccdColumn = ccdColumn;
            this.offsets = offsets;
        }
    }
}
