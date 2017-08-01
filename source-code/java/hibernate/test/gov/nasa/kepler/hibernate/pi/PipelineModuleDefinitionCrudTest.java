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
import static org.junit.Assert.assertNull;
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

import org.hibernate.Query;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests for {@link PipelineModuleDefinitionCrud} Tests that objects can be
 * stored, retrieved, and edited and that mapping metadata (associations,
 * cascade rules, etc.) are setup correctly and work as expected.
 * 
 * @author tklaus
 * 
 */
public class PipelineModuleDefinitionCrudTest {
    // private static final Log log =
    // LogFactory.getLog(PipelineModuleDefinitionCrudTest.class);

    private static final String TEST_MODULE_NAME_1 = "Test Module 1";

    private static final String TEST_PARAM_SET_NAME_1 = "Test MPS-1";

    private static final String MISSING_MODULE = "I DONT EXIST";

    private DatabaseService databaseService = null;

    private UserCrud userCrud;

    private User adminUser;
    private User operatorUser;

    private PipelineModuleDefinitionCrud pipelineModuleDefinitionCrud;
    private ParameterSetCrud parameterSetCrud;

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

    private PipelineModuleDefinition populateObjects() {

        PipelineModuleDefinition moduleDef = null;
        try {
            databaseService.beginTransaction();

            // create users
            adminUser = new User("admin", "Administrator", "admin",
                "admin@kepler.nasa.gov", "x111");
            userCrud.createUser(adminUser);

            operatorUser = new User("ops", "Operator", "ops",
                "ops@kepler.nasa.gov", "x112");
            userCrud.createUser(operatorUser);

            ParameterSet paramSet = createParameterSet(TEST_PARAM_SET_NAME_1);
            parameterSetCrud.create(paramSet);

            moduleDef = createPipelineModuleDefinition(paramSet);
            pipelineModuleDefinitionCrud.create(moduleDef);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        return moduleDef;
    }

    private ParameterSet createParameterSet(String name) {
        ParameterSet parameterSet = new ParameterSet(new AuditInfo(adminUser,
            new Date()), name);
        parameterSet.setParameters(new BeanWrapper<Parameters>(
            new TestModuleParameters(1)));
        return parameterSet;
    }

    private PipelineModuleDefinition createPipelineModuleDefinition(
        ParameterSet parameterSet) {
        PipelineModuleDefinition moduleDef = new PipelineModuleDefinition(
            new AuditInfo(adminUser, new Date()), TEST_MODULE_NAME_1);

        return moduleDef;
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

    private int paramSetNameCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from ParameterSetName");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    private int moduleNameCount() {
        Query q = databaseService.getSession()
            .createQuery("select count(*) from ModuleName");
        int count = ((Long) q.uniqueResult()).intValue();

        return count;
    }

    /**
     * Stores a new PipelineModuleDefinition in the db, then retrieves it and
     * makes sure it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieve() throws Exception {
        try {

            PipelineModuleDefinition expectedModuleDef = populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineModuleDefinition actualModuleDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(TEST_MODULE_NAME_1);

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");
            comparer.assertEquals("PipelineModuleDefinition",
                expectedModuleDef, actualModuleDef);

            assertEquals("PipelineModuleDefinition count", 1,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
            assertEquals("ParameterSetName count", 1, paramSetNameCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testRetrieveMissing() {
        PipelineModuleDefinition moduleDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(MISSING_MODULE);

        assertNull("missing module", moduleDef);
    }

    @Test
    public void testEditPipelineModuleDefinition() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            PipelineModuleDefinition modifiedModuleDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(TEST_MODULE_NAME_1);

            editModuleDef(modifiedModuleDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            PipelineModuleDefinition actualModuleDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(TEST_MODULE_NAME_1);

            databaseService.commitTransaction();

            ParameterSet expectedParamSet = createParameterSet(TEST_PARAM_SET_NAME_1);
            PipelineModuleDefinition expectedModuleDef = createPipelineModuleDefinition(expectedParamSet);
            editModuleDef(expectedModuleDef);
            expectedModuleDef.setDirty(2);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");

            comparer.assertEquals("PipelineModuleDefinition",
                expectedModuleDef, actualModuleDef);

            assertEquals("PipelineModuleDefinition count", 1,
                pipelineModuleDefinitionCount());
            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
            assertEquals("ParameterSetName count", 1, paramSetNameCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user
     * 
     * @param moduleDef
     */
    private void editModuleDef(PipelineModuleDefinition moduleDef) {
        // moduleDef.setName(TEST_MODULE_NAME_2);
        moduleDef.setDescription("new description");
        moduleDef.getAuditInfo()
            .setLastChangedTime(new Date());
        moduleDef.getAuditInfo()
            .setLastChangedUser(operatorUser);
    }

    @Test
    public void testEditPipelineModuleParameterSetChangeParam()
        throws Exception {
        // Create
        populateObjects();

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects

        try {
            // Retrieve & Edit
            databaseService.beginTransaction();

            List<ParameterSet> modifiedParamSets = parameterSetCrud.retrieveAllVersionsForName(TEST_PARAM_SET_NAME_1);

            assertEquals("paramSets size", 1, modifiedParamSets.size());

            ParameterSet modifiedParamSet = modifiedParamSets.get(0);

            editParamSetChangeParam(modifiedParamSet);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            List<ParameterSet> actualParamSets = parameterSetCrud.retrieveAllVersionsForName(TEST_PARAM_SET_NAME_1);
            assertEquals("paramSets size", 1, actualParamSets.size());
            ParameterSet actualParamSet = actualParamSets.get(0);

            databaseService.commitTransaction();

            ParameterSet expectedParamSet = createParameterSet(TEST_PARAM_SET_NAME_1);
            editParamSetChangeParam(expectedParamSet);
            expectedParamSet.setDirty(2);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.excludeField(".*\\.lastChangedUser.created");

            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            assertEquals("ParameterSet count", 1, pipelineModuleParamSetCount());
            assertEquals("ParameterSetName count", 1, paramSetNameCount());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user
     * 
     * @param moduleDef
     * @return
     * @throws PipelineException
     */
    private void editParamSetChangeParam(ParameterSet paramSet) {
        TestModuleParameters moduleParams = paramSet.parametersInstance();
        moduleParams.setValue(100);
        paramSet.getParameters()
            .populateFromInstance(moduleParams);
    }

    @Test
    public void testDeletePipelineModuleParameterSet() throws Exception {
        // Create
        populateObjects();

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects

        assertEquals("ParameterSetName count", 1, paramSetNameCount());

        try {

            databaseService.beginTransaction();

            PipelineModuleDefinition deletedModuleDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(TEST_MODULE_NAME_1);
            pipelineModuleDefinitionCrud.delete(deletedModuleDef);

            ParameterSet deletedParamSet = parameterSetCrud.retrieveLatestVersionForName(TEST_PARAM_SET_NAME_1);
            parameterSetCrud.delete(deletedParamSet);

            // flush changes
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects

        assertEquals("ParameterSet count", 0, pipelineModuleParamSetCount());
        // verify CascadeType.DELETE_ORPHAN functionality
        assertEquals("ParameterSetName count", 0, paramSetNameCount());
    }

    // @Test(expected=ConstraintViolationException.class)
    public void testFailedDeletePipelineModuleParameterSet() throws Exception {
        // Create
        populateObjects();

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects

        assertEquals("ParameterSetName count", 1, paramSetNameCount());

        try {

            databaseService.beginTransaction();

            /*
             * Should fail with ConstraintViolationException because there is
             * still a PipelineModuleDefinition pointing at this
             * ParameterSetName
             */
            ParameterSet deletedParamSet = parameterSetCrud.retrieveLatestVersionForName(TEST_PARAM_SET_NAME_1);
            parameterSetCrud.delete(deletedParamSet);

            // flush changes
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects
    }

    @Test
    public void testDeletePipelineModule() throws Exception {
        // Create
        populateObjects();

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects

        assertEquals("ModuleName count", 1, moduleNameCount());

        try {
            databaseService.beginTransaction();

            PipelineModuleDefinition deletedModuleDef = pipelineModuleDefinitionCrud.retrieveLatestVersionForName(TEST_MODULE_NAME_1);
            pipelineModuleDefinitionCrud.delete(deletedModuleDef);

            // flush changes
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

        databaseService.closeCurrentSession(); // clear the cache , detach
        // the objects

        assertEquals("PipelineModuleDefinition count", 0,
            pipelineModuleDefinitionCount());
        // verify CascadeType.DELETE_ORPHAN functionality
        assertEquals("ModuleName count", 0, moduleNameCount());
    }
}
