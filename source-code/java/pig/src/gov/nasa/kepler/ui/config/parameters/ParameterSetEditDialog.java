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

import gov.nasa.kepler.common.ui.PropertySheetHelper;
import gov.nasa.kepler.hibernate.pi.BeanWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.pi.parameters.ParametersUtils;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.l2fprod.common.propertysheet.PropertySheetPanel;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ParameterSetEditDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ParameterSetEditDialog.class);

    private ParameterSet parameterSet;
    private Parameters currentParams;
    private boolean initializing = true;
    private PropertySheetPanel paramsPropPanel;
    private JButton defaultsButton;
    private JButton exportButton;
    private JButton importButton;
    private JPanel buttonPanel;
    private JPanel namePanel;
    private JButton cancelButton;
    private JButton saveButton;
    private JPanel actionPanel;
    private JTextArea descriptionTextArea;
    private JScrollPane descriptionScrollPane;
    private JPanel descriptionPanel;
    private JTextField versionTextField;
    private JPanel versionPanel;
    private JTextField nameTextField;
    private JPanel parametersPanel;
    private JPanel dataPanel;

    private boolean cancelled = false;

    private boolean isNew = false;

    public ParameterSetEditDialog(JFrame frame, ParameterSet parameterSet, boolean isNew) {
        super(frame, true);
        this.parameterSet = parameterSet;
        this.isNew = isNew;
        
        initializeCurrentParamsfromDefinition();

        initGUI();
        initializing = false;
    }

    private void initializeCurrentParamsfromDefinition() {
        BeanWrapper<Parameters> moduleParamsBean = parameterSet.getParameters();

        if (moduleParamsBean != null && moduleParamsBean.isInitialized()) {
            try {
                this.currentParams = moduleParamsBean.getInstance();
            } catch (PipelineException e) {
                throw new PipelineException("Can't edit this Parameter Set because the underlying Java class has been deleted", e );
            }
        }
    }

    private void populateParamsPropertySheet() {
        if (currentParams != null) {
            try {
                PropertySheetHelper.populatePropertySheet(currentParams, paramsPropPanel);
            } catch (Exception e) {
                throw new PipelineException("Failed to introspect Parameters bean", e);
            }
        }
    }

    private void defaultsButtonActionPerformed(ActionEvent evt) {
        log.debug("defaultsButton.actionPerformed, event="+evt);
        
        BeanWrapper<Parameters> newBean = new BeanWrapper<Parameters>(currentParams.getClass());
        paramsPropPanel.readFromObject(newBean.getInstance());
    }
    
    private void importButtonActionPerformed(ActionEvent evt) {
        log.debug("importButton.actionPerformed, event=" + evt);

        try {
            JFileChooser fc = new JFileChooser();
            int returnVal = fc.showOpenDialog(this);

            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();

                currentParams = ParametersUtils.importParameters(file, currentParams.getClass());
                paramsPropPanel.readFromObject(currentParams);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void exportButtonActionPerformed(ActionEvent evt) {
        log.debug("exportButton.actionPerformed, event=" + evt);

        try {
            JFileChooser fc = new JFileChooser();
            int returnVal = fc.showSaveDialog(this);

            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                paramsPropPanel.writeToObject(currentParams);
                ParametersUtils.exportParameters(file, currentParams);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButton.actionPerformed, event=" + evt);

        try {
            paramsPropPanel.writeToObject(currentParams);
            String description = descriptionTextArea.getText();

            PipelineOperationsProxy pipelineOperations = new PipelineOperationsProxy();
            pipelineOperations.updateParameterSet(parameterSet, currentParams, description, isNew);
            
            setVisible(false);
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event=" + evt);

        cancelled = true;

        setVisible(false);
    }

    private void initGUI() {
        try {
            {
                BorderLayout thisLayout = new BorderLayout();
                getContentPane().setLayout(thisLayout);
                this.setTitle("Edit Parameter Set");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            }
            setSize(500, 600);

            populateParamsPropertySheet();

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * @return the cancelled
     */
    public boolean isCancelled() {
        return cancelled;
    }

    /**
     * @return the initializing
     */
    public boolean isInitializing() {
        return initializing;
    }

    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7 };
            dataPanelLayout.rowHeights = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 };
            dataPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanel.setLayout(dataPanelLayout);

            dataPanel.add(getParametersPanel(), new GridBagConstraints(0, 5, 5, 5, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getNamePanel(), new GridBagConstraints(0, 0, 5, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getVersionPanel(), new GridBagConstraints(0, 1, 5, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getDescriptionPanel(), new GridBagConstraints(0, 2, 5, 2, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }

    private JPanel getParametersPanel() {
        if (parametersPanel == null) {
            parametersPanel = new JPanel();
            BorderLayout parametersPanelLayout = new BorderLayout();
            parametersPanel.setLayout(parametersPanelLayout);
            parametersPanel.setBorder(BorderFactory.createTitledBorder("Parameters (" + parameterSet.getParameters()
                .getClazz()
                .getSimpleName() + ")"));
            parametersPanel.add(getButtonPanel(), BorderLayout.SOUTH);
            parametersPanel.add(getParamsPropPanel(), BorderLayout.CENTER);
        }
        return parametersPanel;
    }

    private PropertySheetPanel getParamsPropPanel() {
        if (paramsPropPanel == null) {
            paramsPropPanel = new PropertySheetPanel();
        }
        return paramsPropPanel;
    }

    private JPanel getNamePanel() {
        if (namePanel == null) {
            namePanel = new JPanel();
            GridBagLayout namePanelLayout = new GridBagLayout();
            namePanelLayout.columnWidths = new int[] { 7 };
            namePanelLayout.rowHeights = new int[] { 7 };
            namePanelLayout.columnWeights = new double[] { 0.1 };
            namePanelLayout.rowWeights = new double[] { 0.1 };
            namePanel.setLayout(namePanelLayout);
            namePanel.setBorder(BorderFactory.createTitledBorder("Name"));
            namePanel.add(getNameTextField(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return namePanel;
    }

    private JTextField getNameTextField() {
        if (nameTextField == null) {
            nameTextField = new JTextField();
            nameTextField.setEditable(false);
            nameTextField.setText(parameterSet.getName()
                .getName());
        }
        return nameTextField;
    }

    private JPanel getVersionPanel() {
        if (versionPanel == null) {
            versionPanel = new JPanel();
            GridBagLayout versionPanelLayout = new GridBagLayout();
            versionPanelLayout.columnWidths = new int[] { 7 };
            versionPanelLayout.rowHeights = new int[] { 7 };
            versionPanelLayout.columnWeights = new double[] { 0.1 };
            versionPanelLayout.rowWeights = new double[] { 0.1 };
            versionPanel.setLayout(versionPanelLayout);
            versionPanel.setBorder(BorderFactory.createTitledBorder("Version"));
            versionPanel.add(getVersionTextField(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return versionPanel;
    }

    private JTextField getVersionTextField() {
        if (versionTextField == null) {
            versionTextField = new JTextField();
            versionTextField.setEditable(false);
            versionTextField.setText(parameterSet.getVersion() + "");
        }
        return versionTextField;
    }

    private JPanel getDescriptionPanel() {
        if (descriptionPanel == null) {
            descriptionPanel = new JPanel();
            GridBagLayout descriptionPanelLayout = new GridBagLayout();
            descriptionPanelLayout.columnWidths = new int[] { 7 };
            descriptionPanelLayout.rowHeights = new int[] { 7 };
            descriptionPanelLayout.columnWeights = new double[] { 0.1 };
            descriptionPanelLayout.rowWeights = new double[] { 0.1 };
            descriptionPanel.setLayout(descriptionPanelLayout);
            descriptionPanel.setBorder(BorderFactory.createTitledBorder("Description"));
            descriptionPanel.add(getDescriptionScrollPane(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return descriptionPanel;
    }

    private JScrollPane getDescriptionScrollPane() {
        if (descriptionScrollPane == null) {
            descriptionScrollPane = new JScrollPane();
            descriptionScrollPane.setViewportView(getDescriptionTextArea());
        }
        return descriptionScrollPane;
    }

    private JTextArea getDescriptionTextArea() {
        if (descriptionTextArea == null) {
            descriptionTextArea = new JTextArea();
            descriptionTextArea.setText(parameterSet.getDescription());
        }
        return descriptionTextArea;
    }

    private JPanel getActionPanel() {
        if (actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(70);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getSaveButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }

    private JButton getSaveButton() {
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
            cancelButton.setText("Cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }

    private JPanel getButtonPanel() {
        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getDefaultsButton());
            buttonPanel.add(getImportButton());
            buttonPanel.add(getExportButton());
        }
        return buttonPanel;
    }

    private JButton getImportButton() {
        if (importButton == null) {
            importButton = new JButton();
            importButton.setText("Import");
            importButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    importButtonActionPerformed(evt);
                }
            });
        }
        return importButton;
    }

    private JButton getExportButton() {
        if (exportButton == null) {
            exportButton = new JButton();
            exportButton.setText("Export");
            exportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    exportButtonActionPerformed(evt);
                }
            });
        }
        return exportButton;
    }
    
    private JButton getDefaultsButton() {
        if(defaultsButton == null) {
            defaultsButton = new JButton();
            defaultsButton.setText("Replace with Defaults");
            defaultsButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    defaultsButtonActionPerformed(evt);
                }
            });
        }
        return defaultsButton;
    }
}
