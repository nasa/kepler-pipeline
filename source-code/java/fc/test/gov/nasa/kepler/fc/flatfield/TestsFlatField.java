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

package gov.nasa.kepler.fc.flatfield;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fc.FlatFieldModel;
import gov.nasa.kepler.fc.importer.ImporterLargeFlatField;
import gov.nasa.kepler.fc.importer.ImporterSmallFlatField;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsFlatField {
    @SuppressWarnings("unused")
	private static final Log log = LogFactory.getLog(TestsFlatField.class);

    private static int TEST_MODULE = 2;
    private static int TEST_OUTPUT = 1;

    private static double TEST_MJD = 55000.0;

    private static DdlInitializer ddlInitializer;
    private static DatabaseService dbService;

    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
        ddlInitializer = dbService.getDdlInitializer();
        ddlInitializer.initDB();

        ImporterSmallFlatField importerSmall = new ImporterSmallFlatField();
        ImporterLargeFlatField importerLarge = new ImporterLargeFlatField();
        try {
            dbService.beginTransaction();
            importerSmall.rewriteHistory(TEST_MODULE, TEST_OUTPUT, "TestsFlatField (small flat)");
            importerLarge.rewriteHistory(TEST_MODULE, TEST_OUTPUT, "TestsFlatField (large flat)");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }

    }

    @AfterClass
    public static void destroyDatabase() {
        dbService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    // public static void persistLargeFlat() throws
    // FocalPlaneException {
    // FlatFieldOperations ops = new FlatFieldOperations();
    // double[] coeffs = { 1.0 };
    // LargeFlatField largeFlatField = new LargeFlatField(TEST_MODULE,
    // TEST_OUTPUT, coeffs, coeffs, TEST_MJD);
    // ops.persistLargeFlatField(largeFlatField);
    // log.info("done");
    // }
    //    
    // @Test
    // public void testRetrieveSmallFlatImage() throws
    // FocalPlaneException {
    // try {
    // double mjd1 = TEST_MJD + 1.0;
    // double mjd2 = mjd1 + 1000.0;
    // dbService.beginTransaction();
    // FlatFieldOperations ffOps = new FlatFieldOperations();
    // // List<SmallFlatFieldDate> sffms =
    // ffOps.retrieveSmallFlatFieldDates(mjd1, mjd2);
    // SmallFlatFieldImage sffi = ffOps.retrieveSmallFlatFieldImage(mjd1,
    // TEST_MODULE, TEST_OUTPUT);
    // dbService.commitTransaction();
    //            
    // float[][] data = sffi.getData();
    // log.debug(sffi.toString());
    //
    // assertTrue(true);
    // } catch (Exception e) {
    // log.error(e);
    // assertTrue(false);
    // } finally {
    // dbService.rollbackTransactionIfActive();
    // }
    // }

//    @Test
//    public void testCrudSmallFlatImage() {
//
//        FcCrud fcCrud = new FcCrud(dbService);
//        SmallFlatFieldOperations smallFlatFieldOps = new SmallFlatFieldOperations();
//        
//        dbService.beginTransaction();
////        History history = new History(50000.0, HistoryModelName.SMALLFLATFIELD);
////        fcCrud.create(history);
//        dbService.commitTransaction();
//
//        // float[][] data = new float[][]{{2,2},{2,2}};
//        // float[][] uncert = new float[][]{{20,20},{20,20}};
//
//        // float[][] data = new
//        // float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];
//        // float[][] uncert = new
//        // float[FcConstants.CCD_ROWS][FcConstants.CCD_COLUMNS];
//
//        int x = 21;
//        float[][] data = new float[x][x];
//        float[][] uncert = new float[x][x];
//
//        for (int irow = 0; irow < x; ++irow) {
//            for (int icol = 0; icol < x; ++icol) {
//                data[irow][icol] = 11.11f;
//                uncert[irow][icol] = 0.33f;
//            }
//        }
//
//        SmallFlatFieldImage imageIn = new SmallFlatFieldImage(56789.0, 2, 1,
//            data, uncert);
////        imageIn.setHistory(history);
//
//        dbService.beginTransaction();
//        fcCrud.create(imageIn);
//        dbService.commitTransaction();
//        dbService.clear();
//        dbService.closeCurrentSession();
//
//        SmallFlatFieldImage imageOut = null;
//        dbService.beginTransaction();
////        imageOut = fcCrud.retrieveSmallFlatFieldImage(60000, 2, 1, history);
//        imageOut = smallFlatFieldOps.retrieveSmallFlatFieldImage(60000, 2, 1);
//        dbService.clear();
//        dbService.closeCurrentSession();
//
//        float imageInFlat = imageIn.getImageValue(1, 1);
//        float imageInUncert = imageIn.getUncertaintyValue(1, 1);
//        float imageOutFlat = imageOut.getImageValue(1, 1);
//        float imageOutUncert = imageOut.getUncertaintyValue(1, 1);
//
//        System.out.println(imageInFlat + " " + imageInUncert);
//        System.out.println(imageOutFlat + " " + imageOutUncert);
//
//        assertTrue(imageInFlat == imageOutFlat);
//        assertTrue(imageInUncert == imageOutUncert);
//    }
//
//    @Test
//    public void testOpsSmallFlatImage() throws
//        FocalPlaneException {
//
//        FlatFieldOperations ops = new FlatFieldOperations(dbService);
//
//        dbService.beginTransaction();
//        SmallFlatFieldImage imageOut = ops.retrieveSmallFlatFieldImage(70000,
//            2, 1);
//        dbService.clear();
//        dbService.closeCurrentSession();
//
//        float imageOutFlat = imageOut.getImageValue(1, 1);
//        float imageOutUncert = imageOut.getUncertaintyValue(1, 1);
//
//        assertTrue(imageOutFlat > .9 && imageOutFlat < 1.1);
//        assertTrue(imageOutUncert > 0.0 && imageOutUncert < 0.1);
//    }
//
//    @Test
//    public void testRawFlat() {
//        FlatFieldOperations ops = new FlatFieldOperations(dbService);
//        SmallFlatFieldImage imageOut = null;
//        try {
//            dbService.beginTransaction();
//            imageOut = ops.retrieveSmallFlatFieldImage(70000, 2, 1);
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//        dbService.clear();
//        dbService.closeCurrentSession();
//
//        float imageOutFlat = imageOut.getImageValue(1, 1);
//        float imageOutUncert = imageOut.getUncertaintyValue(1, 1);
//
//        assertTrue(imageOutFlat > .9 && imageOutFlat < 1.1);
//        assertTrue(imageOutUncert > 0.0 && imageOutUncert < 0.1);
//    }
//
//    // @Test
//    // public void testPersistLargeFlatField() throws
//    // FocalPlaneException {
//    // persistLargeFlat();
//    // }
//
//    @Test
//    public void testRetrieveLargeFlatField() {
//        try {
//            dbService.beginTransaction();
//
//            FlatFieldOperations ffOps = new FlatFieldOperations(dbService);
//            LargeFlatField flat = ffOps.retrieveLargeFlatField(TEST_MJD,
//                TEST_MODULE, TEST_OUTPUT);
//
//            dbService.commitTransaction();
//            assertTrue(true);
//        } catch (Throwable throwable) {
//            log.error(throwable);
//            assertTrue(false);
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
//
//    @Test
//    public void testGetLargeFlat() {
//        double mjd = 55000.0;
//        int module = 2;
//        int output = 1;
//        int polynomialOrder = 5;
//        String type = "standard";
//
//        int xIndex = -1;
//        double offsetX = 0.0;
//        double scaleX = 0.003;
//        double originX = 531.0;
//
//        int yIndex = -1;
//        double offsetY = 0.0;
//        double scaleY = 0.003;
//        double originY = 558.0;
//        
//        double[] coeffs = { 0.0, 0.0, 0.0, 0.0, 0.0 };
//        double[] covars = { 
//            0.0, 0.0, 0.0, 0.0, 0.0,
//            0.0, 0.0, 0.0, 0.0, 0.0,
//            0.0, 0.0, 0.0, 0.0, 0.0,
//            0.0, 0.0, 0.0, 0.0, 0.0,
//            0.0, 0.0, 0.0, 0.0, 0.0
//        };
//        
//        LargeFlatField lff = new LargeFlatField(module, output, mjd,
//            polynomialOrder, type, xIndex, offsetX, scaleX, originX, yIndex,
//            offsetY, scaleY, originY, coeffs, covars);
//        double flatValue = lff.getFlat(5, 3);
//        log.debug(flatValue);
//        assertTrue(flatValue > 0.999 && flatValue < 1.01);
//    }

    @Test
    public void testModelAll() {
        FlatFieldOperations ffOps = new FlatFieldOperations(dbService);
        FlatFieldModel model = ffOps.retrieveFlatFieldModelAll(TEST_MODULE, TEST_OUTPUT);
        assertTrue(model.toString().length() > 0);
    }

    @Test
	public void testModel() {
		FlatFieldOperations ffOps = new FlatFieldOperations(dbService);
		FlatFieldModel model = ffOps.retrieveFlatFieldModel(TEST_MJD, TEST_MJD, TEST_MODULE, TEST_OUTPUT);
		assertTrue(model.toString().length() > 0);
    }

    @Test
    public void testModelZeroWidthDateRange() {
        double date = 55555.5555;
        FlatFieldOperations ops = new FlatFieldOperations(dbService);
        @SuppressWarnings("unused")
		FlatFieldModel model = ops.retrieveFlatFieldModel(date, date, TEST_MODULE, TEST_OUTPUT);
    }

}
