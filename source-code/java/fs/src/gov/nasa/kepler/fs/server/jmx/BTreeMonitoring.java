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

package gov.nasa.kepler.fs.server.jmx;

import gov.nasa.kepler.fs.server.index.DiskNodeIO;
import gov.nasa.kepler.fs.server.index.DiskNodeStats;
import gov.nasa.spiffy.common.jmx.AnnotationMBean;
import gov.nasa.spiffy.common.jmx.AttributeDescription;
import gov.nasa.spiffy.common.jmx.AutoTabularType;
import gov.nasa.spiffy.common.jmx.MBeanDescription;
import gov.nasa.spiffy.common.jmx.OperationDescription;
import gov.nasa.spiffy.common.jmx.TabularTypeDescription;
import gov.nasa.spiffy.common.metrics.ValueMetric;

import javax.management.DynamicMBean;
import javax.management.openmbean.OpenDataException;
import javax.management.openmbean.TabularDataSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static gov.nasa.kepler.fs.FileStoreConstants.*;

/**
 * 
 * @author Sean McCauliff
 *
 */
@MBeanDescription("Monitors BTree disk I/O.")
public class BTreeMonitoring extends AnnotationMBean 
    implements DynamicMBean {

    private static final Log log = LogFactory.getLog(BTreeMonitoring.class);
    
    @SuppressWarnings("unchecked")
    @AttributeDescription("How each B-Tree cache performs.")
    public CachePerformance getCachePerformance() throws OpenDataException {
        
        CachePerformance cachePerformance =
            new CachePerformance();
        
        for (DiskNodeIO dio : DiskNodeIO.diskNodeIOs) {
            cachePerformance.put(dio.stats().stats());
        }
        
        return cachePerformance;
    }
        
    @SuppressWarnings("unchecked")
    @OperationDescription("Reset all counters.")
    public void resetAllCacheCounters() {
        for (DiskNodeIO dio : DiskNodeIO.diskNodeIOs) {
            dio.stats().reset();
        }
    }
    
    @TabularTypeDescription(desc="A table of all btree's node i/o cache performance.",
        rowClass=DiskNodeStats.Stats.class)
    public static class CachePerformance extends TabularDataSupport {

        private static final long serialVersionUID = 3384898064669586781L;

        public CachePerformance() throws OpenDataException {
            super(AutoTabularType.newAutoTabularType(CachePerformance.class).tabularType());
        }
    }
    
    public void runMetricsPoller() {
        BTreePerformancePoller poller = 
            new BTreePerformancePoller(60,280, this);
        
        Thread t = new Thread(poller, "BTree Metrics Poller");
        t.setDaemon(true);
        t.start();
    }
    
    private static final class BTreePerformancePoller implements Runnable {
        private final int pollIntervalSeconds;
        private final int resetMetricsSeconds;
        private final BTreeMonitoring monitoring;
        
        public BTreePerformancePoller(int pollIntervalSeconds, int resetIntervalSeconds, BTreeMonitoring monitor) {
            this.pollIntervalSeconds = pollIntervalSeconds;
            this.resetMetricsSeconds = resetIntervalSeconds;
            this.monitoring = monitor;
        }
        
        public void run() {
            try {
                long lastTime = System.currentTimeMillis();
                while (true) {
                    Thread.sleep(pollIntervalSeconds * 1000);
                    
                    sendMetrics();
                    
                    long currTime = System.currentTimeMillis();
                    long timeDiff = currTime - lastTime;
                    if ( (timeDiff / 1000) > resetMetricsSeconds) {
                        monitoring.resetAllCacheCounters();
                    }
                }
            } catch (Throwable t) {
                log.error(t);
            }
        }
        
        @SuppressWarnings("unchecked")
        private void sendMetrics() {
            long totalHits = 0;
            long totalMisses = 0;
            
            for (DiskNodeIO dio : DiskNodeIO.diskNodeIOs) {
                DiskNodeStats.Stats stats = dio.stats().stats();
                totalHits += stats.getHits();
                totalMisses += stats.getMisses();
            }
            double totalNodeIo = totalHits + totalMisses;
            double hitPercent = 0.0;
            if (totalNodeIo != 0 && totalHits != 0) {
                hitPercent = ((double)totalHits )/ totalNodeIo;
                hitPercent *= 100.0;
            }

            
            String metricPrefix = FS_METRICS_PREFIX + ".server.b-tree";
            ValueMetric.addValue(metricPrefix + ".hit-pct", (long) hitPercent);
        }
    }

}
