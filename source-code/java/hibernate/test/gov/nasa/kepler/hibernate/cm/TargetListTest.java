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
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.hibernate.cm.TargetList.SourceType;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link TargetList} class.
 * 
 * @author Bill Wohler
 */
public class TargetListTest {

    private TargetList targetList;

    @Before
    public void initializeTargetList() {
        targetList = new TargetList("foo");
    }

    @Test(expected = NullPointerException.class)
    public void testConstructorNullArg() {
        new TargetList(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testConstructorEmptyArg() {
        new TargetList("");
    }

    @Test
    public void testTargetListConstructor() {
        targetList.setCategory("Planet Detection Targets");
        targetList.setSourceType(SourceType.FILE);
        targetList.setSource("foo");
        TargetList targetList2 = new TargetList("Copy of "
            + targetList.getName(), targetList);
        assertFalse(targetList.equals(targetList2));
        assertFalse(targetList == targetList2);
        assertEquals("Copy of " + targetList.getName(), targetList2.getName());
        assertEquals(targetList.getCategory(), targetList2.getCategory());
        assertEquals(targetList.getSourceType(), targetList2.getSourceType());
        assertEquals(targetList.getSource(), targetList2.getSource());
    }

    @Test
    public void testGetLastModified() {
        assertNotNull(targetList.getLastModified());
    }

    @Test
    public void testSetName() {
        assertEquals("foo", targetList.getName());
        targetList.setName("bar");
        assertEquals("bar", targetList.getName());
    }

    @Test(expected = NullPointerException.class)
    public void testSetNameNullArg() {
        targetList.setName(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSetNameEmptyArg() {
        targetList.setName("");
    }

    @Test
    public void testSetCategory() {
        targetList.setCategory("bar");
        assertEquals("bar", targetList.getCategory());
    }

    @Test(expected = NullPointerException.class)
    public void testSetCategoryNullArg() {
        targetList.setCategory(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSetCategoryEmptyArg() {
        targetList.setCategory("");
    }

    @Test
    public void testSetSource() {
        assertNull(targetList.getSource());
        String s = "select * from blah";
        targetList.setSource(s);
        assertEquals(s, targetList.getSource());
    }

    @Test
    public void testSetSourceType() {
        assertEquals(SourceType.QUERY, targetList.getSourceType());
        targetList.setSourceType(SourceType.FILE);
        assertEquals(SourceType.FILE, targetList.getSourceType());
    }

    @Test
    public void testEquals() {
        assertEquals(targetList, targetList);
        assertEquals(targetList, new TargetList("foo"));
        assertFalse(targetList.equals(new TargetList("bar")));
    }

    @Test
    public void testHashCode() {
        assertEquals(targetList.hashCode(), targetList.hashCode());
        assertEquals(targetList.hashCode(), new TargetList("foo").hashCode());
        assertFalse(targetList.hashCode() == new TargetList("bar").hashCode());
    }
}
