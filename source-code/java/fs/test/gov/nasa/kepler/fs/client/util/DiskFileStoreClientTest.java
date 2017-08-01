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

package gov.nasa.kepler.fs.client.util;

import static junit.framework.Assert.assertEquals;
import static junit.framework.Assert.assertFalse;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.fs.api.FileStoreTestInterface.TransactionState;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;
import java.util.Random;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class DiskFileStoreClientTest {

    private DiskFileStoreClient diskFsClient = null;
    private FileStoreClient fsClient = null;

    @Before
    public void setUp() {

        diskFsClient = new DiskFileStoreClient(true);
        FileStoreClientFactory.setInstance(diskFsClient);
        fsClient = FileStoreClientFactory.getInstance();
    }

    @After
    public void tearDown() {

        if (diskFsClient != null) {
            diskFsClient.cleanFileStore();
        }
        FileStoreClientFactory.setInstance(null);
    }

    @Test
    public void initialTransaction() {

        assertEquals("initial transaction state", TransactionState.INITIAL,
            diskFsClient.localTransactionState());
    }

    @Test
    public void transactionStarted() {

        fsClient.beginLocalFsTransaction();
        assertEquals("transaction started", TransactionState.STARTED,
            diskFsClient.localTransactionState());
    }

    @Test
    public void transactionCommitted() {

        fsClient.beginLocalFsTransaction();
        fsClient.commitLocalFsTransaction();
        assertEquals("transaction committed", TransactionState.COMMITTED,
            diskFsClient.localTransactionState());
    }

    @Test
    public void transactionRollback() {

        fsClient.beginLocalFsTransaction();
        fsClient.rollbackLocalFsTransaction();
        assertEquals("transaction rollback", TransactionState.ROLLEDBACK,
            diskFsClient.localTransactionState());
    }

    @Test
    public void transactionRollbackIfActive() {

        fsClient.beginLocalFsTransaction();
        fsClient.rollbackLocalFsTransactionIfActive();
        assertEquals("transaction rollback if active",
            TransactionState.ROLLEDBACK, diskFsClient.localTransactionState());
    }

    @Test
    public void transactionRollbackIfActiveInactive() {

        fsClient.rollbackLocalFsTransactionIfActive();
        assertEquals("rollback inactive transaction if active",
            TransactionState.INITIAL, diskFsClient.localTransactionState());
    }

    @Test(expected = FileStoreException.class)
    public void transactionCommitInactive() {

        fsClient.commitLocalFsTransaction();
    }

    @Test(expected = FileStoreException.class)
    public void transactionRollbackInactive() {

        fsClient.rollbackLocalFsTransaction();
    }

    @Test(expected = NullPointerException.class)
    public void blobExistsNullFsId() {

        fsClient.blobExists(null);
    }

    @Test
    public void blobExistsFalse() {

        FsId id = new FsId("/foo/bar");
        assertFalse("blob exists", fsClient.blobExists(id));
    }

    @Test(expected = FileStoreException.class)
    public void readNonExistentBlob() {

        FsId id = new FsId("/foo/bar/blob1");
        fsClient.readBlob(id);
    }

    @Test(expected = NullPointerException.class)
    public void writeBlobNullFsId() {

        fsClient.writeBlob(null, 1L, new byte[1]);
    }

    @Test(expected = NullPointerException.class)
    public void writeBlobNullData() {

        FsId id = new FsId("/foo/bar/blob1");
        fsClient.writeBlob(id, 1L, (byte[]) null);
    }

    @Test
    public void writeBlob() {

        FsId id = new FsId("/foo/bar/blob1");
        fsClient.writeBlob(id, 1L, new byte[1]);
    }

    @Test
    public void readBlob() throws IOException {

        FsId id = new FsId("/foo/bar/2020003123456-blob1");
        byte[] data = new byte[128];
        new Random().nextBytes(data);
        long originator = System.currentTimeMillis();
        fsClient.writeBlob(id, originator, data);

        StreamedBlobResult streamedResult = fsClient.readBlobAsStream(id);
        assertNotNull("streamed result null", streamedResult);
        assertNotNull("streamed result stream null", streamedResult.stream());
        assertEquals("streamed result stream length", 128,
            streamedResult.stream()
                .available());
        assertEquals("streamed result originator", originator,
            streamedResult.originator());

        BlobResult result = fsClient.readBlob(id);
        assertNotNull("result null", result);
        assertNotNull("result data null", result.data());
        assertEquals("result data length", 128, result.data().length);
        assertEquals("result originator", originator, result.originator());

        File tmpFile = File.createTempFile("DiskFileStoreClient", "blob",
            new File(Filenames.BUILD_TMP));
        long blobOriginator = fsClient.readBlob(id, tmpFile);
        assertEquals("blob originator", originator, blobOriginator);
        assertEquals("blob length", 128, tmpFile.length());

        InputStream inputStream = new FileInputStream(tmpFile);
        byte[] blobData = new byte[128];
        int bytesRead = inputStream.read(blobData);
        assertEquals("blob bytes read", 128, bytesRead);
        assertTrue("blob data", Arrays.equals(data, blobData));
    }

    @Test
    public void blobExists() {

        FsId id = new FsId("/foo/bar/blob1");
        fsClient.writeBlob(id, 1L, new byte[1]);
        assertTrue("blob exists", fsClient.blobExists(id));
    }

    @Test
    public void throwAwayWrites() {

        diskFsClient.setThrowAwayWrites(true);

    }

    @Test(expected = NullPointerException.class)
    public void readAllTimeSeriesAsIntNullArray() {

        fsClient.readAllTimeSeriesAsInt(null);
    }

    @Test(expected = NullPointerException.class)
    public void readAllTimeSeriesAsFloatNullArray() {

        fsClient.readAllTimeSeriesAsFloat(null);
    }

    @Test(expected = NullPointerException.class)
    public void readAllTimeSeriesAsIntNullValue() {

        fsClient.readAllTimeSeriesAsInt(new FsId[1]);
    }

    @Test(expected = NullPointerException.class)
    public void readAllTimeSeriesAsFloatNullValue() {

        fsClient.readAllTimeSeriesAsFloat(new FsId[1]);
    }

    @Test(expected = NullPointerException.class)
    public void readTimeSeriesAsIntNullArray() {

        fsClient.readTimeSeriesAsInt(null, 0, 0);
    }

    @Test(expected = NullPointerException.class)
    public void readTimeSeriesAsFloatNullArray() {

        fsClient.readTimeSeriesAsFloat(null, 0, 0);
    }

    @Test(expected = IllegalArgumentException.class)
    public void readTimeSeriesAsIntEmptyArray() {

        fsClient.readTimeSeriesAsInt(new FsId[0], 0, 0);
    }

    @Test(expected = NullPointerException.class)
    public void readTimeSeriesAsIntNullValue() {

        fsClient.readTimeSeriesAsInt(new FsId[1], 0, 0);
    }

    @Test(expected = NullPointerException.class)
    public void readTimeSeriesAsFloatNullValue() {

        fsClient.readTimeSeriesAsFloat(new FsId[1], 0, 0);
    }

    @Test(expected = IllegalArgumentException.class)
    public void readTimeSeriesAsIntInvalidCadences() {

        FsId id = new FsId("/foo/bar/ts1");
        fsClient.readTimeSeriesAsInt(new FsId[] { id }, 1, 0, false);
    }

    @Test(expected = IllegalArgumentException.class)
    public void readTimeSeriesAsFloatInvalidCadences()
        {

        FsId id = new FsId("/foo/bar/ts1");
        fsClient.readTimeSeriesAsFloat(new FsId[] { id }, 1, 0, false);
    }

    @Test(expected = FileStoreIdNotFoundException.class)
    public void readTimeSeriesAsIntExistsErrorDefault()
        {

        FsId id = new FsId("/foo/bar/ts1");
        fsClient.readTimeSeriesAsInt(new FsId[] { id }, 1, 0);
    }

    @Test(expected = FileStoreIdNotFoundException.class)
    public void readTimeSeriesAsFloatExistsErrorDefault()
        {

        FsId id = new FsId("/foo/bar/ts1");
        fsClient.readTimeSeriesAsFloat(new FsId[] { id }, 1, 0);
    }

    @Test(expected = FileStoreIdNotFoundException.class)
    public void readTimeSeriasAsIntExistsError() {

        FsId id = new FsId("/foo/bar/ts1");
        fsClient.readTimeSeriesAsInt(new FsId[] { id }, 0, 1, true);
    }

    @Test(expected = FileStoreIdNotFoundException.class)
    public void readTimeSeriasAsFloatExistsError() {

        FsId id = new FsId("/foo/bar/ts1");
        fsClient.readTimeSeriesAsFloat(new FsId[] { id }, 0, 1, true);
    }

    @Test
    public void readTimeSeriasAsIntExistsErrorFalse() {

        FsId id = new FsId("/foo/bar/ts1");
        IntTimeSeries[] timeSeries = fsClient.readTimeSeriesAsInt(
            new FsId[] { id }, 0, 1, false);
        assertEquals("time series length", 1, timeSeries.length);
        assertEquals("time series id", id, timeSeries[0].id());
        assertFalse("time series exists", timeSeries[0].exists());
    }

    @Test
    public void readTimeSeriasAsFloatExistsErrorFalse()
        {

        FsId id = new FsId("/foo/bar/ts1");
        FloatTimeSeries[] timeSeries = fsClient.readTimeSeriesAsFloat(
            new FsId[] { id }, 0, 1, false);
        assertEquals("time series length", 1, timeSeries.length);
        assertEquals("time series id", id, timeSeries[0].id());
        assertFalse("time series exists", timeSeries[0].exists());
    }

    @Test(expected = NullPointerException.class)
    public void writeTimeSeriesNullArray() {

        fsClient.writeTimeSeries(null);
    }

    @Test(expected = NullPointerException.class)
    public void writeTimeSeriesNullValue() {

        fsClient.writeTimeSeries(new FloatTimeSeries[1]);
    }

    @Test
    public void writeFloatTimeSeries() {

        FsId id = new FsId("/foo/bar/ts1");
        FloatTimeSeries writeTimeSeries = new FloatTimeSeries(id, new float[1],
            1, 1, new boolean[1], 1L);
        fsClient.writeTimeSeries(new FloatTimeSeries[] { writeTimeSeries });
    }

    @Test
    public void writeIntTimeSeries() {

        FsId id = new FsId("/foo/bar/ts1");
        IntTimeSeries writeTimeSeries = new IntTimeSeries(id, new int[1], 1, 1,
            new boolean[1], 1L);
        fsClient.writeTimeSeries(new IntTimeSeries[] { writeTimeSeries });
    }
    
    @Test
    public void writeDoubleTimeSeries() {

        FsId id = new FsId("/foo/bar/ts1");
        DoubleTimeSeries writeTimeSeries = new DoubleTimeSeries(id, new double[1], 1, 1,
            new boolean[1], 1L);
        fsClient.writeTimeSeries(new TimeSeries[] { writeTimeSeries });
    }

    @Test(expected = FileStoreIdNotFoundException.class)
    public void readFloatTimeSeriesNonExistent() {

        FsId id = new FsId("/foo/bar/ts1");
        FloatTimeSeries[] timeSeries = fsClient.readAllTimeSeriesAsFloat(
            new FsId[] { id }, false);
        assertNotNull("read float time series", timeSeries);
        assertEquals("read float time serieslength", 1, timeSeries.length);
        assertFalse("float time series exists", timeSeries[0].exists());

        timeSeries = fsClient.readAllTimeSeriesAsFloat(new FsId[] { id }, true);
        assertTrue("Exception should have been thrown.", false);
    }

    @Test
    public void readFloatTimeSeries() {

        writeFloatTimeSeries();

        FsId id = new FsId("/foo/bar/ts1");
        FloatTimeSeries[] timeSeries = fsClient.readAllTimeSeriesAsFloat(new FsId[] { id });
        assertNotNull("read float time series", timeSeries);
        assertEquals("read float time serieslength", 1, timeSeries.length);
        assertTrue("float time series exists", timeSeries[0].exists());
    }

    @Test(expected = FileStoreIdNotFoundException.class)
    public void readIntTimeSeriesNonExistent() {

        FsId id = new FsId("/foo/bar/ts1");
        IntTimeSeries[] timeSeries = fsClient.readAllTimeSeriesAsInt(
            new FsId[] { id }, false);
        assertNotNull("read int time series", timeSeries);
        assertEquals("read int time serieslength", 1, timeSeries.length);
        assertFalse("int time series exists", timeSeries[0].exists());

        timeSeries = fsClient.readAllTimeSeriesAsInt(new FsId[] { id }, true);
        assertTrue("Should have thrown exception.", false);
    }

    @Test
    public void readIntTimeSeries() {

        FsId id = new FsId("/foo/bar/ts1");
        writeIntTimeSeries();

        IntTimeSeries[] timeSeries = fsClient.readAllTimeSeriesAsInt(new FsId[] { id });
        assertNotNull("read int time series", timeSeries);
        assertEquals("read int time serieslength", 1, timeSeries.length);
        assertTrue("int time series exists", timeSeries[0].exists());
        
        FsIdSet idSet = new FsIdSet(1, 1, Collections.singleton(id));
        List<TimeSeriesBatch> batchList = 
            diskFsClient.readTimeSeriesBatch(Collections.singletonList(idSet), true);
        assertEquals("time series batch list size",1,  batchList.size());
        assertEquals("time series set size", 1, batchList.get(0).timeSeries().size());
        assertTrue("time series set size",batchList.get(0).timeSeries().get(id).exists());
        
    }
    
    @Test
    public void readDoubleTimeSeries() {

        FsId id = new FsId("/foo/bar/ts1");
        writeDoubleTimeSeries();

        DoubleTimeSeries[] timeSeries = fsClient.readAllTimeSeriesAsDouble(new FsId[] { id }, true);
        assertNotNull("read double time series", timeSeries);
        assertEquals("read double time serieslength", 1, timeSeries.length);
        assertTrue("int double series exists", timeSeries[0].exists());
        
        FsIdSet idSet = new FsIdSet(1, 1, Collections.singleton(id));
        List<TimeSeriesBatch> batchList = 
            diskFsClient.readTimeSeriesBatch(Collections.singletonList(idSet), true);
        assertEquals("time series batch list size",1,  batchList.size());
        assertEquals("time series set size", 1, batchList.get(0).timeSeries().size());
        assertTrue("time series set size",batchList.get(0).timeSeries().get(id).exists());
        
    }
    
    @Test
    public void writeReadMjdTimeSeries() {
        FsId id = new FsId("/blah/blah");
        double[] mjd  = new double[10];
        float[] values = new float[mjd.length];
        for (int i=0; i < mjd.length; i++) {
            mjd[i] = 1.0 + i * (1.0/mjd.length);
            values[i] = (float) ((i+1) * Math.PI);
        }
        
        FloatMjdTimeSeries fmjd = 
            new FloatMjdTimeSeries(id, 1.0, 2.0, mjd, values, 5L);
        fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] {fmjd});
        FloatMjdTimeSeries[] readSeries = 
            fsClient.readMjdTimeSeries(new FsId[] {id}, 1.0, 2.0);
        assertEquals(fmjd, readSeries[0]);
        
        MjdFsIdSet idSet = new MjdFsIdSet(1.0, 2.0, Collections.singleton(id));
        List<MjdTimeSeriesBatch> batch = 
            diskFsClient.readMjdTimeSeriesBatch(Collections.singletonList(idSet));
        assertEquals("number of batches", 1, batch.size());
        assertEquals("number of series", 1, batch.get(0).timeSeries().size());
        assertEquals(fmjd, batch.get(0).timeSeries().get(id));
    }

    @Test
    public void recordKeeping() {

        assertEquals("blobs read size", 0, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 0, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 0,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 0,
            diskFsClient.getTimeSeriesWritten()
                .size());

        writeBlob();

        assertTrue("blob exists", diskFsClient.blobExists(new FsId(
            "/foo/bar/blob1")));

        assertEquals("blobs read size", 0, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 1, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 0,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 0,
            diskFsClient.getTimeSeriesWritten()
                .size());

        writeFloatTimeSeries();

        assertTrue("time series exists",
            diskFsClient.timeSeriesExists(new FsId("/foo/bar/ts1")));

        assertEquals("blobs read size", 0, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 1, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 0,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 1,
            diskFsClient.getTimeSeriesWritten()
                .size());

        fsClient.readBlob(new FsId("/foo/bar/blob1"));

        assertEquals("blobs read size", 1, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 1, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 0,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 1,
            diskFsClient.getTimeSeriesWritten()
                .size());

        fsClient.readAllTimeSeriesAsFloat(new FsId[] { new FsId("/foo/bar/ts1") });

        assertEquals("blobs read size", 1, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 1, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 1,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 1,
            diskFsClient.getTimeSeriesWritten()
                .size());
        
        FsIdSet fsIdSet = new FsIdSet(1, 1, Collections.singleton(new FsId("/foo/bar/ts1")));
        fsClient.readTimeSeriesBatch(Collections.singletonList(fsIdSet), true);
        
        assertEquals("blobs read size", 1, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 1, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 2,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 1,
            diskFsClient.getTimeSeriesWritten()
                .size());

        diskFsClient.cleanFileStore();

        assertEquals("blobs read size", 0, diskFsClient.getBlobsRead()
            .size());
        assertEquals("blobs written size", 0, diskFsClient.getBlobsWritten()
            .size());
        assertEquals("time series read size", 0,
            diskFsClient.getTimeSeriesRead()
                .size());
        assertEquals("time series written size", 0,
            diskFsClient.getTimeSeriesWritten()
                .size());
        
        
        
    }
}
