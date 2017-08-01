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

import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

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
import javax.persistence.Version;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;
import org.hibernate.annotations.IndexColumn;

/**
 * This class a pipeline configuration.
 * A 'pipeline' is defined as a directed graph of {@link PipelineDefinitionNode}s
 * that share a common unit of work definition.
 * 
 * @author tklaus
 * 
 */
@Entity
@Table(name = "PI_PIPELINE_DEF")
public class PipelineDefinition{
    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(PipelineDefinition.class);

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_PD_SEQ")
    private long id;

    @Embedded
    // init with empty placeholder, to be filled in by PIG
    private AuditInfo auditInfo = new AuditInfo();
    
    /** used by Hibernate to implement optimistic locking.  Should prevent 2
     * different PIG users from clobbering each others changes */
    @Version
    private int dirty = 0;
    
    private String description = null;
    
    // Combination of name+version must be unique (see shared-extra-ddl-create.sql)
    @ManyToOne(fetch=FetchType.EAGER)
    @Cascade({CascadeType.SAVE_UPDATE, CascadeType.DELETE_ORPHAN})
    private PipelineDefinitionName name;

    private int version = 0;

    @ManyToOne
    private Group group = null;
    
    /** Set to true when the first pipeline instance is created using this
     * definition in order to preserve the data accountability record.  Editing 
     * a locked definition will result in a new, unlocked instance with the
     * version incremented */
    private boolean locked = false;
    
    @OneToMany
    @Cascade({org.hibernate.annotations.CascadeType.SAVE_UPDATE,org.hibernate.annotations.CascadeType.EVICT})
    @JoinTable(name = "PI_PDN_ROOT_NODES", joinColumns = @JoinColumn(name = "PARENT_PI_PD_ID"), inverseJoinColumns = @JoinColumn(name = "CHILD_PI_PDN_ID"))
    @IndexColumn(name = "IDX")
    private List<PipelineDefinitionNode> rootNodes = new ArrayList<PipelineDefinitionNode>();

    public PipelineDefinition() {
    }

    public PipelineDefinition(String name) {
        this.name = new PipelineDefinitionName(name);
    }

    public PipelineDefinition(AuditInfo auditInfo, String name) {
        this.name = new PipelineDefinitionName(name);
        this.auditInfo = auditInfo;
    }
    
    /**
     * Copy constructor
     * 
     * @param pipelineDefinition
     */
    public PipelineDefinition(PipelineDefinition other) {
        this.name = other.name;
        this.description = other.description;
        this.auditInfo = other.auditInfo;
        this.version = 0;
        this.group = other.group;
        this.locked = false;
        
        for (PipelineDefinitionNode otherNode : other.rootNodes) {
            this.rootNodes.add(new PipelineDefinitionNode(otherNode));
        }
    }
    
    public void rename(String name) {
        this.name = new PipelineDefinitionName(name);
    }

    /**
     * Creates a new, unlocked version of this {@link PipelineDefinition}
     * 
     * Called by the PIG when the user edits a locked instance
     * 
     * @return
     * @throws PipelineException 
     */
    public PipelineDefinition newVersion() throws PipelineException{
        if(!locked){
            throw new PipelineException("Can't version an unlocked instance");
        }
        
        PipelineDefinition copy = new PipelineDefinition(this);
        copy.version = this.version + 1;
        
        return copy;
    }
    
    /** 
     * Sets the state of this {@link PipelineDefinition}, and all associated
     * {@link PipelineDefinitionNode}s, {@link PipelineModuleDefinition}s,
     * and {@link ParameterSet}s.
     * 
     * Normally called by the {@link PipelineExecutor} when a pipeline instance
     * is launched in order to preserve the data accountability record by 
     * preventing these definitions from being modified once they are used.
     *
     * @throws PipelineException 
     * 
     */
    public void lock() throws PipelineException{
        locked = true;
    }
    
    /**
     * Walks the tree of {@link PipelineDefinitionNode}s for this pipeline definition
     * and sets the parentNode and path fields for each one. 
     */
    public void buildPaths(){
        Stack<Integer> path = new Stack<Integer>();
        buildPaths(null, rootNodes, path);
    }

    /**
     * Recursive method to set parent pointers
     * 
     * @param parent
     * @param kids
     * @param path 
     */
    private void buildPaths(PipelineDefinitionNode parent, List<PipelineDefinitionNode> kids, Stack<Integer> path){
        for (int i = 0; i < kids.size(); i++) {
            PipelineDefinitionNode kid = kids.get(i);
            path.push(i);
            
            kid.setParentNode(parent);
            kid.setPath(new PipelineDefinitionNodePath(new ArrayList<Integer>(path)));
            
            buildPaths(kid, kid.getNextNodes(), path);
            
            path.pop();
        }
    }
    
    public long getId() {
        return id;
    }

    public PipelineDefinitionName getName() {
        return name;
    }

    /**
     * @return Returns the locked.
     */
    public boolean isLocked() {
        return locked;
    }

    public String toString() {
        return name.toString();
    }

    /**
     * TODO: add validation to ensure that new node is compatible
     * with this pipeline (pipeline params vs. UOWTG)
     * @return
     */
    public List<PipelineDefinitionNode> getRootNodes() {
        return rootNodes;
    }

    public void setRootNodes(List<PipelineDefinitionNode> rootNodes) {
        this.rootNodes = rootNodes;
    }

    public AuditInfo getAuditInfo() {
        return auditInfo;
    }

    public void setAuditInfo(AuditInfo auditInfo) {
        this.auditInfo = auditInfo;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

	public int getVersion() {
        return version;
    }

    public Group getGroup() {
        return group;
    }

    public void setGroup(Group group) {
        this.group = group;
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
