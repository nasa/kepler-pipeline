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

package gov.nasa.kepler.fc.invalidpixels;

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.fc.PixelModel;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.fc.Pixel;
import gov.nasa.kepler.hibernate.fc.PixelType;

import java.util.Random;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.AfterClass;
import org.junit.BeforeClass;
import org.junit.Test;

public class TestsInvalidPixels {
	private static final Log log = LogFactory.getLog(TestsInvalidPixels.class);

	private static DdlInitializer ddlInitializer;
	private static DatabaseService dbService;

	@BeforeClass
	public static void setUpBeforeClass() {
		dbService = DatabaseServiceFactory.getInstance();
		ddlInitializer = dbService.getDdlInitializer();
		ddlInitializer.initDB();
		
		seedPixels();
	}

	@AfterClass
	public static void destroyDatabase() {
		dbService.closeCurrentSession();
		ddlInitializer.cleanDB();
	}

	@Test
	public void testPersistPixels() {
		try {
			seedPixels();
			assertTrue(true);
		} catch (Throwable throwable) {
			log.error("Exception thrown", throwable);
			assertTrue(false);
		} finally {
			dbService.rollbackTransactionIfActive();
		}
	}

	public static Pixel getRandomPixel() {
		Random rand = new Random();
		double time1 = 53000.0;
		double time2 = 60000.0;
		int randMod = FcConstants.modulesList[rand
				.nextInt(FcConstants.modulesList.length - 1)];
		int randOut = rand.nextInt(4);
		int randRow = rand.nextInt(FcConstants.nRowsImaging);
		int randCol = rand.nextInt(FcConstants.nColsImaging);
		Pixel pix = new Pixel(randMod, randOut, randRow, randCol,
				PixelType.HOT, time1, time2);
		return pix;
	}

	@Test
	public void testRetrieveRange() {
		PixelOperations pixOps = new PixelOperations();

		try {
			dbService.beginTransaction();
			Pixel outPix[] = pixOps.retrievePixelRange(4, 3, 1, 500);
			log.debug("pixel list is size " + outPix.length);
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
	public void testRetrieveType() {
        PixelOperations pixOps = new PixelOperations();

        try {
            dbService.beginTransaction();
            Pixel outPix[] = pixOps.retrievePixelRange(2, 1, 50000.0, 60000.0, PixelType.HOT);
            log.debug("pixel list is size " + outPix.length);
            dbService.commitTransaction();
            assertTrue(true);
        } catch (Exception e) {
            log.error("Exception thrown", e);
            assertTrue(false);
        } finally {
            dbService.rollbackTransactionIfActive();
        }	    
	}

	@Test
	public void testRetrieve() {
		try {
			Pixel inPix = new Pixel(PixelType.GOOD, 55500);
			PixelOperations pixOps = new PixelOperations();

			dbService.beginTransaction();
			Pixel outPix = pixOps.retrievePixel(inPix);
			dbService.commitTransaction();

			assertTrue(null != outPix);
		} catch (Throwable throwable) {
			log.error("Exception thrown", throwable);
			assertTrue(false);
		} finally {
			dbService.rollbackTransactionIfActive();
		}
	}

	@Test
	public void testRetrieveModel() {
		PixelOperations ops = new PixelOperations();
		PixelModel model = ops.retrievePixelModel(2, 1, 54000, 55000);
		assertTrue(model.getCcdRows().length > 0);
	}
	
	@Test
	public void testRetrieveModelType() {
		PixelOperations ops = new PixelOperations();
		PixelModel model = ops.retrievePixelModel(2, 1, 54000, 55000, PixelType.HOT);
		assertTrue(model.getCcdRows().length > 0);
	}

	@Test
	public void testRetrieveModelTypeString() {
		PixelOperations ops = new PixelOperations();
		PixelModel model = ops.retrievePixelModel(2, 1, 54000, 55000, "HOT");
		assertTrue(model.getCcdRows().length > 0);
	}

	
	private static void seedPixels() {
		PixelOperations pixOps = new PixelOperations();
		dbService.beginTransaction();

		for (int ii = 0; ii < 10; ++ii) {
			for (int mod : FcConstants.modulesList) {
				for (int out : FcConstants.outputsList) {
					Pixel pixel = new Pixel(mod, out, 512, 512, PixelType.HOT, 50000, 60000);
					pixOps.persistPixel(pixel);
				}
			}
		}

		dbService.commitTransaction();
	}

}
