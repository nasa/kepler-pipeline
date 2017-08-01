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

import gov.nasa.kepler.pi.module.remote.StateFile.State;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Moves a set of {@link StateFile}s to a terminal
 * state by transitioning all sub-tasks in the PROCESSING state
 * to the FAILED state
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TerminateStateFiles {

    public TerminateStateFiles() {
    }

    public void go(File stateFileDir) throws Exception{
        
        ArrayList<State> stateFilters = new ArrayList<StateFile.State>();
        stateFilters.add(StateFile.State.PROCESSING);
        List<StateFile> stateFiles = StateFile.fromDirectory(stateFileDir, stateFilters);
        
        System.out.println("Found " + stateFiles.size() + " statefiles in " + stateFileDir);
        
        for (StateFile originalStateFile : stateFiles) {
            int remainingSubTasks = originalStateFile.getNumTotal() 
            - (originalStateFile.getNumComplete() + originalStateFile.getNumFailed());
            
            StateFile newStateFile = new StateFile(originalStateFile);
            
            newStateFile.setNumFailed(remainingSubTasks);
            newStateFile.setState(StateFile.State.FAILED);
            
            System.out.println("Updating state: " + originalStateFile + " -> " + newStateFile);
            StateFile.updateStateFile(originalStateFile, newStateFile, stateFileDir);
        }
    }
    
    public static void main(String[] args) {
    
        if(args.length != 1){
            System.err.println("USAGE: terminate-state-files STATE_FILE_DIR");
            System.exit(-1);
        }
        
        String stateFileDir = args[0];
        
        try {
            TerminateStateFiles t = new TerminateStateFiles();
            t.go(new File(stateFileDir));
        } catch (Exception e) {
            System.err.println("caught e = " + e);
            e.printStackTrace();
        }
    }
}
