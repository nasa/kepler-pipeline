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

package gov.nasa.kepler.common.os;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.os.ProcInfo;
import gov.nasa.spiffy.common.os.ProcessUtils;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Test the {@link ProcessUtils} class, especially the {@code killPid} method.
 * 
 * @author Forrest Girouard
 */
public class ProcessUtilsTest {

    private static final Log log = LogFactory.getLog(ProcessUtilsTest.class);

    @Test
    public void testKill() throws Exception {

        if (ProcessUtils.isKillEnabled()) {
            int pid = startTestProcess();
            int rc = ProcessUtils.killPid(pid);
            log.info("rc=" + rc);
            assertEquals("rc != 0", 0, rc);
        } else {
            log.error("failed to load native library");
            fail("failed to load native library");
        }
    }
    
    @Test
    public void testGet() throws Exception {
        if (ProcessUtils.isKillEnabled()) {
            int pid = ProcessUtils.getPidNative();
            assertTrue(pid > 0); // 0 is init on UNIX
            assertTrue(pid <= OperatingSystemType.getInstance()
                .getProcInfo()
                .getMaximumPid());

            int altPid = gov.nasa.spiffy.common.os.ProcessUtils.getPid();
            assertEquals(altPid, pid);
        } else {
            log.error("failed to load native library");
            fail("failed to load native library");
        }
    }

    private int startTestProcess() throws Exception {

        String[] command = new String[] { "sleep", "10" };
        Runtime.getRuntime()
            .exec(command);

        ProcInfo procInfo = OperatingSystemType.getInstance()
            .getProcInfo();
        List<Integer> pids = procInfo.getChildPids("sleep");

        assertTrue("sleep process not found", pids.size() == 1);
        
        return pids.get(0);
    }
}
