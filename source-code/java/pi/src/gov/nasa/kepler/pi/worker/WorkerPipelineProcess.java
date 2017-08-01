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

package gov.nasa.kepler.pi.worker;

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud.ClearStaleStateResults;
import gov.nasa.kepler.pi.module.MatlabMcrExecutable;
import gov.nasa.kepler.pi.module.WorkerMemoryManager;
import gov.nasa.kepler.pi.pipeline.PipelineExecutor;
import gov.nasa.kepler.services.process.AbstractPipelineProcess;
import gov.nasa.kepler.services.process.ProcessStatusReporter;
import gov.nasa.spiffy.common.metrics.MetricsDumper;

import java.io.File;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 * 
 */
public class WorkerPipelineProcess extends AbstractPipelineProcess {

    public static final String NAME = "Worker";

    private static final Log log = LogFactory.getLog(WorkerPipelineProcess.class);

    private static final String NUM_WORKER_THREADS_PROP = "pi.worker.numTaskThreads";
    private static final int NUM_WORKER_THREADS_DEFAULT = 1;

    public static final String WORKER_STATUS_REPORT_INTERVAL_MILLIS_PROP = "services.statusReport.workerThread.reportIntervalMillis";
    public static final int WORKER_STATUS_REPORT_INTERVAL_MILLIS_DEFAULT = 15000;
    
    private static final String WORKER_CLEAN_TMP_AT_STARTUP_PROP = "pi.worker.cleanTmp.enabled";
    private static final boolean WORKER_CLEAN_TMP_AT_STARTUP_DEFAULT = false;
    
    private PipelineInstanceQueuePool queueList = null;
    private WorkerMemoryManager memoryManager = null;
    
    public WorkerPipelineProcess() {
        super(NAME);
    }

    public WorkerPipelineProcess(boolean messaging,
        boolean database) {
        super(NAME, messaging, database);
    }

    public void go() {
        try {
            initialize();

            Configuration config = ConfigurationServiceFactory.getInstance();

            clearStaleTaskStates(getProcessInfo().getHost());

            clearTemporaryDirs();
            
            queueList = new PipelineInstanceQueuePool();
            try {
                memoryManager = new WorkerMemoryManager();
            } catch (IOException e) {
                log.warn("unable to determine system physical memory, disabling memory manager", e);
            }
            
            int numTaskThreads = WorkerThreadConfig.numThreads(getProcessInfo().getHost(), config.getInt(NUM_WORKER_THREADS_PROP,
                NUM_WORKER_THREADS_DEFAULT));

            if(numTaskThreads == 0){
                // use # of cores
                int availableProcessors = Runtime.getRuntime().availableProcessors();

                log.info("Setting number of worker threads to number of available processors ("
                    +availableProcessors+")");
                
                numTaskThreads = availableProcessors;
            }
            
            updateProcessState(ProcessStatusReporter.State.WAITING_FOR_FS);
            verifyFilestoreConnectivity();
            updateProcessState(ProcessStatusReporter.State.INITIALIZING);
            
            log.info("Starting " + numTaskThreads + " worker task threads");
            List<WorkerTaskRequestListener> workerThreads = new LinkedList<WorkerTaskRequestListener>();
            
            for (int i = 0; i < numTaskThreads; i++) {
                log.info("Starting worker task thread #" + i);
                WorkerTaskRequestListener workerThread = new WorkerTaskRequestListener(
                    getProcessInfo(), i, queueList, memoryManager);

                /*
                 * Add this taskHandler to the ProcessStatusBroadcaster so that
                 * it will be periodically queried for state
                 */
                int workerReportIntervalMillis = config.getInt(WORKER_STATUS_REPORT_INTERVAL_MILLIS_PROP, 
                    WORKER_STATUS_REPORT_INTERVAL_MILLIS_DEFAULT);
                addProcessStatusReporter(workerThread.getTaskDispatcher(), workerReportIntervalMillis);

                workerThread.start();
                
                workerThreads.add(workerThread);
            }
            
            log.info("Adding shutdown hook");
            Runtime.getRuntime().addShutdownHook(new WorkerShutdownHook(getProcessInfo().getPid(), workerThreads));
            
            log.info("Starting metrics dumper thread...");
            MetricsDumper metricsDumper = new MetricsDumper(AbstractPipelineProcess.getProcessInfo().getPid());
            new Thread(metricsDumper, "MetricsDumper").start();        
            
            updateProcessState(ProcessStatusReporter.State.RUNNING);
            
        } catch (Exception e) {
            log.fatal("Initialization failed!", e);
            System.exit(-1);
        }
    }
    
    private void clearTemporaryDirs() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        boolean enabled = config.getBoolean(WORKER_CLEAN_TMP_AT_STARTUP_PROP, WORKER_CLEAN_TMP_AT_STARTUP_DEFAULT);
        
        if(enabled){
            log.info("Cleaning worker tmp dir");
            
            try {
                String dataDirPath = config.getString(MatlabMcrExecutable.MODULE_EXE_DATA_DIR_PROPERTY_NAME);
                File dataDir = new File(dataDirPath);
                
                FileUtils.cleanDirectory(dataDir);
            } catch (IOException e) {
                log.warn("Failed to clean worker tmp dir, caught e = " + e, e);
            }
        }
    }

    /**
     * Set the state to ERROR for all tasks assigned to this worker
     * where the state is currently PROCESSING.  Used at worker startup
     * to reset the state after an abnormal worker exit while processing.
     * 
     * @param workerHost
     */
    public void clearStaleTaskStates(String workerHost) {

        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        ClearStaleStateResults clearStateResults;

        /* Set the pipeline task state to ERROR for any tasks assigned to this
         * worker that are in the PROCESSING state.  This condition indicates that
         * the previous instance of the worker process on this host died abnormally */
        try {
            databaseService.beginTransaction();

            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
            clearStateResults = pipelineTaskCrud.clearStaleState(workerHost);
            
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
        
        /* Update the pipeline instance state for the instances associated with the stale
         * tasks from above since that change may result in a change to the instances */
        try {
            databaseService.beginTransaction();

            PipelineExecutor pe = new PipelineExecutor();
            PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud();
            
            for (Integer instanceId : clearStateResults.uniqueInstanceIds) {
                log.info("Updating instance state for instanceId = " + instanceId);
                PipelineInstance instance = instanceCrud.retrieve(instanceId);
                pe.updateInstanceState(instance);
            }
            
            databaseService.commitTransaction();
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    
    /**
     * Verify that the filestore is reachable
     */
    private void verifyFilestoreConnectivity() {
        int retryCount = 0;
        
        while(true){
            try {
                FileStoreClientFactory.getInstance().ping();
                return;
            } catch (FileStoreException e2) {
                try {
                    int sleep = (retryCount < 12 * 5) ? 5 : 60;
                    String message = e2.getMessage()
                        + (e2.getCause() != null ? ": " + e2.getCause() : "");
                    log.warn(String.format(
                        "Can't connect to the filestore (%s), sleeping for %d secs...",
                        message, sleep));
                    Thread.sleep(sleep * 1000);
                } catch (InterruptedException ignore) {
                }
            }
            retryCount++;
        }
    }

    /**
     * @param args
     */
    public static void main(String[] args) {
        WorkerPipelineProcess p = new WorkerPipelineProcess();
        p.go();
    }

}
