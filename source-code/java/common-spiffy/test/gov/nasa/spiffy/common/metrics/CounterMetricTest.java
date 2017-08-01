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
public class CounterMetricTest {
    private static final String METRIC_1_NAME = "MetricsTest-1";

    @Before
    public void setUp() {
        Metric.clear();
    }

    @Test
    public void testCounterMetricSimple() throws Exception {
        CounterMetric m = CounterMetric.getCounterMetric(METRIC_1_NAME).left;

        CounterMetric.increment(METRIC_1_NAME);

        m = CounterMetric.getCounterMetric(METRIC_1_NAME).left;

        assertEquals(1, m.getCount());
    }

    @Test
    public void testCounterMetricMultiple() throws Exception {
        CounterMetric.increment(METRIC_1_NAME);
        CounterMetric.increment(METRIC_1_NAME);
        CounterMetric.increment(METRIC_1_NAME);
        CounterMetric.decrement(METRIC_1_NAME);
        CounterMetric.increment(METRIC_1_NAME);

        CounterMetric m = CounterMetric.getCounterMetric(METRIC_1_NAME).left;

        assertEquals(3, m.getCount());
    }

    @Test
    public void testCounterMetricMultiThread() throws Exception {
        Map<String, Metric> threadOneMetrics = executeSynchronous(new Callable<Map<String, Metric>>() {
            @Override
            public Map<String, Metric> call() {
                Metric.enableThreadMetrics();

                CounterMetric.increment(METRIC_1_NAME);
                CounterMetric.increment(METRIC_1_NAME);

                return Metric.getThreadMetrics();
            }
        });

        Map<String, Metric> threadTwoMetrics = executeSynchronous(new Callable<Map<String, Metric>>() {
            @Override
            public Map<String, Metric> call() {
                Metric.enableThreadMetrics();

                CounterMetric.increment(METRIC_1_NAME);

                return Metric.getThreadMetrics();
            }
        });

        CounterMetric metricGlobal = CounterMetric.getCounterMetric(METRIC_1_NAME).left;
        CounterMetric metricThreadOne = (CounterMetric) threadOneMetrics.get(METRIC_1_NAME);
        CounterMetric metricThreadTwo = (CounterMetric) threadTwoMetrics.get(METRIC_1_NAME);

        assertEquals(3, metricGlobal.getCount());
        assertEquals(2, metricThreadOne.getCount());
        assertEquals(1, metricThreadTwo.getCount());
    }

    private <T> T executeSynchronous(Callable<T> task) throws Exception {
        ExecutorService executor = Executors.newSingleThreadExecutor();
        Future<T> result = executor.submit(task);

        return result.get();
    }
}
