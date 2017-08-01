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

import java.awt.FlowLayout;

import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.WindowConstants;

public class StatusSummaryPanel extends javax.swing.JPanel {
    private static final long serialVersionUID = -7538149739596275583L;

    private JLabel pipelinesLabel;
    private JLabel processesLabel;
    private JLabel metricsStateLabel;
    private JLabel metricsLabel;
    private JLabel alertsStateLabel;
    private JLabel alertsLabel;
    private JLabel processesStateLabel;
    private JLabel workersStateLabel;
    private JLabel workersLabel;
    private JLabel pipelinesStateLabel;

    public StatusSummaryPanel() {
        initGUI();
    }

    public void setState(Indicator.Category category, Indicator.State state) {
        switch (category) {
            case PIPELINE:
                pipelinesStateLabel.setIcon(state.getImageIcon());
                break;

            case WORKER:
                workersStateLabel.setIcon(state.getImageIcon());
                break;

            case PROCESS:
                processesStateLabel.setIcon(state.getImageIcon());
                break;

            case ALERT:
                alertsStateLabel.setIcon(state.getImageIcon());
                break;

            case METRIC:
                metricsStateLabel.setIcon(state.getImageIcon());
                break;

            default:
                throw new IllegalStateException("Unknown category: " + category);
        }
    }

    private void initGUI() {
        try {
            FlowLayout thisLayout = new FlowLayout();
            //setPreferredSize(new Dimension(400, 300));
            thisLayout.setAlignment(FlowLayout.LEFT);
            this.setLayout(thisLayout);
            {
                pipelinesLabel = new JLabel();
                this.add(pipelinesLabel);
                pipelinesLabel.setText("Pi:");
                pipelinesLabel.setToolTipText("Pipeline Instances");
            }
            {
                pipelinesStateLabel = new JLabel();
                this.add(pipelinesStateLabel);
                pipelinesStateLabel.setIcon(Indicator.State.GREEN.getImageIcon());
                pipelinesStateLabel.setToolTipText("Pipeline Instances");
            }
            {
                workersLabel = new JLabel();
                this.add(workersLabel);
                workersLabel.setText("W:");
                workersLabel.setToolTipText("Worker Threads");
            }
            {
                workersStateLabel = new JLabel();
                this.add(workersStateLabel);
                workersStateLabel.setIcon(Indicator.State.GREEN.getImageIcon());
                workersStateLabel.setToolTipText("Worker Threads");
            }
            {
                processesLabel = new JLabel();
                this.add(processesLabel);
                processesLabel.setText("Pr:");
                processesLabel.setToolTipText("Pipeline Processes");
            }
            {
                processesStateLabel = new JLabel();
                this.add(processesStateLabel);
                processesStateLabel.setIcon(Indicator.State.GREEN.getImageIcon());
                processesStateLabel.setToolTipText("Pipeline Processes");
            }
            {
                alertsLabel = new JLabel();
                this.add(alertsLabel);
                alertsLabel.setText("A:");
                alertsLabel.setToolTipText("Unacknowledged Alerts");
            }
            {
                alertsStateLabel = new JLabel();
                this.add(alertsStateLabel);
                alertsStateLabel.setIcon(Indicator.State.GREEN.getImageIcon());
                alertsStateLabel.setToolTipText("Unacknowledged Alerts");
            }
            {
                metricsLabel = new JLabel();
                this.add(metricsLabel);
                metricsLabel.setText("M:");
                metricsLabel.setToolTipText("Metrics out of bounds");
            }
            {
                metricsStateLabel = new JLabel();
                this.add(metricsStateLabel);
                metricsStateLabel.setIcon(Indicator.State.GREEN.getImageIcon());
                metricsStateLabel.setToolTipText("Metrics out of bounds");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Auto-generated main method to display this 
     * JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        JFrame frame = new JFrame();
        frame.getContentPane().add(new StatusSummaryPanel());
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);
    }

    /**
     * @return the alertsStateLabel
     */
    public JLabel getAlertsStateLabel() {
        return alertsStateLabel;
    }

    /**
     * @return the metricsStateLabel
     */
    public JLabel getMetricsStateLabel() {
        return metricsStateLabel;
    }

    /**
     * @return the pipelinesStateLabel
     */
    public JLabel getPipelinesStateLabel() {
        return pipelinesStateLabel;
    }

    /**
     * @return the processesStateLabel
     */
    public JLabel getProcessesStateLabel() {
        return processesStateLabel;
    }

    /**
     * @return the workersStateLabel
     */
    public JLabel getWorkersStateLabel() {
        return workersStateLabel;
    }
}
