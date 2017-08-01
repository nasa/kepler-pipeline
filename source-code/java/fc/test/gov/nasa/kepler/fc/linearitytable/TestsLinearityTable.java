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

package gov.nasa.kepler.fc.linearitytable;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fc.LinearityModel;
import gov.nasa.kepler.fc.importer.ImporterLinearity;
import gov.nasa.kepler.fc.linearity.LinearityOperations;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsLinearityTable {
    @SuppressWarnings("unused")
	private static final Log log = LogFactory.getLog(TestsLinearityTable.class);
    
    private static DdlInitializer ddlInitializer;
    private static DatabaseService dbService;

    @Before
    public void setUpBeforeClass() {
        dbService = DatabaseServiceFactory.getInstance();
        ddlInitializer = dbService.getDdlInitializer();
        ddlInitializer.initDB();
        try {
        	dbService.beginTransaction();
            ImporterLinearity importer = new ImporterLinearity();
            importer.rewriteHistory("TestsLinearityTable");

//        	SeedDatabaseLinearity.seedLinearity();
        	dbService.commitTransaction();
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
        	dbService.rollbackTransactionIfActive();
        }
    }

    @After
    public void destroyDatabase() {
        dbService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }
   
    @Test
    public void testModel() {
    	LinearityOperations ops = new LinearityOperations();


    	LinearityModel linearityModel = ops.retrieveLinearityModelAll(10, 1);
    	assertTrue(linearityModel.getMjds().length == linearityModel.getConstants().length);
    	assertTrue(linearityModel.getConstants().length == linearityModel.getUncertainties().length);    	

    	LinearityModel linearityModel2 = ops.retrieveLinearityModel(14, 4, 50000, 60000);
    	assertTrue(linearityModel2.getMjds().length == linearityModel2.getConstants().length);
    	assertTrue(linearityModel2.getConstants().length == linearityModel2.getUncertainties().length);    	
      	
    	LinearityModel linearityModel3 = ops.retrieveMostRecentLinearityModel(24, 1);
    	assertTrue(linearityModel3.getMjds().length == linearityModel3.getConstants().length);
    	assertTrue(linearityModel3.getConstants().length == linearityModel3.getUncertainties().length);    	
    }
    
//    @Test
//    public void testLinearityBetween() {
//        LinearityOperations ops = new LinearityOperations();
//        List<Linearity> lins = ops.retrieveLinearityBetween(2, 1, 55000.0, 56000.0);
//        assertTrue(lins.size() > 0);
//    }
//
//    @Test
//    public void testLinearitySetCoeffs() {
//        try {
//            double[] inCoeffs = { 3.14, 2.72, 6.66, 42.0 };
//            double[] uncert = {
//                0.0,  0.0,  0.0,  0.0,
//                0.0,  0.0,  0.0,  0.0, 
//                0.0,  0.0,  0.0,  0.0, 
//                0.0,  0.0,  0.0,  0.0
//            };
//            
//            int time1 = 55500;
//            Linearity lttest = new Linearity(2, 3, time1, inCoeffs, uncert);
//            double[] outCoeffs = lttest.getCoefficients();
//            assertTrue(
//                outCoeffs[0] == inCoeffs[0] &&
//                outCoeffs[1] == inCoeffs[1] &&
//                outCoeffs[2] == inCoeffs[2] &&
//                outCoeffs[3] == inCoeffs[3]);
//        } catch (Exception ex) {
//            log.error("Exception thrown", ex);
//            assertTrue(false);
//        }
//    }
//
//    @Test
//    public void testLinearityWeightedPolyval() {
//        try {
//            double[] inCoeffs = { 3.14, 2.72, 6.66, 42.0 };
//            double[] uncert = {
//                0.0,  0.0,  0.0,  0.0,
//                0.0,  0.0,  0.0,  0.0, 
//                0.0,  0.0,  0.0,  0.0, 
//                0.0,  0.0,  0.0,  0.0
//            };
//            
//            int time1 = 55500;
//            Linearity lttest = new Linearity(2, 3, time1, 1.0, 1.0, 1.0, "type", 1, 10000, inCoeffs, uncert);
//            double[] outCoeffs = lttest.getCoefficients();
//            assertTrue(
//                outCoeffs[0] == inCoeffs[0] &&
//                outCoeffs[1] == inCoeffs[1] &&
//                outCoeffs[2] == inCoeffs[2] &&
//                outCoeffs[3] == inCoeffs[3]);
//        } catch (Exception ex) {
//            log.error("Exception thrown", ex);
//            assertTrue(false);
//        }
//    }
//    
//    @Test
//    public void testLinearityPersist() {
//        try {
//
//            LinearityOperations linOps = new LinearityOperations();
//
//            double[] inCoeffsArr = new double[4];
//            double[] uncertArr = new double[16];
//            for (int ii = 0; ii < 4; ++ii) {
//                inCoeffsArr[ii] = 2.0 * ii;
//                for (int jj = 0; jj < 4; ++jj) {
//                    uncertArr[ii*jj + ii] = 0.0001;
//                }
//            }
//
//            Linearity ltPersist = new Linearity(4, 1, 500, inCoeffsArr.clone(), uncertArr.clone());
//
//            dbService.beginTransaction();
//
//            linOps.persistLinearity(ltPersist);
//            linOps.persistLinearity(4, 1, 55600.0, inCoeffsArr.clone(), uncertArr.clone());
//
//            dbService.commitTransaction();
//        } catch (Throwable ex) {
//            log.error("Exception thrown",  ex);
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
//
//    @Test
//    public void testLinearityPersistBad() {
//        try {
//            dbService.beginTransaction();
//            LinearityOperations linOps = new LinearityOperations();
//
//            double[] inCoeffsArr = new double[4];
//            double[] uncertArr = new double[16];
//            for (int ii = 0; ii < 4; ++ii) {
//                inCoeffsArr[ii] = 2.0 * ii;
//                for (int jj = 0; jj < 4; ++jj) {
//                    uncertArr[ii*jj + ii] = 0.0001;
//                }
//            }
//
//            Linearity ltPersist = new Linearity(9999, 9999, 55500.0, inCoeffsArr, uncertArr);
//
//            linOps.persistLinearity(ltPersist);
//            linOps.persistLinearity(9999, 9999, 55500.0, inCoeffsArr, uncertArr);
//            dbService.commitTransaction();
//            assertTrue(false);
//        } catch (Throwable ex) {
//            assertTrue(true);
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
//
//
//    @Test(expected=FocalPlaneException.class) 
//    public void testRetrieveNoResults() {
//        double[] inCoeffsArr = new double[4];
//        double[] uncertArr = new double[16];
//        for (int ii = 0; ii < 4; ++ii) {
//            inCoeffsArr[ii] = 2.0 * ii;
//            for (int jj = 0; jj < 4; ++jj) {
//                uncertArr[ii*jj + ii] = 0.0001;
//            }
//        }
//
//        Date farPast = (new GregorianCalendar(1492, Calendar.OCTOBER, 0, 0, 0, 0)).getTime();
//        Linearity ltRetrieve = new Linearity(4, 1, -200, inCoeffsArr, uncertArr);
//        LinearityOperations ltOps;
//        ltOps = new LinearityOperations();
//        @SuppressWarnings("unused")
//        double[] out = ltOps.retrieveLinearity(ltRetrieve);
//    }
//
//    @Test
//    public void testLinearityRetrieve() {
//        double[] inCoeffsArr = new double[4];
//        double[] uncertArr = new double[16];
//        for (int ii = 0; ii < 4; ++ii) {
//            inCoeffsArr[ii] = 2.0 * ii;
//            for (int jj = 0; jj < 4; ++jj) {
//                uncertArr[ii*jj + ii] = 0.0001;
//            }
//        }
//        try {
//            Linearity ltRetrieve = new Linearity(4, 1, 55500, inCoeffsArr, uncertArr);
//            LinearityOperations ltOps = new LinearityOperations();
//
//            double[] out = ltOps.retrieveLinearity(ltRetrieve);
//
//            for (Object val : out) {
//                log.debug(val.toString());
//            }
//            assertTrue(true);
//        } catch (Exception ex) {
//            log.error("Exception thrown", ex);
//            assertTrue(false);
//        }
//    }
//    
//    @Test
//    public void testRetrieveLinearityModel() {
//        LinearityOperations ops = new LinearityOperations();
//        LinearityModel model = ops.retrieveLinearityModel(2, 1, 50000, 60000);
//        assertTrue(true);
//    }
//
//       
//    @Test
//    public void testModelSimple() {
//        LinearityOperations ops = new LinearityOperations();
//        LinearityModel model = ops.retrieveLinearityModel(13, 3, 54000, 56000);
//        assertTrue(true);
//    }
}
