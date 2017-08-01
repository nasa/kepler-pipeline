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

import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.metrics.MetricType;
import gov.nasa.kepler.hibernate.metrics.MetricValue;
import gov.nasa.kepler.hibernate.metrics.MetricsCrud;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.kepler.services.process.MetricsStatusMessage;
import gov.nasa.kepler.services.process.ProcessStatusReporter;
import gov.nasa.spiffy.common.metrics.CounterMetric;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class listens for {@link MetricsStatusMessage} JMS messages and stores
 * them in a Derby database.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class MetricsLogger extends AbstractPipelineProcess implements MetricSampleListener{
    private static final Log log = LogFactory.getLog(MetricsLogger.class);

    public static final String NAME = "MetricsLogger";
    
    private DatabaseService databaseService;

    private Map<String, MetricType> metricTypes = new HashMap<String, MetricType>();
    private MetricsCrud metricsCrud;

    private MetricsSnapshotHandler metricsSnapshotHandler;
    private MetricsReaperThread metricsReaperThread;

    public MetricsLogger() {
        super(NAME);
    }

    public void go() {
        try {
            log.info("MetricsLogger: INITIALIZING...");

            initialize();

            updateProcessState(ProcessStatusReporter.State.INITIALIZING);
            
            metricsReaperThread = new MetricsReaperThread();
            metricsReaperThread.start();
            
            databaseService = DatabaseServiceFactory.getInstance();
            metricsCrud = new MetricsCrud(databaseService);

            loadTypes();

            metricsSnapshotHandler = new MetricsSnapshotHandler();
            metricsSnapshotHandler.addListener(this);
            metricsSnapshotHandler.go();

            log.info("MetricsLogger: listener started");
           
            updateProcessState(ProcessStatusReporter.State.RUNNING);
            
        } catch (Exception e) {
            log.fatal("Initialization failed!", e);
            System.exit(-1);
        }
    }

    public void loadTypes() {

        List<MetricType> storedTypes = metricsCrud.retrieveAllMetricTypes();

        for (MetricType mt : storedTypes) {
            metricTypes.put(mt.getName(), mt);
        }
    }

    @Override
    public void newSample(MetricSample metricSample) {
        try {
            
            databaseService.beginTransaction();
            
            String metricName = metricSample.getMetricName();
            MetricType type = metricTypes.get(metricName);
            
            if (type == null) {
                // new type
                int typeCode = ((metricSample.getMetricClass().equals(CounterMetric.class)) ? MetricType.TYPE_COUNTER : MetricType.TYPE_VALUE);
                type = new MetricType(metricName, typeCode);
                if(log.isDebugEnabled()) {
                    log.debug("creating new type: " + type);
                }
                metricsCrud.createMetricType(type);
                metricTypes.put(metricName, type);
            }

            MetricValue metricValue = new MetricValue(metricSample.getSource(), type, metricSample.getTimestamp(), metricSample.getValue());
            log.info("storing metricValue=" + metricValue);
            metricsCrud.createMetricValue(metricValue);
            
            databaseService.commitTransaction();
            
        } catch (Throwable t) {
            log.error("failed to process metricSample: " + metricSample, t);
            try {
                databaseService.rollbackTransactionIfActive();
            } catch (Exception rollbackException) {
                log.error("failed to rollback database transaction", rollbackException);
            }
        }
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        MetricsLogger metricsLogger = new MetricsLogger();
        metricsLogger.go();
    }
}
