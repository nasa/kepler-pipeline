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

import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.gar.HuffmanTable;
import gov.nasa.kepler.hibernate.gar.HuffmanTableDescriptor;
import gov.nasa.kepler.hibernate.gar.RequantTable;
import gov.nasa.kepler.hibernate.gar.RequantTableDescriptor;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.proxy.CompressionCrudProxy;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Dimension;
import java.awt.Font;
import java.util.Arrays;
import java.util.EventObject;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.ListSelectionModel;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventTopicSubscriber;
import org.jdesktop.application.Action;

/**
 * A panel used to select the Huffman and requantization tables.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class CompressionSelectionPanel extends ToolPanel {
    private static final int PREFFERED_TABLE_WIDTH = 300;
    private static final int PREFFERED_TABLE_HEIGHT = 100;

    private static final String MARK_UPLINKED = "markUplinked";

    // Suffix to build enabled property from action.
    private static final String ENABLED = "Enabled";

    /**
     * List of all actions. Note that adding an action here leads to the
     * creation of both menu items and buttons for it.
     */
    private static final String[] actions = new String[] { MARK_UPLINKED };

    private ToolTable huffmanTableDescriptorTable;
    private HuffmanTableDescriptorModel huffmanTableDescriptorModel;
    private ToolTable requantTableDescriptorTable;
    private RequantTableDescriptorModel requantTableDescriptorModel;

    private boolean markUplinkedEnabled;

    private EventTopicSubscriber huffmanTableSelectionListener;
    private EventTopicSubscriber requantTableSelectionListener;
    private HuffmanTableDescriptor huffmanTableDescriptor;
    private RequantTableDescriptor requantTableDescriptor;

    /**
     * Creates a {@link CompressionSelectionPanel}. Whenever the selection
     * changes, a {@link CompressionSelectionEvent} is published on the
     * {@link EventBus}.
     * 
     * @throws UiException if the panel could not be created
     */
    public CompressionSelectionPanel() throws UiException {
        createUi();
    }

    /**
     * Refreshes the data on this panel.
     */
    public void refresh() {
        getData(false);
    }

    /**
     * Replaces the old Huffman and requantization table descriptors with the
     * new ones. This method does not change the selection.
     * 
     * @param oldHuffmanTableDescriptor the old {@link HuffmanTableDescriptor}
     * @param newHuffmanTableDescriptor the new {@link HuffmanTableDescriptor}
     * @param oldRequantTableDescriptor the old {@link RequantTableDescriptor}
     * @param newRequantTableDescriptor the new {@link RequantTableDescriptor}
     */
    public void replace(HuffmanTableDescriptor oldHuffmanTableDescriptor,
        HuffmanTableDescriptor newHuffmanTableDescriptor,
        RequantTableDescriptor oldRequantTableDescriptor,
        RequantTableDescriptor newRequantTableDescriptor) {

        huffmanTableDescriptorModel.replace(oldHuffmanTableDescriptor,
            newHuffmanTableDescriptor);
        if (oldHuffmanTableDescriptor.equals(huffmanTableDescriptor)) {
            huffmanTableDescriptor = newHuffmanTableDescriptor;
        }

        requantTableDescriptorModel.replace(oldRequantTableDescriptor,
            newRequantTableDescriptor);
        if (oldRequantTableDescriptor.equals(requantTableDescriptor)) {
            requantTableDescriptor = newRequantTableDescriptor;
        }

        updateEnabled();
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actions);
    }

    @Override
    protected void initComponents() {
        // Huffman table table.
        JLabel huffmanTableTableLabel = new JLabel();
        huffmanTableTableLabel.setName("huffmanTableTableLabel");
        huffmanTableTableLabel.setFont(huffmanTableTableLabel.getFont()
            .deriveFont(Font.BOLD));

        huffmanTableDescriptorTable = new ToolTable(this);
        JScrollPane huffmanScrollPane = new JScrollPane(
            huffmanTableDescriptorTable);

        // Requant table table.
        JLabel requantTableTableLabel = new JLabel();
        requantTableTableLabel.setName("requantTableTableLabel");
        requantTableTableLabel.setFont(requantTableTableLabel.getFont()
            .deriveFont(Font.BOLD));

        requantTableDescriptorTable = new ToolTable(this);
        JScrollPane requantScrollPane = new JScrollPane(
            requantTableDescriptorTable);

        // Lay out components.
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(huffmanTableTableLabel)
            .addComponent(huffmanScrollPane)
            .addComponent(requantTableTableLabel)
            .addComponent(requantScrollPane));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(huffmanTableTableLabel)
            .addComponent(huffmanScrollPane)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(requantTableTableLabel)
            .addComponent(requantScrollPane));
    }

    @Override
    protected void configureComponents() {
        huffmanTableDescriptorTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        huffmanTableDescriptorTable.setTimeDisplayed(true);
        huffmanTableDescriptorTable.setBooleanRenderer(ToolTable.IMAGE_BOOLEAN_RENDERER);
        huffmanTableDescriptorTable.setHideFalseIcon(true);
        huffmanTableDescriptorTable.setPreferredScrollableViewportSize(new Dimension(
            PREFFERED_TABLE_WIDTH, PREFFERED_TABLE_HEIGHT));
        huffmanTableDescriptorModel = new HuffmanTableDescriptorModel();
        huffmanTableDescriptorTable.setModel(huffmanTableDescriptorModel);

        requantTableDescriptorTable.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        requantTableDescriptorTable.setTimeDisplayed(true);
        requantTableDescriptorTable.setBooleanRenderer(ToolTable.IMAGE_BOOLEAN_RENDERER);
        requantTableDescriptorTable.setHideFalseIcon(true);
        requantTableDescriptorTable.setPreferredScrollableViewportSize(new Dimension(
            PREFFERED_TABLE_WIDTH, PREFFERED_TABLE_HEIGHT));
        requantTableDescriptorModel = new RequantTableDescriptorModel();
        requantTableDescriptorTable.setModel(requantTableDescriptorModel);
    }

    @Override
    protected void getData(boolean block) {
        executeDatabaseTask(CompressionLoadTask.NAME, new CompressionLoadTask());
    }

    @Override
    protected void addListeners() throws UiException {
        huffmanTableSelectionListener = new EventTopicSubscriber() {
            @Override
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                @SuppressWarnings("rawtypes")
                List list = (List) data;
                if (list.size() > 0) {
                    huffmanTableDescriptor = (HuffmanTableDescriptor) list.get(0);
                    EventBus.publish(new CompressionSelectionEvent(
                        CompressionSelectionPanel.this, huffmanTableDescriptor,
                        requantTableDescriptor));
                }
                updateEnabled();
            }
        };
        EventBus.subscribe(huffmanTableDescriptorTable.getSelectionTopic(),
            huffmanTableSelectionListener);

        requantTableSelectionListener = new EventTopicSubscriber() {
            @Override
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                @SuppressWarnings("rawtypes")
                List list = (List) data;
                if (list.size() > 0) {
                    requantTableDescriptor = (RequantTableDescriptor) list.get(0);
                    EventBus.publish(new CompressionSelectionEvent(
                        CompressionSelectionPanel.this, huffmanTableDescriptor,
                        requantTableDescriptor));
                }
                updateEnabled();
            }
        };
        EventBus.subscribe(requantTableDescriptorTable.getSelectionTopic(),
            requantTableSelectionListener);
    }

    @Override
    protected void updateEnabled() {
        setMarkUplinkedEnabled(true);
    }

    /**
     * Mark selected compression tables as uplinked.
     */
    @Action(enabledProperty = MARK_UPLINKED + ENABLED)
    public void markUplinked() {
        log.info(resourceMap.getString(MARK_UPLINKED,
            huffmanTableDescriptor.getExternalId()));
        if (reloadingData()) {
            handleError(null, MARK_UPLINKED + RELOADING_DATA,
                huffmanTableDescriptor.getExternalId());
            return;
        }

        // Nag user (since you can't edit compression tables after doing this).
        if (warnUser(MARK_UPLINKED, huffmanTableDescriptor.getExternalId())) {
            return;
        }

        executeDatabaseTask(UpdateTask.NAME, new UpdateTask(
            huffmanTableDescriptor, requantTableDescriptor, State.UPLINKED));
    }

    public boolean isMarkUplinkedEnabled() {
        return markUplinkedEnabled;
    }

    public void setMarkUplinkedEnabled(boolean markUplinkedEnabled) {
        boolean oldValue = this.markUplinkedEnabled;
        this.markUplinkedEnabled = markUplinkedEnabled
            && huffmanTableDescriptor != null
            && requantTableDescriptor != null
            && !(huffmanTableDescriptor.getState() == State.UPLINKED && requantTableDescriptor.getState() == State.UPLINKED)
            && huffmanTableDescriptor.getExternalId() == requantTableDescriptor.getExternalId()
            && huffmanTableDescriptor.getExternalId() != ExportTable.INVALID_EXTERNAL_ID
            && huffmanTableDescriptor.getPlannedStartTime() != null
            && huffmanTableDescriptor.getPlannedStartTime()
                .equals(requantTableDescriptor.getPlannedStartTime());
        firePropertyChange(MARK_UPLINKED + ENABLED, oldValue,
            this.markUplinkedEnabled);
    }

    /**
     * An event used when broadcasting updates to the selection.
     * 
     * @author Bill Wohler
     */
    // There is already a serialVersionUID field in EventObject.
    //@edu.umd.cs.findbugs.annotations.SuppressWarnings("SnVI")
    public static class CompressionSelectionEvent extends EventObject {
        private transient HuffmanTableDescriptor huffmanTableDescriptor;
        private transient RequantTableDescriptor requantTableDescriptor;

        /**
         * Creates an {@link CompressionSelectionEvent} with the given source,
         * Huffman, and requantization tables.
         * 
         * @param source the source of this event
         * @param huffmanTableDescriptor the selected
         * {@link HuffmanTableDescriptor} (may be {@code null})
         * @param requantTableDescriptor the selected
         * {@link RequantTableDescriptor} (may be {@code null})
         */
        public CompressionSelectionEvent(Object source,
            HuffmanTableDescriptor huffmanTableDescriptor,
            RequantTableDescriptor requantTableDescriptor) {

            super(source);
            this.huffmanTableDescriptor = huffmanTableDescriptor;
            this.requantTableDescriptor = requantTableDescriptor;
        }

        /**
         * Returns the selected {@link HuffmanTableDescriptor}.
         * 
         * @return a {@link HuffmanTableDescriptor}, may be {@code null} if none
         * is selected
         */
        public HuffmanTableDescriptor getHuffmanTableDescriptor() {
            return huffmanTableDescriptor;
        }

        /**
         * Returns the selected {@link RequantTableDescriptor}.
         * 
         * @return a {@link RequantTableDescriptor}, may be {@code null} if none
         * is selected
         */
        public RequantTableDescriptor getRequantTableDescriptor() {
            return requantTableDescriptor;
        }
    }

    /**
     * A task for loading Huffman and requantization entries from the database
     * in the background.
     * 
     * @author Bill Wohler
     */
    private class CompressionLoadTask extends DatabaseTask<Void, Void> {

        private static final String NAME = "CompressionLoadTask";

        private List<HuffmanTableDescriptor> huffmanTableDescriptors;
        private List<RequantTableDescriptor> requantTableDescriptors;

        @Override
        protected Void doInBackground() throws Exception {
            log.info(resourceMap.getString(NAME + ".loading"));
            EventBus.publish(new StatusEvent(CompressionSelectionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .started());

            CompressionCrudProxy compressionCrud = new CompressionCrudProxy();
            huffmanTableDescriptors = compressionCrud.retrieveAllHuffmanTableDescriptors();
            requantTableDescriptors = compressionCrud.retrieveAllRequantTableDescriptors();

            log.info(resourceMap.getString(NAME + ".loaded",
                huffmanTableDescriptors.size(), requantTableDescriptors.size()));

            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(CompressionSelectionPanel.this, e, NAME);
            EventBus.publish(new StatusEvent(CompressionSelectionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .failed());
        }

        @Override
        protected void succeeded(Void result) {
            huffmanTableDescriptor = null;
            requantTableDescriptor = null;

            huffmanTableDescriptorModel.setHuffmanTableDescriptors(huffmanTableDescriptors);
            if (huffmanTableDescriptors.size() > 0) {
                huffmanTableDescriptorTable.getSelectionModel()
                    .setSelectionInterval(0, 0);
            }
            requantTableDescriptorModel.setRequantTableDescriptors(requantTableDescriptors);
            if (requantTableDescriptors.size() > 0) {
                requantTableDescriptorTable.getSelectionModel()
                    .setSelectionInterval(0, 0);
            }
            setDataValid(true);

            EventBus.publish(new StatusEvent(CompressionSelectionPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .done());
        }
    }

    /**
     * A task for updating compression tables. The action parameter in the
     * constructor is used for constructing an error dialog with
     * KeplerPanel#handleError().
     * 
     * @author Bill Wohler
     */
    private class UpdateTask extends DatabaseTask<Void, Void> {
        private static final String NAME = "UpdateTask";

        private State state;
        private HuffmanTableDescriptor huffmanTableDescriptor;
        private RequantTableDescriptor requantTableDescriptor;

        public UpdateTask(HuffmanTableDescriptor huffmanTableDescriptor,
            RequantTableDescriptor requantTableDescriptor, State state) {
            this.huffmanTableDescriptor = huffmanTableDescriptor;
            this.requantTableDescriptor = requantTableDescriptor;
            this.state = state;
        }

        @Override
        protected Void doInBackground() throws Exception {
            CompressionCrudProxy compressionCrud = new CompressionCrudProxy();

            HuffmanTable huffmanTable = compressionCrud.retrieveHuffmanTable(huffmanTableDescriptor.getId());
            huffmanTable.setState(state);
            compressionCrud.createHuffmanTable(huffmanTable);
            huffmanTableDescriptor = new HuffmanTableDescriptor(huffmanTable);

            RequantTable requantTable = compressionCrud.retrieveRequantTable(requantTableDescriptor.getId());
            requantTable.setState(state);
            compressionCrud.createRequantTable(requantTable);
            requantTableDescriptor = new RequantTableDescriptor(requantTable);

            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(CompressionSelectionPanel.this, e, MARK_UPLINKED,
                huffmanTableDescriptor.getExternalId());
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }

        @Override
        protected void succeeded(Void dummy) {
            replace(CompressionSelectionPanel.this.huffmanTableDescriptor,
                huffmanTableDescriptor,
                CompressionSelectionPanel.this.requantTableDescriptor,
                requantTableDescriptor);

            CompressionSelectionPanel.this.huffmanTableDescriptor = huffmanTableDescriptor;
            CompressionSelectionPanel.this.requantTableDescriptor = requantTableDescriptor;

            EventBus.publish(new CompressionSelectionEvent(
                CompressionSelectionPanel.this, huffmanTableDescriptor,
                requantTableDescriptor));

            updateEnabled();
        }
    }
}
