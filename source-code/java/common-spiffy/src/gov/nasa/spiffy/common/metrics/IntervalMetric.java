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
import java.util.concurrent.Callable;

/**
 * 
 * Metric to measure elapsed time
 * 
 * @created June 13, 2005
 * @author todd.klaus
 */
public class IntervalMetric extends ValueMetric implements Serializable {

    private static final long serialVersionUID = 6018286347911138007L;

    /**
     * 
     * @created June 13, 2005
     * @param name
     * @return
     */
    public static IntervalMetricKey start() {
        return new IntervalMetricKey(System.currentTimeMillis());
    }

    /**
     * 
     * @created June 13, 2005
     * @param name
     * @param key
     */
    public static IntervalMetric stop(String name, IntervalMetricKey key) {
        Pair<IntervalMetric, IntervalMetric> m = getIntervalMetric(name);
        m.left.stop(key);
        if(m.right != null){
            m.right.stop(key);
        }
        return m.left;
    }

    /**
     * Convenience method for measuring the execution time of a block of code
     * @param <V>
     * 
     * @param name
     * @param target
     */
    public static <V> V measure(String name, Callable<V> target) throws Exception{
        IntervalMetricKey key = IntervalMetric.start();

        try{
            return target.call();
        } finally {
            IntervalMetric.stop(name, key);
        }
    }
    
    /**
     * Convenience method for measuring the execution time of a block of code
     * @param <V>
     * 
     * @param name
     * @param target
     */
    public static void measure(String name, Runnable target) throws Exception{
        IntervalMetricKey key = IntervalMetric.start();

        try{
            target.run();
        } finally {
            IntervalMetric.stop(name, key);
        }
    }
    
    /**
     * 
     * Constructor
     * 
     * @created June 13, 2005
     * @param name
     */
    protected IntervalMetric(String name) {
        super(name);
    }

    /**
     * 
     * @created June 13, 2005
     * @param name
     * @return
     */
    protected static Pair<IntervalMetric,IntervalMetric> getIntervalMetric(String name) {
        
        Metric globalMetric = Metric.getGlobalMetric(name);
        if ((globalMetric == null) || !(globalMetric instanceof IntervalMetric)) {
            globalMetric = Metric.addNewGlobalMetric(new IntervalMetric(name));        
        }

        Metric threadMetric = null;
        if(Metric.threadMetricsEnabled()){
            threadMetric = Metric.getThreadMetric(name);
            if ((threadMetric == null) || !(threadMetric instanceof IntervalMetric)) {
                threadMetric = addNewThreadMetric(new IntervalMetric(name));        
            }
        }

        Pair<IntervalMetric,IntervalMetric> m = 
            Pair.of((IntervalMetric)globalMetric, (IntervalMetric)threadMetric);
        
        return m;
    }

    /**
     * Not synchronized because addValue() is
     * 
     * @created June 13, 2005
     * @param key
     */
    protected void stop(IntervalMetricKey key) {
        addValue(System.currentTimeMillis() - key.getStartTime());
    }

    @Override
    public synchronized ValueMetric makeCopy() {
        IntervalMetric copy = new IntervalMetric(this.name);
        copy.name = this.name;
        copy.sum = this.sum;
        copy.min = this.min;
        copy.max = this.max;
        copy.count = this.count;
        return copy;
    }
}
