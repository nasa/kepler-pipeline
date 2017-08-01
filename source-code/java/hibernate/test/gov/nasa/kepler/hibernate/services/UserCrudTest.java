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

package gov.nasa.kepler.hibernate.services;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class UserCrudTest {
    private static final Log log = LogFactory.getLog(UserCrudTest.class);

    private DatabaseService databaseService;
    private UserCrud userCrud = null;

    private Role superUserRole;
    private Role operatorRole;
    private Role monitorRole;
    private User adminUser;
    private User joeOperator;
    private User maryMonitor;

    @Before
    public void setup() throws Exception {

        databaseService = DatabaseServiceFactory.getInstance();
        userCrud = new UserCrud(databaseService);

        log.info("Initializing DB");
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void cleanup() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void createRoles(User createdBy) throws PipelineException {

        superUserRole = new Role("superuser", createdBy);
        operatorRole = new Role("operator", createdBy);
        monitorRole = new Role("monitor", createdBy);

        userCrud.createRole(superUserRole);
        userCrud.createRole(operatorRole);
        userCrud.createRole(monitorRole);
    }

    private void createAdminUser() throws PipelineException {

        adminUser = new User("admin", "SOC Administrator", "foo",
            "socadmin@arc.nasa.gov", "650-604-0001");

        userCrud.createUser(adminUser);
    }

    private void seed() throws PipelineException {

        createAdminUser();
        createRoles(adminUser);

        adminUser.addRole(superUserRole);

        joeOperator = new User("joe", "Joe Operator", "joe",
            "joe@arc.nasa.gov", "650-604-0002");
        joeOperator.addRole(operatorRole);

        maryMonitor = new User("mary", "Mary Monitor", "mary",
            "mary@arc.nasa.gov", "650-604-0003");
        maryMonitor.addRole(monitorRole);

        userCrud.createUser(joeOperator);
        userCrud.createUser(maryMonitor);
    }

    @Test
    public void testCreateRetrieve() throws Exception {

        log.info("START TEST: testCreateRetrieve");

        try {

            databaseService.beginTransaction();

            // store
            seed();

            // retrieve

            List<Role> roles = userCrud.retrieveAllRoles();

            for (Role role : roles) {
                log.info(role);
            }

            assertEquals("BeforeCommit: roles.size()", 3, roles.size());
            assertTrue("BeforeCommit: contains superUserRole",
                roles.contains(superUserRole));
            assertTrue("BeforeCommit: contains operatorRole",
                roles.contains(operatorRole));
            assertTrue("BeforeCommit: contains monitorRole",
                roles.contains(monitorRole));

            List<User> users = userCrud.retrieveAllUsers();

            for (User user : users) {
                log.info(user);
            }

            assertEquals("BeforeCommit: users.size()", 3, users.size());
            assertTrue("BeforeCommit: contains adminUser",
                users.contains(adminUser));
            assertTrue("BeforeCommit: contains joeOperator",
                users.contains(joeOperator));
            assertTrue("BeforeCommit: contains maryMonitor",
                users.contains(maryMonitor));

            assertEquals("AfterCommit: roles.size()", 3, roles.size());
            assertTrue("AfterCommit: contains superUserRole",
                roles.contains(superUserRole));
            assertTrue("AfterCommit: contains operatorRole",
                roles.contains(operatorRole));
            assertTrue("AfterCommit: contains monitorRole",
                roles.contains(monitorRole));

            assertEquals("AfterCommit: users.size()", 3, users.size());
            assertTrue("AfterCommit: contains adminUser",
                users.contains(adminUser));
            assertTrue("AfterCommit: contains joeOperator",
                users.contains(joeOperator));
            assertTrue("AfterCommit: contains maryMonitor",
                users.contains(maryMonitor));

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }

    }

    @Test(expected = org.hibernate.exception.ConstraintViolationException.class)
    public void testDeleteRoleConstraintViolation() throws Throwable {

        log.info("START TEST: testDeleteRoleConstraintViolation");

        try {

            databaseService.beginTransaction();
            // store
            seed();

            // delete
            List<Role> roles = userCrud.retrieveAllRoles();

            /*
             * This should fail because there is a User (maryMonitor) using this
             * Role
             */
            userCrud.deleteRole(roles.get(roles.indexOf(monitorRole)));

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Verify that we can delete a Role after we have deleted all users that
     * reference that Role
     * 
     * @throws Exception
     */
    @Test
    public void testDeleteUserAndRole() throws Exception {

        log.info("START TEST: testDeleteUserAndRole");

        try {

            databaseService.beginTransaction();

            // store
            seed();

            // delete User

            List<User> users = userCrud.retrieveAllUsers();
            userCrud.deleteUser(users.get(users.indexOf(maryMonitor)));

            // delete Role

            List<Role> roles = userCrud.retrieveAllRoles();
            userCrud.deleteRole(roles.get(roles.indexOf(monitorRole)));

            // retrieve Users

            users = userCrud.retrieveAllUsers();

            for (User user : users) {
                log.info(user);
            }

            assertEquals("users.size()", 2, users.size());
            assertTrue("contains adminUser", users.contains(adminUser));
            assertTrue("contains joeOperator", users.contains(joeOperator));

            // retrieve Roles
            roles = userCrud.retrieveAllRoles();

            databaseService.commitTransaction();

            assertEquals("AfterCommit: roles.size()", 2, roles.size());
            assertTrue("AfterCommit: contains superUserRole",
                roles.contains(superUserRole));
            assertTrue("AfterCommit: contains operatorRole",
                roles.contains(operatorRole));
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }
}
