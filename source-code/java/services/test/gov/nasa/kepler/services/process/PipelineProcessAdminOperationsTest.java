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

package gov.nasa.kepler.services.process;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.process.PipelineProcessAdminRequest.BasicRequestType;

import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * @author tklaus
 *
 */
public class PipelineProcessAdminOperationsTest {
    //private static final Log log = LogFactory.getLog(PipelineProcessAdminOperationsTest.class);

    private static final String PROCESS_NAME = "MyTestProcess";
    private static final String PROCESS_HOST = "MyHost";

    /**
     * @throws java.lang.Exception
     */
    @BeforeClass
    public static void setUpBeforeClass() throws Exception {
        System.setProperty("jms.url", "vm://host");
        MessagingServiceFactory.getInstance();
    }

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
    }

    /**
     * Test method for {@link gov.nasa.kepler.services.process.PipelineProcessAdminOperations#pause(java.lang.String, boolean)}.
     * @throws Exception 
     */
    @Test
    public void testPause() throws Exception {

        PipelineProcessAdminListener adminListener = new PipelineProcessAdminListener(PROCESS_NAME, PROCESS_HOST);
        adminListener.start();
        adminListener.waitForReadyToProcess();
        
        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();        
        TestAdminRequest request = new TestAdminRequest(BasicRequestType.PAUSE, true);
        TestAdminResponse response = (TestAdminResponse) ops.adminRequest(PROCESS_NAME, PROCESS_HOST, request);
        
        assertTrue("response.isSuccessful()", response.isSuccessful());
        
        assertTrue("got pause message", response.paused);
        assertFalse("DID NOT get resume message", response.resume);
        assertFalse("DID NOT get restart message", response.restart);
        assertFalse("DID NOT get shutdown message", response.shutdown);
        assertTrue("abortCurrentJobs", response.abortCurrentJobs);
        
        adminListener.shutdown();
    }

    /**
     * Test method for {@link gov.nasa.kepler.services.process.PipelineProcessAdminOperations#resume(java.lang.String)}.
     * @throws Exception 
     */
    @Test
    public void testResume() throws Exception {
        PipelineProcessAdminListener adminListener = new PipelineProcessAdminListener(PROCESS_NAME, PROCESS_HOST);
        adminListener.start();
        adminListener.waitForReadyToProcess();
        
        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();        
        TestAdminRequest request = new TestAdminRequest(BasicRequestType.RESUME);
        TestAdminResponse response = (TestAdminResponse) ops.adminRequest(PROCESS_NAME, PROCESS_HOST, request);
        
        assertTrue("response.isSuccessful()", response.isSuccessful());
        
        assertFalse("DID NOT got pause message", response.paused);
        assertTrue("got resume message", response.resume);
        assertFalse("DID NOT get restart message", response.restart);
        assertFalse("DID NOT get shutdown message", response.shutdown);
        assertFalse("abortCurrentJobs", response.abortCurrentJobs);
        
        adminListener.shutdown();
    }

    /**
     * Test method for {@link gov.nasa.kepler.services.process.PipelineProcessAdminOperations#shutdown(java.lang.String, boolean)}.
     * @throws Exception 
     */
    @Test
    public void testShutdown() throws Exception {
        PipelineProcessAdminListener adminListener = new PipelineProcessAdminListener(PROCESS_NAME, PROCESS_HOST);
        adminListener.start();
        adminListener.waitForReadyToProcess();
        
        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();        
        TestAdminRequest request = new TestAdminRequest(BasicRequestType.SHUTDOWN, true);
        TestAdminResponse response = (TestAdminResponse) ops.adminRequest(PROCESS_NAME, PROCESS_HOST, request);
        
        assertTrue("response.isSuccessful()", response.isSuccessful());
        
        assertFalse("DID NOT get pause message", response.paused);
        assertFalse("DID NOT get resume message", response.resume);
        assertFalse("DID NOT get restart message", response.restart);
        assertTrue("got shutdown message", response.shutdown);
        assertTrue("abortCurrentJobs", response.abortCurrentJobs);
        
        adminListener.shutdown();
    }

    /**
     * Test method for {@link gov.nasa.kepler.services.process.PipelineProcessAdminOperations#restart(java.lang.String, boolean)}.
     * @throws Exception 
     */
    @Test
    public void testRestart() throws Exception {
        PipelineProcessAdminListener adminListener = new PipelineProcessAdminListener(PROCESS_NAME, PROCESS_HOST);
        adminListener.start();
        adminListener.waitForReadyToProcess();
        
        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();    
        TestAdminRequest request = new TestAdminRequest(BasicRequestType.RESTART, true);
        TestAdminResponse response = (TestAdminResponse) ops.adminRequest(PROCESS_NAME, PROCESS_HOST, request);
        
        assertTrue("response.isSuccessful()", response.isSuccessful());
        
        assertFalse("DID NOT get pause message", response.paused);
        assertFalse("DID NOT get resume message", response.resume);
        assertTrue("got restart message", response.restart);
        assertFalse("DID NOT get shutdown message", response.shutdown);
        assertTrue("abortCurrentJobs", response.abortCurrentJobs);
        
        adminListener.shutdown();
    }

}
