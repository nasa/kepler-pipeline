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

package gov.nasa.kepler.hibernate.dr;

import gov.nasa.kepler.hibernate.pi.AuditInfo;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;

import javax.persistence.Embedded;
import javax.persistence.Entity;
import javax.persistence.Id;
import javax.persistence.ManyToOne;
import javax.persistence.Table;
import javax.persistence.Version;

/**
 * This class provides a mapping between a Dispatcher and the corresponding
 * pipeline trigger {@link TriggerDefinition} that should be fired when that dispatcher
 * successfully ingests a data set.
 * 
 * These mappings are managed by the operator using the pipeline console GUI.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@Entity
@Table(name = "DR_DISP_TRIGGER")
public class DispatcherTrigger {

    @Id
    private String dispatcherClass;

    @ManyToOne
    private TriggerDefinition triggerDefinition;

    private boolean enabled = true;

    @Embedded
    // init with empty placeholder, to be filled in by PIG
    private AuditInfo auditInfo = new AuditInfo();

    /** used by Hibernate to implement optimistic locking.  Should prevent 2
     * different PIG users from clobbering each others changes */
    @Version
    private int dirty = 0;
    
    DispatcherTrigger() {
    }

    public DispatcherTrigger(String dispatcherClass,
        TriggerDefinition triggerDefinition) {
        this.dispatcherClass = dispatcherClass;
        this.triggerDefinition = triggerDefinition;
    }

    public DispatcherTrigger(String dispatcherClass) {
        this.dispatcherClass = dispatcherClass;
    }

    /**
     * @return the dispatcherClass
     */
    public String getDispatcherClass() {
        return dispatcherClass;
    }

    /**
     * @return the dispatcherClass short name (for display in the pig)
     * 
     */
    public String getDispatcherClassShortName() {
        return dispatcherClass.substring(dispatcherClass.lastIndexOf(".")+1);
    }

    /**
     * @return the pipelineDefinition
     */
    public TriggerDefinition getTriggerDefinition() {
        return triggerDefinition;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public void setEnabled(boolean enabled) {
        this.enabled = enabled;
    }

    public void setTriggerDefinition(TriggerDefinition triggerDefinition) {
        this.triggerDefinition = triggerDefinition;
    }

    /**
     * @return the auditInfo
     */
    public AuditInfo getAuditInfo() {
        return auditInfo;
    }

    /**
     * @param auditInfo the auditInfo to set
     */
    public void setAuditInfo(AuditInfo auditInfo) {
        this.auditInfo = auditInfo;
    }

    public int getDirty() {
        return dirty;
    }
}
