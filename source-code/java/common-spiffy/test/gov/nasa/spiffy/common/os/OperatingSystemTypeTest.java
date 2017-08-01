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

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.junit.Test;

/**
 * @author Miles Cote
 * 
 */
public class OperatingSystemTypeTest {
    private final OperatingSystemType operatingSystemType = OperatingSystemType.getInstance();

    @Test
    public void testGetName() {
        assertEquals(operatingSystemType == OperatingSystemType.LINUX ? "Linux"
            : "Darwin", operatingSystemType.getName());
    }

    @Test
    public void testGetArchDataModel() {
        assertNotNull(operatingSystemType.getArchDataModel());
    }

    @Test
    public void testGetSharedObjectPathEnvVar() {
        assertEquals(
            operatingSystemType == OperatingSystemType.LINUX ? "LD_LIBRARY_PATH"
                : "DYLD_LIBRARY_PATH",
            operatingSystemType.getSharedObjectPathEnvVar());
    }

    @Test
    public void testGetCpuInfo() throws Exception {
        assertEquals(
            operatingSystemType == OperatingSystemType.LINUX ? LinuxCpuInfo.class
                : MacOSXCpuInfo.class, operatingSystemType.getCpuInfo()
                .getClass());
    }

    @Test
    public void testGetMemInfo() throws Exception {
        assertEquals(
            operatingSystemType == OperatingSystemType.LINUX ? LinuxMemInfo.class
                : MacOSXMemInfo.class, operatingSystemType.getMemInfo()
                .getClass());
    }

    @Test
    public void testGetProcInfo() throws Exception {
        assertEquals(
            operatingSystemType == OperatingSystemType.LINUX ? LinuxProcInfo.class
                : MacOSXProcInfo.class, operatingSystemType.getProcInfo()
                .getClass());
    }

    @Test
    public void testGetProcInfoWithPid() throws Exception {
        assertEquals(
            operatingSystemType == OperatingSystemType.LINUX ? LinuxProcInfo.class
                : MacOSXProcInfo.class, operatingSystemType.getProcInfo(1)
                .getClass());
    }

    @Test
    public void testByName() {
        assertEquals(operatingSystemType,
            OperatingSystemType.byName(operatingSystemType.getName()));
    }

    @Test
    public void testByNameWithEmptyName() {
        assertEquals(OperatingSystemType.DEFAULT,
            OperatingSystemType.byName(""));
    }

    @Test(expected = IllegalArgumentException.class)
    public void testByNameWithNullName() {
        OperatingSystemType.byName(null);
    }

    @Test
    public void testGetInstance() {
        assertNotNull(OperatingSystemType.getInstance());
    }
}
