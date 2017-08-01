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
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;

import java.awt.BorderLayout;
import java.awt.Cursor;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class FireTriggerDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(FireTriggerDialog.class);
    
    private JPanel dataPanel;
    private JPanel namePanel;
    private JCheckBox overrideEndCheckBox;
    private JComboBox endNodeComboBox;
    private JCheckBox overrideStartCheckBox;
    private JComboBox startNodeComboBox;
    private JLabel endNodeLabel;
    private JLabel startNodeLabel;
    private JPanel startEndPanel;
    private JTextField instanceNameTextField;
    private JButton cancelButton;
    private JButton fireButton;
    private JPanel actionPanel;

    private TriggerModulesListModel startNodeComboBoxModel;
    private TriggerModulesListModel endNodeComboBoxModel;

    private TriggerDefinition trigger;

    /** for Jigloo use only **/
    public FireTriggerDialog(JFrame frame) {
        super(frame, true);
        
        initGUI();
    }
    
    public FireTriggerDialog(JFrame frame, TriggerDefinition trigger) {
        super(frame, true);
        this.trigger = trigger;
        
        initGUI();
    }
    
    private void initGUI() {
        try {
            {
                this.setTitle("Launch Pipeline");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            }
            setSize(350, 400);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        
        setVisible(false);
    }
    
    private void fireButtonActionPerformed(ActionEvent evt) {
        log.debug("fireButton.actionPerformed, event="+evt);
        
        try {
            setCursor( Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
            
            PipelineDefinitionNode startNode = null;
            PipelineDefinitionNode endNode = null;
            
            if(overrideStartCheckBox.isSelected()){
                startNode = startNodeComboBoxModel.getSelectedPipelineNode();
            }
            
            if(overrideEndCheckBox.isSelected()){
                endNode = endNodeComboBoxModel.getSelectedPipelineNode();
            }

            PipelineOperationsProxy pipelineOps = new PipelineOperationsProxy();
            pipelineOps.fireTrigger(trigger.getName(), instanceNameTextField.getText(), startNode, endNode);

            setCursor(null);
            
        } catch (Exception e) {
            log.error("fireButtonActionPerformed(ActionEvent)", e);

            PipelineConsole.showError( this, e );
        }
        
        setVisible(false);
    }

    private void overrideStartCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("overrideStartCheckBox.actionPerformed, event="+evt);
        
        startNodeLabel.setEnabled(overrideStartCheckBox.isSelected());
        startNodeComboBox.setEnabled(overrideStartCheckBox.isSelected());
    }

    
    private void overrideEndCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("overrideEndCheckBox.actionPerformed, event="+evt);
        
        endNodeLabel.setEnabled(overrideEndCheckBox.isSelected());
        endNodeComboBox.setEnabled(overrideEndCheckBox.isSelected());
    }

    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7, 7};
            dataPanelLayout.rowHeights = new int[] {7, 7, 7, 7, 7};
            dataPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getNamePanel(), new GridBagConstraints(0, 0, 6, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getStartEndPanel(), new GridBagConstraints(0, 1, 6, 4, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(35);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getFireButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getFireButton() {
        if(fireButton == null) {
            fireButton = new JButton();
            fireButton.setText("Fire!");
            fireButton.setFont(new java.awt.Font("Dialog",1,16));
            fireButton.setForeground(new java.awt.Color(255,0,0));
            fireButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    fireButtonActionPerformed(evt);
                }
            });
        }
        return fireButton;
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
    
    private JPanel getNamePanel() {
        if(namePanel == null) {
            namePanel = new JPanel();
            GridBagLayout namePanelLayout = new GridBagLayout();
            namePanelLayout.columnWidths = new int[] {7};
            namePanelLayout.rowHeights = new int[] {7};
            namePanelLayout.columnWeights = new double[] {0.1};
            namePanelLayout.rowWeights = new double[] {0.1};
            namePanel.setLayout(namePanelLayout);
            namePanel.setBorder(BorderFactory.createTitledBorder("Pipeline Instance Name"));
            namePanel.add(getInstanceNameTextField(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return namePanel;
    }
    
    private JTextField getInstanceNameTextField() {
        if(instanceNameTextField == null) {
            instanceNameTextField = new JTextField();
        }
        return instanceNameTextField;
    }

    private JPanel getStartEndPanel() {
        if(startEndPanel == null) {
            startEndPanel = new JPanel();
            GridBagLayout startEndPanelLayout = new GridBagLayout();
            startEndPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7, 7};
            startEndPanelLayout.rowHeights = new int[] {7, 7, 7};
            startEndPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
            startEndPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1};
            startEndPanel.setLayout(startEndPanelLayout);
            startEndPanel.setBorder(BorderFactory.createTitledBorder("Start & End Node Override"));
            startEndPanel.add(getOverrideStartCheckBox(), new GridBagConstraints(0, 0, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            startEndPanel.add(getStartNodeLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            startEndPanel.add(getEndNodeLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            startEndPanel.add(getStartNodeComboBox(), new GridBagConstraints(1, 1, 5, 1, 1.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            startEndPanel.add(getEndNodeComboBox(), new GridBagConstraints(1, 3, 5, 1, 1.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            startEndPanel.add(getOverrideEndCheckBox(), new GridBagConstraints(0, 2, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return startEndPanel;
    }
    
    private JCheckBox getOverrideStartCheckBox() {
        if(overrideStartCheckBox == null) {
            overrideStartCheckBox = new JCheckBox();
            overrideStartCheckBox.setText("Override Start");
            overrideStartCheckBox.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    overrideStartCheckBoxActionPerformed(evt);
                }
            });
        }
        return overrideStartCheckBox;
    }
    
    private JLabel getStartNodeLabel() {
        if(startNodeLabel == null) {
            startNodeLabel = new JLabel();
            startNodeLabel.setText("Start Node:");
            startNodeLabel.setEnabled(false);
        }
        return startNodeLabel;
    }
    
    private JLabel getEndNodeLabel() {
        if(endNodeLabel == null) {
            endNodeLabel = new JLabel();
            endNodeLabel.setText("End Node:");
            endNodeLabel.setEnabled(false);
        }
        return endNodeLabel;
    }
    
    private JComboBox getStartNodeComboBox() {
        if(startNodeComboBox == null) {
            startNodeComboBoxModel = new TriggerModulesListModel(trigger); 
            startNodeComboBox = new JComboBox();
            startNodeComboBox.setModel(startNodeComboBoxModel);
            startNodeComboBox.setEnabled(false);
        }
        return startNodeComboBox;
    }
    
    private JComboBox getEndNodeComboBox() {
        if(endNodeComboBox == null) {
            endNodeComboBoxModel = new TriggerModulesListModel(trigger); 
            endNodeComboBox = new JComboBox();
            endNodeComboBox.setModel(endNodeComboBoxModel);
            endNodeComboBox.setEnabled(false);
        }
        return endNodeComboBox;
    }
    
    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 FireTriggerDialog inst = new FireTriggerDialog(frame);
                 inst.setVisible(true);
             }
         });
     }
    
    private JCheckBox getOverrideEndCheckBox() {
        if(overrideEndCheckBox == null) {
            overrideEndCheckBox = new JCheckBox();
            overrideEndCheckBox.setText("Override Stop");
            overrideEndCheckBox.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    overrideEndCheckBoxActionPerformed(evt);
                }
            });
        }
        return overrideEndCheckBox;
    }
}
