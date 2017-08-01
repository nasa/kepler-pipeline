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

import gov.nasa.kepler.dr.dispatch.Dispatcher;
import gov.nasa.kepler.hibernate.dr.DispatcherTrigger;
import gov.nasa.kepler.ui.common.ClasspathUtils;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Set;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Select a Dispatcher type
 * Used when creating a new {@link DispatcherTrigger} 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class DispatcherClassSelectorDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(DispatcherClassSelectorDialog.class);

    private JPanel dataPanel;
    private JComboBox dispatcherClassComboBox;
    private JLabel dispatcherLabel;
    private JButton cancelButton;
    private JButton saveButton;
    private JPanel actionPanel;
    private boolean cancelled = false;
    
    public DispatcherClassSelectorDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }
    
    public static DispatcherType showDispatcherClassSelectorDialog(JFrame frame){
        DispatcherClassSelectorDialog dialog = new DispatcherClassSelectorDialog(frame);
        
        dialog.setVisible(true);
        
        DispatcherType selectedDispatcher = null;
        
        if(!dialog.cancelled){
            selectedDispatcher = (DispatcherType) dialog.dispatcherClassComboBox.getSelectedItem();
        }
        
        return selectedDispatcher;
    }
    
    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButton.actionPerformed, event="+evt);
        
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
                this.setTitle("Select Dispatcher Type");
            }
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            this.setSize(434, 139);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.rowWeights = new double[] {0.1};
            dataPanelLayout.rowHeights = new int[] {7};
            dataPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1};
            dataPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7};
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getDispatcherLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getDispatcherClassComboBox(), new GridBagConstraints(1, 0, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
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
            dispatcherLabel.setText("Dispatcher Tyoe:");
        }
        return dispatcherLabel;
    }
    
    private JComboBox getDispatcherClassComboBox() {
        if(dispatcherClassComboBox == null) {

            DefaultComboBoxModel dispatcherTypeComboBoxModel = new DefaultComboBoxModel();

            try {
                ClasspathUtils classpathUtils = new ClasspathUtils();
                Set<Class<? extends Dispatcher>> detectedClasses = classpathUtils.scanFully(Dispatcher.class);
                
                for (Class<? extends Dispatcher> clazz : detectedClasses) {
                    try {
                        DispatcherType wrapper = new DispatcherType(clazz.getName());
                        dispatcherTypeComboBoxModel.addElement(wrapper);
                    } catch (Exception ignore) {
                    }
                }

                dispatcherClassComboBox = new JComboBox();
                dispatcherClassComboBox.setModel(dispatcherTypeComboBoxModel);
            } catch (Exception e) {
                e.printStackTrace();
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        return dispatcherClassComboBox;
    }

}
