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

package gov.nasa.kepler.tad.peer.chartable;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.cm.Characteristic;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.ModOut;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.tad.peer.chartable.TadProductsToCharTablePipelineModule.TadProductType;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TadProductCharManagerTest {

    private static final int KEPLER_ID = 100;
    private static final String TLS_NAME = "TLS_NAME";

    private static final ModOut MOD_OUT = ModOut.of(2, 1);
    private static final int SEASON = 2;
    private static final int SKY_GROUP_ID = 1;

    private static final TadProductType TAD_PRODUCT_TYPE = TadProductType.SIGNAL_TO_NOISE_RATIO;
    private static final String CHAR_TYPE_NAME = TAD_PRODUCT_TYPE.getCharTypeName(SEASON);

    private static final double VALUE = 1.1F;
    private static final double UPDATED_VALUE = 2.2F;

    private DatabaseService databaseService;
    private TargetSelectionCrud targetSelectionCrud;
    private KicCrud kicCrud;
    private TargetCrud targetCrud;
    private CharacteristicCrud charCrud;
    private ObservedTarget observedTarget;
    private TargetTable targetTable;

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

    @Test
    public void testManageCreate() {
        populateObjects();

        databaseService.beginTransaction();

        TadProductCharTypeCreator creator = new TadProductCharTypeCreator();
        creator.run();

        Kic kic = new Kic.Builder(KEPLER_ID, 1.0, 2.0).skyGroupId(SKY_GROUP_ID)
            .build();

        SkyGroup skyGroup = new SkyGroup(SKY_GROUP_ID, MOD_OUT.getCcdModule(),
            MOD_OUT.getCcdOutput(), SEASON);

        targetTable = new TargetTable(TargetType.LONG_CADENCE);
        targetTable.setObservingSeason(SEASON);

        TargetListSet tls = new TargetListSet(TLS_NAME);
        tls.setTargetTable(targetTable);

        observedTarget = new ObservedTarget(KEPLER_ID);
        observedTarget.setModOut(MOD_OUT);
        observedTarget.setSignalToNoiseRatio(VALUE);
        observedTarget.setTargetTable(targetTable);
        observedTarget.setAperture(new Aperture(false, 0, 0, null));

        List<ObservedTarget> observedTargets = ImmutableList.of(observedTarget);

        kicCrud.create(skyGroup);
        kicCrud.create(kic);
        targetSelectionCrud.create(tls);
        targetCrud.createTargetTable(targetTable);
        targetCrud.createObservedTargets(observedTargets);

        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();

        TadProductCharManager manager = new TadProductCharManager();
        manager.manage(TLS_NAME, MOD_OUT);

        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        CharacteristicType charType = charCrud.retrieveCharacteristicType(CHAR_TYPE_NAME);
        List<Characteristic> chars = charCrud.retrieveCharacteristics(charType,
            SKY_GROUP_ID);

        List<Characteristic> expectedChars = ImmutableList.of(new Characteristic(
            KEPLER_ID, charType, VALUE));

        assertEquals(expectedChars, chars);
    }

    private void populateObjects() {
        databaseService = DatabaseServiceFactory.getInstance();
        targetSelectionCrud = new TargetSelectionCrud();
        kicCrud = new KicCrud();
        targetCrud = new TargetCrud();
        charCrud = new CharacteristicCrud();
    }

    @Test
    public void testManageDelete() {
        testManageCreate();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();

        // Simulate deleting the observed target.
        TargetTable scTargetTable = new TargetTable(TargetType.SHORT_CADENCE);
        targetCrud.createTargetTable(scTargetTable);

        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        for (ObservedTarget target : observedTargets) {
            target.setTargetTable(scTargetTable);
        }

        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();
        TadProductCharManager manager = new TadProductCharManager();
        manager.manage(TLS_NAME, MOD_OUT);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        CharacteristicType charType = charCrud.retrieveCharacteristicType(CHAR_TYPE_NAME);
        List<Characteristic> chars = charCrud.retrieveCharacteristics(charType,
            SKY_GROUP_ID);

        // The original characteristic row should be gone.
        assertEquals(ImmutableList.of(), chars);
    }

    @Test
    public void testManageUpdate() {
        testManageCreate();

        databaseService.beginTransaction();
        List<ObservedTarget> observedTargets = targetCrud.retrieveObservedTargets(
            targetTable, MOD_OUT.getCcdModule(), MOD_OUT.getCcdOutput());
        for (ObservedTarget target : observedTargets) {
            target.setSignalToNoiseRatio(UPDATED_VALUE);
        }
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();
        TadProductCharManager manager = new TadProductCharManager();
        manager.manage(TLS_NAME, MOD_OUT);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        CharacteristicType charType = charCrud.retrieveCharacteristicType(CHAR_TYPE_NAME);
        List<Characteristic> chars = charCrud.retrieveCharacteristics(charType,
            SKY_GROUP_ID);

        List<Characteristic> expectedChars = ImmutableList.of(new Characteristic(
            KEPLER_ID, charType, UPDATED_VALUE));

        assertEquals(expectedChars, chars);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testErrorIfNullTargetTable() {
        populateObjects();

        String invalidTlsName = "foo";
        databaseService.beginTransaction();
        TargetListSet tls = new TargetListSet(invalidTlsName);
        targetSelectionCrud.create(tls);
        databaseService.commitTransaction();

        databaseService.closeCurrentSession();
        databaseService.beginTransaction();
        TadProductCharManager manager = new TadProductCharManager();
        manager.manage(invalidTlsName, MOD_OUT);
        databaseService.commitTransaction();
    }

}
