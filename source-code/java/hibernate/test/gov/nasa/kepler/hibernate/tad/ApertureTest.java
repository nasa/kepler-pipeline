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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotSame;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.hibernate.pi.PipelineTask;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.junit.Test;

/**
 * Tests the {@link Aperture} class.
 * 
 * @author Bill Wohler
 */
public class ApertureTest {

    private static final int REFERENCE_ROW = 42;
    private static final int REFERENCE_COLUMN = 43;
    private static final int OFFSET_SEED = 44;
    private Aperture aperture;
    private List<Offset> offsets;

    @Test
    public void testAperture() {
        Aperture aperture = new Aperture();
        assertEquals(0, aperture.getOffsets()
            .size());
        assertNull(aperture.getPipelineTask());
        assertEquals(0, aperture.getReferenceColumn());
        assertEquals(0, aperture.getReferenceRow());
        assertNull(aperture.getTargetTable());
        assertFalse(aperture.isUserDefined());
    }

    @Test
    public void testApertureAperture() {
        populateObjects();
        testAperture(aperture.createCopy());
    }

    @Test
    public void testApertureBooleanIntIntListOfOffset() {
        populateObjects();
        testAperture(aperture);
    }

    @Test
    public void testHashCode() {
        populateObjects();

        assertEquals(aperture.hashCode(), createAperture().hashCode());

        List<Offset> offsets = new ArrayList<Offset>(aperture.getOffsets());
        Collections.reverse(offsets);
        assertEquals(aperture.hashCode(),
            new Aperture(aperture.isUserDefined(), aperture.getReferenceRow(),
                aperture.getReferenceColumn(), offsets).hashCode());

        assertNotSame(aperture, new Aperture(false, REFERENCE_ROW,
            REFERENCE_COLUMN, createOffsets(OFFSET_SEED)));
        assertNotSame(aperture, new Aperture(true, REFERENCE_ROW + 1,
            REFERENCE_COLUMN, createOffsets(OFFSET_SEED)));
        assertNotSame(aperture, new Aperture(true, REFERENCE_ROW,
            REFERENCE_COLUMN + 1, createOffsets(OFFSET_SEED)));
        assertNotSame(aperture, new Aperture(true, REFERENCE_ROW,
            REFERENCE_COLUMN, createOffsets(OFFSET_SEED + 1)));
    }

    @Test
    public void testEquals() {
        populateObjects();

        assertTrue(aperture.equals(createAperture()));
        List<Offset> offsets = new ArrayList<Offset>(aperture.getOffsets());
        Collections.reverse(offsets);
        assertTrue(aperture.equals(new Aperture(aperture.isUserDefined(),
            aperture.getReferenceRow(), aperture.getReferenceColumn(), offsets)));

        assertFalse(aperture.equals(new Aperture(false, REFERENCE_ROW,
            REFERENCE_COLUMN, createOffsets(OFFSET_SEED))));
        assertFalse(aperture.equals(new Aperture(true, REFERENCE_ROW + 1,
            REFERENCE_COLUMN, createOffsets(OFFSET_SEED))));
        assertFalse(aperture.equals(new Aperture(true, REFERENCE_ROW,
            REFERENCE_COLUMN + 1, createOffsets(OFFSET_SEED))));
        assertFalse(aperture.equals(new Aperture(true, REFERENCE_ROW,
            REFERENCE_COLUMN, createOffsets(OFFSET_SEED + 1))));
    }

    @Test
    public void testToString() {
        populateObjects();
        assertTrue(aperture.toString(), aperture.toString()
            .startsWith("gov.nasa.kepler.hibernate.tad.Aperture@"));
        assertTrue(
            aperture.toString(),
            aperture.toString()
                .endsWith(
                    "[userDefined=true,referenceRow=42,referenceColumn=43,offsets=[[44,43], [44,44], [44,45], [45,43], [45,44], [45,46]]]"));
    }

    @Test
    public void testGetTargetTable() {
        Aperture aperture = new Aperture();
        TargetTable targetTable = new TargetTable();
        aperture.setTargetTable(targetTable);
        assertEquals(targetTable, aperture.getTargetTable());
    }

    @Test
    public void testGetPipelineTask() {
        Aperture aperture = new Aperture();
        PipelineTask pipelineTask = new PipelineTask();
        aperture.setPipelineTask(pipelineTask);
        assertEquals(pipelineTask, aperture.getPipelineTask());
    }

    private void populateObjects() {
        offsets = createOffsets(OFFSET_SEED);
        aperture = createAperture();
    }

    private List<Offset> createOffsets(int seed) {
        return Arrays.asList(new Offset(seed, seed - 1),
            new Offset(seed, seed), new Offset(seed, seed + 1), new Offset(
                seed + 1, seed - 1), new Offset(seed + 1, seed), new Offset(
                seed + 1, seed + 2));
    }

    private Aperture createAperture() {
        return new Aperture(true, REFERENCE_ROW, REFERENCE_COLUMN, offsets);
    }

    private void testAperture(Aperture actualAperture) {
        assertEquals(offsets, actualAperture.getOffsets());
        assertNull(actualAperture.getPipelineTask());
        assertEquals(REFERENCE_COLUMN, actualAperture.getReferenceColumn());
        assertEquals(REFERENCE_ROW, actualAperture.getReferenceRow());
        assertNull(actualAperture.getTargetTable());
    }

}
