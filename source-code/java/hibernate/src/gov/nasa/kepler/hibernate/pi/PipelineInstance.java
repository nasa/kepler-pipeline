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

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Represents an instance of a {@link PipelineDefinition} that either is running
 * or has completed. An instance of this class is created when a
 * {@link PipelineDefinition} is launched by a trigger.
 * <p>
 * Pipeline instances have a priority level which determines the JMS priority
 * for the messages that contain the individual unit of work tasks for this
 * pipeline instance.
 * <p>
 * Note that the {@link #equals(Object)} and {@link #hashCode()} methods are
 * written in terms of just the {@code id} field so this object should not be
 * used in sets and maps until it has been stored in the database
 * 
 * @author tklaus
 * 
 */
@Entity
@Table(name = "PI_PIPELINE_INSTANCE")
public class PipelineInstance {
    private static final Log log = LogFactory.getLog(PipelineInstance.class);

    public static final int HIGHEST_PRIORITY = 0;
    public static final int LOWEST_PRIORITY = 4;
    
    public enum State {
        /** Not yet launched */
        INITIALIZED,
        
        /** pipeline running or ready to run, no failed tasks */
        PROCESSING,
        
        /** at least one failed task, but others still running or ready to run */
        ERRORS_RUNNING,
        
        /** at least one failed task, no tasks can run (pipeline stalled) */
        ERRORS_STALLED,
        
        /** pipeline stopped/paused by operator */
        STOPPED,
        
        /** all tasks completed successfully */
        COMPLETED
    }

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_PIPE_INST_SEQ")
    private long id;

    /**
     * Descriptive name specified by the user at launch-time. Used when
     * displaying the instance in the PIG. Does not have to be unique
     */
    private String name;

    @ManyToOne
    private Group group = null;
    
    /** Timestamp that processing started on this pipeline instance */
    private Date startProcessingTime = new Date(0);

    /** Timestamp that processing ended (successfully) on this pipeline instance */
    private Date endProcessingTime = new Date(0);

    @ManyToOne
    private PipelineDefinition pipelineDefinition = null;

    private State state = State.INITIALIZED;
    private int priority = LOWEST_PRIORITY;

    /**
     * {@link ParameterSet}s used as {@link Parameters} for this instance. This
     * is a hard-reference to a specific version of the {@link ParameterSet},
     * selected at launch time (typically the latest available version)
     */
    @ManyToMany
    @JoinTable(name = "PI_INSTANCE_PS")
    private Map<ClassWrapper<Parameters>, ParameterSet> pipelineParameterSets = new HashMap<ClassWrapper<Parameters>, ParameterSet>();

    /**
     * {@link ModelRegistry} in force at the time this pipeline instance was
     * launched. For data accountability
     */
    @ManyToOne
    private ModelRegistry modelRegistry = null;
    
    /**
     * Name of the Trigger that launched this pipeline
     */
    private String triggerName;

    /** If set, the pipeline instance will start at the specified node */
    @OneToOne
    @JoinColumn(name = "START_NODE")
    private PipelineInstanceNode startNode;

    /**
     * If set, the pipeline instance will end at the specified node. Note that
     * only one endNode can be specified, so only one branch can be terminated
     * early. If the pipeline branches before this endNode, other branches will
     * proceed to the end.
     */
    @OneToOne
    @JoinColumn(name = "END_NODE")
    private PipelineInstanceNode endNode;

    /**
     * Required by Hibernate
     */
    public PipelineInstance() {
    }

    public PipelineInstance(PipelineDefinition pipeline) {
        pipelineDefinition = pipeline;
    }

    public State getState() {
        return state;
    }

    public void setState(State state) {
        this.state = state;
    }

    public long getId() {
        return id;
    }

    public void setId(long id) {
        this.id = id;
    }

    public PipelineDefinition getPipelineDefinition() {
        return pipelineDefinition;
    }

    public void setPipelineDefinition(PipelineDefinition pipeline) {
        pipelineDefinition = pipeline;
    }

    public int getPriority() {
        return priority;
    }

    public void setPriority(int priority) {
        this.priority = priority;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public Date getEndProcessingTime() {
        return endProcessingTime;
    }

    public void setEndProcessingTime(Date endProcessingTime) {
        this.endProcessingTime = endProcessingTime;
    }

    public Date getStartProcessingTime() {
        return startProcessingTime;
    }

    public void setStartProcessingTime(Date startProcessingTime) {
        this.startProcessingTime = startProcessingTime;
    }

    /**
     * @return the triggerName
     */
    public String getTriggerName() {
        return triggerName;
    }

    /**
     * @param triggerName the triggerName to set
     */
    public void setTriggerName(String triggerName) {
        this.triggerName = triggerName;
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
        final PipelineInstance other = (PipelineInstance) obj;
        if (id != other.id) {
            return false;
        }
        return true;
    }

    public Map<ClassWrapper<Parameters>, ParameterSet> getPipelineParameterSets() {
        return pipelineParameterSets;
    }

    public void setPipelineParameterSets(
        Map<ClassWrapper<Parameters>, ParameterSet> pipelineParameterSets) {
        this.pipelineParameterSets = pipelineParameterSets;
    }

    public boolean hasPipelineParameters(
        Class<? extends Parameters> parametersClass) {

        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(
            parametersClass);

        return pipelineParameterSets.get(classWrapper) != null;
    }

    /**
     * Convenience method for getting the pipeline parameters for the specified
     * {@link Parameters} class for this {@link PipelineInstance}
     * 
     * @param parametersClass
     * @return
     */
    public Parameters getPipelineParameters(
        Class<? extends Parameters> parametersClass) {

        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(
            parametersClass);
        ParameterSet pipelineParamSet = pipelineParameterSets.get(classWrapper);

        if (pipelineParamSet != null) {
            log.debug("Pipeline parameters for class: " + parametersClass
                + " found");
            return pipelineParamSet.parametersInstance();
        } else {
            throw new PipelineException("Pipeline parameters for class: "
                + parametersClass + " not found in PipelineInstance");
        }
    }

    /**
     * Retrieve module {@link Parameters} for this {@link PipelineInstance}.
     * This method is not intended to be called directly, use the convenience
     * method {@link PipelineTask}.getParameters().
     * 
     * @param parametersClass
     * @return
     */
    ParameterSet getPipelineParameterSet(
        Class<? extends Parameters> parametersClass) {
        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(
            parametersClass);
        return pipelineParameterSets.get(classWrapper);
    }

    public void clearParameterSets() {
        pipelineParameterSets.clear();
    }

    public ParameterSet putParameterSet(ClassWrapper<Parameters> key,
        ParameterSet value) {
        return pipelineParameterSets.put(key, value);
    }

    /**
     * @return the name
     */
    public String getName() {
        return name;
    }

    /**
     * @param name the name to set
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * @return the startNode
     */
    public PipelineInstanceNode getStartNode() {
        return startNode;
    }

    /**
     * @param startNode the startNode to set
     */
    public void setStartNode(PipelineInstanceNode startNode) {
        this.startNode = startNode;
    }

    /**
     * @return the endNode
     */
    public PipelineInstanceNode getEndNode() {
        return endNode;
    }

    /**
     * @param endNode the endNode to set
     */
    public void setEndNode(PipelineInstanceNode endNode) {
        this.endNode = endNode;
    }

    public Group getGroup() {
        return group;
    }

    public void setGroup(Group group) {
        this.group = group;
    }

    /**
     * @return the modelRegistry
     */
    public ModelRegistry getModelRegistry() {
        return modelRegistry;
    }

    /**
     * @param modelRegistry the modelRegistry to set
     */
    public void setModelRegistry(ModelRegistry modelRegistry) {
        this.modelRegistry = modelRegistry;
    }
}
