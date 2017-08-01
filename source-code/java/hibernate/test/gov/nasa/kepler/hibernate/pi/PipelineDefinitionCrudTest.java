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
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.Query;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests for {@link PipelineDefinitionCrud} Tests that objects can be stored,
 * retrieved, and edited and that mapping metadata (associations, cascade rules,
 * etc.) are setup correctly and work as expected.
 * 
 * @author tklaus
 * 
 */
public class PipelineDefinitionCrudTest {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PipelineDefinitionCrudTest.class);

    private static final String TEST_PIPELINE_NAME_1 = "Test Pipeline 1";

    private DatabaseService databaseService = null;

    private UserCrud userCrud;

    private User adminUser;
    private User operatorUser;

    private PipelineDefinitionCrud pipelineDefinitionCrud;

    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
    private ParameterSetCrud parameterSetCrud;

    private ParameterSet expectedParamSet;
    private PipelineModuleDefinition expectedModuleDef1;
    private PipelineModuleDefinition expectedModuleDef2;
    private PipelineModuleDefinition expectedModuleDef3;

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     * @throws ClassNotFoundException
     * @throws IOException
     */
    @Before
    public void setUp() throws SQLException, ClassNotFoundException,
        IOException {

        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        userCrud = new UserCrud(databaseService);
        pipelineDefinitionCrud = new PipelineDefinitionCrud(databaseService);
        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrud(
            databaseService);
        parameterSetCrud = new ParameterSetCrud(databaseService);
    }

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     */
    @After
    public void tearDown() throws SQLException {
        if (databaseService != null) {
            TestUtils.tearDownDatabase(databaseService);
        }
    }

    private PipelineDefinition populateObjects() {

        PipelineDefinition pipelineDef = null;
        try {
            databaseService.beginTransaction();

            // create users
            adminUser = new User("admin", "Administrator", "admin",
                "admin@kepler.nasa.gov", "x111");
            userCrud.createUser(adminUser);

            operatorUser = new User("ops", "Operator", "ops",
                "ops@kepler.nasa.gov", "x112");
            userCrud.createUser(operatorUser);

            // create a module param set def
            expectedParamSet = new ParameterSet(new AuditInfo(adminUser,
                new Date()), "test mps1");
            expectedParamSet.setParameters(new BeanWrapper<Parameters>(
                new TestModuleParameters()));
            parameterSetCrud.create(expectedParamSet);

            // create a few module defs
            expectedModuleDef1 = new PipelineModuleDefinition("Test-1");
            pipelineModuleDefinitionCrud.create(expectedModuleDef1);

            expectedModuleDef2 = new PipelineModuleDefinition("Test-2");
            pipelineModuleDefinitionCrud.create(expectedModuleDef2);

            expectedModuleDef3 = new PipelineModuleDefinition("Test-3");
            pipelineModuleDefinitionCrud.create(expectedModuleDef3);

            // create a pipeline def
            pipelineDef = createPipelineDefinition();
            pipelineDefinitionCrud.create(pipelineDef);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        return pipelineDef;
    }

    private PipelineDefinition createPipelineDefinition() {
        PipelineDefinitionNode pipelineNode1 = new PipelineDefinitionNode(
            expectedModuleDef1.getName());
        PipelineDefinitionNode pipelineNode2 = new PipelineDefinitionNode(
            expectedModuleDef2.getName());
        pipelineNode1.getNextNodes()
            .add(pipelineNode2);

        PipelineDefinition pipelineDef = new PipelineDefinition(new AuditInfo(
            adminUser, new Date()), TEST_PIPELINE_NAME_1);

        pipelineNode1.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
            new TestUowTaskGenerator()));
        pipelineNode1.setStartNewUow(false);

        pipelineNode2.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
            new TestUowTaskGenerator()));
        pipelineNode2.setStartNewUow(false);

        pipelineDef.getRootNodes()
            .add(pipelineNode1);

        return pipelineDef;
    }

    private int pipelineNodeCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from PipelineDefinitionNode");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    private int pipelineModuleDefinitionCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from PipelineModuleDefinition");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    private int pipelineModuleParamSetCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from ParameterSet");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    /**
     * Stores a new PipelineDefinition in the db, then retrieves it and makes
     * sure it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieve() throws Exception {
        PipelineDefinition actualPipelineDef = null;

        try {

            PipelineDefinition expectedPipelineDef = populateObjects();

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            databaseService.beginTransaction();

            actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");
            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            List<PipelineDefinition> latestVersions = pipelineDefinitionCrud.retrieveLatestVersions();
            assertEquals("latestVersions count", 1, latestVersions.size());
            comparer.assertEquals("latest version", expectedPipelineDef,
                latestVersions.get(0));

            assertEquals("PipelineDefinitionNode count", 2, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testEditPipelineDefinition() throws Exception {
        try {
            // Create
            populateObjects();

            assertEquals("PipelineDefinitionNode count", 2, pipelineNodeCount());

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineDefinition modifiedPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            editPipelineDef(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineDefinition actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            // Create & Edit
            databaseService.beginTransaction();

            PipelineDefinition expectedPipelineDef = createPipelineDefinition();
            editPipelineDef(expectedPipelineDef);
            expectedPipelineDef.setDirty(2);

            // flush changes
            databaseService.commitTransaction();

            // databaseService.closeCurrentSession(); // clear the cache ,
            // detach
            // the objects

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");

            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            assertEquals("PipelineDefinitionNode count", 2, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user
     * 
     * @param pipelineDef
     */
    private void editPipelineDef(PipelineDefinition pipelineDef) {
        pipelineDef.setDescription("new description");
        pipelineDef.getAuditInfo()
            .setLastChangedTime(new Date());
        pipelineDef.getAuditInfo()
            .setLastChangedUser(operatorUser);
    }

    @Test
    public void testEditPipelineDefinitionAddNextNode() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineDefinition modifiedPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            editPipelineDefAddNextNode(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineDefinition actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            PipelineDefinition expectedPipelineDef = createPipelineDefinition();
            editPipelineDefAddNextNode(expectedPipelineDef);
            expectedPipelineDef.setDirty(1);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");

            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            assertEquals("PipelineDefinitionNode count", 3, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user add a new node after the last node:
     * N1 -> N2 -> N3(new)
     * 
     * @param pipelineDef
     * @throws PipelineException
     */
    private void editPipelineDefAddNextNode(PipelineDefinition pipelineDef) {
        PipelineDefinitionNode newPipelineNode = new PipelineDefinitionNode(
            expectedModuleDef3.getName());
        pipelineDef.getRootNodes()
            .get(0)
            .getNextNodes()
            .get(0)
            .getNextNodes()
            .add(newPipelineNode);
        newPipelineNode.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
            new TestUowTaskGenerator()));
        newPipelineNode.setStartNewUow(false);
    }

    @Test
    public void testEditPipelineDefinitionAddBranchNode() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineDefinition modifiedPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            editPipelineDefAddBranchNode(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineDefinition actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            PipelineDefinition expectedPipelineDef = createPipelineDefinition();
            editPipelineDefAddBranchNode(expectedPipelineDef);
            expectedPipelineDef.setDirty(1);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");

            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            assertEquals("PipelineDefinitionNode count", 3, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user add a new node branch off the
     * second node: N1 -> N2 \> N3(new)
     * 
     * @param pipelineDef
     * @throws PipelineException
     */
    private void editPipelineDefAddBranchNode(PipelineDefinition pipelineDef) {
        PipelineDefinitionNode newPipelineNode = new PipelineDefinitionNode(
            expectedModuleDef3.getName());
        pipelineDef.getRootNodes()
            .get(0)
            .getNextNodes()
            .add(newPipelineNode);
        newPipelineNode.setUnitOfWork(new ClassWrapper<UnitOfWorkTaskGenerator>(
            new TestUowTaskGenerator()));
        newPipelineNode.setStartNewUow(false);
    }

    @Test
    public void testEditPipelineDefinitionChangeNodeModule() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineDefinition modifiedPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            editPipelineDefChangeNodeModule(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineDefinition actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            PipelineDefinition expectedPipelineDef = createPipelineDefinition();
            editPipelineDefChangeNodeModule(expectedPipelineDef);
            expectedPipelineDef.setDirty(1);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");

            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            assertEquals("PipelineDefinitionNode count", 2, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user change node module for first node
     * from module1 to module3
     * 
     * @param pipelineDef
     */
    private void editPipelineDefChangeNodeModule(PipelineDefinition pipelineDef) {
        pipelineDef.getRootNodes()
            .get(0)
            .setPipelineModuleDefinition(expectedModuleDef3);
    }

    @Test
    public void testEditPipelineDefinitionDeleteLastNode() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineDefinition modifiedPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            editPipelineDefDeleteLastNode(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineDefinition actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            PipelineDefinition expectedPipelineDef = createPipelineDefinition();
            editPipelineDefDeleteLastNode(expectedPipelineDef);
            expectedPipelineDef.setDirty(1);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");

            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            assertEquals("PipelineDefinitionNode count", 1, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user delete last node
     * 
     * @param pipelineDef
     */
    private void editPipelineDefDeleteLastNode(PipelineDefinition pipelineDef) {
        List<PipelineDefinitionNode> nextNodes = pipelineDef.getRootNodes()
            .get(0)
            .getNextNodes();

        for (PipelineDefinitionNode nextNode : nextNodes) {
            pipelineDefinitionCrud.deletePipelineNode(nextNode);
        }
        nextNodes.clear();
    }

    @Test
    public void testEditPipelineDefinitionDeleteAllNodes() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineDefinition modifiedPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            editPipelineDefDeleteAllNodes(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineDefinition actualPipelineDef = pipelineDefinitionCrud.retrieveLatestVersionForName(TEST_PIPELINE_NAME_1);

            databaseService.commitTransaction();

            PipelineDefinition expectedPipelineDef = createPipelineDefinition();
            editPipelineDefDeleteAllNodes(expectedPipelineDef);
            expectedPipelineDef.setDirty(2);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.excludeField(".*\\.uowProperties.instance");

            comparer.assertEquals("PipelineDefinition", expectedPipelineDef,
                actualPipelineDef);

            assertEquals("PipelineDefinitionNode count", 0, pipelineNodeCount());
            assertEquals("PipelineModuleDefinition count", 3,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user delete all nodes
     * 
     * @param pipelineDef
     */
    private void editPipelineDefDeleteAllNodes(PipelineDefinition pipelineDef) {
        pipelineDefinitionCrud.deleteAllPipelineNodes(pipelineDef);
    }

    @Test
    public void testRetrievePipelineDefinitionNamesInUse() throws Exception {

        try {
            // No pipeline definitions at all. Should be empty.
            assertEquals(0,
                pipelineDefinitionCrud.retrievePipelineDefinitionNamesInUse()
                    .size());

            // Add a pipeline definition, but without an associated pipeline
            // instances. Should return an empty list.
            // Create
            PipelineDefinition pipelineDefinition = populateObjects();

            assertEquals(0,
                pipelineDefinitionCrud.retrievePipelineDefinitionNamesInUse()
                    .size());

            // Now, create a pipeline instance associated with the pipeline
            // definition. Should return a single item.
            PipelineInstance pipelineInstance = new PipelineInstance(
                pipelineDefinition);
            PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud(
                databaseService);

            databaseService.beginTransaction();

            pipelineInstanceCrud.create(pipelineInstance);

            databaseService.commitTransaction();

            List<String> pipelineDefinitions = pipelineDefinitionCrud.retrievePipelineDefinitionNamesInUse();

            assertEquals(1, pipelineDefinitions.size());

            String name = pipelineDefinitions.get(0);
            assertEquals(TEST_PIPELINE_NAME_1, name);
            databaseService.closeCurrentSession();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}
