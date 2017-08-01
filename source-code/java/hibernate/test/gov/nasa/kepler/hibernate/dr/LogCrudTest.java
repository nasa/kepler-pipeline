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

package gov.nasa.kepler.hibernate.dr;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.Collections;
import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class LogCrudTest {

    private List<PixelLog> testCadenceLogs;

    private Date socIngestTime = new Date();

    private DispatchLog dispatchLog;

    private List<RefPixelLog> testRefPixelLogs = newArrayList();

    private LogCrud logCrud;

    private DatabaseService databaseService;

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    private ReceiveLog receiveLog;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        logCrud = new LogCrud(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void createAndStoreTestCadenceLogs() {

        databaseService.beginTransaction();

        receiveLog = new ReceiveLog(socIngestTime, "sfnm", "kplr111222333");
        logCrud.createReceiveLog(receiveLog);

        dispatchLog = new DispatchLog(receiveLog,
            DispatcherType.LONG_CADENCE_PIXEL);
        logCrud.createDispatchLog(dispatchLog);

        // long cadence
        testCadenceLogs = newArrayList(new PixelLog(dispatchLog, /* cadnece */
            0, Cadence.CADENCE_LONG, "20081000000", "kplr20081000000", 100D,
            101D,
            /* lc table */(short) 1, /* sc table */(short) 1, /* background */
            (short) 1, (short) 1, (short) 1, (short) 2),

        new PixelLog(dispatchLog, 1, Cadence.CADENCE_LONG, "20081000030",
            "kplr20081000030", 102D, 103D, (short) 1, (short) 2, (short) 1,
            (short) 1, (short) 1, (short) 2),

        new PixelLog(dispatchLog, 2, Cadence.CADENCE_LONG, "20081000100",
            "kplr20081000100", 104D, 105D, (short) 2, (short) 3, (short) 2,
            (short) 1, (short) 1, (short) 2),

        new PixelLog(dispatchLog, 3, Cadence.CADENCE_LONG, "20081000130",
            "kplr20081000130", 106D, 107D, (short) 2, (short) 4, (short) 2,
            (short) 1, (short) 1, (short) 2),

        new PixelLog(dispatchLog, 4, Cadence.CADENCE_LONG, "20081000200",
            "kplr20081000200", 108D, 109D, (short) 2, (short) 5, (short) 3,
            (short) 1, (short) 1, (short) 2),

        new PixelLog(dispatchLog, 5, Cadence.CADENCE_LONG, "20081000230",
            "kplr20081000230", 110D, 111D, (short) 3, (short) 6, (short) 3,
            (short) 1, (short) 1, (short) 2), new PixelLog(dispatchLog, 6,
            Cadence.CADENCE_LONG, "20081000300", "kplr20081000300", 112D, 113D,
            (short) 3, (short) 7, (short) 4, (short) 1, (short) 1, (short) 2),
            new PixelLog(dispatchLog, 7, Cadence.CADENCE_LONG, "20081000300",
                "kplr20081000330", 114D, 115D, (short) 4, (short) 8, (short) 4,
                (short) 1, (short) 1, (short) 2), new PixelLog(dispatchLog,
                100, Cadence.CADENCE_LONG, "20081000400", "kplr20081000400",
                116D, 117D, (short) 5, (short) 9, (short) 5, (short) 2,
                (short) 2, (short) 3), new PixelLog(dispatchLog, 200,
                Cadence.CADENCE_LONG, "20081000450", "kplr20081000450", 118D,
                119D, (short) 5, (short) 9, (short) 5, (short) 2, (short) 2,
                (short) 3));

        int i = 0;
        for (; i < testCadenceLogs.size(); i++) {
            PixelLog pixelLog = testCadenceLogs.get(i);

            pixelLog.setDataRequantizedForDownlink(true);
            pixelLog.setDataSetType(DataSetType.Target);
        }

        testCadenceLogs.get(0)
            .setDataRequantizedForDownlink(false);

        testCadenceLogs.get(0)
            .setSpacecraftConfigId(1);

        // short cadence
        testCadenceLogs.add(new PixelLog(dispatchLog, 0, Cadence.CADENCE_SHORT,
            "20081000000", "kplr20081000000", 100.0D, 100.1D, (short) 1,
            (short) 1, (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 1, Cadence.CADENCE_SHORT,
            "20081000001", "kplr20081000001", 100.2D, 100.3D, (short) 1,
            (short) 1, (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 2, Cadence.CADENCE_SHORT,
            "20081000002", "kplr20081000002", 100.4D, 100.5D, (short) 1,
            (short) 2, (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 3, Cadence.CADENCE_SHORT,
            "20081000003", "kplr20081000003", 100.6D, 100.7D, (short) 1,
            (short) 2, (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 4, Cadence.CADENCE_SHORT,
            "20081000004", "kplr20081000004", 100.8D, 100.9D, (short) 1,
            (short) 2, (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 5, Cadence.CADENCE_SHORT,
            "20081000005", "kplr20081000005", 101.0D, 101.1D, (short) 1,
            (short) 3, (short) 1, (short) 1, (short) 1, (short) 2));
        // overlaps with second long cadence pixel log
        testCadenceLogs.add(new PixelLog(dispatchLog, 11,
            Cadence.CADENCE_SHORT, "20081000011", "kplr20081000011", 102.0D,
            102.1D, (short) 1, (short) 3, (short) 1, (short) 1, (short) 1,
            (short) 2));
        // no overlap with long cadence
        testCadenceLogs.add(new PixelLog(dispatchLog, 100,
            Cadence.CADENCE_SHORT, "20081000100", "kplr20081000100", 1000.0D,
            1000.1D, (short) 1, (short) 3, (short) 1, (short) 1, (short) 1,
            (short) 2));

        for (; i < testCadenceLogs.size(); i++) {
            testCadenceLogs.get(i)
                .setDataSetType(DataSetType.Target);
        }
        for (PixelLog cadenceLog : testCadenceLogs) {
            logCrud.createPixelLog(cadenceLog);
        }

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    private void createAndStoreTestRcLcLogs() {

        databaseService.beginTransaction();

        LogCrud logCrud = new RclcPixelLogCrud();

        ReceiveLog receiveLog = new ReceiveLog(socIngestTime, "sfnm",
            "kplr111222333");
        logCrud.createReceiveLog(receiveLog);

        DispatchLog dispatchLog = new DispatchLog(receiveLog,
            DispatcherType.RCLC_PIXEL);
        logCrud.createDispatchLog(dispatchLog);

        // long cadence
        List<RclcPixelLog> testRcLcLogs = newArrayList(new RclcPixelLog(
            dispatchLog, 0, Cadence.CADENCE_LONG, "20081000000",
            "kplr20081000000", 90D, 91D,
            /* lc table */(short) 1, /* sc table */(short) 1, /* background */
            (short) 1, (short) 1, (short) 1, (short) 2), new RclcPixelLog(
            dispatchLog, 1, Cadence.CADENCE_LONG, "20081000030",
            "kplr20081000030", 200D, 201D, (short) 1, (short) 2, (short) 1,
            (short) 1, (short) 1, (short) 2));

        for (RclcPixelLog pixelLog : testRcLcLogs) {
            pixelLog.setDataRequantizedForDownlink(true);
            pixelLog.setDataSetType(DataSetType.Target);
        }

        testRcLcLogs.get(0)
            .setDataRequantizedForDownlink(false);

        testRcLcLogs.get(0)
            .setSpacecraftConfigId(1);
        for (RclcPixelLog rclcLog : testRcLcLogs) {
            logCrud.createPixelLog(rclcLog.getPixelLog());
        }

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @Test
    public void testSpaceCraftConfigId() throws Exception {
        createAndStoreTestCadenceLogs();

        LogCrud logCrud = new LogCrud();
        List<Integer> ids = logCrud.retrieveConfigMapIds(0.0, 1e12);
        assertEquals(2, ids.size());
        assertEquals(0, (int) ids.get(0));
        assertEquals(1, (int) ids.get(1));

        ids = logCrud.retrieveConfigMapIds(CadenceType.LONG, 0.0, 1e12);
        assertEquals(2, ids.size());
        assertEquals(0, (int) ids.get(0));
        assertEquals(1, (int) ids.get(1));

        ids = logCrud.retrieveConfigMapIds(CadenceType.SHORT, 0.0, 1e12);
        assertEquals(1, ids.size());

        logCrud = new RclcPixelLogCrud();
        ids = logCrud.retrieveConfigMapIds(CadenceType.LONG, 0.0, 1e12);
        assertEquals(0, ids.size());

        createAndStoreTestRcLcLogs();

        ids = logCrud.retrieveConfigMapIds(CadenceType.LONG, 0.0, 1e12);
        assertEquals(2, ids.size());
        assertEquals(0, (int) ids.get(0));
        assertEquals(1, (int) ids.get(1));

        ids = logCrud.retrieveConfigMapIds(TargetType.LONG_CADENCE, 1);
        assertEquals(2, ids.size());
        assertEquals(0, (int) ids.get(0));
        assertEquals(1, (int) ids.get(1));
    }

    @Test
    public void testMinMaxCadence() throws Exception {
        createAndStoreTestCadenceLogs();

        LogCrud logCrud = new LogCrud(databaseService);
        Pair<Integer, Integer> firstLast = logCrud.retrieveFirstAndLastCadences(Cadence.CADENCE_LONG);
        assertEquals(0, (int) firstLast.left);
        assertEquals(200, (int) firstLast.right);

        firstLast = logCrud.retrieveFirstAndLastCadences(Cadence.CADENCE_SHORT);
        assertEquals(0, (int) firstLast.left);
        assertEquals(100, (int) firstLast.right);

    }

    @Test
    public void testRetrieveReceiveLogs() {
        databaseService.beginTransaction();

        // Nothing in the DB; should be 0.
        List<ReceiveLog> receiveLogs = logCrud.retrieveReceiveLogs(new Date(
            socIngestTime.getTime() - 5), new Date(socIngestTime.getTime() + 5));
        assertEquals(0, receiveLogs.size());
        databaseService.commitTransaction();

        createReceiveLogs();
        createDispatchLogs();
        createFileLogs();

        databaseService.beginTransaction();

        // Future; should be 0.
        receiveLogs = logCrud.retrieveReceiveLogs(
            new Date(socIngestTime.getTime() + 5),
            new Date(socIngestTime.getTime() + 10));
        assertEquals(0, receiveLogs.size());

        // Should be 1 (saved log).
        receiveLogs = logCrud.retrieveReceiveLogs(
            new Date(socIngestTime.getTime() - 5),
            new Date(socIngestTime.getTime() + 5));
        assertEquals(1, receiveLogs.size());
        assertEquals(receiveLog, receiveLogs.get(0));
        databaseService.commitTransaction();
    }

    @Test
    public void testConvertLongCadenceToShortCadence() throws Exception {
        createAndStoreTestCadenceLogs();

        // search for an empty long cadence interval
        Pair<Integer, Integer> shortInterval = logCrud.longCadenceToShortCadence(
            10000, 1000000);
        assertEquals(null, shortInterval);

        // search for an interval containing long cadences, but not short
        // cadences
        shortInterval = logCrud.longCadenceToShortCadence(2, 7);
        assertEquals(null, shortInterval);

        // single long cadence
        shortInterval = logCrud.longCadenceToShortCadence(0, 0);
        assertEquals(Pair.of(0, 4), shortInterval);

        // Short does not cover entire long interval
        shortInterval = logCrud.longCadenceToShortCadence(0, 7);
        assertEquals(Pair.of(0, 11), shortInterval);

    }

    @Test
    public void testClosestCadence() throws Exception {
        createAndStoreTestCadenceLogs();

        // Search in hole
        Pair<Integer, Integer> closestCadences = logCrud.retrieveClosestCadenceToCadence(
            55, CadenceType.LONG);

        assertEquals((Integer) 7, closestCadences.left);
        assertEquals((Integer) 100, closestCadences.right);

        // Search off high end
        closestCadences = logCrud.retrieveClosestCadenceToCadence(1000,
            CadenceType.LONG);
        assertEquals((Integer) 200, closestCadences.left);
        assertEquals(null, closestCadences.right);
    }

    @Test
    public void testConvertShortCadenceToLongCadence() throws Exception {
        createAndStoreTestCadenceLogs();

        // search for an empty short cadence interval
        Pair<Integer, Integer> longInterval = logCrud.shortCadenceToLongCadence(
            10000, 1000000);
        assertEquals(null, longInterval);

        // search for an interval containing short cadences, but not long
        // cadences
        longInterval = logCrud.shortCadenceToLongCadence(99, 100);
        assertEquals(null, longInterval);

        // multiple short cadences map to single long cadence
        longInterval = logCrud.shortCadenceToLongCadence(0, 4);
        assertEquals(Pair.of(0, 0), longInterval);

        // multiple short cadences map to multiple long cadence
        longInterval = logCrud.shortCadenceToLongCadence(0, 11);
        assertEquals(Pair.of(0, 1), longInterval);

        // Long does not cover entire short interval
        longInterval = logCrud.shortCadenceToLongCadence(0, 100);
        assertEquals(Pair.of(0, 200), longInterval);
    }

    @Test
    public void testRetrieveDispatchLogs() {
        createReceiveLogs();

        databaseService.beginTransaction();

        // Nothing in the DB; should be 0.
        List<DispatchLog> dispatchLogs = logCrud.retrieveDispatchLogs(receiveLog);
        assertEquals(0, dispatchLogs.size());
        databaseService.commitTransaction();

        createDispatchLogs();
        createFileLogs();

        databaseService.beginTransaction();

        // Should be 1 (saved log).
        dispatchLogs = logCrud.retrieveDispatchLogs(receiveLog);
        assertEquals(1, dispatchLogs.size());
        assertEquals(dispatchLog, dispatchLogs.get(0));
        databaseService.commitTransaction();
    }

    @Test
    public void testFileLogCount() {
        createReceiveLogs();
        createDispatchLogs();

        databaseService.beginTransaction();
        assertEquals(0, logCrud.fileLogCount(dispatchLog));
        databaseService.commitTransaction();

        createFileLogs();

        databaseService.beginTransaction();
        assertEquals(1, logCrud.fileLogCount(dispatchLog));
        databaseService.commitTransaction();
    }

    @Test
    public void testPixelLogCount() {
        createReceiveLogs();
        createDispatchLogs();

        databaseService.beginTransaction();
        assertEquals(0, logCrud.pixelLogCount(dispatchLog));
        databaseService.commitTransaction();

        createFileLogs();

        databaseService.beginTransaction();
        assertEquals(1, logCrud.pixelLogCount(dispatchLog));
        databaseService.commitTransaction();
    }

    private void createReceiveLogs() {
        databaseService.beginTransaction();

        receiveLog = new ReceiveLog(socIngestTime, "RPNM",
            "kplr2008347160000.sdnm");
        logCrud.createReceiveLog(receiveLog);

        databaseService.commitTransaction();
    }

    private void createDispatchLogs() {
        databaseService.beginTransaction();

        dispatchLog = new DispatchLog(receiveLog, DispatcherType.REF_PIXEL);
        logCrud.createDispatchLog(dispatchLog);

        databaseService.commitTransaction();
    }

    private void createFileLogs() {
        databaseService.beginTransaction();

        FileLog fileLog = new FileLog(dispatchLog, "foo");
        logCrud.createFileLog(fileLog);

        PixelLog pixelLog = new PixelLog(dispatchLog, 5, Cadence.CADENCE_SHORT,
            "20081000005", "kplr20081000005", 101.0D, 101.1D, (short) 1,
            (short) 3, (short) 1, (short) 1, (short) 1, (short) 2);
        logCrud.createPixelLog(pixelLog);

        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveTableActualStartStopTimes() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);

        createAndStoreTestCadenceLogs();

        Pair<Double, Double> startStopTimes = logCrud.retrieveActualObservationTimeForTargetTable(
            1, TargetTable.TargetType.LONG_CADENCE);
        assertEquals(100.0, startStopTimes.left, 0);
        assertEquals(103.0, startStopTimes.right, 0);

        startStopTimes = logCrud.retrieveActualObservationTimeForTargetTable(1,
            TargetTable.TargetType.SHORT_CADENCE);
        assertEquals(100.0, startStopTimes.left, 0);
        assertEquals(100.3, startStopTimes.right, 0);
    }

    /**
     * Stores a new set of CadenceLog instances in the db, then retrieves them
     * and makes sure they match what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testCadenceLogStoreAndRetrieve() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);

        // store
        createAndStoreTestCadenceLogs();

        // Retrieve
        databaseService.beginTransaction();

        for (PixelLog cadenceLog : testCadenceLogs) {
            PixelLog retrievedCadenceLog = logCrud.retrievePixelLog(cadenceLog.getId());
            reflectionEquals.assertEquals(
                "retrieved CadenceLog does not match stored", cadenceLog,
                retrievedCadenceLog);
        }

        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveLongCadenceTableIdsForCadenceRange()
        throws Exception {
        List<PixelLogResult> cadenceLogResult = null;

        LogCrud logCrud = new LogCrud(databaseService);

        createAndStoreTestCadenceLogs();

        databaseService.beginTransaction();

        cadenceLogResult = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, 3, 5);

        databaseService.commitTransaction();

        List<PixelLogResult> expectedCadenceLogResult = ImmutableList.of(
            new PixelLogResult((short) 2, 2, 4), new PixelLogResult((short) 3,
                5, 6));

        reflectionEquals.assertEquals(
            "retrieved CadenceLogResult list does not match expected",
            expectedCadenceLogResult, cadenceLogResult);

    }

    @Test
    public void testRetrieveShortCadenceTableIdsForCadenceRange()
        throws Exception {
        List<PixelLogResult> cadenceLogResult = null;

        LogCrud logCrud = new LogCrud(databaseService);

        createAndStoreTestCadenceLogs();

        databaseService.beginTransaction();

        cadenceLogResult = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.SHORT_CADENCE, 1, 4);

        databaseService.commitTransaction();

        List<PixelLogResult> expectedCadenceLogResult = ImmutableList.of(
            new PixelLogResult((short) 1, 0, 1), new PixelLogResult((short) 2,
                2, 4));

        reflectionEquals.assertEquals(
            "retrieved CadenceLogResult list does not match expected",
            expectedCadenceLogResult, cadenceLogResult);
    }

    @Test
    public void testRetrieveBackgroundTableIdsForCadenceRange()
        throws Exception {
        List<PixelLogResult> cadenceLogResult = null;

        LogCrud logCrud = new LogCrud(databaseService);

        createAndStoreTestCadenceLogs();

        databaseService.beginTransaction();

        cadenceLogResult = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.BACKGROUND, 3, 5);

        databaseService.commitTransaction();

        List<PixelLogResult> expectedCadenceLogResult = ImmutableList.of(
            new PixelLogResult((short) 2, 2, 3), new PixelLogResult((short) 3,
                4, 5));

        reflectionEquals.assertEquals(
            "retrieved CadenceLogResult list does not match expected",
            expectedCadenceLogResult, cadenceLogResult);

    }

    @Test
    public void testRetrievePixelLogForCadenceRange() throws Exception {
        List<PixelLog> cadenceLogs = null;

        LogCrud logCrud = new LogCrud(databaseService);

        createAndStoreTestCadenceLogs();

        databaseService.beginTransaction();

        int startCadence = 1;
        int endCadence = 3;
        cadenceLogs = logCrud.retrievePixelLog(Cadence.CADENCE_LONG,
            startCadence, endCadence);

        databaseService.commitTransaction();

        List<PixelLog> expectedCadenceLogs = ImmutableList.of(new PixelLog(
            dispatchLog, 1, Cadence.CADENCE_LONG, "20081000030",
            "kplr20081000030", 102D, 103D, (short) 1, (short) 2, (short) 1,
            (short) 1, (short) 1, (short) 2), new PixelLog(dispatchLog, 2,
            Cadence.CADENCE_LONG, "20081000100", "kplr20081000100", 104D, 105D,
            (short) 2, (short) 3, (short) 2, (short) 1, (short) 1, (short) 2),
            new PixelLog(dispatchLog, 3, Cadence.CADENCE_LONG, "20081000130",
                "kplr20081000130", 106D, 107D, (short) 2, (short) 4, (short) 2,
                (short) 1, (short) 1, (short) 2));

        for (PixelLog pxLog : expectedCadenceLogs) {
            pxLog.setDataRequantizedForDownlink(true);
            pxLog.setDataSetType(DataSetType.Target);
        }

        for (int index = 0; index < expectedCadenceLogs.size(); index++) {
            PixelLog expected = expectedCadenceLogs.get(index);
            PixelLog actual = cadenceLogs.get(index);
            reflectionEquals.excludeField(".*\\.id");
            reflectionEquals.assertEquals(
                "retrieved CadenceLog does not match expected", expected,
                actual);
        }

    }

    @Test
    public void testRetrievePixelLogsForMjd() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);
        createAndStoreTestCadenceLogs();

        // Test some empty cases first
        List<PixelLog> pixelLogs = logCrud.retrievePixelLog(
            Cadence.CADENCE_LONG, 99.0D, 99.9D);
        assertEquals(0, pixelLogs.size());

        pixelLogs = logCrud.retrievePixelLog(Cadence.CADENCE_SHORT, 102.2D,
            110.3D);
        assertEquals(0, pixelLogs.size());

        // Exact over lap
        pixelLogs = logCrud.retrievePixelLog(Cadence.CADENCE_LONG, 100.0D,
            101.0D);
        assertEquals(1, pixelLogs.size());
        PixelLog plog = pixelLogs.get(0);

        assertEquals(100.0, plog.getMjdStartTime(), 0);
        assertEquals(101.0, plog.getMjdEndTime(), 0);
        assertEquals("kplr20081000000", plog.getDatasetName());

        // Partial overlap
        pixelLogs = logCrud.retrievePixelLog(Cadence.CADENCE_LONG, 100.0, 102.5);
        assertEquals(1, pixelLogs.size());

        // All sequential logs
        pixelLogs = logCrud.retrievePixelLog(Cadence.CADENCE_SHORT, 100.0,
            101.5);
        assertEquals(6, pixelLogs.size());

        plog = pixelLogs.get(0);
        for (int i = 1; i < pixelLogs.size(); i++) {
            PixelLog next = pixelLogs.get(i);
            assertTrue(plog.getMjdStartTime() < next.getMjdStartTime());
            plog = next;
        }

        // Convert long cadence to short cadence.
        List<PixelLog> longCadences = logCrud.retrievePixelLog(
            Cadence.CADENCE_LONG, 0, 0);
        assertEquals(1, longCadences.size());
        double longStart = longCadences.get(0)
            .getMjdStartTime();
        double longEnd = longCadences.get(0)
            .getMjdEndTime();
        List<PixelLog> shortCadences = logCrud.retrievePixelLog(
            Cadence.CADENCE_SHORT, longStart, longEnd);
        assertEquals(5, shortCadences.size());
    }

    private void createAndStoreTestRefPixelLogs() {

        databaseService.beginTransaction();

        long startTimestamp = 1000;
        double startMjd = startTimestamp;
        int targetTableId = 1;
        int numberOfRefPixels = 100002;
        int compressionTableId = 1;

        ReceiveLog rpReceiveLog = new ReceiveLog(socIngestTime, "RPNM",
            "kplr2008347160000.sdnm");
        logCrud.createReceiveLog(rpReceiveLog);

        DispatchLog dispatchLog = new DispatchLog(rpReceiveLog,
            DispatcherType.REF_PIXEL);
        logCrud.createDispatchLog(dispatchLog);

        FileLog fileLog = new FileLog(dispatchLog, "foo");
        logCrud.createFileLog(fileLog);

        testRefPixelLogs.clear();

        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));

        // data from the past...
        startTimestamp = 500;
        startMjd = startTimestamp;

        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));
        testRefPixelLogs.add(new RefPixelLog(fileLog, startTimestamp++,
            targetTableId, numberOfRefPixels, compressionTableId, startMjd++));

        for (RefPixelLog refPixelLog : testRefPixelLogs) {
            logCrud.createRefPixelLog(refPixelLog);
        }

        databaseService.commitTransaction();
    }

    /**
     * Stores a new set of RefPixelLog instances in the db, then retrieves them
     * and makes sure they match what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testRefPixelLogRetrieveByTimestamp() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);

        // store
        createAndStoreTestRefPixelLogs();

        // Retrieve
        databaseService.beginTransaction();

        for (RefPixelLog refPixelLog : testRefPixelLogs) {
            RefPixelLog retrievedRefPixelLog = logCrud.retrieveRefPixelLog(refPixelLog.getTimestamp());
            reflectionEquals.assertEquals(
                "retrieved RefPixelLog does not match stored", refPixelLog,
                retrievedRefPixelLog);
        }

        databaseService.commitTransaction();
    }

    /**
     * Stores a new set of RefPixelLog instances in the db, then retrieves them
     * and makes sure they match what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testRefPixelLogRetrieveAll() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);

        // store
        createAndStoreTestRefPixelLogs();

        // Retrieve
        databaseService.beginTransaction();

        List<RefPixelLog> retrievedRefPixelLogList = logCrud.retrieveAllRefPixelLog();

        Collections.sort(testRefPixelLogs);

        for (int index = 0; index < testRefPixelLogs.size(); index++) {
            RefPixelLog expectedRefPixelLog = testRefPixelLogs.get(index);
            RefPixelLog actualRefPixelLog = retrievedRefPixelLogList.get(index);

            reflectionEquals.assertEquals(
                "retrieved RefPixelLog does not match stored",
                expectedRefPixelLog, actualRefPixelLog);
        }

        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveRefPixelLogByTimestampRange() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);

        // store
        createAndStoreTestRefPixelLogs();

        // Retrieve
        databaseService.beginTransaction();

        List<RefPixelLog> retrievedRefPixelLogList = logCrud.retrieveRefPixelLog(
            1000, 1002);

        for (int index = 0; index < 3; index++) {
            RefPixelLog expectedRefPixelLog = testRefPixelLogs.get(index);
            RefPixelLog actualRefPixelLog = retrievedRefPixelLogList.get(index);

            reflectionEquals.assertEquals(
                "retrieved RefPixelLog does not match stored",
                expectedRefPixelLog, actualRefPixelLog);
        }

        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveRefPixelLogByTargetTableId() throws Exception {
        LogCrud logCrud = new LogCrud(databaseService);

        // store
        createAndStoreTestRefPixelLogs();

        // Retrieve
        databaseService.beginTransaction();

        List<RefPixelLog> retrievedRefPixelLogList = logCrud.retrieveAllRefPixelLogForTargetTable(1);

        Collections.sort(testRefPixelLogs);

        for (int index = 0; index < testRefPixelLogs.size(); index++) {
            RefPixelLog expectedRefPixelLog = testRefPixelLogs.get(index);
            RefPixelLog actualRefPixelLog = retrievedRefPixelLogList.get(index);

            reflectionEquals.assertEquals(
                "retrieved RefPixelLog does not match stored",
                expectedRefPixelLog, actualRefPixelLog);
        }

        databaseService.commitTransaction();
    }

    @Test
    public void testDeletePixelLog() {
        DataSetType dataSetType = DataSetType.Target;
        int cadenceType = CadenceType.LONG.intValue();
        int cadenceNumber = 1;

        PixelLog pixelLog = new PixelLog();
        pixelLog.setDataSetType(dataSetType);
        pixelLog.setCadenceType(cadenceType);
        pixelLog.setCadenceNumber(cadenceNumber);

        LogCrud logCrud = new LogCrud();
        logCrud.createPixelLog(pixelLog);

        assertEquals(pixelLog, logCrud.retrievePixelLog(pixelLog.getId()));

        logCrud.deletePixelLog(dataSetType, cadenceType, cadenceNumber);

        databaseService.closeCurrentSession();

        assertEquals(null, logCrud.retrievePixelLog(pixelLog.getId()));
    }

    @Test
    public void testRetrieveFileLogsByFilename() {
        LogCrud logCrud = new LogCrud(databaseService);

        // store
        databaseService.beginTransaction();

        String filename = "kplr1234_ffi-orig.fits";
        FileLog fileLog = new FileLog(null, filename);

        logCrud.createFileLog(fileLog);

        databaseService.commitTransaction();

        // Retrieve
        databaseService.beginTransaction();

        List<FileLog> actualFileLogs = logCrud.retrieveFileLogsWhereFilenameContains("_ffi-orig.fits");

        assertEquals(1, actualFileLogs.size());

        assertEquals(filename, actualFileLogs.get(0)
            .getFilename());

        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveAllFileLogs() {
        LogCrud logCrud = new LogCrud();

        // store
        databaseService.beginTransaction();

        String filename = "kplr1234_ffi-orig.fits";
        FileLog fileLog = new FileLog(null, filename);

        logCrud.createFileLog(fileLog);

        databaseService.commitTransaction();

        // Retrieve
        databaseService.beginTransaction();

        List<FileLog> actualFileLogs = logCrud.retrieveAllFileLogs();

        assertEquals(1, actualFileLogs.size());

        assertEquals(filename, actualFileLogs.get(0)
            .getFilename());

        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveTableIdsForCadenceRangeBeforeFirstTargetTable() {
        createAndStoreTestCadenceLogs();

        List<PixelLogResult> actualResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, -10, -9);

        assertEquals(ImmutableList.of(), actualResults);
    }

    @Test
    public void testRetrieveTableIdsForCadenceRangeGapPlusTable1() {
        createAndStoreTestCadenceLogs();

        List<PixelLogResult> actualResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, -1, 0);

        List<PixelLogResult> expectedResults = ImmutableList.of(new PixelLogResult(
            (short) 1, 0, 1));

        assertEquals(expectedResults, actualResults);
    }

    @Test
    public void testRetrieveTableIdsForCadenceRangeTable4PlusGapPlusTable5() {
        createAndStoreTestCadenceLogs();

        List<PixelLogResult> actualResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, 7, 100);

        List<PixelLogResult> expectedResults = ImmutableList.of(
            new PixelLogResult((short) 4, 7, 7), new PixelLogResult((short) 5,
                100, 200));

        assertEquals(expectedResults, actualResults);
    }

    @Test
    public void testRetrieveTableIdsForCadenceRangeTable5PlusGapPlusTable5() {
        createAndStoreTestCadenceLogs();

        List<PixelLogResult> actualResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, 100, 200);

        List<PixelLogResult> expectedResults = ImmutableList.of(new PixelLogResult(
            (short) 5, 100, 200));

        assertEquals(expectedResults, actualResults);
    }

    @Test
    public void testRetrieveTableIdsForCadenceRangeTable5PlusGap() {
        createAndStoreTestCadenceLogs();

        List<PixelLogResult> actualResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, 200, 300);

        List<PixelLogResult> expectedResults = ImmutableList.of(new PixelLogResult(
            (short) 5, 100, 200));

        assertEquals(expectedResults, actualResults);
    }

    @Test
    public void testRetrieveTableIdsForCadenceRangeAfterLastTargetTable() {
        createAndStoreTestCadenceLogs();

        List<PixelLogResult> actualResults = logCrud.retrieveTableIdsForCadenceRange(
            TargetType.LONG_CADENCE, 100000000, 100000001);

        assertEquals(ImmutableList.of(), actualResults);
    }

    @Test
    public void retrieveCadenceClosestToMjd() {
        createAndStoreTestCadenceLogs();

        int cadenceNumber = logCrud.retrieveCadenceClosestToMjd(
            Cadence.CADENCE_LONG, 103.8);
        assertEquals(2, cadenceNumber);
    }

}
