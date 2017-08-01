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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.hibernate.Constraint;
import gov.nasa.kepler.hibernate.Constraint.Conjunction;
import gov.nasa.kepler.hibernate.Constraint.Operator;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.fc.FcCrud;
import gov.nasa.kepler.hibernate.fc.History;
import gov.nasa.kepler.hibernate.fc.HistoryModelName;
import gov.nasa.kepler.hibernate.fc.RollTime;
import gov.nasa.kepler.hibernate.fc.RollTimeHistoryModel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.hibernate.exception.ConstraintViolationException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link KicCrud} class.
 * 
 * @author Bill Wohler
 */
public class KicCrudTest {

    private static final int REFERENCE_KEPLER_ID = 75;
    private static final double REFERENCE_ROLLTIME = 54908.0;
    private static final int REFERENCE_SEASON = 3;
    private static final double RA_HOURS = 14.5048607;
    private static final double DEC_DEGREES = 0.079690;

    private static final double ARCSECS_PER_PIXEL = 3.9753235;
    private static final double DEGREES_PER_ARCSEC = 1.0 / 3600.0;
    private static final double HOURS_PER_DEGREE = 1.0 / 15.0;

    private DatabaseService databaseService;
    private Kic referenceKic;
    private SkyGroup referenceSkyGroup;
    private CatKey referenceCatKey;
    private ScpKey referenceScpKey;
    private KicCrud kicCrud;
    private FcCrud fcCrud;

    @Before
    public void createDatabase() throws Exception {
        KicCache.clear();
        
        // System.setProperty("hibernate.show_sql", "true");
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);
        kicCrud = new KicCrud();
        fcCrud = new FcCrud();
        referenceSkyGroup = new SkyGroup(42, 23, 2, REFERENCE_SEASON);
        referenceKic = createKicObject(REFERENCE_KEPLER_ID,
            referenceSkyGroup.getSkyGroupId());
        referenceCatKey = createCatKey(42);
        referenceScpKey = createScpKey(42);
    }

    @After
    public void destroyDatabase() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    private void populateObjects() {
        try {
            databaseService.beginTransaction();

            kicCrud.create(referenceKic);
            kicCrud.create(referenceSkyGroup);
            kicCrud.create(createKicObject(74, 41));
            kicCrud.create(createKicObject(73, 40));
            kicCrud.create(createKicObject(72, 39));
            kicCrud.create(createKicObject(123, 0));

            kicCrud.create(referenceCatKey);
            kicCrud.create(createCatKey(43));
            kicCrud.create(createCatKey(44));

            kicCrud.create(referenceScpKey);
            kicCrud.create(createScpKey(43));
            kicCrud.create(createScpKey(44));
            kicCrud.create(createScpKey(45));
            kicCrud.create(createScpKey(46));

            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        databaseService.closeCurrentSession();
    }

    private void populateRollTimeObjects() {
        databaseService.beginTransaction();

        History history = new History(ModifiedJulianDate.dateToMjd(new Date()),
            HistoryModelName.ROLLTIME, "Initial history model", 1);
        fcCrud.create(history);

        RollTime rollTime = new RollTime(REFERENCE_ROLLTIME, REFERENCE_SEASON);
        fcCrud.create(rollTime);

        RollTimeHistoryModel rollTimeHistoryModel = new RollTimeHistoryModel(
            rollTime, history);
        fcCrud.create(rollTimeHistoryModel);

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    private void populateNearbyObjects() {
        databaseService.beginTransaction();

        for (Kic kic : createNearbyKicObjects(REFERENCE_KEPLER_ID,
            referenceSkyGroup.getSkyGroupId(), 1)) {
            kicCrud.create(kic);
        }

        for (Kic kic : createNearbyKicObjects(REFERENCE_KEPLER_ID + 2,
            referenceSkyGroup.getSkyGroupId(), 15)) {
            kicCrud.create(kic);
        }

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @Test
    public void testCreateKic() {
        populateObjects();
    }

    @Test(expected = ConstraintViolationException.class)
    public void testCreateKicWithExistingObject() {
        populateObjects();
        referenceKic = createKicObject(75, referenceSkyGroup.getSkyGroupId());
        populateObjects();
    }

    @Test(expected = ConstraintViolationException.class)
    public void testCreateCatKeyWithExistingObject() {
        populateObjects();
        referenceCatKey = createCatKey(50);
        populateObjects();
    }

    @Test(expected = ConstraintViolationException.class)
    public void testCreateScpKeyWithExistingObject() {
        populateObjects();
        referenceScpKey = createScpKey(50);
        populateObjects();
    }

    // SOC_REQ 164.CM.3: J.testRetrieveSkyGroupId, CERTIFIED 12424
    @Test
    public void testRetrieveKic() {
        Kic k = kicCrud.retrieveKic(referenceKic.getKeplerId());
        assertNull(k);

        CatKey catKey = kicCrud.retrieveCatKey(referenceCatKey.getId());
        assertNull(catKey);

        ScpKey scpKey = kicCrud.retrieveScpKey(referenceScpKey.getId());
        assertNull(scpKey);

        populateObjects();

        k = kicCrud.retrieveKic(referenceKic.getKeplerId());
        testKicObject(k);

        catKey = kicCrud.retrieveCatKey(referenceCatKey.getId());
        testCatKeyObject(catKey);

        scpKey = kicCrud.retrieveScpKey(referenceScpKey.getId());
        testScpKeyObject(scpKey);
    }

    @Test
    public void testRetrieveKics() {
        try {
            kicCrud.retrieveKics(referenceSkyGroup.getCcdModule(),
                referenceSkyGroup.getCcdOutput(),
                referenceSkyGroup.getObservingSeason());
            fail("Expected IllegalArgumentException");
        } catch (IllegalArgumentException e) {
            // Expected.
        }

        populateObjects();

        Collection<Kic> kics = kicCrud.retrieveKics(
            referenceSkyGroup.getCcdModule(), referenceSkyGroup.getCcdOutput(),
            referenceSkyGroup.getObservingSeason());
        assertEquals(1, kics.size());
        testKicObject(kics.iterator()
            .next());

        kics = kicCrud.retrieveKics(0xdeadbeef);
        assertEquals(Collections.EMPTY_LIST, kics);
    }

    @Test
    public void testRetrieveKicsForSkyGroupIdKeplerIdRange() {
        populateObjects();

        List<CelestialObject> actualCelestialObjects = kicCrud.retrieve(
            referenceSkyGroup.getSkyGroupId(), REFERENCE_KEPLER_ID,
            REFERENCE_KEPLER_ID);

        List<CelestialObject> expectedCelestialObjects = new ArrayList<CelestialObject>();
        expectedCelestialObjects.add(referenceKic);

        assertEquals(expectedCelestialObjects, actualCelestialObjects);
    }

    @Test
    public void testRetrieveKeplerIdsForSkyGroupIdKeplerIdRange() {
        populateObjects();

        List<Integer> actualKeplerIds = kicCrud.retrieveKeplerIds(
            referenceSkyGroup.getSkyGroupId(), REFERENCE_KEPLER_ID,
            REFERENCE_KEPLER_ID);

        List<Integer> expectedKeplerIds = newArrayList();
        expectedKeplerIds.add(referenceKic.getKeplerId());

        assertEquals(expectedKeplerIds, actualKeplerIds);
    }

    @Test
    public void testRetrieveKicsWithQuery() {
        populateObjects();
        createKicObjects();
        List<Constraint> constraints = new ArrayList<Constraint>();
        constraints.add(new Constraint(Conjunction.NONE, Kic.Field.KEPLER_ID,
            Operator.GREATER_THAN, "1"));
        constraints.add(new Constraint(Conjunction.AND, Kic.Field.KEPLER_ID,
            Operator.LESS_THAN, "5"));

        List<Kic> kics = kicCrud.retrieveKics(constraints, null, null, 0);
        assertEquals(3, kics.size());
        int i = 2;
        for (Kic kic : kics) {
            assertEquals(i++, kic.getKeplerId());
        }

        kics = kicCrud.retrieveKics(constraints, Kic.Field.KEPLER_ID,
            SortDirection.DESCENDING, referenceSkyGroup.getCcdModule(),
            referenceSkyGroup.getCcdOutput(),
            referenceSkyGroup.getObservingSeason(), 0);
        assertEquals(2, kics.size());
        assertEquals(3, kics.get(0)
            .getKeplerId());
        assertEquals(2, kics.get(1)
            .getKeplerId());

        List<CharacteristicType> types = createCharacteristics();
        constraints.add(new Constraint(Conjunction.AND, types.get(0),
            Operator.GREATER_THAN, ".25"));

        kics = kicCrud.retrieveKics(constraints, null, null, 0);
        assertEquals(2, kics.size());
        i = 3;
        for (Kic kic : kics) {
            assertEquals(i++, kic.getKeplerId());
        }

        kics = kicCrud.retrieveKics(constraints, Kic.Field.KEPLER_ID,
            SortDirection.DESCENDING, 1);
        assertEquals(1, kics.size());
        assertEquals(4, kics.iterator()
            .next()
            .getKeplerId());

        kics = kicCrud.retrieveKics(constraints, types.get(0),
            SortDirection.DESCENDING, 1);
        assertEquals(1, kics.size());
        assertEquals(4, kics.iterator()
            .next()
            .getKeplerId());

        constraints.add(new Constraint(Conjunction.AND, types.get(1),
            Operator.LESS_THAN, ".35"));
        kics = kicCrud.retrieveKics(constraints, null, null, 0);
        assertEquals(1, kics.size());
        assertEquals(3, kics.get(0)
            .getKeplerId());
    }

    @Test
    public void testRetrieveKicsWithArbitaryKeplerIds() throws Exception {
        populateObjects();

        List<Kic> kics = kicCrud.retrieveKics(Arrays.asList(new Integer[] {
            123, 74 }));
        assertEquals(2, kics.size());
        assertEquals(createKicObject(123, 0), kics.get(0));
        assertEquals(createKicObject(74, 41), kics.get(1));
    }

    @Test
    public void testRetrieveAllKics() {
        assertEquals(Collections.EMPTY_LIST, kicCrud.retrieveAllCatKeys());
        assertEquals(Collections.EMPTY_LIST, kicCrud.retrieveAllScpKeys());

        populateObjects();

        Collection<CatKey> catKeys = kicCrud.retrieveAllCatKeys();
        assertEquals(3, catKeys.size());
        testCatKeyObject(catKeys.iterator()
            .next());

        Collection<ScpKey> scpKeys = kicCrud.retrieveAllScpKeys();
        assertEquals(5, scpKeys.size());
        testScpKeyObject(scpKeys.iterator()
            .next());
    }

    @Test
    public void testRetrieveAllVisibleKeplerSkyGroupIds() {
        assertEquals(Collections.EMPTY_LIST,
            kicCrud.retrieveAllVisibleKeplerSkyGroupIds());

        populateObjects();

        List<Object[]> ids = kicCrud.retrieveAllVisibleKeplerSkyGroupIds();
        assertEquals(4, ids.size());
        assertEquals(72, ids.get(0)[0]);
        assertEquals(39, ids.get(0)[1]);
        assertEquals(75, ids.get(3)[0]);
        assertEquals(42, ids.get(3)[1]);
    }

    @Test
    public void testKicCount() {
        assertEquals(0, kicCrud.kicCount());
        assertEquals(0, kicCrud.catKeyCount());
        assertEquals(0, kicCrud.scpKeyCount());

        populateObjects();

        assertEquals(5, kicCrud.kicCount());
        assertEquals(3, kicCrud.catKeyCount());
        assertEquals(5, kicCrud.scpKeyCount());
    }

    @Test
    public void testVisibleKicCount() {
        assertEquals(0, kicCrud.visibleKicCount());
        populateObjects();
        assertEquals(4, kicCrud.visibleKicCount());
    }

    @Test
    public void testExists() {
        populateObjects();

        assertFalse(kicCrud.exists(42));
        assertTrue(kicCrud.exists(75));
    }

    // SOC_REQ_IMPL 164.CM.2
    @Test
    public void testOnFov() {
        databaseService.beginTransaction();
        Kic kicOnFov = new Kic.Builder(42, 1.0, 2.0).skyGroupId(1)
            .build();
        kicCrud.create(kicOnFov);
        Kic kicOffFov = new Kic.Builder(43, 1.0, 2.0).skyGroupId(0)
            .build();
        kicCrud.create(kicOffFov);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        assertTrue("on FOV", kicCrud.retrieveKic(42)
            .getSkyGroupId() != 0);
        assertTrue("off FOV", kicCrud.retrieveKic(43)
            .getSkyGroupId() == 0);
    }

    @Test
    public void testRetrieveSkyGroupId() {
        populateObjects();
        int skyGroupId = kicCrud.retrieveSkyGroupId(
            referenceSkyGroup.getCcdModule(), referenceSkyGroup.getCcdOutput(),
            referenceSkyGroup.getObservingSeason());
        assertEquals(referenceSkyGroup.getSkyGroupId(), skyGroupId);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testRetrieveInvalidSkyGroupId() {
        populateObjects();
        kicCrud.retrieveSkyGroupId(0, 0, 0);
    }

    @Test
    public void testRetrieveSkyGroupBySkyGroupIdObservingSeason() {
        populateObjects();
        SkyGroup skyGroup = kicCrud.retrieveSkyGroup(
            referenceSkyGroup.getSkyGroupId(),
            referenceSkyGroup.getObservingSeason());
        assertEquals(referenceSkyGroup, skyGroup);
    }

    @Test
    public void testRetrieveSkyGroupByKicIdMjd() {
        populateObjects();
        populateRollTimeObjects();

        SkyGroup skyGroup = kicCrud.retrieveSkyGroupByKeplerId(
            REFERENCE_KEPLER_ID, REFERENCE_ROLLTIME + 0.5);
        assertTrue(skyGroup != null);
        assertEquals(referenceSkyGroup, skyGroup);
    }

    @Test
    public void testRetrieveSkyGroup() {
        populateObjects();
        populateRollTimeObjects();

        SkyGroup skyGroup = kicCrud.retrieveSkyGroup(
            referenceSkyGroup.getSkyGroupId(), REFERENCE_ROLLTIME + 0.5);
        assertTrue(skyGroup != null);
        assertEquals(referenceSkyGroup, skyGroup);
    }

    @Test
    public void testRetrieveSkyGroupsForKeplerIds() {
        populateObjects();

        List<Integer> keplerIds = Arrays.asList(new Integer[] { 74, 73, 72, 123 });

        Map<Integer, Integer> keplerIdSkyGroupIdMap = kicCrud.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        assertEquals(41, (int) keplerIdSkyGroupIdMap.get(74));
        assertEquals(40, (int) keplerIdSkyGroupIdMap.get(73));
        assertEquals(39, (int) keplerIdSkyGroupIdMap.get(72));
        assertEquals(0, (int) keplerIdSkyGroupIdMap.get(123));

        keplerIds = new ArrayList<Integer>();
        for (int i = 2000; i > 0; i--) {
            keplerIds.add(i);
        }
        keplerIdSkyGroupIdMap = kicCrud.retrieveSkyGroupIdsForKeplerIds(keplerIds);

        assertEquals(5, keplerIdSkyGroupIdMap.size());
    }

    @Test
    public void testRetrieveAllSkyGroups() {
        List<SkyGroup> expected = new LinkedList<SkyGroup>();
        expected.add(referenceSkyGroup);

        populateObjects();
        List<SkyGroup> skyGroups = kicCrud.retrieveAllSkyGroups();
        assertEquals(expected, skyGroups);
    }

    @Test
    public void testRetrieveNearbyKeplerIds() {
        populateObjects();
        populateNearbyObjects();

        List<Integer> nearbyKeplerIds = kicCrud.retrieveNearbyKeplerIds(
            referenceKic.getKeplerId(), referenceKic.getSkyGroupId(),
            referenceKic.getRa(), referenceKic.getDec(), 6.0F);
        assertNotNull(nearbyKeplerIds);
        assertEquals(2, nearbyKeplerIds.size());
        assertEquals(REFERENCE_KEPLER_ID + 1, nearbyKeplerIds.get(0)
            .intValue());
        assertEquals(REFERENCE_KEPLER_ID + 2, nearbyKeplerIds.get(1)
            .intValue());

        nearbyKeplerIds = kicCrud.retrieveNearbyKeplerIds(
            referenceKic.getKeplerId(), referenceKic.getSkyGroupId(),
            Double.NaN, referenceKic.getDec(), 6.0F);
        assertNotNull(nearbyKeplerIds);
        assertEquals(0, nearbyKeplerIds.size());

        nearbyKeplerIds = kicCrud.retrieveNearbyKeplerIds(
            referenceKic.getKeplerId(), referenceKic.getSkyGroupId(),
            referenceKic.getRa(), Double.NaN, 6.0F);
        assertNotNull(nearbyKeplerIds);
        assertEquals(0, nearbyKeplerIds.size());
    }

    private Kic createKicObject(int keplerId, int skyGroupId) {
        return createKicObject(keplerId, skyGroupId, RA_HOURS, DEC_DEGREES);
    }

    private Kic createKicObject(int keplerId, int skyGroupId, double ra,
        double dec) {
        return new Kic.Builder(keplerId, ra, dec).uMag(17.984F)
            .gMag(16.929F)
            .rMag(16.456F)
            .iMag(16.224F)
            .zMag(16.121F)
            .gredMag(17.238F)
            .d51Mag(16.735F)
            .twoMassJMag(15.300F)
            .twoMassHMag(14.775F)
            .twoMassKMag(14.845F)
            .keplerMag(16.436F)
            .twoMassId(1259050706)
            .alternateSource(1000)
            .effectiveTemp(5750)
            .log10SurfaceGravity(4.000F)
            .log10Metallicity(-3.000F)
            .ebMinusVRedding(0.000F)
            .avExtinction(0.000F)
            .radius(0.039F)
            .source("SCP")
            .photometryQuality(11)
            .astrophysicsQuality(6)
            .scpId(2236363)
            .galacticLongitude(348.283350)
            .galacticLatitude(54.008841)
            .grColor(0.473F)
            .jkColor(0.455F)
            .gkColor(2.084F)
            .skyGroupId(skyGroupId)
            .build();
    }

    private List<Kic> createNearbyKicObjects(int keplerId, int skyGroupId,
        int pixelOffset) {

        double arcsecWidth = pixelOffset * ARCSECS_PER_PIXEL;
        double hourOffset = arcsecWidth / 2 * HOURS_PER_DEGREE
            * DEGREES_PER_ARCSEC;
        double degreeOffset = arcsecWidth / 2 * DEGREES_PER_ARCSEC;

        List<Kic> nearbyKics = new ArrayList<Kic>();
        nearbyKics.add(createKicObject(keplerId + 1, skyGroupId, RA_HOURS
            + hourOffset, DEC_DEGREES - degreeOffset));
        nearbyKics.add(createKicObject(keplerId + 2, skyGroupId, RA_HOURS
            - hourOffset, DEC_DEGREES + degreeOffset));

        return nearbyKics;
    }

    private void testKicObject(Kic kic) {
        testKicObject(referenceKic, kic);
    }

    public static void testKicObject(Kic expectedKic, Kic actualKic) {
        assertEquals(expectedKic.getRa(), actualKic.getRa(), 0);
        assertEquals(expectedKic.getDec(), actualKic.getDec(), 0);
        assertEquals(expectedKic.getRaProperMotion(),
            actualKic.getRaProperMotion());
        assertEquals(expectedKic.getDecProperMotion(),
            actualKic.getDecProperMotion());
        assertEquals(expectedKic.getUMag(), actualKic.getUMag());
        assertEquals(expectedKic.getGMag(), actualKic.getGMag());
        assertEquals(expectedKic.getRMag(), actualKic.getRMag());
        assertEquals(expectedKic.getIMag(), actualKic.getIMag());
        assertEquals(expectedKic.getZMag(), actualKic.getZMag());
        assertEquals(expectedKic.getGredMag(), actualKic.getGredMag());
        assertEquals(expectedKic.getD51Mag(), actualKic.getD51Mag());
        assertEquals(expectedKic.getTwoMassJMag(), actualKic.getTwoMassJMag());
        assertEquals(expectedKic.getTwoMassHMag(), actualKic.getTwoMassHMag());
        assertEquals(expectedKic.getTwoMassKMag(), actualKic.getTwoMassKMag());
        assertEquals(expectedKic.getKeplerMag(), actualKic.getKeplerMag());
        assertEquals(expectedKic.getKeplerId(), actualKic.getKeplerId());
        assertEquals(expectedKic.getTwoMassId(), actualKic.getTwoMassId());
        assertEquals(expectedKic.getInternalScpId(),
            actualKic.getInternalScpId());
        assertEquals(expectedKic.getAlternateId(), actualKic.getAlternateId());
        assertEquals(expectedKic.getAlternateSource(),
            actualKic.getAlternateSource());
        assertEquals(expectedKic.getGalaxyIndicator(),
            actualKic.getGalaxyIndicator());
        assertEquals(expectedKic.getBlendIndicator(),
            actualKic.getBlendIndicator());
        assertEquals(expectedKic.getVariableIndicator(),
            actualKic.getVariableIndicator());
        assertEquals(expectedKic.getEffectiveTemp(),
            actualKic.getEffectiveTemp());
        assertEquals(expectedKic.getLog10SurfaceGravity(),
            actualKic.getLog10SurfaceGravity());
        assertEquals(expectedKic.getLog10Metallicity(),
            actualKic.getLog10Metallicity());
        assertEquals(expectedKic.getEbMinusVRedding(),
            actualKic.getEbMinusVRedding());
        assertEquals(expectedKic.getAvExtinction(), actualKic.getAvExtinction());
        assertEquals(expectedKic.getRadius(), actualKic.getRadius());
        assertEquals(expectedKic.getSource(), actualKic.getSource());
        assertEquals(expectedKic.getPhotometryQuality(),
            actualKic.getPhotometryQuality());
        assertEquals(expectedKic.getAstrophysicsQuality(),
            actualKic.getAstrophysicsQuality());
        assertEquals(expectedKic.getCatalogId(), actualKic.getCatalogId());
        assertEquals(expectedKic.getScpId(), actualKic.getScpId());
        assertEquals(expectedKic.getParallax(), actualKic.getParallax());
        assertEquals(expectedKic.getGalacticLongitude(),
            actualKic.getGalacticLongitude());
        assertEquals(expectedKic.getGalacticLatitude(),
            actualKic.getGalacticLatitude());
        assertEquals(expectedKic.getTotalProperMotion(),
            actualKic.getTotalProperMotion());
        assertEquals(expectedKic.getGrColor(), actualKic.getGrColor());
        assertEquals(expectedKic.getJkColor(), actualKic.getJkColor());
        assertEquals(expectedKic.getGkColor(), actualKic.getGkColor());
        assertEquals(expectedKic.getSkyGroupId(), actualKic.getSkyGroupId());
    }

    private CatKey createCatKey(int id) {
        CatKey catKey = new CatKey(id, 43, Integer.valueOf(44),
            Integer.valueOf(45), Integer.valueOf(46), "source",
            Integer.valueOf(47), Integer.valueOf(48), Integer.valueOf(49),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));
        return catKey;
    }

    private void testCatKeyObject(CatKey catKey) {
        assertEquals(referenceCatKey.getId(), catKey.getId());
        assertEquals(referenceCatKey.getFlag(), catKey.getFlag());
        assertEquals(referenceCatKey.getTychoId(), catKey.getTychoId());
        assertEquals(referenceCatKey.getUcacId(), catKey.getUcacId());
        assertEquals(referenceCatKey.getGcvsId(), catKey.getGcvsId());
        assertEquals(referenceCatKey.getSource(), catKey.getSource());
        assertEquals(referenceCatKey.getSourceId(), catKey.getSourceId());
        assertEquals(referenceCatKey.getFirstFlux(), catKey.getFirstFlux());
        assertEquals(referenceCatKey.getSecondFlux(), catKey.getSecondFlux());
        assertEquals(referenceCatKey.getRaEpoch(), catKey.getRaEpoch(), 0);
        assertEquals(referenceCatKey.getDecEpoch(), catKey.getDecEpoch(), 0);
        assertEquals(referenceCatKey.getJMag(), catKey.getJMag(), 0);
        assertEquals(referenceCatKey.getHMag(), catKey.getHMag(), 0);
        assertEquals(referenceCatKey.getKMag(), catKey.getKMag(), 0);
    }

    private ScpKey createScpKey(int id) {
        ScpKey scpKey = new ScpKey(id, Double.valueOf(42.1),
            Double.valueOf(42.2), Integer.valueOf(45), Integer.valueOf(46),
            Float.valueOf((float) 42.3), Float.valueOf((float) 42.4),
            Float.valueOf((float) 42.5), Float.valueOf((float) 42.6),
            Float.valueOf((float) 50.1), Float.valueOf((float) 50.2),
            Float.valueOf((float) 50.3), Float.valueOf((float) 50.4),
            Float.valueOf((float) 50.5));

        return scpKey;
    }

    private void testScpKeyObject(ScpKey scpKey) {
        assertEquals(referenceScpKey.getId(), scpKey.getId());
        assertEquals(referenceScpKey.getFiberRa(), scpKey.getFiberRa());
        assertEquals(referenceScpKey.getFiberDec(), scpKey.getFiberDec());
        assertEquals(referenceScpKey.getEffectiveTemp(),
            scpKey.getEffectiveTemp());
        assertEquals(referenceScpKey.getEffectiveTempErr(),
            scpKey.getEffectiveTempErr());
        assertEquals(referenceScpKey.getLog10SurfaceGravity(),
            scpKey.getLog10SurfaceGravity(), 0);
        assertEquals(referenceScpKey.getLog10SurfaceGravityErr(),
            scpKey.getLog10SurfaceGravityErr(), 0);
        assertEquals(referenceScpKey.getLog10Metallicity(),
            scpKey.getLog10Metallicity(), 0);
        assertEquals(referenceScpKey.getLog10MetallicityErr(),
            scpKey.getLog10MetallicityErr(), 0);
        assertEquals(referenceScpKey.getRotationalVelocitySin(),
            scpKey.getRotationalVelocitySin(), 0);
        assertEquals(referenceScpKey.getRotationalVelocitySinErr(),
            scpKey.getRotationalVelocitySinErr(), 0);
        assertEquals(referenceScpKey.getRadialVelocity(),
            scpKey.getRadialVelocity(), 0);
        assertEquals(referenceScpKey.getRadialVelocityErr(),
            scpKey.getRadialVelocityErr(), 0);
        assertEquals(referenceScpKey.getCrossCorrelationPeak(),
            scpKey.getCrossCorrelationPeak(), 0);
    }

    private void createKicObjects() {
        databaseService.beginTransaction();

        kicCrud.create(new Kic.Builder(1, 10, 50).build());
        kicCrud.create(new Kic.Builder(2, 20, 40).skyGroupId(
            referenceSkyGroup.getSkyGroupId())
            .build());
        kicCrud.create(new Kic.Builder(3, 30, 30).skyGroupId(
            referenceSkyGroup.getSkyGroupId())
            .build());
        kicCrud.create(new Kic.Builder(4, 40, 20).build());
        kicCrud.create(new Kic.Builder(5, 50, 10).build());

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    private List<CharacteristicType> createCharacteristics() {
        List<CharacteristicType> types = new ArrayList<CharacteristicType>();

        databaseService.beginTransaction();

        CharacteristicCrud characteristicCrud = new CharacteristicCrud();
        CharacteristicType type = new CharacteristicType("CrowdingMetric",
            "%.3f");
        types.add(type);
        characteristicCrud.create(type);
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(1)
            .getKeplerId(), type, .1));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(2)
            .getKeplerId(), type, .2));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(3)
            .getKeplerId(), type, .3));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(4)
            .getKeplerId(), type, .4));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(5)
            .getKeplerId(), type, .5));
        type = new CharacteristicType("EssentialNutrients", "%.2f");
        types.add(type);
        characteristicCrud.create(types.get(types.size() - 1));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(1)
            .getKeplerId(), type, .1));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(2)
            .getKeplerId(), type, .2));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(3)
            .getKeplerId(), type, .3));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(4)
            .getKeplerId(), type, .4));
        characteristicCrud.create(new Characteristic(kicCrud.retrieveKic(5)
            .getKeplerId(), type, .5));

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        return types;
    }

}
