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

package gov.nasa.kepler.pi.module;

import java.io.File;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class MatlabLauncher {
    private static final Log log = LogFactory.getLog(MatlabLauncher.class);

    private File taskDir = null;
    private int groupIndex = -1;
    private int subTaskIndex = -1;
    private String binaryName = null;
    private int timeoutSecs = -1;
    
    public MatlabLauncher(File taskDir, int groupIndex, int subTaskIndex, String binaryName, int timeoutSecs) {
        this.taskDir = taskDir;
        this.groupIndex = groupIndex;
        this.subTaskIndex = subTaskIndex;
        this.binaryName = binaryName;
        this.timeoutSecs = timeoutSecs;
    }

    public int launch(){
        File workingDir = InputsHandler.subTaskDirectory(taskDir, groupIndex, subTaskIndex);
        int retCode = MatlabMcrExecutable.execAlgorithm(binaryName, workingDir, timeoutSecs, 0, true);
        
        return retCode;
    }
    
    private static void usage() {
        System.out.println("launch-matlab TASK_DIR GROUP_INDEX SUBTASK_INDEX BINARY_NAME TIMEOUT_SECS");
    }

    private static int str2int(String argName, String value){
        int result = -1;
        
        try {
            result = Integer.parseInt(value);
        } catch (NumberFormatException e) {
            System.err.println(argName + " must be a number, was: '" + value + "'");
            System.exit(-1);
        }
        return result;
    }
    
    public static void main(String[] args) {
        if (args.length < 5) {
            usage();
            System.exit(-1);
        }
        
        String taskDirStr = args[0];
        String groupIndexStr = args[1];
        String subTaskIndexStr = args[2];
        String binaryName = args[3];
        String timeoutSecsStr = args[4];
        
        File taskDir = new File(taskDirStr);
        int groupIndex = -1;
        int subTaskIndex = -1;
        int timeoutSecs = 0;
        
        groupIndex = str2int("GROUP_INDEX", groupIndexStr);
        subTaskIndex = str2int("SUBTASK_INDEX", subTaskIndexStr);
        timeoutSecs = str2int("TIMEOUT_SECS", timeoutSecsStr);
            
        MatlabLauncher launcher = new MatlabLauncher(taskDir, groupIndex, subTaskIndex, binaryName, timeoutSecs);
        int retCode = launcher.launch();
        
        log.info("MATLAB execution completed, exiting.");
        
        System.exit(retCode);
    }
}
