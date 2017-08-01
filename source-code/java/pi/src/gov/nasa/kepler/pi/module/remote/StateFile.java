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

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.FilenameFilter;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class models a file whose name contains the state
 * of a pipeline task executing on a remote cluster.
 * 
 * The file also contains additional properties of
 * the remote job.
 * 
 * Each state file represents a single unit of work
 * from the perspective of the pipeline module.
 * 
 * <pre>
 * Filename Format:
 * 
 * kepler-PIID.PTID.EXENAME.STATE_TOTAL-COMPLETE-FAILED
 * 
 * PIID: Pipeline Instance ID
 * PTID: Pipeline Task ID
 * EXENAME: Name of the MATLAB executable
 * STATE: enum(SUBMITTED,PROCESSING,ERRORS_RUNNING,FAILED,COMPLETE)
 * TOTAL-COMPLETE-FAILED): Number of jobs in each category
 * 
 * The file contains the following properties of the job:
 * 
 * timeoutSecs: Timeout for the MATLAB process.
 * gigsPerCore: Required memory per core used.
 * tasksPerCore: Number of tasks to allocate to each available core.
 * remoteGroup: Group name used for qsub on remote node
 * queueName: Queue name used for qsub on remote node
 * localBinToMatEnabled: if true, don't generate .mat files on the remote node
 * requestedWallTime: Total walltime to request for the task
 * memdroneEnabled: Determines whether memdrone.sh runs on every remote node
 * 
 * </pre>
 * 
 * @author tklaus
 *
 */
public class StateFile implements Comparable<StateFile>{
    private static final Log log = LogFactory.getLog(StateFile.class);

    public static final String PREFIX = "kepler.";
    private static final String FORMAT = "kepler.PIID.PTID.EXENAME.STATE_TOTAL-COMPLETE-FAILED";
    
    private static final String TIMEOUT_SECS_PROP_NAME = "timeoutSecs";
    private static final String GIGS_PER_CORE_PROP_NAME = "gigsPerCore";
    private static final String TASKS_PER_CORE_PROP_NAME = "tasksPerCore";
    private static final String ARCH_PROP_NAME = "remoteNodeArchitecture";
    private static final String REMOTE_GROUP_PROP_NAME = "remoteGroup";
    private static final String QUEUE_NAME_PROP_NAME = "queueName";
    private static final String RE_RUNNABLE_PROP_NAME = "reRunnable";
    private static final String LOCAL_BIN2MAT_ENABLED_PROP_NAME = "localBinToMatEnabled";
    private static final String REQUESTED_WALLTIME_PROP_NAME = "requestedWallTime";
    private static final String MEMDRONE_ENABLED_PROP_NAME = "memdroneEnabled";
    private static final String SYMLINKS_ENABLED_PROP_NAME = "symlinksEnabled";

    private static final String TAR_EXTENSION = ".tar";
    
    public enum State{
        /** task has been initialized */
        INITIALIZED,
        /** task has been submitted by the SOC worker, but not yet picked up by the remote cluster */
        SUBMITTED,
        /** task has been accepted by PBS for execution, but has not yet started */
        QUEUED,
        /** task is running on the remote cluster and no sub-tasks have failed */
        PROCESSING,
        /** task is running on the remote cluster and at least one sub-task has failed */
        ERRORSRUNNING,
        /** all sub-tasks have failed */
        FAILED,
        /** all sub-tasks have completed successfully */
        COMPLETE,
        /** the final state for this task has been acknowledged by the SOC worker */
        CLOSED;
    }
    
    // Fields in the file name
    private long pipelineInstanceId = -1;
    private long pipelineTaskId = -1;
    private String exeName;
    private State state = State.INITIALIZED;
    private int numTotal = -1;
    private int numComplete = -1;
    private int numFailed = -1;

    // Fields in the file (as properties)
    private int timeoutSecs = -1;

    /** Required memory per core used.
     * Used to calculate coresPerNode based on architecture. */
    private double gigsPerCore = -1.0;
    
    /** Number of tasks to allocate to each available core. */
    private double tasksPerCore = -1.0;
    
    private String remoteNodeArchitecture = "wes";
    
    /** Group name used for the qsub command on the remote node */
    private String remoteGroup = "none";

    /** Queue name used for the qsub command on the remote node */
    private String queueName = "none";

    /** Whether this task is re-runnable. */
    private boolean reRunnable = true;

    /** See {@link RemoteExecutionParameters} */
    private boolean localBinToMatEnabled = true;

    /** Requested wall time for the PBS qsub command */
    private String requestedWallTime = "24:00:00";
    
    /** Determines whether memdrone.sh runs on every remote node */
    private boolean memdroneEnabled = false;
    
    /** Determines whether symlinks are created between sub-task directories and
     * files in the top-level task directory. This should be enabled for modules
     * that store files common to all sub-tasks in the top-level task directory. */
    private boolean symlinksEnabled = false;
 
    /** Contains all properties from the file */
    private PropertiesConfiguration props = new PropertiesConfiguration();

    /**
     * Construct new state file
     * 
     * @param pipelineInstanceId
     * @param pipelineTaskId
     * @param exeName
     * @param timeoutSecs
     * @param gigsPerCore
     * @param tasksPerCore
     * @param localBinToMatEnabled
     * @param requestedWallTime
     * @param memdroneEnabled
     * @param remoteGroup
     * @param queueName
     * @param numTotal
     * @param symlinksEnabled
     */
    public StateFile(long pipelineInstanceId, long pipelineTaskId, 
        String exeName, int timeoutSecs, double gigsPerCore, double tasksPerCore,
        String remoteNodeArchitecture, boolean localBinToMatEnabled, String requestedWallTime, boolean memdroneEnabled, 
        String remoteGroup, String queueName, boolean reRunnable, int numTotal, boolean symlinksEnabled) {
        
        this.pipelineInstanceId = pipelineInstanceId;
        this.pipelineTaskId = pipelineTaskId;
        this.exeName = exeName;
        this.timeoutSecs = timeoutSecs;
        this.gigsPerCore = gigsPerCore;
        this.tasksPerCore = tasksPerCore;
        this.remoteNodeArchitecture = remoteNodeArchitecture;
        this.localBinToMatEnabled = localBinToMatEnabled;
        this.requestedWallTime = requestedWallTime;
        this.memdroneEnabled = memdroneEnabled;
        this.remoteGroup = remoteGroup;
        this.queueName = queueName;
        this.reRunnable = reRunnable;
        this.numTotal = numTotal;
        this.state = State.SUBMITTED;
        this.numComplete = 0;
        this.numFailed = 0;
        this.symlinksEnabled = symlinksEnabled;
    }

    /**
     * Construct a StateFile containing only the invariant part
     * 
     * @param pipelineInstanceId
     * @param pipelineTaskId
     * @param exeName
     */
    public StateFile(long pipelineInstanceId, long pipelineTaskId, String exeName) {
        
        this.pipelineInstanceId = pipelineInstanceId;
        this.pipelineTaskId = pipelineTaskId;
        this.exeName = exeName;
    }

	/**
	 * Construct from an existing name
	 * @param name
	 */
    public StateFile(String name) {
        parse(name);
	}

    /**
     * Copy constructor
     * @param other
     */
    public StateFile(StateFile other){
        this.pipelineInstanceId = other.pipelineInstanceId;
        this.pipelineTaskId = other.pipelineTaskId;
        this.exeName = other.exeName;
        this.timeoutSecs = other.timeoutSecs;
        this.gigsPerCore = other.gigsPerCore;
        this.tasksPerCore = other.tasksPerCore;
        this.remoteNodeArchitecture = other.remoteNodeArchitecture;
        this.state = other.state;
        this.numTotal = other.numTotal;
        this.numComplete = other.numComplete;
        this.numFailed = other.numFailed;
        this.requestedWallTime = other.requestedWallTime;
        this.memdroneEnabled = other.memdroneEnabled;
        this.remoteGroup = other.remoteGroup;
        this.queueName = other.queueName;
        this.reRunnable = other.reRunnable;
        this.localBinToMatEnabled = other.localBinToMatEnabled;
        this.props = other.props;
        this.symlinksEnabled = other.symlinksEnabled;
    }

    /**
     * Construct a new {@link StateFile} from an existing file.
     * 
     * @param stateFilePath
     * @throws Exception 
     */
    public StateFile(File stateFilePath) throws Exception{
        parse(stateFilePath.getName());
        
        File dir = stateFilePath.getParentFile();

        FileFilter fileFilter = new WildcardFileFilter(invariantPart() + "*");
        File[] matches = dir.listFiles(fileFilter);
        File matchedStateFile;

        if(matches.length == 0){
            throw new Exception("State file does not exist: " + stateFilePath);
        }

        if(matches.length > 1){
        	// find the newest (most recently modified) and delete the rest
        	long latestModifiedTime = 0;
        	int latestIndex = 0;

        	for (int i = 0; i < matches.length; i++) {
				if(matches[i].lastModified() > latestModifiedTime){
					latestModifiedTime = matches[i].lastModified();
					latestIndex = i;
				}
			}
        	matchedStateFile = matches[latestIndex];
        	
        	// delete the stale files
        	for (int i = 0; i < matches.length; i++) {
				if(i != latestIndex){
					log.info("Deleting stale StateFile: " + matches[i]);
					FileUtils.deleteQuietly(matches[i]);
				}
			}
        }else{
        	matchedStateFile = matches[0];        
        }

        
        log.info("Matched statefile: " + matchedStateFile);

        parse(matchedStateFile.getName());
        
        props = new PropertiesConfiguration(matchedStateFile);
        
        if(!props.isEmpty()){
            this.timeoutSecs = props.getInt(TIMEOUT_SECS_PROP_NAME);
            this.gigsPerCore = props.getDouble(GIGS_PER_CORE_PROP_NAME);
            this.tasksPerCore = props.getDouble(TASKS_PER_CORE_PROP_NAME);
            this.remoteNodeArchitecture = props.getString(ARCH_PROP_NAME);
            this.remoteGroup = props.getString(REMOTE_GROUP_PROP_NAME);
            this.queueName = props.getString(QUEUE_NAME_PROP_NAME);
            this.reRunnable = props.getBoolean(RE_RUNNABLE_PROP_NAME);
            this.localBinToMatEnabled = props.getBoolean(LOCAL_BIN2MAT_ENABLED_PROP_NAME);
            this.requestedWallTime = props.getString(REQUESTED_WALLTIME_PROP_NAME);
            this.memdroneEnabled = props.getBoolean(MEMDRONE_ENABLED_PROP_NAME);
            this.symlinksEnabled = props.getBoolean(SYMLINKS_ENABLED_PROP_NAME);
        }else{
            throw new Exception("State file contains no properties!");
        }
    }

    /**
     * For testing only (hence the default access modifier)
     * 
     * @param pipelineInstanceId
     * @param pipelineTaskId
     * @param exeName
     * @param timeoutSecs
     * @param gigsPerCore
     * @param tasksPerCore
     * @param state
     * @param numTotal
     * @param numComplete
     * @param numFailed
     * @param localBinToMatEnabled
     * @param requestedWallTime
     * @param memdroneEnabled
     * @param remoteGroup
     * @param queueName
     * @param symlinksEnabled
     */
    StateFile(long pipelineInstanceId, long pipelineTaskId, String exeName, int timeoutSecs, double gigsPerCore,
        double tasksPerCore, String remoteNodeArchitecture, State state, int numTotal, int numComplete, int numFailed, 
        boolean localBinToMatEnabled, String requestedWallTime, boolean memdroneEnabled, 
        String remoteGroup, String queueName, boolean reRunnable, boolean symlinksEnabled) {
        this.pipelineInstanceId = pipelineInstanceId;
        this.pipelineTaskId = pipelineTaskId;
        this.exeName = exeName;
        this.state = state;
        this.numTotal = numTotal;
        this.numComplete = numComplete;
        this.numFailed = numFailed;
        this.timeoutSecs = timeoutSecs;
        this.gigsPerCore = gigsPerCore;
        this.tasksPerCore = tasksPerCore;
        this.remoteNodeArchitecture = remoteNodeArchitecture;
        this.localBinToMatEnabled = localBinToMatEnabled;
        this.requestedWallTime = requestedWallTime;
        this.memdroneEnabled = memdroneEnabled;
        this.remoteGroup = remoteGroup;
        this.queueName = queueName;
        this.reRunnable = reRunnable;
        this.symlinksEnabled = symlinksEnabled;
    }

    public boolean isDone(){
        return(state == State.COMPLETE || state == State.FAILED || state == State.CLOSED);
    }
    
    public boolean isRunning(){
        return(state == State.PROCESSING || state == State.ERRORSRUNNING);
    }
    
    public boolean isFailed(){
        return(state == State.FAILED);
    }
    
    public boolean isQueued(){
        return(state == State.QUEUED);
    }
    
    /**
     * Persist this {@link StateFile} to the specified directory
     * 
     * @param directory
     * @throws Exception 
     */
    public File persist(File directory) throws Exception{
        
        if(!directory.exists() && directory.isDirectory()){
            throw new IllegalArgumentException("Specified directory does not exist or is not a directory: " 
                + directory);
        }
        
        props.setProperty(TIMEOUT_SECS_PROP_NAME, timeoutSecs);
        props.setProperty(GIGS_PER_CORE_PROP_NAME, gigsPerCore);
        props.setProperty(TASKS_PER_CORE_PROP_NAME, tasksPerCore);
        props.setProperty(ARCH_PROP_NAME, remoteNodeArchitecture);
        props.setProperty(REMOTE_GROUP_PROP_NAME, remoteGroup);
        props.setProperty(QUEUE_NAME_PROP_NAME, queueName);
        props.setProperty(RE_RUNNABLE_PROP_NAME, reRunnable);
        props.setProperty(LOCAL_BIN2MAT_ENABLED_PROP_NAME, localBinToMatEnabled);
        props.setProperty(REQUESTED_WALLTIME_PROP_NAME, requestedWallTime);
        props.setProperty(MEMDRONE_ENABLED_PROP_NAME, memdroneEnabled);
        props.setProperty(SYMLINKS_ENABLED_PROP_NAME, symlinksEnabled);
        
        File file = new File(directory, name());
        FileWriter fw = new FileWriter(file);
        
        props.save(fw);
        fw.close(); // flush & close
        
        return file;
    }

    /**
     * Returns a list of {@link StateFile}s in the specified directory
     * 
     * @param directory
     * @return
     * @throws Exception 
     */
    public static List<StateFile> fromDirectory(File directory) throws Exception{
        return fromDirectory(directory, null, 0);
    }

    /**
     * Returns a list of {@link StateFile}s in the specified directory where
     * the state matches the specified stateFilter
     * 
     * @param directory
     * @param stateFilters
     * @return
     * @throws Exception
     */
    public static List<StateFile> fromDirectory(File directory, final List<State> stateFilters) throws Exception{
        return fromDirectory(directory, stateFilters, 0);
    }
    
    /**
     * Returns a list of {@link StateFile}s in the specified directory where
     * the state matches the specified stateFilter and the state file is at
     * least as old as the specified minimum age.
     * 
     * @param directory
     * @param stateFilters
     * @param minimumAgeMillis
     * @return
     * @throws Exception
     */
    public static List<StateFile> fromDirectory(File directory, final List<State> stateFilters, final long minimumAgeMillis) throws Exception{
        if(!directory.exists() || !directory.isDirectory()){
            throw new IllegalArgumentException(directory + ": does not exist or is not a directory");
        }
        
        String[] files = directory.list(new FilenameFilter() {
            @Override
            public boolean accept(File dir, String name) {
                boolean accept = false;

                if(stateFilters != null){
                    if(name.startsWith(PREFIX)){
                        for (State stateFilter : stateFilters) {
                            if(name.contains(stateFilter.toString())){
                                accept = true;
                                break;
                            }
                        }
                    }
                }else{
                    accept = name.startsWith(PREFIX);
                }
                
                if(accept && (minimumAgeMillis > 0)){
                    File f = new File(dir,name);
                    long age = System.currentTimeMillis() - f.lastModified();
                    if(age < minimumAgeMillis){
                        // too young
                        accept = false;
                    }
                }
                return accept;
            }
        });
        
        List<StateFile> stateFiles = new LinkedList<StateFile>();
        for (String filename : files) {
            StateFile stateFile = null;
            try {
                stateFile = new StateFile(new File(directory,filename));
                stateFiles.add(stateFile);
            } catch (Exception e) {
                log.warn("failed to parse statefile: " + filename + ", e=" + e, e);
            }
        }
        
        Collections.sort(stateFiles);
        
        return stateFiles;
    }

    /**
     * Returns a list of {@link StateFile}s in the specified directory where
     * the state matches the specified stateFilter
     * 
     * @param filenames
     * @param stateFilter
     * @return
     */
    public static List<StateFile> fromList(List<String> filenames, final List<State> stateFilters){
        List<StateFile> stateFiles = new LinkedList<StateFile>();
        for (String filename : filenames) {
            boolean accept = false;
            if(stateFilters != null){
                if(filename.startsWith(PREFIX)){
                    for (State stateFilter : stateFilters) {
                        if(filename.contains(stateFilter.toString())){
                            accept = true;
                            break;
                        }
                    }
                }
            }else{
                accept = filename.startsWith(PREFIX);
            }
            if(accept){
                StateFile stateFile = new StateFile(filename);
                stateFiles.add(stateFile);
            }
        }
        
        Collections.sort(stateFiles);
        
        return stateFiles;
    }

    /**
     * Returns a list of {@link StateFile}s in the specified directory
     * 
     * @param filenames
     * @return
     */
    public static List<StateFile> fromList(List<String> filenames){
        return fromList(filenames, null);
    }
    
    public static boolean updateStateFile(StateFile oldStateFile, StateFile newStateFile, File stateFileDir){
        // update the state file
        try {
            log.info("Updating state: " + oldStateFile + " -> " + newStateFile);
            File oldFile = new File(stateFileDir, oldStateFile.name());
            File newFile = new File(stateFileDir, newStateFile.name());
            
            log.debug("  renaming file: " + oldFile + " -> " + newFile);

            FileUtils.moveFile(oldFile, newFile);
        } catch (Exception e) {
            log.warn("Failed to update state file, e=" + e, e);
            return false;
        }
        return true;
    }
    
    /**
     * Build the name of the state file based on the elements.
     * 
     * @return
     */
    public String name(){
        return invariantPart() + "." + state + "_" + numTotal + "-" 
        + numComplete + "-" + numFailed; 
    }
    
    /**
     * Returns the invariant part of the state file name.
     * This includes the static PREFIX and the pipeline instance
     * and task ids.
     *  
     * @return
     */
    public String invariantPart(){
        return PREFIX + pipelineInstanceId + "." + pipelineTaskId + "." + exeName;
    }
    
    /**
     * This is the name of the task dir represented by this StateFile
     * 
     * @return
     */
    public String taskDirName(){
        StringBuffer taskDirName = new StringBuffer();
        taskDirName.append(getExeName()); 
        taskDirName.append("-matlab-"); 
        taskDirName.append(getPipelineInstanceId());
        taskDirName.append("-");
        taskDirName.append(getPipelineTaskId());
        
        return taskDirName.toString();
    }

    public String taskArchiveName(){
        StringBuffer tarName = new StringBuffer();
        tarName.append(taskDirName());
        tarName.append(TAR_EXTENSION);
        
        return tarName.toString();
    }
    
    public String jobName() {
        String jobName = exeName + "-" + pipelineTaskId;
        return jobName;
    }
    
    /**
     * Parse a string of the form:
     * 
     * PIID.PTID.EXENAME.STATE_TOTAL-COMPLETE-FAILED)
     * 
     * @param name
     */
    private void parse(String name) {
        if(!name.startsWith(PREFIX)){
            throw new IllegalArgumentException(name + " does not match expected format: " + FORMAT);
        }

        String nameSansPrefix = name.substring(PREFIX.length());
        String[] elements = nameSansPrefix.split("\\.");
        
        if(elements.length != 4){
            throw new IllegalArgumentException(name + " does not match expected format: " + FORMAT);
        }
        
        try {
            this.pipelineInstanceId = Long.parseLong(elements[0]);
            this.pipelineTaskId = Long.parseLong(elements[1]);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(name 
                + ": One of the IDs is not a number, expected format: " + FORMAT);
        }

        this.exeName = elements[2];
        
        String stateElement = elements[3];
        
        try {
            this.state = State.valueOf(stateElement.substring(0, stateElement.indexOf("_")));
        } catch (Exception e) {
            throw new IllegalArgumentException(name 
                + ": failed to parse state, expected format: " + FORMAT);
        }
        
        String counts = elements[3].substring(stateElement.indexOf("_")+1);
        String[] countElements = counts.split("-");

        if(countElements.length != 3){
            throw new IllegalArgumentException(name 
                + " failed to parse counts, expected format: " + FORMAT);
        }
        
        try {
            this.numTotal = Integer.parseInt(countElements[0]);
            this.numComplete = Integer.parseInt(countElements[1]);
            this.numFailed = Integer.parseInt(countElements[2]);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException(name 
                + ": non-number found in counts, expected format: " + FORMAT);
        }
    }
    
    @Override
    public String toString(){
        return name();
    }

    public long getPipelineInstanceId() {
        return pipelineInstanceId;
    }

    public void setPipelineInstanceId(long pipelineInstanceId) {
        this.pipelineInstanceId = pipelineInstanceId;
    }

    public long getPipelineTaskId() {
        return pipelineTaskId;
    }

    public void setPipelineTaskId(long pipelineTaskId) {
        this.pipelineTaskId = pipelineTaskId;
    }

    public String getExeName() {
        return exeName;
    }

    public void setExeName(String exeName) {
        this.exeName = exeName;
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public int getNumTotal() {
        return numTotal;
    }

    public void setNumTotal(int numTotal) {
        this.numTotal = numTotal;
    }

    public int getNumComplete() {
        return numComplete;
    }

    public void setNumComplete(int numComplete) {
        this.numComplete = numComplete;
    }

    public int getNumFailed() {
        return numFailed;
    }

    public void setNumFailed(int numFailed) {
        this.numFailed = numFailed;
    }

    public int getTimeoutSecs() {
        return timeoutSecs;
    }

    public void setTimeoutSecs(int timeoutSecs) {
        this.timeoutSecs = timeoutSecs;
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

    public boolean isMemdroneEnabled() {
        return memdroneEnabled;
    }

    public void setMemdroneEnabled(boolean memdroneEnabled) {
        this.memdroneEnabled = memdroneEnabled;
    }

    public PropertiesConfiguration getProps() {
        return props;
    }

    public boolean isSymlinksEnabled() {
        return symlinksEnabled;
    }

    public void setSymlinksEnabled(boolean symlinksEnabled) {
        this.symlinksEnabled = symlinksEnabled;
    }

    public String getRemoteNodeArchitecture() {
        return remoteNodeArchitecture;
    }

    public void setRemoteNodeArchitecture(String remoteNodeArchitecture) {
        this.remoteNodeArchitecture = remoteNodeArchitecture;
    }

    @Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((exeName == null) ? 0 : exeName.hashCode());
		result = prime * result + numComplete;
		result = prime * result + numFailed;
		result = prime * result + numTotal;
		result = prime * result
				+ (int) (pipelineInstanceId ^ (pipelineInstanceId >>> 32));
		result = prime * result
				+ (int) (pipelineTaskId ^ (pipelineTaskId >>> 32));
		result = prime * result + ((state == null) ? 0 : state.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		StateFile other = (StateFile) obj;
		if (exeName == null) {
			if (other.exeName != null)
				return false;
		} else if (!exeName.equals(other.exeName))
			return false;
		if (numComplete != other.numComplete)
			return false;
		if (numFailed != other.numFailed)
			return false;
		if (numTotal != other.numTotal)
			return false;
		if (pipelineInstanceId != other.pipelineInstanceId)
			return false;
		if (pipelineTaskId != other.pipelineTaskId)
			return false;
		if (state != other.state)
			return false;
		return true;
	}

    @Override
    public int compareTo(StateFile o) {
        return this.name().compareTo(o.name());
    }
}
