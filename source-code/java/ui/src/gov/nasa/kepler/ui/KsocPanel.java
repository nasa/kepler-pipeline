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

import gov.nasa.kepler.ui.common.UiException;
import gov.nasa.kepler.ui.swing.KeplerDialogs;
import gov.nasa.kepler.ui.swing.KeplerPanel;
import gov.nasa.kepler.ui.swing.ToolPanel;

import java.awt.Component;
import java.awt.event.ComponentEvent;
import java.awt.event.ComponentListener;
import java.text.MessageFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Map;

import javax.swing.Action;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.Icon;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JTabbedPane;

import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.bushe.swing.event.EventTopicSubscriber;
import org.jdesktop.application.SessionStorage;

/**
 * The main KSOC panel. This panel includes the toolbar and tabbed pane of
 * tools. To use, simply add to your frame. Tools must extend {@link ToolPanel}
 * and follow the contract specified in the class documentation.
 * 
 * @author Bill Wohler
 */
@SuppressWarnings("serial")
//@edu.umd.cs.findbugs.annotations.SuppressWarnings(value = "SE_BAD_FIELD_STORE")
public class KsocPanel extends KeplerPanel implements SessionStorage.Property {
    // Component names needed for SessionStorage to save objects in session.
    private static final String KSOC_PANEL_NAME = "ksocPanel";
    private static final String KSOC_TABBED_PANE_NAME = "ksocTabbedPane";

    private JTabbedPane tabbedPane;
    private EventSubscriber<Class<? extends ToolPanel>> toolHandler = new ToolHandler();
    private EventTopicSubscriber closeHandler = new CloseHandler();
    private ComponentListener menuHandler = new MenuHandler();
    private Map<Class<? extends ToolPanel>, ToolPanel> panelMap = new HashMap<Class<? extends ToolPanel>, ToolPanel>();

    /**
     * Creates a KsocPanel.
     * 
     * @param defaultTool the class of the initial tool to display.
     * @throws UiException if the panel could not be created.
     */
    public KsocPanel(Class<? extends ToolPanel> defaultTool) throws UiException {
        setName(KSOC_PANEL_NAME);

        tabbedPane = createTabbedPane();
        layOutComponents(tabbedPane, new KsocStatusBar());

        // Add the default panel, if the panel can be created without error.
        ToolPanel panel = getPanel(defaultTool);
        if (panel != null) {
            addPanel(panel);
        }

        // Subscribe to various actions.
        // Use instance variables because subscribe uses weak references.
        EventBus.subscribe(Class.class, toolHandler);
        EventBus.subscribe(Ksoc.CLOSE, closeHandler);
    }

    @Override
    protected void initComponents() {
    }

    @Override
    protected void updateEnabled() {
    }

    /**
     * Create a tabbed pane to hold all of the workspaces.
     * 
     * @return the tabbed pane
     */
    private JTabbedPane createTabbedPane() {
        JTabbedPane tabbedPane = new JTabbedPane();
        tabbedPane.setName(KSOC_TABBED_PANE_NAME);
        tabbedPane.setTabLayoutPolicy(JTabbedPane.SCROLL_TAB_LAYOUT);

        return tabbedPane;
    }

    /**
     * Lays out all components using a {@link GroupLayout}.
     * 
     * @param tabbedPane the tabbed pane.
     * @param statusBar the status bar.
     */
    private void layOutComponents(JTabbedPane tabbedPane,
        KsocStatusBar statusBar) {
        GroupLayout layout = new GroupLayout(this);

        layout.setHorizontalGroup(layout.createParallelGroup(Alignment.LEADING)
            .addComponent(tabbedPane)
            .addComponent(statusBar));
        layout.setVerticalGroup(layout.createSequentialGroup()
            .addComponent(tabbedPane)
            .addComponent(statusBar, GroupLayout.PREFERRED_SIZE,
                GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE));

        setLayout(layout);
    }

    /**
     * Restores the tabs in the saved view.
     * 
     * @param toolClasses a collection of {@link ToolPanel} class objects of the
     * tools that should be displayed.
     * @throws NullPointerException if {@code toolClasses} is {@code null}.
     */
    private void restoreView(Collection<Class<? extends ToolPanel>> toolClasses) {
        // Remove default panel.
        removePanel(panelMap.values()
            .iterator()
            .next());

        // Add panel(s) from previous session.
        for (Class<? extends ToolPanel> toolClass : toolClasses) {
            EventBus.publish(toolClass);
        }
    }

    /**
     * Adds the given panel to the tabbed pane.
     * 
     * @param panel the panel.
     */
    private void addPanel(ToolPanel panel) {
        Action action = panel.getAction(this);
        tabbedPane.addTab((String) action.getValue(Action.NAME),
            (Icon) action.getValue(Action.SMALL_ICON), panel,
            (String) action.getValue(Action.SHORT_DESCRIPTION));
        addMenu(panel);
        panel.addComponentListener(menuHandler);
    }

    /**
     * Removes the given panel from the tabbed pane.
     * 
     * @param panel the panel.
     */
    private void removePanel(ToolPanel panel) {
        tabbedPane.remove(panel);
        panel.removeComponentListener(menuHandler);
        removeMenu(panel);
    }

    /**
     * Adds a menu for the given panel.
     * 
     * @param panel the panel.
     */
    private void addMenu(ToolPanel panel) {
        JMenu menu = panel.getMenu();
        if (menu == null) {
            return;
        }

        JMenuBar menuBar = getMenuBar();
        for (int i = menuBar.getComponentCount(); i > 0; i--) {
            JMenu m = (JMenu) menuBar.getComponent(i - 1);
            // Append menu after the Tools menu.
            if (m.getAction() == getAction(Ksoc.TOOLS)) {
                menuBar.add(menu, i);
                menuBar.revalidate();
                return;
            }
        }

        throw new IllegalArgumentException("Could not find Tools menu");
    }

    /**
     * Removes a menu for the given panel.
     * 
     * @param panel the panel.
     */
    private void removeMenu(ToolPanel panel) {
        JMenu menu = panel.getMenu();
        if (menu == null) {
            return;
        }

        JMenuBar menuBar = getMenuBar();
        for (int i = menuBar.getComponentCount(); i > 0; i--) {
            JMenu m = (JMenu) menuBar.getComponent(i - 1);
            if (m.getText()
                .equals(menu.getText())) {
                menuBar.remove(i - 1);
                return;
            }
        }

        throw new IllegalArgumentException(MessageFormat.format(
            "Could not find {0} menu for removal", menu.getText()));
    }

    /**
     * Returns this application's menu bar.
     * 
     * @return a menu bar.
     */
    private JMenuBar getMenuBar() {
        return app.getMainFrame()
            .getJMenuBar();
    }

    /**
     * Returns a panel of the given tool class.
     * 
     * @return the tool's panel, or {@code null} on error.
     */
    private ToolPanel getPanel(Class<? extends ToolPanel> tool) {
        ToolPanel panel = panelMap.get(tool);

        // Create panel if it hasn't been created already.
        if (panel == null) {
            try {
                panel = tool.newInstance();
                panelMap.put(tool, panel);
            } catch (Exception e) {
                String primary = resourceMap.getString("getPanel.failed",
                    tool.getSimpleName());
                String secondary = resourceMap.getString(
                    "getPanel.failed.secondary", e.getMessage());
                if (e instanceof UiException) {
                    // Stack trace should have already been printed.
                    log.error(primary + ": " + secondary);
                } else {
                    // Show trace from an unexpected RuntimeException.
                    log.error(primary + ": " + secondary, e);
                }
                KeplerDialogs.showErrorDialog(this, primary, secondary);
            }
        }

        return panel;
    }

    /**
     * Returns a collection of visible tool class objects.
     * 
     * @param c this component. Unused.
     * @return a collection of {@link ToolPanel} class objects.
     * @see org.jdesktop.application.SessionStorage$Property#getSessionState(java.awt.Component)
     */
    @Override
    public Object getSessionState(Component c) {
        Component[] components = tabbedPane.getComponents();
        Collection<Class<? extends ToolPanel>> classes = new ArrayList<Class<? extends ToolPanel>>(
            components.length);
        for (Component component : components) {
            if (component instanceof ToolPanel) {
                ToolPanel panel = (ToolPanel) component;
                classes.add(panel.getClass());
            }
        }

        return classes;
    }

    /**
     * Restores the previous state.
     * 
     * @param c this component. Unused.
     * @param state a collection of {@link ToolPanel} class objects.
     * @see org.jdesktop.application.SessionStorage$Property#setSessionState(java.awt.Component,
     * java.lang.Object)
     */
    @Override
    @SuppressWarnings("unchecked")
    public void setSessionState(Component c, Object state) {
        restoreView((Collection<Class<? extends ToolPanel>>) state);
    }

    /**
     * Event handler that adds or removes menu items as tabs come and go.
     * 
     * @author Bill Wohler
     */
    private class MenuHandler implements ComponentListener {
        /**
         * Disable menu and toolbar icons for panel.
         */
        @Override
        public void componentHidden(ComponentEvent e) {
            removeMenu((ToolPanel) e.getComponent());
        }

        @Override
        public void componentMoved(ComponentEvent e) {
        }

        @Override
        public void componentResized(ComponentEvent e) {
        }

        /**
         * Enable menu and toolbar icons for panel.
         */
        @Override
        public void componentShown(ComponentEvent e) {
            addMenu((ToolPanel) e.getComponent());
        }
    }

    /**
     * Event handler that adds a new tab, or brings it to bear.
     * 
     * @author Bill Wohler
     */
    private class ToolHandler implements
        EventSubscriber<Class<? extends ToolPanel>> {
        @Override
        public void onEvent(Class<? extends ToolPanel> panelClass) {
            log.debug(panelClass);
            if (!ToolPanel.class.isAssignableFrom(panelClass)) {
                return;
            }

            ToolPanel panel = getPanel(panelClass);
            if (panel != null) {
                if (tabbedPane.indexOfComponent(panel) < 0) {
                    // Tool isn't already present. Add it.
                    addPanel(panel);
                }

                // Select the tool, in any case.
                tabbedPane.setSelectedComponent(panel);
            }
        }
    }

    /**
     * Event handler that closes the current tab, or invokes the quit action if
     * the current tab is the last tab standing.
     * 
     * @author Bill Wohler
     */
    private class CloseHandler implements EventTopicSubscriber {
        @Override
        public void onEvent(String topic, Object data) {
            log.debug("topic=" + topic + ", data=" + data);
            ToolPanel panel = (ToolPanel) tabbedPane.getComponentAt(tabbedPane.getSelectedIndex());
            removePanel(panel);
            if (tabbedPane.getTabCount() == 0) {
                EventBus.publish(Ksoc.QUIT, this);
            }
        }
    }
}
