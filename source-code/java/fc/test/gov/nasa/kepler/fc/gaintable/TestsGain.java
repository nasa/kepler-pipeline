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

 package gov.nasa.kepler.fc.gaintable;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.GainModel;
import gov.nasa.kepler.fc.gain.GainOperations;
import gov.nasa.kepler.fc.importer.ImporterGain;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.Gain;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TestsGain {
    public static final Log log = LogFactory.getLog(TestsGain.class);
    
    public static Date ArborDay = (new GregorianCalendar(2006, Calendar.APRIL, 21, 12, 00, 00)).getTime(); // it's
                                                                                                            // in
    public static final Date MayDay = (new GregorianCalendar(2006, Calendar.MAY, 1, 10, 05, 59)).getTime();
    public static final Date CincoDeMayo = (new GregorianCalendar(2006, Calendar.MAY, 5, 01, 00, 00)).getTime();
    public static final Date InRange = MayDay;
    public static final Date OutOfRange = (new GregorianCalendar(2737, Calendar.OCTOBER, 13, 01, 00, 00)).getTime(); // Day Million
    
	public static double[] interpMjds = { 50000.0, 60000.0 };
	public static double[][] interpConstants = {
		{ 13.3, 13.3, 13.3, 13.3 },
		{ 14.4, 14.4, 14.4, 14.4 },
	};
	
    private static DatabaseService dbService;

    @Before
    public void setUp() {
        dbService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(dbService);
    }
   
    @After
    public void destroyDatabase() {
        TestUtils.tearDownDatabase(dbService);
    }
   
    @Test
    public void testPersistGains() {
        GainOperations gainOps = new GainOperations();

        try {
            dbService.beginTransaction();
            for (int module : FcConstants.modulesList) {
                for (int output : FcConstants.outputsList) {
                    Gain gtIn = new Gain(module, output, 3.1411592, 55000.0);
                    gainOps.persistGain(gtIn);
                }
            }
            assertTrue(true); // The persist operation was successful if we
                                // got to here
            dbService.commitTransaction();
        } catch (Exception ex) {
            log.error("Exception thrown", ex);
            assertTrue(false);
        } finally {
            dbService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testPersistGainsIndividual() {
        GainOperations gainOps = new GainOperations();

        try {
            gainOps.persistGain(4, 2, 2.7818, 57000.0);
            assertTrue(true); // The persist operation was successful if we
                                // got to here
        } catch (Exception ex) {
            log.error("Exception thrown", ex);
            assertTrue(false);
        }
    }

    @Test
    public void testPersistGainFail() {
        GainOperations gainOps = new GainOperations();

        try {
            Gain gtIn = new Gain(666, 666, 3.141592, 55000.0);
            gainOps.persistGain(gtIn);
            assertTrue(false);
        } catch (Exception ex) {
            assertTrue(true);
        }
    }

    @Test
    public void testPersistGainFail2() {
        GainOperations gainOps = new GainOperations();

        try {
            Gain gtIn = new Gain(4, 666, 3.141592, 55000.0);
            gainOps.persistGain(gtIn);
            assertTrue(false);
        } catch (Exception ex) {
            assertTrue(true);
        }
    }

    @Test
    public void testPersistGainFailIndividual() {
        GainOperations gainOps = new GainOperations();

        try {
            gainOps.persistGain(666, 666, 3.141592, 57000.0);
            assertTrue(false);
        } catch (Exception ex) {
            assertTrue(true);
        }
    }

    @Test 
    public void testModelRetrieveRange() throws IOException {
        try {
            dbService.beginTransaction();
            new ImporterGain().rewriteHistory("testModelRetrieveRange");
            dbService.commitTransaction();
        } finally {
            dbService.rollbackTransactionIfActive();
        }
        
        GainOperations gainOps = new GainOperations();
        @SuppressWarnings("unused")
		GainModel gainModel = gainOps.retrieveGainModel(50000.0, 60000.0);
        assertTrue(true);
    }
    
    @Test 
    public void testModelRetrieve() throws IOException {
        try {
            dbService.beginTransaction();
            new ImporterGain().rewriteHistory("testModelRetrieve");
            dbService.commitTransaction();
        } finally {
        	dbService.rollbackTransactionIfActive();
        }
        
        GainOperations gainOps = new GainOperations();
        @SuppressWarnings("unused")
		GainModel gainModel = gainOps.retrieveGainModelAll();
        assertTrue(true);
    }
    
    
    @Test 
    public void testModelRetrieveMostRecent() throws IOException {
        try {
            dbService.beginTransaction();
            new ImporterGain().rewriteHistory("testModelRetrieveMostRecent");
            dbService.commitTransaction();
        } finally {
        	dbService.rollbackTransactionIfActive();
        }
        GainOperations gainOps = new GainOperations();
        @SuppressWarnings("unused")
		GainModel gainModel = gainOps.retrieveMostRecentGainModel();
        assertTrue(true);
    }
    
    @Test
    public void testModelWithBrackettingTimeRequest() throws IOException {
        try {
            dbService.beginTransaction();
            new ImporterGain().rewriteHistory("testModelWithBrackettingTimeRequest");
            dbService.commitTransaction();
        } finally {
        	dbService.rollbackTransactionIfActive();
        }
        
        GainOperations gainOps = new GainOperations();
        GainModel gainModel = gainOps.retrieveGainModel(40000, 80000);
        assertTrue(gainModel.getMjds().length > 0);
        double[] mjds = gainModel.getMjds();
        assertTrue(mjds[0] > 40000);
        assertTrue(mjds[mjds.length-1] < 80000);
    }
    
    @Test
    public void testModelInterpolation() {

    	
    	GainModel model1 = new GainModel();
    	model1.setMjds(interpMjds);
    }
}
