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

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.ui.cm.TargetListTableModel.Column;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.common.UpdateEvent;
import gov.nasa.kepler.ui.proxy.TargetSelectionCrudProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.KeplerSwingUtilities;
import gov.nasa.kepler.ui.swing.PanelHeader;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Color;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.text.DateFormat;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.swing.ComboBoxModel;
import javax.swing.DefaultComboBoxModel;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.SwingConstants;
import javax.swing.WindowConstants;
import javax.swing.event.TableModelEvent;
import javax.swing.event.TableModelListener;
import javax.swing.text.JTextComponent;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventTopicSubscriber;
import org.bushe.swing.event.generics.TypeReference;
import org.jdesktop.application.Action;

/**
 * A target list set editor. Use the static factory {@link #edit(List)} to
 * create a new target list set. Use {@link #edit(TargetListSet, List)} to edit
 * (or view) an existing target list set.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD_STORE")
public class TargetListSetEditor extends ToolPanel {

    // UI constants.
    private static final int MAX_NAME_COLUMNS = 20;
    private static final String NEW_TARGET_LIST_SET_NAME = "Unsaved Target List Set";

    // Actions.
    public static final String NAME = "targetListSetEditor";
    private static final String UPDATE = "updateTargetCounts";
    private static final String ADD = "addTargetLists";
    private static final String VIEW = "viewTargetList";
    private static final String DELETE = "deleteTargetLists";
    private static final String SAVE = "save";
    private static final String CANCEL = "cancel";

    // Suffix to build enabled property from action.
    private static final String ENABLED = "Enabled";

    /**
     * List of all actions. Note that adding an action here leads to the
     * creation of both menu items and buttons for it.
     */
    private static final String[] actions = new String[] { ADD,
        DEFAULT_ACTION_CHAR + VIEW, DELETE };

    // Bound properties.
    private boolean addTargetListsEnabled;
    private boolean viewTargetListEnabled;
    private boolean deleteTargetListsEnabled;
    private boolean saveEnabled;

    // UI components.
    private PanelHeader panelHeader;
    private JTextField name;
    private JComboBox targetDefinitionTable;
    private JComboBox start;
    private JComboBox end;
    private JLabel totalIncludedTargetCount;
    private JLabel totalExcludedTargetCount;
    private JLabel totalTargetCount;
    private JLabel totalUniqueTargetCount;
    private JLabel targetCountWarningLabel;
    private ToolTable targetListTable;
    private TargetListTableModel targetListModel;
    private JButton saveButton;

    private static Map<TargetListSet, JDialog> dialogCache = new HashMap<TargetListSet, JDialog>();

    /**
     * Remember the original target list set so that we can disable save button
     * if the user reverts the name back to the original, and update it when the
     * user does save his changes.
     */
    private TargetListSet origTargetListSet;

    /** Target list set we're editing, a copy of {@code origTargetListSet}. */
    private TargetListSet targetListSet;

    /** All target list sets, used to check for duplicate names. */
    private List<TargetListSet> targetListSets;

    /** Selected target lists. */
    private List<TargetList> selectedTargetLists = Collections.emptyList();

    private EventTopicSubscriber targetListSelectionListener;
    private ActionListener targetListSetActionListener = new TargetListSetActionListener();
    private TableModelListener includeExcludeToggle = new IncludeExcludeToggle();

    private DateFormat iso8601DateFormat = Iso8601Formatter.dateTimeFormatter();

    /**
     * Creates a {@link TargetListSetEditor} with the given target list set.
     * 
     * @param targetListSet a non-{@code null} target list set
     * @param targetListSets a list of target list sets which is used to avoid
     * duplicate names; must be non-{@code null} if the given {@code targetList}
     * is not locked
     * @throws NullPointerException if {@code targetListSet} is {@code null}, or
     * {@code targetListSets} is {@code null} and the given {@code targetList}
     * is not locked
     * @throws UiException if the editor could not be created
     */
    private TargetListSetEditor(TargetListSet targetListSet,
        List<TargetListSet> targetListSets) throws UiException {

        if (targetListSet == null) {
            throw new NullPointerException("targetListSet can't be null");
        }
        if (targetListSets == null && targetListSet.getState()
            .unlocked()) {
            throw new NullPointerException("targetListSets can't be null");
        }

        origTargetListSet = targetListSet;
        this.targetListSet = new TargetListSet(targetListSet.getName(),
            targetListSet);
        this.targetListSets = targetListSets;

        targetListModel = new TargetListTableModel(
            this.targetListSet.getTargetLists(),
            this.targetListSet.getExcludedTargetLists(),
            !this.targetListSet.getState()
                .locked());

        createUi();
    }

    @Override
    protected void initComponents() throws UiException {
        panelHeader = new PanelHeader();
        panelHeader.setName("header");

        JLabel informationLabel = new JLabel();
        informationLabel.setName("informationLabel");
        informationLabel.setFont(informationLabel.getFont()
            .deriveFont(Font.BOLD));
        informationLabel.setFocusable(false);

        JLabel nameLabel = new JLabel();
        nameLabel.setName("nameLabel");
        name = new JTextField(targetListSet.getName()
            .trim(), MAX_NAME_COLUMNS);
        nameLabel.setLabelFor(name);
        if (targetListSet.getState()
            .unlocked()) {
            if (getNameText().equals(NEW_TARGET_LIST_SET_NAME)) {
                name.selectAll();
            }
        } else {
            name.setEnabled(false);
        }

        JLabel targetDefinitionTableLabel = new JLabel();
        targetDefinitionTableLabel.setName("targetDefinitionTableLabel");

        targetDefinitionTable = new JComboBox(new DefaultComboBoxModel(
            TargetType.values()));
        // Background targets are generated programmatically, so don't let
        // user choose them as a target definition table.
        targetDefinitionTable.removeItem(TargetType.BACKGROUND);
        targetDefinitionTable.setSelectedItem(targetListSet.getType());
        targetDefinitionTable.addActionListener(targetListSetActionListener);
        targetDefinitionTableLabel.setLabelFor(targetDefinitionTable);
        if (targetListSet.getState()
            .locked()) {
            targetDefinitionTable.setEnabled(false);
        }

        JLabel startLabel = new JLabel();
        startLabel.setName("startLabel");

        ComboBoxModel comboBoxModel = new QuarterlyRollDateModel(
            targetListSet.getStart());
        start = new JComboBox(comboBoxModel);
        start.addActionListener(targetListSetActionListener);
        startLabel.setLabelFor(start);
        if (targetListSet.getState()
            .locked()) {
            start.setEnabled(false);
        }

        JLabel endLabel = new JLabel();
        endLabel.setName("endLabel");

        comboBoxModel = new QuarterlyRollDateModel(targetListSet.getEnd());
        end = new JComboBox(comboBoxModel);
        end.addActionListener(targetListSetActionListener);
        endLabel.setLabelFor(end);
        if (targetListSet.getState()
            .locked()) {
            end.setEnabled(false);
        }

        // Second column.
        JLabel stateLabel = new JLabel();
        stateLabel.setName("stateLabel");
        stateLabel.setFocusable(false);

        JLabel state = new JLabel(targetListSet.getState()
            .toString());
        state.setFocusable(false);

        JLabel totalIncludedTargetCountLabel = new JLabel();
        totalIncludedTargetCountLabel.setName("totalIncludedCountLabel");
        totalIncludedTargetCountLabel.setFocusable(false);

        totalIncludedTargetCount = new JLabel();
        totalIncludedTargetCount.setFocusable(false);

        JLabel totalExcludedTargetCountLabel = new JLabel();
        totalExcludedTargetCountLabel.setName("totalExcludedCountLabel");
        totalExcludedTargetCountLabel.setFocusable(false);

        totalExcludedTargetCount = new JLabel();
        totalExcludedTargetCount.setFocusable(false);

        JLabel totalTargetCountLabel = new JLabel();
        totalTargetCountLabel.setName("totalCountLabel");
        totalTargetCountLabel.setFocusable(false);

        totalTargetCount = new JLabel();
        totalTargetCount.setFocusable(false);

        JLabel totalUniqueTargetCountLabel = new JLabel();
        totalUniqueTargetCountLabel.setName("totalUniqueCountLabel");
        totalUniqueTargetCountLabel.setFocusable(false);

        totalUniqueTargetCount = new JLabel();
        totalUniqueTargetCount.setFocusable(false);

        targetCountWarningLabel = new JLabel();
        targetCountWarningLabel.setFocusable(false);

        JButton updateCountsButton = new JButton(actionMap.get(UPDATE));

        JLabel targetListsLabel = new JLabel();
        targetListsLabel.setName("targetListsLabel");
        targetListsLabel.setFont(targetListsLabel.getFont()
            .deriveFont(Font.BOLD));
        targetListsLabel.setFocusable(false);

        JPanel toolBar = getToolBar();

        targetListTable = new ToolTable(targetListModel, this);
        JScrollPane scrollPane = new JScrollPane(targetListTable);

        JSeparator separator = new JSeparator();
        saveButton = new JButton(actionMap.get(SAVE));
        JButton cancelButton = new JButton(actionMap.get(CANCEL));

        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);

        int targetCountWidth = KeplerSwingUtilities.textWidth(
            totalIncludedTargetCount, resourceMap.getString("UPDATE" + ".text"));

        layout.setAutoCreateGaps(true);
        layout.setAutoCreateContainerGaps(true);
        layout.linkSize(saveButton, cancelButton);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addGroup(
                layout.createSequentialGroup()
                    .addGroup(
                        layout.createParallelGroup()
                            .addComponent(informationLabel)
                            .addGroup(
                                layout.createSequentialGroup()
                                    .addPreferredGap(informationLabel,
                                        nameLabel, ComponentPlacement.INDENT)
                                    .addGroup(
                                        layout.createParallelGroup()
                                            .addComponent(nameLabel)
                                            .addComponent(
                                                targetDefinitionTableLabel)
                                            .addComponent(startLabel)
                                            .addComponent(endLabel))
                                    .addGroup(
                                        layout.createParallelGroup()
                                            .addComponent(name,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.PREFERRED_SIZE)
                                            .addGroup(
                                                layout.createSequentialGroup()
                                                    .addGroup(
                                                        layout.createParallelGroup()
                                                            .addComponent(
                                                                targetDefinitionTable)
                                                            .addComponent(start)
                                                            .addComponent(end))
                                                    .addPreferredGap(
                                                        ComponentPlacement.RELATED,
                                                        GroupLayout.DEFAULT_SIZE,
                                                        Short.MAX_VALUE)))))
                    .addPreferredGap(ComponentPlacement.UNRELATED)
                    .addGroup(
                        layout.createSequentialGroup()
                            .addGroup(layout.createParallelGroup()
                                .addComponent(stateLabel)
                                .addComponent(totalIncludedTargetCountLabel)
                                .addComponent(totalExcludedTargetCountLabel)
                                .addComponent(totalTargetCountLabel)
                                .addComponent(totalUniqueTargetCountLabel)
                                .addComponent(targetCountWarningLabel))
                            .addGroup(
                                layout.createParallelGroup(Alignment.TRAILING)
                                    .addComponent(state)
                                    .addComponent(totalIncludedTargetCount,
                                        Alignment.TRAILING, targetCountWidth,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE)
                                    .addComponent(totalExcludedTargetCount,
                                        Alignment.TRAILING, targetCountWidth,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE)
                                    .addComponent(totalTargetCount,
                                        Alignment.TRAILING, targetCountWidth,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE)
                                    .addComponent(totalUniqueTargetCount,
                                        Alignment.TRAILING, targetCountWidth,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE)
                                    .addComponent(updateCountsButton,
                                        Alignment.TRAILING, targetCountWidth,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE))
                            .addPreferredGap(ComponentPlacement.UNRELATED,
                                GroupLayout.PREFERRED_SIZE, Short.MAX_VALUE)))
            .addGroup(
                layout.createSequentialGroup()
                    .addComponent(targetListsLabel)
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(toolBar))
            .addComponent(scrollPane)
            .addComponent(separator)
            .addGroup(
                layout.createSequentialGroup()
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(cancelButton)
                    .addComponent(saveButton)));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(informationLabel)
            .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                .addGroup(layout.createSequentialGroup()
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(nameLabel)
                        .addComponent(name))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(targetDefinitionTableLabel)
                        .addComponent(targetDefinitionTable))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(startLabel)
                        .addComponent(start))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(endLabel)
                        .addComponent(end)))
                .addGroup(layout.createSequentialGroup()
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(stateLabel)
                        .addComponent(state))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(totalIncludedTargetCountLabel)
                        .addComponent(totalIncludedTargetCount))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(totalExcludedTargetCountLabel)
                        .addComponent(totalExcludedTargetCount))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(totalTargetCountLabel)
                        .addComponent(totalTargetCount))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(totalUniqueTargetCountLabel)
                        .addComponent(totalUniqueTargetCount))
                    .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                        .addComponent(targetCountWarningLabel)
                        .addComponent(updateCountsButton))))
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addGroup(layout.createParallelGroup(Alignment.CENTER)
                .addComponent(targetListsLabel)
                .addComponent(toolBar))
            .addComponent(scrollPane)
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(separator, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addGroup(layout.createParallelGroup()
                .addComponent(cancelButton)
                .addComponent(saveButton)));

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
     * Returns the content of the name field while stripping leading and
     * trailing whitespace.
     * 
     * @return the content of the name field with leading and trailing
     * whitespace stripped
     */
    private String getNameText() {
        return name.getText()
            .trim();
    }

    @Override
    protected void configureComponents() {
        targetListModel.addTableModelListener(includeExcludeToggle);

        name.getDocument()
            .addDocumentListener(dirtyDocumentListener);
        start.setEditable(true);
        end.setEditable(true);

        totalIncludedTargetCount.setHorizontalAlignment(SwingConstants.RIGHT);
        totalExcludedTargetCount.setHorizontalAlignment(SwingConstants.RIGHT);
        totalTargetCount.setHorizontalAlignment(SwingConstants.RIGHT);
        totalUniqueTargetCount.setHorizontalAlignment(SwingConstants.RIGHT);
    }

    @Override
    protected void addListeners() {
        targetListSelectionListener = new EventTopicSubscriber() {
            @Override
            @SuppressWarnings("unchecked")
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                setSelectedTargetLists((List<TargetList>) data);
            }
        };

        // See Support.actionPerformed for start and end listeners.
        EventBus.subscribe(targetListTable.getSelectionTopic(),
            targetListSelectionListener);
    }

    /**
     * Returns the Save button for this panel.
     */
    @Override
    protected JButton getDefaultButton() {
        return saveButton;
    }

    @Override
    protected JComponent getDefaultFocusComponent() {
        return name;
    }

    @Override
    protected List<String> getActionStrings() {
        return Arrays.asList(actions);
    }

    /**
     * Sets the currently selected target lists.
     * 
     * @param targetLists a non-{@code null} list of the selected target lists
     * @throws NullPointerException if {@code targetLists} is {@code null}
     */
    private void setSelectedTargetLists(List<TargetList> targetLists) {
        if (targetLists == null) {
            throw new NullPointerException("targetLists can't be null");
        }

        selectedTargetLists = targetLists;

        updateEnabled();
    }

    /**
     * Updates the actions' enabled state. Tries to enable the actions subject
     * to the setters' logic. Call this after updating the selection, or running
     * a command which might change the state of the current selection.
     */
    @Override
    protected void updateEnabled() {
        setHelpText(null);
        setAddTargetListsEnabled(true);
        setViewTargetListEnabled(true);
        setDeleteTargetListsEnabled(true);
        setSaveEnabled(true);

        setTitle(isDirty(), getNameText());
        if (!isUiInitializing()) {
            panelHeader.displayHelp(getHelpType(), getHelpText());
        }
    }

    /**
     * Create a new target list set.
     * 
     * @param targetListSets a list of target lists which is used to avoid
     * duplicate names; must be non-{@code null}
     * @throws NullPointerException if {@code targetListSets} is {@code null}
     * @throws UiException if the editor could not be created
     */
    public static void edit(List<TargetListSet> targetListSets)
        throws UiException {
        edit(new TargetListSet(NEW_TARGET_LIST_SET_NAME), targetListSets);
    }

    /**
     * Edit the given target list set.
     * 
     * @param targetListSet a non-{@code null} target list set
     * @param targetListSets a list of target lists which is used to avoid
     * duplicate names. Must be non-{@code null}
     * @throws NullPointerException if {@code targetListSet} is {@code null}, or
     * {@code targetListSets} is {@code null} and the given {@code targetList}
     * is not locked
     * @throws UiException if the editor could not be created
     */
    public static void edit(TargetListSet targetListSet,
        List<TargetListSet> targetListSets) throws UiException {

        if (targetListSet == null) {
            throw new NullPointerException("targetListSet can't be null");
        }
        if (targetListSets == null && targetListSet.getState()
            .unlocked()) {
            throw new NullPointerException("targetListSets can't be null");
        }

        JDialog dialog = dialogCache.get(targetListSet);
        if (dialog == null) {
            dialog = new JDialog();
            dialog.setName(NAME);
            final TargetListSetEditor editor = new TargetListSetEditor(
                targetListSet, targetListSets);
            dialog.add(editor);
            editor.setTitle(false, targetListSet);
            dialogCache.put(targetListSet, dialog);
            dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
            dialog.addWindowListener(new WindowAdapter() {
                @Override
                public void windowClosing(WindowEvent e) {
                    editor.dismissDialog();
                }
            });
            editor.initDefaultKeys();
            app.show(dialog);
        } else {
            dialog.setVisible(true);
            dialog.toFront();
        }
    }

    /**
     * Update the target counts and update the UI accordingly.
     */
    @Action
    public void updateTargetCounts() {
        log.info(resourceMap.getString(UPDATE));
        executeDatabaseTask(UniqueTargetCountTask.NAME,
            new UniqueTargetCountTask(targetListModel.getTargetLists(),
                targetListModel.getExcludedTargetLists()));
    }

    /**
     * Adds a new target list.
     */
    @Action(enabledProperty = ADD + ENABLED)
    public void addTargetLists() {
        log.info(resourceMap.getString(ADD));
        try {
            List<TargetList> targetLists = TargetListSelectionPanel.getTargetLists();
            log.info(resourceMap.getString(ADD + ".selected", targetLists));
            if (targetLists.size() > 0) {
                targetListModel.addAll(targetLists);
                setDirty(true);
            }
        } catch (UiException e) {
            handleError(this, e, ADD);
        }
    }

    public boolean isAddTargetListsEnabled() {
        return addTargetListsEnabled;
    }

    public void setAddTargetListsEnabled(boolean addTargetListsEnabled) {
        boolean oldValue = this.addTargetListsEnabled;
        this.addTargetListsEnabled = addTargetListsEnabled
            && targetListSet.getState()
                .unlocked();
        firePropertyChange(ADD + ENABLED, oldValue, this.addTargetListsEnabled);
    }

    /**
     * Views a target list.
     */
    @Action(enabledProperty = VIEW + ENABLED)
    public void viewTargetList() {
        log.info(resourceMap.getString(VIEW, selectedTargetLists.get(0)));
        try {
            TargetListEditor.edit(targetListSet, selectedTargetLists.get(0));
        } catch (UiException e) {
            handleError(e, VIEW, selectedTargetLists.get(0));
        }
    }

    public boolean isViewTargetListEnabled() {
        return viewTargetListEnabled;
    }

    public void setViewTargetListEnabled(boolean viewTargetListEnabled) {
        boolean oldValue = this.viewTargetListEnabled;
        this.viewTargetListEnabled = viewTargetListEnabled
            && selectedTargetLists.size() == 1;
        firePropertyChange(VIEW + ENABLED, oldValue, this.viewTargetListEnabled);
    }

    /**
     * Deletes target lists.
     */
    @Action(enabledProperty = DELETE + ENABLED)
    public void deleteTargetLists() {
        log.info(resourceMap.getString(DELETE, selectedTargetLists));

        if (warnUser(DELETE, selectedTargetLists)) {
            return;
        }

        targetListModel.delete(selectedTargetLists);
        setDirty(true);
    }

    public boolean isDeleteTargetListsEnabled() {
        return deleteTargetListsEnabled;
    }

    public void setDeleteTargetListsEnabled(boolean deleteTargetListsEnabled) {
        boolean oldValue = this.deleteTargetListsEnabled;
        this.deleteTargetListsEnabled = deleteTargetListsEnabled
            && selectedTargetLists.size() > 0 && targetListSet.getState()
                .unlocked();
        firePropertyChange(DELETE + ENABLED, oldValue,
            this.deleteTargetListsEnabled);
    }

    /**
     * Saves the target list set. This method is called when the Save button is
     * pressed.
     */
    @Action(enabledProperty = SAVE + ENABLED)
    public void save() {
        log.info(resourceMap.getString(SAVE, getNameText()));
        if (openTargetListCheck()) {
            return;
        }

        origTargetListSet.setName(getNameText());
        origTargetListSet.setType((TargetType) targetDefinitionTable.getSelectedItem());
        origTargetListSet.setTargetLists(targetListModel.getTargetLists());
        origTargetListSet.setExcludedTargetLists(targetListModel.getExcludedTargetLists());

        try {
            // Protect against throw NullPointerException in case dates weren't
            // loaded. The lack of dates should be enough to tell user that
            // something needs to be done (since calling System.exit() from
            // QuarterlyRollDatesModel would be a bad idea).
            String date = (String) start.getSelectedItem();
            if (date != null) {
                origTargetListSet.setStart(iso8601DateFormat.parse(date));
            }
            date = (String) end.getSelectedItem();
            if (date != null) {
                origTargetListSet.setEnd(iso8601DateFormat.parse(date));
            }
        } catch (ParseException e) {
            handleError(this, e, SAVE + ".parse", origTargetListSet);
            return;
        }

        // Attempt to save this target list set.
        executeDatabaseTask(SAVE, new SaveTask(origTargetListSet));
    }

    public boolean isSaveEnabled() {
        return saveEnabled;
    }

    public void setSaveEnabled(boolean saveEnabled) {
        boolean oldValue = this.saveEnabled;
        String s = getNameText();
        this.saveEnabled = saveEnabled
            && isDirty()
            && conditionalHelp(s.length() > 0, "targetListSetName.help")
            && conditionalHelp(!s.equals(NEW_TARGET_LIST_SET_NAME),
                "targetListSetName.help")
            && conditionalHelp(!duplicate(s), "duplicate.help")
            && conditionalHelp(((JTextField) start.getEditor()
                .getEditorComponent()).getText()
                .length() > 0, "start.help")
            && conditionalHelp(((JTextField) end.getEditor()
                .getEditorComponent()).getText()
                .length() > 0, "end.help") && targetListSet.getState()
                .unlocked();
        firePropertyChange(SAVE + ENABLED, oldValue, this.saveEnabled);
    }

    /**
     * Returns {@code true} if the given name is already in use.
     * 
     * @param name the name to check
     * @return {@code true} if the given name is already in use; otherwise
     * {@code false}
     */
    private boolean duplicate(String name) {
        for (TargetListSet targetListSet : targetListSets) {
            if (targetListSet.getName()
                .equals(name) && targetListSet != origTargetListSet) {
                return true;
            }
        }
        return false;
    }

    /**
     * Discards the changes to the target list set. This method is called when
     * the Cancel button is pressed.
     */
    @Action
    public void cancel() {
        log.info(resourceMap.getString(CANCEL, targetListSet));
        if (openTargetListCheck()) {
            return;
        }

        dismissDialog();
    }

    /**
     * Checks for open target lists. If an open target list is found, a dialog
     * is displayed and this method returns {@code true}. Otherwise,
     * {@code false} is returned.
     * 
     * @return {@code true} if there open target lists; otherwise {@code false}
     */
    private boolean openTargetListCheck() {
        int count = TargetListEditor.dialogCount(origTargetListSet);
        if (count == 0) {
            return false;
        }

        String secondaryResource = count == 1 ? "openTargetListCheck.secondary"
            : "openTargetListCheck.secondary.plural";
        KeplerDialogs.showInformationDialog(this,
            resourceMap.getString("openTargetListCheck"),
            resourceMap.getString(secondaryResource, count));

        return true;
    }

    /**
     * Dismisses this panel's dialog.
     */
    @Override
    protected void dismissDialog() {
        super.dismissDialog();
        dialogCache.remove(origTargetListSet);
    }

    /**
     * Sets the dirty flag if there are changes to the the start, end, or name
     * fields.
     * 
     * @author Bill Wohler
     */
    private class TargetListSetActionListener implements ActionListener {

        private boolean startInitialized;
        private boolean endInitialized;
        private boolean nameInitialized;

        @Override
        public void actionPerformed(ActionEvent e) {
            Object source = e.getSource();
            if (source == start) {
                if (startInitialized) {
                    setDirty(true);
                } else {
                    startInitialized = true;

                    // Wait until QuarterlyRollDateModel has finished to add
                    // listener. Otherwise, we'll get premature events.
                    ((JTextComponent) start.getEditor()
                        .getEditorComponent()).getDocument()
                        .addDocumentListener(dirtyDocumentListener);
                }
            } else if (source == end) {
                if (endInitialized) {
                    setDirty(true);
                } else {
                    endInitialized = true;

                    // Wait until QuarterlyRollDateModel has finished to add
                    // listener. Otherwise, we'll get premature events.
                    ((JTextComponent) end.getEditor()
                        .getEditorComponent()).getDocument()
                        .addDocumentListener(dirtyDocumentListener);
                }
            } else if (source == targetDefinitionTable) {
                setDirty(true);
            }

            if (!nameInitialized && startInitialized && endInitialized) {
                // Similarly, wait until QuarterlyRollDateModel has finished
                // before checking whether we removed leading/trailing
                // whitespace from an existing target list set name.
                // Otherwise, the call to setDirty would be ineffective to allow
                // a quick save since the date fields would still be empty.
                nameInitialized = true;
                if (!getNameText().equals(targetListSet.getName())) {
                    setDirty(true);
                }
            }
        }
    }

    /**
     * Handles changes to the include/exclude checkboxes.
     * 
     * @author Bill Wohler
     */
    private class IncludeExcludeToggle implements TableModelListener {

        private boolean includeExcludeToggle;

        @Override
        public void tableChanged(TableModelEvent e) {
            // If user clicks on include/exclude checkboxes, we need to update
            // the counts. First, ensure that the events are related to the
            // appropriate columns. Then, since the model triggers two events as
            // it simulates a radio button, ignore the first event.
            if (e.getColumn() == targetListModel.columnOf(Column.INCLUDE)
                || e.getColumn() == targetListModel.columnOf(Column.EXCLUDE)) {
                if (includeExcludeToggle) {
                    setDirty(true);
                }
                includeExcludeToggle = !includeExcludeToggle;
            }
        }
    }

    /**
     * A task for updating the unique target count.
     * <p>
     * Requirements:
     * 
     * <pre>
     * SOC_REQ_IMPL 182.CM.1
     * SOC_REQ_IMPL 182.CM.2
     * SOC_REQ_IMPL 182.CM.3
     * </pre>
     * 
     * @author Bill Wohler
     */
    private class UniqueTargetCountTask extends
        DatabaseTask<List<Integer>, Void> {

        private static final String NAME = "UniqueTargetCountTask";

        private List<TargetList> targetLists;
        private List<TargetList> excludedTargetLists;

        public UniqueTargetCountTask(List<TargetList> targetLists,
            List<TargetList> excludedTargetLists) {

            this.targetLists = targetLists;
            this.excludedTargetLists = excludedTargetLists;

            totalIncludedTargetCount.setText(resourceMap.getString(UPDATE
                + ".text"));
            totalExcludedTargetCount.setText("");
            totalTargetCount.setText("");
            totalUniqueTargetCount.setText("");
        }

        @Override
        protected List<Integer> doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            Set<PlannedTarget> uniqueTargets = new HashSet<PlannedTarget>();
            int includedTargetCount = 0;
            int excludedTargetCount = 0;

            for (TargetList targetList : targetLists) {
                for (PlannedTarget plannedTarget : targetSelectionCrud.retrievePlannedTargets(targetList)) {
                    uniqueTargets.add(plannedTarget);
                    includedTargetCount++;
                }
            }

            for (TargetList targetList : excludedTargetLists) {
                for (PlannedTarget plannedTarget : targetSelectionCrud.retrievePlannedTargets(targetList)) {
                    uniqueTargets.remove(plannedTarget);
                    excludedTargetCount++;
                }
            }

            List<Integer> results = new ArrayList<Integer>(3);
            results.add(uniqueTargets.size());
            results.add(includedTargetCount);
            results.add(excludedTargetCount);

            return results;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetEditor.this, e, NAME);
        }

        @Override
        protected void succeeded(List<Integer> results) {
            int uniqueTargetCount = results.get(0);
            int includedTargetCount = results.get(1);
            int excludedTargetCount = results.get(2);

            totalIncludedTargetCount.setText(String.format("%,d",
                includedTargetCount));
            totalExcludedTargetCount.setText(String.format("%,d",
                excludedTargetCount));
            totalTargetCount.setText(String.format("%,d", includedTargetCount
                - excludedTargetCount));
            totalUniqueTargetCount.setText(String.format("%,d",
                uniqueTargetCount));

            String warning = " ";
            Object selectedTdt = targetDefinitionTable.getSelectedItem();
            if (selectedTdt.equals(TargetType.LONG_CADENCE)
                && uniqueTargetCount > TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS) {
                warning = resourceMap.getString("targetCount.lcWarn",
                    TargetManagementConstants.MAX_LONG_CADENCE_TARGET_DEFS);
                totalUniqueTargetCount.setForeground(Color.RED);
            } else if (selectedTdt.equals(TargetType.SHORT_CADENCE)
                && uniqueTargetCount > TargetManagementConstants.MAX_SHORT_CADENCE_TARGET_DEFS) {
                warning = resourceMap.getString("targetCount.scWarn",
                    TargetManagementConstants.MAX_SHORT_CADENCE_TARGET_DEFS);
                totalUniqueTargetCount.setForeground(Color.RED);
            } else {
                totalUniqueTargetCount.setForeground(Color.BLACK);
            }
            targetCountWarningLabel.setText(warning);
            targetCountWarningLabel.setIcon(warning != " " ? warningIcon16
                : null);
        }
    }

    /**
     * A task for saving the target list set.
     * 
     * @author Bill Wohler
     */
    private class SaveTask extends DatabaseTask<TargetListSet, Void> {
        private TargetListSet targetListSet;

        public SaveTask(TargetListSet targetListSet) {
            setUserCanCancel(false);
            this.targetListSet = targetListSet;
        }

        @Override
        protected TargetListSet doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            targetSelectionCrud.create(targetListSet);

            return targetListSet;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListSetEditor.this, e, SAVE, targetListSet);
        }

        @Override
        protected void succeeded(TargetListSet targetListSet) {
            EventBus.publish(new TypeReference<UpdateEvent<TargetListSet>>() {
            }.getType(), new UpdateEvent<TargetListSet>(
                UpdateEvent.Function.ADD_OR_UPDATE, targetListSet));
        }

        @Override
        protected void finished() {
            dismissDialog();
        }
    }
}
