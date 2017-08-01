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
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.KeplerUtilities;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.common.UpdateEvent;
import gov.nasa.kepler.ui.proxy.TargetSelectionCrudProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Font;
import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

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
import org.jdesktop.application.ResourceMap;

/**
 * A panel for the target list table.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListsPanel extends ToolPanel {

    private static final String NAME = "targetListsPanel";

    // Actions.
    private static final String CREATE = "create";
    private static final String EDIT = "edit";
    private static final String COPY = "copy";
    private static final String COMPARE = "compare";
    private static final String EXPORT = "export";
    private static final String DELETE = "delete";
    private static final String REFRESH = "refresh";

    // Suffix to build enabled property from action.
    private static final String ENABLED = "Enabled";

    /**
     * List of all actions. Note that adding an action here leads to the
     * creation of both menu items and buttons for it.
     */
    private static final String[] actions = new String[] { CREATE,
        DEFAULT_ACTION_CHAR + EDIT, COPY, COMPARE, EXPORT, DELETE, REFRESH };

    // Bound properties.
    private boolean createEnabled;
    private boolean editEnabled;
    private boolean copyEnabled;
    private boolean compareEnabled;
    private boolean exportEnabled;
    private boolean deleteEnabled;

    // Selected target list sets.
    private List<TargetList> selectedTargetLists = Collections.emptyList();

    private TargetListTableModel targetListModel;
    private ToolTable targetListTable;
    private EventTopicSubscriber selectedTargetListListener;
    private EventSubscriber<UpdateEvent<TargetList>> targetListUpdateListener;
    private EventSubscriber<UpdateEvent<TargetListSet>> targetListSetUpdateListener;
    private TargetListRequestHandler targetListRequestHandler;

    /**
     * Creates a {@link TargetListsPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public TargetListsPanel() throws UiException {
        setName(NAME);
        createUi();
    }

    @Override
    protected void initComponents() {
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        JLabel targetListLabel = new JLabel();
        targetListLabel.setName("targetListLabel");
        targetListLabel.setFont(targetListLabel.getFont()
            .deriveFont(Font.BOLD));

        JPanel targetListToolBar = getToolBar();

        targetListModel = new TargetListTableModel();
        targetListTable = new ToolTable(targetListModel, this);
        JScrollPane scrollPane = new JScrollPane(targetListTable);

        layout.setAutoCreateGaps(true);
        layout.setAutoCreateContainerGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup(Alignment.LEADING)
            .addGroup(
                layout.createSequentialGroup()
                    .addComponent(targetListLabel)
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(targetListToolBar))
            .addComponent(scrollPane));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addGroup(layout.createParallelGroup(Alignment.CENTER)
                .addComponent(targetListLabel)
                .addComponent(targetListToolBar))
            .addComponent(scrollPane));
    }

    @Override
    protected void getData(boolean block) {
        executeDatabaseTask(TargetListLoadTask.NAME, new TargetListLoadTask());
    }

    @Override
    protected void addListeners() {
        selectedTargetListListener = new EventTopicSubscriber() {
            @Override
            @SuppressWarnings("unchecked")
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                setSelectedTargetLists((List<TargetList>) data);
            }
        };
        EventBus.subscribe(targetListTable.getSelectionTopic(),
            selectedTargetListListener);

        targetListUpdateListener = new EventSubscriber<UpdateEvent<TargetList>>() {
            @Override
            public void onEvent(UpdateEvent<TargetList> e) {
                log.debug(e);
                if (reloadingData()) {
                    return;
                }
                switch (e.getFunction()) {
                    case ADD_OR_UPDATE:
                        targetListModel.addOrUpdate(e.get());
                        break;
                    case DELETE:
                        targetListModel.delete(e.get());
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
        EventBus.subscribe(new TypeReference<UpdateEvent<TargetList>>() {
        }.getType(), targetListUpdateListener);

        targetListSetUpdateListener = new EventSubscriber<UpdateEvent<TargetListSet>>() {
            @Override
            public void onEvent(UpdateEvent<TargetListSet> e) {
                log.debug(e);
                switch (e.getFunction()) {
                    case ADD_OR_UPDATE:
                        targetListModel.updateUsedByColumn();
                        break;
                    case DELETE:
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
        }.getType(), targetListSetUpdateListener);
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actions);
    }

    /**
     * Sets the currently selected target lists.
     * 
     * @param targetLists a non-{@code null} list of the selected target lists
     */
    private void setSelectedTargetLists(List<TargetList> targetLists) {
        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }

        selectedTargetLists = targetLists;

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
        setExportEnabled(true);
        setDeleteEnabled(true);
    }

    /**
     * Creates a new target list.
     */
    @Action(enabledProperty = CREATE + ENABLED)
    public void create() {
        log.info(resourceMap.getString(CREATE));
        if (reloadingData()) {
            handleError(null, CREATE + RELOADING_DATA);
            return;
        }
        try {
            TargetListEditor.edit(targetListModel.getTargetLists());
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
     * Edits a target list.
     */
    @Action(enabledProperty = EDIT + ENABLED)
    public void edit() {
        log.info(resourceMap.getString(EDIT, selectedTargetLists.get(0)));
        try {
            if (reloadingData()) {
                handleError(null, EDIT + RELOADING_DATA,
                    selectedTargetLists.get(0));
                return;
            }
            int lockedCount = lockedCount();
            if (lockedCount < 0) {
                // Either no target lists were selected, or the target list sets
                // were being reloaded. The former shouldn't happen. In the
                // latter case, we should have gotten an explanation dialog from
                // the TargetListSetPanel and so don't need to tell the user
                // here. Either way, we need to wait.
                return;
            }
            boolean readOnly = lockedCount > 0;
            TargetListEditor.edit(selectedTargetLists.get(0),
                targetListModel.getTargetLists(), readOnly);
        } catch (UiException e) {
            handleError(e, EDIT, selectedTargetLists.get(0));
        }
    }

    public boolean isEditEnabled() {
        return editEnabled;
    }

    public void setEditEnabled(boolean editEnabled) {
        boolean oldValue = this.editEnabled;
        this.editEnabled = editEnabled && selectedTargetLists.size() == 1;
        firePropertyChange(EDIT + ENABLED, oldValue, this.editEnabled);
    }

    /**
     * Copies a target list.
     */
    @Action(enabledProperty = COPY + ENABLED)
    public void copy() {
        TargetList targetListToCopy = selectedTargetLists.get(0);
        log.info(resourceMap.getString(COPY, targetListToCopy));
        if (reloadingData()) {
            handleError(null, COPY + RELOADING_DATA, targetListToCopy);
            return;
        }

        // Find a unique new name for the first target list in the list.
        Set<String> targetListNames = new HashSet<String>();
        for (TargetList targetList : targetListModel.getTargetLists()) {
            targetListNames.add(targetList.getName());
        }
        String name = KeplerUtilities.createNewName(targetListToCopy.getName(),
            targetListNames);
        if (name == null) {
            handleError(null, "copy.couldntFindUniqueAlternative",
                selectedTargetLists);
            return;
        }

        // Make a copy of the target list using the unique name.
        TargetList newTargetList = new TargetList(name, targetListToCopy);

        // Store it and update views.
        executeDatabaseTask(COPY, new CopyTask(targetListToCopy, newTargetList));
    }

    public boolean isCopyEnabled() {
        return copyEnabled;
    }

    public void setCopyEnabled(boolean copyEnabled) {
        boolean oldValue = this.copyEnabled;
        this.copyEnabled = copyEnabled && selectedTargetLists.size() == 1;
        firePropertyChange(COPY + ENABLED, oldValue, this.copyEnabled);
    }

    /**
     * Compares two target lists.
     */
    @Action(enabledProperty = COMPARE + ENABLED)
    public void compare() {
        log.info(resourceMap.getString(COMPARE, selectedTargetLists));
        if (reloadingData()) {
            handleError(null, COMPARE + RELOADING_DATA, selectedTargetLists);
            return;
        }
        executeDatabaseTask(COMPARE, new CompareTask(
            selectedTargetLists.get(0), selectedTargetLists.get(1)));
    }

    public boolean isCompareEnabled() {
        return compareEnabled;
    }

    public void setCompareEnabled(boolean compareEnabled) {
        boolean oldValue = this.compareEnabled;
        this.compareEnabled = compareEnabled && selectedTargetLists.size() == 2;
        firePropertyChange(COMPARE + ENABLED, oldValue, this.compareEnabled);
    }

    /**
     * Exports a target list.
     */
    @Action(enabledProperty = EXPORT + ENABLED)
    public void export() {
        log.info(resourceMap.getString(EXPORT, selectedTargetLists.get(0)));
        if (reloadingData()) {
            handleError(null, EXPORT + RELOADING_DATA,
                selectedTargetLists.get(0));
            return;
        }
        File file = KeplerDialogs.showSaveFileChooserDialog(this);
        executeDatabaseTask(EXPORT, new ExportTask(this, resourceMap, EXPORT,
            selectedTargetLists.get(0), file));
    }

    public boolean isExportEnabled() {
        return exportEnabled;
    }

    public void setExportEnabled(boolean exportEnabled) {
        boolean oldValue = this.exportEnabled;
        this.exportEnabled = exportEnabled && selectedTargetLists.size() == 1;
        firePropertyChange(EXPORT + ENABLED, oldValue, this.exportEnabled);
    }

    /**
     * Produces a diff of the two lists of targets and writes it into
     * {@code output}. The format is:
     * 
     * <pre>
     * &lt; Line in targetsA
     * &gt; Line in targetsB
     * </pre>
     * 
     * @param output where the diff is written
     * @param targetsA the first list of targets
     * @param targetsB the second list of targets
     * @return an array containing the number of targets that are same, the
     * number of targets only in {@code targetsA}, and the number of targets
     * only in {@code targetsB}
     */
    public static List<Integer> diffTargets(StringBuilder output,
        List<PlannedTarget> targetsA, List<PlannedTarget> targetsB) {

        int same = 0;
        int inANotInB = 0;
        int inBNotInA = 0;

        ResourceMap resourceMap = appContext.getResourceMap(TargetListsPanel.class);
        String added = resourceMap.getString("compare.text.added");
        String removed = resourceMap.getString("compare.text.removed");

        for (int i = 0, m = targetsA.size(), j = 0, n = targetsB.size(); i < m
            || j < n;) {
            int keplerIdA = i < m ? targetsA.get(i)
                .getKeplerId() : -1;
            int keplerIdB = j < n ? targetsB.get(j)
                .getKeplerId() : -1;
            if (keplerIdA == keplerIdB) {
                same++;
                i++;
                j++;
            } else if (keplerIdA >= 0 && keplerIdA < keplerIdB || keplerIdB < 0) {
                inANotInB++;
                output.append(removed);
                output.append(keplerIdA);
                output.append("\n");
                i++;
            } else if (keplerIdB >= 0 && keplerIdA > keplerIdB || keplerIdA < 0) {
                inBNotInA++;
                output.append(added);
                output.append(keplerIdB);
                output.append("\n");
                j++;
            }
        }

        List<Integer> results = new ArrayList<Integer>(3);
        results.add(same);
        results.add(inANotInB);
        results.add(inBNotInA);

        return results;
    }

    /**
     * Deletes target lists.
     */
    @Action(enabledProperty = DELETE + ENABLED)
    public void delete() {
        log.info(resourceMap.getString(DELETE, selectedTargetLists));
        if (reloadingData()) {
            handleError(null, DELETE + RELOADING_DATA, selectedTargetLists);
            return;
        }

        if (warnUser(DELETE, selectedTargetLists)) {
            return;
        }

        // Delete it from database and update views.
        executeDatabaseTask(DELETE, new DeleteTask(selectedTargetLists));
    }

    public boolean isDeleteEnabled() {
        return deleteEnabled;
    }

    public void setDeleteEnabled(boolean deleteEnabled) {
        boolean oldValue = this.deleteEnabled;
        this.deleteEnabled = deleteEnabled && selectedTargetLists.size() > 0
            && lockedCount() == 0;
        firePropertyChange(DELETE + ENABLED, oldValue, this.deleteEnabled);
    }

    /**
     * Returns a count of the selected target lists that are locked. This means
     * that there are target list sets which reference them.
     * 
     * @return the number of selected target lists that are locked, or -1 if
     * there aren't any selected target lists
     */
    private int lockedCount() {
        if (selectedTargetLists.size() == 0) {
            return -1;
        }

        int count = 0;

        DataRequestEvent<List<TargetListSet>> request = new DataRequestEvent<List<TargetListSet>>();
        EventBus.publish(
            new TypeReference<DataRequestEvent<List<TargetListSet>>>() {
            }.getType(), request);
        if (request.getData() == null) {
            // The target list sets panel must be still reloading...
            return -1;
        }
        for (TargetListSet targetListSet : request.getData()) {
            for (TargetList targetList : targetListSet.getTargetLists()) {
                if (selectedTargetLists.contains(targetList)) {
                    count++;
                    break;
                }
            }
            for (TargetList targetList : targetListSet.getExcludedTargetLists()) {
                if (selectedTargetLists.contains(targetList)) {
                    count++;
                    break;
                }
            }
        }
        log.debug("Target lists " + selectedTargetLists + " are in use by "
            + count + " target list sets");

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
     * A task for loading target lists from the database in the background.
     * 
     * @author Bill Wohler
     */
    private class TargetListLoadTask extends
        DatabaseTask<List<TargetList>, Void> {

        private static final String NAME = "TargetListLoadTask";

        @Override
        protected List<TargetList> doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();

            EventBus.publish(new StatusEvent(TargetListsPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .started());
            log.info(resourceMap.getString(NAME + ".loading"));
            DatabaseServiceFactory.getInstance()
                .evictAll(targetListModel.getTargetLists());
            List<TargetList> targetLists = targetSelectionCrud.retrieveAllTargetLists();
            log.info(resourceMap.getString(NAME + ".loaded", targetLists.size()));

            return targetLists;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListsPanel.this, e, NAME);
            EventBus.publish(new StatusEvent(TargetListsPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .failed());
        }

        @Override
        protected void succeeded(List<TargetList> result) {
            targetListModel.setTargetLists(result);
            setDataValid(true);
            updateEnabled();
            EventBus.publish(new StatusEvent(TargetListsPanel.this).message(
                resourceMap.getString(NAME + ".retrieving"))
                .done());

            // Now that we have target lists, we can answer requests for
            // them. Since this task can be called multiple times via the
            // refresh button, be careful not to subscribe more than once.
            if (targetListRequestHandler == null) {
                targetListRequestHandler = new TargetListRequestHandler();
                EventBus.subscribe(
                    new TypeReference<DataRequestEvent<List<TargetList>>>() {
                    }.getType(), targetListRequestHandler);
            }
        }
    }

    /**
     * Handles requests for {@code DataRequestEvent<List<TargetList>>>} events.
     * 
     * @author Bill Wohler
     */
    private class TargetListRequestHandler implements
        EventSubscriber<DataRequestEvent<List<TargetList>>> {

        @Override
        public void onEvent(DataRequestEvent<List<TargetList>> e) {
            log.debug(e);
            if (reloadingData()) {
                return;
            }
            e.setData(targetListModel.getTargetLists());
        }
    }

    /**
     * A task for saving a copied target list.
     * 
     * @author Bill Wohler
     */
    private class CopyTask extends DatabaseTask<TargetList, Void> {
        private TargetList targetList;
        private TargetList newTargetList;

        public CopyTask(TargetList targetList, TargetList newTargetList) {
            setUserCanCancel(false);
            this.targetList = targetList;
            this.newTargetList = newTargetList;
        }

        @Override
        protected TargetList doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();

            // Save copy of target list object.
            targetSelectionCrud.create(newTargetList);

            // Now copy targets themselves.
            List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(targetList);
            List<PlannedTarget> newTargets = new ArrayList<PlannedTarget>(
                targets.size());
            for (PlannedTarget target : targets) {
                PlannedTarget newTarget = new PlannedTarget(target);
                newTarget.setTargetList(newTargetList);
                newTargets.add(newTarget);
            }
            targetSelectionCrud.create(newTargets);

            return newTargetList;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListsPanel.this, e, COPY, newTargetList);
        }

        @Override
        protected void succeeded(TargetList newTargetList) {
            targetListModel.add(targetList, newTargetList);
        }
    }

    /**
     * A task for comparing two target lists.
     * <p>
     * Requirements: SOC_REQ_IMPL 171.CM.4
     * 
     * @author Bill Wohler
     */
    private class CompareTask extends DatabaseTask<String, Void> {
        private TargetList targetListA;
        private TargetList targetListB;
        private int same;
        private int inANotInB;
        private int inBNotInA;

        public CompareTask(TargetList targetListA, TargetList targetListB) {
            this.targetListA = targetListA;
            this.targetListB = targetListB;
        }

        @Override
        protected String doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            StringBuilder s = new StringBuilder();

            List<PlannedTarget> targetsA = targetSelectionCrud.retrievePlannedTargets(targetListA);
            setProgress(30);
            if (isCancelled()) {
                return null;
            }

            List<PlannedTarget> targetsB = targetSelectionCrud.retrievePlannedTargets(targetListB);
            setProgress(60);
            if (isCancelled()) {
                return null;
            }

            List<Integer> results = diffTargets(s, targetsA, targetsB);
            same = results.get(0);
            inANotInB = results.get(1);
            inBNotInA = results.get(2);
            setProgress(100);

            return s.toString();
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListsPanel.this, e, COMPARE);
        }

        @Override
        protected void cancelled() {
            log.info(resourceMap.getString(COMPARE + ".cancelled"));
            super.cancelled();
        }

        @Override
        protected void succeeded(String s) {
            KeplerDialogs.showMessageDialog(TargetListsPanel.this,
                resourceMap.getString(COMPARE + ".title",
                    targetListA.getName(), targetListB.getName()),
                resourceMap.getString(COMPARE + ".text", targetListA.getName(),
                    targetListB.getName(), same, targetListA.getName(),
                    targetListB.getName(), inANotInB, targetListA.getName(),
                    targetListB.getName(), inBNotInA, targetListB.getName(),
                    targetListA.getName(), targetListA.getName(),
                    targetListB.getName(), s));
        }
    }

    /**
     * A task for deleting target lists.
     * 
     * @author Bill Wohler
     */
    private class DeleteTask extends DatabaseTask<List<TargetList>, TargetList> {
        private List<TargetList> targetLists;

        public DeleteTask(List<TargetList> targetLists) {
            this.targetLists = targetLists;
        }

        @Override
        protected List<TargetList> doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();

            for (TargetList targetList : targetLists) {
                targetSelectionCrud.delete(targetList);
                if (!isCancelled()) {
                    publish(targetList);
                } else {
                    EventBus.publish(
                        new TypeReference<UpdateEvent<TargetList>>() {
                        }.getType(), new UpdateEvent<TargetList>(
                            UpdateEvent.Function.DELETE, targetList));
                    return null;
                }
            }

            return targetLists;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListsPanel.this, e, DELETE, targetLists);
        }

        @Override
        protected void cancelled() {
            log.info(resourceMap.getString(DELETE + ".cancelled"));
        }

        @Override
        protected void process(List<TargetList> values) {
            targetListModel.delete(values);
        }
    }
}
