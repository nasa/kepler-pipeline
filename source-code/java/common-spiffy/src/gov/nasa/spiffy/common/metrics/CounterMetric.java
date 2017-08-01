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
import java.util.concurrent.atomic.AtomicInteger;

/**
 * Implements a simple metric consisting of an integer counter
 * 
 * @created June 13, 2005
 * @author todd.klaus
 */
public class CounterMetric extends Metric implements Serializable {
    private static final long serialVersionUID = -5164077933977735823L;

    private final AtomicInteger count = new AtomicInteger(0);

    public static String COUNTER_TYPE = "C";
    
    /**
     * 
     * @created June 13, 2005
     * @return
     */
    public int getCount() {
        return count.get();
    }


    /**
     * 
     * @created June 13, 2005
     * @param metricName
     */
    public static CounterMetric decrement(String metricName) {
        return CounterMetric.decrement(metricName,1);
    }

    /**
     * 
     * @created June 13, 2005
     * @param metricName
     */
    public static CounterMetric decrement(String metricName, int amount) {
        Pair<CounterMetric, CounterMetric> counterMetric = getCounterMetric(metricName);
        counterMetric.left.decrement(amount);
        if(counterMetric.right != null){
            counterMetric.right.decrement(amount);
        }
        return counterMetric.left;
    }

    /**
     * 
     * @created June 13, 2005
     * @param metricName
     */
    public static CounterMetric increment(String metricName) {
        return CounterMetric.increment(metricName, 1);
    }

    /**
     * 
     * @created June 13, 2005
     * @param metricName
     */
    public static CounterMetric increment(String metricName, int amount) {
        Pair<CounterMetric, CounterMetric> counterMetric = getCounterMetric(metricName);
        counterMetric.left.increment(amount);
        if(counterMetric.right != null){
            counterMetric.right.increment(amount);
        }
        return counterMetric.left;
    }

    @Override
    public void toLogString(StringBuilder bldr) {
        bldr.append(name).append(',').append(COUNTER_TYPE).append(',').append(count);
    }
    
    /**
     * Constructor
     * 
     * @created June 13, 2005
     * 
     */
    protected CounterMetric(String name) {
        setName(name);
    }

    /**
     * Copy ctor
     * 
     * @param otherMetric
     */
    protected CounterMetric(CounterMetric otherMetric) {
        super();
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.common.metrics.Metric#merge(gov.nasa.kepler.common.metrics.Metric)
     */
    @Override
    public synchronized void merge(Metric other) {
        if(other instanceof CounterMetric){
            CounterMetric otherCm = (CounterMetric)other;
            count.addAndGet(otherCm.count.get());
        }else{
            throw new IllegalArgumentException("Specified Metric is not a CounterMetric, type=" + other.getClass().getName());
        }
    }

    @Override
    public CounterMetric makeCopy() {
        CounterMetric copy = new CounterMetric(this.name);
        copy.count.set(this.count.get());
        return copy;
    }

    /**
     * 
     * @created June 13, 2005
     * 
     */
    protected void decrement() {
        count.decrementAndGet();
    }

    /**
     * 
     * @created June 13, 2005
     * 
     */
    protected void decrement(int amount) {
        int oldValue = -1;
        do {
            oldValue = count.get();
        } while (!count.compareAndSet(oldValue, oldValue - amount));
    }

    /**
     * 
     * @created June 13, 2005
     * 
     */
    protected void increment() {
        count.incrementAndGet();
    }

    /**
     * 
     * @created June 13, 2005
     * 
     */
    protected void increment(int amount) {
        int oldValue = -1;
        do {
            oldValue = count.get();
        } while (!count.compareAndSet(oldValue, oldValue + amount));
    }

    /**
     * 
     * @created June 13, 2005
     * 
     */
    @Override
    protected void reset() {
        count.set(0);
    }

    /**
     * 
     * @created June 13, 2005
     * @param name
     * @return
     */
    protected static Pair<CounterMetric, CounterMetric> getCounterMetric(String name) {
        Metric globalMetric = Metric.getGlobalMetric(name);
        if ((globalMetric == null) || !(globalMetric instanceof CounterMetric)) {
            globalMetric = Metric.addNewGlobalMetric(new CounterMetric(name));
        }

        Metric threadMetric = null;
        if(Metric.threadMetricsEnabled()){
            threadMetric = Metric.getThreadMetric(name);
            if ((threadMetric == null) || !(threadMetric instanceof CounterMetric)) {
                threadMetric = Metric.addNewThreadMetric(new CounterMetric(name));        
            }
        }

        Pair<CounterMetric,CounterMetric> m = 
            Pair.of((CounterMetric)globalMetric, (CounterMetric)threadMetric);
        
        return m;
    }

    @Override
    public synchronized int hashCode() {
        final int prime = 31; 
        int result = super.hashCode();
        result = prime * result + ((count == null) ? 0 : count.get());
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
        final CounterMetric other = (CounterMetric) obj;
        if (count == null) {
            if (other.count != null)
                return false;
        } else if (count.get() != other.count.get())
            return false;
        return true;
    }
}
