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

package gov.nasa.spiffy.common.os;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;

import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.os.ProcInfo;

import java.util.List;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

/**
 * Tests the OS-specific implementation of the {@link ProcInfo} class.
 * 
 * @author Forrest Girouard
 */
public class ProcInfoTest {

    private static final Log log = LogFactory.getLog(ProcInfoTest.class);

    @Test
    public void testChildPids() throws Exception {

        List<Integer> childPids = OperatingSystemType.getInstance()
            .getProcInfo(1)
            .getChildPids();

        assertNotNull("childPids null", childPids);

        log.info("found " + childPids.size() + " children");

        assertTrue("At least one child", childPids.size() > 0);
    }

    @Test
    public void testChildPidsNoSuchName() throws Exception {

        List<Integer> childPids = OperatingSystemType.getInstance()
            .getProcInfo(1)
            .getChildPids("NoSuchName");

        assertNotNull("childPids null", childPids);

        log.info("found " + childPids.size() + " children");

        assertTrue("No children", childPids.size() == 0);
    }

    @Test
    public void testChildPidsByName() throws Exception {

        List<Integer> childPids = OperatingSystemType.getInstance()
            .getProcInfo(1)
            .getChildPids("ntpd");

        assertNotNull("childPids null", childPids);

        log.info("found " + childPids.size() + " children");

        assertTrue("At least one child", childPids.size() > 0);
    }

    @Test
    public void testParentPid() throws Exception {

        int parentPid = OperatingSystemType.getInstance()
            .getProcInfo(1)
            .getParentPid();

        log.info(String.format("found parent pid of %d for pid %d", parentPid,
            1));

        assertTrue("unexpected parent pid", parentPid == 0);
    }

    @Test
    public void testPPid() throws Exception {
        ProcInfo procInfo = OperatingSystemType.getInstance()
            .getProcInfo(gov.nasa.spiffy.common.os.ProcessUtils.getPid());

        log.info(String.format("found parent pid of %d for pid %d",
            procInfo.getParentPid(), procInfo.getPid()));

        assertTrue("unexpected parent pid",
            procInfo.getPid() != procInfo.getParentPid());
    }

    @Test
    public void testOpenFileLimit() throws Exception {

        int limit = OperatingSystemType.getInstance()
            .getProcInfo()
            .getOpenFileLimit();

        log.info("max open file limit is " + limit);

        assertTrue("max open files", limit > 0);
    }

    @Test
    public void testMaximumPid() throws Exception {
        int maxPid = OperatingSystemType.getInstance()
            .getProcInfo()
            .getMaximumPid();

        log.info("maximum pid value is " + maxPid);

        assertTrue("maximum pid vale", maxPid > 0);
    }
}
