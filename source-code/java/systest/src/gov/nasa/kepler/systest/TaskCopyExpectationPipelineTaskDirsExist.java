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

package gov.nasa.kepler.systest;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;

import java.io.File;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Describes the expectation that a task dir must exist for each
 * {@link PipelineTask} in the database.
 * 
 * @author Miles Cote
 * 
 */
class TaskCopyExpectationPipelineTaskDirsExist implements TaskCopyExpectation {

    static final String TASK_DIR_NAME_PART_SEPARATOR = "-";

    private static final Log log = LogFactory.getLog(TaskCopyExpectationPipelineTaskDirsExist.class);

    private final PipelineInstance pipelineInstance;
    private final PipelineTaskCrud pipelineTaskCrud;
    private final File taskCopyDir;
    private final TaskCopyValidatorPipelineTaskFilter taskCopyValidatorPipelineTaskFilter;

    TaskCopyExpectationPipelineTaskDirsExist(File taskCopyDir,
        PipelineInstance pipelineInstance,
        TaskCopyValidatorPipelineTaskFilter taskCopyValidatorPipelineTaskFilter) {
        this(taskCopyDir, pipelineInstance, new PipelineTaskCrud(),
            taskCopyValidatorPipelineTaskFilter);
    }

    TaskCopyExpectationPipelineTaskDirsExist(File taskCopyDir,
        PipelineInstance pipelineInstance, PipelineTaskCrud pipelineTaskCrud,
        TaskCopyValidatorPipelineTaskFilter taskCopyValidatorPipelineTaskFilter) {
        this.taskCopyDir = taskCopyDir;
        this.pipelineInstance = pipelineInstance;
        this.pipelineTaskCrud = pipelineTaskCrud;
        this.taskCopyValidatorPipelineTaskFilter = taskCopyValidatorPipelineTaskFilter;
    }

    @Override
    public boolean isMet() {
        Set<Long> taskCopyPipelineTaskIds = new HashSet<Long>();
        for (File taskDir : taskCopyDir.listFiles()) {
            if (taskDir.isDirectory()) {
                String[] taskDirNameParts = taskDir.getName()
                    .split(TASK_DIR_NAME_PART_SEPARATOR);
                Long pipelineTaskId = Long.valueOf(taskDirNameParts[taskDirNameParts.length - 1]);
                taskCopyPipelineTaskIds.add(pipelineTaskId);
            }
        }

        List<PipelineTask> pipelineTasks = pipelineTaskCrud.retrieveAll(pipelineInstance);

        pipelineTasks = taskCopyValidatorPipelineTaskFilter.filter(pipelineTasks);

        boolean met = true;
        for (PipelineTask pipelineTask : pipelineTasks) {
            long pipelineTaskId = pipelineTask.getId();
            if (!taskCopyPipelineTaskIds.contains(pipelineTaskId)) {
                log.warn("The taskCopyDir should contain a taskDir for every pipelineTaskId.\n  taskCopyDir: "
                    + taskCopyDir.getAbsolutePath()
                    + "\n  pipelineInstanceId: "
                    + pipelineInstance.getId()
                    + "\n  pipelineTaskId: " + pipelineTaskId);

                met = false;
            }
        }

        return met;
    }
}
