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
import gov.nasa.spiffy.common.persistable.ProxyIgnoreStatics;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Represents an interval of data, inclusive.
 * 
 * @author Sean McCauliff
 *
 */
@ProxyIgnoreStatics
public class SimpleInterval implements Interval {

    protected  long start;
    protected  long end;
    
    public SimpleInterval(long s, long e) {
        start = s;
        end = e;
        if (end < start) {
            throw new IllegalArgumentException("end " + e + "comes before start " + s);
        }
    }
    
    /**
     * Don't use this constructor.
     *
     */
    public SimpleInterval() {
        
    }
    @Override
    public long start() {
        return start;
    }
    
    @Override
    public long end() {
        return end;
    }

    @Override
    public Interval clone(long newStart, long newEnd) {
        return new SimpleInterval(newStart, newEnd);
    }
    
    @Override
    public MergeResult merge(Interval other) {
        
        SimpleInterval tother = (SimpleInterval) other;
        SimpleMergeResult result = new SimpleMergeResult();
        result.mergedRanges = new ArrayList<Interval>();

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
            SimpleInterval newRange = new SimpleInterval(newStart, newEnd);
            result.mergedRanges.add(newRange);
            result.otherIndex = 0;
        }
        
        return result;
    }

   
    @Override
    public boolean equals(Object other) {
        if (other == null) return false;
        if (this == other) return true;
        if (other.getClass() != this.getClass()) return false;
        SimpleInterval tother = (SimpleInterval) other;
        return (this.start == tother.start) && (this.end == tother.end);
    }
    
    @Override
    public int hashCode() {
        long h =(start + end ) ^ start ^ ( end << 3);
        return (int) (h ^ ( h >>> 32));
    }
    
    public static class Factory implements IntervalFactory<SimpleInterval> {

        private static final int MAX_CACHE = 1024*4;
        final Cache<List<SimpleInterval>, List<SimpleInterval>> listCache =
            new MultiLevelConcurrentLruCache<List<SimpleInterval>,List<SimpleInterval>>(MAX_CACHE);
        
        @Override
        public SimpleInterval readInterval(SimpleInterval prevInterval, DataInput din) throws IOException {
            if (prevInterval == null) {
                long s = bytesToLong(din);
                long e = bytesToLong(din);
                return new SimpleInterval(s,e);
            } else {
                long deltaS = bytesToLong(din);
                long deltaE = bytesToLong(din);
                long s = deltaS + prevInterval.end();
                long e = deltaE + s;
                return new SimpleInterval(s,e);
            }
        }

        @Override
        public void writeInterval(SimpleInterval interval, SimpleInterval prevInterval, DataOutput dout) 
        throws IOException {
            if (prevInterval == null) {
                longToBytes(interval.start(), dout);
                longToBytes(interval.end(), dout);
            } else {
                long deltaS = interval.start() - prevInterval.end();
                long deltaE = interval.end() - interval.start();
                longToBytes(deltaS, dout);
                longToBytes(deltaE, dout);
            }
            
        }

        @Override
        public List<SimpleInterval> cachedList(List<SimpleInterval> original) {
        	assert IntervalUtils.checkOverlap(original);
            List<SimpleInterval> cached = listCache.get(original);
            if (cached != null) {
                return cached;
            } else {
                //This may return different lists on a cache miss, but it's ok
                //to have a few duplicates.
                List<SimpleInterval> unmodList = Collections.unmodifiableList(original);
                listCache.put(unmodList, unmodList);
                return unmodList;
            }
        }
        
    }
    
    private static class SimpleMergeResult implements MergeResult {
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
        return "start="+start+",end="+end;
    }
}
