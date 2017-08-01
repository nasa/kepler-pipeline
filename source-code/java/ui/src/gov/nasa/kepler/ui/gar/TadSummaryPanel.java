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

import gov.nasa.kepler.hibernate.cm.TargetListSet;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.ToolPanel;
import gov.nasa.kepler.ui.swing.ToolTable;
import gov.nasa.spiffy.common.collect.Pair;

import java.awt.Dimension;
import java.awt.Font;
import java.util.Collections;
import java.util.List;

import javax.swing.GroupLayout;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JScrollPane;

/**
 * A panel that displays the {@link TargetTable} with the user-specified
 * external IDs.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class TadSummaryPanel extends ToolPanel {
    private static final int PREFFERED_TABLE_WIDTH = 300;
    private static final int PREFFERED_TABLE_HEIGHT = 100;

    private ToolTable tadTable;
    private TadTableModel tadModel;
    private JEditorPane incompleteWarning;

    /**
     * Creates a {@link TadSummaryPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public TadSummaryPanel() throws UiException {
        createUi();
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    @Override
    protected List<String> getActionStrings() {
        return Collections.emptyList();
    }

    @Override
    protected void initComponents() {
        JLabel titleLabel = new JLabel();
        titleLabel.setName("titleLabel");
        titleLabel.setFont(titleLabel.getFont()
            .deriveFont(Font.BOLD));

        tadTable = new ToolTable(this);
        JScrollPane scrollPane = new JScrollPane(tadTable);

        incompleteWarning = new JEditorPane();
        incompleteWarning.setName("incompleteExportSet");
        incompleteWarning.setFocusable(false);

        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(titleLabel)
            .addComponent(scrollPane)
            .addComponent(incompleteWarning));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(titleLabel)
            .addComponent(scrollPane)
            .addComponent(incompleteWarning));
    }

    @Override
    protected void configureComponents() {
        tadTable.setPreferredScrollableViewportSize(new Dimension(
            PREFFERED_TABLE_WIDTH, PREFFERED_TABLE_HEIGHT));
        tadModel = new TadTableModel();
        tadTable.setModel(tadModel);

        incompleteWarning.setEditable(false);

        // Provides for better word wrapping.
        incompleteWarning.setContentType("text/html");

        // Prevent the editor from putting all of the text on one line.
        // The size is an arbitrary, but small, value.
        incompleteWarning.setPreferredSize(new Dimension(10, 10));
    }

    @Override
    protected void updateEnabled() {
    }

    /**
     * Sets the {@link ExportTable}s that this model is handling.
     * 
     * @param tables the {@link ExportTable}s that this model is handling
     * @throws NullPointerException if {@code tables} is {@code null}
     */
    public void setTables(List<Pair<ExportTable, TargetListSet>> tables) {
        tadModel.setTables(tables);
    }

    /**
     * Displays a warning about not having a complete export set if
     * {@code completeExportSet} is {@code false}.
     * 
     * @param completeExportSet {@code true} if the export set is complete;
     * otherwise, {@code false}
     * @throws NullPointerException if {@code tables} is {@code null}
     */
    public void setCompleteExportSet(boolean completeExportSet) {
        incompleteWarning.setVisible(!completeExportSet);
    }
}
