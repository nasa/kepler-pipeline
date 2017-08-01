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

package gov.nasa.kepler.ui.config.pipeline;

import gov.nasa.kepler.hibernate.pi.Group;
import gov.nasa.kepler.hibernate.pi.PipelineDefinition;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.PipelineUIException;
import gov.nasa.kepler.ui.config.AbstractClonableViewEditPanel;
import gov.nasa.kepler.ui.config.group.GroupSelectorDialog;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.PipelineDefinitionCrudProxy;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.JMenuItem;
import javax.swing.JOptionPane;
import javax.swing.JPopupMenu;
import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class PipelinesViewEditPanel extends AbstractClonableViewEditPanel {
	private static final Log log = LogFactory.getLog(PipelinesViewEditPanel.class);

	private PipelinesTableModel pipelinesTableModel; // do NOT init to null! (see getTableModel)
    private PipelineDefinitionCrudProxy pipelineDefinitionCrud;

    private JMenuItem versionMenuItem;

    private JMenuItem groupMenuItem;
    
	public PipelinesViewEditPanel() throws PipelineUIException {
	    super(true,true);
	    
        pipelineDefinitionCrud = new PipelineDefinitionCrudProxy();

        initGUI();
		
        JPopupMenu menu = getPopupMenu();
        menu.add(getVersionMenuItem());
        menu.add(getGroupMenuItem());

	}

    @Override
    protected void doNew() {
        log.debug("doNew() - start");
    
        try {
            String newPipelineName = (String)JOptionPane.showInputDialog(
                PipelineConsole.instance, "Enter the name for the new Pipeline Definition",
                "New Pipeline Definition",
                JOptionPane.PLAIN_MESSAGE);
            
            if(newPipelineName == null || newPipelineName.length() == 0){
                JOptionPane.showMessageDialog( this, "Please enter a pipeline name", "Error", JOptionPane.ERROR_MESSAGE );
                return;
            }

            showEditDialog(new PipelineDefinition(newPipelineName));
            
            pipelinesTableModel.loadFromDatabase();
            
            PipelineConsole.instance.getConfigTree().reloadModel();
            
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doNew() - end");
    }


    @Override
    protected void doClone(int row) {
        log.debug("doClone() - start");
    
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        PipelineDefinition selectedPipeline = pipelinesTableModel.getPipelineAtRow( row );
        
        try {
            String newPipelineName = (String)JOptionPane.showInputDialog(
                PipelineConsole.instance, "Enter the name for the new Pipeline Definition",
                "New Pipeline Definition",
                JOptionPane.PLAIN_MESSAGE);
            
            if(newPipelineName == null || newPipelineName.length() == 0){
                JOptionPane.showMessageDialog( this, "Please enter a pipeline name", "Error", JOptionPane.ERROR_MESSAGE );
                return;
            }
            
            PipelineDefinition newPipelineDefinition = new PipelineDefinition(selectedPipeline);
            newPipelineDefinition.rename(newPipelineName);
                
            showEditDialog(newPipelineDefinition);
            
            pipelinesTableModel.loadFromDatabase();
            
            PipelineConsole.instance.getConfigTree().reloadModel();
            
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doClone() - end");
    }

    @Override
    protected void doRename(int row) {
        log.debug("doRename() - start");
        
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        PipelineDefinition selectedPipeline = pipelinesTableModel.getPipelineAtRow( row );
        
        try {
            String newPipelineName = (String)JOptionPane.showInputDialog(
                PipelineConsole.instance, "Enter the new name for this Pipeline Definition",
                "Rename Pipeline Definition",
                JOptionPane.PLAIN_MESSAGE);
            
            if(newPipelineName == null || newPipelineName.length() == 0){
                JOptionPane.showMessageDialog( this, "Please enter a pipeline name", "Error", JOptionPane.ERROR_MESSAGE );
                return;
            }
            
            pipelineDefinitionCrud.rename(selectedPipeline, newPipelineName);
            pipelinesTableModel.loadFromDatabase();
            
            PipelineConsole.instance.getConfigTree().reloadModel();
            
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doRename() - end");
    }

    private void doVersion(int row) {
        log.debug("doVersion() - start");
    
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        PipelineDefinition selectedPipeline = pipelinesTableModel.getPipelineAtRow( row );
        
        try {
            PipelineDefinition newPipelineDefinition = selectedPipeline.newVersion();
            
            PipelineDefinitionCrudProxy pipelineDefCrud = new PipelineDefinitionCrudProxy();
            pipelineDefCrud.save(newPipelineDefinition);
            
            pipelinesTableModel.loadFromDatabase();

            PipelineConsole.instance.getConfigTree().reloadModel();
            
        } catch (Exception e) {
            log.error("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doVersion() - end");
    }

    private void doGroup(int row) {
        log.debug("doGroup() - start");
            
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        try {
            PipelineDefinition selectedPipeline = pipelinesTableModel.getPipelineAtRow( row );
            Group selectedGroup = GroupSelectorDialog.selectGroup();
            
            if(selectedGroup != null){
                selectedPipeline.setGroup(selectedGroup);
                PipelineDefinitionCrudProxy pipelineDefCrud = new PipelineDefinitionCrudProxy();
                pipelineDefCrud.saveChanges(selectedPipeline);
            }
            
            pipelinesTableModel.loadFromDatabase();

            PipelineConsole.instance.getConfigTree().reloadModel();
            
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doGroup() - end");
    }

    @Override
    protected void doEdit(int row) {
    	log.debug("doEdit(int) - start");
    
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

    	showEditDialog( pipelinesTableModel.getPipelineAtRow( row ));
        
        pipelinesTableModel.loadFromDatabase();
    
    	log.debug("doEdit(int) - end");
    }

    @Override
    protected void doDelete(int row) {
    	log.debug("doDelete(int) - start");
    
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

    	PipelineDefinition pipeline = pipelinesTableModel.getPipelineAtRow( row );
    	
        if (!pipeline.isLocked()) {

            int choice = JOptionPane.showConfirmDialog( this, 
                    "Are you sure you want to delete pipeline '" + pipeline.getName() + "'?");
        
            if( choice == JOptionPane.YES_OPTION ){
                try {
                    pipelineDefinitionCrud.deletePipeline( pipeline );
                    pipelinesTableModel.loadFromDatabase();
                    PipelineConsole.instance.getConfigTree().reloadModel();
                } catch (Exception e) {
                    log.debug("caught e = ", e );
                    JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
                }
            }
        } else {
            JOptionPane.showMessageDialog(this, "Can't delete a locked pipeline definition.  Pipeline definitions are locked when referenced by a pipeline instance", "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    
    	log.debug("doDelete(int) - end");
    }


    /* (non-Javadoc)
     * @see gov.nasa.kepler.ui.config.GenericViewEditPanel#doRefresh()
     */
    @Override
    protected void doRefresh() {
        try {
            pipelinesTableModel.loadFromDatabase();
            PipelineConsole.instance.getConfigTree().reloadModel();
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    }

    private void showEditDialog( PipelineDefinition pipeline ){
    	log.debug("showEditDialog() - start");
    
    	try {
    		PipelineEditDialog inst = new PipelineEditDialog( PipelineConsole.instance, pipeline );
    		
    		inst.setVisible(true);
    	} catch (Exception e) {
    		log.debug("caught e = ", e );
    		JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
    	}
    
    	log.debug("showEditDialog() - end");
    }

    @Override
	protected AbstractTableModel getTableModel() throws PipelineUIException {
		log.debug("getTableModel() - start");

		if( pipelinesTableModel == null ){
			pipelinesTableModel = new PipelinesTableModel();
			pipelinesTableModel.register();
		}

		log.debug("getTableModel() - end");
		return pipelinesTableModel;
	}

    private JMenuItem getVersionMenuItem() {
        log.debug("getversionMenuItem() - start");

        if (versionMenuItem == null) {
            versionMenuItem = new JMenuItem();
            versionMenuItem.setText("New version of selected pipeline (unlock)...");
            versionMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    versionMenuItemActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getVersionMenuItem() - end");
        return versionMenuItem;
    }

    private void versionMenuItemActionPerformed(ActionEvent evt) {
        doVersion(selectedModelRow);
    }

    private JMenuItem getGroupMenuItem() {
        log.debug("getGroupMenuItem() - start");

        if (groupMenuItem == null) {
            groupMenuItem = new JMenuItem();
            groupMenuItem.setText("Set Group...");
            groupMenuItem.addActionListener(new ActionListener() {
                public void actionPerformed(ActionEvent evt) {
                    log.debug("actionPerformed(ActionEvent) - start");

                    groupMenuItemActionPerformed(evt);

                    log.debug("actionPerformed(ActionEvent) - end");
                }
            });
        }

        log.debug("getGroupMenuItem() - end");
        return groupMenuItem;
    }

    private void groupMenuItemActionPerformed(ActionEvent evt) {
        doGroup(selectedModelRow);
    }

	@Override
	protected String getEditMenuText() {
		return "Edit selected Pipeline...";
	}

	@Override
	protected String getNewMenuText() {
		return "New Pipeline...";
	}

	@Override
	protected String getDeleteMenuText() {
		return "Delete selected Pipeline...";
	}
    @Override
    protected String getCloneMenuText() {
        return "Clone selected Pipeline...";
    }

    @Override
    protected String getRenameMenuText() {
        return "Rename selected pipeline...";
    }
}
