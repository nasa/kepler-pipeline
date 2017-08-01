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

import gov.nasa.kepler.hibernate.pi.PipelineTaskMetrics.Units;
import gov.nasa.spiffy.common.metrics.Metric;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is the super-class for all pipeline modules.
 *
 * It defines the entry point called by the pipeline infrastructure when
 * a task arrives for this module (processTask()).
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public abstract class PipelineModule {
    private static final Log log = LogFactory.getLog(PipelineModule.class);

    public static final String RERUN_MODE_RESET_BEGINNING = "Restart from beginning";

    /**
     * If set to true by a sub-class, the current task will be committed 
     * when the task completes, but the transition logic will not be run.
     */
    private boolean haltPipelineOnTaskCompletion = false;
    
    /**
     * Used by sub-classes to indicate that only a subset of the unit of work
     * was processed successfully. In this case, the transaction will be 
     * committed and the transition logic will be executed, but the 
     * {@link PipelineTask} state will be set to PARTIAL instead of
     * COMPLETE. 
     */
    private boolean partialSuccess = false;
    
    /**
     * Sub-classes should provide a very light-weight default constructor (no dependencies,
     * no complex logic) since they are instantiated by seed data classes and by the PIG
     * in order to query them for various types of information (UOW task type, parameter types,
     * module name, etc.)
     */
    public PipelineModule() {
    }

    /**
     * Called by the pipeline framework immediately after constructing the object.
     * Allows {@link PipelineModule} implementations to perform any necessary
     * initialization prior to processing a task.
     */
    public void initialize(PipelineTask pipelineTask){
    }

    /**
     * 
     * @param pipelineInstance
     * @param pipelineTask
     * @return complete. If true, processing is done and transtion logic is executed
     * @throws Exception 
     */
    public boolean process(PipelineInstance pipelineInstance, PipelineTask pipelineTask) throws Exception{
        processTask(pipelineInstance, pipelineTask);
        return true;
    }
    
    /**
     * Normal entry point for modules.
     * 
     * @param taskId
     * @param unitOfWork
     * @param parameters
     * @throws PipelineException
     */
    public abstract void processTask(PipelineInstance pipelineInstance, PipelineTask pipelineTask) throws PipelineException;

    /**
     * Update the PipelineTask.summaryMetrics.
     * 
     * This default implementation adds a single category ("ALL") with the overall execution time. 
     * 
     * Subclasses can override this method to provide module-specific categories.
     * 
     * @param pipelineTask
     */
    public void updateMetrics(PipelineTask pipelineTask, Map<String, Metric> threadMetrics, long overallExecTimeMillis){
        List<PipelineTaskMetrics> taskMetrics = new ArrayList<PipelineTaskMetrics>();
        PipelineTaskMetrics m = new PipelineTaskMetrics("All", overallExecTimeMillis, Units.TIME);
        taskMetrics.add(m);
        pipelineTask.setSummaryMetrics(taskMetrics);
    }
    
    public abstract String getModuleName();

    /**
     * Returns the type of the {@link UnitOfWorkTask} supported by this PipelineModule.
     * This is used by the PIG to make sure that the user doesn't assign a UOW type to a PipelineModule
     * that it doesn't support.
     *  
     * @return
     */
    public abstract Class<? extends UnitOfWorkTask> unitOfWorkTaskType();

    /**
     * Returns a List of the types of {@link Parameters} required by this PipelineModule, if any.
     * If non-null, this is used by the PIG to make sure that the user assigns all necessary {@link ParameterSet}s.
     * 
     * Sub-classes that use Parameters should override this method to specify the type(s) they expect.  
     * 
     * @return
     */
    public List<Class<? extends Parameters>> requiredParameters(){
        return new ArrayList<Class<? extends Parameters>>();
    }
    
    public String[] supportedRestartModes(){
        return new String[]{RERUN_MODE_RESET_BEGINNING};
    }
    
    protected void logTaskInfo(PipelineInstance instance, PipelineTask task) {
        log.debug("["+getModuleName()+"]instance id = " + instance.getId());
        log.debug("["+getModuleName()+"]instance node id = " + task.getId());
        log.debug("["+getModuleName()+"]instance node uow = " + task.uowTaskInstance().briefState());
    }

    public boolean isHaltPipelineOnTaskCompletion() {
        return haltPipelineOnTaskCompletion;
    }

    public void setHaltPipelineOnTaskCompletion(boolean haltPipelineOnTaskCompletion) {
        this.haltPipelineOnTaskCompletion = haltPipelineOnTaskCompletion;
    }

    public boolean isPartialSuccess() {
        return partialSuccess;
    }

    public void setPartialSuccess(boolean partialSuccess) {
        this.partialSuccess = partialSuccess;
    }
}