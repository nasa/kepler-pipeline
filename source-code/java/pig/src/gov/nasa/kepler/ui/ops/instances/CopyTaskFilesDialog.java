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

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.pi.worker.WorkerPipelineProcess;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirRequest;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirResponse;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.common.MessageDialog;
import gov.nasa.kepler.ui.common.ProgressMonitor;
import gov.nasa.kepler.ui.common.ProgressUtil;
import gov.nasa.kepler.ui.proxy.PipelineProcessAdminProxy;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;

import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class CopyTaskFilesDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(CopyTaskFilesDialog.class);

    private static final String DEFAULT_DEST_DIR = "/path/to/";

    protected static final long REQUEST_TIMEOUT_MILLIS = 60*60*1000; // 1hr

    private JPanel dataPanel;
    private JTextField destDirTextField;
    private JLabel destDirLabel;
    private JButton cancelButton;
    private JButton okButton;
    private JPanel buttonPanel;

    private PipelineTask pipelineTask = null;
    private long instanceId;
    private long taskId;

    public CopyTaskFilesDialog(JDialog parent, PipelineTask pipelineTask) {
        super(parent, true);
        this.pipelineTask = pipelineTask;
        this.instanceId = pipelineTask.getPipelineInstance().getId();
        this.taskId = pipelineTask.getId();
        
        initGUI();
    }
    
    public static void copyTaskFiles(JDialog parent, PipelineTask pipelineTask){
        
        CopyTaskFilesDialog d = new CopyTaskFilesDialog(parent, pipelineTask);
        d.setVisible(true);
    }
    
    private void okButtonActionPerformed(ActionEvent evt) {
        log.debug("okButton.actionPerformed, event="+evt);

        new Thread(new Runnable() {
            @Override
            public void run() {
                
                String destDir = destDirTextField.getText();
                WorkerTaskWorkingDirResponse response = null;
                ProgressMonitor monitor = ProgressUtil.createModalProgressMonitor(PipelineConsole.instance, 100, true, 100); 
                
                monitor.start("Copying files from worker to " + destDir + " ..."); 
                
                try {
                    PipelineProcessAdminProxy ops = new PipelineProcessAdminProxy();

                    response = (WorkerTaskWorkingDirResponse) ops.adminRequest(
                        WorkerPipelineProcess.NAME, pipelineTask.getWorkerHost(), new WorkerTaskWorkingDirRequest(instanceId, taskId,
                            new File(destDir)), REQUEST_TIMEOUT_MILLIS);

                } finally {
                    // close the progress dialog
                    monitor.setCompleted(); 
                    
                    MessageDialog.showMessageDialog(PipelineConsole.instance, "Worker Response: " + response.getStatus());

                    // Close the CopyTaskFilesDialog
                    SwingUtilities.invokeLater(new Runnable(){
                        public void run(){
                            setVisible(false);
                        }
                    });
                }
            }
        }).start();
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);
        setVisible(false);
    }
    
    private void initGUI() {
        try {
            {
                this.setTitle("Copy task files from worker");
            }
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
            this.setSize(541, 143);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            FlowLayout dataPanelLayout = new FlowLayout();
            dataPanelLayout.setVgap(25);
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getDestDirLabel());
            dataPanel.add(getDestDirTextField());
        }
        return dataPanel;
    }
    
    private JPanel getButtonPanel() {
        if(buttonPanel == null) {
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
        if(okButton == null) {
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
        if(cancelButton == null) {
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
    
    private JLabel getDestDirLabel() {
        if(destDirLabel == null) {
            destDirLabel = new JLabel();
            destDirLabel.setText("Destination directory: ");
        }
        return destDirLabel;
    }
    
    private JTextField getDestDirTextField() {
        if(destDirTextField == null) {
            destDirTextField = new JTextField();
            destDirTextField.setText(DEFAULT_DEST_DIR);
            destDirTextField.setColumns(30);
        }
        return destDirTextField;
    }
}
