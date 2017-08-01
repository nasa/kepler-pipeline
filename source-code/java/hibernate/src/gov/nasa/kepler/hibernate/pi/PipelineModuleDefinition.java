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

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.FetchType;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import javax.persistence.Version;

import org.hibernate.annotations.Cascade;
import org.hibernate.annotations.CascadeType;

/**
 * This class models a pipeline module, which consists of an algorithm and the
 * parameters that control the behavior of that algorithm.
 * 
 * @author tklaus
 * 
 */
@Entity
@Table(name = "PI_MOD_DEF")
public class PipelineModuleDefinition {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_MOD_DEF_SEQ")
    private long id;

    // Combination of name+version must be unique (see shared-extra-ddl-create.sql)
    @ManyToOne(fetch=FetchType.EAGER)
    @Cascade({CascadeType.SAVE_UPDATE, CascadeType.DELETE_ORPHAN})
    private ModuleName name;
    private int version = 0;

    @ManyToOne
    private Group group = null;
    
    /**
     * Set to true when the first pipeline instance is created using this
     * definition in order to preserve the data accountability record. Editing a
     * locked definition will result in a new, unlocked instance with the
     * version incremented
     */
    private boolean locked = false;

    @Embedded
    // init with empty placeholder, to be filled in by PIG
    private AuditInfo auditInfo = new AuditInfo();

    /** used by Hibernate to implement optimistic locking.  Should prevent 2
     * different PIG users from clobbering each others changes */
    @Version
    private int dirty = 0;
    
    private String description = "description";

    @Embedded
    private ClassWrapper<PipelineModule> implementingClass;

    private String exeName;
    private int exeTimeoutSecs = 60 * 60 * 50; // 50 hours
    private int minMemoryMegaBytes = 0; // zero means memory usage is not constrained
    
    // for hibernate use only
    public PipelineModuleDefinition() {
    }

    public PipelineModuleDefinition(String name) {
        this.name = new ModuleName(name);
    }

    public PipelineModuleDefinition(AuditInfo auditInfo, String name) {
        this.auditInfo = auditInfo;
        this.name = new ModuleName(name);
    }

    /**
     * Copy constructor
     * 
     * @param other
     */
    public PipelineModuleDefinition(PipelineModuleDefinition other) {
        this(other,false);
    }
    
    PipelineModuleDefinition(PipelineModuleDefinition other, boolean exact) {
        this.name = other.name;
        this.group = other.group;
        this.auditInfo = other.auditInfo;
        this.description = other.description;
        this.implementingClass = other.implementingClass;
        this.exeName = other.exeName;
        this.exeTimeoutSecs = other.exeTimeoutSecs;
        this.minMemoryMegaBytes = other.minMemoryMegaBytes;

        if(exact){
            this.version = other.version;
            this.locked = other.locked;
        }else{
            this.version = 0;
            this.locked = false;
        }
    
    }
    
    public void rename(String name) {
        this.name = new ModuleName(name);
    }

    public PipelineModuleDefinition newVersion() {
        if (!locked) {
            throw new PipelineException("Can't version an unlocked instance");
        }

        PipelineModuleDefinition copy = new PipelineModuleDefinition(this);
        copy.version = this.version + 1;

        return copy;
    }

    /**
     * Lock this and all associated parameter sets
     * 
     * Before locking, if currently NOT locked, replace all param sets
     * with the latest version, then lock those, then this one. This guarantees
     * that when a pipeline is launched, the latest available params are used.
     * 
     * if !locked
     *   lock data object
     *   for each param set
     *     update param set with latest version
     *     lock latest version param set
     *   locked = true
     *   
     * @throws PipelineException
     * 
     */
    public void lock() {
        locked = true;
    }

    public boolean isLocked() {
        return locked;
    }

    public ModuleName getName() {
        return name;
    }

    public int getVersion() {
        return version;
    }

    /**
     * @return Returns the id.
     */
    public long getId() {
        return id;
    }

    public String toString() {
        return name.toString();
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

    public String getExeName() {
        return exeName;
    }

    public void setExeName(String exeName) {
        this.exeName = exeName;
    }

    public int getExeTimeoutSecs() {
        return exeTimeoutSecs;
    }

    public void setExeTimeoutSecs(int exeTimeoutSecs) {
        this.exeTimeoutSecs = exeTimeoutSecs;
    }

    public ClassWrapper<PipelineModule> getImplementingClass() {
        return implementingClass;
    }

    public void setImplementingClass(ClassWrapper<PipelineModule> implementingClass) {
        this.implementingClass = implementingClass;
    }

    /**
     * @return the minMemoryBytes
     */
    public int getMinMemoryMegaBytes() {
        return minMemoryMegaBytes;
    }

    /**
     * @param minMemoryBytes the minMemoryBytes to set
     */
    public void setMinMemoryMegaBytes(int minMemoryBytes) {
        this.minMemoryMegaBytes = minMemoryBytes;
    }

    public Set<ClassWrapper<Parameters>> getRequiredParameterClasses() {
        PipelineModule pipelineModule = implementingClass.newInstance();
        
        Set<ClassWrapper<Parameters>> requiredParameters = new HashSet<ClassWrapper<Parameters>>();
        List<Class<? extends Parameters>> moduleParameters = pipelineModule.requiredParameters();
        
        for (Class<? extends Parameters> clazz : moduleParameters) {
            requiredParameters.add(new ClassWrapper<Parameters>(clazz));
        }
        
        return requiredParameters;
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
