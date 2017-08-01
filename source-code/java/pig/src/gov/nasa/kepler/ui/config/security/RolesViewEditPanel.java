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

package gov.nasa.kepler.ui.config.security;

import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.hibernate.services.Role;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.PipelineUIException;
import gov.nasa.kepler.ui.common.DoubleListDialog;
import gov.nasa.kepler.ui.config.AbstractViewEditPanel;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.UserCrudProxy;

import java.util.LinkedList;
import java.util.List;

import javax.swing.JOptionPane;
import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class RolesViewEditPanel extends AbstractViewEditPanel {
    private static final Log log = LogFactory.getLog(RolesViewEditPanel.class);

	private RolesTableModel rolesTableModel; // do NOT init to null! (see getTableModel)

    private UserCrudProxy userCrud;

    public RolesViewEditPanel() throws PipelineUIException {
		super();
        
		userCrud = new UserCrudProxy();
		
        initGUI();
	}

	@Override
	protected AbstractTableModel getTableModel() throws PipelineUIException {
		log.debug("getTableModel() - start");

		if( rolesTableModel == null ){
			rolesTableModel = new RolesTableModel();
			rolesTableModel.register();
		}

		log.debug("getTableModel() - end");
		return rolesTableModel;
	}

	@Override
	protected void doNew() {
		log.debug("doNew() - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.USER_ADMIN);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

		String roleName = (String) JOptionPane.showInputDialog(PipelineConsole.instance, 
				"Enter a name for the new Role",
				"New Role", JOptionPane.QUESTION_MESSAGE, null, null, "");

		if ((roleName != null) && (roleName.length() > 0)) {
			showEditDialog(new Role( roleName ));
		}

		log.debug("doNew() - end");
	}

	@Override
	protected void doEdit(int row) {
		log.debug("doEdit(int) - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.USER_ADMIN);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

		showEditDialog( rolesTableModel.getRoleAtRow( row ));

		log.debug("doEdit(int) - end");
	}

	@Override
	protected void doDelete(int row) {
		log.debug("doDelete(int) - start");

        try{
            CrudProxy.verifyPrivileges(Privilege.USER_ADMIN);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

		Role role = rolesTableModel.getRoleAtRow( row );
		
		int choice = JOptionPane.showConfirmDialog( this, 
				"Are you sure you want to delete role '" + role.getName() + "'?");

		if( choice == JOptionPane.YES_OPTION ){
			try {
                try{
                    userCrud.deleteRole( role );
                }catch(PigSecurityException e){
                    JOptionPane.showMessageDialog(this, e, "Error",
                        JOptionPane.ERROR_MESSAGE);
                }
                
				rolesTableModel.loadFromDatabase();
			} catch (Throwable e) {
				log.error("caught e = ", e );
				JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
			}
		}

		log.debug("doDelete(int) - end");
	}


    /* (non-Javadoc)
     * @see gov.nasa.kepler.ui.config.GenericViewEditPanel#doRefresh()
     */
    @Override
    protected void doRefresh() {
        try {
            rolesTableModel.loadFromDatabase();
        } catch (Throwable e) {
            log.error("caught e = ", e );
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
        }
    }

    private void showEditDialog( Role role ){
		log.debug("showEditDialog() - start");

		try {
			List<String> currentPrivs = role.getPrivileges();
            LinkedList<String> availablePrivs = new LinkedList<String>();
            for (Privilege priv : Privilege.values()) {
                if (!currentPrivs.contains(priv.toString())) {
                    availablePrivs.add(priv.toString());
                }
            }
			
			DoubleListDialog<String> privSelectionDialog = new DoubleListDialog<String>( PipelineConsole.instance, 
					"Privileges for Role " + role.getName(), "Available Privileges", availablePrivs, "Selected Privileges", currentPrivs );
			privSelectionDialog.setVisible( true );
			
			if( privSelectionDialog.wasSavePressed() ){
				List<String> selectedPrivs = privSelectionDialog.getSelectedListContents();
				role.setPrivileges( selectedPrivs );
                try{
                    userCrud.saveRole( role );
                }catch(PigSecurityException e){
                    JOptionPane.showMessageDialog(this, e, "Error",
                        JOptionPane.ERROR_MESSAGE);
                }
				rolesTableModel.loadFromDatabase();
			}

		} catch (Throwable e) {
			log.debug("caught e = ", e );
			JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
		}

		log.debug("showEditDialog() - end");
	}

	@Override
	protected String getEditMenuText() {
		return "Edit selected role...";
	}

	@Override
	protected String getNewMenuText() {
		return "Add role...";
	}

	@Override
	protected String getDeleteMenuText() {
		return "Delete selected role...";
	}
}
