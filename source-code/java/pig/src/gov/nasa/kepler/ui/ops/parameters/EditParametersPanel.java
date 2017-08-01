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

package gov.nasa.kepler.ui.ops.parameters;
import gov.nasa.kepler.common.ui.PropertySheetHelper;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.Dimension;

import javax.swing.BorderFactory;

import com.l2fprod.common.propertysheet.PropertySheet;
import com.l2fprod.common.propertysheet.PropertySheetPanel;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class EditParametersPanel extends javax.swing.JPanel {

    private PropertySheetPanel propertySheetPanel = null;
    private Parameters parameters = null;
	
    public EditParametersPanel(Parameters parameters) {
        this.parameters = parameters;
        
        initGUI();
    }
    
    public EditParametersPanel() {
        initGUI();
    }
    
    public Parameters getParameters() throws PipelineException{
        propertySheetPanel.writeToObject(parameters);
        return parameters;
    }
    
    public void makeReadOnly(){
        propertySheetPanel.getTable().setEnabled(false);
    }
    
	private void initGUI() {
		try {
            BorderLayout thisLayout = new BorderLayout();
			this.setLayout(thisLayout);
			setPreferredSize(new Dimension(400, 300));
            this.setBorder(BorderFactory.createTitledBorder("Edit Parameters"));
            this.add(getPropertySheetPanel(), BorderLayout.CENTER);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
    private PropertySheetPanel getPropertySheetPanel() {
        if (propertySheetPanel == null) {
            propertySheetPanel = new PropertySheetPanel();

            propertySheetPanel.setMode(PropertySheet.VIEW_AS_CATEGORIES);
            propertySheetPanel.setDescriptionVisible(true);
            propertySheetPanel.setSortingCategories(true);
            //propertySheetPanel.setSortingProperties(true);
            propertySheetPanel.getTable().setWantsExtraIndent(true);

            if(parameters != null){
                try {
                    PropertySheetHelper.populatePropertySheet(parameters, propertySheetPanel);
                } catch (Exception e) {
                    throw new PipelineException("Failed to introspect Parameters bean", e);
                }
            }
        }
        return propertySheetPanel;
    }
}
