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

import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeOperations;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal.RemoteFile;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class acts as a poller for a remote cluster.
 * It monitors the processing on the remote cluster by
 * monitoring the state files on the remote filesystem.
 * 
 * Instances of this class are created using 
 * {@link RemotePollerFactory}. This factory creates one
 * instance per worker process per remote cluster. This instance is shared
 * by all worker threads running tasks on the remote cluster
 * to minimize the number of SSH connections needed. In addition,
 * polling is only active when at least one thread is waiting 
 * on remote jobs to finish.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class RemotePoller extends Thread{
    private static final Log log = LogFactory.getLog(RemotePoller.class);

    private static final long WAITER_POLL_INTERVAL_MILLIS = 5 * 1000; // 5 secs
    private static final long SSH_POLL_INTERVAL_MILLIS = 10 * 1000; // 10 secs

	private SupPortal supPortal;
	private String remoteStateDirPath;
	
	private volatile int waiterCount = 0;
	private Object waiterLock = new Object();
	
	// ConcurrentHashMap<StateFileInvariantPart,StateFile>
	private ConcurrentHashMap<String,StateFile> state = new ConcurrentHashMap<String,StateFile>();
	
	/**
	 * {@link RemotePoller} objects should only be created by {@link RemotePollerFactory}
	 * 
	 * @param supPortal
	 * @param remoteStateDirPath
	 */
    RemotePoller(SupPortal supPortal, String remoteStateDirPath) {
        this.supPortal = supPortal;
        this.remoteStateDirPath = remoteStateDirPath;
    }

    /**
     * 
     * @param supPortal
     * @param stateFile
     */
    public StateFile waitForCompletion(StateFile stateFile, long timeoutMillis){
        String key = stateFile.invariantPart();
        
        // populate the map with the initial state
        log.info("Adding state for: " + stateFile);
        state.put(key, stateFile);

        log.info("Polling remote cluster, waiting for completion for: " + stateFile);
        
        try{
            long startTime = System.currentTimeMillis();
            long now = startTime;
            boolean done = false;
            
            incrementWaiterCount();
            
            StateFile previousState = null;
            
            while((now - startTime) < timeoutMillis){
                StateFile currentState = state.get(key);
                if(currentState != null){
                    switch (currentState.getState()) {
                        case COMPLETE:
                            log.info("Remote task COMPLETED. stateFile=" + currentState);
                            done = true;
                            break;
                            
                        case FAILED:
                            log.warn("Remote task has failures. stateFile=" + currentState);
                            done = true;
                            break;
                            
                        default:
                            log.debug("Remote task still running. stateFile=" + currentState);
                            break;
                    }
                 
                    if(previousState != null && !previousState.equals(currentState)){
                    	log.info("State updated: " + currentState);
                        PipelineTaskAttributeOperations attrOps = new PipelineTaskAttributeOperations();
                    	
                    	long taskId = currentState.getPipelineTaskId();
                    	long instanceId = currentState.getPipelineInstanceId();
                    	
                        attrOps.updateSubTaskCounts(taskId, instanceId,  
                            currentState.getNumTotal(), 
                            currentState.getNumComplete(), 
                            currentState.getNumFailed());
                    	
                    	if(previousState.getState() == StateFile.State.SUBMITTED 
                    	    && currentState.getState() == StateFile.State.PROCESSING){
                    	    // transition from SUBMITTED -> PROCESSING
                            attrOps.updateProcessingState(taskId, instanceId, ProcessingState.ALGORITHM_EXECUTING);
                    	}
                    }
                    
                    if(done){
                        return currentState;
                    }
                    
                    previousState = currentState;
                }
                
                try {
                    Thread.sleep(WAITER_POLL_INTERVAL_MILLIS);
                } catch (InterruptedException e) {
                }

                now = System.currentTimeMillis();
            }
            
            throw new PipelineException("Time out waiting for remote execution to complete");
        }finally{
            decrementWaiterCount();
        }
    }

    private void incrementWaiterCount(){
        synchronized(waiterLock){
            waiterCount++;
            // wake up the poller thread, if necessary
            waiterLock.notify();
        }
    }
    
    private void decrementWaiterCount(){
        synchronized(waiterLock){
            waiterCount--;
            
            if(waiterCount < 0){
                throw new IllegalStateException("waiterCount < 0");
            }
        }
    }
    
    @Override
    public void run(){        
        log.info("RemotePoller thread started...");
        
        while(true){
            try {
                synchronized(waiterLock){
                    // suspend polling if there are no waiters
                    if(waiterCount < 1){
                        log.info("No waiters waiting, suspending polling");
                        waiterLock.wait();
                        log.info("Got a waiter signal, resuming polling");
                    }
                }
                
                List<RemoteFile> remoteDirListing = supPortal.listRemoteDirectoryContents(remoteStateDirPath);
                
                if(log.isDebugEnabled()){
                    dumpRemoteState(remoteDirListing);
                }
                
                for (RemoteFile remoteFile : remoteDirListing) {
                    String name = remoteFile.name;
                    if(name.startsWith(StateFile.PREFIX)){
                        StateFile remoteState = new StateFile(name);
                        String key = remoteState.invariantPart();
                        
                        StateFile existingState = state.get(key);
                        
                        if(existingState == null || !existingState.equals(remoteState)){
                            if(existingState == null){
                                // previously-unseen state file
                                log.info("Adding state for: " + remoteState);
                            }else{
                                // state change
                                log.info("Updating state for: " + remoteState + " (was: " + existingState + ")");
                            }
                            state.put(key, remoteState);
                        }
                    }
                }
                try {
                    Thread.sleep(SSH_POLL_INTERVAL_MILLIS);
                } catch (InterruptedException e) {
                }
            } catch (Exception e) {
                log.warn("Remote polling failed, caught e=" + e, e);
            }
        }
    }
    
    private void dumpRemoteState(List<RemoteFile> remoteState){
        log.debug("Remote state dir:");
        for (RemoteFile remoteFile : remoteState) {
            log.debug(remoteFile);
        }
    }
}
