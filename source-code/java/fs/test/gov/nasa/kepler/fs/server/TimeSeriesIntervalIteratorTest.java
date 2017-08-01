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

package gov.nasa.kepler.fs.server;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.NoSuchElementException;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class TimeSeriesIntervalIteratorTest {

    @SuppressWarnings("unchecked")
    @Test
    public void breakEmptyIntervals() throws Exception {
        TimeSeriesIntervalIterator it = 
            new TimeSeriesIntervalIterator(Collections.EMPTY_LIST, Collections.EMPTY_LIST);
        assertFalse(it.hasNext());
        try {
            it.next();
            assertTrue(false);
        } catch (NoSuchElementException ok) {
            //ok
        }
    }
    
    @Test
    public void breakSingleIntervals() throws Exception {
        SimpleInterval v = new SimpleInterval(0,10);
        TaggedInterval t = new TaggedInterval(0,10, 0);
        
        TimeSeriesIntervalIterator it = 
            new TimeSeriesIntervalIterator(Collections.singletonList(v), Collections.singletonList(t));
        assertTrue(it.hasNext());
        Pair<List<SimpleInterval>, List<TaggedInterval>> chunk = it.next();
        assertEquals(1, chunk.left.size());
        assertEquals(v, chunk.left.get(0));
        assertEquals(1, chunk.right.size());
        assertEquals(t, chunk.right.get(0));
        
        assertFalse(it.hasNext());
        
    }
    
    @Test
    public void singleGap() throws Exception {
        List<SimpleInterval> vl = new ArrayList<SimpleInterval>();
        vl.add(new SimpleInterval(10,16000));
        vl.add(new SimpleInterval(1000000, 100000000));

        List<TaggedInterval> tl = new ArrayList<TaggedInterval>();
        tl.add(new TaggedInterval(10,16000, 1));
        tl.add(new TaggedInterval(1000000,1000001,5));
        tl.add(new TaggedInterval(1000002,100000000,2));
        
        TimeSeriesIntervalIterator it =
            new TimeSeriesIntervalIterator(vl, tl);
        
        Pair<List<SimpleInterval>, List<TaggedInterval>> chunk = it.next();
        
        assertTrue(it.hasNext());
        assertEquals(1, chunk.left.size());
        assertEquals(vl.get(0), chunk.left.get(0));
        assertEquals(1, chunk.right.size());
        assertEquals(tl.get(0), chunk.right.get(0));
        
        chunk = it.next();
        assertEquals(1, chunk.left.size());
        assertEquals(vl.get(1), chunk.left.get(0));
        assertEquals(2, chunk.right.size());
        assertEquals(tl.get(1), chunk.right.get(0));
        assertEquals(tl.get(2), chunk.right.get(1));
        
        assertFalse(it.hasNext());
        
    }

}
