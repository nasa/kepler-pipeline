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

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes.ProcessingState;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.swing.DefaultCellEditor;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.table.TableCellEditor;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 *   
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
@SuppressWarnings("serial")
public class ReRunDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ReRunDialog.class);

    private JPanel dataPanel;
    private JButton reRunButton;
    private JTable reRunTable;
    private JScrollPane scrollPane;
    private JButton cancelButton;
    private JPanel buttonPanel;
    private ReRunTableModel reRunTableModel;
    private List<PipelineTask> failedTasks;
    private Map<Long, PipelineTaskAttributes> taskAttrs;
    private boolean cancelled = false;
    
    public ReRunDialog(JFrame frame, List<PipelineTask> failedTasks, Map<Long, PipelineTaskAttributes> taskAttrs) {
        super(frame, true);
        
        this.failedTasks = failedTasks;
        this.taskAttrs = taskAttrs;
        
        initGUI();
    }
    
    public static boolean reRunTasks(JFrame frame, List<PipelineTask> failedTasks, Map<Long, PipelineTaskAttributes> taskAttrs){
        ReRunDialog dialog = new ReRunDialog(frame, failedTasks, taskAttrs);
        dialog.setVisible(true); // blocks until user presses a button
        
        if(!dialog.cancelled){
            Map<String, ReRunAttributes> moduleMap = dialog.reRunTableModel.getModuleMap();
            
            for (PipelineTask failedTask : failedTasks) {
                String moduleName = failedTask.getModuleName();

                PipelineTaskAttributes attrs = taskAttrs.get(failedTask.getId());
                String pState = ProcessingState.INITIALIZING.toString();
                
                if(attrs != null){
                	pState = attrs.getProcessingState().shortName();
                }

                String key = ReRunAttributes.key(moduleName, pState);

                ReRunAttributes reRunAttrs = moduleMap.get(key);
                failedTask.setRestartMode(reRunAttrs.getSelectedRestartMode());
                
                log.info("Set task " + failedTask.getId() + " restartMode to " + reRunAttrs.getSelectedRestartMode());
            }
            return true;
        }else{
            log.info("Re-run cancelled by user");
            return false;
        }
    }
    
    private void reRunButtonActionPerformed(ActionEvent evt) {
        log.debug("reRunButton.actionPerformed, event="+evt);
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
                this.setTitle("Restart Failed Tasks");
                getContentPane().add(getDataPanel(), BorderLayout.CENTER);
                getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            }
            this.setSize(740, 567);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getScrollPane(), BorderLayout.CENTER);
        }
        return dataPanel;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(100);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getReRunButton());
            buttonPanel.add(getCancelButton());
        }
        return buttonPanel;
    }
    
    private JButton getReRunButton() {
        if(reRunButton == null) {
            reRunButton = new JButton();
            reRunButton.setText("Re-Run");
            reRunButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    reRunButtonActionPerformed(evt);
                }
            });
        }
        return reRunButton;
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
    
    private JScrollPane getScrollPane() {
        if(scrollPane == null) {
            scrollPane = new JScrollPane();
            scrollPane.setViewportView(getReRunTable());
        }
        return scrollPane;
    }
    
    private JTable getReRunTable() {
        if (reRunTable == null) {

            reRunTableModel = new ReRunTableModel(failedTasks, taskAttrs);
            
            List<ReRunAttributes> modules = reRunTableModel.getModuleList();
            final List<TableCellEditor> editors = new ArrayList<TableCellEditor>();

            for (ReRunAttributes module : modules) {
                JComboBox comboBox1 = new JComboBox(module.getRestartModes());
                DefaultCellEditor dce1 = new DefaultCellEditor(comboBox1);
                editors.add(dce1);
            }

            reRunTable = new JTable(reRunTableModel) {
                // Determine editor to be used by row
                public TableCellEditor getCellEditor(int row, int column) {
                    int modelColumn = convertColumnIndexToModel(column);

                    if (modelColumn == 3)
                        return editors.get(row);
                    else
                        return super.getCellEditor(row, column);
                }
            };
        }
        return reRunTable;
    }

    /**
     * @return the cancelled
     */
    public boolean isCancelled() {
        return cancelled;
    }
}
