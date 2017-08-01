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

import gov.nasa.kepler.pi.module.AlgorithmStateFile;
import gov.nasa.kepler.pi.module.AlgorithmStateFile.TaskState;
import gov.nasa.kepler.pi.module.InputsHandler;

import java.io.File;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class RemoteTaskMonitor {
    private static final Log log = LogFactory.getLog(RemoteTaskMonitor.class);
    
    private InputsHandler inputsHandler;
    private StateFile stateFile;
    private File stateFileDir;
    private File taskDir;
    
    public RemoteTaskMonitor(InputsHandler inputsHandler, StateFile stateFile, File stateFileDir, File taskDir) {
        this.inputsHandler = inputsHandler;
        this.stateFile = stateFile;
        this.stateFileDir = stateFileDir;
        this.taskDir = taskDir;
    }

    /**
     * Makes a single pass through all of the sub-task directories
     * and updates the {@link StateFile} based on the {@link AlgorithmStateFile}s.
     * 
     * This method does not update the status to COMPLETE when all sub-tasks are
     * done to allow the caller to do any post processing before the state file 
     * is updated. The state file should be marked COMPLETE with the markStateFileDone()
     * method.
     * 
     * @return
     */
    public boolean updateState() {
        
        StateFile previousStateFile = new StateFile(stateFile);
        
        List<File> subTaskDirs = inputsHandler.allSubTaskDirectories();

        if(subTaskDirs.isEmpty()){
            log.warn("No sub-task dirs found in: " + taskDir);
        }
        
        int numComplete = 0;
        int numFailed = 0;
        
        if(subTaskDirs != null){
            for (File subTaskDir : subTaskDirs) {
                AlgorithmStateFile currentSubTaskStateFile = new AlgorithmStateFile(subTaskDir);
                TaskState currentSubTaskState = currentSubTaskStateFile.currentState();
                
                if(currentSubTaskState == null){
                    // no algorithm state file exists yet
                    continue;
                }
                
                switch (currentSubTaskState) {
                    case COMPLETE:
                        numComplete++;
                        break;
                    case FAILED:
                        numFailed++;
                        break;
                    case PROCESSING:
                        break;
                    default:
                        throw new IllegalArgumentException(
                            "Unexpected type: " + currentSubTaskState);
                }
            }
        }
        
        stateFile.setNumComplete(numComplete);
        stateFile.setNumFailed(numFailed);
        
        boolean done = false;
        
        if((numComplete == stateFile.getNumTotal())
            || (numComplete + numFailed == stateFile.getNumTotal())){
            // done!
            // don't mark the StateFile COMPLETE or FAILED so that the caller
            // can do any necessary post-processing before calling
            // markStateFileDone() to set the final state on the state file.
            done = true;
        }else if(numFailed > 0){
            // at least one sub-task failed, but there is still
            // at least one sub-task PROCESSING
            stateFile.setState(StateFile.State.ERRORSRUNNING);
        }
        
        if(!stateFile.equals(previousStateFile)){
            updateStateFile(previousStateFile);
        }else{
            log.debug("No changes for: " + previousStateFile);
        }

        return done;
    }

    /**
     * Update {@link StateFile} state based on sub-task counts.
     * 
     */
    public void markStateFileDone(){
        StateFile previousStateFile = new StateFile(stateFile);

        if(stateFile.getNumComplete() == stateFile.getNumTotal()){
            log.info("All sub-tasks complete, marking state file COMPLETE");
            stateFile.setState(StateFile.State.COMPLETE);
        }else if(stateFile.getNumComplete() + stateFile.getNumFailed() == stateFile.getNumTotal()){
            log.info("All sub-tasks complete (with errors), marking state file FAILED");
            stateFile.setState(StateFile.State.FAILED);
        }else{
            // If there is a shortfall, consider the missing sub-tasks failed
            int missing = stateFile.getNumTotal() - (stateFile.getNumComplete()+stateFile.getNumFailed());

            log.info("Missing sub-tasks, forcing state to FAILED, missing=" + missing);
            stateFile.setNumFailed(stateFile.getNumFailed() + missing);
            stateFile.setState(StateFile.State.FAILED);
        }
        
        if(!stateFile.equals(previousStateFile)){
            updateStateFile(previousStateFile);
        }else{
            log.info("No state file update necessary");
        }
    }

    private void updateStateFile(StateFile previousStateFile){
        log.info("Updating state: " + previousStateFile + " -> " + stateFile);

        if(!StateFile.updateStateFile(previousStateFile, stateFile, stateFileDir)){
            log.error("Failed to update state file: " + previousStateFile);
        }        
    }    
}
