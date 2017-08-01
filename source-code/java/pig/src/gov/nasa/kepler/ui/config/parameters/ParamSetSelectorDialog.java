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

import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.Dialog;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class ParamSetSelectorDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ParamSetSelectorDialog.class);
    
    private JPanel dataPanel;
    private JScrollPane paramSetsScrollPane;
    private ETable paramSetsTable;
    private JButton cancelButton;
    private JButton okButton;
    private JPanel actionPanel;
    private boolean cancelled = false;

    private ParameterSetsTableModel paramSetsTableModel;

    public ParamSetSelectorDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }

    public ParamSetSelectorDialog(Dialog owner) {
        super(owner, true);
        initGUI();
    }

    public ParameterSet selectParamSet(){
    
        this.setVisible(true); // blocks until user presses a button
        
        if(!cancelled){
            int selectedModelRow = paramSetsTable.convertRowIndexToModel(paramSetsTable.getSelectedRow());
            if(selectedModelRow != -1){
                return (ParameterSet) paramSetsTableModel.getParamSetAtRow(selectedModelRow);
            }
        }
        return null;
    }
    
    private void okButtonActionPerformed(ActionEvent evt) {
        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        cancelled = true;
        
        setVisible(false);
    }

    private void initGUI() {
        try {
            {
                this.setTitle("Select new Parameter Set");
            }
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            setSize(400, 600);
        } catch (Exception e) {
            log.warn("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    }
    
    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getParamSetsScrollPane(), BorderLayout.CENTER);
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if (actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(50);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getOkButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getOkButton() {
        if (okButton == null) {
            okButton = new JButton();
            okButton.setText("Ok");
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
            cancelButton.setText("Cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }
    
    private JScrollPane getParamSetsScrollPane() {
        if (paramSetsScrollPane == null) {
            paramSetsScrollPane = new JScrollPane();
            paramSetsScrollPane.setViewportView(getParamSetsTable());
        }
        return paramSetsScrollPane;
    }
    
    private ETable getParamSetsTable(){
        if (paramSetsTable == null) {
            try {
                paramSetsTableModel = new ParameterSetsTableModel();
                paramSetsTable = new ETable();
                paramSetsTable.setModel(paramSetsTableModel);
            } catch (PipelineException e) {
                log.warn("caught e = ", e );
                JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            }
        }
        return paramSetsTable;
    }
}
