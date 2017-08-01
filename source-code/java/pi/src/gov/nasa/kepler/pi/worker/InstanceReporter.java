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

import static com.google.common.base.Preconditions.checkNotNull;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.pi.common.InstancesDisplayModel;
import gov.nasa.kepler.pi.common.PipelineStatsDisplayModel;
import gov.nasa.kepler.pi.common.TaskMetricsDisplayModel;
import gov.nasa.kepler.pi.common.TaskSummaryDisplayModel;
import gov.nasa.kepler.pi.common.TasksStates;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintStream;
import java.util.List;
import java.util.Map;

/**
 * Creates a report for a {@link PipelineInstance}.
 * 
 * @author Miles Cote
 * 
 */
public class InstanceReporter {

    public File report(PipelineInstance instance, File outputDir)
        throws FileNotFoundException {
        checkNotNull(instance, "instance cannot be null.");
        checkNotNull(outputDir, "outputDir cannot be null.");

        outputDir.mkdirs();

        File reportFile = new File(outputDir, "instance-" + instance.getId()
            + "-report.txt");
        reportFile.delete();

        PrintStream printStream = new PrintStream(reportFile);

        printStream.print("state: " + instance.getState() + "\n\n");

        InstancesDisplayModel instancesDisplayModel = new InstancesDisplayModel(
            instance);
        instancesDisplayModel.print(printStream, "Instance Summary");
        printStream.println();

        PipelineTaskCrud pipelineTaskCrud = new PipelineTaskCrud();
        List<PipelineTask> tasks = pipelineTaskCrud.retrieveAll(instance);

        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
        Map<Long, PipelineTaskAttributes> taskAttrs = attrCrud.retrieveByInstanceId(instance.getId());
        
        TaskSummaryDisplayModel taskSummaryDisplayModel = new TaskSummaryDisplayModel(
            new TasksStates(tasks, taskAttrs));
        taskSummaryDisplayModel.print(printStream, "Instance Task Summary");

        TasksStates tasksStates = taskSummaryDisplayModel.getTaskStates();
        List<String> orderedModuleNames = tasksStates.getModuleNames();

        PipelineStatsDisplayModel pipelineStatsDisplayModel = new PipelineStatsDisplayModel(
            tasks, orderedModuleNames);
        pipelineStatsDisplayModel.print(printStream,
            "Processing Time Statistics");

        TaskMetricsDisplayModel taskMetricsDisplayModel = new TaskMetricsDisplayModel(
            tasks, orderedModuleNames);
        taskMetricsDisplayModel.print(printStream,
            "Processing Time Breakdown (completed tasks only)");

        printStream.close();

        return reportFile;
    }

}
