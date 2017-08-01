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

import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Represents a single pipeline unit of work Associated with a
 * {@link PipelineInstance}, a {@link PipelineDefinitionNode} (which is
 * associated with a {@link PipelineModuleDefinition}), and a
 * {@link UnitOfWorkTask} that represents the unit of work.
 * <p>
 * Note that the {@link #equals(Object)} and {@link #hashCode()} methods are
 * written in terms of just the {@code id} field so this object should not be
 * used in sets and maps until it has been stored in the database
 * 
 * @author tklaus
 */
@Entity
@Table(name = "PI_PIPELINE_TASK")
public class PipelineTask {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PipelineTask.class);

    public enum State {
        /** Not yet started */
        INITIALIZED,

        /**
         * Task has been placed on the JMS queue, but not yet picked up by a
         * worker.
         */
        SUBMITTED,

        /** Task is being processed by a worker */
        PROCESSING,

        /**
         * Task failed. Transition logic will not run (pipeline will stall). For
         * tasks with sub-tasks, this means that all sub-tasks failed.
         */
        ERROR,

        /** Task completed successfully. Transition logic will run. */
        COMPLETED,

        /**
         * Task contains sub-tasks and at least one sub-task failed and at least
         * one sub-task completed successfully
         */
        PARTIAL;

        public String htmlString() {
            String color = "black";

            switch (this) {
                case INITIALIZED:
                case SUBMITTED:
                    color = "black";
                    break;

                case PROCESSING:
                    color = "blue";
                    break;

                case COMPLETED:
                    color = "green";
                    break;

                case ERROR:
                case PARTIAL:
                    color = "red";
                    break;

                default:
            }

            return ("<html><b><font color=" + color + ">" + this.toString() + "</font></b></html>");
        }
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_PIPE_TASK_SEQ")
    private long id;

    /** Current state of this task */
    private State state = State.INITIALIZED;

    /**
     * Flag that indicates whether the transition logic has run successfully for
     * this task
     */
    private boolean transitionComplete = false;

    /**
     * Flag that indicates that this task was re-run from the PIG after an error
     */
    private boolean retry = false;

    /** Timestamp this task was created (either by launcher or transition logic) */
    private Date created = new Date(System.currentTimeMillis());

    /** hostname of the worker that processed (or is processing) this task */
    private String workerHost;

    /** worker thread number that processed (or is processing) this task */
    private int workerThread;

    /** SVN revision of the build at the time this task was executed */
    private String softwareRevision;

    /** Timestamp that processing started on this task */
    private Date startProcessingTime = new Date(0);

    /** Timestamp that processing ended (success or failure) on this task */
    private Date endProcessingTime = new Date(0);

    /** Number of times this task failed and was rolled back */
    private int failureCount = 0;

    @ManyToOne
    private PipelineInstance pipelineInstance = null;

    @ManyToOne
    private PipelineInstanceNode pipelineInstanceNode = null;

    @ManyToOne
    private PipelineDefinitionNode pipelineDefinitionNode = null;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name = "clazz", column = @Column(name = "UOW_T_CN")),
        @AttributeOverride(name = "properties", column = @Column(name = "UOW_T_PROPS")) })
    private BeanWrapper<UnitOfWorkTask> uowTask;

    @org.hibernate.annotations.CollectionOfElements
    @JoinTable(name = "PI_PIPELINE_TASK_METRICS")
    private List<PipelineTaskMetrics> summaryMetrics = new ArrayList<PipelineTaskMetrics>();

    private String restartMode = null;

    @org.hibernate.annotations.CollectionOfElements
    @org.hibernate.annotations.IndexColumn(name = "idx")
    @JoinTable(name = "PI_PIPELINE_TASK_EXEC_LOG")
    private List<TaskExecutionLog> execLog = new ArrayList<TaskExecutionLog>();

    /**
     * Required by Hibernate
     */
    public PipelineTask() {
    }

    public PipelineTask(PipelineInstance pipelineInstance,
        PipelineDefinitionNode pipelineDefinitionNode,
        PipelineInstanceNode pipelineInstanceNode) {
        this.pipelineInstance = pipelineInstance;
        this.pipelineDefinitionNode = pipelineDefinitionNode;
        this.pipelineInstanceNode = pipelineInstanceNode;
    }

    /**
     * Get {@link Parameters} from either the pipeline or module parameters for
     * the specified class.
     * 
     * An exception is thrown if the parameters are not defined as either
     * pipeline parameters or module parameters, or if they are defined at both
     * levels (this is a mis-configuration that should have been caught when the
     * {@link TriggerDefinition} was created or updated (see the validation
     * logic in {@link TriggerDefinitionCrud}
     * 
     * @param parametersClass
     * @return
     */
    public <T extends Parameters> T getParameters(Class<T> parametersClass) {
        return getParameters(parametersClass, true);
    }

    /**
     * Get {@link Parameters} from either the pipeline or module parameters for
     * the specified class.
     * 
     * @param parametersClass
     * @return
     */
    @SuppressWarnings("unchecked")
    public <T extends Parameters> T getParameters(Class<T> parametersClass,
        boolean throwIfMissing) {
        ParameterSet pipelineParamSet = pipelineInstance.getPipelineParameterSet(parametersClass);
        ParameterSet moduleParamSet = pipelineInstanceNode.getModuleParameterSet(parametersClass);

        if (pipelineParamSet == null && moduleParamSet == null) {
            String errMsg = "Parameters for class: "
                + parametersClass
                + " not found in either pipeline parameters or module parameters";

            if (throwIfMissing) {
                throw new PipelineException(errMsg);
            }
            return null;
        } else if (pipelineParamSet != null && moduleParamSet != null) {
            throw new PipelineException("Parameters for class: "
                + parametersClass
                + " found in both pipeline parameters and module parameters");
        } else {
            if (moduleParamSet != null) {
                return (T) moduleParamSet.parametersInstance();
            }
            return (T) pipelineParamSet.parametersInstance();
        }
    }

    /**
     * Convenience function for getting the module exe name
     * 
     * @return
     */
    public String moduleExeName() {
        return getPipelineInstanceNode().getPipelineModuleDefinition()
            .getExeName();
    }

    /**
     * A human readable description of this task and its parameters.
     * 
     * @throws PipelineException
     * 
     */
    public String prettyPrint() {

        PipelineModuleDefinition moduleDefinition = pipelineInstanceNode.getPipelineModuleDefinition();

        StringBuilder bldr = new StringBuilder();
        bldr.append("TaskId: ")
            .append(getId())
            .append(" ")
            .append("Module Software Revision: ")
            .append(getSoftwareRevision())
            .append(" ")
            .append(moduleDefinition.getName())
            .append(" ")
            .append(" UoW: ")
            .append(uowTaskInstance().briefState())
            .append(" ");

        Collection<ParameterSet> setOfParameterSets = pipelineInstanceNode.getModuleParameterSets()
            .values();

        for (ParameterSet pset : setOfParameterSets) {
            bldr.append('[')
                .append(pset.getDescription())
                .append(" ");
            bldr.append(pset.getVersion())
                .append(" ");
            Map<String, String> strParameters = pset.getParameters()
                .getProps();
            for (Map.Entry<String, String> pDescription : strParameters.entrySet()) {
                bldr.append(pDescription.getKey())
                    .append("=")
                    .append(pDescription.getValue())
                    .append(" ");
            }
            bldr.append(']');
        }

        return bldr.toString();

    }

    public String getModuleName() {
        return pipelineDefinitionNode.getModuleName()
            .getName();
    }

    public PipelineModule getModuleImplementation() {
        PipelineModule module = pipelineInstanceNode.getPipelineModuleDefinition()
            .getImplementingClass()
            .newInstance();
        return module;
    }

    public PipelineDefinitionNode getPipelineDefinitionNode() {
        return pipelineDefinitionNode;
    }

    public void setPipelineDefinitionNode(PipelineDefinitionNode configNode) {
        pipelineDefinitionNode = configNode;
    }

    public Date getCreated() {
        return created;
    }

    public void setCreated(Date created) {
        this.created = created;
    }

    public PipelineInstance getPipelineInstance() {
        return pipelineInstance;
    }

    public void setPipelineInstance(PipelineInstance instance) {
        pipelineInstance = instance;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public BeanWrapper<UnitOfWorkTask> getUowTask() {
        return uowTask;
    }

    public void setUowTask(BeanWrapper<UnitOfWorkTask> uowTask) {
        this.uowTask = uowTask;
    }

    @SuppressWarnings("unchecked")
    public <T extends UnitOfWorkTask> T uowTaskInstance() {
        return (T) getUowTask().getInstance();
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public Date getEndProcessingTime() {
        return endProcessingTime;
    }

    public void setEndProcessingTime(Date endProcessingTime) {
        this.endProcessingTime = endProcessingTime;
    }

    public int getFailureCount() {
        return failureCount;
    }

    public void setFailureCount(int failureCount) {
        this.failureCount = failureCount;
    }

    public void incrementFailureCount() {
        failureCount++;
    }

    public Date getStartProcessingTime() {
        return startProcessingTime;
    }

    public void setStartProcessingTime(Date startProcessingTime) {
        this.startProcessingTime = startProcessingTime;
    }

    public String getWorkerName() {
        if (workerHost != null && workerHost.length() > 0) {
            return workerHost + ":" + workerThread;
        }
        return "-";
    }

    public boolean isTransitionComplete() {
        return transitionComplete;
    }

    public void setTransitionComplete(boolean transitionComplete) {
        this.transitionComplete = transitionComplete;
    }

    public PipelineInstanceNode getPipelineInstanceNode() {
        return pipelineInstanceNode;
    }

    public String getSoftwareRevision() {
        return softwareRevision;
    }

    public void setSoftwareRevision(String softwareRevision) {
        this.softwareRevision = softwareRevision;
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

    public boolean isRetry() {
        return retry;
    }

    public void setRetry(boolean retry) {
        this.retry = retry;
    }

    public List<PipelineTaskMetrics> getSummaryMetrics() {
        return summaryMetrics;
    }

    public void setSummaryMetrics(List<PipelineTaskMetrics> summaryMetrics) {
        this.summaryMetrics = summaryMetrics;
    }

    public String getRestartMode() {
        return restartMode;
    }

    public void setRestartMode(String restartMode) {
        this.restartMode = restartMode;
    }

    public List<TaskExecutionLog> getExecLog() {
        return execLog;
    }

    public void setExecLog(List<TaskExecutionLog> execLog) {
        this.execLog = execLog;
    }

    /**
     * For TEST use only
     */
    public void setPipelineInstanceNode(
        PipelineInstanceNode pipelineInstanceNode) {
        this.pipelineInstanceNode = pipelineInstanceNode;
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (id ^ id >>> 32);
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final PipelineTask other = (PipelineTask) obj;
        if (id != other.id) {
            return false;
        }
        return true;
    }
}
