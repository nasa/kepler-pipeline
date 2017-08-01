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
public class IntervalMetricTest {
    private static final String METRIC_1_NAME = "MetricsTest-1";

    @Before
    public void setUp() {
        Metric.clear();
    }

    @Test
    public void testIntervalMetricSimple() throws Exception {
        IntervalMetricKey key = IntervalMetric.start();

        Thread.sleep(10);

        IntervalMetric.stop(METRIC_1_NAME, key);

        IntervalMetric m = IntervalMetric.getIntervalMetric(METRIC_1_NAME).left;

        assertEquals(1, m.getCount());
        assertEquals(10, m.getAverage(), 5);
        assertEquals(10, m.getSum(), 5);
        assertEquals(10, m.getMin(), 5);
        assertEquals(10, m.getMax(), 5);
    }

    @Test
    public void testIntervalMetricMultiple() throws Exception {
        IntervalMetricKey key = IntervalMetric.start();

        Thread.sleep(10);

        IntervalMetric.stop(METRIC_1_NAME, key);

        key = IntervalMetric.start();

        Thread.sleep(15);

        IntervalMetric.stop(METRIC_1_NAME, key);

        key = IntervalMetric.start();

        Thread.sleep(20);

        IntervalMetric.stop(METRIC_1_NAME, key);

        IntervalMetric m = IntervalMetric.getIntervalMetric(METRIC_1_NAME).left;

        int expectedCount = 3;
        long expectedSum = 10 + 15 + 20;
        double expectedAverage = expectedSum / expectedCount;

        assertEquals(expectedCount, m.getCount());
        assertEquals(expectedAverage, m.getAverage(), 5);
        assertEquals(expectedSum, m.getSum(), 5);
        assertEquals(10, m.getMin(), 5);
        assertEquals(20, m.getMax(), 5);
    }

    @Test
    public void testIntervalMetricMultiThread() throws Exception {
        Map<String, Metric> threadOneMetrics = executeSynchronous(new Callable<Map<String, Metric>>() {
            @Override
            public Map<String, Metric> call() {
                Metric.enableThreadMetrics();

                IntervalMetricKey key = IntervalMetric.start();

                try {
                    Thread.sleep(10);
                } catch (InterruptedException e1) {
                }

                IntervalMetric.stop(METRIC_1_NAME, key);

                key = IntervalMetric.start();

                try {
                    Thread.sleep(20);
                } catch (InterruptedException e) {
                }

                IntervalMetric.stop(METRIC_1_NAME, key);

                return Metric.getThreadMetrics();
            }
        });

        Map<String, Metric> threadTwoMetrics = executeSynchronous(new Callable<Map<String, Metric>>() {
            @Override
            public Map<String, Metric> call() {
                Metric.enableThreadMetrics();

                IntervalMetricKey key = IntervalMetric.start();

                try {
                    Thread.sleep(15);
                } catch (InterruptedException e) {
                }

                IntervalMetric.stop(METRIC_1_NAME, key);

                return Metric.getThreadMetrics();
            }
        });

        IntervalMetric metricGlobal = IntervalMetric.getIntervalMetric(METRIC_1_NAME).left;
        IntervalMetric metricThreadOne = (IntervalMetric) threadOneMetrics.get(METRIC_1_NAME);
        IntervalMetric metricThreadTwo = (IntervalMetric) threadTwoMetrics.get(METRIC_1_NAME);

        assertEquals(3, metricGlobal.getCount());
        assertEquals((10.0 + 20.0 + 15.0) / 3.0, metricGlobal.getAverage(), 5);
        assertEquals(45, metricGlobal.getSum(), 5);
        assertEquals(10, metricGlobal.getMin(), 5);
        assertEquals(20, metricGlobal.getMax(), 5);

        assertEquals(2, metricThreadOne.getCount());
        assertEquals((10.0 + 20.0) / 2.0, metricThreadOne.getAverage(), 5);
        assertEquals(30, metricThreadOne.getSum(), 5);
        assertEquals(10, metricThreadOne.getMin(), 5);
        assertEquals(20, metricThreadOne.getMax(), 5);

        assertEquals(1, metricThreadTwo.getCount());
        assertEquals((15.0) / 1.0, metricThreadTwo.getAverage(), 5);
        assertEquals(15, metricThreadTwo.getSum(), 5);
        assertEquals(15, metricThreadTwo.getMin(), 5);
        assertEquals(15, metricThreadTwo.getMax(), 5);
    }

    private <T> T executeSynchronous(Callable<T> task) throws Exception {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        Future<T> result = executor.submit(task);

        return result.get();
    }
}
