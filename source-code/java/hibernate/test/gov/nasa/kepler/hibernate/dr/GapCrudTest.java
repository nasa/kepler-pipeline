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

import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author tklaus
 * 
 */
public class GapCrudTest {

    private static final int KEPLER_ID = 800;

    private GapCrud gapCrud;

    // expecteds
    private GapCadence expectedGapCadence1;
    private GapCadence expectedGapCadence2;
    private GapCadence expectedGapCadence3;

    private GapChannel expectedGapChannel1;
    private GapChannel expectedGapChannel2;
    private GapChannel expectedGapChannel3;
    private GapChannel expectedGapChannel4;

    private GapTarget expectedGapTarget1;
    private GapTarget expectedGapTarget2;
    private GapTarget expectedGapTarget3;

    private GapPixel expectedGapPixel1;
    private GapPixel expectedGapPixel2;
    private GapPixel expectedGapPixel3;

    private DatabaseService databaseService;

    private ReflectionEquals reflectionEquals = new ReflectionEquals();

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
        // DatabaseUtils.deleteAllEntriesForClass(GapCadence.class);
        // DatabaseUtils.deleteAllEntriesForClass(GapChannel.class);
        // DatabaseUtils.deleteAllEntriesForClass(GapTarget.class);
        // DatabaseUtils.deleteAllEntriesForClass(GapPixel.class);

        gapCrud = new GapCrud(DatabaseServiceFactory.getInstance());

        // store test objects
        try {
            DatabaseServiceFactory.getInstance()
                .beginTransaction();

            expectedGapCadence1 = new GapCadence(42, CadenceType.LONG);
            expectedGapCadence2 = new GapCadence(43, CadenceType.LONG);
            expectedGapCadence3 = new GapCadence(44, CadenceType.LONG);

            expectedGapChannel1 = new GapChannel(45, CadenceType.LONG, 2, 1);
            expectedGapChannel2 = new GapChannel(46, CadenceType.LONG, 2, 1);
            expectedGapChannel3 = new GapChannel(47, CadenceType.LONG, 2, 1);
            expectedGapChannel4 = new GapChannel(48, CadenceType.LONG, 2, 1);

            expectedGapTarget1 = new GapTarget(45, CadenceType.LONG, 3, 1,
                KEPLER_ID, 21, TargetType.LONG_CADENCE);
            expectedGapTarget2 = new GapTarget(46, CadenceType.LONG, 3, 1,
                KEPLER_ID, 21, TargetType.LONG_CADENCE);
            expectedGapTarget3 = new GapTarget(47, CadenceType.LONG, 3, 1,
                KEPLER_ID, 21, TargetType.LONG_CADENCE);

            expectedGapPixel1 = new GapPixel(45, CadenceType.LONG, 3, 1,
                TargetType.LONG_CADENCE, KEPLER_ID, 24, 833, 501);
            expectedGapPixel2 = new GapPixel(46, CadenceType.LONG, 3, 1,
                TargetType.LONG_CADENCE, KEPLER_ID, 24, 833, 501);
            expectedGapPixel3 = new GapPixel(47, CadenceType.LONG, 3, 1,
                TargetType.LONG_CADENCE, KEPLER_ID, 24, 833, 501);

            gapCrud.create(expectedGapCadence1);
            gapCrud.create(expectedGapCadence2);
            gapCrud.create(expectedGapCadence3);

            gapCrud.create(expectedGapChannel1);
            gapCrud.create(expectedGapChannel2);
            gapCrud.create(expectedGapChannel3);
            gapCrud.create(expectedGapChannel4);

            gapCrud.create(expectedGapTarget1);
            gapCrud.create(expectedGapTarget2);
            gapCrud.create(expectedGapTarget3);

            gapCrud.create(expectedGapPixel1);
            gapCrud.create(expectedGapPixel2);
            gapCrud.create(expectedGapPixel3);

            DatabaseServiceFactory.getInstance()
                .commitTransaction();
        } finally {
            DatabaseServiceFactory.getInstance()
                .rollbackTransactionIfActive();
        }

        databaseService.closeCurrentSession();
    }

    @Test
    public void retrieveAllGapCadence() throws Exception {
        populateObjects();

        List<GapCadence> gapCadenceList = gapCrud.retrieveGapCadence(
            CadenceType.LONG, 0, 100);

        reflectionEquals.assertEquals("list size", 3, gapCadenceList.size());
        reflectionEquals.assertEquals(expectedGapCadence1,
            gapCadenceList.get(0));
        reflectionEquals.assertEquals(expectedGapCadence2,
            gapCadenceList.get(1));
        reflectionEquals.assertEquals(expectedGapCadence3,
            gapCadenceList.get(2));
    }

    /**
     * @throws Exception
     */
    @Test
    public void retrievePartialGapCadence() throws Exception {
        populateObjects();

        List<GapCadence> gapCadenceList = gapCrud.retrieveGapCadence(
            CadenceType.LONG, 42, 43);

        reflectionEquals.assertEquals("list size", 2, gapCadenceList.size());
        reflectionEquals.assertEquals(expectedGapCadence1,
            gapCadenceList.get(0));
        reflectionEquals.assertEquals(expectedGapCadence2,
            gapCadenceList.get(1));
    }

    @Test
    public void retrieveAllGapChannel() throws Exception {
        populateObjects();

        List<GapChannel> gapChannelList = gapCrud.retrieveGapChannel(
            CadenceType.LONG, 0, 100, 2, 1);

        reflectionEquals.assertEquals("list size", 4, gapChannelList.size());
        reflectionEquals.assertEquals(expectedGapChannel1,
            gapChannelList.get(0));
        reflectionEquals.assertEquals(expectedGapChannel2,
            gapChannelList.get(1));
        reflectionEquals.assertEquals(expectedGapChannel3,
            gapChannelList.get(2));
        reflectionEquals.assertEquals(expectedGapChannel4,
            gapChannelList.get(3));
    }

    /**
     * @throws Exception
     */
    @Test
    public void retrievePartialGapChannel() throws Exception {
        populateObjects();

        List<GapChannel> gapChannelList = gapCrud.retrieveGapChannel(
            CadenceType.LONG, 45, 46, 2, 1);

        reflectionEquals.assertEquals("list size", 2, gapChannelList.size());
        reflectionEquals.assertEquals(expectedGapChannel1,
            gapChannelList.get(0));
        reflectionEquals.assertEquals(expectedGapChannel2,
            gapChannelList.get(1));
    }

    @Test
    public void retrieveAllGapTarget() throws Exception {
        populateObjects();

        List<GapTarget> gapTargetList = gapCrud.retrieveGapTarget(
            CadenceType.LONG, TargetType.LONG_CADENCE, 0, 100, 3, 1, 21);

        reflectionEquals.assertEquals("list size", 3, gapTargetList.size());
        reflectionEquals.assertEquals(expectedGapTarget1, gapTargetList.get(0));
        reflectionEquals.assertEquals(expectedGapTarget2, gapTargetList.get(1));
        reflectionEquals.assertEquals(expectedGapTarget3, gapTargetList.get(2));
    }

    /**
     * @throws Exception
     */
    @Test
    public void retrievePartialGapTarget() throws Exception {
        populateObjects();

        List<GapTarget> gapTargetList = gapCrud.retrieveGapTarget(
            CadenceType.LONG, TargetType.LONG_CADENCE, 45, 46, 3, 1, 21);

        reflectionEquals.assertEquals("list size", 2, gapTargetList.size());
        reflectionEquals.assertEquals(expectedGapTarget1, gapTargetList.get(0));
        reflectionEquals.assertEquals(expectedGapTarget2, gapTargetList.get(1));
    }

    @Test
    public void retrieveAllGapPixel() throws Exception {
        populateObjects();

        List<GapPixel> gapPixelList = gapCrud.retrieveGapPixel(
            CadenceType.LONG, TargetType.LONG_CADENCE, 0, 100, 3, 1, 24, 833,
            501);

        reflectionEquals.assertEquals("list size", 3, gapPixelList.size());
        reflectionEquals.assertEquals(expectedGapPixel1, gapPixelList.get(0));
        reflectionEquals.assertEquals(expectedGapPixel2, gapPixelList.get(1));
        reflectionEquals.assertEquals(expectedGapPixel3, gapPixelList.get(2));
    }

    /**
     * @throws Exception
     */
    @Test
    public void retrievePartialGapPixel() throws Exception {
        populateObjects();

        List<GapPixel> gapPixelList = gapCrud.retrieveGapPixel(
            CadenceType.LONG, TargetType.LONG_CADENCE, 45, 46, 3, 1, 24, 833,
            501);

        reflectionEquals.assertEquals("list size", 2, gapPixelList.size());
        reflectionEquals.assertEquals(expectedGapPixel1, gapPixelList.get(0));
        reflectionEquals.assertEquals(expectedGapPixel2, gapPixelList.get(1));
    }
}
