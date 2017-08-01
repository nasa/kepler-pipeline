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

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.pi.UnitOfWorkTask;
import gov.nasa.kepler.pi.module.WorkingDirManager;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus todd.klaus@nasa.gov
 * 
 */
public class UowAnnotator {
	private static final Log log = LogFactory.getLog(UowAnnotator.class);

	public UowAnnotator() {
	}

	public void generateAnnotationsForTask(PipelineTask task, PipelineTaskAttributes taskAttrs) {
		// no parameter overrides, uses parameters associated with the task
		generateAnnotationsForTask(task, taskAttrs, new HashMap<Class<? extends Parameters>, Parameters>());
	}

	public void generateAnnotationsForTask(PipelineTask task, PipelineTaskAttributes taskAttrs,
			Map<Class<? extends Parameters>, Parameters> overrides) {

		log.info("Generating UOW symlinks for task: " + task.getId() + ", module: " + task.getModuleName());

		TaskFileCopyParameters p = (TaskFileCopyParameters) overrides.get(TaskFileCopyParameters.class);
		if (p == null) {
			p = task.getParameters(TaskFileCopyParameters.class, false);
		}

		File taskFilesDir = new File(p.getDestinationPath());
		File uowSymlinkDir = new File(p.getUowSymlinkPath());
		File taskDir = new File(taskFilesDir, WorkingDirManager.workingDirBaseName(task).getName());

		try {
			FileUtils.forceMkdir(uowSymlinkDir);
		} catch (Exception ignore) {
			log.warn("Failed to mk symlink dir: " + ignore);
		}

		String taskPrefix = task.getModuleName() + "-" + task.getPipelineInstance().getId();

		UnitOfWorkTask uow = task.getUowTask().getInstance();
		Pair<List<String>, Boolean> uowSymlinkData = uow.makeUowSymlinks(task, taskAttrs, overrides);
		List<String> uowDescriptors = uowSymlinkData.left;
		boolean makeLinksToTaskDir = uowSymlinkData.right;

		if (uowDescriptors != null) {
			int numLinks = uowDescriptors.size();
			if (numLinks > 0) {
				if (makeLinksToTaskDir) {
					// link to task dir
					makeSymlink(taskDir, uowSymlinkDir, taskPrefix + "-" + uowDescriptors.get(0));
				} else {
					File[] taskSubDirs = taskDir.listFiles(new FileFilter() {
						@Override
						public boolean accept(File f) {
							return (f.isDirectory() && (f.getName().startsWith("st-") || f.getName().startsWith("g-")));
						}
					});

					List<File> taskSubDirList = Arrays.asList(taskSubDirs);
					Collections.sort(taskSubDirList);
					 
					int index = 0;
					for (File subTaskDir : taskSubDirList) {
					    String symLinkName = index < uowDescriptors.size() ? uowDescriptors.get(index) : "MISSING";
						makeSymlink(subTaskDir, uowSymlinkDir, taskPrefix + "-" + symLinkName);
						index++;
					}
				}
			} else {
				log.warn("makeUowSymlinks returned 0 links");
			}
		} else {
			log.warn("makeUowSymlinks returned NULL");
		}
	}

	public void generateAnnotations(int instanceId, String moduleExeName, File uowSymlinkDir, File taskFilesDir, boolean includeMonths, boolean includeCadenceRange)
			throws Exception {

		if (!taskFilesDir.exists() || !taskFilesDir.isDirectory()) {
			throw new PipelineException("taskFileDir does not exist or is not a directory: " + taskFilesDir);
		}

		if (!uowSymlinkDir.exists()) {
			try {
				FileUtils.forceMkdir(uowSymlinkDir);
			} catch (IOException e1) {
				throw new PipelineException("Unable to create uowSymlinkDir: " + uowSymlinkDir + ", caught e=" + e1);
			}
		}

		log.info("taskFilesDir = " + taskFilesDir);
		log.info("uowSymlinkDir = " + uowSymlinkDir);

		TaskFileCopyParameters taskCopyParams = new TaskFileCopyParameters();
		taskCopyParams.setUowSymlinksEnabled(true);
		taskCopyParams.setDestinationPath(taskFilesDir.getAbsolutePath());
		taskCopyParams.setUowSymlinkPath(uowSymlinkDir.getAbsolutePath());
		taskCopyParams.setUowSymlinksIncludeMonths(includeMonths);
		taskCopyParams.setUowSymlinksIncludeCadenceRange(includeCadenceRange);

		Map<Class<? extends Parameters>, Parameters> overrides = new HashMap<Class<? extends Parameters>, Parameters>();
		overrides.put(TaskFileCopyParameters.class, taskCopyParams);

		PipelineInstanceCrud instanceCrud = new PipelineInstanceCrud();
		PipelineInstance instance = instanceCrud.retrieve(instanceId);

		if (instance == null) {
			throw new PipelineException("No instance found with id=" + instanceId);
		}

		PipelineTaskCrud taskCrud = new PipelineTaskCrud();
		PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();

		List<PipelineTask> tasks = taskCrud.retrieveAll(instance);
		Map<Long, PipelineTaskAttributes> taskAttrsMap = attrCrud.retrieveByInstanceId(instanceId);

		for (PipelineTask task : tasks) {
		    if (task.getModuleName().equals(moduleExeName)) {
			    generateAnnotationsForTask(task, taskAttrsMap.get(task.getId()), overrides);
		    }
		}
	}

	/**
	 * Utility function for creating UOW symlinks
	 * 
	 * @param taskFilesDir
	 * @param destDir
	 * @param symlinkName
	 */
	protected void makeSymlink(File src, File destDir, String symlinkName) {
		File dest = new File(destDir, symlinkName);
		String command = "/bin/ln -s " + src + " " + dest;

		try {
			log.info("Execing: " + command);
			Process p = Runtime.getRuntime().exec(command);
			int rc = p.waitFor();
			log.info("rc: " + rc);
		} catch (Exception e) {
			log.warn("failed to create symlink: " + e + ", cmd: " + command);
		}
	}

	private static void usage() {
		System.out.println("uow-annotate PIPELINE_INSTANCE_ID MODULE_EXE_NAME SYMLINK_DIR TASK_FILES_DIR INCLUDE_MONTHS INICLUDE_CADENCE_RANGE");
		System.out.println("Example:");
		System.out
				.println(" uow-annotate 7170 cal /path/to/OPS/MQ-q1-to-q12/pipeline_results/pdc/uow /path/to/OPS/MQ-q1-to-q12/pipeline_results/pdc/ true true");
	}

	public static void main(String[] args) throws Exception {
        if (args.length < 5) {
            usage();
            System.exit(-1);
        }

        int instanceId = -1;
        String moduleExeName = null;
        File uowSymlinkDir = null;
        File taskFilesDir = null;
        boolean includeMonths = false;
        boolean includeCadenceRange = false;

        try {
            instanceId = Integer.parseInt(args[0]);
            moduleExeName = args[1];
            uowSymlinkDir = new File(args[2]);
            taskFilesDir = new File(args[3]);
            includeMonths = Boolean.parseBoolean(args[4]);
            includeCadenceRange = Boolean.parseBoolean(args[5]);
        } catch (Exception e) {
            System.err.println("Failed to parse command line: " + args);
            System.exit(-1);
        }

        UowAnnotator uowAnnotator = new UowAnnotator();
        uowAnnotator.generateAnnotations(instanceId, moduleExeName, uowSymlinkDir, taskFilesDir, includeMonths, includeCadenceRange);
	}
}
