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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.IndexColumn;

/**
 * This class models a single node in a pipeline definition.
 * Each node maps to a {@link PipelineModuleDefinition} that specifies
 * which algorithm is executed at this node.  A node is executed once
 * for each unit of work.  A node may have any number of nextNodes, which
 * are executed in parallel once this node completes.
 * 
 * @author tklaus
 * 
 */
@Entity
@Table(name = "PI_PIPELINE_DEF_NODE")
public class PipelineDefinitionNode{

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_PDN_SEQ")
    private long id = -1;

    /** Indicates whether the transition logic should simply
     * propagate the {@link UnitOfWorkTask} to the next node
     * or whether it should check to see if all tasks for the current
     * node have completed, and if so, invoke the {@link UnitOfWorkTaskGenerator}
     * to generate the tasks for the next node. 
     * See {@link PipelineExecutor.doTransition() */
    private boolean startNewUow = false;
    
    /** If non-null, this UOW definition is used to generate the 
     * tasks for this node.  May only be null if startNewUow == false
     * (in which case the task from the previous node is just carried forward)
     * and this is not the first node in a pipeline.
     */
    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name="clazz", column=@Column(name="UOW_TG_CN"))
    })
    private ClassWrapper<UnitOfWorkTaskGenerator> unitOfWork = null;
        
    @ManyToOne(fetch=FetchType.EAGER)
    private ModuleName moduleName;
    
    @OneToMany(fetch=FetchType.EAGER)
    @Cascade({org.hibernate.annotations.CascadeType.SAVE_UPDATE,org.hibernate.annotations.CascadeType.EVICT})
    @JoinTable(name = "PI_PDN_PDN", joinColumns = @JoinColumn(name = "PARENT_PI_PDN_ID"), inverseJoinColumns = @JoinColumn(name = "CHILD_PI_PDN_ID"))
    @IndexColumn(name = "IDX")
    private List<PipelineDefinitionNode> nextNodes = new ArrayList<PipelineDefinitionNode>();

    /* Not stored in the database, but can be set for all nodes in a pipeline by calling
     * PipelineDefinition.buildPaths()
     */
    private transient PipelineDefinitionNode parentNode = null;
    private transient PipelineDefinitionNodePath path = null;
    
    public PipelineDefinitionNode() {
    }

    public PipelineDefinitionNode(ModuleName pipelineModuleDefinitionName) {
        this.moduleName = pipelineModuleDefinitionName;
    }

    /**
     * Copy constructor
     * Duplicate this node and all of its child nodes.
     * 
     * @param other
     */
    public PipelineDefinitionNode(PipelineDefinitionNode other) {
        this.startNewUow = other.startNewUow;
        this.moduleName = other.moduleName;
        
        if(other.unitOfWork != null){
            this.unitOfWork = new ClassWrapper<UnitOfWorkTaskGenerator>(other.unitOfWork);
        }
        
        for (PipelineDefinitionNode otherNode : other.nextNodes) {
            this.nextNodes.add(new PipelineDefinitionNode(otherNode));
        }
    }
    
    /**
     * Return the list of required parameter set types needed by the UOW task generator
     * for this node.  Used by {@link PipelineOperations} and the PIG to validate triggers
     * 
     * @return
     */
    public Set<ClassWrapper<Parameters>> getUowRequiredParameterClasses() {
        Set<ClassWrapper<Parameters>> requiredParameters = new HashSet<ClassWrapper<Parameters>>();

        if(hasValidUow()){
            UnitOfWorkTaskGenerator uowTaskGenerator = unitOfWork.newInstance();
            List<Class<? extends Parameters>> uowParameters = uowTaskGenerator.requiredParameterClasses();
            
            for (Class<? extends Parameters> clazz : uowParameters) {
                requiredParameters.add(new ClassWrapper<Parameters>(clazz));
            }
        }
        
        return requiredParameters;
    }

    public boolean hasValidUow() {
        return unitOfWork != null && unitOfWork.isInitialized();
    }

    /**
     * @return the id
     */
    public long getId() {
        return id;
    }

    /**
     * TODO: add validation to ensure that new node is compatible
     * with this pipeline (pipeline params vs. UOWTG)
     * @return
     */
    public List<PipelineDefinitionNode> getNextNodes() {
        return nextNodes;
    }

    public void setNextNodes(List<PipelineDefinitionNode> nextNodes) {
        this.nextNodes = nextNodes;
    }

    public PipelineDefinitionNode getParentNode() {
        return parentNode;
    }

    public void setParentNode(PipelineDefinitionNode parentNode) {
        this.parentNode = parentNode;
    }

    public boolean isStartNewUow() {
        return startNewUow;
    }

    public void setStartNewUow(boolean startNewUow) {
        this.startNewUow = startNewUow;
    }

    public ClassWrapper<UnitOfWorkTaskGenerator> getUnitOfWork() {
        return unitOfWork;
    }

    public void setUnitOfWork(ClassWrapper<UnitOfWorkTaskGenerator> unitOfWork) {
        this.unitOfWork = unitOfWork;
    }

    public ModuleName getModuleName() {
        return moduleName;
    }

    public void setModuleName(ModuleName moduleName) {
        this.moduleName = moduleName;
    }

    public void setPipelineModuleDefinition(PipelineModuleDefinition moduleDefinition){
        this.moduleName = moduleDefinition.getName();
    }

    /**
     * Enforce the use of Java object identity so that we can use transient
     * instances in a Set.  This of course means that non-transient instances
     * with the same database id will not be equal(), but this approach is safer because
     * there's no chance that the equals/hashCode value will change while it's contained
     * in a Set, which would break the contract of Set.
     * 
     * Transient instances of this class are currently used as keys in a Map
     * in {@link TriggerDefinition}
     *  
     */
    @Override
    public boolean equals(Object obj) {
        return super.equals(obj);
    }

    @Override
    public int hashCode() {
        return super.hashCode();
    }

    public PipelineDefinitionNodePath getPath() {
        return path;
    }

    public void setPath(PipelineDefinitionNodePath path) {
        this.path = path;
    }
}
