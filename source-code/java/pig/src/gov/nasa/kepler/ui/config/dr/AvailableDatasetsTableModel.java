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

import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.ui.PigSecurityException;
import gov.nasa.kepler.ui.models.AbstractDatabaseModel;
import gov.nasa.kepler.ui.proxy.LogCrudProxy;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

@SuppressWarnings("serial")
public class AvailableDatasetsTableModel extends AbstractDatabaseModel {
    private static final Log log = LogFactory.getLog(AvailableDatasetsTableModel.class);

    private List<DrDataset> datasets;
    private LogCrudProxy logCrud;

    public AvailableDatasetsTableModel() {
        logCrud = new LogCrudProxy();
    }

    public void loadFromDatabase() {
        log.debug("loadFromDatabase() - start");
        
        datasets = new ArrayList<DrDataset>();

        try{
            List<DispatchLog> dispatchers = logCrud.retrieveAllDispatchLogs();
            
            for (DispatchLog dispatchLog : dispatchers) {
                Pair<Integer, Integer> cadenceRange = logCrud.cadenceRangeForDispatchLog(dispatchLog);
                DrDataset dataset = new DrDataset(dispatchLog, cadenceRange);
                
                datasets.add(dataset);
            }
        }catch(PigSecurityException ignore){
        }
        
        fireTableDataChanged();

        log.debug("loadFromDatabase() - end");
    }

    public DrDataset getDatasetAtRow(int rowIndex) {
        validityCheck();
        return datasets.get(rowIndex);
    }

    public int getRowCount() {
        validityCheck();
        return datasets.size();
    }

    public int getColumnCount() {
        return 5;
    }

    public Object getValueAt(int rowIndex, int columnIndex) {
        validityCheck();

        DrDataset dataset = datasets.get(rowIndex);
        String pipelineInstanceId = "---";
        
        List<PipelineInstance> pipelineInstances = dataset.getDispatchLog().getPipelineInstances();
        if(pipelineInstances != null && pipelineInstances.size() >= 1){
            pipelineInstanceId = "" + pipelineInstances.get(0).getId();
        }

        String cadenceStart = "---";
        String cadenceEnd = "---";
        Pair<Integer, Integer> cadenceRange = dataset.getCadenceRange();
        
        if(cadenceRange != null){
            cadenceStart = "" + cadenceRange.left;
            cadenceEnd = "" + cadenceRange.right;
        }
        
        switch (columnIndex) {
            case 0:
                return dataset.getDispatchLog().getDispatcherType();
            case 1:
                return dataset.getDispatchLog().getReceiveLog().getMessageFileName();
            case 2:
                return cadenceStart;
            case 3:
                return cadenceEnd;
            case 4:
                return pipelineInstanceId;
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
                return "Dispatcher";
            case 1:
                return "Notification Msg";
            case 2:
                return "Start Cadence";
            case 3:
                return "End Cadence";
            case 4:
                return "Pipeline Instance";
        }

        return "huh?";
    }
}
