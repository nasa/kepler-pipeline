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

import java.io.File;
import java.io.IOException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.FileAppender;
import org.apache.log4j.Layout;
import org.apache.log4j.Logger;
import org.apache.log4j.PatternLayout;

/**
 * This class creates a log4j {@link FileAppender} to capture
 * all logging output to a dedicated file for the current worker task.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class TaskLog {
    private static final Log log = LogFactory.getLog(TaskLog.class);

    public static final String ARCHIVE_DIR = "/path/to/archive";
    public static final String TASK_LOG_DIR_PROP = "pi.worker.taskLogDir";

    private Layout taskLogLayout = new PatternLayout("%d %-5p [%t:%C{1}.%M] %m%n");

    private int threadId = 0;
    private long instanceId = 0;
    private long taskId = 0;
    private int stepIndex = 0;
    
    private boolean enabled = false;
    private FileAppender taskLog = null;

    private File taskLogFile = null;
    
    private static String taskLogDir = null;

    public TaskLog(int threadId, long instanceId, long taskId, int stepIndex) {
        this.threadId = threadId;
        this.instanceId = instanceId;
        this.taskId = taskId;
        this.stepIndex = stepIndex;
        
        enabled = (TaskLog.getTaskLogDir() != null);
        
        log.info("enabled=" + enabled + ", taskLogDir=" + TaskLog.getTaskLogDir());
    }
    
    private static synchronized String getTaskLogDir(){
        if(taskLogDir == null){
            Configuration config = ConfigurationServiceFactory.getInstance();
            taskLogDir = config.getString(TASK_LOG_DIR_PROP);
            
            log.debug("taskLogDir: " + taskLogDir);
        }
        return taskLogDir;
    }
    
    public static File createTaskFile(long instanceId, long taskId, int stepIndex) {
        File taskLogDirFile = new File(TaskLog.getTaskLogDir());
        
        String taskLogFilename = taskLogFilename(instanceId, taskId, stepIndex);
        File file = new File(taskLogDirFile, taskLogFilename);
        
        log.info("file: " + file);
        
        return file;
    }

    public static File searchForTaskFile(long instanceId, long taskId, int stepIndex){
        File file = createTaskFile(instanceId, taskId, stepIndex);
        File oldStyleFile = createTaskFileOldStyle(instanceId, taskId);
        
        if(file.exists()){
            return file;
        }else if(oldStyleFile.exists()){
            return oldStyleFile;
        }else{
            // search the archive dir tree (/path/to/archive)
            String taskLogFilename = taskLogFilename(instanceId, taskId, stepIndex);
            String oldStyleTaskLogFilename = oldStyleTaskLogFilename(instanceId, taskId);
            
            File archiveDir = new File(ARCHIVE_DIR);
            if(archiveDir.exists() && archiveDir.isDirectory()){
                File[] snapshots = archiveDir.listFiles();

                for (int i = 0; i < snapshots.length; i++) {
                    File snapshotDir = snapshots[i];
                    File taskLogDirFile = new File(snapshotDir, "logs/tasks");
                    if(taskLogDirFile.exists() && taskLogDirFile.isDirectory()){
                        File taskLogFile = new File(taskLogDirFile, taskLogFilename);
                        File oldStyleTaskLogFile = new File(taskLogDirFile, oldStyleTaskLogFilename);

                        if(taskLogFile.exists()){
                            return taskLogFile;
                        }

                        if(oldStyleTaskLogFile.exists()){
                            return oldStyleTaskLogFile;
                        }
                    }
                }
            }
        }
        return null; // not found
    }
    
    /**
     * @param instanceId
     * @param taskId
     * @return
     */
    private static String taskLogFilename(long instanceId, long taskId, int stepIndex) {
        String taskLogFilename;
        
        if(stepIndex >= 0){
            taskLogFilename = "task-" + instanceId + "-" + taskId + "-" + stepIndex + ".log";
        }else{
            // old style for backwards compatibility
            taskLogFilename = "task-" + instanceId + "-" + taskId + ".log";
        }
        return taskLogFilename;
    }
    
    public void startLogging(){
        if(enabled){
            taskLogFile = createTaskFile(instanceId, taskId, stepIndex);
            File taskLogDir = taskLogFile.getParentFile();
            
            try {
                if(!taskLogDir.exists()){
                    log.info("Creating task log dir: " + taskLogDir);
                    FileUtils.forceMkdir(taskLogDir);
                }
                log.info("Creating task log file: " + taskLogFile);
                taskLog = new TaskLogAppender("task-" + threadId, taskLogLayout, taskLogFile.getAbsolutePath());
            } catch (IOException e) {
                log.warn("failed to create taskLog FileAppender at: " + taskLogFile);
            }
            Logger.getRootLogger().addAppender(taskLog);
        }
    }

    public void endLogging(){
        if(enabled){
            Logger.getRootLogger().removeAppender(taskLog);
            taskLog.close();
            taskLogFile = null;
        }
    }
    
    /**
     * For backward compatibility with task log filenames without a stepIndex
     */
    private static File createTaskFileOldStyle(long instanceId, long taskId) {
        File taskLogDirFile = new File(TaskLog.getTaskLogDir());
        
        String taskLogFilename = taskLogFilename(instanceId, taskId, -1);
        File file = new File(taskLogDirFile, taskLogFilename);
        
        log.info("file: " + file);
        
        return file;
    }

    /**
     * For backward compatibility with task log filenames without a stepIndex
     */
    private static String oldStyleTaskLogFilename(long instanceId, long taskId) {
        return taskLogFilename(instanceId, taskId, -1);
    }
}
