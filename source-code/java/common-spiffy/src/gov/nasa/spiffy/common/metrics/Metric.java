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

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.PrintWriter;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Logger;

/**
 * 
 * Base class for all metrics.
 * 
 * @created June 13, 2005
 * @author todd.klaus
 */
public abstract class Metric implements Serializable {
    private static final Log log = LogFactory.getLog(Metric.class);
    
    private static final long serialVersionUID = -2723751150597278137L;

    private static Logger metricsLogger = Logger.getLogger("metrics.logger");

    private static ConcurrentMap<String, Metric> globalMetrics = new ConcurrentHashMap<String, Metric>();
    private static ThreadLocal<Map<String, Metric>> threadMetrics = new ThreadLocal<Map<String, Metric>>();

    protected String name = null;

    /**
     * 
     * get the name of this metric
     * 
     * @created June 13, 2005
     * @return
     */
    public String getName() {
        return name;
    }

    /**
     * @return Returns the map of global metrics.
     */
    public static Map<String, Metric> getGlobalMetricsSnapshot() {
        HashMap<String, Metric> metricsCopy = new HashMap<String, Metric>();

        for (String metricName : globalMetrics.keySet()) {
            Metric metricCopy = globalMetrics.get(metricName)
                .makeCopy();
            metricsCopy.put(metricName, metricCopy);
        }
        return metricsCopy;
    }

    /**
     * Returns the map of thread metrics for the calling thread. May be null if
     * thread metrics have not been enabled for the calling thread.
     * 
     * @return Map of metrics for the calling thread
     */
    public static Map<String, Metric> getThreadMetrics() {
        return threadMetrics.get();
    }

    /**
     * 
     * Iterate over the metric names
     * 
     * @created June 13, 2005
     * @return
     */
    public static Iterator<String> metricsIterator() {
        return globalMetrics.keySet()
            .iterator();
    }

    /**
     * 
     * Iterate over the metric names that start with the specified String
     * 
     * @created June 13, 2005
     * @return
     */
    public static Iterator<String> metricsIterator(String startsWith) {
        return new StartsWithIterator(globalMetrics.keySet()
            .iterator(), startsWith);
    }

    /**
     * 
     * clear the map
     * 
     * @created June 13, 2005
     * 
     */
    public static void clear() {
        globalMetrics = new ConcurrentHashMap<String, Metric>();
        threadMetrics = new ThreadLocal<Map<String, Metric>>();
    }

    /**
     * 
     * log all metrics to the log4j Logger
     * 
     * @created June 13, 2005
     * @param prefix
     */
    public static void log() {
        long now = System.currentTimeMillis();
        metricsLogger.info("SNAPSHOT-START@" + now);

        Iterator<String> it = Metric.metricsIterator();
        logWithIterator(it);

        metricsLogger.info("SNAPSHOT-END@" + now);
    }

    /**
     * Dump all metrics to stdout
     * 
     */
    public static void dump() {
        Metric.dump(new PrintWriter(System.out));
    }
    
    /**
     * Dump all metrics to specified writer
     * 
     * @param stream
     */
    public static void dump(PrintWriter writer) {
        Set<String> names = globalMetrics.keySet();

        for (String name : names) {
            Metric metric = Metric.getGlobalMetric(name);
            StringBuilder bldr = new StringBuilder(128);
            bldr.append(System.currentTimeMillis()).append(',');
            metric.toLogString(bldr);
            writer.println(bldr.toString());
        }
    }


    /**
     * @see toLogString
     * @return
     */
    public final String getLogString() {
        StringBuilder bldr = new StringBuilder(64);
        toLogString(bldr);
        return bldr.toString();
    }
    
    /**
     * 
     * Must be implemented by subclasses. Should return a String representation
     * of the metrics which includes the type in the following comma separated
     * format: (type),(metric values ...)
     * 
     * For example, a ValueMetric (min, max, count, sum) might look like this:
     * 
     * V,0,100,42,12
     * 
     * Writes the string getLogString() to the specified string builder.
     * @param bldr non-null
     */
    public abstract void toLogString(StringBuilder bldr);

    /**
     * Persist the current set of global metrics to a file using Java
     * serialization.
     * 
     * Used to transfer metrics collected in a sub-process to the parent
     * process.
     * 
     * @param directory
     * @throws IOException
     */
    public static void persist(String path) throws IOException {
        File file = new File(path);

        if (file.isDirectory()) {
            throw new IllegalArgumentException("Specified file is a directory: " + file);
        }

        ObjectOutputStream output = new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(file)));
        
        try {
            output.writeObject(globalMetrics);
        } finally {
            output.close();
        }

    }

    /**
     * Load a set of metrics from a file using Java serialization. The loaded
     * metrics are then merged with the current set of metrics.
     * 
     * Used to transfer metrics collected in a sub-process to the parent
     * process.
     * 
     * @param directory
     * @throws Exception 
     */
    public static void merge(String path) throws Exception {
        File file = new File(path);
        
        if (file.isDirectory()) {
            throw new IllegalArgumentException("Specified file is a directory: " + file);
        }

        Map<String, Metric> metricsToMerge = loadMetricsFromSerializedFile(file);
        
        for (String metricName : metricsToMerge.keySet()) {
            Metric metricToMerge = metricsToMerge.get(metricName);

            log.debug("merge: metricToMerge=" + metricToMerge);
            
            Metric existingGlobalMetric = globalMetrics.get(metricName);
            if(existingGlobalMetric != null){
                log.debug("merge: existingGlobalMetric(BEFORE)=" + existingGlobalMetric);
                existingGlobalMetric.merge(metricToMerge);
                log.debug("merge: existingGlobalMetric(AFTER)=" + existingGlobalMetric);
            }else{
                log.debug("No existingGlobalMetric exists, adding");
                globalMetrics.put(metricName, metricToMerge.makeCopy());
            }

            if(Metric.threadMetricsEnabled()){
                Metric existingThreadMetric = Metric.getThreadMetric(metricName);
                if (existingThreadMetric != null) {
                    log.debug("merge: existingThreadMetric(BEFORE)=" + existingThreadMetric);
                    existingThreadMetric.merge(metricToMerge);
                    log.debug("merge: existingThreadMetric(AFTER)=" + existingThreadMetric);
                }else{
                    log.debug("No existingThreadMetric exists, adding");
                    Metric.addNewThreadMetric(metricToMerge.makeCopy());
                }
            }
        }
    }
    
    /**
     * Load a Metrics map from a serialized (*.ser) file.
     * 
     * @param path
     * @return
     */
    public static Map<String, Metric> loadMetricsFromSerializedFile(File file) throws Exception {
        ObjectInputStream input = new ObjectInputStream(new BufferedInputStream(new FileInputStream(file)));
        Map<String, Metric> metrics = null;
        
        try {
            metrics = (Map<String, Metric>) input.readObject();
            return metrics;
        } finally {
            input.close();
        }
    }
    
    /**
     * Merge another metric (typically from a subprocess) with an existing metric.
     * 
     * @param other
     */
    public abstract void merge(Metric other);
        
    /**
     * Make a copy of the Metric
     * 
     * @return
     */
    public abstract Metric makeCopy();

    /**
     * 
     * Constructor
     * 
     * Subclass ctors must call setName()
     * 
     * @created June 13, 2005
     * @param name
     */
    protected Metric() {
    }

    protected void setName(String name) {
        if (name == null) {
            throw new NullPointerException("Metric name must not be null!");
        }
        this.name = name;
    }

    /**
     * 
     * static accessor to get a metric by name
     * 
     * @created June 13, 2005
     * @param name
     * @return
     */
    protected static Metric getGlobalMetric(String name) {
        return globalMetrics.get(name);
    }

    /**
     * 
     * static accessor to get a metric by name
     * 
     * @created June 13, 2005
     * @param name
     * @return
     */
    protected static Metric getThreadMetric(String name) {
        Map<String, Metric> threadMap = threadMetrics.get();

        if (threadMap != null) {
            return threadMap.get(name);
        } else {
            return null;
        }
    }

    protected static boolean threadMetricsEnabled() {
        return (threadMetrics.get() != null);
    }

    /**
     * Enables collection of metrics at the thread level and initializes them.
     * 
     * Thread metrics are collected in a separate map from global metrics
     * addition to the collection of metrics at the JVM level (global).
     */
    public static void enableThreadMetrics() {
        HashMap<String, Metric> threadMap = new HashMap<String, Metric>();
        threadMetrics.set(threadMap);
    }

    /**
     * Disables collection of metrics at the thread level.
     */
    public static void disableThreadMetrics() {
        threadMetrics.remove();
    }

    /**
     * 
     * Add a new global metric to the map.  This uses ConcurrentMap.putIfAbsent
     * which can be slow.  You might want to check if the metric is in the map
     * beforehand.
     * 
     * @created June 13, 2005
     * @param metric
     * @return this metric may not be identical to the given metric in the
     * concurrent case.
     */
    protected static Metric addNewGlobalMetric(Metric metric) {
        if (metric != null) {
            String metricName = metric.getName();
            globalMetrics.putIfAbsent(metricName, metric);
            metric = globalMetrics.get(metricName);
        }
        return metric;
    }

    /**
     * 
     * Add a new thread metric to the map.
     * 
     * @created June 13, 2005
     * @param metric
     * @return
     */
    protected static Metric addNewThreadMetric(Metric metric) {
        if (metric != null) {
            Map<String, Metric> threadMap = threadMetrics.get();
            if (threadMap != null) {
                threadMap.put(metric.getName(), metric);
            }
        }
        return metric;
    }

    /**
     * 
     * Log all metrics whose name starts with the specified prefix to the log4j
     * Logger
     * 
     * @created June 13, 2005
     * @param prefix
     */
    protected static void log(String prefix) {
        long now = System.currentTimeMillis();
        metricsLogger.info("SNAPSHOT-START@" + now);

        Iterator<String> it = Metric.metricsIterator(prefix);
        logWithIterator(it);

        metricsLogger.info("SNAPSHOT-END@" + now);
    }

    /**
     * 
     * Log all metrics whose name starts with the specified prefixes to the
     * log4j Logger
     * 
     * @created June 13, 2005
     * @param prefix
     */
    protected static void log(List<String> prefixes) {
        long now = System.currentTimeMillis();
        metricsLogger.info("SNAPSHOT-START@" + now);

        Iterator<String> prefixIt = prefixes.iterator();
        while (prefixIt.hasNext()) {
            String prefix = prefixIt.next();
            Iterator<String> it = Metric.metricsIterator(prefix);
            logWithIterator(it);
        }

        metricsLogger.info("SNAPSHOT-END@" + now);
    }

    /**
     * 
     * Log using the specified iterator
     * 
     * @created June 13, 2005
     * @param it
     */
    protected static void logWithIterator(Iterator<String> it) {
        while (it.hasNext()) {
            String name = it.next();
            Metric metric = Metric.getGlobalMetric(name);
            metricsLogger.debug(metric.getName() + ":" + metric.getLogString());
        }
    }

    /**
     * reset metric
     * 
     * @created June 13, 2005
     */
    protected abstract void reset();

    public static class StartsWithIterator implements Iterator<String> {
        private final Iterator<String> it;

        private final String startsWith;

        private String currentValue = null;

        StartsWithIterator(Iterator<String> it, String startsWith) {
            this.it = it;
            this.startsWith = startsWith;
        }

        @Override
        public boolean hasNext() {
            if (!it.hasNext()) {
                return false;
            }
            while (it.hasNext() && (currentValue == null)) {
                String metricName = it.next();
                if (metricName.startsWith(startsWith)) {
                    currentValue = metricName;
                }
            }
            return currentValue != null;
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException("this is a read-only iterator");
        }

        @Override
        public String next() {
            try {
                return currentValue;
            } finally {
                currentValue = null;
            }
        }
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((name == null) ? 0 : name.hashCode());
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
        final Metric other = (Metric) obj;
        if (name == null) {
            if (other.name != null)
                return false;
        } else if (!name.equals(other.name))
            return false;
        return true;
    }

}
