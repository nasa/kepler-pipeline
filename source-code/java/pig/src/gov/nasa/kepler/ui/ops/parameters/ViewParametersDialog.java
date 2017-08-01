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
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;

/**
 * Dialog for viewing (read-only) a {@link Parameters} java bean.
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class ViewParametersDialog extends javax.swing.JDialog {

	private ViewParametersPanel parametersPanel = null;
	
	private JPanel dataPanel;
	private JPanel buttonPanel;
    private JButton closeButton;

    private ParameterSet parameterSet;

	public ViewParametersDialog(JFrame frame, ParameterSet parameterSet) {
		super(frame, true );
		this.parameterSet = parameterSet;

		initGUI();
	}
	
    public static void viewParameters(ParameterSet parameterSet){
        ViewParametersDialog dialog = new ViewParametersDialog(PipelineConsole.instance, parameterSet);

        dialog.setVisible(true); // blocks until user presses a button
    }
    
    private void closeButtonActionPerformed(ActionEvent evt) {
        setVisible( false );
    }
    
    private void initGUI() {
		try {
			BorderLayout thisLayout = new BorderLayout();
			this.getContentPane().setLayout(thisLayout);
			this.getContentPane().add(getDataPanel(), BorderLayout.CENTER);
			this.getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
			setSize(700, 500);
			
            setTitle("View Parameter Set: " + parameterSet.getName() + " (read-only)");
            
		} catch (Exception e) {
			PipelineConsole.showError( this, e );
		}
	}
	
	private JPanel getDataPanel() {
		if (dataPanel == null) {
			dataPanel = new JPanel();
			BorderLayout dataPanelLayout = new BorderLayout();
			dataPanel.setLayout(dataPanelLayout);
			dataPanel.add( getParamPanel(), BorderLayout.CENTER );
		}
		return dataPanel;
	}

	private JPanel getParamPanel() throws PipelineException{
		if( parametersPanel == null ){
            parametersPanel = new ViewParametersPanel(parameterSet);
		}
		return parametersPanel;
	}
	
	private JPanel getButtonPanel() {
		if (buttonPanel == null) {
			buttonPanel = new JPanel();
			FlowLayout buttonPanelLayout = new FlowLayout();
			buttonPanelLayout.setHgap(40);
			buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getCloseButton());
		}
		return buttonPanel;
	}
	
    private JButton getCloseButton() {
        if (closeButton == null) {
            closeButton = new JButton();
            closeButton.setText("close");
            closeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    closeButtonActionPerformed(evt);
                }
            });
        }
        return closeButton;
    }
}
