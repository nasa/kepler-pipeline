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

import java.util.Collection;
import java.util.Date;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.openedit.users.Group;
import com.openedit.users.PropertyContainer;
import com.openedit.users.UserManagerException;
import com.openedit.users.filesystem.MapPropertyContainer;

@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD")
public class PipelineGroup implements Group {

    private static final Log log = LogFactory.getLog(PipelineGroup.class);

    protected Role role;
    protected PropertyContainer properties = new MapPropertyContainer();

    public PipelineGroup(Role role) {
        this.role = role;
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void addPermission(String permissionName)
        throws UserManagerException {
    }

    @Override
    public Date getCreationDate() {
        return role.getCreated();
    }

    @Override
    public long getLastModified() {
        return 0;
    }

    @Override
    public String getName() {
        return role.getName();
    }

    @Override
    public Collection<String> getPermissions() {
        log.debug("Permissions for role " + getName() + ": "
            + role.getPrivileges()
                .size());
        return role.getPrivileges();
    }

    @Override
    public boolean hasPermission(String permissionName) {
        log.debug(getName() + ".hasPermission(" + permissionName + ") = "
            + role.hasPrivilege(permissionName));
        return role.hasPrivilege(permissionName);
    }

    /**
     * This method is disabled so that pipeline users/roles/privileges may only
     * be created, deleted, or modified via the pipeline GUI.
     */
    @Override
    public void removePermission(String permissionName)
        throws UserManagerException {
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    @Override
    public PropertyContainer getPropertyContainer() {
        if (properties == null) {
            properties = new MapPropertyContainer();
        }
        return properties;
    }

    public void setPropertyContainer(PropertyContainer container) {
        properties = container;
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

    @Override
    public void put(String propertyName, Object propertyValue)
        throws UserManagerException {
        properties.put(propertyName, propertyValue);
    }

    @Override
    @SuppressWarnings("rawtypes")
    public void putAll(Map propertyMap) throws UserManagerException {
        properties.putAll(propertyMap);
    }

    @Override
    public void remove(String propertyName) throws UserManagerException {
        properties.remove(propertyName);
    }

    @Override
    public void removeAll(String[] propertyNames) throws UserManagerException {
        properties.removeAll(propertyNames);
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

    @Override
    public void safePut(String key, Object value) {
        try {
            if (value == null) {
                getPropertyContainer().remove(key);
            } else {
                Object o = null;
                if (value instanceof String) {
                    o = ((String) value).trim();
                }
                getPropertyContainer().put(key, o);
            }
        } catch (UserManagerException e) {
            log.error(e);
        }
    }
}
