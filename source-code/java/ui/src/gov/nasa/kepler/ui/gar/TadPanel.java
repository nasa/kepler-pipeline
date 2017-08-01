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
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.MaskTable.MaskType;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.gar.ExternalIdChooser.ExternalIdEvent;
import gov.nasa.kepler.ui.gar.TableExportPanel.Helper;
import gov.nasa.kepler.ui.gar.TargetListSetSelectionPanel.TargetListSetSelectionEvent;
import gov.nasa.kepler.ui.proxy.TargetCrudProxy;
import gov.nasa.kepler.ui.proxy.TargetExporterProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import javax.swing.JComponent;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.jdesktop.application.Action;

/**
 * Exports target and aperture definition tables.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TadPanel extends ExportTablePanel {

    /** Resource prefix for external ID chooser titles. */
    private static final String EXTERNAL_ID = "externalIdChooser";

    /**
     * Supported table types. The specific type is available via the
     * {@link #getTargetType()} method.
     */
    private static enum PanelType {
        LCT(TargetType.LONG_CADENCE),
        SCT1(TargetType.SHORT_CADENCE),
        SCT2(TargetType.SHORT_CADENCE),
        SCT3(TargetType.SHORT_CADENCE),
        RPT(TargetType.REFERENCE_PIXEL),
        BGP(TargetType.BACKGROUND),
        TAD(MaskType.TARGET),
        BAD(MaskType.BACKGROUND);

        Object type;

        private PanelType(Object type) {
            this.type = type;
        }

        public boolean isTargetType() {
            return type instanceof TargetType;
        }

        public TargetType getTargetType() {
            return (TargetType) type;
        }

        public boolean isMaskType() {
            return type instanceof MaskType;
        }

        public MaskType getMaskType() {
            return (MaskType) type;
        }
    };

    /** The panel used to select {@link TargetListSet}s. */
    private TargetListSetSelectionPanel targetListSetSelectionPanel = new TargetListSetSelectionPanel();

    /**
     * The listener for {@link TargetListSet} selection events. This can't be an
     * anonymous class since the {@link EventBus} uses weak references.
     */
    private EventSubscriber<TargetListSetSelectionEvent> targetListSetSelectionListener;

    /**
     * List of selected {@link TargetListSet}s. This is used purely for log
     * messages as the meat of the data structure is {@code tableTypeMap}.
     */
    private List<TargetListSet> targetListSets;

    /**
     * A mapping between {@link PanelType}s and {@link ExportTable}s which is
     * updated whenever {@code targetListSets} changes.
     */
    private Map<PanelType, Pair<ExportTable, TargetListSet>> tableTypeMap = new HashMap<PanelType, Pair<ExportTable, TargetListSet>>();

    /**
     * External ID panels mapped by panel type.
     */
    private Map<PanelType, ExternalIdChooser> externalIdPanelMap = new LinkedHashMap<PanelType, ExternalIdChooser>() {
        {
            for (PanelType type : PanelType.values()) {
                put(type, new ExternalIdChooser());
            }
        }
    };

    private Map<PanelType, Set<Integer>> uplinkedExternalIds = new HashMap<PanelType, Set<Integer>>();
    private Map<PanelType, Set<Integer>> externalIdsInUse = new HashMap<PanelType, Set<Integer>>();
    private Map<PanelType, Integer> oldExternalIdMap = new HashMap<PanelType, Integer>();

    /**
     * The listener for {@link ExternalIdEvent}s. This can't be an anonymous
     * class since the {@link EventBus} uses weak references.
     */
    private EventSubscriber<ExternalIdEvent> externalIdListener;

    /** The panel used to display the actual target tables and export them. */
    private TadSummaryPanel summaryPanel = new TadSummaryPanel();

    /**
     * The list of panels to be displayed to the user in turn. It is initialized
     * to the complete list. The {@link #next()} method will update this field
     * to match the panels needed by the selection of target list sets.
     */
    private List<JComponent> panels = new ArrayList<JComponent>();

    /**
     * Creates a {@link TadPanel}.
     * 
     * @param helper a means for displaying help
     * @throws UiException if the panel could not be created
     */
    public TadPanel(Helper helper) throws UiException {
        super(helper);

        panels.add(targetListSetSelectionPanel);
        for (PanelType type : PanelType.values()) {
            panels.add(externalIdPanelMap.get(type));
            externalIdPanelMap.get(type)
                .setInstruction(
                    resourceMap.getString(EXTERNAL_ID + type.toString()));
        }
        panels.add(summaryPanel);

        createUi();
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    @Override
    protected List<JComponent> getPanels() {
        return panels;
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
            show(targetListSetSelectionPanel);
            return;
        }

        super.previous();
    }

    @Override
    protected boolean readyForNext() {
        if (currentPanel() == targetListSetSelectionPanel) {
            boolean allowIncompleteExportSet = config.getBoolean(
                Properties.ALLOW_INCOMPLETE_EXPORT_SET, false);
            return conditionalHelp(!duplicates(), "duplicates.help")
                && conditionalHelp(sameMaskTable(), "sameMaskTable.help")
                && conditionalHelp(uplinkedTargetListSetCheck(false)
                    || uplinkedTargetListSetCheck(true),
                    "uplinkedTargetListSetCheck.help")
                && (allowIncompleteExportSet || conditionalHelp(
                    completeExportSet(), "completeExportSet.help"));
        } else if (currentPanel() instanceof ExternalIdChooser) {
            for (Entry<PanelType, ExternalIdChooser> entries : externalIdPanelMap.entrySet()) {
                if (entries.getValue() == currentPanel()) {
                    PanelType type = entries.getKey();
                    ExportTable table = tableTypeMap.get(type).left;
                    return conditionalHelp(
                        table.getExternalId() > 0
                            && table.getExternalId() <= ExportTable.MAX_EXTERNAL_ID
                            && !uplinkedExternalIds.get(type)
                                .contains(table.getExternalId()),
                        "validTableId.help");
                }
            }
        }

        return false;
    }

    /**
     * Returns {@code true} if there are duplicate target tables in the selected
     * target list sets. This depends on
     * {@link #updateTargetListSetsToTypeMap(List)} clearing the
     * {@code tableTypeMap} if there are duplicates.
     */
    private boolean duplicates() {
        if (isUiInitializing() || targetListSets == null) {
            return false;
        }

        return targetListSets.size() > 0 && tableTypeMap.size() == 0;
    }

    /**
     * Returns {@code true} if the uplinked state of all of the selected target
     * list sets is {@code uplinked}. Returns {@code false} if none of the
     * target list sets are selected.
     */
    private boolean uplinkedTargetListSetCheck(boolean uplinked) {
        if (tableTypeMap.size() == 0) {
            return false;
        }

        for (ExportTable table : getTables(tableTypeMap)) {
            if (table.getState()
                .uplinked() != uplinked) {
                return false;
            }
        }

        return true;
    }

    private List<ExportTable> getTables(
        Map<PanelType, Pair<ExportTable, TargetListSet>> tableTypeMap) {
        List<ExportTable> tables = new ArrayList<ExportTable>();
        for (Pair<ExportTable, TargetListSet> pair : tableTypeMap.values()) {
            tables.add(pair.left);
        }

        return tables;
    }

    /**
     * Returns {@code true} if the selected target list sets have target tables
     * with the same mask and background tables with the same mask.
     */
    private boolean sameMaskTable() {
        ExportTable targetTableMask = null;
        ExportTable backgroundMask = null;
        for (ExportTable table : getTables(tableTypeMap)) {
            if (table instanceof TargetTable) {
                TargetTable targetTable = (TargetTable) table;
                MaskTable maskTable = targetTable.getMaskTable();
                if (targetTable.getType() == TargetType.BACKGROUND) {
                    if (backgroundMask == null) {
                        backgroundMask = maskTable;
                    } else if (maskTable != backgroundMask) {
                        log.warn(resourceMap.getString("sameMaskTable",
                            table.toString(), maskTable.toString(),
                            backgroundMask.toString()));
                        return false;
                    }
                } else {
                    if (targetTableMask == null) {
                        targetTableMask = maskTable;
                    } else if (maskTable != targetTableMask) {
                        log.warn(resourceMap.getString("sameMaskTable",
                            table.toString(), maskTable.toString(),
                            targetTableMask.toString()));
                        return false;
                    }
                }
            } else if (table instanceof MaskTable) {
                MaskTable maskTable = (MaskTable) table;
                if (maskTable.getType() == MaskType.BACKGROUND) {
                    if (backgroundMask == null) {
                        backgroundMask = maskTable;
                    } else if (maskTable != backgroundMask) {
                        log.warn(resourceMap.getString("sameMaskTable",
                            table.toString(), maskTable.toString(),
                            backgroundMask.toString()));
                        return false;
                    }
                } else {
                    if (targetTableMask == null) {
                        targetTableMask = maskTable;
                    } else if (maskTable != targetTableMask) {
                        log.warn(resourceMap.getString("sameMaskTable",
                            table.toString(), maskTable.toString(),
                            targetTableMask.toString()));
                        return false;
                    }
                }
            } else {
                throw new IllegalStateException("Unknown table type "
                    + table.getClass()
                        .getSimpleName());
            }
        }

        return true;
    }

    /**
     * Returns {@code true} if the selected target list sets form a complete set
     * (all eight target and aperture definition tables are represented).
     */
    private boolean completeExportSet() {
        if (tableTypeMap.size() != PanelType.values().length) {
            log.warn(resourceMap.getString("completeExportSet",
                PanelType.values().length, tableTypeMap.size()));
            return false;
        }

        return true;
    }

    @Override
    @Action(enabledProperty = NEXT + ENABLED)
    public void next() {
        if (reloadingData()) {
            handleError(null, NEXT + RELOADING_DATA);
            show(targetListSetSelectionPanel);
            return;
        }

        if (currentPanel() == targetListSetSelectionPanel) {
            boolean allUplinked = uplinkedTargetListSetCheck(true);
            updatePanels(!allUplinked);
            if (allUplinked) {
                summaryPanel.setTables(new ArrayList<Pair<ExportTable, TargetListSet>>(
                    tableTypeMap.values()));
                summaryPanel.setCompleteExportSet(completeExportSet());
            }
            super.next();
        } else {
            for (Entry<PanelType, ExternalIdChooser> entries : externalIdPanelMap.entrySet()) {
                if (entries.getValue() == currentPanel()) {
                    PanelType type = entries.getKey();
                    ExportTable table = tableTypeMap.get(type).left;
                    int externalId = table.getExternalId();
                    if (externalId != oldExternalIdMap.get(type)
                        && externalIdsInUse.get(type)
                            .contains(externalId)
                        && warnUser(NEXT + ".used", externalId)) {
                        return;
                    }
                    break;
                }
            }

            if (panels.indexOf(currentPanel()) == panels.indexOf(summaryPanel) - 1) {
                executeDatabaseTask(TableUpdateTask.NAME, new TableUpdateTask());
                // Will call super.next() from task.
            } else {
                super.next();
            }
        }
    }

    /**
     * Displays the summary page, but only from the external ID page, as this
     * method simply calls {@code super.next()}.
     */
    private void displaySummary() {
        super.next();
    }

    /**
     * Updates the panels field to match the selected target list sets.
     * 
     * @param chooseExternalId if {@code true}, show external ID chooser panels;
     * otherwise, skip directly to the summary panel.
     */
    private void updatePanels(boolean chooseExternalId) {
        panels.clear();
        oldExternalIdMap.clear();
        panels.add(targetListSetSelectionPanel);
        if (chooseExternalId) {
            for (PanelType type : PanelType.values()) {
                Pair<ExportTable, TargetListSet> pair = tableTypeMap.get(type);
                if (pair == null) {
                    // This can be the case if allowIncompleteExportSet is true.
                    continue;
                }

                ExportTable table = pair.left;
                if (table == null) {
                    // This can be the case if allowIncompleteExportSet is true.
                    continue;
                }

                int externalId = table.getExternalId();
                oldExternalIdMap.put(type, externalId);
                if (externalId == ExportTable.INVALID_EXTERNAL_ID) {
                    externalId = lowestAvailableExternalId(
                        externalIdsInUse.get(type),
                        uplinkedExternalIds.get(type));
                    if (externalId == ExportTable.INVALID_EXTERNAL_ID) {
                        warnUser(NEXT + ".gameOver", type.toString());
                    }
                }

                ExternalIdChooser panel = externalIdPanelMap.get(type);
                panel.setExternalId(externalId);
                panels.add(panel);
            }
        }
        panels.add(summaryPanel);
    }

    @Override
    protected boolean readyToExport() {
        return currentPanel() == summaryPanel;
    }

    @Override
    @Action(enabledProperty = EXPORT + ENABLED)
    public void export() {
        log.info(resourceMap.getString(EXPORT, targetListSets));
        if (reloadingData()) {
            handleError(null, EXPORT + RELOADING_DATA);
            show(targetListSetSelectionPanel);
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
            handleError(this, e, EXPORT, targetListSets);
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

        // Also refresh the TargetListSelectionPanel except for the first
        // time here, since the panel will initialize itself.
        if (externalIdsInUse.size() > 0) {
            targetListSetSelectionPanel.refresh();
        }
    }

    @Override
    protected void addListeners() throws UiException {
        super.addListeners();
        targetListSetSelectionListener = new EventSubscriber<TargetListSetSelectionEvent>() {
            @Override
            public void onEvent(TargetListSetSelectionEvent e) {
                log.debug(e);
                targetListSets = e.getTargetListSets();
                updateTargetListSetsToTypeMap(targetListSets);
                updateEnabled();
            }
        };
        EventBus.subscribe(TargetListSetSelectionEvent.class,
            targetListSetSelectionListener);

        externalIdListener = new EventSubscriber<ExternalIdEvent>() {
            @Override
            public void onEvent(ExternalIdEvent e) {
                log.debug(e);
                for (Entry<PanelType, ExternalIdChooser> entries : externalIdPanelMap.entrySet()) {
                    if (entries.getValue() == e.getSource()) {
                        tableTypeMap.get(entries.getKey()).left.setExternalId(e.getExternalId());
                        updateEnabled();
                        break;
                    }
                }
            }
        };
        EventBus.subscribe(ExternalIdEvent.class, externalIdListener);
    }

    /**
     * Returns a map of the table types to their tables within the selected
     * target list sets.
     * 
     * @param targetListSets a list of {@link TargetListSet}s
     */
    private void updateTargetListSetsToTypeMap(
        List<TargetListSet> targetListSets) {

        tableTypeMap.clear();

        if (targetListSets == null) {
            return;
        }

        boolean duplicate = false;
        for (TargetListSet targetListSet : targetListSets) {
            switch (targetListSet.getType()) {
                case LONG_CADENCE:
                    if (updateTableTypeMap(PanelType.LCT,
                        targetListSet.getTargetTable(), targetListSet) != null
                        || updateTableTypeMap(PanelType.BGP,
                            targetListSet.getBackgroundTable(), targetListSet) != null
                        || updateTableTypeMap(PanelType.TAD,
                            targetListSet.getTargetTable()
                                .getMaskTable(), targetListSet) != null
                        || updateTableTypeMap(PanelType.BAD,
                            targetListSet.getBackgroundTable()
                                .getMaskTable(), targetListSet) != null) {
                        duplicate = true;
                    }
                    break;
                case SHORT_CADENCE:
                    if (tableTypeMap.get(PanelType.SCT1) == null) {
                        tableTypeMap.put(PanelType.SCT1, Pair.of(
                            (ExportTable) targetListSet.getTargetTable(),
                            targetListSet));
                    } else if (tableTypeMap.get(PanelType.SCT2) == null) {
                        tableTypeMap.put(PanelType.SCT2, Pair.of(
                            (ExportTable) targetListSet.getTargetTable(),
                            targetListSet));
                    } else {
                        if (updateTableTypeMap(PanelType.SCT3,
                            targetListSet.getTargetTable(), targetListSet) != null) {
                            duplicate = true;
                        }
                    }
                    break;
                case REFERENCE_PIXEL:
                    if (updateTableTypeMap(PanelType.RPT,
                        targetListSet.getTargetTable(), targetListSet) != null) {
                        duplicate = true;
                    }
                    break;
                case BACKGROUND:
                    break;
            }
            if (duplicate) {
                tableTypeMap.clear();
            }
        }
    }

    /**
     * Adds the given export table to the given slot in the {@code tableTypeMap}
     * . Returns the old value in that slot.
     * 
     * @param type the type
     * @param exportTable the table
     * @see Map#put(Object, Object)
     */
    private Pair<ExportTable, TargetListSet> updateTableTypeMap(PanelType type,
        ExportTable exportTable, TargetListSet targetListSet) {

        Pair<ExportTable, TargetListSet> oldTable = tableTypeMap.put(type,
            Pair.of(exportTable, targetListSet));
        if (oldTable != null) {
            log.warn(resourceMap.getString("updateTableTypeMap", type));
        }

        return oldTable;
    }

    /**
     * A task for looking up sets of external IDs.
     * 
     * @author Bill Wohler
     */
    private class ExternalIdLookupTask extends DatabaseTask<Void, Void> {

        private static final String NAME = "ExternalIdLookupTask";

        private Map<PanelType, Set<Integer>> uplinkedExternalIds = new HashMap<PanelType, Set<Integer>>();
        private Map<PanelType, Set<Integer>> externalIdsInUse = new HashMap<PanelType, Set<Integer>>();

        @Override
        protected Void doInBackground() throws Exception {
            TargetCrudProxy targetCrud = new TargetCrudProxy();

            log.info(resourceMap.getString(NAME + ".loading"));
            for (PanelType type : PanelType.values()) {
                if (type.isTargetType()) {
                    uplinkedExternalIds.put(
                        type,
                        targetCrud.retrieveUplinkedExternalIds(type.getTargetType()));
                    externalIdsInUse.put(
                        type,
                        targetCrud.retrieveExternalIdsInUse(type.getTargetType()));
                } else if (type.isMaskType()) {
                    uplinkedExternalIds.put(
                        type,
                        targetCrud.retrieveUplinkedExternalIds(type.getMaskType()));
                    externalIdsInUse.put(type,
                        targetCrud.retrieveExternalIdsInUse(type.getMaskType()));
                } else {
                    assert false; // otherwise, map will have a null value
                }
            }

            log.info(resourceMap.getString(NAME + ".loaded"));

            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TadPanel.this, e, NAME);
        }

        @Override
        protected void succeeded(Void result) {
            TadPanel.this.uplinkedExternalIds.clear();
            TadPanel.this.externalIdsInUse.clear();

            for (PanelType type : PanelType.values()) {
                TadPanel.this.uplinkedExternalIds.put(type,
                    uplinkedExternalIds.get(type));
                TadPanel.this.externalIdsInUse.put(type,
                    externalIdsInUse.get(type));
            }

            setDataValid(true);
        }
    }

    /**
     * A task for saving modified target and aperture definition tables.
     * 
     * @author Bill Wohler
     */
    private class TableUpdateTask extends
        DatabaseTask<List<Pair<ExportTable, TargetListSet>>, Void> {

        private static final String NAME = "TableUpdateTask";

        public TableUpdateTask() {
            setUserCanCancel(false);
        }

        @Override
        protected List<Pair<ExportTable, TargetListSet>> doInBackground()
            throws Exception {
            log.info(resourceMap.getString(NAME + ".saving"));

            if (hasDuplicateShortCadenceId()) {
                return null;
            }
            List<Pair<ExportTable, TargetListSet>> tables = saveTargetTables();

            log.info(resourceMap.getString(NAME + ".saved"));

            return tables;
        }

        private boolean hasDuplicateShortCadenceId() {
            Set<Integer> ids = new HashSet<Integer>(3);
            for (PanelType type : tableTypeMap.keySet()) {
                switch (type) {
                    case SCT1:
                    case SCT2:
                    case SCT3:
                        if (ids.contains(tableTypeMap.get(type).left.getExternalId())) {
                            return true;
                        }
                        ids.add(tableTypeMap.get(type).left.getExternalId());
                        break;
                    case LCT:
                        break;
                    case RPT:
                        break;
                    case BGP:
                        break;
                    case TAD:
                        break;
                    case BAD:
                        break;
                }
            }

            return false;
        }

        private List<Pair<ExportTable, TargetListSet>> saveTargetTables() {
            TargetCrudProxy targetCrud = new TargetCrudProxy();
            List<Pair<ExportTable, TargetListSet>> tables = new ArrayList<Pair<ExportTable, TargetListSet>>(
                tableTypeMap.size());
            for (PanelType type : tableTypeMap.keySet()) {
                Pair<ExportTable, TargetListSet> pair = tableTypeMap.get(type);
                ExportTable table = pair.left;
                if (table instanceof TargetTable) {
                    targetCrud.createTargetTable((TargetTable) table);
                } else if (table instanceof MaskTable) {
                    targetCrud.createMaskTable((MaskTable) table);
                } else {
                    throw new IllegalArgumentException(
                        "Table must be of type TargetTable or MaskTable\n"
                            + table);
                }
                tables.add(pair);
            }
            return tables;
        }

        @Override
        protected void handleNonFatalError(Throwable e) {
            handleError(TadPanel.this, e, NAME);
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TadPanel.this, e, NAME + ".fatal");
        }

        @Override
        protected void succeeded(List<Pair<ExportTable, TargetListSet>> result) {
            if (result != null) {
                summaryPanel.setTables(result);
                summaryPanel.setCompleteExportSet(completeExportSet());
                displaySummary();
                oldExternalIdMap.clear();
                for (PanelType type : tableTypeMap.keySet()) {
                    oldExternalIdMap.put(type,
                        tableTypeMap.get(type).left.getExternalId());
                }
            } else {
                KeplerDialogs.showErrorDialog(TadPanel.this, resourceMap, NAME
                    + ".dupIds");
            }
        }
    }

    /**
     * A task for exporting target tables. Note that this class updates the
     * target and mask tables in the {@code tableTypeMap} field, so this task
     * must block the UI!
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
            ExportTable lcTargetTable = tableTypeMap.get(PanelType.LCT) == null ? null :
                tableTypeMap.get(PanelType.LCT).left;
            ExportTable bgTargetTable = tableTypeMap.get(PanelType.BGP) == null ? null :
                tableTypeMap.get(PanelType.BGP).left;
            ExportTable targetMaskTable = tableTypeMap.get(PanelType.TAD) == null ? null :
                tableTypeMap.get(PanelType.TAD).left;
            ExportTable bgMaskTable = tableTypeMap.get(PanelType.BAD) == null ? null :
                tableTypeMap.get(PanelType.BAD).left;
            ExportTable rpTargetTable = tableTypeMap.get(PanelType.RPT) == null ? null :
                tableTypeMap.get(PanelType.RPT).left;
            ExportTable sc1TargetTable = tableTypeMap.get(PanelType.SCT1) == null ? null :
                tableTypeMap.get(PanelType.SCT1).left;
            ExportTable sc2TargetTable = tableTypeMap.get(PanelType.SCT2) == null ? null :
                tableTypeMap.get(PanelType.SCT2).left;
            ExportTable sc3TargetTable = tableTypeMap.get(PanelType.SCT3) == null ? null :
                tableTypeMap.get(PanelType.SCT3).left;

            List<File> files = new TargetExporterProxy().export(
                (TargetTable) lcTargetTable,
                (TargetTable) bgTargetTable,
                (MaskTable) targetMaskTable,
                (MaskTable) bgMaskTable,
                (TargetTable) rpTargetTable,
                (TargetTable) sc1TargetTable,
                (TargetTable) sc2TargetTable,
                (TargetTable) sc3TargetTable,
                file.getAbsolutePath());
            log.info(resourceMap.getString(EXPORT + ".exported", files));

            return files;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TadPanel.this, e, EXPORT + ".fatal", targetListSets);
        }

        @Override
        protected void handleNonFatalError(Throwable e) {
            handleError(TadPanel.this, e, EXPORT, targetListSets);
        }

        @Override
        protected void succeeded(List<File> files) {
            EventBus.publish(new StatusEvent(this).message(resourceMap.getString(
                EXPORT + ".exported", files.get(0))));
        }
    }
}
