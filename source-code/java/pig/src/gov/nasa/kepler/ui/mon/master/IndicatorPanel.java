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


import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

/**
 * Superclass for all indicator panels.
 * 
 * An indicator panel is a {@link JPanel} that displays {@link Indicator} objects
 * using the custom {@link IndicatorLayout}.  These Indicator objects display the realtime
 * state of some system element (a process, a worker thread, a pipeline instance, a metric, etc.)
 * with a color-coded health bar (green, amber, red).
 * 
 * Stale indicators can be removed manually by the user via a popup menu for individual indicators, 
 * or the 'dismiss all' button to remove all indicators.
 *  
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public abstract class IndicatorPanel extends StatusPanel {

    private int numRows = 5;
	private IndicatorLayout layout;
	private JPanel dataPanel;
	private JScrollPane scrollPane;
    private JButton resetButton;
    private JLabel titleLabel;
    private JPanel titleButtonBarPanel;

    private boolean hasTitleButtonBar = true;
    
    protected Indicator parentIndicator;
    private JPanel buttonBarPanel;
    private JPanel titlePanel;

    public IndicatorPanel(Indicator parentIndicator) {
        this.parentIndicator = parentIndicator;
		initGUI();
	}
	
	public IndicatorPanel(Indicator parentIndicator, int numRows, boolean hasTitleButtonBar) {
        this.parentIndicator = parentIndicator;
		this.numRows = numRows;
        this.hasTitleButtonBar = hasTitleButtonBar;
		initGUI();
	}
	
    public abstract void dismissAll();

    public void removeIndicator(Indicator indicator) {
        dataPanel.remove(indicator);
        repaint();
    }

    private void initGUI() {
		try {
			BorderLayout thisLayout = new BorderLayout();
			setLayout(thisLayout);
			scrollPane = getScrollPane();
            if(hasTitleButtonBar){
                this.add(getTitleButtonBarPanel(), BorderLayout.NORTH);
            }
			add(scrollPane, BorderLayout.CENTER);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private JScrollPane getScrollPane() {
		if (scrollPane == null) {
			scrollPane = new JScrollPane();
			scrollPane.setViewportView(getDataPanel());
		}
		return scrollPane;
	}

	private JPanel getDataPanel() {
		if (dataPanel == null) {
			dataPanel = new JPanel();

			layout = new IndicatorLayout();
			layout.setNumRows( numRows );
			dataPanel.setLayout( layout );

//			dataPanel.setBackground(new java.awt.Color(255, 255, 255));
//			dataPanel.setPreferredSize(new Dimension(1500, 1500));
		}
		return dataPanel;
	}

    public void setTitle(String title){
        titleLabel.setText(title);
    }
    
	public void add( Indicator indicator ){
		dataPanel.add( indicator );
	}
	
	/**
	 * @return Returns the numRows.
	 */
	public int getNumRows() {
		return numRows;
	}

	/**
	 * @param numRows The numRows to set.
	 */
	public void setNumRows(int numRows) {
		this.numRows = numRows;
	}
    
    private JPanel getTitleButtonBarPanel() {
        if (titleButtonBarPanel == null) {
            titleButtonBarPanel = new JPanel();
            BorderLayout titleButtonBarPanelLayout = new BorderLayout();
            titleButtonBarPanel.setLayout(titleButtonBarPanelLayout);
            titleButtonBarPanel.add(getTitlePanel(), BorderLayout.WEST);
            titleButtonBarPanel.add(getButtonBarPanel(), BorderLayout.EAST);
        }
        return titleButtonBarPanel;
    }
    
    private JLabel getTitleLabel() {
        if (titleLabel == null) {
            titleLabel = new JLabel();
            titleLabel.setText("(title)");
            titleLabel.setFont(new java.awt.Font("Dialog",1,14));
        }
        return titleLabel;
    }
    
    private JButton getResetButton() {
        if (resetButton == null) {
            resetButton = new JButton();
            resetButton.setText("reset");
            resetButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    resetButtonActionPerformed(evt);
                }
            });
        }
        return resetButton;
    }
    
    private void resetButtonActionPerformed(ActionEvent evt) {
        dismissAll();
    }
    
    private JPanel getTitlePanel() {
        if (titlePanel == null) {
            titlePanel = new JPanel();
            FlowLayout titlePanelLayout = new FlowLayout();
            titlePanelLayout.setAlignment(FlowLayout.LEFT);
            titlePanel.setLayout(titlePanelLayout);
            titlePanel.add(getTitleLabel());
        }
        return titlePanel;
    }
    
    private JPanel getButtonBarPanel() {
        if (buttonBarPanel == null) {
            buttonBarPanel = new JPanel();
            FlowLayout buttonBarPanelLayout = new FlowLayout();
            buttonBarPanelLayout.setAlignOnBaseline(true);
            buttonBarPanelLayout.setAlignment(FlowLayout.RIGHT);
            buttonBarPanel.setLayout(buttonBarPanelLayout);
            buttonBarPanel.add(getResetButton());
        }
        return buttonBarPanel;
    }
}
