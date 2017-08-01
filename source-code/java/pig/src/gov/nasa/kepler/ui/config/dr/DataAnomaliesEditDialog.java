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

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.dr.DataAnomaly.DataAnomalyType;
import gov.nasa.kepler.ui.proxy.DataAnomalyModelCrudProxy;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.ComboBoxModel;
import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Dialog for editing new or existing data anomaly entries (DR_DATA_ANOMALY table)
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class DataAnomaliesEditDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(DataAnomaliesEditDialog.class);

    private JPanel dataPanel;
    private JComboBox anomalyTypeComboBox;
    private JComboBox cadenceTypeComboBox;
    private JTextField endCadenceTextField;
    private JTextField startCadenceTextField;
    private JLabel cadenceTypeLabel;
    private JLabel endCadenceLabel;
    private JLabel startCadenceLabel;
    private JLabel anomalyTypeLabel;
    private JButton cancelButton;
    private JButton okButton;
    private JPanel buttonPanel;

    private DataAnomaly existingDataAnomaly;

    public DataAnomaliesEditDialog(JFrame frame, DataAnomaly dataAnomaly) {
        super(frame, true);

        this.existingDataAnomaly = dataAnomaly;

        initGUI();
    }

    public static void addNewDataAnomaly(JFrame frame) {
        DataAnomaliesEditDialog d = new DataAnomaliesEditDialog(frame, null);

        d.setVisible(true);
    }

    public static void editExistingDataAnomaly(JFrame frame, DataAnomaly anomaly) {
        DataAnomaliesEditDialog d = new DataAnomaliesEditDialog(frame, anomaly);

        d.setVisible(true);
    }

    private void okButtonActionPerformed(ActionEvent evt) {
        log.debug("okButton.actionPerformed, event=" + evt);

        DataAnomalyType anomalyType = (DataAnomalyType) anomalyTypeComboBox.getSelectedItem();
        String startCadenceStr = startCadenceTextField.getText();
        String endCadenceStr = endCadenceTextField.getText();
        Cadence.CadenceType cadenceType = (CadenceType) getCadenceTypeComboBox()
            .getSelectedItem();
        int startCadence;
        int endCadence;

        try {
            startCadence = Integer.parseInt(startCadenceStr);
        } catch (NumberFormatException e) {
            log.error("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Invalid number for Start Cadence: " + startCadenceStr,
                JOptionPane.ERROR_MESSAGE);
            return;
        }
        try {
            endCadence = Integer.parseInt(endCadenceStr);
        } catch (NumberFormatException e) {
            log.error("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Invalid number for End Cadence: " + endCadenceStr,
                JOptionPane.ERROR_MESSAGE);
            return;
        }

        DataAnomalyModelCrudProxy crud = new DataAnomalyModelCrudProxy();
        
        try {
            if(existingDataAnomaly != null){
                // edit existing
                existingDataAnomaly.setDataAnomalyType(anomalyType);
                existingDataAnomaly.setCadenceType(cadenceType.intValue());
                existingDataAnomaly.setStartCadence(startCadence);
                existingDataAnomaly.setEndCadence(endCadence);
                
                crud.saveChanges();
            }else{
                // create new
                crud.addDataAnomaly(anomalyType, cadenceType, startCadence, endCadence);
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(this, e, "Error: " + e.getMessage(),
                JOptionPane.ERROR_MESSAGE);
            return;
        }
        
        setVisible(false);
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event=" + evt);

        setVisible(false);
    }

    private void initGUI() {
        try {
            {
                this.setTitle("Add New Data Anomaly");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            }
            setSize(400, 300);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7 };
            dataPanelLayout.rowHeights = new int[] { 7, 7, 7, 7 };
            dataPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getAnomalyTypeLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getStartCadenceLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getEndCadenceLabel(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getCadenceTypeLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getAnomalyTypeComboBox(), new GridBagConstraints(1, 0, 3, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getStartCadenceTextField(), new GridBagConstraints(1, 1, 3, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getEndCadenceTextField(), new GridBagConstraints(1, 2, 3, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getCadenceTypeComboBox(), new GridBagConstraints(1, 3, 3, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }

    private JPanel getButtonPanel() {
        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(50);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getOkButton());
            buttonPanel.add(getCancelButton());
        }
        return buttonPanel;
    }

    private JButton getOkButton() {
        if (okButton == null) {
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

    private JLabel getAnomalyTypeLabel() {
        if (anomalyTypeLabel == null) {
            anomalyTypeLabel = new JLabel();
            anomalyTypeLabel.setText("Anomaly Type");
        }
        return anomalyTypeLabel;
    }

    private JLabel getStartCadenceLabel() {
        if (startCadenceLabel == null) {
            startCadenceLabel = new JLabel();
            startCadenceLabel.setText("Start Cadence");
        }
        return startCadenceLabel;
    }

    private JLabel getEndCadenceLabel() {
        if (endCadenceLabel == null) {
            endCadenceLabel = new JLabel();
            endCadenceLabel.setText("End Cadence");
        }
        return endCadenceLabel;
    }

    private JLabel getCadenceTypeLabel() {
        if (cadenceTypeLabel == null) {
            cadenceTypeLabel = new JLabel();
            cadenceTypeLabel.setText("Cadence Type");
        }
        return cadenceTypeLabel;
    }

    private JComboBox getAnomalyTypeComboBox() {
        if (anomalyTypeComboBox == null) {
            ComboBoxModel anomalyTypeComboBoxModel = new DefaultComboBoxModel(DataAnomaly.DataAnomalyType.values());
            anomalyTypeComboBox = new JComboBox();
            anomalyTypeComboBox.setModel(anomalyTypeComboBoxModel);
            if(existingDataAnomaly != null){
                anomalyTypeComboBox.setSelectedIndex(existingDataAnomaly.getDataAnomalyType().ordinal());
            }
        }
        return anomalyTypeComboBox;
    }

    private JTextField getStartCadenceTextField() {
        if (startCadenceTextField == null) {
            startCadenceTextField = new JTextField();
            if(existingDataAnomaly != null){
                startCadenceTextField.setText(String.valueOf(existingDataAnomaly.getStartCadence()));
            }
        }
        return startCadenceTextField;
    }

    private JTextField getEndCadenceTextField() {
        if (endCadenceTextField == null) {
            endCadenceTextField = new JTextField();
            if(existingDataAnomaly != null){
                endCadenceTextField.setText(String.valueOf(existingDataAnomaly.getEndCadence()));
            }
        }
        return endCadenceTextField;
    }

    private JComboBox getCadenceTypeComboBox() {
        if (cadenceTypeComboBox == null) {
            ComboBoxModel cadenceTypeComboBoxModel = new DefaultComboBoxModel(Cadence.CadenceType.values());
            cadenceTypeComboBox = new JComboBox();
            cadenceTypeComboBox.setModel(cadenceTypeComboBoxModel);
            if(existingDataAnomaly != null){
                cadenceTypeComboBox.setSelectedIndex(Cadence.CadenceType.valueOf(existingDataAnomaly.getCadenceType()).ordinal());
            }else{
                cadenceTypeComboBox.setSelectedIndex(1);
            }
        }
        return cadenceTypeComboBox;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrame frame = new JFrame();
                DataAnomaliesEditDialog inst = new DataAnomaliesEditDialog(frame, null);
                inst.setVisible(true);
            }
        });
    }

}
