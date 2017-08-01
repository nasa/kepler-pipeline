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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.List;
import java.util.Map;

import junit.framework.Assert;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.HibernateException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * Tests the {@link CharacteristicCrud} class.
 * 
 * @author Bill Wohler
 */
public class CharacteristicCrudTest {

    private static final Log log = LogFactory.getLog(CharacteristicCrudTest.class);

    private static final int KEPLER_ID = 12345;

    private DatabaseService databaseService;
    private KicCrud kicCrud;
    private CharacteristicCrud characteristicCrud;
    private Kic kic = createKicObject();
    private CharacteristicType type = createCharacteristicType();
    private Characteristic characteristic = createCharacteristic(
        kic.getKeplerId(), type);

    @Before
    public void createDatabase() throws Exception {
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
        kicCrud = new KicCrud();
        characteristicCrud = new CharacteristicCrud();
    }

    @After
    public void destroyDatabase() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
        databaseService = null;
    }

    @Test
    public void testCreate() {
        populateObjects();
    }

    @Test(expected = HibernateException.class)
    public void testCreateWithExistingObject() {
        testCreate();
        testCreate();
    }

    @Test
    public void testRetrieveCharacteristic() {
        populateObjects();

        assertNull(characteristicCrud.retrieveCharacteristic(
            characteristic.getKeplerId() + 1, characteristic.getType()));

        Characteristic actualCharacteristic = characteristicCrud.retrieveCharacteristic(
            characteristic.getKeplerId(), characteristic.getType());
        assertEquals(characteristic, actualCharacteristic);

        Characteristic characteristic1 = null;
        try {
            databaseService.beginTransaction();
            characteristic1 = createCharacteristic(kic.getKeplerId(), type,
                characteristic.getValue() + 1.0);
            characteristicCrud.create(characteristic1);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        actualCharacteristic = characteristicCrud.retrieveCharacteristic(
            characteristic.getKeplerId(), characteristic.getType());
        assertEquals(characteristic1, actualCharacteristic);
    }

    @Test
    public void testRetrieveCharacteristics() {
        Characteristic characteristic = createCharacteristic(KEPLER_ID,
            createCharacteristicType());
        assertEquals(
            Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(characteristic.getKeplerId()));

        populateObjects();

        characteristic = createCharacteristic(KEPLER_ID,
            createCharacteristicType());
        Collection<Characteristic> characteristics = characteristicCrud.retrieveCharacteristics(characteristic.getKeplerId());
        assertEquals(characteristic, characteristics.iterator()
            .next());
    }

    @Test
    public void testRetrieveCharacteristicMap() {
        populateObjects();

        assertEquals(0,
            characteristicCrud.retrieveCharacteristicMap(kic.getKeplerId() + 1)
                .size());

        Map<CharacteristicType, Double> characteristicMap = characteristicCrud.retrieveCharacteristicMap(kic.getKeplerId());
        assertEquals(1, characteristicMap.size());
        assertNull(characteristicMap.get(createCharacteristicType("unrecognized type")));
        assertEquals(characteristic.getValue(), characteristicMap.get(type), 0);

        try {
            databaseService.beginTransaction();
            characteristicCrud.create(createCharacteristic(kic.getKeplerId(),
                type, 42.0));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        characteristicMap = characteristicCrud.retrieveCharacteristicMap(kic.getKeplerId());
        assertEquals(1, characteristicMap.size());
        assertNull(characteristicMap.get(createCharacteristicType("unrecognized type")));
        assertEquals(42.0, characteristicMap.get(type), 0);
    }

    @Test
    public void testRetrieveCharacteristicMapsForSkyGroupId() {
        populateObjects();

        assertEquals(
            0,
            characteristicCrud.retrieveCharacteristicMaps(
                kic.getSkyGroupId() + 1)
                .size());

        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(kic.getSkyGroupId());
        assertEquals(1, characteristicMaps.size());
        assertNotNull(characteristicMaps.get(kic.getKeplerId()));
        assertNull(characteristicMaps.get(kic.getKeplerId())
            .get(createCharacteristicType("unrecognized type")));
        assertEquals(characteristic.getValue(),
            characteristicMaps.get(kic.getKeplerId())
                .get(type), 0);

        try {
            databaseService.beginTransaction();
            characteristicCrud.create(createCharacteristic(kic.getKeplerId(),
                type, 42.0));
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(kic.getSkyGroupId());
        assertEquals(1, characteristicMaps.size());
        assertNotNull(characteristicMaps.get(kic.getKeplerId()));
        assertNull(characteristicMaps.get(kic.getKeplerId())
            .get(createCharacteristicType("unrecognized type")));
        assertEquals(42.0, characteristicMaps.get(kic.getKeplerId())
            .get(type), 0);
    }

    @Test
    public void testRetrieveCharacteristicMapsForKeplerIds() {
        populateObjects();

        assertEquals(
            0,
            characteristicCrud.retrieveCharacteristicMaps(
                Arrays.asList(kic.getKeplerId() + 1))
                .size());

        Map<Integer, Map<CharacteristicType, Double>> characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(Arrays.asList(kic.getKeplerId()));
        assertEquals(1, characteristicMaps.size());
        assertNotNull(characteristicMaps.get(kic.getKeplerId()));
        assertNull(characteristicMaps.get(kic.getKeplerId())
            .get(createCharacteristicType("unrecognized type")));
        assertEquals(characteristic.getValue(),
            characteristicMaps.get(kic.getKeplerId())
                .get(type), 0);

        List<Integer> keplerIds = generateKeplerIds(2 * KEPLER_ID, 110);
        try {
            // Generate enough to trigger batching.
            databaseService.beginTransaction();
            for (int keplerId : keplerIds) {
                characteristicCrud.create(createCharacteristic(keplerId, type,
                    keplerId));
            }
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        characteristicMaps = characteristicCrud.retrieveCharacteristicMaps(keplerIds);
        assertEquals(110, characteristicMaps.size());
        for (int keplerId : keplerIds) {
            assertNotNull(characteristicMaps.get(keplerId));
            assertNull(characteristicMaps.get(keplerId)
                .get(createCharacteristicType("unrecognized type")));
            assertEquals(keplerId, characteristicMaps.get(keplerId)
                .get(type), 0);
        }
    }

    @Test
    public void testRetrieveCharacteristicsForSkyGroupId() {
        Characteristic characteristic = createCharacteristic(KEPLER_ID,
            createCharacteristicType());
        assertEquals(
            Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(characteristic.getKeplerId()));

        int skyGroupId = 1;
        int quarter = 2;
        double value = 3.3;
        double value2 = 4.4;

        Kic kic = createKicObject();
        kic.setSkyGroupId(skyGroupId);
        CharacteristicType type = createCharacteristicType();
        Characteristic characteristic1 = new Characteristic(kic.getKeplerId(),
            type, value, quarter);
        Characteristic characteristic2 = new Characteristic(kic.getKeplerId(),
            type, value2, null);
        try {
            databaseService.beginTransaction();
            kicCrud.create(kic);
            characteristicCrud.create(type);
            characteristicCrud.create(characteristic1);
            characteristicCrud.create(characteristic2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        characteristic = new Characteristic(KEPLER_ID,
            createCharacteristicType(), value, quarter);
        Collection<Characteristic> characteristics = characteristicCrud.retrieveCharacteristics(
            type, skyGroupId);
        assertEquals(characteristic, characteristics.iterator()
            .next());

        characteristic = new Characteristic(characteristic.getKeplerId(),
            characteristic.getType(), characteristic.getValue(), quarter);
        characteristics = characteristicCrud.retrieveCharacteristics(type,
            skyGroupId, quarter);
        assertEquals(characteristic, characteristics.iterator()
            .next());
        
        characteristic = new Characteristic(characteristic.getKeplerId(),
            characteristic.getType(), value2, null);
        characteristics = characteristicCrud.retrieveCharacteristics(type,
            skyGroupId, null);
        assertEquals(characteristic, characteristics.iterator()
            .next());
    }

    @Test
    public void testDeleteCharacteristics() {
        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(kic.getKeplerId()));

        populateObjects();

        Assert.assertTrue(!Collections.EMPTY_LIST.equals(characteristicCrud.retrieveCharacteristics(kic.getKeplerId())));

        try {
            databaseService.beginTransaction();
            for (CharacteristicType type : characteristicCrud.retrieveAllCharacteristicTypes()) {
                characteristicCrud.deleteCharacteristics(type);
            }
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(kic.getKeplerId()));
    }

    @Test
    public void testDeleteCharacteristic() {
        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(kic.getKeplerId()));

        populateObjects();

        Assert.assertTrue(!Collections.EMPTY_LIST.equals(characteristicCrud.retrieveCharacteristics(kic.getKeplerId())));

        try {
            databaseService.beginTransaction();
            for (CharacteristicType type : characteristicCrud.retrieveAllCharacteristicTypes()) {
                for (Characteristic characteristic : characteristicCrud.retrieveCharacteristics(
                    type, kic.getSkyGroupId())) {
                    characteristicCrud.delete(characteristic);
                }
            }
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(kic.getKeplerId()));
    }

    @Test
    public void testDeleteCharacteristicsForTypeAndSkyGroupId() {
        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(KEPLER_ID));

        populateObjects();

        Assert.assertTrue(!Collections.EMPTY_LIST.equals(characteristicCrud.retrieveCharacteristics(KEPLER_ID)));

        int skyGroupId = 0;

        assertEquals(skyGroupId, kicCrud.retrieveKic(KEPLER_ID)
            .getSkyGroupId());

        try {
            databaseService.beginTransaction();
            for (CharacteristicType type : characteristicCrud.retrieveAllCharacteristicTypes()) {
                characteristicCrud.deleteCharacteristics(type, skyGroupId);
            }
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveCharacteristics(KEPLER_ID));
        assertEquals(KEPLER_ID, kicCrud.retrieveKic(KEPLER_ID)
            .getKeplerId());
    }

    @Test
    public void testCharacteristicCount() {
        assertEquals(0, characteristicCrud.characteristicCount());

        populateObjects();

        assertEquals(1, characteristicCrud.characteristicCount());
    }

    @Test
    public void testRetrieveCharacteristicType() {
        CharacteristicType type = createCharacteristicType();
        assertNull(characteristicCrud.retrieveCharacteristicType(type.getName()));

        populateObjects();

        CharacteristicType expectedType = createCharacteristicType();
        CharacteristicType actualType = characteristicCrud.retrieveCharacteristicType(expectedType.getName());
        testCharacteristicType(expectedType, actualType);
    }

    @Test
    public void testRetrieveAllCharacteristicTypes() {
        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveAllCharacteristicTypes());

        populateObjects();

        Collection<CharacteristicType> characteristicTypes = characteristicCrud.retrieveAllCharacteristicTypes();
        testCharacteristicType(createCharacteristicType(),
            characteristicTypes.iterator()
                .next());
    }

    @Test
    public void testGetCharacteristicType() {
        populateObjects();

        CharacteristicType expectedType = createCharacteristicType();
        CharacteristicType actualType = characteristicCrud.getCharacteristicType(expectedType.getName());
        testCharacteristicType(expectedType, actualType);
    }

    @Test
    public void testDeleteCharacteristicTypes() {
        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveAllCharacteristicTypes());

        populateObjects();

        Assert.assertTrue(!Collections.EMPTY_LIST.equals(characteristicCrud.retrieveAllCharacteristicTypes()));

        try {
            databaseService.beginTransaction();
            for (CharacteristicType type : characteristicCrud.retrieveAllCharacteristicTypes()) {
                characteristicCrud.deleteCharacteristics(type);
                characteristicCrud.delete(type);
            }
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        assertEquals(Collections.EMPTY_LIST,
            characteristicCrud.retrieveAllCharacteristicTypes());
    }

    @Test
    public void testRetrieveCharacteristicsByQuarter() {
        double value1 = 1.1;
        double value2 = 2.2;
        int quarter1 = 15;
        int quarter2 = 16;

        populateObjects();

        try {
            databaseService.beginTransaction();
            Characteristic characteristic1 = new Characteristic(KEPLER_ID,
                type, value1, quarter1);
            Characteristic characteristic2 = new Characteristic(KEPLER_ID,
                type, value2, quarter2);
            characteristicCrud.create(characteristic1);
            characteristicCrud.create(characteristic2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        List<Characteristic> actualCharacteristics1 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter1);

        List<Characteristic> expectedCharacteristics1 = ImmutableList.of(new Characteristic(
            KEPLER_ID, type, value1, quarter1));
        assertEquals(expectedCharacteristics1, actualCharacteristics1);

        List<Characteristic> actualCharacteristics2 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter2);

        List<Characteristic> expectedCharacteristics2 = ImmutableList.of(new Characteristic(
            KEPLER_ID, type, value2, quarter2));
        assertEquals(expectedCharacteristics2, actualCharacteristics2);
    }

    @Test
    public void testDeleteCharacteristicsByQuarter() {
        double value1 = 1.1;
        double value2 = 2.2;
        int quarter1 = 15;
        int quarter2 = 16;

        populateObjects();

        try {
            databaseService.beginTransaction();
            Characteristic characteristic1 = new Characteristic(KEPLER_ID,
                type, value1, quarter1);
            Characteristic characteristic2 = new Characteristic(KEPLER_ID,
                type, value2, quarter2);
            characteristicCrud.create(characteristic1);
            characteristicCrud.create(characteristic2);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();

        characteristicCrud.deleteCharacteristics(quarter1);

        List<Characteristic> actualCharacteristics1 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter1);

        List<Characteristic> expectedCharacteristics1 = ImmutableList.of();
        assertEquals(expectedCharacteristics1, actualCharacteristics1);

        List<Characteristic> actualCharacteristics2 = characteristicCrud.retrieveCharacteristics(
            KEPLER_ID, quarter2);

        List<Characteristic> expectedCharacteristics2 = ImmutableList.of(new Characteristic(
            KEPLER_ID, type, value2, quarter2));
        assertEquals(expectedCharacteristics2, actualCharacteristics2);
    }

    private void testCharacteristicType(CharacteristicType expected,
        CharacteristicType actual) {

        assertEquals(expected.getName(), actual.getName());
        assertEquals(expected.getFormat(), actual.getFormat());

        // This test will let us know if the type or name of the field
        // Characteristic.value changes. Because of the way that
        // CharacteristicType.getObjectClass() works, changing the value
        // shouldn't be a problem--just ensure all is well and fix this unit
        // test--but changing the name of the field will require updating
        // the name of the field in CharacteristicType.getObjectClass().
        assertEquals("double", actual.getObjectClass()
            .toString());

        assertEquals("1", actual.canonicalize(null));
    }

    private void populateObjects() {
        try {
            databaseService.beginTransaction();
            kicCrud.create(kic);
            characteristicCrud.create(type);
            characteristicCrud.create(characteristic);
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private Kic createKicObject() {
        return new Kic.Builder(KEPLER_ID, 0, 0).build();
    }

    private CharacteristicType createCharacteristicType() {
        return createCharacteristicType("some type");
    }

    private CharacteristicType createCharacteristicType(String name) {
        return new CharacteristicType(name, "%.3f");
    }

    private Characteristic createCharacteristic(int keplerId,
        CharacteristicType type) {

        return createCharacteristic(keplerId, type, 5.0);
    }

    private Characteristic createCharacteristic(int keplerId,
        CharacteristicType type, double value) {

        return new Characteristic(keplerId, type, value);
    }

    public static List<Integer> generateKeplerIds(int start, int count) {
        List<Integer> keplerIds = new ArrayList<Integer>(count);
        for (int i = 0; i < count; i++) {
            keplerIds.add(start + i);
        }

        log.debug(keplerIds);

        return keplerIds;
    }
}
