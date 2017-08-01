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

package gov.nasa.kepler.common.concurrent;

import static org.junit.Assert.assertEquals;
import gov.nasa.spiffy.common.concurrent.ServerLock;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.os.ProcessUtils;

import java.io.File;
import java.util.Collections;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class ServerLockTest {

    private File testDir = new File(Filenames.BUILD_TEST
        + "/ServerLockTest");

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testDir.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testDir);
    }

    @Test
    public void testServerLock() throws Exception {
        File lockFile = new File(testDir, "lock");
        ServerLock serverLock = new ServerLock(lockFile);
        serverLock.tryLock("testServerLock");

        Process process = ProcessUtils.runJava(ServerLockTest.class,
            Collections.singletonList(lockFile.getAbsolutePath()));

        int exitCode = process.waitFor();
        FileUtil.close(process.getErrorStream());
        FileUtil.close(process.getOutputStream());
        FileUtil.close(process.getInputStream());

        serverLock.releaseLock();

        process = ProcessUtils.runJava(ServerLockTest.class,
            Collections.singletonList(lockFile.getAbsolutePath()));

        exitCode = process.waitFor();
        FileUtil.close(process.getErrorStream());
        FileUtil.close(process.getOutputStream());
        FileUtil.close(process.getInputStream());

        assertEquals(LOCK_ACQUIRED, exitCode);

    }

    private final static int LOCK_ACQUIRED = 0;
    private final static int LOCK_NOT_ACQUIRED = 7;
    private final static int LOCK_ERROR = 8;

    /**
     * @param args
     */
    public static void main(String[] argv) {
        File lockFile = new File(argv[0]);
        ServerLock serverLock = new ServerLock(lockFile);

        try {
            serverLock.tryLock("main");
            System.exit(LOCK_ACQUIRED);
            serverLock.releaseLock();
        } catch (IllegalStateException fsx) {
            System.exit(LOCK_NOT_ACQUIRED);
        } catch (Throwable t) {
            System.exit(LOCK_ERROR);
        }
    }

}
