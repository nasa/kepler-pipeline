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
import gov.nasa.kepler.ui.PipelineConsole;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.GridLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.net.URL;
import java.util.LinkedList;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JLabel;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.border.BevelBorder;

public class Indicator extends javax.swing.JPanel {
    private static final long serialVersionUID = 5482208634876526294L;

    public static final String GREEN_BALL_IMG = "images/green-ball.gif";
    public static final String AMBER_BALL_IMG = "images/yellow-ball.gif";
    public static final String RED_BALL_IMG = "images/red-ball.gif";

    public enum Category{
        PIPELINE, WORKER, PROCESS, ALERT, METRIC
    }
    
    public enum State{ 
        GREEN(GREEN_BALL_IMG), 
        AMBER(AMBER_BALL_IMG), 
        RED(RED_BALL_IMG);
    
        private ImageIcon imageIcon;
    
        private State(String imageIconPath){
            URL resource = getClass().getClassLoader().getResource(imageIconPath);
            imageIcon = new ImageIcon(resource);
        }

        public ImageIcon getImageIcon() {
            return imageIcon;
        }
    }
	
    /** should be globally unique among all {@link Indicator}s.  
     * Used for storing indicators in collections, etc.
     */
    private String id;
	private String indicatorDisplayName = "name";
	private State state = State.GREEN;
    
	private List<IndicatorListener> listeners = new LinkedList<IndicatorListener>();
    private JMenuItem dismissMenuItem;
    private JPopupMenu popupMenu;

	private JPanel topPanel;
	private JPanel statePanel;
	private JPanel dataPanel;
	private JLabel namelabel;

    private IndicatorPanel parentIndicatorPanel;
    
    private Category category = null;
    
    private long lastUpdated = System.currentTimeMillis();
    	
	public Indicator() {
        initGUI();
    }

    public Indicator(IndicatorPanel parentIndicatorPanel, String displayName ) {
        this.parentIndicatorPanel = parentIndicatorPanel;
		this.indicatorDisplayName = displayName;
		initGUI();
	}
	
	public void setState(State state){
		this.state = state;

		if( state == State.GREEN ){
			statePanel.setBackground(new java.awt.Color(0,167,0));
		}else if( state == State.RED ){
			statePanel.setBackground(new java.awt.Color(250,0,0));
		}else if( state == State.AMBER ){
			statePanel.setBackground(new java.awt.Color(250,250,0));
		}
        
        if(category != null){
            // non-null only for parent Indicators
            PipelineConsole instance = PipelineConsole.instance;
            if(instance != null){
                StatusSummaryPanel statusSummaryPanel = instance.getStatusSummaryPanel();
                if(statusSummaryPanel != null){
                    statusSummaryPanel.setState(category, state);
                }
            }
        }
	}
    
	private void initGUI() {
		try {
			BorderLayout thisLayout = new BorderLayout();
			this.setLayout(thisLayout);
			this.setPreferredSize(new java.awt.Dimension(200, 75));
			this.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));
			this.setVerifyInputWhenFocusTarget(false);
			this.addMouseListener(new MouseAdapter() {
				public void mouseClicked(MouseEvent evt) {
					rootMouseClicked(evt);
				}
			});
			this.add(getTopPanel(), BorderLayout.NORTH);
			this.add(getDataPanel(), BorderLayout.CENTER);
            setComponentPopupMenu(this, getPopupMenu());
            setState(state);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	
	private JPanel getTopPanel() {
		if (topPanel == null) {
			topPanel = new JPanel();
			BorderLayout topPanelLayout = new BorderLayout();
			topPanelLayout.setHgap(5);
			topPanel.setLayout(topPanelLayout);
			topPanel.add(getNamelabel(), BorderLayout.WEST);
			topPanel.add(getStatePanel(), BorderLayout.CENTER);
		}
		return topPanel;
	}
	
	private JLabel getNamelabel() {
		if (namelabel == null) {
			namelabel = new JLabel();
			namelabel.setText( indicatorDisplayName );
		}
		return namelabel;
	}
	
	private JPanel getStatePanel() {
		if (statePanel == null) {
			statePanel = new JPanel();
			statePanel.setBackground(new java.awt.Color(0,167,0));
			statePanel.setBorder(BorderFactory.createEtchedBorder(BevelBorder.LOWERED));
		}
		return statePanel;
	}
	
	private JPanel getDataPanel() {
		if (dataPanel == null) {
			dataPanel = new JPanel();
			GridLayout dataPanelLayout = new GridLayout(3, 2);
			dataPanelLayout.setColumns(2);
			dataPanelLayout.setRows(3);
			dataPanel.setLayout(dataPanelLayout);
			dataPanel.setBackground(new java.awt.Color(255,255,255));
		}
		return dataPanel;
	}

	public void addDataComponent( Component component ){
		dataPanel.add( component );
	}

	/**
	 * @return Returns the indicatorName.
	 */
	public String getIndicatorDisplayName() {
		return indicatorDisplayName;
	}

	/**
	 * @param indicatorName The indicatorName to set.
	 */
	public void setIndicatorDisplayName(String indicatorName) {
		this.indicatorDisplayName = indicatorName;
		namelabel.setText( indicatorName );
	}
	
	private void rootMouseClicked(MouseEvent evt) {
		fireIndicatorListeners();
	}

	private void fireIndicatorListeners(){
		for (IndicatorListener listener : listeners) {
			listener.clicked( this );
		}
	}
	
	/* (non-Javadoc)
	 * @see java.util.LinkedList#add(E)
	 */
	public boolean addIndicatorListener(IndicatorListener o) {
		return listeners.add(o);
	}

	/* (non-Javadoc)
	 * @see java.util.LinkedList#clear()
	 */
	public void clearIndicatorListeners() {
		listeners.clear();
	}

    public long getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(long lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public void setLastUpdatedNow() {
        this.lastUpdated = System.currentTimeMillis();
    }
    
    private JPopupMenu getPopupMenu() {
        if (popupMenu == null) {
            popupMenu = new JPopupMenu();
            popupMenu.add(getDismissMenuItem());
        }
        return popupMenu;
    }
    
    /**
    * Auto-generated method for setting the popup menu for a component
    */
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }
            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }
        });
    }
    
    private JMenuItem getDismissMenuItem() {
        if (dismissMenuItem == null) {
            dismissMenuItem = new JMenuItem();
            dismissMenuItem.setText("dismiss");
            dismissMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    dismissMenuItemActionPerformed(evt);
                }
            });
        }
        return dismissMenuItem;
    }
    
    private void dismissMenuItemActionPerformed(ActionEvent evt) {
        parentIndicatorPanel.removeIndicator(this);
        
        //TODO add your code for dismissMenuItem.actionPerformed
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    /**
     * @return the category
     */
    public Category getCategory() {
        return category;
    }

    /**
     * @param category the category to set
     */
    public void setCategory(Category category) {
        this.category = category;
    }
}
