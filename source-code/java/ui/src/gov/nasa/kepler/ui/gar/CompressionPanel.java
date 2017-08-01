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
import gov.nasa.kepler.ui.gar.CompressionSelectionPanel.CompressionSelectionEvent;
import gov.nasa.kepler.ui.gar.ExternalIdChooser.ExternalIdEvent;
import gov.nasa.kepler.ui.gar.StartTimeChooser.StartTimeEvent;
import gov.nasa.kepler.ui.gar.TableExportPanel.Helper;
import gov.nasa.kepler.ui.proxy.CompressionCrudProxy;
import gov.nasa.kepler.ui.proxy.GarOperationsProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;

import java.io.File;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
import java.util.Set;

import javax.swing.JComponent;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.jdesktop.application.Action;

/**
 * Exports Huffman and requantization tables.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class CompressionPanel extends ExportTablePanel {

    private CompressionSelectionPanel tableSelectionPanel = new CompressionSelectionPanel();
    private EventSubscriber<CompressionSelectionEvent> compressionSelectionListener;
    private HuffmanTable huffmanTable;
    private HuffmanTableDescriptor huffmanTableDescriptor;
    private RequantTable requantTable;
    private RequantTableDescriptor requantTableDescriptor;

    private ExternalIdChooser externalIdPanel = new ExternalIdChooser();
    private EventSubscriber<ExternalIdEvent> externalIdListener;
    private Set<Integer> uplinkedExternalIds;
    private Set<Integer> externalIdsInUse;
    private int externalId = ExportTable.INVALID_EXTERNAL_ID;
    private int dbExternalId = ExportTable.INVALID_EXTERNAL_ID;

    private StartTimeChooser startTimePanel = new StartTimeChooser();
    private EventSubscriber<StartTimeEvent> startTimeListener;
    private Date startTime;

    private CompressionSummaryPanel summaryPanel = new CompressionSummaryPanel();

    private JComponent[] panels = new JComponent[] { tableSelectionPanel,
        startTimePanel, externalIdPanel, summaryPanel };

    /**
     * Creates a {@link CompressionPanel}.
     * 
     * @param helper a means for displaying help
     * @throws UiException if the panel could not be created
     */
    public CompressionPanel(Helper helper) throws UiException {
        super(helper);
        createUi();
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    @Override
    protected List<JComponent> getPanels() {
        return Arrays.asList(panels);
    }

    @Override
    @Action(enabledProperty = REFRESH + ENABLED)
    public void refresh() {
        log.info(resourceMap.getString(REFRESH));
        getData(false);
    }

    @Override
    @Action(enabledProperty = PREVIOUS + ENABLED)
    public void previous() {
        if (reloadingData()) {
            handleError(null, PREVIOUS + RELOADING_DATA);
            show(tableSelectionPanel);
            return;
        }

        if (currentPanel() == summaryPanel
            && huffmanTableDescriptor.getState() == State.UPLINKED
            && requantTableDescriptor.getState() == State.UPLINKED) {
            show(tableSelectionPanel);
        } else {
            super.previous();
        }
    }

    @Override
    protected boolean readyForNext() {
        if (currentPanel() == tableSelectionPanel) {
            return conditionalHelp(huffmanTableDescriptor != null,
                "selectHuffmanTable.help")
                && conditionalHelp(requantTableDescriptor != null,
                    "selectRequantTable.help")
                && conditionalHelp(
                    huffmanTableDescriptor.getState() != State.UPLINKED
                        && requantTableDescriptor.getState() != State.UPLINKED
                        || huffmanTableDescriptor.getState() == State.UPLINKED
                        && requantTableDescriptor.getState() == State.UPLINKED
                        && huffmanTableDescriptor.getExternalId() == requantTableDescriptor.getExternalId(),
                    "tableSelection.help");
        } else if (currentPanel() == startTimePanel) {
            return conditionalHelp(startTime != null, "validStartTime.help");
        } else if (currentPanel() == externalIdPanel) {
            return conditionalHelp(externalId > 0
                && externalId <= ExportTable.MAX_EXTERNAL_ID
                && !uplinkedExternalIds.contains(externalId),
                "validTableId.help");
        }

        return false;
    }

    @Override
    @Action(enabledProperty = NEXT + ENABLED)
    public void next() {
        if (reloadingData()) {
            handleError(null, NEXT + RELOADING_DATA);
            show(tableSelectionPanel);
            return;
        }

        if (currentPanel() == tableSelectionPanel) {
            if (huffmanTableDescriptor.getExternalId() != requantTableDescriptor.getExternalId()
                && warnUser(NEXT + ".matching")) {
                return;
            }
            dbExternalId = externalId;
            if (huffmanTableDescriptor.getState() == State.UPLINKED
                && requantTableDescriptor.getState() == State.UPLINKED) {
                summaryPanel.setHuffmanTaskId(huffmanTableDescriptor.getPipelineTaskId());
                summaryPanel.setRequantTaskId(requantTableDescriptor.getPipelineTaskId());
                summaryPanel.setExternalId(externalId);
                summaryPanel.setStartTime(startTime);
                show(summaryPanel);
            } else {
                super.next();
            }
        } else if (currentPanel() == startTimePanel) {
            if (externalId == ExportTable.INVALID_EXTERNAL_ID) {
                externalId = lowestAvailableExternalId(externalIdsInUse,
                    uplinkedExternalIds);
                if (externalId == ExportTable.INVALID_EXTERNAL_ID) {
                    warnUser(NEXT + ".gameOver");
                }
            }
            super.next();
        } else if (currentPanel() == externalIdPanel) {
            if (externalId != dbExternalId
                && externalIdsInUse.contains(externalId)
                && warnUser(NEXT + ".used", externalId)) {
                return;
            }
            executeDatabaseTask(TableUpdateTask.NAME, new TableUpdateTask());
            // Will call super.next() from task.
        } else {
            super.next();
        }
    }

    /**
     * Displays the summary page, but only from the external ID page, as this
     * method simply calls {@code super.next()}.
     */
    private void displaySummary() {
        super.next();
    }

    @Override
    protected boolean readyToExport() {
        return currentPanel() == summaryPanel;
    }

    @Override
    @Action(enabledProperty = EXPORT + ENABLED)
    public void export() {
        log.info(resourceMap.getString(EXPORT,
            huffmanTableDescriptor.getPipelineTaskId(),
            requantTableDescriptor.getPipelineTaskId()));
        if (reloadingData()) {
            handleError(null, EXPORT + RELOADING_DATA);
            show(tableSelectionPanel);
            return;
        }

        try {
            File file = KeplerDialogs.showSaveDirectoryChooserDialog(this);
            if (file == null) {
                return;
            }
            if (!file.canWrite()) {
                throw new IllegalArgumentException(resourceMap.getString(EXPORT
                    + ".cantWrite", file));
            }

            executeDatabaseTask(EXPORT, new ExportTask(file));
        } catch (Exception e) {
            handleError(this, e, EXPORT,
                huffmanTableDescriptor.getPipelineTaskId(),
                requantTableDescriptor.getPipelineTaskId());
        }
    }

    @Override
    protected void configureComponents() throws UiException {
        super.configureComponents();
        summaryPanel.setDefaultFocusComponent(getExportButton());
    }

    @Override
    protected void getData(boolean block) {
        super.getData(block);
        executeDatabaseTask(ExternalIdLookupTask.NAME,
            new ExternalIdLookupTask());

        // Also refresh the CompressionSelectionPanel except for the first
        // time here, since the panel will initialize itself.
        if (externalIdsInUse != null) {
            tableSelectionPanel.refresh();
        }
    }

    @Override
    protected void addListeners() throws UiException {
        super.addListeners();

        compressionSelectionListener = new EventSubscriber<CompressionSelectionEvent>() {
            @Override
            public void onEvent(CompressionSelectionEvent e) {
                log.debug(e);
                huffmanTableDescriptor = e.getHuffmanTableDescriptor();
                requantTableDescriptor = e.getRequantTableDescriptor();
                externalId = huffmanTableDescriptor.getExternalId();
                startTime = huffmanTableDescriptor.getPlannedStartTime();
                externalIdPanel.setExternalId(externalId);
                startTimePanel.setStartTime(startTime);
                updateEnabled();
            }
        };
        EventBus.subscribe(CompressionSelectionEvent.class,
            compressionSelectionListener);

        externalIdListener = new EventSubscriber<ExternalIdEvent>() {
            @Override
            public void onEvent(ExternalIdEvent e) {
                log.debug(e);
                if (e.getSource() != externalIdPanel) {
                    return;
                }
                externalId = e.getExternalId();
                updateEnabled();
            }
        };
        EventBus.subscribe(ExternalIdEvent.class, externalIdListener);

        startTimeListener = new EventSubscriber<StartTimeEvent>() {
            @Override
            public void onEvent(StartTimeEvent e) {
                log.debug(e);
                if (e.getSource() != startTimePanel) {
                    return;
                }
                startTime = e.getStartTime();
                updateEnabled();
            }
        };
        EventBus.subscribe(StartTimeEvent.class, startTimeListener);
    }

    /**
     * A task for looking up sets of external IDs.
     * 
     * @author Bill Wohler
     */
    private class ExternalIdLookupTask extends DatabaseTask<Void, Void> {

        private static final String NAME = "ExternalIdLookupTask";
        private Set<Integer> uplinkedExternalIds;
        private Set<Integer> externalIdsInUse;

        @Override
        protected Void doInBackground() throws Exception {
            log.info(resourceMap.getString(NAME + ".loading"));

            CompressionCrudProxy compressionCrud = new CompressionCrudProxy();
            uplinkedExternalIds = compressionCrud.retrieveUplinkedExternalIds();
            externalIdsInUse = compressionCrud.retrieveExternalIdsInUse();

            log.info(resourceMap.getString(NAME + ".loaded",
                externalIdsInUse.size(), uplinkedExternalIds.size()));

            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(CompressionPanel.this, e, NAME);
        }

        @Override
        protected void succeeded(Void result) {
            CompressionPanel.this.uplinkedExternalIds = uplinkedExternalIds;
            CompressionPanel.this.externalIdsInUse = externalIdsInUse;
            setDataValid(true);
        }
    }

    /**
     * A task for saving modified {@link HuffmanTable} and {@link RequantTable}
     * objects.
     * 
     * @author Bill Wohler
     */
    private class TableUpdateTask extends DatabaseTask<Void, Void> {

        private static final String NAME = "TableUpdateTask";

        public TableUpdateTask() {
            setUserCanCancel(false);
        }

        @Override
        protected Void doInBackground() throws Exception {
            log.info(resourceMap.getString(NAME + ".saving",
                huffmanTableDescriptor.getPipelineTaskId(),
                requantTableDescriptor.getPipelineTaskId(),
                huffmanTableDescriptor.getExternalId(),
                requantTableDescriptor.getExternalId(), externalId));

            CompressionCrudProxy compressionCrud = new CompressionCrudProxy();

            huffmanTable = compressionCrud.retrieveHuffmanTable(huffmanTableDescriptor.getId());
            huffmanTable.setExternalId(externalId);
            huffmanTable.setPlannedStartTime(startTime);
            compressionCrud.createHuffmanTable(huffmanTable);

            requantTable = compressionCrud.retrieveRequantTable(requantTableDescriptor.getId());
            requantTable.setExternalId(externalId);
            requantTable.setPlannedStartTime(startTime);
            compressionCrud.createRequantTable(requantTable);

            dbExternalId = externalId;

            log.info(resourceMap.getString(NAME + ".saved"));

            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(CompressionPanel.this, e, NAME,
                huffmanTableDescriptor.getPipelineTaskId(),
                requantTableDescriptor.getPipelineTaskId());
        }

        @Override
        protected void succeeded(Void result) {
            HuffmanTableDescriptor oldHuffmanTableDescriptor = huffmanTableDescriptor;
            RequantTableDescriptor oldRequantTableDescriptor = requantTableDescriptor;
            huffmanTableDescriptor = new HuffmanTableDescriptor(huffmanTable);
            requantTableDescriptor = new RequantTableDescriptor(requantTable);
            tableSelectionPanel.replace(oldHuffmanTableDescriptor,
                huffmanTableDescriptor, oldRequantTableDescriptor,
                requantTableDescriptor);

            summaryPanel.setHuffmanTaskId(huffmanTableDescriptor.getPipelineTaskId());
            summaryPanel.setRequantTaskId(requantTableDescriptor.getPipelineTaskId());
            summaryPanel.setExternalId(externalId);
            summaryPanel.setStartTime(startTime);
            displaySummary();
        }
    }

    /**
     * A task for exporting compression tables. Note that this class updates the
     * {@code huffmantTable} and {@code requantTable} fields so this task must
     * block the UI!
     * 
     * @author Bill Wohler
     */
    private class ExportTask extends DatabaseTask<List<File>, Void> {

        private File file;

        public ExportTask(File file) {
            this.file = file;
            setUserCanCancel(false);
        }

        @Override
        protected List<File> doInBackground() throws Exception {
            CompressionCrudProxy compressionCrud = new CompressionCrudProxy();

            log.info(resourceMap.getString(EXPORT + ".retrieving"));
            huffmanTable = compressionCrud.retrieveHuffmanTable(huffmanTableDescriptor.getId());
            requantTable = compressionCrud.retrieveRequantTable(requantTableDescriptor.getId());

            log.info(resourceMap.getString(EXPORT + ".exporting"));
            List<File> files = new GarOperationsProxy().export(huffmanTable,
                requantTable, file.getAbsolutePath());
            log.info(resourceMap.getString(EXPORT + ".exported", files));

            return files;
        }

        @Override
        protected void handleFatalError(Throwable cause) {
            handleError(CompressionPanel.this, cause, EXPORT,
                huffmanTableDescriptor.getPipelineTaskId(),
                requantTableDescriptor.getPipelineTaskId());
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }

        @Override
        protected void succeeded(List<File> files) {
            EventBus.publish(new StatusEvent(this).message(resourceMap.getString(
                EXPORT + ".exported", files.get(0))));
        }
    }
}
