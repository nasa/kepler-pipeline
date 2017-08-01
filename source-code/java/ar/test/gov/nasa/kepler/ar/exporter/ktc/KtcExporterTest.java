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

package gov.nasa.kepler.ar.exporter.ktc;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.ar.cli.KtcExportCli;
import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.KtcInfo;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.lang.TestSystemProvider;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.text.DateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Set;
import java.util.TimeZone;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;

public class KtcExporterTest {

    private static DateFormat dateTimeFormatter = Iso8601Formatter.dateTimeFormatter();

    private Date startUtc;
    private Date endUtc;
    private File outputDir = new File(Filenames.BUILD_TEST
        + "/KtcExporterTest");
    private DatabaseService dbService;

    @Before
    public void setUp() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
        dbService.getDdlInitializer()
            .initDB();
        Calendar cal = Calendar.getInstance();
        cal.setTimeZone(TimeZone.getTimeZone("UTC"));
        cal.set(2009, 2, 20, 4, 4, 0);
        startUtc = cal.getTime();
        cal.set(Calendar.MONTH, 3);
        endUtc = cal.getTime();

        outputDir.mkdirs();

        XANodeNameFactory.setInstance(new XANodeNameFactory("ktc-exporter-test"));
    }

    @After
    public void tearDown() throws Exception {
        dbService.getDdlInitializer()
            .cleanDB();
        dbService.clear();
        FileUtil.removeAll(outputDir);
    }

    @Test
    public void testEmptyKtcExport() throws Exception {
        TargetCrud targetCrud = new TargetCrud(dbService);
        LogCrud logCrud = new LogCrud(dbService);
        KtcExporter ktcExporter = new KtcExporter(targetCrud, logCrud);
        File outputFile = new File(outputDir, "ktc.txt");
        ktcExporter.export(startUtc, endUtc, outputFile, Collections.EMPTY_SET);
        BufferedReader breader = new BufferedReader(new FileReader(outputFile));
        String firstLine = breader.readLine();
        assertTrue("Got \"" + firstLine + "\".",
            firstLine.startsWith("# generated at "));
        assertEquals(null, breader.readLine());
        breader.close();
    }

    @Test
    public void testKtcExport() throws Exception {
        populateTargetTable();

        TargetCrud targetCrud = new TargetCrud(dbService);
        LogCrud logCrud = new LogCrud(dbService);
        File outputFile = new File(outputDir, "ktc.txt");
        KtcExporter ktcExporter = new KtcExporter(targetCrud, logCrud);
        ktcExporter.export(startUtc, endUtc, outputFile, Collections.EMPTY_SET);

        checkOutputFile(outputFile);
    }

    @Test
    public void complexKtcExport() throws Exception {
        TestTargetCrud targetCrud = new TestTargetCrud();
        TestLogCrud logCrud = new TestLogCrud();

        File outputFile = new File(outputDir, "ktc-complex.txt");
        KtcExporter ktcExporter = new KtcExporter(targetCrud, logCrud);
        ktcExporter.export(startUtc, endUtc, outputFile, Collections.EMPTY_SET);

        BufferedReader breader = new BufferedReader(new FileReader(outputFile));
        String headerLine = breader.readLine();
        assertTrue(headerLine.startsWith("# generated"));

        List<CompletedKtcEntry> lines = new ArrayList<CompletedKtcEntry>();
        for (String line = breader.readLine(); line != null; line = breader.readLine()) {
            CompletedKtcEntry readEntry = CompletedKtcEntry.parseInstance(line);
            lines.add(readEntry);
        }

        // Put all the long cadence results first.
        Collections.sort(lines, new Comparator<CompletedKtcEntry>() {

            @Override
            public int compare(CompletedKtcEntry o1, CompletedKtcEntry o2) {
                if (o1.targetType != o2.targetType) {
                    if (o1.targetType == TargetTable.TargetType.LONG_CADENCE) {
                        return -1;
                    } else {
                        return 1;
                    }
                }

                return o1.keplerId - o2.keplerId;
            }

        });

        // check long cadence.
        int lineIndex = 0;
        for (; lineIndex < lines.size(); lineIndex++) {
            CompletedKtcEntry readEntry = lines.get(lineIndex);
            if (readEntry.targetType != TargetType.LONG_CADENCE) {
                break;
            }

            assertTrue("LC kepler ids should contain " + readEntry.keplerId,
                targetCrud.lcKeplerIds.contains(readEntry.keplerId));
            targetCrud.lcKeplerIds.remove(readEntry.keplerId);

            assertEquals("EB", readEntry.category);

            double plannedStartTime = CompletedKtcEntry.convertToDouble(targetCrud.plannedDateList.pop());
            double plannedStopTime = CompletedKtcEntry.convertToDouble(targetCrud.plannedDateList.pop());
            assertEquals(plannedStartTime, readEntry.planStart, 0);
            assertEquals(plannedStopTime, readEntry.planStop, 0);

            double actualStart = minValue(logCrud.lcTimeList);
            double actualStop = maxValue(logCrud.lcTimeList);
            assertEquals(actualStart, readEntry.actualStart, 0);
            assertEquals(actualStop, readEntry.actualStop, 0);

            assertEquals("EX", readEntry.investigation);
        }

        // check short cadence.
        for (; lineIndex < lines.size(); lineIndex++) {
            CompletedKtcEntry readEntry = lines.get(lineIndex);
            assertEquals(TargetType.SHORT_CADENCE, readEntry.targetType);

            assertTrue(targetCrud.scKeplerIds.contains(readEntry.keplerId));
            targetCrud.scKeplerIds.remove(readEntry.keplerId);

            assertEquals("EB", readEntry.category);

            double plannedStartTime = CompletedKtcEntry.convertToDouble(targetCrud.plannedDateList.pop());
            double plannedStopTime = CompletedKtcEntry.convertToDouble(targetCrud.plannedDateList.pop());
            assertEquals(plannedStartTime, readEntry.planStart, 0);
            assertEquals(plannedStopTime, readEntry.planStop, 0);

            assertEquals(logCrud.scStartTime, readEntry.actualStart, 0);
            assertEquals(logCrud.scEndTime, readEntry.actualStop, 0);

            assertEquals("EX", readEntry.investigation);
        }

        assertTrue(targetCrud.lcKeplerIds.isEmpty());
        assertTrue(targetCrud.scKeplerIds.isEmpty());
    }

    @Ignore
    public void testKtcCli() throws Exception {
        populateTargetTable();

        TestSystemProvider testSystemProvider = new TestSystemProvider(
            this.outputDir);
        TargetCrud targetCrud = new TargetCrud();

        KtcExportCli cli = new KtcExportCli(testSystemProvider, targetCrud);
        String beginParam = dateTimeFormatter.format(startUtc);
        String endParam = dateTimeFormatter.format(endUtc);
        String cmd = "-b " + beginParam + " -e " + endParam + " -o "
            + outputDir;
        boolean parseOk = cli.parseCommandLine(cmd.split("\\s+"));
        assertTrue(parseOk);
        cli.execute();

        File[] foundFiles = outputDir.listFiles(new FilenameFilter() {

            public boolean accept(File dir, String name) {
                System.out.println("name : " + name);
                return name.matches("kplr\\d+_ktc.txt");
            }
        });

        assertEquals(1, foundFiles.length);

        checkOutputFile(foundFiles[0]);
    }

    private void checkOutputFile(File outputFile) throws Exception {
        BufferedReader breader = null;
        try {
            breader = new BufferedReader(new FileReader(outputFile));
            String firstLine = breader.readLine();
            assertTrue("Got \"" + firstLine + "\".",
                firstLine.startsWith("# generated at "));
            String targetLine = breader.readLine();
            String[] parts = targetLine.split("\\|");
            assertEquals(8, parts.length);
            assertEquals(1, Integer.parseInt(parts[0]));
            assertEquals(TargetTable.TargetType.LONG_CADENCE.ktcName(),
                parts[1]);
            assertEquals("ARP,PPA_LDE", parts[2]);

            double mjdStart = Double.parseDouble(parts[3]);
            double mjdEnd = Double.parseDouble(parts[4]);
            double actualStart = (new ModifiedJulianDate(startUtc.getTime())).getMjd();
            double actualEnd = (new ModifiedJulianDate(endUtc.getTime())).getMjd();
            assertEquals(actualStart, mjdStart, 0);
            assertEquals(actualEnd, mjdEnd, 0);
            // investigation name
            assertEquals("GO12345", parts[7]);
        } finally {
            breader.close();
        }

    }

    private void populateTargetTable() throws Exception {
        TargetCrud targetCrud = new TargetCrud(dbService);
        TargetSelectionCrud tSelectCrud = new TargetSelectionCrud(dbService);

        List<TargetList> listOfTargetList = new ArrayList<TargetList>();
        TargetList targetList1 = new TargetList("blah");
        targetList1.setCategory(SoTargetCategory.ARP.name());
        listOfTargetList.add(targetList1);

        TargetList targetList2 = new TargetList("blah2");
        targetList2.setCategory(SoTargetCategory.PPA_LDE.name());
        listOfTargetList.add(targetList2);

        List<PlannedTarget> plannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget plannedTarget = new PlannedTarget(1, 1, null);
        plannedTarget.setTargetList(targetList1);
        plannedTargets.add(plannedTarget);

        PlannedTarget plannedTarget2 = new PlannedTarget(1, 1, null);
        plannedTarget2.setTargetList(targetList2);
        plannedTargets.add(plannedTarget2);

        MaskTable maskTable = new MaskTable(MaskType.TARGET);
        maskTable.setExternalId(1);
        maskTable.setState(State.UPLINKED);

        TargetListSet targetListSet = new TargetListSet("TLSblah");
        targetListSet.setTargetLists(listOfTargetList);

        List<Mask> masks = new ArrayList<Mask>();
        Mask mask = new Mask(maskTable, new ArrayList<Offset>());
        masks.add(mask);

        TargetTable targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setExternalId(1);
        targetTable.setState(State.UPLINKED);
        targetTable.setPlannedStartTime(this.startUtc);
        targetTable.setPlannedEndTime(this.endUtc);

        targetListSet.setTargetTable(targetTable);

        List<ObservedTarget> observedTargets = new ArrayList<ObservedTarget>();
        ObservedTarget observedTarget = new ObservedTarget(targetTable, 2, 1, 1);
        observedTargets.add(observedTarget);

        List<TargetDefinition> targetDefs = new ArrayList<TargetDefinition>();
        TargetDefinition targetDef = new TargetDefinition(observedTarget);
        targetDef.setMask(mask);
        targetDefs.add(targetDef);

        observedTarget.getTargetDefinitions()
            .add(targetDef);
        observedTarget.addLabel(PlannedTarget.TargetLabel.PDQ_STELLAR);
        observedTarget.testAddLabel("GO12345");
        dbService.beginTransaction();
        tSelectCrud.create(plannedTargets);
        tSelectCrud.create(targetList1);
        tSelectCrud.create(targetList2);
        targetCrud.createMaskTable(maskTable);
        targetCrud.createMasks(masks);
        targetCrud.createTargetTable(targetTable);
        tSelectCrud.create(targetListSet);
        targetCrud.createObservedTargets(observedTargets);
        dbService.flush();
        dbService.commitTransaction();
    }

    private Double minValue(List<Double> dl) {
        Double minValue = Double.MAX_VALUE;
        for (Double d : dl) {
            if (d < minValue) {
                minValue = d;
            }
        }

        return minValue;
    }

    private Double maxValue(List<Double> dl) {
        Double maxValue = -Double.MIN_VALUE;
        for (Double d : dl) {
            if (d > maxValue) {
                maxValue = d;
            }
        }
        return maxValue;
    }

    /**
     * Generates actual times where the long cadence times are both filled in
     * and short cadence times where only the start time is filled in and the
     * end time has not been filled in, subsequent short cadence times return
     * null for both start and stop actual times.
     * 
     * @author Sean McCauliff
     * 
     */
    private class TestLogCrud extends LogCrud {

        private final LinkedList<Double> lcTimeList = new LinkedList<Double>();
        private final double scStartTime = Math.E;
        private final double scEndTime = Math.E + 1;
        private boolean scTimeStarted = false;
        private double timeCounter = Math.PI;

        TestLogCrud() {

        }

        public Pair<Double, Double> retrieveActualObservationTimeForTargetTable(
            int targetTableId, TargetTable.TargetType targetType) {
            switch (targetType) {
                case LONG_CADENCE:
                    timeCounter += 1.0;
                    double start = timeCounter;
                    timeCounter += 1.0;
                    double end = timeCounter;
                    lcTimeList.add(start);
                    lcTimeList.add(end);
                    return Pair.of(start, end);
                case SHORT_CADENCE:
                    if (scTimeStarted) {
                        return null;
                    }
                    scTimeStarted = true;
                    return Pair.of(scStartTime, scEndTime);
                case BACKGROUND:
                    return null;
                default:
                    throw new IllegalStateException(
                        "Unsupported target table type \"" + targetType + "\".");

            }
        }
    }

    private class TestTargetCrud extends TargetCrud {

        private final List<KtcInfo> ktcList = new ArrayList<KtcInfo>();
        private final Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
        private final LinkedList<Date> plannedDateList = new LinkedList<Date>();
        private final Set<Integer> lcKeplerIds = new HashSet<Integer>();
        private final Set<Integer> scKeplerIds = new HashSet<Integer>();

        TestTargetCrud() {
            int targetId = 0;

            Date plannedStart = null, plannedStop = null;

            for (int i = 0; i < 3; i++, targetId++) {
                for (int nxids = 0; nxids < 3; nxids++) {
                    plannedStart = generateDate();
                    if (nxids == 0) {
                        plannedDateList.add(plannedStart);
                    }
                    plannedStop = generateDate();
                    ktcList.add(new KtcInfo(targetId, TargetType.LONG_CADENCE,
                        plannedStart, plannedStop, targetId, nxids, 1));
                    lcKeplerIds.add(targetId);
                }
                plannedDateList.add(plannedStop);
            }

            // short cadence
            targetId = 0;
            for (int i = 0; i < 2; i++, targetId++) {
                for (int nxids = 0; nxids < 3; nxids++) {
                    plannedStart = generateDate();
                    if (nxids == 0) {
                        plannedDateList.add(plannedStart);
                    }
                    plannedStop = generateDate();
                    ktcList.add(new KtcInfo(targetId, TargetType.SHORT_CADENCE,
                        plannedStart, plannedStop, targetId, nxids, 2));
                    scKeplerIds.add(targetId);
                }
                plannedDateList.add(plannedStop);
            }

            // non merged at end.
            plannedStart = generateDate();
            plannedStop = generateDate();
            ktcList.add(new KtcInfo(targetId, TargetType.SHORT_CADENCE,
                plannedStart, plannedStop, targetId, 0, 2));
            scKeplerIds.add(targetId);
            plannedDateList.add(plannedStart);
            plannedDateList.add(plannedStop);

        }

        private Date generateDate() {
            Date genTime = calendar.getTime();
            calendar.roll(Calendar.MONTH, true);
            return genTime;
        }

        @Override
        public List<KtcInfo> retrieveKtcInfo(Date startUtc, Date stopUtc) {
            return ktcList;
        }

        @Override
        public List<Integer> retrieveOrderedExternalIds(TargetType tableType) {
            List<Integer> l = new ArrayList<Integer>();
            for (int i = 0; i < 3; i++) {
                l.add(i);
            }
            return l;
        }

        /**
         * The way this is implemented the first three targets should get
         * fragmented into different KTC entries.
         */
        @Override
        public List<String> retrieveCategoriesForTarget(long observedTargetId,
            long targetTableId) {
            if (observedTargetId < 3) {
                return Collections.singletonList(SoTargetCategory.EB.name());
            }
            return Collections.singletonList(SoTargetCategory.PLANETARY.name());
        }

        @Override
        public List<String> retrieveLabelsForObservedTarget(
            long observedTargetDbId) {
            return Collections.singletonList("B0GUS");
        }
    }

}
