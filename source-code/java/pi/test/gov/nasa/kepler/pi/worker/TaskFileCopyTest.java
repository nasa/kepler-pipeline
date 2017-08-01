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
import gov.nasa.kepler.hibernate.pi.PipelineInstanceNode;
import gov.nasa.kepler.hibernate.pi.PipelineModuleDefinition;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;

import java.io.File;

import junit.framework.Assert;

import org.apache.commons.io.FileUtils;
import org.jfree.util.Log;
import org.junit.After;
import org.junit.Test;

public class TaskFileCopyTest {

    private static final String ROOT_DIR = "testdata/TaskFileCopy/";
    private static final String SOURCE_DIR = ROOT_DIR + "src";
    private static final String ROOT_WORKING_DIR = ROOT_DIR + "tmp";
    private static final String ARCHIVE_DIR = ROOT_DIR + "archive";
    
    private static final int PIPELINE_INSTANCE_ID = 17;
    private static final int PIPELINE_TASK_ID = 65;
    
    private static final String TASK_DIR_NAME = "debug-matlab-" + PIPELINE_INSTANCE_ID + "-" + PIPELINE_TASK_ID;
    
    private File workingDir;
    private File archiveDir;
    private File binFile;
    private File metricsFile;
    
    public void setUp() throws Exception{

        // make a working copy for the test
        File src = new File(SOURCE_DIR, TASK_DIR_NAME);
        workingDir = new File(ROOT_WORKING_DIR, TASK_DIR_NAME);
        archiveDir = new File(ARCHIVE_DIR, TASK_DIR_NAME);
        binFile = new File(archiveDir.getAbsolutePath(), "st-0/debug-outputs-0.bin"); 
        metricsFile = new File(archiveDir.getAbsolutePath(), "st-0/metrics-0.ser"); 

        if(workingDir.exists()){
            FileUtils.forceDelete(workingDir);
        }
        
        if(archiveDir.exists()){
            FileUtils.forceDelete(archiveDir);
        }
        
        FileUtils.copyDirectory(src, workingDir);
    }

    @After
    public void tearDown() throws Exception {
        try {
            FileUtils.forceDelete(workingDir);
            FileUtils.forceDelete(archiveDir);
        } catch (Exception e) {
            Log.error("failed to delete dirs, caught: " + e);
        }
    }

    @Test
    public void testWildcardsDelete() throws Exception{
        doTestCopy(new String[]{"*.bin","*.ser"}, true);
    }
    
    @Test
    public void testWildcardsNoDelete() throws Exception{
        doTestCopy(new String[]{"*.bin","*.ser"}, false);
    }
    
    @Test
    public void testNoWildcardsDelete() throws Exception{
        doTestCopy(new String[0], true);
    }
    
    @Test
    public void testNoWildcardsNoDelete() throws Exception{
        doTestCopy(new String[0], false);
    }
    
    public void doTestCopy(String[] excludeWildcards, boolean deleteAfterCopy) throws Exception{
        setUp();
        
        TaskFileCopyParameters copyParams = new TaskFileCopyParameters();
        copyParams.setEnabled(true);
        copyParams.setDestinationPath(archiveDir.getParentFile().getAbsolutePath());
        copyParams.setExcludeWildcards(excludeWildcards);
        copyParams.setDeleteAfterCopy(deleteAfterCopy);
        copyParams.setFailTaskOnError(true);
        
        PipelineTask task = new PipelineTask();
        task.setId(PIPELINE_TASK_ID);

        PipelineInstanceNode in = new PipelineInstanceNode();
        PipelineModuleDefinition pmd = new PipelineModuleDefinition();
        pmd.setExeName("debug");
        in.setPipelineModuleDefinition(pmd);
        task.setPipelineInstanceNode(in);
        
        PipelineInstance instance = new PipelineInstance();
        instance.setId(PIPELINE_INSTANCE_ID);
        task.setPipelineInstance(instance);

        System.setProperty(ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME, workingDir.getParentFile().getAbsolutePath());  
        
        TaskFileCopy copier = new TaskFileCopy(task, copyParams);
        
        copier.copyTaskFiles();
        
        if(excludeWildcards.length > 0){
            Assert.assertFalse("binFile exist = FALSE", binFile.exists());
            Assert.assertFalse("metricsFile exist = FALSE", metricsFile.exists());
        }else{
            Assert.assertTrue("binFile exist = TRUE", binFile.exists());
            Assert.assertTrue("metricsFile exist = TRUE", metricsFile.exists());
        }

        if(deleteAfterCopy){
            Assert.assertFalse("workingDir exist = FALSE", workingDir.exists());
        }else{
            Assert.assertTrue("workingDir exist = TRUE", workingDir.exists());
        }
        
        tearDown();
    }
}
