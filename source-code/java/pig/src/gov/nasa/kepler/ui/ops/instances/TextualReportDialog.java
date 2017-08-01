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

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
@SuppressWarnings("serial")
public class TextualReportDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(TextualReportDialog.class);

    private JScrollPane reportTextScrollPane;
    private JButton saveButton;
    private JTextArea reportTextArea;
    private JButton closeButton;
    private JPanel actionPanel;
    private String report = "";
    
    public TextualReportDialog(JFrame owner) {
        super(owner, true);
        
        initGUI();
    }

    public TextualReportDialog(JDialog dialog) {
        super(dialog, true);
        
        initGUI();
    }
    
    public TextualReportDialog(JFrame frame, String report) {
        super(frame, true);
        this.report = report;
        
        initGUI();
    }
    
    public TextualReportDialog(JDialog dialog, String report) {
        super(dialog, true);
        this.report = report;
        
        initGUI();
    }
    
    public static void showReport(JDialog parent, String report){
        TextualReportDialog dialog = new TextualReportDialog(parent, report);
        
        dialog.setVisible(true);
    }

    public static void showReport(JFrame parent, String report){
        TextualReportDialog dialog = new TextualReportDialog(parent, report);
        
        dialog.setVisible(true);
    }

    private void saveButtonActionPerformed(ActionEvent evt) {
        log.debug("saveButton.actionPerformed, event="+evt);
        
        try {
            JFileChooser fc = new JFileChooser();
            int returnVal = fc.showSaveDialog(this);
    
            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                BufferedWriter writer = new BufferedWriter(new FileWriter(file));
                writer.write(report);
                writer.close();
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void closeButtonActionPerformed(ActionEvent evt) {
        setVisible(false);
    }
    
    private void initGUI() {
        try {
            getContentPane().add(getReportTextScrollPane(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            this.setSize(615, 677);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JScrollPane getReportTextScrollPane() {
        if(reportTextScrollPane == null) {
            reportTextScrollPane = new JScrollPane();
            reportTextScrollPane.setViewportView(getReportTextArea());
        }
        return reportTextScrollPane;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(100);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getSaveButton());
            actionPanel.add(getCloseButton());
        }
        return actionPanel;
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
    
    private JTextArea getReportTextArea() {
        if(reportTextArea == null) {
            reportTextArea = new JTextArea();
            reportTextArea.setText(report);
            reportTextArea.setFont(new java.awt.Font("Monospaced",0,12));
        }
        return reportTextArea;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JDialog d = new JDialog();
                 TextualReportDialog inst = new TextualReportDialog(d, "hello!");
                 inst.setVisible(true);
             }
         });
     }
    
    private JButton getSaveButton() {
        if(saveButton == null) {
            saveButton = new JButton();
            saveButton.setText("save to file");
            saveButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    saveButtonActionPerformed(evt);
                }
            });
        }
        return saveButton;
    }
}
