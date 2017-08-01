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

import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

import static gov.nasa.kepler.fs.server.TimeSeriesIntervalIterator.BREAK_AT;
/**
 * Breaks a list of valid intervals and their tagged intervals into matched lists
 * where there is never a gap of more than BREAK_AT size in one chunk 
 * returned by next().  Further more it will break writes if there is existing
 * data that would be over written by extending a list of intervals over them.
 * 
 * @author Sean McCauliff
 *
 */
class TimeSeriesMergeIntervalIterator implements 
    Iterable<Pair<List<SimpleInterval>, List<TaggedInterval>>>, 
    Iterator<Pair<List<SimpleInterval>, List<TaggedInterval>>> {

    private static final Comparator<SimpleInterval> endPointCmp = 
        new Comparator<SimpleInterval>() {

            @Override
            public int compare(SimpleInterval o1, SimpleInterval o2) {
                long diff = o1.end() - o2.end();
                if (diff  == 0) {
                    return 0;
                } else if (diff < 0) {
                    return -1;
                } else {
                    return 1;
                }
            }
        
    };
    
    private final List<SimpleInterval> writeValid;
    private final List<TaggedInterval> writeOrigin;
    private final List<SimpleInterval> existingValid;
    private int nextWriteValid = 0;
    private int nextWriteOrigin = 0;
    /** The next potentially obstructing interval.  Index into list. */
    private int nextExisting;
    
    TimeSeriesMergeIntervalIterator(List<SimpleInterval> writeValid, 
        List<TaggedInterval> writeOrigin, List<SimpleInterval> existingValid) {
        
        this.writeValid = writeValid;
        this.writeOrigin = writeOrigin;
        this.existingValid = existingValid;
        
        if (writeValid.size() > 0) {
            SimpleInterval firstWrite = writeValid.get(0);
            //That's correct the searchKey end is the start of the first write
            SimpleInterval searchKey = 
                new SimpleInterval(firstWrite.start(), firstWrite.start());
            int searchIndex = 
                Collections.binarySearch(existingValid, searchKey,endPointCmp);
            if (searchIndex < 0) {
                searchIndex = (-searchIndex) -1;
            }
            nextExisting = searchIndex;
        }
      
    }
        
    @Override
    public Iterator<Pair<List<SimpleInterval>, List<TaggedInterval>>> iterator() {
        return this;
    }

    @Override
    public Pair<List<SimpleInterval>, List<TaggedInterval>> next() {
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        
        List<SimpleInterval> rvValid  = new ArrayList<SimpleInterval>();
        rvValid.add(writeValid.get(nextWriteValid++));
        while (nextWriteValid < writeValid.size()) {
            
            SimpleInterval prev = rvValid.get(rvValid.size() - 1);
            SimpleInterval next = writeValid.get(nextWriteValid);
            if ((next.start() - prev.end()) + 1 > BREAK_AT) {
                break;
            } else if (isIntervening(prev,next)) {
                break;
            } else {
                rvValid.add(next);
                nextWriteValid++;
            }
        }
        
        List<TaggedInterval> rvOrigin = new ArrayList<TaggedInterval>();
        SimpleInterval lastValid = rvValid.get(rvValid.size() - 1);
        while (nextWriteOrigin < writeOrigin.size()) {
            TaggedInterval origin = writeOrigin.get(nextWriteOrigin);
            if (origin.start() > lastValid.end()) {
                break;
            }
            rvOrigin.add(origin);
            nextWriteOrigin++;
        }
        
        return Pair.of(rvValid, rvOrigin);
    }
    
    private boolean isIntervening(SimpleInterval prev, SimpleInterval next) {

        while (nextExisting < existingValid.size()) {
            SimpleInterval existing = existingValid.get(nextExisting);
            if (existing.start() >= next.start()) {
                //existing interval past the next one.
                return false;
            } else if (existing.end() <= prev.end()) {
                //existing interval before the current one.
                nextExisting++;
            } else if (existing.start() >= prev.end() && existing.start() <= next.start()) {
                //partially or completely in hole between prev and next.
                return true;
            } else if (existing.end() >= prev.end() && existing.end() <= next.start()) {
                //partially or completely in hole between prev and next.
                return true;
            } else if (existing.start() <= prev.end() && existing.end() >= next.start()) {
                //hole is completely covered with lots of existing data.
                return true;
            }
        }
        return false;
    }
    
    @Override
    public boolean hasNext() {
        return nextWriteValid < writeValid.size();
    }
    
    @Override
    public void remove() {
        throw new UnsupportedOperationException("Iterator.remove() is not supported.");
    }
}
