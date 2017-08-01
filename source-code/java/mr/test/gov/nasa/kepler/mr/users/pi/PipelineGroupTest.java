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
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.services.Role;

import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableMap;
import com.openedit.users.filesystem.MapPropertyContainer;

public class PipelineGroupTest {
    private static final String ROLE1 = "role1";
    private static final String ROLE2 = "role2";
    private static final String PRIVILEGE1 = "privilege1";
    private static final String PRIVILEGE2 = "privilege2";

    private PipelineGroup pipelineGroup;
    private Role role1 = new Role(ROLE1);
    private Role role2 = new Role(ROLE2);

    @Before
    public void populateObjects() {
        pipelineGroup = new PipelineGroup(role1);
        role1.addPrivilege(PRIVILEGE1);
    }

    @Test
    public void testAddPermission() {
        assertTrue(pipelineGroup.hasPermission(PRIVILEGE1));
        assertTrue(pipelineGroup.getPermissions()
            .contains(PRIVILEGE1));
        assertFalse(pipelineGroup.hasPermission(PRIVILEGE2));
        assertFalse(pipelineGroup.getPermissions()
            .contains(PRIVILEGE2));

        pipelineGroup.addPermission(PRIVILEGE2);
        assertFalse(pipelineGroup.hasPermission(PRIVILEGE2));

        pipelineGroup.removePermission(PRIVILEGE1);
        assertTrue(pipelineGroup.hasPermission(PRIVILEGE1));
    }

    @Test
    public void testGetCreationDate() {
        long now = System.currentTimeMillis();
        assertEquals(now, pipelineGroup.getCreationDate()
            .getTime(), 100);
    }

    @Test
    public void testGetLastModified() {
        assertEquals(0, pipelineGroup.getLastModified());
    }

    @Test
    public void testGetName() {
        assertEquals(ROLE1, pipelineGroup.getName());
    }

    @Test
    public void testRoles() {
        assertEquals(role1, pipelineGroup.getRole());
        pipelineGroup.setRole(role2);
        assertEquals(role2, pipelineGroup.getRole());
    }

    @Test
    public void testPropertyContainer() {
        assertEquals(MapPropertyContainer.class,
            pipelineGroup.getPropertyContainer()
                .getClass());
        pipelineGroup.setPropertyContainer(pipelineGroup);
        assertEquals(pipelineGroup, pipelineGroup.getPropertyContainer());
    }

    @Test
    public void testProperties() {
        assertEquals(0, pipelineGroup.getProperties()
            .size());
        assertFalse(pipelineGroup.getBoolean("foo"));

        pipelineGroup.safePut("foo", "foofoo");
        assertEquals("foofoo", pipelineGroup.get("foo"));

        pipelineGroup.put("foo", "foofoo");
        assertEquals("foofoo", pipelineGroup.get("foo"));
        assertEquals(1, pipelineGroup.getProperties()
            .size());
        assertEquals("foofoo", pipelineGroup.getProperties()
            .get("foo"));
        assertEquals("foofoo", pipelineGroup.get("foo"));
        assertEquals("foofoo", pipelineGroup.getString("foo"));

        pipelineGroup.putAll(ImmutableMap.of("foo", "foofoo", "bar", "barbar",
            "baz", "bazbaz"));
        assertEquals(3, pipelineGroup.getProperties()
            .size());
        assertEquals("foofoo", pipelineGroup.get("foo"));
        assertEquals("barbar", pipelineGroup.get("bar"));
        assertEquals("bazbaz", pipelineGroup.get("baz"));

        pipelineGroup.remove("foo");
        assertNull(pipelineGroup.get("foo"));

        pipelineGroup.removeAll(new String[] { "foo", "bar", "baz" });
        assertNull(pipelineGroup.get("bar"));
        assertNull(pipelineGroup.get("baz"));
    }
}
