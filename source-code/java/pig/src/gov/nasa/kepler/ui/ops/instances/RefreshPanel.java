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
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JPanel;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class RefreshPanel extends javax.swing.JPanel {
	private JButton nowButton;
	private JPanel nowButtonPanel;

	private RefreshPanelListener listener = null;
	
	public RefreshPanel() {
		super();
		initGUI();
	}
	
	private void initGUI() {
		try {
			//START >>  this

			this.setBorder(BorderFactory.createTitledBorder("Refresh"));
			GridBagLayout thisLayout = new GridBagLayout();
            thisLayout.rowWeights = new double[] {0.1};
            thisLayout.rowHeights = new int[] {7};
            thisLayout.columnWeights = new double[] {0.1};
            thisLayout.columnWidths = new int[] {7};
			this.setLayout(thisLayout);		//END <<  this
            this.setPreferredSize(new java.awt.Dimension(126, 72));
			this.add(getNowButtonPanel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private JButton getNowButton() {
		if (nowButton == null) {
			nowButton = new JButton();
			nowButton.setText("Now");
			nowButton.addActionListener(new ActionListener() {
				public void actionPerformed(ActionEvent evt) {
					nowButtonActionPerformed(evt);
				}
			});
		}
		return nowButton;
	}
	
	private JPanel getNowButtonPanel() {
		if (nowButtonPanel == null) {
			nowButtonPanel = new JPanel();
			FlowLayout nowButtonPanelLayout = new FlowLayout();
            nowButtonPanelLayout.setVgap(1);
            nowButtonPanelLayout.setHgap(1);
            nowButtonPanel.setLayout(nowButtonPanelLayout);
			nowButtonPanel.add(getNowButton());
		}
		return nowButtonPanel;
	}
	
	/**
	 * @return Returns the listener.
	 */
	public RefreshPanelListener getListener() {
		return listener;
	}

	/**
	 * @param listener The listener to set.
	 */
	public void setListener(RefreshPanelListener listener) {
		this.listener = listener;
	}

	private void nowButtonActionPerformed(ActionEvent evt) {
		if( listener != null ){
			listener.refreshNowPressed();
		}
	}
}
