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

import gov.nasa.kepler.cm.TargetListImporter;
import gov.nasa.kepler.cm.TargetListImporter.ProgressHandler;
import gov.nasa.kepler.hibernate.Canonicalizable;
import gov.nasa.kepler.hibernate.Constraint;
import gov.nasa.kepler.hibernate.Constraint.Conjunction;
import gov.nasa.kepler.hibernate.Constraint.Operator;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CharacteristicCrud;
import gov.nasa.kepler.hibernate.cm.CharacteristicType;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.SortDirection;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetList.SourceType;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.common.UpdateEvent;
import gov.nasa.kepler.ui.proxy.CelestialObjectOperationsProxy;
import gov.nasa.kepler.ui.proxy.TargetListImporterProxy;
import gov.nasa.kepler.ui.proxy.TargetSelectionCrudProxy;
import gov.nasa.kepler.ui.proxy.TargetSelectionOperationsProxy;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.KeplerPanel;
import gov.nasa.kepler.ui.swing.PanelHeader;

import java.awt.Component;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.File;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeSet;

import javax.swing.AbstractListModel;
import javax.swing.ButtonGroup;
import javax.swing.ComboBoxModel;
import javax.swing.DefaultComboBoxModel;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JButton;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JRadioButton;
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTextField;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.ListSelectionModel;
import javax.swing.WindowConstants;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;
import javax.swing.text.JTextComponent;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.generics.TypeReference;
import org.jdesktop.application.Action;

/**
 * A target list editor. Use the static factory {@link #edit(List)} to create a
 * new target list, {@link #edit(Object, TargetList)} to view a target list and
 * enable {@link #dialogCount(Object)} so that you can check to see if there are
 * outstanding dialogs. Use {@link #edit(TargetList, List, boolean)} to edit (or
 * view) an existing target list.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TargetListEditor extends KeplerPanel {

    // UI constants.
    private static final String NEW_TARGET_LIST_NAME = "Unsaved Target List";
    private static final int MIN_TEXT_FIELD_COLUMNS = 20;
    private static final int MIN_NUMBER_FIELD_COLUMNS = 10;
    private static final int RADIO_BUTTON_INDENT = 30;

    // Actions.
    public static final String NAME = "targetListEditor";
    private static final String QUERY = "query";
    private static final String ADD_CONSTRAINT = "addConstraint";
    private static final String UPDATE_CONSTRAINT = "updateConstraint";
    private static final String REMOVE_CONSTRAINT = "removeConstraint";
    private static final String RECALCULATE = "recalculate";
    private static final String LIMIT_TARGETS = "limitTargets";
    private static final String ON_FOV = "onFov";
    private static final String FILE = "file";
    private static final String BROWSE = "browse";
    private static final String IMPORT = "importTargetList";
    private static final String CUSTOMIZE = "customize";
    private static final String OK = "ok";
    private static final String CANCEL = "cancel";

    // Suffix to build enabled property from action.
    private static final String ENABLED = "Enabled";

    // Bound properties.
    private boolean addConstraintEnabled = true;
    private boolean updateConstraintEnabled = true;
    private boolean removeConstraintEnabled = true;
    private boolean recalculateEnabled = true;
    private boolean importTargetListEnabled = true;
    private boolean customizeEnabled = true;
    private boolean okEnabled = true;

    // UI components.
    private PanelHeader panelHeader;
    private JTextField name;
    private JComboBox category;
    private JRadioButton queryButton;
    private JComboBox conjunction;
    private CharacteristicModel characteristicModel;
    private JComboBox characteristic;
    private JComboBox operator;
    private JTextField value;
    private ConstraintListModel constraintModel;
    private JList constraints;
    private JButton recalculateTotalButton;
    private JCheckBox limitCheckbox;
    private CharacteristicModel sortModel;
    private JComboBox sort;
    private JComboBox sortDirection;
    private JTextField limit;
    private JCheckBox onFov;
    private JRadioButton fileButton;
    private JTextField file;
    private JLabel targetCountLabel;
    private JButton okButton;

    private static Map<TargetList, JDialog> dialogCache = new HashMap<TargetList, JDialog>();
    private List<JComponent> otherComponents = new ArrayList<JComponent>();
    private List<JComponent> queryComponents = new ArrayList<JComponent>();
    private List<JComponent> limitComponents = new ArrayList<JComponent>();
    private List<JComponent> fileComponents = new ArrayList<JComponent>();
    private Component[] focusTraversalOrder;

    /** Target list we're editing. */
    private TargetList targetList;

    /** All target lists, used to check for duplicate names. */
    private List<TargetList> targetLists;

    /** Whether this editor is read only or not. */
    private boolean readOnly;

    /** Parent object. */
    private Object parent;

    /** List of targets returned from query. */
    private List<PlannedTarget> targets;

    /** Whether the targets have been modified by hand or not. */
    private boolean targetsModified;

    /** Whether targets have been created or not. */
    private boolean targetsCreated;

    /**
     * All defined characteristic types. This is used in the Sort by field, as
     * well as the characteristics fields (along with the columns in the KIC).
     * <p>
     * This field is initialized asynchronously by the
     * {@link CharacteristicTypesLoadTask}.
     */
    private Collection<CharacteristicType> characteristicTypes;

    private ConstraintListSelectionListener constraintListSelectionListener = new ConstraintListSelectionListener();
    private ConstraintActionListener constraintActionListener = new ConstraintActionListener();
    private SourceType currentSourceType;

    /**
     * Creates a TargetListEditor.
     * 
     * @param parent the object which launched this target list. If non-
     * {@code null}, the {@link #dialogCount(Object)} function is enabled
     * @param targetList a non-{@code null} target list
     * @param targetLists a list of target lists which is used to avoid
     * duplicate names. Must be non-{@code null} if {@code readOnly} is
     * {@code false}
     * @param readOnly whether this editor should be read only or not. If
     * {@code parent} is non-{@code null}, this will always be {@code true}
     * @throws NullPointerException if {@code targetList} is {@code null}, or
     * {@code targetLists} is {@code null} and {@code readOnly} is false
     * @throws UiException if the editor could not be created
     */
    private TargetListEditor(Object parent, TargetList targetList,
        List<TargetList> targetLists, boolean readOnly) throws UiException {

        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }
        if (targetLists == null && !readOnly) {
            throw new NullPointerException("targetLists can't be null");
        }

        this.parent = parent;
        this.targetList = targetList;
        this.targetLists = targetLists;
        this.readOnly = readOnly;

        createUi();
        updateTotal();
    }

    @Override
    protected void initComponents() throws UiException {
        panelHeader = new PanelHeader();
        panelHeader.setName("header");

        // Target List Information Panel
        JPanel targetListInfoPanel = new JPanel();

        GroupLayout targetListInfoPanelLayout = new GroupLayout(
            targetListInfoPanel);
        targetListInfoPanel.setLayout(targetListInfoPanelLayout);

        JLabel informationLabel = new JLabel();
        informationLabel.setName("informationLabel");
        informationLabel.setFont(informationLabel.getFont()
            .deriveFont(Font.BOLD));

        JLabel nameLabel = new JLabel();
        nameLabel.setName("nameLabel");
        otherComponents.add(nameLabel);

        name = new JTextField(targetList.getName()
            .trim(), MIN_TEXT_FIELD_COLUMNS);
        nameLabel.setLabelFor(name);
        if (getNameText().equals(NEW_TARGET_LIST_NAME)) {
            name.selectAll();
        }
        otherComponents.add(name);

        JLabel categoryLabel = new JLabel();
        categoryLabel.setName("categoryLabel");
        otherComponents.add(categoryLabel);

        category = new JComboBox();
        categoryLabel.setLabelFor(category);
        otherComponents.add(category);

        // Target List Creation Method Panel
        JPanel targetListCreationPanel = new JPanel();

        GroupLayout targetListCreationPanelLayout = new GroupLayout(
            targetListCreationPanel);
        targetListCreationPanel.setLayout(targetListCreationPanelLayout);

        JLabel creationLabel = new JLabel();
        creationLabel.setName("creationLabel");
        creationLabel.setFont(creationLabel.getFont()
            .deriveFont(Font.BOLD));

        // Query Panel
        JPanel queryPanel = new JPanel();
        GroupLayout queryPanelLayout = new GroupLayout(queryPanel);
        queryPanel.setLayout(queryPanelLayout);
        queryButton = new JRadioButton(actionMap.get(QUERY));
        otherComponents.add(queryButton);

        conjunction = new JComboBox(new DefaultComboBoxModel(
            Conjunction.values()));
        queryComponents.add(conjunction);

        JLabel characteristicLabel = new JLabel();
        characteristicLabel.setName("characteristicLabel");
        queryComponents.add(characteristicLabel);

        characteristicModel = new CharacteristicModel();
        characteristic = new JComboBox(characteristicModel);
        characteristicLabel.setLabelFor(characteristic);
        queryComponents.add(characteristic);

        JLabel operatorLabel = new JLabel();
        operatorLabel.setName("comparisonLabel");
        queryComponents.add(operatorLabel);

        operator = new JComboBox(new DefaultComboBoxModel(Operator.values()));
        operatorLabel.setLabelFor(operator);
        queryComponents.add(operator);

        JLabel valueLabel = new JLabel();
        valueLabel.setName("valueLabel");
        queryComponents.add(valueLabel);

        value = new JTextField(MIN_NUMBER_FIELD_COLUMNS);
        valueLabel.setLabelFor(value);
        queryComponents.add(value);

        JButton addButton = new JButton(actionMap.get(ADD_CONSTRAINT));
        JButton updateButton = new JButton(actionMap.get(UPDATE_CONSTRAINT));
        JButton removeButton = new JButton(actionMap.get(REMOVE_CONSTRAINT));

        constraintModel = new ConstraintListModel();

        constraints = new JList(constraintModel);
        JScrollPane constraintsScrollPane = new JScrollPane(constraints);
        queryComponents.add(constraints);

        recalculateTotalButton = new JButton(actionMap.get(RECALCULATE));

        limitCheckbox = new JCheckBox(actionMap.get(LIMIT_TARGETS));
        queryComponents.add(limitCheckbox);

        JLabel sortLabel = new JLabel();
        sortLabel.setName("sortLabel");
        limitComponents.add(sortLabel);

        sortModel = new CharacteristicModel();
        sort = new JComboBox(sortModel);
        sortLabel.setLabelFor(sort);
        limitComponents.add(sort);

        JLabel sortDirectionLabel = new JLabel();
        sortDirectionLabel.setName("sortDirectionLabel");
        limitComponents.add(sortDirectionLabel);

        sortDirection = new JComboBox(new DefaultComboBoxModel(
            SortDirection.values()));
        sortDirectionLabel.setLabelFor(sortDirection);
        limitComponents.add(sortDirection);

        JLabel limitLabel = new JLabel();
        limitLabel.setName("limitLabel");
        limitComponents.add(limitLabel);

        limit = new JTextField(MIN_NUMBER_FIELD_COLUMNS);
        limitLabel.setLabelFor(limit);
        limitComponents.add(limit);

        onFov = new JCheckBox(actionMap.get(ON_FOV));
        queryComponents.add(onFov);

        // File Panel
        JPanel filePanel = new JPanel();

        GroupLayout filePanelLayout = new GroupLayout(filePanel);
        filePanel.setLayout(filePanelLayout);

        fileButton = new JRadioButton(actionMap.get(FILE));
        otherComponents.add(fileButton);

        JLabel fileLabel = new JLabel();
        fileLabel.setName("fileLabel");
        fileComponents.add(fileLabel);

        file = new JTextField();
        fileLabel.setLabelFor(file);
        fileComponents.add(file);

        JButton browseButton = new JButton(actionMap.get(BROWSE));
        fileComponents.add(browseButton);

        JButton importButton = new JButton(actionMap.get(IMPORT));

        // Target List Customization Panel
        JPanel targetListCustomPanel = new JPanel();

        GroupLayout targetListCustomPanelLayout = new GroupLayout(
            targetListCustomPanel);
        targetListCustomPanel.setLayout(targetListCustomPanelLayout);

        JLabel customLabel = new JLabel();
        customLabel.setName("customLabel");
        customLabel.setFont(customLabel.getFont()
            .deriveFont(Font.BOLD));

        targetCountLabel = new JLabel();

        JButton customButton = new JButton(actionMap.get(CUSTOMIZE));

        // Button area.
        JSeparator separator = new JSeparator();

        okButton = new JButton(actionMap.get(OK));
        JButton cancelButton = new JButton(actionMap.get(CANCEL));

        // Tie things together.
        ButtonGroup creationMethodButtonGroup = new ButtonGroup();
        creationMethodButtonGroup.add(queryButton);
        creationMethodButtonGroup.add(fileButton);

        focusTraversalOrder = new Component[] { name, category, queryButton,
            conjunction, characteristic, operator, value, addButton,
            constraints, updateButton, removeButton, limitCheckbox, sort,
            sortDirection, limit, recalculateTotalButton, onFov, fileButton,
            file, browseButton, importButton, customButton, cancelButton,
            okButton };

        // And lay them out.
        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);

        layout.setAutoCreateContainerGaps(true);
        layout.setAutoCreateGaps(true);
        layout.linkSize(okButton, cancelButton);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(targetListInfoPanel)
            .addComponent(targetListCreationPanel)
            .addComponent(targetListCustomPanel)
            .addComponent(separator)
            .addGroup(
                layout.createSequentialGroup()
                    .addPreferredGap(ComponentPlacement.UNRELATED,
                        GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                    .addComponent(cancelButton)
                    .addComponent(okButton)));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(targetListInfoPanel)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(targetListCreationPanel)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(targetListCustomPanel)
            .addComponent(separator, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                .addComponent(okButton)
                .addComponent(cancelButton)));

        targetListInfoPanelLayout.setAutoCreateGaps(true);

        targetListInfoPanelLayout.setHorizontalGroup(targetListInfoPanelLayout.createSequentialGroup()
            .addGroup(
                targetListInfoPanelLayout.createParallelGroup()
                    .addComponent(informationLabel)
                    .addGroup(
                        targetListInfoPanelLayout.createSequentialGroup()
                            .addPreferredGap(informationLabel, nameLabel,
                                ComponentPlacement.INDENT)
                            .addGroup(
                                targetListInfoPanelLayout.createParallelGroup()
                                    .addComponent(nameLabel)
                                    .addComponent(categoryLabel))
                            .addGroup(
                                targetListInfoPanelLayout.createParallelGroup(
                                    Alignment.LEADING, false)
                                    .addComponent(name)
                                    .addComponent(category)))));

        targetListInfoPanelLayout.setVerticalGroup(targetListInfoPanelLayout.createSequentialGroup()
            .addGroup(
                targetListInfoPanelLayout.createParallelGroup(
                    Alignment.BASELINE)
                    .addComponent(informationLabel))
            .addGroup(
                targetListInfoPanelLayout.createParallelGroup(
                    Alignment.BASELINE)
                    .addComponent(nameLabel)
                    .addComponent(name))
            .addGroup(
                targetListInfoPanelLayout.createParallelGroup(
                    Alignment.BASELINE)
                    .addComponent(categoryLabel)
                    .addComponent(category)));

        targetListCreationPanelLayout.setAutoCreateGaps(true);

        targetListCreationPanelLayout.setHorizontalGroup(targetListCreationPanelLayout.createParallelGroup()
            .addComponent(creationLabel)
            .addComponent(queryPanel)
            .addComponent(filePanel));
        targetListCreationPanelLayout.setVerticalGroup(targetListCreationPanelLayout.createSequentialGroup()
            .addComponent(creationLabel)
            .addComponent(queryPanel)
            .addComponent(filePanel));

        queryPanelLayout.setAutoCreateGaps(true);
        queryPanelLayout.linkSize(addButton, updateButton, removeButton);

        queryPanelLayout.setHorizontalGroup(queryPanelLayout.createParallelGroup()
            .addComponent(queryButton)
            .addGroup(
                queryPanelLayout.createSequentialGroup()
                    .addGap(RADIO_BUTTON_INDENT)
                    .addGroup(
                        queryPanelLayout.createParallelGroup()
                            .addGroup(
                                queryPanelLayout.createSequentialGroup()
                                    .addComponent(conjunction)
                                    .addGroup(
                                        queryPanelLayout.createParallelGroup()
                                            .addComponent(characteristicLabel)
                                            .addComponent(characteristic))
                                    .addGroup(
                                        queryPanelLayout.createParallelGroup()
                                            .addComponent(operatorLabel)
                                            .addComponent(operator))
                                    .addGroup(
                                        queryPanelLayout.createParallelGroup()
                                            .addComponent(valueLabel)
                                            .addComponent(value)))
                            .addComponent(constraintsScrollPane,
                                GroupLayout.DEFAULT_SIZE,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(recalculateTotalButton))
                    .addGroup(queryPanelLayout.createParallelGroup()
                        .addComponent(addButton)
                        .addComponent(updateButton)
                        .addComponent(removeButton))
                    .addPreferredGap(ComponentPlacement.UNRELATED)
                    .addGroup(
                        queryPanelLayout.createParallelGroup()
                            .addComponent(limitCheckbox)
                            .addGroup(
                                queryPanelLayout.createSequentialGroup()
                                    .addGap(RADIO_BUTTON_INDENT)
                                    .addGroup(
                                        queryPanelLayout.createParallelGroup()
                                            .addComponent(sortLabel)
                                            .addComponent(sortDirectionLabel)
                                            .addComponent(limitLabel))
                                    .addGroup(
                                        queryPanelLayout.createParallelGroup(
                                            Alignment.LEADING, false)
                                            .addComponent(sort)
                                            .addComponent(sortDirection)
                                            .addComponent(limit)))
                            .addComponent(onFov))));

        queryPanelLayout.setVerticalGroup(queryPanelLayout.createSequentialGroup()
            .addComponent(queryButton)
            .addGroup(queryPanelLayout.createParallelGroup(Alignment.BASELINE)
                .addComponent(characteristicLabel)
                .addComponent(operatorLabel)
                .addComponent(valueLabel))
            .addGroup(
                queryPanelLayout.createParallelGroup()
                    .addGroup(
                        queryPanelLayout.createSequentialGroup()
                            .addGroup(
                                queryPanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(conjunction)
                                    .addComponent(characteristic)
                                    .addComponent(operator)
                                    .addComponent(value))
                            .addComponent(constraintsScrollPane,
                                GroupLayout.DEFAULT_SIZE,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(recalculateTotalButton))
                    .addGroup(queryPanelLayout.createSequentialGroup()
                        .addComponent(addButton)
                        .addComponent(updateButton)
                        .addComponent(removeButton))
                    .addGroup(
                        queryPanelLayout.createSequentialGroup()
                            .addComponent(limitCheckbox)
                            .addGroup(
                                queryPanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(sortLabel)
                                    .addComponent(sort))
                            .addGroup(
                                queryPanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(sortDirectionLabel)
                                    .addComponent(sortDirection))
                            .addGroup(
                                queryPanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(limitLabel)
                                    .addComponent(limit))
                            .addComponent(onFov))));

        filePanelLayout.setAutoCreateGaps(true);

        filePanelLayout.setHorizontalGroup(filePanelLayout.createParallelGroup()
            .addComponent(fileButton)
            .addGroup(
                filePanelLayout.createSequentialGroup()
                    .addGap(RADIO_BUTTON_INDENT)
                    .addGroup(
                        filePanelLayout.createParallelGroup()
                            .addGroup(
                                filePanelLayout.createSequentialGroup()
                                    .addComponent(fileLabel)
                                    .addComponent(file,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.PREFERRED_SIZE,
                                        Short.MAX_VALUE)
                                    .addComponent(browseButton))
                            .addComponent(importButton))));

        filePanelLayout.setVerticalGroup(filePanelLayout.createSequentialGroup()
            .addComponent(fileButton)
            .addGroup(filePanelLayout.createParallelGroup(Alignment.BASELINE)
                .addComponent(browseButton)
                .addComponent(file)
                .addComponent(fileLabel))
            .addComponent(importButton));

        targetListCustomPanelLayout.setAutoCreateGaps(true);

        targetListCustomPanelLayout.setHorizontalGroup(targetListCustomPanelLayout.createParallelGroup()
            .addComponent(customLabel)
            .addGroup(
                targetListCustomPanelLayout.createSequentialGroup()
                    .addPreferredGap(customLabel, targetCountLabel,
                        ComponentPlacement.INDENT)
                    .addGroup(targetListCustomPanelLayout.createParallelGroup()
                        .addComponent(targetCountLabel)
                        .addComponent(customButton))));

        targetListCustomPanelLayout.setVerticalGroup(targetListCustomPanelLayout.createSequentialGroup()
            .addComponent(customLabel)
            .addComponent(targetCountLabel)
            .addComponent(customButton));

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
    protected void configureComponents() throws UiException {

        // If the category is null, then we do want an empty text box.
        category.setModel(new DefaultComboBoxModel(getCategories().toArray()));
        category.setEditable(true);
        category.setSelectedItem(targetList.getCategory());
        constraints.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);

        switch (targetList.getSourceType()) {
            case FILE:
                fileButton.setSelected(true);
                file.setText(targetList.getSource());
                file();

                // Reset query default
                onFov.setSelected(true);
                onFov();
                setDirty(false); // undo dirty effect of onFov
                break;

            case QUERY:
            default:
                try {
                    constraintModel.setConstraints(targetList.getSource());
                } catch (ParseException e) {
                    String message = resourceMap.getString(
                        "configureComponents", targetList.getSource());
                    log.error(message);
                    throw new UiException(message, e);
                }

                queryButton.setSelected(true);
                query();
                break;
        }

        limit.setText(Integer.toString(CelestialObjectOperationsProxy.getMaxKicResultSetCount()));

        // Because the group layout doesn't lay out the components in the
        // desired tab order, do that here. This depends on the dialog
        // calling
        // setFocusTraversalPolicy(editor.getFocusTraversalPolicy()).
        setFocusTraversalComponents(Arrays.asList(focusTraversalOrder));

        if (readOnly) {
            enableComponents(otherComponents, false);
            enableComponents(queryComponents, false);
            enableComponents(fileComponents, false);
            enableComponents(limitComponents, false);
        }

        // If we removed leading/trailing whitespace from an existing target
        // list name; allow a quick save.
        if (!getNameText().equals(targetList.getName())) {
            setDirty(true);
        }
    }

    /**
     * Retrieves the target categories that are in use.
     * 
     * @return a set of categories, as strings
     * @throws UiException if the categories could not be obtained
     */
    private Set<String> getCategories() throws UiException {
        Set<String> categories = new TreeSet<String>();

        DataRequestEvent<List<TargetList>> request = new DataRequestEvent<List<TargetList>>();
        EventBus.publish(
            new TypeReference<DataRequestEvent<List<TargetList>>>() {
            }.getType(), request);
        if (request.getData() == null) {
            return categories;
        }
        for (TargetList targetList : request.getData()) {
            categories.add(targetList.getCategory());
        }

        return categories;
    }

    @Override
    protected void addListeners() {
        name.getDocument()
            .addDocumentListener(dirtyDocumentListener);
        ((JTextComponent) category.getEditor()
            .getEditorComponent()).getDocument()
            .addDocumentListener(dirtyDocumentListener);
        conjunction.addActionListener(constraintActionListener);
        operator.addActionListener(constraintActionListener);
        value.getDocument()
            .addDocumentListener(updateDocumentListener);
        constraints.addListSelectionListener(constraintListSelectionListener);
        limit.getDocument()
            .addDocumentListener(updateDocumentListener);
        file.getDocument()
            .addDocumentListener(dirtyDocumentListener);
    }

    @Override
    protected void getData(boolean block) {
        executeDatabaseTask(CharacteristicTypesLoadTask.NAME,
            new CharacteristicTypesLoadTask());

        if (targetList.getName() == NEW_TARGET_LIST_NAME) {
            targets = new ArrayList<PlannedTarget>();
        } else {
            executeDatabaseTask(PlannedTargetsLoadTask.NAME,
                new PlannedTargetsLoadTask());
        }
    }

    /**
     * Create a new target list while editing a target list set.
     * 
     * @param targetLists a list of target lists which is used to avoid
     * duplicate names. Must be non-{@code null}
     * @throws NullPointerException if {@code targetLists} is {@code null}
     * @throws UiException if the editor could not be created
     */
    public static void edit(List<TargetList> targetLists) throws UiException {
        edit(null, new TargetList(NEW_TARGET_LIST_NAME), targetLists, false);
    }

    /**
     * Edit the given target list.
     * 
     * @param targetList a target list
     * @param targetLists a list of target lists which is used to avoid
     * duplicate names. Must be non-{@code null} if {@code readOnly} is
     * {@code false}
     * @param readOnly whether this editor should be read only or not
     * @throws NullPointerException if {@code targetList} is {@code null}, or
     * {@code targetLists} is {@code null} and {@code readOnly} is false
     * @throws UiException if the editor could not be created
     */
    public static void edit(TargetList targetList,
        List<TargetList> targetLists, boolean readOnly) throws UiException {
        edit(null, targetList, targetLists, readOnly);
    }

    /**
     * Views the given target list.
     * 
     * @param parent the object which launched this target list.
     * @param targetList a target list
     * @throws NullPointerException if either {@code targetList} or
     * {@code parent} are {@code null}
     * @throws UiException if the the editor could not be created
     */
    public static void edit(Object parent, TargetList targetList)
        throws UiException {
        edit(parent, targetList, null, true);
    }

    /**
     * Edit the given target list.
     * 
     * @param parent the object which launched this target list. If non-
     * {@code null}, the {@link #dialogCount(Object)} function is enabled
     * @param targetList a target list
     * @param targetLists a list of target lists which is used to avoid
     * duplicate names. Must be non-{@code null} if {@code readOnly} is
     * {@code false}
     * @param readOnly whether this editor should be read only or not. If
     * {@code parent} is non-{@code null}, this will always be {@code true}
     * @throws NullPointerException if {@code targetList} is {@code null}, or
     * {@code targetLists} is {@code null} and {@code readOnly} is false
     * @throws UiException if the editor could not be created
     */
    private static void edit(Object parent, TargetList targetList,
        List<TargetList> targetLists, boolean readOnly) throws UiException {

        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }
        if (targetLists == null && !readOnly) {
            throw new NullPointerException("targetLists can't be null");
        }

        JDialog dialog = dialogCache.get(targetList);
        if (dialog == null) {
            dialog = new JDialog();
            dialog.setName(NAME);

            final TargetListEditor editor = new TargetListEditor(parent,
                targetList, targetLists, readOnly);
            dialog.setContentPane(editor);
            editor.setTitle(false, targetList);
            dialogCache.put(targetList, dialog);
            dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
            dialog.addWindowListener(new WindowAdapter() {
                @Override
                public void windowClosing(WindowEvent e) {
                    editor.dismissDialog();
                }
            });
            editor.initDefaultKeys();
            dialog.setFocusTraversalPolicy(editor.getFocusTraversalPolicy());
            app.show(dialog);
        } else {
            dialog.setVisible(true);
            dialog.toFront();
        }
    }

    /**
     * Returns the number of visible target list editor dialogs associated with
     * the given target list set.
     * 
     * @param parent the target list set
     * @return the number of target list editor dialogs associated with the
     * given target list set
     */
    public static int dialogCount(Object parent) {
        int count = 0;

        for (JDialog dialog : dialogCache.values()) {
            TargetListEditor editor = (TargetListEditor) dialog.getContentPane();
            if (editor.parent == parent && dialog.isVisible()) {
                count++;
            }
        }

        return count;
    }

    /**
     * Updates the actions' enabled state. Tries to enable the actions subject
     * to the setters' logic. Call this after updating a selection, or running a
     * command which might change the state of the dialog.
     */
    @Override
    protected void updateEnabled() {
        setHelpText(null);
        setAddConstraintEnabled(true);
        setUpdateConstraintEnabled(true);
        setRemoveConstraintEnabled(true);
        setRecalculateEnabled(true);
        setImportTargetListEnabled(true);
        setCustomizeEnabled(true);
        setOkEnabled(true);

        setTitle(isDirty(), getNameText());
        if (!loadingTargets() && !loadingCharacteristicTypes()
            && !isUiInitializing()) {
            panelHeader.displayHelp(getHelpType(), getHelpText());
        }
    }

    /**
     * Returns the OK button for this panel.
     */
    @Override
    protected JButton getDefaultButton() {
        return okButton;
    }

    /**
     * Use a query to define the target lists.
     */
    @Action
    public void query() {
        if (currentSourceType == SourceType.QUERY) {
            return;
        }
        currentSourceType = SourceType.QUERY;

        log.info(resourceMap.getString(QUERY));

        resetTargets();
        enableComponents(queryComponents, true && !readOnly);
        enableComponents(fileComponents, false);
        updateEnabled();

        limitTargets();

        // If this is a new target list, initialize onFov to "on." Otherwise,
        // sniff query for setting.
        if (targetList.getName() == NEW_TARGET_LIST_NAME) {
            onFov.setSelected(true);
            onFov(); // add constraint for this setting
        } else {
            onFov.setSelected(isOnFov());
            ensureConjunctionUseful();
        }
        constraints.clearSelection();

        characteristic.requestFocusInWindow();
    }

    /**
     * Returns {@code true} if we're still loading characteristic types. Many
     * operations should be disabled while this returns {@code true}.
     * 
     * @return {@code true} if we're loading characteristic types; otherwise,
     * {@code false}
     */
    private boolean loadingCharacteristicTypes() {
        return characteristicTypes == null;
    }

    /**
     * Returns {@code true} if we're still loading targets. Many operations
     * should be disabled while this returns {@code true}.
     * 
     * @return {@code true} if we're loading targets; otherwise, {@code false}
     */
    private boolean loadingTargets() {
        return targets == null;
    }

    /**
     * Optionally clear keplerIds field. If we've performed a query or imported
     * targets, then clear them and disable the OK button when switching to
     * another creation method. That prevents the source type from being set to
     * one thing and the list of targets being set to another.
     */
    private void resetTargets() {
        if (!loadingTargets()) {
            targets.clear();
            updateTotal();
        }
    }

    /**
     * Updates the "X Targets" label in the customization panel with the current
     * target count.
     */
    private void updateTotal() {
        String s;
        if (loadingTargets()) {
            s = resourceMap.getString("loading");
        } else {
            int targetCount = targets.size();
            String targetWord = resourceMap.getString("target."
                + (targetCount == 1 ? "singular" : "plural"));
            s = resourceMap.getString("targetCount", targetCount, targetWord);
        }
        targetCountLabel.setText(s);
    }

    /**
     * Add the current constraint to the constraints window.
     */
    @Action(enabledProperty = ADD_CONSTRAINT + ENABLED)
    public void addConstraint() {
        // Ensure conjunction for first item is NONE; use AND elsewhere if a
        // conjunction has not been chosen.
        Conjunction conjunction = (Conjunction) this.conjunction.getSelectedItem();
        if (constraintModel.getSize() == 0) {
            conjunction = Conjunction.NONE;
        } else if (conjunction == Conjunction.NONE) {
            conjunction = Conjunction.AND;
        }
        Constraint constraint = new Constraint(conjunction,
            (Canonicalizable) characteristic.getSelectedItem(),
            (Operator) operator.getSelectedItem(), value.getText());
        log.info(resourceMap.getString(ADD_CONSTRAINT, constraint));
        constraintModel.add(constraint);
        constraints.setSelectedIndex(constraintModel.getSize() - 1);
        constraints.ensureIndexIsVisible(constraintModel.getSize() - 1);
        onFov.setSelected(isOnFov());
        setDirty(true);
        ensureConjunctionUseful();
        characteristic.requestFocusInWindow();
    }

    public boolean isAddConstraintEnabled() {
        return addConstraintEnabled;
    }

    public void setAddConstraintEnabled(boolean addConstraintEnabled) {
        boolean oldValue = this.addConstraintEnabled;
        boolean nullValueBadOperator = value.getText()
            .equals("null") && operator.getSelectedItem() != Operator.EQUAL
            && operator.getSelectedItem() != Operator.NOT_EQUAL;
        this.addConstraintEnabled = addConstraintEnabled
            && !readOnly
            && !loadingCharacteristicTypes()
            && getSourceType() == SourceType.QUERY
            && value.getText()
                .length() > 0
            && conditionalHelp(!nullValueBadOperator, HelpType.WARNING,
                "nullValue.help");
        firePropertyChange(ADD_CONSTRAINT + ENABLED, oldValue,
            this.addConstraintEnabled);
    }

    /**
     * Updates the selected constraint.
     */
    @Action(enabledProperty = UPDATE_CONSTRAINT + ENABLED)
    public void updateConstraint() {
        // Ensure conjunction for first item is NONE; use AND elsewhere if a
        // conjunction has not been chosen.
        Conjunction conjunction = (Conjunction) this.conjunction.getSelectedItem();
        if (constraints.getSelectedIndex() == 0) {
            conjunction = Conjunction.NONE;
        } else if (conjunction == Conjunction.NONE) {
            conjunction = Conjunction.AND;
        }
        Constraint constraint = new Constraint(conjunction,
            (Canonicalizable) characteristic.getSelectedItem(),
            (Operator) operator.getSelectedItem(), value.getText());
        log.info(resourceMap.getString(UPDATE_CONSTRAINT,
            constraints.getSelectedValue(), constraint));
        replace(constraints.getSelectedIndex(), constraint);
        onFov.setSelected(isOnFov());
        setDirty(true);
        recalculateTotalButton.requestFocusInWindow();
    }

    public boolean isUpdateConstraintEnabled() {
        return updateConstraintEnabled;
    }

    public void setUpdateConstraintEnabled(boolean updateConstraintEnabled) {
        boolean oldValue = this.updateConstraintEnabled;
        boolean nullValueBadOperator = value.getText()
            .equals("null") && operator.getSelectedItem() != Operator.EQUAL
            && operator.getSelectedItem() != Operator.NOT_EQUAL;
        this.updateConstraintEnabled = updateConstraintEnabled
            && !readOnly
            && !loadingCharacteristicTypes()
            && getSourceType() == SourceType.QUERY
            && value.getText()
                .length() > 0
            && conditionalHelp(!nullValueBadOperator, HelpType.WARNING,
                "nullValue.help") && !constraints.isSelectionEmpty();
        firePropertyChange(UPDATE_CONSTRAINT + ENABLED, oldValue,
            this.updateConstraintEnabled);
    }

    /**
     * Removes the selected constraint.
     */
    @Action(enabledProperty = REMOVE_CONSTRAINT + ENABLED)
    public void removeConstraint() {
        log.info(resourceMap.getString(REMOVE_CONSTRAINT,
            constraints.getSelectedValue()));
        int index = constraints.getSelectedIndex();
        constraintModel.remove(index);
        ensureFirstConjunctionNone();
        onFov.setSelected(isOnFov());
        setDirty(true);
        ensureConjunctionUseful();
        recalculateTotalButton.requestFocusInWindow();
    }

    public boolean isRemoveConstraintEnabled() {
        return removeConstraintEnabled;
    }

    public void setRemoveConstraintEnabled(boolean removeConstraintEnabled) {
        boolean oldValue = this.removeConstraintEnabled;
        this.removeConstraintEnabled = removeConstraintEnabled && !readOnly
            && !loadingCharacteristicTypes()
            && getSourceType() == SourceType.QUERY
            && constraints.getSelectedIndex() >= 0;
        firePropertyChange(REMOVE_CONSTRAINT + ENABLED, oldValue,
            this.removeConstraintEnabled);
    }

    /**
     * This is called to ensure that the conjunction is NONE if there aren't any
     * constraints, and anything but NONE if there is at least one constraint.
     * This should be called when adding or removing constraints.
     */
    private void ensureConjunctionUseful() {
        if (constraintModel.getSize() == 0) {
            conjunction.setSelectedItem(Conjunction.NONE);
        } else {
            if (conjunction.getSelectedItem() == Conjunction.NONE) {
                conjunction.setSelectedItem(Conjunction.AND);
            }
        }
    }

    /**
     * Ensure that the conjunction of the first element is NONE and update it if
     * necessary. This should be called after removing constraints.
     */
    private void ensureFirstConjunctionNone() {
        if (constraintModel.getSize() < 1) {
            return;
        }

        Constraint constraint = (Constraint) constraintModel.getElementAt(0);
        if (constraint.getConjunction() == Conjunction.NONE) {
            return;
        }

        constraint = new Constraint(Conjunction.NONE,
            constraint.getColumnName(), constraint.getOperator(),
            constraint.getValue());
        replace(0, constraint);
    }

    /**
     * Replace item in constraint list at the given index with the given object.
     * 
     * @param index the index of the item to replace
     * @param constraint the constraint object that should replace existing item
     */
    private void replace(int index, Constraint constraint) {
        constraintModel.remove(index);
        constraintModel.add(index, constraint);
        constraints.setSelectedIndex(index);
        constraints.ensureIndexIsVisible(index);
    }

    /**
     * Run the query and display the new total number of targets.
     * <p>
     * Requirements: SOC_REQ_IMPL SOC174
     */
    @Action(enabledProperty = RECALCULATE + ENABLED)
    public void recalculate() {
        if (targetsModified && warnUser(RECALCULATE)) {
            return;
        }

        try {
            QueryTask task = null;
            if (limitCheckbox.isSelected()) {
                task = new QueryTask(constraintModel,
                    (Canonicalizable) sortModel.getSelectedItem(),
                    (SortDirection) sortDirection.getSelectedItem(),
                    Integer.parseInt(limit.getText()));
            } else {
                task = new QueryTask(constraintModel);
            }
            executeDatabaseTask(RECALCULATE, task);
        } catch (NumberFormatException e) {
            handleError(this, e, RECALCULATE, limit.getText());
        }
    }

    public boolean isRecalculateEnabled() {
        return recalculateEnabled;
    }

    public void setRecalculateEnabled(boolean recalculateEnabled) {
        boolean oldValue = this.recalculateEnabled;
        this.recalculateEnabled = recalculateEnabled && !loadingTargets()
            && !readOnly && !loadingCharacteristicTypes()
            && getSourceType() == SourceType.QUERY
            && conditionalHelp(constraintModel.getSize() > 0, "querySize.help")
            && (!limitCheckbox.isSelected() || conditionalHelp(limit.getText()
                .length() > 0, "limitText.help"));
        firePropertyChange(RECALCULATE + ENABLED, oldValue,
            this.recalculateEnabled);
    }

    /**
     * Enables/Disables the fields used to limit the size of the result set.
     */
    @Action
    public void limitTargets() {
        boolean selected = limitCheckbox.isSelected();
        log.info(resourceMap.getString(LIMIT_TARGETS, selected ? "on" : "off"));
        enableComponents(limitComponents, selected && !readOnly);
        updateEnabled();
        if (selected) {
            sort.requestFocusInWindow();
        }
    }

    /**
     * Limit query to field of view (FOV). This implies that the query includes
     * SKY_GROUP_ID != 0 or its equivalent.
     */
    @Action
    public void onFov() {
        boolean onFovSelected = onFov.isSelected();
        log.info(resourceMap.getString(ON_FOV, onFovSelected ? "on" : "off"));

        // Remove any existing SKY_GROUP_ID entries.
        for (int i = constraintModel.getSize() - 1; i >= 0; i--) {
            Constraint constraint = (Constraint) constraintModel.getElementAt(i);
            if (constraint.getColumnName() == Kic.Field.SKY_GROUP_ID) {
                constraintModel.remove(i);
            }
        }

        // Add SKY_GROUP_ID != 0 if selected.
        if (onFovSelected) {
            Constraint constraint = new Constraint(Conjunction.AND,
                Kic.Field.SKY_GROUP_ID, Operator.NOT_EQUAL, "0");
            constraintModel.add(constraint);
        }

        ensureFirstConjunctionNone();
        ensureConjunctionUseful();
        if (!isUiInitializing()) {
            setDirty(true);
        }
        recalculateTotalButton.requestFocusInWindow();
    }

    /**
     * Determines whether this query is limited to the field of view (FOV). This
     * is the case if there is a constraint Kic.Field.SKY_GROUP_ID != 0,
     * Kic.Field.SKY_GROUP_ID > [0 or above], Kic.Field.SKY_GROUP_ID >= [1 or
     * above], or Kic.Field.SKY_GROUP_ID = [1 or above] and there are not any OR
     * conjunctions.
     * 
     * @return {@code true} if the query is limited to the field of view (FOV);
     * otherwise, {@code false}
     */
    private boolean isOnFov() {
        boolean foundOr = false;
        boolean foundOnFov = false;

        for (Constraint constraint : constraintModel.getAllElements()) {
            if (constraint.getConjunction() == Conjunction.OR) {
                foundOr = true;
            }
            if (constraint.getColumnName() == Kic.Field.SKY_GROUP_ID) {
                Operator op = constraint.getOperator();
                int value = Integer.parseInt(constraint.getValue());
                if (op == Operator.NOT_EQUAL && value == 0
                    || op == Operator.GREATER_THAN && value >= 0
                    || op == Operator.GREATER_THAN_OR_EQUAL && value > 0
                    || op == Operator.EQUAL && value > 0) {
                    foundOnFov = true;
                }
            }
        }

        return foundOnFov && !foundOr;
    }

    /**
     * Determines whether this target list has any targets that are off the
     * field of view. This is the case if the {@code skyGroupId} for any target
     * is equal to 0.
     * 
     * @return {@code true} if the query is limited to the field of view (FOV)
     * or there aren't any targets; otherwise, {@code false}
     */
    private boolean allTargetsOnFov() {
        for (PlannedTarget target : targets) {
            if (target.getSkyGroupId() == 0) {
                return false;
            }
        }
        return true;
    }

    /**
     * Use a file of targets to define target list.
     */
    @Action
    public void file() {
        if (currentSourceType == SourceType.FILE) {
            return;
        }
        currentSourceType = SourceType.FILE;

        log.info(resourceMap.getString(FILE));

        resetTargets();
        enableComponents(queryComponents, false);
        enableComponents(limitComponents, false);
        enableComponents(fileComponents, true && !readOnly);
        updateEnabled();
        file.requestFocusInWindow();
    }

    /**
     * Display file browser.
     */
    @Action
    public void browse() {
        log.info(resourceMap.getString(BROWSE));

        File importFile = KeplerDialogs.showFileChooserDialog(this,
            file.getText());
        if (importFile != null) {
            file.setText(importFile.getAbsolutePath());
        }
    }

    /**
     * Load targets from file.
     */
    @Action(enabledProperty = IMPORT + ENABLED)
    public void importTargetList() {
        if (targetsModified && warnUser(IMPORT)) {
            return;
        }

        executeDatabaseTask(IMPORT, new ImportTask(file.getText()));
    }

    public boolean isImportTargetListEnabled() {
        return importTargetListEnabled;
    }

    public void setImportTargetListEnabled(boolean importTargetListEnabled) {
        boolean oldValue = this.importTargetListEnabled;
        this.importTargetListEnabled = importTargetListEnabled
            && !loadingTargets() && !readOnly
            && getSourceType() == SourceType.FILE
            && conditionalHelp(file.getText()
                .length() > 0, "file.help");
        firePropertyChange(IMPORT + ENABLED, oldValue,
            this.importTargetListEnabled);
    }

    /**
     * Customize targets.
     */
    @Action(enabledProperty = CUSTOMIZE + ENABLED)
    public void customize() {
        log.info(resourceMap.getString(CUSTOMIZE));
        try {
            targetsModified = TargetEditor.edit(targetList, targets, readOnly);
        } catch (UiException e) {
            handleError(this, e, CUSTOMIZE);
        }
        updateTotal();
        setDirty(isDirty() || targetsModified);
    }

    public boolean isCustomizeEnabled() {
        return customizeEnabled;
    }

    public void setCustomizeEnabled(boolean customizeEnabled) {
        boolean oldValue = this.customizeEnabled;
        this.customizeEnabled = customizeEnabled && !loadingTargets();
        firePropertyChange(CUSTOMIZE + ENABLED, oldValue, this.customizeEnabled);
    }

    /**
     * Save work and dismiss dialog.
     */
    @Action(enabledProperty = OK + ENABLED)
    public void ok() {
        // Avoid showing user both warnings.
        if (getSourceType() == SourceType.QUERY && !isOnFov()) {
            if (warnUser(OK, resourceMap.getString(OK + ".warn.query"))) {
                return;
            }
        } else if (!allTargetsOnFov()
            && warnUser(OK, resourceMap.getString(OK + ".warn.targets"))) {
            return;
        }

        log.info(resourceMap.getString(OK, getNameText()));

        targetList.setName(getNameText());
        targetList.setCategory((String) category.getSelectedItem());
        targetList.setSourceType(getSourceType());
        targetList.setSource(getSource());

        // Attempt to save this target list.
        executeDatabaseTask(OK, new SaveTask(targetList));
    }

    public boolean isOkEnabled() {
        return okEnabled;
    }

    public void setOkEnabled(boolean okEnabled) {
        boolean oldValue = this.okEnabled;
        String s = getNameText();
        this.okEnabled = okEnabled
            && !readOnly
            && isDirty()
            && conditionalHelp(s.length() > 0, "targetListName.help")
            && conditionalHelp(!s.equals(NEW_TARGET_LIST_NAME),
                "targetListName.help")
            && conditionalHelp(((JTextField) category.getEditor()
                .getEditorComponent()).getText()
                .length() > 0, "category.help")
            && conditionalHelp(!duplicate(s), "duplicate.help");
        firePropertyChange(OK + ENABLED, oldValue, this.okEnabled);
    }

    /**
     * Gets the selected source type.
     * 
     * @return one of the values from the {@link SourceType} enum
     * @throws IllegalStateException if none of the query source buttons are
     * selected
     */
    private SourceType getSourceType() {
        if (queryButton.isSelected()) {
            return SourceType.QUERY;
        } else if (fileButton.isSelected()) {
            return SourceType.FILE;
        }

        throw new IllegalStateException(
            "None of the query source buttons are selected");
    }

    /**
     * Gets the selected source.
     * 
     * @return either a query string or a file name
     * @throws IllegalStateException if none of the query source buttons are
     * selected
     */
    private String getSource() {
        switch (getSourceType()) {
            case QUERY:
                return Constraint.listToString(constraintModel.getAllElements());
            case FILE:
                return file.getText();
        }

        throw new IllegalStateException(
            "None of the query source buttons are selected");
    }

    /**
     * Returns {@code true} if the given name is already in use.
     * 
     * @param name the name to check
     * @return {@code true} if the given name is already in use; otherwise
     * {@code false}
     */
    private boolean duplicate(String name) {
        for (TargetList targetList : targetLists) {
            if (targetList.getName()
                .equals(name) && targetList != this.targetList) {
                return true;
            }
        }
        return false;
    }

    /**
     * Discard work and dismiss dialog.
     */
    @Action
    public void cancel() {
        log.info(resourceMap.getString(CANCEL, targetList));
        executeDatabaseTask(CANCEL, new CancelTask());
    }

    /**
     * Dismisses this panel's dialog.
     */
    @Override
    protected void dismissDialog() {
        super.dismissDialog();
        dialogCache.remove(targetList);
    }

    /**
     * Updates current constraint from selection.
     * 
     * @author Bill Wohler
     */
    private class ConstraintListSelectionListener implements
        ListSelectionListener {

        @Override
        public void valueChanged(ListSelectionEvent e) {
            if (e.getValueIsAdjusting()) {
                return;
            }

            log.debug(e.getSource());

            Constraint constraint = (Constraint) constraints.getSelectedValue();
            log.info(resourceMap.getString("valueChanged", constraint));
            updateEnabled();

            if (constraint == null) {
                // Selected item removed.
                return;
            }

            conjunction.setSelectedItem(constraint.getConjunction());
            characteristic.setSelectedItem(constraint.getColumnName());
            operator.setSelectedItem(constraint.getOperator());
            value.setText(constraint.getValue());
        }
    }

    /**
     * Ensure Add and Update buttons are only enabled when the conjunction and
     * operator fields are set properly for the context.
     * 
     * @author Bill Wohler
     */
    private class ConstraintActionListener implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            updateEnabled();
        }
    }

    /**
     * A combobox model for characteristics. This model adds the characteristic
     * types loaded from the database, and appends the names of the columns in
     * the KIC to them.
     * 
     * @author Bill Wohler
     */
    private class CharacteristicModel extends AbstractListModel implements
        ComboBoxModel {

        private List<Object> characteristics;
        private Object selectedItem;

        /**
         * Creates a CharacteristicModel. The model initially contains a
         * "Loading..." item.
         * <p>
         * N.B. This class is not thread-safe; be sure to call its methods just
         * on the EDT.
         */
        public CharacteristicModel() {
            setCharacteristicTypes(null);
        }

        /**
         * Updates the characteristic types in this model. The KIC columns
         * (Kic.Columns) are appended. The selection is cleared.
         * 
         * @param characteristicTypes the new characteristic types
         */
        public void setCharacteristicTypes(
            Collection<CharacteristicType> characteristicTypes) {
            characteristics = new ArrayList<Object>();
            if (loadingCharacteristicTypes()) {
                // Temporary value in case types are being loaded in
                // background.
                characteristics.add(resourceMap.getString("loading"));
            } else {
                characteristics.clear();
                characteristics.addAll(characteristicTypes);
                characteristics.addAll(Arrays.asList(Kic.Field.values()));
            }
            fireContentsChanged(this, 0, characteristics.size() - 1);
            setSelectedItem(characteristics.get(0));
        }

        @Override
        public Object getElementAt(int index) {
            return characteristics.get(index);
        }

        @Override
        public int getSize() {
            return characteristics.size();
        }

        @Override
        public Object getSelectedItem() {
            return selectedItem;
        }

        @Override
        public void setSelectedItem(Object item) {
            if (selectedItem != null && !selectedItem.equals(item)
                || selectedItem == null && item != null) {
                selectedItem = item;
                fireContentsChanged(this, -1, -1);
            }
        }
    }

    /**
     * A list model for constraints.
     * 
     * @author Bill Wohler
     */
    private class ConstraintListModel extends AbstractListModel implements
        Constraint.CanonicalizableConverter {

        private List<Constraint> constraints = new ArrayList<Constraint>();

        public ConstraintListModel() {
        }

        public void setConstraints(String expression) throws ParseException {
            constraints = Constraint.parseExpression(expression, this);
            fireContentsChanged(this, 0, constraints.size() - 1);
        }

        @Override
        public Object getElementAt(int index) {
            return constraints.get(index);
        }

        @Override
        public int getSize() {
            return constraints.size();
        }

        public boolean add(Constraint constraint) {
            boolean status = constraints.add(constraint);
            int index = constraints.size() - 1;
            fireIntervalAdded(this, index, index);
            return status;
        }

        public void add(int index, Constraint constraint) {
            constraints.add(index, constraint);
            fireIntervalAdded(this, index, index);
        }

        public Constraint remove(int index) {
            Constraint constraint = constraints.remove(index);
            fireIntervalRemoved(this, index, index);
            return constraint;
        }

        public List<Constraint> getAllElements() {
            return Collections.unmodifiableList(constraints);
        }

        @Override
        public Canonicalizable toCanonicalizable(final String s) {
            // See if this string looks like a Kic.Column.
            for (Kic.Field field : Kic.Field.values()) {
                if (field.toString()
                    .equals(s)) {
                    return field;
                }
            }

            // No? It's a Characteristic.
            if (!loadingCharacteristicTypes()) {
                for (CharacteristicType type : characteristicTypes) {
                    if (type.toString()
                        .equals(s)) {
                        return type;
                    }
                }
                throw new IllegalArgumentException(s
                    + " not a KIC column, or characteristic type");
            }

            // Still loading characteristics. Display Loading... instead.
            return new Canonicalizable() {
                @Override
                public String canonicalize(String alias) {
                    return toString();
                }

                @Override
                public Class<?> getObjectClass() {
                    return String.class;
                }

                @Override
                public String toString() {
                    return resourceMap.getString("loading");
                }
            };
        }
    }

    /**
     * A task for loading the planned targets from the database in the
     * background.
     * 
     * @author Bill Wohler
     */
    private class PlannedTargetsLoadTask extends
        DatabaseTask<List<PlannedTarget>, Object> {

        private static final String NAME = "PlannedTargetsLoadTask";

        public PlannedTargetsLoadTask() {
            setUserCanCancel(false);
        }

        @Override
        protected List<PlannedTarget> doInBackground() throws Exception {
            long start = System.currentTimeMillis();
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();
            List<PlannedTarget> targets = targetSelectionCrud.retrievePlannedTargets(targetList);
            log.debug("Loaded " + targets.size() + " targets in "
                + (System.currentTimeMillis() - start) + " ms");

            return targets;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListEditor.this, e, NAME);
            dismissDialog();
        }

        @Override
        protected void succeeded(List<PlannedTarget> result) {
            targets = result;
            updateTotal();

            boolean oldInitializingValue = isUiInitializing();
            setUiInitializing(true);
            updateEnabled();
            setUiInitializing(oldInitializingValue);
        }
    }

    /**
     * A task for loading the characteristic types from the database in the
     * background.
     * 
     * @author Bill Wohler
     */
    private class CharacteristicTypesLoadTask extends
        DatabaseTask<Collection<CharacteristicType>, Object> {

        private static final String NAME = "CharacteristicTypesLoadTask";

        public CharacteristicTypesLoadTask() {
            enableComponents(queryComponents, false);
            updateEnabled();
        }

        @Override
        protected Collection<CharacteristicType> doInBackground()
            throws Exception {

            long start = System.currentTimeMillis();
            CharacteristicCrud charCrud = new CharacteristicCrud();
            Collection<CharacteristicType> characteristicTypes = charCrud.retrieveAllCharacteristicTypes();
            log.debug("Loaded characteristic types in "
                + (System.currentTimeMillis() - start) + " ms");

            return characteristicTypes;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListEditor.this, e, NAME);
            dismissDialog();
        }

        @Override
        protected void succeeded(Collection<CharacteristicType> result) {
            characteristicTypes = result;
            characteristicModel.setCharacteristicTypes(result);
            sortModel.setCharacteristicTypes(result);
            sortModel.setSelectedItem(Kic.Field.KEPLER_ID);
            if (targetList.getSourceType() == SourceType.QUERY
                && targetList.getSource() != null) {
                try {
                    constraintModel.setConstraints(targetList.getSource());
                } catch (ParseException e) {
                    handleError(e, NAME + ".parse", targetList.getSource());
                }
            }
        }

        @Override
        protected void finished() {
            if (currentSourceType == SourceType.QUERY && !readOnly) {
                enableComponents(queryComponents, true);
            }

            boolean oldInitializingValue = isUiInitializing();
            setUiInitializing(true);
            updateEnabled();
            setUiInitializing(oldInitializingValue);
        }
    }

    /**
     * A task for performing a query. The constructor builds the query from the
     * UI components. Then the application framework dispatches
     * {@link #doInBackground()} in the database thread which performs the
     * query. When the query is done, {@link #succeeded(List)} is called on the
     * EDT which updates the list of targets and the count in the GUI.
     * 
     * @author Bill Wohler
     */
    private class QueryTask extends DatabaseTask<List<PlannedTarget>, Object> {

        private List<Constraint> constraints;
        private long start;
        private Canonicalizable sortColumn;
        private SortDirection sortDirection;
        private int rowCount;

        public QueryTask(ConstraintListModel constraintModel) {
            this(constraintModel, null, null, 0);
        }

        public QueryTask(ConstraintListModel constraintModel,
            Canonicalizable sortColumn, SortDirection sortDirection,
            int rowCount) {

            setRecalculateEnabled(false);
            constraints = constraintModel.getAllElements();
            if (sortColumn != null) {
                this.sortColumn = sortColumn;
            }
            if (sortDirection != null) {
                this.sortDirection = sortDirection;
            }
            this.rowCount = rowCount;
        }

        @Override
        protected List<PlannedTarget> doInBackground() throws Exception {
            CelestialObjectOperationsProxy celestialObjectOperations = new CelestialObjectOperationsProxy();

            log.info(resourceMap.getString(RECALCULATE,
                Constraint.listToCanonicalizedString(constraints, null)));
            if (rowCount > 0) {
                log.info(resourceMap.getString(RECALCULATE + ".limit",
                    rowCount, sortColumn, sortDirection));
            }
            start = System.currentTimeMillis();

            // Make current list available for garbage collection in case we
            // need the space!
            targets = null;

            List<CelestialObject> celestialObjects = celestialObjectOperations.retrieveCelestialObjects(
                constraints, sortColumn, sortDirection, rowCount);
            if (isCancelled()) {
                return null;
            }
            List<PlannedTarget> targets = new ArrayList<PlannedTarget>(
                celestialObjects.size());
            for (CelestialObject celestialObject : celestialObjects) {
                targets.add(new PlannedTarget(celestialObject.getKeplerId(),
                    celestialObject.getSkyGroupId(), targetList));
            }

            return targets;
        }

        @Override
        protected void cancelled() {
            log.info(resourceMap.getString(RECALCULATE + ".cancelled"));
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListEditor.this, e, RECALCULATE + ".fatal",
                Constraint.listToCanonicalizedString(constraints, null));
            targets = new ArrayList<PlannedTarget>();
        }

        @Override
        protected void handleNonFatalError(Throwable e) {
            if (e instanceof OutOfMemoryError) {
                log.error(resourceMap.getString(RECALCULATE + ".outofmemory"));
                KeplerDialogs.showInformationDialog(
                    TargetListEditor.this,
                    resourceMap.getString(RECALCULATE + ".outofmemory.failed"),
                    resourceMap.getString(RECALCULATE
                        + ".outofmemory.failed.secondary"));
            } else {
                handleError(TargetListEditor.this, e,
                    RECALCULATE + ".nonfatal",
                    Constraint.listToCanonicalizedString(constraints, null));
            }
        }

        @Override
        protected void succeeded(List<PlannedTarget> result) {
            log.info(resourceMap.getString(RECALCULATE + ".duration",
                (System.currentTimeMillis() - start)));

            targets = result;
            targetsModified = false;
            targetsCreated = true;
            updateTotal();
        }

        @Override
        protected void finished() {
            setDirty(true);
        }
    }

    /**
     * A task for importing targets.
     * 
     * @author Bill Wohler
     */
    private class ImportTask extends DatabaseTask<List<PlannedTarget>, Object> {

        private static final String NEW_SUFFIX = ".new";

        private String filename;
        private String category;

        public ImportTask(String filename) {
            this.filename = filename;

            setImportTargetListEnabled(false);

            // Make current list available for garbage collection in case we
            // need the space!
            targets = null;
        }

        @Override
        protected List<PlannedTarget> doInBackground() throws Exception {
            log.info(resourceMap.getString(IMPORT, filename));

            long start = System.currentTimeMillis();

            File file = new File(filename);
            setMessage(resourceMap.getString(IMPORT + ".importMessage",
                file.getName()));
            TargetListImporterProxy importer = new TargetListImporterProxy(
                targetList);
            importer.setProgressHandler(new ProgressHandlerImpl());
            List<PlannedTarget> targets = importer.ingestTargetFile(filename);
            category = importer.getCategory();
            if (isCancelled()) {
                return null;
            }
            log.info(resourceMap.getString(IMPORT + ".importDuration",
                targets.size(), (System.currentTimeMillis() - start)));

            // Now export the file with the NEW keplerIds converted to valid
            // keplerIds.
            start = System.currentTimeMillis();
            setMessage(resourceMap.getString(IMPORT + ".exportMessage",
                file.getName()));
            Map<String, String> targetListFields = new HashMap<String, String>();
            targetListFields.put(TargetListImporter.CATEGORY_LABEL, category);
            new ExportTask().export(targets, targetListFields, new File(
                filename + NEW_SUFFIX));
            log.info(resourceMap.getString(IMPORT + ".exportDuration",
                targets.size(), (System.currentTimeMillis() - start)));

            return targets;
        }

        @Override
        protected void handleNonFatalError(Throwable e) {
            handleError(TargetListEditor.this, e, IMPORT + ".parse", filename);
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetListEditor.this, e, IMPORT, filename);
        }

        @Override
        protected void cancelled() {
            log.info(resourceMap.getString(IMPORT + ".warn.cancelled"));
        }

        @Override
        protected void succeeded(List<PlannedTarget> result) {
            targets = result;
            targetsModified = false;
            targetsCreated = true;
            updateTotal();
            if (category != null && category.length() > 0) {
                TargetListEditor.this.category.setSelectedItem(category);
            }
        }

        @Override
        protected void finished() {

            // Upon error, ensure that UI doesn't think we're still working.
            if (targets == null) {
                targets = new ArrayList<PlannedTarget>();
            }
            setDirty(true);
        }

        private class ProgressHandlerImpl implements ProgressHandler {
            @Override
            public void setProgress(float progress) {
                ImportTask.this.setProgress(progress);
            }
        }
    }

    /**
     * A task for saving the target list.
     * 
     * @author Bill Wohler
     */
    private class SaveTask extends DatabaseTask<TargetList, Void> {
        private TargetList targetList;

        public SaveTask(TargetList targetList) {
            setUserCanCancel(false);
            this.targetList = targetList;
        }

        @Override
        protected TargetList doInBackground() throws Exception {
            TargetSelectionCrudProxy targetSelectionCrud = new TargetSelectionCrudProxy();

            targetSelectionCrud.create(targetList);

            if (targetsCreated || targetsModified) {
                // TODO KSOC-500: Show progress (see ImportTask)
                new TargetSelectionOperationsProxy().updatePlannedTargets(
                    targetList, targets);
            }

            return targetList;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleErrorIntern(e);
        }

        @Override
        protected void handleNonFatalError(Throwable e) {
            handleErrorIntern(e);
        }

        private void handleErrorIntern(Throwable e) {
            handleError(TargetListEditor.this, e, OK, targetList);
        }

        @Override
        protected void succeeded(TargetList targetList) {
            EventBus.publish(new TypeReference<UpdateEvent<TargetList>>() {
            }.getType(), new UpdateEvent<TargetList>(
                UpdateEvent.Function.ADD_OR_UPDATE, targetList));
            dismissDialog();
        }
    }

    /**
     * A task for canceling the {@link TargetListEditor}.
     * 
     * @author Bill Wohler
     */
    private class CancelTask extends DatabaseTask<Void, Void> {

        public CancelTask() {
            setUserCanCancel(false);
        }

        @Override
        protected Void doInBackground() throws Exception {
            // Remove possibly modified targets from cache.
            DatabaseServiceFactory.getInstance()
                .evictAll(targets);
            return null;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            // Ignore. If we couldn't get a DatabaseService here, we
            // probably couldn't have gotten it when we entered the dialog.
            log.error("Shouldn't happen");
        }

        @Override
        protected void finished() {
            dismissDialog();
        }
    }
}
