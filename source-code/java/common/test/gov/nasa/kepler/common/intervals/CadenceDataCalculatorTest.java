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

package gov.nasa.kepler.common.intervals;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Forrest Girouard
 */
public class CadenceDataCalculatorTest {

    private final SimpleCadenceDataFactory dataFactory = new SimpleCadenceDataFactory();

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void singleCadenceDataTest() throws IOException {
        singleCadenceDataTest(dataFactory);
    }

    /**
     * Data passed in represent a super interval of the desired time interval.
     * This test should produce a data series which starts with gaps and ends
     * with real data from two different data.
     */
    @Test
    public void clipResultsDataTest() throws IOException {
        clipResultsDataTest(dataFactory);
    }

    /**
     * Overwrite an interval in the middle.
     */
    @Test
    public void dataInTheMiddle() throws IOException {
        dataInTheMiddle(dataFactory);
    }

    /**
     * There is an interval that completely overlaps.
     */
    @Test
    public void checkDeletedData() {
        checkDeletedData(dataFactory);
    }

    private <E> void singleCadenceDataTest(CadenceDataFactory<E> dataFactory)
        throws IOException {
        SimpleCadenceData single = new SimpleCadenceData(1, 2, 3, 4, 101);
        List<CadenceData> dataList = new ArrayList<CadenceData>();
        dataList.add(single);
        CadenceDataCalculator<E> bcalc = new CadenceDataCalculator<E>(dataList);
        DataSeries<E> dataSeries = bcalc.dataSeries(dataFactory);

            assertEquals(1, dataSeries.data().length);

            byte[] bytes = new byte[1024];
            Arrays.fill(bytes, (byte) 4);
            byte[] data = null;
            if (dataSeries.data()[0] instanceof byte[]) {
                data = (byte[]) dataSeries.data()[0];
            }
            assertTrue(Arrays.equals(bytes, data));

            int[] indices = new int[2];
            Arrays.fill(indices, 0);
            assertTrue(Arrays.equals(indices, dataSeries.dataIndices()));
            boolean[] gaps = new boolean[2];
            Arrays.fill(gaps, false);
            assertTrue(Arrays.equals(gaps, dataSeries.gapIndicators()));
    }

    private <E> void clipResultsDataTest(CadenceDataFactory<E> dataFactory)
        throws IOException {
        SimpleCadenceData b1 = new SimpleCadenceData(1, 100, 1000, 4, 101);
        SimpleCadenceData b2 = new SimpleCadenceData(2, 500, 2000, 5, 102);
        List<CadenceData> data = new ArrayList<CadenceData>();
        data.add(b2);
        data.add(b1);

        CadenceDataCalculator<E> bcalc = new CadenceDataCalculator<E>(data);
        DataSeries<E> dataSeries = bcalc.dataSeriesForCadenceInterval(
            dataFactory, 0, 1500);

            assertEquals(2, dataSeries.data().length);
            byte[] byteData4 = new byte[1024];
            Arrays.fill(byteData4, (byte) 4);
            byte[] data4 = null;
            byte[] byteData5 = new byte[1024];
            Arrays.fill(byteData5, (byte) 5);
            byte[] data5 = null;

            if (dataSeries.data()[0] instanceof byte[]) {
                data4 = (byte[]) dataSeries.data()[0];
                data5 = (byte[]) dataSeries.data()[1];
            }
            assertTrue(Arrays.equals(byteData4, data4));
            assertTrue(Arrays.equals(byteData5, data5));

            boolean[] gaps = new boolean[1501];
            Arrays.fill(gaps, 0, 100, true);
            assertTrue(Arrays.equals(gaps, dataSeries.gapIndicators()));

            int[] indices = new int[gaps.length];
            Arrays.fill(indices, 500, indices.length, 1);
            assertTrue(Arrays.equals(indices, dataSeries.dataIndices()));
    }

    private <T> void dataInTheMiddle(CadenceDataFactory<T> dataFactory)
        throws IOException {
        SimpleCadenceData b1 = new SimpleCadenceData(1, 1000, 2000, 1, 101);
        SimpleCadenceData b2 = new SimpleCadenceData(2, 1500, 1600, 2, 102);
        List<CadenceData> data = new ArrayList<CadenceData>();
        data.add(b2);
        data.add(b1);

        CadenceDataCalculator<T> bcalc = new CadenceDataCalculator<T>(data);
        DataSeries<T> dataSeries = bcalc.dataSeries(dataFactory);

            assertEquals(2, dataSeries.data().length);

            byte[] bytes1 = new byte[1024];
            Arrays.fill(bytes1, (byte) 1);
            byte[] data1 = null;
            byte[] bytes2 = new byte[1024];
            Arrays.fill(bytes2, (byte) 2);
            byte[] data2 = null;

            if (dataSeries.data()[0] instanceof byte[]) {
                data1 = (byte[]) dataSeries.data()[0];
                data2 = (byte[]) dataSeries.data()[1];
            }
            assertTrue(Arrays.equals(bytes1, data1));
            assertTrue(Arrays.equals(bytes2, data2));

            boolean[] gaps = new boolean[1001];
            assertTrue(Arrays.equals(gaps, dataSeries.gapIndicators()));

            int[] indices = new int[gaps.length];
            Arrays.fill(indices, 0, 500, 0);
            Arrays.fill(indices, 500, 601, 1);
            Arrays.fill(indices, 601, indices.length, 0);
            assertTrue(Arrays.equals(indices, dataSeries.dataIndices()));
    }

    private <T> void checkDeletedData(CadenceDataFactory<T> dataFactory) {
        SimpleCadenceData b1 = new SimpleCadenceData(1, 1000, 2000, 1, 101);
        SimpleCadenceData b2 = new SimpleCadenceData(2, 500, 600, 2, 102);
        SimpleCadenceData b3 = new SimpleCadenceData(3, 400, 3000, -1, 103);
        List<SimpleCadenceData> data = new ArrayList<SimpleCadenceData>();
        data.add(b2);
        data.add(b1);
        data.add(b3);

        CadenceDataCalculator<T> bcalc = new CadenceDataCalculator<T>(data);
        DataSeries<T> dataSeries = bcalc.dataSeries(dataFactory);
        List<CadenceData> deletedData = bcalc.deletedData();
        assertEquals(1, dataSeries.data().length);
        assertEquals(2, deletedData.size());

        assertEquals(b1.getId(), deletedData.get(0)
            .getId());
        assertEquals(b2.getId(), deletedData.get(1)
            .getId());
    }

    /**
     * 
     * @author Forrest Girouard
     */
    private static final class SimpleCadenceData implements CadenceData {
        private final long creationTime;
        private final int startCadence;
        private final int endCadence;
        private final long id;
        private final long originator;

        public SimpleCadenceData(long creationTime, int startCadence,
            int endCadence, long id, long originator) {
            this.creationTime = creationTime;
            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.id = id;
            this.originator = originator;
        }

        @Override
        public long getCreationTime() {
            return creationTime;
        }

        @Override
        public int getEndCadence() {
            return endCadence;
        }

        @Override
        public long getId() {
            return id;
        }

        @Override
        public int getStartCadence() {
            return startCadence;
        }

        public long getOriginator() {
            return originator;
        }

    }

    private static final class SimpleCadenceDataFactory implements
        CadenceDataFactory<byte[]> {

        public SimpleCadenceDataFactory() {
        }

        @Override
        public long originatorForCadenceData(CadenceData cadenceData) {
            return ((SimpleCadenceData) cadenceData).getOriginator();
        }

        @Override
        public byte[] dataForCadenceData(CadenceData cadenceData) {
            byte[] data = new byte[1024];
            Arrays.fill(data, (byte) cadenceData.getId());
            return data;
        }
        
        @Override
        public byte[] duplicateCadenceData(CadenceData cadenceData) {
            byte[] originalData = dataForCadenceData(cadenceData);
            byte[] duplicateData = new byte[originalData.length];
            System.arraycopy(originalData, 0, duplicateData, 0, originalData.length);
            return duplicateData;
        }
    }
}
