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

package gov.nasa.kepler.fc.pointing;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fc.PointingModel;
import gov.nasa.kepler.fc.importer.ImporterPointing;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Pointing;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsPointing {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TestsPointing.class);

    @SuppressWarnings("unused")
    private static FcCrud fcCrud;
    private static DatabaseService dbService;

    @BeforeClass
    public static void setUp() {
        dbService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(dbService);
        fcCrud = new FcCrud(dbService);

        try {
            dbService.beginTransaction();
            new ImporterPointing().rewriteHistory("BeforeClass in TestsPointing");
            dbService.commitTransaction();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @AfterClass
    public static void destroyDatabase() {
        TestUtils.tearDownDatabase(dbService);
    }

    @Test
    public void testPersistPointing() {
        PointingOperations ptOps = new PointingOperations();
        Pointing pointing = new Pointing(66666.666,
            RollTime.KEPLER_FOV_CENTER_RA,
            RollTime.KEPLER_FOV_CENTER_DECLINATION,
            RollTime.KEPLER_FOV_CENTER_ROLL, 66666.666);
        ptOps.persistPointing(pointing);
    }

    // @Test
    // public void testRetrieveSinglePointing() {
    // double mjd = 56262.6;
    // PointingOperations ptOps = new PointingOperations();
    // Pointing pointing = ptOps.retrievePointing(mjd);
    //
    // assertTrue(pointing.getMjd() <= mjd);
    // }

    // @Test
    // public void testRetrieveMultiplePointingsBetween() {
    // try {
    // double startMjd = 50000.0;
    // double stopMjd = 60000.0;
    //
    // PointingOperations ptOps = new PointingOperations();
    // List<Pointing> pointings = ptOps.retrievePointingsBetween(startMjd,
    // stopMjd);
    // log.debug(pointings.size() + " is pointings size");
    // assertTrue(pointings.size() > 1);
    // } catch (Exception ex) {
    // log.error("Exception thrown", ex);
    // assertTrue(false);
    // }
    // }
    //
    // @Test
    // public void testRetrieveMultiplePointings() {
    // try {
    // double[] mjds = new double[10];
    // for (int ii = 0; ii < 10; ii++) {
    // mjds[ii] = 55000.0 + ii*10.0;
    // }
    //
    // PointingOperations ptOps = new PointingOperations();
    // Pointing[] pointings = ptOps.retrievePointings(mjds);
    //
    // // An extra pointing is returned for bracketing/interpolation:
    // //
    // assertTrue(mjds.length == pointings.length - 1);
    // } catch (Exception ex) {
    // log.error("Exception thrown", ex);
    // assertTrue(false);
    // }
    //
    // }
    //
    // @Test
    // public void testRetrieveUniquePointings() {
    // double[] mjds = new double[10];
    // Arrays.fill(mjds, 55000.00001); // not on an actual persisted pointing
    // mjd
    //
    // PointingOperations ptOps = new PointingOperations();
    // Pointing[] uniquePointings = ptOps.retrieveUniquePointings(mjds);
    //
    // assertTrue(2 == uniquePointings.length);
    // }
    //
    //
    // @Test
    // public void testRetrieveUniquePointingsMultiple() {
    // double[] mjds = { 55000.1, 55100.2, 55200.2 };
    //
    // PointingOperations ptOps = new PointingOperations();
    // Pointing[] uniquePointings = ptOps.retrieveUniquePointings(mjds);
    //
    // assertTrue(4 == uniquePointings.length);
    // }
    //
    // @Test
    // public void testRetrieveUniquePointingsSingle() {
    // double[] mjds = new double[1];
    // Arrays.fill(mjds, 55000.00001); // not on an actual persisted pointing
    // mjd
    //
    // PointingOperations ptOps = new PointingOperations();
    // Pointing[] uniquePointings = ptOps.retrieveUniquePointings(mjds);
    //
    // assertTrue(2 == uniquePointings.length);
    // }
    //
    // @Test
    // public void testRetrieveUniquePointingsSingleExactMatch() {
    // double[] mjds = new double[1];
    // Arrays.fill(mjds, 55000.0); // on an actual persisted pointing mjd
    //
    // PointingOperations ptOps = new PointingOperations();
    // Pointing[] uniquePointings = ptOps.retrieveUniquePointings(mjds);
    //
    // assertTrue(1 == uniquePointings.length);
    // }

    /**
     * Test the retrievePointingModel(double[]) API.
     * 
     * @throws PipelineException
     */
    @Test
    public void testRetrievePointingModelArray() {
        PointingOperations ptOps = new PointingOperations();
        double[] mjds = { 55000.0, 56000.0, 57000.0, 57000.1 };
        PointingModel pointingModel = ptOps.retrievePointingModel(mjds[0],
            mjds[3]);
        assertTrue(pointingModel.size() >= mjds.length);
    }

    /**
     * Test the retrievePointingModel(double, double) API (MJD time range).
     * 
     * @throws PipelineException
     */
    @Test
    public void testRetrievePointingModelRange() {
        PointingOperations ptOps = new PointingOperations();
        double mjdStart = 55000.0;
        double mjdEnd = 57000.0;

        PointingModel pointingModel = ptOps.retrievePointingModel(mjdStart,
            mjdEnd);
        assertTrue(pointingModel.size() > 1);
    }

    /**
     * Test the retrievePointingModel() API (get all pointings).
     * 
     * @throws PipelineException
     */
    @Test
    public void testRetrievePointingModelAll() {
        PointingOperations ptOps = new PointingOperations();
        PointingModel pointingModel = ptOps.retrievePointingModelAll();
        assertTrue(pointingModel.size() > 1);
    }

}
