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

package gov.nasa.kepler.pi.worker;

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.TaskExecutionLog;
import gov.nasa.kepler.services.process.PipelineProcessAdminOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.List;

import org.apache.log4j.Logger;

public class WorkerOperations {
    private static final Logger log = Logger.getLogger(WorkerOperations.class);
    private static final long TIMEOUT = 5000;

    public WorkerOperations() {
    }

    public String retrieveTaskLog(PipelineTask task){
        long instanceId = task.getPipelineInstance().getId();
        long taskId = task.getId();
        
        PipelineProcessAdminOperations ops = new PipelineProcessAdminOperations();
        StringBuilder taskLog = new StringBuilder();
        
        List<TaskExecutionLog> steps = task.getExecLog();
        int stepIndex = 0;
        
        List<Pair<String,Integer>> workers = new ArrayList<Pair<String,Integer>>();

        if(steps != null){
            for (TaskExecutionLog execLog : steps) {
                if(execLog.getWorkerHost() != null){
                    workers.add(Pair.of(execLog.getWorkerHost(), stepIndex));
                }
                
                taskLog.append("Step: " + stepIndex + ": " + execLog + "\n");
                stepIndex++;
            }
        }else{
            // backwards compatibility for PipelineTask objects in the database
            // without any TaskStepLogs
            workers.add(Pair.of(task.getWorkerHost(), 0));
        }

        for (Pair<String, Integer> worker : workers) {
            String label = "Task log for step: " + worker.right + " on worker: " + worker.left;
            String stepLogContents = "<Request timed-out!>";
            
            log.info("Fetching " + label);
            
            WorkerTaskLogResponse response;
            try {
                response = ops.adminRequest(WorkerPipelineProcess.NAME,
                    worker.left, new WorkerTaskLogRequest(instanceId, taskId, worker.right), TIMEOUT);
                
                stepLogContents = response.getLogContents();
            } catch (Exception e) {
                log.warn("Timeout waiting for response from: " + worker.left);
            }
            
            taskLog.append("\n---\n");
            taskLog.append(label);
            taskLog.append("\n---\n");
            taskLog.append(stepLogContents);
        }

        return taskLog.toString();
    }
}
