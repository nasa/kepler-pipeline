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

package gov.nasa.kepler.pi.pipeline;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.fs.client.util.DiskFileStoreClient;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.kepler.pi.worker.EmbeddedWorkerCluster;
import gov.nasa.kepler.pi.worker.WorkerTaskRequestDispatcher;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.integration.junit4.JUnit4Mockery;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * This feature test is intended to exercise the pipeline
 * trigger, launch, and transition logic.  It covers the
 * following components:
 *  - execution logic (including {@link PipelineExecutor})
 *  - trigger logic
 *  - worker task dispatcher logic {@link WorkerTaskRequestDispatcher}
 *  - pipeline CRUD classes.
 * 
 * TODO: add non-fatal exception test case
 * TODO: add other exception test case
 * TODO: add test case for PipelineTask not in db
 * 
 * The following components are mocked:
 *  - File store
 *  
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@RunWith(JMock.class)
public class PipelineExecutorFeatureTest {

    private static final int NUM_UOW_TASKS = 2;
    private static final String TEST_TRIGGER_NAME_1 = "Test trigger def";
    private static final boolean USE_XA_TRANSACTIONS = false;
    
    private DatabaseService databaseService = null;
    private DdlInitializer ddlInitializer = null;

    private UserCrud userCrud;

    private User adminUser;
    private User operatorUser;

    @SuppressWarnings("unused")
    private PipelineDefinitionNode n1;
    private PipelineDefinitionNode n2;
    private PipelineDefinitionNode n3;
    @SuppressWarnings("unused")
    private PipelineDefinitionNode n4;
    
    @SuppressWarnings("unused")
    private Mockery context = new JUnit4Mockery() {{
        setImposteriser(ClassImposteriser.INSTANCE);
    }};
    
    @BeforeClass
    public static void beforeClassSetup() throws IOException{
        // clean messaging
        FileUtil.cleanDir(FilenameConstants.ACTIVEMQ_DATA);
    }

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     * @throws ClassNotFoundException
     * @throws IOException
     */
    @Before
    public void setUp() throws SQLException,
        ClassNotFoundException, IOException {

        // no MATLAB binaries needed for this test
        System.setProperty(EmbeddedWorkerCluster.REFRESH_MBIN_PROP, "false");

        TransactionServiceFactory.setXa(USE_XA_TRANSACTIONS);
        MessagingServiceFactory.setUseXa(USE_XA_TRANSACTIONS);
        DatabaseServiceFactory.setUseXa(USE_XA_TRANSACTIONS);
        
        databaseService = DatabaseServiceFactory.getInstance(false);
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        userCrud = new UserCrud(databaseService);
        
        DiskFileStoreClient fakeClient = new DiskFileStoreClient();
        FileStoreClientFactory.setInstance(fakeClient);
    }

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     */
    @After
    public void tearDown() throws SQLException {
        if (databaseService != null) {
            databaseService.closeCurrentSession();
            ddlInitializer.cleanDB();
        }
    }

    /**
     * Create a simple pipeline definition with 3 nodes
     *   (n1:single) -(wait)-> (n2:multi) -(nowait)-> (n3:multi)-> (wait) -> (n4:single)
     * 
     * @return
     * @throws PipelineException 
     */
    private void populateObjects(int desiredResult) {

        databaseService.beginTransaction();

        // create users
        adminUser = new User("admin", "Administrator", "admin",
            "admin@kepler.nasa.gov", "x111");
        userCrud.createUser(adminUser);

        operatorUser = new User("ops", "Operator", "ops",
            "ops@kepler.nasa.gov", "x112");
        userCrud.createUser(operatorUser);

        // create a pipeline def
        PipelineConfigurator pc = new PipelineConfigurator();
        pc.createPipeline("Test Pipeline");

        ParameterSet paramSet = pc.createParamSet("test", new TestModuleParameters(desiredResult));
        ParameterSet uowParams = pc.createParamSet("testUow", new TestUowParameters(NUM_UOW_TASKS));
        
        PipelineModuleDefinition singleModule = pc.createModule("single UOW module", TestSinglePipelineModule.class, null);
        PipelineModuleDefinition multiModule = pc.createModule("multi UOW module", TestMultiplePipelineModule.class, null);

        n1 = pc.addNode(singleModule, new TestSingleUowTaskGenerator(), paramSet);
        n2 = pc.addNode(multiModule, new TestMultipleUowTaskGenerator(), paramSet, uowParams);
        n3 = pc.addNode(multiModule, paramSet);
        n4 = pc.addNode(singleModule, new TestSingleUowTaskGenerator(), paramSet);
        
        pc.createTrigger(TEST_TRIGGER_NAME_1);
        pc.finalizePipeline();
        
        databaseService.commitTransaction();
    }

    @Test
    public void testPipelineExecutionSuccess() throws Exception{
        
        TestPipelineModule.resetRecordedTasks();
        
        // Create the pipeline definition in the database
        populateObjects(TestModuleParameters.SUCCESS);
        
        // launch the pipeline
        EmbeddedWorkerCluster workers = new EmbeddedWorkerCluster();
        workers.setVerifyMcr(false); // no MATLAB here
        workers.setUseXa(USE_XA_TRANSACTIONS);
        workers.setNumWorkerThreads(1);
        workers.start();

        workers.runPipeline(TEST_TRIGGER_NAME_1);
        
        workers.shutdown();
        
        // verify that the correct tasks were executed, in the correct order
        List<PipelineTask> executedTasks = TestPipelineModule.getExecutedTasks();

        assertEquals("executedTasks.size()", (NUM_UOW_TASKS * 2) + 2, executedTasks.size());
    }

    @Test
    public void testPipelineExecutionSuccessWithStartNodeN2() throws Exception{
        
        TestPipelineModule.resetRecordedTasks();
        
        // Create the pipeline definition in the database
        populateObjects(TestModuleParameters.SUCCESS);
        
        // launch the pipeline
        EmbeddedWorkerCluster workers = new EmbeddedWorkerCluster();
        workers.setVerifyMcr(false); // no MATLAB here
        workers.setUseXa(USE_XA_TRANSACTIONS);
        workers.setNumWorkerThreads(1);
        workers.start();

        workers.runPipeline(TEST_TRIGGER_NAME_1, n2, null);
        
        workers.shutdown();
        
        // verify that the correct tasks were executed, in the correct order
        List<PipelineTask> executedTasks = TestPipelineModule.getExecutedTasks();

        assertEquals("executedTasks.size()", (NUM_UOW_TASKS * 2) + 1, executedTasks.size());
    }

    @Test
    public void testPipelineExecutionSuccessWithStartNodeN3() throws Exception{
        
        TestPipelineModule.resetRecordedTasks();
        
        // Create the pipeline definition in the database
        populateObjects(TestModuleParameters.SUCCESS);
        
        // launch the pipeline
        EmbeddedWorkerCluster workers = new EmbeddedWorkerCluster();
        workers.setVerifyMcr(false); // no MATLAB here
        workers.setUseXa(USE_XA_TRANSACTIONS);
        workers.setNumWorkerThreads(1);
        workers.start();

        workers.runPipeline(TEST_TRIGGER_NAME_1, n3, null);
        
        workers.shutdown();
        
        // verify that the correct tasks were executed, in the correct order
        List<PipelineTask> executedTasks = TestPipelineModule.getExecutedTasks();

        assertEquals("executedTasks.size()", (NUM_UOW_TASKS) + 1, executedTasks.size());
    }

    @Test
    public void testPipelineExecutionSuccessWithEndNodeSpecified() throws Exception{
        
        TestPipelineModule.resetRecordedTasks();
        
        // Create the pipeline definition in the database
        populateObjects(TestModuleParameters.SUCCESS);
        
        // launch the pipeline
        EmbeddedWorkerCluster workers = new EmbeddedWorkerCluster();
        workers.setVerifyMcr(false); // no MATLAB here
        workers.setUseXa(USE_XA_TRANSACTIONS);
        workers.setNumWorkerThreads(1);
        workers.start();

        workers.runPipeline(TEST_TRIGGER_NAME_1, null, n3);
        
        workers.shutdown();
        
        // verify that the correct tasks were executed, in the correct order
        List<PipelineTask> executedTasks = TestPipelineModule.getExecutedTasks();

        assertEquals("executedTasks.size()", (NUM_UOW_TASKS * 2) + 1, executedTasks.size());
    }

    @Test
    public void testPipelineExecutionSuccessWithStartNodeAndEndNodeSpecified() throws Exception{
        
        TestPipelineModule.resetRecordedTasks();
        
        // Create the pipeline definition in the database
        populateObjects(TestModuleParameters.SUCCESS);
        
        // launch the pipeline
        EmbeddedWorkerCluster workers = new EmbeddedWorkerCluster();
        workers.setVerifyMcr(false); // no MATLAB here
        workers.setUseXa(USE_XA_TRANSACTIONS);
        workers.setNumWorkerThreads(1);
        workers.start();

        workers.runPipeline(TEST_TRIGGER_NAME_1, n2, n3);
        
        workers.shutdown();
        
        // verify that the correct tasks were executed, in the correct order
        List<PipelineTask> executedTasks = TestPipelineModule.getExecutedTasks();

        assertEquals("executedTasks.size()", (NUM_UOW_TASKS * 2), executedTasks.size());
    }

    @Test
    public void testPipelineExecutionFatal() throws Exception{

        TestPipelineModule.resetRecordedTasks();
        
//        final FileStoreClient fileStoreClient = context.mock(FileStoreClient.class);
//        FileStoreClientFactory.setInstance(fileStoreClient);
//
//        context.checking(new Expectations() {{
//            atLeast(1).of(fileStoreClient).initialize(with(any(TransactionService.class)));
//            atLeast(1).of(fileStoreClient).getXAResource();
//        }});

        // Create the pipeline definition in the database
        populateObjects(TestModuleParameters.FATAL_EXCEPTION);
        
        // launch the pipeline
        EmbeddedWorkerCluster workers = new EmbeddedWorkerCluster();
        workers.setVerifyMcr(false); // no MATLAB here
        workers.setUseXa(USE_XA_TRANSACTIONS);
        workers.setNumWorkerThreads(1);
        workers.start();

        try {
            workers.runPipeline(TEST_TRIGGER_NAME_1);
            
            Assert.fail("pipeline did not generate FAILED event as expected");
        } catch (PipelineException e) {
        }
        
        workers.shutdown();

        // verify that the correct tasks were executed, in the correct order
        //List<PipelineTask> executedTasks = TestPipelineModule.getExecutedTasks();
        
        /* TODO: appears to be non-deterministic, disabling this test.
         * Probably randomness in how long it takes to shutdown worker
         * cluster affects how many tasks are successful.
         */
        //assertEquals("executedTasks.size()", 3, executedTasks.size());
    }
}
