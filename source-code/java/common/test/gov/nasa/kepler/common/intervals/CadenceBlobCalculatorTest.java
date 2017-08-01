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
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Forrest Girouard
 * @author Sean McCauliff
 * 
 */
public class CadenceBlobCalculatorTest {

    private final SimpleCadenceBlobDataFactory blobDataFactory = new SimpleCadenceBlobDataFactory();
    private final SimpleCadenceBlobFileFactory blobFileFactory = new SimpleCadenceBlobFileFactory();

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
    public void singleCadenceBlobTest() throws IOException {
        singleCadenceBlobTest(blobDataFactory);
        singleCadenceBlobTest(blobFileFactory);
    }

    /**
     * Blobs passed in represent a super interval of the desired time interval.
     * This test should produce a blob series which starts with gaps and ends
     * with real data from two different blobs.
     */
    @Test
    public void clipResultsBlobTest() throws IOException {
        clipResultsBlobTest(blobDataFactory);
        clipResultsBlobTest(blobFileFactory);
    }

    /**
     * Overwrite an interval in the middle.
     */
    @Test
    public void blobInTheMiddle() throws IOException {
        blobInTheMiddle(blobDataFactory);
        blobInTheMiddle(blobFileFactory);
    }

    /**
     * There is an interval that completely overlaps.
     */
    @Test
    public void checkDeletedBlobs() {
        checkDeletedBlobs(blobDataFactory);
        checkDeletedBlobs(blobFileFactory);
    }

    private <E> void singleCadenceBlobTest(CadenceBlobDataFactory<E> dataFactory)
        throws IOException {
        SimpleCadenceBlob single = new SimpleCadenceBlob(1, 2, 3, 4, 101);
        List<CadenceBlob> blobs = new ArrayList<CadenceBlob>();
        blobs.add(single);
        CadenceBlobCalculator<E> bcalc = new CadenceBlobCalculator<E>(blobs);
        BlobSeries<E> blobSeries = bcalc.blobSeries(dataFactory);
        try {
            assertEquals(1, blobSeries.blobFilenames().length);

            byte[] data = new byte[1024];
            Arrays.fill(data, (byte) 4);
            byte[] blobData = null;
            if (blobSeries.blobFilenames()[0] instanceof byte[]) {
                blobData = (byte[]) blobSeries.blobFilenames()[0];
            } else if (blobSeries.blobFilenames()[0] instanceof String) {
                blobData = extractBlobData((String) blobSeries.blobFilenames()[0]);
            }
            assertTrue(Arrays.equals(data, blobData));

            int[] indices = new int[2];
            Arrays.fill(indices, 0);
            assertTrue(Arrays.equals(indices, blobSeries.blobIndices()));
            boolean[] gaps = new boolean[2];
            Arrays.fill(gaps, false);
            assertTrue(Arrays.equals(gaps, blobSeries.gapIndicators()));
        } finally {
            deleteBlobFiles(blobSeries);
        }
    }

    private <E> void clipResultsBlobTest(CadenceBlobDataFactory<E> dataFactory)
        throws IOException {
        SimpleCadenceBlob b1 = new SimpleCadenceBlob(1, 100, 1000, 4, 101);
        SimpleCadenceBlob b2 = new SimpleCadenceBlob(2, 500, 2000, 5, 102);
        List<CadenceBlob> blobs = new ArrayList<CadenceBlob>();
        blobs.add(b2);
        blobs.add(b1);

        CadenceBlobCalculator<E> bcalc = new CadenceBlobCalculator<E>(blobs);
        BlobSeries<E> blobSeries = bcalc.blobSeriesForCadenceInterval(
            dataFactory, 0, 1500);
        try {
            assertEquals(2, blobSeries.blobFilenames().length);
            byte[] data4 = new byte[1024];
            Arrays.fill(data4, (byte) 4);
            byte[] blobData4 = null;
            byte[] data5 = new byte[1024];
            Arrays.fill(data5, (byte) 5);
            byte[] blobData5 = null;

            if (blobSeries.blobFilenames()[0] instanceof byte[]) {
                blobData4 = (byte[]) blobSeries.blobFilenames()[0];
                blobData5 = (byte[]) blobSeries.blobFilenames()[1];
            } else if (blobSeries.blobFilenames()[0] instanceof String) {
                blobData4 = extractBlobData((String) blobSeries.blobFilenames()[0]);
                blobData5 = extractBlobData((String) blobSeries.blobFilenames()[1]);
            }
            assertTrue(Arrays.equals(data4, blobData4));
            assertTrue(Arrays.equals(data5, blobData5));

            boolean[] gaps = new boolean[1501];
            Arrays.fill(gaps, 0, 100, true);
            assertTrue(Arrays.equals(gaps, blobSeries.gapIndicators()));

            int[] indices = new int[gaps.length];
            Arrays.fill(indices, 500, indices.length, 1); // index into
            // blobData()
            assertTrue(Arrays.equals(indices, blobSeries.blobIndices()));
        } finally {
            deleteBlobFiles(blobSeries);
        }
    }

    private <T> void blobInTheMiddle(CadenceBlobDataFactory<T> dataFactory)
        throws IOException {
        SimpleCadenceBlob b1 = new SimpleCadenceBlob(1, 1000, 2000, 1, 101);
        SimpleCadenceBlob b2 = new SimpleCadenceBlob(2, 1500, 1600, 2, 102);
        List<CadenceBlob> blobs = new ArrayList<CadenceBlob>();
        blobs.add(b2);
        blobs.add(b1);

        CadenceBlobCalculator<T> bcalc = new CadenceBlobCalculator<T>(blobs);
        BlobSeries<T> blobSeries = bcalc.blobSeries(dataFactory);

        try {
            assertEquals(2, blobSeries.blobFilenames().length);

            byte[] data1 = new byte[1024];
            Arrays.fill(data1, (byte) 1);
            byte[] blobData1 = null;
            byte[] data2 = new byte[1024];
            Arrays.fill(data2, (byte) 2);
            byte[] blobData2 = null;

            if (blobSeries.blobFilenames()[0] instanceof byte[]) {
                blobData1 = (byte[]) blobSeries.blobFilenames()[0];
                blobData2 = (byte[]) blobSeries.blobFilenames()[1];
            } else if (blobSeries.blobFilenames()[0] instanceof String) {
                blobData1 = extractBlobData((String) blobSeries.blobFilenames()[0]);
                blobData2 = extractBlobData((String) blobSeries.blobFilenames()[1]);
            }
            assertTrue(Arrays.equals(data1, blobData1));
            assertTrue(Arrays.equals(data2, blobData2));

            boolean[] gaps = new boolean[1001];
            assertTrue(Arrays.equals(gaps, blobSeries.gapIndicators()));

            int[] indices = new int[gaps.length];
            Arrays.fill(indices, 0, 500, 0);
            Arrays.fill(indices, 500, 601, 1);
            Arrays.fill(indices, 601, indices.length, 0);
            assertTrue(Arrays.equals(indices, blobSeries.blobIndices()));
        } finally {
            deleteBlobFiles(blobSeries);
        }
    }

    private <T> void checkDeletedBlobs(CadenceBlobDataFactory<T> dataFactory) {
        SimpleCadenceBlob b1 = new SimpleCadenceBlob(1, 1000, 2000, 1, 101);
        SimpleCadenceBlob b2 = new SimpleCadenceBlob(2, 500, 600, 2, 102);
        SimpleCadenceBlob b3 = new SimpleCadenceBlob(3, 400, 3000, -1, 103);
        List<CadenceBlob> blobs = new ArrayList<CadenceBlob>();
        blobs.add(b2);
        blobs.add(b1);
        blobs.add(b3);

        CadenceBlobCalculator<T> bcalc = new CadenceBlobCalculator<T>(blobs);
        BlobSeries<T> blobSeries = bcalc.blobSeries(dataFactory);
        try {
            List<CadenceBlob> deletedBlobs = bcalc.deletedBlobs();
            assertEquals(1, blobSeries.blobFilenames().length);
            assertEquals(2, deletedBlobs.size());

            assertEquals(b1.getId(), deletedBlobs.get(0)
                .getId());
            assertEquals(b2.getId(), deletedBlobs.get(1)
                .getId());
        } finally {
            deleteBlobFiles(blobSeries);
        }

    }

    /**
     * 
     * @author Sean McCauliff
     * 
     */

    private static final class SimpleCadenceBlob implements CadenceBlob {
        private final long creationTime;
        private final int startCadence;
        private final int endCadence;
        private final long id;
        private final String fileExtension;
        private final long originator;

        public SimpleCadenceBlob(long creationTime, int startCadence,
            int endCadence, long id, long originator) {

            this(creationTime, startCadence, endCadence, id, originator, ".mat");
        }

        public SimpleCadenceBlob(long creationTime, int startCadence,
            int endCadence, long id, long originator, String fileExtension) {
            this.creationTime = creationTime;
            this.startCadence = startCadence;
            this.endCadence = endCadence;
            this.id = id;
            this.fileExtension = fileExtension;
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

        public String getFileExtension() {
            return fileExtension;
        }

        public long getOriginator() {
            return originator;
        }

    }

    private static final class SimpleCadenceBlobDataFactory implements
        CadenceBlobDataFactory<byte[]> {

        public SimpleCadenceBlobDataFactory() {
        }

        @Override
        public long originatorForCadenceBlob(CadenceBlob cadenceBlob) {
            return ((SimpleCadenceBlob) cadenceBlob).getOriginator();
        }

        @Override
        public byte[] blobDataForCadenceBlob(CadenceBlob cadenceBlob) {
            byte[] data = new byte[1024];
            Arrays.fill(data, (byte) cadenceBlob.getId());
            return data;
        }

    }

    private static final class SimpleCadenceBlobFileFactory implements
        CadenceBlobDataFactory<String> {

        public SimpleCadenceBlobFileFactory() {
        }

        @Override
        public long originatorForCadenceBlob(CadenceBlob cadenceBlob) {
            return ((SimpleCadenceBlob) cadenceBlob).getOriginator();
        }

        @Override
        public String blobDataForCadenceBlob(CadenceBlob cadenceBlob) {
            File file = null;
            OutputStream outputStream = null;
            try {
                file = File.createTempFile("blob",
                    ((SimpleCadenceBlob) cadenceBlob).getFileExtension(),
                    new File("."));
                outputStream = new FileOutputStream(file);
                byte[] data = new byte[1024];
                Arrays.fill(data, (byte) cadenceBlob.getId());
                outputStream.write(data);
            } catch (IOException ioe) {
                throw new RuntimeException(ioe);
            } finally {
                FileUtil.close(outputStream);
            }
            return file.getName();
        }

    }

    private byte[] extractBlobData(String fileName) throws IOException {
        File file = new File(fileName);
        assertTrue(file.exists());
        assertEquals((int) file.length(), 1024);
        InputStream inputStream = null;
        byte[] blobData = null;
        try {
            inputStream = new FileInputStream(file);
            blobData = new byte[1024];
            inputStream.read(blobData);
        } finally {
            FileUtil.close(inputStream);
            file.delete();
        }
        return blobData;
    }

    private <T> void deleteBlobFiles(BlobSeries<T> blobSeries) {
        for (int i = 0; i < blobSeries.blobFilenames().length; i++) {
            if (blobSeries.blobFilenames()[i] instanceof String) {
                new File((String) blobSeries.blobFilenames()[i]).delete();
            }
        }
    }

}
