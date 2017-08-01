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

import gov.nasa.kepler.common.Cadence;
import gov.nasa.kepler.hibernate.dr.DataAnomaly;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.models.AbstractDatabaseModel;
import gov.nasa.kepler.ui.proxy.DataAnomalyModelCrudProxy;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Table model for data anomalies
 * 
 * @author tklaus
 *
 */
@SuppressWarnings("serial")
public class DataAnomaliesTableModel extends AbstractDatabaseModel {
    private static final Log log = LogFactory.getLog(DataAnomaliesTableModel.class);

    private List<DataAnomaly> anomalies;
    private DataAnomalyModelCrudProxy dataAnomalyModelCrud;

    public DataAnomaliesTableModel() {
        dataAnomalyModelCrud = new DataAnomalyModelCrudProxy();
    }

    public void loadFromDatabase() {
        log.debug("loadFromDatabase() - start");
        
        anomalies = new ArrayList<DataAnomaly>();

        try{
            anomalies = dataAnomalyModelCrud.retrieveAllDataAnomalies();
            
        }catch(PigSecurityException ignore){
        }
        
        fireTableDataChanged();

        log.debug("loadFromDatabase() - end");
    }

    public DataAnomaly getDataAnomalyAtRow(int rowIndex) {
        validityCheck();
        return anomalies.get(rowIndex);
    }

    public int getRowCount() {
        validityCheck();
        return anomalies.size();
    }

    public int getColumnCount() {
        return 5;
    }

    public Object getValueAt(int rowIndex, int columnIndex) {
        validityCheck();

        DataAnomaly anomaly = anomalies.get(rowIndex);
        
        int cadenceTypeInt = anomaly.getCadenceType();
        Cadence.CadenceType cadenceType = Cadence.CadenceType.valueOf(cadenceTypeInt);
        
        switch (columnIndex) {
            case 0:
                return anomaly.getStartCadence();
            case 1:
                return anomaly.getEndCadence();
            case 2:
                return cadenceType;
            case 3:
                return anomaly.getDataAnomalyType();
            case 4:
                return anomaly.getRevision();
        }

        return "huh?";
    }

    /*
     * (non-Javadoc)
     * 
     * @see javax.swing.table.AbstractTableModel#getColumnName(int)
     */
    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "Start Cadence";
            case 1:
                return "End Cadence";
            case 2:
                return "Cadence Type";
            case 3:
                return "Anomaly Type";
            case 4:
                return "Revision";
        }

        return "huh?";
    }
}
