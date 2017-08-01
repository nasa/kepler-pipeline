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

package gov.nasa.spiffy.common.metrics;

import gov.nasa.spiffy.common.collect.Pair;

import java.io.Serializable;

/**
 * Implements a metric which represents an accumulator which can be incremented
 * by an arbitrary amount. Also tracks the the minimum and maximum values added
 * and the count of values added, allowing the computation of the average.
 * 
 * @author tklaus
 * 
 */
public class ValueMetric extends Metric implements Serializable {
    private static final long serialVersionUID = -3921293669950350490L;

    public static final String VALUE_TYPE = "V";
    
    protected long min = Long.MAX_VALUE;
    protected long max = Long.MIN_VALUE;
    protected int count = 0;
    protected long sum = 0;

    public synchronized double getAverage() {
        if (count > 0) {
            return ((double) sum) / ((double) count);
        }
        return 0;
    }

    public synchronized long getSum() {
        return sum;
    }

    public synchronized int getCount() {
        return count;
    }

    public synchronized long getMax() {
        return (max == Long.MIN_VALUE) ? 0 : max;
    }

    public synchronized long getMin() {
        return (min == Long.MAX_VALUE) ? 0 : min;
    }
    
    @Override
    public synchronized void toLogString(StringBuilder bldr) {
        bldr.append(name).append(',').append(VALUE_TYPE).append(',').append(min).append(',').append(max).append(',').append(getAverage()).append(',').append(count).append(',').append(sum);
    }
    
    @Override
    public String toString() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("mean: ").append(getAverage()).append(", min: ").append(min).append(", max: ").append(max).append(", count: ").append(count).append(", sum: ").append(sum);
        return bldr.toString();
    }

    public static ValueMetric addValue(String name, long value) {
        Pair<ValueMetric, ValueMetric> m = getValueMetric(name);
        m.left.addValue(value);
        if(m.right != null){
            m.right.addValue(value);
        }
        return m.left;
    }

    protected static Pair<ValueMetric,ValueMetric> getValueMetric(String name) {
        Metric globalMetric = Metric.getGlobalMetric(name);
        if ((globalMetric == null) || !(globalMetric instanceof ValueMetric)) {
            globalMetric = Metric.addNewGlobalMetric(new ValueMetric(name));
        }

        Metric threadMetric = null;
        if(Metric.threadMetricsEnabled()){
            threadMetric = Metric.getThreadMetric(name);
            if ((threadMetric == null) || !(threadMetric instanceof ValueMetric)) {
                threadMetric = addNewThreadMetric(new ValueMetric(name));        
            }
        }

        Pair<ValueMetric,ValueMetric> m = 
            Pair.of((ValueMetric)globalMetric, (ValueMetric)threadMetric);
        
        return m;
    }

    protected ValueMetric(String name) {
        setName(name);
    }

    ValueMetric(String name, long min, long max, int count, long sum) {
        this(name);
        this.min = min;
        this.max = max;
        this.count = count;
        this.sum = sum;
    }

    @Override
    public synchronized ValueMetric makeCopy() {
        ValueMetric copy = new ValueMetric(this.name);
        copy.name = this.name;
        copy.sum = this.sum;
        copy.min = this.min;
        copy.max = this.max;
        copy.count = this.count;
        return copy;
    }

    protected synchronized void addValue(long value) {
        if (value < min) {
            min = value;
        }
        if (value > max) {
            max = value;
        }
        count++;
        sum += value;
    }


    @Override
    public synchronized void merge(Metric other) {
        if(other instanceof ValueMetric){
            ValueMetric otherVm = (ValueMetric)other;
            count += otherVm.count;
            sum += otherVm.sum;
            max = Math.max(max, otherVm.max);
            min = Math.min(min, otherVm.min);
        }else{
            throw new IllegalArgumentException("Specified Metric is not a ValueMetric, type=" + other.getClass().getName());
        }
    }
    
    @Override
    protected synchronized void reset() {
        min = Long.MAX_VALUE;
        max = Long.MIN_VALUE;
        count = 0;
        sum = 0;
    }

    @Override
    public synchronized int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result + count;
        result = prime * result + (int) (max ^ (max >>> 32));
        result = prime * result + (int) (min ^ (min >>> 32));
        result = prime * result + (int) (sum ^ (sum >>> 32));
        return result;
    }

    @Override
    public synchronized boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (getClass() != obj.getClass())
            return false;
        final ValueMetric other = (ValueMetric) obj;
        if (count != other.count)
            return false;
        if (max != other.max)
            return false;
        if (min != other.min)
            return false;
        if (sum != other.sum)
            return false;
        return true;
    }
}
