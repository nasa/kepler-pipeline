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

import static gov.nasa.spiffy.common.io.LongEncoder.*;

import gov.nasa.spiffy.common.collect.Cache;
import gov.nasa.spiffy.common.concurrent.MultiLevelConcurrentLruCache;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.atomic.AtomicLong;

/**
 * This range has type with it such that two ranges can only be merged
 * into the same range only if they have the same type.  In the case where
 * all types are the same this is equivelent to untyped ranges.
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public class TaggedInterval extends SimpleInterval {
    private long tag;
    
    public TaggedInterval(long start, long end, long tag) {
        super(start, end);
        this.tag = tag;
    }
  
    /**
     * Don't use this constructor.
     *
     */
    public TaggedInterval() {
        
    }
    
    public long tag() {
        return tag;
    }
    
    @Override
    public boolean equals(Object other) {
        if (this == other) return true;
        if (other == null) return false;
        if (other.getClass() != this.getClass()) return false;
        TaggedInterval tother = (TaggedInterval) other;
        return (this.start == tother.start) && (this.end == tother.end) &&
            (this.tag == tother.tag);
    }
    
    @Override
    public int hashCode() {
        long h =(start + end + tag) ^ start ^ ( end << 3)  ^ (tag << 5);
        return (int) (h ^ ( h >>> 32));
    }
    
    @Override
    public Interval clone(long newStart, long newEnd) {
        return new TaggedInterval(newStart, newEnd, tag);
    }
    
    /**
     * When a range is merged into this range it may be broken
     * into three different ranges if the other range is of a different type
     * than this range.  This part are:  the old part before,
     * the new part in the middle and the old part after.
     */
    @Override
    public MergeResult merge(Interval other) {
        
        TaggedInterval tother = (TaggedInterval) other;
        TypedMergeResult result = new TypedMergeResult();
        result.mergedRanges = new ArrayList<Interval>();
        
        if (tother.tag == this.tag) {
            if ((tother.end + 1) < start ) {
                //Disjoint ranges.
                result.mergedRanges.add(other);
                result.mergedRanges.add(this);
                result.otherIndex = 1;
            } else if ( (tother.start - 1) > end) {
                result.mergedRanges.add(this);
                result.mergedRanges.add(other);
                result.otherIndex = 0;
            } else {
                //Glue them together.
                long newStart = Math.min(this.start, tother.start);
                long newEnd = Math.max(this.end, tother.end);
                TaggedInterval newRange = new TaggedInterval(newStart, newEnd, this.tag);
                result.mergedRanges.add(newRange);
                result.otherIndex = 0;
            }
        } else {
            //     nnnnnnnnn
            //  ooooooo
            //      nnnnnnnnnnnn
            //  ooooooooooooooooooo
            //              nnnnnnnnnnnn
            // oooooooo
            if (start < tother.start) {
                long oldEnd = Math.min(tother.start-1, end);
                result.mergedRanges.add(new TaggedInterval(start, oldEnd, tag));
            } 
            result.mergedRanges.add(tother);
            result.otherIndex = result.mergedRanges.size() - 1;
            
            //   nnnnnnnnn
            //     oooooooooo
            //    nnnnnn
            // oooooooooooo
            //  nnnnnnnn
            //             oooooo
            if (end > tother.end) {
                long oldStart = Math.max(tother.end+1, start);
                result.mergedRanges.add(new TaggedInterval(oldStart, end, tag));
            }
        }
        
        if (!(result.otherIndex >= 0)) {
            throw new ArrayIndexOutOfBoundsException("Internal error souce index must be valid.");
        }
        if (!(result.mergedRanges.size() > 0)) {
            throw new IllegalStateException("Invalid number of merged ranges.");
        }
        assert IntervalUtils.checkOverlap(result.mergedRanges);
        return result;
    }
    
    /**
     * Read/Write TypedRanges.
     * 
     * @author Sean McCauliff
     *
     */
    public static class Factory implements IntervalFactory<TaggedInterval> {

        private static final AtomicLong metricCount = new AtomicLong();
        private static final long METRIC_MOD = 17;
        private static final int MAX_CACHE = 1024*4;
        private final Cache<List<TaggedInterval>, List<TaggedInterval>> listCache =
            new MultiLevelConcurrentLruCache<List<TaggedInterval>,List<TaggedInterval>>(MAX_CACHE);
        
        @Override
        public TaggedInterval readInterval(TaggedInterval prevInterval, DataInput din) throws IOException {
            if (prevInterval == null) {
                long start = bytesToLong(din);
                long end = bytesToLong(din);
                long type = bytesToLong(din);
                return new TaggedInterval(start, end, type);
            } else {
                long s = bytesToLong(din) + prevInterval.end();
                long e = bytesToLong(din) + s;
                long t = bytesToLong(din) + prevInterval.tag();
                return new TaggedInterval(s, e, t);
            }
        }

        @Override
        public void writeInterval(TaggedInterval interval, TaggedInterval prevInterval, DataOutput dout) 
            throws IOException {
            
            if (prevInterval == null) {
                longToBytes(interval.start, dout);
                longToBytes(interval.end, dout);
                longToBytes(interval.tag, dout);
            } else {
                long deltaS = interval.start() - prevInterval.end();
                long deltaE = interval.end() - interval.start();
                long deltaT = interval.tag() - prevInterval.tag();
                longToBytes(deltaS, dout);
                longToBytes(deltaE, dout);
                longToBytes(deltaT, dout);
            }
        }

        @Override
        public List<TaggedInterval> cachedList(List<TaggedInterval> original) {
        	assert IntervalUtils.checkOverlap(original);
            IntervalMetricKey waitKey = 
                (metricCount.getAndIncrement() % METRIC_MOD == 0) ? IntervalMetric.start() : null;
            try {
                List<TaggedInterval> cached = listCache.get(original);
                if (cached != null) {
                    return cached;
                } else {
                    //This may return different lists on a cache miss, but it's ok
                    //to have a few duplicates.
                    List<TaggedInterval> unmodList = Collections.unmodifiableList(original);
                    listCache.put(unmodList, unmodList);
                    return unmodList;
                }
            } finally {
                if (waitKey != null) {
                    IntervalMetric.stop("common.taggedinterval.cachelist", waitKey);
                }
            }
        }
    }
   
    private static class TypedMergeResult implements MergeResult {
        private List<Interval> mergedRanges;
        private int otherIndex = -1;
        
        @Override
        public List<Interval> mergedIntervals() {
            return mergedRanges;
        }

        @Override
        public int otherIndex() {
            return otherIndex;
        }
        
    }

    
    /**
     * @see java.lang.Object#toString()
     */
    @Override
    public String toString() {
        return "start="+start+",end="+end+",tag="+tag;
    }
}
