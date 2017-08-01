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

import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.ui.proxy.UserCrudProxy;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.WindowConstants;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@SuppressWarnings("serial")
public class UserEditDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(UserEditDialog.class);

    private UserEditPanel userPanel;
    private User user;
    private JButton cancelButton;
    private JButton saveButton;
    private JPanel buttonPanel;

    private UserCrudProxy userCrud;

    public UserEditDialog(JFrame frame, User user) {
        super(frame, true);
        this.user = user;
        userCrud = new UserCrudProxy();
        initGUI();
    }

    public UserEditDialog(JFrame frame) {
        super(frame, true);
        this.user = new User();
        userCrud = new UserCrudProxy();
        initGUI();
    }

    private void initGUI() {
        log.debug("initGUI() - start");

        try {
            // START >> this
            BorderLayout thisLayout = new BorderLayout();
            this.getContentPane().setLayout(thisLayout);
            this.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
            this.setTitle("Edit User " + user.getDisplayName());
            // END << this
            this.getContentPane().add(getUserPanel(), BorderLayout.CENTER);
            this.getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            this.setSize(700, 483);
        } catch (Exception e) {
            log.error("initGUI()", e);

            e.printStackTrace();
        }

        log.debug("initGUI() - end");
    }

    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButtonActionPerformed(ActionEvent) - start");
        try {
            userPanel.updateUser();
            userCrud.saveUser(user);
            setVisible(false);
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error Saving User", JOptionPane.ERROR_MESSAGE);
        }

        log.debug("saveButtonActionPerformed(ActionEvent) - end");
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButtonActionPerformed(ActionEvent) - start");

        setVisible(false);

        log.debug("cancelButtonActionPerformed(ActionEvent) - end");
    }

    private UserEditPanel getUserPanel() {
        log.debug("getUserPanel() - start");

        if (userPanel == null) {
            userPanel = new UserEditPanel(user);
        }

        log.debug("getUserPanel() - end");
        return userPanel;
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

    private JPanel getButtonPanel() {
        log.debug("getButtonPanel() - start");

        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(40);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getSaveButton());
            buttonPanel.add(getCancelButton());
        }

        log.debug("getButtonPanel() - end");
        return buttonPanel;
    }

    private JButton getSaveButton() {
        log.debug("getSaveButton() - start");

        if (saveButton == null) {
            saveButton = new JButton();
            saveButton.setText("Save Changes");
            saveButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    saveButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getSaveButton() - end");
        return saveButton;
    }

    private JButton getCancelButton() {
        log.debug("getCancelButton() - start");

        if (cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("Cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    cancelButtonActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getCancelButton() - end");
        return cancelButton;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
    public static void main(String[] args) {
        log.debug("main(String[]) - start");

        JFrame frame = new JFrame();
        UserEditDialog inst = new UserEditDialog(frame);
        inst.setVisible(true);

        log.debug("main(String[]) - end");
    }

}
