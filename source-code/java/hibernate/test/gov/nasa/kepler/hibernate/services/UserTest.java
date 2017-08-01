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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import java.util.Date;
import java.util.LinkedList;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link User} class.
 * 
 * @author Bill Wohler
 */
public class UserTest {

    private User user;

    @Before
    public void setUp() {
        user = createUser();
    }

    private User createUser() {
        return new User("jamesAdmin", "Administrator", "james",
            "james@kepler.nasa.gov", "x555");
    }

    @Test
    public void testConstructors() {
        User user = new User();
        assertTrue(user.getCreated() != null);

        user = createUser();
        assertEquals("jamesAdmin", user.getLoginName());
        assertFalse(user.getPassword()
            .equals("james"));
        assertEquals("Administrator", user.getDisplayName());
        assertEquals("james@kepler.nasa.gov", user.getEmail());
        assertEquals("x555", user.getPhone());
    }

    @Test
    public void testLoginName() {
        assertEquals("jamesAdmin", user.getLoginName());
        String s = "a string";
        user.setLoginName(s);
        assertEquals(s, user.getLoginName());
    }

    @Test
    public void testPassword() {
        assertFalse(user.getPassword()
            .equals("james"));

        // Test that the password isn't being saved in cleartext.
        String s = "a string";
        user.setPassword(s);
        String password = user.getPassword();
        assertFalse(password.equals(s));

        // Test that the salt is random.
        user.setPassword(s);
        assertFalse(password.equals(user.getPassword()));

        // Test ability to match passwords by extracting salt from previous
        // password and encrypt new string with it.
        password = user.getPassword();
        assertEquals(password, user.encryptPassword(s));

        // Test null passwords.
        assertFalse(password.equals(user.encryptPassword("")));
        user = new User();
        assertEquals("", user.getPassword());
        assertEquals("", user.encryptPassword(null));
        assertEquals("", user.encryptPassword(""));
        assertFalse("".equals(user.encryptPassword(s)));
    }

    @Test
    public void testDisplayName() {
        assertEquals("Administrator", user.getDisplayName());
        String s = "a string";
        user.setDisplayName(s);
        assertEquals(s, user.getDisplayName());
    }

    @Test
    public void testEmail() {
        assertEquals("james@kepler.nasa.gov", user.getEmail());
        String s = "a string";
        user.setEmail(s);
        assertEquals(s, user.getEmail());
    }

    @Test
    public void testPhone() {
        assertEquals("x555", user.getPhone());
        String s = "a string";
        user.setPhone(s);
        assertEquals(s, user.getPhone());
    }

    @Test
    public void testRoles() {
        assertEquals(0, user.getRoles()
            .size());

        Role role = new Role("operator");
        LinkedList<Role> rList = new LinkedList<Role>();
        rList.add(role);
        user.setRoles(rList);
        assertEquals(1, user.getRoles()
            .size());
        assertEquals(role, user.getRoles()
            .get(0));

        role = new Role("galley-slave");
        user.addRole(role);
        assertEquals(2, user.getRoles()
            .size());
        assertEquals(role, user.getRoles()
            .get(1));
    }

    @Test
    public void testPrivileges() {
        assertEquals(0, user.getPrivileges()
            .size());

        String privilege = Privilege.PIPELINE_MONITOR.toString();
        LinkedList<String> pList = new LinkedList<String>();
        pList.add(privilege);
        user.setPrivileges(pList);
        assertEquals(1, user.getPrivileges()
            .size());
        assertEquals(privilege, user.getPrivileges()
            .get(0));

        privilege = Privilege.PIPELINE_OPERATIONS.toString();
        user.addPrivilege(privilege);
        assertEquals(2, user.getPrivileges()
            .size());
        assertEquals(privilege, user.getPrivileges()
            .get(1));

        assertTrue(user.hasPrivilege(Privilege.PIPELINE_OPERATIONS.toString()));
        assertTrue(user.hasPrivilege(Privilege.PIPELINE_MONITOR.toString()));
        assertFalse(user.hasPrivilege(Privilege.PIPELINE_CONFIG.toString()));
        assertFalse(user.hasPrivilege(Privilege.USER_ADMIN.toString()));
    }

    @Test
    public void testCreated() {
        assertTrue(user.getCreated() != null);

        Date date = new Date(System.currentTimeMillis());
        user.setCreated(date);
        assertEquals(date, user.getCreated());
    }

    @Test
    public void testHashCode() {
        int hashCode = user.hashCode();
        hashCode = createUser().hashCode();
        assertEquals(hashCode, createUser().hashCode());
    }

    @Test
    public void testEquals() {
        assertEquals(user, createUser());
    }

    @Test
    public void testToString() {
        assertEquals("Administrator", user.toString());
    }
}
