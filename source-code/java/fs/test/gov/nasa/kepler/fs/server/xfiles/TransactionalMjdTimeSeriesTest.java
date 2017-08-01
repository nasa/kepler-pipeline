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

package gov.nasa.kepler.fs.server.xfiles;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FloatMjdTimeSeries;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.journal.JournalStreamReader;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.journal.SerialJournalWriter;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.io.File;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.Xid;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class TransactionalMjdTimeSeriesTest {
    private final AtomicInteger xidNumber = new AtomicInteger(0);
    
    private File rootDir = new File(Filenames.BUILD_TEST,
        "TransactionalCosmicRayTest.test");
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        rootDir.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
    }
    
    public static void commitTransaction(Xid xid, File journalFile,
            TransactionalMjdTimeSeriesFile xfile, RandomAccessStorage storage) throws Exception {
        
        TransactionalMjdTimeSeriesFile.Recovery recovery =
            TransactionalMjdTimeSeriesFile.recoverFile(storage, true);
        JournalStreamReader journalReader = new JournalStreamReader(journalFile);
        try {
            for (JournalEntry journalEntry : journalReader) {
                if (journalEntry.fsId().equals(xfile.id())) {
                    recovery.mergeRecovery(journalEntry);
                }
            }
            recovery.recoveryComplete();
        } finally {
            journalReader.close();
        }
        xfile.commitTransaction(xid);
    }
    @Test
    public void testSimpleReadWrite() throws Exception {
        File seriesFile0 = new File(rootDir, "series0");
        
        FsId id = new FsId("/test/crs/1");
        DefaultStorage storage = new DefaultStorage(seriesFile0, id, true, true);
        TransactionalMjdTimeSeriesFile xfile =
            TransactionalMjdTimeSeriesFile.loadFile(storage);
       
        Xid xid = new FakeXid(3,4);
        File journalFile = new File(rootDir, "journal");
        JournalWriter journalWriter = new SerialJournalWriter(journalFile, xid);
        
        xfile.beginTransaction(xid, journalWriter, 1);
        double[] mjd = new double[10];
        float[] values = new float[mjd.length];
        long[] originators =new long[mjd.length];
        for (int i=0; i < mjd.length; i++) {
            mjd[i] = Math.PI * (i+1);
            values[i] =(float) Math.E * (i + 1);
            originators[i] = Long.MAX_VALUE - i;
        }
        FloatMjdTimeSeries series = 
            new FloatMjdTimeSeries(id, -Double.MIN_VALUE, Double.MAX_VALUE,
                                                mjd, values, originators, true);
        
        xfile.write(series, true, xid);
        xfile.acquireTransactionLock(xid);
        xfile.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(xid, journalWriter.file(), xfile, storage);
        
        File journalFile2 = new File(rootDir, "journal2");
        Xid xid2 = new FakeXid(55, 444);
        JournalWriter journalWriter2 = new SerialJournalWriter(journalFile2, xid2);
        xfile.beginTransaction(xid2, journalWriter2, 1);
        FloatMjdTimeSeries readSeries = xfile.read(0, 100000000.0, xid2);
            
        
        FloatMjdTimeSeries expectedSeries =
            new FloatMjdTimeSeries(id, 0.0, 100000000.0, mjd, values, originators, true);
        ReflectionEquals refEquals = new ReflectionEquals();
        refEquals.assertEquals(expectedSeries, readSeries);
        
        //Check that the old file will load correctly.
        storage = new DefaultStorage(seriesFile0, id, true, false);
        xfile = TransactionalMjdTimeSeriesFile.loadFile(storage);
        Xid xid3 = new FakeXid(77, 4444);
        File journalFile3 = new File(rootDir, "journal3");
        JournalWriter journalWriter3 = new SerialJournalWriter(journalFile3, xid3);
        xfile.beginTransaction(xid3, journalWriter3, 2);
        readSeries = xfile.read(-Double.MIN_VALUE, Double.MAX_VALUE, xid3);
        assertEquals(series, readSeries);
        
    }
    @Test
    public void overwriteFalse() throws Exception {
           FsId id = new FsId("/test/crs/1");
        MjdTimeSeriesTestData testData = new MjdTimeSeriesTestData(id);
        File seriesFile0 = new File(rootDir, "series0");

 
        DefaultStorage storage = new DefaultStorage(seriesFile0, id, true, true);
        TransactionalMjdTimeSeriesFile xfile =
            TransactionalMjdTimeSeriesFile.loadFile(storage);

        Xid xid = new FakeXid(3,4);
        File journalFile = new File(rootDir, "journal");
        JournalWriter journalWriter = new SerialJournalWriter(journalFile, xid);


        xfile.beginTransaction(xid, journalWriter, 1);
    
        xfile.write(testData.series, false, xid);
        xfile.acquireTransactionLock(xid);
        xfile.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(xid, journalWriter.file(), xfile, storage);
        
        File journalFile2 = new File(rootDir, "journal2");
        Xid xid2 = new FakeXid(5,6);
        JournalWriter journalWriter2 = new SerialJournalWriter(journalFile2, xid2);

        xfile.beginTransaction(xid2, journalWriter2, 2);
        xfile.write(testData.middle, false, xid2);
        xfile.acquireTransactionLock(xid2);
        xfile.prepareTransaction(xid2);
        journalWriter2.close();
        commitTransaction(xid2, journalWriter2.file(), xfile, storage);
        
    
        Xid xid3 = new FakeXid(6,7);
        File journalFile3 = new File(rootDir, "journal3");
        JournalWriter journalWriter3 = new SerialJournalWriter(journalFile3, xid3);
        xfile.beginTransaction(xid3, journalWriter3, 50);
        FloatMjdTimeSeries readSeries = xfile.read(-Double.MIN_VALUE, Double.MAX_VALUE, xid3);
        ReflectionEquals reflectionEquals = new ReflectionEquals();
        reflectionEquals.assertEquals(testData.combinedSeries, readSeries);
        
        
    }

    @Test
    public void simpleDeleteMjdTimeSeries() throws Exception {
        File seriesFile0 = new File(rootDir, "series0");
        
        FsId id = new FsId("/test/crs/1");
        FloatMjdTimeSeries someData = new FloatMjdTimeSeries(id, 0.0, 1.0, new double[] { 0.5}, new float[] {8.0f}, 2);
        
        DefaultStorage storage = new DefaultStorage(seriesFile0, id, true, true);
        TransactionalMjdTimeSeriesFile xfile = 
            TransactionalMjdTimeSeriesFile.loadFile(storage);    
        Xid xid = new FakeXid(3,4);
        
        File journalFile = new File(rootDir, "j");
        JournalWriter journalWriter = new SerialJournalWriter(journalFile, xid);
        xfile.beginTransaction(xid, journalWriter, 2);
        xfile.write(someData, true, xid);
        xfile.acquireTransactionLock(xid);
        xfile.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(xid, journalFile, xfile, storage);
        
        File journalFile2 = new File(rootDir, "j2");
        JournalWriter journalWriter2 = new SerialJournalWriter(journalFile2, xid);
        xfile.beginTransaction(xid, journalWriter2, 2);
        xfile.delete(xid);
        try {
            xfile.read(0.0, 1.0, xid);
            assertTrue("should not have reached here", false);
        } catch (FileStoreIdNotFoundException idNotFound) {
            //ok
        }
        xfile.acquireTransactionLock(xid);
        xfile.prepareTransaction(xid);
        journalWriter2.close();
        commitTransaction(xid, journalFile2, xfile, storage);
        
        assertFalse(seriesFile0.exists());
    }
    
    @Test
    public void deleteMjdTimeSeriesWhileAnotherIsReading() throws Exception {
        File seriesFile0 = new File(rootDir, "series0");
        
        FsId id = new FsId("/test/crs/1");
        FloatMjdTimeSeries someData = new FloatMjdTimeSeries(id, 0.0, 1.0, new double[] { 0.5}, new float[] {8.0f}, 2);
        
        DefaultStorage storage = new DefaultStorage(seriesFile0, id, true, true);
        TransactionalMjdTimeSeriesFile xfile = 
            TransactionalMjdTimeSeriesFile.loadFile(storage);    
        Xid xid = new FakeXid(3,4);
        
        File journalFile = new File(rootDir, "j");
        JournalWriter journalWriter = new SerialJournalWriter(journalFile, xid);
        xfile.beginTransaction(xid, journalWriter, 2);
        xfile.write(someData, true, xid);
        xfile.acquireTransactionLock(xid);
        xfile.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(xid, journalFile, xfile, storage);
        
        File journalFile2 = new File(rootDir, "j2");
        JournalWriter journalWriter2 = new SerialJournalWriter(journalFile2, xid);
        xfile.beginTransaction(xid, journalWriter2, 2);
        xfile.delete(xid);
        
        Xid xid2 = new FakeXid(44, 44);
        File journalFile1_xid2 = new File(rootDir, "j1-xid2");
        JournalWriter journalWriter_xid2 = new SerialJournalWriter(journalFile1_xid2, xid2);
        xfile.beginTransaction(xid2, journalWriter_xid2, 2);
        FloatMjdTimeSeries read = xfile.read(0.0, 1.0, xid2);
        assertEquals(someData, read);
        
        xfile.acquireTransactionLock(xid);
        xfile.prepareTransaction(xid);
        journalWriter2.close();
        commitTransaction(xid, journalWriter2.file(), xfile, storage);
        
        try {
            xfile.read(0.0, 1.0, xid2);
            assertTrue("should not have reached here", false);
        } catch (FileStoreIdNotFoundException fsinfe) {
            //ok
        }
        
    }
    
    /**
     * Multiple threads read and write to the mjd time series.  Reading
     * threads should always read a consistent state of the series.
     * They can check this because the writing thread's id is written into the
     * series and the reading thread can regenerate the entire series from this.
     * 
     * @throws Exception
     */
    @Test
    public void mtSimpleReadWriteMjdTimeSeries() throws Exception {
        File seriesFile0 = new File(rootDir, "series0");
        FsId fsId = new FsId("/test/crs/1");
        DefaultStorage storage = new DefaultStorage(seriesFile0,fsId, true, true);
        final TransactionalMjdTimeSeriesFile xfile =
            TransactionalMjdTimeSeriesFile.loadFile(storage);
        
        final int maxThreads = 32;
        final CountDownLatch start = new CountDownLatch(1);
        final CountDownLatch stop = new CountDownLatch(maxThreads);
        final AtomicReference<Throwable> error = 
            new AtomicReference<Throwable>();

        for (int i=0; i < maxThreads; i++) {
            Runnable r = new MtReadWrite(xfile, start, stop, error, i, storage);
            Thread t = new Thread(r, "TransactionalCosmicRay-mtSimpleReadWriteTest-" + i);
            t.setDaemon(true);
            t.start();
        }
        
        start.countDown();
        stop.await();
        
        assertTrue((error.get() == null) ? "" : error.get().toString(), error.get() == null);
        
    }
    
    

    private  class MtReadWrite implements Runnable {
        private final CountDownLatch start;
        private final CountDownLatch stop;
        private final AtomicReference<Throwable> error;
        private final int threadId;
        private final TransactionalMjdTimeSeriesFile xfile;
        private final RandomAccessStorage storage;
        
        MtReadWrite(TransactionalMjdTimeSeriesFile xfile, CountDownLatch start, CountDownLatch stop, AtomicReference<Throwable> error, int threadId, RandomAccessStorage storage) {
            this.start = start;
            this.stop = stop;
            this.error = error;
            this.threadId = threadId;
            this.xfile = xfile;
            this.storage = storage;
        }
        
        public void run() {
            
            try {
                start.await();
                for (int i=0; i < 5; i++) {
                    Xid xid = nextXid();
                    File journalFile = new File(rootDir, "journal-" + threadId + "-" + i);
                    JournalWriter journalWriter = new SerialJournalWriter(journalFile, xid);
                    xfile.beginTransaction(xid, journalWriter, 30);
                    
                    //Write the CosmicRaySeries so that the first originator is
                    //the thread id that generated the series, when we read it
                    //back we can completely regenerate the expected series.
                    if ((threadId % 2) == 0) {
                        xfile.write(generateCosmicRaySeries(threadId), true, xid);
                        xfile.acquireTransactionLock(xid);
                        xfile.prepareTransaction(xid);
                        journalWriter.close();
                        commitTransaction(xid, journalWriter.file(), xfile, storage);
                    } else {
                        FloatMjdTimeSeries readSeries = 
                            xfile.read(-Double.MIN_VALUE, Double.MAX_VALUE, xid);
                        if (readSeries.mjd().length != 0) {
                            FloatMjdTimeSeries expectedSeries =
                                generateCosmicRaySeries((int)readSeries.originators()[0]);
                            assertEquals(expectedSeries, readSeries);
                        }
                        xfile.rollbackTransaction(xid);
                    }
                    
                    journalFile.delete();
                }
            } catch (Throwable t) {
                t.printStackTrace();
                error.compareAndSet(null, t);
            } finally {
                stop.countDown();
            }
        }
        
        private FloatMjdTimeSeries generateCosmicRaySeries(int threadId) {
            double[] mjd = new double[1024*8];
            float[] values = new float[mjd.length];
            long[] origin = new long[mjd.length];
            
            for (int i=0; i < mjd.length; i++) {
                mjd[i] = i * Math.E + threadId;
                values[i] = threadId + i * (float)Math.PI;
                origin[i] = threadId + i;
            }
            
            return new FloatMjdTimeSeries(xfile.id(), -Double.MIN_VALUE, 
                Double.MAX_VALUE, mjd, values, origin, true);
        }
        
        private Xid nextXid() {
            int xidn = xidNumber.getAndIncrement();
            return new FakeXid(xidn , 0);
        }
        
    }
    
}
