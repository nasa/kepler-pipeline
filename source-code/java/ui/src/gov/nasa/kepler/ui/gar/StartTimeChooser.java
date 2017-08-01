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
import java.text.ParseException;
import java.util.Date;
import java.util.EventObject;

import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.JComponent;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JTextField;
import javax.swing.LayoutStyle.ComponentPlacement;

import org.bushe.swing.event.EventBus;

/**
 * A panel for modifying the start time. As the user edits the date, a
 * {@code StartTimeEvent} is published on the event bus with the current value,
 * or {@code null} if the field is empty or contains an invalid date. Use the
 * event's source property to ignore events from panels you are not managing.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class StartTimeChooser extends KeplerPanel {

    private static final int FIELD_WIDTH = 20;

    private JLabel titleLabel;
    private JEditorPane description;
    private JTextField startTime;
    private JEditorPane whatNext;

    private String title;

    private DateFormat dateTimeFormatter = Iso8601Formatter.dateTimeFormatter();

    /**
     * Creates an {@link StartTimeChooser}.
     * 
     * @throws UiException if the panel could not be created.
     */
    public StartTimeChooser() throws UiException {
        title = resourceMap.getString("listEntry");
        createUi();
    }

    @Override
    public String toString() {
        return title;
    }

    /**
     * Returns the current value entered for the start time.
     * 
     * @return the start time, or {@code null} if the field is blank or not a
     * valid date.
     */
    public Date getStartTime() {
        try {
            String s = startTime.getText()
                .trim();
            Date startTime = dateTimeFormatter.parse(s);
            return startTime;
        } catch (ParseException ignore) {
            return null;
        }
    }

    /**
     * Sets the start time text field.
     * 
     * @param startTime the time to use, or {@code null} to clear the field..
     */
    public void setStartTime(Date startTime) {
        String s = "";
        if (startTime != null) {
            s = dateTimeFormatter.format(startTime);
        }

        this.startTime.setText(s);
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

        JLabel startTimeLabel = new JLabel();
        startTimeLabel.setName("startTimeLabel");
        startTimeLabel.setFocusable(false);
        startTime = new JTextField(FIELD_WIDTH);
        startTimeLabel.setLabelFor(startTime);

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
                                        .addComponent(startTimeLabel))
                                    .addGroup(
                                        layout.createParallelGroup(
                                            Alignment.TRAILING)
                                            .addComponent(startTime,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.DEFAULT_SIZE,
                                                GroupLayout.PREFERRED_SIZE)))
                            .addComponent(whatNext))));

        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(titleLabel)
            .addComponent(description, GroupLayout.DEFAULT_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addGroup(layout.createParallelGroup(Alignment.BASELINE)
                .addComponent(startTimeLabel)
                .addComponent(startTime))
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

        startTime.getDocument()
            .addDocumentListener(updateDocumentListener);
    }

    @Override
    protected JComponent getDefaultFocusComponent() {
        if (startTime.getText()
            .length() == 0) {
            return startTime;
        }

        return null;
    }

    @Override
    protected void updateEnabled() {
        if (isUiInitializing()) {
            description.setText(resourceMap.getString("description.text",
                dateTimeFormatter.format(new Date())));
        } else {
            EventBus.publish(new StartTimeEvent(this, getStartTime()));
        }
    }

    /**
     * Update the title text. Note that a reasonable default is given. This
     * method is useful if several of these panels are used and each needs a
     * different title to set it apart from the others. This string is then
     * returned from {@link #toString()}.
     * 
     * @param string the new title text.
     */
    public void setInstruction(String string) {
        title = string;
        titleLabel.setText(string);
    }

    /**
     * An event used when broadcasting updates to the start time.
     * 
     * @author Bill Wohler
     */
    public static class StartTimeEvent extends EventObject {
        private Date startTime;

        /**
         * Creates a {@link StartTimeEvent} with the given source and start
         * time.
         * 
         * @param source the source of this event.
         * @param startTime the start time.
         */
        public StartTimeEvent(Object source, Date startTime) {
            super(source);
            this.startTime = startTime;
        }

        /**
         * Returns the updated start time.
         * 
         * @return the start time.
         */
        public Date getStartTime() {
            return startTime;
        }
    }
}
