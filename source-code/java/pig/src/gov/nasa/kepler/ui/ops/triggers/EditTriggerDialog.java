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

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinitionNode;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.pi.pipeline.TriggerValidationResults;
import gov.nasa.kepler.ui.ops.instances.TextualReportDialog;
import gov.nasa.kepler.ui.ops.parameters.ParameterSetMapEditorDialog;
import gov.nasa.kepler.ui.ops.parameters.ParameterSetMapEditorListener;
import gov.nasa.kepler.ui.ops.parameters.ParameterSetMapEditorPanel;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;
import gov.nasa.kepler.ui.proxy.TriggerDefinitionCrudProxy;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSpinner;
import javax.swing.JTextField;
import javax.swing.SpinnerListModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class EditTriggerDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(EditTriggerDialog.class);

    private JPanel modulesPanel;
    private JButton syncButton;
    private JButton validateButton;
    private JSpinner prioritySpinner;
    private JPanel prioriytPanel;
    private JCheckBox validCheckBox;
    private JLabel validLabel;
    private JTextField pipelineDefNameTextField;
    private JLabel pipelineLabel;
    private JTextField triggerNameTextField;
    private JLabel triggerNameLabel;
    private JButton cancelButton;
    private JButton saveButton;
    private JPanel actionPanel;
    private JButton editModulesButton;
    private JPanel modulesButtonPanel;
    private JList modulesList;
    private JScrollPane modulesScrollPane;
    private ParameterSetMapEditorPanel parameterSetMapEditorPanel;
    private JButton exportButton;
    private JPanel labelsPanel;
    private JPanel dataPanel;

    private TriggerDefinition trigger;
    private JButton reportButton;

    private TriggerModulesListModel triggerModulesListModel;
    private TriggersTreeModel allTriggersModel;

    public EditTriggerDialog(JFrame frame, TriggerDefinition trigger, TriggersTreeModel triggerModel) {
        super(frame, true);
        this.trigger = trigger;
        this.allTriggersModel = triggerModel;

        initGUI();
    }

    /* For Jigloo use only */
    public EditTriggerDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }

    /**
     * Disabled for now since it doesn't work in all cases.
     * 
     * @param evt
     */
    private void syncButtonActionPerformed(ActionEvent evt) {
        log.debug("syncButton.actionPerformed, event=" + evt);

        // verify
        int ans = JOptionPane.showConfirmDialog(this, "Are you sure you want to re-sync this trigger?  " +
        		"This will remove all parameter sets at the module level.", "Are you sure?",
            JOptionPane.YES_NO_OPTION);

        if(ans == JOptionPane.YES_OPTION){
            PipelineOperations pipelineOps = new PipelineOperations();
            pipelineOps.updateTrigger(trigger);

            triggerModulesListModel.loadFromDatabase();
        }
    }

    private void validateButtonActionPerformed(ActionEvent evt) {
        log.debug("validateButton.actionPerformed, event=" + evt);

        PipelineOperationsProxy pipelineOps = new PipelineOperationsProxy();

        TriggerValidationResults results = null;
        try {
            results = pipelineOps.validateTrigger(trigger);

            if (results.hasErrors()) {
                TriggerValidationResultsDialog.showValidationResults(this, results);
            } else {
                JOptionPane.showMessageDialog(this, "This trigger is valid", "Validation OK",
                    JOptionPane.INFORMATION_MESSAGE);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

    }

    private void reportButtonActionPerformed(ActionEvent evt) {
        log.debug("reportButton.actionPerformed, event=" + evt);

        PipelineOperationsProxy ops = new PipelineOperationsProxy();
        String report = ops.generateTriggerReport(trigger);

        TextualReportDialog.showReport(this, report);
    }

    /**
     * 
     * @param evt
     */
    private void exportButtonActionPerformed(ActionEvent evt) {
        log.debug("exportButton.actionPerformed, event=" + evt);

        try {
            JFileChooser fc = new JFileChooser();
            fc.setFileSelectionMode(JFileChooser.DIRECTORIES_ONLY);

            int returnVal = fc.showSaveDialog(this);

            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();

                PipelineOperationsProxy ops = new PipelineOperationsProxy();
                ops.exportTriggerParams(trigger, file);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

    }

    private void initGUI() {
        try {
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);

            if (trigger != null) {
                triggerNameTextField.setText(trigger.getName());
                pipelineDefNameTextField.setText(trigger.getPipelineDefinitionName()
                    .toString());
                validCheckBox.setSelected(trigger.isValid());
            }

            this.setTitle("Edit Trigger");
            this.setSize(572, 603);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void editModulesButtonActionPerformed(ActionEvent evt) {
        log.debug("editModulesButton.actionPerformed, event=" + evt);

        int selectedRow = modulesList.getSelectedIndex();

        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this, "No parameter set selected", "Error", JOptionPane.ERROR_MESSAGE);
        } else {
            final TriggerDefinitionNode triggerNode = triggerModulesListModel.getTriggerNodeAt(selectedRow);

            PipelineOperationsProxy pipelineOps = new PipelineOperationsProxy();
            Set<ClassWrapper<Parameters>> allRequiredParams = pipelineOps.retrieveRequiredParameterClassesForNode(
                trigger, triggerNode);

            Map<ClassWrapper<Parameters>, ParameterSetName> currentParams = triggerNode.getModuleParameterSetNames();
            Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParams = trigger.getPipelineParameterSetNames();

            final ParameterSetMapEditorDialog dialog = new ParameterSetMapEditorDialog(this, currentParams,
                allRequiredParams, currentPipelineParams);

            dialog.setMapListener(new ParameterSetMapEditorListener() {

                public void notifyMapChanged(Object source) {
                    triggerNode.setModuleParameterSetNames(dialog.getParameterSetsMap());
                }
            });

            dialog.setVisible(true); // block until user dismisses
        }
    }

    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButton.actionPerformed, event=" + evt);

        TriggerDefinitionCrudProxy triggerCrud = new TriggerDefinitionCrudProxy();

        try {
            String newName = triggerNameTextField.getText();

            TriggerDefinition existingTrigger = allTriggersModel.triggerByName(newName);

            if ((existingTrigger != null) && (existingTrigger.getId() != trigger.getId())) {
                // operator changed trigger name & it conflicts with an existing
                // trigger
                JOptionPane.showMessageDialog(this, "Trigger name already used, please enter a different name.",
                    "Duplicate Trigger Name", JOptionPane.ERROR_MESSAGE);
                return;
            }

            String priorityString = (String) prioritySpinner.getValue();
            int priority;

            try {
                priority = Integer.parseInt(priorityString);
            } catch (NumberFormatException e) {
                JOptionPane.showMessageDialog(this, e.getMessage(), "Error parsing priority: " + priorityString,
                    JOptionPane.ERROR_MESSAGE);
                return;
            }

            trigger.setName(newName);
            trigger.setInstancePriority(priority);

            triggerCrud.save(trigger);

            setVisible(false);
        } catch (Throwable e) {
            JOptionPane.showMessageDialog(this, e.getMessage(), "Error Saving Trigger", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event=" + evt);
        setVisible(false);
    }

    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWidths = new int[] { 7 };
            dataPanelLayout.rowHeights = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7 };
            dataPanelLayout.columnWeights = new double[] { 0.1 };
            dataPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getLabelsPanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getPrioriytPanel(), new GridBagConstraints(0, 1, 4, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getParameterSetMapEditorPanel(), new GridBagConstraints(0, 2, 1, 4, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getModulesPanel(), new GridBagConstraints(0, 6, 1, 4, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }

    private JPanel getLabelsPanel() {
        if (labelsPanel == null) {
            labelsPanel = new JPanel();
            GridBagLayout labelsPanelLayout = new GridBagLayout();
            labelsPanel.setBorder(BorderFactory.createTitledBorder("Trigger"));
            labelsPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            labelsPanelLayout.rowHeights = new int[] { 7, 7, 7, 7 };
            labelsPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1 };
            labelsPanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7 };
            labelsPanel.setLayout(labelsPanelLayout);
            labelsPanel.add(getTriggerNameLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getTriggerNameTextField(), new GridBagConstraints(1, 0, 4, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getPipelineLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getPipelineDefNameTextField(), new GridBagConstraints(1, 1, 4, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getValidLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getValidCheckBox(), new GridBagConstraints(1, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getValidateButton(), new GridBagConstraints(4, 3, 1, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getReportButton(), new GridBagConstraints(3, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            labelsPanel.add(getExportButton(), new GridBagConstraints(2, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return labelsPanel;
    }

    private ParameterSetMapEditorPanel getParameterSetMapEditorPanel() {
        if (parameterSetMapEditorPanel == null) {
            parameterSetMapEditorPanel = new ParameterSetMapEditorPanel(trigger.getPipelineParameterSetNames(),
                new HashSet<ClassWrapper<Parameters>>(), new HashMap<ClassWrapper<Parameters>, ParameterSetName>());
            parameterSetMapEditorPanel.setMapListener(new ParameterSetMapEditorListener() {
                public void notifyMapChanged(Object source) {
                    trigger.setPipelineParameterSetNames(parameterSetMapEditorPanel.getParameterSetsMap());
                }
            });
            parameterSetMapEditorPanel.setBorder(BorderFactory.createTitledBorder("Pipeline Parameter Sets"));
        }
        return parameterSetMapEditorPanel;
    }

    private JPanel getModulesPanel() {
        if (modulesPanel == null) {
            modulesPanel = new JPanel();
            BorderLayout ModulesPanelLayout = new BorderLayout();
            modulesPanel.setLayout(ModulesPanelLayout);
            modulesPanel.setBorder(BorderFactory.createTitledBorder("Modules"));
            modulesPanel.add(getModulesScrollPane(), BorderLayout.CENTER);
            modulesPanel.add(getModulesButtonPanel(), BorderLayout.SOUTH);
        }
        return modulesPanel;
    }

    private JScrollPane getModulesScrollPane() {
        if (modulesScrollPane == null) {
            modulesScrollPane = new JScrollPane();
            modulesScrollPane.setViewportView(getModulesList());
        }
        return modulesScrollPane;
    }

    private JList getModulesList() {
        if (modulesList == null) {
            triggerModulesListModel = new TriggerModulesListModel(trigger);

            modulesList = new JList();
            modulesList.setModel(triggerModulesListModel);
        }
        return modulesList;
    }

    private JPanel getModulesButtonPanel() {
        if (modulesButtonPanel == null) {
            modulesButtonPanel = new JPanel();
            FlowLayout modulesButtonPanelLayout = new FlowLayout();
            modulesButtonPanelLayout.setHgap(40);
            modulesButtonPanel.setLayout(modulesButtonPanelLayout);
            modulesButtonPanel.add(getEditModulesButton());
            modulesButtonPanel.add(getSyncButton());
        }
        return modulesButtonPanel;
    }

    private JButton getEditModulesButton() {
        if (editModulesButton == null) {
            editModulesButton = new JButton();
            editModulesButton.setText("Edit Parameters");
            editModulesButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    editModulesButtonActionPerformed(evt);
                }
            });
        }
        return editModulesButton;
    }

    private JPanel getActionPanel() {
        if (actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(35);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getCloseButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }

    private JButton getCloseButton() {
        if (saveButton == null) {
            saveButton = new JButton();
            saveButton.setText("Save");
            saveButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    saveButtonActionPerformed(evt);
                }
            });
        }
        return saveButton;
    }

    private JButton getCancelButton() {
        if (cancelButton == null) {
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

    private JLabel getTriggerNameLabel() {
        if (triggerNameLabel == null) {
            triggerNameLabel = new JLabel();
            triggerNameLabel.setText("Name ");
        }
        return triggerNameLabel;
    }

    private JTextField getTriggerNameTextField() {
        if (triggerNameTextField == null) {
            triggerNameTextField = new JTextField();
        }
        return triggerNameTextField;
    }

    private JLabel getPipelineLabel() {
        if (pipelineLabel == null) {
            pipelineLabel = new JLabel();
            pipelineLabel.setText("Pipeline ");
        }
        return pipelineLabel;
    }

    private JTextField getPipelineDefNameTextField() {
        if (pipelineDefNameTextField == null) {
            pipelineDefNameTextField = new JTextField();
            pipelineDefNameTextField.setEditable(false);
        }
        return pipelineDefNameTextField;
    }

    private JLabel getValidLabel() {
        if (validLabel == null) {
            validLabel = new JLabel();
            validLabel.setText("Valid? ");
        }
        return validLabel;
    }

    private JCheckBox getValidCheckBox() {
        if (validCheckBox == null) {
            validCheckBox = new JCheckBox();
            validCheckBox.setEnabled(false);
        }
        return validCheckBox;
    }

    private JPanel getPrioriytPanel() {
        if (prioriytPanel == null) {
            prioriytPanel = new JPanel();
            GridBagLayout prioriytPanelLayout = new GridBagLayout();
            prioriytPanelLayout.rowWeights = new double[] { 0.1 };
            prioriytPanelLayout.rowHeights = new int[] { 7 };
            prioriytPanelLayout.columnWeights = new double[] { 0.1 };
            prioriytPanelLayout.columnWidths = new int[] { 7 };
            prioriytPanel.setLayout(prioriytPanelLayout);
            prioriytPanel.setBorder(BorderFactory.createTitledBorder("Priority (smaller numbers = higher priority)"));
            prioriytPanel.add(getPrioritySpinner(), new GridBagConstraints(0, -1, 1, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return prioriytPanel;
    }

    private JSpinner getPrioritySpinner() {
        if (prioritySpinner == null) {
            SpinnerListModel prioritySpinnerModel = new SpinnerListModel(new String[] { "1", "2", "3", "4", "5", "6",
                "7", "8", "9", "10" });
            prioritySpinner = new JSpinner();
            prioritySpinner.setModel(prioritySpinnerModel);
            prioritySpinner.setPreferredSize(new java.awt.Dimension(50, 22));
            prioritySpinnerModel.setValue(trigger.getInstancePriority() + "");
        }
        return prioritySpinner;
    }

    private JButton getValidateButton() {
        if (validateButton == null) {
            validateButton = new JButton();
            validateButton.setText("validate");
            validateButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    validateButtonActionPerformed(evt);
                }
            });
        }
        return validateButton;
    }

    private JButton getSyncButton() {
        if (syncButton == null) {
            syncButton = new JButton();
            syncButton.setText("Re-sync");
            syncButton.setToolTipText("Re-sync module list with latest version of the pipeline definition");
            syncButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    syncButtonActionPerformed(evt);
                }
            });
        }
        return syncButton;
    }

    private JButton getReportButton() {
        if (reportButton == null) {
            reportButton = new JButton();
            reportButton.setText("report");
            reportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    reportButtonActionPerformed(evt);
                }
            });
        }
        return reportButton;
    }

    private JButton getExportButton() {
        if (exportButton == null) {
            exportButton = new JButton();
            exportButton.setText("export params");
            exportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    exportButtonActionPerformed(evt);
                }
            });
        }
        return exportButton;
    }
}
