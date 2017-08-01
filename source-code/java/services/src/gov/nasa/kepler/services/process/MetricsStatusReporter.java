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

package gov.nasa.kepler.services.process;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.spiffy.common.metrics.Metric;
import gov.nasa.spiffy.common.metrics.ValueMetric;
import gov.nasa.spiffy.common.os.MemInfo;
import gov.nasa.spiffy.common.os.OperatingSystemType;

import java.util.HashMap;
import java.util.Map;

import org.apache.commons.configuration.Configuration;

/**
 * {@link StatusReporter} that generates {@link MetricsStatusMessage}s
 * that contain a snapshot of the metrics database for this process
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class MetricsStatusReporter implements StatusReporter {

    private static final String MEMORY_METRIC_PREFIX = "os.meminfo";
    public static final String MEMORY_METRICS_UPDATE_INTERVAL_MILLIS_PROP = "process.memoryMetricsUpdateIntervalMillis";
    public static final int MEMORY_METRICS_UPDATE_INTERVAL_MILLIS_DEFAULT = 60 * 10 * 1000; // 10 min.

    private int memoryMetricsUpdateIntervalMillis = 0;
    private long lastMemoryMetricsUpdate = 0;
    
    private Map<String, Metric> previousSnapshot = new HashMap<String, Metric>();
    
    public MetricsStatusReporter() {
        Configuration configService = ConfigurationServiceFactory.getInstance();
        memoryMetricsUpdateIntervalMillis = configService.getInt(MEMORY_METRICS_UPDATE_INTERVAL_MILLIS_PROP, 
            MEMORY_METRICS_UPDATE_INTERVAL_MILLIS_DEFAULT);
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.services.process.StatusReporter#reportCurrentStatus()
     */
    @Override
    public StatusMessage reportCurrentStatus() {
        /* Disable for now since the memory metrics dominate the table and cause other
           useful metrics to be aged out too quickly.  Once we add per-metric maxRow limits,
           we can turn this back on.
         */
        //updateMemoryMetrics();

        Map<String, Metric> currentSnapshot = Metric.getGlobalMetricsSnapshot();
        Map<String, Metric> snapshotToSend = new HashMap<String, Metric>();        
        
        for (String metricKey : currentSnapshot.keySet()) {
            Metric currentMetric = currentSnapshot.get(metricKey);
            Metric previousMetric = previousSnapshot.get(metricKey);
            
            if(previousMetric == null || (!currentMetric.equals(previousMetric))){
                snapshotToSend.put(metricKey, currentMetric);
            }
        }
        
        MetricsStatusMessage m = new MetricsStatusMessage(System.currentTimeMillis(), currentSnapshot);

        // TODO: uncomment this line and remove the line above once the logger is modified to 
        //       remove filtering based on change (filtering is done here now)
        //MetricsStatusMessage m = new MetricsStatusMessage(System.currentTimeMillis(), snapshotToSend);
        
        previousSnapshot = currentSnapshot;
        
        return m;
    }

    @SuppressWarnings("unused")
    private void updateMemoryMetrics() {
        long now = System.currentTimeMillis();
        
        if(now - lastMemoryMetricsUpdate >= memoryMetricsUpdateIntervalMillis){
            try {
                MemInfo memInfo = OperatingSystemType.getInstance().getMemInfo();
                long usedMemoryKb = memInfo.getTotalMemoryKB() - memInfo.getFreeMemoryKB();
                long usedSwapKb = memInfo.getTotalSwapKB() - memInfo.getFreeSwapKB();
                
                ValueMetric.addValue(MEMORY_METRIC_PREFIX + ".usedMemoryKb", usedMemoryKb);
                ValueMetric.addValue(MEMORY_METRIC_PREFIX + ".usedSwapKb", usedSwapKb);
                ValueMetric.addValue(MEMORY_METRIC_PREFIX + ".buffersKb", memInfo.getBuffersKB());
                ValueMetric.addValue(MEMORY_METRIC_PREFIX + ".cachedKb", memInfo.getCachedKB());
                ValueMetric.addValue(MEMORY_METRIC_PREFIX + ".cachedSwapKb", memInfo.getCachedSwapedKB());
                
            } catch (Exception ignore) {
            }

            lastMemoryMetricsUpdate = now;
        }
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.services.process.StatusReporter#destination()
     */
    @Override
    public String destination() {
        return MessagingDestinations.PIPELINE_METRICS_DESTINATION;
    }
}
