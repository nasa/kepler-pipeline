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

package gov.nasa.kepler.hibernate.dr;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ConfigMapCrudTest {

    private static final int OTHER_SC_CONFIG_ID = 99;

    private static final int SC_CONFIG_ID = 1;

    private static final double MJD = 50000;

    private DatabaseService databaseService;
    private ConfigMapCrud configMapCrud;
    private ConfigMap expectedConfigMap;
    private ConfigMap otherConfigMap;

    private ReflectionEquals reflectionEquals;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {
        configMapCrud = new ConfigMapCrud(databaseService);

        reflectionEquals = new ReflectionEquals();

        databaseService.beginTransaction();

        Map<String, String> map = new HashMap<String, String>();
        map.put("1", "2");
        map.put("3", "4");
        map.put("5", "6");

        expectedConfigMap = new ConfigMap(SC_CONFIG_ID, MJD, map);
        configMapCrud.createConfigMap(expectedConfigMap);

        otherConfigMap = new ConfigMap(OTHER_SC_CONFIG_ID, MJD, map);
        configMapCrud.createConfigMap(otherConfigMap);

        databaseService.commitTransaction();
    }

    @Test
    public void retrieveConfigMapByIds() throws Exception {
        populateObjects();

        List<Integer> ids = new ArrayList<Integer>();
        ids.add(SC_CONFIG_ID);
        ids.add(OTHER_SC_CONFIG_ID);

        List<ConfigMap> list = configMapCrud.retrieveConfigMaps(ids);
        assertEquals(2, list.size());
        assertEquals(expectedConfigMap, list.get(0));
        assertEquals(otherConfigMap, list.get(1));
    }

    @Test
    public void retrieveConfigMap() throws Exception {
        populateObjects();

        ConfigMap actual = configMapCrud.retrieveConfigMap(SC_CONFIG_ID);

        reflectionEquals.assertEquals(expectedConfigMap, actual);
    }

    @Test
    public void testRetrieveAllConfigMaps() {
        populateObjects();
        List<ConfigMap> configMaps = configMapCrud.retrieveAllConfigMaps();
        assertEquals(2, configMaps.size());
        assertEquals(otherConfigMap, configMaps.get(0));
        assertEquals(expectedConfigMap, configMaps.get(1));
    }
}
