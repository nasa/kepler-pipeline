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

package gov.nasa.kepler.common.intervals;

import static org.junit.Assert.*;

import java.util.List;

import gov.nasa.spiffy.common.intervals.DoubleInterval.DoubleMergeResult;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class DoubleIntervalSetTest {

    @Test
    public void mergeSimpleDoubleInterval()  {
        SimpleDoubleInterval i1 = new SimpleDoubleInterval(1.0, 2.0);
        SimpleDoubleInterval i2 = new SimpleDoubleInterval(3.0, 4.0);
        
        //Merge before.
        DoubleMergeResult mergeResult = i2.merge(i1, 0.0);
        assertEquals(2, mergeResult.mergedIntervals().size());
        assertEquals(i1, mergeResult.mergedIntervals().get(0));
        assertEquals(i2, mergeResult.mergedIntervals().get(1));
        assertEquals(1, mergeResult.otherIndex());
        
        //Merge after
        mergeResult = i1.merge(i2, 0.0);
        assertEquals(2, mergeResult.mergedIntervals().size());
        assertEquals(i1, mergeResult.mergedIntervals().get(0));
        assertEquals(i2, mergeResult.mergedIntervals().get(1));
        assertEquals(0, mergeResult.otherIndex());
        
        //Merge overlap
        mergeResult = i2.merge(i1, 1.1);
        SimpleDoubleInterval expected = new SimpleDoubleInterval(i1.start(), i2.end());
        assertEquals(1, mergeResult.mergedIntervals().size());
        assertEquals(expected, mergeResult.mergedIntervals().get(0));
        assertEquals(0, mergeResult.otherIndex());
    }
    
    @Test
    public void mergeIntoEmptyDoubleIntervalSet()  {
        DoubleIntervalSet<SimpleDoubleInterval> iSet = 
            new DoubleIntervalSet<SimpleDoubleInterval>(0.0);
        iSet.mergeInterval(new SimpleDoubleInterval(7.0, 11.0));
        
        List<SimpleDoubleInterval> intervals = iSet.intervals();
        assertEquals(1, intervals.size());
        assertEquals(new SimpleDoubleInterval(7.0, 11.0), intervals.get(0));
    }
    
    @Test
    /**
     * 22222222222
     *               0000000000
     *                            11111111111
     */
    public void mergeBeforeAndAfterDoubleIntervalSet()  {
        DoubleIntervalSet<SimpleDoubleInterval> iSet = 
            new DoubleIntervalSet<SimpleDoubleInterval>(1.0);
        
        iSet.mergeInterval(new SimpleDoubleInterval(10.0, 20.0));
        iSet.mergeInterval(new SimpleDoubleInterval(30.0, 40.0));
        iSet.mergeInterval(new SimpleDoubleInterval(-10.0, 9.0));
        
        List<SimpleDoubleInterval> intervals = iSet.intervals();
        assertEquals(3, intervals.size());
        assertEquals(new SimpleDoubleInterval(-10.0, 9.0), intervals.get(0));
        assertEquals(new SimpleDoubleInterval(10.0, 20.0), intervals.get(1));
        assertEquals(new SimpleDoubleInterval(30.0, 40.0), intervals.get(2));
    }
    
    /**
     *      222222222222
     * 000000000   111111111111
     */
    @Test
    public void mergeOverlapDoubleIntervalSet() {
        DoubleIntervalSet<SimpleDoubleInterval> iSet = 
            new DoubleIntervalSet<SimpleDoubleInterval>(1.0);
        
        iSet.mergeInterval(new SimpleDoubleInterval(10.0, 20.0));
        iSet.mergeInterval(new SimpleDoubleInterval(30.0, 40.0));
        iSet.mergeInterval(new SimpleDoubleInterval(15.0, 35.0));
        
        List<SimpleDoubleInterval> intervals = iSet.intervals();
        assertEquals(1, intervals.size());
        assertEquals(new SimpleDoubleInterval(10.0, 40.0), intervals.get(0));
    }
    
    /**
     *      11111111111111111
     * 0000000000000000000000
     */
    @Test
    public void mergeSubset() {
        DoubleIntervalSet<SimpleDoubleInterval> iSet = 
            new DoubleIntervalSet<SimpleDoubleInterval>(1.0);
        
        iSet.mergeInterval(new SimpleDoubleInterval(10.0, 20.0));
        iSet.mergeInterval(new SimpleDoubleInterval(15.0, 20.0));
        
        List<SimpleDoubleInterval> intervals = iSet.intervals();
        assertEquals(1, intervals.size());
        assertEquals(new SimpleDoubleInterval(10.0, 20.0), intervals.get(0));
    }
    
    @Test
    public void fuzzyMergeBeforeAndAfter() {
        
        DoubleIntervalSet<SimpleDoubleInterval> iSet = 
            new DoubleIntervalSet<SimpleDoubleInterval>(10.001);
        
        iSet.mergeInterval(new SimpleDoubleInterval(10.0, 20.0));
        iSet.mergeInterval(new SimpleDoubleInterval(30.0, 40.0));
        iSet.mergeInterval(new SimpleDoubleInterval(-10.0, 9.0));
        
        List<SimpleDoubleInterval> intervals = iSet.intervals();
        assertEquals(1, intervals.size());
        assertEquals(new SimpleDoubleInterval(-10.0, 40.0), intervals.get(0));
    }
    
    
    /**
     * Query interval set with state:
     * 000000   111111
     */
    @Test
    public void doubleSpanningInterval() {
        DoubleIntervalSet<SimpleDoubleInterval> iSet =
            new DoubleIntervalSet<SimpleDoubleInterval>(0.1);
        iSet.mergeInterval(new SimpleDoubleInterval(10.0, 11.0));
        iSet.mergeInterval(new SimpleDoubleInterval(12.0, 13.0));
        
        List<SimpleDoubleInterval> spanned = 
            iSet.spannedIntervals(new SimpleDoubleInterval(10.5, 11.0), false);
        assertEquals(1, spanned.size());
        assertEquals(new SimpleDoubleInterval(10.0, 11.0), spanned.get(0));
        spanned = iSet.spannedIntervals(new SimpleDoubleInterval(12.5, 13.3));
        assertEquals(new SimpleDoubleInterval(12.0, 13.0), spanned.get(0));
        
        //Same tests, but clip ends.
        spanned = 
            iSet.spannedIntervals(new SimpleDoubleInterval(10.5, 11.0), true);
        assertEquals(1, spanned.size());
        assertEquals(new SimpleDoubleInterval(10.5, 11.0), spanned.get(0));
        spanned = iSet.spannedIntervals(new SimpleDoubleInterval(12.5, 13.3), true);
        assertEquals(new SimpleDoubleInterval(12.5, 13.0), spanned.get(0));
        
        //Get none.
        spanned = 
            iSet.spannedIntervals(new SimpleDoubleInterval(23432, 999999.0), true);
        assertEquals(0, spanned.size());
        
        //Get all
        spanned = 
            iSet.spannedIntervals(new SimpleDoubleInterval(10.5, 12.5), true);
        assertEquals(2, spanned.size());
        assertEquals(new SimpleDoubleInterval(10.5, 11.0), spanned.get(0));
        assertEquals(new SimpleDoubleInterval(12.0, 12.5), spanned.get(1));
    }
}
