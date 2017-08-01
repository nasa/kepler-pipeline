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

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.pi.module.WorkingDirManager;

import java.io.File;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class allows the user to get the bin file dir for a {@link PipelineTask}.
 * 
 * @author Miles Cote
 * @author tklaus
 * 
 */
public class TaskWorkingDir {

    private static final Log log = LogFactory.getLog(TaskWorkingDir.class);

    private static String binFileDirPath = null;

    public static File searchForTaskWorkingDir(PipelineTask pipelineTask){
        return searchForTaskWorkingDir(pipelineTask.getPipelineInstance().getId(), pipelineTask.getId());
    }
    
    public static File searchForTaskWorkingDir(long instanceId, long taskId){
        File file = TaskWorkingDir.getWorkingDir(taskId);
        
        if(file != null && file.exists()){
            // this is the case where the workingDir is still in the current dist 
            return file;
        }else{
            // search the archive dir tree (/path/to/archive)
            String workingDirSuffix = WorkingDirManager.workingDirSuffix(instanceId, taskId);
            File archivedWorkingDir = null;
            long archivedWorkingDirModTime = 0;
            
            File archiveDir = new File(TaskLog.ARCHIVE_DIR);
            if(archiveDir.exists() && archiveDir.isDirectory()){
                File[] snapshots = archiveDir.listFiles();

                for (int i = 0; i < snapshots.length; i++) {
                    File snapshotDir = snapshots[i];
                    
                    log.debug("snapshotDir = " + snapshotDir);

                    File taskWorkingDirsDir = new File(snapshotDir, "tmp");
                    if(taskWorkingDirsDir.exists() && taskWorkingDirsDir.isDirectory()){
                        File[] taskWorkingDirs = taskWorkingDirsDir.listFiles();

                        for (int j = 0; j < taskWorkingDirs.length; j++) {
                            File taskWorkingDir = taskWorkingDirs[j];

                            log.debug("taskWorkingDir = " + taskWorkingDir);
                            
                            if(taskWorkingDir.getName().endsWith(workingDirSuffix) && taskWorkingDir.lastModified() > archivedWorkingDirModTime){
                                archivedWorkingDir = taskWorkingDir;
                                archivedWorkingDirModTime = taskWorkingDir.lastModified();
                                log.debug("archivedWorkingDir = " + archivedWorkingDir);
                                log.debug("archivedWorkingDirModTime = " + archivedWorkingDirModTime);
                            }
                        }
                    }
                }
            }
            
            if(archivedWorkingDir != null){
                log.info("found taskWorkingDir in the archive here: " + archivedWorkingDir);
                return archivedWorkingDir;
            }else{
                log.info("No taskWorkingDir found in the archive for suffix: " + workingDirSuffix);
                return null; // not found
            }
        }
    }
    
    private static File getWorkingDir(long taskId) {
        File binFileDir = new File(TaskWorkingDir.getWorkerModuleWorkingDir());

        File taskBinFileDir = null;
        for (File file : binFileDir.listFiles()) {
            if (file.getName()
                .endsWith("-" + taskId)) {
                taskBinFileDir = file;
            }
        }

        log.debug("file: " + taskBinFileDir);

        return taskBinFileDir;
    }

    private static synchronized String getWorkerModuleWorkingDir() {
        if (binFileDirPath == null) {
            Configuration config = ConfigurationServiceFactory.getInstance();
            binFileDirPath = config.getString(ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME);
        }

        return binFileDirPath;
    }

}
