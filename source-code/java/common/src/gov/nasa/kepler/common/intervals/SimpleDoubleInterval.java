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

import gov.nasa.spiffy.common.intervals.DoubleInterval;

import java.util.ArrayList;
import java.util.List;

/**
 * A simple double interval with no additional information.  This class
 *  is immutable.
 * 
 * @author Sean McCauliff
 *
 */
public class SimpleDoubleInterval implements DoubleInterval {

    private final double start;
    private final double end;
    
    
    public SimpleDoubleInterval(double start, double end) {
        this.start = start;
        this.end = end;
        
        if (end < start) {
            throw new IllegalArgumentException("end " + end +
                " comes before start " + start);
            
        }
        
        if (Double.isNaN(start)) {
            throw new IllegalArgumentException("Start may not be NaN.");
        }
        if (Double.isNaN(end)) {
            throw new IllegalArgumentException("End may not be NaN");
        }
    }


    @Override
    public DoubleInterval clone(double start, double end) {
        return new SimpleDoubleInterval(start, end);
    }


    @Override
    public double end() {
        return end;
    }
    
    @Override
    public double start() {
        return start;
    }
    
    @Override
    public DoubleMergeResult merge(DoubleInterval o, double delta) {
        
        SimpleDoubleInterval other = (SimpleDoubleInterval) o;
        SimpleDoubleMergeResult result = new SimpleDoubleMergeResult();
        result.mergedIntervals = new ArrayList<DoubleInterval>(2);

        if ( (this.start - other.end) >= delta) {
            //Disjoint ranges.
            result.mergedIntervals.add(other);
            result.mergedIntervals.add(this);
            result.otherIndex = 1;
        } else if ( (other.start - this.end) >= delta) {
            result.mergedIntervals.add(this);
            result.mergedIntervals.add(other);
            result.otherIndex = 0;
        } else {
            //Glue them together.
            double newStart = Math.min(this.start, other.start);
            double newEnd = Math.max(this.end, other.end);
            SimpleDoubleInterval mergedInterval = new SimpleDoubleInterval(newStart, newEnd);
            result.mergedIntervals.add(mergedInterval);
            result.otherIndex = 0;
        }
        
        return result;
    }

    
    @Override
    public String toString() {
        return "start="+start+",end="+end;
    }

    private static class SimpleDoubleMergeResult implements DoubleMergeResult {
        private List<DoubleInterval> mergedIntervals;
        private int otherIndex = -1;
        
        public List<DoubleInterval> mergedIntervals() {
            return mergedIntervals;
        }
        
        public int otherIndex() {
            return otherIndex;
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        long temp;
        temp = Double.doubleToLongBits(end);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(start);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        return result;
    }


    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        SimpleDoubleInterval other = (SimpleDoubleInterval) obj;
        if (Double.doubleToLongBits(end) != Double.doubleToLongBits(other.end))
            return false;
        if (Double.doubleToLongBits(start) != Double.doubleToLongBits(other.start))
            return false;
        return true;
    }
    
    
}
