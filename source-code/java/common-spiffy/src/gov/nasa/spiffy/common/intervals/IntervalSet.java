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

import gov.nasa.spiffy.common.collect.RemovableArrayList;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * A class for the manipulation of non-overlapping intervals of values.
 * 
 * This implementation uses a sorted list to store intervals. This gives the * following performance:
 * 
 * 
 * <pre>
 *    save / load : O(n)
 *    insert : O(n)
 *    query :  O(ln n)
 *  </pre>
 * 
 * 
 * A TreeSet could be used to store intervals, this would yield:
 * 
 * <pre>
 *    save/load : O( n)
 *    insert : O(n)
 *    query :  O(ln n)
 *   </pre>
 * 
 * The save / load operation would be much worse than any other operation in the
 * array implementation. If a tree based implementation could be constructed
 * that could read in a pre-sorted data structure in O(n) time then it would be
 * worth moving over to that.
 * 
 * This class is not MT-safe.
 * 
 * @author Sean McCauliff
 * 
 */
public class IntervalSet<I extends Interval, F extends IntervalFactory<I> > {
    
    private final F factory;
    //Changing this to a LinkedList will give very different performance
    //with  Collections.binarySearch().
    private List<I> intervals;
    
    /** Constructs a new empty interval set */
    public IntervalSet(F factory) {
        if (factory == null) {
            throw new NullPointerException("Factory must not be null.");
        }
        this.factory = factory;

        intervals = Collections.EMPTY_LIST;
    }
    
    /**
     * Creates a new set from a presorted collection of intervals.
     * 
     * @param factory
     * @param init A presorted collection of intervals.
     */
    public IntervalSet(F factory, Collection<I> init) {
        if (factory == null) {
            throw new NullPointerException("Factory must not be null.");
        }
        this.factory = factory;
        intervals = factory.cachedList(new ArrayList<I>(init));
        assert IntervalUtils.checkOverlap(intervals);
    }
    
    /**
     * Copy constructor.
     * @param init
     */
    public IntervalSet(IntervalSet<I,F> init) {
        this.factory = init.factory;
        this.intervals = factory.cachedList(new ArrayList<I>(init.intervals));
    }
    
    public void readFrom(DataInput din) throws IOException {
        ArrayList<I> readInto =  new ArrayList<I>(2);
        final int nitems = din.readInt();
        I prevInterval = null;
        for (int i=0; i < nitems; i++) {
            I interval = factory.readInterval(prevInterval, din);
            readInto.add(interval);
            prevInterval = interval;
        }
        intervals = factory.cachedList(readInto);
        assert IntervalUtils.checkOverlap(intervals);
    }
    
    public void writeTo(DataOutput dout) throws IOException {
        assert IntervalUtils.checkOverlap(intervals);
        dout.writeInt(intervals.size());
        I prevInterval = null;
        for (I interval : intervals) {
            factory.writeInterval(interval, prevInterval, dout);
            prevInterval = interval;
        }
    }
    
    /**
     * Check if a Interval is in the IntervalSet
     * 
     * @param queryinterval The Interval to ask about.
     * @return true if this Interval is contained in the IntervalSet.
     */
    public  boolean inIntervalSet(I queryinterval) {
        OverlapIntervalComparator<I> comp = new OverlapIntervalComparator<I>();
        int insertPoint = Collections.binarySearch(intervals, queryinterval, comp);
        if (insertPoint < 0) return false;
        I intervalInList = intervals.get(insertPoint);
        return queryinterval.end() <= intervalInList.end() && 
               queryinterval.start() >= intervalInList.start();
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
    public List<I> spannedIntervals(I spanningInterval, boolean clip) {
        StartIntervalComparator<I> scomp = 
            new StartIntervalComparator<I>();

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
        
        EndIntervalComparator<I> ecomp = new EndIntervalComparator<I>();

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

        if (endPoint < startPoint) {
            throw new IllegalStateException("endPoint " + endPoint +
                    " comes before start point " + startPoint + 
                    " for spanning interval " + spanningInterval + 
                    " on intervals " + intervals);
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
            long clipedStart = Math.max(firstInterval.start(), spanningInterval.start());
            firstInterval = (I) firstInterval.clone(clipedStart, firstInterval.end());
            rv.set(0, firstInterval);
            I lastInterval = rv.get(rv.size() - 1);
            long clipedEnd = Math.min(lastInterval.end(), spanningInterval.end());
            lastInterval = (I) lastInterval.clone(lastInterval.start(), clipedEnd);
            rv.set(rv.size() - 1, lastInterval);
           
            assert IntervalUtils.checkOverlap(rv);
            return rv;
        }
    }
    
    /**
     * Removes intervals in the specified range clipping intervals that are
     * at the start and and of the specified start and end.
     * @param deleteMe inclusive.
     */
    public void deleteInterval(I deleteMe) {
        StartIntervalComparator<I> startComp =
            new StartIntervalComparator<I>();
        RemovableArrayList<I> arrayList = new RemovableArrayList<I>(this.intervals);
        
        //Start point should be the index of the first interval to delete
        //or to split into a different interval.
        int startPoint = Collections.binarySearch(arrayList, deleteMe,startComp);
        if (startPoint  < 0) {
            startPoint = (-startPoint) - 1;
        }
        
        if (startPoint > 0) {
            //If the end of the previous index over laps that begin of the delete
            //point then backup the start index by one.
            if (arrayList.get(startPoint - 1).end() >= deleteMe.start()) {
                startPoint--;
            }
        }
        
        if (startPoint >= intervals.size()) return;
        
        //endPoint should be the index last interval to delete or to split into
        //a different interval.
        EndIntervalComparator<I> endComp = new EndIntervalComparator<I>();
        int endPoint = Collections.binarySearch(arrayList, deleteMe, endComp);
        if (endPoint < 0) {
            endPoint = (-endPoint) - 1;
        }

        if (endPoint >= arrayList.size()) {
            endPoint--;
        } else if (arrayList.get(endPoint).start() > deleteMe.end()) {
            endPoint--;
        }
        
        if (endPoint < startPoint) {
            //delete interval is in hole or before all other intervals.
            return;
        }
        
        //At this point in the code start and end points should be arranged so
        //they fall at parts of the array which have elements that need to be
        //broken or removed.
        
        I firstErased = arrayList.get(startPoint);
        
        //If both deleteMe.start() and deleteMe.end() lands in the middle of an
        //interval then break that interval into zero one or two intervals.
        if (startPoint == endPoint) {
            arrayList.remove(startPoint);

            if (firstErased.start() < deleteMe.start()) {
                I newFirst = (I) firstErased.clone(firstErased.start(), deleteMe.start() - 1);
                arrayList.add(startPoint, newFirst);
                endPoint++;
            }
            if (firstErased.end() > deleteMe.end()) {
                I newEnd =  (I) firstErased.clone(deleteMe.end() + 1, firstErased.end());
                arrayList.add(endPoint, newEnd);
            }
        } else {
            if (firstErased.start() < deleteMe.start() && firstErased.end() >= deleteMe.start()) {
                arrayList.set(startPoint, (I) firstErased.clone(firstErased.start(), deleteMe.start()-1));
                startPoint++;
            }
            I lastErased = arrayList.get(endPoint);
            if (lastErased.end() > deleteMe.end() && lastErased.start() < deleteMe.end()) {
                arrayList.set(endPoint, (I) lastErased.clone(deleteMe.end() + 1, lastErased.end()));
                endPoint--;
            }
            
            arrayList.removeInterval(startPoint, (endPoint+1));
        }
        
        intervals = factory.cachedList(arrayList);
        assert IntervalUtils.checkOverlap(intervals);
    }
    
    /**
     * Insert a new interval into the set. This may do nothing, create a new interval
     * or merge existing intervals into new intervals.
     * 
     * @param newinterval The interval to insert.
     */
    public void mergeInterval(I newinterval) {
        mergeInterval(newinterval, true, true);
    }
    
    public String printIntervals() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("----").append('\n');
        for (Interval i : intervals) {
            bldr.append(i).append('\n');
        }
        bldr.append("====").append('\n');
        String s = bldr.toString();
        System.out.print(s);
        return s;
    }
    
    private void mergeInterval(I newinterval, boolean doPool, boolean newList) {
        if (newList) {
            intervals = new ArrayList<I>(intervals);
        }
        
        // Base case. No existing intervals.
        if (intervals.size() == 0) {
            intervals.add(newinterval);
            if (doPool) {
                intervals  = factory.cachedList(intervals);
            }
            return;
        }
        
        //printIntervals();
        
        Comparator<I> comp = new StartIntervalComparator<I>();
        int insertIndex = Collections.binarySearch(intervals, newinterval, comp);
        
        if (insertIndex >=0 ) {
            //Found exact match.
            mergeIntervalsAt(insertIndex, newinterval);
        } else {
            //See the documentation for Collections.binarySearch for
            //how this index is computed.
            mergeIntervalsAt( (-insertIndex) - 1, newinterval);
        }
        
        if (doPool) {
            intervals = factory.cachedList(intervals);
        }
    }

    private void insertintervalsAt( int insertIndex, 
                                    Interval.MergeResult result, 
                                    boolean insertNewinterval) {
        List<I> mergedintervals = (List<I>) result.mergedIntervals();
        int insertedCount = 0;
        for (int i=0; i < mergedintervals.size(); i++) {
            if (!insertNewinterval && i == result.otherIndex()) continue;
            intervals.add(insertIndex + insertedCount, mergedintervals.get(i));
            insertedCount++;
        }
    }
    
    /**
     * Merges the new interval at the specified index.
     * 
     * @param insertIndex At this index.  It should be the index before the
     * first item that it needs to be inserted into.  Or equal to the one it
     * replaces.
     * @param newInterval The interval to merge into existing intervals.
     */
    private void mergeIntervalsAt(int insertIndex, I newInterval) {
        
        //Base case, insert at end.
        if (insertIndex == intervals.size()) {
            Interval.MergeResult result =
                intervals.get(insertIndex -1).merge(newInterval);
            intervals.remove(insertIndex - 1);
            insertintervalsAt(insertIndex - 1, result, true);
            assert IntervalUtils.checkOverlap(intervals) : printIntervals();
            return;
        } 
        
        //     nnnnnnnnnn
        //     oooooooooo
        I current = intervals.get(insertIndex);
        if (current.end() == newInterval.end() && current.start() == newInterval.start()) {
            Interval.MergeResult result = intervals.get(insertIndex).merge(newInterval);
            intervals.remove(insertIndex);
            insertintervalsAt(insertIndex, result, true);
            assert IntervalUtils.checkOverlap(intervals) : printIntervals();
            return;
        }
        
        if (insertIndex != 0) {
            I prev = intervals.get(insertIndex - 1);
            if (prev.end() + 1 >= newInterval.start()) {
                //          nnnnnnnnn
                //oooooooooo
                
                //         nnnnnnnnnn
                //      oooooo
                
                //     nnnnnnnnnnnn
                // oooooooooo ooooooooo
                
                //merge with the previous interval.
                Interval.MergeResult mergeResult = 
                    intervals.get(insertIndex-1).merge(newInterval);
                intervals.remove(insertIndex - 1);
                insertintervalsAt(insertIndex -1, mergeResult, false);
                newInterval = (I) mergeResult.mergedIntervals().get(mergeResult.otherIndex());
                insertIndex = insertIndex - 1 + mergeResult.otherIndex();
            }
        }
        
        boolean inserted = true;
        while (insertIndex < intervals.size()) {
            current = intervals.get(insertIndex);
            
            if (current.start() > newInterval.end() + 1) {
                //            nnnnnnnnnnnn
                //  oooooo                    ooooo
                intervals.add(insertIndex, newInterval);
                inserted = true;
                break;
            }
            
            //nnnnnnnnnn
            //          ooooooooo
            if (current.start() == newInterval.end() + 1) {
                Interval.MergeResult result = intervals.get(insertIndex).merge(newInterval);
                intervals.remove(insertIndex);
                insertintervalsAt(insertIndex, result, true);
                inserted = true;
                break;
            }
          
            //         nnnnnn
            //    oooooooooooooo
            if (current.start() <= newInterval.start() && current.end() >= newInterval.end()) {
                Interval.MergeResult result = intervals.get(insertIndex).merge(newInterval);
                intervals.remove(insertIndex);
                insertintervalsAt(insertIndex, result, true);
                inserted = true;
                break;
            }
        
            //     nnnnnnnnn
            //           ooooooooo
            
            
            //  nnnnnnnnnnnnnnnnnnn
            //    oooooo    ooooo
            Interval.MergeResult mergeResult = 
                intervals.get(insertIndex).merge(newInterval);
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
        assert IntervalUtils.checkOverlap(intervals) : printIntervals();
    }
    
    /**
     * Merge another set into this one.
     * @param other The other set.
     */
    public void mergeSet(IntervalSet<I,F> other) {
        assert IntervalUtils.checkOverlap(other.intervals);
        boolean firstInterval = true;
        for (I interval : other.intervals) {
            this.mergeInterval(interval, false, firstInterval);
            firstInterval = false;
        }
        intervals = factory.cachedList(intervals);
        assert IntervalUtils.checkOverlap(this.intervals);
    }
    
    /**
     * Get all the intervals known to this IntervalSet.
     * 
     * @return an unmodifiable list.
     */
    public  List<I> intervals() {
        if (intervals.size() == 0) return Collections.emptyList();
        List<I> rv = new ArrayList<I>();
        rv.addAll(intervals);
        return Collections.unmodifiableList(rv);
    }

    public void ensureCapacity(int minCapacity) {
        if (intervals instanceof ArrayList) {
            ((ArrayList<I>)intervals).ensureCapacity(minCapacity);
        }
    }
    
    static class StartIntervalComparator<I extends Interval> implements Comparator<I> {
        
        /** o1.start() < o2.start() orders by the start of the interval.
         * 
         */
        @Override
        public int compare(I r1, I r2) {
            if (r1 == r2) return 0;
            
            assert r1.end() >= r1.start();
            assert r2.end() >= r2.start();
            
            long diff = r1.start() - r2.start();
            if (diff < 0) return -1;
            if (diff == 0) return 0;
            return 1;
        }
    }
   
    static class EndIntervalComparator<I extends Interval> implements Comparator<I> {

        /**
         * o1.end() < o2.end()
         */
        @Override
        public int compare(I r1, I r2) {
            if (r1 == r2) return 0;
            assert r1.end() >= r1.start();
            assert r2.end() >= r2.start();
            
            long diff = r1.end() - r2.end();
            if (diff < 0) return -1;
            if (diff == 0) return 0;
            return 1;
        }
        
    }
    
    static class OverlapIntervalComparator<I extends Interval> implements Comparator<I> {
        /**
         * Check if a interval overlaps this interval.
         * 
         * @param s Start cadence, inclusive.
         * @param e End cadence, inclusive.
         * @return -1 if r1 is less than r2, 0 if they overlap , 2 if it is
         * greater than this interval and 0 contained or are equal.
         */
        @Override
        public int compare(I r1, I r2) {
            if (r1 == r2) return 0;
            
            assert r1.end() >= r1.start();
            assert r2.end() >= r2.start();
            
            if ( r1.end() < r2.start()) return -1;
            if ( r1.start() > r2.end()) return 2;
            return 0;
        }
    }
}
