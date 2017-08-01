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

package gov.nasa.kepler.cm;

import static gov.nasa.kepler.common.TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.CustomTarget;
import gov.nasa.kepler.hibernate.cm.CustomTargetCrud;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Offset;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link TargetSelectionOperations} class.
 * 
 * @author Bill Wohler
 */
public class TargetSelectionOperationsTest {

    private static final int KEPLER_ID = 42;
    private static final int KEPLER_ID_WITH_SKY_GROUP_0 = 142;
    private static final int SKY_GROUP_ID = 43;
    private static final int CUSTOM_TARGET_ID = 100000011;

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TargetSelectionOperationsTest.class);

    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer;
    private KicCrud kicCrud = new KicCrud();
    private CustomTargetCrud customTargetCrud = new CustomTargetCrud();
    private TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();
    private TargetSelectionOperations targetSelectionOperations;
    private Kic kic;
    private CustomTarget customTarget;
    private CustomTarget customTarget2;
    private PlannedTarget plannedTarget;
    private Set<String> labels;
    private PlannedTarget plannedTarget2;
    private PlannedTarget customPlannedTarget;
    private PlannedTarget customPlannedTarget2;
    private PlannedTarget customPlannedTarget3;
    private List<PlannedTarget> plannedTargets;
    private List<PlannedTarget> plannedTargets2;
    private TargetList targetList;

    @Before
    public void createDatabase() {
        databaseService = DatabaseServiceFactory.getInstance();
        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();

        System.setProperty(
            TargetSelectionOperations.ALLOW_NEW_CUSTOM_TARGETS_PROPERTY, "true");
        targetSelectionOperations = new TargetSelectionOperations();
    }

    @After
    public void destroyDatabase() {
        databaseService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    private void populateObjects() {
        databaseService.beginTransaction();

        kic = new Kic.Builder(KEPLER_ID, 10, 20).skyGroupId(SKY_GROUP_ID)
            .build();
        kicCrud.create(kic);

        Kic kic2 = new Kic.Builder(KEPLER_ID + 1, 10, 20).skyGroupId(
            SKY_GROUP_ID + 1)
            .build();
        kicCrud.create(kic2);

        kic2 = new Kic.Builder(KEPLER_ID_WITH_SKY_GROUP_0, 10, 20).skyGroupId(0)
            .build();
        kicCrud.create(kic2);

        customTarget = new CustomTarget(CUSTOM_TARGET_KEPLER_ID_START,
            SKY_GROUP_ID);
        customTargetCrud.create(customTarget);
        customTarget2 = new CustomTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID);
        customTargetCrud.create(customTarget2);

        targetList = new TargetList("foo");
        targetList.setCategory("foo");
        targetSelectionCrud.create(targetList);

        plannedTarget = new PlannedTarget(KEPLER_ID, SKY_GROUP_ID, targetList);
        plannedTarget2 = new PlannedTarget(KEPLER_ID + 1, SKY_GROUP_ID + 1,
            targetList);
        plannedTarget2.addLabel(TargetLabel.PDQ_BACKGROUND);
        labels = new HashSet<String>();
        labels.add(TargetLabel.PDQ_BACKGROUND.toString());

        customPlannedTarget = new PlannedTarget(CUSTOM_TARGET_KEPLER_ID_START,
            SKY_GROUP_ID, targetList);
        customPlannedTarget.setAperture(new Aperture(true, 42, 43,
            Arrays.asList(new Offset(42, 43))));
        customPlannedTarget2 = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        customPlannedTarget2.setAperture(new Aperture(true, 43, 44,
            Arrays.asList(new Offset(43, 44))));
        customPlannedTarget3 = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        customPlannedTarget3.setAperture(new Aperture(true, 44, 45,
            Arrays.asList(new Offset(44, 45))));

        plannedTargets = Arrays.asList(plannedTarget, customPlannedTarget);
        plannedTargets2 = Arrays.asList(plannedTarget2, customPlannedTarget2,
            customPlannedTarget3);

        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @Test
    public void testConstructor() {
        // Feel free to delete this coverage test if this constructor goes away.
        new TargetSelectionOperations(databaseService);
    }

    @Test(expected = NullPointerException.class)
    public void testUpdatePlannedTargetsWithNullTargetList() {
        targetSelectionOperations.updatePlannedTargets(null, null);
    }

    @Test(expected = NullPointerException.class)
    public void testUpdatePlannedTargetsWithNullPlannedTargets() {
        targetSelectionOperations.updatePlannedTargets(new TargetList("foo"),
            null);
    }

    @Test
    public void testUpdatePlannedTargets() {

        populateObjects();

        List<PlannedTarget> actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(targetList);
        assertNotNull(actualPlannedTargets);
        assertEquals(0, actualPlannedTargets.size());

        databaseService.beginTransaction();
        targetSelectionOperations.updatePlannedTargets(targetList,
            plannedTargets);
        databaseService.commitTransaction();
        actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(targetList);
        assertNotNull(actualPlannedTargets);
        assertEquals(2, actualPlannedTargets.size());
        assertEquals(plannedTarget, actualPlannedTargets.get(0));
        assertEquals(customPlannedTarget, actualPlannedTargets.get(1));

        databaseService.beginTransaction();
        targetSelectionOperations.updatePlannedTargets(targetList,
            plannedTargets2);
        databaseService.commitTransaction();
        actualPlannedTargets = targetSelectionCrud.retrievePlannedTargets(targetList);
        assertNotNull(actualPlannedTargets);
        assertEquals(3, actualPlannedTargets.size());
        assertEquals(plannedTarget2, actualPlannedTargets.get(0));
        assertEquals(labels, actualPlannedTargets.get(0)
            .getLabels());
        assertEquals(customPlannedTarget2, actualPlannedTargets.get(1));
    }

    @Test(expected = NullPointerException.class)
    public void testValidatePlannedTargetsWithNullTargetList() {
        targetSelectionOperations.validatePlannedTargets(null, null, false);
    }

    @Test(expected = NullPointerException.class)
    public void testValidatePlannedTargetsWithNullPlannedTargets() {
        targetSelectionOperations.validatePlannedTargets(new TargetList("foo"),
            null, false);
    }

    @Test(expected = IllegalStateException.class)
    public void testValidatePlannedTargetsWithMissingSkyGroupId() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(
            TargetManagementConstants.INVALID_KEPLER_ID,
            TargetManagementConstants.INVALID_SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test(expected = IllegalStateException.class)
    public void testValidatePlannedTargetsWithMissingAperture() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test(expected = IllegalStateException.class)
    public void testValidatePlannedTargetsWithMissingApertureSameTargetList() {
        populateObjects();
        databaseService.beginTransaction();
        targetSelectionCrud.create(plannedTargets2);
        databaseService.commitTransaction();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test
    public void testValidatePlannedTargetsWithMissingApertureDifferentTargetList() {
        populateObjects();
        databaseService.beginTransaction();
        targetSelectionCrud.create(plannedTargets2);
        targetList = new TargetList("bar");
        targetList.setCategory("bar");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        assertNotSame(customPlannedTarget2, newPlannedTarget);
        assertNotSame(customPlannedTarget3, newPlannedTarget);
        List<PlannedTarget> validatedTargets = targetSelectionOperations.validatePlannedTargets(
            targetList, newPlannedTargets, false);
        // Ensure that we get the aperture from the latest custom planned target
        // with our ID.
        assertTrue(customPlannedTarget3.getId() > customPlannedTarget2.getId());
        assertEquals(customPlannedTarget3, validatedTargets.get(0));
        assertEquals(customPlannedTarget3.getAperture(),
            validatedTargets.get(0)
                .getAperture());
    }

    @Test(expected = IllegalStateException.class)
    public void testValidatePlannedTargetsWithDifferentSkyGroupIdInPlannedTarget() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("bar");
        targetList.setCategory("bar");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTargets.add(new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID + 1, targetList));
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test(expected = IllegalStateException.class)
    public void testValidatePlannedTargetsWithDifferentSkyGroupIdInSavedPlannedTargets() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("bar");
        targetList.setCategory("bar");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTargets.add(new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID + 1, targetList));

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("baz");
        targetList.setCategory("baz");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTargets.add(new PlannedTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID,
            targetList));

        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test
    public void testValidatePlannedTargetsWithDifferentApertureInPlannedTarget() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        Aperture aperture = new Aperture(true, 42, 43, Arrays.asList(
            new Offset(42, 43), new Offset(46, 47)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("bar");
        targetList.setCategory("bar");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID,
            targetList);
        newPlannedTargets.add(newPlannedTarget);
        aperture = new Aperture(true, 44, 45, Arrays.asList(new Offset(44, 45),
            new Offset(46, 47)));
        newPlannedTarget.setAperture(aperture);
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test
    public void testValidatePlannedTargetsWithDifferentApertureInSavedPlannedTargets() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        Aperture aperture = new Aperture(true, 42, 43, Arrays.asList(
            new Offset(42, 43), new Offset(46, 47)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("bar");
        targetList.setCategory("bar");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID,
            targetList);
        aperture = new Aperture(true, 44, 45, Arrays.asList(new Offset(44, 45),
            new Offset(46, 47)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("baz");
        targetList.setCategory("baz");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID,
            targetList);
        newPlannedTargets.add(newPlannedTarget);

        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test
    public void testValidatePlannedTargetsWithSameApertureOffsetsInDifferentOrder() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID,
            SKY_GROUP_ID, targetList);
        Aperture aperture = new Aperture(true, 42, 43, Arrays.asList(
            new Offset(42, 43), new Offset(44, 45), new Offset(46, 47)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("bar");
        targetList.setCategory("bar");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID,
            targetList);
        aperture = new Aperture(true, 42, 43, Arrays.asList(new Offset(46, 47),
            new Offset(44, 45), new Offset(42, 43)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        targetList = new TargetList("baz");
        targetList.setCategory("baz");
        targetSelectionCrud.create(targetList);
        databaseService.commitTransaction();

        newPlannedTargets.clear();
        newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID, SKY_GROUP_ID,
            targetList);
        aperture = new Aperture(true, 42, 43, Arrays.asList(new Offset(44, 45),
            new Offset(46, 47), new Offset(42, 43)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);

        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testValidatePlannedTargetsWithInvalidKeplerId() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(KEPLER_ID - 1,
            SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test(expected = IllegalStateException.class)
    public void testValidatePlannedTargetsWithNewTargetWhenNotAllowed() {
        populateObjects();
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>();
        PlannedTarget newPlannedTarget = new PlannedTarget(
            TargetManagementConstants.INVALID_KEPLER_ID, SKY_GROUP_ID,
            targetList);
        newPlannedTargets.add(newPlannedTarget);
        System.setProperty(
            TargetSelectionOperations.ALLOW_NEW_CUSTOM_TARGETS_PROPERTY,
            "false");
        targetSelectionOperations.validatePlannedTargets(targetList,
            newPlannedTargets, false);
    }

    @Test
    public void testValidatePlannedTargets() {
        populateObjects();

        // Check no-op.
        List<PlannedTarget> validatedPlannedTargets = targetSelectionOperations.validatePlannedTargets(
            targetList, plannedTargets, false);
        assertEquals(plannedTargets, validatedPlannedTargets);

        // Check creation of new custom target and exercise cache.
        ArrayList<PlannedTarget> newPlannedTargets = new ArrayList<PlannedTarget>(
            plannedTargets);
        PlannedTarget newPlannedTarget = new PlannedTarget(
            CUSTOM_TARGET_ID + 42, SKY_GROUP_ID + 2, targetList);
        Aperture aperture = new Aperture(true, 44, 45,
            Arrays.asList(new Offset(44, 45)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);
        newPlannedTarget = new PlannedTarget(
            TargetManagementConstants.INVALID_KEPLER_ID, SKY_GROUP_ID + 2,
            targetList);
        aperture = new Aperture(true, 46, 47, Arrays.asList(new Offset(46, 47)));
        newPlannedTarget.setAperture(aperture);
        newPlannedTargets.add(newPlannedTarget);
        validatedPlannedTargets = targetSelectionOperations.validatePlannedTargets(
            targetList, newPlannedTargets, false);
        assertEquals(newPlannedTargets, validatedPlannedTargets);
        assertEquals(CUSTOM_TARGET_ID + 42, validatedPlannedTargets.get(2)
            .getKeplerId());
        assertEquals(CUSTOM_TARGET_ID + 42 + 1, validatedPlannedTargets.get(3)
            .getKeplerId());

        databaseService.beginTransaction();
        targetSelectionCrud.create(newPlannedTargets);
        databaseService.commitTransaction();

        // Check filling in of sky group and aperture information.
        targetList = new TargetList("bar");
        newPlannedTargets = new ArrayList<PlannedTarget>();
        newPlannedTarget = new PlannedTarget(CUSTOM_TARGET_ID + 42 + 1,
            TargetManagementConstants.INVALID_SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        validatedPlannedTargets = targetSelectionOperations.validatePlannedTargets(
            targetList, newPlannedTargets, false);
        assertEquals(newPlannedTargets, validatedPlannedTargets);
        assertEquals(SKY_GROUP_ID + 2, validatedPlannedTargets.get(0)
            .getSkyGroupId());
        assertEquals(aperture, validatedPlannedTargets.get(0)
            .getAperture());

        // Check that a sky group of 0 doesn't cause an exception to be thrown.
        newPlannedTargets = new ArrayList<PlannedTarget>();
        newPlannedTarget = new PlannedTarget(KEPLER_ID, 0, targetList);
        newPlannedTargets.add(newPlannedTarget);
        newPlannedTarget = new PlannedTarget(KEPLER_ID_WITH_SKY_GROUP_0,
            TargetManagementConstants.INVALID_SKY_GROUP_ID, targetList);
        newPlannedTargets.add(newPlannedTarget);
        validatedPlannedTargets = targetSelectionOperations.validatePlannedTargets(
            targetList, newPlannedTargets, false);
        assertEquals(2, validatedPlannedTargets.size());
        assertEquals(SKY_GROUP_ID, validatedPlannedTargets.get(0)
            .getSkyGroupId());
        assertEquals(0, validatedPlannedTargets.get(1)
            .getSkyGroupId());

        // Verify that a missing Kepler ID doesn't result in an exception if
        // skipMissingKeplerIds is true.
        newPlannedTargets = new ArrayList<PlannedTarget>();
        newPlannedTarget = new PlannedTarget(KEPLER_ID - 1, SKY_GROUP_ID,
            targetList);
        newPlannedTargets.add(newPlannedTarget);
        validatedPlannedTargets = targetSelectionOperations.validatePlannedTargets(
            targetList, newPlannedTargets, true);
        assertEquals(0, validatedPlannedTargets.size());
    }

    @Test
    public void testMerge() {
        populateObjects();
        HashMap<Integer, PlannedTarget> targetByKeplerId = new HashMap<Integer, PlannedTarget>();
        TargetSelectionOperations.merge(targetByKeplerId, 0,
            customPlannedTarget);
        TargetSelectionOperations.merge(targetByKeplerId, 1,
            customPlannedTarget2);
        TargetSelectionOperations.merge(targetByKeplerId, 2, plannedTarget2);
        PlannedTarget plannedTarget = new PlannedTarget(plannedTarget2);
        plannedTarget.addLabel(TargetLabel.PDQ_GUIDE_STAR);
        TargetSelectionOperations.merge(targetByKeplerId, 2, plannedTarget);
        assertEquals(3, targetByKeplerId.size());
        assertEquals(customPlannedTarget, targetByKeplerId.get(0));
        assertEquals(customPlannedTarget2, targetByKeplerId.get(1));
        plannedTarget = targetByKeplerId.get(2);
        assertEquals(2, plannedTarget.getLabels()
            .size());
        assertTrue(plannedTarget.getLabels()
            .contains(TargetLabel.PDQ_BACKGROUND.toString()));
        assertTrue(plannedTarget.getLabels()
            .contains(TargetLabel.PDQ_GUIDE_STAR.toString()));
    }

    @Test(expected = NullPointerException.class)
    public void testMergeWithNullMap() {
        TargetSelectionOperations.merge(null, 0, customPlannedTarget);
    }

    @Test(expected = NullPointerException.class)
    public void testMergeWithNullPlannedTarget() {
        HashMap<Integer, PlannedTarget> targetByKeplerId = new HashMap<Integer, PlannedTarget>();
        TargetSelectionOperations.merge(targetByKeplerId, 0, null);
    }

    @Test(expected = IllegalStateException.class)
    public void testMergeWithDifferentApertures() {
        populateObjects();
        HashMap<Integer, PlannedTarget> targetByKeplerId = new HashMap<Integer, PlannedTarget>();
        TargetSelectionOperations.merge(targetByKeplerId, 0,
            customPlannedTarget);
        TargetSelectionOperations.merge(targetByKeplerId, 0,
            customPlannedTarget2);
    }

    @Test
    public void testAllVisibleKeplerSkyGroupIds() {
        assertEquals(Collections.EMPTY_LIST,
            targetSelectionOperations.retrieveAllVisibleKeplerSkyGroupIds());
        populateObjects();
        List<Object[]> ids = targetSelectionOperations.retrieveAllVisibleKeplerSkyGroupIds();
        assertEquals(4, ids.size());

        assertEquals(KEPLER_ID, ids.get(0)[0]);
        assertEquals(SKY_GROUP_ID, ids.get(0)[1]);
        assertEquals(KEPLER_ID + 1, ids.get(1)[0]);
        assertEquals(SKY_GROUP_ID + 1, ids.get(1)[1]);

        assertEquals(TargetManagementConstants.CUSTOM_TARGET_KEPLER_ID_START,
            ids.get(2)[0]);
        assertEquals(SKY_GROUP_ID, ids.get(2)[1]);
        assertEquals(CUSTOM_TARGET_ID, ids.get(3)[0]);
        assertEquals(SKY_GROUP_ID, ids.get(3)[1]);
    }

    @Test
    public void testExists() {
        populateObjects();

        assertTrue(targetSelectionOperations.exists(KEPLER_ID));
        assertFalse(targetSelectionOperations.exists(KEPLER_ID - 1));
        assertTrue(targetSelectionOperations.exists(CUSTOM_TARGET_ID));
        assertFalse(targetSelectionOperations.exists(CUSTOM_TARGET_ID - 1));
    }

    private void populateSkyGroupTable() throws Exception {
        databaseService.beginTransaction();
        new CmSeedData().createSkyGroupTable();
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();
    }

    @Test
    public void testSkyGroupIdFor() throws Exception {
        populateSkyGroupTable();

        for (SkyGroup skyGroup : kicCrud.retrieveAllSkyGroups()) {
            if (skyGroup.getObservingSeason() == SkyGroup.DEFAULT_SEASON) {
                assertEquals(
                    skyGroup.getSkyGroupId(),
                    targetSelectionOperations.skyGroupIdFor(
                        skyGroup.getCcdModule(), skyGroup.getCcdOutput()));
            }
        }
    }

    @Test
    public void testSkyGroupFor() throws Exception {
        populateSkyGroupTable();

        for (SkyGroup skyGroup : kicCrud.retrieveAllSkyGroups()) {
            assertEquals(skyGroup, targetSelectionOperations.skyGroupFor(
                skyGroup.getSkyGroupId(), skyGroup.getObservingSeason()));
            if (skyGroup.getObservingSeason() == SkyGroup.DEFAULT_SEASON) {
                assertEquals(
                    skyGroup,
                    targetSelectionOperations.skyGroupFor(skyGroup.getSkyGroupId()));
            }
        }
    }

    @Test(expected = NullPointerException.class)
    public void testStringToTargetNull() throws Exception {
        TargetSelectionOperations.stringToTarget(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetEmptyString() throws Exception {
        TargetSelectionOperations.stringToTarget(""); // no fields at all
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetLineNoise() throws Exception {
        TargetSelectionOperations.stringToTarget("34098lksjlkdskldf3432");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetNotEnoughFields() throws Exception {
        TargetSelectionOperations.stringToTarget("||||");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetMissingRequiredFields() throws Exception {
        TargetSelectionOperations.stringToTarget("||||||");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetNewMissingSkyGroupId() throws Exception {
        TargetSelectionOperations.stringToTarget("NEW|||3|4|1,2;3,4;5,6");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetNewMissingRow() throws Exception {
        TargetSelectionOperations.stringToTarget("NEW|1|||4|1,2;3,4;5,6");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetNewMissingColumn() throws Exception {
        TargetSelectionOperations.stringToTarget("NEW|1||3||1,2;3,4;5,6");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetNewMissingOffsets() throws Exception {
        TargetSelectionOperations.stringToTarget("NEW|1||3|4|");
    }

    @Test
    public void testStringToTargetCustomMissingSkyGroupId() {
        String s = "100000042|||3|4|1,2;3,4;5,6";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomMissingRow() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1|||4|1,2;3,4;5,6");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomMissingColumn() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3||1,2;3,4;5,6");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomMissingOffsets() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets1() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets2() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets3() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|,");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets4() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|,2");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets5() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,2;3");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets6() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,2;3,");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets7() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,2;,");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets8() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,2;,4");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets9() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,2;");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets10() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|;1,2");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomIncompleteOffsets11() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|4|1,2;;3,4");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidReferencePixel1()
        throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||-1|4|0,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidReferencePixel2()
        throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|-1|0,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidReferencePixel3()
        throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||1070|4|0,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidReferencePixel4()
        throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||3|1132|0,0");
    }

    @Test
    public void testStringToTargetCustomValidOffset1() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||0|0|0,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidOffset1() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||0|0|-1,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidOffset2() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||0|0|0,-1");
    }

    @Test
    public void testStringToTargetCustomValidOffset2() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||1069|1131|0,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidOffset3() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||1069|1131|1,0");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetCustomInvalidOffset4() throws Exception {
        TargetSelectionOperations.stringToTarget("100000042|1||1069|1131|0,1");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetKicWithSkyGroupId() throws Exception {
        TargetSelectionOperations.stringToTarget("42|1||||");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetKicWithRow() throws Exception {
        TargetSelectionOperations.stringToTarget("42|||3||");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetKicWithColumn() throws Exception {
        TargetSelectionOperations.stringToTarget("42||||4|");
    }

    @Test(expected = IllegalArgumentException.class)
    public void testStringToTargetKicWithOffsets() throws Exception {
        TargetSelectionOperations.stringToTarget("42|||||1,2;3,4;5,6");
    }

    @Test
    public void testStringToTarget() throws Exception {
        // Add a legit sky group.
        SkyGroup skyGroup = new SkyGroup(1, 1, 2, SkyGroup.DEFAULT_SEASON);
        databaseService.beginTransaction();
        kicCrud.create(skyGroup);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        // Multiple label and offset entries.
        String s = "NEW|1|label1,label2,label3|3|4|1,2;3,4;5,6";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // Single label and offset entries.
        s = "NEW|1|label1|3|4|1,2";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // No labels.
        s = "NEW|1||3|4|1,2;3,4;5,6";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // Multiple label and offset entries.
        s = "100000042|1|label1,label2,label3|3|4|1,2;3,4;5,6";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // Single label and offset entries.
        s = "100000042|1|label1|3|4|1,2";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // No labels.
        s = "100000042|1||3|4|1,2;3,4;5,6";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // Just a custom target.
        s = "100000042|||||";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // Just a KIC.
        s = "42|||||";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // Just a label...
        s = "42||label1|||";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));

        // ...or two.
        s = "42||label1,label2|||";
        assertEquals(
            s,
            targetSelectionOperations.targetToString(TargetSelectionOperations.stringToTarget(s)));
    }
}
