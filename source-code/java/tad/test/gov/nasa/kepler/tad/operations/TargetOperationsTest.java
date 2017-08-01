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

package gov.nasa.kepler.tad.operations;

import static com.google.common.collect.Sets.newHashSet;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Mask;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.ObservedTarget;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetDefinition;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.mc.Pixel;

import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableSet;

/**
 * @author Sean McCauliff
 * @author Miles Cote
 * 
 */
public class TargetOperationsTest {

    private TargetOperations targetOperations;

    private DatabaseService databaseService;
    private TargetCrud targetCrud;

    @Before
    public void setUp() throws Exception {
        DefaultProperties.setPropsForUnitTest();
        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        targetCrud = new TargetCrud(databaseService);

        targetOperations = new TargetOperations();
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(databaseService);
    }

    @Test
    public void testGetPixelsForLabeledTargets() throws Exception {

        Pixel p1 = new Pixel(10, 23);
        Pixel p2 = new Pixel(10, 23);
        assertEquals(p1, p2);
        assertEquals(p1.hashCode(), p2.hashCode());

        Map<Integer, List<Pixel>> keplerIdToPixel = targetOperations.getAperturePixelsForLabeledTargets(
            new TestTargetCrud(), null, 2, 2, ImmutableSet.of("Y"));

        assertEquals(1, keplerIdToPixel.size());
        List<Pixel> pixels = keplerIdToPixel.get(2);
        Set<Pixel> pixelSet = newHashSet(pixels);
        assertEquals(2, pixelSet.size());

        assertTrue(pixelSet.contains(new Pixel(23, 10)));
        // assertTrue(pixelSet.contains(new Pixel(24,10)));
        assertTrue(pixelSet.contains(new Pixel(23, 11)));
    }

    private static final class TestTargetCrud extends TargetCrud {
        @Override
        public List<ObservedTarget> retrieveObservedTargets(
            TargetTable targetTable, int ccdModule, int ccdOutput) {

            List<Offset> apertureOffsets = ImmutableList.of(new Offset(0, 0),
                new Offset(0, 1));

            Aperture a1 = new Aperture(true, 23, 25, apertureOffsets);
            ObservedTarget ot1 = new ObservedTarget(1);
            ot1.setAperture(a1);
            ot1.setLabels(ImmutableSet.of("X"));

            ObservedTarget ot2 = new ObservedTarget(2);
            ot2.setLabels(ImmutableSet.of("Y"));

            TargetDefinition tgtDef = new TargetDefinition();
            tgtDef.setReferenceColumn(10);
            tgtDef.setReferenceRow(23);

            Mask mask = new Mask();

            List<Offset> offsetList = ImmutableList.of(new Offset(0, 0),
                new Offset(1, 0), new Offset(0, 1));

            mask.setOffsets(offsetList);

            tgtDef.setMask(mask);

            ot2.setTargetDefinitions(ImmutableSet.of(tgtDef));

            Aperture a2 = new Aperture(true, 23, 10, apertureOffsets);
            ot2.setAperture(a2);

            List<ObservedTarget> rv = ImmutableList.of(ot1, ot2);

            return rv;
        }
    }

    @Test
    public void testCopyMaskTable() {
        List<Offset> offsets = ImmutableList.of(new Offset(1, 1));
        MaskTable sourceMaskTable = new MaskTable(MaskType.TARGET);
        List<Mask> sourceMasks = ImmutableList.of(new Mask(sourceMaskTable,
            offsets));

        databaseService.beginTransaction();
        targetCrud.createMaskTable(sourceMaskTable);
        targetCrud.createMasks(sourceMasks);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        databaseService.beginTransaction();
        MaskTable newMaskTable = targetOperations.copy(sourceMaskTable, null);
        databaseService.commitTransaction();
        databaseService.closeCurrentSession();

        List<Mask> newMasks = targetCrud.retrieveMasks(newMaskTable);
        Mask newMask = newMasks.get(0);

        assertNotSame(sourceMaskTable, newMaskTable);
        assertNotSame(sourceMasks.get(0), newMask);
        assertEquals(new Offset(1, 1), newMask.getOffsets()
            .get(0));
    }

}
