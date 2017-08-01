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

import gov.nasa.kepler.services.process.PipelineProcessAdminRequest;
import gov.nasa.kepler.services.process.PipelineProcessAdminResponse;

import java.io.File;
import java.util.Collection;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.FileFilterUtils;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class requests that a worker copy a bin file dir into a destination dir.
 * 
 * @author Miles Cote
 * 
 */
public class WorkerTaskWorkingDirRequest extends PipelineProcessAdminRequest {

    private static final long serialVersionUID = 4210792720997328681L;

    private static final Log log = LogFactory.getLog(WorkerTaskWorkingDirRequest.class);

    private long instanceId = 0;
    private long taskId = 0;
    private File destDir;
    private boolean copyBinFiles = false;
    private boolean binFilesOnly = false;
    
    public WorkerTaskWorkingDirRequest(long instanceId, long taskId, File destDir) {
        this.instanceId = instanceId;
        this.taskId = taskId;
        this.destDir = destDir;
    }

    public WorkerTaskWorkingDirRequest(long instanceId, long taskId, File destDir, 
        boolean copyBinFiles, boolean binFilesOnly) {
        this.instanceId = instanceId;
        this.taskId = taskId;
        this.destDir = destDir;
        this.copyBinFiles = copyBinFiles;
        this.binFilesOnly = binFilesOnly;
    }

    @Override
    public PipelineProcessAdminResponse processRequest() {
        try {
            File srcDir = TaskWorkingDir.searchForTaskWorkingDir(instanceId, taskId);

            if (srcDir != null) {
                String status = "\nCopying srcDir to destDir." + "\n  srcDir = " + srcDir + "\n  destDir = " + destDir;
                log.info(status);

                IOFileFilter filter;
                
                if(binFilesOnly){
                    // ONLY copy .bin files
                    log.info("copying all files except .bin files");
                    filter = FileFilterUtils.suffixFileFilter(".bin");
                }else if(copyBinFiles){
                    // copy everything
                    log.info("copying all files");
                    filter = FileFilterUtils.trueFileFilter();
                }else{
                    // exclude .bin files
                    log.info("copying all files except .bin files");
                    filter = FileFilterUtils.notFileFilter(FileFilterUtils.suffixFileFilter(".bin"));
                    // If there are no mat files in srcDir, log an error and return a failure message
                    if (!directoryContainsFilesWithExtension(srcDir, "mat")) {
                        String message = "No .mat files in " + srcDir
                            + " for instanceId=" + instanceId + ", taskId="
                            + taskId;
                        log.error(message);
                        return new WorkerTaskWorkingDirResponse(false, message);
                    }

                }
                
                File dest = new File(destDir, srcDir.getName());
                
                FileUtils.deleteQuietly(dest);
                
                FileUtils.copyDirectory(srcDir, dest, filter);

                log.info("Completed copy.");

                return new WorkerTaskWorkingDirResponse(true, "Files copied to: \n" + dest);
            } else {
                return new WorkerTaskWorkingDirResponse(false, "No taskWorkingDir found in the archive for instanceId="
                    + instanceId + ", taskId=" + taskId);
            }
        } catch (Exception e) {
            log.error("Failed to fetch taskWorkingDir", e);
            return new WorkerTaskWorkingDirResponse(false, e.getMessage());
        }
    }
    

    /**
     * Returns true if directory or any of its subdirectories contains one or
     * more files or type extension, otherwise returns false.
     * 
     * @param directory
     * @param extension
     * @return
     */
    private boolean directoryContainsFilesWithExtension(File directory, String extension) {
        Collection<File> matchingFiles = FileUtils.listFiles(directory, new String[] {extension}, true);
        return matchingFiles.size() > 0;
    }
    
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + ((destDir == null) ? 0 : destDir.hashCode());
        result = prime * result + (int) (instanceId ^ (instanceId >>> 32));
        result = prime * result + (int) (taskId ^ (taskId >>> 32));
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        final WorkerTaskWorkingDirRequest other = (WorkerTaskWorkingDirRequest) obj;
        if (destDir == null) {
            if (other.destDir != null)
                return false;
        } else if (!destDir.equals(other.destDir))
            return false;
        if (instanceId != other.instanceId)
            return false;
        if (taskId != other.taskId)
            return false;
        return true;
    }

    /**
     * @return the instanceId
     */
    public long getInstanceId() {
        return instanceId;
    }

    /**
     * @return the taskId
     */
    public long getTaskId() {
        return taskId;
    }

    /**
     * @return the destDir
     */
    public File getDestDir() {
        return destDir;
    }

    /**
     * @return the copyBinFiles
     */
    public boolean isCopyBinFiles() {
        return copyBinFiles;
    }

    /**
     * @param copyBinFiles the copyBinFiles to set
     */
    public void setCopyBinFiles(boolean copyBinFiles) {
        this.copyBinFiles = copyBinFiles;
    }

}
