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

import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributeCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTaskAttributes;
import gov.nasa.kepler.pi.module.MatlabPipelineModule;
import gov.nasa.kepler.pi.module.WorkingDirManager;
import gov.nasa.spiffy.common.metrics.ValueMetric;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.filefilter.AndFileFilter;
import org.apache.commons.io.filefilter.IOFileFilter;
import org.apache.commons.io.filefilter.NameFileFilter;
import org.apache.commons.io.filefilter.NotFileFilter;
import org.apache.commons.io.filefilter.WildcardFileFilter;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Copy task files from the worker to another directory, typically
 * a shared volume.
 * 
 * This class uses {@link TaskFileCopyParameters} to control behavior.
 * 
 * @author tklaus
 *
 */
public class TaskFileCopy {
    private static final Log log = LogFactory.getLog(TaskFileCopy.class);

    private PipelineTask pipelineTask;
    private TaskFileCopyParameters copyParams;
    
    public TaskFileCopy(PipelineTask pipelineTask, TaskFileCopyParameters copyParams) {
        this.pipelineTask = pipelineTask;
        this.copyParams = copyParams;
    }

    public void copyTaskFiles() throws Exception{
        File srcTaskDir = WorkingDirManager.workingDir(pipelineTask);
        
        if(copyParams.isDeleteWithoutCopy()){
            log.warn("*** TEST USE ONLY ***: deleting source directory without copying");
            try {
                FileUtils.forceDelete(srcTaskDir);
            } catch (IOException e) {
                handleError("Failed to delete source task dir: " + srcTaskDir + ", caught e = " + e, e);                
                return;
            }
            log.info("Done deleting source directory");
        }else{
            String destPath = copyParams.getDestinationPath();
            File destDir = new File(destPath);
            
            if(!destDir.exists()){
                try {
                    FileUtils.forceMkdir(destDir);
                } catch (IOException e1) {
                    handleError("Unable to create destDir: " + destDir + ", caught e=" + e1);
                    return;
                }
            }
            
            log.info("srcTaskDir = " + srcTaskDir);
            log.info("destPath = " + destPath);
            
            if(!destDir.exists() || !destDir.isDirectory()){
                handleError("destDir does not exist or is not a directory: " + destPath);
                return;
            }
            
            if(srcTaskDir != null){
                File destTaskDir = new File(destDir,srcTaskDir.getName());
                File destTaskTmpDir = new File(destDir,srcTaskDir.getName() + ".in_progress");

                log.info("destTaskDir = " + destTaskDir);
                
                if(destTaskTmpDir.exists()){
                    try {
                        log.info("destTaskTmpDir already exists, deleting: " + destTaskTmpDir);
                        FileUtils.forceDelete(destTaskTmpDir);
                    } catch (IOException e) {
                        handleError("Unable to delete existing destTaskTmpDir: " + destTaskTmpDir + ", caught e=" + e);
                        return;
                    }
                }
                
                // setup exclude filter
                FileFilter excludeFilter = null;
                String[] wildcards = copyParams.getExcludeWildcards();
                if(wildcards != null && wildcards.length > 0){
                    excludeFilter = new NotFileFilter(new WildcardFileFilter(wildcards));
                    NotFileFilter svnFilter = new NotFileFilter(new NameFileFilter(".svn"));
                    excludeFilter = new AndFileFilter(svnFilter, (IOFileFilter) excludeFilter);
                    log.info("Using filter: " + excludeFilter);
                }
                
                // do copy
                try {
                    if(excludeFilter != null){
                        FileUtils.copyDirectory(srcTaskDir, destTaskTmpDir, excludeFilter);
                    }else{
                        FileUtils.copyDirectory(srcTaskDir, destTaskTmpDir);
                    }
                } catch (IOException e) {
                    handleError("Failed to copy task dir: " + srcTaskDir + ", caught e = " + e, e);   
                    return;
                }
                
                if (destTaskDir.exists()) {
                    destTaskDir.delete();
                }
                // rename dest now that copy is complete
                boolean renamed = destTaskTmpDir.renameTo(destTaskDir);
                if(!renamed){
                    handleError("Failed to rename: " + destTaskTmpDir + " -> " + destTaskDir);                
                    return;
                }
                
                // delete source
                if(copyParams.isDeleteAfterCopy()){
                    log.info("Copy complete, deleting source directory");
                    try {
                        FileUtils.forceDelete(srcTaskDir);
                    } catch (IOException e) {
                        handleError("Failed to delete source task dir: " + srcTaskDir + ", caught e = " + e, e);                
                        return;
                    }
                    log.info("Done deleting source directory");
                }
                
                // generate UOW symlinks if necessary
                if(copyParams.isUowSymlinksEnabled()){
                    try{
                        PipelineTaskAttributeCrud attrCrud = new PipelineTaskAttributeCrud();
                        PipelineTaskAttributes taskAttrs = attrCrud.retrieveByTaskId(pipelineTask.getId());

                        UowAnnotator uowAnnotator = new UowAnnotator();
                        uowAnnotator.generateAnnotationsForTask(pipelineTask, taskAttrs);
                    }catch(Exception e){
                        log.warn("Failed generate UOW symlinks for dir: " + srcTaskDir + ", caught e = " + e, e);   
                    }
                }
                
                // attempt to measure dest file sizes
                try {
                    long archiveSize = FileUtils.sizeOfDirectory(destTaskDir);
                    ValueMetric.addValue(MatlabPipelineModule.TF_ARCHIVE_SIZE_METRIC, archiveSize);
                } catch (Exception e) {
                    log.warn("Failed to size destTaskDir: " + destTaskDir + ", caught e = " + e, e);
                }
            }else{
                handleError("sourceTaskDir not found for pipelineTask: " + pipelineTask);
            }
        }
    }
    
    private void handleError(String msg){
        handleError(msg, null);
    }
    
    private void handleError(String msg, Exception e){
        log.error(msg, e);
        if(copyParams.isFailTaskOnError()){
            throw new PipelineException(msg, e);
        }
    }
    
    public static void main(String[] args) {
    }
}
