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

package gov.nasa.kepler.dr.pixels;

import static gov.nasa.kepler.common.FitsConstants.*;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.dr.dispatch.DispatcherWrapper;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;

import java.util.Arrays;
import java.util.LinkedList;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class TimeSeriesBufferTest {

    private final FsId fsId1 = new FsId("/dr/mock/ORIG:4:1");
    private final FsId fsId2 = new FsId("/dr/mock/ORIG:4:2");

    private FileStoreClient fsClient;

    @Before
    public void setUp() throws Exception {
        FileUtil.cleanDir(FilenameConstants.ACTIVEMQ_DATA);

        DefaultProperties.setPropsForUnitTest();
        TestUtils.setUpDatabase(DatabaseServiceFactory.getInstance());

        FileStoreClientFactory.getInstance()
            .rollbackLocalFsTransactionIfActive();
    }

    @After
    public void tearDown() throws Exception {
        TestUtils.tearDownDatabase(DatabaseServiceFactory.getInstance());
    }

    private void populateObjects() throws Exception {
        fsClient = FileStoreClientFactory.getInstance();

        ((FileStoreTestInterface) fsClient).cleanFileStore();

        fsClient.rollbackLocalFsTransactionIfActive();
    }

    @Test
    public void testNoGaps() throws Exception {
        populateObjects();

        fsClient.beginLocalFsTransaction();

        TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 10, false);

        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0, 42));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 1, 43));
        timeSeriesBuffer.flush();

        fsClient.commitLocalFsTransaction();

        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(0, 1,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(0, 1));

        FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
        int[] expectedIntSeries = new int[] { 42, 43, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 10;

        FsId[] fsids = { expectedFsId };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedOriginators, actualTimeSeries.originators());
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());

        fsClient.commitLocalFsTransaction();
    }

    @Test
    public void testGaps() throws Exception {
        populateObjects();

        fsClient.beginLocalFsTransaction();

        TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 10, false);

        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0, 1));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 1, 2));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 4, 3));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 5, 4));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 9, 5));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 10, 6));
        timeSeriesBuffer.flush();

        fsClient.commitLocalFsTransaction();

        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(0, 1,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(4, 5,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(9, 10,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(0, 1));
        expectedValidCadences.add(new SimpleInterval(4, 5));
        expectedValidCadences.add(new SimpleInterval(9, 10));

        int[] expectedIntSeries = new int[] { 1, 2, 0, 0, 3, 4, 0, 0, 0, 5, 6 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 10;

        FsId[] fsids = { fsId1 };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedOriginators, actualTimeSeries.originators());
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());

        fsClient.commitLocalFsTransaction();
    }

    @Test
    public void testOneCadenceGaps() throws Exception {
        populateObjects();

        fsClient.beginLocalFsTransaction();

        TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 4, false);

        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 1, 1));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 3, 3));
        timeSeriesBuffer.flush();

        fsClient.commitLocalFsTransaction();

        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(1, 1,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(3, 3,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(1, 1));
        expectedValidCadences.add(new SimpleInterval(3, 3));

        FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
        int[] expectedIntSeries = new int[] { 0, 1, 0, 3, 0 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 4;

        FsId[] fsids = { expectedFsId };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());
        assertEquals(expectedOriginators, actualTimeSeries.originators());

        fsClient.commitLocalFsTransaction();
    }

    @Test
    public void testTwoCadenceGaps() throws Exception {
        populateObjects();

        fsClient.beginLocalFsTransaction();

        TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 9, false);

        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 2, 2));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 3, 3));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 6, 6));
        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 7, 7));
        timeSeriesBuffer.flush();

        fsClient.commitLocalFsTransaction();

        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(2, 3,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(6, 7,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(2, 3));
        expectedValidCadences.add(new SimpleInterval(6, 7));

        FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
        int[] expectedIntSeries = new int[] { 0, 0, 2, 3, 0, 0, 6, 7, 0, 0 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 9;

        FsId[] fsids = { expectedFsId };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());
        assertEquals(expectedOriginators, actualTimeSeries.originators());

        fsClient.commitLocalFsTransaction();
    }

    @Test
    public void testSingleValidCadence() throws Exception {
        populateObjects();

        fsClient.beginLocalFsTransaction();

        TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 0, false);

        timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0, 1));
        timeSeriesBuffer.flush();

        fsClient.commitLocalFsTransaction();

        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(0, 0,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(0, 0));

        FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
        int[] expectedIntSeries = new int[] { 1 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 0;

        FsId[] fsids = { expectedFsId };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedOriginators, actualTimeSeries.originators());
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());

        fsClient.commitLocalFsTransaction();
    }

    // If a time series is all gaps, it won't exist in the filestore.
    @Test(expected = FileStoreIdNotFoundException.class)
    public void testSingleGapCadence() throws Exception {
        populateObjects();

        try {
            fsClient.beginLocalFsTransaction();

            TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 0,
                false);

            timeSeriesBuffer.flush();

            fsClient.commitLocalFsTransaction();

            fsClient.beginLocalFsTransaction();

            LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();

            LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();

            FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
            int[] expectedIntSeries = new int[] { 0 };
            int expectedStartCadence = 0;
            int expectedEndCadence = 0;

            FsId[] fsids = { expectedFsId };
            IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
                expectedStartCadence, expectedEndCadence);

            assertEquals(1, intTimeSeries.length);

            IntTimeSeries actualTimeSeries = intTimeSeries[0];

            assertNotNull(actualTimeSeries);

            assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
            assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
            assertTrue(Arrays.equals(expectedIntSeries,
                actualTimeSeries.iseries()));
            assertEquals(expectedOriginators, actualTimeSeries.originators());
            assertEquals(expectedValidCadences,
                actualTimeSeries.validCadences());

            fsClient.commitLocalFsTransaction();
        } finally {
            fsClient.rollbackLocalFsTransactionIfActive();
        }
    }

    @Test
    public void testOneCadenceGapValues() throws Exception {
        populateObjects();

        try {
            fsClient.beginLocalFsTransaction();

            TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 4,
                false);

            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 1, 1));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 2,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 3, 3));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 4,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.flush();

            fsClient.commitLocalFsTransaction();

            fsClient.beginLocalFsTransaction();

            LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
            expectedOriginators.add(new TaggedInterval(1, 1,
                (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
            expectedOriginators.add(new TaggedInterval(3, 3,
                (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

            LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
            expectedValidCadences.add(new SimpleInterval(1, 1));
            expectedValidCadences.add(new SimpleInterval(3, 3));

            FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
            int[] expectedIntSeries = new int[] { 0, 1, 0, 3, 0 };
            int expectedStartCadence = 0;
            int expectedEndCadence = 4;

            FsId[] fsids = { expectedFsId };
            IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
                expectedStartCadence, expectedEndCadence);

            assertEquals(1, intTimeSeries.length);

            IntTimeSeries actualTimeSeries = intTimeSeries[0];

            assertNotNull(actualTimeSeries);

            assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
            assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
            assertTrue(Arrays.equals(expectedIntSeries,
                actualTimeSeries.iseries()));
            assertEquals(expectedValidCadences,
                actualTimeSeries.validCadences());
            assertEquals(expectedOriginators, actualTimeSeries.originators());

            fsClient.commitLocalFsTransaction();
        } finally {
            fsClient.rollbackLocalFsTransactionIfActive();
        }
    }

    @Test
    public void testTwoCadenceGapValues() throws Exception {
        populateObjects();

        try {
            fsClient.beginLocalFsTransaction();

            TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 9,
                false);

            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 1,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 2, 2));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 3, 3));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 4,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 5,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 6, 6));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 7, 7));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 8,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 9,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.flush();

            fsClient.commitLocalFsTransaction();

            fsClient.beginLocalFsTransaction();

            LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
            expectedOriginators.add(new TaggedInterval(2, 3,
                (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
            expectedOriginators.add(new TaggedInterval(6, 7,
                (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

            LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
            expectedValidCadences.add(new SimpleInterval(2, 3));
            expectedValidCadences.add(new SimpleInterval(6, 7));

            FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
            int[] expectedIntSeries = new int[] { 0, 0, 2, 3, 0, 0, 6, 7, 0, 0 };
            int expectedStartCadence = 0;
            int expectedEndCadence = 9;

            FsId[] fsids = { expectedFsId };
            IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
                expectedStartCadence, expectedEndCadence);

            assertEquals(1, intTimeSeries.length);

            IntTimeSeries actualTimeSeries = intTimeSeries[0];

            assertNotNull(actualTimeSeries);

            assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
            assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
            assertTrue(Arrays.equals(expectedIntSeries,
                actualTimeSeries.iseries()));
            assertEquals(expectedValidCadences,
                actualTimeSeries.validCadences());
            assertEquals(expectedOriginators, actualTimeSeries.originators());

            fsClient.commitLocalFsTransaction();
        } finally {
            fsClient.rollbackLocalFsTransactionIfActive();
        }
    }

    @Test
    public void testSingleGapValue() throws Exception {
        populateObjects();

        try {
            fsClient.beginLocalFsTransaction();

            TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 0,
                false);

            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.flush();

            fsClient.commitLocalFsTransaction();

            fsClient.beginLocalFsTransaction();

            LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();

            LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();

            FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
            int[] expectedIntSeries = new int[] { 0 };
            int expectedStartCadence = 0;
            int expectedEndCadence = 0;

            FsId[] fsids = { expectedFsId };
            IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
                expectedStartCadence, expectedEndCadence);

            assertEquals(1, intTimeSeries.length);

            IntTimeSeries actualTimeSeries = intTimeSeries[0];

            assertNotNull(actualTimeSeries);

            assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
            assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
            assertTrue(Arrays.equals(expectedIntSeries,
                actualTimeSeries.iseries()));
            assertEquals(expectedOriginators, actualTimeSeries.originators());
            assertEquals(expectedValidCadences,
                actualTimeSeries.validCadences());

            fsClient.commitLocalFsTransaction();
        } finally {
            fsClient.rollbackLocalFsTransactionIfActive();
        }
    }

    @Test
    public void testTwoCadenceGapValuesAlternating() throws Exception {
        populateObjects();

        try {
            fsClient.beginLocalFsTransaction();

            TimeSeriesBuffer timeSeriesBuffer = new TimeSeriesBuffer(0, 9,
                false);

            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 0,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 0, 0));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 1,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 1, 1));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 2, 2));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 2,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 3, 3));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 3,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 4,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 4, 4));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 5,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 5, 5));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 6, 6));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 6,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 7, 7));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 7,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 8,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 8, 8));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId1, 9,
                MISSING_PIXEL_VALUE));
            timeSeriesBuffer.addValue(new TimeSeriesEntry(fsId2, 9, 9));

            timeSeriesBuffer.flush();

            fsClient.commitLocalFsTransaction();

            testTwoCadenceGapValuesAlternatingPixel1(timeSeriesBuffer);

            testTwoCadenceGapValuesAlternatingPixel2(timeSeriesBuffer);
        } finally {
            fsClient.rollbackLocalFsTransactionIfActive();
        }
    }

    private void testTwoCadenceGapValuesAlternatingPixel1(
        TimeSeriesBuffer timeSeriesBuffer) {
        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(2, 3,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(6, 7,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(2, 3));
        expectedValidCadences.add(new SimpleInterval(6, 7));

        FsId expectedFsId = new FsId("/dr/mock/ORIG:4:1");
        int[] expectedIntSeries = new int[] { 0, 0, 2, 3, 0, 0, 6, 7, 0, 0 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 9;

        FsId[] fsids = { expectedFsId };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());
        assertEquals(expectedOriginators, actualTimeSeries.originators());

        fsClient.commitLocalFsTransaction();
    }

    private void testTwoCadenceGapValuesAlternatingPixel2(
        TimeSeriesBuffer timeSeriesBuffer) {
        fsClient.beginLocalFsTransaction();

        LinkedList<TaggedInterval> expectedOriginators = new LinkedList<TaggedInterval>();
        expectedOriginators.add(new TaggedInterval(0, 1,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(4, 5,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));
        expectedOriginators.add(new TaggedInterval(8, 9,
            (int) DispatcherWrapper.DATA_RECEIPT_ORIGIN_ID));

        LinkedList<SimpleInterval> expectedValidCadences = new LinkedList<SimpleInterval>();
        expectedValidCadences.add(new SimpleInterval(0, 1));
        expectedValidCadences.add(new SimpleInterval(4, 5));
        expectedValidCadences.add(new SimpleInterval(8, 9));

        FsId expectedFsId = new FsId("/dr/mock/ORIG:4:2");
        int[] expectedIntSeries = new int[] { 0, 1, 0, 0, 4, 5, 0, 0, 8, 9 };
        int expectedStartCadence = 0;
        int expectedEndCadence = 9;

        FsId[] fsids = { expectedFsId };
        IntTimeSeries[] intTimeSeries = fsClient.readTimeSeriesAsInt(fsids,
            expectedStartCadence, expectedEndCadence);

        assertEquals(1, intTimeSeries.length);

        IntTimeSeries actualTimeSeries = intTimeSeries[0];

        assertNotNull(actualTimeSeries);

        assertEquals(expectedStartCadence, actualTimeSeries.startCadence());
        assertEquals(expectedEndCadence, actualTimeSeries.endCadence());
        assertTrue(Arrays.equals(expectedIntSeries, actualTimeSeries.iseries()));
        assertEquals(expectedValidCadences, actualTimeSeries.validCadences());
        assertEquals(expectedOriginators, actualTimeSeries.originators());

        fsClient.commitLocalFsTransaction();
    }

}
