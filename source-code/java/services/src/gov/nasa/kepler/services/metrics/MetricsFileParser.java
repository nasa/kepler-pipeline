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

package gov.nasa.kepler.services.metrics;

import gov.nasa.kepler.hibernate.metrics.MetricType;
import gov.nasa.kepler.hibernate.metrics.MetricValue;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.metrics.CounterMetric;
import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.util.*;

import com.google.common.collect.Maps;
import com.google.common.collect.Sets;

/**
 * Parses a file containing metrics that have been written with 
 * Metric.getLogString().  One per line.
 * 
 * This class is not MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public class MetricsFileParser {

    private static final int BUFFER_SIZE_BYTES = 1024*1024;
    private static final int TYPE_INDEX = 2;
    private static final int NAME_INDEX = 1;
    private static final int TIMESTAMP_INDEX = 0;
    private static final int VALUE_TYPE_VALUE_INDEX = TYPE_INDEX + 5;
    private static final int COUNTER_TYPE_VALUE_INDEX = TYPE_INDEX + 1;
    
    
    private final File metricsFile;
    private Map<String, MetricMetadata> metricNameToMetricType = Collections.emptyMap();
    private final String metricSource;
    
    
    public MetricsFileParser(File metricsFile) {
        this(metricsFile, "");
    }
    
    public MetricsFileParser(File metricsFile, String metricSource) {
        this.metricsFile = metricsFile;
        this.metricSource = metricSource;
    }
    
    public Iterator<MetricValue> parseFile() throws IOException {
        if (metricNameToMetricType.isEmpty()) {
            types();
        }
        
        return new LineIterator<MetricValue>() {

            @Override
            protected MetricValue parseLine(String line) {
                String[] parts = line.split(",");
                Date timestamp = new Date(Long.parseLong(parts[TIMESTAMP_INDEX]));
                String name = parts[NAME_INDEX];
                String typeStr = parts[TYPE_INDEX];
                float value = (float) Double.parseDouble(parts[metricTypeSwitch(typeStr, VALUE_TYPE_VALUE_INDEX, COUNTER_TYPE_VALUE_INDEX)]);
                MetricType metricType = metricNameToMetricType.get(name).metricType;
                MetricValue metricValue = new MetricValue(metricSource, metricType, timestamp, value);
                return metricValue;
            }
        };
    }
    
    /**
     * Call this after calling parse to get the parsed metrics.
     * @return
     * @throws IOException 
     */
    public Set<MetricType> types() throws IOException {
        metricNameToMetricType = Maps.newHashMap();
        LineIterator<MetricMetadata> typeIt = metricMetadataIterator();
        for (MetricMetadata metadata : typeIt) {
            MetricMetadata oldMetadata = metricNameToMetricType.get(metadata.metricType.getName());
            if (oldMetadata == null) {
                metricNameToMetricType.put(metadata.metricType.getName(), metadata);
            } else {
                Date start = metadata.start.before(oldMetadata.start) ? metadata.start : oldMetadata.start;
                Date end = metadata.end.after(oldMetadata.end) ? metadata.end : metadata.start;
                if (start != oldMetadata.start || end != oldMetadata.end) {
                    MetricMetadata updated = new MetricMetadata(metadata.metricType, start, end);
                    metricNameToMetricType.put(metadata.metricType.getName(), updated);
                }
            }
        }
        
        Set<MetricType> allTypes = Sets.newHashSetWithExpectedSize(metricNameToMetricType.size());
        for (MetricMetadata metadata : metricNameToMetricType.values()) {
            allTypes.add(metadata.metricType);
        }
        return allTypes;
    }
    
    public Map<MetricType, Pair<Date, Date>> getTimestampRange() {
        Map<MetricType, Pair<Date, Date>> rv = Maps.newHashMapWithExpectedSize(metricNameToMetricType.size());
        for (MetricMetadata metadata : metricNameToMetricType.values()) {
            rv.put(metadata.metricType, Pair.of(metadata.start, metadata.end));
        }
        return rv;
    }
    
    private LineIterator<MetricMetadata> metricMetadataIterator() throws IOException {
     
        return new LineIterator<MetricMetadata>() {
            @Override
            protected MetricMetadata parseLine(String line) {
                String[] parts = line.split(",");
                String name = parts[NAME_INDEX];
                String typeStr = parts[TYPE_INDEX];
                int type = metricTypeSwitch(typeStr, MetricType.TYPE_VALUE, MetricType.TYPE_COUNTER);
                Date timestamp = new Date(Long.parseLong(parts[TIMESTAMP_INDEX]));
                MetricType metricType = new MetricType(name, type);
                return new MetricMetadata(metricType, timestamp, timestamp);
            }
        };
    }
    
    private <T> T metricTypeSwitch(String metricTypeStr, T valueCase, T counterCase) {
        if (metricTypeStr.equals(ValueMetric.VALUE_TYPE)) {
            return valueCase;
        } else if (metricTypeStr.equals(CounterMetric.COUNTER_TYPE)) {
            return counterCase;
        } else {
            throw new IllegalStateException("Parse error.  Unknown metric type \"" + metricTypeStr +"\".");
        }
    }
    
    protected Reader openReader() throws IOException {
        return new FileReader(metricsFile);
    }
    
    private abstract class LineIterator<T> implements Iterator<T>, Iterable<T>{
        private String nextLine;
        private final BufferedReader breader;
        
        LineIterator() throws IOException {
            breader = new BufferedReader(openReader(), BUFFER_SIZE_BYTES);
            nextLine = breader.readLine();
        }
        @Override
        public boolean hasNext() {
            return nextLine != null;
        }

        @Override
        public T next() {
            if (nextLine == null) {
                throw new IllegalStateException();
            }
            T rv = parseLine(nextLine);
            try {
                nextLine = breader.readLine();
            } catch (IOException e) {
                throw new IllegalStateException(e);
            }
            if (nextLine == null) {
                FileUtil.close(breader);
            }
            return rv;
        }

        @Override
        public void remove() {
            throw new UnsupportedOperationException();
        }
        
        @Override
        public Iterator<T> iterator() {
            return this;
        }
        
        protected abstract T parseLine(String line);
    }
    
    private static final class MetricMetadata {
        public final MetricType metricType;
        public final Date start;
        public final Date end;
        MetricMetadata(MetricType metricType, Date start, Date end) {
            this.metricType = metricType;
            this.start = start;
            this.end = end;
        }
    }
}
