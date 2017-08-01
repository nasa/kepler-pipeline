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

import gov.nasa.kepler.common.KeplerSocBranch;
import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.hibernate.CrudFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.services.User;
import gov.nasa.kepler.ui.common.LoginDialog;
import gov.nasa.kepler.ui.config.ConfigDataPanel;
import gov.nasa.kepler.ui.config.ConfigTree;
import gov.nasa.kepler.ui.metrilyzer.MetrilyzerPanel;
import gov.nasa.kepler.ui.mon.alerts.MonitoringAlertsPanel;
import gov.nasa.kepler.ui.mon.master.MasterStatusPanel;
import gov.nasa.kepler.ui.mon.master.StatusSummaryPanel;
import gov.nasa.kepler.ui.ops.instances.OpsInstancesPanel;
import gov.nasa.kepler.ui.ops.triggers.OpsTriggersPanel;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.CrudProxyExecutor;
import gov.nasa.kepler.ui.proxy.PigProxyFactory;
import gov.nasa.kepler.ui.proxy.UserCrudProxy;

import java.awt.BorderLayout;
import java.awt.Component;
import java.awt.FlowLayout;
import java.awt.Image;
import java.awt.Toolkit;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;

import javax.swing.JMenu;
import javax.swing.JMenuBar;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTabbedPane;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.jgoodies.looks.plastic.PlasticLookAndFeel;
import com.jgoodies.looks.plastic.theme.SkyBluer;

/**
 * The PIG (Pipeline Infrastructure GUI)
 * 
 * Used by the SOC operator to configure, launch, and monitor pipelines.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
@SuppressWarnings("serial")
public class PipelineConsole extends javax.swing.JFrame {
    private static final Log log = LogFactory.getLog(PipelineConsole.class);

    private static final int MAIN_WINDOW_HEIGHT = 900;
    private static final int MAIN_WINDOW_WIDTH = 1400;

    public static PipelineConsole instance = null;
    // public static DatabaseService databaseService = null;
    public static CrudProxyExecutor crudProxyExecutor = new CrudProxyExecutor();
    
    static {
        //Crud proxy will return proxies that run the crud methods in
        //using the crudProxyExecutor.
        CrudFactory.setProxyFactory(new PigProxyFactory());
    }

    public static User currentUser = null;

    private static String configName;

    private JTabbedPane consoleTabbedPane;
    private JPanel statusPanel;
    private JMenuBar consoleMenuBar;
    private JMenuItem helpMenuItem;
    private JMenu helpMenu;
    private JMenuItem exitMenuItem;
    private JMenu fileMenu;

    /** Config tab */
    private JPanel configDataPanel;
    private JSplitPane configSplitPane;
    private JScrollPane configDataScrollPane;
    private ConfigTree configTree2;
    private JScrollPane configTreeScrollPane;

    /** Operations tab */
    private JTabbedPane operationsTabbedPane;
    private OpsInstancesPanel opsInstancesPanel;
    private OpsTriggersPanel opsTriggersPanel;
    
    /** Monitoring tab */
    private JTabbedPane monitoringTabbedPane;
    private StatusSummaryPanel statusSummaryPanel;
    private MasterStatusPanel masterStatusPanel;
    private MonitoringAlertsPanel monitoringAlertsPanel;
    private MetrilyzerPanel metrilyzerPanel;
    
    /** If this property is true, require login even when running on
     * trunk code.  On non-trunk code, login is always required */
    private static final String REQUIRE_LOGIN_OVERRIDE = "pig.dev.require.login";


    {
        // Set Look & Feel
        try {

            PlasticLookAndFeel.setMyCurrentTheme(new SkyBluer());
            javax.swing.UIManager.setLookAndFeel("com.jgoodies.looks.plastic.Plastic3DLookAndFeel");
            // javax.swing.UIManager.setLookAndFeel("javax.swing.plaf.metal.MetalLookAndFeel");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    public static void showError(Component parent, Throwable e) {
        log.debug("caught e = ", e);
        JOptionPane.showMessageDialog(parent, e, "Error", JOptionPane.ERROR_MESSAGE);
    }

    public static void main(String[] args) {
        try {
            // setCursor( Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));

            if(args.length > 2){
                System.err.println("USAGE: pig [config override name]");
                System.exit(-1);
            }
            
            configName = "(default)";
            if(args.length == 1){
                String configOverrideName = args[0];
                System.setProperty(ConfigurationServiceFactory.CONFIG_SERVICE_OVERRIDE_NAME_PROP, configOverrideName);
                log.info("  ConfigName: " + configOverrideName);
                configName = "(" + configOverrideName + ")";
            }
            
            log.info(KeplerSocVersion.getProject());
            log.info("  Release: " + KeplerSocVersion.getRelease());
            log.info("  Revision: " + KeplerSocVersion.getRevision());
            log.info("  SVN URL: " + KeplerSocVersion.getUrl());
            log.info("  Build Date: " + KeplerSocVersion.getBuildDate());

            log.info("Initializing Configuration Service");
            ConfigurationServiceFactory.getInstance();

            // log.info("Initializing Messaging Service");
            // MessagingServiceFactory.getInstance();

            log.info("Initializing Database Service");
            try{
                CrudProxy.initialize();
            }catch(Throwable t){
                log.fatal("Failed to connect to the database, caught: " + t, t);
                System.exit(-1);
            }

            // setCursor(null);
            
            doLogin();
        } catch (Throwable e) {
            log.error("PipelineConsole.main", e);

            PipelineConsole.showError(null, e);
            System.exit(1);
        }

        PipelineConsole.instance = new PipelineConsole();
        PipelineConsole.instance.setVisible(true);
        PipelineConsole.instance.configSplitPane.setDividerLocation(0.25);
        PipelineConsole.instance.masterStatusPanel.getSplitPane().setDividerLocation(0.25);
    }

    private static void doLogin() {
        Configuration config = ConfigurationServiceFactory.getInstance();
        boolean devModeRequireLogin = config.getBoolean(REQUIRE_LOGIN_OVERRIDE, false);
        
        if(devModeRequireLogin || KeplerSocBranch.isRelease()){
            // require login
            currentUser  = LoginDialog.showLogin();
            
            if(currentUser == null){
                log.fatal("Exceeded max login attempts");
                System.exit(-1);
            }
        }else{
            UserCrudProxy userCrud = new UserCrudProxy();
            try {
                currentUser = userCrud.retrieveUser("socops");
            } catch (Throwable t) {
            }
        }
    }

    public PipelineConsole() {
        super();
        initGUI();
    }

    private void initGUI() {
        try {
            // START >> this
            this.setTitle("Kepler Science Pipeline Console " + configName);
            // END << this
            {
                this.addWindowListener(new WindowAdapter() {
                    public void windowClosing(WindowEvent evt) {
                        System.exit(0);
                    }
                });
            }
            setSize(MAIN_WINDOW_WIDTH, MAIN_WINDOW_HEIGHT);
            {
                consoleMenuBar = new JMenuBar();
                getContentPane().add(getStatusPanel(), BorderLayout.NORTH);
                getContentPane().add(getConsoleTabbedPane(), BorderLayout.CENTER);
                setJMenuBar(consoleMenuBar);
                consoleMenuBar.add(getFileMenu());
                consoleMenuBar.add(getHelpMenu());
            }
            {
                Toolkit kit = Toolkit.getDefaultToolkit();
                Image img = kit.createImage(ClassLoader.getSystemResource("gov/nasa/kepler/ui/swing/resources/nasa-logo.png"));
                setIconImage(img);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JTabbedPane getConsoleTabbedPane() {
        if (consoleTabbedPane == null) {
            consoleTabbedPane = new JTabbedPane();
            consoleTabbedPane.addTab("Configuration", null, getConfigSplitPane(), null);
            consoleTabbedPane.addTab("Operations", null, getOperationsTabbedPane(), null);
            consoleTabbedPane.addTab("Monitoring", null, getMonitoringTabbedPane(), null);
        }
        return consoleTabbedPane;
    }

    private JTabbedPane getOperationsTabbedPane() {
        if (operationsTabbedPane == null) {
            operationsTabbedPane = new JTabbedPane();
            operationsTabbedPane.addTab("Instances", null, getOpsInstancesPanel(), null);
            operationsTabbedPane.addTab("Triggers", null, getOpsTriggersPanel(), null);
        }
        return operationsTabbedPane;
    }

    private JTabbedPane getMonitoringTabbedPane() {
        if (monitoringTabbedPane == null) {
            monitoringTabbedPane = new JTabbedPane();
            monitoringTabbedPane.addTab("Status", null, getMasterStatusPanel(), null);
            monitoringTabbedPane.addTab("Alerts", null, getMonitoringAlertsPanel(), null);
            monitoringTabbedPane.addTab("Metrilyzer", null, getMetrilyzerPanel(), null);
        }
        return monitoringTabbedPane;
    }

    /**
     * Auto-generated method for setting the popup menu for a component
     */
    @SuppressWarnings("unused")
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger())
                    menu.show(parent, e.getX(), e.getY());
            }
        });
    }

    private JSplitPane getConfigSplitPane() {
        if (configSplitPane == null) {
            configSplitPane = new JSplitPane();
            configSplitPane.add(getConfigTreeScrollPane(), JSplitPane.LEFT);
            configSplitPane.add(getConfigDataScrollPane(), JSplitPane.RIGHT);
        }
        return configSplitPane;
    }

    private JMenu getFileMenu() {
        if (fileMenu == null) {
            fileMenu = new JMenu();
            fileMenu.setText("File");
            fileMenu.add(getExitMenuItem());
        }
        return fileMenu;
    }

    private JMenuItem getExitMenuItem() {
        if (exitMenuItem == null) {
            exitMenuItem = new JMenuItem();
            exitMenuItem.setText("Exit");
            exitMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    exitMenuItemActionPerformed(evt);
                }
            });
        }
        return exitMenuItem;
    }

    private JMenu getHelpMenu() {
        if (helpMenu == null) {
            helpMenu = new JMenu();
            helpMenu.setText("Help");
            helpMenu.add(getHelpMenuItem());
        }
        return helpMenu;
    }

    private JMenuItem getHelpMenuItem() {
        if (helpMenuItem == null) {
            helpMenuItem = new JMenuItem();
            helpMenuItem.setText("About");
            helpMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    helpMenuItemActionPerformed(evt);
                }
            });
        }
        return helpMenuItem;
    }

    private void exitMenuItemActionPerformed(ActionEvent evt) {
        System.exit(0);
    }

    private JScrollPane getConfigTreeScrollPane() {
        if (configTreeScrollPane == null) {
            configTreeScrollPane = new JScrollPane();
            configTreeScrollPane.setViewportView(getConfigTree());
            // configTreeScrollPane.getViewport().setViewSize( new
            // java.awt.Dimension(400, 200) );
        }
        return configTreeScrollPane;
    }

    public ConfigTree getConfigTree() {
        if (configTree2 == null) {
            configTree2 = new ConfigTree((ConfigDataPanel) getConfigDataPanel());
        }
        return configTree2;
    }

    private JScrollPane getConfigDataScrollPane() {
        if (configDataScrollPane == null) {
            configDataScrollPane = new JScrollPane();
            configDataScrollPane.setViewportView(getConfigDataPanel());
        }
        return configDataScrollPane;
    }

    private JPanel getConfigDataPanel() {
        if (configDataPanel == null) {
            configDataPanel = new ConfigDataPanel();
        }
        return configDataPanel;
    }

    private OpsTriggersPanel getOpsTriggersPanel() {
        if (opsTriggersPanel == null) {
            opsTriggersPanel = new OpsTriggersPanel();
        }
        return opsTriggersPanel;
    }

    private OpsInstancesPanel getOpsInstancesPanel() {
        if (opsInstancesPanel == null) {
            opsInstancesPanel = new OpsInstancesPanel();
        }
        return opsInstancesPanel;
    }

    private MonitoringAlertsPanel getMonitoringAlertsPanel() {
        if (monitoringAlertsPanel == null) {
            monitoringAlertsPanel = new MonitoringAlertsPanel();
        }
        return monitoringAlertsPanel;
    }

    private MetrilyzerPanel getMetrilyzerPanel() {
        if (metrilyzerPanel == null) {
            metrilyzerPanel = new MetrilyzerPanel();
        }
        return metrilyzerPanel;
    }

    private MasterStatusPanel getMasterStatusPanel() {
        if (masterStatusPanel == null) {
            masterStatusPanel = new MasterStatusPanel();
        }
        return masterStatusPanel;
    }

    private JPanel getStatusPanel() {
        if (statusPanel == null) {
            statusPanel = new JPanel();
            FlowLayout statusPanelLayout = new FlowLayout();
            statusPanelLayout.setAlignment(FlowLayout.RIGHT);
            statusPanel.setLayout(statusPanelLayout);
            statusPanel.add(getStatusSummaryPanel());
        }
        return statusPanel;
    }

    public StatusSummaryPanel getStatusSummaryPanel() {
        if (statusSummaryPanel == null) {
            statusSummaryPanel = new StatusSummaryPanel();
        }
        return statusSummaryPanel;
    }
    
    private void helpMenuItemActionPerformed(ActionEvent evt) {
        log.debug("helpMenuItem.actionPerformed, event="+evt);
        
        AboutPigDialog about = new AboutPigDialog(this);
        about.setVisible(true);
    }
}
