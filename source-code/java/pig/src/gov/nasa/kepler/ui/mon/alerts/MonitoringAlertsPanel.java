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

package gov.nasa.kepler.ui.mon.alerts;

import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.mon.master.Indicator;
import gov.nasa.kepler.ui.ons.etable.EShadedTable;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class MonitoringAlertsPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(MonitoringAlertsPanel.class);

	private JPanel buttonPanel;
	private ETable alertTable;
    private JButton ackButton;
	private JButton clearButton;
	private JScrollPane alertTableScrollPane;
	private JCheckBox enabledCheckBox;
	private AlertMessageHandlerThread alertMessageHandlerThread;
	private AlertMessageTableModel alertMessageTableModel;

	public MonitoringAlertsPanel() {
		super();
		initGUI();

		enableHandlerThread();
	}
	
    private void enabledCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("enabledCheckBox.actionPerformed, event=" + evt);
        
        enableHandlerThread();
    }

    private void enableHandlerThread() {
        try {
            getAlertMessageHandlerThread().setEnabled( enabledCheckBox.isSelected() );
        } catch (PipelineException e) {
            PipelineConsole.showError( this, e );
        }
    }
    
    private void clearButtonActionPerformed(ActionEvent evt) {
        log.debug("clearButton.actionPerformed, event=" + evt);
        
        alertMessageTableModel.clear();

        alertMessageTableModel.updateCurrentState(Indicator.State.GREEN);
    }
    
    
    private void ackButtonActionPerformed(ActionEvent evt) {
        log.debug("ackButton.actionPerformed, event="+evt);

        alertMessageTableModel.updateCurrentState(Indicator.State.GREEN);
    }

    private AlertMessageHandlerThread getAlertMessageHandlerThread() {
        if( alertMessageHandlerThread == null ){
            alertMessageHandlerThread = new AlertMessageHandlerThread(alertMessageTableModel);
            alertMessageHandlerThread.start();
        }
        return alertMessageHandlerThread;
    }

	private void initGUI() {
		try {
			BorderLayout thisLayout = new BorderLayout();
			this.setLayout(thisLayout);
			setPreferredSize(new Dimension(400, 300));
			this.add(getButtonPanel(), BorderLayout.NORTH);
			this.add(getAlertTableScrollPane(), BorderLayout.CENTER);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private JPanel getButtonPanel() {
		if (buttonPanel == null) {
			buttonPanel = new JPanel();
			FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(20);
            buttonPanel.setLayout(buttonPanelLayout);
			buttonPanel.add(getEnabledCheckBox());
			buttonPanel.add(getClearButton());
            buttonPanel.add(getAckButton());
		}
		return buttonPanel;
	}
	
	private JCheckBox getEnabledCheckBox() {
		if (enabledCheckBox == null) {
			enabledCheckBox = new JCheckBox();
			enabledCheckBox.setText("Enabled");
            enabledCheckBox.setSelected(true);
			enabledCheckBox.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					enabledCheckBoxActionPerformed(evt);
				}
			});
		}
		return enabledCheckBox;
	}
	
	private JScrollPane getAlertTableScrollPane() {
		if (alertTableScrollPane == null) {
			alertTableScrollPane = new JScrollPane();
			alertTableScrollPane.setViewportView(getAlertTable());
		}
		return alertTableScrollPane;
	}

	private JButton getClearButton() {
		if (clearButton == null) {
			clearButton = new JButton();
			clearButton.setText("Clear");
			clearButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					clearButtonActionPerformed(evt);
				}
			});
		}
		return clearButton;
	}
	
	private ETable getAlertTable() {
		if (alertTable == null) {
			alertMessageTableModel = new AlertMessageTableModel();
			alertTable = new EShadedTable();
			alertTable.setModel(alertMessageTableModel);
			alertTable.setShowVerticalLines( false );
			alertTable.setShowHorizontalLines( false );
		}
		return alertTable;
	}
	
	private JButton getAckButton() {
	    if(ackButton == null) {
	        ackButton = new JButton();
	        ackButton.setText("Ack");
	        ackButton.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                ackButtonActionPerformed(evt);
	            }
	        });
	    }
	    return ackButton;
	}
}
