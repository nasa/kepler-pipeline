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

import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.spiffy.common.pi.Parameters;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.apache.commons.lang.builder.ReflectionToStringBuilder;

/**
 * Created by the {@link PipelineExecutor} when creating {@link PipelineTask}
 * objects for a {@link PipelineDefinitionNode}
 * 
 * Associated with a {@link PipelineInstance}, and a
 * {@link PipelineDefinitionNode}. Contains the number of {@link PipelineTask}
 * objects created for this node and their aggregate states so that the 
 * transition logic can properly determine whether all tasks for this node 
 * have completed.
 * 
 * @author tklaus
 * 
 */
@Entity
@Table(name = "PI_PIPELINE_INST_NODE")
public class PipelineInstanceNode {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_PIPE_IN_SEQ")
    private long id;

    /** Timestamp this was created (either by launcher or transition logic) */
    private Date created = new Date(System.currentTimeMillis());

    /**
     * Total number of {@link PipelineTask}s needed for the associated
     * {@link PipelineDefinitionNode}
     */
    private int numTasks = 0;

    /**
     * Number of {@link PipelineTask}s actually created for the associated
     * {@link PipelineDefinitionNode}. For nodes where
     * {@link PipelineDefinitionNode.startNewUow} == true, this number will be
     * equal to numTasks above since all of the tasks are created when the node
     * is launched. For nodes where startNewUow == false, this field will start
     * out at zero and will be incremented by 1 by the transition logic as each
     * task for the previous node completes.
     */
    private int numSubmittedTasks = 0;

    /**
     * Number of {@link PipelineTask}s completed for the associated
     * {@link PipelineDefinitionNode}. If numCompletedTasks == numTasks, then
     * this node is complete and the transition logic will progress to the next
     * node. The transition logic uses 'select for update' locking when
     * accessing this object to ensure that this field is updated atomically
     */
    private int numCompletedTasks = 0;

    /**
     * Number of {@link PipelineTask}s that have failed for the associated
     * {@link PipelineDefinitionNode}. If numFailedTasks > 0 and
     * (numCompletedTasks + numFailedTasks) == numTasks, then all tasks have
     * been attempted at least once and the {@link PipelineInstance} state will
     * be set to failed.  The transition logic uses 'select for update' locking when
     * accessing this object to ensure that this field is updated atomically
     */
    private int numFailedTasks = 0;

    @ManyToOne
    private PipelineInstance pipelineInstance = null;

    @ManyToOne
    private PipelineDefinitionNode pipelineDefinitionNode = null;

    @ManyToOne
    private PipelineModuleDefinition pipelineModuleDefinition = null;

    /**
     * {@link ParameterSet}s used as {@link Parameters} for this instance. This
     * is a hard-reference to a specific version of the {@link ParameterSet},
     * selected at launch time (typically the latest available version)
     */
    @ManyToMany
    @JoinTable(name = "PI_PIN_PI_MPS")
    private Map<ClassWrapper<Parameters>, ParameterSet> moduleParameterSets = new HashMap<ClassWrapper<Parameters>, ParameterSet>();

    /**
     * Required by Hibernate
     */
    public PipelineInstanceNode() {
    }

    public PipelineInstanceNode(PipelineInstance pipelineInstance,
        PipelineDefinitionNode pipelineDefinitionNode,
        PipelineModuleDefinition pipelineModuleDefinition) {
        this.pipelineInstance = pipelineInstance;
        this.pipelineDefinitionNode = pipelineDefinitionNode;
        this.pipelineModuleDefinition = pipelineModuleDefinition;
    }

    /**
     * Specify the counts at creation-time.  Only used by tests
     * 
     * @param pipelineInstance
     * @param pipelineDefinitionNode
     * @param pipelineModuleDefinition
     * @param numTasks
     * @param numSubmittedTasks
     * @param numCompletedTasks
     * @param numFailedTasks
     */
    PipelineInstanceNode(PipelineInstance pipelineInstance,
        PipelineDefinitionNode pipelineDefinitionNode,
        PipelineModuleDefinition pipelineModuleDefinition, int numTasks,
        int numSubmittedTasks, int numCompletedTasks, int numFailedTasks) {
        this.pipelineInstance = pipelineInstance;
        this.pipelineDefinitionNode = pipelineDefinitionNode;
        this.pipelineModuleDefinition = pipelineModuleDefinition;
        this.numTasks = numTasks;
        this.numSubmittedTasks = numSubmittedTasks;
        this.numCompletedTasks = numCompletedTasks;
        this.numFailedTasks = numFailedTasks;
    }

    /**
     * Return the aggregate state for the node.
     * Used for reporting.
     * 
     * @return
     */
    public PipelineInstance.State state(){
        PipelineInstance.State nodeState = State.INITIALIZED;
        
        if(numTasks > 0){
            if (numCompletedTasks == numTasks) {
                nodeState = PipelineInstance.State.COMPLETED;
            } else {
                if (numFailedTasks > 0) {
                    if (numFailedTasks + numCompletedTasks == numSubmittedTasks) {
                        nodeState = PipelineInstance.State.ERRORS_STALLED;
                    } else {
                        nodeState = PipelineInstance.State.ERRORS_RUNNING;
                    }
                } else {
                    nodeState = PipelineInstance.State.PROCESSING;
                }
            }        
        }
        return nodeState;
    }
    
    public void setNumTasks(int taskCount) {
        this.numTasks = taskCount;
    }

    /**
     * Should only be called for new (non-persisted) instances of PipelineInstanceNode.
     * For persisted instances, use PipelineInstanceNodeCrud.incrementSubmittedTaskCount()
     * to ensure that the instance is updated atomically (it does select for update)
     * 
     * @param numSubmittedTasks
     */
    public void setNumSubmittedTasks(int numSubmittedTasks) {
        this.numSubmittedTasks = numSubmittedTasks;
    }

    public int getNumTasks() {
        return numTasks;
    }

    public int getNumCompletedTasks() {
        return numCompletedTasks;
    }

    public PipelineDefinitionNode getPipelineDefinitionNode() {
        return pipelineDefinitionNode;
    }

    public void setPipelineDefinitionNode(PipelineDefinitionNode configNode) {
        this.pipelineDefinitionNode = configNode;
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
        this.pipelineInstance = instance;
    }

    public long getId() {
        return id;
    }

    @Override
    public String toString() {
        return ReflectionToStringBuilder.toString(this);
    }

    public PipelineModuleDefinition getPipelineModuleDefinition() {
        return pipelineModuleDefinition;
    }

    public void setPipelineModuleDefinition(
        PipelineModuleDefinition pipelineModuleDefinition) {
        this.pipelineModuleDefinition = pipelineModuleDefinition;
    }

    public int getNumFailedTasks() {
        return numFailedTasks;
    }

    /**
     * Retrieve module {@link Parameters} for this {@link PipelineInstanceNode}.
     * This method is not intended to be called directly, use the convenience
     * method {@link PipelineTask}.getParameters().
     * 
     * @param parametersClass
     * @return
     */
    ParameterSet getModuleParameterSet(
        Class<? extends Parameters> parametersClass) {
        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(
            parametersClass);
        return moduleParameterSets.get(classWrapper);
    }

    public Map<ClassWrapper<Parameters>, ParameterSet> getModuleParameterSets() {
        return moduleParameterSets;
    }

    public void setModuleParameterSets(
        Map<ClassWrapper<Parameters>, ParameterSet> moduleParameterSets) {
        this.moduleParameterSets = moduleParameterSets;
    }

    public ParameterSet putModuleParameterSet(
        Class<? extends Parameters> clazz, ParameterSet paramSet) {
        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(
            clazz);
        return moduleParameterSets.put(classWrapper, paramSet);
    }

    public int getNumSubmittedTasks() {
        return numSubmittedTasks;
    }
}
