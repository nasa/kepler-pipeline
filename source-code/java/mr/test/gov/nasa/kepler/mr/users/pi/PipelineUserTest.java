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

package gov.nasa.kepler.mr.users.pi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.User;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableMap;
import com.openedit.users.Group;

public class PipelineUserTest {

    private static final String LOGIN_NAME1 = "test1";
    private static final String PASSWORD1 = "password1";
    private static final String DISPLAY_NAME1 = "Test 1";
    private static final String ROLE1 = "role1";
    private static final String PRIVILEGE1 = "privilege1";
    private static final String EMAIL1 = "test@nasa.gov";
    private static final String PHONE1 = "555-1212";

    private static final String LOGIN_NAME2 = "test2";
    private static final String PASSWORD2 = "password2";
    private static final String DISPLAY_NAME2 = "Test 2";
    private static final String ROLE2 = "role2";
    private static final String PRIVILEGE2 = "privilege2";
    private static final String EMAIL2 = "test@nasa.gov";
    private static final String PHONE2 = "555-1212";

    private User piUser1;
    private User piUser2;
    private Role role1;
    private Role role2;
    private Group group1;
    private Group group2;
    private PipelineUser pipelineUser;

    @Before
    public void populateObjects() {
        piUser1 = new User(LOGIN_NAME1, DISPLAY_NAME1, PASSWORD1, EMAIL1,
            PHONE1);
        role1 = new Role(ROLE1);
        role1.addPrivilege(PRIVILEGE1);
        piUser1.addRole(role1);
        pipelineUser = new PipelineUser(piUser1);

        group1 = new PipelineGroup(role1);
        pipelineUser.addGroup(group1);

        piUser2 = new User(LOGIN_NAME2, DISPLAY_NAME2, PASSWORD2, EMAIL2,
            PHONE2);
        group2 = new PipelineGroup(role2);
        role2 = new Role(ROLE2);
        role2.addPrivilege(PRIVILEGE2);
        piUser2.addRole(role1);
    }

    @Test
    public void testGroups() {
        assertTrue(pipelineUser.isInGroup(group1));
        assertFalse(pipelineUser.isInGroup(group2));
        pipelineUser.addGroup(group2);
        assertFalse(pipelineUser.isInGroup(group2));
        pipelineUser.removeGroup(group1);
        assertTrue(pipelineUser.isInGroup(group1));

        pipelineUser.clearGroups();
        assertEquals(1, pipelineUser.getGroups()
            .size());
    }

    @Test
    public void testGetCreationDate() {
        assertEquals(piUser1.getCreated(), pipelineUser.getCreationDate());
    }

    @Test
    public void testEmail() {
        assertEquals(EMAIL1, pipelineUser.getEmail());
        pipelineUser.setEmail(EMAIL2);
        assertEquals(EMAIL2, pipelineUser.getEmail());
    }

    @Test
    public void testFirstName() {
        String firstName = DISPLAY_NAME1.split(" ")[0];
        assertEquals(firstName, pipelineUser.getFirstName());
        String newFirstName = DISPLAY_NAME2.split(" ")[0];
        pipelineUser.setFirstName(newFirstName);
        assertEquals(firstName, pipelineUser.getFirstName());
    }

    @Test
    public void testLastName() {
        String lastName = DISPLAY_NAME1.split(" ")[1];
        assertEquals(lastName, pipelineUser.getLastName());
        String newLastName = DISPLAY_NAME2.split(" ")[1];
        pipelineUser.setLastName(newLastName);
        assertEquals(lastName, pipelineUser.getLastName());
    }

    @Test
    public void testPassword() {
        assertEquals(piUser1.getPassword(), pipelineUser.getClearPassword());

        assertEquals(piUser1.getPassword(), pipelineUser.getPassword());
        pipelineUser.setPassword(PASSWORD2);
        assertEquals(piUser1.getPassword(), pipelineUser.getPassword());
    }

    @Test
    public void testProperties() {
        assertEquals(0, pipelineUser.getProperties()
            .size());
        assertEquals(Boolean.TRUE, pipelineUser.getProperty(PRIVILEGE1));
        assertFalse(pipelineUser.getBoolean("foo"));
        assertFalse(pipelineUser.hasProperty("foo"));

        pipelineUser.safePut("foo", "foofoo");
        assertFalse(pipelineUser.hasProperty("foo"));

        pipelineUser.put("foo", "foofoo");
        assertTrue(pipelineUser.hasProperty("foo"));
        assertEquals(1, pipelineUser.getProperties()
            .size());
        assertEquals("foofoo", pipelineUser.getProperties()
            .get("foo"));
        assertEquals("foofoo", pipelineUser.get("foo"));
        assertEquals("foofoo", pipelineUser.getString("foo"));

        pipelineUser.putAll(ImmutableMap.of("foo", "foofoo", "bar", "barbar",
            "baz", "bazbaz"));
        assertEquals(3, pipelineUser.getProperties()
            .size());
        assertTrue(pipelineUser.hasProperty("foo"));
        assertTrue(pipelineUser.hasProperty("bar"));
        assertTrue(pipelineUser.hasProperty("baz"));

        pipelineUser.remove("foo");
        assertFalse(pipelineUser.hasProperty("foo"));

        pipelineUser.removeAll(new String[] { "foo", "bar", "baz" });
        assertFalse(pipelineUser.hasProperty("bar"));
        assertFalse(pipelineUser.hasProperty("baz"));
    }

    @Test
    public void testGetShortDescription() {
        assertEquals(DISPLAY_NAME1, pipelineUser.getShortDescription());
    }

    @Test
    public void testGetUserName() {
        assertEquals(LOGIN_NAME1, pipelineUser.getUserName());
        pipelineUser.setUserName(LOGIN_NAME2);
        assertEquals(LOGIN_NAME1, pipelineUser.getUserName());
    }

    @Test
    public void testHasPermission() {
        assertTrue(pipelineUser.hasPermission(PRIVILEGE1));
        assertFalse(pipelineUser.hasPermission("no such permission"));
    }

    @Test
    public void testPiUser() {
        assertEquals(piUser1, pipelineUser.getPiUser());

        pipelineUser.setPiUser(piUser2);
        assertEquals(piUser2, pipelineUser.getPiUser());
    }

    @Test
    public void testVirtual() {
        assertFalse(pipelineUser.isVirtual());
        pipelineUser.setVirtual(true);
        assertFalse(pipelineUser.isVirtual());
    }

    @Test
    public void testListGroupPermissions() {
        assertEquals(1, pipelineUser.listGroupPermissions()
            .size());
        assertEquals(PRIVILEGE1, pipelineUser.listGroupPermissions()
            .get(0));
    }

    @Test(expected = RuntimeException.class)
    public void testPropertyContainer() {
        assertEquals(pipelineUser, pipelineUser.getPropertyContainer());
        pipelineUser.setPropertyContainer(pipelineUser);
    }

    @Test
    public void testToString() {
        assertEquals(LOGIN_NAME1, pipelineUser.toString());
    }
}
