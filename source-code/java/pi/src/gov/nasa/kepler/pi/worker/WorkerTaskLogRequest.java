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

import gov.nasa.kepler.services.process.PipelineProcessAdminRequest;
import gov.nasa.kepler.services.process.PipelineProcessAdminResponse;

import java.io.File;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

public class WorkerTaskLogRequest extends PipelineProcessAdminRequest {
    private static final Log log = LogFactory.getLog(WorkerTaskLogRequest.class);

    private static final long serialVersionUID = -580210981200216527L;

    private long instanceId = 0;
    private long taskId = 0;
    private int stepIndex = 0;
    
    public WorkerTaskLogRequest(long instanceId, long taskId, int stepIndex) {
        this.instanceId = instanceId;
        this.taskId = taskId;
        this.stepIndex = stepIndex;
    }

    @Override
    public PipelineProcessAdminResponse processRequest() {
        StringBuilder fileContents = new StringBuilder();
        String nl = System.getProperty("line.separator");

        try {
            File taskLogFile = TaskLog.searchForTaskFile(instanceId, taskId, stepIndex);

            if(taskLogFile != null){
                log.info("Reading task log: " + taskLogFile);
                fileContents.append("Task log location: " + taskLogFile.getAbsolutePath() + nl);
                fileContents.append(FileUtils.readFileToString(taskLogFile));
                log.info("Returning task log ("+ fileContents.length()+" chars): " + taskLogFile);
            }else{
                log.info("Task log not found for instanceId: " + instanceId + ", taskId: " + taskId);
                fileContents.append("Task log not found in current log directory or in the archives");
            }
            
            return new WorkerTaskLogResponse(true, fileContents.toString());
        } catch (Exception e) {
            return new WorkerTaskLogResponse(false, e.getMessage());
        }
    }
}
