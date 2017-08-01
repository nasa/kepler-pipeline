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
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
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
public class ParameterSetNewDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ParameterSetNewDialog.class);

    private JPanel dataPanel;
    private JPanel namePanel;
    private JPanel typePanel;
    private JPanel descPanel;
    private ParameterClassSelectorPanel parameterClassSelectorPanel;
    private JScrollPane descriptionScrollPane;
    private JTextArea descriptionTextArea;
    private JTextField nameTextField;
    private JButton cancelButton;
    private JButton okButton;
    private JPanel actionPanel;

    private boolean cancelled = false;

    private ParameterSet newParamSet = null;
    
    public ParameterSetNewDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }
    
    public static ParameterSet createParameterSet(){
        
        ParameterSetNewDialog dialog = new ParameterSetNewDialog(PipelineConsole.instance);
        dialog.setVisible(true); // blocks until user presses a button
        
        if(!dialog.cancelled){
            return dialog.newParamSet;
        }else{
            return null;
        }
    }
    
    private void okButtonActionPerformed(ActionEvent evt) {
        log.debug("okButton.actionPerformed, event="+evt);
        
        String paramSetName = getNameTextField().getText();
        
        if(paramSetName.isEmpty()){
            JOptionPane.showMessageDialog(this, "Please enter a unique name for the new Parameter Set", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        String paramSetDesc = getDescriptionTextArea().getText();

        ClassWrapper<Parameters> paramSetClassWrapper = getParameterClassSelectorPanel().getSelectedElement();

        if(paramSetClassWrapper == null){
            JOptionPane.showMessageDialog(this, "Please select a class for the new Parameter Set", "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        Class<? extends Parameters> paramSetClass = (Class<? extends Parameters>) paramSetClassWrapper.getClazz();
        
        newParamSet = new ParameterSet(paramSetName);
        newParamSet.setDescription(paramSetDesc);
        newParamSet.setParameters(new BeanWrapper<Parameters>(paramSetClass));
        
        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        
        cancelled = true;

        setVisible(false);
    }
    
    private void initGUI() {
        try {
            {
                this.setTitle("New Parameter Set");
            }
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            setSize(400, 500);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanelLayout.rowHeights = new int[] {7, 7, 7, 7, 7, 7, 7, 7};
            dataPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7, 7};
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getNamePanel(), new GridBagConstraints(0, 0, 6, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getDescPanel(), new GridBagConstraints(0, 1, 6, 2, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getTypePanel(), new GridBagConstraints(0, 4, 6, 4, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(30);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getOkButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getOkButton() {
        if(okButton == null) {
            okButton = new JButton();
            okButton.setText("ok");
            okButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    okButtonActionPerformed(evt);
                }
            });
        }
        return okButton;
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

    private JTextField getNameTextField() {
        if(nameTextField == null) {
            nameTextField = new JTextField();
        }
        return nameTextField;
    }
    
    private JTextArea getDescriptionTextArea() {
        if(descriptionTextArea == null) {
            descriptionTextArea = new JTextArea();
        }
        return descriptionTextArea;
    }
    
    private JScrollPane getDescriptionScrollPane() {
        if(descriptionScrollPane == null) {
            descriptionScrollPane = new JScrollPane();
            descriptionScrollPane.setViewportView(getDescriptionTextArea());
        }
        return descriptionScrollPane;
    }

    private ParameterClassSelectorPanel getParameterClassSelectorPanel() {
        if(parameterClassSelectorPanel == null) {
            parameterClassSelectorPanel = new ParameterClassSelectorPanel();
        }
        return parameterClassSelectorPanel;
    }
    
    private JPanel getNamePanel() {
        if(namePanel == null) {
            namePanel = new JPanel();
            GridBagLayout namePanelLayout = new GridBagLayout();
            namePanelLayout.rowWeights = new double[] {0.1};
            namePanelLayout.rowHeights = new int[] {7};
            namePanelLayout.columnWeights = new double[] {0.1};
            namePanelLayout.columnWidths = new int[] {7};
            namePanel.setLayout(namePanelLayout);
            namePanel.setBorder(BorderFactory.createTitledBorder("Name"));
            namePanel.add(getNameTextField(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return namePanel;
    }
    
    private JPanel getDescPanel() {
        if(descPanel == null) {
            descPanel = new JPanel();
            GridBagLayout descPanelLayout = new GridBagLayout();
            descPanelLayout.rowWeights = new double[] {0.1};
            descPanelLayout.rowHeights = new int[] {7};
            descPanelLayout.columnWeights = new double[] {0.1};
            descPanelLayout.columnWidths = new int[] {7};
            descPanel.setLayout(descPanelLayout);
            descPanel.setBorder(BorderFactory.createTitledBorder("Description"));
            descPanel.add(getDescriptionScrollPane(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return descPanel;
    }
    
    private JPanel getTypePanel() {
        if(typePanel == null) {
            typePanel = new JPanel();
            BorderLayout typePanelLayout = new BorderLayout();
            typePanel.setLayout(typePanelLayout);
            typePanel.setBorder(BorderFactory.createTitledBorder("Type"));
            typePanel.add(getParameterClassSelectorPanel(), BorderLayout.CENTER);
        }
        return typePanel;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 ParameterSetNewDialog inst = new ParameterSetNewDialog(frame);
                 inst.setVisible(true);
             }
         });
     }

}
