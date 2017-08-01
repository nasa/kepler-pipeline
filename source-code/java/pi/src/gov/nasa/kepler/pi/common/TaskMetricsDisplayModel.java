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
import gov.nasa.spiffy.common.collect.Pair;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang.time.DurationFormatUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Display a table containing a row for each pipeline module and a column for
 * each category defined in PipelineTask.summaryMetrics.
 * 
 * The cells of the table contain the total time spent on each category for all
 * tasks for the pipeline module and the percentage of the total processing time
 * for all of the tasks.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class TaskMetricsDisplayModel extends DisplayModel {
	@SuppressWarnings("unused")
	private static final Log log = LogFactory
			.getLog(TaskMetricsDisplayModel.class);

	/* List<Pair<moduleName,taskMetrics>> */
	private List<Pair<String, TaskMetrics>> categorySummariesByModule = new LinkedList<Pair<String, TaskMetrics>>();
	private List<String> seenCategories = new ArrayList<String>();
	private int numColumns = 0;

    private boolean completedTasksOnly = false;

    public TaskMetricsDisplayModel(List<PipelineTask> tasks,
        List<String> orderedModuleNames) {
    this(tasks, orderedModuleNames, true);
}

    public TaskMetricsDisplayModel(List<PipelineTask> tasks,
        List<String> orderedModuleNames, boolean completedTasksOnly) {
        this.completedTasksOnly  = completedTasksOnly;
        
    update(tasks, orderedModuleNames);
}

	private void update(List<PipelineTask> tasks,
			List<String> orderedModuleNames) {
		categorySummariesByModule = new LinkedList<Pair<String, TaskMetrics>>();
		seenCategories = new ArrayList<String>();

		Map<String, List<PipelineTask>> tasksByModule = new HashMap<String, List<PipelineTask>>();

		// partition the tasks by module
        for (PipelineTask task : tasks) {
            if (!completedTasksOnly || 
                (task.getState() == PipelineTask.State.COMPLETED ||
                    task.getState() == PipelineTask.State.PARTIAL)) {
                String moduleName = task.getPipelineInstanceNode()
                    .getPipelineModuleDefinition()
                    .toString();

                List<PipelineTask> taskListForModule = tasksByModule.get(moduleName);
                if (taskListForModule == null) {
                    taskListForModule = new LinkedList<PipelineTask>();
                    tasksByModule.put(moduleName, taskListForModule);
                }
                taskListForModule.add(task);
            }
        }

		// for each module, aggregate the summary metrics by category
		// and build a list of categories
		for (String moduleName : orderedModuleNames) {
			List<PipelineTask> taskListForModule = tasksByModule
					.get(moduleName);
			TaskMetrics taskMetrics = new TaskMetrics(taskListForModule);
			categorySummariesByModule.add(Pair.of(moduleName, taskMetrics));

			Set<String> categories = taskMetrics.getCategoryMetrics().keySet();
			for (String category : categories) {
				if (!seenCategories.contains(category)) {
					seenCategories.add(category);
				}
			}
		}
		numColumns = seenCategories.size() + 3;
	}

	@Override
	public int getColumnCount() {
		return numColumns;
	}

	@Override
	public String getColumnName(int column) {
		if (column == 0) {
			return "Module";
		} else if (column == 1) {
			return "Total";
		} else if (column == numColumns - 1) {
			return "Other";
		} else {
			return seenCategories.get(column - 2);
		}
	}

	@Override
	public int getRowCount() {
		return categorySummariesByModule.size();
	}

	@Override
	public Object getValueAt(int rowIndex, int columnIndex) {
		Pair<String, TaskMetrics> row = categorySummariesByModule.get(rowIndex);

		if (columnIndex == 0) {
			return row.left; // module name
		} else if (columnIndex == 1) {
			return formatDuration(row.right.getTotalProcessingTimeMillis()); // total
		} else if (columnIndex == numColumns - 1) {
			return categoryValuesString(row.right.getUnallocatedTime());
		} else {
			String category = seenCategories.get(columnIndex - 2);
			Pair<Long, Double> categoryValues = row.right.getCategoryMetrics()
					.get(category);
			return categoryValuesString(categoryValues);
		}
	}

	private String categoryValuesString(Pair<Long, Double> categoryValues) {
		if (categoryValues != null) {
			long categoryTimeMillis = categoryValues.left;
			double categoryPercent = categoryValues.right;
			return String.format("%s (%4.1f%%)",
					formatDuration(categoryTimeMillis), categoryPercent);
		} else {
			return "--";
		}
	}

	private String formatDuration(long durationMillis) {
		return DurationFormatUtils.formatDuration(durationMillis, "HHH:mm:ss");
	}
}
