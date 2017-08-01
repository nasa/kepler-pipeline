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

package gov.nasa.spiffy.common.intervals;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests that the IntervalSet class behaves correctly.
 * 
 * @author Sean McCauliff
 *
 */
public class IntervalSetTest {
    private TaggedInterval.Factory factory;
    private IntervalSet<TaggedInterval, TaggedInterval.Factory> rs;
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        factory = new TaggedInterval.Factory();
        rs =  new IntervalSet<TaggedInterval, TaggedInterval.Factory>(factory);
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
    }

    /**
     * <pre>
     *     nnnnnnnnnnnnnnnnnnnnnnnnnnnnn
     *            ooooo    ooooooo   ooooo
     *   </pre>
     */
    @Test
    public void insertUntypedMergeMany() {
        TaggedInterval tr1 = new TaggedInterval(1,1,0);
        TaggedInterval tr2 = new TaggedInterval(100,100,0);
        TaggedInterval tr3 = new TaggedInterval(110,120,0);
        TaggedInterval tr4 = new TaggedInterval(0,115, 0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        rs.mergeInterval(tr4);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(120L, newRange.end());
   
    }
 
    /**
     * <pre>
     *       nnn
     *    oooEND
     *    </pre>
     */
    @Test
    public void insertUntypedRangeAtEndMerge() {
        TaggedInterval tr1 = new TaggedInterval(0,0,0);
        TaggedInterval tr2 = new TaggedInterval(1,1,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(1L, newRange.end());
        
    }
    
    /**
     * <pre>
     *          nnn
     *    oooEND
     *    </pre>
     */
    @Test
    public void insertUntypedRangeAtEnd() {
        TaggedInterval tr1 = new TaggedInterval(0,0,0);
        TaggedInterval tr2 = new TaggedInterval(2,2,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        newRange = ranges.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    
    /**
     * <pre>
     *     nnn
     *   STARToooEND
     * </pre>
     */
    @Test
    public void insertUntypedRangeAtStartMerge() {
        TaggedInterval tr1 = new TaggedInterval(1,1,0);
        TaggedInterval tr2 = new TaggedInterval(0,0,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(1L, newRange.end());
    }
    
    /**
     *  <pre>
     *  nnnn
     *  START  oooo
     *  </pre>
     *
     */
    @Test
    public void insertUntypedRangeAtStart() {
        TaggedInterval tr1 = new TaggedInterval(2,2,0);
        TaggedInterval tr2 = new TaggedInterval(0,0,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end());
        newRange = ranges.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    /**
     *        <pre>
     *        nnnnn
     *        ooooo
     *        </pre>
     */
    @Test
    public void insertUntypedRangeEquals() {
        TaggedInterval tr1 = new TaggedInterval(1,11,0);
        TaggedInterval tr2 = new TaggedInterval(1,11,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(1L, newRange.start());
        assertEquals(11L, newRange.end());
    }
    
    /**
     *  <pre>
     *       nnnnn
     *   oooo          ooooo
     *   </pre>
     */
    @Test
    public void insertUntypedMergePreviousEdge() {
        TaggedInterval tr1 = new TaggedInterval(0,0,0);
        TaggedInterval tr2 = new TaggedInterval(100,100,0);
        TaggedInterval tr3 = new TaggedInterval(1,1,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(1L, newRange.end());
        newRange = ranges.get(1);
        assertEquals(100L, newRange.start());
        assertEquals(100L, newRange.end());
    }
    
    /**
     * <pre>
     *     nnnnnn
     *   oooo          ooooo
     *  </pre>
     */
    @Test
    public void insertUntypedMergePrevious() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(100,100,0);
        TaggedInterval tr3 = new TaggedInterval(1,2,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(2L, newRange.end());
        newRange = ranges.get(1);
        assertEquals(100L, newRange.start());
        assertEquals(100L, newRange.end());
    }
    
    
    /**
     * <pre>
     *     nnnnnnnnnnnn
     *   oooo          ooooo
     * </pre>
     */
    @Test
    public void insertUntypedMergePreviousMultiMerge() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(100,100,0);
        TaggedInterval tr3 = new TaggedInterval(1,99,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(100L, newRange.end());
   
    }
    
    /**
     * <pre>
     *     nnnnnnnnnnnnnn
     *   oooo          ooooo
     *  </pre>
     */
    @Test
    public void insertUntypedMergePreviousMulti() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(100,100,0);
        TaggedInterval tr3 = new TaggedInterval(1,100,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(100L, newRange.end());
   
    }
    

    /**
     * <pre>
     *       nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
     *   oo     oooo  ooooo ooooo ooo oo oooooooo oo oo    ooo
     * </pre>
     */
    @Test
    public void insertUntypedMultiMiddle() {
        for (int i=10; i < 100; i += 4) {
            TaggedInterval tr = new TaggedInterval(i, i + 2, 0);
            rs.mergeInterval(tr);
        }
        TaggedInterval atEnd = new TaggedInterval(200,200, 0);
        rs.mergeInterval(atEnd);
        TaggedInterval overlapRange = new TaggedInterval(0, 110, 0);
        rs.mergeInterval(overlapRange);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(110L, newRange.end());
        newRange = ranges.get(1);
        assertEquals(200L, newRange.start());
        assertEquals(200L, newRange.end());
    }
    
    /**
     * <pre>
     *       nnnnnn
     *    ooooooooooo
     *  </pre>
     */
    @Test
    public void insertUntypedSubSet() {
        TaggedInterval tr1 = new TaggedInterval(0,2,0);
        TaggedInterval tr2 = new TaggedInterval(1,1,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    /**
     * <pre>
     *       nnnnnn
     *        oooo
     *   </pre>
     */
    @Test
    public void insertUntypedSuperSet() {
        TaggedInterval tr1 = new TaggedInterval(1,1,0);
        TaggedInterval tr2 = new TaggedInterval(0,2,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(2L, newRange.end());
    }
    
    /**
     * <pre>
     *       nnnnnn
     *        oooo
     *   </pre>
     */
    @Test
    public void insertTypedSuperSet() {
        TaggedInterval tr1 = new TaggedInterval(1,1,0);
        TaggedInterval tr2 = new TaggedInterval(0,2,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(1, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(2L, newRange.end());
        assertEquals(1L, newRange.tag());
    }
    
    /**
     * <pre>
     *      nnnnnn
     *    ooooooooo
     *  </pre>
     */
    @Test
    public void insertTypedSubSet() {
        TaggedInterval tr1 = new TaggedInterval(0,2,0);
        TaggedInterval tr2 = new TaggedInterval(1,1,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(3, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(0L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end()); 
        assertEquals(1L, newRange.tag());
        newRange = ranges.get(2);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end()); 
        assertEquals(0L, newRange.tag());
    }
    
    /**
     * <pre>
     *      nnnnnn
     *  oooo
     *  </pre>
     */
    @Test
    public void insertTypedLeftNoMerge() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(2,2,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(1L, newRange.end()); 
        assertEquals(0L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end()); 
        assertEquals(1L, newRange.tag());
    }
    
    /**
     * <pre>
     *      nnnnnn
     *            oooooo
     *  </pre>
     */
    @Test
    public void insertTypedRightNoMerge() {
        TaggedInterval tr1 = new TaggedInterval(1,1,0);
        TaggedInterval tr2 = new TaggedInterval(0,0,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(1L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end()); 
        assertEquals(0L, newRange.tag());
    }
    
    /**
     * <pre>
     *      nnnnnn
     *    oooooo
     *  </pre>
     */
    @Test
    public void insertTypedLeftOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(1,1,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(0L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end()); 
        assertEquals(1L, newRange.tag());
    }
    
    /**
     *  <pre>
     *      nnnnnn
     *         oooooo
     *   </pre>
     */
    @Test
    public void insertTypedRightOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(0,0,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(2, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(1L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end()); 
        assertEquals(0L, newRange.tag());
    }
    
    /**
     * <pre>
     *       nnnnnn
     *   oooo      ooooo
     *  </pre>
     */
    @Test
    public void insertTypedMiddleNoMerge() {
        TaggedInterval tr1 = new TaggedInterval(0,0,0);
        TaggedInterval tr2 = new TaggedInterval(2,2,1);
        TaggedInterval tr3 = new TaggedInterval(1,1,2);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(3, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(0L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(1L, newRange.end()); 
        assertEquals(2L, newRange.tag());
        newRange = ranges.get(2);
        assertEquals(2L, newRange.start());
        assertEquals(2L, newRange.end()); 
        assertEquals(1L, newRange.tag());
    }
    
    /**
     * <pre>
     *     nnnnnnnnnn
     *   oooo      ooooo
     *  </pre>
     */
    @Test
    public void insertTypedMultiBreak() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(2,3,1);
        TaggedInterval tr3 = new TaggedInterval(1,2,2);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(3, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(0L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(2L, newRange.end()); 
        assertEquals(2L, newRange.tag());
        newRange = ranges.get(2);
        assertEquals(3L, newRange.start());
        assertEquals(3L, newRange.end()); 
        assertEquals(1L, newRange.tag());
    }
    
    /**
     * <pre>
     *     nnnnnnnnnnnnnnnnnnn
     *   oooo      ooooo   ooooo
     *  </pre>
     */
    @Test
    public void insertTypedMultiOverwriteBreak() {
        TaggedInterval tr1 = new TaggedInterval(0,1,0);
        TaggedInterval tr2 = new TaggedInterval(2,2,1);
        TaggedInterval tr3 = new TaggedInterval(3,4,2);
        TaggedInterval tr4 = new TaggedInterval(1,3,3);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        rs.mergeInterval(tr4);
        
        List<TaggedInterval> ranges = rs.intervals();
        assertEquals(3, ranges.size());
        TaggedInterval newRange = ranges.get(0);
        assertEquals(0L, newRange.start());
        assertEquals(0L, newRange.end()); 
        assertEquals(0L, newRange.tag());
        newRange = ranges.get(1);
        assertEquals(1L, newRange.start());
        assertEquals(3L, newRange.end()); 
        assertEquals(3L, newRange.tag());
        newRange = ranges.get(2);
        assertEquals(4L, newRange.start());
        assertEquals(4L, newRange.end()); 
        assertEquals(2L, newRange.tag());
    }
    
    /**
     * 
     */
    @Test
    public void subsetInRange() {
        TaggedInterval tr1 = new TaggedInterval(0, 2, 0);
        TaggedInterval q = new TaggedInterval(1,1,0);
        
        rs.mergeInterval(tr1);
        assertTrue("Should be in IntervalSet.", rs.inIntervalSet(q));
        
    }
    
    @Test
    public void edgeInRange() {
        TaggedInterval tr1 = new TaggedInterval(0, 2, 0);
        TaggedInterval q = new TaggedInterval(0,2,0);
        rs.mergeInterval(tr1);
        assertTrue("Should be in IntervalSet.", rs.inIntervalSet(q));
    }
    
    @Test
    public void leftSidePartiallyInRange() {
        TaggedInterval tr1 = new TaggedInterval(0, 2, 0);
        TaggedInterval q = new TaggedInterval(2,3,0);
        rs.mergeInterval(tr1);
        assertFalse("Should NOT be in IntervalSet.", rs.inIntervalSet(q));
    }
    
    @Test
    public void rightSidePartiallyInRange() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval q = new TaggedInterval(0,1,0);
        rs.mergeInterval(tr1);
        assertFalse("Should NOT be in IntervalSet.", rs.inIntervalSet(q));
    }
    
    @Test
    public void completelyNotInRange() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval q = new TaggedInterval(100,100,0);
        rs.mergeInterval(tr1);
        assertFalse("Should NOT be in IntervalSet.", rs.inIntervalSet(q));
    }
    
    @Test
    public void inDifferentRanges() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval q = new TaggedInterval(1,10,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        assertFalse("Should NOT be in IntervalSet.", rs.inIntervalSet(q));
    }
    
    @Test
    public void readWriteUntypedRanges()  throws IOException {
        List<TaggedInterval> testList = new ArrayList<TaggedInterval>();
        for (int i=10; i < 100; i += 4) {
            TaggedInterval tr = new TaggedInterval(i, i + 2, 0);
            rs.mergeInterval(tr);
            testList.add(tr);
        }
        
        ByteArrayOutputStream bos = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(bos);
        rs.writeTo(dos);
        dos.close();
        byte[] bytes = bos.toByteArray();
        ByteArrayInputStream bin = new ByteArrayInputStream(bytes);
        DataInputStream din = new DataInputStream(bin);
        IntervalSet<TaggedInterval, TaggedInterval.Factory> newSet = 
            new IntervalSet<TaggedInterval, TaggedInterval.Factory>(factory);
        newSet.readFrom(din);
        List<TaggedInterval> newRanges = newSet.intervals();
        assertTrue("Serialized lists must be the same." , testList.equals(newRanges));
        
    }
    
    /**
     * <pre>
     *        ssss
     *    ttt          ttt
     *  </pre>
     */
    @Test
    public void spanHole() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(3,9,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval);
        assertEquals(0, spanned.size());
    }
    
    /**
     * <pre>
     *  ssssssss
     *            tttttttt
     * </pre>
     */
    @Test
    public void spanPrefix() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(0,0,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval);
        assertEquals(0, spanned.size());
    }
     
    /**
     * <pre>
     *              ssssss
     *    tttttttt
     *  </pre>
     */
    @Test
    public void spanSuffix() {
           TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(11,20,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
    
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval);
        assertEquals(0, spanned.size());
    }
    
    /**
     *  <pre>
     *       ssssssssssssssssssss
     *          ttttt tttt tttt
     *   </pre>
     */
    @Test
    public void spanSuperSet() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr3 = new TaggedInterval(4,4, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(0,20,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
    
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval);
        assertEquals(3, spanned.size());
    }
    
    /**
     *   <pre>
     *       sssss
     *     ttttttttt
     *   </pre>
     */
    @Test
    public void spanSubSet() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
          TaggedInterval tr3 = new TaggedInterval(4,6, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(5,5,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
    
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval);
        assertEquals(1, spanned.size());
    }
    
    /**
     *  <pre>
     *        ssssssss
     *    ttt          ttt
     *  </pre>
     */
    @Test
    public void clippedSpanHole() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(3,9,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval, true);
        assertEquals(0, spanned.size());
    }
    
    /**
     * <pre>
     *  ssssssss
     *            tttttttt
     *  </pre>
     */
    @Test
    public void clippedSpanPrefix() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(0,0,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval, true);
        assertEquals(0, spanned.size());
    }
     
    /**
     * <pre>
     *              ssssss
     *    tttttttt
     *  </pre>
     */
    @Test
    public void clippedSpanSuffix() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(11,20,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
    
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval, true);
        assertEquals(0, spanned.size());
    }
    
    /**
     * <pre>
     *       ssssssssssssssssssss
     *          ttttt tttt tttt
     *  </pre>
     */
    @Test
    public void clipSpanSuperSet() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr3 = new TaggedInterval(4,4, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(0,20,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
    
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval, true);
        assertEquals(3, spanned.size());
        assertEquals(1L, spanned.get(0).start());
        assertEquals(10L, spanned.get( spanned.size() -1).end());
    }
    
    /**
     * <pre>
     *       sssss
     *     ttttttttt
     *  </pre>
     */
    @Test
    public void clipSpanSubSet() {
        TaggedInterval tr1 = new TaggedInterval(1,2, 0);
        TaggedInterval tr3 = new TaggedInterval(4,6, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(5,5,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
    
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval, true);
        assertEquals(1, spanned.size());
        assertEquals(5L, spanned.get(0).end());
        assertEquals(5L, spanned.get(0).start());
    }
    
    /**
     * <pre>
     *      sssssssssssssss
     *    ttt             ttt
     *  </pre>
     */
    @Test
    public void clipSpanDisjoint() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval tr2 = new TaggedInterval( 10,10, 0);
        TaggedInterval spanningInterval = new TaggedInterval(2,10,0);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        List<TaggedInterval> spanned = rs.spannedIntervals(spanningInterval, true);
        assertEquals(2, spanned.size());
        assertEquals(2L, spanned.get(0).start());
        assertEquals(10L, spanned.get(spanned.size()-1).end());
    }
  
    @Test
    public void deleteNothing() {
        TaggedInterval deleteMe = new TaggedInterval(4,11, -1);
        
        rs.deleteInterval(deleteMe);
        assertEquals(0, rs.intervals().size());
        
    }
    
    /** 
     * <pre>
     *                 ssssss
     *      ttttttttt              ttttttttt
     *  </pre>
     */
    @Test
    public void deleteHole() {
        TaggedInterval tr1 = new TaggedInterval(1,2,0);
        TaggedInterval tr2 = new TaggedInterval(10,10,1);
        TaggedInterval deleteMe = new TaggedInterval(3,9,1);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        assertEquals(2, intervals.size());
        assertEquals(tr1, intervals.get(0));
        assertEquals(tr2, intervals.get(1));
    }
    
    /**
     * <pre>
     * 
     * ssss
     *          tttttttttt
     *          
     * </pre>
     */
    @Test
    public void deleteBefore() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval deleteMe = new TaggedInterval(0,0,0);
        rs.mergeInterval(tr1);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(1, intervals.size());
        assertEquals(tr1, intervals.get(0));
    
    }
    
    /**
     * <pre>
     *                     sssss
     *    tttttttttt
     *    
     *  </pre>
     */
    @Test
    public void deleteAfter() {
        TaggedInterval tr1 = new TaggedInterval(1, 2, 0);
        TaggedInterval deleteMe = new TaggedInterval(3,4,0);
        rs.mergeInterval(tr1);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(1, intervals.size());
        assertEquals(tr1, intervals.get(0));
    }
    
    /**
     * <pre>
     *     sssss
     *tt  ttttttttttttttttt tt
     *</pre>
     */
    @Test
    public void deleteBreakMiddle() {
        TaggedInterval tr1 = new TaggedInterval(1,3,0);
        TaggedInterval tr2 = new TaggedInterval(4,6, 1);
        TaggedInterval tr3 = new TaggedInterval(7,8, 2);
        TaggedInterval deleteMe = new TaggedInterval(5,5,5);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        assertEquals(3, rs.intervals().size());
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(4, intervals.size());
        assertEquals(tr1, intervals.get(0));
        assertEquals(4L, intervals.get(1).start());
        assertEquals(4L, intervals.get(1).end());
        assertEquals(1L, intervals.get(2).tag());
        assertEquals(6L, intervals.get(2).start());
        assertEquals(6L, intervals.get(2).end());
        assertEquals(1L, intervals.get(2).tag());
        assertEquals(tr3, intervals.get(3));
    }
    
    /**
     * <pre>
     *     sss
     * ttt ttttttt tt
     * 
     * </pre>
     */
    @Test
    public void deleteBreakLeftMiddle() {
        TaggedInterval tr1 = new TaggedInterval(1,3,0);
        TaggedInterval tr2 = new TaggedInterval(4,6, 1);
        TaggedInterval tr3 = new TaggedInterval(7,8, 2);
        TaggedInterval deleteMe = new TaggedInterval(4,5,5);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        assertEquals(3, intervals.size());
        assertEquals(tr1, intervals.get(0));
        assertEquals(tr3, intervals.get(2));
        assertEquals(6L, intervals.get(1).start());
        assertEquals(6L,  intervals.get(1).end());
        assertEquals(1L, intervals.get(1).tag());
    }
    
    /**
     * <pre>
     *        sss
     * tttt tttttttt ttt
     * </pre>
     */
    @Test
    public void deleteBreakRightMiddle() {
        TaggedInterval tr1 = new TaggedInterval(1,3,0);
        TaggedInterval tr2 = new TaggedInterval(4,6, 1);
        TaggedInterval tr3 = new TaggedInterval(7,8, 2);
        TaggedInterval deleteMe = new TaggedInterval(5,6,5);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(3, intervals.size());
        assertEquals(tr1, intervals.get(0));
        assertEquals(tr3, intervals.get(2));
        assertEquals(4L, intervals.get(1).start());
        assertEquals(4L, intervals.get(1).end());

    }
    
    /**
     * <pre>
     *      xxxxx
     * yy yyyyy yyy
     * </pre>
     * 
     */
    @Test
    public void deleteExactOverlap() {
        TaggedInterval tr1 = new TaggedInterval(1,3,0);
        TaggedInterval tr2 = new TaggedInterval(4,6, 1);
        TaggedInterval tr3 = new TaggedInterval(7,8, 2);
        TaggedInterval deleteMe = new TaggedInterval(4,6,5);
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(2, intervals.size());
        assertEquals(tr1, intervals.get(0));
        assertEquals(tr3, intervals.get(1));
    }
    
    /**
     * <pre>
     *      xxxxxx
     *   yyyy        yyyy 
     *  </pre>
     */
    @Test
    public void deleteLeftOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0,1,1);
        TaggedInterval tr2 = new TaggedInterval(3,3,3);
        TaggedInterval deleteMe = new TaggedInterval(1,2,2);
        
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        assertEquals(2, intervals.size());
        assertEquals(0L, intervals.get(0).start());
        assertEquals(0L, intervals.get(0).end());
        assertEquals(tr2, intervals.get(1));
    }
    
    /**
     * <pre>
     *      xxxxxx
     * yy        yyyyyy
     * </pre>
     */
    @Test
    public void deleteRightOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0,1,1);
        TaggedInterval tr2 = new TaggedInterval(3,4,3);
        TaggedInterval deleteMe = new TaggedInterval(2,3,2);
        
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        assertEquals(2, intervals.size());
        assertEquals(tr1, intervals.get(0));
        assertEquals(4L, intervals.get(1).start());
        assertEquals(4L, intervals.get(1).end());
        assertEquals(3L, intervals.get(1).tag());
    }
    
    /**
     * <pre>
     *     xxxxxx
     *     yy         yyyy
     *  </pre>
     */
    @Test
    public void deleteCompleteLeftOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0,1,1);
        TaggedInterval tr2 = new TaggedInterval(3,4,3);
        TaggedInterval deleteMe = new TaggedInterval(0,2,2);
        
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(1, intervals.size());
        assertEquals(tr2, intervals.get(0));
    }
    
    /**
     * <pre>
     *          33333
     * 1111122222
     * </pre>
     */
    @Test
    public void deleteMultiple()  {
        TaggedInterval tr1 = new TaggedInterval(4,7, 1);
        TaggedInterval tr2 = new TaggedInterval(8,11, 2);
        TaggedInterval deleteMe = new TaggedInterval(4,11, -1);
        
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        rs.deleteInterval(deleteMe);
        
        assertEquals(0, rs.intervals().size());
        
    }
    
    /**
     * <pre>
     *           xxxxx
     * yyy        yyy
     * 
     * </pre>
     */
    @Test
    public void completeCompleteRightOverlap() {
        TaggedInterval tr1 = new TaggedInterval(0,1,1);
        TaggedInterval tr2 = new TaggedInterval(3,4,3);
        TaggedInterval deleteMe = new TaggedInterval(2,4,2);
        
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        
        assertEquals(1, intervals.size());
        assertEquals(tr1, intervals.get(0));
    }
    
    /**
     * <pre>
     *         xxxxxxxxxxxxx
     *     yyyy yyyyyy yyyyyyy
     *  </pre>
     */
    @Test
    public void deleteCompleteSpan() {
        TaggedInterval tr1 = new TaggedInterval(0,9,1);
        TaggedInterval tr2 = new TaggedInterval(10,19, 11);
        TaggedInterval tr3 = new TaggedInterval(20,29,3);

        TaggedInterval deleteMe = new TaggedInterval(1,28,2);
        
        rs.mergeInterval(tr1);
        rs.mergeInterval(tr2);
        rs.mergeInterval(tr3);
        
        rs.deleteInterval(deleteMe);
        List<TaggedInterval> intervals = rs.intervals();
        assertEquals(2, intervals.size());
        assertEquals(0L, intervals.get(0).start());
        assertEquals(0L, intervals.get(0).end());
        assertEquals(1L, intervals.get(0).tag());
        assertEquals(29L, intervals.get(1).start());
        assertEquals(29L, intervals.get(1).end());
        assertEquals(3L, intervals.get(1).tag());
    }
    
    /**
     * <pre>
     *   xxxxxxxxxxxxxxxxxxxxxxxxx
     *        yyyyyyyyyyyyyyyyyyy
     *  </pre>
     */
    @Test
    public void deleteCompleteOverlap() {
        TaggedInterval tr1 = new TaggedInterval(5,50,1);
        TaggedInterval deleteMe = new TaggedInterval(0,51,2);
        
        rs.mergeInterval(tr1);
        
        rs.deleteInterval(deleteMe);
        
        List<TaggedInterval> intervals = rs.intervals();
        assertEquals(0, intervals.size());
    }
    
    /**
     * <pre>
     *       22
     *      000011
     *  </pre>
     */
    @Test
    public void ksoc4524() {
//       These are the original intervals inserted causing an unordered list.
//                start=369190,end=375189,tag=15436
//                start=375190,end=375879,tag=15449
//                start=375880,end=377129,tag=25510
//                start=377130,end=381189,tag=15449
//                start=372130,end=373379,tag=100000 (not exactly the correct number)
        TaggedInterval ti0 = new TaggedInterval(0, 3, 0);
        TaggedInterval ti1 = new TaggedInterval(4, 5, 1);
        TaggedInterval newInterval = new TaggedInterval(1, 1, 2);
        rs.mergeInterval(ti0);
        rs.mergeInterval(ti1);

        rs.mergeInterval(newInterval);

        assertEquals(4, rs.intervals().size());
        assertEquals(new TaggedInterval(0, 0, 0), rs.intervals().get(0));
        assertEquals(new TaggedInterval(1, 1, 2), rs.intervals().get(1));
        assertEquals(new TaggedInterval(2, 3, 0), rs.intervals().get(2));
        assertEquals(new TaggedInterval(4, 5, 1), rs.intervals().get(3));
    }
}
