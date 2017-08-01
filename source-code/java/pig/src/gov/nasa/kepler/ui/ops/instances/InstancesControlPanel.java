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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstance.State;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceFilter;

import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.GridLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.border.BevelBorder;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class InstancesControlPanel extends javax.swing.JPanel{
    private static final Log log = LogFactory.getLog(InstancesControlPanel.class);

	private JPanel filtersPanel;
	private JCheckBox stateErrorsStalledCheckBox;
    private JCheckBox nameCheckBox;
	private JCheckBox stateInitializedCheckBox;
	private JCheckBox stateProcessingCheckBox;
	private JCheckBox stateErrorsRunningCheckBox;
	private JPanel ageOptionsFlowPanel;
	private JLabel startLabel;
	private JCheckBox ageCheckBox;
	private JCheckBox stateCompleteCheckBox;
	private JCheckBox statesCheckBox;
    private JButton refreshNowButton;
    private JTextField ageTextField;
    private JButton clearFiltersButton;
    private JPanel refreshButtonPanel;
    private JLabel daysLabel;
    private JButton day90Button;
    private JButton day30Button;
    private JButton day10Button;
    private JButton day5Button;
    private JButton day1Button;
    private JPanel ageDefaultButtonsPanel;
    private JPanel nameOptionsPanel;
    private JTextField nameContainsTextField;
    private JLabel containsLabel;
    private JPanel nameOptionsFlowPanel;
    private JPanel nameEnabledPanel;
	private JPanel ageOptionsPanel;
	private JPanel ageEnabledPanel;
	private JPanel statesOptionsPanel;
	private JPanel statesEnabledPanel;
	
	private PipelineInstanceFilter filter;

	private InstancesControlPanelListener listener = null;
	
	/* for Jigloo use only */
    public InstancesControlPanel() {
        super();
        this.filter = new PipelineInstanceFilter();
        initGUI();
    }
    
    public InstancesControlPanel(PipelineInstanceFilter filter) {
        super();
        this.filter = filter;
        initGUI();
    }
    
    private void day1ButtonActionPerformed(ActionEvent evt) {
        log.debug("day1Button.actionPerformed, event="+evt);
        
        ageTextField.setText("1");
    }
    
    private void day5ButtonActionPerformed(ActionEvent evt) {
        log.debug("day5Button.actionPerformed, event="+evt);
        
        ageTextField.setText("5");
    }
    
    private void day10ButtonActionPerformed(ActionEvent evt) {
        log.debug("day10Button.actionPerformed, event="+evt);
        
        ageTextField.setText("10");
    }
    
    private void day30ButtonActionPerformed(ActionEvent evt) {
        log.debug("day30Button.actionPerformed, event="+evt);
        
        ageTextField.setText("30");
    }
    
    private void day90ButtonActionPerformed(ActionEvent evt) {
        log.debug("day90Button.actionPerformed, event="+evt);
        
        ageTextField.setText("90");
    }

    private void clearFiltersButtonActionPerformed(ActionEvent evt) {
        log.debug("clearFiltersButton.actionPerformed, event="+evt);

        statesCheckBox.setSelected(false);
        ageCheckBox.setSelected(false);
        nameCheckBox.setSelected(false);
        
        updateEnabledState();
        updateFilter();
    }
    
    private void refreshNowButtonActionPerformed(ActionEvent evt) {
        log.debug("refreshNowButton.actionPerformed, event="+evt);
        
        updateFilter();

        refreshNowPressed();
    }
    
    private void statesCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("statesCheckBox.actionPerformed, event="+evt);
        
        updateEnabledState();
    }
    
    private void ageCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("ageCheckBox.actionPerformed, event="+evt);
        
        updateEnabledState();
    }
    
    private void nameCheckBoxActionPerformed(ActionEvent evt) {
        log.debug("nameCheckBox.actionPerformed, event="+evt);
        
        updateEnabledState();
    }
    
    /**
     * Update the 'enabled' state for the options components based on
     * the state of the master checkboxes
     */
    private void updateEnabledState(){
        // states
        stateInitializedCheckBox.setEnabled(statesCheckBox.isSelected());
        stateProcessingCheckBox.setEnabled(statesCheckBox.isSelected());
        stateCompleteCheckBox.setEnabled(statesCheckBox.isSelected());
        stateErrorsRunningCheckBox.setEnabled(statesCheckBox.isSelected());
        stateErrorsStalledCheckBox.setEnabled(statesCheckBox.isSelected());

        // age
        startLabel.setEnabled(ageCheckBox.isSelected());
        ageTextField.setEnabled(ageCheckBox.isSelected());
        daysLabel.setEnabled(ageCheckBox.isSelected());
        day1Button.setEnabled(ageCheckBox.isSelected());
        day5Button.setEnabled(ageCheckBox.isSelected());
        day10Button.setEnabled(ageCheckBox.isSelected());
        day30Button.setEnabled(ageCheckBox.isSelected());
        day90Button.setEnabled(ageCheckBox.isSelected());
        
        // name
        containsLabel.setEnabled(nameCheckBox.isSelected());
        nameContainsTextField.setEnabled(nameCheckBox.isSelected());
    }
    
    private void updateFilter(){
        // states
        if(statesCheckBox.isSelected()){
            List<State> states = new ArrayList<State>();
            filter.setStates(states);
            
            if(stateInitializedCheckBox.isSelected()){
                states.add(PipelineInstance.State.INITIALIZED);
            }
            if(stateProcessingCheckBox.isSelected()){
                states.add(PipelineInstance.State.PROCESSING);
            }
            if(stateCompleteCheckBox.isSelected()){
                states.add(PipelineInstance.State.COMPLETED);
            }
            if(stateErrorsRunningCheckBox.isSelected()){
                states.add(PipelineInstance.State.ERRORS_RUNNING);
            }
            if(stateErrorsStalledCheckBox.isSelected()){
                states.add(PipelineInstance.State.ERRORS_STALLED);
            }
        }else{
            filter.setStates(null);
        }
        
        // age
        if(ageCheckBox.isSelected()){
            int age = 0;
            String ageText = ageTextField.getText();
            
            try {
                age = Integer.parseInt(ageText);
            } catch (NumberFormatException e) {
                JOptionPane.showMessageDialog(this, "Invalid age: " + ageText + ":" + e.getMessage(), "Error", JOptionPane.ERROR_MESSAGE);
            }
            filter.setAgeDays(age);
        }else{
            filter.setAgeDays(0);
        }
        
        // name
        if(nameCheckBox.isSelected()){
            filter.setNameContains(nameContainsTextField.getText());
        }else{
            filter.setNameContains("");
        }
    }
    
	private void initGUI() {
		try {
		    GridBagLayout thisLayout = new GridBagLayout();
			thisLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
			thisLayout.columnWidths = new int[] {7, 7, 7, 7, 7, 7};
			thisLayout.rowWeights = new double[] {0.1};
			thisLayout.rowHeights = new int[] {7};
			this.setLayout(thisLayout);
			this.setPreferredSize(new java.awt.Dimension(500, 226));
			this.setOpaque(false);
			this.add(getFiltersPanel(), new GridBagConstraints(0, 0, 6, 2, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private JPanel getFiltersPanel() {
		if (filtersPanel == null) {
			filtersPanel = new JPanel();
			GridBagLayout filtersPanelLayout = new GridBagLayout();
			filtersPanelLayout.columnWeights = new double[] {0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1};
			filtersPanelLayout.columnWidths = new int[] {7, 7, 7, 7, 7, 7, 7, 7};
			filtersPanelLayout.rowWeights = new double[] {0.1,0.1,0.1,0.1};
			filtersPanelLayout.rowHeights = new int[] {7,7,7,7};
			filtersPanel.setLayout(filtersPanelLayout);
			filtersPanel.setBorder(BorderFactory.createTitledBorder("Filter by"));
			filtersPanel.add(getStatesEnabledPanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
			filtersPanel.add(getStatesOptionsPanel(), new GridBagConstraints(1, 0, 7, 1, 1.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
			filtersPanel.add(getAgeEnabledPanel(), new GridBagConstraints(0, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
			filtersPanel.add(getAgeOptionsPanel(), new GridBagConstraints(1, 1, 7, 1, 1.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            filtersPanel.add(getNameEnabledPanel(), new GridBagConstraints(0, 2, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            filtersPanel.add(getNameOptionsPanel(), new GridBagConstraints(1, 2, 7, 1, 1.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            filtersPanel.add(getRefreshButtonPanel(), new GridBagConstraints(0, 3, 8, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
		}
		return filtersPanel;
	}

	private JPanel getStatesEnabledPanel() {
		if (statesEnabledPanel == null) {
			statesEnabledPanel = new JPanel();
			statesEnabledPanel.add(getStatesCheckBox());
		}
		return statesEnabledPanel;
	}
	
	private JPanel getStatesOptionsPanel() {
		if (statesOptionsPanel == null) {
			statesOptionsPanel = new JPanel();
			GridLayout statesOptionsPanelLayout = new GridLayout(3, 2);
			statesOptionsPanelLayout.setColumns(2);
			statesOptionsPanelLayout.setRows(3);
			statesOptionsPanel.setLayout(statesOptionsPanelLayout);
			statesOptionsPanel.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));
			statesOptionsPanel.add(getStateInitializedCheckBox());
            statesOptionsPanel.add(getStateErrorsRunningCheckBox());
            statesOptionsPanel.add(getStateProcessingCheckBox());
			statesOptionsPanel.add(getStateErrorsStalledCheckBox());
			statesOptionsPanel.add(getStateCompleteCheckBox());
		}
		return statesOptionsPanel;
	}
	
	private JPanel getAgeEnabledPanel() {
		if (ageEnabledPanel == null) {
			ageEnabledPanel = new JPanel();
			ageEnabledPanel.add(getAgeCheckBox());
		}
		return ageEnabledPanel;
	}
	
	private JPanel getAgeOptionsPanel() {
		if (ageOptionsPanel == null) {
			ageOptionsPanel = new JPanel();
			GridLayout datesOptionsPanelLayout = new GridLayout(2, 2);
			datesOptionsPanelLayout.setColumns(2);
			datesOptionsPanelLayout.setRows(2);
			ageOptionsPanel.setLayout(datesOptionsPanelLayout);
			ageOptionsPanel.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));
			ageOptionsPanel.add(getAgeOptionsFlowPanel());
            ageOptionsPanel.add(getAgeDefaultButtonsPanel());
		}
		return ageOptionsPanel;
	}

	private JCheckBox getStatesCheckBox() {
		if (statesCheckBox == null) {
			statesCheckBox = new JCheckBox();
			statesCheckBox.setText("States");
			statesCheckBox.setSelected(filter.getStates() != null);
			statesCheckBox.addActionListener(new ActionListener() {
			    public void actionPerformed(ActionEvent evt) {
			        statesCheckBoxActionPerformed(evt);
			    }
			});
		}
		return statesCheckBox;
	}
	
	private JCheckBox getStateProcessingCheckBox() {
		if (stateProcessingCheckBox == null) {
			stateProcessingCheckBox = new JCheckBox();
			stateProcessingCheckBox.setText("Processing");
            List<State> states = filter.getStates();
            stateProcessingCheckBox.setSelected(states != null && states.contains(PipelineInstance.State.PROCESSING));
            stateProcessingCheckBox.setEnabled(states != null);
		}
		return stateProcessingCheckBox;
	}
	
	private JCheckBox getStateInitializedCheckBox() {
		if (stateInitializedCheckBox == null) {
			stateInitializedCheckBox = new JCheckBox();
			stateInitializedCheckBox.setText("Initialized");
            List<State> states = filter.getStates();
            stateInitializedCheckBox.setSelected(states != null && states.contains(PipelineInstance.State.INITIALIZED));
            stateInitializedCheckBox.setEnabled(states != null);
		}
		return stateInitializedCheckBox;
	}
	
	private JCheckBox getStateErrorsStalledCheckBox() {
		if (stateErrorsStalledCheckBox == null) {
			stateErrorsStalledCheckBox = new JCheckBox();
			stateErrorsStalledCheckBox.setText("Errors (stalled)");
            List<State> states = filter.getStates();
            stateErrorsStalledCheckBox.setSelected(states != null && states.contains(PipelineInstance.State.ERRORS_STALLED));
            stateErrorsStalledCheckBox.setEnabled(states != null);
		}
		return stateErrorsStalledCheckBox;
	}
	
	private JCheckBox getStateErrorsRunningCheckBox() {
		if (stateErrorsRunningCheckBox == null) {
			stateErrorsRunningCheckBox = new JCheckBox();
			stateErrorsRunningCheckBox.setText("Errors (running)");
            List<State> states = filter.getStates();
            stateErrorsRunningCheckBox.setSelected(states != null && states.contains(PipelineInstance.State.ERRORS_RUNNING));
            stateErrorsRunningCheckBox.setEnabled(states != null);
		}
		return stateErrorsRunningCheckBox;
	}
	
	private JCheckBox getStateCompleteCheckBox() {
		if (stateCompleteCheckBox == null) {
			stateCompleteCheckBox = new JCheckBox();
			stateCompleteCheckBox.setText("Completed");
            List<State> states = filter.getStates();
            stateCompleteCheckBox.setSelected(states != null && states.contains(PipelineInstance.State.COMPLETED));
            stateCompleteCheckBox.setEnabled(states != null);
		}
		return stateCompleteCheckBox;
	}
	
	private JCheckBox getAgeCheckBox() {
		if (ageCheckBox == null) {
			ageCheckBox = new JCheckBox();
			ageCheckBox.setText("Age");
			ageCheckBox.setSelected(filter.getAgeDays() != 0);
			ageCheckBox.addActionListener(new ActionListener() {
			    public void actionPerformed(ActionEvent evt) {
			        ageCheckBoxActionPerformed(evt);
			    }
			});
		}
		return ageCheckBox;
	}
	
	private JLabel getStartLabel() {
		if (startLabel == null) {
			startLabel = new JLabel();
			startLabel.setEnabled(filter.getAgeDays() > 0);
			startLabel.setText("Started within the last");
		}
		return startLabel;
	}

	private JPanel getAgeOptionsFlowPanel() {
		if (ageOptionsFlowPanel == null) {
			ageOptionsFlowPanel = new JPanel();
			FlowLayout datesOptionsStartPanelLayout = new FlowLayout();
			datesOptionsStartPanelLayout.setAlignment(FlowLayout.LEFT);
			ageOptionsFlowPanel.setLayout(datesOptionsStartPanelLayout);
			ageOptionsFlowPanel.add(getStartLabel());
            ageOptionsFlowPanel.add(getAgeTextField());
            ageOptionsFlowPanel.add(getDaysLabel());
		}
		return ageOptionsFlowPanel;
	}

	/**
	 * @return Returns the listener.
	 */
	public InstancesControlPanelListener getListener() {
		return listener;
	}

	/**
	 * @param listener The listener to set.
	 */
	public void setListener(InstancesControlPanelListener listener) {
		this.listener = listener;
	}

    public void refreshNowPressed() {
		if( listener != null ){
			listener.refreshInstanceNowPressed();
		}
	}
	
	private JCheckBox getNameCheckBox() {
	    if(nameCheckBox == null) {
	        nameCheckBox = new JCheckBox();
	        nameCheckBox.setText("Name");
	        String name = filter.getNameContains();
            nameCheckBox.setSelected(name != null && name.length() > 0);
	        nameCheckBox.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                nameCheckBoxActionPerformed(evt);
	            }
	        });
	    }
	    return nameCheckBox;
	}
	
	private JPanel getNameEnabledPanel() {
	    if(nameEnabledPanel == null) {
	        nameEnabledPanel = new JPanel();
            nameEnabledPanel.add(getNameCheckBox());
	    }
	    return nameEnabledPanel;
	}
	
	private JPanel getNameOptionsFlowPanel() {
	    if(nameOptionsFlowPanel == null) {
	        nameOptionsFlowPanel = new JPanel();
	        FlowLayout nameOptionsPanelLayout = new FlowLayout();
            nameOptionsPanelLayout.setAlignment(FlowLayout.LEFT);
            nameOptionsFlowPanel.setLayout(nameOptionsPanelLayout);
            nameOptionsFlowPanel.setEnabled(false);
            nameOptionsFlowPanel.add(getContainsLabel());
            nameOptionsFlowPanel.add(getNameContainsTextField());
	    }
	    return nameOptionsFlowPanel;
	}
	
	private JLabel getContainsLabel() {
	    if(containsLabel == null) {
	        containsLabel = new JLabel();
	        containsLabel.setText("Contains: ");
	        String name = filter.getNameContains();
            containsLabel.setEnabled(name != null && name.length() > 0);
	    }
	    return containsLabel;
	}
	
	private JTextField getNameContainsTextField() {
	    if(nameContainsTextField == null) {
	        nameContainsTextField = new JTextField();
            nameContainsTextField.setColumns(15);
            String name = filter.getNameContains();
            if(name != null){
                nameContainsTextField.setText(name);
            }
            nameContainsTextField.setEnabled(name != null && name.length() > 0);
	    }
	    return nameContainsTextField;
	}
	
	private JPanel getNameOptionsPanel() {
	    if(nameOptionsPanel == null) {
	        nameOptionsPanel = new JPanel();
	        GridBagLayout nameTextPanelLayout = new GridBagLayout();
            nameTextPanelLayout.rowWeights = new double[] {0.1};
            nameTextPanelLayout.rowHeights = new int[] {7};
            nameTextPanelLayout.columnWeights = new double[] {0.1};
            nameTextPanelLayout.columnWidths = new int[] {7};
            nameOptionsPanel.setLayout(nameTextPanelLayout);
            nameOptionsPanel.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));
            nameOptionsPanel.add(getNameOptionsFlowPanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.LINE_START, GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
	    }
	    return nameOptionsPanel;
	}
	
	private JPanel getAgeDefaultButtonsPanel() {
	    if(ageDefaultButtonsPanel == null) {
	        ageDefaultButtonsPanel = new JPanel();
	        FlowLayout ageDefaultButtonsPanelLayout = new FlowLayout();
            ageDefaultButtonsPanelLayout.setAlignment(FlowLayout.LEFT);
            ageDefaultButtonsPanel.setLayout(ageDefaultButtonsPanelLayout);
            ageDefaultButtonsPanel.add(getDay1Button());
            ageDefaultButtonsPanel.add(getDay5Button());
            ageDefaultButtonsPanel.add(getDay10Button());
            ageDefaultButtonsPanel.add(getDay30Button());
            ageDefaultButtonsPanel.add(getDay90Button());
	    }
	    return ageDefaultButtonsPanel;
	}
	
	private JButton getDay1Button() {
	    if(day1Button == null) {
	        day1Button = new JButton();
	        day1Button.setText("1d");
	        day1Button.setEnabled(filter.getAgeDays() > 0);
	        day1Button.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                day1ButtonActionPerformed(evt);
	            }
	        });
	    }
	    return day1Button;
	}
	
	private JButton getDay5Button() {
	    if(day5Button == null) {
	        day5Button = new JButton();
	        day5Button.setText("5d");
	        day5Button.setEnabled(filter.getAgeDays() > 0);
	        day5Button.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                day5ButtonActionPerformed(evt);
	            }
	        });
	    }
	    return day5Button;
	}
	
	private JButton getDay10Button() {
	    if(day10Button == null) {
	        day10Button = new JButton();
	        day10Button.setText("10d");
	        day10Button.setEnabled(filter.getAgeDays() > 0);
	        day10Button.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                day10ButtonActionPerformed(evt);
	            }
	        });
	    }
	    return day10Button;
	}
	
	private JButton getDay30Button() {
	    if(day30Button == null) {
	        day30Button = new JButton();
	        day30Button.setText("30d");
	        day30Button.setEnabled(filter.getAgeDays() > 0);
	        day30Button.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                day30ButtonActionPerformed(evt);
	            }
	        });
	    }
	    return day30Button;
	}
	
	private JButton getDay90Button() {
	    if(day90Button == null) {
	        day90Button = new JButton();
	        day90Button.setText("90d");
	        day90Button.setEnabled(filter.getAgeDays() > 0);
	        day90Button.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                day90ButtonActionPerformed(evt);
	            }
	        });
	    }
	    return day90Button;
	}
	
	private JLabel getDaysLabel() {
	    if(daysLabel == null) {
	        daysLabel = new JLabel();
	        daysLabel.setText("days");
	        daysLabel.setEnabled(filter.getAgeDays() > 0);
	    }
	    return daysLabel;
	}

	private JPanel getRefreshButtonPanel() {
	    if(refreshButtonPanel == null) {
	        refreshButtonPanel = new JPanel();
	        FlowLayout refreshButtonPanelLayout = new FlowLayout();
            refreshButtonPanelLayout.setHgap(40);
            refreshButtonPanel.setLayout(refreshButtonPanelLayout);
            refreshButtonPanel.add(getClearFiltersButton());
            refreshButtonPanel.add(getRefreshNowButton());
	    }
	    return refreshButtonPanel;
	}
	
	private JButton getClearFiltersButton() {
	    if(clearFiltersButton == null) {
	        clearFiltersButton = new JButton();
	        clearFiltersButton.setText("clear filters");
	        clearFiltersButton.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                clearFiltersButtonActionPerformed(evt);
	            }
	        });
	    }
	    return clearFiltersButton;
	}
	
	private JButton getRefreshNowButton() {
	    if(refreshNowButton == null) {
	        refreshNowButton = new JButton();
	        refreshNowButton.setText("refresh");
	        refreshNowButton.addActionListener(new ActionListener() {
	            public void actionPerformed(ActionEvent evt) {
	                refreshNowButtonActionPerformed(evt);
	            }
	        });
	    }
	    return refreshNowButton;
	}
	
	private JTextField getAgeTextField() {
	    if(ageTextField == null) {
	        ageTextField = new JTextField();
            ageTextField.setColumns(4);
            ageTextField.setText("" + filter.getAgeDays());
            ageTextField.setEnabled(filter.getAgeDays() > 0);
	    }
	    return ageTextField;
	}
}
