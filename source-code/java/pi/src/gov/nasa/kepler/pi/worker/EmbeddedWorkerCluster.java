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

import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionCrud;
import gov.nasa.kepler.pi.module.WorkerMemoryManager;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FilenameFilter;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Provides the functionality of a cluster of workers for use by tests that need
 * to run pipelines in a single JVM.
 * 
 * @author tklaus
 * 
 */
public class EmbeddedWorkerCluster {
    private static final Log log = LogFactory.getLog(EmbeddedWorkerCluster.class);

    private static final String LATEST_RELEASE_DIST = "/path/to/releases/soc/latest-artifacts-SUCCESS/dist";

    /**
     * Controls whether dist/mbin is refreshed from LATEST_RELEASE_DIST, even if
     * it already exists (default true)
     */
    public static final String REFRESH_MBIN_PROP = "aft.refresh.mbin";

    private boolean useXa = false;
    private int numWorkerThreads = 1;

    private PipelineEventListener eventListener;
    private boolean initialized = false;

    private List<WorkerTaskRequestListener> workers;

    private PipelineInstanceQueuePool queueList;
    private WorkerMemoryManager memoryManager = null;

    private boolean verifyMcr = true;

    public EmbeddedWorkerCluster() {
    }

    public void start() throws PipelineException {

        if (initialized) {
            throw new PipelineException("Already started");
        }

        // start the pipeline event listener thread so we know when the
        // instance is done
        log.info("EWC: Start event listener ...");
        eventListener = new PipelineEventListener();
        eventListener.start();

        ProcessInfo processInfo = new ProcessInfo("aft-worker", "testHost", 42,
            0);

        // start the worker dispatcher threads
        log.info("EWC: Start pipeline instance queue list...");
        queueList = new PipelineInstanceQueuePool();

        try {
            memoryManager = new WorkerMemoryManager();
        } catch (Exception e) {
            log.warn(
                "unable to determine system physical memory, disabling memory manager",
                e);
        }

        workers = new LinkedList<WorkerTaskRequestListener>();
        for (int i = 0; i < numWorkerThreads; i++) {
            log.info("EWC: Start pipeline worker thread (" + i + ")...");
            WorkerTaskRequestListener worker = new WorkerTaskRequestListener(
                processInfo, i, queueList, memoryManager);
            worker.setUseXa(useXa);
            worker.start();
            workers.add(worker);
        }

        initialized = true;
    }

    public void runPipeline(String triggerName) {
        runPipeline(triggerName, null, null);
    }

    /**
     * Launch a pipeline using the specified trigger and the default pipeline
     * parameters stored with the trigger.
     * 
     * This method will block until the pipeline completes (as determined by the
     * receipt of a {@link PipelineInstanceEvent} FINISHED message).
     * 
     * @param triggerName
     * @param startNode Optional start node (default is root of the
     * PipelineDefnition)
     * @param endNode Optional end node (default is leafs of the
     * PipelineDefnition)
     * @throws PipelineException
     */
    public void runPipeline(String triggerName,
        PipelineDefinitionNode startNode, PipelineDefinitionNode endNode) {

        if (!initialized) {
            throw new PipelineException(
                "not started, call start() before launching pipeline");
        }

        if (verifyMcr) {
            verifyMcrClasspath();
        }

        Configuration config = ConfigurationServiceFactory.getInstance();

        boolean refreshMbin = config.getBoolean(REFRESH_MBIN_PROP, true);

        if (refreshMbin) {
            copyDistMBin();
        }

        log.info(triggerName + ": Launching ...");

        TransactionService transactionService = TransactionServiceFactory.getInstance();

        try {
            log.info(triggerName + ": Begin transaction ...");
            transactionService.beginTransaction(true, true, true);

            // Launch the pipeline.
            log.info(triggerName + ": Create and fire trigger ...");
            TriggerDefinitionCrud triggerDefinitionCrud = new TriggerDefinitionCrud(
                DatabaseServiceFactory.getInstance());
            TriggerDefinition triggerDefinition = triggerDefinitionCrud.retrieve(triggerName);

            if (triggerDefinition != null) {
                String instanceName = triggerDefinition.getPipelineDefinitionName()
                    + ": launched by EWC";

                PipelineOperations pipelineOps = new PipelineOperations();
                pipelineOps.fireTrigger(triggerDefinition, instanceName,
                    startNode, endNode);

                log.info(triggerName + ": Commit transaction ...");
                transactionService.commitTransaction();

                log.info(triggerName + ": Launched");

                log.info(triggerName + ": Waiting for worker ...");

                /* wait for the pipeline to complete */
                eventListener.waitForPipelineComplete();

                log.info(triggerName + ": Worker done ...");
            } else {
                throw new PipelineException("No trigger found for name: "
                    + triggerName);
            }
        } catch (Exception e) {
            throw new PipelineException(e.getMessage(), e);
        } finally {
            transactionService.rollbackTransactionIfActive();
        }

        if (eventListener.getEventType() == PipelineInstanceEvent.Type.FAILURE) {
            throw new PipelineFailedException(
                "Got a PipelineInstanceEvent.Type.FAILURE event, pipeline failed");
        }
    }

    public void shutdown() throws InterruptedException {
        eventListener.shutdown();
        
        if (workers != null) {
            for (WorkerTaskRequestListener worker : workers) {
                worker.shutdown(true);
            }
        }
    }

    /**
     * Make sure that the SOC_CODE_ROOT environment variable plus "/dist" (or
     * /path/to/dist if the variable is not set) is equivalent to
     * ../../dist.
     * 
     * /path/to/matlab/mcr/v76/toolbox/local/classpath.txt contains a
     * reference to /path/to/dist/lib/soc-classpath.jar, which is where
     * the MATLAB code looks for the SOC java code. This check ensures that the
     * JVM process and the MATLAB process are using the same Java code.
     * 
     * @throws PipelineException
     */
    private void verifyMcrClasspath() {
        try {
            File dist = new File(Filenames.DIST_ROOT);
            String distPath = dist.getCanonicalPath();
            String socDistPath = SocEnvVars.getLocalDistDir();
            File socDist = new File(socDistPath);
            socDistPath = socDist.getCanonicalPath();

            if (!distPath.equals(socDistPath)) {
                String errMsg = String.format(
                    "ERROR: %s does not point to %s, so "
                        + "MATLAB code will not see the same java code "
                        + "as the JVM that launched it. \ntry: export %s=%s",
                    socDistPath, distPath, SocEnvVars.SOC_CODE_ROOT_VAR,
                    dist.getParentFile().getCanonicalPath());

                log.error(errMsg);
                throw new PipelineException(errMsg);
            }
        } catch (IOException e) {
            throw new PipelineException("failed, caught e = " + e, e);
        }
    }

    protected void copyDistMBin() {

        // Get latest dist/mbin
        File localMbin = new File(Filenames.DIST_ROOT, "mbin");

        log.info("Deleting dist/mbin (" + REFRESH_MBIN_PROP + " == true)");
        try {
            FileUtils.deleteDirectory(localMbin);
        } catch (IOException e) {
            throw new PipelineException(
                "failed to delete dist/mbin directory, caught e = " + e, e);
        }

        if (!localMbin.exists()) {
            File latestMbin = new File(LATEST_RELEASE_DIST, "mbin");
            if (!latestMbin.exists()) {
                throw new PipelineException("Source '" + latestMbin
                    + "' does not exist.");
            }

            log.info("Copy mbin directory ...");
            try {
                FileUtils.copyDirectory(latestMbin, localMbin);
            } catch (IOException e) {
                throw new PipelineException("failed to copy mbin from "
                    + LATEST_RELEASE_DIST + " directory, caught e = " + e, e);
            }

            // Make mbin files executable (except *.ctf)
            FilenameFilter filter = new FilenameFilter() {
                @Override
                public boolean accept(File dir, String name) {
                    return !(name.endsWith(".ctf") || name.endsWith("_mcr"));
                }
            };
            for (File file : localMbin.listFiles(filter)) {
                log.info("Set executable: " + file.getName());
                file.setExecutable(true);
            }
        }
    }

    public int getNumWorkerThreads() {
        return numWorkerThreads;
    }

    public void setNumWorkerThreads(int numWorkerThreads) {
        this.numWorkerThreads = numWorkerThreads;
    }

    public boolean isUseXa() {
        return useXa;
    }

    public void setUseXa(boolean useXa) {
        this.useXa = useXa;
    }

    public boolean isVerifyMcr() {
        return verifyMcr;
    }

    public void setVerifyMcr(boolean verifyMcr) {
        this.verifyMcr = verifyMcr;
    }
}
