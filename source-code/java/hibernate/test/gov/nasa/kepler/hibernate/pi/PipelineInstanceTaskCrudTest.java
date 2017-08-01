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

package gov.nasa.kepler.hibernate.pi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud.ClearStaleStateResults;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests for {@link PipelineInstanceCrud} and {@link PipelineTaskCrud} Tests
 * that objects can be stored, retrieved, and edited and that mapping metadata
 * (associations, cascade rules, etc.) are setup correctly and work as expected.
 * 
 * @author tklaus
 * 
 */
public class PipelineInstanceTaskCrudTest {
    private static final Log log = LogFactory.getLog(PipelineInstanceTaskCrudTest.class);

    // private static final Log log =
    // LogFactory.getLog(PipelineInstanceTaskCrudTest.class);

    private static final String TEST_PIPELINE_NAME = "Test Pipeline";
    private static final String TEST_WORKER_NAME = "TestWorker";

    private DatabaseService databaseService = null;

    private UserCrud userCrud;

    private User adminUser;

    private PipelineDefinitionCrud pipelineDefinitionCrud;
    private PipelineInstanceCrud pipelineInstanceCrud;
    private PipelineInstanceNodeCrud pipelineInstanceNodeCrud;
    private PipelineTaskCrud pipelineTaskCrud;

    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
    private ParameterSetCrud parameterSetCrud;

    private PipelineInstance pipelineInstance;
    private PipelineInstanceNode pipelineInstanceNode1;
    private PipelineInstanceNode pipelineInstanceNode2;
    private PipelineTask pipelineTask1;
    private PipelineTask pipelineTask2;
    private PipelineTask pipelineTask3;
    private PipelineTask pipelineTask4;

    private PipelineDefinition pipelineDef;
    private PipelineDefinitionNode pipelineDefNode1;
    private PipelineDefinitionNode pipelineDefNode2;
    private ParameterSet parameterSet;
    private PipelineModuleDefinition moduleDef;

    /**
     * 
     * @throws Exception
     * @throws PipelineException
     */
    @Before
    public void setUp() throws Exception {

        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        userCrud = new UserCrud(databaseService);

        pipelineDefinitionCrud = new PipelineDefinitionCrud(databaseService);
        pipelineInstanceCrud = new PipelineInstanceCrud(databaseService);
        pipelineInstanceNodeCrud = new PipelineInstanceNodeCrud(databaseService);
        pipelineTaskCrud = new PipelineTaskCrud(databaseService);

        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud(
            databaseService);
        parameterSetCrud = new ParameterSetCrud(databaseService);
    }

    /**
     * 
     * @throws Exception
     * @throws PipelineException
     */
    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {

        try {
        databaseService.beginTransaction();

        // create users
        adminUser = new User("admin", "Administrator", "admin",
            "admin@kepler.nasa.gov", "x111");
        userCrud.createUser(adminUser);

        // create a module param set def
        parameterSet = new ParameterSet(new AuditInfo(adminUser, new Date()),
            "test mps1");
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new TestModuleParameters()));
        parameterSetCrud.create(parameterSet);

        // create a module def
        moduleDef = new PipelineModuleDefinition("Test-1");
        pipelineModuleDefinitionCrud.create(moduleDef);

        // create some pipeline def nodes
        pipelineDefNode1 = new PipelineDefinitionNode(moduleDef.getName());
        pipelineDefNode1.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
            new TestUowTaskGenerator()));
        pipelineDefNode1.setStartNewUow(true);

        pipelineDefNode2 = new PipelineDefinitionNode(moduleDef.getName());
        pipelineDefNode2.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
            new TestUowTaskGenerator()));
        pipelineDefNode2.setStartNewUow(true);

        pipelineDef = new PipelineDefinition(new AuditInfo(adminUser,
            new Date()), TEST_PIPELINE_NAME);

        pipelineDef.getRootNodes()
            .add(pipelineDefNode1);
        pipelineDefNode1.getNextNodes()
            .add(pipelineDefNode2);

        pipelineDefinitionCrud.create(pipelineDef);

        pipelineInstance = createPipelineInstance();
        pipelineInstanceCrud.create(pipelineInstance);

        pipelineInstanceNode1 = createPipelineInstanceNode(pipelineDefNode1, 2,
            2, 1, 0);
        pipelineInstanceNodeCrud.create(pipelineInstanceNode1);

        pipelineTask1 = createPipelineTask(pipelineInstanceNode1);
        pipelineTask1.setState(PipelineTask.State.PROCESSING);
        pipelineTaskCrud.create(pipelineTask1);

        pipelineTask2 = createPipelineTask(pipelineInstanceNode1);
        pipelineTask2.setState(PipelineTask.State.COMPLETED);
        pipelineTaskCrud.create(pipelineTask2);

        pipelineInstanceNode2 = createPipelineInstanceNode(pipelineDefNode2, 2,
            2, 0, 1);
        pipelineInstanceNodeCrud.create(pipelineInstanceNode2);

        pipelineTask3 = createPipelineTask(pipelineInstanceNode2);
        pipelineTask3.setState(PipelineTask.State.PROCESSING);
        pipelineTaskCrud.create(pipelineTask3);

        pipelineTask4 = createPipelineTask(pipelineInstanceNode2);
        pipelineTask4.setState(PipelineTask.State.ERROR);
        pipelineTaskCrud.create(pipelineTask4);

        databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private PipelineInstance createPipelineInstance() throws PipelineException {
        PipelineInstance pipelineInstance = new PipelineInstance(pipelineDef);
        pipelineInstance.putParameterSet(new ClassWrapper<Parameters>(
            new TestPipelineParameters()), parameterSet);
        return pipelineInstance;
    }

    private PipelineInstanceNode createPipelineInstanceNode(
        PipelineDefinitionNode pipelineDefNode, int numTasks,
        int numSubmittedTasks, int numCompletedTasks, int numFailedTasks)
        throws PipelineException {

        PipelineInstanceNode pipelineInstanceNode = new PipelineInstanceNode(
            pipelineInstance, pipelineDefNode, moduleDef, numTasks,
            numSubmittedTasks, numCompletedTasks, numFailedTasks);
        // pipelineInstanceNode.setNumTasks(numTasks);
        // pipelineInstanceNode.setNumSubmittedTasks(numSubmittedTasks);
        // pipelineInstanceNode.setNumCompletedTasks(numCompletedTasks);
        // pipelineInstanceNode.setNumFailedTasks(numFailedTasks);

        return pipelineInstanceNode;
    }

    private PipelineTask createPipelineTask(
        PipelineInstanceNode parentPipelineInstanceNode)
        throws PipelineException {
        PipelineTask pipelineTask = new PipelineTask(pipelineInstance,
            pipelineDefNode1, parentPipelineInstanceNode);
        pipelineTask.setUowTask(new BeanWrapper<UnitOfWorkTask>(
            new TestUowTask()));
        pipelineTask.setWorkerHost(TEST_WORKER_NAME);
        pipelineTask.setSoftwareRevision("42");
        return pipelineTask;
    }

    private int pipelineInstanceCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from PipelineInstance");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    private int pipelineTaskCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from PipelineTask");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    private int pipelineTaskWithErrorsCount() {
        Query q = databaseService.getSession()
            .createQuery(
                "select count(*) from PipelineTask where state = :state");
        q.setParameter("state", PipelineTask.State.ERROR);
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    /**
     * Stores a new PipelineInstance in the db, then retrieves it and makes sure
     * it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveInstance() throws Exception {
        try {

            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineInstance actualPipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstance.getId());

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.assertEquals("PipelineInstance", pipelineInstance,
                actualPipelineInstance);

            assertEquals("PipelineInstance count", 1, pipelineInstanceCount());
            assertEquals("PipelineTask count", 4, pipelineTaskCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new PipelineInstanceNode in the db, then retrieves it and makes
     * sure it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveInstanceNode() throws Exception {
        try {

            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineInstanceNode actualPipelineInstanceNode = pipelineInstanceNodeCrud.retrieve(
                pipelineInstance, pipelineDefNode1);

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("PipelineInstanceNode",
                pipelineInstanceNode1, actualPipelineInstanceNode);

        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new PipelineInstanceNode in the db, then retrieves it using
     * retrieveAll and makes sure it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveAllInstanceNodes() throws Exception {
        try {

            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            List<PipelineInstanceNode> actualPipelineInstanceNodes = pipelineInstanceNodeCrud.retrieveAll(pipelineInstance);

            databaseService.commitTransaction();

            assertEquals("actualPipelineInstanceNodes.size() == 2", 2,
                actualPipelineInstanceNodes.size());

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("PipelineInstanceNode",
                pipelineInstanceNode1, actualPipelineInstanceNodes.get(0));

        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new PipelineTask in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTask() throws Exception {
        try {
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineTask actualPipelineTask = pipelineTaskCrud.retrieve(pipelineTask1.getId());

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.assertEquals("PipelineTask", pipelineTask1,
                actualPipelineTask);

            assertEquals("PipelineInstance count", 1, pipelineInstanceCount());
            assertEquals("PipelineTask count", 4, pipelineTaskCount());

            List<String> nodeRevisions = pipelineTaskCrud.distinctSoftwareRevisions(pipelineInstanceNode1);
            assertEquals("nodeRevisions count", 1, nodeRevisions.size());

            List<String> instanceRevisions = pipelineTaskCrud.distinctSoftwareRevisions(pipelineInstance);
            assertEquals("instanceRevisions count", 1, instanceRevisions.size());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testStoreAndRetrieveTasks() throws Exception {
        try {
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            Set<Long> taskIds = new HashSet<Long>();
            taskIds.add(pipelineTask1.getId());
            taskIds.add(pipelineTask2.getId());

            List<PipelineTask> actualPipelineTasks = pipelineTaskCrud.retrieveAll(taskIds);

            databaseService.commitTransaction();

            List<PipelineTask> expectedPipelineTasks = new ArrayList<PipelineTask>();
            expectedPipelineTasks.add(pipelineTask1);
            expectedPipelineTasks.add(pipelineTask2);

            Assert.assertEquals(expectedPipelineTasks, actualPipelineTasks);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testStoreAndRetrieveTasksEmptyInputSet() throws Exception {
        try {
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            Set<Long> taskIds = new HashSet<Long>();

            List<PipelineTask> actualPipelineTasks = pipelineTaskCrud.retrieveAll(taskIds);

            databaseService.commitTransaction();

            List<PipelineTask> expectedPipelineTasks = new ArrayList<PipelineTask>();

            Assert.assertEquals(expectedPipelineTasks, actualPipelineTasks);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new PipelineTask in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testInstanceState() throws Exception {
        try {
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineInstanceAggregateState actualState = pipelineInstanceCrud.instanceState(pipelineInstance);

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();

            PipelineInstanceAggregateState expectedState = new PipelineInstanceAggregateState(
                4L, 4L, 1L, 1L);

            comparer.assertEquals("instanceState", expectedState, actualState);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testEditPipelineInstance() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineInstance modifiedPipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstance.getId());

            editPipelineInstance(modifiedPipelineInstance);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineInstance actualPipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstance.getId());

            databaseService.commitTransaction();

            PipelineInstance expectedPipelineInstance = createPipelineInstance();
            editPipelineInstance(expectedPipelineInstance);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.created");
            comparer.excludeField(".*\\.lastChangedTime");

            comparer.assertEquals("PipelineInstance", expectedPipelineInstance,
                actualPipelineInstance);

            assertEquals("PipelineInstance count", 1, pipelineInstanceCount());
            assertEquals("PipelineTask count", 4, pipelineTaskCount());

            assertTrue(
                "isInstanceComplete",
                actualPipelineInstance.getState() == PipelineInstance.State.COMPLETED);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user
     * 
     * @param pipelineDef
     */
    private void editPipelineInstance(PipelineInstance pipelineInstance) {
        pipelineInstance.setState(PipelineInstance.State.COMPLETED);
    }

    @Test
    public void testEditPipelineTask() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineTask modifiedPipelineTask = pipelineTaskCrud.retrieve(pipelineTask1.getId());

            editPipelineTask(modifiedPipelineTask);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineTask actualPipelineTask = pipelineTaskCrud.retrieve(pipelineTask1.getId());

            databaseService.commitTransaction();

            PipelineTask expectedPipelineTask = createPipelineTask(pipelineInstanceNode1);
            editPipelineTask(expectedPipelineTask);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.created");
            comparer.excludeField(".*\\.lastChangedTime");

            comparer.assertEquals("PipelineTask", expectedPipelineTask,
                actualPipelineTask);

            assertEquals("PipelineInstance count", 1, pipelineInstanceCount());
            assertEquals("PipelineTask count", 4, pipelineTaskCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user
     * 
     * @param pipelineDef
     */
    private void editPipelineTask(PipelineTask pipelineTask) {
        pipelineTask.setState(PipelineTask.State.COMPLETED);
    }

    @Test
    public void testRetrieveByDateStatesTypes() {
        populateObjects();

        State[] states = new State[] { State.INITIALIZED };
        String[] types = new String[] { "foo" }; // wrong
        List<PipelineInstance> pipelineInstances = pipelineInstanceCrud.retrieve(
            new Date(0), new Date(Long.MAX_VALUE), states, types);
        assertEquals(0, pipelineInstances.size());

        states = new State[] { State.ERRORS_RUNNING }; // wrong
        types = new String[] { TEST_PIPELINE_NAME };
        pipelineInstances = pipelineInstanceCrud.retrieve(new Date(0),
            new Date(Long.MAX_VALUE), states, types);
        assertEquals(0, pipelineInstances.size());

        states = new State[] { State.INITIALIZED };
        types = new String[] { TEST_PIPELINE_NAME };
        pipelineInstances = pipelineInstanceCrud.retrieve(new Date(0),
            new Date(Long.MAX_VALUE), states, types);
        assertEquals(1, pipelineInstances.size());
        assertEquals(pipelineInstance, pipelineInstances.get(0));
    }

    @Test
    public void testClearStaleState() throws Exception {

        try {
            // Create
            populateObjects();

            assertEquals("pipelineTaskWithErrorsCount count", 1,
                pipelineTaskWithErrorsCount());

            ClearStaleStateResults staleStateResults = pipelineTaskCrud.clearStaleState(TEST_WORKER_NAME);

            assertEquals("stale row count", 2,
                staleStateResults.totalUpdatedTaskCount);
            assertEquals("unique instance ids count", 1,
                staleStateResults.uniqueInstanceIds.size());
            assertEquals(
                "unique instance id",
                1,
                ((Integer) staleStateResults.uniqueInstanceIds.toArray()[0]).intValue());
            assertEquals("pipelineTaskWithErrorsCount count", 3,
                pipelineTaskWithErrorsCount());

            PipelineInstanceAggregateState actualState = pipelineInstanceCrud.instanceState(pipelineInstance);

            PipelineInstanceAggregateState expectedState = new PipelineInstanceAggregateState(
                4L, 4L, 1L, 3L);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("instanceState", expectedState, actualState);
        } catch (Exception e) {
            log.error("caught e:" + e);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testRetrieveAllPipelineInstancesForPipelineInstanceIds() {
        populateObjects();

        PipelineInstance pipelineInstance2 = new PipelineInstance();

        databaseService.beginTransaction();
        pipelineInstanceCrud.create(pipelineInstance2);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        Collection<Long> pipelineInstanceIds = new ArrayList<Long>();
        pipelineInstanceIds.add(pipelineInstance2.getId());

        List<PipelineInstance> actualPipelineInstances = pipelineInstanceCrud.retrieveAll(pipelineInstanceIds);

        List<PipelineInstance> expectedPipelineInstances = new ArrayList<PipelineInstance>();
        expectedPipelineInstances.add(pipelineInstance2);

        assertEquals(expectedPipelineInstances, actualPipelineInstances);
    }

}
