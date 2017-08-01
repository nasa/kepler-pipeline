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

import gov.nasa.kepler.ui.PipelineUIException;
import gov.nasa.kepler.ui.ons.etable.EShadedTable;
import gov.nasa.kepler.ui.ons.etable.ETable;

import java.awt.BorderLayout;
import java.awt.Dimension;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;

import javax.swing.JButton;
import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JPopupMenu;
import javax.swing.JScrollPane;
import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 * 
 */
@SuppressWarnings("serial")
public abstract class AbstractViewEditPanel extends javax.swing.JPanel {
    private static final Log log = LogFactory.getLog(AbstractViewEditPanel.class);

    protected JScrollPane scrollPane;
    protected JPopupMenu popupMenu;
    protected JMenuItem editMenuItem;
    protected JMenuItem newMenuItem;
    protected JMenuItem deleteMenuItem;
    protected JButton refreshButton;
    protected JButton newButton;
    private JPanel buttonPanel;
    protected ETable table;
    protected int selectedModelRow = -1;

    public AbstractViewEditPanel() throws PipelineUIException {
        super();
    }

    protected abstract AbstractTableModel getTableModel() throws PipelineUIException;
    
    protected abstract void doEdit(int row);
    protected abstract void doDelete(int row);
    protected abstract void doNew();
    protected abstract void doRefresh();
    
    protected abstract String getEditMenuText();
    protected abstract String getNewMenuText();
    protected abstract String getDeleteMenuText();

    private void newButtonActionPerformed(ActionEvent evt) {
        log.debug("newButton.actionPerformed, event="+evt);
        
        try{
            doNew();
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }
    
    private void refreshButtonActionPerformed(ActionEvent evt) {
        log.debug("refreshButton.actionPerformed, event="+evt);

        try{
            doRefresh();
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private void editMenuItemActionPerformed(ActionEvent evt) {
        log.debug("editMenuItem.actionPerformed, event=" + evt);
        log.debug("[PU] table row =" + selectedModelRow);

        try{
            doEdit(selectedModelRow);
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private void tableMouseClicked(MouseEvent evt) {
        log.debug("tableMouseClicked(MouseEvent) - start");

        if (evt.getClickCount() == 2) {
            log.debug("tableMouseClicked(MouseEvent) - [DOUBLE-CLICK] table.mouseClicked, event=" + evt);
            int tableRow = table.rowAtPoint(evt.getPoint());
            selectedModelRow = table.convertRowIndexToModel(tableRow);
            log.debug("tableMouseClicked(MouseEvent) - [DC] table row =" + selectedModelRow);

            try{
                doEdit(selectedModelRow);
            }catch(Exception e){
                JOptionPane.showMessageDialog(this, e, "Error",
                    JOptionPane.ERROR_MESSAGE);
            }
        }

        log.debug("tableMouseClicked(MouseEvent) - end");
    }

    private void deleteMenuItemActionPerformed(ActionEvent evt) {
        log.debug("deleteMenuItem.actionPerformed, event=" + evt);

        try{
            doDelete(selectedModelRow);
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private void newMenuItemActionPerformed(ActionEvent evt) {
        log.debug("newMenuItem.actionPerformed, event=" + evt);

        try{
            doNew();
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }
    
    protected void initGUI() throws PipelineUIException {
        log.debug("initGUI() - start");

        BorderLayout thisLayout = new BorderLayout();
        this.setLayout(thisLayout);
        setPreferredSize(new Dimension(400, 300));
        this.add(getScrollPane(), BorderLayout.CENTER);
        this.add(getButtonPanel(), BorderLayout.NORTH);

        log.debug("initGUI() - end");
    }

    private JScrollPane getScrollPane() throws PipelineUIException {
        log.debug("getUsersPanelScrollPane() - start");

        if (scrollPane == null) {
            scrollPane = new JScrollPane();
            scrollPane.setViewportView(getTable());
        }

        log.debug("getUsersPanelScrollPane() - end");
        return scrollPane;
    }

    private ETable getTable() throws PipelineUIException {
        log.debug("getUsersTable() - start");

        if (table == null) {
            table = new EShadedTable();
            table.setModel(getTableModel());
            table.addMouseListener(new MouseAdapter() {
                public void mouseClicked(MouseEvent evt) {
                    tableMouseClicked(evt);
                }
            });
            setComponentPopupMenu(table, getPopupMenu());
        }

        log.debug("getUsersTable() - end");
        return table;
    }

    /**
     * Auto-generated method for setting the popup menu for a component
     */
    private void setComponentPopupMenu(final java.awt.Component parent, final javax.swing.JPopupMenu menu) {
        log.debug("setComponentPopupMenu(java.awt.Component, javax.swing.JPopupMenu) - start");

        parent.addMouseListener(new java.awt.event.MouseAdapter() {
            public void mousePressed(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger()) {
                    menu.show(parent, e.getX(), e.getY());
                    int tableRow = table.rowAtPoint(e.getPoint());
                    // windows bug? works ok on Linux/gtk. Here's a workaround:
                    if (tableRow == -1) {
                        tableRow = table.getSelectedRow();
                    }
                    selectedModelRow = table.convertRowIndexToModel(tableRow);
                }
            }

            public void mouseReleased(java.awt.event.MouseEvent e) {
                if (e.isPopupTrigger()) {
                    menu.show(parent, e.getX(), e.getY());
                }
            }
        });

        log.debug("setComponentPopupMenu(java.awt.Component, javax.swing.JPopupMenu) - end");
    }

    protected JPopupMenu getPopupMenu() {
        log.debug("getUserMenu() - start");

        if (popupMenu == null) {
            popupMenu = new JPopupMenu();
            popupMenu.add(getEditMenuItem());
            popupMenu.add(getDeleteMenuItem());
            popupMenu.add(getNewMenuItem());
        }

        log.debug("getUserMenu() - end");
        return popupMenu;
    }

    private JMenuItem getEditMenuItem() {
        log.debug("getEditMenuItem() - start");

        if (editMenuItem == null) {
            editMenuItem = new JMenuItem();
            editMenuItem.setText(getEditMenuText());
            editMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    editMenuItemActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getEditMenuItem() - end");
        return editMenuItem;
    }

    private JMenuItem getDeleteMenuItem() {
        log.debug("getDeleteMenuItem() - start");

        if (deleteMenuItem == null) {
            deleteMenuItem = new JMenuItem();
            deleteMenuItem.setText(getDeleteMenuText());
            deleteMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    deleteMenuItemActionPerformed(evt);
                }
            });
        }

        log.debug("getDeleteMenuItem() - end");
        return deleteMenuItem;
    }

    private JMenuItem getNewMenuItem() {
        log.debug("getNewMenuItem() - start");

        if (newMenuItem == null) {
            newMenuItem = new JMenuItem();
            newMenuItem.setText(getNewMenuText());
            newMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    newMenuItemActionPerformed(evt);
                }
            });
        }

        log.debug("getNewMenuItem() - end");
        return newMenuItem;
    }
    
    protected JPanel getButtonPanel() {
        if(buttonPanel == null) {
            buttonPanel = new JPanel();
            FlowLayout buttonPanelLayout = new FlowLayout();
            buttonPanelLayout.setAlignment(FlowLayout.LEFT);
            buttonPanelLayout.setHgap(20);
            buttonPanel.setLayout(buttonPanelLayout);
            buttonPanel.add(getNewButton());
            buttonPanel.add(getRefreshButton());
        }
        return buttonPanel;
    }
    
    private JButton getNewButton() {
        if(newButton == null) {
            newButton = new JButton();
            newButton.setText("new");
            newButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    newButtonActionPerformed(evt);
                }
            });
        }
        return newButton;
    }
    
    private JButton getRefreshButton() {
        if(refreshButton == null) {
            refreshButton = new JButton();
            refreshButton.setText("refresh");
            refreshButton.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    refreshButtonActionPerformed(evt);
                }
            });
        }
        return refreshButton;
    }
}
