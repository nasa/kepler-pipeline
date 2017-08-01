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

//package gov.nasa.kepler.fc.focalplaneoverview;
//
//import static org.junit.Assert.assertTrue;
//
//import gov.nasa.kepler.common.DatabaseService;
//import gov.nasa.kepler.common.PipelineException;
//import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
//
//import org.junit.Before;
//import org.junit.Test;
//
//public class TestsFocalplaneOverview {
//    private static DatabaseService dbService;
//
////    public void main(String[] args) {
////        junit.textui.TestRunner.run(new TestSuite(TestsFocalplaneOverview.class));
////    }
////
////    protected void setUp() {
////        // initialization code
////        dbService = DatabaseServiceFactory.getInstance();
////    }
////
////    protected void tearDown() {
////        // cleanup code
////    }
//
//    @Test
//    public void testLaunch() {
//        try {
//            FullFieldImageViewer ffiv = new FullFieldImageViewer();
//            assertTrue(true);
//        } catch (Throwable throwable) {
//            System.out.println(throwable.getMessage());
//            throwable.printStackTrace();
//            assertTrue(false);
//        }
//    }
//    
//    @Test
//    public void testCopyFitsFile() {
//        assertTrue(true);
//    }
//    
//    @Test
//    public void testGenerateApertures() {
//    }
//    
//    @Test
//    public void testMakeCreateImage() {
//        try {
//            for (int im = 5; im < 10; ++im) {
//                for (int io = 1; io < 4; ++io) {
//                    OutputSketch outputSketch = new OutputSketch(im, io);
//                    String command = outputSketch.makeCreateImageCommand("test string", "another test string");
//                    assertTrue(command.contains("fim2lst"));
//                }
//            }
//        } catch (Throwable throwable) {
//            throwable.printStackTrace();
//            assertTrue(false);
//        }
//    }
//    
//    @Test
//    public void testMakeCreateImageOverriden() {
//        try {
//            for (int im = 5; im < 10; ++im) {
//                for (int io = 1; io < 4; ++io) {
//                    OutputSketch outputSketch = new OutputSketch(im, io);
//                    String command = outputSketch.makeCreateImageCommand("test string");
//                    assertTrue(command.contains("fim2lst"));
//                }
//            }
//        } catch (Throwable throwable) {
//            throwable.printStackTrace();
//            assertTrue(false);
//        }
//    }
// 
//    @Test
//    public void testMakeDisplayDefaults() {
//        try{
//            for (int im = 5; im < 10; ++im) {
//                for (int io = 1; io < 4; ++io) {
//                    OutputSketch outputSketch = new OutputSketch(im, io);
//                    String command = outputSketch.makeDisplayCommand();
//                    assertTrue(command.contains("ds9"));
//                }
//            }
//        } catch (Throwable throwable) {
//            throwable.printStackTrace();
//            assertTrue(false);
//        }
//    }
// 
//    @Test
//    public void testMakeDisplayOneArg() {
//        try {
//            for (int im = 5; im < 10; ++im) {
//                for (int io = 1; io < 4; ++io) {
//                    OutputSketch outputSketch = new OutputSketch(im, io);
//                    String command = outputSketch.makeDisplayCommand("test");
//                    assertTrue(command.contains("ds9"));
//                }
//            }
//        } catch (Throwable throwable) {
//            throwable.printStackTrace();
//            assertTrue(false);
//        }
//    }
//
//    @Test
//    public void testMakeDisplayTwoArgs() {
//        try { 
//            for (int im = 5; im < 10; ++im) {
//                for (int io = 1; io < 4; ++io) {
//                    OutputSketch outputSketch = new OutputSketch(im, io);
//                    String command = outputSketch.makeDisplayCommand("test", "test");
//                    assertTrue(command.contains("ds9"));
//                }
//            }
//        } catch (Throwable throwable) {
//            throwable.printStackTrace();
//            assertTrue(false);
//        }
//    }
//
//}
