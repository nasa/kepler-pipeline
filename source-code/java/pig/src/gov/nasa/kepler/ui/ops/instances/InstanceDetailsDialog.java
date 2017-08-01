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

package gov.nasa.kepler.ui.ops.instances;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.ui.ons.etable.EShadedTable;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.kepler.ui.ops.parameters.ParameterSetViewDialog;
import gov.nasa.kepler.ui.ops.parameters.ParameterSetViewPanel;
import gov.nasa.kepler.ui.proxy.PipelineInstanceCrudProxy;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Date;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
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
public class InstanceDetailsDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(InstanceDetailsDialog.class);

    private JPanel infoPanel;
    private JPanel nodesPanel;
    private JPanel actionPanel;
    private JButton viewNodeParamsButton;
    private JPanel nodesButtonPanel;
    private JScrollPane nodesScrollPane;
    private JButton closeButton;
    private ParameterSetViewPanel pipelineParameterSetsPanel;
    private JLabel endLabel;
    private JTextField endTextField;
    private JTextField totalTextField;
    private JTextField startTextField;
    private JTextField idTextField;
    private JTextField nameTextField;
    private JButton updateButton;
    private JButton reportButton;
    private ETable nodeTable;
    private JLabel idLabel;
    private JLabel totalLabel;
    private JLabel startLabel;
    private JLabel nameLabel;

    private PipelineInstance pipelineInstance = null;

    private InstanceModulesTableModel nodeTableModel;

    /* for Jigloo use only */
    public InstanceDetailsDialog(JFrame frame) {
        this(frame, null);
    }

    public InstanceDetailsDialog(JFrame frame, PipelineInstance pipelineInstance) {
        super(frame, true);
        this.pipelineInstance = pipelineInstance;

        initGUI();
    }
    
    private void updateButtonActionPerformed(ActionEvent evt) {
        log.debug("updateButton.actionPerformed, event="+evt);
        
        try {
            String newName = nameTextField.getText();
            
            if(!newName.equals(pipelineInstance.getName())){
                PipelineInstanceCrudProxy instanceCrud = new PipelineInstanceCrudProxy();
                instanceCrud.updateName(pipelineInstance.getId(), newName);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
        
    }
    
    private void viewNodeParamsButtonActionPerformed(ActionEvent evt) {
        log.debug("viewNodeParamsButton.actionPerformed, event=" + evt);
        
        int selectedRow = nodeTable.getSelectedRow();
        
        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this, "No module selected", "Error", JOptionPane.ERROR_MESSAGE);
        } else {
            PipelineInstanceNode node = nodeTableModel.getPipelineNodeAt(selectedRow);
            ParameterSetViewDialog.showParameterSet(this, node.getModuleParameterSets());
        }
    }

    private void reportButtonActionPerformed(ActionEvent evt) {
        log.debug("reportButton.actionPerformed, event="+evt);
        
        PipelineOperationsProxy ops = new PipelineOperationsProxy();
        String report = ops.generatePedigreeReport(pipelineInstance);
        
        TextualReportDialog.showReport(this, report);
    }


    private void closeButtonActionPerformed(ActionEvent evt) {
        log.debug("closeButton.actionPerformed, event=" + evt);
        
        setVisible(false);
    }

    private void initGUI() {
        try {
            {
                GridBagLayout thisLayout = new GridBagLayout();
                this.setTitle("Pipeline Instance Details");
                thisLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
                thisLayout.rowHeights = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 };
                thisLayout.columnWeights = new double[] { 0.1 };
                thisLayout.columnWidths = new int[] { 7 };
                getContentPane().setLayout(thisLayout);
                getContentPane().add(
                    getInfoPanel(),
                    new GridBagConstraints(0, 0, 1, 4, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH,
                        new Insets(0, 0, 0, 0), 0, 0));
                getContentPane().add(
                    getPipelineParameterSetsPanel(),
                    new GridBagConstraints(0, 4, 1, 4, 0.0, 1.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH,
                        new Insets(0, 0, 0, 0), 0, 0));
                getContentPane().add(
                    getNodesPanel(),
                    new GridBagConstraints(0, 8, 1, 4, 0.0, 1.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH,
                        new Insets(0, 0, 0, 0), 0, 0));
                getContentPane().add(
                    getActionPanel(),
                    new GridBagConstraints(0, 12, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH,
                        new Insets(0, 0, 0, 0), 0, 0));
            }
            this.setSize(520, 648);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JPanel getInfoPanel() {
        if (infoPanel == null) {
            infoPanel = new JPanel();
            GridBagLayout infoPanelLayout = new GridBagLayout();
            infoPanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7, 7, 7, 7 };
            infoPanelLayout.rowHeights = new int[] { 7, 7, 7, 7 };
            infoPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            infoPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            infoPanel.setLayout(infoPanelLayout);
            infoPanel.setBorder(BorderFactory.createTitledBorder("Pipeline Instance"));
            infoPanel.add(getNameLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getStartLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getEndLabel(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getTotalLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getIdLabel(), new GridBagConstraints(6, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getNameTextField(), new GridBagConstraints(1, 0, 4, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getIdTextField(), new GridBagConstraints(7, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getStartTextField(), new GridBagConstraints(1, 1, 7, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getEndTextField(), new GridBagConstraints(1, 2, 8, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getTotalTextField(), new GridBagConstraints(1, 3, 8, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            infoPanel.add(getUpdateButton(), new GridBagConstraints(5, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return infoPanel;
    }

    private ParameterSetViewPanel getPipelineParameterSetsPanel() {
        if (pipelineParameterSetsPanel == null) {
            if(pipelineInstance != null){
                pipelineParameterSetsPanel = new ParameterSetViewPanel(pipelineInstance.getPipelineParameterSets());
            }else{
                pipelineParameterSetsPanel = new ParameterSetViewPanel();
            }
            pipelineParameterSetsPanel.setBorder(BorderFactory.createTitledBorder("Pipeline Parameters"));
        }
        return pipelineParameterSetsPanel;
    }

    private JPanel getNodesPanel() {
        if (nodesPanel == null) {
            nodesPanel = new JPanel();
            BorderLayout nodesPanelLayout = new BorderLayout();
            nodesPanel.setLayout(nodesPanelLayout);
            nodesPanel.setBorder(BorderFactory.createTitledBorder("Modules"));
            nodesPanel.add(getNodesScrollPane(), BorderLayout.CENTER);
            nodesPanel.add(getNodesButtonPanel(), BorderLayout.SOUTH);
        }
        return nodesPanel;
    }

    private JPanel getActionPanel() {
        if (actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(35);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getCloseButton());
            actionPanel.add(getReportButton());
        }
        return actionPanel;
    }

    private JButton getCloseButton() {
        if (closeButton == null) {
            closeButton = new JButton();
            closeButton.setText("close");
            closeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    closeButtonActionPerformed(evt);
                }
            });
        }
        return closeButton;
    }

    private JScrollPane getNodesScrollPane() {
        if (nodesScrollPane == null) {
            nodesScrollPane = new JScrollPane();
            nodesScrollPane.setViewportView(getNodeTable());
        }
        return nodesScrollPane;
    }

    private JPanel getNodesButtonPanel() {
        if (nodesButtonPanel == null) {
            nodesButtonPanel = new JPanel();
            nodesButtonPanel.add(getViewNodeParamsButton());
        }
        return nodesButtonPanel;
    }

    private JButton getViewNodeParamsButton() {
        if (viewNodeParamsButton == null) {
            viewNodeParamsButton = new JButton();
            viewNodeParamsButton.setText("view module parameters");
            viewNodeParamsButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    viewNodeParamsButtonActionPerformed(evt);
                }
            });
        }
        return viewNodeParamsButton;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrame frame = new JFrame();
                InstanceDetailsDialog inst = new InstanceDetailsDialog(frame);
                inst.setVisible(true);
            }
        });
    }

    private JLabel getNameLabel() {
        if (nameLabel == null) {
            nameLabel = new JLabel();
            nameLabel.setText("Name ");
        }
        return nameLabel;
    }

    private JLabel getStartLabel() {
        if (startLabel == null) {
            startLabel = new JLabel();
            startLabel.setText("Start ");
        }
        return startLabel;
    }

    private JLabel getEndLabel() {
        if (endLabel == null) {
            endLabel = new JLabel();
            endLabel.setText("End ");
        }
        return endLabel;
    }

    private JLabel getTotalLabel() {
        if (totalLabel == null) {
            totalLabel = new JLabel();
            totalLabel.setText("Total ");
        }
        return totalLabel;
    }

    private JLabel getIdLabel() {
        if (idLabel == null) {
            idLabel = new JLabel();
            idLabel.setText("ID ");
        }
        return idLabel;
    }

    private JTextField getNameTextField() {
        if (nameTextField == null) {
            nameTextField = new JTextField();
            nameTextField.setText(pipelineInstance.getName());
        }
        return nameTextField;
    }

    private JTextField getIdTextField() {
        if (idTextField == null) {
            idTextField = new JTextField();
            idTextField.setText(pipelineInstance.getId() + "");
            idTextField.setEditable(false);
        }
        return idTextField;
    }

    private JTextField getStartTextField() {
        if (startTextField == null) {
            startTextField = new JTextField();
            startTextField.setText(pipelineInstance.getStartProcessingTime().toString());
            startTextField.setEditable(false);
        }
        return startTextField;
    }

    private JTextField getEndTextField() {
        if (endTextField == null) {
            endTextField = new JTextField();
            Date endProcessingTime = pipelineInstance.getEndProcessingTime();
            if(endProcessingTime.getTime() == 0){
                endTextField.setText("-");
            }else{
                endTextField.setText(endProcessingTime.toString());
            }
            endTextField.setEditable(false);
        }
        return endTextField;
    }

    private JTextField getTotalTextField() {
        if (totalTextField == null) {
            totalTextField = new JTextField();
            String elapsedTime = StringUtils.elapsedTime(pipelineInstance.getStartProcessingTime(),
                pipelineInstance.getEndProcessingTime());
            totalTextField.setText(elapsedTime);
            totalTextField.setEditable(false);
        }
        return totalTextField;
    }
    
    private ETable getNodeTable() {
        if(nodeTable == null) {
            nodeTableModel = 
                new InstanceModulesTableModel(pipelineInstance);
            nodeTable = new EShadedTable();
            nodeTable.setModel(nodeTableModel);
        }
        return nodeTable;
    }
    
    private JButton getReportButton() {
        if(reportButton == null) {
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
    
    private JButton getUpdateButton() {
        if(updateButton == null) {
            updateButton = new JButton();
            updateButton.setText("update");
            updateButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    updateButtonActionPerformed(evt);
                }
            });
        }
        return updateButton;
    }
}
