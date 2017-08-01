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

package gov.nasa.kepler.ui.config.security;

import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.common.DoubleListDialog;
import gov.nasa.kepler.ui.common.GenericListModel;
import gov.nasa.kepler.ui.proxy.UserCrudProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.LinkedList;
import java.util.List;

import javax.swing.DefaultListModel;
import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.WindowConstants;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@SuppressWarnings("serial")
public class UserEditPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(UserEditPanel.class);

    private JLabel loginLabel;
    private JTextField loginTextField;
    private JTextField nameText;
    private JLabel userLabel;
    private JSeparator rolesSep;
    private JButton privsButton;
    private JButton rolesButton;
    private JLabel metaLabel;
    private JList privsList;
    private JScrollPane privsScollPane;
    private JList rolesList;
    private JScrollPane rolesScrollPane;
    private JPanel actionButtonPanel;
    private JSeparator privsSep;
    private JLabel privsLabel;
    private JLabel rolesLabel;
    private JTextField phoneText;
    private JLabel phoneLabel;
    private JTextField emailText;
    private JLabel emailLabel;
    private JTextField passwd2Text;
    private JLabel passwd2Label;
    private JTextField passwd1Text;
    private JLabel passwd1Label;
    private JSeparator userSep;
    private JLabel nameLabel;
    private User user;
    
    private UserCrudProxy userCrud;

    public UserEditPanel(User user) {
        super();
        this.user = user;
        userCrud = new UserCrudProxy();
        initGUI();
    }

    public UserEditPanel() {
        super();
        this.user = new User();
        userCrud = new UserCrudProxy();
        initGUI();
    }

    public void updateUser() {
        log.debug("updateUser() - start");

        user.setLoginName(loginTextField.getText());
        user.setDisplayName(nameText.getText());
        String password1 = passwd1Text.getText();
        String password2 = passwd2Text.getText();

        if ((password1.length() > 0) || (password2.length() > 0)) {
            if(password1.equals(password2)){
                user.setPassword(password1);
            }else{
                throw new PipelineException("Passwords do not match!");
            }
        }
        user.setEmail(emailText.getText());
        user.setPhone(phoneText.getText());

        log.debug("updateUser() - end");
    }

    private void rolesButtonActionPerformed(ActionEvent evt) {
        log.debug("rolesButtonActionPerformed(ActionEvent) - start");
        try {
            List<Role> currentRoles = user.getRoles();
            List<Role> allRoles = userCrud.retrieveAllRoles();
            List<Role> availableRoles = new LinkedList<Role>();
            for (Role role : allRoles) {
                if (!currentRoles.contains(role)) {
                    availableRoles.add(role);
                }
            }

            DoubleListDialog<Role> roleSelectionDialog = new DoubleListDialog<Role>(PipelineConsole.instance,
                "Roles for " + user.getDisplayName(), "Available Roles", availableRoles, "Selected Roles", currentRoles);
            roleSelectionDialog.setVisible(true);

            if (roleSelectionDialog.wasSavePressed()) {
                List<Role> selectedRoles = roleSelectionDialog.getSelectedListContents();
                // TODO: need to add as Role, not String
                user.setRoles(selectedRoles);
                rolesList.setModel(new GenericListModel<Role>(selectedRoles));
            }

        } catch (Throwable e) {
            log.warn("rolesButtonActionPerformed(ActionEvent)", e);

            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

        log.debug("rolesButtonActionPerformed(ActionEvent) - end");
    }

    private void privsButtonActionPerformed(ActionEvent evt) {
        log.debug("privsButtonActionPerformed(ActionEvent) - start");

        try {
            List<String> currentPrivs = user.getPrivileges();
            List<String> availablePrivs = new LinkedList<String>();
            for (Privilege priv : Privilege.values()) {
                if (!currentPrivs.contains(priv.toString())) {
                    availablePrivs.add(priv.toString());
                }
            }

            DoubleListDialog<String> privSelectionDialog = new DoubleListDialog<String>(PipelineConsole.instance,
                "Privileges for " + user.getDisplayName(), "Available Privileges", availablePrivs,
                "Selected Privileges", currentPrivs);
            privSelectionDialog.setVisible(true);

            if (privSelectionDialog.wasSavePressed()) {
                List<String> selectedPrivs = privSelectionDialog.getSelectedListContents();
                user.setPrivileges(selectedPrivs);
                privsList.setModel(new GenericListModel<String>(selectedPrivs));
            }

        } catch (Throwable e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }

        log.debug("privsButtonActionPerformed(ActionEvent) - end");
    }

    private void initGUI() {
        log.debug("initGUI() - start");

        try {
            GridBagLayout thisLayout = new GridBagLayout(); // rows
            thisLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            thisLayout.columnWidths = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7 };
            thisLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            thisLayout.rowHeights = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7 };
            this.setLayout(thisLayout);
            setPreferredSize(new Dimension(600, 400));
            this.add(getLoginLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getLoginTextField(), new GridBagConstraints(1, 1, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getNameLabel(), new GridBagConstraints(4, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getNameText(), new GridBagConstraints(5, 1, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getUserLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getUserSep(), new GridBagConstraints(1, 0, 7, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPasswd1Label(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPasswd1Text(), new GridBagConstraints(1, 2, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPasswd2Label(), new GridBagConstraints(4, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPasswd2Text(), new GridBagConstraints(5, 2, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getEmailLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getEmailText(), new GridBagConstraints(1, 3, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPhoneLabel(), new GridBagConstraints(4, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPhoneText(), new GridBagConstraints(5, 3, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getRolesLabel(), new GridBagConstraints(0, 4, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getRolesSep(), new GridBagConstraints(1, 4, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPrivsLabel(), new GridBagConstraints(4, 4, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPrivsSep(), new GridBagConstraints(5, 4, 3, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.HORIZONTAL, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getRolesScrollPane(), new GridBagConstraints(1, 5, 3, 4, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPrivsScollPane(), new GridBagConstraints(5, 5, 3, 4, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getMetaLabel(), new GridBagConstraints(0, 10, 9, 1, 0.0, 0.0, GridBagConstraints.LINE_START,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            this.add(getRolesButton(), new GridBagConstraints(2, 9, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getPrivsButton(), new GridBagConstraints(6, 9, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            this.add(getActionButtonPanel(), new GridBagConstraints(2, 9, 5, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        } catch (Exception e) {
            log.error("initGUI()", e);

            e.printStackTrace();
        }

        log.debug("initGUI() - end");
    }

    /**
     * Auto-generated method for setting the popup menu for a component
     */
    @SuppressWarnings("unused")
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        log.debug("setComponentPopupMenu(java.awt.Component, javax.swing.JPopupMenu) - start");

        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                log.debug("mousePressed(java.awt.event.MouseEvent) - start");

                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
                log.debug("mousePressed(java.awt.event.MouseEvent) - end");
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                log.debug("mouseReleased(java.awt.event.MouseEvent) - start");

                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
                log.debug("mouseReleased(java.awt.event.MouseEvent) - end");
            }
        });

        log.debug("setComponentPopupMenu(java.awt.Component, javax.swing.JPopupMenu) - end");
    }

    private JLabel getLoginLabel() {
        log.debug("getLoginLabel() - start");

        if (loginLabel == null) {
            loginLabel = new JLabel();
            loginLabel.setText("Login");
        }

        log.debug("getLoginLabel() - end");
        return loginLabel;
    }

    private JTextField getLoginTextField() {
        log.debug("getLoginTextField() - start");

        if (loginTextField == null) {
            loginTextField = new JTextField();
            loginTextField.setText(user.getLoginName());
        }

        log.debug("getLoginTextField() - end");
        return loginTextField;
    }

    private JLabel getNameLabel() {
        log.debug("getNameLabel() - start");

        if (nameLabel == null) {
            nameLabel = new JLabel();
            nameLabel.setText("Full Name");
        }

        log.debug("getNameLabel() - end");
        return nameLabel;
    }

    private JTextField getNameText() {
        log.debug("getNameText() - start");

        if (nameText == null) {
            nameText = new JTextField();
            nameText.setText(user.getDisplayName());
        }

        log.debug("getNameText() - end");
        return nameText;
    }

    private JLabel getUserLabel() {
        log.debug("getUserLabel() - start");

        if (userLabel == null) {
            userLabel = new JLabel();
            userLabel.setText("User");
            userLabel.setFont(new java.awt.Font("Dialog", 1, 14));
        }

        log.debug("getUserLabel() - end");
        return userLabel;
    }

    private JSeparator getUserSep() {
        log.debug("getUserSep() - start");

        if (userSep == null) {
            userSep = new JSeparator();
        }

        log.debug("getUserSep() - end");
        return userSep;
    }

    private JLabel getPasswd1Label() {
        log.debug("getPasswd1Label() - start");

        if (passwd1Label == null) {
            passwd1Label = new JLabel();
            passwd1Label.setText("Password");
        }

        log.debug("getPasswd1Label() - end");
        return passwd1Label;
    }

    private JTextField getPasswd1Text() {
        log.debug("getPasswd1Text() - start");

        if (passwd1Text == null) {
            passwd1Text = new JPasswordField();
        }

        log.debug("getPasswd1Text() - end");
        return passwd1Text;
    }

    private JLabel getPasswd2Label() {
        log.debug("getPasswd2Label() - start");

        if (passwd2Label == null) {
            passwd2Label = new JLabel();
            passwd2Label.setText("Retype Password");
        }

        log.debug("getPasswd2Label() - end");
        return passwd2Label;
    }

    private JTextField getPasswd2Text() {
        log.debug("getPasswd2Text() - start");

        if (passwd2Text == null) {
            passwd2Text = new JPasswordField();
        }

        log.debug("getPasswd2Text() - end");
        return passwd2Text;
    }

    private JLabel getEmailLabel() {
        log.debug("getEmailLabel() - start");

        if (emailLabel == null) {
            emailLabel = new JLabel();
            emailLabel.setText("Email");
        }

        log.debug("getEmailLabel() - end");
        return emailLabel;
    }

    private JTextField getEmailText() {
        log.debug("getEmailText() - start");

        if (emailText == null) {
            emailText = new JTextField();
            emailText.setText(user.getEmail());
        }

        log.debug("getEmailText() - end");
        return emailText;
    }

    private JLabel getPhoneLabel() {
        log.debug("getPhoneLabel() - start");

        if (phoneLabel == null) {
            phoneLabel = new JLabel();
            phoneLabel.setText("Phone");
        }

        log.debug("getPhoneLabel() - end");
        return phoneLabel;
    }

    private JTextField getPhoneText() {
        log.debug("getPhoneText() - start");

        if (phoneText == null) {
            phoneText = new JTextField();
            phoneText.setText(user.getPhone());
        }

        log.debug("getPhoneText() - end");
        return phoneText;
    }

    private JLabel getRolesLabel() {
        log.debug("getRolesLabel() - start");

        if (rolesLabel == null) {
            rolesLabel = new JLabel();
            rolesLabel.setText("Roles");
            rolesLabel.setFont(new java.awt.Font("Dialog", 1, 14));
        }

        log.debug("getRolesLabel() - end");
        return rolesLabel;
    }

    private JSeparator getRolesSep() {
        log.debug("getRolesSep() - start");

        if (rolesSep == null) {
            rolesSep = new JSeparator();
        }

        log.debug("getRolesSep() - end");
        return rolesSep;
    }

    private JLabel getPrivsLabel() {
        log.debug("getPrivsLabel() - start");

        if (privsLabel == null) {
            privsLabel = new JLabel();
            privsLabel.setText("Privileges");
            privsLabel.setFont(new java.awt.Font("Dialog", 1, 14));
        }

        log.debug("getPrivsLabel() - end");
        return privsLabel;
    }

    private JSeparator getPrivsSep() {
        log.debug("getPrivsSep() - start");

        if (privsSep == null) {
            privsSep = new JSeparator();
        }

        log.debug("getPrivsSep() - end");
        return privsSep;
    }

    private JScrollPane getRolesScrollPane() {
        log.debug("getRolesScrollPane() - start");

        if (rolesScrollPane == null) {
            rolesScrollPane = new JScrollPane();
            rolesScrollPane.setViewportView(getRolesList());
        }

        log.debug("getRolesScrollPane() - end");
        return rolesScrollPane;
    }

    private JList getRolesList() {
        log.debug("getRolesList() - start");

        if (rolesList == null) {
            DefaultListModel rolesListModel = new DefaultListModel();
            for (Role role : user.getRoles()) {
                rolesListModel.addElement(role);
            }
            rolesList = new JList();
            rolesList.setModel(rolesListModel);
            rolesList.setVisibleRowCount(3);
        }

        log.debug("getRolesList() - end");
        return rolesList;
    }

    private JScrollPane getPrivsScollPane() {
        log.debug("getPrivsScollPane() - start");

        if (privsScollPane == null) {
            privsScollPane = new JScrollPane();
            privsScollPane.setViewportView(getPrivsList());
        }

        log.debug("getPrivsScollPane() - end");
        return privsScollPane;
    }

    private JList getPrivsList() {
        log.debug("getPrivsList() - start");

        if (privsList == null) {
            DefaultListModel privsListModel = new DefaultListModel();
            for (String privilege : user.getPrivileges()) {
                privsListModel.addElement(privilege);
            }
            privsList = new JList();
            privsList.setModel(privsListModel);
            privsList.setVisibleRowCount(3);
        }

        log.debug("getPrivsList() - end");
        return privsList;
    }

    private JLabel getMetaLabel() {
        log.debug("getMetaLabel() - start");

        if (metaLabel == null) {
            metaLabel = new JLabel();
            metaLabel.setText("Modified: " + user.getCreated() + " by admin");
            // metaLabel.setText("Modified: 7/1/05 17:55:00 by admin");
            metaLabel.setFont(new java.awt.Font("Dialog", 2, 12));
        }

        log.debug("getMetaLabel() - end");
        return metaLabel;
    }

    private JButton getRolesButton() {
        log.debug("getRolesButton() - start");

        if (rolesButton == null) {
            rolesButton = new JButton();
            rolesButton.setText("edit");
            rolesButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    rolesButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getRolesButton() - end");
        return rolesButton;
    }

    private JButton getPrivsButton() {
        log.debug("getPrivsButton() - start");

        if (privsButton == null) {
            privsButton = new JButton();
            privsButton.setText("edit");
            privsButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    privsButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getPrivsButton() - end");
        return privsButton;
    }

    private JPanel getActionButtonPanel() {
        log.debug("getActionButtonPanel() - start");

        if (actionButtonPanel == null) {
            actionButtonPanel = new JPanel();
            FlowLayout actionButtonPanelLayout = new FlowLayout();
            actionButtonPanelLayout.setHgap(35);
            actionButtonPanel.setLayout(actionButtonPanelLayout);
        }

        log.debug("getActionButtonPanel() - end");
        return actionButtonPanel;
    }

    /**
     * Auto-generated main method to display this JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        log.debug("main(String[]) - start");

        JFrame frame = new JFrame();
        User newUser = new User("user1", "User One", "p1", "user1@nasa.gov", "555-1212");
        Role r1 = new Role("role1");
        r1.addPrivilege(Privilege.PIPELINE_OPERATIONS.toString());
        r1.addPrivilege(Privilege.PIPELINE_MONITOR.toString());
        Role r2 = new Role("role2");
        r2.addPrivilege(Privilege.PIPELINE_OPERATIONS.toString());
        r2.addPrivilege(Privilege.PIPELINE_MONITOR.toString());
        newUser.addRole(r1);
        newUser.addRole(r2);

        frame.getContentPane()
            .add(new UserEditPanel(newUser));
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);

        log.debug("main(String[]) - end");
    }
}
