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

package gov.nasa.kepler.ui.config.pipeline;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ModuleName;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.hibernate.pi.PipelineModule;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTaskGenerator;
import gov.nasa.kepler.ui.proxy.PipelineModuleDefinitionCrudProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextArea;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Allows editing a new or existing {@link PipelineDefinitionNode}, including
 * selecting an optional (is startNewUow checkbox is selected)
 * {@link UnitOfWorkTaskGenerator} class and editing its properties.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@SuppressWarnings("serial")
public class PipelineNodeEditDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(PipelineNodeEditDialog.class);
    private JLabel moduleLabel;

    private JPanel dataPanel;
    private JTextArea errorTextArea;
    private JComboBox uowTypeComboBox;
    private JLabel uowTypeLabel;
    private JCheckBox startNewUowCheckBox;
    private JPanel uowPanel;
    private JPanel buttonPanel;
    private JComboBox moduleComboBox;
    private JButton cancelButton;
    private JButton saveButton;
    private boolean savePressed = false;

    private PipelineModuleDefinitionCrudProxy pipelineModuleDefinitionCrud;

    private JLabel uowFullNameLabel;

    private PipelineDefinition pipeline;
    private PipelineDefinitionNode pipelineNode;
    private UowTgListModel uowTypeComboBoxModel;

    public PipelineNodeEditDialog(JFrame frame, PipelineDefinition pipeline, PipelineDefinitionNode pipelineNode)
        throws Exception {
        super(frame, "Edit Pipeline Node", true);
        this.pipeline = pipeline;
        this.pipelineNode = pipelineNode;
        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrudProxy();

        initGUI();
    }

    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButtonActionPerformed(ActionEvent) - start");

        try {
            boolean startNewUowSelected = startNewUowCheckBox.isSelected();

            PipelineModuleDefinition selectedModule = (PipelineModuleDefinition) moduleComboBox.getSelectedItem();
            pipelineNode.setPipelineModuleDefinition(selectedModule);
            pipelineNode.setStartNewUow(startNewUowSelected);

            if (startNewUowSelected) {
                UowTgElement selectedUow = (UowTgElement) uowTypeComboBoxModel.getSelectedItem();
                pipelineNode.setUnitOfWork(selectedUow.getClazz());
            }

            setVisible(false);
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

        savePressed = true;
        log.debug("saveButtonActionPerformed(ActionEvent) - end");
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButtonActionPerformed(ActionEvent) - start");

        setVisible(false);

        log.debug("cancelButtonActionPerformed(ActionEvent) - end");
    }

    /**
     * Make sure that the selected UOW task generator generates the
     * {@link UnitOfWorkTask} type that the selected {@link PipelineModule}
     * expects.
     * 
     * If the startNewUowCheckBox is not checked, we actually want to validate
     * against the previous node (TBD)
     * 
     */
    private void validateUnitOfWork() {
        try {
            PipelineModuleDefinition selectedModule = (PipelineModuleDefinition) moduleComboBox.getSelectedItem();
            PipelineModule newInstance = selectedModule.getImplementingClass()
                .newInstance();

            Class<? extends UnitOfWorkTask> selectedModuleUowTaskType = newInstance.unitOfWorkTaskType();

            if (startNewUowCheckBox.isSelected()) {
                UowTgElement selectedItem = (UowTgElement) uowTypeComboBox.getSelectedItem();
                if (selectedItem != null) {
                    ClassWrapper<UnitOfWorkTaskGenerator> bean = selectedItem.getClazz();
                    UnitOfWorkTaskGenerator selectedUowType = bean.newInstance();
                    Class<? extends UnitOfWorkTask> selectedUowTaskType = selectedUowType.unitOfWorkTaskType();

                    if (!selectedModuleUowTaskType.equals(selectedUowTaskType)) {
                        setError(selectedModule + " expects " + selectedModuleUowTaskType.getSimpleName()
                            + ", but the selected UOW type: " + selectedUowType + " generates "
                            + selectedUowTaskType.getSimpleName());
                    } else {
                        setError("");
                    }
                } else {
                    setError("Select a Unit of Work type");
                }
            } else {
                PipelineDefinitionNode parentNode = pipelineNode.getParentNode();
                
                while(parentNode != null && !parentNode.isStartNewUow()){
                    parentNode = parentNode.getParentNode();
                }
                
                if (parentNode != null) {
                    ClassWrapper<UnitOfWorkTaskGenerator> parentTg = parentNode.getUnitOfWork();
                    if(parentTg != null){
                        UnitOfWorkTaskGenerator parentUowType = parentTg.newInstance();
                        Class<? extends UnitOfWorkTask> parentUowTaskType = parentUowType.unitOfWorkTaskType();

                        if (!selectedModuleUowTaskType.equals(parentUowTaskType)) {
                            setError(selectedModule + " expects " + selectedModuleUowTaskType.getSimpleName()
                                + ", but the previous node (" + parentNode.getModuleName() + ") uses "
                                + parentUowTaskType.getSimpleName() + ". Select 'Start new unit of work' or select a different module");
                        } else {
                            setError("");
                        }
                    }
                }else{
                    setError("Unit of Work type must be set for the first node in a pipeline");
                }
            }
        } catch (PipelineException e) {
            log.warn("Failed to validate UOW type", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    /**
     * Update the available UOW types in the uowTypeComboBox based on the newly-selected
     * module.
     * 
     * @param evt
     */
    private void moduleComboBoxActionPerformed(ActionEvent evt) {

        try {
            PipelineModuleDefinition selectedModule = (PipelineModuleDefinition) moduleComboBox.getSelectedItem();
            uowTypeComboBoxModel = new UowTgListModel(selectedModule.getImplementingClass(),
                pipelineNode.getUnitOfWork());
            uowTypeComboBox.setModel(uowTypeComboBoxModel);
            UowTgElement currentUow = (UowTgElement) uowTypeComboBox.getSelectedItem();
            if(currentUow != null){
                uowFullNameLabel.setText(currentUow.getClazz().getClassName());
            }
        } catch (Exception e) {
            log.warn("Failed to change module", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
        
        validateUnitOfWork();
    }

    /**
     * Verify that the selected UOW type is supported by the currently selected
     * module and update error text if it does not.
     * 
     * @param evt
     */
    private void uowTypeComboBoxActionPerformed(ActionEvent evt) {
        UowTgElement currentUow = (UowTgElement) uowTypeComboBox.getSelectedItem();
        if(currentUow != null){
            uowFullNameLabel.setText(currentUow.getClazz().getClassName());
        }
        
        validateUnitOfWork();
    }

    /**
     * 
     * @param evt
     */
    private void startNewUowCheckBoxActionPerformed(ActionEvent evt) {
        boolean selected = startNewUowCheckBox.isSelected();
        // grey out the uow tg settings if the checkbox is not checked
        uowTypeComboBox.setEnabled(selected);
        uowTypeLabel.setEnabled(selected);
        uowFullNameLabel.setEnabled(selected);

        validateUnitOfWork();
    }

    private void initGUI() throws Exception {
        log.debug("initGUI() - start");

        BorderLayout thisLayout = new BorderLayout();
        this.getContentPane()
            .setLayout(thisLayout);
        this.getContentPane()
            .add(getDataPanel(), BorderLayout.CENTER);
        this.getContentPane()
            .add(getButtonPanel(), BorderLayout.SOUTH);

        validateUnitOfWork();

        this.setSize(424, 248);

        log.debug("initGUI() - end");
    }

    private JComboBox getModuleComboBox() {
        log.debug("getModuleComboBox() - start");

        if (moduleComboBox == null) {
            ModuleName moduleName = pipelineNode.getModuleName();
            String currentModuleName = null;

            if (moduleName != null) {
                currentModuleName = moduleName.getName();
            }

            int currentIndex = 0;
            int initialIndex = 0;
            DefaultComboBoxModel moduleComboBoxModel = new DefaultComboBoxModel();
            List<PipelineModuleDefinition> modules = pipelineModuleDefinitionCrud.retrieveAll();
            for (PipelineModuleDefinition module : modules) {
                moduleComboBoxModel.addElement(module);
                if (currentModuleName != null && module.getName()
                    .getName()
                    .equals(currentModuleName)) {
                    initialIndex = currentIndex;
                }
                currentIndex++;
            }
            moduleComboBox = new JComboBox();
            moduleComboBox.setModel(moduleComboBoxModel);
            moduleComboBox.setMaximumRowCount(15);
            moduleComboBox.setSelectedIndex(initialIndex);
            moduleComboBox.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    moduleComboBoxActionPerformed(evt);
                }
            });

            moduleComboBox.setEnabled(!pipeline.isLocked());
        }

        log.debug("getModuleComboBox() - end");
        return moduleComboBox;
    }

    private JComboBox getUowTypeComboBox() {
        if (uowTypeComboBox == null) {
            try {
                PipelineModuleDefinition selectedModule = (PipelineModuleDefinition) moduleComboBox.getSelectedItem();
                uowTypeComboBoxModel = new UowTgListModel(selectedModule.getImplementingClass(),
                    pipelineNode.getUnitOfWork());

                uowTypeComboBox = new JComboBox();
                uowTypeComboBox.setModel(uowTypeComboBoxModel);

                UowTgElement currentUow = (UowTgElement) uowTypeComboBox.getSelectedItem();
                if(currentUow != null){
                    uowFullNameLabel.setText(currentUow.getClazz().getClassName());
                }

                uowTypeComboBox.addActionListener(new ActionListener() {
                    public void actionPerformed(ActionEvent evt) {
                        uowTypeComboBoxActionPerformed(evt);
                    }
                });
            } catch (Exception e) {
                e.printStackTrace();
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
            uowTypeComboBox.setEnabled(!pipeline.isLocked());
        }
        return uowTypeComboBox;
    }

    private JPanel getDataPanel() {
        log.debug("getDataPanel() - start");

        if (dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7, 7 };
            dataPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            dataPanelLayout.rowHeights = new int[] { 7, 7, 7, 7 };
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getModuleComboBox(), new GridBagConstraints(2, 0, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            dataPanel.add(getModuleLabel(), new GridBagConstraints(1, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            dataPanel.add(getUowPanel(), new GridBagConstraints(1, 2, 4, 3, 0.0, 1.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getErrorTextArea(), new GridBagConstraints(1, 1, 4, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }

        log.debug("getDataPanel() - end");
        return dataPanel;
    }

    private JPanel getButtonPanel() {
        log.debug("getButtonPanel() - start");

        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(40);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getSaveButton());
            buttonPanel.add(getCancelButton());
        }

        log.debug("getButtonPanel() - end");
        return buttonPanel;
    }

    private JButton getSaveButton() {
        log.debug("getSaveButton() - start");

        if (saveButton == null) {
            saveButton = new JButton();
            saveButton.setText("Save Changes");
            saveButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    saveButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
            saveButton.setEnabled(!pipeline.isLocked());
        }

        log.debug("getSaveButton() - end");
        return saveButton;
    }

    private JButton getCancelButton() {
        log.debug("getCancelButton() - start");

        if (cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("Cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    cancelButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getCancelButton() - end");
        return cancelButton;
    }

    private JTextArea getErrorTextArea() {
        if (errorTextArea == null) {
            errorTextArea = new JTextArea();
            errorTextArea.setEditable(false);
            errorTextArea.setForeground(new java.awt.Color(255, 0, 0));
            errorTextArea.setOpaque(false);
            errorTextArea.setLineWrap(true);
            errorTextArea.setWrapStyleWord(true);
        }
        return errorTextArea;
    }

    private JLabel getModuleLabel() {
        if (moduleLabel == null) {
            moduleLabel = new JLabel();
            moduleLabel.setText("Module");
        }
        return moduleLabel;
    }

    /**
     * @return Returns the savePressed.
     */
    public boolean wasSavePressed() {
        return savePressed;
    }

    private JPanel getUowPanel() {
        if (uowPanel == null) {
            uowPanel = new JPanel();
            GridBagLayout uowPanelLayout = new GridBagLayout();
            uowPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            uowPanelLayout.rowHeights = new int[] { 7, 7, 7, 7 };
            uowPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            uowPanelLayout.columnWidths = new int[] { 7, 7, 7, 7 };
            uowPanel.setLayout(uowPanelLayout);
            uowPanel.setBorder(BorderFactory.createTitledBorder("Unit of Work"));
            uowPanel.add(getStartNewUowCheckBox(), new GridBagConstraints(0, 0, 4, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            uowPanel.add(getUowTypeLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            uowPanel.add(getUowFullNameLabel(), new GridBagConstraints(0, 3, 4, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            uowPanel.add(getUowTypeComboBox(), new GridBagConstraints(1, 1, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return uowPanel;
    }

    private JCheckBox getStartNewUowCheckBox() {
        if (startNewUowCheckBox == null) {
            startNewUowCheckBox = new JCheckBox();
            startNewUowCheckBox.setText("Start new unit of work");
            startNewUowCheckBox.setSelected(pipelineNode.isStartNewUow());
            startNewUowCheckBox.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    startNewUowCheckBoxActionPerformed(evt);
                }
            });
            startNewUowCheckBox.setEnabled(!pipeline.isLocked());
        }
        return startNewUowCheckBox;
    }

    private JLabel getUowTypeLabel() {
        if (uowTypeLabel == null) {
            uowTypeLabel = new JLabel();
            uowTypeLabel.setText("Unit Of Work Type:");
        }
        return uowTypeLabel;
    }

    /**
     * If the combination of module/uowtype/checkbox is in an invalid state,
     * display error text and disable the save button until it's fixed
     * 
     * @param message
     */
    private void setError(String message) {
        if (saveButton != null) {
            saveButton.setEnabled(message.isEmpty());
        }

        if (errorTextArea != null) {
            errorTextArea.setText(message);
        }
    }
    
    private JLabel getUowFullNameLabel() {
        if(uowFullNameLabel == null) {
            uowFullNameLabel = new JLabel();
            uowFullNameLabel.setFont(new java.awt.Font("Dialog",2,10));
        }
        return uowFullNameLabel;
    }

}
