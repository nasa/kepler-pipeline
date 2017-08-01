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

import static gov.nasa.kepler.ui.common.MathUtilities.isNumber;
import gov.nasa.kepler.cm.TargetSelectionOperations;
import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.common.TargetManagementConstants;
import gov.nasa.kepler.hibernate.cm.CelestialObject;
import gov.nasa.kepler.hibernate.cm.CustomTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget;
import gov.nasa.kepler.hibernate.cm.PlannedTarget.TargetLabel;
import gov.nasa.kepler.hibernate.cm.SkyGroup;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.pi.ModelMetadataRetrieverLatest;
import gov.nasa.kepler.hibernate.tad.Aperture;
import gov.nasa.kepler.hibernate.tad.Offset;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.proxy.CustomTargetCrudProxy;
import gov.nasa.kepler.ui.swing.KeplerPanel;
import gov.nasa.kepler.ui.swing.PanelHeader;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.Component;
import java.awt.Font;
import java.awt.Point;
import java.awt.event.ItemEvent;
import java.awt.event.ItemListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.ArrayList;
import java.util.Collection;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

import javax.swing.AbstractListModel;
import javax.swing.BorderFactory;
import javax.swing.ComboBoxModel;
import javax.swing.DefaultListCellRenderer;
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
import javax.swing.JScrollPane;
import javax.swing.JSeparator;
import javax.swing.JTabbedPane;
import javax.swing.JTextField;
import javax.swing.LayoutStyle;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.ListSelectionModel;
import javax.swing.SwingConstants;
import javax.swing.WindowConstants;
import javax.swing.border.Border;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.jdesktop.application.Action;

/**
 * A target editor. To use, call
 * {@link TargetEditor#edit(TargetList, List, boolean)}.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD_STORE")
public class TargetEditor extends KeplerPanel {

    private static final int STRING_FIELD_WIDTH = 15;
    private static final int NUMBER_FIELD_WIDTH = 5;
    private static final String NO_DATA = "-";

    private static final String NAME = "targetEditor";
    private static final String ADD = "add";
    private static final String REMOVE = "remove";
    private static final String TARGET_ID_PANEL = "targetIdPanel";
    private static final String CREATE = "create";
    private static final String LOOK_UP = "lookUp";
    private static final String LABEL_PANEL = "labelPanel";
    private static final String ADD_LABEL = "addLabel";
    private static final String UPDATE_LABEL = "updateLabel";
    private static final String REMOVE_LABEL = "removeLabel";
    private static final String APPLY_LABEL = "applyLabel";
    private static final String APERTURE_PANEL = "aperturePanel";
    private static final String USER_DEFINED_APERTURE = "userDefinedAperture";
    private static final String MOVE_APERTURE_REFERENCE = "moveApertureReference";
    private static final String APPLY = "apply";
    private static final String DONE = "done";

    private static final String ENABLED = "Enabled";

    private boolean addEnabled;
    private boolean removeEnabled;
    private boolean createEnabled;
    private boolean lookUpEnabled;
    private boolean addLabelEnabled;
    private boolean updateLabelEnabled;
    private boolean removeLabelEnabled;
    private boolean applyLabelEnabled;
    private boolean userDefinedApertureEnabled;
    private boolean applyEnabled;

    // UI components.
    private PanelHeader panelHeader;
    private JList targetsList;
    private TargetListModel targetListModel;
    private JTabbedPane tabbedPane;

    private JPanel targetIdPanel;
    private JTextField targetId;
    private JTextField skyGroup;
    private JLabel season0Module;
    private JLabel season0Output;
    private JLabel season1Module;
    private JLabel season1Output;
    private JLabel season2Module;
    private JLabel season2Output;
    private JLabel season3Module;
    private JLabel season3Output;

    private JPanel labelPanel;
    private JComboBox labelEditor;
    private JList labelList;
    private LabelListModel labelListModel;

    private JPanel aperturePanel;
    private JCheckBox userDefinedAperture;
    private ApertureEditor editAperturePanel;
    private JCheckBox moveApertureReference;
    private JTextField apertureReferenceRow;
    private JTextField apertureReferenceColumn;
    private JLabel mouseOffsetRow;
    private JLabel mouseOffsetColumn;

    private JButton okButton;

    // Additional fields.
    private TargetList targetList;
    private List<PlannedTarget> targets;
    private boolean readOnly;
    private boolean modified;
    private PropertyChangeListener aperturePropertyChangeListener = new AperturePropertyChangeListener();
    private ItemListener moveApertureReferenceListener = new MoveApertureReferenceListener();
    private TargetSelectionOperations targetSelectionOperations;
    private CelestialObjectOperations celestialObjectOperations;

    /**
     * The selected target. This is {@code null} if none of the targets are
     * selected.
     */
    private PlannedTarget selectedTarget;
    private List<JComponent> idComponents = new ArrayList<JComponent>();
    private List<JComponent> labelsComponents = new ArrayList<JComponent>();
    private List<JComponent> apertureComponents = new ArrayList<JComponent>();

    /**
     * Creates a {@link TargetEditor}.
     * 
     * @param targetList the target list that contains the targets
     * @param targets a non-{@code null} list of targets to edit
     * @param readOnly whether this editor should be read only or not
     * @throws NullPointerException if either {@code targetListName} or
     * {@code targets} are {@code null}
     * @throws UiException if the editor could not be created
     */
    public TargetEditor(TargetList targetList, List<PlannedTarget> targets,
        boolean readOnly) throws UiException {

        if (targetList == null) {
            throw new NullPointerException("targetList can't be null");
        }
        if (targets == null) {
            throw new NullPointerException("targets can't be null");
        }

        this.targetList = targetList;
        this.targets = targets;
        this.readOnly = readOnly;

        try {
            targetSelectionOperations = new TargetSelectionOperations();
            celestialObjectOperations = new CelestialObjectOperations(
                new ModelMetadataRetrieverLatest(), false);
        } catch (PipelineException e) {
            throw new UiException(e);
        }

        createUi();
    }

    @Override
    protected void initComponents() throws UiException {

        panelHeader = new PanelHeader();
        panelHeader.setName("header");

        targetsList = new JList();

        JScrollPane targetListScrollPane = new JScrollPane(targetsList);

        final JButton addButton = new JButton(actionMap.get(ADD));

        final JButton removeButton = new JButton(actionMap.get(REMOVE));

        tabbedPane = new JTabbedPane();
        tabbedPane.setTabLayoutPolicy(JTabbedPane.SCROLL_TAB_LAYOUT);

        // Target Identification Panel
        targetIdPanel = new JPanel();

        tabbedPane.addTab(resourceMap.getString(TARGET_ID_PANEL + ".text"),
            resourceMap.getIcon(TARGET_ID_PANEL + ".smallIcon"), targetIdPanel,
            resourceMap.getString(TARGET_ID_PANEL + ".shortDescription"));

        final JLabel targetTypeLabel = new JLabel();
        targetTypeLabel.setName("targetIdentification");
        targetTypeLabel.setFont(targetTypeLabel.getFont()
            .deriveFont(Font.BOLD));

        final JLabel targetIdLabel = new JLabel();
        targetIdLabel.setName("targetId");

        targetId = new JTextField(STRING_FIELD_WIDTH);
        targetIdLabel.setLabelFor(targetId);

        final JButton newTargetButton = new JButton(actionMap.get(CREATE));

        final JButton lookUpButton = new JButton(actionMap.get(LOOK_UP));

        final JLabel skyGroupLabel = new JLabel();
        skyGroupLabel.setName("skyGroup");

        skyGroup = new JTextField(NUMBER_FIELD_WIDTH);
        skyGroupLabel.setLabelFor(skyGroup);

        final JLabel tableModuleLabel = new JLabel();
        tableModuleLabel.setHorizontalAlignment(SwingConstants.TRAILING);
        tableModuleLabel.setName("module");

        final JLabel tableOutputLabel = new JLabel();
        tableOutputLabel.setHorizontalAlignment(SwingConstants.TRAILING);
        tableOutputLabel.setName("output");

        final JLabel season0Label = new JLabel();
        season0Label.setName("season0");

        season0Module = new JLabel();

        season0Output = new JLabel();

        final JLabel season1Label = new JLabel();
        season1Label.setName("season1");

        season1Module = new JLabel();

        season1Output = new JLabel();

        final JLabel season2Label = new JLabel();
        season2Label.setName("season2");

        season2Module = new JLabel();

        season2Output = new JLabel();

        final JLabel season3Label = new JLabel();
        season3Label.setName("season3");

        season3Module = new JLabel();

        season3Output = new JLabel();

        GroupLayout targetIdPanelLayout = new GroupLayout(targetIdPanel);
        targetIdPanel.setLayout(targetIdPanelLayout);
        targetIdPanelLayout.setAutoCreateContainerGaps(true);
        targetIdPanelLayout.setAutoCreateGaps(true);
        targetIdPanelLayout.linkSize(season0Label, tableModuleLabel,
            tableOutputLabel);

        targetIdPanelLayout.setHorizontalGroup(targetIdPanelLayout.createParallelGroup()
            .addComponent(targetTypeLabel)
            .addGroup(
                targetIdPanelLayout.createSequentialGroup()
                    .addPreferredGap(targetTypeLabel, targetIdLabel,
                        ComponentPlacement.INDENT)
                    .addGroup(
                        targetIdPanelLayout.createParallelGroup()
                            .addGroup(
                                targetIdPanelLayout.createSequentialGroup()
                                    .addGroup(
                                        targetIdPanelLayout.createParallelGroup()
                                            .addComponent(targetIdLabel)
                                            .addComponent(skyGroupLabel))
                                    .addGroup(
                                        targetIdPanelLayout.createParallelGroup(
                                            Alignment.LEADING, false)
                                            .addGroup(
                                                targetIdPanelLayout.createSequentialGroup()
                                                    .addComponent(
                                                        targetId,
                                                        GroupLayout.PREFERRED_SIZE,
                                                        GroupLayout.DEFAULT_SIZE,
                                                        GroupLayout.PREFERRED_SIZE)
                                                    .addComponent(
                                                        newTargetButton))
                                            .addComponent(lookUpButton)
                                            .addComponent(skyGroup,
                                                GroupLayout.PREFERRED_SIZE,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.PREFERRED_SIZE)))
                            .addGroup(
                                targetIdPanelLayout.createSequentialGroup()
                                    .addGroup(
                                        targetIdPanelLayout.createParallelGroup()
                                            .addComponent(season0Label)
                                            .addComponent(season1Label)
                                            .addComponent(season2Label)
                                            .addComponent(season3Label))
                                    .addPreferredGap(season0Module,
                                        tableModuleLabel,
                                        ComponentPlacement.UNRELATED)
                                    .addGroup(
                                        targetIdPanelLayout.createParallelGroup(
                                            Alignment.TRAILING)
                                            .addComponent(tableModuleLabel)
                                            .addComponent(season0Module)
                                            .addComponent(season1Module)
                                            .addComponent(season2Module)
                                            .addComponent(season3Module))
                                    .addPreferredGap(
                                        ComponentPlacement.UNRELATED)
                                    .addGroup(
                                        targetIdPanelLayout.createParallelGroup(
                                            Alignment.TRAILING)
                                            .addComponent(tableOutputLabel)
                                            .addComponent(season0Output)
                                            .addComponent(season1Output)
                                            .addComponent(season2Output)
                                            .addComponent(season3Output))))));

        targetIdPanelLayout.setVerticalGroup(targetIdPanelLayout.createSequentialGroup()
            .addComponent(targetTypeLabel)
            .addPreferredGap(LayoutStyle.ComponentPlacement.UNRELATED)
            .addGroup(
                targetIdPanelLayout.createParallelGroup(Alignment.BASELINE)
                    .addComponent(targetId)
                    .addComponent(targetIdLabel)
                    .addComponent(newTargetButton))
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(lookUpButton)
            .addGroup(
                targetIdPanelLayout.createParallelGroup(Alignment.BASELINE)
                    .addComponent(skyGroupLabel)
                    .addComponent(skyGroup))
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addGroup(targetIdPanelLayout.createSequentialGroup()
                .addGroup(targetIdPanelLayout.createParallelGroup()
                    .addComponent(tableModuleLabel)
                    .addComponent(tableOutputLabel))
                .addGroup(targetIdPanelLayout.createParallelGroup()
                    .addComponent(season0Label)
                    .addComponent(season0Module)
                    .addComponent(season0Output))
                .addGroup(targetIdPanelLayout.createParallelGroup()
                    .addComponent(season1Label)
                    .addComponent(season1Module)
                    .addComponent(season1Output))
                .addGroup(targetIdPanelLayout.createParallelGroup()
                    .addComponent(season2Label)
                    .addComponent(season2Module)
                    .addComponent(season2Output))
                .addGroup(targetIdPanelLayout.createParallelGroup()
                    .addComponent(season3Label)
                    .addComponent(season3Module)
                    .addComponent(season3Output))));

        // Target Labels Panel
        labelPanel = new JPanel();

        tabbedPane.addTab(resourceMap.getString(LABEL_PANEL + ".text"),
            resourceMap.getIcon(LABEL_PANEL + ".smallIcon"), labelPanel,
            resourceMap.getString(LABEL_PANEL + ".shortDescription"));

        final JLabel targetLabelsLabel = new JLabel();
        targetLabelsLabel.setName("label");
        targetLabelsLabel.setFont(targetLabelsLabel.getFont()
            .deriveFont(Font.BOLD));

        labelEditor = new JComboBox();

        labelList = new JList();
        JScrollPane labelListScrollPane = new JScrollPane(labelList);

        final JButton addLabelButton = new JButton(actionMap.get(ADD_LABEL));

        final JButton updateLabelButton = new JButton(
            actionMap.get(UPDATE_LABEL));

        final JButton deleteLabelButton = new JButton(
            actionMap.get(REMOVE_LABEL));

        final JButton applyLabelButton = new JButton(actionMap.get(APPLY_LABEL));

        GroupLayout labelPanelLayout = new GroupLayout(labelPanel);
        labelPanel.setLayout(labelPanelLayout);
        labelPanelLayout.setAutoCreateContainerGaps(true);
        labelPanelLayout.setAutoCreateGaps(true);
        labelPanelLayout.linkSize(addLabelButton, updateLabelButton,
            deleteLabelButton, applyLabelButton);

        labelPanelLayout.setHorizontalGroup(labelPanelLayout.createSequentialGroup()
            .addGroup(
                labelPanelLayout.createParallelGroup()
                    .addComponent(targetLabelsLabel)
                    .addGroup(
                        labelPanelLayout.createSequentialGroup()
                            .addPreferredGap(targetLabelsLabel, labelEditor,
                                ComponentPlacement.INDENT)
                            .addGroup(labelPanelLayout.createParallelGroup()
                                .addComponent(labelEditor)
                                .addComponent(labelListScrollPane))
                            .addGroup(labelPanelLayout.createParallelGroup()
                                .addComponent(addLabelButton)
                                .addComponent(updateLabelButton)
                                .addComponent(deleteLabelButton)
                                .addComponent(applyLabelButton))))
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE));

        labelPanelLayout.setVerticalGroup(labelPanelLayout.createSequentialGroup()
            .addComponent(targetLabelsLabel)
            .addPreferredGap(LayoutStyle.ComponentPlacement.UNRELATED)
            .addGroup(
                labelPanelLayout.createParallelGroup()
                    .addGroup(
                        labelPanelLayout.createSequentialGroup()
                            .addComponent(labelEditor,
                                GroupLayout.DEFAULT_SIZE,
                                GroupLayout.DEFAULT_SIZE,
                                GroupLayout.PREFERRED_SIZE)
                            .addComponent(labelListScrollPane,
                                GroupLayout.PREFERRED_SIZE,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
                    .addGroup(
                        labelPanelLayout.createSequentialGroup()
                            .addComponent(addLabelButton)
                            .addComponent(updateLabelButton)
                            .addComponent(deleteLabelButton)
                            .addPreferredGap(ComponentPlacement.UNRELATED,
                                GroupLayout.DEFAULT_SIZE,
                                GroupLayout.PREFERRED_SIZE)
                            .addComponent(applyLabelButton))));

        // Aperture Panel
        aperturePanel = new JPanel();

        tabbedPane.addTab(resourceMap.getString(APERTURE_PANEL + ".text"),
            resourceMap.getIcon(APERTURE_PANEL + ".smallIcon"), aperturePanel,
            resourceMap.getString(APERTURE_PANEL + ".shortDescription"));

        final JLabel apertureLabel = new JLabel();
        apertureLabel.setName("aperture");
        apertureLabel.setFont(apertureLabel.getFont()
            .deriveFont(Font.BOLD));

        userDefinedAperture = new JCheckBox(
            actionMap.get(USER_DEFINED_APERTURE));
        editAperturePanel = new ApertureEditor();
        editAperturePanel.addPropertyChangeListener(aperturePropertyChangeListener);

        moveApertureReference = new JCheckBox(
            actionMap.get(MOVE_APERTURE_REFERENCE));

        final JLabel apertureReferenceLabel = new JLabel();
        apertureReferenceLabel.setName("apertureReference");

        final JLabel apertureRowLabel = new JLabel();
        apertureRowLabel.setName("row");

        apertureReferenceRow = new JTextField(NUMBER_FIELD_WIDTH);
        apertureReferenceLabel.setLabelFor(apertureReferenceRow);

        final JLabel apertureColumnLabel = new JLabel();
        apertureColumnLabel.setName("column");

        apertureReferenceColumn = new JTextField(NUMBER_FIELD_WIDTH);

        final JLabel mouseOffsetLabel = new JLabel();
        mouseOffsetLabel.setName("mouseOffset");

        mouseOffsetRow = new JLabel();

        mouseOffsetColumn = new JLabel();

        GroupLayout aperturePanelLayout = new GroupLayout(aperturePanel);
        aperturePanel.setLayout(aperturePanelLayout);
        aperturePanelLayout.setAutoCreateContainerGaps(true);
        aperturePanelLayout.setAutoCreateGaps(true);

        aperturePanelLayout.setHorizontalGroup(aperturePanelLayout.createParallelGroup()
            .addComponent(apertureLabel)
            .addGroup(
                aperturePanelLayout.createSequentialGroup()
                    .addPreferredGap(apertureLabel, userDefinedAperture,
                        ComponentPlacement.INDENT)
                    .addGroup(
                        aperturePanelLayout.createParallelGroup()
                            .addComponent(userDefinedAperture)
                            .addGroup(
                                aperturePanelLayout.createSequentialGroup()
                                    .addGroup(
                                        aperturePanelLayout.createParallelGroup()
                                            .addGroup(
                                                aperturePanelLayout.createSequentialGroup()
                                                    .addPreferredGap(
                                                        userDefinedAperture,
                                                        editAperturePanel,
                                                        ComponentPlacement.INDENT)
                                                    .addComponent(
                                                        editAperturePanel))
                                            .addComponent(moveApertureReference))
                                    .addPreferredGap(editAperturePanel,
                                        apertureReferenceLabel,
                                        ComponentPlacement.UNRELATED)
                                    .addGroup(
                                        aperturePanelLayout.createSequentialGroup()
                                            .addGroup(
                                                aperturePanelLayout.createParallelGroup()
                                                    .addComponent(
                                                        apertureReferenceLabel)
                                                    .addComponent(
                                                        mouseOffsetLabel))
                                            .addGroup(
                                                aperturePanelLayout.createParallelGroup()
                                                    .addComponent(
                                                        apertureReferenceRow)
                                                    .addComponent(
                                                        mouseOffsetRow)
                                                    .addComponent(
                                                        apertureRowLabel))
                                            .addGroup(
                                                aperturePanelLayout.createParallelGroup()
                                                    .addComponent(
                                                        apertureColumnLabel)
                                                    .addComponent(
                                                        apertureReferenceColumn)
                                                    .addComponent(
                                                        mouseOffsetColumn)))))));

        aperturePanelLayout.setVerticalGroup(aperturePanelLayout.createSequentialGroup()
            .addComponent(apertureLabel)
            .addPreferredGap(ComponentPlacement.UNRELATED)
            .addComponent(userDefinedAperture)
            .addGroup(
                aperturePanelLayout.createParallelGroup()
                    .addGroup(aperturePanelLayout.createSequentialGroup()
                        .addComponent(editAperturePanel)
                        .addComponent(moveApertureReference))
                    .addGroup(
                        aperturePanelLayout.createSequentialGroup()
                            .addGroup(
                                aperturePanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(apertureRowLabel)
                                    .addComponent(apertureColumnLabel))
                            .addGroup(
                                aperturePanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(apertureReferenceLabel)
                                    .addComponent(apertureReferenceRow)
                                    .addComponent(apertureReferenceColumn))
                            .addPreferredGap(ComponentPlacement.UNRELATED)
                            .addGroup(
                                aperturePanelLayout.createParallelGroup(
                                    Alignment.BASELINE)
                                    .addComponent(mouseOffsetLabel)
                                    .addComponent(mouseOffsetRow)
                                    .addComponent(mouseOffsetColumn)))));

        // Controls
        final JButton applyButton = new JButton(actionMap.get(APPLY));

        final JSeparator separator = new JSeparator();

        okButton = new JButton(actionMap.get(DONE));

        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);

        layout.setAutoCreateContainerGaps(true);
        layout.setAutoCreateGaps(true);
        layout.linkSize(addButton, removeButton);

        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addGroup(
                layout.createParallelGroup()
                    .addGroup(
                        layout.createSequentialGroup()
                            .addGroup(
                                layout.createParallelGroup(Alignment.LEADING,
                                    false)
                                    .addComponent(targetListScrollPane,
                                        GroupLayout.DEFAULT_SIZE,
                                        GroupLayout.DEFAULT_SIZE,
                                        Short.MAX_VALUE)
                                    .addGroup(layout.createSequentialGroup()
                                        .addComponent(addButton)
                                        .addComponent(removeButton)))
                            .addGroup(
                                layout.createParallelGroup()
                                    .addComponent(tabbedPane,
                                        GroupLayout.PREFERRED_SIZE,
                                        GroupLayout.DEFAULT_SIZE,
                                        Short.MAX_VALUE)
                                    .addGroup(
                                        layout.createSequentialGroup()
                                            .addPreferredGap(
                                                ComponentPlacement.UNRELATED,
                                                GroupLayout.DEFAULT_SIZE,
                                                Short.MAX_VALUE)
                                            .addComponent(applyButton))))
                    .addComponent(separator, GroupLayout.Alignment.LEADING,
                        GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE,
                        Short.MAX_VALUE)
                    .addGroup(
                        layout.createSequentialGroup()
                            .addPreferredGap(ComponentPlacement.UNRELATED,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(okButton))));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addGroup(
                layout.createParallelGroup()
                    .addGroup(
                        layout.createSequentialGroup()
                            .addComponent(targetListScrollPane,
                                GroupLayout.PREFERRED_SIZE,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addGroup(
                                layout.createParallelGroup(Alignment.BASELINE)
                                    .addComponent(addButton)
                                    .addComponent(removeButton)))
                    .addGroup(
                        layout.createSequentialGroup()
                            .addComponent(tabbedPane,
                                GroupLayout.PREFERRED_SIZE,
                                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
                            .addComponent(applyButton)))
            .addPreferredGap(LayoutStyle.ComponentPlacement.UNRELATED)
            .addComponent(separator, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addPreferredGap(LayoutStyle.ComponentPlacement.UNRELATED)
            .addComponent(okButton));

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
     * Provides for additional configuration of the components.
     */
    @Override
    protected void configureComponents() {
        targetListModel = new TargetListModel(targets);
        targetsList.setModel(targetListModel);
        targetsList.setCellRenderer(new TargetListCellRenderer());
        targetsList.setPrototypeCellValue(new PlannedTarget(2000000000, 0,
            targetList));
        targetsList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        targetsList.getSelectionModel()
            .addListSelectionListener(targetListModel);

        idComponents.add(targetId);
        idComponents.add(skyGroup);
        enableComponents(idComponents, !isReadOnly());

        labelEditor.setModel(new LabelEditorModel());
        labelEditor.setEditable(true);
        labelsComponents.add(labelEditor);
        labelListModel = new LabelListModel();
        labelList.setModel(labelListModel);
        labelList.setCellRenderer(new LabelListCellRenderer());
        labelList.setPrototypeCellValue("The longest label that we expect");
        labelList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        labelList.getSelectionModel()
            .addListSelectionListener(labelListModel);
        labelsComponents.add(labelList);
        enableComponents(labelsComponents, !isReadOnly());

        apertureComponents.add(editAperturePanel);
        moveApertureReference.addItemListener(moveApertureReferenceListener);
        apertureComponents.add(moveApertureReference);
        apertureComponents.add(apertureReferenceRow);
        apertureComponents.add(apertureReferenceColumn);
        apertureComponents.add(mouseOffsetRow);
        apertureComponents.add(mouseOffsetColumn);
        enableComponents(apertureComponents, false);

        setDirtyDocumentListeners(true);
    }

    /**
     * Edits the given target list in a modal dialog.
     * 
     * @param targetList the target list that contains the targets
     * @param targets a non-{@code null} list of targets to edit
     * @param readOnly whether this editor should be read only or not
     * @return {@code true} if the list was modified; otherwise, {@code false}
     * @throws NullPointerException if either {@code targetListName} or
     * {@code targets} are {@code null}
     * @throws UiException if the editor could not be created
     */
    public static boolean edit(TargetList targetList,
        List<PlannedTarget> targets, boolean readOnly) throws UiException {

        JDialog dialog = new JDialog();
        dialog.setName(NAME);
        dialog.setModal(true);
        final TargetEditor editor = new TargetEditor(targetList, targets,
            readOnly);
        dialog.add(editor);
        editor.setTitle(false, targetList.getName());
        dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
        dialog.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                editor.dismissDialog();
            }
        });
        editor.initDefaultKeys();
        app.show(dialog);

        return editor.isModified();
    }

    @Override
    protected void updateEnabled() {
        setHelpText(null);
        setAddEnabled(true);
        setRemoveEnabled(true);
        setCreateEnabled(true);
        setLookUpEnabled(true);
        setAddLabelEnabled(true);
        setUpdateLabelEnabled(true);
        setRemoveLabelEnabled(true);
        setApplyLabelEnabled(true);
        setUserDefinedApertureEnabled(true);
        setApplyEnabled(true);

        // Can't modify skyGroupId of KIC objects.
        String s = targetId.getText();
        int keplerId = isNumber(s) ? Integer.parseInt(s)
            : TargetManagementConstants.INVALID_KEPLER_ID;
        skyGroup.setEnabled(TargetManagementConstants.isCustomTarget(keplerId));

        updateModuleOutputs();
        panelHeader.displayHelp(getHelpText());
    }

    @Override
    protected JButton getDefaultButton() {
        return okButton;
    }

    /**
     * Used to add new targets. This method simply clears all fields.
     */
    @Action(enabledProperty = ADD + ENABLED)
    public void add() {
        log.info(resourceMap.getString(ADD));
        clearFields();
    }

    public boolean isAddEnabled() {
        return addEnabled;
    }

    public void setAddEnabled(boolean addEnabled) {
        boolean oldValue = this.addEnabled;
        // Not using isReadOnly() here because we should always be able to add a
        // new target unless the target list is read-only.
        this.addEnabled = addEnabled && !readOnly;
        firePropertyChange(ADD + ENABLED, oldValue, this.addEnabled);
    }

    /**
     * Removes the selected target.
     */
    @Action(enabledProperty = REMOVE + ENABLED)
    public void remove() {
        int index = targetsList.getSelectedIndex();
        PlannedTarget target = (PlannedTarget) targetsList.getSelectedValue();
        log.info(resourceMap.getString(REMOVE, target.getKeplerId()));
        targetListModel.remove(target);
        if (targetListModel.getSize() > 0) {
            targetsList.setSelectedIndex(Math.min(index,
                targetListModel.getSize() - 1));
        } else {
            clearFields();
        }
        setModified(true);
    }

    public boolean isRemoveEnabled() {
        return removeEnabled;
    }

    public void setRemoveEnabled(boolean removeEnabled) {
        boolean oldValue = this.removeEnabled;
        // Not using isReadOnly() here because we should be able to remove any
        // target unless the target list is read-only.
        this.removeEnabled = removeEnabled
            && targetsList.getSelectedIndex() != -1 && !readOnly;
        firePropertyChange(REMOVE + ENABLED, oldValue, this.removeEnabled);
    }

    @Action(enabledProperty = CREATE + ENABLED)
    public void create() {
        log.info(resourceMap.getString(CREATE));
        clearFields();
        executeDatabaseTask(CREATE, new CustomTargetLookupTask());
    }

    public boolean isCreateEnabled() {
        return createEnabled;
    }

    public void setCreateEnabled(boolean createEnabled) {
        boolean oldValue = this.createEnabled;
        this.createEnabled = createEnabled && !isReadOnly();
        firePropertyChange(CREATE + ENABLED, oldValue, this.createEnabled);
    }

    /**
     * Look up the sky group. Invoked when the Look Up button is pressed.
     */
    @Action(enabledProperty = LOOK_UP + ENABLED)
    public void lookUp() {
        log.info(resourceMap.getString(LOOK_UP, targetId.getText()));
        executeDatabaseTask(LOOK_UP,
            new KicLookupTask(Integer.parseInt(targetId.getText())));
    }

    public boolean isLookUpEnabled() {
        return lookUpEnabled;
    }

    public void setLookUpEnabled(boolean lookUpEnabled) {
        boolean oldValue = this.lookUpEnabled;
        this.lookUpEnabled = lookUpEnabled && isNumber(targetId.getText())
            && !isReadOnly();
        firePropertyChange(LOOK_UP + ENABLED, oldValue, this.lookUpEnabled);
    }

    @Action(enabledProperty = ADD_LABEL + ENABLED)
    public void addLabel() {
        log.info(resourceMap.getString(ADD_LABEL,
            (String) labelEditor.getSelectedItem()));
        labelListModel.add((String) labelEditor.getSelectedItem());
        labelList.setSelectedIndex(labelListModel.getSize() - 1);
        labelEditor.requestFocusInWindow();
        setDirty(true);
    }

    public boolean isAddLabelEnabled() {
        return addLabelEnabled;
    }

    public void setAddLabelEnabled(boolean addLabelEnabled) {
        boolean oldValue = this.addLabelEnabled;
        this.addLabelEnabled = addLabelEnabled && !isReadOnly();
        firePropertyChange(ADD_LABEL + ENABLED, oldValue, this.addLabelEnabled);
    }

    @Action(enabledProperty = UPDATE_LABEL + ENABLED)
    public void updateLabel() {
        String oldValue = (String) labelList.getSelectedValue();
        String newValue = (String) labelEditor.getSelectedItem();
        log.info(resourceMap.getString(UPDATE_LABEL, oldValue, newValue));
        labelListModel.setElementAt(labelListModel.indexOf(oldValue), newValue);
        setDirty(true);
    }

    public boolean isUpdateLabelEnabled() {
        return updateLabelEnabled;
    }

    public void setUpdateLabelEnabled(boolean updateLabelEnabled) {
        boolean oldValue = this.updateLabelEnabled;
        this.updateLabelEnabled = updateLabelEnabled
            && !labelList.isSelectionEmpty();
        firePropertyChange(UPDATE_LABEL + ENABLED, oldValue,
            this.updateLabelEnabled);
    }

    @Action(enabledProperty = REMOVE_LABEL + ENABLED)
    public void removeLabel() {
        int index = labelList.getSelectedIndex();
        String label = (String) labelList.getSelectedValue();
        log.info(resourceMap.getString(REMOVE_LABEL, label));
        labelListModel.remove(label);
        labelList.setSelectedIndex(Math.min(index, labelListModel.getSize() - 1));
        setDirty(true);
    }

    public boolean isRemoveLabelEnabled() {
        return removeLabelEnabled;
    }

    public void setRemoveLabelEnabled(boolean removeLabelEnabled) {
        boolean oldValue = this.removeLabelEnabled;
        this.removeLabelEnabled = removeLabelEnabled
            && !labelList.isSelectionEmpty();
        firePropertyChange(REMOVE_LABEL + ENABLED, oldValue,
            this.removeLabelEnabled);
    }

    // SOC_REQ_IMPL 926.CM.5
    @Action(enabledProperty = APPLY_LABEL + ENABLED)
    public void applyLabel() {
        log.info(resourceMap.getString(APPLY_LABEL));

        for (PlannedTarget target : targets) {
            target.setLabels(labelListModel.getLabels());
        }
    }

    public boolean isApplyLabelEnabled() {
        return applyLabelEnabled;
    }

    public void setApplyLabelEnabled(boolean applyLabelEnabled) {
        boolean oldValue = this.applyLabelEnabled;
        this.applyLabelEnabled = applyLabelEnabled && !isReadOnly();
        firePropertyChange(APPLY_LABEL + ENABLED, oldValue,
            this.applyLabelEnabled);
    }

    @Action(enabledProperty = USER_DEFINED_APERTURE + ENABLED)
    public void userDefinedAperture() {
        boolean on = userDefinedAperture.isSelected();
        log.info(resourceMap.getString(USER_DEFINED_APERTURE, on ? "on" : "off"));
        enableComponents(apertureComponents, on);
        setDirty(true);
        updateEnabled();
    }

    public boolean isUserDefinedApertureEnabled() {
        return userDefinedApertureEnabled;
    }

    public void setUserDefinedApertureEnabled(boolean userDefinedApertureEnabled) {
        boolean oldValue = this.userDefinedApertureEnabled;
        this.userDefinedApertureEnabled = userDefinedApertureEnabled
            && !isReadOnly();
        firePropertyChange(USER_DEFINED_APERTURE + ENABLED, oldValue,
            this.userDefinedApertureEnabled);
    }

    @Action
    public void moveApertureReference() {
        log.info(resourceMap.getString(MOVE_APERTURE_REFERENCE));
        // Action used solely for resources. See
        // MoveApertureReferenceListener.itemStateChanged for code.
    }

    /**
     * Creates a {@link PlannedTarget} from the user-provided information.
     */
    @Action(enabledProperty = APPLY + ENABLED)
    public void apply() {
        int keplerId = Integer.parseInt(targetId.getText());
        log.info(resourceMap.getString(APPLY, keplerId));

        // Is this target already in the list?
        PlannedTarget target = null;
        for (PlannedTarget t : targets) {
            if (keplerId == t.getKeplerId()) {
                target = t;
                break;
            }
        }

        // If not, create a new one and add it to the list.
        if (target == null) {
            target = new PlannedTarget(targetList);
            targetListModel.add(target);
        }

        populateTargetFromFields(target);

        if (TargetManagementConstants.isCustomTarget(target.getKeplerId())) {
            executeDatabaseTask(
                APPLY,
                new CustomTargetLookupTask(target.getKeplerId(),
                    target.getSkyGroupId()));
        }

        setDirty(false);
        setModified(true);
    }

    public boolean isApplyEnabled() {
        return applyEnabled;
    }

    public void setApplyEnabled(boolean applyEnabled) {
        boolean oldValue = this.applyEnabled;
        this.applyEnabled = applyEnabled
            && isDirty()
            && !isReadOnly()
            && conditionalHelp(isNumber(targetId.getText()),
                "numericTargetId.help")
            && conditionalHelp(isNumber(skyGroup.getText()),
                "numericSkyGroup.help")
            && (!TargetManagementConstants.isCustomTarget(Integer.parseInt(targetId.getText())) || conditionalHelp(
                userDefinedAperture.isSelected(), "customTargetAperture.help"))
            && (!userDefinedAperture.isSelected() || conditionalHelp(
                validReferenceRow(), "validReferenceRow.help")
                && conditionalHelp(validReferenceColumn(),
                    "validReferenceColumn.help")
                && conditionalHelp(validOffsets(), "validOffsets.help"));
        firePropertyChange(APPLY + ENABLED, oldValue, this.applyEnabled);
    }

    private boolean validReferenceRow() {
        if (!isNumber(apertureReferenceRow.getText())) {
            return false;
        }

        int referenceRow = Integer.parseInt(apertureReferenceRow.getText());
        if (referenceRow < 0 || referenceRow >= FcConstants.CCD_ROWS) {
            return false;
        }

        return true;
    }

    private boolean validReferenceColumn() {
        if (!isNumber(apertureReferenceColumn.getText())) {
            return false;
        }

        int referenceColumn = Integer.parseInt(apertureReferenceColumn.getText());
        if (referenceColumn < 0 || referenceColumn >= FcConstants.CCD_COLUMNS) {
            return false;
        }

        return true;
    }

    // This method assumes that validReferenceRow and validReferenceColumn have
    // both returned true.
    private boolean validOffsets() {
        List<Offset> offsets = editAperturePanel.getOffsets();
        if (offsets.size() == 0) {
            return false;
        }

        int referenceRow = Integer.parseInt(apertureReferenceRow.getText());
        int referenceColumn = Integer.parseInt(apertureReferenceColumn.getText());

        for (Offset offset : offsets) {
            // Absolute pixel must be on the CCD.
            int absoluteRow = referenceRow + offset.getRow();
            int absoluteColumn = referenceColumn + offset.getColumn();
            if (absoluteRow < 0 || absoluteRow >= FcConstants.CCD_ROWS
                || absoluteColumn < 0
                || absoluteColumn >= FcConstants.CCD_COLUMNS) {
                return false;
            }
        }

        return true;
    }

    /**
     * Dismisses the dialog.
     */
    @Action
    public void done() {
        log.info(resourceMap.getString(DONE, targetList));
        if (isDirty() && warnUser(DONE)) {
            return;
        }

        dismissDialog();
    }

    /**
     * Clears the fields and sets focus to the first field of the selected tab.
     * This is typically invoked by the Add command.
     * <p>
     * The Beans Binding or other techniques described at JavaOne 2007 would
     * simplify {@link #clearFields()}, {@link #updateFields()}, and
     * {@link #populateTargetFromFields(PlannedTarget)} dramatically!
     */
    private void clearFields() {
        setDirtyDocumentListeners(false);

        selectedTarget = null;
        targetsList.clearSelection();

        targetId.setText("");
        if (tabbedPane.getSelectedComponent() == targetIdPanel) {
            targetId.requestFocus();
        }
        skyGroup.setText("");
        enableComponents(idComponents, !isReadOnly());

        if (tabbedPane.getSelectedComponent() == labelPanel) {
            labelList.requestFocus();
        }
        labelListModel.clear();
        enableComponents(labelsComponents, !isReadOnly());

        if (tabbedPane.getSelectedComponent() == aperturePanel) {
            userDefinedAperture.requestFocus();
        }
        userDefinedAperture.setSelected(false);
        editAperturePanel.clear();
        apertureReferenceRow.setText("");
        apertureReferenceColumn.setText("");
        mouseOffsetRow.setText("");
        mouseOffsetColumn.setText("");
        enableComponents(apertureComponents, false);

        setDirty(false);
        setDirtyDocumentListeners(true);
    }

    /**
     * Updates the fields based upon the selected target.
     */
    private void updateFields() {
        setDirtyDocumentListeners(false);

        targetId.setText(Integer.toString(selectedTarget.getKeplerId()));
        skyGroup.setText(Integer.toString(selectedTarget.getSkyGroupId()));
        enableComponents(idComponents, !isReadOnly());

        labelListModel.clear();
        labelListModel.addAll(selectedTarget.getLabels());
        labelList.clearSelection();
        enableComponents(labelsComponents, !isReadOnly());

        Aperture aperture = selectedTarget.getAperture();
        boolean userDefined = aperture != null && aperture.isUserDefined();
        userDefinedAperture.setSelected(userDefined);
        if (userDefined) {
            // aperture can't be null if userDefined is true!
            editAperturePanel.setOffsets(aperture.getOffsets());
            apertureReferenceRow.setText(Integer.toString(aperture.getReferenceRow()));
            apertureReferenceColumn.setText(Integer.toString(aperture.getReferenceColumn()));
        } else {
            editAperturePanel.clear();
            apertureReferenceRow.setText("");
            apertureReferenceColumn.setText("");
        }
        mouseOffsetRow.setText("");
        mouseOffsetColumn.setText("");
        enableComponents(apertureComponents, userDefined && !isReadOnly());

        setDirty(false);
        setDirtyDocumentListeners(true);
    }

    /**
     * Creates a planned target based upon the content of the fields. This is
     * typically invoked by the Apply command.
     */
    private PlannedTarget populateTargetFromFields(PlannedTarget target) {
        target.setKeplerId(Integer.parseInt(targetId.getText()));
        target.setSkyGroupId(Integer.parseInt(skyGroup.getText()));

        target.setLabels(labelListModel.getLabels());

        Aperture aperture = null;
        if (userDefinedAperture.isSelected()) {
            aperture = new Aperture(true,
                Integer.parseInt(apertureReferenceRow.getText()),
                Integer.parseInt(apertureReferenceColumn.getText()),
                editAperturePanel.getOffsets());
        }
        target.setAperture(aperture);

        return target;
    }

    /**
     * Updates the module and outputs using the entered sky group.
     */
    private void updateModuleOutputs() {

        int skyGroupId = 0;
        String skyGroupString = skyGroup.getText()
            .trim();
        if (isNumber(skyGroupString)) {
            skyGroupId = Integer.parseInt(skyGroupString);
        }

        // If sky group ID is too large, display help and reset ID to 0 to
        // clear the module/output fields.
        if (!conditionalHelp(
            skyGroupId <= TargetManagementConstants.MAX_SKY_GROUP_ID,
            "numericSkyGroup.help")) {
            skyGroupId = 0;
        }

        // Get the sky group for each of the four seasons.
        SkyGroup[] skyGroups = new SkyGroup[4];
        try {
            if (skyGroupId > 0) {
                for (int i = 0; i < 4; i++) {
                    skyGroups[i] = targetSelectionOperations.skyGroupFor(
                        skyGroupId, i);
                }
            }
        } catch (IllegalArgumentException e) {
            handleError(e, LOOK_UP + ".skyGroup", skyGroupId);
        }

        season0Module.setText(skyGroups[0] == null ? NO_DATA
            : Integer.toString(skyGroups[0].getCcdModule()));
        season0Output.setText(skyGroups[0] == null ? NO_DATA
            : Integer.toString(skyGroups[0].getCcdOutput()));

        season1Module.setText(skyGroups[1] == null ? NO_DATA
            : Integer.toString(skyGroups[1].getCcdModule()));
        season1Output.setText(skyGroups[1] == null ? NO_DATA
            : Integer.toString(skyGroups[1].getCcdOutput()));

        season2Module.setText(skyGroups[2] == null ? NO_DATA
            : Integer.toString(skyGroups[2].getCcdModule()));
        season2Output.setText(skyGroups[2] == null ? NO_DATA
            : Integer.toString(skyGroups[2].getCcdOutput()));

        season3Module.setText(skyGroups[3] == null ? NO_DATA
            : Integer.toString(skyGroups[3].getCcdModule()));
        season3Output.setText(skyGroups[3] == null ? NO_DATA
            : Integer.toString(skyGroups[3].getCcdOutput()));
    }

    /**
     * Turn the dirty document listener on or off on the text components. This
     * is useful before running commands that update the fields but would not
     * ordinarily change the dirty state.
     * 
     * @param addListener if {@code true}, use a dirty document listener; else,
     * do not use a listener on the text components at all
     */
    private void setDirtyDocumentListeners(boolean addListener) {
        // Ensure listeners aren't added twice.
        targetId.getDocument()
            .removeDocumentListener(dirtyDocumentListener);
        skyGroup.getDocument()
            .removeDocumentListener(dirtyDocumentListener);
        apertureReferenceRow.getDocument()
            .removeDocumentListener(dirtyDocumentListener);
        apertureReferenceColumn.getDocument()
            .removeDocumentListener(dirtyDocumentListener);

        if (addListener) {
            targetId.getDocument()
                .addDocumentListener(dirtyDocumentListener);
            skyGroup.getDocument()
                .addDocumentListener(dirtyDocumentListener);
            apertureReferenceRow.getDocument()
                .addDocumentListener(dirtyDocumentListener);
            apertureReferenceColumn.getDocument()
                .addDocumentListener(dirtyDocumentListener);
        }
    }

    /**
     * Returns {@code true} if the selected target (or target list) is
     * read-only.
     * 
     * @return {@code true} if the selected target (or target list) is read
     * only; otherwise, {@code false}
     */
    private boolean isReadOnly() {
        return readOnly;
    }

    /**
     * Tests whether the target list has been modified.
     * 
     * @return {@code true}, if the list has been modified; otherwise,
     * {@code false}
     */
    private boolean isModified() {
        return modified;
    }

    /**
     * Sets whether the target list has been modified.
     * 
     * @param modified {@code true}, if the list has been modified; otherwise,
     * {@code false}
     */
    private void setModified(boolean modified) {
        this.modified = modified;
    }

    /**
     * Handles changes to properties in the aperture panel.
     * 
     * @author Bill Wohler
     */
    private class AperturePropertyChangeListener implements
        PropertyChangeListener {

        @Override
        public void propertyChange(PropertyChangeEvent e) {
            log.debug(e);
            Object source = e.getSource();
            String property = e.getPropertyName();

            if (source != editAperturePanel) {
                return;
            }

            if (property.equals(ApertureEditor.MOUSE_OFFSET_PROPERTY)) {
                Point point = (Point) e.getNewValue();
                mouseOffsetRow.setText(Integer.toString(point.y));
                mouseOffsetColumn.setText(Integer.toString(point.x));
            } else if (property.equals(ApertureEditor.ORIGIN_PROPERTY)) {
                moveApertureReference.setSelected(false);
                setDirty(true);
            } else if (property.equals(ApertureEditor.OFFSETS_PROPERTY)) {
                setDirty(true);
            }
        }
    }

    /**
     * Handles changes to the move aperture reference field.
     * 
     * @author Bill Wohler
     */
    private class MoveApertureReferenceListener implements ItemListener {
        @Override
        public void itemStateChanged(ItemEvent e) {
            Object source = e.getItemSelectable();
            int change = e.getStateChange();
            if (source == moveApertureReference) {
                editAperturePanel.setMoveOrigin(change == ItemEvent.SELECTED);
            }
        }
    }

    /**
     * A model for the list of targets. Includes the the list's
     * {@link ListSelectionListener}.
     * 
     * @author Bill Wohler
     */
    private class TargetListModel extends AbstractListModel implements
        ListSelectionListener {

        private List<PlannedTarget> targets;

        public TargetListModel(List<PlannedTarget> targets) {
            this.targets = targets;
        }

        @Override
        public Object getElementAt(int index) {
            return targets.get(index);
        }

        @Override
        public int getSize() {
            return targets.size();
        }

        public void add(PlannedTarget target) {
            targets.add(target);
            int row = targets.size() - 1;
            fireIntervalAdded(this, row, row);
        }

        public void remove(PlannedTarget target) {
            int row = targets.indexOf(target);
            targets.remove(row);
            fireIntervalRemoved(this, row, row);
        }

        @Override
        public void valueChanged(ListSelectionEvent e) {
            if (e.getValueIsAdjusting()) {
                return;
            }

            int selectedIndex = targetsList.getSelectedIndex();
            if (selectedIndex >= 0) {
                selectedTarget = targets.get(selectedIndex);
                updateFields();
            } else {
                selectedTarget = null;
            }
        }
    }

    /**
     * A cell renderer for the list of targets.
     * 
     * @author Bill Wohler
     */
    private class TargetListCellRenderer extends
        DefaultListCellRenderer.UIResource {

        private static final String NAME = "TargetListCellRenderer";

        private Border border;

        public TargetListCellRenderer() {
            setHorizontalAlignment(TRAILING);
            border = BorderFactory.createEmptyBorder(0, 6, 0, 6);
        }

        @Override
        public Component getListCellRendererComponent(JList list, Object value,
            int index, boolean isSelected, boolean cellHasFocus) {

            // Display either the Kepler ID or a default string.
            JLabel c = (JLabel) super.getListCellRendererComponent(list, value,
                index, isSelected, cellHasFocus);
            PlannedTarget target = (PlannedTarget) value;
            if (target.getKeplerId() >= 0) {
                c.setText(Integer.toString(target.getKeplerId()));
            } else {
                c.setText(resourceMap.getString(NAME + ".noLabel"));
            }

            c.setBorder(border);

            return c;
        }
    }

    /**
     * A task for looking up the next available {@link CustomTarget} ID, or
     * creating or updating and saving a {@link CustomTarget}. Use the default
     * constructor to get the former functionality and the
     * {@code CustomTargetLookupTask(int, int)} constructor in the latter case.
     * 
     * @author Bill Wohler
     */
    private class CustomTargetLookupTask extends DatabaseTask<Integer, Void> {

        private int keplerId;
        private int skyGroupId;

        public CustomTargetLookupTask() {
            this(TargetManagementConstants.INVALID_KEPLER_ID,
                TargetManagementConstants.INVALID_SKY_GROUP_ID);
        }

        public CustomTargetLookupTask(int keplerId, int skyGroupId) {
            this.keplerId = keplerId;
            this.skyGroupId = skyGroupId;
        }

        @Override
        protected Integer doInBackground() throws Exception {
            CustomTargetCrudProxy customTargetCrud = new CustomTargetCrudProxy();

            int id = -1;

            if (keplerId == TargetManagementConstants.INVALID_KEPLER_ID) {
                id = customTargetCrud.retrieveNextCustomTargetKeplerId();
                log.info(resourceMap.getString(CREATE + ".created", id));
            } else {
                CustomTarget customTarget = customTargetCrud.retrieveCustomTarget(keplerId);
                if (customTarget == null) {
                    customTarget = new CustomTarget(keplerId, skyGroupId);
                    log.info(resourceMap.getString(CREATE + ".updated",
                        keplerId));
                    customTargetCrud.create(customTarget);
                } else if (customTarget.getSkyGroupId() != skyGroupId) {
                    log.info(resourceMap.getString(CREATE + ".updated",
                        keplerId));
                    customTarget.setSkyGroupId(skyGroupId);
                    customTargetCrud.create(customTarget);
                }
            }

            return id;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetEditor.this, e, CREATE);
        }

        @Override
        protected void succeeded(Integer id) {
            // Only update fields if we created a new ID.
            if (id >= 0) {
                targetId.setText(Integer.toString(id));
            }
        }
    }

    /**
     * A task for looking up and updating fields related to a
     * {@link CelestialObject}.
     * 
     * @author Bill Wohler
     */
    private class KicLookupTask extends DatabaseTask<Integer, Void> {

        private int keplerId;

        public KicLookupTask(int keplerId) {
            this.keplerId = keplerId;

            // In the meantime...
            setDirtyDocumentListeners(false);
            skyGroup.setText(resourceMap.getString("loading"));
            setDirtyDocumentListeners(true);
        }

        @Override
        protected Integer doInBackground() throws Exception {
            CelestialObject celestialObject = celestialObjectOperations.retrieveCelestialObject(keplerId);
            if (celestialObject == null) {
                return null;
            }
            int skyGroupId = celestialObject.getSkyGroupId();

            return skyGroupId;
        }

        @Override
        protected void handleFatalError(Throwable e) {
            handleError(TargetEditor.this, e, LOOK_UP, keplerId);
        }

        @Override
        protected void succeeded(Integer skyGroupId) {
            setDirtyDocumentListeners(false);
            if (skyGroupId == null) {
                handleError(TargetEditor.this, null, LOOK_UP + ".notFound",
                    keplerId);
                skyGroup.setText("");
            } else {
                skyGroup.setText(skyGroupId != TargetManagementConstants.INVALID_SKY_GROUP_ID ? skyGroupId.toString()
                    : NO_DATA);
                updateEnabled();
            }
            setDirtyDocumentListeners(true);
        }
    }

    /**
     * A model for the list of labels.
     * 
     * @author Bill Wohler
     */
    private class LabelListModel extends AbstractListModel implements
        ListSelectionListener {

        private List<String> labels = new ArrayList<String>();

        @Override
        public Object getElementAt(int index) {
            return labels.get(index);
        }

        public void setElementAt(int index, Object element) {
            labels.set(index, (String) element);
            fireContentsChanged(this, index, index);
        }

        public int indexOf(Object o) {
            return labels.indexOf(o);
        }

        @Override
        public int getSize() {
            return labels.size();
        }

        public Set<String> getLabels() {
            return new LinkedHashSet<String>(labels);
        }

        public void clear() {
            labels.clear();
            fireContentsChanged(this, 0, 0);
        }

        // SOC_REQ_IMPL 926.CM.7
        public void add(String label) {
            // Avoid duplicates.
            if (!labels.contains(label)) {
                labels.add(label);
                int row = labels.size() - 1;
                fireIntervalAdded(this, row, row);
            }
        }

        public void addAll(Collection<String> newLabels) {
            int begin = Math.max(labels.size() - 1, 0);
            for (String label : newLabels) {
                // Avoid duplicates.
                if (!labels.contains(label)) {
                    labels.add(label);
                }
            }
            int end = Math.max(labels.size() - 1, 0);
            fireIntervalAdded(this, begin, end);
        }

        public void remove(String label) {
            int row = labels.indexOf(label);
            labels.remove(row);
            fireIntervalRemoved(this, row, row);
        }

        @Override
        public void valueChanged(ListSelectionEvent e) {
            if (e.getValueIsAdjusting()) {
                return;
            }

            ListSelectionModel lsm = (ListSelectionModel) e.getSource();
            int selectedIndex = lsm.getLeadSelectionIndex();
            if (selectedIndex < labels.size()) {
                labelEditor.getModel()
                    .setSelectedItem(labelListModel.getElementAt(selectedIndex));
            }

            updateEnabled();
        }
    }

    /**
     * A cell renderer for the list of labels. This just adds a little padding
     * on the left and right side.
     * 
     * @author Bill Wohler
     */
    private static class LabelListCellRenderer extends
        DefaultListCellRenderer.UIResource {

        private Border border;

        public LabelListCellRenderer() {
            border = BorderFactory.createEmptyBorder(0, 6, 0, 6);
        }

        @Override
        public Component getListCellRendererComponent(JList list, Object value,
            int index, boolean isSelected, boolean cellHasFocus) {

            JLabel c = (JLabel) super.getListCellRendererComponent(list, value,
                index, isSelected, cellHasFocus);
            c.setBorder(border);

            return c;
        }
    }

    /**
     * A model for the label editor, a combo box.
     * 
     * @author Bill Wohler
     */
    private class LabelEditorModel extends AbstractListModel implements
        ComboBoxModel {

        private List<String> items = new ArrayList<String>();
        private String selectedItem;

        // SOC_REQ_IMPL 926.CM.6
        public LabelEditorModel() {
            items.add(resourceMap.getString(ADD_LABEL + ".new"));
            for (TargetLabel label : TargetLabel.values()) {
                items.add(label.toString());
            }
            setSelectedItem(items.get(0));
        }

        @Override
        public Object getSelectedItem() {
            return selectedItem;
        }

        @Override
        public void setSelectedItem(Object item) {
            selectedItem = (String) item;
            int index = items.indexOf(item);
            fireContentsChanged(this, index, index);
        }

        @Override
        public Object getElementAt(int index) {
            return items.get(index);
        }

        @Override
        public int getSize() {
            return items.size();
        }
    }
}
