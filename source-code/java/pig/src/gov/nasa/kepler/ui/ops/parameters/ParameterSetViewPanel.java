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

package gov.nasa.kepler.ui.ops.parameters;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.WindowConstants;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Display a Map<ClassWrapper<Parameters>, ParameterSet> in
 * read-only mode.  Used for viewing the parameters used for a 
 * particular pipeline instance.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class ParameterSetViewPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(ParameterSetViewPanel.class);

    private JScrollPane paramSetsScrollPane;
    private JButton viewParamSetButton;
    private JPanel buttonPanel;
    private ETable paramSetsTable;
    private Map<ClassWrapper<Parameters>, ParameterSet> parameterSetsMap = new HashMap<ClassWrapper<Parameters>, ParameterSet>();
    private ParameterSetTableModel paramSetsTableModel;

    public ParameterSetViewPanel() {
        this(null);
    }
    
    public ParameterSetViewPanel(Map<ClassWrapper<Parameters>, ParameterSet> parameterSetsMap) {
        this.parameterSetsMap  = parameterSetsMap;
        
        initGUI();
    }
    
    
    private void viewParamSetButtonActionPerformed(ActionEvent evt) {
        log.debug("viewParamSetButton.actionPerformed, event="+evt);
        
        int selectedModelRow = paramSetsTable.convertRowIndexToModel(paramSetsTable.getSelectedRow());

        if (selectedModelRow == -1) {
            JOptionPane.showMessageDialog(this, "No parameter set selected", "Error", JOptionPane.ERROR_MESSAGE);
        } else {
            ParameterSet paramSet = paramSetsTableModel.getParamSetAtRow(selectedModelRow);
            
            ViewParametersDialog.viewParameters(paramSet);        
        }
        
    }

    private void initGUI() {
        try {
            GridBagLayout thisLayout = new GridBagLayout();
            setPreferredSize(new Dimension(400, 300));
            thisLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1};
            thisLayout.rowHeights = new int[] {7, 7, 7, 7};
            thisLayout.columnWeights = new double[] {0.1};
            thisLayout.columnWidths = new int[] {7};
            this.setLayout(thisLayout);
            this.add(getParamSetsScrollPane(), new GridBagConstraints(0, 0, 1, 3, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            this.add(getButtonPanel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JScrollPane getParamSetsScrollPane() {
        if(paramSetsScrollPane == null) {
            paramSetsScrollPane = new JScrollPane();
            paramSetsScrollPane.setViewportView(getParamSetsTable());
        }
        return paramSetsScrollPane;
    }
    
    private ETable getParamSetsTable() {
        if(paramSetsTable == null) {
            paramSetsTableModel = new ParameterSetTableModel(parameterSetsMap); 
            paramSetsTable = new ETable();
            paramSetsTable.setModel(paramSetsTableModel);
        }
        return paramSetsTable;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            buttonPanel.add(getViewParamSetButton());
        }
        return buttonPanel;
    }
    
    private JButton getViewParamSetButton() {
        if(viewParamSetButton == null) {
            viewParamSetButton = new JButton();
            viewParamSetButton.setText("view parameters");
            viewParamSetButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    viewParamSetButtonActionPerformed(evt);
                }
            });
        }
        return viewParamSetButton;
    }

    /**
     * Auto-generated main method to display this 
     * JPanel inside a new JFrame.
     */
     public static void main(String[] args) {
         JFrame frame = new JFrame();
         frame.getContentPane().add(new ParameterSetViewPanel());
         frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
         frame.pack();
         frame.setVisible(true);
     }
     
}
