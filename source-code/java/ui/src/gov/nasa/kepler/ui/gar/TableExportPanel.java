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

import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.KeplerPanel;
import gov.nasa.kepler.ui.swing.PanelHeader;
import gov.nasa.kepler.ui.swing.ToolPanel;

import java.awt.CardLayout;
import java.awt.Component;
import java.util.Collections;
import java.util.List;

import javax.swing.BorderFactory;
import javax.swing.DefaultComboBoxModel;
import javax.swing.DefaultListCellRenderer;
import javax.swing.GroupLayout;
import javax.swing.JLabel;
import javax.swing.JList;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.ListModel;
import javax.swing.ListSelectionModel;
import javax.swing.border.Border;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import org.jdesktop.application.Action;

/**
 * Exports Huffman, requantizition, delta-quaternion, and target tables.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD_STORE")
public class TableExportPanel extends ToolPanel {
    public static final String NAME = "tableExportPanel";

    private PanelHeader panelHeader;
    private JList tableTypeList;
    private JScrollPane listScrollPane;
    private KeplerPanel[] panels;
    private JPanel cardPanel;
    private CardLayout cardLayout;

    private Helper helper = new HelperImpl();
    private ListSelectionListener tableTypeSelectionListener = new TableTypeSelectionListener();

    /**
     * Creates a {@link TableExportPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public TableExportPanel() throws UiException {
        setName(NAME);
        createUi();
    }

    @Override
    protected void initComponents() throws UiException {

        panelHeader = new PanelHeader();
        panelHeader.setName("header");

        tableTypeList = new JList();
        listScrollPane = new JScrollPane();
        listScrollPane.setViewportView(tableTypeList);

        cardPanel = new JPanel();
        cardLayout = new CardLayout();
        cardPanel.setLayout(cardLayout);

        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);
        layout.setAutoCreateContainerGaps(true);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addComponent(listScrollPane, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addComponent(cardPanel, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE));

        layout.setVerticalGroup(layout.createParallelGroup()
            .addComponent(listScrollPane, GroupLayout.Alignment.LEADING,
                GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE,
                Short.MAX_VALUE)
            .addComponent(cardPanel, GroupLayout.Alignment.LEADING,
                GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE,
                Short.MAX_VALUE));

        GroupLayout panelLayout = new GroupLayout(this);
        setLayout(panelLayout);

        panelLayout.setHorizontalGroup(panelLayout.createParallelGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
        panelLayout.setVerticalGroup(panelLayout.createSequentialGroup()
            .addComponent(panelHeader)
            .addComponent(panel));
    }

    @Override
    protected void configureComponents() throws UiException {
        panels = new KeplerPanel[] { new TadPanel(helper),
            new CompressionPanel(helper), new DeltaQuaternionPanel(helper) };
        ListModel tableTypeModel = new DefaultComboBoxModel(panels);
        tableTypeList.setModel(tableTypeModel);

        for (KeplerPanel element : panels) {
            cardPanel.add(element, element.toString());
        }

        tableTypeList.setCellRenderer(new TableTypeListCellRenderer());
        tableTypeList.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
        tableTypeList.getSelectionModel()
            .addListSelectionListener(tableTypeSelectionListener);
        tableTypeList.setSelectedIndex(0);
    }

    @Override
    protected void updateEnabled() {
    }

    @Override
    protected List<String> getActionStrings() {
        return Collections.emptyList();
    }

    /**
     * Generate table export menu.
     */
    @Action
    public void tableExport() {
        log.info("Shouldn't happen");
    }

    /**
     * Adds a little breathing room around text.
     * 
     * @author Bill Wohler
     */
    private static class TableTypeListCellRenderer extends
        DefaultListCellRenderer.UIResource {

        private Border border;

        public TableTypeListCellRenderer() {
            border = BorderFactory.createEmptyBorder(3, 6, 3, 6);
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
     * Listens for table type selection.
     * 
     * @author Bill Wohler
     */
    private class TableTypeSelectionListener implements ListSelectionListener {
        @Override
        public void valueChanged(ListSelectionEvent e) {
            if (e.getValueIsAdjusting()) {
                return;
            }

            ListSelectionModel lsm = (ListSelectionModel) e.getSource();
            int selectedIndex = lsm.getLeadSelectionIndex();
            log.info(resourceMap.getString("tableTypeList.show",
                panels[selectedIndex].toString()));
            cardLayout.show(cardPanel, panels[selectedIndex].toString());
            panelHeader.displayHelp(null); // clear help when switching
        }
    }

    /**
     * Hook for displaying contextual help in this panel.
     * 
     * @author Bill Wohler
     */
    private class HelperImpl implements Helper {
        @Override
        public void contextHelp(String helpText) {
            panelHeader.displayHelp(helpText);
        }
    }

    /**
     * Requests contextual help.
     * 
     * @author Bill Wohler
     */
    interface Helper {
        /**
         * Requests contextual help.
         * 
         * @param helpText the contextual help text
         */
        public void contextHelp(String helpText);
    }
}
