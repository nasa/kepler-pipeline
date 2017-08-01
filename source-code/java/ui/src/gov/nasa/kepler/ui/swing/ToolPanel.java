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

import gov.nasa.kepler.ui.common.UiException;

import java.awt.Insets;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.List;

import javax.swing.Action;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Group;
import javax.swing.JButton;
import javax.swing.JMenu;
import javax.swing.JMenuItem;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;

/**
 * An abstract class for tool panels. A tool is a major application within the
 * KSOC framework. To use, override each abstract method. See the method
 * documentation for specifics.
 * <p>
 * Tool panels are also required to call {@link #setName} using the name of the
 * action which invokes them plus the string "Panel" (for example,
 * "targetManagementPanel"). This logic is used by the {@link #getAction()}
 * method to access the tool's action from its name, while having a separate
 * name to avoid errors when the application framework injects properties
 * <p>
 * Since not all panels will be used by all users, try to keep the static memory
 * usage down to a minimum. A user may view a panel briefly and then dismiss it;
 * therefore, caching items staticly isn't recommended either.
 * 
 * @author Bill Wohler
 */
public abstract class ToolPanel extends KeplerPanel {

    private static final long serialVersionUID = 1L;

    /**
     * Creates a {@link ToolPanel}.
     * 
     * @throws UiException if the configuration object could not be created.
     */
    public ToolPanel() throws UiException {
    }

    /**
     * Character used as prefix in front of action name that serves as default
     * action for panel. For example, a string returned by
     * {@link #getActionStrings()} might return "*edit" as one of its strings so
     * that double-clicking on an item might invoke the edit function.
     */
    protected static final char DEFAULT_ACTION_CHAR = '*';

    private List<JButton> toolBarButtons;
    private JMenu menu;
    private JPopupMenu popupMenu;
    private Action defaultAction;

    /**
     * Returns the action associated with this panel. This can be used to
     * enable/disable the menu item, for example.
     * <p>
     * For this to work, subclasses must set the name of their panel using the
     * name of the action which invokes them plus the string "Panel" (for
     * example, "targetManagementPanel").
     * 
     * @see #getAction(Object)
     * @return the action.
     */
    public Action getAction() {
        return getAction(this);
    }

    /**
     * Returns the action associated with this panel for the specified
     * {@code actionsObject}. This can be used to enable/disable the menu item,
     * for example.
     * <p>
     * For this to work, subclasses must set the name of their panel using the
     * name of the action which invokes them plus the string "Panel" (for
     * example, "targetManagementPanel").
     * 
     * @param actionsObject the object that contains the action
     * @return the action.
     */
    public Action getAction(Object actionsObject) {
        return getAction(actionsObject, getActionName());
    }

    /**
     * Gets the panel's action name.
     * 
     * @see #getAction()
     * @return the panel's action name.
     */
    private String getActionName() {
        String name = getName();
        // Assert that panels are named action + "Panel", and strip Panel
        // before lookup.
        if (name.endsWith("Panel")) {
            name = name.substring(0, name.indexOf("Panel"));
        } else {
            throw new IllegalArgumentException(MessageFormat.format(
                "Name of panel must end in Panel: {0}", this));
        }

        return name;
    }

    /**
     * Returns a list of actions for this panel.
     * 
     * @return a non-<code>null</code> list of actions associated with the menu
     * items and toolbar buttons for this panel.
     */
    public List<Action> getActions() {
        List<Action> actions = new ArrayList<Action>();
        for (String s : getActionStrings()) {
            actions.add(getAction(stripDefaultActionChar(s)));
        }

        return actions;
    }

    /**
     * Strip default action character if it exists. For example:
     * 
     * <pre>
     *  stripDefaultActionChar(&quot;*foo&quot;) -&gt; &quot;foo&quot;
     * stripDefaultActionChar(&quot;foo&quot;) -&gt; &quot;foo&quot;
     * </pre>
     * 
     * @see #DEFAULT_ACTION_CHAR
     * @param s the original string.
     * @return a string without a leading "*".
     */
    private String stripDefaultActionChar(String s) {
        if (s.charAt(0) == DEFAULT_ACTION_CHAR) {
            return s.substring(1);
        }

        return s;
    }

    /**
     * Returns a list of action strings for this panel. Precede one of the
     * strings with {@link #DEFAULT_ACTION_CHAR}, an asterisk, as in "*edit", to
     * indicate the panel's default action. A default action is one that should
     * be invoked if the user double-clicks on an item, for example.
     * 
     * @see #getDefaultAction()
     * @return a non-<code>null</code> list of strings; if empty, no menu or
     * toolbar buttons are created.
     */
    protected abstract List<String> getActionStrings();

    /**
     * Returns a menu for this tool. This menu is appended to the main menu bar
     * after the Tools menu.
     * 
     * @return a menu, which may be null to indicate that this tool doesn't have
     * a menu to add.
     */
    public final JMenu getMenu() {
        if (menu != null) {
            return menu;
        }

        List<Action> actions = getActions();
        if (actions.size() == 0) {
            return null;
        }

        menu = new JMenu(getAction(getActionName()));
        for (Action action : actions) {
            menu.add(new JMenuItem(action));
        }

        return menu;
    }

    /**
     * Returns a popup menu for this tool.
     * 
     * @return a popup menu, which may be null to indicate that this tool
     * doesn't have a menu to add.
     */
    public final JPopupMenu getPopupMenu() {
        if (popupMenu != null) {
            return popupMenu;
        }

        List<Action> actions = getActions();
        if (actions.size() == 0) {
            return null;
        }

        popupMenu = new JPopupMenu();
        for (Action action : actions) {
            popupMenu.add(new JMenuItem(action));
        }

        return popupMenu;
    }

    /**
     * Creates a toolbar for this panel. It is up to the panel to actually
     * position it.
     * 
     * @return a tool bar.
     */
    public JPanel getToolBar() {
        // Create (possibly empty) toolbar with a group layout.
        JPanel toolBar = new JPanel();
        GroupLayout layout = new GroupLayout(toolBar);
        toolBar.setLayout(layout);
        Group horizontalGroup = layout.createSequentialGroup();
        layout.setHorizontalGroup(horizontalGroup);
        Group verticalGroup = layout.createParallelGroup();
        layout.setVerticalGroup(verticalGroup);

        List<JButton> buttons = getToolBarButtons();
        if (buttons.size() == 0) {
            return toolBar;
        }

        // Add tool's buttons to toolbar.
        for (JButton button : buttons) {
            button.setMargin(new Insets(0, 0, 0, 0));
            horizontalGroup.addComponent(button);
            verticalGroup.addComponent(button);
        }

        return toolBar;
    }

    /**
     * Returns a list of toolbar buttons for this tool. These buttons are placed
     * in their own button group and are appended to the main toolbar. However,
     * if a large icon is not defined for an action, a button is not created.
     * These buttons are cached so that subsequent calls will retrieve the same
     * buttons. Panels can therefore call this method and use the equality
     * operator (==) to test which buttons to remove, for example.
     * 
     * @return a non-<code>null</code> list of buttons, which may be empty to
     * indicate that this tool doesn't have any buttons to add.
     */
    private final List<JButton> getToolBarButtons() {
        if (toolBarButtons != null) {
            return toolBarButtons;
        }

        toolBarButtons = new ArrayList<JButton>();
        for (String s : getActionStrings()) {
            Action action = getAction(stripDefaultActionChar(s));
            if (action.getValue(Action.LARGE_ICON_KEY) == null) {
                continue;
            }
            JButton button = new JButton(action);
            button.setHideActionText(true);
            toolBarButtons.add(button);
        }

        return toolBarButtons;
    }

    /**
     * Returns the default action for this panel, if one is defined.
     * 
     * @see #getActionStrings()
     * @return the default action, or <code>null</code> if one is not defined.
     */
    public Action getDefaultAction() {
        if (defaultAction == null) {
            for (String s : getActionStrings()) {
                if (s.charAt(0) == DEFAULT_ACTION_CHAR) {
                    defaultAction = getAction(stripDefaultActionChar(s));
                    break;
                }
            }
        }

        return defaultAction;
    }
}
