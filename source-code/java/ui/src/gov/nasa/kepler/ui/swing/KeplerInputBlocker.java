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

package gov.nasa.kepler.ui.swing;

import static gov.nasa.kepler.ui.swing.KeplerSwingUtilities.toHtml;

import java.awt.Component;
import java.awt.Cursor;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;

import javax.swing.GroupLayout;
import javax.swing.JButton;
import javax.swing.JDialog;
import javax.swing.JEditorPane;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JProgressBar;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.Timer;
import javax.swing.WindowConstants;
import javax.swing.text.JTextComponent;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.Task;
import org.jdesktop.application.Task.InputBlocker;

/**
 * An input blocker which is derived from
 * {@code ApplicationAction.DefaultInputBlocker}. This copy is here since the \@Action
 * annotation doesn't (yet) support a parameter for specifying the task service
 * and DefaultInputBlocker is private. Modifications include:
 * <ol>
 * <li>ResourceMap and String prefix arguments.
 * <li>Cancel button and option pane icon resources come from from local
 * resource map, but can be overridden.
 * <li>Declare log4j logger.
 * <li>Display dialog after 250 ms.
 * <li>Display hourglass cursor.
 * <li>Add constructor for use without dialog.
 * </ol>
 * <p>
 * The various properties for the progress dialog have the prefix given in
 * {@link #KeplerInputBlocker(ResourceMap, String, Task, Task.BlockingScope, Object)}
 * . These properties are:
 * <ul>
 * <li><b>BlockingDialog</b> This is the name of the dialog (a {@link JDialog}),
 * from which its properties are derived. A common property includes
 * <i>prefix</i>{@code .BlockingDialog.title}.
 * <li><b>BlockingDialog.optionPane</b> This is the name for the body of the
 * dialog (a {@link JOptionPane}). A default is provided for <i>prefix</i>.
 * {@code BlockingDialog.optionPane.icon}; you will surely want to set
 * <i>prefix</i>.{@code BlockingDialog.optionPane.message}
 * </ul>
 * <p>
 * Other interesting properties include:
 * <ul>
 * <li><b>cancelButton</b> This is the name of the Cancel button (a
 * {@link JButton}). While the button has useful defaults, you may still want to
 * override {@code cancelButton.icon} or {@code cancelButton.text}
 * </ul>
 */
public class KeplerInputBlocker extends InputBlocker {
    private static final Log log = LogFactory.getLog(KeplerInputBlocker.class);

    /**
     * User-perceivable amount of time, in milliseconds. Delay used before
     * showing dialog. Progress messages should not be displayed any faster than
     * one tick, and should preferably only be updated once every four.
     */
    private static final int TICK_TIME = 250;

    private JDialog modalDialog = null;
    private JProgressBar progressBar;
    private JLabel messageArea;
    private ResourceMap resourceMap;
    private ResourceMap localResourceMap;
    private String prefix;

    /**
     * Creates a {@link KeplerInputBlocker} that does not have a dialog.
     * 
     * @param resourceMap the resource map
     * @param task block input while this {@link Task} is executing
     * @param scope how much of the GUI will be blocked
     * @param target the GUI element that will be blocked
     */
    @SuppressWarnings("rawtypes")
    public KeplerInputBlocker(ResourceMap resourceMap, Task task,
        Task.BlockingScope scope, Object target) {
        this(resourceMap, null, task, scope, target);
    }

    /**
     * Creates a {@link KeplerInputBlocker} with a dialog (after 250 ms).
     * 
     * @param resourceMap the resource map
     * @param prefix the resource prefix (see class description for resources)
     * @param task block input while this {@link Task} is executing
     * @param scope how much of the GUI will be blocked
     * @param target the GUI element that will be blocked
     */
    @SuppressWarnings("rawtypes")
    public KeplerInputBlocker(ResourceMap resourceMap, String prefix,
        Task task, Task.BlockingScope scope, Object target) {
        super(task, scope, target);
        this.resourceMap = resourceMap;
        this.prefix = prefix != null ? prefix
            + (prefix.endsWith(".") ? "" : ".") : null;
        localResourceMap = Application.getInstance()
            .getContext()
            .getResourceMap(getClass());

        switch (scope) {
            case ACTION:
                if (!(target instanceof javax.swing.Action)) {
                    throw new IllegalArgumentException("target not an Action");
                }
                break;
            case COMPONENT:
            case WINDOW:
                if (!(target instanceof Component)) {
                    throw new IllegalArgumentException("target not a Component");
                }
                break;
            case APPLICATION:
                break;
            case NONE:
                break;
        }
    }

    private void setActionTargetBlocked(boolean f) {
        javax.swing.Action action = (javax.swing.Action) getTarget();
        action.setEnabled(!f);
    }

    private void setComponentTargetBlocked(boolean f) {
        Component component = (Component) getTarget();
        component.setEnabled(!f);
    }

    /*
     * Creates a dialog whose visuals are initialized from the following task
     * resources: BlockingDialog.title BlockingDialog.optionPane.icon
     * BlockingDialog.optionPane.message BlockingDialog.cancelButton.text
     */
    private JDialog createBlockingDialog() {
        JOptionPane optionPane = new JOptionPane();
        if (getTask().getUserCanCancel()) {
            JButton cancelButton = new JButton();
            cancelButton.setName("cancelButton");
            ActionListener doCancelTask = new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent ignore) {
                    getTask().cancel(true);
                }
            };
            cancelButton.addActionListener(doCancelTask);
            optionPane.setOptions(new Object[] { cancelButton });
        } else {
            optionPane.setOptions(new Object[] {}); // avoid OK button
        }
        Component dialogOwner = (Component) getTarget();
        JDialog dialog = optionPane.createDialog(dialogOwner, prefix
            + "BlockingDialog");
        dialog.setModal(true);
        dialog.setDefaultCloseOperation(WindowConstants.DO_NOTHING_ON_CLOSE);
        dialog.setName(prefix + "BlockingDialog");
        optionPane.setName(prefix + "BlockingDialog.optionPane");
        // Load default properties.
        optionPane.setIcon(localResourceMap.getIcon("optionPane.icon"));
        localResourceMap.injectComponents(dialog);
        // Override with caller's resources.
        if (resourceMap != null) {
            resourceMap.injectComponents(dialog);
        }
        // Replace message object with panel with text and progress bar.
        optionPane.setMessage(createOptionPanePanel(optionPane.getMessage()));
        dialog.pack();
        return dialog;
    }

    private Object createOptionPanePanel(Object message) {
        Component c;
        if (message instanceof String) {
            c = new JEditorPane("text/html", toHtml((String) message));
            ((JTextComponent) c).setEditable(false);
        } else {
            c = (Component) message;
        }
        JPanel panel = new JPanel();
        GroupLayout layout = new GroupLayout(panel);
        panel.setLayout(layout);
        progressBar = createProgressBar();
        messageArea = createMessageArea();
        layout.setHorizontalGroup(layout.createParallelGroup()
            .addComponent(c)
            .addComponent(messageArea)
            .addComponent(progressBar, GroupLayout.DEFAULT_SIZE,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE));
        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(c)
            .addPreferredGap(ComponentPlacement.UNRELATED,
                GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE)
            .addComponent(messageArea)
            .addComponent(progressBar)
            .addContainerGap());

        return panel;
    }

    private JProgressBar createProgressBar() {
        final JProgressBar progressBar = new JProgressBar(0, 100);
        progressBar.setIndeterminate(true);
        progressBar.setStringPainted(true);
        getTask().addPropertyChangeListener(new PropertyChangeListener() {
            private long start = System.currentTimeMillis();
            private String remaining = localResourceMap.getString("remaining");

            @Override
            public void propertyChange(PropertyChangeEvent evt) {
                if (evt.getPropertyName()
                    .equals("progress")) {
                    int progress = (Integer) evt.getNewValue();
                    progressBar.setIndeterminate(false);
                    progressBar.setValue(progress);
                    progressBar.setString(getTimeLeftString(progress));
                }
            }

            private String getTimeLeftString(int progress) {
                if (progress == 0) {
                    // If a task has just started and the second step takes a
                    // long time, it looks pretty silly to see "00:00:00
                    // remaining". In addition, avoids divide by 0 error.
                    return "";
                }
                long duration = System.currentTimeMillis() - start;
                long timeLeft = Math.round((float) duration / progress * 100.0F
                    - duration);

                return String.format("%s %s",
                    DurationFormatUtils.formatDuration(timeLeft, "H:mm:ss"),
                    remaining);
            }
        });

        return progressBar;
    }

    private JLabel createMessageArea() {
        // Create a label with at least one space so that the layout manager
        // makes room for it. Otherwise, the Cancel button will be pushed out of
        // the dialog when a real message arrives.
        final JLabel messageArea = new JLabel(" ");
        getTask().addPropertyChangeListener(new PropertyChangeListener() {
            @Override
            public void propertyChange(PropertyChangeEvent evt) {
                if (evt.getPropertyName()
                    .equals("message")) {
                    String text = (String) evt.getNewValue();
                    messageArea.setText(text);
                }
            }
        });

        return messageArea;
    }

    private void showBlockingDialog(boolean f) {
        if (f) {
            if (modalDialog != null) {
                String msg = String.format(
                    "unexpected InputBlocker state [%s] %s", f, this);
                log.warn(msg);
                modalDialog.dispose();
            }
            modalDialog = createBlockingDialog();
            Timer timer = new Timer(TICK_TIME, new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent e) {
                    // Might have completed task in the meantime.
                    if (modalDialog != null) {
                        modalDialog.setVisible(true);
                    }
                }
            });
            timer.setRepeats(false);
            timer.start();
        } else {
            if (modalDialog != null) {
                modalDialog.dispose();
                modalDialog = null;
            } else {
                String msg = String.format(
                    "unexpected InputBlocker state [%s] %s", f, this);
                log.warn(msg);
            }
        }
    }

    @Override
    protected void block() {
        if (getTarget() instanceof Component) {
            Component c = (Component) getTarget();
            c.setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        }
        switch (getScope()) {
            case ACTION:
                setActionTargetBlocked(true);
                break;
            case COMPONENT:
                setComponentTargetBlocked(true);
                break;
            case WINDOW:
            case APPLICATION:
                if (prefix != null) {
                    showBlockingDialog(true);
                }
                break;
            case NONE:
                break;
        }
    }

    @Override
    protected void unblock() {
        switch (getScope()) {
            case ACTION:
                setActionTargetBlocked(false);
                break;
            case COMPONENT:
                setComponentTargetBlocked(false);
                break;
            case WINDOW:
            case APPLICATION:
                if (prefix != null) {
                    showBlockingDialog(false);
                }
                break;
            case NONE:
                break;
        }
        if (getTarget() instanceof Component) {
            Component c = (Component) getTarget();
            c.setCursor(Cursor.getDefaultCursor());
        }
    }
}
