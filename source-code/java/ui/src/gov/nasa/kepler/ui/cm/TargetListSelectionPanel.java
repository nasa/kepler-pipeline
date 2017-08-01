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

import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.PanelHeader;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Font;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.WindowConstants;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventTopicSubscriber;
import org.bushe.swing.event.generics.TypeReference;
import org.jdesktop.application.Action;

/**
 * A panel used for selecting target lists. Use {@link #getTargetLists()} to
 * create a modal dialog and return the selected target lists. This list will be
 * empty if the user cancelled.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD_STORE")
public class TargetListSelectionPanel extends ToolPanel {

    private static final String NAME = "targetListSelectionPanel";

    private static final String SELECT = "select";
    private static final String CANCEL = "cancel";
    private static final String ENABLED = "Enabled";

    private boolean selectEnabled;

    private String[] actionStrings = new String[] { DEFAULT_ACTION_CHAR
        + SELECT };

    private ToolTable targetListTable;
    private JButton selectButton;

    private List<TargetList> targetLists = Collections.emptyList();

    private EventTopicSubscriber targetListSelectionListener = new TargetListSelectionListener();

    /**
     * Creates a {@link TargetListSelectionPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public TargetListSelectionPanel() throws UiException {
        createUi();
    }

    @Override
    protected void initComponents() throws UiException {
        PanelHeader panelHeader = new PanelHeader();
        panelHeader.setName("header");

        JLabel targetListsLabel = new JLabel();
        targetListsLabel.setName("targetListsLabel");
        targetListsLabel.setFont(targetListsLabel.getFont()
            .deriveFont(Font.BOLD));

        TargetListTableModel targetListModel = new TargetListTableModel();
        targetListModel.setTargetLists(lookUpTargetLists());
        targetListTable = new ToolTable(targetListModel, this);
        EventBus.subscribe(targetListTable.getSelectionTopic(),
            targetListSelectionListener);
        JScrollPane scrollPane = new JScrollPane(targetListTable);

        JSeparator separator = new JSeparator();
        selectButton = new JButton(actionMap.get(SELECT));
        JButton cancelButton = new JButton(actionMap.get(CANCEL));

        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);

        layout.setAutoCreateGaps(true);
        layout.setAutoCreateContainerGaps(true);
        layout.linkSize(selectButton, cancelButton);

        layout.setHorizontalGroup(layout.createParallelGroup(Alignment.LEADING)
            .addComponent(targetListsLabel)
            .addComponent(scrollPane)
            .addComponent(separator)
            .addGroup(
                layout.createSequentialGroup()
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(cancelButton)
                    .addComponent(selectButton)));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(targetListsLabel)
            .addComponent(scrollPane)
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(separator, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addGroup(layout.createParallelGroup()
                .addComponent(cancelButton)
                .addComponent(selectButton)));

        GroupLayout panelLayout = new GroupLayout(this);
        setLayout(panelLayout);

        panelLayout.setHorizontalGroup(panelLayout.createParallelGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
        panelLayout.setVerticalGroup(panelLayout.createSequentialGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
    }

    /**
     * Asks the system for a list of target lists.
     * 
     * @return a non-{@code null} list of {@link TargetList}s
     */
    private List<TargetList> lookUpTargetLists() {
        DataRequestEvent<List<TargetList>> request = new DataRequestEvent<List<TargetList>>();
        EventBus.publish(
            new TypeReference<DataRequestEvent<List<TargetList>>>() {
            }.getType(), request);

        if (request.getData() == null) {
            return new ArrayList<TargetList>();
        }

        return request.getData();
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actionStrings);
    }

    @Override
    protected JButton getDefaultButton() {
        return selectButton;
    }

    @Override
    protected void updateEnabled() {
        setSelectEnabled(true);
    }

    /**
     * Displays all target lists and allows user to select them. A list of these
     * selected lists is returned.
     * 
     * @return a list of {@link TargetList}s
     * @throws UiException if the panel could not be created
     */
    public static List<TargetList> getTargetLists() throws UiException {
        JDialog dialog = new JDialog();
        dialog.setName(NAME);
        dialog.setModal(true);
        final TargetListSelectionPanel panel = new TargetListSelectionPanel();
        dialog.add(panel);
        panel.setTitle(false);
        dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
        dialog.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                panel.dismissDialog();
            }
        });
        panel.initDefaultKeys();
        app.show(dialog);

        return panel.targetLists;
    }

    /**
     * Confirms the current selection.
     */
    @Action(enabledProperty = SELECT + ENABLED)
    public void select() {
        log.info(resourceMap.getString(SELECT, targetLists));
        dismissDialog();
    }

    public boolean isSelectEnabled() {
        return selectEnabled;
    }

    public void setSelectEnabled(boolean selectEnabled) {
        boolean oldValue = this.selectEnabled;
        this.selectEnabled = targetLists.size() > 0;
        firePropertyChange(SELECT + ENABLED, oldValue, this.selectEnabled);
    }

    /**
     * Discards the changes to the target list set.
     */
    @Action
    public void cancel() {
        log.info(resourceMap.getString(CANCEL));
        targetLists = Collections.emptyList();
        dismissDialog();
    }

    /**
     * Target list selection listener.
     * 
     * @author Bill Wohler
     */
    private class TargetListSelectionListener implements EventTopicSubscriber {

        @Override
        @SuppressWarnings("unchecked")
        public void onEvent(String topic, Object data) {
            log.debug("topic=" + topic + ", data=" + data);
            targetLists = (List<TargetList>) data;
            updateEnabled();
        }
    }
}
