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
import java.util.Iterator;
import java.util.List;
import java.util.NoSuchElementException;

/**
 * Breaks a list of valid intervals and their tagged intervals into matched lists
 * where there is never a gap of more than BREAK_AT size in one chunk 
 * returned by next().
 * 
 * @author Sean McCauliff
 *
 */
public class TimeSeriesIntervalIterator implements 
    Iterable<Pair<List<SimpleInterval>, List<TaggedInterval>>>, 
    Iterator<Pair<List<SimpleInterval>, List<TaggedInterval>>> {


    static final int BREAK_AT = 1024*4;
    
    private final List<SimpleInterval> valid;
    private final List<TaggedInterval> originators;
    private int nextValidIndex = 0;
    private int nextOriginIndex = 0;
    
    TimeSeriesIntervalIterator(List<SimpleInterval> valid, List<TaggedInterval> originators) {
        this.valid = valid;
        this.originators = originators;
    }
    
    @Override
    public Iterator<Pair<List<SimpleInterval>, List<TaggedInterval>>> iterator() {
        return this;
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#hasNext()
     */
    @Override
    public boolean hasNext() {
        return nextValidIndex < valid.size();
    }

    /* (non-Javadoc)
     * @see java.util.Iterator#next()
     */
    @Override
    public Pair<List<SimpleInterval>, List<TaggedInterval>> next() {
        
        if (!hasNext()) {
            throw new NoSuchElementException();
        }
        
        List<SimpleInterval> rvValid = new ArrayList<SimpleInterval>();
        
        while (true) {
            rvValid.add(valid.get(nextValidIndex++));
            
            if (nextValidIndex == valid.size()) {
                break;
            }
            
            long gapSize = valid.get(nextValidIndex ).start() - valid.get(nextValidIndex - 1).end();
            if (gapSize >= BREAK_AT) {
                break;
            }
        }
        
        List<TaggedInterval> rvOrigin = new ArrayList<TaggedInterval>();
        while(true) {
            rvOrigin.add(originators.get(nextOriginIndex++));
            
            if (nextOriginIndex == originators.size()) {
                break;
            }
            
            long gapSize = originators.get(nextOriginIndex).start() - originators.get(nextOriginIndex-1).end();
            if (gapSize >= BREAK_AT) {
                break;
            }
        }
        
        return Pair.of(rvValid, rvOrigin);
        
    }

    @Override
    public void remove() {
        throw new UnsupportedOperationException("Iterator.remove() is not supported.");
    }

}
