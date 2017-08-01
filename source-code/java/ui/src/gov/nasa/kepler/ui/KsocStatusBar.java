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

package gov.nasa.kepler.ui;

import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.KeplerPanel;
import gov.nasa.kepler.ui.swing.ToolTable;

import java.awt.Dimension;
import java.util.List;
import java.util.regex.Pattern;

import javax.swing.BorderFactory;
import javax.swing.GroupLayout;
import javax.swing.JComponent;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JProgressBar;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.bushe.swing.event.EventTopicSubscriber;

/**
 * A status bar for the KSOC application.
 * <p>
 * Messages are displayed when items are selected. In particular, this class
 * subscribes for topics of the form <code>.*ToolTable.SELECT</code>.
 * <p>
 * Objects of this class also subscribe to {@link StatusEvent} messages and
 * display those messages contained therein.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
public class KsocStatusBar extends KeplerPanel {
    private static final int MESSAGES_MIN_SIZE = 200;

    private JLabel messages;

    private EventTopicSubscriber selectionListener;
    private EventSubscriber<StatusEvent> statusListener;

    /**
     * Creates a {@link KsocStatusBar}.
     * 
     * @throws UiException if the status bar could not be created
     */
    public KsocStatusBar() throws UiException {
        createUi();
    }

    @Override
    protected void initComponents() {
        GroupLayout layout = new GroupLayout(this);
        setLayout(layout);

        messages = new JLabel();

        JComponent separator = createVerticalSeparator();

        JProgressBar progressBar = new JProgressBar();
        progressBar.setVisible(false);

        layout.setAutoCreateGaps(true);

        layout.setHorizontalGroup(layout.createSequentialGroup()
            .addComponent(messages, MESSAGES_MIN_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
            .addComponent(separator)
            .addComponent(progressBar));
        layout.setVerticalGroup(layout.createParallelGroup()
            .addComponent(messages)
            .addComponent(separator)
            .addComponent(progressBar));
    }

    @Override
    protected void addListeners() {
        selectionListener = new EventTopicSubscriber() {
            /**
             * Displays how many items were selected.
             * 
             * @param topic the topic (.*selectedItem)
             * @param data the data (a list of items)
             */
            @Override
            public void onEvent(String topic, Object data) {
                log.debug("topic=" + topic + ", data=" + data);
                if (data instanceof List<?>) {
                    List<?> list = (List<?>) data;
                    int size = list.size();
                    if (size > 0) {
                        String name = list.get(0)
                            .getClass()
                            .getSimpleName();
                        messages.setText(resourceMap.getString("selection",
                            size, name, size > 1 ? "s" : ""));
                    } else {
                        messages.setText(null);
                    }
                }
            }
        };
        EventBus.subscribe(Pattern.compile(".*" + ToolTable.SELECT),
            selectionListener);

        statusListener = new EventSubscriber<StatusEvent>() {
            /**
             * Displays the content of the given {@link StatusEvent}, displaying
             * an error dialog if necessary.
             * 
             * @param status the {@link StatusEvent}
             */
            @Override
            public void onEvent(StatusEvent status) {
                log.debug(status);
                String message = status.getMessage();
                String append = null;
                if (status.isDone()) {
                    append = resourceMap.getString("done");
                } else if (status.isFailed()) {
                    append = resourceMap.getString("failed");
                }
                if (append != null) {
                    if (message != null) {
                        message = message + append.toLowerCase();
                    } else {
                        message = append;
                    }
                }
                messages.setText(message);
            }
        };
        EventBus.subscribe(StatusEvent.class, statusListener);
    }

    @Override
    protected void updateEnabled() {
    }

    /**
     * Returns a vertical separator.
     * 
     * @return a vertical separator
     */
    private JComponent createVerticalSeparator() {
        // The GTK JSeparator draws vertical separators with horizontal
        // separator. See
        // http://bugs.sun.com/bugdatabase/view_bug.do?bug_id=6538756
        // This method SHOULD say:
        // return new JSeparator(SwingConstants.VERTICAL);
        // Workaround:
        JPanel separator = new JPanel();
        separator.setBorder(BorderFactory.createEtchedBorder());
        Dimension d = separator.getPreferredSize();
        separator.setMinimumSize(new Dimension(2, d.height));
        separator.setPreferredSize(new Dimension(2, d.height));
        separator.setMaximumSize(new Dimension(2, d.height));

        return separator;
    }
}
