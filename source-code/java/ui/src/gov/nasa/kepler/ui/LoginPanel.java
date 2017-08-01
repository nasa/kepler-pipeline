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

package gov.nasa.kepler.ui;

import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.services.security.SecurityOperations;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.ToolPanel;

import java.awt.Color;
import java.awt.Dimension;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Image;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.Arrays;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;
import javax.swing.KeyStroke;
import javax.swing.LayoutStyle.ComponentPlacement;

import org.jdesktop.application.Action;

/**
 * A panel used for logging in. Use {@link #login()} to create a modal dialog
 * and return the user that logged in.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class LoginPanel extends ToolPanel {

    private static final String NAME = "loginPanel";

    private static final String CHECK_LOGIN = "checkLogin";
    private static final String SELECT = "select";
    private static final String CANCEL = "cancel";

    private String[] actionStrings = new String[] { DEFAULT_ACTION_CHAR
        + SELECT };

    private static final int FIELD_WIDTH = 10;
    private static final int MAX_TRIES = 3;

    private Image image;
    private JLabel errLabel;
    private JLabel label;
    private JTextField login;
    private JPasswordField password;
    private JButton cancelButton;
    private JButton checkLogin;

    private SecurityOperations securityOperations;
    private String username;

    private int count;
    private User user;

    /**
     * Creates a {@link LoginPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public LoginPanel() throws UiException {
        securityOperations = new SecurityOperations();

        createUi();
    }

    @Override
    protected void initComponents() throws UiException {
        errLabel = new JLabel();
        errLabel.setName("errLabel");

        label = new JLabel();
        label.setName("label");

        login = new JTextField(FIELD_WIDTH);
        password = new JPasswordField(FIELD_WIDTH);

        cancelButton = new JButton(actionMap.get(CANCEL));
        checkLogin = new JButton(actionMap.get(CHECK_LOGIN)); // not visible

        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        layout.setAutoCreateContainerGaps(true);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addGroup(
                layout.createParallelGroup()
                    .addComponent(errLabel)
                    .addComponent(label)
                    .addComponent(login, GroupLayout.DEFAULT_SIZE,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                    .addComponent(password, GroupLayout.DEFAULT_SIZE,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(cancelButton));

        layout.setVerticalGroup(layout.createSequentialGroup()

            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)

            .addComponent(errLabel)

            .addPreferredGap(ComponentPlacement.UNRELATED)

            .addComponent(label)

            .addGroup(
                layout.createParallelGroup(Alignment.BASELINE)

                    .addComponent(login, GroupLayout.DEFAULT_SIZE,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                    .addComponent(password, GroupLayout.DEFAULT_SIZE,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
                    .addComponent(cancelButton)));
    }

    @Override
    protected void configureComponents() throws UiException {
        image = resourceMap.getImageIcon(NAME + ".image")
            .getImage();
        Dimension size = new Dimension(image.getWidth(null),
            image.getHeight(null));
        setPreferredSize(size);
        setMinimumSize(size);
        setMaximumSize(size);
        setSize(size);

        errLabel.setForeground(Color.WHITE);

        label.setFont(label.getFont()
            .deriveFont(Font.BOLD));
        label.setForeground(Color.WHITE);
        // TODO Doesn't seem to work here
        label.setFocusable(false);

        setDefaultFocusComponent(login);
        login.getDocument()
            .addDocumentListener(updateDocumentListener);
        password.setVisible(false);
        password.getDocument()
            .addDocumentListener(updateDocumentListener);

        // TODO Keep or remove button?
        cancelButton.setVisible(false);
    }

    @Override
    public void initDefaultKeys() {
        super.initDefaultKeys();
        login.getInputMap()
            .put(KeyStroke.getKeyStroke("ENTER"), CHECK_LOGIN);
        login.getActionMap()
            .put(CHECK_LOGIN, actionMap.get(CHECK_LOGIN));
        login.getInputMap()
            .put(KeyStroke.getKeyStroke("ESCAPE"), CANCEL);
        login.getActionMap()
            .put(CANCEL, actionMap.get(CANCEL));
        password.getInputMap()
            .put(KeyStroke.getKeyStroke("ENTER"), CHECK_LOGIN);
        password.getActionMap()
            .put(CHECK_LOGIN, actionMap.get(CHECK_LOGIN));
        password.getInputMap()
            .put(KeyStroke.getKeyStroke("ESCAPE"), CANCEL);
        password.getActionMap()
            .put(CANCEL, actionMap.get(CANCEL));
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actionStrings);
    }

    @Override
    protected JButton getDefaultButton() {
        return checkLogin;
    }

    @Override
    protected void updateEnabled() {
        errLabel.setVisible(false);
    }

    @Override
    public void paintComponent(Graphics g) {
        g.drawImage(image, 0, 0, null);
    }

    /**
     * Displays login window. Returns a {@link User} object all target lists and
     * allows user to select them. A list of these selected lists is returned.
     * 
     * @return a list of {@link TargetList}s
     * @throws UiException if the panel could not be created database
     */
    public static User login() throws UiException {
        JDialog dialog = new JDialog();
        dialog.setName(NAME);
        dialog.setModal(true);
        final LoginPanel panel = new LoginPanel();
        dialog.add(panel);
        dialog.setUndecorated(true);
        dialog.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                panel.dismissDialog();
            }
        });
        panel.initDefaultKeys();
        app.show(dialog);

        return panel.user;
    }

    /**
     * Either changes dialog to accept password, or attempts to validate login
     * information.
     */
    @Action
    public void checkLogin() {
        log.info(resourceMap.getString(CHECK_LOGIN));
        if (label.getText()
            .equals(resourceMap.getString("label.text"))) {
            label.setText(resourceMap.getString("passwordLabel.text"));
            username = login.getText();
            login.setVisible(false);
            password.setVisible(true);
            password.requestFocusInWindow();
        } else {
            try {
                password.setEditable(false);
                if (!securityOperations.validateLogin(username, new String(
                    password.getPassword()))) {
                    log.warn(resourceMap.getString(CHECK_LOGIN + ".invalid",
                        username));
                    if (++count >= MAX_TRIES) {
                        dismissDialog();
                    }
                    try {
                        Thread.sleep(5000);
                    } catch (InterruptedException e) {
                        // Ignore.
                    }
                    password.setEditable(true);
                    password.setText("");
                    password.setVisible(false);
                    label.setText(resourceMap.getString("label.text"));
                    login.setVisible(true);
                    login.requestFocusInWindow();
                    errLabel.setVisible(true);
                } else {
                    log.info(resourceMap.getString(CHECK_LOGIN + ".valid",
                        username));
                    user = securityOperations.getCurrentUser();
                    dismissDialog();
                }
            } catch (Exception e) {
                handleError(this, e, CHECK_LOGIN);
                dismissDialog();
            }
        }
    }

    /**
     * Discards the changes to the target list set.
     */
    @Action
    public void cancel() {
        log.info(resourceMap.getString(CANCEL));
        user = null;
        dismissDialog();
    }
}
