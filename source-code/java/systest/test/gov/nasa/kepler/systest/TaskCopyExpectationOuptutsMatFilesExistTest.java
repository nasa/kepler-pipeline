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

package gov.nasa.kepler.systest;

import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.io.File;
import java.io.IOException;

import org.apache.commons.io.FileUtils;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class TaskCopyExpectationOuptutsMatFilesExistTest extends JMockTest {

    private File taskCopyDir = new File(Filenames.BUILD_TMP,
        "taskCopyDir");
    private File outputsMatFile = new File(taskCopyDir,
        TaskCopyExpectationOutputsMatFilesExist.OUTPUTS_MAT_FILE_SUFFIX);
    private File subDir = new File(taskCopyDir, "subDir");

    private TaskCopyExpectationOutputsMatFilesExist taskCopyExpectationOutputsMatFilesExist = new TaskCopyExpectationOutputsMatFilesExist(
        taskCopyDir);

    @Before
    public void setUp() throws IOException {
        FileUtil.cleanDir(taskCopyDir);
        outputsMatFile.createNewFile();
    }

    @Test
    public void testIsMet() {
        boolean actualMet = taskCopyExpectationOutputsMatFilesExist.isMet();

        assertEquals(true, actualMet);
    }

    @Test
    public void testIsMetWithNoOutputsMatFile() {
        outputsMatFile.renameTo(new File(taskCopyDir, "not-an-outputs-mat-file"));

        boolean actualMet = taskCopyExpectationOutputsMatFilesExist.isMet();

        assertEquals(false, actualMet);
    }

    @Test
    public void testIsMetWithOutputsMatFileInSubDir() throws IOException {
        FileUtils.moveFileToDirectory(outputsMatFile, subDir, true);

        boolean actualMet = taskCopyExpectationOutputsMatFilesExist.isMet();

        assertEquals(true, actualMet);
    }

    @Test
    public void testIsMetWithOutputsMatFileNextToSubDir() throws IOException {
        FileUtil.cleanDir(subDir);

        boolean actualMet = taskCopyExpectationOutputsMatFilesExist.isMet();

        assertEquals(true, actualMet);
    }

}
