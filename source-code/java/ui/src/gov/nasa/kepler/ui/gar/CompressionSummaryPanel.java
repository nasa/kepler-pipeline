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

import gov.nasa.kepler.common.Iso8601Formatter;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.KeplerPanel;

import java.awt.Dimension;
import java.awt.Font;
import java.text.DateFormat;
import java.util.Date;

import javax.swing.GroupLayout;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.LayoutStyle.ComponentPlacement;

/**
 * A summary panel for the Huffman and requantization table export.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class CompressionSummaryPanel extends KeplerPanel {
    private static final String MESSAGE = "message";

    private JLabel titleLabel;
    private JEditorPane message;

    private long huffmanTaskId;
    private long requantTaskId;
    private int externalId;
    private Date startDate = new Date();

    private DateFormat dateTimeFormatter = Iso8601Formatter.dateTimeFormatter();

    /**
     * Creates a {@link CompressionSummaryPanel}.
     * 
     * @throws UiException if the panel could not be created
     */
    public CompressionSummaryPanel() throws UiException {
        createUi();
    }

    @Override
    public String toString() {
        return resourceMap.getString("listEntry");
    }

    /**
     * Sets the external ID shown in this panel.
     * 
     * @param externalId the external ID
     */
    public void setExternalId(int externalId) {
        this.externalId = externalId;
        updateEnabled();
    }

    /**
     * Sets the Huffman task ID shown in this panel.
     * 
     * @param huffmanTaskId the Huffman task ID
     */
    public void setHuffmanTaskId(long huffmanTaskId) {
        this.huffmanTaskId = huffmanTaskId;
        updateEnabled();
    }

    /**
     * Sets the requantization task ID shown in this panel.
     * 
     * @param requantTaskId the requantization task ID
     */
    public void setRequantTaskId(long requantTaskId) {
        this.requantTaskId = requantTaskId;
        updateEnabled();
    }

    /**
     * Sets the start date shown in this panel.
     * 
     * @param startDate the start date
     */
    public void setStartTime(Date startDate) {
        this.startDate = startDate;
        updateEnabled();
    }

    @Override
    protected void initComponents() {
        titleLabel = new JLabel();
        titleLabel.setName("titleLabel");
        titleLabel.setFont(titleLabel.getFont()
            .deriveFont(Font.BOLD));

        message = new JEditorPane();
        message.setName(MESSAGE);

        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addGroup(
                layout.createParallelGroup()
                    .addComponent(titleLabel)
                    .addGroup(
                        layout.createSequentialGroup()
                            .addPreferredGap(titleLabel, message,
                                ComponentPlacement.INDENT)
                            .addComponent(message))));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(titleLabel)
            .addComponent(message));
    }

    @Override
    protected void configureComponents() {
        message.setEditable(false);
        // The following provides better word wrapping.
        message.setContentType("text/html");
        // Prevent the editor from putting all of the text on one line.
        // The size is an arbitrary, but small, value.
        message.setPreferredSize(new Dimension(10, 10));
    }

    @Override
    protected void updateEnabled() {
        if (startDate != null) {
            message.setText(resourceMap.getString(MESSAGE, huffmanTaskId,
                requantTaskId, externalId, dateTimeFormatter.format(startDate)));
        } else {
            message.setText(resourceMap.getString(MESSAGE
                + "BadlyUpdatedTables"));
        }
    }
}
