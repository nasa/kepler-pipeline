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
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.kepler.ui.proxy.PipelineTaskCrudProxy;
import gov.nasa.kepler.ui.proxy.WorkerOperationsProxy;
import gov.nasa.spiffy.common.lang.StringUtils;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class TaskLogDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(TaskLogDialog.class);

    private static final long serialVersionUID = -8926788606491576183L;

    private JPanel textPanel;
    private JButton copyFilesButton;
    private JButton bugReportButton;
    private JButton refreshButton;
    private JPanel upperButtonPanel;
    private JLabel taskLogLabel;
    private JPanel labelPanel;
    private JTextArea textArea;
    private JScrollPane textScrollPane;
    private JButton closeButton;
    private JPanel actionPanel;

    private PipelineTask task = null;

    private long instanceId;

    private long taskId;

    public TaskLogDialog(JFrame frame) {
        this(frame, null);
    }

    public TaskLogDialog(JFrame frame, PipelineTask task) {
        super(frame, false);

        this.task = task;

        initGUI();

        refreshContents();
    }

    public static void showTaskLog(JFrame frame, PipelineTask task) {
        TaskLogDialog dialog = new TaskLogDialog(frame, task);

        dialog.setVisible(true);
    }

    private void refreshContents() {
        if (task != null) {
            try {
                // refresh the task object
                PipelineTaskCrudProxy pipelineTaskCrud = new PipelineTaskCrudProxy();
                pipelineTaskCrud.evict(task); // clear the cache
                task = pipelineTaskCrud.retrieve(task.getId());

                instanceId = task.getPipelineInstance()
                    .getId();
                taskId = task.getId();

                log.debug("selected task id = " + taskId);


                String module = task.getPipelineInstanceNode()
                    .getPipelineModuleDefinition()
                    .toString();
                String briefState = task.uowTaskInstance()
                    .briefState();
                String elapsedTime = StringUtils.elapsedTime(task.getStartProcessingTime(), task.getEndProcessingTime());
                State state = task.getState();
                String stateString;

                if (state == State.ERROR) {
                    stateString = "<b><font color=red>" + state + "</font></b>";
                } else {
                    stateString = "<b><font color=green>" + state + "</font></b>";
                }

                String taskLabelText = "<html>  " + "<b>ID:</b> " + instanceId + ":" + taskId + " <b>WORKER:</b> "
                    + task.getWorkerName() + " <b>TASK:</b> " + module + " ([" + briefState + "] " + stateString
                    + " <i>" + elapsedTime + "</i>)</html>";

                taskLogLabel.setText(taskLabelText);
                
                WorkerOperationsProxy workerOps = new WorkerOperationsProxy();
                String taskLogs = workerOps.retrieveTaskLog(task);
                textArea.setText(taskLogs);

            } catch (Exception e) {
                e.printStackTrace();
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }

    private void refreshButtonActionPerformed(ActionEvent evt) {
        log.debug("refreshButton.actionPerformed, event=" + evt);

        refreshContents();
    }

    private void copyFilesButtonActionPerformed(ActionEvent evt) {
        log.debug("copyFilesButtonActionPerformed.actionPerformed, event=" + evt);

        CopyTaskFilesDialog.copyTaskFiles(this, task);
    }

    private void bugReportButtonActionPerformed(ActionEvent evt) {
        log.debug("bugReportButton.actionPerformed, event=" + evt);
    }

    private void initGUI() {
        try {
            BorderLayout thisLayout = new BorderLayout();
            this.setTitle("Task Log");
            getContentPane().setLayout(thisLayout);
            getContentPane().add(getTextPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            getContentPane().add(getLabelPanel(), BorderLayout.NORTH);
            this.setSize(1192, 879);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JPanel getTextPanel() {
        if (textPanel == null) {
            textPanel = new JPanel();
            BorderLayout textPanelLayout = new BorderLayout();
            textPanel.setLayout(textPanelLayout);
            textPanel.add(getTextScrollPane(), BorderLayout.CENTER);
        }
        return textPanel;
    }

    private JPanel getActionPanel() {
        if (actionPanel == null) {
            actionPanel = new JPanel();
            actionPanel.add(getCloseButton());
        }
        return actionPanel;
    }

    private JButton getCloseButton() {
        if (closeButton == null) {
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

    private void closeButtonActionPerformed(ActionEvent evt) {
        setVisible(false);
    }

    private JScrollPane getTextScrollPane() {
        if (textScrollPane == null) {
            textScrollPane = new JScrollPane();
            textScrollPane.setViewportView(getTextArea());
        }
        return textScrollPane;
    }

    private JTextArea getTextArea() {
        if (textArea == null) {
            textArea = new JTextArea();
            textArea.setEditable(false);
        }
        return textArea;
    }

    private JPanel getLabelPanel() {
        if (labelPanel == null) {
            labelPanel = new JPanel();
            GridBagLayout labelPanelLayout = new GridBagLayout();
            labelPanelLayout.rowWeights = new double[] { 0.1 };
            labelPanelLayout.rowHeights = new int[] {};
            labelPanelLayout.columnWeights = new double[] { 0.1 };
            labelPanelLayout.columnWidths = new int[] { 7 };
            labelPanel.setLayout(labelPanelLayout);
            labelPanel.add(getTaskLogLabel(), new GridBagConstraints(0, 0, 2, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 10, 0, 0), 0, 0));
            labelPanel.add(getUpperButtonPanel(), new GridBagConstraints(3, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        }
        return labelPanel;
    }

    private JLabel getTaskLogLabel() {
        if (taskLogLabel == null) {
            taskLogLabel = new JLabel();
        }
        return taskLogLabel;
    }

    /**
     * Auto-generated main method to display this JDialog
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                JFrame frame = new JFrame();
                TaskLogDialog inst = new TaskLogDialog(frame);
                inst.setVisible(true);
            }
        });
    }

    private JPanel getUpperButtonPanel() {
        if (upperButtonPanel == null) {
            upperButtonPanel = new JPanel();
            FlowLayout upperButtonPanelLayout = new FlowLayout();
            upperButtonPanelLayout.setHgap(20);
            upperButtonPanelLayout.setAlignment(FlowLayout.RIGHT);
            upperButtonPanel.setLayout(upperButtonPanelLayout);
            upperButtonPanel.add(getRefreshButton());
            upperButtonPanel.add(getCopyFilesButton());
            upperButtonPanel.add(getBugReportButton());
        }
        return upperButtonPanel;
    }

    private JButton getRefreshButton() {
        if (refreshButton == null) {
            refreshButton = new JButton();
            refreshButton.setText("refresh");
            refreshButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    refreshButtonActionPerformed(evt);
                }
            });
        }
        return refreshButton;
    }

    private JButton getBugReportButton() {
        if (bugReportButton == null) {
            bugReportButton = new JButton();
            bugReportButton.setText("bug report");
            bugReportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    bugReportButtonActionPerformed(evt);
                }
            });
        }
        return bugReportButton;
    }

    private JButton getCopyFilesButton() {
        if (copyFilesButton == null) {
            copyFilesButton = new JButton();
            copyFilesButton.setText("Copy Task Files");
            copyFilesButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    copyFilesButtonActionPerformed(evt);
                }
            });
        }
        return copyFilesButton;
    }
}
