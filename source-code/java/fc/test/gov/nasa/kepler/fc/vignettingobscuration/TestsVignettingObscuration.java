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

package gov.nasa.kepler.fc.vignettingobscuration;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fc.FocalPlaneException;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.fc.Obscuration;
import gov.nasa.kepler.hibernate.fc.Vignetting;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsVignettingObscuration {
    private static final Log log = LogFactory.getLog(TestsVignettingObscuration.class);

    private static DdlInitializer ddlInitializer;
    private static DatabaseService dbService;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
        ddlInitializer = dbService.getDdlInitializer();
        ddlInitializer.initDB();

        try {
            dbService.beginTransaction();
            // seed
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @AfterClass
    public static void tearDown() {
        dbService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    @Test
    public void testPersistVignetting() {
        dbService.beginTransaction();
        try {
            Vignetting inVin = new Vignetting(2, 2, 2, 2, 3.14159, -200, -100);
            VignettingObscurationOperations voOps = new VignettingObscurationOperations();

            voOps.persistVignetting(inVin);
            dbService.commitTransaction();

            assertTrue(true);
        } catch (Throwable throwable) {
            log.error("Exception thrown", throwable);
            assertTrue(false);
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testPersistObscuration() {
        dbService.beginTransaction();
        try {
            Obscuration inObs = new Obscuration(2, 2, 2, 2, 3.14159, 55000,
                56000);
            VignettingObscurationOperations voOps = new VignettingObscurationOperations();

            voOps.persistObscuration(inObs);
            dbService.commitTransaction();
            assertTrue(true);
        } catch (Throwable throwable) {
            log.error("Exception thrown", throwable);
            assertTrue(false);
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = FocalPlaneException.class)
    public void testPersistFailVin() {

        try {
            Vignetting vin = new Vignetting(666, 666, 2, 2, 3.14159, -200, -100);
            VignettingObscurationOperations voOps = new VignettingObscurationOperations();

            dbService.beginTransaction();
            voOps.persistVignetting(vin);
            dbService.commitTransaction();
            voOps.toString();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @Test(expected = FocalPlaneException.class)
    public void testPersistFailObs() {
        dbService.beginTransaction();
        try {
            Obscuration inObs = new Obscuration(666, 666, 2, 2, 3.14159, 55000,
                56000);
            VignettingObscurationOperations voOps = new VignettingObscurationOperations();
            voOps.persistObscuration(inObs);
            dbService.commitTransaction();

            assertTrue(false);
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testRetrieveVignettingObscuration() {
        try {
            VignettingObscurationOperations voOps = new VignettingObscurationOperations();

            dbService.beginTransaction();
            double value = voOps.retrieveVignettingObscurationValue(55500);
            dbService.commitTransaction();

            assertTrue(value > 0.0);
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

}
