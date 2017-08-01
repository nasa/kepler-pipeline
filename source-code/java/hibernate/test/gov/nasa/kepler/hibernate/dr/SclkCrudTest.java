/*
 * Copyright 2017 United States Government as represented by the
 * Administrator of the National Aeronautics and Space Administration.
 * All Rights Reserved.
 * 
 * NASA acknowledges the SETI Institute's primary role in authoring and
 * producing the Kepler Data Processing Pipeline under Cooperative
 * Agreement Nos. NNA04CC63A, NNX07AD96A, NNX07AD98A, NNX11AI13A,
 * NNX11AI14A, NNX13AD01A & NNX13AD16A.
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
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class SclkCrudTest {

    private SclkCrud sclkCrud;

    private SclkCoefficients expected1;
    private SclkCoefficients expected2;
    private SclkCoefficients expected3;
    private double expectedMjd;

    private static final long VTC_VALUE = 73000000000L * 256;

    private DatabaseService databaseService;

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {
        sclkCrud = new SclkCrud(databaseService);

        expected1 = new SclkCoefficients(null, 0.0, 6.4184000000000E+01,
            1.0000000000000E+00);
        expected2 = new SclkCoefficients(null, 7.1575159086761E+10,
            2.7959046518266E+08, 9.9730398999001E-01);
        expected3 = new SclkCoefficients(null, 7.4904899887523E+10,
            2.9259726518564E+08, 1.0001884629544E+00);
        expectedMjd = 71227.25454926994;

        // store test objects
        databaseService.beginTransaction();
        sclkCrud.createSclkCoefficients(expected1);
        sclkCrud.createSclkCoefficients(expected2);
        sclkCrud.createSclkCoefficients(expected3);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
    }

    @Test
    public void retrieveAllSclkCoefficients() throws Exception {
        populateObjects();

        try {
            databaseService.beginTransaction();

            List<SclkCoefficients> actuals = sclkCrud.retrieveAllSclkCoefficients();

            reflectionEquals.assertEquals(3, actuals.size());
            reflectionEquals.assertEquals(expected1, actuals.get(0));
            reflectionEquals.assertEquals(expected2, actuals.get(1));
            reflectionEquals.assertEquals(expected3, actuals.get(2));

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void retrieveSclkCoefficients() throws Exception {
        populateObjects();

        try {
            databaseService.beginTransaction();

            SclkCoefficients actual = sclkCrud.retrieveSclkCoefficients(7.3e10);

            reflectionEquals.assertEquals(expected2, actual);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void convertVtcToMjd() {
        populateObjects();

        try {
            databaseService.beginTransaction();

            /*
             * The on-board clock consists of two fields: SSSSSSSSSS.FFF where:
             * SSSSSSSSSS -- count of on-board seconds (top 4 bytes) FFF --
             * count of fractions of a second with one fraction being 1/256 of a
             * second (bottom byte)
             */
            long vtcValue = VTC_VALUE; // 7.3e10 seconds

            @SuppressWarnings("deprecation")
            double actual = sclkCrud.convertVtcToMjd(vtcValue);

            assertEquals("expectedMjd", expectedMjd, actual, 0.0000001);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void convertVtcToMjdExtraArgs() {
        populateObjects();

        try {
            databaseService.beginTransaction();

            /*
             * this test exercises the convertVtcToMjd method with user-supplied
             * values for the seconds since epoch, clock rate, and event time
             */

            long vtcValue = VTC_VALUE;
            double vtcTime = vtcValue / 256.0;
            SclkCoefficients sclkCoefficients = sclkCrud.retrieveSclkCoefficients(vtcTime);

            @SuppressWarnings("deprecation")
            double actual = sclkCrud.convertVtcToMjd(vtcValue,
                sclkCoefficients.getSecondsSinceEpoch(),
                sclkCoefficients.getClockRate(),
                sclkCoefficients.getVtcEventTime(), FcConstants.J2000_MJD);
            assertEquals("expectedMjd", expectedMjd, actual, 0.0000001);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

}
