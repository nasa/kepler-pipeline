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

package gov.nasa.kepler.hibernate.tad;

import static org.junit.Assert.assertEquals;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.Date;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TargetTableComparatorTest extends JMockTest {

    private static final int CCD_MODULE = 2;
    private static final int CCD_OUTPUT = 1;

    private static final boolean INCLUDE_NULL_APERTURES = false;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    @Test
    public void testValid() {
        Mask oldMask = new Mask(null, ImmutableList.of(new Offset(1, 1)));

        TargetDefinition oldTargetDef = new TargetDefinition(1, 1, 0, oldMask);

        ObservedTarget oldObservedTarget = new ObservedTarget(100);
        oldObservedTarget.getTargetDefinitions()
            .add(oldTargetDef);

        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldObservedTarget);

        Aperture newAperture = new Aperture(false, 1, 1,
            ImmutableList.of(new Offset(1, 1)));

        ObservedTarget newObservedTarget = new ObservedTarget(100);
        newObservedTarget.setAperture(newAperture);

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        List<ObservedTarget> newTargets = ImmutableList.of(newObservedTarget);

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);

        // Check alerts.
        AlertLogCrud alertLogCrud = new AlertLogCrud();
        List<AlertLog> alertLogs = alertLogCrud.retrieve(new Date(0),
            new Date());
        assertEquals(0, alertLogs.size());
    }

    @Test
    public void testDifferentSeasons() {
        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        oldTargetTable.setObservingSeason(1);
        List<ObservedTarget> oldTargets = ImmutableList.of(new ObservedTarget(
            100));

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        oldTargetTable.setObservingSeason(2);
        List<ObservedTarget> newTargets = ImmutableList.of(new ObservedTarget(
            100));

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

    @Test
    public void testDifferentTargetCounts() {
        TargetTable oldTargetTable = mock(TargetTable.class, "oldTargetTable");
        ObservedTarget oldTarget = mock(ObservedTarget.class);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldTarget);

        TargetTable newTargetTable = mock(TargetTable.class, "newTargetTable");
        List<ObservedTarget> newTargets = ImmutableList.of();

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(oldTarget).getKeplerId();
        will(returnValue(100));

        allowing(oldTargetTable).getObservingSeason();
        will(returnValue(2));

        allowing(newTargetTable).getObservingSeason();
        will(returnValue(2));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

    @Test
    public void testDifferentKeplerIds() {
        TargetTable oldTargetTable = mock(TargetTable.class, "oldTargetTable");
        ObservedTarget oldTarget = mock(ObservedTarget.class, "oldTarget");
        List<ObservedTarget> oldTargets = ImmutableList.of(oldTarget);

        TargetTable newTargetTable = mock(TargetTable.class, "newTargetTable");
        ObservedTarget newTarget = mock(ObservedTarget.class, "newTarget");
        List<ObservedTarget> newTargets = ImmutableList.of(newTarget);

        Aperture newAperture = new Aperture(false, 1, 1,
            ImmutableList.of(new Offset(1, 1)));

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(oldTarget).getKeplerId();
        will(returnValue(100));

        allowing(newTarget).getKeplerId();
        will(returnValue(200));

        allowing(newTarget).getAperture();
        will(returnValue(newAperture));

        allowing(oldTargetTable).getObservingSeason();
        will(returnValue(2));

        allowing(newTargetTable).getObservingSeason();
        will(returnValue(2));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

    @Test
    public void testNewOptimalAperturePixelWithNoOldTargetDefPixel() {
        Mask oldMask = new Mask(null, ImmutableList.of(new Offset(1, 1)));

        TargetDefinition oldTargetDef = new TargetDefinition(1, 1, 0, oldMask);

        ObservedTarget oldObservedTarget = new ObservedTarget(100);
        oldObservedTarget.getTargetDefinitions()
            .add(oldTargetDef);

        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldObservedTarget);

        Aperture newAperture = new Aperture(false, 2, 2,
            ImmutableList.of(new Offset(2, 2)));

        ObservedTarget newObservedTarget = new ObservedTarget(100);
        newObservedTarget.setAperture(newAperture);

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);
        List<ObservedTarget> newTargets = ImmutableList.of(newObservedTarget);

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        DatabaseServiceFactory.getInstance()
            .beginTransaction();
        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
        DatabaseServiceFactory.getInstance()
            .commitTransaction();
    }

    @Test
    public void testRejectedOriginalRejectedSupplemental() {
        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget oldTarget = new ObservedTarget(100);
        oldTarget.setRejected(true);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldTarget);

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget newTarget = new ObservedTarget(100);
        newTarget.setRejected(true);
        List<ObservedTarget> newTargets = ImmutableList.of(newTarget);

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

    @Test
    public void testRejectedOriginalNotRejectedSupplemental() {
        Aperture aperture = new Aperture(false, 1, 1,
            ImmutableList.of(new Offset(1, 1)));

        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget oldTarget = new ObservedTarget(100);
        oldTarget.setRejected(true);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldTarget);

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget newTarget = new ObservedTarget(100);
        newTarget.setRejected(false);
        newTarget.setAperture(aperture);
        List<ObservedTarget> newTargets = ImmutableList.of(newTarget);

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

    @Test
    public void testNotRejectedOriginalRejectedSupplemental() {
        Aperture aperture = new Aperture(false, 1, 1,
            ImmutableList.of(new Offset(1, 1)));

        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget oldTarget = new ObservedTarget(100);
        oldTarget.setRejected(false);
        oldTarget.setAperture(aperture);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldTarget);

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget newTarget = new ObservedTarget(100);
        newTarget.setRejected(true);
        List<ObservedTarget> newTargets = ImmutableList.of(newTarget);

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

    @Test
    public void testNotRejectedOriginalNotRejectedSupplemental() {
        Aperture aperture = new Aperture(false, 1, 1,
            ImmutableList.of(new Offset(1, 1)));

        TargetTable oldTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget oldTarget = new ObservedTarget(100);
        oldTarget.setRejected(false);
        oldTarget.setAperture(aperture);
        List<ObservedTarget> oldTargets = ImmutableList.of(oldTarget);

        TargetTable newTargetTable = new TargetTable(TargetType.LONG_CADENCE);

        ObservedTarget newTarget = new ObservedTarget(100);
        newTarget.setRejected(false);
        newTarget.setAperture(aperture);
        List<ObservedTarget> newTargets = ImmutableList.of(newTarget);

        TargetCrud targetCrud = mock(TargetCrud.class);

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            oldTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(oldTargets));

        allowing(targetCrud).retrieveObservedTargetsPlusRejectedIgnoreSupplemental(
            newTargetTable, CCD_MODULE, CCD_OUTPUT, INCLUDE_NULL_APERTURES);
        will(returnValue(newTargets));

        TargetTableComparator validator = new TargetTableComparator();
        validator.setTargetCrud(targetCrud);
        validator.validate(oldTargetTable, newTargetTable, CCD_MODULE,
            CCD_OUTPUT);
    }

}
