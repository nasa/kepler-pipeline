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

package gov.nasa.kepler.ui.cm;

import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.PanelHeader;
import gov.nasa.kepler.ui.swing.ToolPanel;

import java.util.ArrayList;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.JPanel;

import org.jdesktop.application.Action;

/**
 * A panel used to do target management. This panel displays all known target
 * list and target list sets, and provides a means to add, delete, and modify
 * them.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetManagementPanel extends ToolPanel {
    private static final String NAME = "targetManagementPanel";

    private ToolPanel targetListSetsPanel;
    private ToolPanel targetListsPanel;

    /**
     * Creates a {@link TargetManagementPanel}.
     * 
     * @throws UiException if the panel could not be created.
     */
    public TargetManagementPanel() throws UiException {
        setName(NAME);
        createUi();
    }

    @Override
    protected void initComponents() throws UiException {
        PanelHeader panelHeader = new PanelHeader();
        panelHeader.setName("header");

        targetListSetsPanel = new TargetListSetsPanel();
        targetListsPanel = new TargetListsPanel();

        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(targetListSetsPanel)
            .addComponent(targetListsPanel));
        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(targetListSetsPanel)
            .addComponent(targetListsPanel));

        GroupLayout panelLayout = new GroupLayout(this);
        setLayout(panelLayout);

        panelLayout.setHorizontalGroup(panelLayout.createParallelGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
        panelLayout.setVerticalGroup(panelLayout.createSequentialGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
    }

    @Override
    protected List<String> getActionStrings() {
        // TODO Fix
        List<String> actions = new ArrayList<String>();
        // actions.addAll(targetListSetsPanel.getActionStrings());
        // actions.addAll(targetListsPanel.getActionStrings());

        return actions;
    }

    @Override
    protected void updateEnabled() {
    }

    /**
     * Generate target management menu.
     */
    @Action
    public void targetManagement() {
    }
}
