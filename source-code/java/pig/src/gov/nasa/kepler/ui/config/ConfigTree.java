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

package gov.nasa.kepler.ui.config;

import gov.nasa.kepler.ui.config.pipeline.PipelinesContainerNode;

import java.awt.Cursor;

import javax.swing.JOptionPane;
import javax.swing.JTree;
import javax.swing.event.TreeExpansionEvent;
import javax.swing.event.TreeExpansionListener;
import javax.swing.event.TreeSelectionEvent;
import javax.swing.event.TreeSelectionListener;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreePath;
import javax.swing.tree.TreeSelectionModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class implements the navigation tree for the config panel.
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ConfigTree extends JTree implements TreeSelectionListener, TreeExpansionListener {
    private static final Log log = LogFactory.getLog(ConfigTree.class);

    private DefaultTreeModel model = null;
    private ConfigDataPanel dataPanel = null;

    public enum TreeLabel{
        MODULE_LIBRARY("Module Library"),
        PARAMETER_LIBRARY("Parameter Library"),
        DATA_RECEIPT("Data Receipt"),
        DR_DISPATCHER_TRIGGER("Dispatcher Triggers"),
        DR_AVAILABLE_DATASETS("Available Datasets"),
        DR_DATA_ANOMALIES("Data Anomalies"),
        SECURITY("Security"),
        USERS("Users"),
        ROLES("Roles"),
        GENERAL("General");
        
        private String displayValue;

        private TreeLabel(String displayValue) {
            this.displayValue = displayValue;
        }
        public String toString() {
            return displayValue;
        }
    };

    public ConfigTree(ConfigDataPanel dataPanel) {
        super(initModel());

        this.dataPanel = dataPanel;
        model = (DefaultTreeModel) getModel();

        setRootVisible(false);
        putClientProperty("JTree.lineStyle", "Vertical");
        setShowsRootHandles(true);
        getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);

        this.addTreeSelectionListener(this);
        this.addTreeExpansionListener(this);
    }

    public void reloadModel() {
        setModel(initModel());
        model = (DefaultTreeModel) getModel();
        expandRow(3);
    }

    public static DefaultTreeModel initModel() {
        log.debug("initModel() - start");

        DefaultMutableTreeNode root = new DefaultMutableTreeNode("root");
        DefaultTreeModel model = new DefaultTreeModel(root);

        DefaultMutableTreeNode pipelines = new DefaultMutableTreeNode(new PipelinesContainerNode());
        root.add(pipelines);
        ((TreeContainerNode) pipelines.getUserObject()).init(pipelines);

        DefaultMutableTreeNode modules = new DefaultMutableTreeNode(TreeLabel.MODULE_LIBRARY);
        root.add(modules);

        DefaultMutableTreeNode moduleParamSets = new DefaultMutableTreeNode(TreeLabel.PARAMETER_LIBRARY);
        root.add(moduleParamSets);

        DefaultMutableTreeNode dataReceipt = new DefaultMutableTreeNode(TreeLabel.DATA_RECEIPT);
        root.add(dataReceipt);

        DefaultMutableTreeNode availableDatasets = new DefaultMutableTreeNode(TreeLabel.DR_AVAILABLE_DATASETS);
        dataReceipt.add(availableDatasets);

        DefaultMutableTreeNode dataAnomalies = new DefaultMutableTreeNode(TreeLabel.DR_DATA_ANOMALIES);
        dataReceipt.add(dataAnomalies);

        DefaultMutableTreeNode dispatcherTriggers = new DefaultMutableTreeNode(TreeLabel.DR_DISPATCHER_TRIGGER);
        dataReceipt.add(dispatcherTriggers);

        DefaultMutableTreeNode security = new DefaultMutableTreeNode(TreeLabel.SECURITY);
        root.add(security);

        DefaultMutableTreeNode users = new DefaultMutableTreeNode(TreeLabel.USERS);
        security.add(users);

        DefaultMutableTreeNode roles = new DefaultMutableTreeNode(TreeLabel.ROLES);
        security.add(roles);

        DefaultMutableTreeNode general = new DefaultMutableTreeNode(TreeLabel.GENERAL);
        root.add(general);

        log.debug("initModel() - end");
        return model;
    }

    public void valueChanged(TreeSelectionEvent event) {
        log.debug("valueChanged(TreeSelectionEvent) - start");

        log.debug("valueChanged, event=" + event);
        DefaultMutableTreeNode node = (DefaultMutableTreeNode) getLastSelectedPathComponent();

        if (node == null)
            return;

        Object nodeInfo = node.getUserObject();
        if (node.isLeaf()) {
            log.debug("leaf = " + nodeInfo + ", class = " + nodeInfo.getClass());
        } else {
            log.debug("folder = " + nodeInfo + ", class = " + nodeInfo.getClass());
        }

        setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
        dataPanel.treeSelectionEvent(nodeInfo);
        setCursor(null);

        log.debug("valueChanged(TreeSelectionEvent) - end");
    }

    public void treeExpanded(TreeExpansionEvent event) {
        log.debug("treeExpanded(TreeExpansionEvent) - start");

        log.debug("treeExpanded, event=" + event);
        DefaultMutableTreeNode node = null;
        TreePath path = event.getPath();
        node = (DefaultMutableTreeNode) (path.getLastPathComponent());
        log.debug("expanded node = " + node);

        Object userObject = node.getUserObject();
        if (userObject instanceof TreeContainerNode) {
            try {
                setCursor(Cursor.getPredefinedCursor(Cursor.WAIT_CURSOR));
                ((TreeContainerNode) userObject).expand(model, node);
                setCursor(null);
                scrollPathToVisible(new TreePath(((DefaultMutableTreeNode) node.getFirstChild()).getPath()));
            } catch (Exception e) {
                log.debug("caught e = ", e);
                JOptionPane.showMessageDialog(this, e, "Error", JOptionPane.ERROR_MESSAGE);
            }
        }

        log.debug("treeExpanded(TreeExpansionEvent) - end");
    }

    public void treeCollapsed(TreeExpansionEvent event) {
        log.debug("treeCollapsed(TreeExpansionEvent) - start");

        log.debug("treeCollapsed, event=" + event);

        log.debug("treeCollapsed(TreeExpansionEvent) - end");
    }
}