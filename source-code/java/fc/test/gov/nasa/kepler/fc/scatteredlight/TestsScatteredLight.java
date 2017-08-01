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


package gov.nasa.kepler.fc.scatteredlight;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.fc.ScatteredLight;

import java.util.Date;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsScatteredLight {
    private static final Log log = LogFactory.getLog(TestsScatteredLight.class);

    private static DdlInitializer ddlInitializer;
	private static DatabaseService dbService;
    
    @BeforeClass
    public static void setUp() {
        // initialization code
    	dbService = DatabaseServiceFactory.getInstance();
        ddlInitializer = dbService.getDdlInitializer();
        ddlInitializer.initDB();
    }

    @AfterClass
    public static void destroyDatabase() {
        dbService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }
    
    @Test
    public void testPersist() {
        try {
        	dbService.beginTransaction();

            ScatteredLightOperations slOps = new ScatteredLightOperations();
            for ( int i = 0; i < 3; ++i ) {
                ScatteredLight sl = new ScatteredLight( 4, 1, 333.3, 444.4, 555.5 * i );
                slOps.persistScatteredLight( sl );
            }
            
            dbService.commitTransaction();
            assertTrue(true);
        } catch( Throwable throwable ) {
            log.error("Exception thrown", throwable);
        } finally {
        	dbService.rollbackTransactionIfActive();
        }
    }
    
    @Test
    public void testPersistBad() {
        try {
        	dbService.beginTransaction();

            ScatteredLightOperations slOps = new ScatteredLightOperations();
            for ( int i = 0; i < 3; ++i ) {
                ScatteredLight sl = new ScatteredLight( 99999, 99999, 333.3, 444.4, 555.5 * i );
                slOps.persistScatteredLight( sl );
            }
            
            dbService.commitTransaction();
            assertTrue(false);
        } catch( Throwable throwable ) {
        	assertTrue(true);
        } finally {
        	dbService.rollbackTransactionIfActive();
        }
    }
    
    @Test
    public void testRetrieve() {
    	try {
    		dbService.beginTransaction();
    		
    		ScatteredLightOperations slOps = new ScatteredLightOperations();
    		slOps.retrieveScatteredLight(new ScatteredLight(new Date()));
    		
    		dbService.commitTransaction();
    		assertTrue( true );
    	} catch( Throwable throwable ) {
    		log.error("Exception thrown", throwable);
    		assertTrue( false );
    	} finally {
    		dbService.rollbackTransactionIfActive();
    	} 
    	assertTrue(true);
    }
    
}
