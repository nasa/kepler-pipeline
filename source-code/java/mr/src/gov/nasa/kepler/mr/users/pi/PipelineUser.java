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

import gov.nasa.kepler.hibernate.services.Role;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;

import com.openedit.users.Group;
import com.openedit.users.Permission;
import com.openedit.users.PropertyContainer;
import com.openedit.users.User;
import com.openedit.users.UserManagerException;
import com.openedit.users.filesystem.MapPropertyContainer;

@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD")
public class PipelineUser implements User {

    protected gov.nasa.kepler.hibernate.services.User piUser;

    protected String firstName = null;
    protected String lastName = null;
    protected MapPropertyContainer properties = new MapPropertyContainer();

    public PipelineUser(gov.nasa.kepler.hibernate.services.User piUser) {
        this.piUser = piUser;
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void addGroup(Group group) {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void clearGroups() {
    }

    @Override
    public String getClearPassword() {
        return piUser.getPassword();
    }

    @Override
    public Date getCreationDate() {
        return piUser.getCreated();
    }

    @Override
    public String getEmail() {
        return piUser.getEmail();
    }

    @Override
    public String getFirstName() {
        String displayName = piUser.getDisplayName();
        int index = displayName.indexOf(' ');
        if (index != -1) {
            displayName = displayName.substring(0, index);
        }
        return firstName = displayName;
    }

    @Override
    public String getLastName() {
        String displayName = piUser.getDisplayName();
        int index = displayName.lastIndexOf(' ');
        if (index != -1 && displayName.length() > index) {
            displayName = displayName.substring(index + 1);
        }
        return lastName = displayName;
    }

    @Override
    public Collection<Group> getGroups() {
        List<Role> roles = piUser.getRoles();
        List<Group> groups = new ArrayList<Group>();
        for (Role role : roles) {
            groups.add(new PipelineGroup(role));
        }
        return groups;
    }

    @Override
    public String getPassword() {
        return piUser.getPassword();
    }

    @Override
    public Object getProperty(String propertyName) {
        Object property = properties.get(propertyName);
        if (property == null) {
            property = piUser.hasPrivilege(propertyName);
        }

        return property;
    }

    @Override
    public String getShortDescription() {
        return piUser.getDisplayName();
    }

    @Override
    public String getUserName() {
        return piUser.getLoginName();
    }

    @Override
    public boolean hasPermission(String permissionName) {
        for (Group group : getGroups()) {
            if (group.hasPermission(permissionName)) {
                return true;
            }
        }

        if (piUser.hasPrivilege(permissionName)) {
            return true;
        }

        String ok = getPropertyContainer().getString(permissionName);
        if (Boolean.parseBoolean(ok)) {
            return true;
        }

        return false;
    }

    public gov.nasa.kepler.hibernate.services.User getPiUser() {
        return piUser;
    }

    public void setPiUser(gov.nasa.kepler.hibernate.services.User piUser) {
        this.piUser = piUser;
    }

    @Override
    public boolean isInGroup(Group group) {
        return piUser.getRoles()
            .contains(((PipelineGroup) group).getRole());
    }

    @Override
    public boolean isVirtual() {
        return false;
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<Permission> listGroupPermissions() {
        List<Permission> all = new ArrayList<Permission>();
        for (Object element : getGroups()) {
            Group group = (Group) element;
            all.addAll(group.getPermissions());
        }
        return all;
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void removeGroup(Group group) {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void setEmail(String email) {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void setFirstName(String firstName) {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void setLastName(String lastName) {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void setPassword(String password) throws UserManagerException {
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void setUserName(String userName) {
    }

    @Override
    public void setVirtual(boolean virtualFlag) {
    }

    @Override
    public PropertyContainer getPropertyContainer() {
        return this;
    }

    public void setPropertyContainer(PropertyContainer container) {
        throw new RuntimeException("setPropertyContainer called: " + container);
    }

    @Override
    public boolean hasProperty(String propertyName) {
        if (properties.get(propertyName) != null) {
            return true;
        }
        if (piUser.hasPrivilege(propertyName)) {
            return true;
        }
        return false;
    }

    @Override
    @SuppressWarnings("rawtypes")
    public Map getProperties() {
        return properties.getProperties();
    }

    @Override
    public Object get(String propertyName) {
        return properties.get(propertyName);
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void put(String propertyName, Object propertyValue)
        throws UserManagerException {
        properties.put(propertyName, propertyValue);
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    @SuppressWarnings("rawtypes")
    public void putAll(Map properties) throws UserManagerException {
        this.properties.putAll(properties);
    }

    @Override
    public void remove(String propertyName) throws UserManagerException {
        properties.remove(propertyName);
    }

    @Override
    public void removeAll(String[] properties) throws UserManagerException {
        this.properties.removeAll(properties);
    }

    @Override
    public boolean getBoolean(String propertyName) {
        return Boolean.valueOf(getString(propertyName))
            .booleanValue();
    }

    @Override
    public String getString(String propertyName) {
        return (String) get(propertyName);
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void safePut(String key, Object value) {
    }

    @Override
    public String toString() {
        return piUser != null ? piUser.getLoginName() : "";
    }
}
