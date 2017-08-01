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

import javax.persistence.AttributeOverride;
import javax.persistence.AttributeOverrides;
import javax.persistence.Column;
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
 * This class models a set of module parameters.
 * A parameter set may be shared by multiple pipeline
 * modules.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@Entity
@Table(name = "PI_PS")
public class ParameterSet {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO, generator = "sg")
    @SequenceGenerator(name = "sg", sequenceName = "PI_PS_SEQ")
    private long id;

    @Embedded
    // init with empty placeholder, to be filled in by PIG
    private AuditInfo auditInfo = new AuditInfo();

    // Combination of name+version must be unique (see shared-extra-ddl-create.sql)
    @ManyToOne(fetch=FetchType.EAGER)
    @Cascade({CascadeType.SAVE_UPDATE, CascadeType.DELETE_ORPHAN})
    private ParameterSetName name;
    private int version = 0;

    /** used by Hibernate to implement optimistic locking.  Should prevent 2
     * different PIG users from clobbering each others changes */
    @Version
    private int dirty = 0;
    
    @ManyToOne
    private Group group = null;
    
    /** Set to true when the first pipeline instance is created using this
     * definition in order to preserve the data accountability record.  Editing 
     * a locked definition will result in a new, unlocked instance with the
     * version incremented */
    private boolean locked = false;
    
    private String description = null;

    @Embedded
    @AttributeOverrides({
        @AttributeOverride(name="clazz", column=@Column(name="PS_CN")),
        @AttributeOverride(name="props", column=@Column(name="PS_PROPS")),
        @AttributeOverride(name="initialized", column=@Column(name="PS_INITED"))
    })
    private BeanWrapper<Parameters> parameters = null;

    public ParameterSet() {
    }

    public ParameterSet(String name) {
        this.name = new ParameterSetName(name);
    }

    public ParameterSet(AuditInfo auditInfo, String name) {
        this.auditInfo = auditInfo;
        this.name = new ParameterSetName(name);
    }

    /**
     * Copy constructor
     */
    public ParameterSet(ParameterSet other) {
        this(other,false);
    }
    
    ParameterSet(ParameterSet other, boolean exact) {
        this.auditInfo = other.auditInfo;
        this.name = other.name;
        this.group = other.group;
        this.description = other.description;
        this.parameters = new BeanWrapper<Parameters>(other.parameters);
        
        if(exact){
            this.version = other.version;
            this.locked = other.locked;
        }else{
            this.version = 0;
            this.locked = false;
        }
    }

    public void rename(String name) {
        this.name = new ParameterSetName(name);
    }
    
    public ParameterSet newVersion() throws PipelineException{
        if(!locked){
            throw new PipelineException("Can't version an unlocked instance");
        }
        
        ParameterSet copy = new ParameterSet(this);
        copy.version = this.version + 1;
        
        return copy;
    }
    
    /**
     * just set locked = true
     *
     */
    public void lock() {
        locked = true;
    }
    
    /**
     * @return Returns the description.
     */
    public String getDescription() {
        return description;
    }

    /**
     * @param description The description to set.
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * @return Returns the name.
     */
    public ParameterSetName getName() {
        return name;
    }

    /**
     * @return Returns the version.
     */
    public int getVersion() {
        return version;
    }

    /**
     * @return the parameters
     */
    public BeanWrapper<Parameters> getParameters() {
        return parameters;
    }

    @SuppressWarnings("unchecked")
    public <T extends Parameters> T parametersInstance() {
        return (T) getParameters().getInstance();
    }
    
    public boolean parametersClassDeleted(){
        boolean deleted = false;
        try{
            parameters.getInstance();
        }catch(PipelineException e){
            deleted = true;
        }
        return deleted;
    }
    /**
     * @param parameters the parameters to set
     */
    public void setParameters(BeanWrapper<Parameters> parameters) {
        this.parameters = parameters;
    }

    public AuditInfo getAuditInfo() {
        return auditInfo;
    }

    public void setAuditInfo(AuditInfo auditInfo) {
        this.auditInfo = auditInfo;
    }

    public boolean isLocked() {
        return locked;
    }

    @Override
    public String toString() {
        return name != null ? name.getName() : "UNNAMED";
    }

    public Group getGroup() {
        return group;
    }

    public void setGroup(Group group) {
        this.group = group;
    }

    public long getId() {
        return id;
    }

    /**
     * For TEST USE ONLY
     */
    void setDirty(int dirty) {
        this.dirty = dirty;
    }
}
