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

import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.gar.ExportTable.State;
import gov.nasa.kepler.hibernate.tad.MaskTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.KeplerUtilities;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.common.UpdateEvent;
import gov.nasa.kepler.ui.proxy.ConversationUtils;
import gov.nasa.kepler.ui.proxy.TargetSelectionCrudProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Font;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.LayoutStyle.ComponentPlacement;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.bushe.swing.event.EventTopicSubscriber;
import org.bushe.swing.event.generics.TypeReference;
import org.jdesktop.application.Action;

/**
 * A panel for the target list set table.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListSetsPanel extends ToolPanel {

    private static final String NAME = "targetListSetsPanel";

    // Actions.
    private static final String CREATE = "create";
    private static final String EDIT = "edit";
    private static final String COPY = "copy";
    private static final String COMPARE = "compare";
    private static final String EXPORT_REJECTED = "exportRejected";
    private static final String DELETE = "delete";
    private static final String UNLOCK = "unlock";
    private static final String LOCK_DOWN = "lock";
    private static final String MARK_UPLINKED = "markUplinked";
    private static final String REFRESH = "refresh";

    // Suffix to build enabled property from action.
    private static final String ENABLED = "Enabled";

    /**
     * List of all actions. Note that adding an action here leads to the
     * creation of both menu items and buttons for it.
     */
    private static final String[] actions = new String[] { CREATE,
        DEFAULT_ACTION_CHAR + EDIT, COPY, COMPARE, EXPORT_REJECTED, DELETE,
        UNLOCK, LOCK_DOWN, MARK_UPLINKED, REFRESH };

    // Bound properties.
    private boolean createEnabled;
    private boolean editEnabled;
    private boolean copyEnabled;
    private boolean compareEnabled;
    private boolean exportRejectedEnabled;
    private boolean deleteEnabled;
    private boolean unlockEnabled;
    private boolean lockEnabled;
    private boolean markUplinkedEnabled;

    // Selected target list sets.
    private List<TargetListSet> selectedTargetListSets = Collections.emptyList();

    private ToolTable targetListSetTable;
    private TargetListSetTableModel targetListSetModel;
    private EventSubscriber<StatusEvent> statusEventListener;
    private EventTopicSubscriber selectedTargetListSetListener;
    private EventSubscriber<UpdateEvent<TargetListSet>> targetListSetUpdateHandler;
    private EventSubscriber<DataRequestEvent<List<TargetListSet>>> targetListSetRequestListener;

    /**
     * Creates a {@link TargetListSetsPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public TargetListSetsPanel() throws UiException {
        setName(NAME);
        createUi();
    }

    @Override
    protected void initComponents() {
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        // Target list sets.
        JLabel targetListSetLabel = new JLabel();
        targetListSetLabel.setName("targetListSetLabel");
        targetListSetLabel.setFont(targetListSetLabel.getFont()
            .deriveFont(Font.BOLD));

        JPanel targetListSetToolBar = getToolBar();

        targetListSetModel = new TargetListSetTableModel();
        targetListSetTable = new ToolTable(targetListSetModel, this);
        JScrollPane scrollPane = new JScrollPane(targetListSetTable);

        layout.setAutoCreateGaps(true);
        layout.setAutoCreateContainerGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup(Alignment.LEADING)
            .addGroup(
                layout.createSequentialGroup()
                    .addComponent(targetListSetLabel)
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(targetListSetToolBar))
            .addComponent(scrollPane));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addGroup(layout.createParallelGroup(Alignment.CENTER)
                .addComponent(targetListSetLabel)
                .addComponent(targetListSetToolBar))
            .addComponent(scrollPane));
    }

    @Override
    protected void configureComponents() throws UiException {
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
        statusEventListener = new EventSubscriber<StatusEvent>() {
            @Override
            public void onEvent(StatusEvent event) {
                log.debug(event);
                if (event.getSource() == targetListSetModel) {
                    setDataValid(event.isDone());
                    updateEnabled();
                }
            }
        };
        EventBus.subscribe(StatusEvent.class, statusEventListener);

        selectedTargetListSetListener = new EventTopicSubscriber() {
            @Override
            @SuppressWarnings("unchecked")
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                setSelectedTargetListSets((List<TargetListSet>) data);
            }
        };
        EventBus.subscribe(targetListSetTable.getSelectionTopic(),
            selectedTargetListSetListener);

        targetListSetUpdateHandler = new EventSubscriber<UpdateEvent<TargetListSet>>() {
            @Override
            public void onEvent(UpdateEvent<TargetListSet> e) {
                log.debug(e);
                if (reloadingData()) {
                    return;
                }
                switch (e.getFunction()) {
                    case ADD_OR_UPDATE:
                        targetListSetModel.addOrUpdate(e.get());
                        break;
                    case DELETE:
                        targetListSetModel.delete(e.get());
                        break;
                    case ADD:
                        break;
                    case INSERT:
                        break;
                    case UPDATE:
                        break;
                    case SELECT:
                        break;
                    case REFRESH:
                        break;
                }
            }
        };
        EventBus.subscribe(new TypeReference<UpdateEvent<TargetListSet>>() {
        }.getType(), targetListSetUpdateHandler);
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actions);
    }

    /**
     * Sets the currently selected target list sets.
     * 
     * @param targetListSets a non-null list of the selected target list sets
     */
    private void setSelectedTargetListSets(List<TargetListSet> targetListSets) {
        if (targetListSets == null) {
            throw new NullPointerException(
                "List of target list sets can't be null");
        }

        selectedTargetListSets = targetListSets;

        updateEnabled();
    }

    /**
     * Updates the actions' enabled state. Call this after updating the
     * selection, or running a command which might change the state of the
     * current selection.
     */
    @Override
    protected void updateEnabled() {
        // Try to enable actions subject to setters' logic.
        setCreateEnabled(true);
        setEditEnabled(true);
        setCopyEnabled(true);
        setCompareEnabled(true);
        setExportRejectedEnabled(true);
        setDeleteEnabled(true);
        setUnlockEnabled(true);
        setLockEnabled(true);
        setMarkUplinkedEnabled(true);
    }

    /**
     * Creates a new target list set.
     */
    @Action(enabledProperty = CREATE + ENABLED)
    public void create() {
        log.info(resourceMap.getString(CREATE));
        if (reloadingData()) {
            handleError(null, CREATE + RELOADING_DATA);
            return;
        }
        try {
            TargetListSetEditor.edit(targetListSetModel.getTargetListSets());
        } catch (UiException e) {
            handleError(e, CREATE);
        }
    }

    public boolean isCreateEnabled() {
        return createEnabled;
    }

    public void setCreateEnabled(boolean createEnabled) {
        boolean oldValue = this.createEnabled;
        this.createEnabled = createEnabled;
        firePropertyChange(CREATE + ENABLED, oldValue, this.createEnabled);
    }

    /**
     * Edits a target list set.
     */
    @Action(enabledProperty = EDIT + ENABLED)
    public void edit() {
        log.info(resourceMap.getString(EDIT, selectedTargetListSets.get(0)));
        try {
            if (reloadingData()) {
                handleError(null, EDIT + RELOADING_DATA,
                    selectedTargetListSets.get(0));
                return;
            }
            TargetListSetEditor.edit(selectedTargetListSets.get(0),
                targetListSetModel.getTargetListSets());
        } catch (UiException e) {
            handleError(e, EDIT, selectedTargetListSets.get(0));
        }
    }

    public boolean isEditEnabled() {
        return editEnabled;
    }

    public void setEditEnabled(boolean editEnabled) {
        boolean oldValue = this.editEnabled;
        this.editEnabled = editEnabled && selectedTargetListSets.size() == 1;
        firePropertyChange(EDIT + ENABLED, oldValue, this.editEnabled);
    }

    /**
     * Copies a target list set.
     */
    @Action(enabledProperty = COPY + ENABLED)
    public void copy() {
        TargetListSet targetListSetToCopy = selectedTargetListSets.get(0);
        log.info(resourceMap.getString(COPY, targetListSetToCopy));
        if (reloadingData()) {
            handleError(null, COPY + RELOADING_DATA, targetListSetToCopy);
            return;
        }

        // Find a unique new name for the first target list set in the
        // list.
        Set<String> targetListSetNames = new HashSet<String>();
        for (TargetListSet targetListSet : targetListSetModel.getTargetListSets()) {
            targetListSetNames.add(targetListSet.getName());
        }
        String name = KeplerUtilities.createNewName(
            targetListSetToCopy.getName(), targetListSetNames);
        if (name == null) {
            handleError(null, "copy.couldntFindUniqueAlternative",
                selectedTargetListSets);
        }

        // Make a copy of the target list set using the unique name.
        TargetListSet newTargetListSet = new TargetListSet(name,
            targetListSetToCopy);
        newTargetListSet.setState(State.UNLOCKED);
        newTargetListSet.clearTadFields();

        // Store it and update views.
        executeDatabaseTask(COPY, new CopyTask(targetListSetToCopy,
            newTargetListSet));
    }

    public boolean isCopyEnabled() {
        return copyEnabled;
    }

    public void setCopyEnabled(boolean copyEnabled) {
        boolean oldValue = this.copyEnabled;
        this.copyEnabled = copyEnabled && selectedTargetListSets.size() == 1;
        firePropertyChange(COPY + ENABLED, oldValue, this.copyEnabled);
    }

    /**
     * Compares two target list sets.
     */
    @Action(enabledProperty = COMPARE + ENABLED)
    public void compare() {
        log.info(resourceMap.getString(COMPARE, selectedTargetListSets));
        if (reloadingData()) {
            handleError(null, COMPARE + RELOADING_DATA, selectedTargetListSets);
            return;
        }

        executeDatabaseTask(COMPARE,
            new CompareTask(selectedTargetListSets.get(0),
                selectedTargetListSets.get(1)));
    }

    public boolean isCompareEnabled() {
        return compareEnabled;
    }

    public void setCompareEnabled(boolean compareEnabled) {
        boolean oldValue = this.compareEnabled;
        this.compareEnabled = compareEnabled
            && selectedTargetListSets.size() == 2;
        firePropertyChange(COMPARE + ENABLED, oldValue, this.compareEnabled);
    }

    /**
     * Exports rejected targets into a target list.
     */
    @Action(enabledProperty = EXPORT_REJECTED + ENABLED)
    public void exportRejected() {
        log.info(resourceMap.getString(EXPORT_REJECTED,
            selectedTargetListSets.get(0)));
        if (reloadingData()) {
            handleError(null, EXPORT_REJECTED + RELOADING_DATA,
                selectedTargetListSets.get(0));
            return;
        }
        File file = KeplerDialogs.showSaveFileChooserDialog(this);
        executeDatabaseTask(EXPORT_REJECTED, new ExportRejectedTask(
            selectedTargetListSets.get(0), file));
    }

    public boolean isExportRejectedEnabled() {
        return exportRejectedEnabled;
    }

    public void setExportRejectedEnabled(boolean exportRejectedEnabled) {
        boolean oldValue = this.exportRejectedEnabled;
        this.exportRejectedEnabled = exportRejectedEnabled
            && selectedTargetListSets.size() == 1
            && selectedTargetListSets.get(0)
                .getState()
                .tadCompleted();
        firePropertyChange(EXPORT_REJECTED + ENABLED, oldValue,
            this.exportRejectedEnabled);
    }

    /**
     * Deletes target list sets.
     */
    @Action(enabledProperty = DELETE + ENABLED)
    public void delete() {
        log.info(resourceMap.getString(DELETE, selectedTargetListSets));
        if (reloadingData()) {
            handleError(null, DELETE + RELOADING_DATA, selectedTargetListSets);
            return;
        }
        if (warnUser(DELETE, selectedTargetListSets)) {
            return;
        }

        executeDatabaseTask(DELETE, new DeleteTask(selectedTargetListSets));
    }

    public boolean isDeleteEnabled() {
        return deleteEnabled;
    }

    public void setDeleteEnabled(boolean deleteEnabled) {
        boolean oldValue = this.deleteEnabled;
        this.deleteEnabled = deleteEnabled && selectedTargetListSets.size() > 0
            && lockedCount() == 0;
        firePropertyChange(DELETE + ENABLED, oldValue, this.deleteEnabled);
    }

    /**
     * Unlocks target list sets.
     */
    @Action(enabledProperty = UNLOCK + ENABLED)
    public void unlock() {
        log.info(resourceMap.getString(UNLOCK, selectedTargetListSets));

        if (reloadingData()) {
            handleError(null, UNLOCK + RELOADING_DATA, selectedTargetListSets);
            return;
        }

        // Nag user (since this could undo hours of work if it's accidental).
        if (warnUser(UNLOCK, selectedTargetListSets)) {
            return;
        }

        executeDatabaseTask(UNLOCK, new UpdateTask(selectedTargetListSets,
            UNLOCK, State.UNLOCKED));
    }

    public boolean isUnlockEnabled() {
        return unlockEnabled;
    }

    public void setUnlockEnabled(boolean unlockEnabled) {
        boolean oldValue = this.unlockEnabled;
        this.unlockEnabled = unlockEnabled && lockedCount() > 0
            && uplinkedCount() == 0;
        firePropertyChange(UNLOCK + ENABLED, oldValue, this.unlockEnabled);
    }

    /**
     * Ready to generate target definitions.
     */
    @Action(enabledProperty = LOCK_DOWN + ENABLED)
    public void lock() {
        log.info(resourceMap.getString(LOCK_DOWN, selectedTargetListSets));

        if (reloadingData()) {
            handleError(null, LOCK_DOWN + RELOADING_DATA,
                selectedTargetListSets);
            return;
        }

        executeDatabaseTask(LOCK_DOWN, new UpdateTask(selectedTargetListSets,
            LOCK_DOWN, State.LOCKED));
    }

    public boolean isLockEnabled() {
        return lockEnabled;
    }

    public void setLockEnabled(boolean lockEnabled) {
        boolean oldValue = this.lockEnabled;
        this.lockEnabled = lockEnabled && lockedCount() == 0;
        firePropertyChange(LOCK_DOWN + ENABLED, oldValue, this.lockEnabled);
    }

    /**
     * Returns a count of the selected target list sets that are locked.
     * 
     * @return the number of selected target list sets that are locked, or -1 if
     * there aren't any selected target list sets
     */
    private int lockedCount() {
        if (selectedTargetListSets.size() == 0) {
            return -1;
        }

        int count = 0;
        for (TargetListSet targetListSet : selectedTargetListSets) {
            if (targetListSet.getState()
                .locked()) {
                count++;
            }
        }

        return count;
    }

    /**
     * Mark selected target list sets as uplinked.
     */
    @Action(enabledProperty = MARK_UPLINKED + ENABLED)
    public void markUplinked() {
        log.info(resourceMap.getString(MARK_UPLINKED, selectedTargetListSets));

        if (reloadingData()) {
            handleError(null, MARK_UPLINKED + RELOADING_DATA,
                selectedTargetListSets);
            return;
        }

        // Nag user (since you can't edit target list sets after doing this).
        if (warnUser(MARK_UPLINKED, selectedTargetListSets)) {
            return;
        }

        executeDatabaseTask(MARK_UPLINKED, new UpdateTask(
            selectedTargetListSets, MARK_UPLINKED, State.UPLINKED));
    }

    public boolean isMarkUplinkedEnabled() {
        return markUplinkedEnabled;
    }

    public void setMarkUplinkedEnabled(boolean markUplinkedEnabled) {
        boolean oldValue = this.markUplinkedEnabled;
        this.markUplinkedEnabled = markUplinkedEnabled && uplinkedCount() == 0
            && lockedCount() == selectedTargetListSets.size();
        firePropertyChange(MARK_UPLINKED + ENABLED, oldValue,
            this.markUplinkedEnabled);
    }

    /**
     * Returns a count of the target list sets that have been accepted by the
     * MOC.
     * 
     * @return the number of selected target list sets that have been accepted
     * by the MOC, or -1 if there aren't any selected target list sets
     */
    private int uplinkedCount() {
        if (selectedTargetListSets.size() == 0) {
            return -1;
        }

        int count = 0;
        for (TargetListSet targetListSet : selectedTargetListSets) {
            if (targetListSet.getState()
                .uplinked()) {
                count++;
            }
        }

        return count;
    }

    /**
     * Refreshes the target lists.
     */
    @Action
    public void refresh() {
        log.info(resourceMap.getString(REFRESH));
        getData(false);
    }

    /**
     * A task for loading target list sets from the database in the background.
     * 
     * @author Bill Wohler
     */
    private class TargetListSetLoadTask extends
        DatabaseTask<List<TargetListSet>, Object> {

        private static final String NAME = "TargetListSetLoadTask";

        @Override
        protected List<TargetListSet> doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            EventBus.publish(new StatusEvent(TargetListSetsPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .started());
            log.info(resourceMap.getString(NAME + ".loading"));
            DatabaseServiceFactory.getInstance()
                .evictAll(targetListSetModel.getTargetListSets());
            List<TargetListSet> targetListSets = targetSelectionCrud.retrieveAllTargetListSets();
            log.info(resourceMap.getString(NAME + ".loaded",
                targetListSets.size()));

            return targetListSets;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetsPanel.this, e, NAME);
            EventBus.publish(new StatusEvent(TargetListSetsPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .failed());
        }

        @Override
        protected void succeeded(List<TargetListSet> result) {
            targetListSetModel.setTargetListSets(result);
            setDataValid(true);
            updateEnabled();
            EventBus.publish(new StatusEvent(TargetListSetsPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .done());

            // Now that we have target lists, we can answer requests for
            // them. Since this task can be called multiple times via the
            // refresh button, be careful not to subscribe more than once.
            if (targetListSetRequestListener == null) {
                targetListSetRequestListener = new TargetListSetRequestListener();
                EventBus.subscribe(
                    new TypeReference<DataRequestEvent<List<TargetListSet>>>() {
                    }.getType(), targetListSetRequestListener);
            }
        }
    }

    /**
     * Handles requests for {@code DataRequestEvent<List<TargetListSet>>>}
     * events.
     * 
     * @author Bill Wohler
     */
    private class TargetListSetRequestListener implements
        EventSubscriber<DataRequestEvent<List<TargetListSet>>> {

        @Override
        public void onEvent(DataRequestEvent<List<TargetListSet>> e) {
            log.debug(e);
            if (reloadingData()) {
                return;
            }
            e.setData(targetListSetModel.getTargetListSets());
        }
    }

    /**
     * A task for saving a copied target list set.
     * 
     * @author Bill Wohler
     */
    private class CopyTask extends DatabaseTask<TargetListSet, Void> {
        private TargetListSet targetListSet;
        private TargetListSet newTargetListSet;

        public CopyTask(TargetListSet targetListSet,
            TargetListSet newTargetListSet) {

            this.targetListSet = targetListSet;
            this.newTargetListSet = newTargetListSet;
        }

        @Override
        protected TargetListSet doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            targetSelectionCrud.create(newTargetListSet);

            return newTargetListSet;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetsPanel.this, e, COPY, newTargetListSet);
        }

        @Override
        protected void succeeded(TargetListSet newTargetListSet) {
            targetListSetModel.add(targetListSet, newTargetListSet);
        }
    }

    /**
     * A task for comparing two target list sets.
     * <p>
     * Requirements: SOC_REQ_IMPL 171.CM.3
     * 
     * @author Bill Wohler
     */
    private class CompareTask extends DatabaseTask<String, Void> {
        private TargetListSet targetListSetA;
        private TargetListSet targetListSetB;
        private String added = resourceMap.getString("compare.text.added");
        private String removed = resourceMap.getString("compare.text.removed");
        private int sameLists;
        private int listsInANotInB;
        private int listsInBNotInA;
        private int sameExcludedLists;
        private int excludedListsInANotInB;
        private int excludedListsInBNotInA;
        private int same;
        private int inANotInB;
        private int inBNotInA;

        public CompareTask(TargetListSet targetListSetA,
            TargetListSet targetListSetB) {

            this.targetListSetA = targetListSetA;
            this.targetListSetB = targetListSetB;
        }

        @Override
        protected String doInBackground() throws Exception {
            StringBuilder s = new StringBuilder();

            // Diff names of target lists.
            setMessage(resourceMap.getString(COMPARE + ".message1"));
            List<TargetList> targetListsA = targetListSetA.getTargetLists();
            List<TargetList> targetListsB = targetListSetB.getTargetLists();
            diffTargetLists(s, targetListsA, targetListsB);
            sameLists = same;
            listsInANotInB = inANotInB;
            listsInBNotInA = inBNotInA;
            same = inANotInB = inBNotInA = 0;

            // Diff names of excluded target lists.
            setMessage(resourceMap.getString(COMPARE + ".message2"));
            s.append(resourceMap.getString(COMPARE + ".text.diffExcluded",
                targetListSetA.getName(), targetListSetB.getName()));
            targetListsA = targetListSetA.getExcludedTargetLists();
            targetListsB = targetListSetB.getExcludedTargetLists();
            diffTargetLists(s, targetListsA, targetListsB);
            sameExcludedLists = same;
            excludedListsInANotInB = inANotInB;
            excludedListsInBNotInA = inBNotInA;
            setProgress(20);
            if (isCancelled()) {
                return null;
            }

            // Diff targets themselves.
            setMessage(resourceMap.getString(COMPARE + ".message3",
                targetListSetA.getName()));
            s.append(resourceMap.getString(COMPARE + ".text.targets",
                targetListSetA.getName(), targetListSetB.getName()));
            List<PlannedTarget> targetsA = uniquePlannedTargets(
                targetListSetA.getTargetLists(),
                targetListSetA.getExcludedTargetLists());
            setProgress(40);
            if (isCancelled()) {
                return null;
            }

            setMessage(resourceMap.getString(COMPARE + ".message3",
                targetListSetB.getName()));
            List<PlannedTarget> targetsB = uniquePlannedTargets(
                targetListSetB.getTargetLists(),
                targetListSetB.getExcludedTargetLists());
            setProgress(60);
            if (isCancelled()) {
                return null;
            }

            setMessage(resourceMap.getString(COMPARE + ".message4"));
            List<Integer> results = TargetListsPanel.diffTargets(s, targetsA,
                targetsB);
            same = results.get(0);
            inANotInB = results.get(1);
            inBNotInA = results.get(2);
            setProgress(100);

            return s.toString();
        }

        private void diffTargetLists(StringBuilder output,
            List<TargetList> targetListsA, List<TargetList> targetListsB) {

            for (int i = 0, m = targetListsA.size(), j = 0, n = targetListsB.size(); i < m
                || j < n;) {
                String targetListNameA = i < m ? targetListsA.get(i)
                    .getName() : null;
                String targetListNameB = j < n ? targetListsB.get(j)
                    .getName() : null;
                if (targetListNameA != null && targetListNameB != null
                    && targetListNameA.equals(targetListNameB)) {
                    same++;
                    i++;
                    j++;
                } else if (targetListNameA != null
                    && (targetListNameB == null || targetListNameA.compareTo(targetListNameB) < 0)) {
                    inANotInB++;
                    output.append(removed);
                    output.append(targetListNameA);
                    output.append("\n");
                    i++;
                } else if (targetListNameB != null
                    && (targetListNameA == null || targetListNameB.compareTo(targetListNameA) < 0)) {
                    inBNotInA++;
                    output.append(added);
                    output.append(targetListNameB);
                    output.append("\n");
                    j++;
                }
            }
        }

        private List<PlannedTarget> uniquePlannedTargets(
            List<TargetList> targetLists, List<TargetList> excludedTargetLists)
            throws Exception {

            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            Set<PlannedTarget> uniqueTargets = new TreeSet<PlannedTarget>();

            for (TargetList targetList : targetLists) {
                for (PlannedTarget plannedTarget : targetSelectionCrud.retrievePlannedTargets(targetList)) {
                    uniqueTargets.add(plannedTarget);
                }
                if (isCancelled()) {
                    return null;
                }
            }

            for (TargetList targetList : excludedTargetLists) {
                for (PlannedTarget plannedTarget : targetSelectionCrud.retrievePlannedTargets(targetList)) {
                    uniqueTargets.remove(plannedTarget);
                }
                if (isCancelled()) {
                    return null;
                }
            }

            return new ArrayList<PlannedTarget>(uniqueTargets);
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetsPanel.this, e, COMPARE);
        }

        @Override
        protected void cancelled() {
            log.info(resourceMap.getString(COMPARE + ".cancelled"));
        }

        @Override
        protected void succeeded(String s) {
            KeplerDialogs.showMessageDialog(TargetListSetsPanel.this,
                resourceMap.getString(COMPARE + ".title",
                    targetListSetA.getName(), targetListSetB.getName()),
                resourceMap.getString(COMPARE + ".text",
                    targetListSetA.getName(), targetListSetB.getName(),
                    sameLists, targetListSetA.getName(),
                    targetListSetB.getName(), listsInANotInB,
                    targetListSetA.getName(), targetListSetB.getName(),
                    listsInBNotInA, targetListSetB.getName(),
                    targetListSetA.getName(), sameExcludedLists,
                    targetListSetA.getName(), targetListSetB.getName(),
                    excludedListsInANotInB, targetListSetA.getName(),
                    targetListSetB.getName(), excludedListsInBNotInA,
                    targetListSetB.getName(), targetListSetA.getName(), same,
                    targetListSetA.getName(), targetListSetB.getName(),
                    inANotInB, targetListSetA.getName(),
                    targetListSetB.getName(), inBNotInA,
                    targetListSetB.getName(), targetListSetA.getName(),
                    targetListSetA.getName(), targetListSetB.getName()), s);
        }
    }

    /**
     * A task for exporting any rejected targets into a target list.
     * 
     * @author Bill Wohler
     */
    private class ExportRejectedTask extends DatabaseTask<Void, Void> {
        private static final String CATEGORY = "Category";
        private static final String REJECTED_BY_COA = "Rejected by COA";
        private TargetListSet targetListSet;
        private File file;

        /**
         * Creates a {@link ExportRejectedTask}.
         * 
         * @param targetListSet the target list set that contains the rejected
         * targets to be exported
         * @param file the output file
         * @throws NullPointerException if any of the arguments are {@code null}
         */
        public ExportRejectedTask(TargetListSet targetListSet, File file) {
            if (targetListSet == null) {
                throw new NullPointerException("targetListSet can't be null");
            }
            if (file == null) {
                throw new NullPointerException("file can't be null");
            }

            this.targetListSet = targetListSet;
            this.file = file;
        }

        @Override
        protected Void doInBackground() throws Exception {
            TargetSelectionCrud targetSelectionCrud = new TargetSelectionCrud();

            long start = System.currentTimeMillis();
            List<PlannedTarget> targets = targetSelectionCrud.retrieveRejectedPlannedTargets(targetListSet);
            log.info(resourceMap.getString(EXPORT_REJECTED + ".loaded",
                targets.size(), System.currentTimeMillis() - start));

            start = System.currentTimeMillis();
            log.info(resourceMap.getString(EXPORT_REJECTED + ".exporting",
                file.getAbsolutePath()));
            Map<String, String> targetListFields = new HashMap<String, String>();
            targetListFields.put(CATEGORY, REJECTED_BY_COA);
            new ExportTask().export(targets, targetListFields, file);
            log.info(resourceMap.getString(EXPORT_REJECTED + ".exported",
                targets.size(), System.currentTimeMillis() - start));

            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(e, EXPORT_REJECTED);
        }

        @Override
        protected void cancelled() {
            log.info(getResourceMap().getString(EXPORT_REJECTED + ".cancelled"));
            super.cancelled();
        }
    }

    /**
     * A task for deleting target list sets.
     * 
     * @author Bill Wohler
     */
    private class DeleteTask extends
        DatabaseTask<List<TargetListSet>, TargetListSet> {

        private List<TargetListSet> targetListSets;

        public DeleteTask(List<TargetListSet> targetListSets) {
            this.targetListSets = targetListSets;
        }

        @Override
        protected List<TargetListSet> doInBackground() throws Exception {
            setProgress(1);
            int i = 1;
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            for (TargetListSet targetListSet : targetListSets) {
                targetSelectionCrud.delete(targetListSet);
                if (!isCancelled()) {
                    setProgress((float) i++ / targetListSets.size());
                    publish(targetListSet);
                } else {
                    EventBus.publish(
                        new TypeReference<UpdateEvent<TargetListSet>>() {
                        }.getType(), new UpdateEvent<TargetListSet>(
                            UpdateEvent.Function.DELETE, targetListSet));
                    return null;
                }
            }

            return targetListSets;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetsPanel.this, e, DELETE, targetListSets);
        }

        @Override
        protected void cancelled() {
            log.info(resourceMap.getString(DELETE + ".cancelled"));
        }

        @Override
        protected void process(List<TargetListSet> values) {
            targetListSetModel.delete(values);
        }
    }

    /**
     * A task for updating target list sets. The action parameter in the
     * constructor is used for constructing an error dialog with
     * KeplerPanel#handleError().
     * 
     * @author Bill Wohler
     */
    private class UpdateTask extends DatabaseTask<List<TargetListSet>, Void> {
        private List<TargetListSet> targetListSets;
        private String action;
        private State state;

        public UpdateTask(List<TargetListSet> targetListSets, String action,
            State state) {
            this.targetListSets = targetListSets;
            this.action = action;
            this.state = state;
        }

        @Override
        protected List<TargetListSet> doInBackground() throws Exception {
            setState(selectedTargetListSets, state);
            ConversationUtils.save();

            return targetListSets;
        }

        /**
         * Sets the state of the given target list sets.
         * 
         * @param targetListSets the target list sets
         * @param state the new state
         */
        private void setState(List<TargetListSet> targetListSets, State state) {
            for (TargetListSet targetListSet : targetListSets) {
                targetListSet.setState(state);

                // Propagate state to TargetTables as well, if present.
                setState(targetListSet.getTargetTable(), state);
                setState(targetListSet.getBackgroundTable(), state);
            }
        }

        /**
         * Sets the state of the given target table.
         * 
         * @param targetTable the target table, may be {@code null}
         * @param state the new state
         */
        private void setState(TargetTable targetTable, State state) {
            if (targetTable != null) {
                targetTable.setState(state);
                MaskTable maskTable = targetTable.getMaskTable();
                if (maskTable != null) {
                    maskTable.setState(state);
                }
            }
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetsPanel.this, e, action, targetListSets);
        }

        @Override
        protected void interrupted(InterruptedException e) {
            failed(e);
        }

        @Override
        protected void succeeded(List<TargetListSet> targetListSets) {
            targetListSetModel.refresh(targetListSets);
            updateEnabled();
        }
    }
}
