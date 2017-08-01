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

package gov.nasa.kepler.ui.common;

import gov.nasa.kepler.hibernate.pi.Group;
import gov.nasa.kepler.ui.proxy.GroupCrudProxy;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class GroupsDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(GroupsDialog.class);

    private JPanel dataPanel;
    private JPanel addRemovePanel;
    private JPanel defaultPanel;
    private JCheckBox defaultCheckBox;
    private JButton removeButton;
    private JButton addButton;
    private JTextField newGroupTextField;
    private JList groupsList;
    private JScrollPane groupsScrollPane;
    private JButton cancelButton;
    private JButton okButton;
    private JPanel buttonPanel;
    private GenericListModel<Group> groupsListModel;
    private GroupCrudProxy groupCrud;
    private boolean isCancelled = false;
    private boolean defaultSelected = false;
    
    public GroupsDialog(JFrame frame) {
        super(frame, true);
        initGUI();
        
        groupCrud = new GroupCrudProxy();
        loadFromDatabase();
    }

    public GroupsDialog(JDialog owner) {
        super(owner, true);
    }

    public static Group selectGroup(Component owner){
        Window ownerWindow = findParentWindow(owner);

        GroupsDialog editor;
        if (ownerWindow instanceof JFrame) {
            editor = new GroupsDialog((JFrame) ownerWindow);
        } else {
            editor = new GroupsDialog((JDialog) ownerWindow);
        }

        editor.setVisible(true);
        
        if(!editor.isCancelled){
            if(editor.defaultCheckBox.isSelected()){
                return Group.DEFAULT_GROUP;
            }else{
                return editor.getSelectedGroup();
            }
        }else{
            return null;
        }
    }
    
    public boolean isDefaultSelected() {
        return defaultSelected;
    }

    private void loadFromDatabase(String selectedName){
        loadFromDatabase();
        
        List<Group> groups = groupsListModel.getList();
        int index = 0;
        
        for (Group group : groups) {
            if(group.getName().equals(selectedName)){
                groupsList.setSelectedIndex(index);
            }
            index++;
        }
    }
    
    private void loadFromDatabase(){
        List<Group> groups = groupCrud.retrieveAll();
        groupsListModel.setList(groups);
    }
        
    private void defaultCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("defaultCheckBox.actionPerformed, event="+evt);
        
        groupsList.clearSelection();
    }
    
    private void groupsListValueChanged(ListSelectionEvent evt) {
        log.debug("groupsList.valueChanged, event="+evt);
        
        defaultCheckBox.setSelected(groupsList.getSelectedIndex() == -1);
    }
    
    private void okButtonActionPerformed(ActionEvent evt) {
        log.debug("okButton.actionPerformed, event=" + evt);

        setVisible(false);
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event=" + evt);
        
        isCancelled = true;
        setVisible(false);
    }

    private void addButtonActionPerformed(ActionEvent evt) {
        log.debug("addButton.actionPerformed, event=" + evt);
        
        addGroup();
    }

    private void newGroupTextFieldActionPerformed(ActionEvent evt) {
        log.debug("newGroupTextField.actionPerformed, event="+evt);
        
        addGroup();
    }

    private void addGroup(){
        try{
            String groupName = newGroupTextField.getText();
            if(groupName != null && groupName.length() > 0){
                List<Group> currentList = groupsListModel.getList();
                Group newGroup = new Group(groupName);
                if(currentList.contains(newGroup)){
                    JOptionPane.showMessageDialog(this, "A group by that name already exists", "Error", JOptionPane.ERROR_MESSAGE);
                }else{
                    groupCrud.save(newGroup);
                    
                    loadFromDatabase(groupName);
                }
            }
        }catch(Exception e){
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void removeButtonActionPerformed(ActionEvent evt) {
        log.debug("removeButton.actionPerformed, event=" + evt);

        try{
            Group group = getSelectedGroup();
            if(group != null){
                groupCrud.delete(group);
                loadFromDatabase();
            }
        }catch(Exception e){
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private Group getSelectedGroup(){
        int selectedIndex = groupsList.getSelectedIndex();
        if(selectedIndex >= 0){
            return groupsListModel.get(selectedIndex); 
        }else{
            return null;
        }
    }
    
    private static Window findParentWindow(Component c) {
        Component root = c;

        while (!(root instanceof JFrame) && !(root instanceof JDialog)) {
            root = root.getParent();
            if (root == null) {
                return null;
            }
        }
        return (Window) root;
    }

    private void initGUI() {
        try {
            {
                this.setTitle("Select Group");
            }
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            this.setSize(269, 412);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getAddRemovePanel(), BorderLayout.SOUTH);
            dataPanel.add(getGroupsScrollPane(), BorderLayout.CENTER);
            dataPanel.add(getDefaultPanel(), BorderLayout.NORTH);
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

    private JPanel getAddRemovePanel() {
        if (addRemovePanel == null) {
            addRemovePanel = new JPanel();
            GridBagLayout addRemovePanelLayout = new GridBagLayout();
            addRemovePanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1 };
            addRemovePanelLayout.rowHeights = new int[] { 7, 7, 7, 7 };
            addRemovePanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            addRemovePanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 };
            addRemovePanel.setLayout(addRemovePanelLayout);
            addRemovePanel.setBorder(BorderFactory.createTitledBorder("add/remove group"));
            addRemovePanel.add(getNewGroupTextField(), new GridBagConstraints(0, 1, 8, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            addRemovePanel.add(getAddButton(), new GridBagConstraints(8, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            addRemovePanel.add(getRemoveButton(), new GridBagConstraints(9, 1, 1, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return addRemovePanel;
    }

    private JScrollPane getGroupsScrollPane() {
        if (groupsScrollPane == null) {
            groupsScrollPane = new JScrollPane();
            groupsScrollPane.setViewportView(getGroupsList());
        }
        return groupsScrollPane;
    }

    private JList getGroupsList() {
        if (groupsList == null) {
            groupsListModel = new GenericListModel<Group>();
            groupsList = new JList();
            groupsList.setModel(groupsListModel);
            groupsList.addListSelectionListener(new ListSelectionListener() {
                public void valueChanged(ListSelectionEvent evt) {
                    groupsListValueChanged(evt);
                }
            });
        }
        return groupsList;
    }

    private JTextField getNewGroupTextField() {
        if (newGroupTextField == null) {
            newGroupTextField = new JTextField();
            newGroupTextField.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    newGroupTextFieldActionPerformed(evt);
                }
            });
        }
        return newGroupTextField;
    }

    private JButton getAddButton() {
        if (addButton == null) {
            addButton = new JButton();
            addButton.setText("+");
            addButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    addButtonActionPerformed(evt);
                }
            });
        }
        return addButton;
    }

    private JButton getRemoveButton() {
        if (removeButton == null) {
            removeButton = new JButton();
            removeButton.setText("-");
            removeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    removeButtonActionPerformed(evt);
                }
            });
        }
        return removeButton;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrame frame = new JFrame();
                GroupsDialog inst = new GroupsDialog(frame);
                inst.setVisible(true);
            }
        });
    }
    
    private JPanel getDefaultPanel() {
        if(defaultPanel == null) {
            defaultPanel = new JPanel();
            FlowLayout defaultPanelLayout = new FlowLayout();
            defaultPanelLayout.setAlignment(FlowLayout.LEFT);
            defaultPanel.setLayout(defaultPanelLayout);
            defaultPanel.add(getDefaultCheckBox());
        }
        return defaultPanel;
    }
    
    private JCheckBox getDefaultCheckBox() {
        if(defaultCheckBox == null) {
            defaultCheckBox = new JCheckBox();
            defaultCheckBox.setText("default group");
            defaultCheckBox.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    defaultCheckBoxActionPerformed(evt);
                }
            });
        }
        return defaultCheckBox;
    }
}
