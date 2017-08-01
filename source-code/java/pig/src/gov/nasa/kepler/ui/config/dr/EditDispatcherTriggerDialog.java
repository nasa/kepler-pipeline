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
import gov.nasa.kepler.ui.ops.triggers.TriggersListModel;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class EditDispatcherTriggerDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(EditDispatcherTriggerDialog.class);

    private JPanel dataPanel;
    private JComboBox triggerComboBox;
    private JCheckBox enabledCheckBox;
    private JLabel enabledLabel;
    private JLabel triggerLabel;
    private JTextField dispatcherTextField;
    private JLabel dispatcherLabel;
    private JButton cancelButton;
    private JButton saveButton;
    private JPanel actionPanel;

    private DispatcherTrigger dispatcherTrigger;
    private TriggersListModel triggerComboBoxModel;

    private boolean cancelled = false;

    public EditDispatcherTriggerDialog(JFrame frame, DispatcherTrigger dispatcherTrigger) {
        super(frame, true);
        
        this.dispatcherTrigger = dispatcherTrigger;
        
        initGUI();
    }
    
    public boolean isTriggerEnabled(){
        return enabledCheckBox.isSelected();
    }
    
    public TriggerDefinition getSelectedTriggerDef(){
        return (TriggerDefinition) triggerComboBoxModel.getSelectedItem();
    }
    
    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButton.actionPerformed, event="+evt);
        
        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        cancelled  = true;
        
        setVisible(false);
    }
    
    private void initGUI() {
        try {
            {
                BorderLayout thisLayout = new BorderLayout();
                getContentPane().setLayout(thisLayout);
                this.setTitle("Edit Dispatcher Trigger");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            }
            this.setSize(443, 183);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7};
            dataPanelLayout.rowHeights = new int[] {7, 7, 7, 7};
            dataPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1};
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.setPreferredSize(new java.awt.Dimension(422, 129));
            dataPanel.add(getDispatcherLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getDispatcherTextField(), new GridBagConstraints(1, 0, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getTriggerLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getTriggerComboBox(), new GridBagConstraints(1, 1, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getEnabledLabel(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getEnabledCheckBox(), new GridBagConstraints(1, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(35);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getSaveButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getSaveButton() {
        if(saveButton == null) {
            saveButton = new JButton();
            saveButton.setText("save");
            saveButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    saveButtonActionPerformed(evt);
                }
            });
        }
        return saveButton;
    }
    
    private JButton getCancelButton() {
        if(cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }
    
    private JLabel getDispatcherLabel() {
        if(dispatcherLabel == null) {
            dispatcherLabel = new JLabel();
            dispatcherLabel.setText("Dispatcher:");
        }
        return dispatcherLabel;
    }
    
    private JTextField getDispatcherTextField() {
        if(dispatcherTextField == null) {
            dispatcherTextField = new JTextField();
            dispatcherTextField.setEditable(false);
            dispatcherTextField.setText(dispatcherTrigger.getDispatcherClassShortName());
        }
        return dispatcherTextField;
    }
    
    private JLabel getTriggerLabel() {
        if(triggerLabel == null) {
            triggerLabel = new JLabel();
            triggerLabel.setText("Trigger:");
        }
        return triggerLabel;
    }
    
    private JComboBox getTriggerComboBox() {
        if(triggerComboBox == null) {
            triggerComboBoxModel = new TriggersListModel(); 
            triggerComboBox = new JComboBox();
            triggerComboBox.setModel(triggerComboBoxModel);
            
            int index = triggerComboBoxModel.indexOf(dispatcherTrigger.getTriggerDefinition());
            if(index != -1){
                triggerComboBox.setSelectedIndex(index);
            }
        }
        return triggerComboBox;
    }
    
    private JLabel getEnabledLabel() {
        if(enabledLabel == null) {
            enabledLabel = new JLabel();
            enabledLabel.setText("Enabled:");
        }
        return enabledLabel;
    }
    
    private JCheckBox getEnabledCheckBox() {
        if(enabledCheckBox == null) {
            enabledCheckBox = new JCheckBox();
            enabledCheckBox.setSelected(dispatcherTrigger.isEnabled());
        }
        return enabledCheckBox;
    }

    public boolean isCancelled() {
        return cancelled;
    }
}
