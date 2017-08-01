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

import static gov.nasa.kepler.ui.common.MathUtilities.isNumber;
import gov.nasa.kepler.hibernate.gar.ExportTable;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.KeplerPanel;

import java.awt.Dimension;
import java.awt.Font;
import java.util.EventObject;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JComponent;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.SwingConstants;

import org.bushe.swing.event.EventBus;

/**
 * A panel for obtaining an external ID. As the user edits the external ID, an
 * {@code ExternalIdEvent} is published on the event bus with the current value,
 * or {@link ExportTable#INVALID_EXTERNAL_ID} if the field is empty or contains
 * non-numeric characters. Use the event's source property to ignore events from
 * panels you are not managing.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class ExternalIdChooser extends KeplerPanel {

    private static final int FIELD_WIDTH = 3;

    private JLabel titleLabel;
    private JEditorPane description;
    private JTextField externalId;
    private JEditorPane whatNext;

    private String title;

    /**
     * Creates an {@link ExternalIdChooser}.
     * 
     * @throws UiException if the panel could not be created
     */
    public ExternalIdChooser() throws UiException {
        title = resourceMap.getString("listEntry");
        createUi();
    }

    @Override
    public String toString() {
        return title;
    }

    /**
     * Returns the current value entered for the external ID. If 0 is displayed,
     * the value {@link ExportTable#INVALID_EXTERNAL_ID} is returned.
     * 
     * @return the external ID, or {@link ExportTable#INVALID_EXTERNAL_ID} if
     * the field is blank or not a number
     */
    public int getExternalId() {
        String s = externalId.getText()
            .trim();
        int id = isNumber(s) ? Integer.valueOf(s)
            : ExportTable.INVALID_EXTERNAL_ID;
        if (id == 0) {
            id = ExportTable.INVALID_EXTERNAL_ID;
        }

        return id;
    }

    /**
     * Sets the external ID text field.
     * 
     * @param externalId the external ID to use
     */
    public void setExternalId(int externalId) {
        this.externalId.setText(Integer.toString(externalId));
    }

    @Override
    protected void initComponents() {
        titleLabel = new JLabel();
        titleLabel.setName("titleLabel");
        titleLabel.setFont(titleLabel.getFont()
            .deriveFont(Font.BOLD));
        titleLabel.setFocusable(false);

        description = new JEditorPane();
        description.setName("description");
        description.setFocusable(false);

        JLabel externalIdLabel = new JLabel();
        externalIdLabel.setName("externalIdLabel");
        externalIdLabel.setFocusable(false);
        externalId = new JTextField(FIELD_WIDTH);

        whatNext = new JEditorPane();
        whatNext.setName("whatNext");
        whatNext.setFocusable(false);

        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);
        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(titleLabel)
            .addGroup(
                layout.createSequentialGroup()
                    .addPreferredGap(titleLabel, description,
                        ComponentPlacement.INDENT)
                    .addGroup(
                        layout.createParallelGroup()
                            .addComponent(description)
                            .addGroup(
                                layout.createSequentialGroup()
                                    .addGroup(layout.createParallelGroup()
                                        .addComponent(externalIdLabel))
                                    .addGroup(
                                        layout.createParallelGroup(
                                            Alignment.TRAILING)
                                            .addComponent(externalId,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.PREFERRED_SIZE)))
                            .addComponent(whatNext))));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(titleLabel)
            .addComponent(description, GroupLayout.DEFAULT_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                .addComponent(externalIdLabel)
                .addComponent(externalId))
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(whatNext));
    }

    @Override
    protected void configureComponents() {
        description.setEditable(false);
        whatNext.setEditable(false);

        // The following provides better word wrapping.
        description.setContentType("text/html");
        whatNext.setContentType("text/html");

        // Prevent the editor from putting all of the text on one line.
        // The size is an arbitrary, but small, value.
        description.setPreferredSize(new Dimension(10, 10));
        whatNext.setPreferredSize(new Dimension(10, 10));

        externalId.getDocument()
            .addDocumentListener(updateDocumentListener);
        externalId.setHorizontalAlignment(SwingConstants.TRAILING);
    }

    @Override
    protected JComponent getDefaultFocusComponent() {
        if (externalId.getText()
            .length() == 0) {
            return externalId;
        }

        return null;
    }

    @Override
    protected void updateEnabled() {
        if (!isUiInitializing()) {
            EventBus.publish(new ExternalIdEvent(this, getExternalId()));
        }
    }

    /**
     * Update the title text. Note that a reasonable default is given. This
     * method is useful if several of these panels are used and each needs a
     * different title to set it apart from the others. This string is then
     * returned from {@link #toString()}.
     * 
     * @param string the new title text
     */
    public void setInstruction(String string) {
        title = string;
        titleLabel.setText(string);
    }

    /**
     * An event used when broadcasting updates to the external ID.
     * 
     * @author Bill Wohler
     */
    public static class ExternalIdEvent extends EventObject {
        private int externalId;

        /**
         * Creates an {@link ExternalIdEvent} with the given source and external
         * ID.
         * 
         * @param source the source of this event
         * @param externalId the external ID
         */
        public ExternalIdEvent(Object source, int externalId) {
            super(source);
            this.externalId = externalId;
        }

        /**
         * Returns the updated external ID.
         * 
         * @return the external ID
         */
        public int getExternalId() {
            return externalId;
        }
    }
}
