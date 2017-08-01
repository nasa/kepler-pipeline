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

package gov.nasa.kepler.ui.mon.master;

import gov.nasa.kepler.pi.worker.WorkerStatusMessage;
import gov.nasa.kepler.services.process.ProcessStatusMessage;
import gov.nasa.kepler.services.process.StatusMessage;
import gov.nasa.kepler.ui.ons.outline.DefaultOutlineModel;
import gov.nasa.kepler.ui.ons.outline.Outline;
import gov.nasa.kepler.ui.ons.outline.OutlineModel;
import gov.nasa.kepler.ui.ons.outline.RenderDataProvider;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.HashMap;
import java.util.Map;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.WindowConstants;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.TreePath;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * {@link StatusPanel} for pipeline processes and worker threads. Status
 * information is displayed using {@link Outline}
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public class ProcessesStatusPanel extends StatusPanel {
    private static final Log log = LogFactory.getLog(ProcessesStatusPanel.class);

    private JScrollPane processesScrollPane;
    private JButton clearButton;
    private Outline processesOutline;
    private JPanel buttonPanel;

    private DefaultTreeModel treeModel;

    private OutlineModel outlineModel;
    private JButton collapseAllButton;
    private JButton expandAllButton;

    private Map<String, StatusNode> statusNodes = new HashMap<String, StatusNode>();

    private DefaultMutableTreeNode rootTreeNode;

    public ProcessesStatusPanel() {
        super();
        initGUI();
    }

    @Override
    public void update(StatusMessage statusMessage) {

        String key = statusMessage.uniqueKey();
        StatusNode node = statusNodes.get(key);
        if (node == null) {

            // new node
            StatusNode newNode = null;
            
            DefaultMutableTreeNode parent = null;
            
            if (statusMessage instanceof ProcessStatusMessage) {
                newNode = new ProcessNode((ProcessStatusMessage) statusMessage);

                // add to root of tree
                parent = rootTreeNode;
            } else if (statusMessage instanceof WorkerStatusMessage) {
                String parentKey = statusMessage.getSourceProcess().getKey();
                StatusNode parentNode = statusNodes.get(parentKey);
                
                if(parentNode == null){
                    /* we haven't gotten a ProcessStatusMessage from this worker
                     * yet, so we have nowhere to put this node.  Discard for now
                     * and we'll process the next one.*/
                    return;
                }

                newNode = new WorkerThreadNode((WorkerStatusMessage) statusMessage);

                // add to owning process node
                parent = parentNode.getTreeNode();
            }

            statusNodes.put(key, newNode);
            
            DefaultMutableTreeNode childNode = new DefaultMutableTreeNode(newNode);
            newNode.setTreeNode(childNode);
            
            int index = parent.getChildCount();
            treeModel.insertNodeInto(childNode, parent, index);
            processesOutline.expandPath(new TreePath(childNode.getPath()));
        }else{
            node.update(statusMessage);
            treeModel.nodeChanged(node.getTreeNode());
        }
    }

    private void clearButtonActionPerformed(ActionEvent evt) {
        log.debug("clearButton.actionPerformed, event=" + evt);

        statusNodes = new HashMap<String, StatusNode>();
        
        rootTreeNode = new DefaultMutableTreeNode("");
        treeModel.setRoot(rootTreeNode);
    }

    private void expandAllButtonActionPerformed(ActionEvent evt) {
        log.debug("expandAllButton.actionPerformed, event="+evt);
        
        int numKids = rootTreeNode.getChildCount();
        for (int kidIndex = 0; kidIndex < numKids; kidIndex++) {
            DefaultMutableTreeNode kid = (DefaultMutableTreeNode) rootTreeNode.getChildAt(kidIndex);
            processesOutline.expandPath(new TreePath(kid.getPath()));
        }
    }
    
    private void collapseAllButtonActionPerformed(ActionEvent evt) {
        log.debug("collapseAllButton.actionPerformed, event="+evt);
        
        int numKids = rootTreeNode.getChildCount();
        for (int kidIndex = 0; kidIndex < numKids; kidIndex++) {
            DefaultMutableTreeNode kid = (DefaultMutableTreeNode) rootTreeNode.getChildAt(kidIndex);
            processesOutline.collapsePath(new TreePath(kid.getPath()));
        }
    }

    private void initGUI() {
        try {
            BorderLayout thisLayout = new BorderLayout();
            this.setLayout(thisLayout);
            // setPreferredSize(new Dimension(400, 300));
            this.add(getProcessesScrollPane(), BorderLayout.CENTER);
            this.add(getButtonPanel(), BorderLayout.NORTH);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private JScrollPane getProcessesScrollPane() {
        if (processesScrollPane == null) {
            processesScrollPane = new JScrollPane();
            processesScrollPane.setViewportView(getProcessesOutline());
        }
        return processesScrollPane;
    }

    private JPanel getButtonPanel() {
        if (buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setAlignment(FlowLayout.LEFT);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getClearButton());
            buttonPanel.add(getExpandAllButton());
            buttonPanel.add(getCollapseAllButton());
        }
        return buttonPanel;
    }

    private JButton getClearButton() {
        if (clearButton == null) {
            clearButton = new JButton();
            clearButton.setText("clear");
            clearButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    clearButtonActionPerformed(evt);
                }
            });
        }
        return clearButton;
    }

    private Outline getProcessesOutline() {
        if (processesOutline == null) {
            
            rootTreeNode = new DefaultMutableTreeNode("");
            treeModel = new DefaultTreeModel(rootTreeNode);
            
            outlineModel = DefaultOutlineModel.createOutlineModel(treeModel, new StatusRowModel(), false,
                "SOC Processes");

            processesOutline = new Outline();
            // if true, nothing is displayed
            //processesOutline.setRootVisible(false);
            processesOutline.setModel(outlineModel);
            processesOutline.setRenderDataProvider(new RenderData());  
            processesOutline.expandPath(new TreePath(rootTreeNode.getPath()));
        }
        return processesOutline;
    }
    
    private class RenderData implements RenderDataProvider {

        @Override
        public java.awt.Color getBackground(Object o) {
            return null;
        }

        @Override
        public String getDisplayName(Object o) {
            DefaultMutableTreeNode treeNode = (DefaultMutableTreeNode)o;
            Object userObject = treeNode.getUserObject();
            
            if(userObject instanceof String){
                return (String) userObject;
            }else if(userObject instanceof StatusNode){
                StatusNode node = (StatusNode) userObject;
                return (node.toString());
            }else{
                return "huh?";
            }
        }

        @Override
        public java.awt.Color getForeground(Object o) {
            Object node = ((DefaultMutableTreeNode)o).getUserObject();
            
            if (node instanceof WorkerThreadNode) {
                return Color.GRAY;
            }
            return null;
        }

        @Override
        public javax.swing.Icon getIcon(Object o) {
            // TODO: use age-colored balls
            return null;
        }

        @Override
        public String getTooltipText(Object o) {
            return ("");
        }

        @Override
        public boolean isHtmlDisplayName(Object o) {
            return false;
        }
    }

    /**
     * This method should return an instance of this class which does NOT
     * initialize it's GUI elements. This method is ONLY required by Jigloo if
     * the superclass of this class is abstract or non-public. It is not needed
     * in any other situation.
     */
    public static Object getGUIBuilderInstance() {
        return new ProcessesStatusPanel(Boolean.FALSE);
    }

    /**
     * This constructor is used by the getGUIBuilderInstance method to provide
     * an instance of this class which has not had it's GUI elements initialized
     * (ie, initGUI is not called in this constructor).
     */
    public ProcessesStatusPanel(Boolean initGUI) {
        super();
    }

    /**
     * Auto-generated main method to display this JPanel inside a new JFrame.
     */
    public static void main(String[] args) {
        JFrame frame = new JFrame();
        frame.getContentPane()
            .add(new ProcessesStatusPanel());
        frame.setDefaultCloseOperation(WindowConstants.DISPOSE_ON_CLOSE);
        frame.pack();
        frame.setVisible(true);
    }
    
    private JButton getExpandAllButton() {
        if(expandAllButton == null) {
            expandAllButton = new JButton();
            expandAllButton.setText("+");
            expandAllButton.setToolTipText("Expand All");
            expandAllButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    expandAllButtonActionPerformed(evt);
                }
            });
        }
        return expandAllButton;
    }
    
    private JButton getCollapseAllButton() {
        if(collapseAllButton == null) {
            collapseAllButton = new JButton();
            collapseAllButton.setText("-");
            collapseAllButton.setToolTipText("Collapse All");
            collapseAllButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    collapseAllButtonActionPerformed(evt);
                }
            });
        }
        return collapseAllButton;
    }
}
