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

package gov.nasa.kepler.ui.config.group;

import gov.nasa.kepler.hibernate.pi.Group;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.proxy.GroupCrudProxy;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Prompt the user for a group selection.
 * Also provides the ability to add/remove groups.
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class GroupSelectorDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(GroupSelectorDialog.class);

    private boolean cancelled = false;
    private JPanel dataPanel;
    private JScrollPane groupListScrollPane;
    private JButton removeGroupButton;
    private JButton addGroupButton;
    private JPanel groupListEditPanel;
    private JList groupList;
    private JButton cancelButton;
    private JButton selectButton;
    private JPanel actionPanel;

    private GroupListModel groupListModel;

    public GroupSelectorDialog(JFrame frame) {
        super(frame, true);
        initGUI();
    }

    public static Group selectGroup(){
        GroupSelectorDialog dialog = new GroupSelectorDialog(PipelineConsole.instance);
        dialog.setVisible(true); // blocks until user presses a button

        if (!dialog.cancelled ) {
            return dialog.getSelectedGroup();
        } else {
            return null;
        }
    }
    
    public Group getSelectedGroup() {
        int selectedIndex = groupList.getSelectedIndex();
        
        if(selectedIndex != -1){
            return (Group) groupListModel.getElementAt(selectedIndex);
        }else{
            return null;
        }
    }

    private void selectButtonActionPerformed(ActionEvent evt) {
        log.debug("selectButton.actionPerformed, event="+evt);

        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        
        cancelled = true;
        
        setVisible(false);
    }
    
    
    private void addGroupButtonActionPerformed(ActionEvent evt) {
        log.debug("addGroupButton.actionPerformed, event="+evt);
        
        try {
            String newGroupName = (String)JOptionPane.showInputDialog(
                PipelineConsole.instance, "Enter the name for the new Group",
                "New Group",
                JOptionPane.PLAIN_MESSAGE);
            
            if(newGroupName == null || newGroupName.length() == 0){
                JOptionPane.showMessageDialog( this, "Please enter a group name", "Error", JOptionPane.ERROR_MESSAGE );
                return;
            }

            Group group = new Group(newGroupName);
            
            GroupCrudProxy groupCrud = new GroupCrudProxy();
            groupCrud.save(group);
            
            groupListModel.loadFromDatabase();
            
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
        
    }
    
    private void removeGroupButtonActionPerformed(ActionEvent evt) {
        log.debug("removeGroupButton.actionPerformed, event="+evt);
        
        
    }

    private void initGUI() {
        try {
            {
                this.setTitle("Select Group");
            }
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            this.setSize(229, 377);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrame frame = new JFrame();
                GroupSelectorDialog inst = new GroupSelectorDialog(frame);
                inst.setVisible(true);
            }
        });
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getGroupListScrollPane(), BorderLayout.CENTER);
            dataPanel.add(getGroupListEditPanel(), BorderLayout.EAST);
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(40);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getSelectButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getSelectButton() {
        if(selectButton == null) {
            selectButton = new JButton();
            selectButton.setText("Select");
            selectButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    selectButtonActionPerformed(evt);
                }
            });
        }
        return selectButton;
    }
    
    private JButton getCancelButton() {
        if(cancelButton == null) {
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
    
    private JScrollPane getGroupListScrollPane() {
        if(groupListScrollPane == null) {
            groupListScrollPane = new JScrollPane();
            groupListScrollPane.setViewportView(getGroupList());
        }
        return groupListScrollPane;
    }
    
    private JList getGroupList() {
        if(groupList == null) {
            groupListModel = new GroupListModel(); 
            groupList = new JList();
            groupList.setModel(groupListModel);
        }
        return groupList;
    }
    
    private JPanel getGroupListEditPanel() {
        if(groupListEditPanel == null) {
            groupListEditPanel = new JPanel();
            GridBagLayout groupListEditPanelLayout = new GridBagLayout();
            groupListEditPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
            groupListEditPanelLayout.rowHeights = new int[] {7, 7, 7, 7, 7, 7, 7, 7, 7, 7};
            groupListEditPanelLayout.columnWeights = new double[] {0.1};
            groupListEditPanelLayout.columnWidths = new int[] {7};
            groupListEditPanel.setLayout(groupListEditPanelLayout);
            groupListEditPanel.add(getAddGroupButton(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            groupListEditPanel.add(getRemoveGroupButton(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return groupListEditPanel;
    }
    
    private JButton getAddGroupButton() {
        if(addGroupButton == null) {
            addGroupButton = new JButton();
            addGroupButton.setText("+");
            addGroupButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    addGroupButtonActionPerformed(evt);
                }
            });
        }
        return addGroupButton;
    }
    
    private JButton getRemoveGroupButton() {
        if(removeGroupButton == null) {
            removeGroupButton = new JButton();
            removeGroupButton.setText("-");
            removeGroupButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    removeGroupButtonActionPerformed(evt);
                }
            });
        }
        return removeGroupButton;
    }
}
