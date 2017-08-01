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

package gov.nasa.kepler.ui.config.parameters;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.BorderLayout;

import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JScrollPane;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class ParameterClassSelectorPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(ParameterClassSelectorPanel.class);

    private JScrollPane paramClassScrollPane;
    private JList paramClassList;

    private ParameterClassListModel paramClassListModel;

	public ParameterClassSelectorPanel() {
		super();
		initGUI();
	}
	
    public ClassWrapper<Parameters> getSelectedElement(){
        int selectedIndex = paramClassList.getSelectedIndex();
        if(selectedIndex != -1){
            @SuppressWarnings("unchecked")
            ClassWrapper<Parameters> selected = (ClassWrapper<Parameters>) paramClassListModel.getElementAt(selectedIndex);
            return selected;
        }else{
            return null;
        }
	}
	
	private void initGUI() {
		try{
            BorderLayout thisLayout = new BorderLayout();
            this.setLayout(thisLayout);
            this.add(getParamClassScrollPane(), BorderLayout.CENTER);
		}catch (Exception e) {
            log.warn("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
		}
	}
	
	private JScrollPane getParamClassScrollPane() throws Exception {
	    if(paramClassScrollPane == null) {
	        paramClassScrollPane = new JScrollPane();
            paramClassScrollPane.setViewportView(getParamClassList());
	    }
	    return paramClassScrollPane;
	}
	
	private JList getParamClassList() throws Exception {
	    if(paramClassList == null) {
            paramClassListModel = new AllParameterClassListModel();
	        paramClassList = new JList();
	        paramClassList.setModel(paramClassListModel);
	    }
	    return paramClassList;
	}

}
