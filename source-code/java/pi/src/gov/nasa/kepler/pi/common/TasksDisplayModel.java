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

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.spiffy.common.lang.StringUtils;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * {@link DisplayModel} for pipeline tasks.
 * This class is used to format pipeline tasks for display in the 
 * pig and picli.
 * 
 * @author tklaus
 *
 */
public class TasksDisplayModel extends DisplayModel{

    private static final int NUM_COLUMNS = 7;
    
    private List<PipelineTask> tasks = new LinkedList<PipelineTask>();
    private Map<Long, PipelineTaskAttributes> taskAttrs;
    private TasksStates taskStates = new TasksStates();

    public TasksDisplayModel() {
    }

    public TasksDisplayModel(List<PipelineTask> tasks, Map<Long,PipelineTaskAttributes> taskAttrs){
        this.tasks = tasks;
        this.taskAttrs = taskAttrs;
        
        taskStates.update(this.tasks, taskAttrs);
    }

    public TasksDisplayModel(PipelineTask task, PipelineTaskAttributes taskAttrs){
        this.tasks = new LinkedList<PipelineTask>();
        this.tasks.add(task);
        this.taskAttrs = new HashMap<Long, PipelineTaskAttributes>();
        this.taskAttrs.put(task.getId(), taskAttrs);
        
        taskStates.update(this.tasks, this.taskAttrs);
    }

    public void update(List<PipelineTask> tasks, Map<Long,PipelineTaskAttributes> taskAttrs){
        this.tasks = tasks;
        this.taskAttrs = taskAttrs;

        taskStates.update(this.tasks, taskAttrs);
    }
    
    public PipelineTask getPipelineTaskForRow(int row) {
        return tasks.get(row);
    }

    @Override
    public int getRowCount() {
        return tasks.size();
    }

    @Override
    public int getColumnCount() {
        return NUM_COLUMNS;
    }

    @Override
    public Object getValueAt(int rowIndex, int columnIndex) {
        PipelineTask task = tasks.get(rowIndex);
        String briefState = "?";

        try {
            briefState = task.uowTaskInstance()
                .briefState();
        } catch (PipelineException e) {
        }

        switch (columnIndex) {
            case 0:
                return task.getId();
            case 1:
                return task.getPipelineInstanceNode()
                    .getPipelineModuleDefinition()
                    .toString();
            case 2:
                return briefState;
            case 3:
                return task.getState();
            case 4:
                return task.getWorkerName();
            case 5:
                return StringUtils.elapsedTime(task.getStartProcessingTime(),
                    task.getEndProcessingTime());
            case 6:
                PipelineTaskAttributes attributes = taskAttrs.get(task.getId());
                if(attributes != null){
                    return attributes.processingStateShortLabel();
                }else{
                    return "???";
                }
            default: throw new IllegalArgumentException("Unexpected value: " + columnIndex);
        }
    }

    @Override
    public String getColumnName(int column) {
        switch (column) {
            case 0:
                return "ID";
            case 1:
                return "Module";
            case 2:
                return "UOW";
            case 3:
                return "State";
            case 4:
                return "Worker";
            case 5:
                return "P-time";
            case 6:
                return "P-state";
            default: throw new IllegalArgumentException("Unexpected value: " + column);
        }
    }

    public TasksStates getTaskStates() {
        return taskStates;
    }
}
