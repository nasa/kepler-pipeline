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

package gov.nasa.kepler.ui.ops.triggers;

import gov.nasa.kepler.hibernate.pi.AuditInfo;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.models.AbstractDatabaseModel;
import gov.nasa.kepler.ui.proxy.TriggerDefinitionCrudProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.Date;
import java.util.LinkedList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class TriggersTableModel extends AbstractDatabaseModel {
    private static final Log log = LogFactory.getLog(TriggersTableModel.class);

    private List<TriggerDefinition> triggers = new LinkedList<TriggerDefinition>();
    private TriggerDefinitionCrudProxy triggerDefinitionCrud;

    public TriggersTableModel() {
        triggerDefinitionCrud = new TriggerDefinitionCrudProxy();
    }

    public void loadFromDatabase() throws PipelineException {

        try{
            if (triggers != null) {
                log.info("Clearing the Hibernate cache of all loaded triggers");
                triggerDefinitionCrud.evictAll(triggers); // clear the cache
            }

            triggers = triggerDefinitionCrud.retrieveAll();
        }catch(PigSecurityException ignore){
        }
        fireTableDataChanged();
    }

    /**
     * Returns true if a trigger already exists with the specified name. checked
     * when the operator changes the trigger name so we can warn them before we
     * get a database constraint violation.
     * 
     * @param name
     * @return
     */
    public TriggerDefinition triggerByName(String name) {
        validityCheck();
        for (TriggerDefinition triggerDef : triggers) {
            if (name.equals(triggerDef.getName())) {
                return triggerDef;
            }
        }
        return null;
    }

    public int getRowCount() {
        validityCheck();
        return triggers.size();
    }

    public int getColumnCount() {
        return 5;
    }

    public TriggerDefinition getTriggerAt(int rowIndex) {
        validityCheck();
        return triggers.get(rowIndex);
    }

    public Object getValueAt(int rowIndex, int columnIndex) {
        validityCheck();
        TriggerDefinition trigger = triggers.get(rowIndex);

        AuditInfo auditInfo = trigger.getAuditInfo();
        
        User lastChangedUser = null;
        Date lastChangedTime = null;

        if(auditInfo != null){
            lastChangedUser = auditInfo.getLastChangedUser();
            lastChangedTime = auditInfo.getLastChangedTime();
        }

        switch (columnIndex) {
            case 0:
                return trigger.getName();
            case 1:
                return trigger.getPipelineDefinitionName()
                    .toString();
            case 2:
                if(lastChangedUser != null){
                    return lastChangedUser.getLoginName();
                }else{
                    return "---";
                }
            case 3:
                if(lastChangedTime != null){
                    return lastChangedTime;
                }else{
                    return "---";
                }
            case 4:
                return trigger.isValid();
        }

        return "huh?";
    }

    @Override
    public Class<?> getColumnClass(int columnIndex) {
        validityCheck();

        switch (columnIndex) {
            case 0:
                return String.class;
            case 1:
                return String.class;
            case 2:
                return String.class;
            case 3:
                return Object.class;
            case 4:
                return Boolean.class;
            default:
                return String.class;
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see javax.swing.table.AbstractTableModel#getColumnName(int)
     */
    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "Name";
            case 1:
                return "Pipeline Name";
            case 2:
                return "User";
            case 3:
                return "Mod. Time";
            case 4:
                return "Valid";
        }

        return "huh?";
    }
}
