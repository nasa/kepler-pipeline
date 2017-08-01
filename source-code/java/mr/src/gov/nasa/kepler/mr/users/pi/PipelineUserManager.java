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

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.UserCrud;
import gov.nasa.kepler.services.security.SecurityOperations;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeSet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.openedit.hittracker.HitTracker;
import com.openedit.hittracker.ListHitTracker;
import com.openedit.page.manage.PageManager;
import com.openedit.users.Authenticator;
import com.openedit.users.Group;
import com.openedit.users.GroupComparator;
import com.openedit.users.User;
import com.openedit.users.UserComparator;
import com.openedit.users.UserListener;
import com.openedit.users.UserManager;
import com.openedit.users.UserManagerException;
import com.openedit.users.filesystem.PermissionsManager;

public class PipelineUserManager implements UserManager {

    private static final Log log = LogFactory.getLog(PipelineUserManager.class);

    private UserCrud userCrud = new UserCrud();
    private Authenticator authenticator;
    private PermissionsManager permissionsManager;
    private PageManager pageManager;
    private Map<UserListener, Object> userListeners;
    private Map<String, PipelineUser> pipelineUserByName = new HashMap<String, PipelineUser>();

    public PipelineUserManager() {
    }

    @Override
    public boolean authenticate(User user, String password)
        throws UserManagerException {

        try {
            PipelineUser pipelineUser = getUser(user.getUserName());
            if (new SecurityOperations().validateLogin(
                pipelineUser.getPiUser(), password)) {
                log.info("User " + pipelineUser + " logged in");
                fireUserLoggedIn(user);
                return true;
            }
        } catch (PipelineException e) {
            log.debug("Could not authenticate user " + user.getUserName(), e);
            throw new UserManagerException(e);
        }

        return false;
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public Group createGroup(String groupName) throws UserManagerException {
        Group group = getGroup(groupName);
        if (group != null) {
            return group;
        }
        return null;
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public User createGuestUser(String userName, String password,
        String groupName) {
        return null;
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public User createUser(String userName, String password)
        throws UserManagerException {
        return new PipelineUser(null);
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void deleteGroup(Group group) throws UserManagerException {
    }

    @Override
    @SuppressWarnings("unchecked")
    public void deleteGroups(@SuppressWarnings("rawtypes") List groups)
        throws UserManagerException {
        if (groups != null) {
            for (Group group : (List<Group>) groups) {
                deleteGroup(group);
            }
        }
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void deleteUser(User user) throws UserManagerException {
    }

    @Override
    @SuppressWarnings("unchecked")
    public void deleteUsers(@SuppressWarnings("rawtypes") List users)
        throws UserManagerException {
        for (User user : (List<User>) users) {
            deleteUser(user);
        }
    }

    @Override
    public HitTracker findUser(String query) throws UserManagerException {
        return findUser(query, 1000);
    }

    @SuppressWarnings("rawtypes")
    public HitTracker findUser(String query, int maxNum)
        throws UserManagerException {

        ListHitTracker tracker = new ListHitTracker();

        if (query == null || query.equalsIgnoreCase("all")
            || query.length() == 0) {
            for (Iterator iter = getUsers().getAllHits(); iter.hasNext()
                && tracker.getTotal() < maxNum;) {
                String username = (String) iter.next();
                User user = getUser(username);
                tracker.addHit(user);
            }
            return tracker;
        }
        for (Iterator iter = getUsers().getAllHits(); iter.hasNext();) {
            String username = (String) iter.next();
            if (matches(username, query)) {
                User user = getUser(username);
                tracker.addHit(user);
            }
            if (tracker.getTotal() >= maxNum) {
                break;
            }
        }

        return tracker;
    }

    private boolean matches(String inText, String inQuery) {
        if (inText != null) {
            if (inText.toLowerCase()
                .startsWith(inQuery)) {
                return true;
            }
        }

        return false;
    }

    @Override
    public Authenticator getAuthenticator() {
        return authenticator;
    }

    @Override
    public Group getGroup(String groupName) throws UserManagerException {
        List<Role> roles;

        roles = userCrud.retrieveAllRoles();
        if (roles == null) {
            String errorText = "Unable to get pipeline roles";
            log.error(errorText);
            throw new UserManagerException(errorText);
        }
        for (Role role : roles) {
            if (role.getName()
                .equals(groupName)) {
                return new PipelineGroup(role);
            }
        }

        return null;
    }

    @Override
    public Collection<Group> getGroups() {
        List<Role> roles;

        roles = userCrud.retrieveAllRoles();
        if (roles == null) {
            String errorText = "Unable to get pipeline roles";
            log.error(errorText);
            throw new UserManagerException(errorText);
        }
        ArrayList<Group> groups = new ArrayList<Group>();
        for (Role role : roles) {
            log.debug("getGroups(): role: " + role);
            groups.add(new PipelineGroup(role));
        }
        log.debug("getGroups(): Returning list with " + groups.size()
            + " groups");

        return groups;
    }

    public Collection<Group> getGroupsSorted() {
        @SuppressWarnings("unchecked")
        TreeSet<Group> treeSet = new java.util.TreeSet<Group>(
            new GroupComparator());
        treeSet.addAll(getGroups());

        return treeSet;
    }

    @Override
    @SuppressWarnings("rawtypes")
    public List getPermissions() throws UserManagerException {
        return getPermissionsManager().getSystemPermissions();
    }

    @Override
    public PipelineUser getUser(String userName) throws UserManagerException {
        PipelineUser pipelineUser = pipelineUserByName.get(userName);
        if (pipelineUser == null) {
            pipelineUser = new PipelineUser(null);
            pipelineUserByName.put(userName, pipelineUser);
        }

        DatabaseServiceFactory.getInstance()
            .evict(pipelineUser.getPiUser());
        pipelineUser.setPiUser(userCrud.retrieveUser(userName));

        if (pipelineUser.getPiUser() == null) {
            // No such user.
            return null;
        }

        return pipelineUser;
    }

    @Override
    public HitTracker getUsers() {
        List<gov.nasa.kepler.hibernate.services.User> users = getAllUsers();
        HitTracker tracker = null;
        if (users != null) {
            List<String> userNameList = new ArrayList<String>();
            for (gov.nasa.kepler.hibernate.services.User user : users) {
                userNameList.add(user.getLoginName());
            }
            tracker = new ListHitTracker(userNameList);
        } else {
            tracker = new ListHitTracker();
        }

        return tracker;
    }

    private List<gov.nasa.kepler.hibernate.services.User> getAllUsers() {
        List<gov.nasa.kepler.hibernate.services.User> users;

        users = userCrud.retrieveAllUsers();
        if (users == null) {
            String errorText = "Unable to get pipeline users";
            log.error(errorText);
            throw new UserManagerException(errorText);
        }

        return users;
    }

    @Override
    @SuppressWarnings({ "rawtypes", "unchecked" })
    public HitTracker getUsersInGroup(Group group) {
        List<User> all = new ArrayList<User>();
        for (Iterator iter = getUsers().getAllHits(); iter.hasNext();) {
            String name = (String) iter.next();
            User user = getUser(name);
            if (user.isInGroup(group)) {
                all.add(user);
            }
        }
        Collections.sort(all, new UserComparator());
        HitTracker tracker = new ListHitTracker(all);

        return tracker;
    }

    @Override
    public HitTracker getUsersInGroup(String groupName) {
        Group group = getGroup(groupName);
        return getUsersInGroup(group);
    }

    @Override
    @SuppressWarnings("rawtypes")
    public User getUserByEmail(String emailAddress) throws UserManagerException {
        for (Iterator iter = getUsers().getAllHits(); iter.hasNext();) {
            String username = (String) iter.next();
            User element = getUser(username);

            String email = element.getEmail();
            if (email != null && email.equalsIgnoreCase(emailAddress)) {
                return element;
            }
        }

        return null;
    }

    @Override
    public Map<UserListener, Object> getUserListeners() {
        if (userListeners == null) {
            userListeners = new HashMap<UserListener, Object>();
        }
        return userListeners;
    }

    @Override
    public void logout(User user) {
        fireUserLoggedOut(user);
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void saveGroup(Group group) {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void saveUser(User user) {
    }

    @Override
    public void setAuthenticator(Authenticator authenticator) {
        this.authenticator = authenticator;
    }

    private void fireUserLoggedOut(User inUser) {
        for (UserListener listener : getUserListeners().keySet()) {
            listener.userLoggedOut(inUser);
        }
    }

    private void fireUserLoggedIn(User inUser) {
        for (UserListener listener : getUserListeners().keySet()) {
            listener.userLoggedIn(inUser);
        }
    }

    @Override
    public void addUserListener(UserListener inListener) {
        getUserListeners().put(inListener, this);
    }

    @Override
    public PermissionsManager getPermissionsManager() {
        if (permissionsManager == null) {
            permissionsManager = new PipelinePermissionsManager();
            permissionsManager.setPageManager(getPageManager());

            permissionsManager.loadPermissions();
        }

        return permissionsManager;
    }

    public void setPermissionsManager(PermissionsManager permissionsManager) {
        this.permissionsManager = permissionsManager;
    }

    @Override
    @SuppressWarnings("rawtypes")
    public List getSystemPermissionGroups() {
        return getPermissionsManager().getSystemPermissionGroups();
    }

    public void setPageManager(PageManager pageManager) {
        this.pageManager = pageManager;
    }

    public PageManager getPageManager() {
        return pageManager;
    }

    void setUserCrud(UserCrud userCrud) {
        this.userCrud = userCrud;
    }
}
