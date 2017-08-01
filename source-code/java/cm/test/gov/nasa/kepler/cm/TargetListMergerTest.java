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
import gov.nasa.kepler.cm.TargetListImporterTest.Target;
import gov.nasa.kepler.cm.TargetListMergerCli.TargetListMerger;
import gov.nasa.kepler.cm.TargetListMergerCli.TargetListMergerOptions;
import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.common.UsageException;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.HashSet;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link TargetListMerger} class.
 * 
 * @author Bill Wohler
 */
public class TargetListMergerTest {

    // Targets and lists of targets.
    private static final Target TARGET1 = new Target(142, 143, null, -1, -1,
        null);
    private static final Target TARGET2 = new Target(143, 144, null, -1, -1,
        null);
    private static final Target TARGET3 = new Target(242, 243, null, -1, -1,
        null);
    private static final Target TARGET4 = new Target(243, 244, null, -1, -1,
        null);
    private static final List<Target> TARGETSA1 = Arrays.asList(TARGET1);
    private static final List<Target> TARGETSA = Arrays.asList(TARGET1, TARGET2);
    private static final List<Target> TARGETSB1 = Arrays.asList(TARGET3);
    private static final List<Target> TARGETSB = Arrays.asList(TARGET3, TARGET4);
    private static final List<Target> TARGETSAB = Arrays.asList(TARGET1,
        TARGET2, TARGET3, TARGET4);
    private static final List<Target> TARGETSA1B1 = Arrays.asList(TARGET1,
        TARGET3);
    private static final List<Target> EMPTY_TARGETS = new ArrayList<Target>();

    // Labels.
    private static final List<String> LABELSA = Arrays.asList("LABEL1",
        "LABEL2");
    private static final List<String> LABELSB = Arrays.asList("LABEL3",
        "LABEL4");
    // private static final List<String> LABELSC = Arrays.asList("LABEL5",
    // "LABEL6");
    private static final List<String> LABELSAB = Arrays.asList("LABEL1",
        "LABEL2", "LABEL3", "LABEL4");
    private static final List<String> LABELSBC = Arrays.asList("LABEL3",
        "LABEL4", "LABEL5", "LABEL6");
    private static final List<String> LABELSABC = Arrays.asList("LABEL1",
        "LABEL2", "LABEL3", "LABEL4", "LABEL5", "LABEL6");

    // Targets and lists of targets with manually-added labels.
    private static final Target TARGET11 = new Target(142, 143,
        new HashSet<String>(Arrays.asList("label1")), -1, -1, null);
    private static final Target TARGET12 = new Target(143, 144,
        new HashSet<String>(Arrays.asList("label1")), -1, -1, null);
    private static final Target TARGET13 = new Target(242, 243,
        new HashSet<String>(Arrays.asList("label1")), -1, -1, null);
    private static final Target TARGET14 = new Target(142, 143, null, -1, -1,
        null);
    private static final Target TARGET15 = new Target(242, 243, null, -1, -1,
        null);
    private static final Target TARGET16 = new Target(243, 244, null, -1, -1,
        null);
    private static final List<Target> TARGETS10A = Arrays.asList(TARGET11,
        TARGET12);
    private static final List<Target> TARGETS10B = Arrays.asList(TARGET15,
        TARGET16);
    private static final List<Target> TARGETS10AB = Arrays.asList(TARGET11,
        TARGET12, TARGET15, TARGET16);
    private static final List<Target> TARGETS11A = Arrays.asList(TARGET11,
        TARGET13);
    private static final List<Target> TARGETS11B = Arrays.asList(TARGET14,
        TARGET15);
    private static final List<Target> TARGETS11AB = Arrays.asList(TARGET11,
        TARGET13);

    // Custom targets.
    private static final Target CUSTOM_TARGET1 = new Target(100000142, 143,
        null, 1, 2, Arrays.asList(new Offset(3, 4)));
    private static final Target CUSTOM_TARGET11 = new Target(100000142, 143,
        null, 2, 2, Arrays.asList(new Offset(3, 4)));
    private static final Target CUSTOM_TARGET2 = new Target(100000143, 144,
        null, 2, 3, Arrays.asList(new Offset(4, 5)));
    private static final Target CUSTOM_TARGET21 = new Target(100000143, 144,
        null, 2, 3, Arrays.asList(new Offset(5, 5)));
    private static final Target NEW_CUSTOM_TARGET = new Target(TargetManagementConstants.INVALID_KEPLER_ID, 144,
        null, 2, 3, Arrays.asList(new Offset(5, 5)));
    private static final List<Target> CUSTOM_TARGETSA = Arrays.asList(CUSTOM_TARGET1);
    private static final List<Target> CUSTOM_TARGETSA1 = Arrays.asList(CUSTOM_TARGET11);
    private static final List<Target> CUSTOM_TARGETSB = Arrays.asList(CUSTOM_TARGET2);
    private static final List<Target> CUSTOM_TARGETSB1 = Arrays.asList(CUSTOM_TARGET21);
    private static final List<Target> NEW_CUSTOM_TARGETS = Arrays.asList(NEW_CUSTOM_TARGET);

    private static final String CATEGORY = "foo-category";
    private static final String CATEGORY1 = "foo-category-1";
    private static final String CATEGORY2 = "foo-category-2";
    private static final String FILE1 = "foo1.txt";
    private static final String FILE2 = "foo2.txt";
    private static final String OUTPUT = "merged-lists.txt";

    private static final File testRoot = new File(Filenames.BUILD_TEST,
        "TargetListMergerTest");
    private TargetListImporter mergedTargetListImporter;

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
    public void testCli() {
        new TargetListMergerCli();
    }
    
    @Test(expected = UsageException.class)
    public void testZeroLists() {
        new TargetListMerger(new TargetListMergerOptions());
    }

    @Test(expected = UsageException.class)
    public void testOneList() {
        TargetListMergerOptions targetListMergerOptions = new TargetListMergerOptions();
        targetListMergerOptions.setTargetListFilenames(Arrays.asList("foo"));
        new TargetListMerger(targetListMergerOptions);
    }

    @Test
    public void testCategoryGiven() throws IOException, ParseException {
        mergeLists(TARGETSA, TARGETSB, TARGETSAB, true);
        assertEquals(CATEGORY, mergedTargetListImporter.getCategory());
    }

    @Test
    public void testCategoryNotGiven() throws IOException, ParseException {
        mergeLists(TARGETSA, TARGETSB, TARGETSAB, false);
        assertEquals(TargetListMergerOptions.DEFAULT_CATEGORY,
            mergedTargetListImporter.getCategory());
    }

    @Test
    public void testTwoEmptyLists() throws IOException, ParseException {
        mergeLists(EMPTY_TARGETS, EMPTY_TARGETS, EMPTY_TARGETS);
    }

    @Test
    public void testTwoIdenticalLists() throws IOException, ParseException {
        mergeLists(TARGETSA, TARGETSA, TARGETSA);
    }

    @Test
    public void testOneEmptyListAndOneNonEmptyList() throws IOException,
        ParseException {
        mergeLists(EMPTY_TARGETS, TARGETSA, TARGETSA);
    }

    @Test
    public void testTwoListsWithUniqueTargets() throws IOException,
        ParseException {
        mergeLists(TARGETSA, TARGETSB, TARGETSAB);
    }

    @Test
    public void testTwoListsWithDuplicateTargetsWithUniqueLabels()
        throws IOException, ParseException {
        mergeLists(TARGETSA, LABELSA, TARGETSA, LABELSB, TARGETSA, LABELSAB);
    }

    @Test
    public void testTwoListsWithDuplicateTargetsWithSameLabels()
        throws IOException, ParseException {
        mergeLists(TARGETSA, LABELSA, TARGETSA, LABELSA, TARGETSA, LABELSA);
    }

    @Test
    public void testTwoListsWithDuplicateTargetsWithUniqueAndSameLabels()
        throws IOException, ParseException {
        mergeLists(TARGETSA, LABELSAB, TARGETSA, LABELSBC, TARGETSA, LABELSABC);
    }

    @Test
    public void testTwoListsWithSingleUniqueTargets() throws IOException,
        ParseException {
        mergeLists(TARGETSA1, TARGETSB1, TARGETSA1B1);
    }

    @Test
    public void testTwoListsWithSingleDuplicateTargetsWithUniqueAndSameLabels()
        throws IOException, ParseException {
        mergeLists(TARGETSA1, LABELSAB, TARGETSA1, LABELSBC, TARGETSA1,
            LABELSABC);
    }

    @Test
    public void testTwoListsWithNoLabels() throws IOException, ParseException {
        mergeLists(TARGETSA, TARGETSB, TARGETSAB);
    }

    @Test
    public void testTwoListsWithOneWithLabelsOneWithout() throws IOException,
        ParseException {
        mergeLists(TARGETS10A, TARGETS10B, TARGETS10AB);
    }

    @Test
    public void testTwoListsWithDuplicateTargetsOneWithLabelsOneWithout()
        throws IOException, ParseException {
        mergeLists(TARGETS11A, TARGETS11B, TARGETS11AB);
    }

    @Test(expected = IllegalStateException.class)
    public void testTwoListsWithNewCustomTargets() throws IOException,
        ParseException {
        mergeLists(NEW_CUSTOM_TARGETS, NEW_CUSTOM_TARGETS, NEW_CUSTOM_TARGETS);
    }

    @Test
    public void testTwoListsWithDuplicateCustomTargets() throws IOException,
        ParseException {
        mergeLists(CUSTOM_TARGETSA, CUSTOM_TARGETSA, CUSTOM_TARGETSA);
    }

    @Test(expected = IllegalStateException.class)
    public void testTwoListsWithDuplicateCustomTargetsWithMismatchedReference()
        throws IOException, ParseException {
        mergeLists(CUSTOM_TARGETSA, CUSTOM_TARGETSA1, CUSTOM_TARGETSA);
    }

    @Test(expected = IllegalStateException.class)
    public void testTwoListsWithDuplicateCustomTargetsWithMismatchedOffsets()
        throws IOException, ParseException {
        mergeLists(CUSTOM_TARGETSB, CUSTOM_TARGETSB1, CUSTOM_TARGETSA);
    }

    private void mergeLists(List<Target> targetsA, List<String> labelsA,
        List<Target> targetsB, List<String> labelsB,
        List<Target> mergedTargets, List<String> mergedLabels)
        throws IOException, ParseException {

        mergeLists(addLabels(targetsA, labelsA), addLabels(targetsB, labelsB),
            addLabels(mergedTargets, mergedLabels));
    }

    private void mergeLists(List<Target> targetsA, List<Target> targetsB,
        List<Target> mergedTargets) throws IOException, ParseException {
        mergeLists(targetsA, targetsB, mergedTargets, false);
    }

    private void mergeLists(List<Target> targetsA, List<Target> targetsB,
        List<Target> mergedTargets, boolean setCategory) throws IOException,
        ParseException {

        // Create two target lists with different categories.
        TargetList targetList1 = new TargetList(FILE1);
        File file1 = new File(testRoot, FILE1);
        TargetListImporterTest targetListImporterTest = new TargetListImporterTest();
        targetListImporterTest.createPlannedTargets(targetsA, targetList1,
            CATEGORY1, file1, false);

        TargetList targetList2 = new TargetList(FILE2);
        File file2 = new File(testRoot, FILE2);
        targetListImporterTest.createPlannedTargets(targetsB, targetList2,
            CATEGORY2, file2, false);

        // Create expected merged list.
        // TODO Write expected list to a file *other* than OUTPUT and then add
        // code to actually diff the expected output with the actual output.
        // targetListImporterTest.createPlannedTargets(mergedTargets,
        // targetList,
        // setCategory ? CATEGORY : TargetListMergerOptions.DEFAULT_CATEGORY,
        // new File(testRoot, OUTPUT), false);

        // Merge them.
        TargetListMergerOptions targetListMergerOptions = new TargetListMergerOptions();
        targetListMergerOptions.setTargetListFilenames(Arrays.asList(testRoot
            + File.separator + FILE1, testRoot + File.separator + FILE2));
        if (setCategory) {
            targetListMergerOptions.setCategory(CATEGORY);
        }
        targetListMergerOptions.setOutputFilename(testRoot + File.separator
            + OUTPUT);
        TargetListMerger targetListMerger = new TargetListMerger(
            targetListMergerOptions);
        targetListMerger.mergeTargetLists();

        mergedTargetListImporter = new TargetListImporter(new TargetList(OUTPUT));
        mergedTargetListImporter.setImportingTargetList(false);
        mergedTargetListImporter.ingestTargetFile(testRoot + File.separator
            + OUTPUT);

        // Check that there is a comment that contains the names of the files.
        checkComment(testRoot + File.separator + OUTPUT, file1.getName(),
            file2.getName());
    }

    private List<Target> addLabels(List<Target> targets, List<String> labels) {

        List<Target> modifiedTargets = new ArrayList<Target>(targets.size());
        for (Target target : targets) {
            Target newTarget = new Target(target);
            newTarget.labels.addAll(labels);
            modifiedTargets.add(newTarget);
        }

        return modifiedTargets;
    }

    private void checkComment(String filename, String targetListName1,
        String targetListName2) throws IOException {

        StringBuilder comment = new StringBuilder();
        BufferedReader br = new BufferedReader(new FileReader(filename));
        for (String s = br.readLine(); s != null; s = br.readLine()) {
            if (!s.startsWith(TargetListImporter.COMMENT_CHAR)) {
                continue;
            }
            comment.append(s);
        }
        br.close();

        assertEquals(TargetListImporter.COMMENT_CHAR
            + " Merged the following target lists on "
            + Iso8601Formatter.dateFormatter()
                .format(new Date()) + ":" + TargetListImporter.COMMENT_CHAR
            + " " + targetListName1 + TargetListImporter.COMMENT_CHAR + " "
            + targetListName2, comment.toString());
    }
}
