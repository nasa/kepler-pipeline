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
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.kepler.ui.proxy.PipelineTaskCrudProxy;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class InstanceStatsDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(InstanceStatsDialog.class);

    private JPanel dataPanel;
    private JScrollPane processingBreakdownScrollPane;
    private JButton refreshButton;
    private JScrollPane processingTimeScrollPane;
    private JPanel processingBreakdownPanel;
    private JPanel processingTimePanel;
    private JButton closeButton;
    private JPanel buttonPanel;

    private ETable processingBreakdownTable;
    private ETable processingTimeTable;

    private PipelineInstance pipelineInstance;
    private TaskMetricsTableModel processingBreakdownTableModel;
    private PipelineStatsTableModel processingTimeTableModel;
    private PipelineTaskCrudProxy pipelineTaskCrud = new PipelineTaskCrudProxy();
    private List<PipelineTask> tasks;
    private ArrayList<String> orderedModuleNames;
    
    public InstanceStatsDialog(JFrame frame, PipelineInstance pipelineInstance) {
        super(frame);
        
        this.pipelineInstance = pipelineInstance;

        loadFromDatabase();        
        initGUI();
    }
    
    public static void showInstanceStatsDialog(JFrame frame, PipelineInstance pipelineInstance) {
        InstanceStatsDialog dialog = new InstanceStatsDialog(frame, pipelineInstance);

        dialog.setVisible(true);
    }

    private void loadFromDatabase(){
        tasks = pipelineTaskCrud.retrieveAll(pipelineInstance);
        orderedModuleNames = new ArrayList<String>();
        
        for (PipelineTask task : tasks) {
            String moduleName = task.getPipelineInstanceNode().getPipelineModuleDefinition().getName().getName();
            if(!orderedModuleNames.contains(moduleName)){
                orderedModuleNames.add(moduleName);
            }
        }
    }
    
    private void refreshButtonActionPerformed(ActionEvent evt) {
        log.info("refreshButton.actionPerformed, event="+evt);

        loadFromDatabase();
        updateTables();
    }

    private void updateTables(){        
        processingTimeTableModel.update(tasks, orderedModuleNames);
        processingBreakdownTableModel.update(tasks, orderedModuleNames);
    }
    
    private void closeButtonActionPerformed(ActionEvent evt) {
        log.info("closeButton.actionPerformed, event="+evt);

        setVisible(false);
    }
    
    private void initGUI() {
        try {
            {
                this.setTitle("Pipeline Instance Performance Statistics");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            }
            this.setSize(1280, 500);
        } catch (Exception e) {
            e.printStackTrace();
        }
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
            dataPanel.add(getProcessingTimePanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getProcessingBreakdownPanel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(50);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getRefreshButton());
            buttonPanel.add(getCloseButton());
        }
        return buttonPanel;
    }
    
    private JButton getCloseButton() {
        if(closeButton == null) {
            closeButton = new JButton();
            closeButton.setText("<html><b>close</b></html>");
            closeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    closeButtonActionPerformed(evt);
                }
            });
        }
        return closeButton;
    }
    
    private JPanel getProcessingTimePanel() {
        if(processingTimePanel == null) {
            processingTimePanel = new JPanel();
            BorderLayout processingTimePanelLayout = new BorderLayout();
            processingTimePanel.setLayout(processingTimePanelLayout);
            processingTimePanel.setBorder(BorderFactory.createTitledBorder("Processing Time Statistics"));
            processingTimePanel.add(getProcessingTimeScrollPane(), BorderLayout.CENTER);
        }
        return processingTimePanel;
    }
    
    private JPanel getProcessingBreakdownPanel() {
        if(processingBreakdownPanel == null) {
            processingBreakdownPanel = new JPanel();
            BorderLayout processingBreakdownPanelLayout = new BorderLayout();
            processingBreakdownPanel.setLayout(processingBreakdownPanelLayout);
            processingBreakdownPanel.setBorder(BorderFactory.createTitledBorder("Processing Time Breakdown (completed tasks only)"));
            processingBreakdownPanel.add(getProcessingBreakdownScrollPane(), BorderLayout.CENTER);
        }
        return processingBreakdownPanel;
    }
    
    private JScrollPane getProcessingTimeScrollPane() {
        if(processingTimeScrollPane == null) {
            processingTimeScrollPane = new JScrollPane();
            processingTimeScrollPane.setViewportView(getProcessingTimeTable());
        }
        return processingTimeScrollPane;
    }
    
    private JScrollPane getProcessingBreakdownScrollPane() {
        if(processingBreakdownScrollPane == null) {
            processingBreakdownScrollPane = new JScrollPane();
            processingBreakdownScrollPane.setViewportView(getProcessingBreakdownTable());
        }
        return processingBreakdownScrollPane;
    }
    
    private ETable getProcessingTimeTable() {
        if(processingTimeTable == null) {
            processingTimeTableModel = new PipelineStatsTableModel(tasks, orderedModuleNames);
            processingTimeTable = new ETable();
            processingTimeTable.setModel(processingTimeTableModel);
        }
        return processingTimeTable;
    }
    
    private ETable getProcessingBreakdownTable() {
        if(processingBreakdownTable == null) {
            processingBreakdownTableModel = new TaskMetricsTableModel(tasks, orderedModuleNames, false);
            processingBreakdownTable = new ETable();
            processingBreakdownTable.setModel(processingBreakdownTableModel);
        }
        return processingBreakdownTable;
    }
    
    private JButton getRefreshButton() {
        if(refreshButton == null) {
            refreshButton = new JButton();
            refreshButton.setText("refresh");
            refreshButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    refreshButtonActionPerformed(evt);
                }
            });
        }
        return refreshButton;
    }
}
