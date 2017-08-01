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
import gov.nasa.kepler.services.process.PipelineProcessAdminRequest;
import gov.nasa.kepler.services.process.PipelineProcessAdminRequest.BasicRequestType;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.kepler.ui.proxy.PipelineProcessAdminProxy;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPopupMenu;

public class ProcessIndicator extends Indicator {
    private static final long serialVersionUID = -5828233116180226266L;

    LabelValue hostLV = new LabelValue( "host", "quantum:21434" );
	LabelValue stateLV = new LabelValue( "state", "Running" );
    private JPopupMenu popupMenu;
    private JMenuItem shutdownMenuItem;
    private JMenuItem restartMenuItem;
    private JMenuItem resumeMenuItem;
    private JMenuItem pauseMenuItem;
	LabelValue uptimeLV = new LabelValue( "UT", "12d 03h 16m 34s" );

    private ProcessInfo processInfo = null;
    
    public ProcessIndicator(IndicatorPanel parentIndicatorPanel, String name, ProcessInfo processInfo) {
        super(parentIndicatorPanel, name);
        this.processInfo = processInfo;
        setIndicatorDisplayName(getHost());
        initGUI();
    }

    public ProcessIndicator(IndicatorPanel parentIndicatorPanel, String name, String host, String state, String uptime, ProcessInfo processInfo) {
        super(parentIndicatorPanel, name);
        this.processInfo = processInfo;
        hostLV.setValue(host);
        stateLV.setValue(state);
        uptimeLV.setValue(uptime);
        initGUI();
    }

    private void initGUI(){
        this.setPreferredSize(new java.awt.Dimension(220, 70));
        setComponentPopupMenu(this, getPopupMenu());

        addDataComponent( hostLV );
        addDataComponent( stateLV );
        addDataComponent( uptimeLV );
    }
    
    /**
	 * @return Returns the host.
	 */
	public String getHost() {
		return hostLV.getValue();
	}

	/**
	 * @param host The host to set.
	 */
	public void setHost(String host) {
		hostLV.setValue( host );
	}

	/**
	 * @return Returns the state.
	 */
	public String getState() {
		return stateLV.getValue();
	}

	/**
	 * @param state The state to set.
	 */
	public void setState(String state) {
		stateLV.setValue( state );
	}

	/**
	 * @return Returns the uptime.
	 */
	public String getUptime() {
		return uptimeLV.getValue();
	}

	/**
	 * @param uptime The uptime to set.
	 */
	public void setUptime(String uptime) {
		uptimeLV.setValue( uptime );
	}
    
    private JPopupMenu getPopupMenu() {
        if (popupMenu == null) {
            popupMenu = new JPopupMenu();
            popupMenu.add(getPauseMenuItem());
            popupMenu.add(getResumeMenuItem());
            popupMenu.add(getRestartMenuItem());
            popupMenu.add(getShutdownMenuItem());
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
    
    private JMenuItem getPauseMenuItem() {
        if (pauseMenuItem == null) {
            pauseMenuItem = new JMenuItem();
            pauseMenuItem.setText("pause work");
            pauseMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    pauseMenuItemActionPerformed(evt);
                }
            });
        }
        return pauseMenuItem;
    }
    
    private void pauseMenuItemActionPerformed(ActionEvent evt) {

        try {
            PipelineProcessAdminProxy ops = new PipelineProcessAdminProxy();

            if(processInfo != null){
                // TODO: support setting abort flag
                ops.adminRequest(processInfo.getName(), processInfo.getHost(), new PipelineProcessAdminRequest(BasicRequestType.PAUSE, true));
            }
            
        } catch (PipelineException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
        
    }
    
    private JMenuItem getResumeMenuItem() {
        if (resumeMenuItem == null) {
            resumeMenuItem = new JMenuItem();
            resumeMenuItem.setText("resume work");
            resumeMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    resumeMenuItemActionPerformed(evt);
                }
            });
        }
        return resumeMenuItem;
    }
    
    private void resumeMenuItemActionPerformed(ActionEvent evt) {
        try {
            PipelineProcessAdminProxy ops = new PipelineProcessAdminProxy();

            if(processInfo != null){
                // TODO: support setting abort flag
                ops.adminRequest(processInfo.getName(), processInfo.getHost(), new PipelineProcessAdminRequest(BasicRequestType.RESUME));
            }
            
        } catch (PipelineException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private JMenuItem getRestartMenuItem() {
        if (restartMenuItem == null) {
            restartMenuItem = new JMenuItem();
            restartMenuItem.setText("restart process");
            restartMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    restartMenuItemActionPerformed(evt);
                }
            });
        }
        return restartMenuItem;
    }
    
    private void restartMenuItemActionPerformed(ActionEvent evt) {

        try {
            PipelineProcessAdminProxy ops = new PipelineProcessAdminProxy();

            if(processInfo != null){
                // TODO: support setting abort flag
                ops.adminRequest(processInfo.getName(), processInfo.getHost(), new PipelineProcessAdminRequest(BasicRequestType.RESTART, true));
            }
            
        } catch (PipelineException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private JMenuItem getShutdownMenuItem() {
        if (shutdownMenuItem == null) {
            shutdownMenuItem = new JMenuItem();
            shutdownMenuItem.setText("shutdown process");
            shutdownMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    shutdownMenuItemActionPerformed(evt);
                }
            });
        }
        return shutdownMenuItem;
    }
    
    private void shutdownMenuItemActionPerformed(ActionEvent evt) {
        try {
            PipelineProcessAdminProxy ops = new PipelineProcessAdminProxy();

            if(processInfo != null){
                // TODO: support setting abort flag
                ops.adminRequest(processInfo.getName(), processInfo.getHost(), new PipelineProcessAdminRequest(BasicRequestType.SHUTDOWN, true));
            }
            
        } catch (PipelineException e) {
            e.printStackTrace();
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
    }
}
