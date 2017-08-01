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

package gov.nasa.kepler.services.security;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.hibernate.services.UserCrud;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link SecurityOperations} class.
 * 
 * @author Bill Wohler
 */
public class SecurityOperationsTest {

    private static DatabaseService databaseService;
    private DdlInitializer ddlInitializer;
    private SecurityOperations securityOperations;

    @Before
    public void setup() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();
        securityOperations = new SecurityOperations(databaseService);
    }

    @After
    public void cleanup() {
        databaseService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    private void populateObjects() {
        databaseService.beginTransaction();

        TestSecuritySeedData testSecuritySeedData = new TestSecuritySeedData(
            databaseService);
        testSecuritySeedData.loadSeedData();

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @Test
    public void testValidateLogin() {
        // Don't need to test validateLogin(User, String) explicitly since that
        // method is tested indirectly by validateLogin(String, String).
        populateObjects();

        assertTrue("valid user/password", securityOperations.validateLogin(
            "admin", "admin"));
        assertFalse("invalid user", securityOperations.validateLogin("foo",
            "admin"));
        assertFalse("invalid password", securityOperations.validateLogin(
            "admin", "foo"));
        assertFalse("invalid user/password", securityOperations.validateLogin(
            "foo", "bar"));
        assertFalse("null user", securityOperations.validateLogin(
            (String) null, "bar"));
        assertFalse("null password", securityOperations.validateLogin("foo",
            (String) null));
        assertFalse("null user/password", securityOperations.validateLogin(
            (String) null, (String) null));
        assertFalse("empty user", securityOperations.validateLogin("", "bar"));
        assertFalse("empty password", securityOperations.validateLogin("foo",
            ""));
        assertFalse("empty user/password", securityOperations.validateLogin("",
            ""));
    }

    @Test
    public void testHasPrivilege() {
        populateObjects();

        UserCrud userCrud = new UserCrud(databaseService);
        User user = userCrud.retrieveUser("admin");
        assertTrue("admin has create", securityOperations.hasPrivilege(user,
            Privilege.PIPELINE_OPERATIONS.toString()));
        assertTrue("admin has modify", securityOperations.hasPrivilege(user,
            Privilege.PIPELINE_MONITOR.toString()));
        assertTrue("admin has monitor", securityOperations.hasPrivilege(user,
            Privilege.PIPELINE_CONFIG.toString()));
        assertTrue("admin has operations", securityOperations.hasPrivilege(
            user, Privilege.USER_ADMIN.toString()));

        user = userCrud.retrieveUser("joe");
        assertFalse("joe does not have create",
            securityOperations.hasPrivilege(user, Privilege.PIPELINE_OPERATIONS.toString()));
        assertFalse("joe does not have modify",
            securityOperations.hasPrivilege(user, Privilege.PIPELINE_MONITOR.toString()));
        assertTrue("joe has monitor", securityOperations.hasPrivilege(user,
            Privilege.PIPELINE_CONFIG.toString()));
        assertTrue("joe has operations", securityOperations.hasPrivilege(user,
            Privilege.USER_ADMIN.toString()));
    }

    @Test
    public void testGetCurrentUser() {
        populateObjects();
        assertNull("user is null", securityOperations.getCurrentUser());
        securityOperations.validateLogin("foo", "bar");
        assertNull("user is null", securityOperations.getCurrentUser());
        securityOperations.validateLogin("admin", "admin");
        assertEquals("admin", securityOperations.getCurrentUser()
            .getLoginName());
        securityOperations.validateLogin("joe", "joe");
        assertEquals("joe", securityOperations.getCurrentUser().getLoginName());
    }
}
