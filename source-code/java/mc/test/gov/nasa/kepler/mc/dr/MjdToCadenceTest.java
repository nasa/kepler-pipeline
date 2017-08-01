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

package gov.nasa.kepler.mc.dr;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;
import gov.nasa.kepler.hibernate.dr.PixelLog.DataSetType;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.mc.MockUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

@RunWith(JMock.class)
public class MjdToCadenceTest {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(MjdToCadenceTest.class);

    private Date socIngestTime = new Date();

    private List<PixelLog> testCadenceLogs = new ArrayList<PixelLog>();

    private DispatchLog dispatchLog;

    private ReceiveLog receiveLog;

    private LogCrud logCrud;

    private DatabaseService databaseService;

    private Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private DataAnomalyOperations dataAnomalyOperations = mockery.mock(DataAnomalyOperations.class);

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        logCrud = new LogCrud(databaseService);

        databaseService.closeCurrentSession();
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testConvertMjdToCadence() throws Exception {
        createAndStoreTestCadenceLogs();

        LogCrud logCrud = new LogCrud(databaseService);
        MjdToCadence mjdToCadence = new MjdToCadence(CadenceType.LONG,
            new ModelMetadataRetrieverLatest());

        // Long cadence
        double mjd = mjdToCadence.cadenceToMjd(0);
        assertEquals(100.5, mjd, 0);
        // Test reverse cache
        int cadence = mjdToCadence.mjdToCadence(mjd);
        assertEquals(0, cadence);
        // forward cache
        mjd = mjdToCadence.cadenceToMjd(0);
        assertEquals(100.5, mjd, 0);

        cadence = mjdToCadence.mjdToCadence(102.5);
        assertEquals(1, cadence);
        mjd = mjdToCadence.cadenceToMjd(cadence);
        assertEquals(102.5, mjd, 0);
        cadence = mjdToCadence.mjdToCadence(102.5);
        assertEquals(1, cadence);

        mjdToCadence = new MjdToCadence(CadenceType.LONG,
            new ModelMetadataRetrieverLatest());
        mjdToCadence.cacheInterval(100.5, 104.5);
        assertEquals(0, mjdToCadence.mjdToCadence(100.5));
        assertEquals(1, mjdToCadence.mjdToCadence(102.5));

        MockUtils.mockDataAnomalyFlags(mockery, dataAnomalyOperations,
            CadenceType.LONG, 0, 8);

        mjdToCadence = new MjdToCadence(logCrud, dataAnomalyOperations,
            CadenceType.LONG);
        mjdToCadence.cacheInterval(1, 3);
        assertEquals(102.5, mjdToCadence.cadenceToMjd(1), 0);
        assertEquals(104.5, mjdToCadence.cadenceToMjd(2), 0);

        MjdToCadence.TimestampSeries cadenceTs = mjdToCadence.cadenceTimes(0, 8);

        assertTrue(Arrays.equals(new double[] { 100.5, 102.5, 104.5, 106.5,
            108.5, 110.5, 112.5, 114.5, 0.0 }, cadenceTs.midTimestamps));
        assertTrue(Arrays.equals(new boolean[] { false, false, false, false,
            false, false, false, false, true }, cadenceTs.gapIndicators));
        assertTrue(Arrays.equals(new boolean[] { false, true, true, true, true,
            true, true, true, false }, cadenceTs.requantEnabled));

        // Check that exists errors can be bypassed.
        assertFalse(mjdToCadence.hasCadence(2000000));
        // This should not throw an exception
        mjdToCadence.cacheInterval(Integer.MAX_VALUE - 1, Integer.MAX_VALUE,
            false);
    }

    @Test
    public void completelyEmptyTimeStampSeries() {
        MockUtils.mockDataAnomalyFlags(mockery, dataAnomalyOperations,
            CadenceType.LONG, 0, 1);

        MjdToCadence mjdToCadence = new MjdToCadence(new LogCrud(),
            dataAnomalyOperations, CadenceType.LONG);
        MjdToCadence.TimestampSeries emptyTs = mjdToCadence.cadenceTimes(0, 1,
            false);
        assertEquals(2, emptyTs.cadenceNumbers.length);
        for (boolean gapIndicator : emptyTs.gapIndicators) {
            assertTrue(gapIndicator);
        }
    }

    private void createAndStoreTestCadenceLogs() {

        databaseService.beginTransaction();

        receiveLog = new ReceiveLog(socIngestTime, "sfnm", "kplr111222333");
        logCrud.createReceiveLog(receiveLog);

        dispatchLog = new DispatchLog(receiveLog,
            DispatcherType.LONG_CADENCE_PIXEL);
        logCrud.createDispatchLog(dispatchLog);

        // long cadence
        testCadenceLogs.add(new PixelLog(dispatchLog, 0, Cadence.CADENCE_LONG,
            "20081000000", "kplr20081000000", 100D, 101D,
            /* lc table */(short) 1, /* sc table */(short) 1, /* background */
            (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 1, Cadence.CADENCE_LONG,
            "20081000030", "kplr20081000030", 102D, 103D, (short) 1, (short) 2,
            (short) 1, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 2, Cadence.CADENCE_LONG,
            "20081000100", "kplr20081000100", 104D, 105D, (short) 2, (short) 3,
            (short) 2, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 3, Cadence.CADENCE_LONG,
            "20081000130", "kplr20081000130", 106D, 107D, (short) 2, (short) 4,
            (short) 2, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 4, Cadence.CADENCE_LONG,
            "20081000200", "kplr20081000200", 108D, 109D, (short) 2, (short) 5,
            (short) 3, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 5, Cadence.CADENCE_LONG,
            "20081000230", "kplr20081000230", 110D, 111D, (short) 3, (short) 6,
            (short) 3, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 6, Cadence.CADENCE_LONG,
            "20081000300", "kplr20081000300", 112D, 113D, (short) 3, (short) 7,
            (short) 4, (short) 1, (short) 1, (short) 2));
        testCadenceLogs.add(new PixelLog(dispatchLog, 7, Cadence.CADENCE_LONG,
            "20081000300", "kplr20081000330", 114D, 115D, (short) 4, (short) 8,
            (short) 4, (short) 1, (short) 1, (short) 2));

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
    }
}
