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

import gov.nasa.kepler.hibernate.pi.Group;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.pi.TriggerDefinition;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.common.GroupsDialog;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.kepler.ui.ons.outline.DefaultOutlineModel;
import gov.nasa.kepler.ui.ons.outline.Outline;
import gov.nasa.kepler.ui.ons.outline.OutlineModel;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;
import gov.nasa.kepler.ui.proxy.TriggerDefinitionCrudProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.LinkedList;
import java.util.List;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.WindowConstants;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.TreePath;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 */
@SuppressWarnings("serial")
public class OpsTriggersPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(OpsTriggersPanel.class);

    private JScrollPane tableScrollPane;
    private JPopupMenu triggerTablePopupMenu;
    private JMenuItem editMenuItem;
    private JButton refreshButton;
    private JMenuItem deleteMenuItem;
    private JMenuItem cloneMenuItem;
    private JButton fireButton;
    private JButton newButton;
    private JPanel buttonPanel;

    private OutlineModel triggersOutlineModel;
    private TriggersTreeModel triggersTreeModel;

    private int selectedModelRow;

    private Outline triggersOutline;

    private JMenuItem groupAssignMenuItem;

    private JButton collapseAllButton;
    private JButton expandAllButton;

    public OpsTriggersPanel() {
        super();
        initGUI();
    }

    private void expandAllButtonActionPerformed(ActionEvent evt) {
        log.debug("expandAllButton.actionPerformed, event="+evt);
        
        DefaultMutableTreeNode rootNode = triggersTreeModel.getRootNode();
        int numKids = rootNode.getChildCount();
        for (int kidIndex = 0; kidIndex < numKids; kidIndex++) {
            DefaultMutableTreeNode kid = (DefaultMutableTreeNode) rootNode.getChildAt(kidIndex);
            triggersOutline.expandPath(new TreePath(kid.getPath()));
        }
    }
    
    private void collapseAllButtonActionPerformed(ActionEvent evt) {
        log.debug("collapseAllButton.actionPerformed, event="+evt);
        
        DefaultMutableTreeNode rootNode = triggersTreeModel.getRootNode();
        int numKids = rootNode.getChildCount();
        for (int kidIndex = 0; kidIndex < numKids; kidIndex++) {
            DefaultMutableTreeNode kid = (DefaultMutableTreeNode) rootNode.getChildAt(kidIndex);
            triggersOutline.collapsePath(new TreePath(kid.getPath()));
        }
    }

    private void newButtonActionPerformed(ActionEvent evt) {
        log.debug("newButtonActionPerformed(ActionEvent) - start");

        log.debug("newButton.actionPerformed, event=" + evt);

        try {
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        } catch (PigSecurityException e) {
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        NewTriggerDialog newTriggerDialog = new NewTriggerDialog(PipelineConsole.instance);
        newTriggerDialog.setVisible(true);

        if (!newTriggerDialog.isCancelled()) {
            String triggerName = newTriggerDialog.getTriggerName();
            PipelineDefinition pipelineDefinition = newTriggerDialog.getPipelineDefinition();

            PipelineOperationsProxy pipelineOps = new PipelineOperationsProxy();

            /*
             * PipelineOperationsProxy.createTrigger() will create the
             * TriggerDefinition & associated classes, but will not persist it.
             * It only gets persisted if the user clicks 'save' on the
             * EditTriggerDialog
             */

            TriggerDefinition trigger = pipelineOps.createTrigger(triggerName, pipelineDefinition);

            EditTriggerDialog editDialog = new EditTriggerDialog(PipelineConsole.instance, trigger, triggersTreeModel);
            editDialog.setVisible(true);

            try {
                triggersTreeModel.loadFromDatabase();
            } catch (PipelineException e) {
                log.error("newButtonActionPerformed(ActionEvent)", e);

                PipelineConsole.showError(this, e);
            }
        }

        log.debug("newButtonActionPerformed(ActionEvent) - end");
    }

    private void fireButtonActionPerformed(ActionEvent evt) {
        log.debug("fireButtonActionPerformed(ActionEvent) - start");

        try {
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_OPERATIONS);
        } catch (PigSecurityException e) {
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        int selectedRow = triggersOutline.getSelectedRow();
        int modelIndex = triggersOutline.convertRowIndexToModel(selectedRow);
        TriggerDefinition trigger = null;
        if (selectedRow != -1) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode) triggersOutlineModel.getValueAt(modelIndex, 0);
            Object userObject = node.getUserObject();
            if(userObject instanceof TriggerDefinition){
                trigger = (TriggerDefinition) userObject;
            }
        }

        if (trigger != null) {
            FireTriggerDialog fireTriggerDialog = new FireTriggerDialog(PipelineConsole.instance, trigger);
            fireTriggerDialog.setVisible(true); // modal, blocks until user
            // dismisses
        }

        log.debug("fireButtonActionPerformed(ActionEvent) - end");
    }

    private void triggerTableMouseClicked(MouseEvent evt) {
        log.debug("triggerTableMouseClicked(MouseEvent) - start");

        log.debug("triggerTable.mouseClicked, event=" + evt);

        if (evt.getClickCount() == 2) {
            log.debug("[DOUBLE-CLICK] table.mouseClicked, event=" + evt);
            selectedModelRow = triggersOutline.convertRowIndexToModel(triggersOutline.rowAtPoint(evt.getPoint()));

            log.debug("table row =" + selectedModelRow);

            doEdit(selectedModelRow);
        }

        log.debug("triggerTableMouseClicked(MouseEvent) - end");
    }

    private void doEdit(int popupRow) {
        log.debug("doEdit(int) - start");

        try {
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        } catch (PigSecurityException e) {
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        int selectedRow = triggersOutline.getSelectedRow();
        int modelIndex = triggersOutline.convertRowIndexToModel(selectedRow);
        if (selectedRow != -1) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode) triggersOutlineModel.getValueAt(modelIndex, 0);
            Object userObject = node.getUserObject();
            if(userObject instanceof TriggerDefinition){
                TriggerDefinition trigger = (TriggerDefinition) userObject;
                EditTriggerDialog editDialog = new EditTriggerDialog(PipelineConsole.instance, trigger, triggersTreeModel);
                editDialog.setVisible(true);

                try {
                    triggersTreeModel.loadFromDatabase();
                } catch (Exception e) {
                    log.error("showEditDialog(User)", e);

                    JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        }

        log.debug("doEdit(int) - end");
    }

    private void editMenuItemActionPerformed(ActionEvent evt) {
        log.debug("editMenuItem.actionPerformed, event=" + evt);

        doEdit(selectedModelRow);
    }

    private void cloneMenuItemActionPerformed(ActionEvent evt) {
        log.debug("cloneMenuItem.actionPerformed, event=" + evt);

        try {
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        } catch (PigSecurityException e) {
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        int selectedRow = triggersOutline.getSelectedRow();
        int modelIndex = triggersOutline.convertRowIndexToModel(selectedRow);
        if (selectedRow != -1) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode) triggersOutlineModel.getValueAt(modelIndex, 0);
            Object userObject = node.getUserObject();
            if(userObject instanceof TriggerDefinition){
                TriggerDefinition trigger = (TriggerDefinition) node.getUserObject();
                TriggerDefinition clonedTrigger = new TriggerDefinition(trigger);

                EditTriggerDialog editDialog = new EditTriggerDialog(PipelineConsole.instance, clonedTrigger,
                    triggersTreeModel);
                editDialog.setVisible(true);

                try {
                    triggersTreeModel.loadFromDatabase();
                } catch (Exception e) {
                    log.error("showEditDialog(User)", e);

                    JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        }
    }

    private void deleteMenuItemActionPerformed(ActionEvent evt) {
        log.debug("deleteMenuItem.actionPerformed, event=" + evt);

        try {
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        } catch (PigSecurityException e) {
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            return;
        }

        int selectedRow = triggersOutline.getSelectedRow();
        int modelIndex = triggersOutline.convertRowIndexToModel(selectedRow);
        TriggerDefinition trigger = null;
        if (selectedRow != -1) {
            DefaultMutableTreeNode node = (DefaultMutableTreeNode) triggersOutlineModel.getValueAt(modelIndex, 0);
            Object userObject = node.getUserObject();
            
            if(userObject instanceof TriggerDefinition){
                trigger = (TriggerDefinition) userObject;
            }
        }

        if (trigger != null) {
            int choice = JOptionPane.showConfirmDialog(this, "Are you sure you want to delete trigger: = "
                + trigger.getName() + "?");

            if (choice == JOptionPane.YES_OPTION) {
                try {
                    TriggerDefinitionCrudProxy triggerCrud = new TriggerDefinitionCrudProxy();
                    triggerCrud.delete(trigger);
                    triggersTreeModel.loadFromDatabase();

                } catch (Exception e) {
                    log.debug("caught e = ", e);
                    JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
                }
            }
        }
    }

    private void refreshButtonActionPerformed(ActionEvent evt) {
        log.debug("refreshButton.actionPerformed, event=" + evt);
        try {
            triggersTreeModel.loadFromDatabase();
        } catch (Exception e) {
            log.debug("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private void groupAssignMenuItemActionPerformed(ActionEvent evt) {
        log.debug("groupAssignMenuItem.actionPerformed, event=" + evt);
        
        doGroup();
    }

    private List<TriggerDefinition> getSelectedTriggers(){
        List<TriggerDefinition> selectedTriggers = new LinkedList<TriggerDefinition>();
        
        int[] selectedRows = triggersOutline.getSelectedRows();

        for (int selectedRow : selectedRows) {
            if(selectedRow >= 0){
                int modelIndex = triggersOutline.convertRowIndexToModel(selectedRow);
                DefaultMutableTreeNode node = (DefaultMutableTreeNode) triggersOutlineModel.getValueAt(modelIndex, 0);
                Object userObject = node.getUserObject();
                if(userObject instanceof TriggerDefinition){
                    TriggerDefinition trigger = (TriggerDefinition) userObject;
                    
                    selectedTriggers.add(trigger);
                }
            }
        }
        
        return selectedTriggers;
    }
    
    private void doGroup() {
        log.debug("doGroup() - start");
            
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        try {
            Group group = GroupsDialog.selectGroup(PipelineConsole.instance);
            
            if(group != null){
                List<TriggerDefinition> selectedTriggers = getSelectedTriggers();
                
                for (TriggerDefinition trigger : selectedTriggers) {
                    if(group == Group.DEFAULT_GROUP){
                        trigger.setGroup(null);
                    }else{
                        trigger.setGroup(group);
                    }
                }
                
                TriggerDefinitionCrudProxy triggerCrud = new TriggerDefinitionCrudProxy();
                triggerCrud.saveChanges();
                
                triggersTreeModel.loadFromDatabase();
            }
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doGroup() - end");
    }
    
    
    private void initGUI() {
        log.debug("initGUI() - start");

        try {
            BorderLayout thisLayout = new BorderLayout();
            this.setLayout(thisLayout);
            setPreferredSize(new Dimension(400, 300));
            this.add(getTableScrollPane(), BorderLayout.CENTER);
            this.add(getButtonPanel(), BorderLayout.NORTH);
        } catch (Exception e) {
            log.error("initGUI()", e);

            e.printStackTrace();
        }

        log.debug("initGUI() - end");
    }

    private JScrollPane getTableScrollPane() {
        log.debug("getTableScrollPane() - start");

        if (tableScrollPane == null) {
            tableScrollPane = new JScrollPane();
            tableScrollPane.setViewportView(getTriggersOutline());
        }

        log.debug("getTableScrollPane() - end");
        return tableScrollPane;
    }

    private JPanel getButtonPanel() {
        log.debug("getButtonPanel() - start");

        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(20);
            buttonPanelLayout.setAlignment(FlowLayout.LEFT);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getNewButton());
            buttonPanel.add(getFireButton());
            buttonPanel.add(getRefreshButton());
            buttonPanel.add(getExpandAllButton());
            buttonPanel.add(getCollapseAllButton());
        }

        log.debug("getButtonPanel() - end");
        return buttonPanel;
    }

    private Outline getTriggersOutline() {
        if (triggersOutline == null) {

            triggersTreeModel = new TriggersTreeModel();
            TriggersRowModel triggersRowModel = new TriggersRowModel(triggersTreeModel);
            triggersOutlineModel = DefaultOutlineModel.createOutlineModel(triggersTreeModel, triggersRowModel,
                false, "Trigger Name");

            triggersOutline = new Outline();
            //triggersOutline.setRootVisible(false);
            triggersOutline.setModel(triggersOutlineModel);
            triggersTreeModel.setTriggersOutline(triggersOutline);
            //triggersOutline.setRenderDataProvider(new RenderData());
            DefaultMutableTreeNode defaultGroupNode = triggersTreeModel.getDefaultGroupNode();
            if(defaultGroupNode != null){
                triggersOutline.expandPath(new TreePath(defaultGroupNode.getPath()));
            }

            setComponentPopupMenu(triggersOutline, getTriggerTablePopupMenu());
            triggersOutline.addMouseListener(new MouseAdapter() {
                public void mouseClicked(MouseEvent evt) {
                    log.debug("mouseClicked(MouseEvent) - start");

                    triggerTableMouseClicked(evt);

                    log.debug("mouseClicked(MouseEvent) - end");
                }
            });
        }
        return triggersOutline;
    }

    private JButton getNewButton() {
        log.debug("getNewButton() - start");

        if (newButton == null) {
            newButton = new JButton();
            newButton.setText("New");
            newButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    newButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getNewButton() - end");
        return newButton;
    }

    private JButton getFireButton() {
        log.debug("getFireButton() - start");

        if (fireButton == null) {
            fireButton = new JButton();
            fireButton.setText("Fire");
            fireButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    fireButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getFireButton() - end");
        return fireButton;
    }

    private JPopupMenu getTriggerTablePopupMenu() {
        if (triggerTablePopupMenu == null) {
            triggerTablePopupMenu = new JPopupMenu();
            triggerTablePopupMenu.add(getEditMenuItem());
            triggerTablePopupMenu.add(getDeleteMenuItem());
            triggerTablePopupMenu.add(getCloneMenuItem());
            triggerTablePopupMenu.add(getGroupAssignMenuItem());
        }
        return triggerTablePopupMenu;
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
                selectedModelRow = table.convertRowIndexToModel(selectedTableRow);

                log.debug("selectedTableRow = " + selectedTableRow);
                log.debug("selectedModelRow = " + selectedModelRow);
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }
        });
    }

    private JMenuItem getEditMenuItem() {
        if (editMenuItem == null) {
            editMenuItem = new JMenuItem();
            editMenuItem.setText("Edit Trigger Parameters...");
            editMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    editMenuItemActionPerformed(evt);
                }
            });
        }
        return editMenuItem;
    }

    private JMenuItem getDeleteMenuItem() {
        if (deleteMenuItem == null) {
            deleteMenuItem = new JMenuItem();
            deleteMenuItem.setText("Delete Trigger...");
            deleteMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    deleteMenuItemActionPerformed(evt);
                }
            });
        }
        return deleteMenuItem;
    }

    private JButton getRefreshButton() {
        if (refreshButton == null) {
            refreshButton = new JButton();
            refreshButton.setText("Refresh");
            refreshButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    refreshButtonActionPerformed(evt);
                }
            });
        }
        return refreshButton;
    }

    private JMenuItem getCloneMenuItem() {
        if (cloneMenuItem == null) {
            cloneMenuItem = new JMenuItem();
            cloneMenuItem.setText("Clone Trigger...");
            cloneMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cloneMenuItemActionPerformed(evt);
                }
            });
        }
        return cloneMenuItem;
    }

    private JMenuItem getGroupAssignMenuItem() {
        if (groupAssignMenuItem == null) {
            groupAssignMenuItem = new JMenuItem();
            groupAssignMenuItem.setText("Assign Group...");
            groupAssignMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    groupAssignMenuItemActionPerformed(evt);
                }
            });
        }
        return groupAssignMenuItem;
    }

    /**
     * Auto-generated main method to display this JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        log.debug("main(String[]) - start");

        JFrame frame = new JFrame();
        frame.getContentPane()
            .add(new OpsTriggersPanel());
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);

        log.debug("main(String[]) - end");
    }
    
    private JButton getExpandAllButton() {
        if(expandAllButton == null) {
            expandAllButton = new JButton();
            expandAllButton.setText("+");
            expandAllButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    expandAllButtonActionPerformed(evt);
                }
            });
        }
        return expandAllButton;
    }
    
    private JButton getCollapseAllButton() {
        if(collapseAllButton == null) {
            collapseAllButton = new JButton();
            collapseAllButton.setText("-");
            collapseAllButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    collapseAllButtonActionPerformed(evt);
                }
            });
        }
        return collapseAllButton;
    }
}
