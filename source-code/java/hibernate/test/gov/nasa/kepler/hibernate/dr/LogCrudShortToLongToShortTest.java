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

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.collect.Pair;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class LogCrudShortToLongToShortTest {

    private static final double DAYS_PER_SHORT_CADENCE = 0.1;

    private DatabaseService databaseService;
    private LogCrud logCrud;
    private PixelLog lplA;
    private PixelLog lplB;
    private PixelLog lplC;
    private PixelLog splA;
    private PixelLog splBFirst;
    private PixelLog splBLast;
    private PixelLog splC;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        populateObjects();
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testLplA() {
        Pair<Integer, Integer> scRange = logCrud.longCadenceToShortCadence(
            lplA.getCadenceNumber(), lplA.getCadenceNumber());
        assertEquals(Integer.valueOf(splA.getCadenceNumber()), scRange.left);
        assertEquals(Integer.valueOf(splA.getCadenceNumber()), scRange.right);
    }

    @Test
    public void testLplB() {
        Pair<Integer, Integer> scRange = logCrud.longCadenceToShortCadence(
            lplB.getCadenceNumber(), lplB.getCadenceNumber());
        assertEquals(Integer.valueOf(splBFirst.getCadenceNumber()),
            scRange.left);
        assertEquals(Integer.valueOf(splBLast.getCadenceNumber()),
            scRange.right);
    }

    @Test
    public void testLplC() {
        Pair<Integer, Integer> scRange = logCrud.longCadenceToShortCadence(
            lplC.getCadenceNumber(), lplC.getCadenceNumber());
        assertEquals(Integer.valueOf(splC.getCadenceNumber()), scRange.left);
        assertEquals(Integer.valueOf(splC.getCadenceNumber()), scRange.right);
    }

    @Test
    public void testSplA() {
        Pair<Integer, Integer> lcRange = logCrud.shortCadenceToLongCadence(
            splA.getCadenceNumber(), splA.getCadenceNumber());
        assertEquals(Integer.valueOf(lplA.getCadenceNumber()), lcRange.left);
        assertEquals(Integer.valueOf(lplA.getCadenceNumber()), lcRange.right);
    }

    @Test
    public void testSplBFirst() {
        Pair<Integer, Integer> lcRange = logCrud.shortCadenceToLongCadence(
            splBFirst.getCadenceNumber(), splBFirst.getCadenceNumber());
        assertEquals(Integer.valueOf(lplB.getCadenceNumber()), lcRange.left);
        assertEquals(Integer.valueOf(lplB.getCadenceNumber()), lcRange.right);
    }

    @Test
    public void testSplBLast() {
        Pair<Integer, Integer> lcRange = logCrud.shortCadenceToLongCadence(
            splBLast.getCadenceNumber(), splBLast.getCadenceNumber());
        assertEquals(Integer.valueOf(lplB.getCadenceNumber()), lcRange.left);
        assertEquals(Integer.valueOf(lplB.getCadenceNumber()), lcRange.right);
    }

    @Test
    public void testSplC() {
        Pair<Integer, Integer> lcRange = logCrud.shortCadenceToLongCadence(
            splC.getCadenceNumber(), splC.getCadenceNumber());
        assertEquals(Integer.valueOf(lplC.getCadenceNumber()), lcRange.left);
        assertEquals(Integer.valueOf(lplC.getCadenceNumber()), lcRange.right);
    }

    private void populateObjects() {
        lplA = new PixelLog();
        lplA.setCadenceType(CadenceType.LONG.intValue());
        lplA.setCadenceNumber(0);
        lplA.setMjdStartTime(55000);
        lplA.setMjdEndTime(55001);
        lplA.setMjdMidTime((lplA.getMjdStartTime() + lplA.getMjdEndTime()) / 2);

        lplB = new PixelLog();
        lplB.setCadenceType(CadenceType.LONG.intValue());
        lplB.setCadenceNumber(1);
        lplB.setMjdStartTime(lplA.getMjdEndTime());
        lplB.setMjdEndTime(55002);
        lplB.setMjdMidTime((lplB.getMjdStartTime() + lplB.getMjdEndTime()) / 2);

        lplC = new PixelLog();
        lplC.setCadenceType(CadenceType.LONG.intValue());
        lplC.setCadenceNumber(2);
        lplC.setMjdStartTime(lplB.getMjdEndTime());
        lplC.setMjdEndTime(55003);
        lplC.setMjdMidTime((lplC.getMjdStartTime() + lplC.getMjdEndTime()) / 2);

        splA = new PixelLog();
        splA.setCadenceType(CadenceType.SHORT.intValue());
        splA.setCadenceNumber(29);
        splA.setMjdStartTime(lplA.getMjdEndTime() - DAYS_PER_SHORT_CADENCE);
        splA.setMjdEndTime(lplA.getMjdEndTime());
        splA.setMjdMidTime((splA.getMjdStartTime() + splA.getMjdEndTime()) / 2);

        splBFirst = new PixelLog();
        splBFirst.setCadenceType(CadenceType.SHORT.intValue());
        splBFirst.setCadenceNumber(30);
        splBFirst.setMjdStartTime(lplB.getMjdStartTime());
        splBFirst.setMjdEndTime(lplB.getMjdStartTime() + DAYS_PER_SHORT_CADENCE);
        splBFirst.setMjdMidTime((splBFirst.getMjdStartTime() + splBFirst.getMjdEndTime()) / 2);

        splBLast = new PixelLog();
        splBLast.setCadenceType(CadenceType.SHORT.intValue());
        splBLast.setCadenceNumber(59);
        splBLast.setMjdStartTime(lplB.getMjdEndTime() - DAYS_PER_SHORT_CADENCE);
        splBLast.setMjdEndTime(lplB.getMjdEndTime());
        splBLast.setMjdMidTime((splBLast.getMjdStartTime() + splBLast.getMjdEndTime()) / 2);

        splC = new PixelLog();
        splC.setCadenceType(CadenceType.SHORT.intValue());
        splC.setCadenceNumber(60);
        splC.setMjdStartTime(lplC.getMjdStartTime());
        splC.setMjdEndTime(lplC.getMjdStartTime() + DAYS_PER_SHORT_CADENCE);
        splC.setMjdMidTime((splC.getMjdStartTime() + splC.getMjdEndTime()) / 2);

        databaseService.beginTransaction();
        logCrud = new LogCrud();
        logCrud.createPixelLog(lplA);
        logCrud.createPixelLog(lplB);
        logCrud.createPixelLog(lplC);
        logCrud.createPixelLog(splA);
        logCrud.createPixelLog(splBFirst);
        logCrud.createPixelLog(splBLast);
        logCrud.createPixelLog(splC);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

}
