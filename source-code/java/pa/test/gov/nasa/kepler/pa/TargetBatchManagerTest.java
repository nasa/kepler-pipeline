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

package gov.nasa.kepler.pa;

import static gov.nasa.kepler.pa.TargetBatchManager.batchSize;
import static gov.nasa.kepler.pa.TargetBatchManager.timeSeriesCount;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FloatTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.tad.TargetCrud;
import gov.nasa.kepler.hibernate.tad.TargetTable;
import gov.nasa.kepler.hibernate.tad.TargetTable.TargetType;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.Pixel;
import gov.nasa.kepler.mc.cm.CelestialObjectOperations;
import gov.nasa.kepler.mc.pa.PaTarget;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.TreeSet;

import junit.framework.JUnit4TestAdapter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Before;
import org.junit.Test;

/**
 * Unit tests to exercise the {@code TargetBatchManager} API.
 * 
 * @author Forrest Girouard
 * 
 */
public class TargetBatchManagerTest extends JMockTest {

    private static final Log log = LogFactory.getLog(TargetBatchManagerTest.class);

    private static final int CCD_MODULE = 6;
    private static final int CCD_OUTPUT = 3;
    private static final int START_CADENCE = 0;
    private static final int END_CADENCE = 31;
    private static final int CADENCE_COUNT = END_CADENCE - START_CADENCE + 1;
    private static final int MAX_TARGET_PIXELS = 32;
    private static final int TARGETS_PER_TABLE = 10;

    private static final int READ_SIZE = TARGETS_PER_TABLE * MAX_TARGET_PIXELS
        * 2;
    private static final int BATCH_SIZE = READ_SIZE
        * (END_CADENCE - START_CADENCE + 1);

    // these are used by PaScienceTimeSeriesOperations
    private CelestialObjectOperations celestialObjectOperations;
    private TargetCrud targetCrud;

    private List<PaTarget> paTargets;
    private int timeSeriesCount;

    public static junit.framework.Test suite() {
        return new JUnit4TestAdapter(TargetBatchManager.class);
    }

    @Before
    public void setUp() throws Exception {
        celestialObjectOperations = mock(CelestialObjectOperations.class);
        targetCrud = mock(TargetCrud.class);
    }

    @Test
    public void singleBatchSingleRead() {

        populateObjects();

        TargetBatchManager targetBatchManager = new TargetBatchManager(
            paTargets, BATCH_SIZE, timeSeriesCount, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE);
        assertTrue("target batch manager is empty",
            targetBatchManager.hasNext());
        assertSame("target batch manager cache is not empty", 0,
            targetBatchManager.cacheSize());

        List<PaTarget> nextTargets = targetBatchManager.nextTargets();
        assertNotNull("next targets is empty", nextTargets);

        assertTrue("unexpected batch size",
            batchSize(nextTargets, CADENCE_COUNT) <= BATCH_SIZE);
        assertTrue("target batch is empty", targetBatchManager.hasNext());
        assertSame("target batch manager cache is not empty", 0,
            targetBatchManager.cacheSize());

        List<PaTarget> nextBatch = targetBatchManager.nextBatch();
        assertNotNull("next batch is null", nextBatch);
        assertEquals("next targets and next batch size mismatch",
            nextTargets.size(), nextBatch.size());
        assertEquals("next targets and next batch size mismatch",
            batchSize(nextTargets, CADENCE_COUNT),
            batchSize(nextBatch, CADENCE_COUNT));
        assertFalse("target batch manager is empty",
            targetBatchManager.hasNext());
        assertSame("target batch manager cache is not empty", 0,
            targetBatchManager.cacheSize());

        assertEquals("next targets and next batch size mismatch",
            nextTargets.size(), nextBatch.size());
    }

    @Test
    public void singleBatchMultiRead() {

        populateObjects();

        TargetBatchManager targetBatchManager = new TargetBatchManager(
            paTargets, BATCH_SIZE, timeSeriesCount / 2, CCD_MODULE, CCD_OUTPUT,
            START_CADENCE, END_CADENCE);
        assertTrue("target batch manager is empty",
            targetBatchManager.hasNext());

        List<PaTarget> nextBatch = targetBatchManager.nextBatch();
        assertTrue("unexpected batch size",
            batchSize(nextBatch, CADENCE_COUNT) <= BATCH_SIZE);
        assertFalse("target batch manager is empty",
            targetBatchManager.hasNext());
        assertSame("target batch manager cache is not empty", 0,
            targetBatchManager.cacheSize());
    }

    @Test
    public void multiBatchSingleRead() {

        populateObjects();

        TargetBatchManager targetBatchManager = new TargetBatchManager(
            paTargets, BATCH_SIZE / TARGETS_PER_TABLE, timeSeriesCount,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue("target batch manager is empty",
            targetBatchManager.hasNext());

        List<PaTarget> nextBatch = targetBatchManager.nextBatch();
        assertNotNull("next batch is null", nextBatch);
        assertTrue("target batch manager is empty",
            targetBatchManager.hasNext());

        int unprocessedTimeSeriesCount = timeSeriesCount
            - timeSeriesCount(nextBatch);
        assertEquals("time series count and cache size mismatch",
            unprocessedTimeSeriesCount, targetBatchManager.cacheSize());

        while (targetBatchManager.hasNext()) {
            assertTrue("has next is true but cache size is zero",
                targetBatchManager.cacheSize() > 0);

            List<PaTarget> lastBatch = nextBatch;
            nextBatch = targetBatchManager.nextBatch();
            for (PaTarget target : lastBatch) {
                assertNull("last batch not cleared",
                    target.getPaPixelTimeSeries());
            }
            assertNotNull("next batch is null", nextBatch);

            unprocessedTimeSeriesCount -= timeSeriesCount(nextBatch);
            assertEquals("time series count and cache size mismatch",
                unprocessedTimeSeriesCount, targetBatchManager.cacheSize());
        }
        assertSame("target batch manager cache is not empty", 0,
            targetBatchManager.cacheSize());
    }

    @Test
    public void multiBatchMultiRead() {

        populateObjects();

        int maxReadFsIds = timeSeriesCount / 2;
        TargetBatchManager targetBatchManager = new TargetBatchManager(
            paTargets, BATCH_SIZE / TARGETS_PER_TABLE, maxReadFsIds,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue("target batch manager is empty",
            targetBatchManager.hasNext());

        while (targetBatchManager.hasNext()) {
            int cacheSize = targetBatchManager.cacheSize();
            List<PaTarget> nextTargets = targetBatchManager.nextTargets();
            assertNotNull("next batch is null", nextTargets);
            for (PaTarget target : nextTargets) {
                cacheSize -= timeSeriesCount(target);
            }

            List<PaTarget> nextBatch = targetBatchManager.nextBatch();
            assertNotNull("next batch is null", nextBatch);

            if (cacheSize >= 0) {
                assertEquals("cache size mismatch", cacheSize,
                    targetBatchManager.cacheSize());
            } else if (!targetBatchManager.hasNext()) {
                assertSame("target batch manager cache is not empty", 0,
                    targetBatchManager.cacheSize());
            }
        }
        assertSame("target batch manager cache is not empty", 0,
            targetBatchManager.cacheSize());
    }

    @Test
    public void reset() {

        populateObjects();

        int maxReadFsIds = timeSeriesCount / 2;
        TargetBatchManager targetBatchManager = new TargetBatchManager(
            paTargets, BATCH_SIZE / TARGETS_PER_TABLE, maxReadFsIds,
            CCD_MODULE, CCD_OUTPUT, START_CADENCE, END_CADENCE);
        assertTrue("target batch manager is empty",
            targetBatchManager.hasNext());

        int batchCount1 = 0;
        while (targetBatchManager.hasNext()) {
            batchCount1++;
            List<PaTarget> nextBatch = targetBatchManager.nextBatch();
            assertNotNull("next batch is null", nextBatch);
        }

        targetBatchManager.reset();

        assertTrue("reset failed", targetBatchManager.hasNext());

        int batchCount2 = 0;
        while (targetBatchManager.hasNext()) {
            batchCount2++;
            List<PaTarget> nextBatch = targetBatchManager.nextBatch();
            assertNotNull("next batch is null", nextBatch);
        }
        assertEquals("full reset failed", batchCount1, batchCount2);

        targetBatchManager.reset();
        targetBatchManager.nextBatch();
        targetBatchManager.reset();

        batchCount2 = 0;
        while (targetBatchManager.hasNext()) {
            batchCount2++;
            List<PaTarget> nextBatch = targetBatchManager.nextBatch();
            assertNotNull("next batch is null", nextBatch);
        }
        assertEquals("partial reset failed", batchCount1, batchCount2);
    }

    private void populateObjects() {
        Set<Pixel> pixelsInUse = new HashSet<Pixel>();
        Set<FsId> sortedFsIds = new TreeSet<FsId>();
        TargetTable targetTable = MockUtils.mockTargetTable(this, null,
            TargetType.LONG_CADENCE, 1);
        MockUtils.mockTargets(this, targetCrud, celestialObjectOperations,
            true, targetTable, TARGETS_PER_TABLE, MAX_TARGET_PIXELS,
            CCD_MODULE, CCD_OUTPUT, pixelsInUse, sortedFsIds);
        paTargets = createPaTargets(targetTable);
        FloatTimeSeries[] testTimeSeries = createFloatTimeSeries(sortedFsIds.toArray(new FsId[sortedFsIds.size()]));
        timeSeriesCount = testTimeSeries.length;
    }

    private List<PaTarget> createPaTargets(final TargetTable targetTable) {

        PaTargetOperations targetOperations = new PaTargetOperations(
            targetTable, null, CCD_MODULE, CCD_OUTPUT,
            celestialObjectOperations);
        targetOperations.setTargetCrud(targetCrud);

        List<PaTarget> targets = targetOperations.getAllTargets();
        log.debug("total targets count: " + targets.size());

        return targets;
    }

    private FloatTimeSeries[] createFloatTimeSeries(final FsId[] fsIds) {

        FloatTimeSeries[] testTimeSeries = MockUtils.mockReadFloatTimeSeries(
            (JMockTest) null, null, START_CADENCE, END_CADENCE, 0L, fsIds,
            false);

        log.debug("write time series count: " + testTimeSeries.length);
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(testTimeSeries);
        fsClient.commitLocalFsTransaction();
        return testTimeSeries;
    }

}
