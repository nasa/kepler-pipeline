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

import java.awt.*;

import javax.swing.*;
import javax.swing.event.ListSelectionListener;

/**
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("serial")
class ListEditorDialog extends JDialog {
    private JList jList;
    
    /**
     * 
     */
    public ListEditorDialog() {
        initUi();
    }

    /**
     * @param owner
     */
    public ListEditorDialog(Frame owner) {
        super(owner);
        initUi();
    }

    /**
     * @param owner
     */
    public ListEditorDialog(Dialog owner) {
        super(owner);
        initUi();
    }

    /**
     * @param owner
     */
    public ListEditorDialog(Window owner) {
        super(owner);
        initUi();
    }

    /**
     * @param owner
     * @param modal
     */
    public ListEditorDialog(Frame owner, boolean modal) {
        super(owner, modal);
        initUi();
    }

    /**
     * @param owner
     * @param title
     */
    public ListEditorDialog(Frame owner, String title) {
        super(owner, title);
        initUi();
    }

    /**
     * @param owner
     * @param modal
     */
    public ListEditorDialog(Dialog owner, boolean modal) {
        super(owner, modal);
        initUi();
    }

    /**
     * @param owner
     * @param title
     */
    public ListEditorDialog(Dialog owner, String title) {
        super(owner, title);
        initUi();
    }

    /**
     * @param owner
     * @param modalityType
     */
    public ListEditorDialog(Window owner, ModalityType modalityType) {
        super(owner, modalityType);
        initUi();
    }

    /**
     * @param owner
     * @param title
     */
    public ListEditorDialog(Window owner, String title) {
        super(owner, title);
        initUi();
    }

    /**
     * @param owner
     * @param title
     * @param modal
     */
    public ListEditorDialog(Frame owner, String title, boolean modal) {
        super(owner, title, modal);
        initUi();
    }

    /**
     * @param owner
     * @param title
     * @param modal
     */
    public ListEditorDialog(Dialog owner, String title, boolean modal) {
        super(owner, title, modal);
        initUi();
    }

    /**
     * @param owner
     * @param title
     * @param modalityType
     */
    public ListEditorDialog(Window owner, String title,
        ModalityType modalityType) {
        super(owner, title, modalityType);
        initUi();
    }

    /**
     * @param owner
     * @param title
     * @param modal
     * @param gc
     */
    public ListEditorDialog(Frame owner, String title, boolean modal,
        GraphicsConfiguration gc) {
        super(owner, title, modal, gc);
        initUi();
    }

    /**
     * @param owner
     * @param title
     * @param modal
     * @param gc
     */
    public ListEditorDialog(Dialog owner, String title, boolean modal,
        GraphicsConfiguration gc) {
        super(owner, title, modal, gc);
        initUi();
    }

    /**
     * @param owner
     * @param title
     * @param modalityType
     * @param gc
     */
    public ListEditorDialog(Window owner, String title,
        ModalityType modalityType, GraphicsConfiguration gc) {
        super(owner, title, modalityType, gc);
        initUi();
    }
    
    private void initUi() {
        jList = new JList();
        jList.setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
        JScrollPane scrollPane = new JScrollPane(jList);
        add(scrollPane);
    }
    
    public void addListSelectionListener(ListSelectionListener listener) {
        jList.getSelectionModel().addListSelectionListener(listener);
    }
    
    public Object[] getSelectedValues() {
        return jList.getSelectedValues();
    }
    
    public void setSelectedIndices(int[] selectedIndices) {
        jList.setSelectedIndices(selectedIndices);
    }
    
    public void setAvailableValues(Object[] values) {
        DefaultListModel data = new DefaultListModel();
        for (Object value : values) {
            data.addElement(value);
        }
        jList.setModel(data);
    }

    public static ListEditorDialog newDialog(Component owner) {

        Window ownerWindow = SwingUtilities.windowForComponent(owner);

        ListEditorDialog dialog;
        if (ownerWindow instanceof JFrame) {
            dialog = new ListEditorDialog((JFrame) ownerWindow);
        } else {
            dialog = new ListEditorDialog((JDialog) ownerWindow);
        }
        dialog.setModalityType(ModalityType.APPLICATION_MODAL);
        return dialog;
        
    }
}
