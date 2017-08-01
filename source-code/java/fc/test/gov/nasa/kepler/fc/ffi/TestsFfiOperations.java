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

//package gov.nasa.kepler.fc.ffi;
//
//import gov.nasa.kepler.common.PipelineException;
//import gov.nasa.kepler.fc.fitsapi.FfiOperations;
//import gov.nasa.kepler.fs.api.FileStoreClient;
//import gov.nasa.kepler.fs.api.FsId;
//import gov.nasa.kepler.fs.client.FileStoreClientFactory;
//import gov.nasa.kepler.fs.id.DrFsIdFactory;
//import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
//
//import java.io.File;
//import java.io.FileNotFoundException;
//import java.io.IOException;
//import java.util.List;
//import java.util.Random;
//
//import junit.framework.Test;
//import junit.framework.TestCase;
//import junit.framework.TestSuite;
//
//import org.apache.commons.configuration.Configuration;
//
//public class TestsFfiOperations extends TestCase {
//	private static String goodName = "ffi/fake_ffi_from_TestFitsApi.java.fits";
//	private static String badName = "notThere.orAnywhere";
//	private static String outputFilename = "/path/to/testOutput.data";
//	private static FsId fsId;
//
//	public static void main(String[] args) {
//		junit.textui.TestRunner.run(suite());
//	}
//	
//	public static Test suite() {
//		TestSuite suite = new TestSuite(TestsFfiOperations.class);
//		return suite;
//	}
//
//	/**
//	 * Write a test file to the filestore if it doesn't already exist. 
//	 * @throws PipelineException 
//	 */
//	protected void setUp()  {
//        
//		fsId = DrFsIdFactory.getFfiFile(goodName);
//		FfiOperations ffiOperations;
//
//		FileStoreClient fsClient;
//        try {
//            ffiOperations = new FfiOperations(DatabaseServiceFactory.getInstance());
//            Configuration config = ffiOperations.getConfig();
//            fsClient = FileStoreClientFactory.getInstance(config);
//
//
//            if (!fsClient.blobExists(fsId)) {
//                Random rand = new Random();
//                int numElems = 1024;
//                byte[] fileData = new byte[numElems];
//                rand.nextBytes(fileData);
//
//                int origin = 666;
//                fsClient.writeBlob(fsId, origin, fileData);
//            }
//        } catch (PipelineException e) {
//            e.printStackTrace();
//        }
//	}
//
//	protected void tearDown() {
//		// cleanup code
//	}
//
////	/**
////	 * Test grabbing a file out of the filestore.
////	 *
////	 */
////	public static void testFileRead() {
////		FileStoreClient fsClient = null;
////		try {
////			FfiOperations fitsApi = new FfiOperations();
////			fsClient = FileStoreClientFactory.getInstance(fitsApi.getConfig());
////			
////			BlobResult myFfi = new BlobResult();
////			myFfi = fitsApi.getFfi(new FsId(name));
////			
////			assertTrue(true);
////		} catch (PipelineException e) {
////			e.printStackTrace();
////			assertTrue(false);
////		}
////	}
//	
//	/**
//	 * Test getting a file out of the filestore and writing it locally.
//	 *
//	 */
//	public static void testWriteFfi() {
//		FileStoreClient fsClient = null;
//		try {
//			
//			// Get file as a BlobResult:
//			//
//			FfiOperations ffiOperations =
//			    new FfiOperations(DatabaseServiceFactory.getInstance());
//			ffiOperations.copyFfiToLocal(goodName, outputFilename);
//			
//			// Verify the file exists:
//			//
//			File testFile = new File(outputFilename);
//			assertTrue(testFile.exists());
//		} catch (PipelineException pe) {
//			pe.printStackTrace();
//			assertTrue(false); 
//		} catch (FileNotFoundException fe) {
//			fe.printStackTrace();
//			assertTrue(false); 
//		} catch (IOException ie) {
//			ie.printStackTrace();
//			assertTrue(false);
//		}
//	}
//	
//	/**
//	 * Test the failure mode for a nonexistent file
//	 *
//	 */
//	public static void testSaveLocalCopyFail() {
//		FileStoreClient fsClient = null;
//		try {
//			// Get file as a BlobResult:
//			//
//			FfiOperations ffiOperations = 
//                new FfiOperations(DatabaseServiceFactory.getInstance());
//			ffiOperations.copyFfiToLocal(badName, outputFilename);
//			assertTrue(false);
//		} catch (PipelineException pe) {
//			assertTrue(true);
//		} catch (IOException e) {
//			assertTrue(false);
//		}
//	}
//    
//    public static void testGetAllFfis() {
//        FfiOperations ffiOperations;
//        try {
//            ffiOperations = 
//                new FfiOperations(DatabaseServiceFactory.getInstance());
//            List<String> ffiNames = ffiOperations.getFfiList();
//            if (ffiNames.size() > 0) {
//                assertTrue(false);
//            } else {
//                assertTrue(true);
//            }
//        } catch (PipelineException e) {
//            e.printStackTrace();
//            assertTrue(false);
//        }
//    }
//
//}
