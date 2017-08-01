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

package gov.nasa.kepler.mc.blob;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.intervals.BlobSeries;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.mc.MockUtils;
import gov.nasa.kepler.mc.dr.DataAnomalyOperations;
import gov.nasa.kepler.mc.dr.MjdToCadence;
import gov.nasa.kepler.mc.dr.MjdToCadence.TimestampSeries;
import gov.nasa.spiffy.common.jmock.JMockTest;

import java.util.Arrays;

import junit.framework.JUnit4TestAdapter;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;

public class BlobOperationsTest extends JMockTest {

    private static final int SC_PER_LC = 30;
    private static final int LONG_CADENCES = 4;
    private static final int START_LC = 1439;
    private static final int END_LC = START_LC + LONG_CADENCES - 1;
    private static final int SHORT_CADENCES = LONG_CADENCES * SC_PER_LC;
    private static final int START_SC = START_LC * SC_PER_LC;
    private static final int END_SC = START_SC + LONG_CADENCES * SC_PER_LC - 1;

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(BlobOperationsTest.class);

    private LogCrud logCrud = mock(LogCrud.class);
    private DataAnomalyOperations dataAnomalyOperations = mock(DataAnomalyOperations.class);

    public static junit.framework.Test suite() {
        return new JUnit4TestAdapter(BlobOperationsTest.class);
    }

    @Test
    public void convertSimpleBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC, END_LC);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 1);

        BlobSeries<String> scBlobSeries = BlobOperations.longToShortCadenceBlobSeries(
            scTimes, lcTimes, lcBlobSeries, START_SC);
        assertNotNull(scBlobSeries);
        assertEquals(SHORT_CADENCES, scBlobSeries.gapIndicators().length);
        assertEquals(SHORT_CADENCES, scBlobSeries.blobIndices().length);
        assertTrue(Arrays.equals(lcBlobSeries.blobFilenames(),
            scBlobSeries.blobFilenames()));
        assertTrue(Arrays.equals(lcBlobSeries.blobOriginators(),
            scBlobSeries.blobOriginators()));
        boolean[] gaps = new boolean[SHORT_CADENCES];
        assertTrue(Arrays.equals(gaps, scBlobSeries.gapIndicators()));
    }

    @Test(expected = IllegalArgumentException.class)
    public void convertLcTimesMismatchBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC, END_LC);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(
            LONG_CADENCES + 1, 1);

        BlobOperations.longToShortCadenceBlobSeries(scTimes, lcTimes,
            lcBlobSeries, START_SC);
    }

    @Test(expected = IllegalArgumentException.class)
    public void convertScAfterLcBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG, 0,
            LONG_CADENCES);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 1);

        BlobOperations.longToShortCadenceBlobSeries(scTimes, lcTimes,
            lcBlobSeries, START_SC);
    }

    @Test(expected = IllegalArgumentException.class)
    public void convertScBeforeLcBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC, END_LC);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT, 0,
            SHORT_CADENCES);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 1);

        BlobOperations.longToShortCadenceBlobSeries(scTimes, lcTimes,
            lcBlobSeries, START_SC);
    }

    @Test
    public void convertScOverlapLcBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC + 1, END_LC + 1);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 1);

        BlobSeries<String> scBlobSeries = BlobOperations.longToShortCadenceBlobSeries(
            scTimes, lcTimes, lcBlobSeries, START_SC);
        assertEquals(SHORT_CADENCES, scBlobSeries.gapIndicators().length);
        assertEquals(SHORT_CADENCES, scBlobSeries.blobIndices().length);
        assertTrue(Arrays.equals(lcBlobSeries.blobFilenames(),
            scBlobSeries.blobFilenames()));
        assertTrue(Arrays.equals(lcBlobSeries.blobOriginators(),
            scBlobSeries.blobOriginators()));

        boolean[] gaps = new boolean[SHORT_CADENCES];
        for (int i = 0; i < SC_PER_LC; i++) {
            gaps[i] = true;
        }
        assertTrue(Arrays.equals(gaps, scBlobSeries.gapIndicators()));
    }

    @Test
    public void convertBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC, END_LC);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 2);

        BlobSeries<String> scBlobSeries = BlobOperations.longToShortCadenceBlobSeries(
            scTimes, lcTimes, lcBlobSeries, START_SC);
        assertEquals(SHORT_CADENCES, scBlobSeries.gapIndicators().length);
        assertEquals(SHORT_CADENCES, scBlobSeries.blobIndices().length);
        assertTrue(Arrays.equals(lcBlobSeries.blobFilenames(),
            scBlobSeries.blobFilenames()));
        assertTrue(Arrays.equals(lcBlobSeries.blobOriginators(),
            scBlobSeries.blobOriginators()));
        boolean[] gaps = new boolean[SHORT_CADENCES];
        assertTrue(Arrays.equals(gaps, scBlobSeries.gapIndicators()));

        int[] indices = new int[SHORT_CADENCES / 2];
        assertTrue(Arrays.equals(indices, ArrayUtils.subarray(
            scBlobSeries.blobIndices(), 0, SHORT_CADENCES / 2)));
        Arrays.fill(indices, 1);
        assertTrue(Arrays.equals(indices, ArrayUtils.subarray(
            scBlobSeries.blobIndices(), SHORT_CADENCES / 2, SHORT_CADENCES)));
    }

    @Test
    public void convertScContainsLcBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC + 1, END_LC - 1);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(
            LONG_CADENCES - 2, 2);

        BlobSeries<String> scBlobSeries = BlobOperations.longToShortCadenceBlobSeries(
            scTimes, lcTimes, lcBlobSeries, START_SC);
        assertEquals(SHORT_CADENCES, scBlobSeries.gapIndicators().length);
        assertEquals(SHORT_CADENCES, scBlobSeries.blobIndices().length);
        assertTrue(Arrays.equals(lcBlobSeries.blobFilenames(),
            scBlobSeries.blobFilenames()));
        assertTrue(Arrays.equals(lcBlobSeries.blobOriginators(),
            scBlobSeries.blobOriginators()));

        int[] indices = new int[(SHORT_CADENCES - 2 * SC_PER_LC) / 2];
        assertTrue(Arrays.equals(indices, ArrayUtils.subarray(
            scBlobSeries.blobIndices(), SC_PER_LC, SHORT_CADENCES / 2)));
        Arrays.fill(indices, 1);
        assertTrue(Arrays.equals(indices, ArrayUtils.subarray(
            scBlobSeries.blobIndices(), SHORT_CADENCES / 2, SHORT_CADENCES
                - SC_PER_LC)));

        boolean[] gaps = new boolean[SC_PER_LC];
        Arrays.fill(gaps, true);
        assertTrue(Arrays.equals(gaps,
            ArrayUtils.subarray(scBlobSeries.gapIndicators(), 0, SC_PER_LC)));
        assertTrue(Arrays.equals(
            gaps,
            ArrayUtils.subarray(scBlobSeries.gapIndicators(), SHORT_CADENCES
                - SC_PER_LC, SHORT_CADENCES)));
        gaps = new boolean[SHORT_CADENCES - 2 * SC_PER_LC];
        assertTrue(Arrays.equals(gaps,
            ArrayUtils.subarray(scBlobSeries.gapIndicators(), SC_PER_LC,
                SHORT_CADENCES - SC_PER_LC)));
    }

    @Test
    public void convertLcContainsScBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC, END_LC);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC + SC_PER_LC, END_SC - SC_PER_LC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 2);

        int shortCadences = SHORT_CADENCES - 2 * SC_PER_LC;
        BlobSeries<String> scBlobSeries = BlobOperations.longToShortCadenceBlobSeries(
            scTimes, lcTimes, lcBlobSeries, START_SC);
        assertEquals(shortCadences, scBlobSeries.gapIndicators().length);
        assertEquals(shortCadences, scBlobSeries.blobIndices().length);
        assertTrue(Arrays.equals(lcBlobSeries.blobFilenames(),
            scBlobSeries.blobFilenames()));
        assertTrue(Arrays.equals(lcBlobSeries.blobOriginators(),
            scBlobSeries.blobOriginators()));

        int[] indices = new int[shortCadences / 2];
        assertTrue(Arrays.equals(indices, ArrayUtils.subarray(
            scBlobSeries.blobIndices(), 0, shortCadences / 2)));
        Arrays.fill(indices, 1);
        assertTrue(Arrays.equals(indices, ArrayUtils.subarray(
            scBlobSeries.blobIndices(), shortCadences / 2, shortCadences)));

        boolean[] gaps = new boolean[shortCadences];
        assertTrue(Arrays.equals(gaps, scBlobSeries.gapIndicators()));
    }

    @Test
    public void convertGappedBlobSeries() {

        TimestampSeries lcTimes = createCadenceTimes(CadenceType.LONG,
            START_LC, END_LC);
        TimestampSeries scTimes = createCadenceTimes(CadenceType.SHORT,
            START_SC, END_SC);
        BlobSeries<String> lcBlobSeries = createBlobFileSeries(LONG_CADENCES, 2);

        lcTimes.gapIndicators[1] = true;
        scTimes.gapIndicators[0] = true;
        scTimes.gapIndicators[SC_PER_LC / 2] = true;
        scTimes.gapIndicators[SHORT_CADENCES - 1] = true;
        lcBlobSeries.gapIndicators()[2] = true;

        BlobSeries<String> scBlobSeries = BlobOperations.longToShortCadenceBlobSeries(
            scTimes, lcTimes, lcBlobSeries, START_SC);
        assertEquals(SHORT_CADENCES, scBlobSeries.gapIndicators().length);
        assertEquals(SHORT_CADENCES, scBlobSeries.blobIndices().length);
        assertTrue(Arrays.equals(lcBlobSeries.blobFilenames(),
            scBlobSeries.blobFilenames()));
        assertTrue(Arrays.equals(lcBlobSeries.blobOriginators(),
            scBlobSeries.blobOriginators()));

        int[] indices = new int[SHORT_CADENCES];
        boolean[] gaps = new boolean[SHORT_CADENCES];
        for (int i = 0; i < gaps.length; i++) {
            if (i == SC_PER_LC / 2 || i == 0 || i == SHORT_CADENCES - 1) {
                gaps[i] = true;
            } else if (i >= SC_PER_LC && i < 3 * SC_PER_LC) {
                gaps[i] = true;
            } else if (i >= SHORT_CADENCES / 2) {
                indices[i] = 1;
            }
        }
        assertTrue(Arrays.equals(indices, scBlobSeries.blobIndices()));
        assertTrue(Arrays.equals(gaps, scBlobSeries.gapIndicators()));
    }

    private TimestampSeries createCadenceTimes(CadenceType cadenceType,
        int startCadence, int endCadence) {

        MockUtils.mockPixelLogs(this, logCrud, cadenceType, startCadence,
            endCadence);
        MockUtils.mockDataAnomalies(this, dataAnomalyOperations, cadenceType,
            startCadence, endCadence);
        MockUtils.mockDataAnomalyFlags(this, dataAnomalyOperations,
            cadenceType, startCadence, endCadence);
        return new MjdToCadence(logCrud, dataAnomalyOperations, cadenceType).cadenceTimes(
            startCadence, endCadence);
    }

    private BlobSeries<String> createBlobFileSeries(int cadences, int files) {

        boolean[] blobGaps = new boolean[cadences];
        int[] blobIndices = new int[cadences];
        for (int i = 0; i < cadences; i++) {
            blobIndices[i] = i * files / cadences;
        }
        String[] blobFilenames = new String[files];
        long[] blobOriginators = new long[files];
        for (int i = 0; i < files; i++) {
            blobFilenames[i] = "blob" + i + ".mat";
            blobOriginators[i] = i;
        }
        return new BlobSeries<String>(blobIndices, blobGaps, blobFilenames,
            blobOriginators, START_SC, END_SC);
    }
}
