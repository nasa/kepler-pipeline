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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.pi.worker.messages.WorkerTaskRequest;
import gov.nasa.spiffy.common.metrics.Metric;

import java.io.File;
import java.util.Map;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class WorkerThreadContext {

    public enum ThreadState {
        IDLE, PROCESSING
    }

    private WorkerTaskRequest currentRequest = null;
    private PipelineInstance currentPipelineInstance = null;
    private PipelineTask currentPipelineTask = null;
    private PipelineModule currentPipelineModule = null;
    private ThreadState currentState = ThreadState.IDLE;
    private String currentModule = "-";
    private String currentModuleUow = "-";
    private long currentProcessingStartTimeMillis = 0;
    private int currentMinMemoryMegaBytes = 0;
    private File currentTaskWorkingDir = null;
    private TaskLog taskLog = null;
    private long moduleExecTime = 0L;
    private Map<String, Metric> threadMetrics = null;
    
    public WorkerThreadContext() {
    }

    public WorkerTaskRequest getCurrentRequest() {
        return currentRequest;
    }

    public void setCurrentRequest(WorkerTaskRequest currentRequest) {
        this.currentRequest = currentRequest;
    }

    public PipelineInstance getCurrentPipelineInstance() {
        return currentPipelineInstance;
    }

    public void setCurrentPipelineInstance(PipelineInstance currentPipelineInstance) {
        this.currentPipelineInstance = currentPipelineInstance;
    }

    public PipelineTask getCurrentPipelineTask() {
        return currentPipelineTask;
    }

    public void setCurrentPipelineTask(PipelineTask currentPipelineTask) {
        this.currentPipelineTask = currentPipelineTask;
    }

    public PipelineModule getCurrentPipelineModule() {
        return currentPipelineModule;
    }

    public void setCurrentPipelineModule(PipelineModule currentPipelineModule) {
        this.currentPipelineModule = currentPipelineModule;
    }

    public ThreadState getCurrentState() {
        return currentState;
    }

    public void setCurrentState(ThreadState currentState) {
        this.currentState = currentState;
    }

    public String getCurrentModule() {
        return currentModule;
    }

    public void setCurrentModule(String currentModule) {
        this.currentModule = currentModule;
    }

    public String getCurrentModuleUow() {
        return currentModuleUow;
    }

    public void setCurrentModuleUow(String currentModuleUow) {
        this.currentModuleUow = currentModuleUow;
    }

    public long getCurrentProcessingStartTimeMillis() {
        return currentProcessingStartTimeMillis;
    }

    public void setCurrentProcessingStartTimeMillis(long currentProcessingStartTimeMillis) {
        this.currentProcessingStartTimeMillis = currentProcessingStartTimeMillis;
    }

    public int getCurrentMinMemoryMegaBytes() {
        return currentMinMemoryMegaBytes;
    }

    public void setCurrentMinMemoryMegaBytes(int currentMinMemoryMegaBytes) {
        this.currentMinMemoryMegaBytes = currentMinMemoryMegaBytes;
    }

    public File getCurrentTaskWorkingDir() {
        return currentTaskWorkingDir;
    }

    public void setCurrentTaskWorkingDir(File currentTaskWorkingDir) {
        this.currentTaskWorkingDir = currentTaskWorkingDir;
    }

    public TaskLog getTaskLog() {
        return taskLog;
    }

    public void setTaskLog(TaskLog taskLog) {
        this.taskLog = taskLog;
    }

    /**
     * @return the moduleExecTime
     */
    public long getModuleExecTime() {
        return moduleExecTime;
    }

    /**
     * @param moduleExecTime the moduleExecTime to set
     */
    public void setModuleExecTime(long moduleExecTime) {
        this.moduleExecTime = moduleExecTime;
    }

    /**
     * @return the threadMetrics
     */
    public Map<String, Metric> getThreadMetrics() {
        return threadMetrics;
    }

    /**
     * @param threadMetrics the threadMetrics to set
     */
    public void setThreadMetrics(Map<String, Metric> threadMetrics) {
        this.threadMetrics = threadMetrics;
    }
}
