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

package gov.nasa.kepler.ui.mon.master;

import gov.nasa.kepler.pi.worker.WorkerStatusMessage;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.process.ProcessStatusMessage;
import gov.nasa.kepler.services.process.StatusMessage;
import gov.nasa.kepler.services.process.StatusMessageHandler;
import gov.nasa.kepler.services.process.StatusMessageListener;

import java.awt.BorderLayout;
import java.awt.CardLayout;

import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.SwingUtilities;
import javax.swing.WindowConstants;

/**
 * This class provides a color-coded display that provides real-time status of
 * pipeline elements, including active pipelines, pipeline processes, worker
 * threads, metrics, and alerts.
 * 
 * @author tklaus
 * 
 */
public class MasterStatusPanel extends javax.swing.JPanel implements IndicatorListener, StatusMessageHandler {
    private static final long serialVersionUID = 7318171252724116063L;

    private JSplitPane splitPane;
    private IndicatorPanel processesPanel;
    private JPanel detailedPanel;
    private IndicatorPanel parentIndicatorPanel;
    private Indicator workersParent;
    private Indicator instancesParent;
    private Indicator processesParent;
    private Indicator alertsParent;
    private Indicator metricsParent;
    private CardLayout detailedPanelLayout;
    private JScrollPane parentScrollPane;
    private JScrollPane detailedScrollPane;

    private StatusMessageListener statusMessageListener = new StatusMessageListener(MessagingDestinations.PIPELINE_STATUS_DESTINATION);
    private ProcessesStatusPanel workersPanel;
    private IndicatorPanel instancesPanel;

    public MasterStatusPanel() {
        initGUI();

        statusMessageListener.addProcessStatusHandler(this);
        statusMessageListener.start();
    }

    private void initGUI() {
        try {
            setLayout(new BorderLayout());
            this.add(getSplitPane(), BorderLayout.CENTER);
            splitPane.setDividerLocation(0.35);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public JSplitPane getSplitPane() {
        if (splitPane == null) {
            splitPane = new JSplitPane();
            splitPane.add(getParentScrollPane(), JSplitPane.LEFT);
            splitPane.add(getDetailedScrollPane(), JSplitPane.RIGHT);
        }
        return splitPane;
    }

    private JScrollPane getParentScrollPane() {
        if (parentScrollPane == null) {
            parentScrollPane = new JScrollPane();
            parentScrollPane.setViewportView(getParentIndicatorPanel());
        }
        return parentScrollPane;
    }

    private JScrollPane getDetailedScrollPane() {
        if (detailedScrollPane == null) {
            detailedScrollPane = new JScrollPane();
            detailedScrollPane.setViewportView(getDetailedPanel());
        }
        return detailedScrollPane;
    }

    private StatusPanel getParentIndicatorPanel() {
        if (parentIndicatorPanel == null) {
            parentIndicatorPanel = new ParentIndicatorPanel(6, false);

            instancesParent = new Indicator(parentIndicatorPanel, "Pipelines");
            instancesParent.addIndicatorListener(this);
            instancesParent.setState(Indicator.State.GREEN);
            instancesParent.setCategory(Indicator.Category.PIPELINE);

            workersParent = new Indicator(parentIndicatorPanel, "Workers");
            workersParent.addIndicatorListener(this);
            workersParent.setState(Indicator.State.GREEN);
            workersParent.setCategory(Indicator.Category.WORKER);
            
            processesParent = new Indicator(parentIndicatorPanel, "Processes");
            processesParent.addIndicatorListener(this);
            processesParent.setState(Indicator.State.GREEN);
            processesParent.setCategory(Indicator.Category.PROCESS);
            
            alertsParent = new Indicator(parentIndicatorPanel, "Alerts");
            alertsParent.addIndicatorListener(this);
            alertsParent.setState(Indicator.State.GREEN);
            alertsParent.setCategory(Indicator.Category.ALERT);
            
            metricsParent = new Indicator(parentIndicatorPanel, "Metrics");
            metricsParent.addIndicatorListener(this);
            metricsParent.setState(Indicator.State.GREEN);
            metricsParent.setCategory(Indicator.Category.METRIC);

            parentIndicatorPanel.add(instancesParent);
            parentIndicatorPanel.add(workersParent);
            parentIndicatorPanel.add(processesParent);
            parentIndicatorPanel.add(alertsParent);
            parentIndicatorPanel.add(metricsParent);
        }
        return parentIndicatorPanel;
    }

    private JPanel getDetailedPanel() {
        if (detailedPanel == null) {
            detailedPanel = new JPanel();
            detailedPanelLayout = new CardLayout();
            detailedPanel.setLayout(detailedPanelLayout);

            detailedPanel.add(getWorkerPanel(), "workers");
            detailedPanel.add(getInstancesPanel(), "instances");
            detailedPanel.add(getProcessesPanel(), "processes");
        }
        return detailedPanel;
    }

    private StatusPanel getInstancesPanel() {
        if(instancesPanel == null){
            instancesPanel = new InstancesIndicatorPanel(instancesParent, 7, true);
            instancesPanel.setTitle("Active Pipeline Instances");
            
            String ids[] = { "11", "20", "15", "4", "6", "7", "8" };
            String pipelines[] = { "PA", "DIA", "PDC", "TPS", "RLS", "FC", "DV" };
            String tasks[] = { "252/70/2/0", "252/10/2/0", "84/5/2/0", "1700/513/2/0", "1700/102/2/0", "84/5/2/0",
                "5/1/2/0" };

            for (int i = 0; i < 7; i++) {

                PipelineInstanceIndicator p = new PipelineInstanceIndicator(instancesPanel, ids[i]);
                p.setId(ids[i]);
                p.setPipeline(pipelines[i]);
                p.setState("Processing");
                p.setTasks(tasks[i]);
                p.setWorkers("2");
                instancesPanel.add(p);
            }
        }
        return instancesPanel;
    }

    private StatusPanel getWorkerPanel() {
        if(workersPanel == null){
//            workersPanel = new WorkersIndicatorPanel(workersParent, 7, true);
//            workersPanel.setTitle("Worker Threads");
            
            workersPanel = new ProcessesStatusPanel();
        }
        return workersPanel;
    }

    private StatusPanel getProcessesPanel() {
        if (processesPanel == null) {
            processesPanel = new ProcessesIndicatorPanel(processesParent, 7, true);
            processesPanel.setTitle("Processes");

//            Indicator.State states[] = { Indicator.State.GREEN, Indicator.State.GREEN, Indicator.State.AMBER,
//                Indicator.State.GREEN, Indicator.State.GREEN, Indicator.State.GREEN };
//
//            String processes[] = { "worker", "worker", "worker", "worker", "data receipt", "file store" };
//            String hosts[] = { "host1:1", "host2:2", "host3:3", "host4:4", "host5:5", "host6:6" };
//
//            for (int i = 0; i < processes.length; i++) {
//                ProcessIndicator p = new ProcessIndicator(processes[i], hosts[i], "running", "12d 03h 16m 34s");
//                p.setState(states[i]);
//                processesPanel.add(p);
//            }
        }
        return processesPanel;
    }

    public void clicked(Indicator source) {

        if (source == workersParent) {
            detailedPanelLayout.show(detailedPanel, "workers");
        } else if (source == instancesParent) {
            detailedPanelLayout.show(detailedPanel, "instances");
        } else if (source == processesParent) {
            detailedPanelLayout.show(detailedPanel, "processes");
        }
    }

    private void updateUiFromStatusMessage(StatusMessage statusMessage) {
        
        if (statusMessage instanceof ProcessStatusMessage) {
            processesPanel.update(statusMessage);

            workersPanel.update(statusMessage);
        } else if (statusMessage instanceof WorkerStatusMessage) {
            workersPanel.update(statusMessage);
        }
    }

    public void handleMessage(final StatusMessage statusMessage) {
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                updateUiFromStatusMessage(statusMessage);
            }
        });
    }

    /**
     * Auto-generated main method to display this JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        JFrame frame = new JFrame();
        MasterStatusPanel masterStatusPanel = new MasterStatusPanel();
        frame.getContentPane().add(masterStatusPanel);
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);
        frame.setSize(1024, 700);
        masterStatusPanel.splitPane.setDividerLocation(0.35);
    }
}
