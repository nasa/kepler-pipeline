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

package gov.nasa.kepler.ui.config.dr;

import gov.nasa.kepler.hibernate.dr.DispatcherTrigger;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.ui.proxy.TriggerDefinitionCrudProxy;

import java.util.List;

import javax.swing.AbstractListModel;
import javax.swing.ComboBoxModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * List model for triggers.  
 * Used by the {@link DispatcherTrigger} edit dialog
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class DispatchersListModel extends AbstractListModel implements ComboBoxModel{
	@SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(DispatchersListModel.class);

    private List<TriggerDefinition> triggers;
    private TriggerDefinition selectedTrigger;
    
    private TriggerDefinitionCrudProxy triggerDefinitionCrud;
	
	public DispatchersListModel() {
        triggerDefinitionCrud = new TriggerDefinitionCrudProxy();
        triggers = triggerDefinitionCrud.retrieveAll();
	}
	
	/**
	 * Index of the specified trigger.
	 * Used for initializing the selection for the parent combo box
	 * 
	 * @param triggerDef
	 * @return
	 */
	public int indexOf(TriggerDefinition triggerDef){
        if(triggerDef != null){
            int size = triggers.size();
            for (int i = 0; i < size; i++) {
                if(triggerDef.getId() == triggers.get(i).getId()){
                    return i;
                }
            }
        }
        return -1;
	}
	
    @Override
    public Object getSelectedItem() {
        return selectedTrigger;
    }

    @Override
    public void setSelectedItem(Object selectedItem) {
        selectedTrigger = (TriggerDefinition) selectedItem;
    }

    @Override
    public Object getElementAt(int index) {
        return triggers.get(index);
    }

    @Override
    public int getSize() {
        return triggers.size();
    }
}
