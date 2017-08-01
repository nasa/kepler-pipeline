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

import static gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFile.loadFile;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.journal.JournalStreamReader;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.journal.SerialJournalWriter;
import gov.nasa.kepler.fs.storage.DirectoryHash;
import gov.nasa.kepler.fs.storage.RandomAccessAllocator;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;
import gov.nasa.spiffy.common.collect.ArrayUtils;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.Xid;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class TransactionalRandomAccessFileTest {

    // TODO: Need to add error cases

    private final File rootDir = new File(Filenames.BUILD_TEST
        , "/TransactionalRandomAccessFileTest.test");
    private final File targetFile = new File(rootDir, "targetFile");

    private RandomAccessAllocator dirHash;
    private final FsId id = new FsId("/TransactionalRandomAccessFileTest/blah");
    private JournalWriter journalWriter;
    private File journalFile;
    private byte[] data;
    private TransactionalRandomAccessFileMetadataCache mdCache;

    @Before
    public void setUp() throws Exception {
        rootDir.mkdirs();
        data = new byte[1024 * 16];
        for (int i = 0; i < data.length; i++) {
            data[i] = (byte) (i + 1);
        }
        if (dirHash != null) {
            dirHash.close();
        }
        DirectoryHash forTimeSeries = new DirectoryHash(64, 8, rootDir);
        dirHash = new RandomAccessAllocator(forTimeSeries);
        journalFile = new File(rootDir, "journalFile");
        Xid xid = new FakeXid(new BigInteger("3434"), new BigInteger("444"));
        journalWriter = new SerialJournalWriter(journalFile, xid);
        mdCache = new TransactionalRandomAccessFileMetadataCache();
    }

    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
    }

    public static void commitTransaction(File journalFile, Xid xid, TransactionalRandomAccessFile traf, RandomAccessStorage storage) throws Exception {
        TransactionalRandomAccessFile.Recovery recovery =
            TransactionalRandomAccessFile.recoverFile(storage);
        JournalStreamReader journalStreamReader =
            new JournalStreamReader(journalFile);
        try {
	        for (JournalEntry journalEntry : journalStreamReader) {
	            recovery.mergeRecovery(journalEntry);
	        }
	        recovery.recoveryComplete();
        } finally {
        	journalStreamReader.close();
        }
        traf.commitTransaction(xid);
    }
    
    @Test
    public void trafDelete() throws Exception {
        DefaultStorage defaultStorage = new DefaultStorage(targetFile, id);
        TransactionalRandomAccessFile xrf = loadFile(defaultStorage, mdCache);
        FakeXid xid = new FakeXid(1,1);
        xrf.beginTransaction(xid, 1, journalWriter);
        xrf.write(new byte[1],0, 1, 0, xid, 1);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, defaultStorage);
        
        xid = new FakeXid(2,1);
        File journalFile = new File(rootDir, "journalFile2");
        journalWriter = new SerialJournalWriter(journalFile, xid);
        xrf.beginTransaction(xid, 1, journalWriter);
        xrf.delete(xid);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, defaultStorage);
        
        assertFalse(targetFile.exists());
    }
    
    @Test
    public void writeWithGaps() throws Exception {
        List<SimpleInterval> valid = new ArrayList<SimpleInterval>();
        valid.add(new SimpleInterval(0,1024));
        valid.add(new SimpleInterval(3000, data.length-1));
        List<TaggedInterval> originators = new ArrayList<TaggedInterval>();
        originators.add(new TaggedInterval(0,1024, 7));
        originators.add(new TaggedInterval(3000,data.length-1, 8));
        
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        FakeXid xid = new FakeXid(1,1);
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data,0, data.length, 0, xid,valid, originators);
        mdCache.clear();
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);
        
        byte[] readData = new byte[data.length];
        xid = new FakeXid(4, 5);
        File journalFile2 = new File(rootDir, "j2");
        journalWriter = new SerialJournalWriter(journalFile2, xid);
        DefaultStorage defaultStorage2 = new DefaultStorage(targetFile, id);
        defaultStorage2.setNew(false);
        mdCache.clear();
        xrf = loadFile(defaultStorage2, mdCache);
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.read(readData, 0, readData.length, 0, xid);
        
        assertTrue(Arrays.equals(readData, data));
        
    }

    /**
     * Attempt to read uncommitted data.
     * 
     * @throws Exception
     */
    @Test
    public void readUncommittedXRAF() throws Exception {
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        FakeXid xid = new FakeXid(3, 5);
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data, 0, data.length, 0, xid, 23);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        byte[] uncommittedData = new byte[1024];
        Arrays.fill(uncommittedData, (byte) 88);

        xid = new FakeXid(999, 34);
        File journalFile2 = new File(rootDir, "j2");
        DefaultStorage defaultStorage2 = new DefaultStorage(targetFile, id);
        defaultStorage2.setNew(false);
        journalWriter = new SerialJournalWriter(journalFile2, xid);

        xrf = loadFile(defaultStorage2, mdCache);
        xrf.beginTransaction(xid, 8, journalWriter);
        xrf.write(uncommittedData, 0, uncommittedData.length, 1024, xid,88);
        byte[] readData = new byte[data.length];
        xrf.read(readData, 0, readData.length, 0, xid);
        System.arraycopy(uncommittedData, 0, data, 1024, uncommittedData.length);
        assertTrue(Arrays.equals(data, readData));
    }

    /**
     * Being a transaction. Write some data. Commit. Read that data back.
     * 
     */
    @Test
    public void basicReadWrite() throws Exception {
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        FakeXid xid = new FakeXid(new BigInteger("1"), new BigInteger("2"));
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data, 0, data.length, 0, xid,23);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        byte[] read = new byte[data.length];
        xid = new FakeXid(new BigInteger("2323"), new BigInteger("333"));
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.read(read, 0, read.length, 0, xid);
        xrf.rollbackTransaction(xid);

        assertTrue("Read and write data must be equal.",
            Arrays.equals(data, read));
    }

    /**
     * Begin a transaction. Write some data. Prepare Commit. Begin a
     * transaction. Write some data. Prepare Rollback.
     */
    @Test
    public void rollbackCheckData() throws Exception {
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);

        FakeXid xid = new FakeXid(new BigInteger("1"), new BigInteger("2"));
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.setDataType(xid, (byte)77);
        xrf.write(data, 0, data.length, 0, xid,  23);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        xid = new FakeXid(new BigInteger("3"), new BigInteger("4"));
        File journalFile = new File(rootDir, "secondJournal");
        journalWriter = new SerialJournalWriter(journalFile, xid);
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.setDataType(xid, (byte) 78);
        xrf.write(data, 0, data.length, 1, xid, 42);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        xrf.rollbackTransaction(xid);

        xid = new FakeXid(new BigInteger("3335"), new BigInteger("666"));
        journalFile = new File(rootDir, "thirdJournal");
        journalWriter = new SerialJournalWriter(journalFile, xid);
        byte[] read = new byte[data.length];
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.read(read, 0, read.length, 0, xid);
        FileMetadata meta = xrf.metadata(xid);
        assertEquals((byte) 77, meta.dataType);
        xrf.rollbackTransaction(xid);
        assertTrue("Read and write data must be equal.",
            Arrays.equals(data, read));
    }

    /**
     * Test that dataType can be read/written correctly.
     */
    @Test
    public void dataTypeCorrectness() throws Exception {
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);

        //Uncommitted read
        FakeXid xid = new FakeXid(new BigInteger("1"), new BigInteger("2"));
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data,0, data.length, 0, xid,  23);
        xrf.setDataType(xid, (byte) 77);
        FileMetadata meta = xrf.metadata(xid);
        assertEquals((byte) 77, meta.dataType);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        //committed read
        xid = new FakeXid(new BigInteger("1666"), new BigInteger("2"));
        journalWriter =
            new SerialJournalWriter(new File(rootDir, "secondJournal"), xid);

        xrf.beginTransaction(xid, 1, journalWriter);
        meta = xrf.metadata(xid);
        xrf.rollbackTransaction(xid);
        assertEquals((byte) 77, meta.dataType);

        //Reload file.
        mdCache.clear();
        DefaultStorage loadStorage = new DefaultStorage(targetFile, id);
        loadStorage.setNew(false);
        TransactionalRandomAccessFile newX = loadFile(loadStorage, mdCache);
        FakeXid newXid = new FakeXid(new BigInteger("7"), new BigInteger("2"));
        newX.beginTransaction(newXid, 30, null);
        meta = newX.metadata(newXid);
        assertEquals((byte) 77, meta.dataType);
    }

    /**
     * Recover file after a transaction has been prepared.
     */
    @Test
    public void recoverUncomitted() throws Exception {
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        File targetFile = new File(rootDir, "targetFile");
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        FakeXid xid = new FakeXid(new BigInteger("1"), new BigInteger("2"));
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data,0, data.length, 0, xid, 23);
        xrf.setDataType(xid, (byte) 77);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        xid = new FakeXid(new BigInteger("44"), new BigInteger("2"));
        File newJournalFile = new File(rootDir, "newJournalFile");
        journalWriter = new SerialJournalWriter(newJournalFile, xid);
        xrf.beginTransaction(xid, 2, journalWriter);
        xrf.write(data, 0, data.length, 13, xid,44);

        DefaultStorage loadStorage = new DefaultStorage(targetFile, id);
        loadStorage.setNew(false);
        mdCache.clear();
        TransactionalRandomAccessFile xrfRecovered =
            loadFile(loadStorage, mdCache);

        xid = new FakeXid(new BigInteger("333"), new BigInteger("8"));
        newJournalFile = new File(rootDir, "anotherJournalFile");
        journalWriter = new SerialJournalWriter(newJournalFile, xid);
        byte[] readData = new byte[data.length];
        xrfRecovered.beginTransaction(xid, 1, journalWriter);
        xrfRecovered.read(readData, 0, data.length, 0, xid);
        assertTrue(Arrays.equals(data, readData));
    }

    /**
     * Recover file after a transaction has been prepared.
     */
    @Test
    public void recoverPrepared() throws Exception {
        RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        File targetFile = new File(rootDir, "targetFile");
        TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        FakeXid xid = new FakeXid(new BigInteger("1"), new BigInteger("2"));
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data,0, data.length, 0, xid, 23);
        xrf.setDataType(xid, (byte) 77);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        xid = new FakeXid(new BigInteger("44"), new BigInteger("2"));
        File newJournalFile = new File(rootDir, "newJournalFile");
        journalWriter = new SerialJournalWriter(newJournalFile, xid);
        xrf.beginTransaction(xid, 2, journalWriter);
        xrf.write(data, 0, data.length, 13, xid, 44);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();

        DefaultStorage loadStorage = new DefaultStorage(targetFile, id);
        loadStorage.setNew(false);

        TransactionalRandomAccessFile.Recovery xrfRecovery = TransactionalRandomAccessFile.recoverFile(loadStorage);
        JournalStreamReader journalStreamReader = new JournalStreamReader(newJournalFile);

        for (JournalEntry jentry = journalStreamReader.nextEntry(); 
            jentry != null; 
            jentry = journalStreamReader.nextEntry()) {
            xrfRecovery.mergeRecovery(jentry);
        }
        xrfRecovery.recoveryComplete();
        journalStreamReader.close();

        mdCache.clear();
        
        loadStorage = new DefaultStorage(targetFile, id);
        loadStorage.setNew(false);
        TransactionalRandomAccessFile xrfRecovered =
            loadFile(loadStorage, mdCache);

        xid = new FakeXid(new BigInteger("888"), new BigInteger("0900"));
        newJournalFile = new File(rootDir, "recoveredFileJournal");
        journalWriter = new SerialJournalWriter(newJournalFile, xid);
        byte[] readData = new byte[data.length];
        xrfRecovered.beginTransaction(xid, 1, journalWriter);
        xrfRecovered.read(readData, 0, 13, 0, xid);
        assertTrue(ArrayUtils.arrayEquals(data, 0, readData, 0, 13));
        xrfRecovered.read(readData, 0, readData.length, 13, xid);
        assertTrue(Arrays.equals(data, readData));

    }
    /**
     * Test TransactionalRandomAccessFile file with a storage object produced
     * from RandomAccessAllocator.
     * 
     * @throws Exception
     */
    @Test
    public void testTransactionalRandomAccessFileWithStorage() throws Exception {
        final int nFiles = 100;
        final int maxFilesPerDir = 10;

        FsId id = new FsId("/blah/blah");
        
        DirectoryHash forTimeSeries = new DirectoryHash(nFiles, maxFilesPerDir, rootDir);
        RandomAccessAllocator randAllocator = new RandomAccessAllocator(forTimeSeries);

        RandomAccessStorage storage= randAllocator.randomAccessStorage(id);
        TransactionalRandomAccessFile traf = 
            TransactionalRandomAccessFile.loadFile( storage, mdCache);

        byte[] data = new byte[1024 * 1024];
        Arrays.fill(data, (byte) 64);
        Xid xid = new FakeXid(3,4);
        File journalFile = new File(rootDir, "journalFile");
        JournalWriter journalWriter = new SerialJournalWriter(journalFile, xid);
        traf.beginTransaction(xid, 30, journalWriter);
        traf.write(data,0, data.length, 0, xid, 56);
        traf.acquireTransactionLock(xid);
        traf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, traf, storage);
        
        storage = randAllocator.randomAccessStorage(id);
        traf = TransactionalRandomAccessFile.loadFile(storage, mdCache);

        xid = new FakeXid(7, 4);
        journalWriter = new SerialJournalWriter(journalFile, xid);
        traf.beginTransaction(xid, 9, journalWriter);
        byte[] readData = new byte[data.length];
        traf.read(readData, 0, readData.length, 0, xid);
        assertTrue(Arrays.equals(data, readData));
    }

    @Test
    public void commitCompletedByDifferentThread() throws Exception {
        final RandomAccessStorage storage = new DefaultStorage(targetFile, id);
        final TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        final FakeXid xid = new FakeXid(1, 2);
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data, 0, data.length, 0, xid,23);
        
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        Runnable lockRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    xrf.acquireTransactionLock(xid, 0);
                } catch (Throwable t) {
                    error.set(t);
                }
            }
        };
        Thread t1 = new Thread(lockRunnable);
        t1.start();
        t1.join(1000);
        assertEquals(null, error.get());
        
        Runnable prepareRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    xrf.prepareTransaction(xid);
                } catch (Throwable t) {
                    error.set(t);
                }
            }
        };
        
        
        Thread t2 = new Thread(prepareRunnable);
        t2.start();
        t2.join(1000);
        assertEquals(null, error.get());
        
        journalWriter.close();
        
        Runnable commitRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    commitTransaction(journalFile,xid, xrf, storage);
                } catch (Throwable t) {
                    error.set(t);
                }
            }
        };
        Thread t3 = new Thread(commitRunnable);
        t3.start();
        t3.join(1000);
        assertEquals(null, error.get());
        assertFalse(xrf.hasTransactionLock(xid));
        
        byte[] read = new byte[data.length];
        final  Xid readXid = new FakeXid(2323, 333);
        xrf.beginTransaction(readXid, 30, journalWriter);
        xrf.read(read, 0, read.length, 0, readXid);
        xrf.rollbackTransaction(readXid);

        assertTrue("Read and write data must be equal.", 
            Arrays.equals(data, read));
    }
    
    @Test
    public void testExclusiveLockExclusiveness() throws Exception {
        final TransactionalRandomAccessFile xrf =
            loadFile(new DefaultStorage(targetFile, id), mdCache);
        FakeXid xid = new FakeXid(1, 2);
        xrf.beginTransaction(xid, 30, journalWriter);
        xrf.write(data,0,  data.length, 0, xid,23);
        
        xrf.acquireTransactionLock(xid, 1);
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        final AtomicBoolean done = new AtomicBoolean(false);
        final CountDownLatch start = new CountDownLatch(1);
        Runnable r = new Runnable() {
            @Override
            public void run() {
                FakeXid myXid = new FakeXid(55, 66);
                try {
                    start.countDown();
                    xrf.beginTransaction(myXid, 1, new SerialJournalWriter(new File(rootDir, myXid.toString()), myXid));
                } catch (Throwable t) {
                    error.set(t);
                } finally {
                    done.set(true);
                }
            }
        };
        
        Thread thread = new Thread(r);
        thread.start();
        start.await();
        Thread.sleep(250);
        assertEquals(null, error.get());
        assertFalse(done.get());
        
        xrf.rollbackTransaction(xid);
        thread.join();
        assertEquals(null, error.get());
        assertTrue(done.get());
    }
    
    
    /**
     * Multi Thread Read/Write
     */
    @Test
    public void mtReadWrite() throws Exception {
        final RandomAccessStorage storage =  new DefaultStorage(targetFile, id);
        final TransactionalRandomAccessFile xrf = loadFile(storage, mdCache);
        FakeXid xid = new FakeXid(33443, 44);
        xrf.beginTransaction(xid, 30, journalWriter);

        Arrays.fill(data, (byte) 0);
        xrf.write(data,0, data.length, 0, xid, 0);
        xrf.setDataType(xid, (byte) 77);
        xrf.acquireTransactionLock(xid);
        xrf.prepareTransaction(xid);
        journalWriter.close();
        commitTransaction(journalFile,xid, xrf, storage);

        final int TIME_OUT_SECS = 3;
        final int NTHREADS = 16;
        final int NITER = 128;

        final AtomicReference<Throwable> errorMessage = new AtomicReference<Throwable>();
        final CountDownLatch start = new CountDownLatch(NTHREADS);
        final CountDownLatch stop = new CountDownLatch(NTHREADS);

        for (int i = 0; i < NTHREADS; i++) {
            final int threadId = i;
           
            MtTester mtTester = new MtTester(NTHREADS, NITER, TIME_OUT_SECS, errorMessage,
                start, stop, threadId, xrf, storage);
            Thread thread = new Thread(mtTester, "mtReadWrite test thread " + i);
            thread.start();
        }

        stop.await();
        assertEquals(null, errorMessage.get());

    }
    

    private final class MtTester implements Runnable {
        
        final int NTHREADS;
        final int NITER;
        final int TIME_OUT_SECS;
        final AtomicReference<Throwable> errorMessage;
        final CountDownLatch start;
        final CountDownLatch stop;
        final int threadId;
        final TransactionalRandomAccessFile xrf;
        final RandomAccessStorage storage;
        
        public MtTester(int NTHREADS, int NITER, int TIMEOUTSECS,
            AtomicReference<Throwable> errorMessage, CountDownLatch start,
            CountDownLatch stop, int threadId, TransactionalRandomAccessFile xrf,
            RandomAccessStorage storage) {

            this.NTHREADS = NTHREADS;
            this.NITER = NITER;
            this.TIME_OUT_SECS = TIMEOUTSECS;
            this.errorMessage = errorMessage;
            this.start = start;
            this.stop = stop;
            this.xrf = xrf;
            this.threadId = threadId;
            this.storage = storage;
        }

        @Override
        public void run() {
                try {
                    start.countDown();
                    start.await();

                    for (int n = 0; n < NITER; n++) {
                        int transactionId = threadId + (n * NTHREADS);
                        Xid threadXid = new FakeXid(transactionId, 0);
                        File threadJournalFile = new File(rootDir, "thread-journal." + threadId);
                        JournalWriter threadJournal = new SerialJournalWriter(threadJournalFile, threadXid);

                        if ((threadId % 2) == 0) {
                            doWrite(xrf, TIME_OUT_SECS, threadId,
                                transactionId, threadXid, threadJournal);
                        } else {
                            doRead(xrf, TIME_OUT_SECS, threadXid,  threadJournal);
                        }

                        threadJournalFile.delete();
                    }
                } catch (Throwable t) {
                    t.printStackTrace();
                    errorMessage.compareAndSet(null, t);
                } finally {
                    stop.countDown();
                }
            }

            private void doRead(final TransactionalRandomAccessFile xrf,
                final int TIME_OUT_SECS, Xid threadXid,
                JournalWriter threadJournal) throws IOException,
                InterruptedException, AssertionError {
            	
                byte[] rdata = new byte[data.length];
                xrf.beginTransaction(threadXid, TIME_OUT_SECS,  threadJournal);
                FileMetadata meta = xrf.read(rdata, 0, rdata.length, 0, threadXid);

                xrf.rollbackTransaction(threadXid);
                threadJournal.close();
                byte filler = (byte) meta.origin.get(0).tag();
                for (int i = 0; i < rdata.length; i++) {
                    // Not using assertEquals since there is no
                    // assertEquals
                    // for byte values.
                    if (filler != rdata[i]) {
                        throw new AssertionError(
                            "data and originator must be consistent");
                    }
                }
            }

            private void doWrite(final TransactionalRandomAccessFile xrf,
                final int TIME_OUT_SECS, final int threadId,
                int transactionId, Xid threadXid,
                JournalWriter threadJournal) throws Exception {
                
                File threadJournalFile = threadJournal.file();
                
                byte filler = (byte) transactionId;
                byte[] wdata = new byte[data.length];
                Arrays.fill(wdata, (byte) filler);
                xrf.beginTransaction(threadXid, TIME_OUT_SECS, threadJournal);
                xrf.write(wdata,0, wdata.length, 0, threadXid, filler);
                switch ((threadId % 3)) {
                    case 0:
                        xrf.acquireTransactionLock(threadXid);
                        xrf.prepareTransaction(threadXid);
                        threadJournal.close();
                        commitTransaction(threadJournalFile, threadXid, xrf, storage);
                        break;
                    case 1: 
                        xrf.acquireTransactionLock(threadXid);
                        xrf.prepareTransaction(threadXid);
                        threadJournal.close();
                        xrf.rollbackTransaction(threadXid);
                        break;
                    case 2:
                        xrf.rollbackTransaction(threadXid);
                        break;
                }
            }
    }
}
