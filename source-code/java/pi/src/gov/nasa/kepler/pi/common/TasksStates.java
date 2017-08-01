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

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Summary statistics for the tasks of a pipeline instance
 *  
 * @author tklaus
 *
 */
public class TasksStates {

    public class Summary{
        private int submittedCount = 0;
        private int processingCount = 0;
        private int errorCount = 0;
        private int completedCount = 0;
        private int subTaskTotalCount = 0;
        private int subTaskCompleteCount = 0;
        private int subTaskFailedCount = 0;
        
        public int getSubmittedCount() {
            return submittedCount;
        }
        public int getProcessingCount() {
            return processingCount;
        }
        public int getErrorCount() {
            return errorCount;
        }
        public int getCompletedCount() {
            return completedCount;
        }
        public int getSubTaskTotalCount() {
            return subTaskTotalCount;
        }
        public int getSubTaskCompleteCount() {
            return subTaskCompleteCount;
        }
        public int getSubTaskFailedCount() {
            return subTaskFailedCount;
        }
    }

    private int totalSubmittedCount = 0;
    private int totalProcessingCount = 0;
    private int totalErrorCount = 0;
    private int totalCompletedCount = 0;
    private int totalSubTaskTotalCount = 0;
    private int totalSubTaskCompleteCount = 0;
    private int totalSubTaskFailedCount = 0;
    
    private List<String> moduleNames = new LinkedList<String>();
    private Map<String, Summary> moduleStates = new HashMap<String, Summary>();

    public TasksStates() {
    }

    public TasksStates(List<PipelineTask> tasks, Map<Long,PipelineTaskAttributes> taskAttrs){
        update(tasks, taskAttrs);
    }
    
    public void update(List<PipelineTask> tasks, Map<Long,PipelineTaskAttributes> taskAttrs){
        clear();
        
        for (PipelineTask task : tasks) {
            String moduleName = task.getPipelineInstanceNode().getPipelineModuleDefinition().getName().getName();
            
            Summary s = moduleStates.get(moduleName);
            if(s == null){
                s = new Summary();
                moduleStates.put(moduleName, s);
                moduleNames.add(moduleName);
            }
            
            switch(task.getState()){
                case INITIALIZED:
                    break;
                case SUBMITTED:
                    s.submittedCount++;
                    totalSubmittedCount++;
                    break;
                case PROCESSING:
                    s.processingCount++;
                    totalProcessingCount++;
                    break;
                case ERROR:
                    s.errorCount++;
                    totalErrorCount++;
                    break;
                case COMPLETED:
                case PARTIAL:
                    s.completedCount++;
                    totalCompletedCount++;
                    break;
                default:
                    break;
            }
            
            PipelineTaskAttributes taskAttributes = taskAttrs.get(task.getId());
            
            if(taskAttributes != null){
                totalSubTaskTotalCount += taskAttributes.getNumSubTasksTotal();
                s.subTaskTotalCount += taskAttributes.getNumSubTasksTotal();
                totalSubTaskCompleteCount += taskAttributes.getNumSubTasksComplete();
                s.subTaskCompleteCount += taskAttributes.getNumSubTasksComplete();
                totalSubTaskFailedCount += taskAttributes.getNumSubTasksFailed();
                s.subTaskFailedCount += taskAttributes.getNumSubTasksFailed();
            }
        }
    }

    private void clear(){
        moduleNames.clear();
        moduleStates.clear();
        
        totalSubmittedCount = 0;
        totalProcessingCount = 0;
        totalErrorCount = 0;
        totalCompletedCount = 0;
        totalSubTaskTotalCount = 0;
        totalSubTaskCompleteCount = 0;
        totalSubTaskFailedCount = 0;
    }
    
    public Map<String, Summary> getModuleStates() {
        return moduleStates;
    }

    public List<String> getModuleNames() {
        return moduleNames;
    }

    public int getTotalSubmittedCount() {
        return totalSubmittedCount;
    }

    public int getTotalProcessingCount() {
        return totalProcessingCount;
    }

    public int getTotalErrorCount() {
        return totalErrorCount;
    }

    public int getTotalCompletedCount() {
        return totalCompletedCount;
    }

    public int getTotalSubTaskTotalCount() {
        return totalSubTaskTotalCount;
    }

    public int getTotalSubTaskCompleteCount() {
        return totalSubTaskCompleteCount;
    }

    public int getTotalSubTaskFailedCount() {
        return totalSubTaskFailedCount;
    }
}
