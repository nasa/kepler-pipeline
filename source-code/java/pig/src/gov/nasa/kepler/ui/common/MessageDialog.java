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

import java.awt.BorderLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Display a String message in a scrollable JTextArea
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class MessageDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(MessageDialog.class);

    private JPanel dataPanel;
    private JTextArea messageTextArea;
    private JScrollPane textAreaScrollPane;
    private JButton closeButton;
    private JPanel buttonPanel;

    private String message = "";
    
    public MessageDialog(JFrame parent, String message) {
        super(parent, true);
        this.message = message;
        
        initGUI();
    }
    
    public MessageDialog(JDialog parent, String message) {
        super(parent, true);
        this.message = message;
        
        initGUI();
    }
    
    public static void showMessageDialog(JFrame parent, String message){
        MessageDialog d = new MessageDialog(parent, message);
        d.setVisible(true);
    }
    
    public static void showMessageDialog(JDialog parent, String message){
        MessageDialog d = new MessageDialog(parent, message);
        d.setVisible(true);
    }
    
    private void closeButtonActionPerformed(ActionEvent evt) {
        log.debug("closeButton.actionPerformed, event="+evt);
        
        setVisible(false);
    }
    
    private void initGUI() {
        try {
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            setSize(400, 300);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getTextAreaScrollPane(), BorderLayout.CENTER);
        }
        return dataPanel;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            buttonPanel.add(getCloseButton());
        }
        return buttonPanel;
    }
    
    private JButton getCloseButton() {
        if(closeButton == null) {
            closeButton = new JButton();
            closeButton.setText("close");
            closeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    closeButtonActionPerformed(evt);
                }
            });
        }
        return closeButton;
    }
    
    private JScrollPane getTextAreaScrollPane() {
        if(textAreaScrollPane == null) {
            textAreaScrollPane = new JScrollPane();
            textAreaScrollPane.setViewportView(getMessageTextArea());
        }
        return textAreaScrollPane;
    }
    
    private JTextArea getMessageTextArea() {
        if(messageTextArea == null) {
            messageTextArea = new JTextArea(message);
        }
        return messageTextArea;
    }

}
