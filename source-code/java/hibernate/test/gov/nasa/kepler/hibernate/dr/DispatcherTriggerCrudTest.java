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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.pi.AuditInfo;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionCrud;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DispatcherTriggerCrudTest {

    private DatabaseService databaseService;

    private DispatcherTriggerCrud dispatcherTriggerCrud;
    private PipelineDefinitionCrud pipelineDefinitionCrud;
    private TriggerDefinitionCrud triggerDefinitionCrud;
    private UserCrud userCrud;

    private PipelineDefinition pipelineDef1;
    private PipelineDefinition pipelineDef2;

    private TriggerDefinition triggerDef1;
    private TriggerDefinition triggerDef2;

    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        userCrud = new UserCrud(databaseService);
        pipelineDefinitionCrud = new PipelineDefinitionCrud(databaseService);
        triggerDefinitionCrud = new TriggerDefinitionCrud(databaseService);
        dispatcherTriggerCrud = new DispatcherTriggerCrud(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {

        // store test objects
        databaseService.beginTransaction();

        // create user
        User adminUser = new User("admin", "Administrator", "admin",
            "admin@kepler.nasa.gov", "x111");
        userCrud.createUser(adminUser);

        // create pipeline defs
        pipelineDef1 = new PipelineDefinition(new AuditInfo(adminUser,
            new Date()), "Pipeline 1");
        pipelineDefinitionCrud.create(pipelineDef1);

        pipelineDef2 = new PipelineDefinition(new AuditInfo(adminUser,
            new Date()), "Pipeline 2");
        pipelineDefinitionCrud.create(pipelineDef2);

        // create trigger defs
        triggerDef1 = new TriggerDefinition("td1", pipelineDef1);
        triggerDefinitionCrud.create(triggerDef1);

        triggerDef2 = new TriggerDefinition("td2", pipelineDef2);
        triggerDefinitionCrud.create(triggerDef2);

        List<DispatcherTrigger> maps = createDispatcherTriggers();
        for (DispatcherTrigger map : maps) {
            dispatcherTriggerCrud.create(map);
        }

        databaseService.commitTransaction();
    }

    private List<DispatcherTrigger> createDispatcherTriggers() {

        List<DispatcherTrigger> maps = new LinkedList<DispatcherTrigger>();

        maps.add(new DispatcherTrigger("PixelDispatcher", triggerDef1));
        maps.add(new DispatcherTrigger("RefPixelDispatcher", triggerDef2));
        maps.add(new DispatcherTrigger("SomeOtherDispatcher", triggerDef2));

        return maps;
    }

    @Test
    public void testRetrieveAll() throws Exception {
        populateObjects();

        databaseService.closeCurrentSession();

        try {
            // retrieve
            databaseService.beginTransaction();

            List<DispatcherTrigger> actualDispatcherTriggerMaps = dispatcherTriggerCrud.retrieveAll();

            databaseService.commitTransaction();

            List<DispatcherTrigger> expectedDispatcherTriggerMaps = createDispatcherTriggers();

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.pipelineParameters");
            comparer.excludeField(".*\\.lastChangedTime");
            comparer.assertEquals("DispatcherTriggerMaps",
                expectedDispatcherTriggerMaps, actualDispatcherTriggerMaps);

        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}
