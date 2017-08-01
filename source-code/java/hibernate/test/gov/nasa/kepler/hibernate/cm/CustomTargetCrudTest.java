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

package gov.nasa.kepler.hibernate.cm;

import static com.google.common.collect.Lists.newArrayList;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class CustomTargetCrudTest {

    private static final int SKY_GROUP_ID_1 = 1;
    private static final int SKY_GROUP_ID_2 = 2;

    private CustomTargetCrud customTargetCrud;

    private DatabaseService databaseService;

    private CustomTarget customTarget1;
    private CustomTarget customTarget2;

    private int nextCustomTargetId = TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        customTargetCrud = new CustomTargetCrud(databaseService);
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {
        try {
            databaseService.beginTransaction();

            customTargetCrud.create(new CustomTarget(nextCustomTargetId++, 0));

            customTarget1 = new CustomTarget(nextCustomTargetId++,
                SKY_GROUP_ID_1);
            customTarget2 = new CustomTarget(nextCustomTargetId++,
                SKY_GROUP_ID_2);

            Collection<CustomTarget> customTargets = new HashSet<CustomTarget>();
            customTargets.add(customTarget1);
            customTargets.add(customTarget2);

            customTargetCrud.create(customTargets);

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    // SOC_REQ_IMPL 926.CM.1
    // SOC_REQ_IMPL SOC993
    @Test
    public void testRetrieveCustomTarget() {
        populateObjects();

        List<CelestialObject> actualCustomTargets = customTargetCrud.retrieveForKeplerId(customTarget1.getKeplerId());

        List<CelestialObject> expectedCustomTargets = new ArrayList<CelestialObject>();
        expectedCustomTargets.add(customTarget1);

        assertEquals(expectedCustomTargets, actualCustomTargets);
    }

    @Test
    public void testRetrieveCustomTargetForNonexistentKeplerId() {
        populateObjects();

        List<CelestialObject> actualCustomTargets = customTargetCrud.retrieveForKeplerId(-100);

        List<CelestialObject> expectedCustomTargets = new ArrayList<CelestialObject>();

        assertEquals(expectedCustomTargets, actualCustomTargets);
    }

    @Test
    public void testRetrieveCustomTargetsForKeplerIdRange() {
        populateObjects();

        List<CelestialObject> actualCustomTargets = customTargetCrud.retrieve(
            customTarget1.getKeplerId(), customTarget1.getKeplerId());

        List<CelestialObject> expectedCustomTargets = new ArrayList<CelestialObject>();
        expectedCustomTargets.add(customTarget1);

        assertEquals(expectedCustomTargets, actualCustomTargets);
    }

    @Test
    public void testRetrieveCustomTargetsForSkyGroupIdKeplerIdRange() {
        populateObjects();

        List<CelestialObject> actualCustomTargets = customTargetCrud.retrieve(
            customTarget1.getSkyGroupId(), customTarget1.getKeplerId(),
            customTarget1.getKeplerId());

        List<CelestialObject> expectedCustomTargets = new ArrayList<CelestialObject>();
        expectedCustomTargets.add(customTarget1);

        assertEquals(expectedCustomTargets, actualCustomTargets);
    }

    @Test
    public void testRetrieveKeplerIdsForSkyGroupIdKeplerIdRange() {
        populateObjects();

        List<Integer> actualKeplerIds = customTargetCrud.retrieveKeplerIds(
            customTarget1.getSkyGroupId(), customTarget1.getKeplerId(),
            customTarget1.getKeplerId());

        List<Integer> expectedKeplerIds = newArrayList();
        expectedKeplerIds.add(customTarget1.getKeplerId());

        assertEquals(expectedKeplerIds, actualKeplerIds);
    }

    @Test
    public void testRetrieveCustomTargetsForSkyGroupId() {
        populateObjects();

        List<CelestialObject> actualCustomTargets = customTargetCrud.retrieveForSkyGroupId(SKY_GROUP_ID_1);

        List<CelestialObject> expectedCustomTargets = new ArrayList<CelestialObject>();
        expectedCustomTargets.add(customTarget1);

        assertEquals(expectedCustomTargets, actualCustomTargets);
    }

    @Test(expected = NullPointerException.class)
    public void testRetrieveCustomTargetsWithNullIds() {
        customTargetCrud.retrieve(null);
    }

    @Test
    public void testRetrieveCustomTargets() {
        populateObjects();

        List<CelestialObject> customTargets = customTargetCrud.retrieve(new ArrayList<Integer>());
        assertNotNull(customTargets);
        assertEquals(0, customTargets.size());

        customTargets = customTargetCrud.retrieve(Arrays.asList(-1));
        assertNotNull(customTargets);
        assertEquals(1, customTargets.size());
        assertNull(customTargets.get(0));

        customTargets = customTargetCrud.retrieve(Arrays.asList(
            customTarget2.getKeplerId(), customTarget1.getKeplerId(), -1));
        assertEquals(3, customTargets.size());
        assertEquals(customTarget2, customTargets.get(0));
        assertEquals(customTarget1, customTargets.get(1));
        assertNull(customTargets.get(2));
    }

    @Test
    public void testRetrieveNextCustomTargetKeplerId() {
        assertEquals(TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START,
            customTargetCrud.retrieveNextCustomTargetKeplerId());

        databaseService.beginTransaction();
        customTargetCrud.create(new CustomTarget(nextCustomTargetId++, 1));
        assertEquals(nextCustomTargetId,
            customTargetCrud.retrieveNextCustomTargetKeplerId());
        databaseService.commitTransaction();

        populateObjects();

        databaseService.beginTransaction();
        assertEquals(nextCustomTargetId,
            customTargetCrud.retrieveNextCustomTargetKeplerId());

        customTargetCrud.create(new CustomTarget(nextCustomTargetId++, 1));
        assertEquals(nextCustomTargetId,
            customTargetCrud.retrieveNextCustomTargetKeplerId());
        databaseService.commitTransaction();
    }

    @Test
    public void testRetrieveAllVisibleKeplerSkyGroupIds() {
        assertEquals(Collections.EMPTY_LIST,
            customTargetCrud.retrieveAllVisibleKeplerSkyGroupIds());

        populateObjects();

        List<Object[]> ids = customTargetCrud.retrieveAllVisibleKeplerSkyGroupIds();
        assertEquals(2, ids.size());
        assertEquals(
            TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START + 1,
            ids.get(0)[0]);
        assertEquals(SKY_GROUP_ID_1, ids.get(0)[1]);
        assertEquals(
            TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START + 2,
            ids.get(1)[0]);
        assertEquals(SKY_GROUP_ID_2, ids.get(1)[1]);
    }

    @Test
    public void testCustomTargetCount() {
        assertEquals(0, customTargetCrud.customTargetCount());
        populateObjects();
        assertEquals(3, customTargetCrud.customTargetCount());
    }

    @Test
    public void testVisibleCustomTargetCount() {
        assertEquals(0, customTargetCrud.visibleCustomTargetCount());
        populateObjects();
        assertEquals(2, customTargetCrud.visibleCustomTargetCount());
    }

    @Test
    public void testRetrieveSkyGroupIdsForKeplerIds() {
        populateObjects();

        List<Integer> keplerIds = Arrays.asList(customTarget1.getKeplerId());

        Map<Integer, Integer> actualKeplerIdToSkyGroupId = customTargetCrud.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        Map<Integer, Integer> expectedKeplerIdToSkyGroupId = new HashMap<Integer, Integer>();
        expectedKeplerIdToSkyGroupId.put(customTarget1.getKeplerId(),
            SKY_GROUP_ID_1);

        assertEquals(expectedKeplerIdToSkyGroupId, actualKeplerIdToSkyGroupId);
    }

}
