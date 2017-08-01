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

package gov.nasa.kepler.mc.uow;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.PixelLog;

import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.primitives.Ints;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class TargetTableBinnerTest {

    private static final CadenceType CADENCE_TYPE = CadenceType.LONG;

    private static final int TABLE_1_START = 0;
    private static final int TABLE_1_MID = 50;
    private static final int TABLE_1_END = 99;
    private static final int TABLE_2_START = 100;
    private static final int TABLE_2_MID = 150;
    private static final int TABLE_2_END = 199;
    private static final int TABLE_3_START = 200;
    private static final int TABLE_3_MID = 250;
    private static final int TABLE_3_END = 299;

    private static final int ILLEGAL_CADENCE = -1;

    private DatabaseService databaseService = null;
    private DdlInitializer ddlInitializer = null;

    @Before
    public void setUp() {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        populatePixelLog();
    }

    @After
    public void tearDown() {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
    }

    private void populatePixelLog() {
        databaseService.beginTransaction();

        LogCrud logCrud = new LogCrud();

        // table 1
        for (int i = TABLE_1_START; i <= TABLE_1_END; i++) {
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(PixelLog.DataSetType.Target);
            pixelLog.setCadenceType(Cadence.CADENCE_LONG);
            pixelLog.setCadenceNumber(i);
            pixelLog.setLcTargetTableId((short) 1);

            logCrud.createPixelLog(pixelLog);
        }

        // table 2
        for (int i = TABLE_2_START; i <= TABLE_2_END; i++) {
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(PixelLog.DataSetType.Target);
            pixelLog.setCadenceType(Cadence.CADENCE_LONG);
            pixelLog.setCadenceNumber(i);
            pixelLog.setLcTargetTableId((short) 2);

            logCrud.createPixelLog(pixelLog);
        }

        // table 3
        for (int i = TABLE_3_START; i <= TABLE_3_END; i++) {
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(PixelLog.DataSetType.Target);
            pixelLog.setCadenceType(Cadence.CADENCE_LONG);
            pixelLog.setCadenceNumber(i);
            pixelLog.setLcTargetTableId((short) 3);

            logCrud.createPixelLog(pixelLog);
        }

        databaseService.commitTransaction();
    }

    @Test
    public void testSingleTableMatchingCadenceRange() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_1_START, TABLE_1_END), CADENCE_TYPE,
            emptyExcludeCadenceList());

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_1_START, TABLE_1_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testSingleTableDifferentCadenceRange() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_1_MID, TABLE_1_MID), CADENCE_TYPE,
            emptyExcludeCadenceList());

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_1_MID, TABLE_1_MID));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testMultipleTableMatchingCadenceRange() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_1_START, TABLE_3_END), CADENCE_TYPE,
            emptyExcludeCadenceList());

        List<CadenceUowTask> expectedTasks = ImmutableList.of(
            taskOf(TABLE_1_START, TABLE_1_END),
            taskOf(TABLE_2_START, TABLE_2_END),
            taskOf(TABLE_3_START, TABLE_3_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testMultipleTableDifferentCadenceRange() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_1_MID, TABLE_3_MID), CADENCE_TYPE,
            emptyExcludeCadenceList());

        List<CadenceUowTask> expectedTasks = ImmutableList.of(
            taskOf(TABLE_1_MID, TABLE_1_END),
            taskOf(TABLE_2_START, TABLE_2_END),
            taskOf(TABLE_3_START, TABLE_3_MID));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test(expected = IllegalStateException.class)
    public void testMultipleTableMatchingCadenceRangeOutOfOrder() {
        databaseService.beginTransaction();

        LogCrud logCrud = new LogCrud();

        // back to table 1
        for (int i = 300; i < 400; i++) {
            PixelLog pixelLog = new PixelLog();
            pixelLog.setDataSetType(PixelLog.DataSetType.Target);
            pixelLog.setCadenceType(Cadence.CADENCE_LONG);
            pixelLog.setCadenceNumber(i);
            pixelLog.setLcTargetTableId((short) 1);

            logCrud.createPixelLog(pixelLog);
        }

        databaseService.commitTransaction();

        TargetTableBinner.subdivide(taskListOf(0, 399), CADENCE_TYPE,
            emptyExcludeCadenceList());
    }

    @Test
    public void testNoTableMatchingCadenceRange() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(ILLEGAL_CADENCE, ILLEGAL_CADENCE),
            Cadence.CadenceType.LONG, emptyExcludeCadenceList());

        List<CadenceUowTask> expectedTasks = new ArrayList<CadenceUowTask>();
        assertEquals(expectedTasks, subdividedTasks);
    }

    private List<CadenceUowTask> taskListOf(int startCadence, int endCadence) {
        return ImmutableList.of(taskOf(startCadence, endCadence));
    }

    private CadenceUowTask taskOf(int startCadence, int endCadence) {
        return new CadenceUowTask(startCadence, endCadence);
    }

    @Test
    public void testExcludeSingleCadenceAtStartOfTargetTable() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_2_START, TABLE_2_END), CADENCE_TYPE,
            excludeCadenceListOf(TABLE_2_START));

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_2_START + 1, TABLE_2_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testExcludeCadencesBeforeTargetTable() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_2_START, TABLE_2_END),
            CADENCE_TYPE,
            excludeCadenceListOf(TABLE_2_START - 3, TABLE_2_START - 2,
                TABLE_2_START - 1));

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_2_START, TABLE_2_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testExcludeCadencesSurroundingStartOfTargetTable() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_2_START, TABLE_2_END),
            CADENCE_TYPE,
            excludeCadenceListOf(TABLE_2_START - 1, TABLE_2_START,
                TABLE_2_START + 1));

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_2_START + 2, TABLE_2_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testExcludeCadencesWithinTargetTable() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_2_START, TABLE_2_END), CADENCE_TYPE,
            excludeCadenceListOf(TABLE_2_MID - 1, TABLE_2_MID, TABLE_2_MID + 1));

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_2_START, TABLE_2_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testExcludeCadencesSurroundingEndOfTargetTable() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_2_START, TABLE_2_END), CADENCE_TYPE,
            excludeCadenceListOf(TABLE_2_END - 1, TABLE_2_END, TABLE_2_END + 1));

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_2_START, TABLE_2_END - 2));
        assertEquals(expectedTasks, subdividedTasks);
    }

    @Test
    public void testExcludeCadencesAfterTargetTable() {
        List<CadenceUowTask> subdividedTasks = TargetTableBinner.subdivide(
            taskListOf(TABLE_2_START, TABLE_2_END),
            CADENCE_TYPE,
            excludeCadenceListOf(TABLE_2_END + 1, TABLE_2_END + 2,
                TABLE_2_END + 3));

        List<CadenceUowTask> expectedTasks = ImmutableList.of(taskOf(
            TABLE_2_START, TABLE_2_END));
        assertEquals(expectedTasks, subdividedTasks);
    }

    private List<Integer> emptyExcludeCadenceList() {
        return excludeCadenceListOf();
    }

    private List<Integer> excludeCadenceListOf(int... ints) {
        return Ints.asList(ints);
    }

}
