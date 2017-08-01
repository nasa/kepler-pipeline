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

import gov.nasa.kepler.pi.module.remote.sup.SupCommandResults;
import gov.nasa.kepler.pi.module.remote.sup.SupPortal;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.LinkedList;
import java.util.List;

/**
 * Calls qsub over sup.
 * 
 * SCRIPT_ARGS="$WORKING_DIR $KEPLER_DIST_DIR $STATE_FILE_PATH"
 * QSUB_ARGS="-N $JOB_NAME -q $QUEUE_NAME -rn -l walltime=$WALL_TIME -l select=$NUM_NODES:model=$ARCH_TYPE -W group_list=$GROUP_NAME"
 *
 * echo ${KEPLER_BIN_DIR}/nas-task-master.sh ${SCRIPT_ARGS} | qsub ${QSUB_ARGS}
 * or
 * qsub ${QSUB_ARGS} -- nas-task-master.sh ${SCRIPT_ARGS}
 * 
 * @author tklaus
 *
 */
public class Qsub {

    private SupPortal supPortal = null;
    
    private String jobName = "none";
    private String queueName = "none";
    private boolean reRunnable = true;
    private String wallTime = "01:00:00";
    private int numNodes = 1;
    private String model = "wes"; // wes, san, ivy
    private String groupName = "none";
    
    private String scriptPath = null;
    private String[] scriptArgs = null;
    
    public Qsub(SupPortal supPortal, String jobName, String queueName, boolean reRunnable, String wallTime, 
        int numNodes, String model, String groupName, String scriptPath, String[] scriptArgs) {
        this.supPortal = supPortal;
        this.jobName = jobName;
        this.queueName = queueName;
        this.reRunnable = reRunnable;
        this.wallTime = wallTime;
        this.numNodes = numNodes;
        this.model = model;
        this.groupName = groupName;
        this.scriptPath = scriptPath;
        this.scriptArgs = scriptArgs;
    }

    public int call() {
        List<String> commandLine = new LinkedList<String>();
        
        commandLine.add("qsub");
        commandLine.add("-N");
        commandLine.add(jobName);
        commandLine.add("-q");
        commandLine.add(queueName);
        commandLine.add(reRunnable ? "-ry" : "-rn");
        commandLine.add("-l");
        commandLine.add("walltime=" + wallTime + ",select=" + numNodes + ":model=" + model);
        commandLine.add("-W");
        commandLine.add("group_list=" + groupName);
        commandLine.add("--");
        commandLine.add(scriptPath);
        
        for (String scriptArg : scriptArgs) {
            commandLine.add(scriptArg);
        }

        SupCommandResults result = supPortal.execCommand(commandLine);

        if(result.failed()){
            throw new PipelineException("failed to call qsub, result=" + result.toString());
        }
        return result.getReturnCode();
    }

    public SupPortal getSupPortal() {
        return supPortal;
    }

    public void setSupPortal(SupPortal supPortal) {
        this.supPortal = supPortal;
    }

    public String getJobName() {
        return jobName;
    }

    public void setJobName(String jobName) {
        this.jobName = jobName;
    }

    public String getQueueName() {
        return queueName;
    }

    public void setQueueName(String queueName) {
        this.queueName = queueName;
    }

    public boolean isReRunnable() {
        return reRunnable;
    }

    public void setReRunnable(boolean reRunnable) {
        this.reRunnable = reRunnable;
    }

    public String getWallTime() {
        return wallTime;
    }

    public void setWallTime(String wallTime) {
        this.wallTime = wallTime;
    }

    public int getNumNodes() {
        return numNodes;
    }

    public void setNumNodes(int numNodes) {
        this.numNodes = numNodes;
    }

    public String getModel() {
        return model;
    }

    public void setModel(String model) {
        this.model = model;
    }

    public String getGroupName() {
        return groupName;
    }

    public void setGroupName(String groupName) {
        this.groupName = groupName;
    }

    public String getScriptPath() {
        return scriptPath;
    }

    public void setScriptPath(String scriptPath) {
        this.scriptPath = scriptPath;
    }

    public String[] getScriptArgs() {
        return scriptArgs;
    }

    public void setScriptArgs(String[] scriptArgs) {
        this.scriptArgs = scriptArgs;
    }
}
