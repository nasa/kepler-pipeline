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
//import gov.nasa.kepler.fc.fitsapi.RegionOperations;
//import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
//import gov.nasa.kepler.hibernate.fc.Pixel;
//
//import java.io.File;
//import java.io.IOException;
//import java.util.Calendar;
//import java.util.Date;
//import java.util.GregorianCalendar;
//
//import junit.framework.Test;
//import junit.framework.TestCase;
//import junit.framework.TestSuite;
//
//public class TestRegions extends TestCase {
//    private static RegionOperations regionOps = null;
//    
//    public static void main(String[] args) {
//        junit.textui.TestRunner.run(suite());
//    }
//
//    public static Test suit   e() {
//        TestSuite suite = new TestSuite(TestRegions.class);
//        return suite;
//    }
//
//    protected void setUp() {
//        regionOps = new RegionOperations(DatabaseServiceFactory.getInstance());
//    }
//
//    public static void testRegion() {
//        Date start  = (new GregorianCalendar(2005, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Date stop   = (new GregorianCalendar(2008, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Pixel pixel = new Pixel(13, 4, 512, 512, Pixel.HOT_TYPE, start, stop);
//        
//        try {
//            String regionString = regionOps.getRegionTypeString(pixel);
//            System.out.println(regionString);
//            assertTrue(true);
//        } catch (Throwable t) {
//            t.printStackTrace();
//            assertTrue(false);
//        }
//    }
//
//    public static void testRegionsMultiple() {
//        Date t1 = (new GregorianCalendar(2005, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Date t2 = (new GregorianCalendar(2006, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Date t3 = (new GregorianCalendar(2007, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Date t4 = (new GregorianCalendar(2008, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        
//        Pixel[] pixels;
//        pixels = new Pixel[3];
//        pixels[0] = new Pixel(13, 4, 512, 512, Pixel.HOT_TYPE, t1, t2);
//        pixels[1] = new Pixel(13, 4, 512, 512, Pixel.HOT_TYPE, t3, t3);
//        pixels[2] = new Pixel(13, 4, 512, 512, Pixel.HOT_TYPE, t3, t4);
//        
//        try {
//            String regionString = regionOps.getRegionTypeStrings(pixels);
//            System.out.println(regionString);
//            assertTrue(true);
//        } catch (Throwable t) {
//            t.printStackTrace();
//            assertTrue(false);
//        }
//    }
//    
//    public static void testWriteRegionFileFail() {
//        Date t1 = (new GregorianCalendar(2005, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Date t2 = (new GregorianCalendar(2006, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//
//        try {
//            RegionOperations regionOps = 
//                new RegionOperations(DatabaseServiceFactory.getInstance());
//            regionOps.writeInvalidPixelRegionFile(Pixel.HOT_TYPE, t1, t2);
//            File file = new File(RegionOperations.REGION_FILENAME);
//            file.delete();
//            assertTrue(!file.exists());
//        } catch (PipelineException e) {
//            e.printStackTrace();
//            assertTrue(false);
//        }
//    }
//    
//    public static void testWriteRegionFile() {
//        Date t1 = (new GregorianCalendar(2005, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        Date t2 = (new GregorianCalendar(2006, Calendar.JANUARY, 1, 13, 56, 57)).getTime();
//        try {
//            RegionOperations regionOps = 
//                new RegionOperations(DatabaseServiceFactory.getInstance());
//            regionOps.writeInvalidPixelRegionFile(Pixel.HOT_TYPE, t1, t2);
//            File file = new File(RegionOperations.REGION_FILENAME);
//            assertTrue(file.exists());
//        } catch (PipelineException e) {
//            e.printStackTrace();
//            assertTrue(false);
//        }
//    }
//    
//    public static void testExternalCall() {
//        try {
//            Runtime rt = Runtime.getRuntime();
//            rt.exec("/path/to/ds9");
//            System.out.println(System.getProperty("os.name"));
//            assertTrue(true);
//        } catch (IOException e) {
//            e.printStackTrace();
//            assertTrue(false);
//        }
//    }
//    
//    public static void testGetApertures() {
//        try {
//            RegionOperations regionOps = 
//                new RegionOperations(DatabaseServiceFactory.getInstance());
//            regionOps.writeApertureRegionFile("fake", 666);
//            assertTrue(true);
//        } catch (PipelineException e) {
//            e.printStackTrace();
//            assertTrue(false);
//        }
//
//    }
//    
//    protected void tearDown() {
//        // cleanup code
//    }
//
//}
