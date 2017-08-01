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
import gov.nasa.spiffy.common.intervals.Interval;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.List;

import org.junit.Test;

/**
 * 
 * @author smccauliff
 *
 */
public class TypedRangeMergeTest {

    @Test
    public void intervalEquals() throws Exception {
        SimpleInterval si = new SimpleInterval(55, 55);
        TaggedInterval ti = new TaggedInterval(55,55,1);
        assertFalse(si.equals(ti));
        
        List<SimpleInterval> sia = new ArrayList<SimpleInterval>();
        sia.add(si);
        List<SimpleInterval> tia = new ArrayList<SimpleInterval>();
        tia.add(ti);
        assertFalse(sia.equals(tia));
        
    }
    
    @Test
    public void mergeSameTypeSubset() throws Exception {
        TaggedInterval tr1 = new TaggedInterval(0, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(1L, newRange.end());
    }
   
    @Test
    public void mergeSameTypeSuperSet() throws Exception {
        TaggedInterval tr1 = new TaggedInterval(0, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 2, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    @Test
    public void mergeSame() throws Exception {
        TaggedInterval tr1 = new TaggedInterval(0, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(1L, newRange.end());
    }
    
    @Test
    public void mergeSameTypeLeftEdge() {
        TaggedInterval tr1 = new TaggedInterval(1, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(1L, newRange.end());
    }
    
    @Test
    public void mergeSameTypeRightEdge() {
        TaggedInterval tr1 = new TaggedInterval(0, 0, 0);
        TaggedInterval tr2 = new TaggedInterval(1, 1, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(1L, newRange.end());
    }
    
    @Test
    public void mergeSameTypeRightDisjoint() {
        TaggedInterval tr1 = new TaggedInterval(0, 0, 0);
        TaggedInterval tr2 = new TaggedInterval(2, 2, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(2, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(0L, newRange.end());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    @Test
    public void mergeSameTypeLeftDisjoint() {
        TaggedInterval tr1 = new TaggedInterval(2, 2, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(2, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(0L, newRange.end());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    @Test
    public void mergeSameTypeRightOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(1, 2, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    @Test
    public void mergeSameTypeLeftOverlap() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 1, 0);
        
        List<Interval> intervals = tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L,newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    @Test
    public void mergeDifferentBreakInMiddle() {
        TaggedInterval tr1 = new TaggedInterval(0, 2, 0);
        TaggedInterval tr2 = new TaggedInterval(1, 1, 1);
        
        List<Interval> intervals =  tr1.merge(tr2).mergedIntervals();
        assertEquals(3, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        assertEquals(0L, newRange.tag());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end());
        assertEquals(1L, newRange.tag());
        newRange = (TaggedInterval) intervals.get(2);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
        assertEquals(0L, newRange.tag());
    }
    
    @Test
    public void mergeDifferentOverlapLeft() {
        TaggedInterval tr1 = new TaggedInterval(0, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 1);
        
        List<Interval> intervals =  tr1.merge(tr2).mergedIntervals();
        assertEquals(2, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        assertEquals(1L, newRange.tag());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end());     
        assertEquals(0L, newRange.tag());
    }
    
    @Test
    public void mergeDifferentOverlapRight() {
        TaggedInterval tr1 = new TaggedInterval(0, 1, 0);
        TaggedInterval tr2 = new TaggedInterval(1, 1, 1);
        
        List<Interval> intervals =  tr1.merge(tr2).mergedIntervals();
        assertEquals(2, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        assertEquals(0L, newRange.tag());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end());     
        assertEquals(1L, newRange.tag());
    }
    
    @Test
    public void mergeDifferentOverwrite() {
        TaggedInterval tr1 = new TaggedInterval(0, 0, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 1);
        
        List<Interval> intervals =  tr1.merge(tr2).mergedIntervals();
        assertEquals(1, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        assertEquals(1L, newRange.tag());
    }
    
    @Test
    public void mergeDifferentLeftDisjoint() {
        TaggedInterval tr1 = new TaggedInterval(2, 2, 0);
        TaggedInterval tr2 = new TaggedInterval(0, 0, 1);
        
        List<Interval> intervals =  tr1.merge(tr2).mergedIntervals();
        assertEquals(2, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        assertEquals(1L, newRange.tag());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
        assertEquals(0L, newRange.tag());
    }
    
    @Test
    public void mergeDifferentRightDisjoint() {
        TaggedInterval tr1 = new TaggedInterval(0, 0, 0);
        TaggedInterval tr2 = new TaggedInterval(2, 2, 1);
        
        List<Interval> intervals =  tr1.merge(tr2).mergedIntervals();
        assertEquals(2, intervals.size());
        TaggedInterval newRange = (TaggedInterval) intervals.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        assertEquals(0L, newRange.tag());
        newRange = (TaggedInterval) intervals.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
        assertEquals(1L, newRange.tag());
    }
}
