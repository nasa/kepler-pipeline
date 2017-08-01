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
import static org.junit.Assert.assertNull;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.Iterator;
import java.util.List;

import org.junit.Before;
import org.junit.Test;

/**
 * Tests the {@link TargetListSet} class.
 * 
 * @author Bill Wohler
 */
public class TargetListSetTest {

    private TargetListSet targetListSet;

    @Before
    public void initializeTargetListSet() {
        targetListSet = new TargetListSet("foo");
    }

    @Test(expected = NullPointerException.class)
    public void testConstructorNullArg1() {
        new TargetListSet(null);
    }

    @Test(expected = NullPointerException.class)
    public void testConstructorNullArg2() {
        new TargetListSet(null, null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testConstructorEmptyArg() {
        new TargetListSet("");
    }

    @Test
    public void testTargetListSetConstructor() {
        targetListSet.setType(TargetType.REFERENCE_PIXEL);
        targetListSet.setStart(new Date(42));
        targetListSet.setEnd(new Date(4242));
        TargetListSet targetListSet2 = new TargetListSet("Copy of "
            + targetListSet.getName(), targetListSet);
        assertFalse(targetListSet.equals(targetListSet2));
        assertFalse(targetListSet == targetListSet2);
        assertEquals("Copy of " + targetListSet.getName(),
            targetListSet2.getName());
        assertEquals(targetListSet.getType(), targetListSet2.getType());
        assertEquals(targetListSet.getState(), targetListSet2.getState());
        assertEquals(targetListSet.getStart(), targetListSet2.getStart());
        assertEquals(targetListSet.getEnd(), targetListSet2.getEnd());
        Collection<TargetList> targetLists1 = targetListSet.getTargetLists();
        Collection<TargetList> targetLists2 = targetListSet2.getTargetLists();
        assertEquals(targetLists1.size(), targetLists2.size());
        Iterator<TargetList> i1 = targetLists1.iterator();
        Iterator<TargetList> i2 = targetLists2.iterator();
        // We've asserted the sets are the same size, so only need to test one
        // iterator.
        while (i1.hasNext()) {
            TargetList targetList1 = i1.next();
            TargetList targetList2 = i2.next();
            assertEquals(targetList1, targetList2);
            assertFalse(targetList1 == targetList2);
        }
    }

    @Test
    public void testGetId() {
        assertEquals(0L, targetListSet.getId());
    }

    @Test
    public void testSetName() {
        assertEquals("foo", targetListSet.getName());
        targetListSet.setName("bar");
        assertEquals("bar", targetListSet.getName());
    }

    @Test(expected = NullPointerException.class)
    public void testSetNameNullArg() {
        targetListSet.setName(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSetNameEmptyArg() {
        targetListSet.setName("");
    }

    @Test(expected = IllegalStateException.class)
    public void testSetNameIllegalState() {
        targetListSet.setState(State.LOCKED);
        targetListSet.setName("bar");
    }

    @Test
    public void testSetListType() {
        assertEquals(TargetType.LONG_CADENCE, targetListSet.getType());
        targetListSet.setType(TargetType.SHORT_CADENCE);
        assertEquals(TargetType.SHORT_CADENCE, targetListSet.getType());
    }

    @Test(expected = NullPointerException.class)
    public void testSetListTypeArg() {
        targetListSet.setType(null);
    }

    @Test
    public void testSetState() {
        assertEquals(State.UNLOCKED, targetListSet.getState());
        targetListSet.setState(State.LOCKED);
        assertEquals(State.LOCKED, targetListSet.getState());
    }

    @Test(expected = NullPointerException.class)
    public void testSetStateNullArg() {
        targetListSet.setState(null);
    }

    @Test
    public void testSetStart() {
        assertNull(targetListSet.getStart());
        Date date = new Date(42);
        targetListSet.setStart(date);
        assertEquals(date, targetListSet.getStart());
    }

    @Test(expected = NullPointerException.class)
    public void testSetStartNullArg() {
        targetListSet.setStart(null);
    }

    @Test
    public void testSetEnd() {
        assertNull(targetListSet.getEnd());
        Date date = new Date(42);
        targetListSet.setEnd(date);
        assertEquals(date, targetListSet.getEnd());
    }

    @Test(expected = NullPointerException.class)
    public void testSetEndNullArg() {
        targetListSet.setEnd(null);
    }

    @Test(expected = UnsupportedOperationException.class)
    public void testGetTargetListIllegalState() {
        targetListSet.setState(State.LOCKED);
        targetListSet.getTargetLists()
            .add(new TargetList("foo"));
    }

    @Test
    public void testGetSetTargetList() {
        assertEquals(Collections.EMPTY_LIST, targetListSet.getTargetLists());
        TargetList targetList = new TargetList("foo");
        List<TargetList> targetLists = targetListSet.getTargetLists();
        targetLists.add(targetList);
        assertEquals(targetList, targetListSet.getTargetLists()
            .iterator()
            .next());

        targetLists = new ArrayList<TargetList>();
        targetLists.add(targetList);
        targetListSet.setTargetLists(targetLists);
        assertEquals(targetList, targetListSet.getTargetLists()
            .iterator()
            .next());
    }

    // SOC_REQ_IMPL 227.CM.1
    @Test(expected = IllegalStateException.class)
    public void testSetTargetListIllegalState() {
        targetListSet.setState(State.LOCKED);
        List<TargetList> targetLists = new ArrayList<TargetList>();
        targetLists.add(new TargetList("foo"));
        targetListSet.setTargetLists(targetLists);
    }

    @Test
    public void testEquals() {
        assertEquals(targetListSet, targetListSet);
        assertEquals(targetListSet, new TargetListSet("foo"));
        assertFalse(targetListSet.equals(new TargetListSet("bar")));
    }

    @Test
    public void testHashCode() {
        assertEquals(targetListSet.hashCode(), targetListSet.hashCode());
        assertEquals(targetListSet.hashCode(),
            new TargetListSet("foo").hashCode());
        assertFalse(targetListSet.hashCode() == new TargetListSet("bar").hashCode());
    }
}
