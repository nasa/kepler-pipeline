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

import static org.junit.Assert.*;
import gov.nasa.kepler.hibernate.metrics.MetricType;
import gov.nasa.kepler.hibernate.metrics.MetricValue;
import gov.nasa.spiffy.common.metrics.CounterMetric;
import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.io.File;
import java.io.IOException;
import java.io.Reader;
import java.io.StringReader;
import java.util.Date;
import java.util.Iterator;

import org.junit.Test;

/**
 * Test the MetricsFileParser
 * 
 * @author Sean McCauliff
 *
 */
public class MetricsFileParserTest {

    @Test
    public void testParse() throws Exception {
        long timestamp = 23432434;
        Date timestampAsDate = new Date(timestamp);
        MetricType mType0 = new MetricType("vm0", MetricType.TYPE_VALUE);
        MetricType mType1 = new MetricType("vm1", MetricType.TYPE_VALUE);
        ValueMetric vm0 = ValueMetric.addValue("vm0", 1);
        ValueMetric vm1 = ValueMetric.addValue("vm1", 314);
        MetricType mType2 = new MetricType("cm0", MetricType.TYPE_COUNTER);
        CounterMetric cm0 = CounterMetric.increment("cm0");

        final StringBuilder testInput = new StringBuilder(1024);
        testInput.append(timestamp).append(',');
        vm0.toLogString(testInput);
        testInput.append('\n');
        testInput.append(timestamp).append(',');
        vm1.toLogString(testInput);
        testInput.append('\n');
        testInput.append(timestamp).append(',');
        cm0.toLogString(testInput);
        testInput.append('\n');
        
        
        MetricsFileParser parser = new MetricsFileParser(new File("bogus")) {
            @Override
            protected Reader openReader() throws IOException {
                return new StringReader(testInput.toString());
            }
        };
        
        Iterator<MetricValue> mvIt = parser.parseFile();
        MetricValue metricValue = mvIt.next();
        assertMetricValue(new MetricValue("", mType0, timestampAsDate, (float) vm0.getAverage()), metricValue);
        metricValue = mvIt.next();
        assertMetricValue(new MetricValue("", mType1, timestampAsDate, (float) vm1.getAverage()), metricValue);
        metricValue = mvIt.next();
        assertMetricValue(new MetricValue("", mType2, timestampAsDate, cm0.getCount()), metricValue);
        assertFalse(mvIt.hasNext());
    }
    
    static void assertMetricValue(MetricValue expected, MetricValue actual) {
        assertEquals(expected.getMetricType(), actual.getMetricType());
        assertEquals(expected.getSource(), actual.getSource());
        assertEquals(expected.getTimestamp(), actual.getTimestamp());
        assertEquals(expected.getValue(), actual.getValue(), 0.001f);
    }
}
