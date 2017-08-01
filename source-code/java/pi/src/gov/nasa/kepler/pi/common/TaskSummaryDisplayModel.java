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

package gov.nasa.kepler.pi.common;

/**
 * {@link DisplayModel} for the pipeline task summary.
 * This class is used to format the pipeline task summary for display in the 
 * pig and picli.
 * 
 * @author tklaus
 *
 */
public class TaskSummaryDisplayModel extends DisplayModel{
    private static final int NUM_COLUMNS = 6;
    private TasksStates taskStates = new TasksStates();
    
    public TaskSummaryDisplayModel() {
    }

    public TaskSummaryDisplayModel(TasksStates taskStates) {
        this.taskStates = taskStates;
    }

    public void update(TasksStates taskStates){
        this.taskStates = taskStates;
    }
    
    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        int moduleCount = taskStates.getModuleNames().size();
        boolean isTotalsRow = (rowIndex == moduleCount); 
        String moduleName = "";
        TasksStates.Summary moduleSummary = null;

        if(!isTotalsRow){
            moduleName = taskStates.getModuleNames().get(rowIndex);
            moduleSummary = taskStates.getModuleStates().get(moduleName);
        }
        
        switch( columnIndex ){
            case 0: // Module
                return moduleName;
            case 1: // Submitted
                if(isTotalsRow){
                    return taskStates.getTotalSubmittedCount();
                }else{
                    return moduleSummary.getSubmittedCount();
                }
            case 2: // Processing
                if(isTotalsRow){
                    return taskStates.getTotalProcessingCount();
                }else{
                    return moduleSummary.getProcessingCount();
                }
            case 3: // Completed
                if(isTotalsRow){
                    return taskStates.getTotalCompletedCount();
                }else{
                    return moduleSummary.getCompletedCount();
                }
            case 4: // Failed
                if(isTotalsRow){
                    return taskStates.getTotalErrorCount();
                }else{
                    return moduleSummary.getErrorCount();
                }
            case 5: // SubTasks
                if(isTotalsRow){
                    String allTotals = taskStates.getTotalSubTaskTotalCount() 
                    + "/" + taskStates.getTotalSubTaskCompleteCount() 
                    + "/" + taskStates.getTotalSubTaskFailedCount();
                    return allTotals;
                }else{
                    String moduleTotals = moduleSummary.getSubTaskTotalCount() 
                    + "/" + moduleSummary.getSubTaskCompleteCount() 
                    + "/" + moduleSummary.getSubTaskFailedCount();
                    return moduleTotals;
                }
            default:
                throw new IllegalArgumentException("Unexpected value: " + columnIndex);
            }
    }

    @Override
    public int getColumnCount() {
        return NUM_COLUMNS;
    }

    @Override
    public String getColumnName(int column) {
        switch( column ){
        case 0: return "Module";
        case 1: return "Submitted";
        case 2: return "Processing";
        case 3: return "Completed";
        case 4: return "Failed";
        case 5: return "SubTasks";
        default: throw new IllegalArgumentException("Unexpected value: " + column);
        }
    }

    @Override
    public int getRowCount() {
        if(taskStates != null){
            return taskStates.getModuleNames().size() + 1;
        }else{
            return 0;
        }
    }

    public TasksStates getTaskStates() {
        return taskStates;
    }
}
