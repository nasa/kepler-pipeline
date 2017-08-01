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

package gov.nasa.kepler.ui.ops.parameters;

import gov.nasa.kepler.hibernate.pi.ClassWrapper;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetName;
import gov.nasa.kepler.ui.ons.etable.EShadedTable;
import gov.nasa.kepler.ui.ons.etable.ETable;
import gov.nasa.kepler.ui.proxy.ParameterSetCrudProxy;
import gov.nasa.kepler.ui.proxy.PipelineOperationsProxy;
import gov.nasa.spiffy.common.pi.Parameters;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.swing.JButton;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Edit/view all of the {@link ParameterSet}s for a pipeline or node
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ParameterSetMapEditorPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(ParameterSetMapEditorPanel.class);

    private ParameterSetMapEditorListener mapListener;
    private JButton autoAssignButton;
    private JMenuItem removeMenuItem;
    private JMenuItem editMenuItem;
    private JMenuItem selectMenuItem;
    private JPopupMenu tablePopupMenu;
    private JButton selectParamSetButton;
    private JButton addButton;
    private JButton editParamValuesButton;
    private JPanel buttonPanel;
    private ETable paramSetMapTable;
    private JScrollPane tableScrollPane1;
    private JPanel tablePanel;
    private int selectedModelIndex = -1;

    private Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters = null;
    private Set<ClassWrapper<Parameters>> requiredParameters = null;
    private Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters = null;

    private ParameterSetNamesTableModel paramSetMapTableModel;

    /* For Jigloo use only */
    public ParameterSetMapEditorPanel() {
        initGUI();
    }

    public ParameterSetMapEditorPanel(Map<ClassWrapper<Parameters>, ParameterSetName> currentParameters,
        Set<ClassWrapper<Parameters>> requiredParameters,
        Map<ClassWrapper<Parameters>, ParameterSetName> currentPipelineParameters) {

        this.currentParameters = currentParameters;
        this.requiredParameters = requiredParameters;
        this.currentPipelineParameters = currentPipelineParameters;

        initGUI();
    }

    private void initGUI() {
        try {
            GridBagLayout thisLayout = new GridBagLayout();
            setPreferredSize(new Dimension(400, 300));
            thisLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            thisLayout.rowHeights = new int[] { 7, 7, 7, 7, 7, 7 };
            thisLayout.columnWeights = new double[] { 0.1 };
            thisLayout.columnWidths = new int[] { 7 };
            this.setLayout(thisLayout);
            this.add(getTablePanel(), new GridBagConstraints(0, 0, 1, 4, 0.0, 1.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
            this.add(getButtonPanel(), new GridBagConstraints(0, 4, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.BOTH, new Insets(0, 0, 0, 0), 0, 0));
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private void addButtonActionPerformed(ActionEvent evt) {
        log.debug("addButton.actionPerformed, event=" + evt);

        ParameterSet newParameterSet = ParameterSetSelectorDialog.selectParameterSet();

        if (newParameterSet != null) {
            @SuppressWarnings("unchecked")
            Class<? extends Parameters> clazz = (Class<? extends Parameters>) newParameterSet.getParameters()
                .getClazz();

            ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(clazz);

            if (currentParameters.containsKey(classWrapper)) {
                JOptionPane.showMessageDialog(this, "A parameter set for " + clazz.getSimpleName()
                    + " already exists, use 'select' to change the existing instance", "Error",
                    JOptionPane.ERROR_MESSAGE);
            } else {
                currentParameters.put(classWrapper, newParameterSet.getName());

                if (mapListener != null) {
                    mapListener.notifyMapChanged(this);
                }

                paramSetMapTableModel.update(currentParameters, requiredParameters, currentPipelineParameters);
            }
        }
    }

    private void selectMenuItemActionPerformed(ActionEvent evt) {
        log.debug("selectMenuItem.actionPerformed, event="+evt);
        
        doSelect(selectedModelIndex);
    }
    
    private void selectParamSetButtonActionPerformed(ActionEvent evt) {
        log.debug("selectParamSetButton.actionPerformed, event=" + evt);

        int selectedRow = paramSetMapTable.getSelectedRow();

        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this, "No parameter set selected", "Error", JOptionPane.ERROR_MESSAGE);
        } else {
            int modelIndex = paramSetMapTable.convertRowIndexToModel(selectedRow);
            doSelect(modelIndex);
        }
    }

    /**
     * @param selectedRow
     */
    private void doSelect(int modelIndex) {
        ParameterSetAssignment paramSetAssignment = paramSetMapTableModel.getParamAssignmentAtRow(modelIndex);

        if (paramSetAssignment.isAssignedAtPipelineLevel()) {
            JOptionPane.showMessageDialog(this,
                "Already assigned at the pipeline level.  Remove that assignment first.", "Error",
                JOptionPane.ERROR_MESSAGE);
            return;
        }

        ClassWrapper<Parameters> type = paramSetAssignment.getType();
        boolean isDeleted = false;
        
        try{
            type.getClazz();
        }catch(Exception e){
            isDeleted = true;
        }
        
        if(!isDeleted){
            Class<? extends Parameters> currentType = (Class<? extends Parameters>) type
                .getClazz();
            ParameterSet newParameterSet = ParameterSetSelectorDialog.selectParameterSet(currentType);

            if (newParameterSet != null) {
                ParameterSetName previouslyAssignedName = paramSetAssignment.getAssignedName();
                if (previouslyAssignedName == null || (previouslyAssignedName != null && !newParameterSet.getName()
                    .equals(previouslyAssignedName))) {
                    // changed, store the change
                    ClassWrapper<Parameters> classWrapper = new ClassWrapper<Parameters>(currentType);
                    currentParameters.put(classWrapper, newParameterSet.getName());

                    if (mapListener != null) {
                        mapListener.notifyMapChanged(this);
                    }

                    paramSetMapTableModel.update(currentParameters, requiredParameters, currentPipelineParameters);
                }
            }
        }else{
            JOptionPane.showMessageDialog(this, "Can't select a parameter set whose class has been deleted.", 
                "Error", JOptionPane.ERROR_MESSAGE);
        }
    }

    private void editMenuItemActionPerformed(ActionEvent evt) {
        log.debug("editMenuItem.actionPerformed, event="+evt);

        doEdit(selectedModelIndex);
    }
    
    private void editParamValuesButtonActionPerformed(ActionEvent evt) {
        log.debug("editParamValuesButton.actionPerformed, event=" + evt);

        int selectedRow = paramSetMapTable.getSelectedRow();

        if (selectedRow == -1) {
            JOptionPane.showMessageDialog(this, "No parameter set selected", "Error", JOptionPane.ERROR_MESSAGE);
        } else {
            int modelIndex = paramSetMapTable.convertRowIndexToModel(selectedRow);
            doEdit(modelIndex);
        }
    }

    /**
     * @param modelIndex
     */
    private void doEdit(int modelIndex) {
        ParameterSetName paramSetName = paramSetMapTableModel.getParamSetAtRow(modelIndex);

        if(paramSetName != null){
            PipelineOperationsProxy pipelineOps = new PipelineOperationsProxy();

            ParameterSet latestParameterSet = pipelineOps.retrieveLatestParameterSet(paramSetName);

            if(!latestParameterSet.parametersClassDeleted()){
                Parameters newParameters = EditParametersDialog.editParameters(latestParameterSet);

                if (newParameters != null) {
                    pipelineOps.updateParameterSet(latestParameterSet, newParameters, latestParameterSet.getDescription(), false);
                }
            }else{
                JOptionPane.showMessageDialog(this, "Can't edit a parameter set whose class has been deleted.", "Error", JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    
    private void removeMenuItemActionPerformed(ActionEvent evt) {
        log.debug("removeMenuItem.actionPerformed, event="+evt);
        
        ClassWrapper<Parameters> type = paramSetMapTableModel.getParamAssignmentAtRow(selectedModelIndex).getType();
        currentParameters.remove(type);

        if (mapListener != null) {
            mapListener.notifyMapChanged(this);
        }

        paramSetMapTableModel.update(currentParameters, requiredParameters, currentPipelineParameters);
        
    }
    
    private void autoAssignButtonActionPerformed(ActionEvent evt) {
        log.debug("autoAssignButton.actionPerformed, event="+evt);
        
        ParameterSetCrudProxy crud = new ParameterSetCrudProxy();
        List<ParameterSet> allParamSets = crud.retrieveLatestVersions();
        LinkedList<ParameterSetAssignment> currentAssignments = paramSetMapTableModel.getParamSetAssignments();
        boolean changesMade = false;
        
        for (ParameterSetAssignment assignment : currentAssignments) {
            if(assignment.getAssignedName() == null){
                ClassWrapper<Parameters> type = assignment.getType();
                ParameterSet instance = null;
                int foundCount = 0;
                
                for (ParameterSet parameterSet : allParamSets) {
                    Class<?> clazz = null;
                    
                    try {
                        clazz = parameterSet.getParameters().getClazz();
                    } catch (RuntimeException e) {
                        // ignore this parameter set
                    }

                    if(clazz != null && parameterSet.getParameters().getClazz().equals(type.getClazz())){
                        instance = parameterSet;
                        foundCount++;
                    }
                }
                
                if(foundCount == 1){
                    log.info("Found a match: " + instance.getName() + " for type: " + type);
                    currentParameters.put(type, instance.getName());
                    changesMade = true;
                }
            }
        }

        if(changesMade){
            if (mapListener != null) {
                mapListener.notifyMapChanged(this);
            }

            paramSetMapTableModel.update(currentParameters, requiredParameters, currentPipelineParameters);
        }
    }

    public ParameterSetMapEditorListener getMapListener() {
        return mapListener;
    }

    public void setMapListener(ParameterSetMapEditorListener mapListener) {
        this.mapListener = mapListener;
    }

    public Map<ClassWrapper<Parameters>, ParameterSetName> getParameterSetsMap() {
        return currentParameters;
    }

    private JPanel getTablePanel() {
        if (tablePanel == null) {
            tablePanel = new JPanel();
            BorderLayout tablePanelLayout = new BorderLayout();
            tablePanel.setLayout(tablePanelLayout);
            tablePanel.add(getTableScrollPane1(), BorderLayout.CENTER);
        }
        return tablePanel;
    }

    private JScrollPane getTableScrollPane1() {
        if (tableScrollPane1 == null) {
            tableScrollPane1 = new JScrollPane();
            tableScrollPane1.setViewportView(getParamSetMapTable());
        }
        return tableScrollPane1;
    }

    private ETable getParamSetMapTable() {
        if (paramSetMapTable == null) {
            paramSetMapTableModel = new ParameterSetNamesTableModel(currentParameters, requiredParameters,
                currentPipelineParameters);
            paramSetMapTable = new EShadedTable();
            paramSetMapTable.setModel(paramSetMapTableModel);
            paramSetMapTable.addMouseListener(new MouseAdapter() {
                public void mouseClicked(MouseEvent evt) {
                    tableMouseClicked(evt);
                }
            });
            setComponentPopupMenu(paramSetMapTable, getTablePopupMenu());
        }
        return paramSetMapTable;
    }

    private JPanel getButtonPanel() {
        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(20);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getAddButton());
            buttonPanel.add(getSelectParamSetButton());
            buttonPanel.add(getEditParamValuesButton());
            buttonPanel.add(getAutoAssignButton());
        }
        return buttonPanel;
    }

    private JButton getSelectParamSetButton() {
        if (selectParamSetButton == null) {
            selectParamSetButton = new JButton();
            selectParamSetButton.setText("select");
            selectParamSetButton.setToolTipText("Select a different parameter set instance for this type");
            selectParamSetButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    selectParamSetButtonActionPerformed(evt);
                }
            });
        }
        return selectParamSetButton;
    }

    private JButton getEditParamValuesButton() {
        if (editParamValuesButton == null) {
            editParamValuesButton = new JButton();
            editParamValuesButton.setText("edit values");
            editParamValuesButton.setToolTipText("Shortcut to edit the values in this parameter set instance (same as editing the set in the Parameter Library)");
            editParamValuesButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    editParamValuesButtonActionPerformed(evt);
                }
            });
        }
        return editParamValuesButton;
    }

    private JButton getAddButton() {
        if (addButton == null) {
            addButton = new JButton();
            addButton.setText("add");
            addButton.setToolTipText("Add a new parameter set");
            addButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    addButtonActionPerformed(evt);
                }
            });
        }
        return addButton;
    }
    
    private JPopupMenu getTablePopupMenu() {
        if(tablePopupMenu == null) {
            tablePopupMenu = new JPopupMenu();
            tablePopupMenu.add(getSelectMenuItem());
            tablePopupMenu.add(getEditMenuItem());
            tablePopupMenu.add(getRemoveMenuItem());
        }
        return tablePopupMenu;
    }
    
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                if(e.isPopupTrigger()){
                    menu.show(parent, e.getX(), e.getY());
                    int tableRow = paramSetMapTable.rowAtPoint(e.getPoint());
                    // windows bug? works ok on Linux/gtk. Here's a workaround:
                    if (tableRow == -1) {
                        tableRow = paramSetMapTable.getSelectedRow();
                    }
                    selectedModelIndex = paramSetMapTable.convertRowIndexToModel(tableRow);
                }
            }
            public void mouseReleased(java.awt.event.MouseEvent e) {
                if(e.isPopupTrigger()){
                    menu.show(parent, e.getX(), e.getY());
                }
            }
        });
    }
    
    private void tableMouseClicked(MouseEvent evt) {
        log.debug("tableMouseClicked(MouseEvent) - start");

        if (evt.getClickCount() == 2) {
            log.debug("tableMouseClicked(MouseEvent) - [DOUBLE-CLICK] table.mouseClicked, event=" + evt);
            int tableRow = paramSetMapTable.rowAtPoint(evt.getPoint());
            selectedModelIndex = paramSetMapTable.convertRowIndexToModel(tableRow);
            log.debug("tableMouseClicked(MouseEvent) - [DC] table row =" + selectedModelIndex);

            doEdit(selectedModelIndex);
        }

        log.debug("tableMouseClicked(MouseEvent) - end");
    }

    private JMenuItem getSelectMenuItem() {
        if(selectMenuItem == null) {
            selectMenuItem = new JMenuItem();
            selectMenuItem.setText("Select Parameter Set...");
            selectMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    selectMenuItemActionPerformed(evt);
                }
            });
        }
        return selectMenuItem;
    }
    
    private JMenuItem getEditMenuItem() {
        if(editMenuItem == null) {
            editMenuItem = new JMenuItem();
            editMenuItem.setText("Edit Parameter Values...");
            editMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    editMenuItemActionPerformed(evt);
                }
            });
        }
        return editMenuItem;
    }
    
    private JMenuItem getRemoveMenuItem() {
        if(removeMenuItem == null) {
            removeMenuItem = new JMenuItem();
            removeMenuItem.setText("Remove Parameter Set");
            removeMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    removeMenuItemActionPerformed(evt);
                }
            });
        }
        return removeMenuItem;
    }
    
    private JButton getAutoAssignButton() {
        if(autoAssignButton == null) {
            autoAssignButton = new JButton();
            autoAssignButton.setText("auto-assign");
            autoAssignButton.setToolTipText("Automatically assign a parameter set if there is only one available");
            autoAssignButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    autoAssignButtonActionPerformed(evt);
                }
            });
        }
        return autoAssignButton;
    }
}
