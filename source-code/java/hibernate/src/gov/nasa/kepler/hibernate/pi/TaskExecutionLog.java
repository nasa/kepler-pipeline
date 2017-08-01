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

package gov.nasa.kepler.hibernate.pi;

import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.text.SimpleDateFormat;
import java.util.Date;

import javax.persistence.Embeddable;

@Embeddable
public class TaskExecutionLog {

    /** hostname of the worker that processed (or is processing) this step */
    private String workerHost;

    /** worker thread number that processed (or is processing) this step */
    private int workerThread;

    /** Timestamp that processing started on this step */
    private Date startProcessingTime = new Date(0);

    /** Timestamp that processing ended (success or failure) on this step */
    private Date endProcessingTime = new Date(0);

    /** PipelineTask.State at the time this execution iteration started */
    private State initialState = PipelineTask.State.INITIALIZED;
    
    /** PipelineTask.State at the time this execution iteration ended */
    private State finalState = PipelineTask.State.INITIALIZED;

    /** PipelineTask.ProcessingState at the time this execution iteration started */
    private ProcessingState initialProcessingState = ProcessingState.INITIALIZING;

    /** PipelineTask.ProcessingState at the time this execution iteration ended */
    private ProcessingState finalProcessingState = ProcessingState.INITIALIZING;

    public TaskExecutionLog() {
    }

    public TaskExecutionLog(String workerHost, int workerThread) {
        this.workerHost = workerHost;
        this.workerThread = workerThread;
    }

    public String getWorkerHost() {
        return workerHost;
    }

    public void setWorkerHost(String workerHost) {
        this.workerHost = workerHost;
    }

    public int getWorkerThread() {
        return workerThread;
    }

    public void setWorkerThread(int workerThread) {
        this.workerThread = workerThread;
    }

    public Date getStartProcessingTime() {
        return startProcessingTime;
    }

    public void setStartProcessingTime(Date startProcessingTime) {
        this.startProcessingTime = startProcessingTime;
    }

    public Date getEndProcessingTime() {
        return endProcessingTime;
    }

    public void setEndProcessingTime(Date endProcessingTime) {
        this.endProcessingTime = endProcessingTime;
    }

    public State getInitialState() {
        return initialState;
    }

    public void setInitialState(State initialState) {
        this.initialState = initialState;
    }

    public State getFinalState() {
        return finalState;
    }

    public void setFinalState(State finalState) {
        this.finalState = finalState;
    }

    public ProcessingState getInitialProcessingState() {
        return initialProcessingState;
    }

    public void setInitialProcessingState(ProcessingState initialProcessingState) {
        this.initialProcessingState = initialProcessingState;
    }

    public ProcessingState getFinalProcessingState() {
        return finalProcessingState;
    }

    public void setFinalProcessingState(ProcessingState finalProcessingState) {
        this.finalProcessingState = finalProcessingState;
    }

    @Override
    public String toString() {
        SimpleDateFormat f = new SimpleDateFormat("MMddyy-HH:mm:ss");
        String start = f.format(startProcessingTime);
        String end = f.format(endProcessingTime);
        
        return "TaskExecutionLog [wh=" + workerHost + ", wt=" + workerThread
            + ", start=" + start + ", end=" + end
            + ", elapsed=" + StringUtils.elapsedTime(startProcessingTime, endProcessingTime)
            + ", Si=" + initialState + ", Sf=" + finalState + ", PSi="
            + initialProcessingState + ", PSf=" + finalProcessingState + "]";
    }
}
