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

package gov.nasa.kepler.fs.perf;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import gov.nasa.spiffy.common.jmx.AnnotationMBean;
import gov.nasa.spiffy.common.jmx.AttributeDescription;
import gov.nasa.spiffy.common.jmx.AutoTabularType;
import gov.nasa.spiffy.common.jmx.MBeanDescription;
import gov.nasa.spiffy.common.jmx.OperationDescription;
import gov.nasa.spiffy.common.jmx.ParameterDescription;
import gov.nasa.spiffy.common.jmx.TabularTypeDescription;

import javax.management.DynamicMBean;
import javax.management.NotCompliantMBeanException;
import javax.management.openmbean.OpenDataException;
import javax.management.openmbean.TabularDataSupport;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * A way to control the file store performance counters.
 * 
 * @author Sean McCauliff
 *
 */
@MBeanDescription("A bean to list and modify reporting interval of performance metrics.")
public class PerformanceCounterMBean extends AnnotationMBean implements
    DynamicMBean {

    private static final Log log = LogFactory.getLog(PerformanceCounterMBean.class);
    
    private static PerformanceCounterMBean instance;
  
    private Map<String, InstrumentedMetric> instrumentedMetrics = 
        Collections.synchronizedMap(new HashMap<String, InstrumentedMetric>());
    
    public synchronized static PerformanceCounterMBean instance() throws NotCompliantMBeanException {
        if (instance == null) {
            instance = new PerformanceCounterMBean();
        }
        return instance;
    }
    
    public PerformanceCounterMBean() throws NotCompliantMBeanException {
        super();
    }
    
    @AttributeDescription("Instrumented Metrics")
    public InstrumentedMetricTabularData getInstrumentedMetrics() throws Exception {
        List<InstrumentedMetric> imetricList = null;
        synchronized (instrumentedMetrics) {
            imetricList = new ArrayList<InstrumentedMetric>(instrumentedMetrics.values());
        }
        Collections.sort(imetricList, new Comparator<InstrumentedMetric>() {

            @Override
            public int compare(InstrumentedMetric o1, InstrumentedMetric o2) {
                return o1.name().compareTo(o2.name());
            }
            
        });
        
        InstrumentedMetricTabularData table = new InstrumentedMetricTabularData();
        for (InstrumentedMetric imetric : imetricList) {
            table.put(new InstrumentedMetricInfo(imetric.name(), imetric.getReportingInterval()));
        }
        return table;
    }
    
    @OperationDescription("Set the reporting interval on a instrumented metric.")
    public void setReportingInterval(
            @ParameterDescription(desc="The name of the metric to modify.", name="name") String name, 
            @ParameterDescription(desc="The new reporting interval.", name="newReportingInterval") int newReportingInterval) {
        InstrumentedMetric imetric = instrumentedMetrics.get(name);
        if (imetric == null) {
            log.error("imetric " + name + " does not exist.");
            throw new IllegalArgumentException("imetric \"" + name + "\" not present.");
        }
        if (newReportingInterval < 0) {
            throw new IllegalArgumentException("newReportingInterval is too small");
        }
        imetric.setReportingInterval(newReportingInterval);
        
    }
    
    public void registerInstrumentedMetric(InstrumentedMetric imetric) {
        instrumentedMetrics.put(imetric.name(), imetric);
    }
    
    @TabularTypeDescription(desc="A table of all the classes that have been instrumented with metrics.",
        rowClass=InstrumentedMetricInfo.class)
    public static class InstrumentedMetricTabularData extends TabularDataSupport {
        
        private static final long serialVersionUID = -8195715195223255050L;

        public InstrumentedMetricTabularData() throws OpenDataException {
            super(AutoTabularType.newAutoTabularType(InstrumentedMetricTabularData.class).tabularType());
            
        }
    }
}
