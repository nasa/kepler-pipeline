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

package gov.nasa.kepler.services.metrics.logger;

import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.process.MetricsStatusMessage;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.kepler.services.process.StatusMessage;
import gov.nasa.kepler.services.process.StatusMessageHandler;
import gov.nasa.kepler.services.process.StatusMessageListener;
import gov.nasa.spiffy.common.metrics.CounterMetric;
import gov.nasa.spiffy.common.metrics.Metric;
import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class converts a stream of metrics snapshots (raw sum & count values)
 * from the {@link StatusMessageListener} into time series samples by computing
 * the differences between snapshots and passes them on to registered
 * {@link MetricSampleListener}s
 * 
 * Unchanged metrics are filtered out to reduce the amount of data passed to the
 * registered listeners
 * 
 * Use cases include the {@link MetricsLogger} and the live metrics view in the
 * PIG.
 * 
 * @author tklaus
 * 
 */
public class MetricsSnapshotHandler implements StatusMessageHandler {
    private static final Log log = LogFactory.getLog(MetricsSnapshotHandler.class);

    private static final int REPORT_INTERVAL_MILLIS = 5 * 60 * 1000; // 5mins

    private StatusMessageListener statusMessageListener = new StatusMessageListener(MessagingDestinations.PIPELINE_METRICS_DESTINATION);
    private Map<String, PreviousMetricSample> mostRecentValues = new HashMap<String, PreviousMetricSample>();
    private List<MetricSampleListener> listeners = new ArrayList<MetricSampleListener>();
    private long lastReport = System.currentTimeMillis();
    private int numMessagesSinceLastReport = 0;

    public MetricsSnapshotHandler() {
    }

    public void go() {
        statusMessageListener.addProcessStatusHandler(this);
        statusMessageListener.start();
    }

    @Override
    public void handleMessage(StatusMessage statusMessage) {
        if(statusMessage instanceof MetricsStatusMessage){
            numMessagesSinceLastReport++;
            MetricsStatusMessage message = (MetricsStatusMessage) statusMessage;
            log.debug("got a MSM from " + message.getSourceProcess());
            Map<String, Metric> metrics = message.getMetricsSnapshot();

            for (Metric metric : metrics.values()) {
                log.debug(metric.getName() + ":" + metric.getLogString());

                processMetric(message.getSourceProcess(), message.getTimestamp(), metric);
            }

            long now = System.currentTimeMillis();
            if((now - lastReport) > REPORT_INTERVAL_MILLIS){
                log.info("Recieved " + numMessagesSinceLastReport + " MSMs since " + new Date(lastReport));
                lastReport = now;
                numMessagesSinceLastReport = 0;
            }
        }
    }

    /**
     * 
     * @param pm
     * @param processName
     * @param timestamp
     * @param metric
     */
    public void processMetric(ProcessInfo processName, long timestamp, Metric metric) {

        String source = processName.getHost() + ":" + processName.getPid();

        int newCount = 0;
        long newSum = 0;

        if (metric instanceof CounterMetric) {
            CounterMetric cm = (CounterMetric) metric;
            newCount = cm.getCount();
        } else {
            ValueMetric vm = (ValueMetric) metric;
            newCount = vm.getCount();
            newSum = vm.getSum();
        }

        // log.debug("count=" + count + ", sum=" + sum);

        String key = processName + ":" + metric.getName();
        PreviousMetricSample previousValue = mostRecentValues.get(key);

        if (previousValue == null) {
            // first time we have seen this metric from this source
            previousValue = new PreviousMetricSample();
            previousValue.previousCount = newCount;
            previousValue.previousSum = newSum;

            mostRecentValues.put(key, previousValue);
        } else {
            /*
             * we have at least one previous value, so we can compute a new
             * sample. A sample is the delta between this message and the last
             * message for this metric from the same source. The way the delta
             * is computed depends on the metric type.
             */
            float newSample = 0.0f;

            if (newCount > previousValue.previousCount) {
                // the metric has changed since the last message
                if (newSum > 0) {
                    // ValueMetric
                    newSample = ((float) (newSum - previousValue.previousSum))
                        / ((float) (newCount - previousValue.previousCount));
                } else {
                    // CounterMetric
                    newSample = newCount - previousValue.previousCount;
                }
            }

            /*
             * The metrics report is broadcast by every pipeline process at
             * regular intervals, whether the values have changed or not. To
             * prevent the storage of many redundant samples when the value for
             * a particular metric is not changing, we don't store a new sample
             * if the current sample is zero and the last sample we saved was
             * zero (to ensure that we store the first zero sample so we can see
             * when the metric became quiescent).
             */
            if (previousValue.previousCount == newCount) {
                // no changes since the last update
                previousValue.lastReceivedTimestamp = timestamp;
            } else {
                if (log.isDebugEnabled()) {
                    log.debug("newSample=" + newSample);
                }

                // store the sample
                MetricSample metricSample = new MetricSample(metric.getName(), metric.getClass(), source, new Date(
                    timestamp), newSample);
                notifyListeners(metricSample);

                previousValue.lastStoredSample = newSample;
                previousValue.lastStoredTimestamp = timestamp;
            }
        }

        previousValue.previousCount = newCount;
        previousValue.previousSum = newSum;
    }

    private void notifyListeners(MetricSample metricSample) {
        for (MetricSampleListener listener : listeners) {
            listener.newSample(metricSample);
        }
    }

    public boolean addListener(MetricSampleListener listener) {
        return listeners.add(listener);
    }

    public void clearListeners() {
        listeners.clear();
    }

    public boolean removeListener(MetricSampleListener listener) {
        return listeners.remove(listener);
    }

    /**
     * Holds the most recently received value for a particular metric.
     */
    class PreviousMetricSample {
        public int previousCount;
        public long previousSum;

        public float lastStoredSample;
        public long lastStoredTimestamp;
        public long lastReceivedTimestamp;
    }
}
