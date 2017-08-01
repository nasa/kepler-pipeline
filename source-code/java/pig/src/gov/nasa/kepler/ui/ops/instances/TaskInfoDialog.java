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
import gov.nasa.kepler.pi.common.DisplayModel;
import gov.nasa.kepler.ui.ons.etable.ETable;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;

import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextField;
import javax.swing.SwingConstants;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class TaskInfoDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(TaskInfoDialog.class);

    private JPanel detailsPanel;
	private JLabel failureCountLabel;
	private JTextField createdTextField;
	private JTextField endTextField;
	private JTextField startTextField;
	private JTextField workerTextField;
	private JTextField uowTextField;
	private JTextField moduleTextField;
	private JTextField stateTextField;
	private ETable processingBreakdownTable;
	private JScrollPane processingBreakdownScrollPane;
	private JPanel processingBreakdownPanel;
	private JTextField svnTextField;
	private JTextField idTextField;
	private JCheckBox transitionCheckBox;
	private JTextField failCountTextField;
	private JPanel miscPanel;
	private JLabel stateLabel;
	private JLabel svnLabel;
	private JLabel createdLabel;
	private JLabel endLabel;
	private JLabel startLabel;
	private JLabel workerLabel;
	private JLabel uowLabel;
	private JLabel moduleLabel;
	private JLabel idLabel;
	private JPanel dataPanel;
	private JButton closeButton;
	private JPanel buttonPanel;

    private TaskMetricsTableModel processingBreakdownTableModel;
    private PipelineTask pipelineTask;
    
    public TaskInfoDialog(JFrame frame, PipelineTask pipelineTask) {
        super(frame);
        
        this.pipelineTask = pipelineTask;

        initGUI();
    }
    
    public static void showTaskInfoDialog(JFrame frame, PipelineTask pipelineTask) {
    	TaskInfoDialog dialog = new TaskInfoDialog(frame, pipelineTask);

        dialog.setVisible(true);
    }

	private void closeButtonActionPerformed(ActionEvent evt) {
        log.info("closeButton.actionPerformed, event="+evt);

        setVisible(false);
	}
	
	private void transitionCheckBoxActionPerformed(ActionEvent evt) {
		transitionCheckBox.setSelected(pipelineTask.isTransitionComplete());
	}

    private void initGUI() {
		try {
			{
				BorderLayout thisLayout = new BorderLayout();
				thisLayout.setHgap(10);
				thisLayout.setVgap(10);
				getContentPane().setLayout(thisLayout);
				this.setTitle("Pipeline Task Details");
				getContentPane().add(getButtonPanel(), BorderLayout.SOUTH);
				getContentPane().add(getDataPanel(), BorderLayout.NORTH);
			}
			this.setSize(1280, 400);
			
            String moduleName = pipelineTask.getPipelineInstanceNode().getPipelineModuleDefinition().getName().getName();
            
			idTextField.setText(pipelineTask.getId()+"");
			moduleTextField.setText(moduleName+"");
			uowTextField.setText(pipelineTask.uowTaskInstance().briefState());
			workerTextField.setText(pipelineTask.getWorkerName());
			startTextField.setText(DisplayModel.formatDate(pipelineTask.getStartProcessingTime()));
			endTextField.setText(DisplayModel.formatDate(pipelineTask.getEndProcessingTime()));
			createdTextField.setText(DisplayModel.formatDate(pipelineTask.getCreated()));
			svnTextField.setText(pipelineTask.getSoftwareRevision());
			failCountTextField.setText(pipelineTask.getFailureCount()+"");
			transitionCheckBox.setSelected(pipelineTask.isTransitionComplete());

			State state = pipelineTask.getState();
            stateTextField.setText(state.toString());

		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private JPanel getDetailsPanel() {
		if(detailsPanel == null) {
			detailsPanel = new JPanel();
			GridBagLayout dataPanelLayout = new GridBagLayout();
			dataPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7, 7, 7, 7};
			dataPanelLayout.rowHeights = new int[] {7, 7, 7, 7, 7, 7, 7, 7, 7, 7};
			dataPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
			dataPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
			detailsPanel.setLayout(dataPanelLayout);
			detailsPanel.add(getIdLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getStateLabel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getModuleLabel(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getUowLabel(), new GridBagConstraints(0, 3, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getWorkerLabel(), new GridBagConstraints(0, 4, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getStartLabel(), new GridBagConstraints(0, 5, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getEndLabel(), new GridBagConstraints(0, 6, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getCreatedLabel(), new GridBagConstraints(0, 7, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getSvnLabel(), new GridBagConstraints(0, 8, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_END, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getMiscPanel(), new GridBagConstraints(0, 9, 8, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getIdTextField(), new GridBagConstraints(1, 0, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getStateTextField(), new GridBagConstraints(1, 1, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getModuleTextField(), new GridBagConstraints(1, 2, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getUowTextField(), new GridBagConstraints(1, 3, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getWorkerTextField(), new GridBagConstraints(1, 4, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getStartTextField(), new GridBagConstraints(1, 5, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getEndTextField(), new GridBagConstraints(1, 6, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getCreatedTextField(), new GridBagConstraints(1, 7, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
			detailsPanel.add(getSvnTextField(), new GridBagConstraints(1, 8, 6, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
		}
		return detailsPanel;
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
	
	private JPanel getDataPanel() {
		if(dataPanel == null) {
			dataPanel = new JPanel();
			GridBagLayout dataPanelLayout = new GridBagLayout();
			dataPanelLayout.columnWidths = new int[] {7};
			dataPanelLayout.rowHeights = new int[] {7, 7, 7, 7, 7, 7};
			dataPanelLayout.columnWeights = new double[] {0.1};
			dataPanelLayout.rowWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
			dataPanel.setLayout(dataPanelLayout);
			dataPanel.add(getDetailsPanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
			dataPanel.add(getMetricsPanel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
		}
		return dataPanel;
	}
	
	private JLabel getIdLabel() {
		if(idLabel == null) {
			idLabel = new JLabel();
			idLabel.setText("ID: ");
			idLabel.setHorizontalAlignment(SwingConstants.TRAILING);
		}
		return idLabel;
	}
	
	private JLabel getStateLabel() {
		if(stateLabel == null) {
			stateLabel = new JLabel();
			stateLabel.setText("State: ");
		}
		return stateLabel;
	}
	
	private JLabel getModuleLabel() {
		if(moduleLabel == null) {
			moduleLabel = new JLabel();
			moduleLabel.setText("Module Name: ");
		}
		return moduleLabel;
	}
	
	private JLabel getUowLabel() {
		if(uowLabel == null) {
			uowLabel = new JLabel();
			uowLabel.setText("Unit of Work: ");
		}
		return uowLabel;
	}
	
	private JLabel getWorkerLabel() {
		if(workerLabel == null) {
			workerLabel = new JLabel();
			workerLabel.setText("Worker (host:thread): ");
		}
		return workerLabel;
	}
	
	private JLabel getStartLabel() {
		if(startLabel == null) {
			startLabel = new JLabel();
			startLabel.setText("Start Time: ");
		}
		return startLabel;
	}
	
	private JLabel getEndLabel() {
		if(endLabel == null) {
			endLabel = new JLabel();
			endLabel.setText("End Time: ");
		}
		return endLabel;
	}
	
	private JLabel getCreatedLabel() {
		if(createdLabel == null) {
			createdLabel = new JLabel();
			createdLabel.setText("Create Time: ");
		}
		return createdLabel;
	}
	
	private JLabel getSvnLabel() {
		if(svnLabel == null) {
			svnLabel = new JLabel();
			svnLabel.setText("Software Revision: ");
		}
		return svnLabel;
	}
	
	private JPanel getMiscPanel() {
		if(miscPanel == null) {
			miscPanel = new JPanel();
			FlowLayout miscPanelLayout = new FlowLayout();
			miscPanelLayout.setHgap(20);
			miscPanel.setLayout(miscPanelLayout);
			miscPanel.add(getFailureCountLabel());
			miscPanel.add(getFailCountTextField());
			miscPanel.add(getTransitionCheckBox());
		}
		return miscPanel;
	}
	
	private JLabel getFailureCountLabel() {
		if(failureCountLabel == null) {
			failureCountLabel = new JLabel();
			failureCountLabel.setText("Failure Count");
		}
		return failureCountLabel;
	}
	
	private JTextField getFailCountTextField() {
		if(failCountTextField == null) {
			failCountTextField = new JTextField();
			failCountTextField.setEditable(false);
			failCountTextField.setColumns(2);
		}
		return failCountTextField;
	}

	private JCheckBox getTransitionCheckBox() {
		if(transitionCheckBox == null) {
			transitionCheckBox = new JCheckBox();
			transitionCheckBox.setText("Transition Complete");
			transitionCheckBox.setSelected(true);
			transitionCheckBox.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					transitionCheckBoxActionPerformed(evt);
				}
			});
		}
		return transitionCheckBox;
	}
	
	private JTextField getIdTextField() {
		if(idTextField == null) {
			idTextField = new JTextField();
			idTextField.setColumns(10);
			idTextField.setEditable(false);
		}
		return idTextField;
	}
	
	private JTextField getStateTextField() {
		if(stateTextField == null) {
			stateTextField = new JTextField();
			stateTextField.setText("COMPLETED");
			stateTextField.setColumns(50);
			stateTextField.setEditable(false);
		}
		return stateTextField;
	}
	
	private JTextField getModuleTextField() {
		if(moduleTextField == null) {
			moduleTextField = new JTextField();
			moduleTextField.setText("pa");
			moduleTextField.setEditable(false);
			moduleTextField.setColumns(50);
		}
		return moduleTextField;
	}
	
	private JTextField getUowTextField() {
		if(uowTextField == null) {
			uowTextField = new JTextField();
			uowTextField.setColumns(50);
			uowTextField.setEditable(false);
		}
		return uowTextField;
	}
	
	private JTextField getWorkerTextField() {
		if(workerTextField == null) {
			workerTextField = new JTextField();
			workerTextField.setColumns(50);
			workerTextField.setEditable(false);
		}
		return workerTextField;
	}
	
	private JTextField getStartTextField() {
		if(startTextField == null) {
			startTextField = new JTextField();
			startTextField.setEditable(false);
			startTextField.setColumns(50);
		}
		return startTextField;
	}
	
	private JTextField getEndTextField() {
		if(endTextField == null) {
			endTextField = new JTextField();
			endTextField.setColumns(50);
			endTextField.setEditable(false);
		}
		return endTextField;
	}
	
	private JTextField getCreatedTextField() {
		if(createdTextField == null) {
			createdTextField = new JTextField();
			createdTextField.setEditable(false);
			createdTextField.setColumns(50);
		}
		return createdTextField;
	}
	
	private JTextField getSvnTextField() {
		if(svnTextField == null) {
			svnTextField = new JTextField();
			svnTextField.setColumns(50);
			svnTextField.setEditable(false);
		}
		return svnTextField;
	}
	
	private JPanel getMetricsPanel() {
		if(processingBreakdownPanel == null) {
			processingBreakdownPanel = new JPanel();
			BorderLayout metricsPanelLayout = new BorderLayout();
			processingBreakdownPanel.setLayout(metricsPanelLayout);
			processingBreakdownPanel.add(getMetricsScrollPane(), BorderLayout.CENTER);
		}
		return processingBreakdownPanel;
	}
	
	private JScrollPane getMetricsScrollPane() {
		if(processingBreakdownScrollPane == null) {
			processingBreakdownScrollPane = new JScrollPane();
			processingBreakdownScrollPane.setViewportView(getMetricsTable());
		}
		return processingBreakdownScrollPane;
	}
	
	private ETable getMetricsTable() {
		if(processingBreakdownTable == null) {
	        
			ArrayList<PipelineTask> tasks = new ArrayList<PipelineTask>();
	        tasks.add(pipelineTask);
	        
            String moduleName = pipelineTask.getPipelineInstanceNode().getPipelineModuleDefinition().getName().getName();
	        ArrayList<String> moduleNames = new ArrayList<String>();
            moduleNames.add(moduleName);
            
            processingBreakdownTableModel = new TaskMetricsTableModel(tasks, moduleNames, false);
			processingBreakdownTable = new ETable();
			processingBreakdownTable.setModel(processingBreakdownTableModel);
		}
		return processingBreakdownTable;
	}

	/**
	* Auto-generated main method to display this JDialog
	*/
	
	public TaskInfoDialog(JFrame frame) {
		super(frame);
		initGUI();
	}
	
}
