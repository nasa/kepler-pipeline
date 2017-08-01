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

package gov.nasa.kepler.fs.storage;


import static gov.nasa.kepler.fs.storage.LaneAddressSpace.LANE_BLOCK_SIZE;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWrite;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.RandomAccessFile;
import java.util.Arrays;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class ContainerFileTest {

    private File testRoot;

    @Before
    public void setUp() throws Exception {
        testRoot = new File(Filenames.BUILD_TEST
            + "/ContainerFileTest.test");
        testRoot.mkdirs();
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }

    @Test
    public void testLaneAddressSpace() throws Exception {
        final int headerSize = 55;
        LaneAddressSpace laneASpace0 = new LaneAddressSpace(
            0, headerSize, 2, null, -1);
        LaneAddressSpace laneASpace1 = new LaneAddressSpace(
            1, headerSize, 2, null, -1);

        assertTrue(laneASpace0.isUsed(headerSize - 1));
        assertFalse(laneASpace0.isUsed(headerSize));
        assertTrue(laneASpace1.isUsed(1000));
        assertEquals((long) headerSize, laneASpace0.nextUnusedAddress(0));
        assertEquals((long) headerSize + LANE_BLOCK_SIZE,
            laneASpace1.nextUnusedAddress(0));

        assertEquals((long) headerSize + LANE_BLOCK_SIZE * 2 - 1,
            laneASpace1.nextUnusedAddress(headerSize + LANE_BLOCK_SIZE));

        assertTrue(laneASpace1.isUsed(1000));
        assertEquals((long) headerSize, laneASpace0.xlateAddress(0));
        assertEquals((long) headerSize + LANE_BLOCK_SIZE,
            laneASpace1.xlateAddress(0));
    }

    @Test
    public void testLastAddress() throws Exception {
        final int fileNo = 0;
        File testFile = new File(testRoot, DirectoryHash.toFileName(Integer.toString(fileNo)));

        LaneAddressSpace laneSpace0 = new LaneAddressSpace(
            0, 0, 2, testRoot, fileNo);
        LaneAddressSpace laneSpace1 = new LaneAddressSpace(
            1, 0, 2, testRoot, fileNo);
        RandomAccessFile raf = new RandomAccessFile(testFile, "rw");
        NonContiguousReadWrite rwLane0 = new NonContiguousReadWrite(raf, laneSpace0);

        byte[] data = new byte[1];
        rwLane0.write(data);
        assertEquals(1L, laneSpace0.lastVirtualAddress());

        NonContiguousReadWrite rwLane1 = new NonContiguousReadWrite(raf, laneSpace1);
        rwLane1.write(data);
        assertEquals((long) LANE_BLOCK_SIZE,
            laneSpace0.lastVirtualAddress());
        assertEquals(1L, laneSpace1.lastVirtualAddress());

        data = new byte[LANE_BLOCK_SIZE];
        rwLane1.seek(0);
        rwLane1.write(data, 0, data.length);
        assertEquals((long) LANE_BLOCK_SIZE,
            laneSpace0.lastVirtualAddress());
        assertEquals((long) LANE_BLOCK_SIZE,
            laneSpace1.lastVirtualAddress());
    }

    @Test
    public void testLaneAddressSpaceReadWrite() throws Exception {
        final int fileNo = 255;
        final int headerSize = 55;
        final byte headerFill = 66;
        byte[] headerData = new byte[headerSize];
        Arrays.fill(headerData, headerFill);

        File testFile = new File(testRoot, DirectoryHash.toFileName(Integer.toString(fileNo)));
        LaneAddressSpace laneASpace0 = new LaneAddressSpace(
            0, headerSize, 2, testRoot, fileNo);
        LaneAddressSpace laneASpace1 = new LaneAddressSpace(
            1, headerSize, 2, testRoot, fileNo);

        RandomAccessFile raf = new RandomAccessFile(testFile, "rw");
        raf.write(headerData);
        NonContiguousReadWrite rwLane0 = new NonContiguousReadWrite(raf, laneASpace0);

        byte[] data0 = new byte[1024 * 1024];
        Arrays.fill(data0, (byte) 0x61);
        rwLane0.write(data0);

        byte[] data1 = new byte[data0.length];
        Arrays.fill(data1, (byte) 0x62);
        
        NonContiguousReadWrite rwLane1 = new NonContiguousReadWrite(raf, laneASpace1);
        rwLane1.write(data1);
        assertEquals((long) data0.length, laneASpace0.lastVirtualAddress());
        assertEquals((long) data1.length, laneASpace1.lastVirtualAddress());
        raf.close();

        RandomAccessFile readFile = new RandomAccessFile(testFile, "r");
        byte[] allData = new byte[data0.length * 2 + headerSize];
        readFile.readFully(allData);
        assertTrue(ArrayUtils.arrayEquals(headerData, 0, allData, 0,
            headerData.length));
        for (int ai = headerSize, di = 0; ai < allData.length; di += LANE_BLOCK_SIZE, ai += LANE_BLOCK_SIZE * 2) {
            assertTrue(ArrayUtils.arrayEquals(allData, ai, data0, di,
                LANE_BLOCK_SIZE));
        }
    }

}
