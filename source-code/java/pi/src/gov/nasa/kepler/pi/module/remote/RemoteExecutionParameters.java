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

import gov.nasa.spiffy.common.pi.Parameters;

import org.apache.commons.lang.ArrayUtils;

/**
 * {@link Parameters} class used for controlling whether
 * a particular pipeline module uses remote execution.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class RemoteExecutionParameters implements Parameters {

    private boolean enabled;
    
    /** If multiple hosts are specified, remoteHost[0] will be
     * used as the primary and remoteHost[1]..remoteHost[N] will
     * be used as fallbacks in the retry logic when the primary
     * fails (in round-robin order) */
    private String[] remoteHost = ArrayUtils.EMPTY_STRING_ARRAY;

    private String remoteUser;

    /** Group name used to execute the job on the remote cluster */
    private String remoteGroup = "";
        
    /** queue name used on the remote cluster */
    private String queueName = "";
        
    /** Whether this task is re-runnable. */
    private boolean reRunnable = true;

    /** If true, use ArcFour ciphers for SUP transfers
     * (-oCiphers=arcfour128 -oMACs=umac-64@openssh.com) **/
    private boolean useArcFourCiphers;

    private boolean bbftpEnabled;
    
    /** Required memory per core used.
     * Used to calculate coresPerNode based on architecture. */
    private double gigsPerCore;
    
    /** Number of tasks to allocate to each available core. */
    private double tasksPerCore;
    
    private String[] remoteNodeArchitectures = ArrayUtils.EMPTY_STRING_ARRAY;
    
	private int numElementsPerTaskFile = 1;
    private String remoteTaskFilePath = "";
    private String remoteStateFilePath = "";

    /** If true, generation of .mat files from .bin files is deferred until the 
     * task files have been copied back to the local worker. This is done to
     * reduce bandwidth requirements for copying task files */
    private boolean localBinToMatEnabled;
    
    /** PBS qsub wall time parameter */
    private String requestedWallTime="";

    /** Determines whether memdrone.sh runs on every remote node */
    private boolean memdroneEnabled;
    
    /** Determines whether symlinks are created between sub-task directories and
     * files in the top-level task directory. This should be enabled for modules
     * that store files common to all sub-tasks in the top-level task directory. */
    private boolean symlinksEnabled;
    
    /**
     * The maximum number of subtasks that are allowed to fail and still 
     * automatically store and commit the task. If this is exceeded, then the 
     * task will pause in the Ac state. The operator will either 'resume current 
     * step' or 'restart from beginning'.
     */
    private int maxFailedSubtaskCount;
    
    public RemoteExecutionParameters() {
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public String[] getRemoteHost() {
        return remoteHost;
    }

    public void setRemoteHost(String[] remoteHost) {
        this.remoteHost = remoteHost;
    }

    public String getRemoteTaskFilePath() {
        return remoteTaskFilePath;
    }

    public void setRemoteTaskFilePath(String remoteTaskFilePath) {
        this.remoteTaskFilePath = remoteTaskFilePath;
    }

    public String getRemoteUser() {
        return remoteUser;
    }

    public void setRemoteUser(String remoteUser) {
        this.remoteUser = remoteUser;
    }

    public String getRemoteStateFilePath() {
        return remoteStateFilePath;
    }

    public void setRemoteStateFilePath(String remoteStateFilePath) {
        this.remoteStateFilePath = remoteStateFilePath;
    }

    public int getNumElementsPerTaskFile() {
        return numElementsPerTaskFile;
    }

    public void setNumElementsPerTaskFile(int numElementsPerTaskFile) {
        this.numElementsPerTaskFile = numElementsPerTaskFile;
    }

    public double getGigsPerCore() {
        return gigsPerCore;
    }

    public void setGigsPerCore(double gigsPerCore) {
        this.gigsPerCore = gigsPerCore;
    }

    public double getTasksPerCore() {
        return tasksPerCore;
    }

    public void setTasksPerCore(double tasksPerCore) {
        this.tasksPerCore = tasksPerCore;
    }

    public String getRemoteGroup() {
        return remoteGroup;
    }

    public void setRemoteGroup(String remoteGroup) {
        this.remoteGroup = remoteGroup;
    }

    public boolean isLocalBinToMatEnabled() {
        return localBinToMatEnabled;
    }

    public void setLocalBinToMatEnabled(boolean localBinToMatEnabled) {
        this.localBinToMatEnabled = localBinToMatEnabled;
    }

    public String getRequestedWallTime() {
        return requestedWallTime;
    }

    public void setRequestedWallTime(String requestedWallTime) {
        this.requestedWallTime = requestedWallTime;
    }

    public boolean isUseArcFourCiphers() {
        return useArcFourCiphers;
    }

    public void setUseArcFourCiphers(boolean useArcFourCiphers) {
        this.useArcFourCiphers = useArcFourCiphers;
    }

    public boolean isBbftpEnabled() {
        return bbftpEnabled;
    }

    public void setBbftpEnabled(boolean bbftpEnabled) {
        this.bbftpEnabled = bbftpEnabled;
    }

    public boolean isMemdroneEnabled() {
        return memdroneEnabled;
    }

    public void setMemdroneEnabled(boolean memdroneEnabled) {
        this.memdroneEnabled = memdroneEnabled;
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

    public boolean isSymlinksEnabled() {
        return symlinksEnabled;
    }

    public void setSymlinksEnabled(boolean symlinksEnabled) {
        this.symlinksEnabled = symlinksEnabled;
    }

    public String[] getRemoteNodeArchitectures() {
        return remoteNodeArchitectures;
    }

    public void setRemoteNodeArchitectures(String[] remoteNodeArchitectures) {
        this.remoteNodeArchitectures = remoteNodeArchitectures;
    }

    public int getMaxFailedSubtaskCount() {
        return maxFailedSubtaskCount;
    }

    public void setMaxFailedSubtaskCount(int maxFailedSubtaskCount) {
        this.maxFailedSubtaskCount = maxFailedSubtaskCount;
    }
}
