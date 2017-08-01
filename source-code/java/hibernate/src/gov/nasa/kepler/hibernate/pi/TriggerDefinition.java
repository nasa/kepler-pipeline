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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.CascadeType;
import javax.persistence.Column;
import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinColumn;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.OneToMany;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Version;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.annotations.IndexColumn;

/**
 * This class models a pipeline trigger definition.
 * A pipeline trigger is used to launch a new {@link PipelineInstance}.
 * It holds references to the {@link ParameterSetName}s that will be 
 * resolved to hard-references (specific {@link ParameterSet} versions)
 * when the pipeline instance is created (the pipeline instance contains
 * the hard-references)
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@Entity
@Table(name = "PI_TRIGGER_DEF")
public class TriggerDefinition {
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(TriggerDefinition.class);

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_TRIGGER_DEF_SEQ")
    private long id = 0;

    @Embedded
    // init with empty placeholder, to be filled in by PIG
    private AuditInfo auditInfo = new AuditInfo();

    /** used by Hibernate to implement optimistic locking.  Should prevent 2
     * different PIG users from clobbering each others changes */
    @Version
    private int dirty = 0;
    
    @Column(unique = true)
    private String name = "";

    @ManyToOne
    private Group group = null;
    
    /** Set to false if the associated {@link PipelineDefinition} is versioned (edited). 
     * If invalid, this trigger cannot be used to launch a pipeline until it is
     * reconciled with the new version */
    private boolean valid = true;
    
    @ManyToOne(fetch=FetchType.EAGER)
    private PipelineDefinitionName pipelineDefinitionName;

    private int pipelineDefinitionVersion = 0;
    
    private int instancePriority = PipelineInstance.LOWEST_PRIORITY;
    
    /**
     * {@link ParameterSetName}s that will be used as {@link Parameters} when an
     * instance of this pipeline is launched.  At launch-time, the {@Link PipelineInstance}
     * will be given a hard-reference to a specific version (typically latest) of the
     * {@link ParameterSet} for this {@link ParameterSetName}
     */
    @ManyToMany
    @JoinTable(name = "PI_TD_PSN")
    private Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames = 
    	new HashMap<ClassWrapper<Parameters>, ParameterSetName>();
    
    /**
     * Nodes for this {@link TriggerDefinition}.  Each node contains the {@link ParameterSetName}s
     * for the module {@link Parameters} for the corresponding {@link PipelineDefinitionNode}
     */
    @OneToMany(cascade = CascadeType.ALL)
    @JoinTable(name = "PI_TD_NODES", joinColumns = @JoinColumn(name = "PARENT_PI_TD_ID"))
    @IndexColumn(name = "IDX")
    private List<TriggerDefinitionNode> nodes = new ArrayList<TriggerDefinitionNode>();
        
    /* For Hibernate use only */
    TriggerDefinition() {
    }

    public TriggerDefinition(AuditInfo auditInfo, String name, PipelineDefinition pipelineDefinition) {
        this(name, pipelineDefinition);
        this.auditInfo = auditInfo;
    }

    public TriggerDefinition(String name, PipelineDefinition pipelineDefinition) {
        this.name = name;
        this.pipelineDefinitionName = pipelineDefinition.getName();
        this.pipelineDefinitionVersion = pipelineDefinition.getVersion();
    }

    /**
     * Copy constructor
     * 
     * @return
     */
    public TriggerDefinition(TriggerDefinition other){
        this.auditInfo = other.auditInfo;
        this.name = "Copy of " + other.name;
        this.group = other.group;
        this.valid = other.valid;
        this.pipelineDefinitionName = other.pipelineDefinitionName;
        this.instancePriority = other.instancePriority;
        this.pipelineParameterSetNames.putAll(other.pipelineParameterSetNames);
        
        for (TriggerDefinitionNode otherTriggerDefinitionNode : other.nodes) {
            TriggerDefinitionNode copyTriggerDefinitionNode = new TriggerDefinitionNode(otherTriggerDefinitionNode);
            this.nodes.add(copyTriggerDefinitionNode);
        }
    }
    
    /**
     * Find the trigger node with the specified path
     * 
     * @param path
     * @return
     */
    public TriggerDefinitionNode findNodeForPath(PipelineDefinitionNodePath path){
        for (TriggerDefinitionNode triggerNode : nodes) {            
            if(triggerNode.pathMatches(path)){
                return triggerNode;
            }
        }
        return null; // no matching path found
    }
    
    public long getId() {
        return id;
    }

    public int getInstancePriority() {
        return instancePriority;
    }

    public void setInstancePriority(int instancePriority) {
        this.instancePriority = instancePriority;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public PipelineDefinitionName getPipelineDefinitionName() {
        return pipelineDefinitionName;
    }

    public AuditInfo getAuditInfo() {
        return auditInfo;
    }

    public void setAuditInfo(AuditInfo auditInfo) {
        this.auditInfo = auditInfo;
    }

    public String toString() {
        return name;
    }

	public Map<ClassWrapper<Parameters>, ParameterSetName> getPipelineParameterSetNames() {
		return pipelineParameterSetNames;
	}

    public ParameterSetName getPipelineParameterSetName(Class<? extends Parameters> parameterClass) {
        ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(parameterClass);
        return pipelineParameterSetNames.get(classWrapper);
    }

	public void setPipelineParameterSetNames(
			Map<ClassWrapper<Parameters>, ParameterSetName> pipelineParameterSetNames) {
		this.pipelineParameterSetNames = pipelineParameterSetNames;
	}
	
	public void addPipelineParameterSetName(Class<? extends Parameters> parameterClass, ParameterSet parameterSet){
		ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(parameterClass);
		
		if(pipelineParameterSetNames.containsKey(classWrapper)){
			throw new PipelineException("This TriggerDefinition already contains a pipeline parameter set for class: " + parameterClass);
		}
		
		pipelineParameterSetNames.put(classWrapper, parameterSet.getName());
	}

    public boolean isValid() {
        return valid;
    }

    public void setValid(boolean valid) {
        this.valid = valid;
    }

    public List<TriggerDefinitionNode> getNodes() {
        return nodes;
    }

    public void setNodes(List<TriggerDefinitionNode> nodes) {
        this.nodes = nodes;
    }

    public Group getGroup() {
        return group;
    }

    public void setGroup(Group group) {
        this.group = group;
    }

    public int getPipelineDefinitionVersion() {
        return pipelineDefinitionVersion;
    }

    public int getDirty() {
        return dirty;
    }

    /**
     * For TEST USE ONLY
     */
    void setDirty(int dirty) {
        this.dirty = dirty;
    }
}
