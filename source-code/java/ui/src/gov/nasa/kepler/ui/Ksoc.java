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

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.ui.cm.TargetManagementPanel;
import gov.nasa.kepler.ui.common.DatabaseTask;
import gov.nasa.kepler.ui.common.DatabaseTaskService;
import gov.nasa.kepler.ui.common.StatusEvent;
import gov.nasa.kepler.ui.ffi.FfiViewerPanel;
import gov.nasa.kepler.ui.gar.TableExportPanel;
import gov.nasa.kepler.ui.swing.ToolPanel;

import java.awt.event.ActionEvent;
import java.io.FileNotFoundException;
import java.util.LinkedHashMap;
import java.util.Map;

import javax.swing.JFrame;
import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.bushe.swing.event.EventBus;
import org.bushe.swing.event.EventSubscriber;
import org.bushe.swing.event.EventTopicSubscriber;
import org.jdesktop.application.Action;
import org.jdesktop.application.Application;
import org.jdesktop.application.ResourceMap;
import org.jdesktop.application.SingleFrameApplication;

/**
 * The main class for the Kepler Science Operations Console (KSOC).
 * 
 * @author Bill Wohler
 */
public class Ksoc extends SingleFrameApplication {
    private static final Log log = LogFactory.getLog(Ksoc.class);

    // Actions.
    public static final String FILE = "file";
    public static final String CLOSE = "close";
    public static final String QUIT = "quit";
    public static final String TOOLS = "tools";
    public static final String TARGET_MANAGEMENT = "targetManagement";
    public static final String TABLE_EXPORT = "tableExport";
    public static final String FFI_VIEWER = "ffiViewer";
    public static final String MONITORING = "monitoring";
    public static final String CONFIGURATION = "configuration";
    public static final String OPERATIONS = "operations";
    public static final String HELP = "help";
    public static final String ABOUT = "about";
    public static final String HELP_CONTENTS = "helpContents";

    private ResourceMap resourceMap = Application.getInstance()
        .getContext()
        .getResourceMap(getClass());

    /**
     * A map whose keys consist of the actions in this class used to display
     * tools. The values are each tool's panel's class. This map is used to
     * construct the Tools menu. The first item in this map (a
     * {@link LinkedHashMap} is considered the "default" and will be displayed
     * if this is the first time this application is run.
     */
    private Map<String, Class<? extends ToolPanel>> actionMap = new LinkedHashMap<String, Class<? extends ToolPanel>>();

    private ActionListener actionListener;
    private EventSubscriber<StatusEvent> statusListener;
    private boolean databaseInitialized;

    /**
     * Creates a Ksoc object.
     */
    public Ksoc() {
        // Initialize {@link #actionMap} object. The first tool in the list
        // is presented to the user the user the first time he runs this
        // application.
        actionMap.put(TARGET_MANAGEMENT, TargetManagementPanel.class);
        actionMap.put(TABLE_EXPORT, TableExportPanel.class);
        actionMap.put(FFI_VIEWER, FfiViewerPanel.class);
        // actionMap.put(MONITORING, MonitoringPanel.class);
        // actionMap.put(CONFIGURATION, ConfigurationPanel.class);
        // actionMap.put(OPERATIONS, OperationsPanel.class);
    }

    /**
     * Fire up the KSOC UI.
     * 
     * @param args the command line arguments
     */
    public static void main(String args[]) {
        Application.launch(Ksoc.class, args);
    }

    /**
     * Create the application.
     */
    //@edu.umd.cs.findbugs.annotations.SuppressWarnings("DM")
    @Override
    public void startup() {
        try {
            log.info(resourceMap.getString("startup"));
            actionListener = new ActionListener(this);
            statusListener = new StatusListener();
            createTaskService();

            if (loginRequired() && LoginPanel.login() == null) {
                System.exit(1);
            }

            JFrame frame = getMainFrame();
            frame.setJMenuBar(createMenu());
            KsocPanel panel = new KsocPanel(actionMap.values()
                .iterator()
                .next());
            show(panel);
            log.info(resourceMap.getString("startup.done"));
        } catch (Exception e) {
            log.error(resourceMap.getString("startup.failed", e.getMessage()),
                e);
            System.exit(1);
        }
    }

    /**
     * Creates a task service for database requests.
     */
    private void createTaskService() {
        EventBus.subscribe(StatusEvent.class, statusListener);
        Application.getInstance()
            .getContext()
            .addTaskService(new DatabaseTaskService());
    }

    private boolean loginRequired() {
        return !KeplerSocVersion.getRelease()
            .equals("trunk");
    }

    /**
     * Creates the menu bar.
     * 
     * @return the menu bar
     * @throws FileNotFoundException if any of the actions has an image and it
     * can't be found
     */
    private JMenuBar createMenu() throws FileNotFoundException {
        JMenuBar menuBar = new JMenuBar();

        // File Menu
        JMenu menu = new JMenu(action(FILE));
        menu.add(new JMenuItem(action(CLOSE)));
        menu.add(new JMenuItem(action(QUIT)));
        menuBar.add(menu);

        // Tools Menu
        menu = new JMenu(action(TOOLS));
        for (String s : actionMap.keySet()) {
            menu.add(new JMenuItem(getAction(s)));
        }
        menuBar.add(menu);

        // Help Menu
        menu = new JMenu(action(HELP));
        menu.add(new JMenuItem(action(ABOUT)));
        menu.add(new JMenuItem(action(HELP_CONTENTS)));
        menuBar.add(menu);

        return menuBar;
    }

    /**
     * Return action associated with given string. Subscribe to the topic
     * designated by the given string as well.
     * 
     * @param s the string used to obtain the action, as well as to be used as a
     * topic for publishing
     * @return the action
     */
    private javax.swing.Action action(String s) {
        javax.swing.Action action = getAction(s);
        log.debug("action(String) - Subscribing to " + s + "; returning "
            + action);
        EventBus.subscribe(s, actionListener);

        return action;
    }

    /**
     * Returns the action associated with the given string.
     * 
     * @param s the string used to obtain the action
     * @return the action
     */
    private javax.swing.Action getAction(String s) {
        javax.swing.Action returnAction = Application.getInstance()
            .getContext()
            .getActionMap()
            .get(s);

        return returnAction;
    }

    @Override
    protected void ready() {
        // Let the user know what is going on. While the DatabaseTaskService
        // does update the status bar, its initial message happens before the
        // status bar is created, so we reiterate the message here. Ideally,
        // we'd also create the DatabaseTaskService here, but it needs to be in
        // place before the UI is started (since the components read the
        // database as part of their initialization).
        if (!databaseInitialized) {
            EventBus.publish(new StatusEvent(this).message(
                resourceMap.getString("ready.initDb"))
                .started());
        }
    }

    @Override
    protected void shutdown() {
        log.info(resourceMap.getString("shutdown"));
        super.shutdown();

        try {
            DatabaseTask<Void, Void> closeDatabaseSessionTask = new DatabaseTask<Void, Void>() {
                @Override
                protected Void doInBackground() throws Exception {
                    DatabaseServiceFactory.getInstance()
                        .closeCurrentSession();
                    return null;
                }
            };
            Application.getInstance()
                .getContext()
                .getTaskService(DatabaseTaskService.NAME)
                .execute(closeDatabaseSessionTask);
        } catch (Exception e) {
            String message = resourceMap.getString("shutdown.cantCloseDb",
                e.getMessage());
            log.error(message, e);
        }
    }

    /**
     * Generate file menu.
     */
    @Action
    public void file() {
        log.info("Shouldn't happen");
    }

    /**
     * Closes panel.
     */
    @Action
    public void close() {
        log.info(resourceMap.getString(CLOSE));
        EventBus.publish(CLOSE, this);
    }

    /**
     * Calls exit.
     */
    @Action
    public void quit() {
        log.info(resourceMap.getString(QUIT));
        Application.getInstance()
            .exit();
    }

    /**
     * Generate tools menu.
     */
    @Action
    public void tools() {
        log.info("Shouldn't happen");
    }

    @Action
    public void targetManagement() {
        log.info(resourceMap.getString(TARGET_MANAGEMENT));
        EventBus.publish(actionMap.get(TARGET_MANAGEMENT));
    }

    @Action
    public void tableExport() {
        log.info(resourceMap.getString(TABLE_EXPORT));
        EventBus.publish(actionMap.get(TABLE_EXPORT));
    }

    @Action
    public void ffiViewer() {
        log.info(resourceMap.getString(FFI_VIEWER));
        EventBus.publish(actionMap.get(FFI_VIEWER));
    }

    @Action
    public void monitoring() {
        log.info(resourceMap.getString(MONITORING));
        EventBus.publish(actionMap.get(MONITORING));
    }

    @Action
    public void configuration() {
        log.info(resourceMap.getString(CONFIGURATION));
        EventBus.publish(actionMap.get(CONFIGURATION));
    }

    @Action
    public void operations() {
        log.info(resourceMap.getString(OPERATIONS));
        EventBus.publish(actionMap.get(OPERATIONS));
    }

    /**
     * Generate help menu.
     */
    @Action
    public void help() {
        log.info("Shouldn't happen");
    }

    /**
     * About action.
     */
    @Action
    public void about() {
        log.info(resourceMap.getString("about"));
    }

    /**
     * Help contents action.
     */
    @Action
    public void helpContents() {
        log.info(resourceMap.getString("helpContents"));
    }

    /**
     * Listens for actions that have been invoked by the user.
     * 
     * @author Bill Wohler
     */
    private class ActionListener implements EventTopicSubscriber {
        private Ksoc ksoc;

        public ActionListener(Ksoc ksoc) {
            this.ksoc = ksoc;
        }

        @Override
        public void onEvent(String topic, Object data) {
            log.debug("topic=" + topic + ", data=" + data);

            if (data == ksoc) {
                // Ignore events we generate to avoid loops.
                return;
            }
            javax.swing.Action action = getAction(topic);
            action.actionPerformed((ActionEvent) null);
        }
    }

    /**
     * Listens for the initialization of the {@code DatabaseTaskService}.
     * 
     * @author Bill Wohler
     */
    private class StatusListener implements EventSubscriber<StatusEvent> {

        @Override
        public void onEvent(StatusEvent event) {
            log.debug("event=" + event);
            if (event.getSource() instanceof DatabaseTaskService
                && event.isDone()) {
                databaseInitialized = true;
            }
        }
    }
}
