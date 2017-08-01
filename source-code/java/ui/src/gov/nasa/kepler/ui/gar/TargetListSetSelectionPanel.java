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

package gov.nasa.kepler.ui.gar;

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.proxy.TargetSelectionCrudProxy;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Dimension;
import java.awt.Font;
import java.util.Collections;
import java.util.EventObject;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.JLabel;
import javax.swing.JScrollPane;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventTopicSubscriber;

/**
 * A panel used to select the target list sets.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListSetSelectionPanel extends ToolPanel {
    private static final int PREFFERED_TABLE_WIDTH = 300;
    private static final int PREFFERED_TABLE_HEIGHT = 100;

    private ToolTable targetListSetTable;
    private TargetListSetTableModel targetListSetModel;

    private EventTopicSubscriber targetListSetSelectionListener;

    /**
     * Creates a {@link TargetListSetSelectionPanel}. Whenever the selection
     * changes, a {@link TargetListSetSelectionEvent} is published on the
     * {@link EventBus}.
     * 
     * @throws UiException if the panel could not be created
     */
    public TargetListSetSelectionPanel() throws UiException {
        createUi();
    }

    /**
     * Refreshes the data on this panel.
     */
    public void refresh() {
        getData(false);
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    @Override
    protected List<String> getActionStrings() {
        return Collections.emptyList();
    }

    @Override
    protected void initComponents() {
        JLabel targetListSetTableLabel = new JLabel();
        targetListSetTableLabel.setName("targetListSetTableLabel");
        targetListSetTableLabel.setFont(targetListSetTableLabel.getFont()
            .deriveFont(Font.BOLD));

        targetListSetTable = new ToolTable(this);
        JScrollPane targetListSetScrollPane = new JScrollPane(
            targetListSetTable);

        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(targetListSetTableLabel)
            .addComponent(targetListSetScrollPane));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(targetListSetTableLabel)
            .addComponent(targetListSetScrollPane));
    }

    @Override
    protected void configureComponents() {
        targetListSetTable.setPreferredScrollableViewportSize(new Dimension(
            PREFFERED_TABLE_WIDTH, PREFFERED_TABLE_HEIGHT));
        targetListSetModel = new TargetListSetTableModel();
        targetListSetTable.setModel(targetListSetModel);
        targetListSetTable.setBooleanRenderer(ToolTable.IMAGE_BOOLEAN_RENDERER);
        targetListSetTable.setHideFalseIcon(true);
    }

    @Override
    protected void getData(boolean block) {
        executeDatabaseTask(TargetListSetLoadTask.NAME,
            new TargetListSetLoadTask());
    }

    @Override
    protected void addListeners() {
        targetListSetSelectionListener = new EventTopicSubscriber() {
            @Override
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                @SuppressWarnings("unchecked")
                List<TargetListSet> targetListSets = (List<TargetListSet>) data;
                EventBus.publish(new TargetListSetSelectionEvent(
                    TargetListSetSelectionPanel.this, targetListSets));
            }
        };
        EventBus.subscribe(targetListSetTable.getSelectionTopic(),
            targetListSetSelectionListener);
    }

    @Override
    protected void updateEnabled() {
    }

    /**
     * An event used when broadcasting updates to the selection.
     * 
     * @author Bill Wohler
     */
    public static class TargetListSetSelectionEvent extends EventObject {
        private List<TargetListSet> targetListSets;

        /**
         * Creates an {@link TargetListSetSelectionEvent} with the given source
         * and {@link TargetListSet}s.
         * 
         * @param source the source of this event
         * @param targetListSets the selected {@link TargetListSet}s (may be
         * {@code null})
         */
        public TargetListSetSelectionEvent(Object source,
            List<TargetListSet> targetListSets) {

            super(source);
            this.targetListSets = targetListSets;
        }

        /**
         * Returns the selected {@link TargetListSet}s.
         * 
         * @return a list of {@link TargetListSet}s, may be {@code null} if none
         * is selected.
         */
        public List<TargetListSet> getTargetListSets() {
            return targetListSets;
        }

        @Override
        public String toString() {
            return super.toString() + ", targetListSets=" + targetListSets;
        }
    }

    /**
     * A task for loading {@link TargetListSet}s from the database in the
     * background.
     * 
     * @author Bill Wohler
     */
    private class TargetListSetLoadTask extends
        DatabaseTask<List<TargetListSet>, Void> {

        private static final String NAME = "TargetListSetLoadTask";

        @Override
        protected List<TargetListSet> doInBackground() throws Exception {
            log.info(resourceMap.getString(NAME + ".loading"));
            EventBus.publish(new StatusEvent(TargetListSetSelectionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .started());

            DatabaseServiceFactory.getInstance()
                .evictAll(targetListSetModel.getTargetListSets());
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            List<TargetListSet> targetListSets = targetSelectionCrud.retrieveTargetListSets(
                State.TAD_COMPLETED, State.UPLINKED);

            log.info(resourceMap.getString(NAME + ".loaded",
                targetListSets.size()));

            return targetListSets;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetSelectionPanel.this, e, NAME);
            EventBus.publish(new StatusEvent(TargetListSetSelectionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .failed());
        }

        @Override
        protected void succeeded(List<TargetListSet> targetListSets) {
            targetListSetModel.setTargetListSets(targetListSets);
            EventBus.publish(new StatusEvent(TargetListSetSelectionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .done());
        }
    }
}