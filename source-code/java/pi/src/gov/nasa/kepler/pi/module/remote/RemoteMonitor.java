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

package gov.nasa.kepler.pi.module.remote;

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal.RemoteFile;
import gov.nasa.kepler.pi.pipeline.PipelineExecutor;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Monitors the processing on the remote cluster by monitoring the state files
 * on the remote filesystem.
 * 
 * A single instance is shared by all worker threads running tasks on the remote
 * cluster to minimize the number of SSH connections needed. In addition,
 * polling is only active when at least one thread is waiting on remote jobs to
 * finish.
 * 
 * @author tklaus
 * 
 */
public class RemoteMonitor implements Runnable {
    private static final Log log = LogFactory.getLog(RemoteMonitor.class);

    private static final long SSH_POLL_INTERVAL_MILLIS = 10 * 1000; // 10 secs

    private SupPortal supPortal;
    private String remoteStateDirPath;

    // ConcurrentHashMap<StateFileInvariantPart,StateFile>
    private ConcurrentHashMap<String, StateFile> state = new ConcurrentHashMap<String, StateFile>();

    private int maxFailedSubtaskCount;

    private static RemoteMonitor instance = null;
    
    public static RemoteMonitor getInstance(RemoteExecutionParameters remoteParams){
        synchronized(RemoteMonitor.class){
            if(instance == null){
                instance = new RemoteMonitor(remoteParams);
                new Thread(instance).start();
            }
            return instance;
        }
    }
    
    private RemoteMonitor(RemoteExecutionParameters remoteParams) {
        log.info("Starting new monitor for: " + remoteStateDirPath);

        String[] remoteHost = remoteParams.getRemoteHost();
        String remoteUser = remoteParams.getRemoteUser();
        this.remoteStateDirPath = remoteParams.getRemoteStateFilePath();

        SupPortal supPortal = new SupPortal(remoteHost, remoteUser);
        this.supPortal = supPortal;
        
        this.maxFailedSubtaskCount = remoteParams.getMaxFailedSubtaskCount();
    }

    public void startMonitoring(StateFile task) {
        log.info("Starting monitoring for: " + task.invariantPart());
        state.put(task.invariantPart(), new StateFile(task));
    }

    @Override
    public void run() {
        log.info("RemoteMonitor thread started...");

        while (true) {
            try {
                if (!state.isEmpty()) {
                    List<RemoteFile> remoteDirListing = supPortal.listRemoteDirectoryContents(remoteStateDirPath);

                    if (log.isDebugEnabled()) {
                        dumpRemoteState(remoteDirListing);
                    }

                    for (RemoteFile remoteFile : remoteDirListing) {
                        String name = remoteFile.name;
                        if (name.startsWith(StateFile.PREFIX)) {
                            StateFile remoteState = new StateFile(name);
                            String key = remoteState.invariantPart();

                            StateFile oldState = state.get(key);

                            if (oldState != null) { // ignore tasks we were not charged with
                                if (!oldState.equals(remoteState)) {
                                    // state change
                                    log.info("Updating state for: " + remoteState + " (was: " + oldState + ")");
                                    state.put(key, remoteState);

                                    PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
                                    long instanceId = remoteState.getPipelineInstanceId();
                                    long taskId = remoteState.getPipelineTaskId();
                                    
                                    attrOps.updateSubTaskCounts(taskId, instanceId, 
                                        remoteState.getNumTotal(), 
                                        remoteState.getNumComplete(), 
                                        remoteState.getNumFailed());
                                    
                                    if(remoteState.isRunning()){
                                        // update processing state
                                        attrOps.updateProcessingState(taskId, instanceId,
                                            ProcessingState.ALGORITHM_EXECUTING);
                                    }
                                    
                                    if(remoteState.isDone()){
                                        // update processing state
                                        attrOps.updateProcessingState(taskId, instanceId, 
                                            ProcessingState.ALGORITHM_COMPLETE);
                                        
                                        if (remoteState.getNumFailed() <= maxFailedSubtaskCount) {
                                            resubmitTask(remoteState);
                                            
                                            // KSOC-4150: Keep monitoring until the task has been resubmitted.
                                            log.info("Removing monitoring for: " + key);
                                            state.remove(key);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                try {
                    Thread.sleep(SSH_POLL_INTERVAL_MILLIS);
                } catch (InterruptedException e) {
                }
            } catch (Exception e) {
                log.warn("top: caught e=" + e, e);
            }
        }
    }

    private void resubmitTask(StateFile remoteState) {
        long taskId = remoteState.getPipelineTaskId();
        
        MessagingServiceFactory.setUseXa(false);
        DatabaseServiceFactory.setUseXa(false);

        TransactionService transactionService = TransactionServiceFactory.getInstance(false);
        transactionService.beginTransaction(true, true, false);

        try {
            PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
            PipelineTask task = pipelineTaskCrud.retrieve(taskId);
            
            PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
            PipelineTaskAttributes taskAttrs = attrCrud.retrieveByTaskId(taskId);
            
            log.info("Resubmitting task id: " + task.getId() + ": " + taskAttrs.processingStateShortLabel());
            
            PipelineExecutor exec = new PipelineExecutor();        
            exec.reRunTask(task);
            
            transactionService.commitTransaction();
        } catch (Exception e) {
            transactionService.rollbackTransactionIfActive();
            throw new PipelineException("failed to launch task", e);
        }
    }

    private void dumpRemoteState(List<RemoteFile> remoteState) {
        log.debug("Remote state dir:");
        for (RemoteFile remoteFile : remoteState) {
            log.debug(remoteFile);
        }
    }

}
