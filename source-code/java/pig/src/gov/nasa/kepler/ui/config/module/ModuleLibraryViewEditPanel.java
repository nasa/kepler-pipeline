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

package gov.nasa.kepler.ui.config.module;

import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.PipelineUIException;
import gov.nasa.kepler.ui.config.AbstractClonableViewEditPanel;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.PipelineModuleDefinitionCrudProxy;

import javax.swing.JOptionPane;
import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class ModuleLibraryViewEditPanel extends AbstractClonableViewEditPanel {
	public static final Log log = LogFactory.getLog(ModuleLibraryViewEditPanel.class);

	private ModuleLibraryTableModel moduleLibraryTableModel; // do NOT init to null! (see getTableModel)

    private PipelineModuleDefinitionCrudProxy pipelineModuleDefinitionCrud;
    
	public ModuleLibraryViewEditPanel() throws PipelineUIException {
        super(true,true);
        
        pipelineModuleDefinitionCrud = new PipelineModuleDefinitionCrudProxy();

        initGUI();
        
	}

	@Override
	protected AbstractTableModel getTableModel() throws PipelineUIException {
		log.debug("getTableModel() - start");

		if( moduleLibraryTableModel == null ){
			moduleLibraryTableModel = new ModuleLibraryTableModel();
			moduleLibraryTableModel.register();
		}

		log.debug("getTableModel() - end");
		return moduleLibraryTableModel;
	}

	@Override
	protected void doNew() {
		log.debug("doNew() - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        String newModuleName = (String)JOptionPane.showInputDialog(
            PipelineConsole.instance, "Enter the name for the new Module Definition",
            "New Pipeline Module Definition",
            JOptionPane.PLAIN_MESSAGE);
		
		if(newModuleName == null || newModuleName.length() == 0){
            JOptionPane.showMessageDialog( this, "Please enter a module name", "Error", JOptionPane.ERROR_MESSAGE );
            return;
		}
		
		showEditDialog( new PipelineModuleDefinition(newModuleName));

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

        PipelineModuleDefinition selectedModule = moduleLibraryTableModel.getModuleAtRow( row );
        
        try {
            String newModuleName = (String)JOptionPane.showInputDialog(
                PipelineConsole.instance, "Enter the name for the new Module Definition",
                "New Module Definition",
                JOptionPane.PLAIN_MESSAGE);
            
            if(newModuleName == null || newModuleName.length() == 0){
                JOptionPane.showMessageDialog( this, "Please enter a module name", "Error", JOptionPane.ERROR_MESSAGE );
                return;
            }
            
            PipelineModuleDefinition newModuleDefinition = new PipelineModuleDefinition(selectedModule);
            newModuleDefinition.rename(newModuleName);
                
            showEditDialog(newModuleDefinition);
            
            moduleLibraryTableModel.loadFromDatabase();
            
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

        PipelineModuleDefinition selectedModule = moduleLibraryTableModel.getModuleAtRow( row );
        
        try {
            String newModuleName = (String)JOptionPane.showInputDialog(
                PipelineConsole.instance, "Enter the new name for this Module Definition",
                "Rename Module Definition",
                JOptionPane.PLAIN_MESSAGE);
            
            if(newModuleName == null || newModuleName.length() == 0){
                JOptionPane.showMessageDialog( this, "Please enter a module name", "Error", JOptionPane.ERROR_MESSAGE );
                return;
            }

            pipelineModuleDefinitionCrud.rename(selectedModule, newModuleName);
            moduleLibraryTableModel.loadFromDatabase();
            
        } catch (Exception e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    
        log.debug("doRename() - end");
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

        showEditDialog( moduleLibraryTableModel.getModuleAtRow( row ));

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

		PipelineModuleDefinition module = moduleLibraryTableModel.getModuleAtRow( row );
		
        if (!module.isLocked()) {

            int choice = JOptionPane.showConfirmDialog( this, 
                    "Are you sure you want to delete module '" + module.getName() + "'?");

            if( choice == JOptionPane.YES_OPTION ){
                try {
                    pipelineModuleDefinitionCrud.delete( module );
                    moduleLibraryTableModel.loadFromDatabase();
                
                } catch (Throwable e) {
                    log.debug("caught e = ", e );
                    JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
                }
            }
        } else {
            JOptionPane.showMessageDialog(this, "Can't delete a locked module definition.  Modules are locked when referenced by a pipeline instance", "Error",
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
            moduleLibraryTableModel.loadFromDatabase();
        } catch (Throwable e) {
            log.debug("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    }

    private void showEditDialog( PipelineModuleDefinition module ){
		log.debug("showEditDialog() - start");

		ModuleEditDialog inst = new ModuleEditDialog( PipelineConsole.instance, module );
		
		inst.setVisible(true);

		if(!inst.isCancelled()){
	        try {
	            moduleLibraryTableModel.loadFromDatabase();
	        } catch (Exception e) {
	            log.error("showEditDialog(User)", e);

	            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
	        }
		}
		
		log.debug("showEditDialog() - end");
	}

    @Override
	protected String getEditMenuText() {
		return "Edit selected module...";
	}

	@Override
	protected String getNewMenuText() {
		return "Add module...";
	}

	@Override
	protected String getDeleteMenuText() {
		return "Delete selected module...";
	}
	
    @Override
    protected String getCloneMenuText() {
        return "Clone selected module...";
    }
    
    @Override
    protected String getRenameMenuText() {
        return "Rename selected module...";
    }

	/**
	* This method should return an instance of this class which does 
	* NOT initialize it's GUI elements. This method is ONLY required by
	* Jigloo if the superclass of this class is abstract or non-public. It 
	* is not needed in any other situation.
	 * @throws PipelineUIException 
	 */
	public static Object getGUIBuilderInstance() throws PipelineUIException {
		return new ModuleLibraryViewEditPanel(Boolean.FALSE);
	}
	
	/**
	 * This constructor is used by the getGUIBuilderInstance method to
	 * provide an instance of this class which has not had it's GUI elements
	 * initialized (ie, initGUI is not called in this constructor).
	 * @throws PipelineUIException 
	 */
	public ModuleLibraryViewEditPanel(Boolean initGUI) throws PipelineUIException {
		super(true, false);
	}
}
