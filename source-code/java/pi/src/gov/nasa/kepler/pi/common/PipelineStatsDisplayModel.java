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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTask.State;
import gov.nasa.spiffy.common.collect.Pair;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Aggregates and displays stats for processing times for the
 * {@link PipelineTask}s that make up the specified {@link PipelineInstance}.
 * 
 * Sum, max, min, mean, and standard deviation are provided for each
 * module/state combination.
 * 
 * @author tklaus
 * 
 */
public class PipelineStatsDisplayModel extends DisplayModel {

	private List<Pair<Pair<String, State>, TaskProcessingTimeStats>> stats = new LinkedList<Pair<Pair<String, State>, TaskProcessingTimeStats>>();

	public PipelineStatsDisplayModel(List<PipelineTask> tasks,
			List<String> orderedModuleNames) {
		update(tasks, orderedModuleNames);
	}

	private void update(List<PipelineTask> tasks,
			List<String> orderedModuleNames) {
		stats = new LinkedList<Pair<Pair<String, State>, TaskProcessingTimeStats>>();

		Map<String, Map<State, List<PipelineTask>>> moduleStats = new HashMap<String, Map<State, List<PipelineTask>>>();

		for (PipelineTask task : tasks) {
			String moduleName = task.getPipelineInstanceNode()
					.getPipelineModuleDefinition().toString();

			Map<State, List<PipelineTask>> moduleMap = moduleStats
					.get(moduleName);
			if (moduleMap == null) {
				moduleMap = new HashMap<State, List<PipelineTask>>();
				moduleStats.put(moduleName, moduleMap);
			}

			State state = task.getState();
			List<PipelineTask> tasksSubList = moduleMap.get(state);
			if (tasksSubList == null) {
				tasksSubList = new LinkedList<PipelineTask>();
				moduleMap.put(state, tasksSubList);
			}

			tasksSubList.add(task);
		}

		State[] states = State.values();

		for (String moduleName : orderedModuleNames) {
			Map<State, List<PipelineTask>> moduleMap = moduleStats
					.get(moduleName);

			for (State state : states) {
				if (state != State.SUBMITTED) {
					List<PipelineTask> tasksSubList = moduleMap.get(state);
					if (tasksSubList != null) {
						TaskProcessingTimeStats s = TaskProcessingTimeStats
								.of(tasksSubList);

						Pair<String, State> key = Pair.of(moduleName, state);
						stats.add(Pair.of(key, s));
					}
				}
			}
		}
	}

	@Override
	public int getRowCount() {
		return stats.size();
	}

	@Override
	public int getColumnCount() {
		return 11;
	}

	@Override
	public Object getValueAt(int rowIndex, int columnIndex) {
		Pair<Pair<String, State>, TaskProcessingTimeStats> statsForTaskType = stats
				.get(rowIndex);
		Pair<String, State> key = statsForTaskType.left;
		TaskProcessingTimeStats s = statsForTaskType.right;

		switch (columnIndex) {
		case 0:
			return key.left;
		case 1:
			return key.right;
		case 2:
			return s.getCount();
		case 3:
			return formatDouble(s.getSum());
		case 4:
			return formatDouble(s.getMin());
		case 5:
			return formatDouble(s.getMax());
		case 6:
			return formatDouble(s.getMean());
		case 7:
			return formatDouble(s.getStddev());
		case 8:
			return formatDate(s.getMinStart());
		case 9:
			return formatDate(s.getMaxEnd());
		case 10:
			return formatDouble(s.getTotalElapsed());
        default:
            throw new IllegalArgumentException("Unexpected value: " + columnIndex);
		}
	}

	@Override
	public String getColumnName(int column) {
		switch (column) {
		case 0:
			return "Module";
		case 1:
			return "State";
		case 2:
			return "Count";
		case 3:
			return "Sum (hrs)";
		case 4:
			return "Min (hrs)";
		case 5:
			return "Max (hrs)";
		case 6:
			return "Mean (hrs)";
		case 7:
			return "Std (hrs)";
		case 8:
			return "Start";
		case 9:
			return "End";
		case 10:
			return "Elapsed (hrs)";
        default:
            throw new IllegalArgumentException("Unexpected value: " + column);
		}
	}

}
