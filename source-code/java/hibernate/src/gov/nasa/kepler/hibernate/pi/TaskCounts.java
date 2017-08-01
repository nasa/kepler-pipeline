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

package gov.nasa.kepler.hibernate.pi;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Result class for a query against PipelineInstanceNode.
 * 
 * @author tklaus
 *
 */
public class TaskCounts{
    private final Log log = LogFactory.getLog(TaskCounts.class);

    private long total;
    private long submitted;
    private long completed;
    private long failed;
    
    public TaskCounts(long total, long submitted, long completed, long failed) {
        this.total = total;
        this.submitted = submitted;
        this.completed = completed;
        this.failed = failed;
    }
    
    public TaskCounts(TaskCounts other){
        this.total = other.total;
        this.submitted = other.submitted;
        this.completed = other.completed;
        this.failed = other.failed;
    }

    /**
     * True if numCompletedTasks == numTasks
     * 
     * @param pipelineInstanceNodeId
     * @return
     */
    public boolean isInstanceNodeComplete(){
        log.info("numTasks/numCompletedTasks = "+total+"/"+completed);
        
        return(completed == total);
    }

    public String log(){
        return "taskCounts: numTasks/numSubmittedTasks/numCompletedTasks/numFailedTasks =  "
            + total + "/" 
            + submitted + "/"
            + completed + "/"
            + failed;
    }
    
    public long getTotal() {
        return total;
    }

    public long getSubmitted() {
        return submitted;
    }

    public long getCompleted() {
        return completed;
    }

    public long getFailed() {
        return failed;
    }

    void setTotal(long total) {
        this.total = total;
    }

    void setSubmitted(long submitted) {
        this.submitted = submitted;
    }

    void setCompleted(long completed) {
        this.completed = completed;
    }

    void setFailed(long failed) {
        this.failed = failed;
    }
}