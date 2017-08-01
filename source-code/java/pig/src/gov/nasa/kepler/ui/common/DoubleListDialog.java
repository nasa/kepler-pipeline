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

package gov.nasa.kepler.ui.common;

import java.awt.BorderLayout;
import java.awt.FlowLayout;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.LinkedList;
import java.util.List;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;

/**
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
@SuppressWarnings("serial")
public class DoubleListDialog<T> extends javax.swing.JDialog {
    private JPanel dataPanel;
    private JPanel buttonPanel;
    private JButton cancelButton;
    private JButton saveButton;

    private boolean savePressed = false;
    private JButton removeButton;
    private JLabel availListLabel;
    private JButton addButton;
    private JList selectedList;
    private JList availList;
    private JScrollPane selectedScrollPane;
    private JScrollPane availScrollPane;
    private JLabel selectedListLabel;
    private boolean cancelPressed = false;
    private String availableListTitle = "Available";
    private GenericListModel<T> availableListModel = new GenericListModel<T>();
    private String selectedListTitle = "Selected";
    private GenericListModel<T> selectedListModel = new GenericListModel<T>();

    public DoubleListDialog(JFrame frame) {
        super(frame, "Select", true);
        initGUI();
    }

    public DoubleListDialog(JFrame frame, String title, String availableListTitle, List<T> availableListContents,
        String selectedListTitle, List<T> selectedListContents) {
        super(frame, title, true);
        this.availableListTitle = availableListTitle;
        this.availableListModel = new GenericListModel<T>(availableListContents);
        this.selectedListTitle = selectedListTitle;
        this.selectedListModel = new GenericListModel<T>(selectedListContents);
        initGUI();
    }

    private void initGUI() {
        try {
            BorderLayout thisLayout = new BorderLayout();
            this.getContentPane()
                .setLayout(thisLayout);
            this.getContentPane()
                .add(getButtonPanel(), BorderLayout.SOUTH);
            this.getContentPane()
                .add(getDataPanel(), BorderLayout.CENTER);
            setSize(400, 300);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JPanel getDataPanel() {
        if (dataPanel == null) {
            dataPanel = new JPanel();
            GridBagLayout dataPanelLayout = new GridBagLayout();
            dataPanelLayout.columnWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanelLayout.columnWidths = new int[] { 7, 7, 7, 7, 7, 7, 7, 7, 7 };
            dataPanelLayout.rowWeights = new double[] { 0.1, 0.1, 0.1, 0.1, 0.1 };
            dataPanelLayout.rowHeights = new int[] { 7, 7, 7, 7, 7 };
            dataPanel.setLayout(dataPanelLayout);
            dataPanel.add(getAvailListLabel(), new GridBagConstraints(0, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getSelectedListLabel(), new GridBagConstraints(6, 0, 1, 1, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.NONE, new Insets(2, 2, 2, 2), 0, 0));
            dataPanel.add(getAvailScrollPane(), new GridBagConstraints(0, 1, 3, 3, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.BOTH, new Insets(2, 2, 2, 2), 0, 0));
            dataPanel.add(getSelectedScrollPane(), new GridBagConstraints(6, 1, 3, 3, 0.0, 0.0,
                GridBagConstraints.LINE_START, GridBagConstraints.BOTH, new Insets(2, 2, 2, 2), 0, 0));
            dataPanel.add(getAddButton(), new GridBagConstraints(4, 1, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
            dataPanel.add(getRemoveButton(), new GridBagConstraints(4, 3, 1, 1, 0.0, 0.0, GridBagConstraints.CENTER,
                GridBagConstraints.NONE, new Insets(0, 0, 0, 0), 0, 0));
        }
        return dataPanel;
    }

    /**
     * Auto-generated method for setting the popup menu for a component
     */
    @SuppressWarnings("unused")
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }
        });
    }

    private JPanel getButtonPanel() {
        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setHgap(40);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getSaveButton());
            buttonPanel.add(getCancelButton());
        }
        return buttonPanel;
    }

    private JButton getSaveButton() {
        if (saveButton == null) {
            saveButton = new JButton();
            saveButton.setText("Save Changes");
            saveButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    saveButtonActionPerformed(evt);
                }
            });
        }
        return saveButton;
    }

    private JButton getCancelButton() {
        if (cancelButton == null) {
            cancelButton = new JButton();
            cancelButton.setText("Cancel");
            cancelButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    cancelButtonActionPerformed(evt);
                }
            });
        }
        return cancelButton;
    }

    private void saveButtonActionPerformed(ActionEvent evt) {
        savePressed = true;
        setVisible(false);
    }

    private void cancelButtonActionPerformed(ActionEvent evt) {
        cancelPressed = true;
        setVisible(false);
    }

    /**
     * @return Returns the cancelPressed.
     */
    public boolean wasCancelPressed() {
        return cancelPressed;
    }

    /**
     * @return Returns the savePressed.
     */
    public boolean wasSavePressed() {
        return savePressed;
    }

    private JLabel getAvailListLabel() {
        if (availListLabel == null) {
            availListLabel = new JLabel();
            availListLabel.setText(availableListTitle);
        }
        return availListLabel;
    }

    private JLabel getSelectedListLabel() {
        if (selectedListLabel == null) {
            selectedListLabel = new JLabel();
            selectedListLabel.setText(selectedListTitle);
        }
        return selectedListLabel;
    }

    private JScrollPane getAvailScrollPane() {
        if (availScrollPane == null) {
            availScrollPane = new JScrollPane();
            availScrollPane.setViewportView(getAvailList());
        }
        return availScrollPane;
    }

    private JScrollPane getSelectedScrollPane() {
        if (selectedScrollPane == null) {
            selectedScrollPane = new JScrollPane();
            selectedScrollPane.setViewportView(getSelectedList());
        }
        return selectedScrollPane;
    }

    private JList getAvailList() {
        if (availList == null) {
            availList = new JList();
            availList.setModel(availableListModel);
        }
        return availList;
    }

    private JList getSelectedList() {
        if (selectedList == null) {
            selectedList = new JList();
            selectedList.setModel(selectedListModel);
        }
        return selectedList;
    }

    private JButton getAddButton() {
        if (addButton == null) {
            addButton = new JButton();
            addButton.setText("->");
            addButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    addButtonActionPerformed(evt);
                }
            });
        }
        return addButton;
    }

    private JButton getRemoveButton() {
        if (removeButton == null) {
            removeButton = new JButton();
            removeButton.setText("<-");
            removeButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    removeButtonActionPerformed(evt);
                }
            });
        }
        return removeButton;
    }

    private void addButtonActionPerformed(ActionEvent evt) {
        int availIndex = availList.getSelectedIndex();

        if (availIndex == -1) {
            return;
        }

        selectedListModel.add(availableListModel.remove(availIndex));
    }

    private void removeButtonActionPerformed(ActionEvent evt) {
        int selectedIndex = selectedList.getSelectedIndex();

        if (selectedIndex == -1) {
            return;
        }

        availableListModel.add(selectedListModel.remove(selectedIndex));
    }

    /**
     * @return Returns the availableListModel.
     */
    public List<T> getAvailableListContents() {
        return availableListModel.getList();
    }

    /**
     * @return Returns the selectedListModel.
     */
    public List<T> getSelectedListContents() {
        return selectedListModel.getList();
    }

    /**
     * Auto-generated main method to display this JDialog
     */
    public static void main(String[] args) {
        JFrame frame = new JFrame();
        List<String> a = new LinkedList<String>();
        a.add("A");
        a.add("B");
        a.add("C");
        List<String> s = new LinkedList<String>();

        DoubleListDialog<String> inst = new DoubleListDialog<String>(frame, "Select some letters", "Available letters", a,
            "Selected letters", s);
        inst.setVisible(true);
    }

}
