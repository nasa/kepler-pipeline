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

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPopupMenu;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public abstract class AbstractClonableViewEditPanel extends AbstractViewEditPanel {
    private static final Log log = LogFactory.getLog(AbstractClonableViewEditPanel.class);

    protected JMenuItem cloneMenuItem;
    protected JMenuItem renameMenuItem;

    private boolean supportsClone;
    private boolean supportsRename;

    public AbstractClonableViewEditPanel(boolean supportsClone, boolean supportsRename) throws PipelineUIException {
        this.supportsClone = supportsClone;
        this.supportsRename = supportsRename;
    }

    protected abstract void doClone(int row);
    protected abstract String getCloneMenuText(); 
    protected abstract void doRename(int row);
    protected abstract String getRenameMenuText(); 

    private void cloneMenuItemActionPerformed(ActionEvent evt) {
        try{
            doClone(selectedModelRow);
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    private void renameMenuItemActionPerformed(ActionEvent evt) {
        try{
            doRename(selectedModelRow);
        }catch(Exception e){
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    }

    protected void initGUI() throws PipelineUIException{
        super.initGUI();
        
        JPopupMenu menu = getPopupMenu();
        
        if(supportsClone){
            menu.add(getCloneMenuItem());
        }

        if(supportsRename){
            menu.add(getRenameMenuItem());
        }
    }
    
    protected JMenuItem getCloneMenuItem() {
        log.debug("getCloneMenuItem() - start");
    
        if (cloneMenuItem == null) {
            cloneMenuItem = new JMenuItem();
            cloneMenuItem.setText(getCloneMenuText());
            cloneMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");
    
                    cloneMenuItemActionPerformed(evt);
    
                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }
    
        log.debug("getCloneMenuItem() - end");
        return cloneMenuItem;
    }

    protected JMenuItem getRenameMenuItem() {
        log.debug("getRenameMenuItem() - start");
    
        if (renameMenuItem == null) {
            renameMenuItem = new JMenuItem();
            renameMenuItem.setText(getRenameMenuText());
            renameMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");
    
                    renameMenuItemActionPerformed(evt);
    
                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }
    
        log.debug("getRenameMenuItem() - end");
        return renameMenuItem;
    }
}
