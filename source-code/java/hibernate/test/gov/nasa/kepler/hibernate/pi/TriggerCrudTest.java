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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Date;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests for {@link TriggerDefinitionCrud}. Tests that objects can be stored,
 * retrieved, and edited and that mapping metadata (associations, cascade rules,
 * etc.) are setup correctly and work as expected.
 * 
 * @author tklaus
 * 
 */
public class TriggerCrudTest {
    // private static final Log log =
    // LogFactory.getLog(PipelineDefinitionCrudTest.class);

    private static final String TEST_PIPELINE_NAME_1 = "Test Pipeline 1";

    private static final String TEST_TRIGGER_NAME_1 = "Test Trigger Def 1";

    private DatabaseService databaseService = null;

    private UserCrud userCrud;

    private User adminUser;
    private User operatorUser;

    private PipelineDefinitionCrud pipelineDefinitionCrud;
    private PipelineInstanceCrud pipelineInstanceCrud;
    private TriggerDefinitionCrud triggerDefinitionCrud;

    private PipelineDefinition pipelineDefinition;
    private TriggerDefinition triggerDefinition;
    private PipelineInstance pipelineInstance;

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
        pipelineInstanceCrud = new PipelineInstanceCrud(databaseService);
        triggerDefinitionCrud = new TriggerDefinitionCrud(databaseService);
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

    private void populateObjects() {

        try {
            databaseService.beginTransaction();

            // create users
            adminUser = new User("admin", "Administrator", "admin",
                "admin@kepler.nasa.gov", "x111");
            userCrud.createUser(adminUser);

            operatorUser = new User("ops", "Operator", "ops",
                "ops@kepler.nasa.gov", "x112");
            userCrud.createUser(operatorUser);

            // create a pipeline def
            pipelineDefinition = new PipelineDefinition(new AuditInfo(
                adminUser, new Date()), TEST_PIPELINE_NAME_1);

            // pipelineDefinition.setPipelineParameters(new
            // BeanWrapper<Parameters>(new TestPipelineParameters()));
            pipelineDefinitionCrud.create(pipelineDefinition);

            triggerDefinition = createTriggerDefinition(pipelineDefinition);
            triggerDefinitionCrud.create(triggerDefinition);

            pipelineInstance = createPipelineInstance(pipelineDefinition);
            pipelineInstanceCrud.create(pipelineInstance);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    private PipelineInstance createPipelineInstance(
        PipelineDefinition pipelineDefinition) throws PipelineException {
        PipelineInstance pipelineInstance = new PipelineInstance(
            pipelineDefinition);
        // pipelineInstance.setPipelineParameters(new
        // BeanWrapper<Parameters>(new TestPipelineParameters()));
        pipelineInstance.setTriggerName(triggerDefinition.getName());
        return pipelineInstance;
    }

    private TriggerDefinition createTriggerDefinition(
        PipelineDefinition pipelineDefinition) {
        TriggerDefinition triggerDefinition = new TriggerDefinition(
            new AuditInfo(adminUser, new Date()), TEST_TRIGGER_NAME_1,
            pipelineDefinition);
        return triggerDefinition;
    }

    /**
     * Stores a new TriggerDefinition in the db, then retrieves it and makes
     * sure it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTriggerDefinition() throws Exception {
        TriggerDefinition actualTriggerDef = null;

        try {
            populateObjects();
            TriggerDefinition expectedTriggerDef = triggerDefinition;

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            actualTriggerDef = triggerDefinitionCrud.retrieve(TEST_TRIGGER_NAME_1);

            databaseService.commitTransaction();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("TriggerDefinition", expectedTriggerDef,
                actualTriggerDef);

        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testEditTriggerDefinition() throws Exception {
        try {
            // Create
            populateObjects();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve & Edit
            databaseService.beginTransaction();

            TriggerDefinition modifiedPipelineDef = triggerDefinitionCrud.retrieve(TEST_TRIGGER_NAME_1);

            editTriggerDef(modifiedPipelineDef);

            // flush changes
            databaseService.commitTransaction();

            databaseService.closeCurrentSession(); // clear the cache , detach
            // the objects

            // Retrieve
            databaseService.beginTransaction();

            TriggerDefinition actualTriggerDef = triggerDefinitionCrud.retrieve(TEST_TRIGGER_NAME_1);

            databaseService.commitTransaction();

            TriggerDefinition expectedTriggerDef = createTriggerDefinition(pipelineDefinition);
            editTriggerDef(expectedTriggerDef);
            expectedTriggerDef.setDirty(1);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.lastChangedTime");

            comparer.assertEquals("TriggerDefinition", expectedTriggerDef,
                actualTriggerDef);

        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * simulate modifications made by a user
     * 
     * @param triggerDef
     */
    private void editTriggerDef(TriggerDefinition triggerDef) {
        triggerDef.setInstancePriority(PipelineInstance.HIGHEST_PRIORITY + 1);
        triggerDef.getAuditInfo()
            .setLastChangedTime(new Date());
        triggerDef.getAuditInfo()
            .setLastChangedUser(operatorUser);
    }
}
