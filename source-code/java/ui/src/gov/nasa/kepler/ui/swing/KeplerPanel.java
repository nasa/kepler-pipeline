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

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.DatabaseTaskService;
import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.common.UpdateEvent;
import gov.nasa.kepler.ui.common.UpdateEvent.Function;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.awt.Component;
import java.awt.Container;
import java.awt.Dialog;
import java.awt.FocusTraversalPolicy;
import java.awt.event.HierarchyEvent;
import java.awt.event.HierarchyListener;
import java.util.List;

import javax.swing.Action;
import javax.swing.ImageIcon;
import javax.swing.JButton;
import javax.swing.JComponent;
import javax.swing.JDialog;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.KeyStroke;
import javax.swing.event.DocumentEvent;
import javax.swing.event.DocumentListener;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.jdesktop.application.Application;
import org.jdesktop.application.ApplicationActionMap;
import org.jdesktop.application.ApplicationContext;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.SingleFrameApplication;
import org.jdesktop.application.Task;
import org.jdesktop.application.Task.BlockingScope;

/**
 * A panel that most substantial panels should subclass. After setting its
 * instance variables, a subclass' constructor should call {@link #createUi()}
 * which is a template method that calls {@link #initComponents()},
 * {@link #configureComponents()}, {@link #addListeners()},
 * {@link #getData(boolean)}, and {@link #updateEnabled()}, and injects this
 * panel's resources. Override these methods as needed. Subclasses should avail
 * themselves generously of the protected fields and methods.
 * <p>
 * In order to set up default keys for the OK and Cancel buttons, the dialog
 * which creates such a panel must call {@link #initDefaultKeys()}. This method
 * makes Enter activate the OK button and Escape activate the Cancel button.
 * Subclasses must override {@link #getDefaultButton()} to provide the OK
 * button; the Escape will activate the "cancel" action.
 * <p>
 * It is a good thing for one of the components to get the focus initially. If
 * you don't use {@link #setFocusTraversalComponents(List)} to set the focus
 * cycle explicitly, consider overriding {@link #getDefaultFocusComponent()} to
 * return the component that should get the initial focus. In addition, you may
 * also have to call {@link #setFocusable(boolean)} with an argument of
 * {@code false} to get labels or other non-editable components off of the focus
 * cycle. To test this, follow the focus as you use TAB or C-TAB. Also, give a
 * text field the focus and use the mouse to click on all non-editable
 * components; the focus should not change.
 * <p>
 * You must also override {@link #updateEnabled()} and will find the related
 * method {@link #setDirty(boolean)} to be quite handy. Related fields include
 * {@link #updateDocumentListener} and {@link #dirtyDocumentListener} which call
 * {@link #updateEnabled()} and {@link #setDirty(boolean)} respectively when the
 * document that they are listening to is modified. To take advantage of the
 * latter, use code such as
 * {@code someTextComponent.getDocument().addDocumentListener(dirtyDocumentListener);}
 * 
 * @author Bill Wohler
 */
public abstract class KeplerPanel extends JPanel {

    private static final long serialVersionUID = 1L;

    private static final String MODIFIED = "*";

    /**
     * Common constant used to build resource name when {@link #reloadingData()}
     * return {@code true}.
     */
    protected static final String RELOADING_DATA = ".ReloadingData";

    protected final Log log;
    protected ImageIcon informationIcon16;
    protected ImageIcon warningIcon16;
    protected ImageIcon errorIcon16;
    protected ImageIcon informationIcon24;
    protected ImageIcon warningIcon24;
    protected ImageIcon errorIcon24;

    protected static final SingleFrameApplication app = (SingleFrameApplication) Application.getInstance();
    protected static final ApplicationContext appContext = app.getContext();
    protected final ResourceMap resourceMap = appContext.getResourceMap(getClass());
    protected final ApplicationActionMap actionMap = appContext.getActionMap(this);
    protected final DocumentListener updateDocumentListener = new UpdateDocumentListener();
    protected final DocumentListener dirtyDocumentListener = new DirtyDocumentListener();
    private final UpdateHandler updateHandler = new UpdateHandler();
    protected final Configuration config;

    private boolean uiInitializing;
    private boolean dirty;
    private boolean dataValid;
    private String helpText;
    private HelpType helpType;

    private JComponent defaultFocusComponent;

    /**
     * The type of help--and hence the icon--that is displayed.
     */
    public enum HelpType {
        INFORMATION, WARNING, ERROR;
    }

    /**
     * Creates a {@link KeplerPanel}.
     * 
     * @throws UiException if the configuration object could not be created
     */
    public KeplerPanel() throws UiException {
        log = LogFactory.getLog(getClass());

        try {
            config = ConfigurationServiceFactory.getInstance();
        } catch (PipelineException e) {
            ResourceMap resourceMap = app.getContext()
                .getResourceMap(KeplerPanel.class);
            log.error(resourceMap.getString("badConfiguration"), e);
            throw new UiException(resourceMap.getString("badConfiguration"), e);
        }

        initIcons();
    }

    /**
     * Create some useful icons.
     */
    private void initIcons() {
        ResourceMap resourceMap = app.getContext()
            .getResourceMap(KeplerPanel.class);
        informationIcon16 = KeplerSwingUtilities.scaleIcon(
            resourceMap.getImageIcon("information.icon"), 16, 16);
        warningIcon16 = KeplerSwingUtilities.scaleIcon(
            resourceMap.getImageIcon("warning.icon"), 16, 16);
        errorIcon16 = KeplerSwingUtilities.scaleIcon(
            resourceMap.getImageIcon("error.icon"), 16, 16);

        informationIcon24 = KeplerSwingUtilities.scaleIcon(
            resourceMap.getImageIcon("information.icon"), 24, 24);
        warningIcon24 = KeplerSwingUtilities.scaleIcon(
            resourceMap.getImageIcon("warning.icon"), 24, 24);
        errorIcon24 = KeplerSwingUtilities.scaleIcon(
            resourceMap.getImageIcon("error.icon"), 24, 24);
    }

    /**
     * A template method that creates the UI which should be called by your
     * constructor. This method calls {@link #initComponents()},
     * {@link #configureComponents()}, {@link #addListeners()},
     * {@link #getData(boolean)}, and {@link #updateEnabled()} in that order.
     * Override these methods as necessary. In addition, it also injects this
     * panel's resources.
     */
    protected final void createUi() throws UiException {
        setUiInitializing(true);

        initComponents();
        configureComponents();
        addListeners();
        EventBus.subscribe(UpdateEvent.class, updateHandler);
        getData(false);
        resourceMap.injectComponents(this);
        updateEnabled();

        addHierarchyListener(new HierarchyListener() {
            @Override
            public void hierarchyChanged(HierarchyEvent e) {
                JComponent c = null;
                JDialog dialog = null;
                if (e.getSource() instanceof JDialog) {
                    dialog = (JDialog) e.getSource();
                    c = dialog.getRootPane();
                } else if (e.getSource() instanceof JComponent) {
                    c = (JComponent) e.getSource();
                }
                if (c == KeplerPanel.this
                    && (e.getChangeFlags() & HierarchyEvent.SHOWING_CHANGED) != 0
                    && c.isShowing()) {
                    if (getDefaultFocusComponent() != null) {
                        getDefaultFocusComponent().requestFocusInWindow();
                    }
                }
            }
        });

        setUiInitializing(false);
    }

    /**
     * Returns the value of the {@code uiInitializing} property. This property
     * is {@code true} while {@link #createUi()} is running. It is useful to
     * suppress actions that make more sense when driven by user input (like
     * context help).
     * 
     * @return {@code true}, if this component is still in the initialization
     * phase; otherwise, {@code false}
     */
    protected boolean isUiInitializing() {
        return uiInitializing;
    }

    /**
     * Sets the value of the {@code uiInitializing} property. Subclasses may
     * have need for this to suppress actions when asynchronous initialization
     * tasks return after {@link #createUi()} has finished.
     * 
     * @param uiInitializing {@code true}, if this component should be
     * considered in the initialization phase; otherwise, {@code false}
     */
    protected void setUiInitializing(boolean uiInitializing) {
        this.uiInitializing = uiInitializing;
    }

    /**
     * Called by {@link #createUi()} to create the UI's components. This method
     * is typically owned by a GUI builder. Resist the urge to edit the contents
     * (other than removing the hard-coded pixel sizes created by Jigloo). Use
     * {@link #configureComponents()} instead.
     */
    protected abstract void initComponents() throws UiException;

    /**
     * Called by {@link #createUi()} to configure the UI components. This
     * optional method is used to keep code out of {@link #initComponents()}
     * that was not generated by a GUI builder.
     */
    protected void configureComponents() throws UiException {
    }

    /**
     * Called by {@link #createUi()} to add listeners to the panel's components
     * and to add subscribers to the event bus.
     */
    protected void addListeners() throws UiException {
    }

    /**
     * Called by {@link #createUi()} to get data used to populate the form. This
     * optional method creates tasks which are then run in the background to
     * retrieve data used by the form. The tasks' {@code succeeded()} method
     * populates the form's fields; it must then call
     * {@link #setDataValid(boolean)} with a value of {@code true}.
     * <p>
     * The {@code block} parameter is typically {@code false} when this method
     * is called during initialization by {@link #createUi()}. However, it is
     * {@code true} when it is called from {@link #reloadingData()} since it is
     * important that the user not do anything while the state of his session is
     * being refreshed.
     * 
     * @param block {@code true} if the task should display a blocking dialog;
     * {@code false} if the user can continue working while the task is running
     * @see #reloadingData()
     * @see #setDataValid(boolean)
     */
    protected void getData(boolean block) {
    }

    /**
     * Calls {@code getData(true)} to refresh the panel's data if
     * {@link #isDataValid()} returns {@code false}. This method should always
     * be called before accessing data that has been loaded by
     * {@link #getData(boolean)}.
     * <p>
     * Please make use of the {@code $retry} property when the problem was
     * originally detected and the ${@code databaseError} property if
     * {@code reloadingData()} returns {@code true}, as well as the
     * {@code RELOADING_DATA} constant. For example, this function can be used
     * as follows:
     * 
     * <pre>
     * if (reloadingData()) {
     *     handleError(null, PREVIOUS + RELOADING_DATA);
     *     return;
     * }
     * Properties:
     * previous.ReloadingData.failed=Could not go to the previous page
     * previous.ReloadingData.failed.secondary=${databaseError}
     * </pre>
     * 
     * @return {@code false} if the data is OK and it's safe to access it;
     * {@code true} if the data is being reloaded and the activity should be
     * aborted and retried after the data has been loaded
     * @see #RELOADING_DATA
     */
    protected final boolean reloadingData() {
        if (isDataValid()) {
            return false;
        }

        getData(true);

        return true;
    }

    /**
     * Returns {@code true} if the next invocation of {@link #reloadingData()}
     * will call {@link #getData(boolean)}.
     */
    protected boolean isDataValid() {
        return dataValid;
    }

    /**
     * Sets whether the next invocation of {@link #reloadingData()} will call
     * {@link #getData(boolean)}. This method should be called with a value of
     * {@code true} once the data has been loaded.
     * 
     * @param dataValid the new value of the {@code dataValid} property
     */
    protected void setDataValid(boolean dataValid) {
        this.dataValid = dataValid;
    }

    /**
     * Called by {@link #createUi()} to update the actions' enabled state. Tries
     * to enable the actions subject to the setters' logic. You can and should
     * also call this after updating a selection, or running a command which
     * might change the state of the dialog. If you've used
     * {@link #updateDocumentListener} then this method is called automatically
     * when the associated document is updated.
     */
    protected abstract void updateEnabled();

    /**
     * Creates default keys for the OK and Cancel buttons and the Enter key. An
     * enter should fire the OK button and Escape should fire the Escape button.
     * This method can only be called after the panel has been attached to a
     * dialog.
     * 
     * @throws NullPointerException if this method is called before the panel
     * has been attached to a dialog
     */
    public void initDefaultKeys() {
        getRootPane().setDefaultButton(getDefaultButton());

        // TODO Fix Escape running Cancel when focus is in any field
        KeyStroke escape = KeyStroke.getKeyStroke("ESCAPE");
        getRootPane().getInputMap()
            .put(escape, "cancel");
        getRootPane().getActionMap()
            .put("cancel", actionMap.get("cancel"));
    }

    /**
     * Returns the default button. Override this and return the default button
     * for your panel. For example, this is probably your OK button.
     * 
     * @return the default button
     */
    protected JButton getDefaultButton() {
        return null;
    }

    /**
     * Returns the action associated with the given string.
     * 
     * @param s the string used to obtain the action
     * @return the action
     */
    protected Action getAction(String s) {
        return getAction(this, s);
    }

    /**
     * Returns the action associated with the given string for the specified
     * {@code actionsObject}.
     * 
     * @param actionsObject the object that contains the action
     * @param s the string used to obtain the action
     * @return the action
     */
    protected Action getAction(Object actionsObject, String s) {
        Action action = appContext.getActionMap(actionsObject)
            .get(s);
        log.debug("Returning action=" + action + " for actionsObject="
            + actionsObject.getClass()
                .getSimpleName() + ", s=" + s);
        return action;
    }

    /**
     * Updates the title. The title is formed by taking the dialog's title
     * resource and passing the given args to its constructor. The resource used
     * is formed by taking the dialog's name and appending ".title".
     * 
     * @param modified if {@code true}, inserts a * before the title per the HIG
     * @param args arguments to pass to
     * {@link ResourceMap#getString(String, Object[])}
     */
    public void setTitle(boolean modified, Object... args) {
        Dialog dialog = KeplerSwingUtilities.getDialog(this);
        if (dialog == null) {
            // Not yet attached.
            return;
        }
        setTitle(modified,
            resourceMap.getString(dialog.getName() + ".title", args));
    }

    /**
     * Updates the title.
     * 
     * @param modified if {@code true}, inserts a * before the title per the HIG
     * @param title the new title
     */
    private void setTitle(boolean modified, String title) {
        Dialog dialog = KeplerSwingUtilities.getDialog(this);
        if (dialog == null) {
            // Not yet attached.
            return;
        }
        String saveString = modified ? MODIFIED : "";
        dialog.setTitle(saveString + title);
    }

    /**
     * Gets the title.
     * 
     * @return the title, or an empty string if this panel is not attached to a
     * dialog
     */
    private String getTitle() {
        Dialog dialog = KeplerSwingUtilities.getDialog(this);
        if (dialog == null) {
            // Not yet attached.
            return "";
        }

        return dialog.getTitle();
    }

    /**
     * Looks up {@code helpTextKey} property from the {@code ResourceMap} and
     * saves the text if {@code condition} is {@code false}. This text can be
     * retrieved by {@link #getHelpText()}. This method sets the
     * {@link HelpType} to {@code ERROR}.
     * 
     * @param condition the condition
     * @param helpTextKey the non-{@code null} key to the help text
     * @return the condition
     * @throws NullPointerException if {@code helpTextKey} is {@code null}
     * @see #getHelpType()
     * @see #getHelpText()
     * @see #setHelpText(String)
     */
    protected boolean conditionalHelp(boolean condition, String helpTextKey) {
        return conditionalHelp(condition, HelpType.ERROR, helpTextKey);
    }

    /**
     * Looks up {@code helpTextKey} property from the {@code ResourceMap} and
     * saves the text if {@code condition} is {@code false}. This text can be
     * retrieved by {@link #getHelpText()}.
     * 
     * @param condition the condition
     * @param helpType the type of help; this is typically used to set the icon
     * associated with the help
     * @param helpTextKey the non-{@code null} key to the help text
     * @return the condition
     * @throws NullPointerException if {@code helpTextKey} is {@code null}
     * @see #getHelpType()
     * @see #getHelpText()
     * @see #setHelpText(String)
     */
    protected boolean conditionalHelp(boolean condition, HelpType helpType,
        String helpTextKey) {

        if (helpTextKey == null) {
            throw new NullPointerException("helpTextKey can't be null");
        }

        if (condition == false) {
            String helpText = resourceMap.getString(helpTextKey);
            this.helpText = helpText != null ? helpText : helpTextKey;
            this.helpType = helpType;
        }

        return condition;
    }

    /**
     * Returns the type of contextual help displayed.
     * 
     * @see #conditionalHelp(boolean, String)
     * @see #conditionalHelp(boolean, HelpType, String)
     * @see #getHelpText()
     * @see #setHelpText(String)
     */
    protected HelpType getHelpType() {
        return helpType;
    }

    /**
     * Sets the text used when displaying contextual help. This is typically
     * used to clear the text. Normally,
     * {@link #conditionalHelp(boolean, String)} is used to set the text.
     * 
     * @param helpText the help text; use {@code null} to clear the text
     * @see #conditionalHelp(boolean, String)
     * @see #conditionalHelp(boolean, HelpType, String)
     * @see #getHelpType()
     * @see #getHelpText()
     */
    protected void setHelpText(String helpText) {
        this.helpText = helpText;

        // TODO Animate
        // Animator animator = new Animator(1000);
        // new ScreenTransition(this, this, animator).start();
    }

    /**
     * Returns the text used to display contextual help.
     * 
     * @see #conditionalHelp(boolean, String)
     * @see #conditionalHelp(boolean, HelpType, String)
     * @see #getHelpType()
     * @see #setHelpText(String)
     */
    protected String getHelpText() {
        return helpText;
    }

    /**
     * Executes a task on the database thread with a blocking dialog (after 250
     * ms).
     * 
     * @param prefix the resource prefix (see class description for resources)
     * @param task block input while this {@link Task} is executing
     */
    protected void executeDatabaseTask(String prefix, Task<?, ?> task) {
        executeDatabaseTask(prefix, task, BlockingScope.WINDOW, this);
    }

    /**
     * Executes a task on the database thread with a blocking dialog (after 250
     * ms) when scope is either WINDOW or APPLICATION. In this case the
     * {@code target} is typically {@code this}, a component. If the scope is
     * ACTION, then the {@code target} is typically the action (for example,
     * {@code actionMap.get(LOOK_UP)}).
     * 
     * @param prefix the resource prefix (see class description for resources)
     * @param task execute this {@link Task}
     * @param scope how much of the GUI will be blocked
     * @param target the GUI element that will be blocked
     */
    protected void executeDatabaseTask(String prefix, Task<?, ?> task,
        Task.BlockingScope scope, Object target) {
        task.setInputBlocker(new KeplerInputBlocker(resourceMap, prefix, task,
            scope, target));
        appContext.getTaskService(DatabaseTaskService.NAME)
            .execute(task);
    }

    /**
     * Dismisses this panel's dialog.
     */
    protected void dismissDialog() {
        Dialog dialog = KeplerSwingUtilities.getDialog(this);
        if (dialog == null) {
            throw new IllegalStateException(String.format(
                "Could not find dialog for panel %s", this));
        }
        dialog.dispose();
    }

    /**
     * Log error and display error to user.
     * 
     * @param e the exception that got us here
     * @param action the action that was executed; it must have a resource with
     * a ".failed" suffix and may have a resource with a ".failed.secondary"
     * suffix
     * @param args the arguments used in the primary message; the exception's
     * message is passed to the secondary's message
     * @see KeplerDialogs#showErrorDialog(java.awt.Container, String, String)
     */
    public void handleError(Throwable e, String action, Object... args) {
        handleError(this, e, action, args);
    }

    /**
     * Log error and display error to user. The exception's messages will be
     * summarized both in the log message and in the dialog and a stack trace
     * will be logged.
     * 
     * @param parent the parent for the error dialog
     * @param e the exception that got us here; this can be {@code null} which
     * is useful if this method is called when an exception wasn't thrown
     * @param action the action that was executed; it must have a resource with
     * a ".failed" suffix and may have a resource with a ".failed.secondary"
     * suffix.
     * @param args the arguments used in the primary message; the exception's
     * message is passed to the secondary's message
     * @see KeplerDialogs#showErrorDialog(java.awt.Container, String, String)
     */
    protected void handleError(Container parent, Throwable e, String action,
        Object... args) {
        String primary = resourceMap.getString(action + ".failed", args);
        String secondary = resourceMap.getString(action + ".failed.secondary",
            exceptionMessages(e));
        log.error(primary + (secondary != null ? ": " + secondary : ""), e);
        KeplerDialogs.showErrorDialog(this, primary, secondary);
    }

    /**
     * Returns the messages of all of the throwables in {@code e} separated by
     * newlines.
     * 
     * @param e the exception that got us here
     * @return a newline separated string of messages, or an empty string if
     * there aren't any messages or they are all empty
     */
    private String exceptionMessages(Throwable e) {
        Throwable t = e;
        StringBuilder s = new StringBuilder();

        while (t != null) {
            if (s.length() > 0) {
                s.append("\n");
            }
            if (t.getMessage() != null) {
                String message = t.getMessage()
                    .trim();
                s.append(message);
                if (!(message.endsWith(".") || message.endsWith("!") || message.endsWith("?"))) {
                    s.append(".");
                }
            } else {
                s.append(e.getClass()
                    .getSimpleName());
            }
            t = t.getCause();
        }

        return s.toString();
    }

    /**
     * Enables or disables the given components as directed. This is not meant
     * to be called on components associated with bound enabled properties.
     * Their setters should already contain the necessary logic.
     * 
     * @param components the components
     * @param enabled {@code true} to enable the components, {@code false} to
     * disable the components
     * @throws NullPointerException if components is {@code null}
     */
    protected void enableComponents(List<JComponent> components, boolean enabled) {
        for (JComponent element : components) {
            element.setEnabled(enabled);
        }
    }

    /**
     * Sets the dirty flag as directed. As a side-effect, updates title (by
     * adding or removing the *) and calls {@link #updateEnabled()}.
     */
    protected void setDirty(boolean dirty) {
        this.dirty = dirty;

        // Strip modified character from title and set title with new status.
        String title = getTitle();
        if (title.startsWith(MODIFIED)) {
            title = title.substring(MODIFIED.length());
        }
        setTitle(dirty, title);

        updateEnabled();
    }

    /**
     * Has this panel been modified by the user?
     * 
     * @return {@code true} if this panel has been modified by the user;
     * otherwise {@code false}
     */
    protected boolean isDirty() {
        return dirty;
    }

    /**
     * Asks the user whether they wish to continue to do the potential damaging
     * operation they are doing.
     * 
     * @param prefix the resource prefix to use; there must be resources that
     * begin with this prefix and have the following suffixes: ".warn" (for the
     * primary message), ".warn.secondary" (optional, for the secondary
     * message), and ".warn.cancelled" (for the log message that is generated if
     * the user cancels)
     * @param args optional arguments for the secondary message
     * @return {@code true}, if the user wishes to cancel the damaging action,
     * {@code false} if it's OK to do so
     */
    protected boolean warnUser(String prefix, Object... args) {
        String actualPrefix = prefix + ".warn";
        String primary = resourceMap.getString(actualPrefix);
        String secondary = resourceMap.getString(actualPrefix + ".secondary",
            args);
        int n = KeplerDialogs.showConfirmDialog(this, primary, secondary, true);
        if (n != JOptionPane.OK_OPTION) {
            log.info(resourceMap.getString(prefix + ".cancelled"));
            return true;
        }
        return false;
    }

    /**
     * Returns the default focus component. Override this and return the
     * component in your panel that should initially get the focus. For example,
     * this is probably the first field.
     * 
     * @return the default focus component
     * @see #setDefaultFocusComponent(JComponent)
     */
    protected JComponent getDefaultFocusComponent() {
        return defaultFocusComponent;
    }

    /**
     * Sets the default focus component unless a subclass overrides
     * {@link #getDefaultFocusComponent()}.
     * 
     * @param defaultFocusComponent the new default focus component
     * @see #getDefaultFocusComponent()
     */
    public final void setDefaultFocusComponent(JComponent defaultFocusComponent) {
        this.defaultFocusComponent = defaultFocusComponent;
    }

    /**
     * Sets the components that should get the focus, as well as their focus
     * traversal order. The first component gets the initial focus.
     * 
     * @param focusTraversalOrder a non-{@code null} array of components
     */
    protected final void setFocusTraversalComponents(
        List<Component> focusTraversalOrder) {
        setFocusCycleRoot(true);
        setFocusTraversalPolicy(new DefinedFocusTraversalPolicy(
            focusTraversalOrder));
    }

    /**
     * A listener for changes to a text field that might update the state of the
     * dialog without necessary rendering it "dirty"
     * 
     * @see DirtyDocumentListener
     * 
     * @author Bill Wohler
     */
    private class UpdateDocumentListener implements DocumentListener {
        @Override
        public void changedUpdate(DocumentEvent e) {
        }

        /**
         * Check to see if any components should be enabled upon update.
         */
        @Override
        public void insertUpdate(DocumentEvent e) {
            updateEnabled();
        }

        /**
         * Check to see if any components should be enabled upon update.
         */
        @Override
        public void removeUpdate(DocumentEvent e) {
            updateEnabled();
        }
    }

    /**
     * A listener for changes to a text field that render the dialog "dirty".
     * 
     * @see UpdateDocumentListener
     * 
     * @author Bill Wohler
     */
    private class DirtyDocumentListener implements DocumentListener {
        @Override
        public void changedUpdate(DocumentEvent e) {
        }

        /**
         * Mark dialog dirty upon update.
         */
        @Override
        public void insertUpdate(DocumentEvent e) {
            setDirty(true);
        }

        /**
         * Mark dialog dirty upon update.
         */
        @Override
        public void removeUpdate(DocumentEvent e) {
            setDirty(true);
        }
    }

    /**
     * Event handler that invalidates the panel's data if the
     * {@link DatabaseTask} requests a {@link Function#REFRESH}.
     * 
     * @author Bill Wohler
     */
    private class UpdateHandler implements EventSubscriber<UpdateEvent<Object>> {

        @Override
        public void onEvent(UpdateEvent<Object> event) {
            log.debug(String.format("panel=%s, event=%s",
                KeplerPanel.this.getClass()
                    .getSimpleName(), event.toString()));

            // Because DatabaseTask is parameterized, Class.isAssignableFrom
            // doesn't seem to work here.
            if (event.get() instanceof DatabaseTask
                && event.getFunction() == Function.REFRESH) {
                setDataValid(false);
            }
        }
    }

    /**
     * Provides a focus traversal policy using an array of components. This
     * class requires that at least one component is enabled.
     * 
     * @author Bill Wohler
     */
    private static class DefinedFocusTraversalPolicy extends
        FocusTraversalPolicy {

        private List<Component> components;

        public DefinedFocusTraversalPolicy(List<Component> components) {
            if (components == null) {
                throw new NullPointerException("components can't be null");
            }
            this.components = components;
        }

        @Override
        public Component getComponentAfter(Container container,
            Component component) {
            int index = indexOf(component);
            int size = components.size();
            do {
                index++;
            } while (!components.get(index % size)
                .isEnabled());

            return components.get(index % size);
        }

        @Override
        public Component getComponentBefore(Container container,
            Component component) {
            int index = indexOf(component);
            do {
                if (--index < 0) {
                    index = components.size() - 1;
                }
            } while (!components.get(index)
                .isEnabled());

            return components.get(index);
        }

        private int indexOf(Component component) {
            int index = components.indexOf(component);
            if (index < 0) {
                // Editable JComboBox, for example.
                index = components.indexOf(component.getParent());
            }
            if (index < 0) {
                throw new IllegalStateException(
                    "Could not find component in focus list: " + component);
            }

            return index;
        }

        @Override
        public Component getDefaultComponent(Container container) {
            return getFirstComponent(container);
        }

        @Override
        public Component getFirstComponent(Container container) {
            return components.get(0);
        }

        @Override
        public Component getLastComponent(Container container) {
            return components.get(components.size() - 1);
        }
    }
}
