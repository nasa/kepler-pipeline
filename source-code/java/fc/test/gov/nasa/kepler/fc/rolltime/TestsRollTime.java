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

package gov.nasa.kepler.fc.rolltime;

import static org.junit.Assert.assertArrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.importer.ImporterRollTime;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.RollTime;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.Before;
import org.junit.Test;

public class TestsRollTime {
    /**
     * Based on 10173_01_kibrahim_roll_time/kplr2009022410_rolltime.txt.
     */
    private static final double[] ROLL_TIMES = new double[] { 54818, 54908,
        54998, 55091, 55182, 55275, 55371, 55462, 55552, 55644, 55739, 55833,
        55924, 56015, 56106, 56201 };

    /**
     * Test MJDs.
     */
    private static final double[] MJDS = new double[] { 54818, 54817, 54819,
        54908, 54907, 54909, 54953.02, 54952, 54954, 54964, 54963, 54965,
        54998, 54997, 54999, 55091, 55090, 55092, 55182, 55181, 55183, 55275,
        55274, 55276, 55371, 55370, 55372, 55462, 55461, 55463, 55552, 55551,
        55553, 55644, 55643, 55645, 55739, 55738, 55740, 55833, 55832, 55834,
        55924, 55923, 55925, 56015, 56014, 56016, 56106, 56105, 56107, 56201,
        56200, 56202 };

    /**
     * Quarter numbers that correspond to MJDS.
     */
    private static final int[] QUARTERS = new int[] { -1, -1, -1, -1, -1, -1,
        0, -1, 0, 0, 0, 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6,
        7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13,
        13, 14, 14, 14, 15 };

    private static final int SEASON = 3;

    private final Mockery mockery = new JUnit4Mockery() {
        {
            setImposteriser(ClassImposteriser.INSTANCE);
        }
    };

    private FcCrud fcCrud;
    private RollTimeOperations rollTimeOperations;
    private History history;

    @Before
    public void setUp() {
        fcCrud = mockery.mock(FcCrud.class);
        rollTimeOperations = new RollTimeOperations();
        rollTimeOperations.setFcCrud(fcCrud);
        history = new History(ModifiedJulianDate.dateToMjd(new Date()),
            HistoryModelName.ROLLTIME, "description", 1);
        rollTimeOperations.setHistory(history);
    }

    @Test
    public void testRetrieveSingleRollTime() {
        createRollTime(ROLL_TIMES[0]);
        assertEquals(ROLL_TIMES[0],
            rollTimeOperations.retrieveRollTime(ROLL_TIMES[0])
                .getMjd(), 0);
    }

    @Test
    public void testMjdToSeason() {
        RollTime rollTime = createRollTime(ROLL_TIMES[0]);
        assertEquals(rollTime.getSeason(),
            rollTimeOperations.mjdToSeason(ROLL_TIMES[0]));
    }

    @Test
    public void testMjdToQuarter() {
        createRollTimes(ROLL_TIMES);
        assertArrayEquals(QUARTERS, rollTimeOperations.mjdToQuarter(MJDS));
    }

    @Test
    public void testJdToQuarter() {
        createRollTimes(ROLL_TIMES);
        assertArrayEquals(QUARTERS,
            rollTimeOperations.jdToQuarter(mjdsToJds(MJDS)));
    }

    @Test
    public void testRetrieveMultipleRollTimes() {
        createRollTimes(ROLL_TIMES);
        assertEquals(ROLL_TIMES.length,
            rollTimeOperations.retrieveAllRollTimes()
                .size());
    }

    @Test
    public void testPersistRollTime() {
        final RollTime rollTime = new RollTime(55553.5, SEASON);
        mockery.checking(new Expectations() {
            {
                one(fcCrud).create(with(equal(rollTime)));
            }
        });
        rollTimeOperations.persistRollTime(rollTime);
    }

    @Test
    public void testRetrieveAllRollTimesModel() throws Exception {
        // TODO Rewrite FcModelFactory so that it doesn't use static methods
        // This is a problem because static methods shouldn't be talking to a
        // database, which they do and they cannot be mocked with JMock.
        // Then the following code can be replaced with a mock.
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
        try {
            databaseService.beginTransaction();
            new ImporterRollTime().rewriteHistory("TestsRollTime");
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        assertTrue(new RollTimeOperations().retrieveRollTimeModelAll()
            .size() > 1);
        TestUtils.tearDownDatabase(databaseService);
    }

    private RollTime createRollTime(final double mjd) {
        final RollTime rollTime = new RollTime(mjd, SEASON);
        mockery.checking(new Expectations() {
            {
                one(fcCrud).retrieveRollTime(with(equal(mjd)),
                    with(equal(history)));
                will(returnValue(rollTime));
            }
        });

        return rollTime;
    }

    private List<RollTime> createRollTimes(double[] mjds) {
        final List<RollTime> rollTimes = new ArrayList<RollTime>(mjds.length);
        for (double mjd : mjds) {
            rollTimes.add(new RollTime(mjd, SEASON));
        }

        mockery.checking(new Expectations() {
            {
                one(fcCrud).retrieveAllRollTimes(with(equal(history)));
                will(returnValue(rollTimes));
            }
        });

        return rollTimes;
    }

    private double[] mjdsToJds(double[] mjds) {
        double[] jds = new double[mjds.length];
        for (int i = 0; i < mjds.length; i++) {
            jds[i] = mjds[i] + ModifiedJulianDate.MJD_OFFSET_FROM_JD;
        }

        return jds;
    }
}
