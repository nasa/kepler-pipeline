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

package gov.nasa.kepler.common.ui;
import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.Window;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JFileChooser;
import javax.swing.JFrame;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTable;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Dialog for editing the contents of a Java array
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class ArrayEditorDialog extends javax.swing.JDialog {
    private static final Log log = LogFactory.getLog(ArrayEditorDialog.class);
    
    private JPanel dataPanel;
    private JButton removeButton;
    private JButton addButton;
    private JTable elementsTable;
    private JScrollPane scrollPane;
    private JButton cancelButton;
    private JButton okButton;
    private JPanel actionPanel;

    private boolean isCancelled = false;
    private JButton exportButton;
    private JButton importButton;
    private JTextField addTextField;
    private JPanel addPanel;

    private ArrayEditorTableModel arrayEditorTableModel;

    private Object array;

    public ArrayEditorDialog(JFrame frame) {
        super(frame);
        initGUI();
    }
    
    public ArrayEditorDialog(JFrame owner, Object array) {
        super(owner, true);
        init(array);
    }

    public ArrayEditorDialog(JDialog owner, Object array) {
        super(owner, true);
        init(array);
    }

    private void init(Object array) {
        this.array = array;

        initGUI();

        elementsTable.getColumnModel().getColumn(0).setPreferredWidth(10);
        elementsTable.getColumnModel().getColumn(1).setPreferredWidth(300);
    }

    private void addButtonActionPerformed(ActionEvent evt) {
        log.debug("addButton.actionPerformed, event="+evt);

        addElement();
    }
    
    
    private void addTextFieldActionPerformed(ActionEvent evt) {
        log.debug("addTextField.actionPerformed, event="+evt);

        addElement();
    }

    private void addElement(){
        int selectedIndex = elementsTable.getSelectedRow();

        if(selectedIndex == -1){
            arrayEditorTableModel.insertElementAtEnd(addTextField.getText());
        }else{
            arrayEditorTableModel.insertElementAt(selectedIndex, addTextField.getText());
            elementsTable.getSelectionModel().setSelectionInterval(selectedIndex+1, selectedIndex+1);
        }
        
        addTextField.setText("");
    }
    
    private void removeButtonActionPerformed(ActionEvent evt) {
        log.debug("removeButton.actionPerformed, event="+evt);

        int selectedIndex = elementsTable.getSelectedRow();
        
        if(selectedIndex != -1){
            arrayEditorTableModel.removeElementAt(selectedIndex);
            
            int newSize = arrayEditorTableModel.getRowCount();
            if(selectedIndex < newSize){
                elementsTable.getSelectionModel().setSelectionInterval(selectedIndex, selectedIndex);
            }
        }
    }
    
    private void importButtonActionPerformed(ActionEvent evt) {
        log.debug("importButton.actionPerformed, event="+evt);
        
        try {
            JFileChooser fc = new JFileChooser();
            int returnVal = fc.showOpenDialog(this);

            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();

                List<String> newArray = ArrayImportExportUtils.importArray(file);
                arrayEditorTableModel.replaceWith(newArray);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
        
    }
    
    private void exportButtonActionPerformed(ActionEvent evt) {
        log.debug("exportButton.actionPerformed, event="+evt);
        
        try {
            JFileChooser fc = new JFileChooser();
            int returnVal = fc.showSaveDialog(this);

            if (returnVal == JFileChooser.APPROVE_OPTION) {
                File file = fc.getSelectedFile();
                
                List<String> values = arrayEditorTableModel.asStringList();
                ArrayImportExportUtils.exportArray(file, values);
            }
        } catch (Exception e) {
            log.warn("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
        }
        
    }

    private void okButtonActionPerformed(ActionEvent evt) {
        log.debug("okButton.actionPerformed, event="+evt);

        setVisible(false);
    }
    
    private void cancelButtonActionPerformed(ActionEvent evt) {
        log.debug("cancelButton.actionPerformed, event="+evt);

        isCancelled = true;
        setVisible(false);
    }

    public static Object showDialog(Component owner, String title, Object array) {

        Window ownerWindow = findParentWindow(owner);

        ArrayEditorDialog editor;
        if (ownerWindow instanceof JFrame) {
            editor = new ArrayEditorDialog((JFrame) ownerWindow, array);
        } else {
            editor = new ArrayEditorDialog((JDialog) ownerWindow, array);
        }

        editor.setLocationRelativeTo(owner);
        editor.setVisible(true);
        
        if(!editor.isCancelled){
            return editor.editedArray();
        }else{
            return null;
        }
    }

    public Object editedArray(){
        return arrayEditorTableModel.asArray();
    }
    
    private static Window findParentWindow(Component c) {
        Component root = c;

        while (!(root instanceof JFrame) && !(root instanceof JDialog)) {
            root = root.getParent();
            if (root == null) {
                return null;
            }
        }
        return (Window) root;
    }

    private void initGUI() {
        try {
            setTitle("Array Editor");
            this.setPreferredSize(new java.awt.Dimension(491, 762));
            getContentPane().add(getDataPanel(), BorderLayout.CENTER);
            getContentPane().add(getActionPanel(), BorderLayout.SOUTH);
            this.setSize(491, 762);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private JPanel getDataPanel() {
        if(dataPanel == null) {
            dataPanel = new JPanel();
            BorderLayout dataPanelLayout = new BorderLayout();
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getScrollPane(), BorderLayout.CENTER);
            dataPanel.add(getAddPanel(), BorderLayout.SOUTH);
        }
        return dataPanel;
    }
    
    private JPanel getActionPanel() {
        if(actionPanel == null) {
            actionPanel = new JPanel();
            FlowLayout actionPanelLayout = new FlowLayout();
            actionPanelLayout.setHgap(50);
            actionPanel.setLayout(actionPanelLayout);
            actionPanel.add(getOkButton());
            actionPanel.add(getCancelButton());
        }
        return actionPanel;
    }
    
    private JButton getOkButton() {
        if(okButton == null) {
            okButton = new JButton();
            okButton.setText("ok");
            okButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    okButtonActionPerformed(evt);
                }
            });
        }
        return okButton;
    }
    
    private JButton getCancelButton() {
        if(cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }
    
    private JScrollPane getScrollPane() {
        if(scrollPane == null) {
            scrollPane = new JScrollPane();
            scrollPane.setViewportView(getElementsTable());
        }
        return scrollPane;
    }
    
    private JTable getElementsTable() {
        if(elementsTable == null) {
            elementsTable = new JTable();
            elementsTable.setDefaultRenderer(Float.class, new FloatingPointTableCellRenderer());
            elementsTable.setDefaultRenderer(Double.class, new FloatingPointTableCellRenderer());
            arrayEditorTableModel = new ArrayEditorTableModel(array);
            elementsTable.setModel(arrayEditorTableModel);
        }
        return elementsTable;
    }

    private JButton getAddButton() {
        if(addButton == null) {
            addButton = new JButton();
            addButton.setText("+");
            addButton.setToolTipText("Insert the specified element before the selected row (or at the end if no row is selected)");
            addButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    addButtonActionPerformed(evt);
                }
            });
        }
        return addButton;
    }
    
    private JButton getRemoveButton() {
        if(removeButton == null) {
            removeButton = new JButton();
            removeButton.setText("-");
            removeButton.setToolTipText("Remove the element at the selected row");
            removeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    removeButtonActionPerformed(evt);
                }
            });
        }
        return removeButton;
    }
    
    /**
     * Auto-generated main method to display this JDialog
     */
     public static void main(String[] args) {
         SwingUtilities.invokeLater(new Runnable() {
             public void run() {
                 JFrame frame = new JFrame();
                 ArrayEditorDialog inst = new ArrayEditorDialog(frame);
                 inst.setVisible(true);
             }
         });
     }
    
    private JPanel getAddPanel() {
        if(addPanel == null) {
            addPanel = new JPanel();
            GridBagLayout addPanelLayout = new GridBagLayout();
            addPanel.setBorder(BorderFactory.createTitledBorder("add/remove elements"));
            addPanelLayout.rowWeights = new double[] {0.1};
            addPanelLayout.rowHeights = new int[] {7};
            addPanelLayout.columnWeights = new double[] {1.0, 0.1, 0.1};
            addPanelLayout.columnWidths = new int[] {7, 7, 7};
            addPanel.setLayout(addPanelLayout);
            addPanel.add(getAddTextField(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.HORIZONTAL, new Insets(0, 0, 0, 0), 0, 0));
            addPanel.add(getAddButton(), new GridBagConstraints(1, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            addPanel.add(getRemoveButton(), new GridBagConstraints(2, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            addPanel.add(getImportButton(), new GridBagConstraints(3, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            addPanel.add(getExportButton(), new GridBagConstraints(4, 0, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return addPanel;
    }
    
    private JTextField getAddTextField() {
        if(addTextField == null) {
            addTextField = new JTextField();
            addTextField.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    addTextFieldActionPerformed(evt);
                }
            });
        }
        return addTextField;
    }
    
    private JButton getImportButton() {
        if(importButton == null) {
            importButton = new JButton();
            importButton.setText("import");
            importButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    importButtonActionPerformed(evt);
                }
            });
        }
        return importButton;
    }
    
    private JButton getExportButton() {
        if(exportButton == null) {
            exportButton = new JButton();
            exportButton.setText("export");
            exportButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    exportButtonActionPerformed(evt);
                }
            });
        }
        return exportButton;
    }
}
