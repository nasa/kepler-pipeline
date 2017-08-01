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

import java.util.HashMap;
import java.util.Map;

import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.JoinTable;
import javax.persistence.ManyToMany;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;

/**
 * This class models a single node in a {@link TriggerDefinition}.
 * 
 * There is one {@link TriggerDefinitionNode} for each {@link PipelineDefinitionNode}
 * in the {@link PipelineDefinition} for this {@link TriggerDefinition}.
 * 
 * This class contains the {@link ParameterSetName}s that will be used for the 
 * {@link Parameters} for each {@link PipelineDefinitionNode}
 *  
 * @author tklaus
 *
 */
@Entity
@Table(name = "PI_TRIGGER_DEF_NODE")
public class TriggerDefinitionNode {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_TRIGGER_DEF_SEQ")
    private long id;

    @ManyToOne
    private TriggerDefinition trigger = null;

    /**
     * The module (by name) for the node represented by this path. Used to verify whether the PipelineDefinition structure has changed, invalidating the TriggerDefinition 
     */
    @ManyToOne(fetch = FetchType.EAGER)
    private ModuleName nodeModuleName;
    
    /**
     * {@link ParameterSet}s used as {@link Parameters} for this instance.
     * This is a hard-reference to a specific version of the {@link ParameterSet}, 
     * selected at launch time (typically the latest available version)
     */
    @ManyToMany
    @JoinTable(name = "PI_TDN_MPS")
    private Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames = 
    	new HashMap<ClassWrapper<Parameters>, ParameterSetName>();

    @Embedded
    private PipelineDefinitionNodePath pipelineDefinitionNodePath = null;
    
    TriggerDefinitionNode() {
	}

	public TriggerDefinitionNode(TriggerDefinition trigger, PipelineDefinitionNodePath pipelineDefinitionNodePath,
        ModuleName nodeModuleName) {
        this.trigger = trigger;
        this.pipelineDefinitionNodePath = pipelineDefinitionNodePath;
        this.nodeModuleName = nodeModuleName;
    }

	public TriggerDefinitionNode(TriggerDefinitionNode other){
	    this.trigger = other.trigger;
	    this.nodeModuleName = other.nodeModuleName;
        this.moduleParameterSetNames.putAll(other.moduleParameterSetNames);
        this.pipelineDefinitionNodePath = new PipelineDefinitionNodePath(other.pipelineDefinitionNodePath);
	}
	
    public PipelineDefinitionNodePath getPipelineDefinitionNodePath() {
		return pipelineDefinitionNodePath;
	}

	public void setPipelineDefinitionNodePath(
			PipelineDefinitionNodePath pipelineDefinitionNodePath) {
		this.pipelineDefinitionNodePath = pipelineDefinitionNodePath;
	}

	public long getId() {
		return id;
	}

	public Map<ClassWrapper<Parameters>, ParameterSetName> getModuleParameterSetNames() {
		return moduleParameterSetNames;
	}

	public void clearModuleParameterSetNames() {
		moduleParameterSetNames.clear();
	}

	public ParameterSetName putModuleParameterSetName(Class<? extends Parameters> clazz,
			ParameterSetName paramSetName) {
		
		ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(clazz);
		
		if(moduleParameterSetNames.containsKey(classWrapper)){
			throw new PipelineException("This TriggerDefinition already contains a pipeline parameter set name for class: " + classWrapper);
		}
		
		return moduleParameterSetNames.put(classWrapper, paramSetName);
	}

    public TriggerDefinition getTrigger() {
        return trigger;
    }

    public void setModuleParameterSetNames(Map<ClassWrapper<Parameters>, ParameterSetName> moduleParameterSetNames) {
        this.moduleParameterSetNames = moduleParameterSetNames;
    }

    public ModuleName getNodeModuleName() {
        return nodeModuleName;
    }

    public void setNodeModuleName(ModuleName nodeModuleName) {
        this.nodeModuleName = nodeModuleName;
    }

    public boolean pathMatches(PipelineDefinitionNodePath path){
        return path.equals(pipelineDefinitionNodePath);
    }
}
