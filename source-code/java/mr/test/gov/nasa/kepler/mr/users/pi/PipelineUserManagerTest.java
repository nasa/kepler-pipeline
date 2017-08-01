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

import static com.google.common.collect.Lists.newArrayList;
import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertTrue;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

import com.openedit.hittracker.HitTracker;
import com.openedit.page.manage.PageManager;
import com.openedit.users.Authenticator;
import com.openedit.users.Group;
import com.openedit.users.Permission;
import com.openedit.users.User;
import com.openedit.users.UserManagerException;
import com.openedit.users.filesystem.PermissionsManager;

/**
 * Tests the {@link PipelineUserManager} class.
 * 
 * @author jbrittain
 * @author Bill Wohler
 */
public class PipelineUserManagerTest extends JMockTest {

    protected static final Log log = LogFactory.getLog(PipelineUserManagerTest.class);

    private PipelineUserManager userManager = new PipelineUserManager();
    private User user;
    private User user2;
    private Group group;
    private Group group2;
    private List<Group> groups = newArrayList();
    private List<User> users = newArrayList();

    private gov.nasa.kepler.hibernate.services.User piUser;
    private gov.nasa.kepler.hibernate.services.User piUser2;
    private Role role;
    private Role role2;

    @Before
    public void populateObjects() {
        UserCrud userCrud = mock(UserCrud.class);
        userManager.setUserCrud(userCrud);

        role = new Role("testrole");
        role.addPrivilege("privilege1");
        List<Role> roles = newArrayList();
        roles.add(role);

        role2 = new Role("testrole2");
        role2.addPrivilege("privilege2");
        role2.addPrivilege("privilege3");
        roles.add(role2);

        allowing(userCrud).retrieveAllRoles();
        will(returnValue(roles));

        List<gov.nasa.kepler.hibernate.services.User> piUsers = newArrayList();
        piUser = new gov.nasa.kepler.hibernate.services.User("testuser",
            "Test User", "testuser", "mr@host", "none");
        piUser.addRole(role);
        piUser.addRole(role2);
        piUsers.add(piUser);
        allowing(userCrud).retrieveUser(piUser.getLoginName());
        will(returnValue(piUser));
        user = new PipelineUser(piUser);
        users.add(user);

        piUser2 = new gov.nasa.kepler.hibernate.services.User("testuser2",
            "Test User2", "testuser2", "mr2@host", "none");
        piUser2.addRole(role2);
        piUsers.add(piUser2);
        allowing(userCrud).retrieveUser(piUser2.getLoginName());
        will(returnValue(piUser2));
        user2 = new PipelineUser(piUser2);
        users.add(user2);

        allowing(userCrud).retrieveAllUsers();
        will(returnValue(piUsers));

        group = userManager.getGroup("testrole");
        groups.add(group);
        group2 = userManager.getGroup("testrole2");
        groups.add(group2);
    }

    @Test
    public void testCreateGroup() {
        assertEquals(group.getName(), userManager.createGroup("testrole")
            .getName());
        assertNull(userManager.createGroup("newrole"));
    }

    @Test(expected = NullPointerException.class)
    public void testCreateUsers() {
        assertNull(userManager.createGuestUser("userName", "password",
            "groupName"));
        userManager.createUser("userName", "password")
            .getUserName();
    }

    @Test
    public void testDeleteGroups() {
        userManager.deleteGroup(group);
        userManager.deleteGroups(groups);
    }

    @Test
    public void testDeleteUsers() {
        userManager.deleteUser(user);
        userManager.deleteUsers(users);
    }

    @Test
    public void testFindUser() {
        // Try finding one user.
        HitTracker ht = userManager.findUser("testuser2");
        assertEquals("findUser() malfunction", ht.size(), 1);
        @SuppressWarnings("rawtypes")
        Iterator i = ht.getAllHits();
        assertTrue("findUser() did not return any users", i.hasNext());
        User userFound = (User) i.next();
        assertEquals("findUser() didn't find the right user",
            ((PipelineUser) userFound).getPiUser()
                .getLoginName(), ((PipelineUser) user2).getPiUser()
                .getLoginName());

        // Try finding all users.
        ht = userManager.findUser("all");
        assertEquals("findUser() malfunction", ht.size(), 2);
        i = ht.getAllHits();
        assertTrue("findUser() did not return any users", i.hasNext());
        userFound = (User) i.next();
        assertEquals("findUser() didn't find the right user",
            ((PipelineUser) userFound).getPiUser()
                .getLoginName(), ((PipelineUser) user).getPiUser()
                .getLoginName());
        assertTrue("findUser() did not return both users", i.hasNext());
        userFound = (User) i.next();
        assertEquals("findUser() didn't find the right user",
            ((PipelineUser) userFound).getPiUser()
                .getLoginName(), ((PipelineUser) user2).getPiUser()
                .getLoginName());
    }

    @Test
    public void testAuthenticator() {
        Authenticator authenticator = new Authenticator() {
            @Override
            public boolean authenticate(User arg0, String arg1)
                throws UserManagerException {
                assertEquals(arg0, user);
                assertEquals(arg1, "password");
                return true;
            }
        };
        userManager.setAuthenticator(authenticator);
        assertTrue(userManager.getAuthenticator()
            .authenticate(user, "password"));
    }

    @Test
    public void testGetGroups() {
        Collection<Group> groupCollection = userManager.getGroups();
        assertEquals("getGroups() didn't return two groups",
            groupCollection.size(), 2);
        ArrayList<Role> roles = new ArrayList<Role>();
        roles.add(((PipelineGroup) groupCollection.toArray()[0]).role);
        roles.add(((PipelineGroup) groupCollection.toArray()[1]).role);
        assertTrue("getGroups() didn't return group " + group,
            roles.contains(((PipelineGroup) group).role));
        assertTrue("getGroups() didn't return group " + group2,
            roles.contains(((PipelineGroup) group2).role));
    }

    @Test
    public void testGroupsSorted() {
        // This version of OpenEdit is broken. It uses Group.toString() in the
        // comparator, but then does not override Group.toString! So, the sorted
        // list isn't what you would expect. Worse, the order is not
        // deterministic.
        // System.out.println(group.toString());
        Collection<Group> sortedGroups = userManager.getGroupsSorted();
        assertEquals(groups.size(), sortedGroups.size());
    }

    @Test
    public void testPermissions() {
        @SuppressWarnings("unchecked")
        List<Permission> permissions = userManager.getPermissions();
        boolean found = false;
        for (Permission permission : permissions) {
            if (permission.getName()
                .equals("oe.administration")) {
                found = true;
            }
        }
        assertTrue("oe.administration not found in permissions", found);

        assertTrue("Should have privilege1", group.hasPermission("privilege1"));
        assertTrue("Should have privilege1", group2.hasPermission("privilege2"));
        assertTrue("Should have privilege1", group2.hasPermission("privilege3"));

        assertTrue("User should have privilege1",
            user.hasPermission("privilege1"));
        assertTrue("User should have privilege3",
            user.hasPermission("privilege3"));

        assertTrue("User should not have nosuchprivilege",
            !user.hasPermission("nosuchprivilege"));

        PermissionsManager permissionsManager = new PermissionsManager();
        List<String> systemPermissions = newArrayList();
        systemPermissions.add("jailbreak");
        permissionsManager.setSystemPermissionGroups(systemPermissions);
        userManager.setPermissionsManager(permissionsManager);
        assertEquals(permissionsManager, userManager.getPermissionsManager());
        assertEquals("jailbreak", userManager.getSystemPermissionGroups()
            .get(0));
    }

    @Test
    public void testGetUsers() {
        HitTracker ht = userManager.getUsers();
        assertEquals("getUsers() did not return two users", ht.size(), 2);
        @SuppressWarnings("rawtypes")
        Iterator i = ht.getAllHits();
        assertTrue("getUsers() did not return any users", i.hasNext());
        String userFound = (String) i.next();
        assertEquals("getUsers() didn't find the right user", userFound,
            user.getUserName());
        assertTrue("getUsers() did not return both users", i.hasNext());
        userFound = (String) i.next();
        assertEquals("getUsers() didn't find the right user", userFound,
            user2.getUserName());
    }

    @Test
    public void testGetUsersInGroup() {
        HitTracker ht = userManager.getUsersInGroup("testrole");
        assertEquals("getUsersInGroup() did not return a user", ht.size(), 1);
        @SuppressWarnings("rawtypes")
        Iterator i = ht.getAllHits();
        assertTrue("getUsersInGroup() did not return any users", i.hasNext());
        User userFound = (User) i.next();
        assertEquals("getUsersInGroup() didn't find the right user",
            ((PipelineUser) userFound).getPiUser()
                .getLoginName(), ((PipelineUser) user).getPiUser()
                .getLoginName());
    }

    @Test
    public void testGetUserByEmail() {
        assertEquals(user.getUserName(),
            userManager.getUserByEmail("mr@host")
                .getUserName());
    }

    @Test
    public void testSaveGroup() {
        userManager.saveGroup(group);
    }

    @Test
    public void testSaveUser() {
        userManager.saveUser(user);
    }

    @Test
    public void testUserAuthenticate() throws Exception {

        UserListener listener = new UserListener(user);
        userManager.addUserListener(listener);

        assertTrue("Should have authenticated with new password successfully",
            userManager.authenticate(user, "testuser"));
        assertTrue("Should not have authenticated",
            !userManager.authenticate(user, "badpwd"));

        // Should not throw an exception.
        userManager.logout(user);
    }

    @Test
    public void setPageManager() {
        PageManager pageManager = new PageManager();
        userManager.setPageManager(pageManager);
        assertEquals(pageManager, userManager.getPageManager());
    }

    @Test
    public void testUserPut() throws Exception {
        user.put("foo", "bar");
        assertEquals("bar", user.get("foo"));
    }

    @Test
    public void testUserPutAll() throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("foo", "bar");
        map.put("baz", "wibble");
        user.putAll(map);
        assertEquals("bar", user.get("foo"));
        assertEquals("wibble", user.get("baz"));
    }

    @Test
    public void testUserGetCreationDate() throws Exception {
        long currentTime = System.currentTimeMillis();
        // There shouldn't be more than about 2 seconds between the two dates.
        assertTrue("Dates are not within 2 seconds of each other", currentTime
            - user.getCreationDate()
                .getTime() <= 2000);
    }

    private static class UserListener implements
        com.openedit.users.UserListener {

        private final User user;

        public UserListener(User user) {
            this.user = user;
        }

        @Override
        public void userLoggedOut(User arg0) {
            assertEquals(user.getUserName(), arg0.getUserName());
        }

        @Override
        public void userLoggedIn(User arg0) {
            assertEquals(user.getUserName(), arg0.getUserName());
        }

        @Override
        public void userDeleted(User arg0) {
            assertEquals(user.getUserName(), arg0.getUserName());
        }

        @Override
        public void userAdded(User arg0) {
            assertEquals(user.getUserName(), arg0.getUserName());
        }
    }
}
