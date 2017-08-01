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

import static org.junit.Assert.*;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import static gov.nasa.kepler.fs.server.TimeSeriesIntervalIterator.BREAK_AT;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class TimeSeriesMergeIntervalIteratorTest {

    /**
     * 
     */
    @Test
    public void debugTest() throws Exception {
        List<SimpleInterval> writeValid = new ArrayList<SimpleInterval>();
        writeValid.add(new SimpleInterval(0,0));
        writeValid.add(new SimpleInterval(2,3));
        writeValid.add(new SimpleInterval(49,50));
       
        List<TaggedInterval> writeOrigin = originatorsFromValid(writeValid);
        
        List<SimpleInterval> existing = new ArrayList<SimpleInterval>();
        existing.add(new SimpleInterval(2,4));
        existing.add(new SimpleInterval(50,51));
        
        TimeSeriesMergeIntervalIterator mergeIt = 
            new TimeSeriesMergeIntervalIterator(writeValid, writeOrigin, existing);
        
        for (Pair<List<SimpleInterval>, List<TaggedInterval>> pair : mergeIt) {
            System.out.println("Chunk.");
            for (SimpleInterval s : pair.left) {
                System.out.println("[" + s.start() + "," + s.end() + "]");
            }
            System.out.println("--");
            for (TaggedInterval t : pair.right) {
                System.out.println("[" + t.start() + "," + t.end() + "]");
            }
        }
    }
    /**
     *     xxx  xxx xxx
     *  ooo              oooo
     */
    @Test
    public void mergeIterator() {
        List<SimpleInterval> writeValid = new ArrayList<SimpleInterval>();
        writeValid.add(new SimpleInterval(4,4));
        writeValid.add(new SimpleInterval(6,6));
        writeValid.add(new SimpleInterval(8,8));
        List<TaggedInterval> writeOrigin = originatorsFromValid(writeValid);
        
        List<SimpleInterval> existing = new ArrayList<SimpleInterval>();
        existing.add(new SimpleInterval(0,4));
        existing.add(new SimpleInterval(8,10));
        
        TimeSeriesMergeIntervalIterator mergeIt = 
            new TimeSeriesMergeIntervalIterator(writeValid, writeOrigin, existing);
        assertTrue(mergeIt.hasNext());
        Pair<List<SimpleInterval>, List<TaggedInterval>> pair =  mergeIt.next();
        assertEquals(writeValid, pair.left);
        assertEquals(writeOrigin, pair.right);
        assertFalse(mergeIt.hasNext());
       
    }
    
    /**
     *     xxx  xxx xxx
     *  ooo    ooooo     oooo
     */
    @Test
    public void mergeIterator2() {
        List<SimpleInterval> writeValid = new ArrayList<SimpleInterval>();
        writeValid.add(new SimpleInterval(4,4));
        writeValid.add(new SimpleInterval(6,6));
        writeValid.add(new SimpleInterval(8,8));
        List<TaggedInterval> writeOrigin = originatorsFromValid(writeValid);
        
        List<SimpleInterval> existing = new ArrayList<SimpleInterval>();
        existing.add(new SimpleInterval(0,4));
        existing.add(new SimpleInterval(5,7));
        existing.add(new SimpleInterval(7, 10));
        
        TimeSeriesMergeIntervalIterator mergeIt = 
            new TimeSeriesMergeIntervalIterator(writeValid, writeOrigin, existing);
        assertTrue(mergeIt.hasNext());
        Pair<List<SimpleInterval>, List<TaggedInterval>> pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(4,4)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(4,4, 1L)), pair.right);
        pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(6,6)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(6,6, 1L)), pair.right);
        pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(8,8)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(8,8, 1L)), pair.right);
        assertFalse(mergeIt.hasNext());
    }
    
    /**
     *     xxx  xxxxxxx xxx
     *  ooooo    ooooo     oooo
     */
    @Test
    public void mergeIterator3() {
        List<SimpleInterval> writeValid = new ArrayList<SimpleInterval>();
        writeValid.add(new SimpleInterval(4,5));
        writeValid.add(new SimpleInterval(10,20));
        writeValid.add(new SimpleInterval(30,40));
        List<TaggedInterval> writeOrigin = originatorsFromValid(writeValid);
        
        List<SimpleInterval> existing = new ArrayList<SimpleInterval>();
        existing.add(new SimpleInterval(0,4));
        existing.add(new SimpleInterval(11,20));
        existing.add(new SimpleInterval(30, 42));
        
        TimeSeriesMergeIntervalIterator mergeIt = 
            new TimeSeriesMergeIntervalIterator(writeValid, writeOrigin, existing);
        assertTrue(mergeIt.hasNext());
        Pair<List<SimpleInterval>, List<TaggedInterval>> pair =  mergeIt.next();
        assertEquals(writeValid, pair.left);
        assertEquals(writeOrigin, pair.right);
        assertFalse(mergeIt.hasNext());
    }
    
    /**
     *     xxx  xxxxxxx xxx           <---BREAK_AT --> xxx
     *  o oooooooooo       
     */
    @Test
    public void mergeIterator4() {
        List<SimpleInterval> writeValid = new ArrayList<SimpleInterval>();
        writeValid.add(new SimpleInterval(4,5));
        writeValid.add(new SimpleInterval(10,20));
        writeValid.add(new SimpleInterval(30,40));
        writeValid.add(new SimpleInterval(BREAK_AT*2, BREAK_AT*4));
        List<TaggedInterval> writeOrigin = originatorsFromValid(writeValid);
        
        List<SimpleInterval> existing = new ArrayList<SimpleInterval>();
        existing.add(new SimpleInterval(0,1));
        existing.add(new SimpleInterval(3,15));
        
        TimeSeriesMergeIntervalIterator mergeIt = 
            new TimeSeriesMergeIntervalIterator(writeValid, writeOrigin, existing);
        assertTrue(mergeIt.hasNext());
        Pair<List<SimpleInterval>, List<TaggedInterval>> pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(4,5)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(4,5, 1L)), pair.right);
        pair = mergeIt.next();
        List<SimpleInterval> expectedValidChunk = new ArrayList<SimpleInterval>();
        expectedValidChunk.add(new SimpleInterval(10,20));
        expectedValidChunk.add(new SimpleInterval(30,40));
        List<TaggedInterval> expectedOriginatorChunk = 
            originatorsFromValid(expectedValidChunk);
        assertEquals(expectedValidChunk, pair.left);
        assertEquals(expectedOriginatorChunk, pair.right);
        pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(BREAK_AT*2,BREAK_AT*4)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(BREAK_AT*2, BREAK_AT*4, 1L)), pair.right);
        assertFalse(mergeIt.hasNext());
    }
    
    /**
     *     xxx    xxx  xxx
     *         oo    o
     */
    @Test
    public void mergeIterator5() {
        List<SimpleInterval> writeValid = new ArrayList<SimpleInterval>();
        writeValid.add(new SimpleInterval(4,4));
        writeValid.add(new SimpleInterval(6,6));
        writeValid.add(new SimpleInterval(8,8));
        List<TaggedInterval> writeOrigin = originatorsFromValid(writeValid);
        
        List<SimpleInterval> existing = new ArrayList<SimpleInterval>();

        existing.add(new SimpleInterval(5,5));
        existing.add(new SimpleInterval(7, 7));
        
        TimeSeriesMergeIntervalIterator mergeIt = 
            new TimeSeriesMergeIntervalIterator(writeValid, writeOrigin, existing);
        assertTrue(mergeIt.hasNext());
        Pair<List<SimpleInterval>, List<TaggedInterval>> pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(4,4)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(4,4, 1L)), pair.right);
        pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(6,6)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(6,6, 1L)), pair.right);
        pair = mergeIt.next();
        assertEquals(Collections.singletonList(new SimpleInterval(8,8)), pair.left);
        assertEquals(Collections.singletonList(new TaggedInterval(8,8, 1L)), pair.right);
        assertFalse(mergeIt.hasNext());
    }
    
    
    private List<TaggedInterval> originatorsFromValid(List<SimpleInterval> valid) {
        List<TaggedInterval> originators = new ArrayList<TaggedInterval>(valid.size());
        for (SimpleInterval s : valid) {
            originators.add(new TaggedInterval(s.start(), s.end(), 1L));
        }
        return originators;
    }
}
