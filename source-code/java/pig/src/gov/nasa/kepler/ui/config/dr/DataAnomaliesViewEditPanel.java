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

package gov.nasa.kepler.ui.config.dr;

import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.hibernate.services.Privilege;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.PipelineUIException;
import gov.nasa.kepler.ui.config.AbstractViewEditPanel;
import gov.nasa.kepler.ui.proxy.CrudProxy;
import gov.nasa.kepler.ui.proxy.DataAnomalyModelCrudProxy;

import javax.swing.JOptionPane;
import javax.swing.table.AbstractTableModel;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * View/Edit panel for data anomalies
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class DataAnomaliesViewEditPanel extends AbstractViewEditPanel {
    private static final Log log = LogFactory.getLog(DataAnomaliesViewEditPanel.class);
    
    // do NOT init to null! (see getTableModel)
    private DataAnomaliesTableModel anomaliesTableModel;

    public DataAnomaliesViewEditPanel() throws PipelineUIException {
        super();
        
        initGUI();
    }

    @Override
    protected AbstractTableModel getTableModel() throws PipelineUIException {
        log.debug("getTableModel() - start");

        if (anomaliesTableModel == null) {
            anomaliesTableModel = new DataAnomaliesTableModel();
            anomaliesTableModel.register();
        }

        log.debug("getTableModel() - end");
        return anomaliesTableModel;
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

        DataAnomaly dataset = anomaliesTableModel.getDataAnomalyAtRow(row);
        showEditDialog(dataset);
        
        anomaliesTableModel.loadFromDatabase();

        log.debug("doEdit(int) - end");
    }

    private void showEditDialog(DataAnomaly anomaly) {
        log.debug("showEditDialog() - start");
    
        try {
            if(anomaly != null){
                DataAnomaliesEditDialog.editExistingDataAnomaly(PipelineConsole.instance, anomaly);
            }else{
                DataAnomaliesEditDialog.addNewDataAnomaly(PipelineConsole.instance);
            }
        } catch (Exception e) {
            log.error("showEditDialog(User)", e);
    
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
    
        log.debug("showEditDialog() - end");
    }

    /*
     * (non-Javadoc)
     * 
     * @see gov.nasa.kepler.ui.config.GenericViewEditPanel#doRefresh()
     */
    @Override
    protected void doRefresh() {
        try {
            anomaliesTableModel.loadFromDatabase();
        } catch (Throwable e) {
            log.error("caught e = ", e);
            JOptionPane.showMessageDialog(this, e, "Error",
                JOptionPane.ERROR_MESSAGE);
        }
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

        DataAnomaly anomaly = anomaliesTableModel.getDataAnomalyAtRow( row );
        
        int choice = JOptionPane.showConfirmDialog( this, 
                "Are you sure you want to delete this anomaly?");

        if( choice == JOptionPane.YES_OPTION ){
            try {
                try{
                    DataAnomalyModelCrudProxy dataAnomalyModelCrud = new DataAnomalyModelCrudProxy();
                    dataAnomalyModelCrud.deleteDataAnomaly(anomaly.getId());
                }catch(PigSecurityException e){
                    JOptionPane.showMessageDialog(this, e, "Error",
                        JOptionPane.ERROR_MESSAGE);
                }
                anomaliesTableModel.loadFromDatabase();
            
            } catch (Throwable e) {
                log.error("caught e = ", e );
                JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            }
        }

        log.debug("doDelete(int) - end");
    }

    @Override
    protected void doNew() {
        try{
            CrudProxy.verifyPrivileges(Privilege.PIPELINE_CONFIG);
        }catch(PigSecurityException e){
            JOptionPane.showMessageDialog( this, e, "Error", JOptionPane.ERROR_MESSAGE );
            return;
        }

        showEditDialog(null);
        
        anomaliesTableModel.loadFromDatabase();
    }

    @Override
    protected String getEditMenuText() {
        return "Edit selected anomaly...";
    }

    @Override
    protected String getDeleteMenuText() {
        return "Delete selected anomaly...";
    }

    @Override
    protected String getNewMenuText() {
        return "Add anomaly...";
    }
}
