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

import static com.google.common.collect.Lists.newArrayList;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.pi.worker.WorkerPipelineProcess;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirRequest;
import gov.nasa.kepler.pi.worker.WorkerTaskWorkingDirResponse;
import gov.nasa.kepler.services.process.PipelineProcessAdminOperations;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.IOException;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class TaskBinFileDirOperationsTest extends JMockTest {

    private static final String WORKER_HOST = "WORKER_HOST";
    private static final int INSTANCE_ID = 1;
    private static final int TASK_ID = 2;

    private PipelineProcessAdminOperations mockAdminOperations;
    private PipelineTaskCrud mockPipelineTaskCrud;
    private PipelineInstance pipelineInstance;
    private File destDir;
    private TaskBinFileDirOperations operations;
    private PipelineTask pipelineTask;

    @Test
    public void testCopyBinFileDirToDir() throws IOException,
        InterruptedException {
        setUp();

        operations.copyBinFileDirToDir(pipelineTask, destDir);
    }

    @Test
    public void testCopyBinFileDirsToDirSingleTask() throws IOException,
        InterruptedException {
        setUp();

        allowing(mockPipelineTaskCrud).retrieveAll(pipelineInstance);
        will(returnValue(ImmutableList.of(pipelineTask)));

        operations.copyBinFileDirsToDir(pipelineInstance, destDir);
    }

    @Test
    public void testCopyBinFileDirsToDirMultiTask() throws IOException,
        InterruptedException {
        setUp();

        List<PipelineTask> pipelineTasks = newArrayList();
        for (int i = 0; i < 100; i++) {
            pipelineTasks.add(pipelineTask);
        }

        allowing(mockPipelineTaskCrud).retrieveAll(pipelineInstance);
        will(returnValue(pipelineTasks));

        operations.copyBinFileDirsToDir(pipelineInstance, destDir);
    }

    private void setUp() throws IOException {
        pipelineInstance = new PipelineInstance();
        pipelineInstance.setId(INSTANCE_ID);

        pipelineTask = new PipelineTask();
        pipelineTask.setId(TASK_ID);
        pipelineTask.setWorkerHost(WORKER_HOST);
        pipelineTask.setPipelineInstance(pipelineInstance);

        File srcDir = new File(Filenames.BUILD_TMP, "/foo-"
            + INSTANCE_ID + "-" + TASK_ID);
        FileUtil.cleanDir(srcDir);

        destDir = new File(Filenames.BUILD_TMP, "/foo-dest-dir");
        FileUtil.cleanDir(destDir);

        mockAdminOperations = mock(PipelineProcessAdminOperations.class);
        mockPipelineTaskCrud = mock(PipelineTaskCrud.class);

        operations = new TaskBinFileDirOperations();
        operations.setAdminOperations(mockAdminOperations);
        operations.setPipelineTaskCrud(mockPipelineTaskCrud);

        WorkerTaskWorkingDirRequest expectedRequest = new WorkerTaskWorkingDirRequest(
            INSTANCE_ID, TASK_ID, destDir);

        allowing(mockAdminOperations).adminRequest(WorkerPipelineProcess.NAME,
            WORKER_HOST, expectedRequest);
        will(returnValue(new WorkerTaskWorkingDirResponse(true, "Success.")));
    }

}
