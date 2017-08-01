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

package gov.nasa.kepler.pi.pipeline;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.pi.worker.WorkerPipelineProcess;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirRequest;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirResponse;
import gov.nasa.kepler.services.process.PipelineProcessAdminOperations;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class supports copying bin file dirs to a destination dir.
 * 
 * @author Miles Cote
 * 
 */
public class TaskBinFileDirOperations {

    private static final int SLEEP_INTERVAL_MILLIS = 10000;

    private static final Log log = LogFactory.getLog(TaskBinFileDirOperations.class);
    
    private int successCount = 0;
    private int failureCount = 0;

    private PipelineProcessAdminOperations adminOperations;
    private PipelineTaskCrud pipelineTaskCrud;

    public Pair<Integer, Integer> copyBinFileDirsToDir(PipelineInstance pipelineInstance,
        File destDir) throws IOException, InterruptedException {
        FileUtils.forceMkdir(destDir);

        List<PipelineTask> pipelineTasks = getPipelineTaskCrud().retrieveAll(
            pipelineInstance);
        
        for (PipelineTask pipelineTask : pipelineTasks) {
            copy(pipelineTask, destDir);
        }
        
        while (successCount + failureCount != pipelineTasks.size()) {
            Thread.sleep(SLEEP_INTERVAL_MILLIS);
        }
        
        return Pair.of(successCount, failureCount);
    }

    public Pair<Integer, Integer> copyBinFileDirToDir(PipelineTask pipelineTask, File destDir)
        throws IOException, InterruptedException {
        FileUtils.forceMkdir(destDir);

        copy(pipelineTask, destDir);

        while (successCount + failureCount != 1) {
            Thread.sleep(SLEEP_INTERVAL_MILLIS);
        }
       
        return Pair.of(successCount, failureCount);
    }

    private void copy(final PipelineTask pipelineTask, final File destDir) {
        Thread thread = new Thread() {
            @Override
            public void run() {
                try {
                    WorkerTaskWorkingDirResponse response = null;
                    if (pipelineTask != null) {
                        response = (WorkerTaskWorkingDirResponse) getAdminOperations().adminRequest(
                            WorkerPipelineProcess.NAME,
                            pipelineTask.getWorkerHost(),
                            new WorkerTaskWorkingDirRequest(
                                pipelineTask.getPipelineInstance()
                                    .getId(), pipelineTask.getId(), destDir));
                    }

                    if (response.isSuccessful()) {
                        log.info("Success:  " + response.getStatus());
                        incrementSuccess();
                    } else {
                        log.error("Failure:  " + response.getStatus());
                        incrementFailure();
                    }
                } catch (Exception e) {
                    log.error("Unable to copy.  ", e);
                }
            }
        };
        thread.start();
    }
    
    private synchronized void incrementSuccess() {
        successCount++;
    }
    
    private synchronized void incrementFailure() {
        failureCount++;
    }

    private PipelineProcessAdminOperations getAdminOperations() {
        if (adminOperations == null) {
            adminOperations = new PipelineProcessAdminOperations();
        }

        return adminOperations;
    }

    void setAdminOperations(PipelineProcessAdminOperations adminOperations) {
        this.adminOperations = adminOperations;
    }

    private PipelineTaskCrud getPipelineTaskCrud() {
        if (pipelineTaskCrud == null) {
            pipelineTaskCrud = new PipelineTaskCrud();
        }

        return pipelineTaskCrud;
    }

    void setPipelineTaskCrud(PipelineTaskCrud pipelineTaskCrud) {
        this.pipelineTaskCrud = pipelineTaskCrud;
    }

}
