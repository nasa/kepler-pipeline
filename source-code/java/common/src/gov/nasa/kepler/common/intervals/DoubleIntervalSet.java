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

import gov.nasa.spiffy.common.collect.RemovableArrayList;
import gov.nasa.spiffy.common.intervals.DoubleInterval;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.IntervalUtils;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 *  A class for the manipulation of non-overlapping intervals of values.  See
 *  {@link IntervalSet} for other notes.  Unlike the IntervalSet this does not
 *  have any support for storing the interval set persistently.  This class is
 *  not MT-safe.
 *  
 * @author Sean McCauliff
 *
 */
public class DoubleIntervalSet<I extends DoubleInterval> {

    private final List<I> intervals;
    private final double delta;
    
    /**
     * 
     * @param delta  Differences smaller than delta between interval boundries
     * are considered to be negligible. 
     */
    public DoubleIntervalSet(double delta) {
        if (delta < 0.0) {
            throw new IllegalArgumentException("Invalid delta " + delta
                + ".  Must be greater than or equal to zero.");
        }
        intervals = new RemovableArrayList<I>();
        this.delta = delta;
    }
    /**
     * Get all the intervals known to this DoubleIntervalSet.
     * 
     * @return an unmodifiable list.
     */
    public List<I> intervals() {
        if (intervals.size() == 0) return Collections.emptyList();
        List<I> rv = new ArrayList<I>();
        rv.addAll(intervals);
        return Collections.unmodifiableList(rv);
    }
    
    /**
     * Check if a Interval is in the IntervalSet
     * 
     * @param queryinterval The Interval to ask about.
     * @return true if this Interval is contained in the IntervalSet.
     */
    public boolean inIntervalSet(I queryinterval) {
        OverlapIntervalComparator comp = new OverlapIntervalComparator();
        int insertPoint = Collections.binarySearch(intervals, queryinterval, comp);
        if (insertPoint < 0) return false;
        I intervalInList = intervals.get(insertPoint);
        return Math.abs(queryinterval.end() - intervalInList.end()) < delta && 
               Math.abs(queryinterval.start() - intervalInList.start()) < delta;
    }
    
    public void mergeInterval(I newInterval) {
        
        // Base case. No existing intervals.
        if (intervals.size() == 0) {
            intervals.add(newInterval);
            return;
        }
        
        Comparator<I> comp = new StartIntervalComparator();
        int insertIndex = Collections.binarySearch(intervals, newInterval, comp);
        
        if (insertIndex >=0 ) {
            //Found exact match.
            mergeIntervalsAt(insertIndex, newInterval);
        } else {
            //See the documentation for Collections.binarySearch for
            //how this index is computed.
            mergeIntervalsAt( (-insertIndex) - 1, newInterval);
        }
        
    }
    
    public List<I> spannedIntervals(I spanningInterval) {
        return spannedIntervals(spanningInterval, false);
    }
    
    /**
     * @param spanningInterval An interval that may overlap with some, none
     * or all intervals within this set.
     * @param clip When true the return values are clipped to the start and
     * end values of the spanningInterval
     * @return All the intervals that overlap within the specified
     * spanning interval.  This returns the empty list if there are none.
     */
    @SuppressWarnings("unchecked")
    public List<I> spannedIntervals(I spanningInterval, boolean clip) {
        StartIntervalComparator scomp =  new StartIntervalComparator();

        int startPoint = Collections.binarySearch(intervals, 
                spanningInterval, scomp);
        if (startPoint < 0) {
            startPoint = (-startPoint) - 1;
        }
        //The index before the current start point may be covered by
        //the spanning interval.
        if (startPoint != 0) {
            if (intervals.get(startPoint - 1).end() >= spanningInterval.start()) {
                startPoint--;
            }
        }
        
        if (startPoint >= intervals.size()) return Collections.emptyList();
        
        EndIntervalComparator ecomp = new EndIntervalComparator();

        int endPoint = Collections.binarySearch(intervals, 
                spanningInterval, ecomp);
  
        if (endPoint < 0) {
            endPoint = (-endPoint) - 1;
        } 
        
        //If the end point is sitting inside an interval make the end point
        //one greater than that interval, since List.subList() required that
        //the end index is one greater than the end of the List
        if (endPoint < intervals.size() ) {
            I last = intervals.get(endPoint);
            if (!(spanningInterval.end() < last.start())) {
                endPoint++;
            }
        }


        if (endPoint == 0) {
            //Spanning interval is before all intervals; it covers nothing.
            return Collections.emptyList();
        }
        if (!clip) {
            // subList() is from inclusive index, exclusive index
            return Collections.unmodifiableList(intervals.subList(startPoint, endPoint));
        } else {
            //Modify the first and last intervals so they start and end at 
            //the spanning intervals start and end points if they would
            //extend beyond them.
            int listSize = endPoint - startPoint; //no +1 needed here
            List<I> rv = new ArrayList<I>(listSize);
            for (int i=startPoint; i < endPoint; i++) {
                rv.add(intervals.get(i));
            }
            if (rv.size() == 0) return rv;
            I firstInterval = rv.get(0);
            double clipedStart = Math.max(firstInterval.start(), spanningInterval.start());
            firstInterval = (I) firstInterval.clone(clipedStart, firstInterval.end());
            rv.set(0, firstInterval);
            I lastInterval = rv.get(rv.size() - 1);
            double clipedEnd = Math.min(lastInterval.end(), spanningInterval.end());
            lastInterval = (I) lastInterval.clone(lastInterval.start(), clipedEnd);
            rv.set(rv.size() - 1, lastInterval);
           
            return rv;
        }
    }
    
    /**
     * Merges the new interval at the specified index.
     * 
     * @param insertIndex At this index.  It should be the index before the
     * first item that it needs to be inserted into.  Or equal to the one it
     * replaces.
     * @param newinterval The interval to merge into existing intervals.
     */
    @SuppressWarnings("unchecked")
    private void mergeIntervalsAt(int insertIndex, I newInterval) {
        //Base case, insert at end.
        if (insertIndex == intervals.size()) {
            DoubleInterval.DoubleMergeResult result =
                intervals.get(insertIndex -1).merge(newInterval, delta);
            intervals.remove(insertIndex - 1);
            insertintervalsAt(insertIndex - 1, result, true);
            assert IntervalUtils.checkOverlap(intervals, delta);
            return;
        } 
        
        //     nnnnnnnnnn
        //     oooooooooo
        I current = intervals.get(insertIndex);
        if (isSame(current.end(), newInterval.end()) &&
            isSame(current.start(),newInterval.start())) {
            DoubleInterval.DoubleMergeResult result = 
                intervals.get(insertIndex).merge(newInterval, delta);
            intervals.remove(insertIndex);
            insertintervalsAt(insertIndex, result, true);
            assert IntervalUtils.checkOverlap(intervals, delta);
            return;
        }
        
        if (insertIndex != 0) {
            I prev = intervals.get(insertIndex - 1);
            if (isGreater(prev.end(), newInterval.start()) || 
                isSame(prev.end(), newInterval.start())) {
                //          nnnnnnnnn
                //oooooooooo
                
                //         nnnnnnnnnn
                //      oooooo
                
                //     nnnnnnnnnnnn
                // oooooooooo ooooooooo
                
                //merge with the previous interval.
                DoubleInterval.DoubleMergeResult mergeResult = 
                    intervals.get(insertIndex-1).merge(newInterval, delta);
                intervals.remove(insertIndex - 1);
                insertintervalsAt(insertIndex -1, mergeResult, false);
                newInterval = (I) mergeResult.mergedIntervals().get(mergeResult.otherIndex());
                insertIndex = insertIndex - 1 + mergeResult.otherIndex();
            }
        }
        
        boolean inserted = true;
        while (insertIndex < intervals.size()) {
            current = intervals.get(insertIndex);
            
            if (isGreater(current.start(), newInterval.end())) {
                //            nnnnnnnnnnnn
                //  oooooo                    ooooo
                intervals.add(insertIndex, newInterval);
                inserted = true;
                break;
            }
            
            //nnnnnnnnnn
            //          ooooooooo
            if (isSame(current.start(), newInterval.end())) {
                DoubleInterval.DoubleMergeResult result = 
                    intervals.get(insertIndex).merge(newInterval, delta);
                intervals.remove(insertIndex);
                insertintervalsAt(insertIndex, result, true);
                inserted = true;
                break;
            }
          
            //         nnnnnn
            //    oooooooooooooo
            if (isLessThanOrSame(current.start(), newInterval.start()) &&
                isGreaterThanOrSame(current.end(),newInterval.end())) {
                DoubleInterval.DoubleMergeResult result = 
                    intervals.get(insertIndex).merge(newInterval, delta);
                intervals.remove(insertIndex);
                insertintervalsAt(insertIndex, result, true);
                inserted = true;
                break;
            }
        
            //     nnnnnnnnn
            //           ooooooooo
            
            
            //  nnnnnnnnnnnnnnnnnnn
            //    oooooo    ooooo
            DoubleInterval.DoubleMergeResult mergeResult = 
                intervals.get(insertIndex).merge(newInterval, delta);
            intervals.remove(insertIndex);
            if (mergeResult.mergedIntervals().size() - 1 != mergeResult.otherIndex()) {
                //Merging resulted in a new interval which is greater than
                //the new interval and non-contiguous.
                insertintervalsAt(insertIndex, mergeResult, true);
                inserted = true;
                break;
            } else {
                //More intervals to merge?
                newInterval = (I) mergeResult.mergedIntervals().get(mergeResult.otherIndex());
                insertintervalsAt(insertIndex, mergeResult, false);
                inserted = false;
            }
                
        }
        
        if (!inserted) {
            intervals.add(insertIndex, newInterval);
        }
        assert IntervalUtils.checkOverlap(intervals, delta);
    }
    
    private void insertintervalsAt( int insertIndex, 
        DoubleInterval.DoubleMergeResult result, 
        boolean insertNewinterval) {

        @SuppressWarnings("unchecked")
        List<I> mergedintervals = (List<I>) result.mergedIntervals();
        for (int i=0; i < mergedintervals.size(); i++) {
            if (!insertNewinterval && i == result.otherIndex()) continue;
            intervals.add(insertIndex + i, mergedintervals.get(i));
        }
    }
    
    /**
     * 
     * @param a
     * @param b
     * @return  true if a and b differ by less than delta.
     */
    private boolean isSame(double a, double b) {
        return Math.abs(a - b) < delta;
    }
    
    /**
     * 
     * @param a
     * @param b
     * @return  true if a is greater than b and a and b differ by more
     * than or equal to delta.
     */
    private boolean isGreater(double a, double b) {
        double diff = a - b;
        return diff > 0 && diff >= delta;
    }
    
    private boolean isLessThanOrSame(double a, double b) {
        double diff = a - b;
        if (Math.abs(diff) < delta) {
            return true;
        }
        return diff < 0;
    }
    
    private boolean isGreaterThanOrSame(double a, double b) {
        double diff = a - b;
        if (Math.abs(diff) < delta) {
            return true;
        }
        return diff > 0;
    }
    
    private class StartIntervalComparator implements Comparator<I> {
        
        /** o1.start() < o2.start() orders by the start of the interval.
         * 
         */
        public int compare(I r1, I r2) {
            if (r1.equals(r2)) return 0;

            
            double diff = r1.start() - r2.start();
            if (Math.abs(diff) < delta) return 0;
            if (diff < 0) return -1;
            return 1;
        }
    }
    
    private class EndIntervalComparator implements Comparator<I> {

        /**
         * o1.end() < o2.end()
         */
        public int compare(I r1, I r2) {
            if (r1.equals(r2)) return 0;
 
            
            double diff = r1.end() - r2.end();
            if (Math.abs(diff) < delta) return 0;
            if (diff < 0) return -1;
            return 1;
        }
        
    }
    
    private class OverlapIntervalComparator implements Comparator<I> {
        
        /**
         * Check if an interval overlaps this interval.
         * 
         * @param s Start cadence, inclusive.
         * @param e End cadence, inclusive.
         * @return -1 if r1 is less than r2, 0 if they overlap , 2 if it is
         * greater than this interval and 0 contained or are equal.
         */
        public int compare(I r1, I r2) {
            if (r1.equals(r2)) return 0;
            //r1 before r2
            if ((r2.start() - r1.end()) >= delta) return -1;
            //r2 before r1
            if ((r1.start() - r2.end()) >= delta) return 2;
            //overlapping
            return 0;
        }
    }
    
    
}
