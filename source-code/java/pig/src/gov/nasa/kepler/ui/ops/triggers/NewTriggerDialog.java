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
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.ui.config.pipeline.PipelineDefinitionListModel;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
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
public class NewTriggerDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(NewTriggerDialog.class);

    private JPanel dataPanel;
    private JButton createButton;
    private JPanel namePanel;
    private JComboBox pipelineComboBox;
    private JTextField nameTextField;
    private JPanel pipelinePanel;
    private JButton cancelButton;
    private JPanel actionPanel;

    private boolean cancelled = false;
    
    PipelineDefinition pipelineDefinition;
    private PipelineDefinitionListModel pipelineComboBoxModel;
    
    public NewTriggerDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }
    
    /**
     * @return the triggerName
     */
    public String getTriggerName() {
        return nameTextField.getText();
    }

    /**
     * @return the pipelineDefinition
     */
    public PipelineDefinition getPipelineDefinition() {
        return (PipelineDefinition) pipelineComboBox.getSelectedItem();
    }
     
    private void initGUI() {
        try {
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            setSize(300, 200);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void createButtonActionPerformed(ActionEvent evt) {
        log.debug("createButton.actionPerformed, event="+evt);
        
        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        
        cancelled = true;
        
        setVisible(false);
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWidths = new int[] {7};
            dataPanelLayout.rowHeights = new int[] {7, 7};
            dataPanelLayout.columnWeights = new double[] {0.1};
            dataPanelLayout.rowWeights = new double[] {0.1, 0.1};
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getNamePanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getPipelinePanel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(35);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getCreateButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getCreateButton() {
        if(createButton == null) {
            createButton = new JButton();
            createButton.setText("create");
            createButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    createButtonActionPerformed(evt);
                }
            });
        }
        return createButton;
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
            namePanel.setBorder(BorderFactory.createTitledBorder("Trigger Name"));
            namePanel.add(getNameTextField(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return namePanel;
    }
    
    private JPanel getPipelinePanel() {
        if(pipelinePanel == null) {
            pipelinePanel = new JPanel();
            GridBagLayout pipelinePanelLayout = new GridBagLayout();
            pipelinePanelLayout.columnWidths = new int[] {7};
            pipelinePanelLayout.rowHeights = new int[] {7};
            pipelinePanelLayout.columnWeights = new double[] {0.1};
            pipelinePanelLayout.rowWeights = new double[] {0.1};
            pipelinePanel.setLayout(pipelinePanelLayout);
            pipelinePanel.setBorder(BorderFactory.createTitledBorder("Pipeline Definition"));
            pipelinePanel.add(getPipelineComboBox(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return pipelinePanel;
    }
    
    private JTextField getNameTextField() {
        if(nameTextField == null) {
            nameTextField = new JTextField();
        }
        return nameTextField;
    }
    
    private JComboBox getPipelineComboBox() {
        if(pipelineComboBox == null) {
            pipelineComboBoxModel = new PipelineDefinitionListModel();
            pipelineComboBox = new JComboBox();
            pipelineComboBox.setModel(pipelineComboBoxModel);
        }
        return pipelineComboBox;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 NewTriggerDialog inst = new NewTriggerDialog(frame);
                 inst.setVisible(true);
             }
         });
     }

    /**
     * @return the cancelled
     */
    public boolean isCancelled() {
        return cancelled;
    }

    /**
     * @param cancelled the cancelled to set
     */
    public void setCancelled(boolean cancelled) {
        this.cancelled = cancelled;
    }
}
