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
import gov.nasa.kepler.hibernate.pi.PipelineInstanceFilter;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.ons.etable.EShadedTable;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.kepler.ui.proxy.PipelineExecutorProxy;
import gov.nasa.kepler.ui.proxy.PipelineTaskAttrOpsProxy;
import gov.nasa.kepler.ui.proxy.PipelineTaskCrudProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.Cursor;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.swing.BorderFactory;
import javax.swing.JFrame;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.ListSelectionModel;
import javax.swing.Timer;
import javax.swing.WindowConstants;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@SuppressWarnings("serial")
public class OpsInstancesPanel extends javax.swing.JPanel implements InstancesControlPanelListener,
    TasksControlPanelListener {
    private static final Log log = LogFactory.getLog(OpsInstancesPanel.class);

    private JMenuItem rerunMenuItem;
    private JSeparator instancesPopupSeparator;
    private JMenuItem detailsMenuItem;
    private JMenuItem statisticsMenuItem;
    private JPopupMenu tasksPopupMenu;
    private JMenuItem restartInstanceMenuItem;
    private JPopupMenu instancesPopupMenu;
    private JMenuItem alertsMenuItem;
    private TaskStatusSummaryPanel taskStatusSummaryPanel;
    private JPanel tasksTablePanel;
    private JMenuItem reRunAllFailedTasksMenuItem;

    private InstancesControlPanel instancesControlPanel;
    private JScrollPane instancesTableScrollPane;
    private JScrollPane tasksTableScrollPane;
    private JPanel tasksPanel;
    private JPanel instancesPanel;
    private ETable tasksTable;
    private ETable instancesTable;
    private TasksControlPanel tasksControlPanel;

    private TasksTableModel tasksTableModel;
    private InstancesTableModel instancesTableModel;
    private PipelineInstanceFilter filter;

    private Timer instanceRefreshTimer = null;
    private Timer tasksRefreshTimer = null;

    private int selectedInstanceModelRow = -1;

    private JMenuItem instanceDetailsMenuItem;
    private JMenuItem retrieveLogMenuItem;
    protected List<Integer> selectedTasksIndices = new ArrayList<Integer>();


    public OpsInstancesPanel() {
        filter = new PipelineInstanceFilter();
        initGUI();
    }

    private void reRunAllFailedTasksMenuItemActionPerformed(ActionEvent evt) {
        log.debug("reRunAllFailedTasksMenuItem.actionPerformed, event=" + evt);

        try {
            PipelineInstance selectedInstance = instancesTableModel.getInstanceAt(selectedInstanceModelRow);

            log.debug("selected instance id = " + selectedInstance.getId());

            PipelineTaskCrudProxy taskCrud = new PipelineTaskCrudProxy();
            List<PipelineTask> failedTasks = taskCrud.retrieveAll(selectedInstance, PipelineTask.State.ERROR);

            PipelineTaskAttrOpsProxy attrOps = new PipelineTaskAttrOpsProxy();
            Map<Long, PipelineTaskAttributes> taskAttrs = attrOps.retrieveByInstanceId(selectedInstance.getId());
            
            if (failedTasks.size() > 0) {
                boolean confirmed = ReRunDialog.reRunTasks(PipelineConsole.instance, failedTasks, taskAttrs);
                
                if (confirmed) {
                    PipelineExecutorProxy pipelineExecutor = new PipelineExecutorProxy();
                    // TODO: let the use decide whether doTransitionOnly
                    // should be true
                    
                    log.debug("Rerunning " + failedTasks.size() + " failed tasks");
                    
                    pipelineExecutor.reRunTasks(failedTasks, false);
                }
            } else {
                JOptionPane.showMessageDialog(PipelineConsole.instance,
                    "No failed tasks found for the selected instance!", "Re-run Tasks", JOptionPane.ERROR_MESSAGE);
            }
        } catch (Exception e) {
        	log.error("Failed to re-run tasks, caught: " + e, e);
            JOptionPane.showMessageDialog(PipelineConsole.instance, "caught e = " + e, "Failed to Re-run Tasks",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private PipelineTask getSelectedTask(){
        if(selectedTasksIndices.size() != 1){
            log.debug("Only one task may be selected!");
            return null;
        }

        int selectedIndex = selectedTasksIndices.get(0);
        int selectedModelRow = tasksTable.convertRowIndexToModel(selectedIndex);
        PipelineTask task = tasksTableModel.getPipelineTaskForRow(selectedModelRow);
        
        return task;
    }
    
    private void reRunMenuItemActionPerformed(ActionEvent evt) {
        log.debug("reRunMenuItemActionPerformed(ActionEvent) - reRunMenuItem.actionPerformed, event=" + evt);

        PipelineInstance selectedInstance = instancesTableModel.getInstanceAt(selectedInstanceModelRow);

        try {
            if(selectedTasksIndices.isEmpty()){
                log.debug("No tasks selected");
                return;
            }
            
            List<PipelineTask> failedTasks = new ArrayList<PipelineTask>();
            
            for (int selectedIndex : selectedTasksIndices) {
                int selectedModelRow = tasksTable.convertRowIndexToModel(selectedIndex);
                PipelineTask task = tasksTableModel.getPipelineTaskForRow(selectedModelRow);
                if(task.getState() == PipelineTask.State.ERROR){
                    failedTasks.add(task);
                }
            }

            if(failedTasks.isEmpty()){
                log.debug("Selected tasks contain no ERROR tasks");
                JOptionPane.showMessageDialog(PipelineConsole.instance,
                    "None of the selected tasks are in the ERROR state.", "Re-run Tasks", JOptionPane.ERROR_MESSAGE);
                return;
            }

            PipelineTaskAttrOpsProxy attrOps = new PipelineTaskAttrOpsProxy();
            Map<Long, PipelineTaskAttributes> taskAttrs = attrOps.retrieveByInstanceId(selectedInstance.getId());
            
            boolean confirmed = ReRunDialog.reRunTasks(PipelineConsole.instance, failedTasks, taskAttrs);
            
            if (confirmed) {
                PipelineExecutorProxy pipelineExecutor = new PipelineExecutorProxy();
                // TODO: let the use decide whether doTransitionOnly
                // should be true
                
                log.debug("Rerunning " + failedTasks.size() + " failed tasks");
                
                pipelineExecutor.reRunTasks(failedTasks, false);
            }
        } catch (Exception e) {
            JOptionPane.showMessageDialog(PipelineConsole.instance, "caught e = " + e, "Failed to Re-run Tasks",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private void statisticsMenuItemActionPerformed(ActionEvent evt) {
        log.debug("statisticsMenuItem.actionPerformed, event=" + evt);

        try {
            PipelineInstance selectedInstance = instancesTableModel.getInstanceAt(selectedInstanceModelRow);

            log.debug("selected instance id = " + selectedInstance.getId());

            InstanceStatsDialog.showInstanceStatsDialog(PipelineConsole.instance, selectedInstance);

        } catch (Exception e) {
            JOptionPane.showMessageDialog(PipelineConsole.instance, "caught e = " + e,
                "Failed to retrieve performance stats", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void alertsMenuItemActionPerformed(ActionEvent evt) {
        log.debug("alertsMenuItem.actionPerformed, event=" + evt);

        try {
            PipelineInstance selectedInstance = instancesTableModel.getInstanceAt(selectedInstanceModelRow);
            long id = selectedInstance.getId();

            log.debug("selected instance id = " + id);

            AlertLogDialog.showAlertLogDialog(PipelineConsole.instance, id);

        } catch (Exception e) {
            JOptionPane.showMessageDialog(PipelineConsole.instance, "caught e = " + e, "Failed to Re-run Tasks",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private void instanceDetailsMenuItemActionPerformed(ActionEvent evt) {

        PipelineInstance selectedInstance = instancesTableModel.getInstanceAt(selectedInstanceModelRow);

        log.debug("selected instance id = " + selectedInstance.getId());

        if (selectedInstance != null) {
            InstanceDetailsDialog instanceDetailsDialog = new InstanceDetailsDialog(PipelineConsole.instance,
                selectedInstance);
            instanceDetailsDialog.setVisible(true);
        }
    }

    private void retrieveLogMenuItemActionPerformed(ActionEvent evt) {
        PipelineTask selectedTask = getSelectedTask();

        if (selectedTask != null) {
            try {
                TaskLogDialog.showTaskLog(PipelineConsole.instance, selectedTask);
            } catch (PipelineException e) {
                log.warn("caught e = ", e);
                JOptionPane.showMessageDialog(PipelineConsole.instance, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private void detailsMenuItemActionPerformed(ActionEvent evt) {
        PipelineTask selectedTask = getSelectedTask();

        if (selectedTask != null) {
            try {
                TaskInfoDialog.showTaskInfoDialog(PipelineConsole.instance, selectedTask);
            } catch (PipelineException e) {
                log.warn("caught e = ", e);
                JOptionPane.showMessageDialog(PipelineConsole.instance, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    public void refreshInstanceNowPressed() {
        log.debug("refreshInstanceNowPressed() - start");

        try {
            instancesTableModel.loadFromDatabase();
        } catch (PipelineException e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(PipelineConsole.instance, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

        log.debug("refreshInstanceNowPressed() - end");
    }

    public void autoRefreshInstanceCheckboxChanged(boolean checked, String refreshRate) {
        log.debug("autoRefreshInstanceCheckboxChanged(boolean) - start");

        if (instanceRefreshTimer == null) {
            instanceRefreshTimer = new Timer(1000, new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    refreshInstanceNowPressed();
                }
            });
        }

        resetTimer(instanceRefreshTimer, checked, refreshRate);

        log.debug("autoRefreshInstanceCheckboxChanged(boolean) - end");
    }

    public void refreshTaskNowPressed() {
        try {
            ListSelectionModel lsm = instancesTable.getSelectionModel();
            if (!lsm.isSelectionEmpty()) {
                int selectedRow = lsm.getMinSelectionIndex();
                int selectedModelRow = instancesTable.convertRowIndexToModel(selectedRow);
                tasksTableModel.setPipelineInstance(instancesTableModel.getInstanceAt(selectedModelRow));
                tasksTableModel.loadFromDatabase();
                taskStatusSummaryPanel.update(tasksTableModel);

                int newSize = tasksTableModel.getRowCount();
                tasksTable.setRowSelectionInterval(newSize - 1, newSize - 1);
            }
        } catch (PipelineException e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(PipelineConsole.instance, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void initGUI() {
        log.debug("initGUI() - start");

        try {
            GridBagLayout thisLayout = new GridBagLayout();
            thisLayout.columnWeights = new double[] { 0.1, 0.1 };
            thisLayout.columnWidths = new int[] { 7, 7 };
            thisLayout.rowWeights = new double[] { 0.1 };
            thisLayout.rowHeights = new int[] { 7 };
            this.setLayout(thisLayout);
            this.setPreferredSize(new java.awt.Dimension(1000, 700));
            this.add(getInstancesPanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            this.add(getTasksPanel(), new GridBagConstraints(1, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));

        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

        log.debug("initGUI() - end");
    }

    private InstancesControlPanel getInstancesControlPanel() {
        log.debug("getInstancesControlPanel() - start");

        if (instancesControlPanel == null) {
            instancesControlPanel = new InstancesControlPanel(filter);
            instancesControlPanel.setListener(this);
        }

        log.debug("getInstancesControlPanel() - end");
        return instancesControlPanel;
    }

    private TasksControlPanel getTasksControlPanel() {
        log.debug("getInstanceNodesControlPanel() - start");

        if (tasksControlPanel == null) {
            tasksControlPanel = new TasksControlPanel();
            tasksControlPanel.setListener(this);
        }

        log.debug("getInstanceNodesControlPanel() - end");
        return tasksControlPanel;
    }

    private ETable getInstancesTable() {
        log.debug("getInstancesTable() - start");

        if (instancesTable == null) {
            instancesTableModel = new InstancesTableModel(filter);
            instancesTableModel.register();

            instancesTable = new EShadedTable();
            instancesTable.getSelectionModel()
                .setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            instancesTable.setModel(instancesTableModel);
            instancesTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
            setComponentPopupMenu(instancesTable, getInstancesPopupMenu());

            ListSelectionModel rowSM = instancesTable.getSelectionModel();
            rowSM.addListSelectionListener(new ListSelectionListener() {
                public void valueChanged(ListSelectionEvent event) {
                    log.debug("valueChanged(ListSelectionEvent) - start");

                    try {
                        // Ignore extra messages.
                        if (event.getValueIsAdjusting()) {
                            log.debug("valueChanged(ListSelectionEvent) - end");
                            return;
                        }

                        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

                        ListSelectionModel lsm = instancesTable.getSelectionModel();
                        if (lsm.isSelectionEmpty()) {
                            tasksTableModel.setPipelineInstance(null);
                            tasksTableModel.loadFromDatabase();
                            taskStatusSummaryPanel.update(tasksTableModel);
                        } else {
                            int selectedRow = lsm.getMinSelectionIndex();
                            int modelIndex = instancesTable.convertRowIndexToModel(selectedRow);
                            tasksTableModel.setPipelineInstance(instancesTableModel.getInstanceAt(modelIndex));
                            tasksTableModel.loadFromDatabase();
                            taskStatusSummaryPanel.update(tasksTableModel);
                        }

                        setCursor(null);

                    } catch (Exception e) {
                        log.warn("caught e = ", e);
                        JOptionPane.showMessageDialog(PipelineConsole.instance, e, "Error", JOptionPane.ERROR_MESSAGE);
                    }

                    log.debug("valueChanged(ListSelectionEvent) - end");
                }
            });
        }

        log.debug("getInstancesTable() - end");
        return instancesTable;
    }

    private ETable getTasksTable() {
        log.debug("getInstanceNodesTable() - start");

        if (tasksTable == null) {
            tasksTableModel = new TasksTableModel();
            tasksTableModel.register();

            tasksTable = new EShadedTable();
            ListSelectionModel selectionModel = tasksTable.getSelectionModel();
            selectionModel.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
            selectionModel.addListSelectionListener(new ListSelectionListener(){
                @Override
                public void valueChanged(ListSelectionEvent e) {
                    ListSelectionModel lsm = (ListSelectionModel)e.getSource();

                    if(!lsm.getValueIsAdjusting()){
                        selectedTasksIndices = new ArrayList<Integer>();
                        
                        if(lsm.isSelectionEmpty()) {
                            log.debug("empty selection");
                        } else {
                            // Find out which indexes are selected. 
                            // Works for multiple_interval_selection too
                            int selectedTasksMinIndex = lsm.getMinSelectionIndex();
                            int selectedTasksMaxIndex = lsm.getMaxSelectionIndex();
                            int count = 0;
                            for (int i = selectedTasksMinIndex; i <= selectedTasksMaxIndex; i++) {
                                if (lsm.isSelectedIndex(i)) {
                                    log.debug("selected index: " + i);
                                    selectedTasksIndices.add(i);
                                    count++;
                                }
                            }
                            log.debug("Num selected: " + count);
                        }
                    }
                }
            });
            
            tasksTable.setModel(tasksTableModel);
            
            //setComponentPopupMenu(tasksTable, getTasksPopupMenu());
            getTasksPopupMenu();
            tasksTable.addMouseListener(new java.awt.event.MouseAdapter() {
                public void mousePressed(java.awt.event.MouseEvent e) {
                    
                    int numTasksSelected = selectedTasksIndices.size();
                    if(numTasksSelected == 1){
                        detailsMenuItem.setEnabled(true);
                        rerunMenuItem.setEnabled(true);
                        retrieveLogMenuItem.setEnabled(true);
                    }else{
                        detailsMenuItem.setEnabled(false);
                        rerunMenuItem.setEnabled(true);
                        retrieveLogMenuItem.setEnabled(false);
                    }
                    
                    if (numTasksSelected > 0 && e.isPopupTrigger()) {
                        tasksPopupMenu.show(tasksTable, e.getX(), e.getY());
                    }
                }

                public void mouseReleased(java.awt.event.MouseEvent e) {
//                    if (e.isPopupTrigger()){
//                        tasksPopupMenu.show(tasksTable, e.getX(), e.getY());
//                    }
                }
            });

//            tasksTable.addMouseListener(new MouseAdapter() {
//                public void mouseClicked(MouseEvent evt) {
//                    tableMouseClicked(evt, tasksTable);
//                }
//            });
        }

        log.debug("getInstanceNodesTable() - end");
        return tasksTable;
    }

//    private void tableMouseClicked(MouseEvent evt, ETable table) {
//        log.debug("tableMouseClicked(MouseEvent) - start");
//
//        if (evt.getClickCount() == 2) {
//            log.debug("tableMouseClicked(MouseEvent) - [DOUBLE-CLICK] table.mouseClicked, event=" + evt);
//            int tableRow = table.rowAtPoint(evt.getPoint());
//            selectedModelRow = table.convertRowIndexToModel(tableRow);
//            log.debug("tableMouseClicked(MouseEvent) - [DC] table row =" + selectedModelRow);
//
//            /* TODO: do default action */
//            // doEdit(selectedModelRow);
//        }
//
//        log.debug("tableMouseClicked(MouseEvent) - end");
//    }

    private JPanel getInstancesPanel() {
        log.debug("getInstancesPanel() - start");

        if (instancesPanel == null) {
            instancesPanel = new JPanel();
            BorderLayout instancesPanelLayout = new BorderLayout();
            instancesPanel.setLayout(instancesPanelLayout);
            instancesPanel.setBorder(BorderFactory.createTitledBorder("Pipeline Instances"));
            instancesPanel.add(getInstancesControlPanel(), BorderLayout.NORTH);
            instancesPanel.add(getInstancesTableScrollPane(), BorderLayout.CENTER);
        }

        log.debug("getInstancesPanel() - end");
        return instancesPanel;
    }

    private JPanel getTasksPanel() {
        log.debug("getInstanceNodesPanel() - start");

        if (tasksPanel == null) {
            tasksPanel = new JPanel();
            BorderLayout instanceNodesPanelLayout = new BorderLayout();
            tasksPanel.setLayout(instanceNodesPanelLayout);
            tasksPanel.setBorder(BorderFactory.createTitledBorder("Pipeline Tasks"));
            tasksPanel.add(getTasksControlPanel(), BorderLayout.NORTH);
            tasksPanel.add(getTasksTablePanel(), BorderLayout.CENTER);
        }

        log.debug("getInstanceNodesPanel() - end");
        return tasksPanel;
    }

    private JScrollPane getTasksTableScrollPane() {
        log.debug("getInstanceNodesTableScrollPane() - start");

        if (tasksTableScrollPane == null) {
            tasksTableScrollPane = new JScrollPane();
            tasksTableScrollPane.setViewportView(getTasksTable());
        }

        log.debug("getInstanceNodesTableScrollPane() - end");
        return tasksTableScrollPane;
    }

    private JScrollPane getInstancesTableScrollPane() {
        log.debug("getInstancesTableScrollPane() - start");

        if (instancesTableScrollPane == null) {
            instancesTableScrollPane = new JScrollPane();
            instancesTableScrollPane.setViewportView(getInstancesTable());
        }

        log.debug("getInstancesTableScrollPane() - end");
        return instancesTableScrollPane;
    }

    public void autoRefreshTaskCheckboxChanged(boolean checked, String refreshRate) {
        log.debug("autoRefreshInstanceNodeCheckboxChanged(boolean) - start");

        if (tasksRefreshTimer == null) {
            tasksRefreshTimer = new Timer(1000, new ActionListener() {
                public void actionPerformed(ActionEvent e) {
                    refreshTaskNowPressed();
                }
            });
        }

        resetTimer(tasksRefreshTimer, checked, refreshRate);

        log.debug("autoRefreshInstanceNodeCheckboxChanged(boolean) - end");
    }

    private void resetTimer(Timer timer, boolean checked, String refreshRate) {
        if (checked) {
            if (timer.isRunning()) {
                timer.stop();
            }

            try {
                int delay = Integer.parseInt(refreshRate);

                timer.setDelay(delay * 1000);
                timer.start();

            } catch (NumberFormatException e) {
                JOptionPane.showMessageDialog(PipelineConsole.instance, "Invalid refresh rate: " + refreshRate
                    + " is not a number", "Invalid refresh rate", JOptionPane.ERROR_MESSAGE);
                return;
            }
        } else { // not checked
            if (timer != null) {
                timer.stop();
            }
        }
    }

    private JPopupMenu getInstancesPopupMenu() {
        if (instancesPopupMenu == null) {
            instancesPopupMenu = new JPopupMenu();
            instancesPopupMenu.add(getInstanceDetailsMenuItem());
            instancesPopupMenu.add(getAlertsMenuItem());
            instancesPopupMenu.add(getStatisticsMenuItem());
            instancesPopupMenu.add(getInstancesPopupSeparator());
            // instancesPopupMenu.add(getRestartInstanceMenuItem());
            instancesPopupMenu.add(getReRunAllFailedTasksMenuItem());
        }
        return instancesPopupMenu;
    }

    @SuppressWarnings("unused")
    private JMenuItem getRestartInstanceMenuItem() {
        if (restartInstanceMenuItem == null) {
            restartInstanceMenuItem = new JMenuItem();
            restartInstanceMenuItem.setText("Restart...");
        }
        return restartInstanceMenuItem;
    }

    private JMenuItem getInstanceDetailsMenuItem() {
        if (instanceDetailsMenuItem == null) {
            instanceDetailsMenuItem = new JMenuItem();
            instanceDetailsMenuItem.setText("Details...");
            instanceDetailsMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    instanceDetailsMenuItemActionPerformed(evt);
                }
            });
        }
        return instanceDetailsMenuItem;
    }

    /**
     * Auto-generated method for setting the popup menu for a component
     */
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger()) {
                    menu.show(parent, e.getX(), e.getY());
                }
                ETable table = (ETable) parent;
                int selectedTableRow = table.rowAtPoint(e.getPoint());
                // windows bug? works ok on Linux/gtk. Here's a workaround:
                if (selectedTableRow == -1) {
                    selectedTableRow = table.getSelectedRow();
                }
                selectedInstanceModelRow = table.convertRowIndexToModel(selectedTableRow);
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }
        });
    }

    private JPopupMenu getTasksPopupMenu() {
        if (tasksPopupMenu == null) {
            tasksPopupMenu = new JPopupMenu();
            tasksPopupMenu.add(getDetailsMenuItem());
            tasksPopupMenu.add(getRerunMenuItem());
            tasksPopupMenu.add(getRetrieveLogMenuItem());
        }
        return tasksPopupMenu;
    }

    private JMenuItem getRerunMenuItem() {
        if (rerunMenuItem == null) {
            rerunMenuItem = new JMenuItem();
            rerunMenuItem.setText("Re-run");
            rerunMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    reRunMenuItemActionPerformed(evt);
                }
            });
        }
        return rerunMenuItem;
    }

    private JMenuItem getRetrieveLogMenuItem() {
        if (retrieveLogMenuItem == null) {
            retrieveLogMenuItem = new JMenuItem();
            retrieveLogMenuItem.setText("Retrieve log from worker");
            retrieveLogMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    retrieveLogMenuItemActionPerformed(evt);
                }
            });
        }
        return retrieveLogMenuItem;
    }

    /**
     * Auto-generated main method to display this JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        log.debug("main(String[]) - start");

        JFrame frame = new JFrame();
        frame.getContentPane()
            .add(new OpsInstancesPanel());
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);

        log.debug("main(String[]) - end");
    }

    private JMenuItem getReRunAllFailedTasksMenuItem() {
        if (reRunAllFailedTasksMenuItem == null) {
            reRunAllFailedTasksMenuItem = new JMenuItem();
            reRunAllFailedTasksMenuItem.setText("Re-run all failed tasks...");
            reRunAllFailedTasksMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    reRunAllFailedTasksMenuItemActionPerformed(evt);
                }
            });
        }
        return reRunAllFailedTasksMenuItem;
    }

    private JPanel getTasksTablePanel() {
        if (tasksTablePanel == null) {
            tasksTablePanel = new JPanel();
            BorderLayout jPanel1Layout = new BorderLayout();
            tasksTablePanel.setLayout(jPanel1Layout);
            tasksTablePanel.add(getTasksTableScrollPane(), BorderLayout.CENTER);
            tasksTablePanel.add(getTaskStatusSummaryPanel(), BorderLayout.NORTH);
        }
        return tasksTablePanel;
    }

    private TaskStatusSummaryPanel getTaskStatusSummaryPanel() {
        if (taskStatusSummaryPanel == null) {
            taskStatusSummaryPanel = new TaskStatusSummaryPanel();
        }
        return taskStatusSummaryPanel;
    }

    private JMenuItem getAlertsMenuItem() {
        if (alertsMenuItem == null) {
            alertsMenuItem = new JMenuItem();
            alertsMenuItem.setText("Alerts...");
            alertsMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    alertsMenuItemActionPerformed(evt);
                }
            });
        }
        return alertsMenuItem;
    }

    private JSeparator getInstancesPopupSeparator() {
        if (instancesPopupSeparator == null) {
            instancesPopupSeparator = new JSeparator();
        }
        return instancesPopupSeparator;
    }

    private JMenuItem getStatisticsMenuItem() {
        if (statisticsMenuItem == null) {
            statisticsMenuItem = new JMenuItem();
            statisticsMenuItem.setText("Performance Statistics...");
            statisticsMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    statisticsMenuItemActionPerformed(evt);
                }
            });
        }
        return statisticsMenuItem;
    }

    private JMenuItem getDetailsMenuItem() {
        if (detailsMenuItem == null) {
            detailsMenuItem = new JMenuItem();
            detailsMenuItem.setText("Task Details...");
            detailsMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    detailsMenuItemActionPerformed(evt);
                }
            });
        }
        return detailsMenuItem;
    }
}
