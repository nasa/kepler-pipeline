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

package gov.nasa.kepler.pi.module;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.util.TreeSet;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Names, creates, and deletes the temporary working directories 
 * for external process invocation.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 */
public class WorkingDirManager {
    private static final Log log = LogFactory.getLog(WorkingDirManager.class);

    private static final String MODULE_EXE_WORKING_DIR_MAX_PROPERTY_NAME = "pi.worker.moduleExe.workingDir.maxPreserve";
    
    private File rootWorkingDir;
    private int maxDirsToPreserve;
    
    public WorkingDirManager() {        
        rootWorkingDir = new File(workingDirParent());

        Configuration config = ConfigurationServiceFactory.getInstance();
        maxDirsToPreserve = config.getInteger(MODULE_EXE_WORKING_DIR_MAX_PROPERTY_NAME, 100);
    }

    public static String workingDirParent(){
        Configuration config = ConfigurationServiceFactory.getInstance();
        
        String workingDirParent = config.getString(ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME);
        
        if (workingDirParent == null) {
            throw new PipelineException(ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME + " prop must be defined!");
        }
        
        return workingDirParent;
    }
    
    public static String workingDirPrefix(PipelineTask pipelineTask){
        return pipelineTask.moduleExeName() + "-matlab";
    }

    public static String workingDirSuffix(PipelineTask pipelineTask){
        return workingDirSuffix(pipelineTask.getPipelineInstance().getId(), pipelineTask.getId());
    }

    public static String workingDirSuffix(long instanceId, long taskId){
        return "-" + instanceId + "-" + taskId;
    }

    public static File workingDirBaseName(PipelineTask pipelineTask){
        return new File(workingDirPrefix(pipelineTask) + workingDirSuffix(pipelineTask));
    }

    public static File workingDir(PipelineTask pipelineTask){
        return workingDir(workingDirPrefix(pipelineTask), workingDirSuffix(pipelineTask));
    }

    private static File workingDir(String workingDirPrefix, String workingDirSuffix){
        return new File(workingDirParent(), workingDirPrefix + workingDirSuffix);
    }

    public synchronized File allocateWorkingDir(String workingDirPrefix, long instanceId, long taskId) throws IOException{
        File workingDir = new File(rootWorkingDir, workingDirPrefix + workingDirSuffix(instanceId, taskId));
        
        if(workingDir.exists()){
            log.info("Working directory for name=" + taskId + " already exists, deleting");
            FileUtils.deleteDirectory(workingDir);
        }
        
        log.info("Creating task working dir: " + workingDir);
        FileUtils.forceMkdir(workingDir);
        
        return workingDir;
    }
    
    public synchronized void releaseWorkingDir() throws IOException{
    
        // cleanup if we have exceeded the max
        File[] files = rootWorkingDir.listFiles();
        
        if(files.length > maxDirsToPreserve){
            TreeSet<TimeOrderedFile> dirs = new TreeSet<TimeOrderedFile>();
            
            for (int i = 0; i < files.length; i++) {
                if(files[i].isDirectory()){
                    dirs.add(new TimeOrderedFile(files[i]));
                }
            }
            
            int index = 1;
            for (TimeOrderedFile dir : dirs) {
                if(index > maxDirsToPreserve){
                    log.info("deleting expired working dir: " + dir.getFile());
                    FileUtils.deleteDirectory(dir.getFile());
                }
                index++;
            }
        }
    }
    
    /**
     * Simple wrapper around File that implements Comparable
     * based on the file's modify time
     * 
     * @author tklaus
     *
     */
    private class TimeOrderedFile implements Comparable<TimeOrderedFile>{

        private File file;
        
        public TimeOrderedFile(File file) {
            this.file = file;
        }

        @Override
        public int compareTo(TimeOrderedFile o) {
            if(FileUtils.isFileNewer(this.file, o.file)){
                return -1;
            }else{
                return 1;
            }
        }

        public File getFile() {
            return file;
        }
    }
}
