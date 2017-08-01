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

package gov.nasa.kepler.ui.config;

import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.ui.config.dr.DataAnomaliesViewEditPanel;
import gov.nasa.kepler.ui.config.dr.DispatcherTriggersViewEditPanel;
import gov.nasa.kepler.ui.config.dr.DrAvailableDatasetsViewEditPanel;
import gov.nasa.kepler.ui.config.general.KeyValuePairViewEditPanel;
import gov.nasa.kepler.ui.config.module.ModuleLibraryViewEditPanel;
import gov.nasa.kepler.ui.config.parameters.ParameterSetsViewEditPanel;
import gov.nasa.kepler.ui.config.pipeline.PipelineGraphCanvas;
import gov.nasa.kepler.ui.config.pipeline.PipelinesContainerNode;
import gov.nasa.kepler.ui.config.pipeline.PipelinesViewEditPanel;
import gov.nasa.kepler.ui.config.security.RolesViewEditPanel;
import gov.nasa.kepler.ui.config.security.UsersViewEditPanel;

import java.awt.CardLayout;
import java.awt.Dimension;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.util.HashMap;

import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.WindowConstants;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ConfigDataPanel extends javax.swing.JPanel {

    private static final Log log = LogFactory.getLog(ConfigDataPanel.class);

    private JPanel logoCard;
    private JLabel logoLabel;
    private PipelinesViewEditPanel pipelinesPanel = null;
    private HashMap<String, PipelineGraphCanvas> pipelineNodesPanelMap = new HashMap<String, PipelineGraphCanvas>();
    private ModuleLibraryViewEditPanel moduleLibraryPanel = null;
    private ParameterSetsViewEditPanel moduleParamSetsPanel = null;
    private DrAvailableDatasetsViewEditPanel availableDatasetsPanel;
    private DataAnomaliesViewEditPanel dataAnomaliesPanel;
    private DispatcherTriggersViewEditPanel dispatcherTriggersPanel;
    private UsersViewEditPanel usersPanel = null;
    private RolesViewEditPanel rolesPanel = null;
    private KeyValuePairViewEditPanel keyValuePanel = null;

    /**
     * Auto-generated main method to display this JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        log.debug("main(String[]) - start");

        JFrame frame = new JFrame();
        frame.getContentPane().add(new ConfigDataPanel());
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);

        log.debug("main(String[]) - end");
    }

    public ConfigDataPanel() {
        super();
        initGUI();
    }

    private void initGUI() {
        log.debug("initGUI() - start");

        try {
            CardLayout thisLayout = new CardLayout();
            this.setLayout(thisLayout);
            setPreferredSize(new Dimension(400, 300));
            this.add(getLogoCard(), "logoCard");
        } catch (Exception e) {
            log.error("initGUI()", e);

            e.printStackTrace();
        }

        log.debug("initGUI() - end");
    }

    private JPanel getLogoCard() {
        log.debug("getLogoCard() - start");

        if (logoCard == null) {
            logoCard = new JPanel();
            GridBagLayout logoCardLayout = new GridBagLayout();
            logoCard.setLayout(logoCardLayout);
            logoCard.setBackground(new java.awt.Color(255, 255, 255));
            logoCard.add(getLogoLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }

        log.debug("getLogoCard() - end");
        return logoCard;
    }

    public void treeSelectionEvent(Object userObject) {
        log.debug("treeSelectionEvent(Object) - start");

        if (userObject instanceof ConfigTree.TreeLabel) {
            ConfigTree.TreeLabel selection = (ConfigTree.TreeLabel) userObject;
            log.debug("selection = " + selection);

            if (selection.equals(ConfigTree.TreeLabel.MODULE_LIBRARY)) {
                displayModuleLibraryPanel();
            } else if (selection.equals(ConfigTree.TreeLabel.PARAMETER_LIBRARY)) {
                displayModuleParamSetsPanel();
            } else if (selection.equals(ConfigTree.TreeLabel.DR_AVAILABLE_DATASETS)) {
                displayAvailableDatasetsPanel();
            } else if (selection.equals(ConfigTree.TreeLabel.DR_DATA_ANOMALIES)) {
                displayDataAnomaliesPanel();
            } else if (selection.equals(ConfigTree.TreeLabel.DR_DISPATCHER_TRIGGER)) {
                displayDispatcherTriggersPanel();
            } else if (selection.equals(ConfigTree.TreeLabel.USERS)) {
                displayUserPanel();
            } else if (selection.equals(ConfigTree.TreeLabel.ROLES)) {
                displayRolePanel();
            } else if (selection.equals(ConfigTree.TreeLabel.GENERAL)) {
                displayKeyValuePanel();
            } else {
                ((CardLayout) getLayout()).show(this, "logoCard");
            }
        } else {
            log.debug("selection class = " + userObject.getClass());

            if (userObject instanceof PipelinesContainerNode) {
                displayPipelinePanel();
            } else if (userObject instanceof PipelineDefinition) {
                displayPipelineNodesPanel((PipelineDefinition) userObject);
            } else {
                ((CardLayout) getLayout()).show(this, "logoCard");
            }
        }

        log.debug("treeSelectionEvent(Object) - end");
    }

    private void displayPipelinePanel() {
        if (pipelinesPanel == null) {
            try {
                pipelinesPanel = new PipelinesViewEditPanel();
                this.add(pipelinesPanel, "pipelinesCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "pipelinesCard");
    }

    private void displayPipelineNodesPanel(PipelineDefinition pipeline) {
        String panelName = "pipelineNodesCard-" + pipeline.getId();
        PipelineGraphCanvas pipelineNodesPanel = pipelineNodesPanelMap.get(panelName);

        if (pipelineNodesPanel == null) {
            try {
                // pipelineNodesPanel = new PipelineNodesViewEditPanel( pipeline
                // );
                pipelineNodesPanel = new PipelineGraphCanvas(pipeline);
                this.add(pipelineNodesPanel, panelName);
                pipelineNodesPanelMap.put(panelName, pipelineNodesPanel);
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, panelName);
    }

    private void displayAvailableDatasetsPanel() {
        if (availableDatasetsPanel == null) {
            try {
                availableDatasetsPanel = new DrAvailableDatasetsViewEditPanel();
                this.add(availableDatasetsPanel, "availableDatasetsCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "availableDatasetsCard");
    }

    private void displayDataAnomaliesPanel() {
        if (dataAnomaliesPanel == null) {
            try {
                dataAnomaliesPanel = new DataAnomaliesViewEditPanel();
                this.add(dataAnomaliesPanel, "dataAnomaliesCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "dataAnomaliesCard");
    }

    private void displayDispatcherTriggersPanel() {
        if (dispatcherTriggersPanel == null) {
            try {
                dispatcherTriggersPanel = new DispatcherTriggersViewEditPanel();
                this.add(dispatcherTriggersPanel, "dispatchersCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "dispatchersCard");
    }

    private void displayUserPanel() {
        if (usersPanel == null) {
            try {
                usersPanel = new UsersViewEditPanel();
                this.add(usersPanel, "usersCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "usersCard");
    }

    private void displayRolePanel() {
        if (rolesPanel == null) {
            try {
                rolesPanel = new RolesViewEditPanel();
                this.add(rolesPanel, "rolesCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "rolesCard");
    }

    private void displayModuleLibraryPanel() {
        if (moduleLibraryPanel == null) {
            try {
                moduleLibraryPanel = new ModuleLibraryViewEditPanel();
                this.add(moduleLibraryPanel, "moduleLibraryCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "moduleLibraryCard");
    }

    private void displayModuleParamSetsPanel() {
        if (moduleParamSetsPanel == null) {
            try {
                moduleParamSetsPanel = new ParameterSetsViewEditPanel();
                this.add(moduleParamSetsPanel, "moduleParamSetsCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "moduleParamSetsCard");
    }

    private void displayKeyValuePanel() {
        if (keyValuePanel == null) {
            try {
                keyValuePanel = new KeyValuePairViewEditPanel();
                this.add(keyValuePanel, "keyValueCard");
            } catch (Throwable e) {
                log.error("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
        ((CardLayout) getLayout()).show(this, "keyValueCard");
    }

    /**
     * Auto-generated method for setting the popup menu for a component
     */
    @SuppressWarnings("unused")
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        log.debug("setComponentPopupMenu(java.awt.Component, javax.swing.JPopupMenu) - start");

        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                log.debug("mousePressed(java.awt.event.MouseEvent) - start");

                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
                log.debug("mousePressed(java.awt.event.MouseEvent) - end");
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                log.debug("mouseReleased(java.awt.event.MouseEvent) - start");

                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
                log.debug("mouseReleased(java.awt.event.MouseEvent) - end");
            }
        });

        log.debug("setComponentPopupMenu(java.awt.Component, javax.swing.JPopupMenu) - end");
    }

    private JLabel getLogoLabel() {
        log.debug("getLogoLabel() - start");

        if (logoLabel == null) {
            logoLabel = new JLabel();
            logoLabel.setIcon(new ImageIcon(getClass().getClassLoader().getResource("images/kepler-logo.jpg")));
        }

        log.debug("getLogoLabel() - end");
        return logoLabel;
    }

}
