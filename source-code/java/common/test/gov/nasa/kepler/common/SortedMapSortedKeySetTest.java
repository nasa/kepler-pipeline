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

package gov.nasa.kepler.common;

import java.util.SortedMap;
import java.util.SortedSet;
import java.util.TreeMap;

import org.junit.Test;
import static org.junit.Assert.*;

public class SortedMapSortedKeySetTest {

    @Test
    public void sortedMapSortedKeySetTest() {
        SortedMap<Integer, String> backingMap = new TreeMap<Integer, String>();
        
        SortedSet<Integer> w = 
            new SortedMapSortedKeySet<Integer>(backingMap);
        
        assertTrue(w.isEmpty());
        
        assertEquals(backingMap.comparator(), w.comparator());
        
        backingMap.put(0, "a");
        backingMap.put(1, "b");
        backingMap.put(2, "c");
        
        assertEquals(3, w.size());
        
        assertEquals(Integer.valueOf(0), w.first());
        assertEquals(Integer.valueOf(2), (Integer) w.last());
        assertTrue(w.contains(1));
        assertFalse(w.contains(7));
        
        assertEquals(Integer.valueOf(0),w.headSet(1).first());
        assertEquals(Integer.valueOf(2), w.tailSet(1).last());
        assertEquals(Integer.valueOf(0), w.iterator().next());
        SortedSet<Integer> subSetOfW = w.subSet(1, 2);
        assertEquals(1, subSetOfW.size());
        assertEquals(Integer.valueOf(1), subSetOfW.first());
        
        Integer[] keyArray = w.toArray(new Integer[3]);
        for (int i=0; i < 3; i++) {
            assertEquals(Integer.valueOf(i),keyArray[i]);
        }
        Object[] objectKeyArray = w.toArray();
        assertEquals(keyArray.length, objectKeyArray.length);
        for (int i=0; i < objectKeyArray.length; i++) {
            assertEquals(keyArray[i], objectKeyArray[i]);
        }
        
    }
}
