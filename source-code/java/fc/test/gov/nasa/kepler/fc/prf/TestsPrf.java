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

package gov.nasa.kepler.fc.prf;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.fc.importer.ImporterPrf;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.Prf;

import java.io.IOException;
import java.util.Date;

import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsPrf {
    private static DatabaseService dbService;

    private static int[] modulesList = { 7, 19 };
    private static int[] outputsList = { 3 };

    @BeforeClass
    public static void setUp() throws IOException {
        dbService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(dbService);

        int numberOutputs = modulesList.length * outputsList.length;
        int n = 0;
        int[] channels = new int[numberOutputs];
        for (int ccdModule : modulesList) {
            for (int ccdOutput : outputsList) {
                channels[n++] = FcConstants.getChannelNumber(ccdModule,
                    ccdOutput);
            }
        }

        try {
            dbService.beginTransaction();
            ImporterPrf importer = new ImporterPrf();
            importer.rewriteHistory(channels, "testModelPersist");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @AfterClass
    public static void destroyDatabase() {
        TestUtils.tearDownDatabase(dbService);
    }

    @Test
    public void testPrfRetrieveCrud() {
        FcCrud fcCrud = new FcCrud();
        double now = ModifiedJulianDate.dateToMjd(new Date());

        for (int ccdModule : modulesList) {
            for (int ccdOutput : outputsList) {
                Prf prf = fcCrud.retrievePrf(now, ccdModule, ccdOutput);
                assertTrue(prf != null);
            }
        }

    }

    @Test
    public void testPrfRetrieveMostRecent() {
        PrfOperations ops = new PrfOperations();

        for (int ccdModule : modulesList) {
            for (int ccdOutput : outputsList) {
                PrfModel model = ops.retrieveMostRecentPrfModel(ccdModule,
                    ccdOutput);
                assertNotNull(model);
                assertTrue(model.getCcdModule() == ccdModule);
                assertTrue(model.getCcdOutput() == ccdOutput);
                assertTrue(model.getMjd() > 50000.0);
                assertTrue(model.getBlob().length > 1e6);
            }
        }

    }

    @Test
    public void testPrfRetrieve() {
        PrfOperations ops = new PrfOperations();
        double mjd = 60000.0;

        for (int ccdModule : modulesList) {
            for (int ccdOutput : outputsList) {
                PrfModel model = ops.retrievePrfModel(mjd, ccdModule, ccdOutput);
                assertNotNull(model);
                assertTrue(model.getCcdModule() == ccdModule);
                assertTrue(model.getCcdOutput() == ccdOutput);
                assertTrue(model.getMjd() <= mjd);
                assertTrue(model.getBlob().length > 1e6);
            }
        }

    }

}
