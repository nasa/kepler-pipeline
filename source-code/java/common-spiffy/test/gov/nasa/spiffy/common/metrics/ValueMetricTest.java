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

import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.pojo.PojoTest;

import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class ValueMetricTest {
    private static final String METRIC_1_NAME = "MetricsTest-1";
    private static final String METRIC_2_NAME = "MetricsTest-2";

    @Before
    public void setUp() {
        Metric.clear();
    }

    @Test
    public void testValueMetricEmpty() {
        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;

        assertEquals(0, m.getCount());
        assertEquals(0, m.getAverage(), 0);
        assertEquals(0, m.getSum());
        assertEquals(0, m.getMin());
        assertEquals(0, m.getMax());
    }

    @Test
    public void testValueMetricSimple() {
        ValueMetric.addValue(METRIC_1_NAME, 1);

        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;

        assertEquals(1, m.getCount());
        assertEquals(1, m.getAverage(), 0);
        assertEquals(1, m.getSum());
        assertEquals(1, m.getMin());
        assertEquals(1, m.getMax());
    }

    @Test
    public void testValueMetricMultiple() throws Exception {
        ValueMetric.addValue(METRIC_1_NAME, 2);
        ValueMetric.addValue(METRIC_1_NAME, 4);
        ValueMetric.addValue(METRIC_1_NAME, 6);

        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;

        assertEquals(3, m.getCount());
        assertEquals(4, m.getAverage(), 0);
        assertEquals(12, m.getSum());
        assertEquals(2, m.getMin());
        assertEquals(6, m.getMax());
    }

    @Test
    public void testValueMetricMultiThread() throws Exception {
        Map<String, Metric> threadOneMetrics = executeSynchronous(new Callable<Map<String, Metric>>() {
            @Override
            public Map<String, Metric> call() {
                Metric.enableThreadMetrics();

                ValueMetric.addValue(METRIC_1_NAME, 1);
                ValueMetric.addValue(METRIC_1_NAME, 1);

                return Metric.getThreadMetrics();
            }
        });

        Map<String, Metric> threadTwoMetrics = executeSynchronous(new Callable<Map<String, Metric>>() {
            @Override
            public Map<String, Metric> call() {
                Metric.enableThreadMetrics();

                ValueMetric.addValue(METRIC_1_NAME, 1);

                return Metric.getThreadMetrics();
            }
        });

        ValueMetric metricGlobal = ValueMetric.getValueMetric(METRIC_1_NAME).left;
        ValueMetric metricThreadOne = (ValueMetric) threadOneMetrics.get(METRIC_1_NAME);
        ValueMetric metricThreadTwo = (ValueMetric) threadTwoMetrics.get(METRIC_1_NAME);

        assertEquals(3, metricGlobal.getCount());
        assertEquals(2, metricThreadOne.getCount());
        assertEquals(1, metricThreadTwo.getCount());
    }

    private <T> T executeSynchronous(Callable<T> task) throws Exception {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        Future<T> result = executor.submit(task);

        return result.get();
    }
    
    @Test
    public void testMakeCopy() {
        ValueMetric.addValue(METRIC_1_NAME, 1);

        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;
        
        ValueMetric copiedMetric = m.makeCopy();
        
        assertEquals(m, copiedMetric);
    }

    @Test
    public void testMerge() {
        ValueMetric.addValue(METRIC_1_NAME, 4);

        ValueMetric.addValue(METRIC_2_NAME, 2);
        ValueMetric.addValue(METRIC_2_NAME, 6);
        
        ValueMetric metric1 = ValueMetric.getValueMetric(METRIC_1_NAME).left;
        ValueMetric metric2 = ValueMetric.getValueMetric(METRIC_2_NAME).left;
        
        metric1.merge(metric2);
        
        assertEquals(3, metric1.getCount());
        assertEquals(4, metric1.getAverage(), 0);
        assertEquals(12, metric1.getSum());
        assertEquals(2, metric1.getMin());
        assertEquals(6, metric1.getMax());
    }

    @Test
    public void testReset() {
        ValueMetric.addValue(METRIC_1_NAME, 1);

        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;
        
        m.reset();

        ValueMetric.addValue(METRIC_1_NAME, 1);
        
        assertEquals(1, m.getCount());
        assertEquals(1, m.getAverage(), 0);
        assertEquals(1, m.getSum());
        assertEquals(1, m.getMin());
        assertEquals(1, m.getMax());
    }

    @Test
    public void testToLogString() {
        ValueMetric.addValue(METRIC_1_NAME, 1);

        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;

        StringBuilder builder = new StringBuilder();
        m.toLogString(builder);

        assertEquals("MetricsTest-1,V,1,1,1.0,1,1", builder.toString());
    }
    
    @Test
    public void testToString() {
        ValueMetric.addValue(METRIC_1_NAME, 1);

        ValueMetric m = ValueMetric.getValueMetric(METRIC_1_NAME).left;

        assertEquals("mean: 1.0, min: 1, max: 1, count: 1, sum: 1", m.toString());
    }

    @Test
    public void testHashCodeEquals() {
        ValueMetric valueMetric = new ValueMetric("name", 1, 2, 3, 4);
        ValueMetric valueMetricWithSameKeys = new ValueMetric("name", 1, 2, 3,
            4);
        ValueMetric valueMetricWithDifferentMin = new ValueMetric("name", 0, 2,
            3, 4);
        ValueMetric valueMetricWithDifferentMax = new ValueMetric("name", 1, 0,
            3, 4);
        ValueMetric valueMetricWithDifferentCount = new ValueMetric("name", 1,
            2, 0, 4);
        ValueMetric valueMetricWithDifferentSum = new ValueMetric("name", 1, 2,
            3, 0);
        ValueMetric valueMetricWithDifferentClass = new IntervalMetric("name");

        PojoTest.testHashCodeEquals(valueMetric, valueMetricWithSameKeys,
            valueMetricWithDifferentSum, valueMetricWithDifferentCount,
            valueMetricWithDifferentMin, valueMetricWithDifferentMax,
            valueMetricWithDifferentClass);
    }
}
