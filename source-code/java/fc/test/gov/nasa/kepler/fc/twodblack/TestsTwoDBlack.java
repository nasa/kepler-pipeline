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

package gov.nasa.kepler.fc.twodblack;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fc.TwoDBlackModel;
import gov.nasa.kepler.fc.importer.ImporterTwoDBlack;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.TwoDBlackImage;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsTwoDBlack {
    @SuppressWarnings("unused")
	private static final Log log = LogFactory.getLog(TestsTwoDBlack.class);

    private static DatabaseService dbService;

    private static int MODULE = 7;
    private static int OUTPUT = 3;
    
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        dbService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(dbService);
        
        try {
            dbService.beginTransaction();
            ImporterTwoDBlack importer = new ImporterTwoDBlack();
            importer.rewriteHistory(MODULE, OUTPUT, "loading test data in TestsTwoDBlack");
            dbService.commitTransaction();
            dbService.flush();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }
    
    @AfterClass
    public static void destroyDatabase() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }
    
//    @Test
//    public void testRetrieveDates(){
//    	double startTime = 55000.0;
//    	double endTime = 56000.0;
//    	List<TwoDBlackDate> dates = null;
//    	try {
//    		dbService.beginTransaction();
//    		TwoDBlackOperations ops = new TwoDBlackOperations();
//    		dates = ops.retrieveTwoDBlackDates(startTime, endTime);
//    		dbService.commitTransaction();
//    	} catch (Exception e) {
//			log.error(e);
//			assertTrue(false);
//		} finally {
//    		dbService.rollbackTransactionIfActive();
//    	}
//        assertTrue(dates != null && dates.size() > 0);
//    }
    
//    @Test
//    public void testRetrieveImage() {
//    	double startTime = 49000.0;
//    	double endTime = 56000.0;
//    	double[] mjds = null;
//    	try {
//    		
//    		dbService.beginTransaction();
//            TwoDBlackOperations ops = new TwoDBlackOperations();
//    		mjds = ops.retrieveTwoDBlackImageTimes(startTime, endTime);
//    		dbService.commitTransaction();
//    		
//    		List<TwoDBlackImage> images = new ArrayList<TwoDBlackImage>();
//    		for (double mjd : mjds) {
//    			dbService.beginTransaction();
//    			TwoDBlackImage image = ops.retrieveTwoDBlackImage(mjd, MODULE, OUTPUT); 
//        		images.add(image);
//        		dbService.commitTransaction();
//        		dbService.evict(image);
//			}
//    		assertTrue(images.size() > 0);
//    	} catch (Exception e) {
//            log.error(e);
//            e.printStackTrace();
//		} finally {
//    		dbService.rollbackTransactionIfActive();
//    	}
//    }
    
//    @Test
//    public void testConvenienceCadence() {
//        
//    	int cadenceStart = 10000;
//    	int cadenceEnd   = 40000;
//        
//    	List<TwoDBlack> tdbs = new ArrayList<TwoDBlack>();
//    	try {
//    		dbService.beginTransaction();
//    		TwoDBlackOperations ops = new TwoDBlackOperations();
//    		tdbs = ops.retrieveTwoDBlacks(MODULE, OUTPUT, cadenceStart, cadenceEnd, Cadence.CadenceType.LONG);
//    		dbService.commitTransaction();
//            dbService.evict(tdbs);
//		} finally {
//    		dbService.rollbackTransactionIfActive();
//    	}
//		assertTrue(tdbs.size() > 0);
//    }
//    	
//    @Test
//    public void testConvenienceTime() {
//    	double startTime = 55000.0;
//    	double endTime = 56000.0;
//    	List<TwoDBlack> tdbs = new ArrayList<TwoDBlack>();
//    	try {
//    		dbService.beginTransaction();
//    		TwoDBlackOperations ops = new TwoDBlackOperations();
//    		tdbs = ops.retrieveTwoDBlacks(MODULE, OUTPUT, startTime, endTime);
//    		dbService.commitTransaction();
//            dbService.evict(tdbs);
//    	} catch (PipelineException e) {
//			log.error(e);
//			assertTrue(false);
//		} finally {
//    		dbService.rollbackTransactionIfActive();
//    	}
//		assertTrue(tdbs.size() > 0);
//    }

//    @Test
//    public void testModelDatesAndRows() {
//        int[] rows = new int[50];
//        int[] cols = new int[50];
//        
//        for (int ii = 0; ii < 50; ++ii) {
//            rows[ii] = ii;
//            cols[ii] = 2 * ii;
//        }
//        try {
//            dbService.beginTransaction();
//            TwoDBlackOperations ops = new TwoDBlackOperations();
//            TwoDBlackModel model = ops.retrieveTwoDBlackModel(55000, 56000, MODULE, OUTPUT, rows, cols);
//            dbService.commitTransaction();
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
    
    @Test
    public void testModelDateRange() {
        double date1 = 55555.5555;
        double date2 = 56555.5555;
        try {
            dbService.beginTransaction();
            TwoDBlackOperations ops = new TwoDBlackOperations();
            @SuppressWarnings("unused")
			TwoDBlackModel model = ops.retrieveTwoDBlackModel(date1, date2, MODULE, OUTPUT);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }
    
    @Test
    public void testModelZeroWidthDateRange() {
        double date = 55555.5555;
        try {
            dbService.beginTransaction();
            TwoDBlackOperations ops = new TwoDBlackOperations();
            @SuppressWarnings("unused")
			TwoDBlackModel model = ops.retrieveTwoDBlackModel(date, date, MODULE, OUTPUT);
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }
    
    @Test
    public void testModelMostRecent() {
        TwoDBlackOperations ops = new TwoDBlackOperations();
        @SuppressWarnings("unused")
		TwoDBlackModel model = ops.retrieveMostRecentTwoDBlackModel(MODULE, OUTPUT);
    }
    
    
    @Test
    public void testModelAll() {
        TwoDBlackOperations ops = new TwoDBlackOperations();
        @SuppressWarnings("unused")
		TwoDBlackModel model = ops.retrieveTwoDBlackModelAll(MODULE, OUTPUT);
    }
    
//    @Test
//    public void testModelDates() {
//        try {
//            dbService.beginTransaction();
//            TwoDBlackOperations ops = new TwoDBlackOperations();
//            TwoDBlackModel model = ops.retrieveTwoDBlackModel(55000, 56000, MODULE, OUTPUT);
//            dbService.commitTransaction();
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
    
//    @Test
//    public void testModelDefault() {
//        try {
//            dbService.beginTransaction();
//            TwoDBlackOperations ops = new TwoDBlackOperations();
//            TwoDBlackModel model = ops.retrieveTwoDBlackModel(MODULE, OUTPUT);
//            dbService.commitTransaction();
//        } finally {
//            dbService.rollbackTransactionIfActive();
//        }
//    }
    
//    @SuppressWarnings("unchecked")
//	@Test
//    public void testModelTargetDefinitions() {
//        final int FAKE_KEPLER_ID = 1;
//    	List<List<TargetDefinition>> moduleOutputDefinitions = new ArrayList();
//    	
//    	ObservedTarget observedTarget = new ObservedTarget(FAKE_KEPLER_ID);
//    	List<TargetDefinition> targetDefinitions = new ArrayList<TargetDefinition>();
//    	targetDefinitions.add(new TargetDefinition(observedTarget));
//    	moduleOutputDefinitions.add(targetDefinitions);
//    	
//    	try {
//    		dbService.beginTransaction();
//    		TwoDBlackOperations ops = new TwoDBlackOperations();
//    		List<TwoDBlackModel> models = ops.retrieveTwoDBlackModels(55000, 56000, moduleOutputDefinitions);
//    		dbService.commitTransaction();
//		} finally {
//			dbService.rollbackTransactionIfActive();
//		}
//	}
    
    // TODO Why is this static and why isn't there an @Test? -bw
    public static void testBlack() {
        DatabaseService dbService = DatabaseServiceFactory.getInstance();
        TwoDBlackOperations ops = null;
        TwoDBlackImage twoDBlack= null;
        TwoDBlackModel model = null;
        
        
        dbService.beginTransaction();
        ops = new TwoDBlackOperations();
        twoDBlack = ops.retrieveTwoDBlackImage(55000, 2, 1);
        dbService.commitTransaction();
        dbService.closeCurrentSession();
        dbService.clear();
        
        
        dbService.beginTransaction();
        ops = new TwoDBlackOperations();
        model = ops.retrieveTwoDBlackModelAll(2, 1);
        dbService.commitTransaction();
        dbService.closeCurrentSession();
        dbService.clear();

        float[][][] flats = model.getBlacks();
        float[][][] uncert = model.getUncertainties();   
        
        
        TwoDBlackImage newTwoDBlack = null;
        dbService.beginTransaction();
        newTwoDBlack = ops.retrieveTwoDBlackImage(55000, 2, 1);
        dbService.commitTransaction();
        
        assertTrue(twoDBlack.getImageValue(1, 1) == flats[0][1][1]);
        assertTrue(newTwoDBlack.getImageValue(1, 1) == newTwoDBlack.getImageValue(1, 1));
        assertTrue(twoDBlack.getUncertaintyValue(1, 1) == uncert[0][1][1]);
        assertTrue(newTwoDBlack.getUncertaintyValue(1, 1) == newTwoDBlack.getUncertaintyValue(1, 1));
    }

    
}
