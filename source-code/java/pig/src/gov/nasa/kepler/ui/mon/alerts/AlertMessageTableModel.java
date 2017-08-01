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

package gov.nasa.kepler.ui.mon.alerts;

import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.services.alert.AlertMessage;
import gov.nasa.kepler.ui.PipelineConsole;
import gov.nasa.kepler.ui.mon.master.Indicator;
import gov.nasa.kepler.ui.mon.master.Indicator.State;

import java.text.SimpleDateFormat;
import java.util.LinkedList;
import java.util.List;

import javax.swing.table.AbstractTableModel;

@SuppressWarnings("serial")
public class AlertMessageTableModel extends AbstractTableModel {

    private static final int MAX_ALERTS = 1000;

    private List<AlertMessage> alertMessages = new LinkedList<AlertMessage>();
    private SimpleDateFormat formatter;
    private Indicator.State currentState = Indicator.State.GREEN;
    
    public AlertMessageTableModel() {
        formatter = new SimpleDateFormat("MM/dd/yy HH:mm:ss");
    }

    public void clear() {
        alertMessages.clear();
        fireTableDataChanged();
    }

    public void updateCurrentState(State state){
        this.currentState = state;

        PipelineConsole.instance.getStatusSummaryPanel().setState(Indicator.Category.ALERT, currentState);
    }
    
    public void addAlertMessage(AlertMessage msg) {
        if(alertMessages.size() >= MAX_ALERTS){
            // remove oldest (at the bottom)
            alertMessages.remove(alertMessages.size() - 1);
        }
        
        alertMessages.add(0, msg); // add to the beginning
        
        fireTableRowsInserted(alertMessages.size() - 1, alertMessages.size() - 1);
        
        String severity = msg.getAlertData().getSeverity();
        if(severity.equals("WARNING")){
            updateCurrentState(Indicator.State.AMBER);
        }else if(severity.equals("ERROR") || severity.equals("INFRASTRUCTURE")){
            updateCurrentState(Indicator.State.RED);
        }
    }

    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        Alert alert = alertMessages.get(rowIndex)
            .getAlertData();

        switch (columnIndex) {
            case 0:
                return formatter.format(alert.getTimestamp());
            case 1:
                return alert.getSourceComponent();
            case 2:
                return alert.getProcessHost();
            case 3:
                return alert.getSourceTaskId();
            case 4:
                return alert.getSeverity();
            case 5:
                return alert.getMessage();
        }

        return null;
    }

    @Override
    public int getColumnCount() {
        return 6;
    }

    @Override
    public int getRowCount() {
        return alertMessages.size();
    }

    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "Time";
            case 1:
                return "Source";
            case 2:
                return "Host";
            case 3:
                return "Task";
            case 4:
                return "Severity";
            case 5:
                return "Message";
        }

        return "huh?";
    }
}
