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
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Validates that a task-copy command was successful.
 * 
 * @author Miles Cote
 * 
 */
public class TaskCopyValidator {

    private final List<TaskCopyExpectation> taskCopyExpectations;

    public TaskCopyValidator(List<TaskCopyExpectation> taskCopyExpectations) {
        this.taskCopyExpectations = taskCopyExpectations;
    }

    public boolean isValid() {
        boolean valid = true;
        for (TaskCopyExpectation taskCopyExpectation : taskCopyExpectations) {
            valid = valid && taskCopyExpectation.isMet();
        }

        return valid;
    }

    public static void main(String[] args) {
        if (args.length != 3) {
            System.err.println("USAGE: validate-task-copy TASK_COPY_DIR PIPELINE_INSTANCE_ID MODULE_EXE_NAME");
            System.err.println("EXAMPLE: validate-task-copy /path/to/TEST/pipeline_results/planet-search/lc/dv/i4178--integ-7.0-i20-at-41191--q1-q6 4178 dv");
            System.exit(-1);
        }

        File taskCopyDir = new File(args[0]);
        if (!taskCopyDir.exists()) {
            throw new IllegalArgumentException(
                "The taskCopyDir must exist.\n  taskCopyDir: "
                    + taskCopyDir.getAbsolutePath());
        }

        long pipelineInstanceId = Long.parseLong(args[1]);
        PipelineInstanceCrud pipelineInstanceCrud = new PipelineInstanceCrud();
        PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(pipelineInstanceId);
        if (pipelineInstance == null) {
            throw new IllegalArgumentException(
                "The pipelineInstanceId must exist in the database.\n  pipelineInstanceId: "
                    + pipelineInstanceId);
        }

        String moduleExeName = args[2];

        TaskCopyValidatorPipelineTaskFilter taskCopyValidatorPipelineTaskFilter = new TaskCopyValidatorPipelineTaskFilter(
            moduleExeName);

        List<TaskCopyExpectation> taskCopyExpectations = new ArrayList<TaskCopyExpectation>();
        taskCopyExpectations.add(new TaskCopyExpectationPipelineTaskDirsExist(
            taskCopyDir, pipelineInstance, taskCopyValidatorPipelineTaskFilter));
        taskCopyExpectations.add(new TaskCopyExpectationOutputsMatFilesExist(
            taskCopyDir));

        TaskCopyValidator taskCopyValidator = new TaskCopyValidator(
            taskCopyExpectations);
        boolean valid = taskCopyValidator.isValid();

        System.out.println("\n\nSummary: Task Copy valid? " + valid + "\n\n");
        System.exit(0);
    }

}
