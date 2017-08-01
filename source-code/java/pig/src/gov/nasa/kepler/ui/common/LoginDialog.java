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

import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.services.security.SecurityOperations;
import gov.nasa.kepler.ui.PipelineConsole;

import java.awt.BorderLayout;
import java.awt.CardLayout;
import java.awt.Color;
import java.awt.Dimension;
import java.awt.Graphics;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Image;
import java.awt.Insets;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.net.URL;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JPasswordField;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class LoginDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(LoginDialog.class);
    
    private static final String PASSWORD_PANEL = "passwordPanel";
    private static final String USER_NAME_PANEL = "userNamePanel";
    private JPanel backgroundPanel;
    private JLabel errorTextLabel;

    private JPanel actionPanel;
    private JPanel passwordPanel;
    private JPasswordField passwordField;
    private JLabel passwordLabel;
    private JTextField userNameTextField;
    private JLabel userNameLabel;
    private JPanel userNamePanel;
    private CardLayout actionPanelLayout;
    private Image backgroundImage;

    private SecurityOperations securityOperations;
    private User user = null;
    private int loginAttempts = 0;
    private static final int MAX_LOGIN_ATTEMPTS = 3;
    
    public LoginDialog(JFrame frame) {
        super();
        setModal(true);
        initGUI();

        Dimension size = new Dimension(backgroundImage.getWidth(null),
            backgroundImage.getHeight(null));
        setPreferredSize(size);
        setMinimumSize(size);
        setMaximumSize(size);
        setSize(size);
        
        Toolkit toolkit = Toolkit.getDefaultToolkit();
        Dimension screenSize = toolkit.getScreenSize();

        // center the dialog on the screen
        int x = (screenSize.width - getWidth()) / 2;
        int y = (screenSize.height - getHeight()) / 2;
        setLocation(x, y); 
        
        securityOperations = new SecurityOperations();
    }
    
    public static User showLogin(){
        LoginDialog dialog = new LoginDialog(PipelineConsole.instance);
        dialog.setVisible(true); // blocks until user presses a button
        
        User loggedInUser = dialog.getUser();
        return loggedInUser;
    }

    private void userNameTextFieldActionPerformed(ActionEvent evt) {
        log.debug("userNameTextField.actionPerformed, event="+evt);

        actionPanelLayout.show(actionPanel, PASSWORD_PANEL);
        passwordField.requestFocusInWindow();
    }
    
    private void passwordFieldActionPerformed(ActionEvent evt) {
        log.debug("passwordField.actionPerformed, event="+evt);
        
        String enteredUserName = userNameTextField.getText();
        String enteredPassword = new String(passwordField.getPassword());
        
        passwordField.setText("");
        
        boolean loginSuccessful = securityOperations.validateLogin(enteredUserName, enteredPassword);
        
        if(loginSuccessful){
            user = securityOperations.getCurrentUser();
            setVisible(false);
        }else{
            errorTextLabel.setText("Login failed");
            actionPanelLayout.show(actionPanel, USER_NAME_PANEL);
            userNameTextField.requestFocusInWindow();
            
            loginAttempts++;
            if(loginAttempts >= MAX_LOGIN_ATTEMPTS){
                setVisible(false);
            }
        }
    }

    private void initGUI() {
        try {
            {
                URL resource = getClass().getClassLoader().getResource("images/kepler-splash.jpg");
                backgroundImage = new ImageIcon(resource).getImage();
                
                this.setModal(true);
                this.setUndecorated(true);
                BorderLayout thisLayout = new BorderLayout();
                getContentPane().setLayout(thisLayout);
                getContentPane().add(getBackgroundPanel(), BorderLayout.CENTER);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            actionPanelLayout = new CardLayout();
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getUserNamePanel(), USER_NAME_PANEL);
            actionPanel.add(getPasswordPanel(), PASSWORD_PANEL);
            actionPanel.setOpaque(false);
        }
        return actionPanel;
    }
    
    private JPanel getUserNamePanel() {
        if(userNamePanel == null) {
            userNamePanel = new JPanel();
            userNamePanel.add(getUserNameLabel());
            userNamePanel.add(getUserNameTextField());
            userNamePanel.setOpaque(false);
        }
        return userNamePanel;
    }
    
    private JPanel getPasswordPanel() {
        if(passwordPanel == null) {
            passwordPanel = new JPanel();
            passwordPanel.add(getPasswordLabel());
            passwordPanel.add(getPasswordField());
            passwordPanel.setOpaque(false);
        }
        return passwordPanel;
    }
    
    private JLabel getUserNameLabel() {
        if(userNameLabel == null) {
            userNameLabel = new JLabel();
            userNameLabel.setText("Username:");
            userNameLabel.setForeground(Color.WHITE);
        }
        return userNameLabel;
    }
    
    private JTextField getUserNameTextField() {
        if(userNameTextField == null) {
            userNameTextField = new JTextField();
            userNameTextField.setColumns(20);
            userNameTextField.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    userNameTextFieldActionPerformed(evt);
                }
            });
        }
        return userNameTextField;
    }
    
    private JLabel getPasswordLabel() {
        if(passwordLabel == null) {
            passwordLabel = new JLabel();
            passwordLabel.setText("Password:");
            passwordLabel.setForeground(Color.WHITE);
        }
        return passwordLabel;
    }

    private JPasswordField getPasswordField() {
        if(passwordField == null) {
            passwordField = new JPasswordField();
            passwordField.setColumns(20);
            passwordField.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    passwordFieldActionPerformed(evt);
                }
            });
        }
        return passwordField;
    }
    
    private JPanel getBackgroundPanel() {
        if(backgroundPanel == null) {
            backgroundPanel = new JPanel(){
                @Override
                public void paintComponent(Graphics g) {
                    g.drawImage(backgroundImage, 0, 0, null);
                }
            };
            GridBagLayout jPanel1Layout = new GridBagLayout();
            jPanel1Layout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
            jPanel1Layout.rowHeights = new int[] {7, 7, 7, 7, 7, 7, 7, 7, 7, 7};
            jPanel1Layout.columnWeights = new double[] {0.1};
            jPanel1Layout.columnWidths = new int[] {7};
            backgroundPanel.setLayout(jPanel1Layout);
            backgroundPanel.add(getActionPanel(), new GridBagConstraints(0, 9, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            backgroundPanel.add(getErrorTextLabel(), new GridBagConstraints(0, 10, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return backgroundPanel;
    }
    
    private JLabel getErrorTextLabel() {
        if(errorTextLabel == null) {
            errorTextLabel = new JLabel(" ");
            errorTextLabel.setForeground(Color.RED);
        }
        return errorTextLabel;
    }


    public User getUser() {
        return user;
    }
    
    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 LoginDialog inst = new LoginDialog(frame);
                 inst.setVisible(true);
             }
         });
     }
}
