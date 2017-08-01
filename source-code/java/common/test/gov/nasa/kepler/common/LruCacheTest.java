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


import static org.junit.Assert.*;

import gov.nasa.spiffy.common.collect.LruCache;
import gov.nasa.spiffy.common.concurrent.MultiLevelConcurrentLruCache;

import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class LruCacheTest {

    @Before
    public void setUp() throws Exception {
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void lruTest() {
        LruCache<Integer, Integer> lruCache = 
            new LruCache<Integer, Integer>(3, true);
        
        lruCache.put(1,2);
        lruCache.put(2,2);
        lruCache.put(3,3);
        lruCache.get(1);
        lruCache.put(4,4);
        
        assertTrue(lruCache.containsKey(1));
        assertTrue(lruCache.containsKey(3));
        assertTrue(lruCache.containsKey(4));
        assertFalse(lruCache.containsKey(2));
    }
    
    @Test
    public void multiLevelConcurrentCacheTest() throws Exception {
        MultiLevelConcurrentLruCache<List<Integer>, List<Integer>> mlLruCache =
            new MultiLevelConcurrentLruCache<List<Integer>, List<Integer>>(32);
        List<List<Integer>> listOfLists = generateListData();
        List<List<Integer>> listOfLists2 = generateListData();
        
        assertEquals(null, mlLruCache.get(listOfLists2.get(0)));
        mlLruCache.put(listOfLists.get(0), listOfLists.get(0));
        assertEquals(listOfLists2.get(0), mlLruCache.get(listOfLists2.get(0)));
        for (List<Integer> data : listOfLists) {
            mlLruCache.put(data, data);
        }
        assertEquals(null, mlLruCache.get(listOfLists2.get(0)));
        mlLruCache.put(listOfLists.get(0), listOfLists.get(0));
        assertEquals(listOfLists2.get(0), mlLruCache.get(listOfLists2.get(0)));
    }

    private List<List<Integer>> generateListData() {
        List<List<Integer>> listOfLists = new ArrayList<List<Integer>>();
        for (int i=0; i < 64; i++) {
            List<Integer> data = new ArrayList<Integer>();
            for (int j=0; j < 70; j++) {
                data.add(j);
            }
            data.add(i);
            listOfLists.add(data);
        }
        return listOfLists;
    }
}
