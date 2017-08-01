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

import gov.nasa.kepler.pi.module.ExternalProcessPipelineModule;
import gov.nasa.kepler.services.process.PipelineProcessAdminResponse;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;

import junit.framework.Assert;

import org.junit.Test;

public class WorkerTaskWorkingDirRequestTest {

    private static final int TASK_ID = 1;
    private static final int INSTANCE_ID = 1;
    private File expectedCopiedTaskBinFileDir;
    private WorkerTaskWorkingDirRequest request;
    private File srcDir;
    private File destDir;

    @Test
    public void testCopyAll() throws Exception {
        setUp(true, true);

        boolean copyBin = true;
        boolean binOnly = false;
        request = new WorkerTaskWorkingDirRequest(INSTANCE_ID, TASK_ID, destDir, copyBin, binOnly);
        PipelineProcessAdminResponse response = request.processRequest();

        Assert.assertTrue(response.isSuccessful());
        Assert.assertTrue(expectedCopiedTaskBinFileDir.exists());
        verifyDestContents(copyBin, !binOnly);
    }

    @Test
    public void testCopyBinOnly() throws Exception {
        setUp(true, true);

        boolean copyBin = true;
        boolean binOnly = true;
        request = new WorkerTaskWorkingDirRequest(INSTANCE_ID, TASK_ID, destDir, copyBin, binOnly);
        PipelineProcessAdminResponse response = request.processRequest();

        Assert.assertTrue(response.isSuccessful());
        Assert.assertTrue(expectedCopiedTaskBinFileDir.exists());
        verifyDestContents(copyBin, !binOnly);
    }

    @Test
    public void testCopyMatOnly() throws Exception {
        setUp(true, true);

        boolean copyBin = false;
        boolean binOnly = false;
        request = new WorkerTaskWorkingDirRequest(INSTANCE_ID, TASK_ID, destDir, copyBin, binOnly);
        PipelineProcessAdminResponse response = request.processRequest();

        Assert.assertTrue(response.isSuccessful());
        Assert.assertTrue(expectedCopiedTaskBinFileDir.exists());
        verifyDestContents(copyBin, !binOnly);
    }

    @Test
    public void testCopyMissing() throws Exception {
        setUp(false, false);

        boolean copyBin = false;
        boolean binOnly = false;
        request = new WorkerTaskWorkingDirRequest(INSTANCE_ID, TASK_ID, destDir, copyBin, binOnly);
        PipelineProcessAdminResponse response = request.processRequest();

        Assert.assertFalse(response.isSuccessful());
    }

    private void setUp(boolean createBin, boolean createMat) throws Exception {
        srcDir = new File(Filenames.BUILD_TMP, "/foo-" + INSTANCE_ID + "-" + TASK_ID);
        FileUtil.cleanDir(srcDir);

        if(createBin){
            File srcBin = new File(srcDir, "foo.bin");
            if(!srcBin.createNewFile()){
                throw new Exception("Failed to create: " + srcBin);            
            }
        }

        if(createMat){
            File srcMat = new File(srcDir, "foo.mat");
            if(!srcMat.createNewFile()){
                throw new Exception("Failed to create: " + srcMat);            
            }
        }
        
        destDir = new File(Filenames.BUILD_TMP, "/foo-dest-dir");
        FileUtil.cleanDir(destDir);

        expectedCopiedTaskBinFileDir = new File(destDir, srcDir.getName());
        System.setProperty(
            ExternalProcessPipelineModule.MODULE_EXE_WORKING_DIR_PROPERTY_NAME,
            Filenames.BUILD_TMP);
    }

    private void verifyDestContents(boolean expectBin, boolean expectMat){
        File dest = new File(destDir,srcDir.getName());
        
        File destBin = new File(dest, "foo.bin");
        File destMat = new File(dest, "foo.mat");
        
        if(expectBin && !destBin.exists()){
            Assert.fail("Expected a .bin file, but none found!");
        }

        if(expectMat && !destMat.exists()){
            Assert.fail("Expected a .mat file, but none found!");
        }
    }
}
