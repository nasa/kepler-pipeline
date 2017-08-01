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
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.ReadableBlob;
import gov.nasa.kepler.fs.server.WritableBlob;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.journal.ModifiedFsIdJournal;
import gov.nasa.kepler.fs.server.xfiles.TransactionalStreamFile.Recovery;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Random;
import java.util.Set;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class TransactionalStreamFileTest {
    private static final Log log = LogFactory.getLog(TransactionalStreamFileTest.class);

    private static final class XidFsIdPairComparator implements Comparator<Pair<Xid, FsId>>{

        @Override
        public int compare(Pair<Xid, FsId> o1, Pair<Xid, FsId> o2) {
            int c = XidComparator.INSTANCE.compare(o1.left, o2.left);
            if (c != 0) {
                return c;
            }
            return o1.right.compareTo(o2.right);
        }
        
    }
    
    private static final class TestJournal implements ModifiedFsIdJournal {

        private final Set<Pair<Xid, FsId >> expectedSet = 
                new ConcurrentSkipListSet<Pair<Xid, FsId>>(new XidFsIdPairComparator());
        
        @Override
        public void fileModified(Xid xid, FsId id) throws IOException {
            Pair<Xid, FsId> pair = Pair.of(xid, id);
            if (!expectedSet.contains(pair)) {
                throw new AssertionError("Unexpected pair " + pair);
            }
            expectedSet.remove(pair);
        }
        
        private void expectedModification(Xid xid, FsId id) {
            expectedSet.add(Pair.of(xid, id));
        }
        
        private void checkExpectationsWereFulfilled() {
            if (!expectedSet.isEmpty()) {
                StringBuilder bldr = new StringBuilder("Not all expectations were fulfilled: ");
                for (Pair<Xid, FsId> p : expectedSet) {
                	bldr.append(p).append(",");
                }
                throw new AssertionError(bldr.toString());
            }
        }
        
    }
    private File rootDir;
    private TestJournal mockedJournal;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        rootDir = new File(Filenames.BUILD_TEST,"TransactionalStreamFileTest");
        rootDir.mkdirs();
        mockedJournal = new TestJournal();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(rootDir);
    }

    private void addJournalExpectation(final Xid xid, final FsId id) throws IOException {
    	mockedJournal.expectedModification(xid, id);
    }
    
    private ByteBuffer newTestBuffer(boolean init) {
        ByteBuffer buf = ByteBuffer.allocateDirect(127);
        if (init) {
            for (int i = 0; i < 127; i++) {
                buf.put((byte) (i + 1));
            }
        }
        buf.position(0);
        return buf;
    }

    private void write(final TransactionalStreamFile xsFile, 
                       final ByteBuffer buf, final Xid xid, 
                       final ModifiedFsIdJournal journal)  
    throws Exception {

        addJournalExpectation(xid, xsFile.id());
        xsFile.beginTransaction(xid, 30, journal);
        WritableBlob writable = xsFile.writeBlob(xid, 23);
        writable.fileChannel.write(buf);
        writable.close();
        assertEquals((long) buf.capacity(), xsFile.length(xid));
        assertEquals(23L, xsFile.origin(xid));
        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);
        xsFile.commitTransaction(xid);
    }

    /**
     * 
     * Write something and then delete it.
     */
    @Test
    public void deleteStreamFile() throws Exception {
        File targetFile = new File(rootDir, "target");
        final FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        FakeXid xid = new FakeXid(1456, 2);
        ByteBuffer buf = newTestBuffer(true);
        write(xsFile, buf, xid, mockedJournal);
        
        final FakeXid deleteXid = new FakeXid(6,7);
        xsFile.beginTransaction(deleteXid, 30, mockedJournal);
        addJournalExpectation(deleteXid, fsId);
        xsFile.delete(deleteXid);
        
        xsFile.beginTransaction(xid, 2, mockedJournal);
        ReadableBlob readable = xsFile.readBlob(xid);
        ByteBuffer readBuf = newTestBuffer(false);
        readable.fileChannel.read(readBuf);
        readBuf.position(0);
        buf.position(0);
        readable.close();
        assertEquals(diffBuffer(buf, readBuf), buf, readBuf);
        
        xsFile.acquireTransactionLock(deleteXid);
        xsFile.prepareTransaction(deleteXid);
        xsFile.commitTransaction(deleteXid);
        
        try {
            readable = xsFile.readBlob(xid);
            assertTrue("should not have reached here.", false);
        } catch (FileStoreIdNotFoundException fsinfe) {
            //ok
        }
        
        assertFalse(targetFile.exists());
        mockedJournal.checkExpectationsWereFulfilled();
    }
    
    /**
     * Write stuff. Read that stuff back in.
     * 
     * @throws Exception
     */
    @Test
    public void writeCommit() throws Exception {
        File targetFile = new File(rootDir, "target");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        FakeXid xid = new FakeXid(1456, 2);
        ByteBuffer buf = newTestBuffer(true);
        write(xsFile, buf, xid, mockedJournal);

        FakeXid readXid = new FakeXid(245566, 3);
        xsFile.beginTransaction(readXid, 30, mockedJournal);
        ReadableBlob readable = xsFile.readBlob(readXid);
        ByteBuffer readBuf = newTestBuffer(false);
        readable.fileChannel.read(readBuf);
        readBuf.position(0);
        buf.position(0);
        readable.close();
        assertEquals(diffBuffer(buf, readBuf), buf, readBuf);
        xsFile.rollbackTransaction(readXid);
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Write stuff. Create a new transaction file object. Read that stuff from
     * the new file object.
     * 
     * @throws Exception
     */
    @Test
    public void writeCloseCommit() throws Exception {
        File targetFile = new File(rootDir, "target");
        final FsId fsId = new FsId("/stream/1");
        {
            TransactionalStreamFile xsFile = 
                TransactionalStreamFile.loadFile(targetFile, fsId);
            final FakeXid xid = new FakeXid(1, 2);
            xsFile.beginTransaction(xid, 30, mockedJournal);
            addJournalExpectation(xid, fsId);
            WritableBlob writable = xsFile.writeBlob(xid, 23);
            ByteBuffer buf = newTestBuffer(true);
            writable.fileChannel.write(buf);
            writable.close();

            xsFile.acquireTransactionLock(xid);
            xsFile.prepareTransaction(xid);
            xsFile.commitTransaction(xid);
        }

        {
            TransactionalStreamFile newXSFile = 
                TransactionalStreamFile.loadFile(targetFile, fsId);
            FakeXid readXid = new FakeXid(2, 3);
            newXSFile.beginTransaction(readXid, 30, mockedJournal);
            assertEquals(127L, newXSFile.length(readXid));
            assertEquals(23L, newXSFile.origin(readXid));
            ReadableBlob readable = newXSFile.readBlob(readXid);
            ByteBuffer readBuf = newTestBuffer(false);
            ByteBuffer realStuff = newTestBuffer(true);
            readable.fileChannel.read(readBuf);
            readBuf.position(0);
            readable.close();
            assertEquals(realStuff, readBuf);
            newXSFile.rollbackTransaction(readXid);
        }
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Write a zero length file.
     * 
     */
    @Test
    public void zeroLength() throws Exception {
        File targetFile = new File(rootDir, "target");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        FakeXid xid = new FakeXid(1, 2);
        xsFile.beginTransaction(xid, 30, mockedJournal);
        addJournalExpectation(xid, fsId);
        WritableBlob writableBlob = xsFile.writeBlob(xid, 23L);
        writableBlob.close();

        //Check that we get the dirty version that has not been committed.
        assertEquals(0L, xsFile.length(xid));
        assertEquals(23L, xsFile.origin(xid));

        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);
        xsFile.commitTransaction(xid);

        //Checked after commit.
        FakeXid readXid = new FakeXid(2, 3);
        xsFile.beginTransaction(readXid, 30, mockedJournal);
        ReadableBlob readable = xsFile.readBlob(readXid);
        ByteBuffer readBuf = newTestBuffer(false);
        readable.fileChannel.read(readBuf);
        readable.close();
        readBuf.position (0);
        assertEquals(0, readBuf.position());
        xsFile.rollbackTransaction(readXid);
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * When rollback happens the target file should not exist.
     * 
     * @throws Exception
     */
    @Test
    public void rollbackFromInit() throws Exception {
        File targetFile = new File(rootDir, "target");
        final FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        final FakeXid xid = new FakeXid(1, 2);
        xsFile.beginTransaction(xid, 30, mockedJournal);
        addJournalExpectation(xid, fsId);
        WritableBlob writable = xsFile.writeBlob(xid, 23);
        writable.close();
        assertEquals(0L, xsFile.length(xid));
        assertEquals(23L, xsFile.origin(xid));

        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);

        xsFile.rollbackTransaction(xid);
        Thread.sleep(500);
        assertFalse("target file must not exist.", targetFile.exists());
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Write a zero length file.
     */
    @Test
    public void rollbackToPreExisting() throws Exception {
        File targetFile = new File(rootDir, "target");
        FsId fsId = new FsId("/stream/1");
        {
            TransactionalStreamFile xsFile = 
                TransactionalStreamFile.loadFile(targetFile, fsId);
            final FakeXid xid = new FakeXid(1, 2);
            xsFile.beginTransaction(xid, 30, mockedJournal);
            addJournalExpectation(xid, fsId);
            WritableBlob writable = xsFile.writeBlob(xid, 23);
            writable.close();
            xsFile.acquireTransactionLock(xid);
            xsFile.prepareTransaction(xid);

            xsFile.commitTransaction(xid);
        }

        {
            TransactionalStreamFile xsFile = 
                TransactionalStreamFile.loadFile(targetFile, fsId);
            FakeXid xid = new FakeXid(1, 2);
            xsFile.beginTransaction(xid, 30, mockedJournal);
            addJournalExpectation(xid, fsId);
            WritableBlob writable = xsFile.writeBlob(xid, 42);
            writable.fileChannel.write(newTestBuffer(true));
            writable.close();
            xsFile.acquireTransactionLock(xid);
            xsFile.prepareTransaction(xid);

            xsFile.rollbackTransaction(xid);

            xid = new FakeXid(4, 5);
            xsFile.beginTransaction(xid, 30, mockedJournal);
            ReadableBlob readable = xsFile.readBlob(xid);
            ByteBuffer readBuf = newTestBuffer(false);
            readable.fileChannel.read(readBuf);
            readable.close();
            assertEquals(0, readBuf.position());
            assertEquals(23L, xsFile.origin(xid));
            assertEquals(0L, xsFile.length(xid));

            xsFile.rollbackTransaction(xid);
        }
        mockedJournal.checkExpectationsWereFulfilled();

    }

    @Test
    public void truncateData() throws Exception {
        File targetFile = new File(rootDir, "target");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        FakeXid xid = new FakeXid(1, 2);
        xsFile.beginTransaction(xid, 30, mockedJournal);
        addJournalExpectation(xid, fsId);
        WritableBlob writable = xsFile.writeBlob(xid, 23);
        writable.fileChannel.write(newTestBuffer(true));
        writable.close();

        assertEquals(127L, xsFile.length(xid));
        assertEquals(23L, xsFile.origin(xid));

        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);
        xsFile.commitTransaction(xid);

        zeroLength();
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Recover from a new prepared state.
     */
    @Test
    public void recoverNewPrepaired() throws Exception {
        File targetFile = new File(rootDir, "recoverClean");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        Xid xid = new FakeXid(44445, 443);
        ByteBuffer buf = newTestBuffer(true);
        xsFile.beginTransaction(xid, 30, mockedJournal);
        addJournalExpectation(xid, fsId);
        WritableBlob writable = xsFile.writeBlob(xid, 23);
        writable.fileChannel.write(buf);
        writable.close();
        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);

        
        Recovery recovery = TransactionalStreamFile.recover(targetFile, fsId);
        recovery.mergeRecovery(xid, false);
        recovery.completeRecovery();
        
        assertFalse("File should not exist.", targetFile.exists());
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Recover from a prepared state.
     */
    @Test
    public void recoverPrepaired() throws Exception {
        File targetFile = new File(rootDir, "recoverClean");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        Xid xid = new FakeXid(44445, 443);
        ByteBuffer buf = newTestBuffer(true);
        write(xsFile, buf, xid, mockedJournal);

        xid = new FakeXid(2, 0);
        buf.position(0);
        fillBuffer(buf, (byte) 4);

        xsFile.beginTransaction(xid, 30, mockedJournal);
        addJournalExpectation(xid, fsId);
        WritableBlob writable = xsFile.writeBlob(xid, 23);
        writable.fileChannel.write(buf);
        writable.close();
        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);

        Recovery recovery = TransactionalStreamFile.recover(targetFile, fsId);
        recovery.mergeRecovery(xid, false);
        recovery.completeRecovery();

        TransactionalStreamFile recoveredFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        assertTrue("File should  exist.", targetFile.exists());

        buf = newTestBuffer(true);
        ByteBuffer recoveredBuf = newTestBuffer(false);
        xid = new FakeXid(7, 11);
        recoveredFile.beginTransaction(xid, 0, mockedJournal);
        ReadableBlob readable = recoveredFile.readBlob(xid);
        readable.fileChannel.read(recoveredBuf);
        readable.close();
        recoveredBuf.position(0);
        assertEquals(diffBuffer(buf, recoveredBuf), buf, recoveredBuf);
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Check that we can recover from multiple transactions where we
     * recover non-committing transactions first.
     * @throws Exception
     */
    @Test
    public void recoverMultiple() throws Exception {
        File targetFile = new File(rootDir, "recoverClean");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        Xid xid = new FakeXid(44445, 443);
        xsFile.beginTransaction(xid, 1, mockedJournal);
        ByteBuffer buf = newTestBuffer(true);
        addJournalExpectation(xid, fsId);
        WritableBlob writeBlob = xsFile.writeBlob(xid, 99990L);
        writeBlob.fileChannel.write(buf);
        writeBlob.close(); 

        Xid xid2 = new FakeXid(234234, 93);
        xsFile.beginTransaction(xid2, 1, mockedJournal);
        addJournalExpectation(xid2, fsId);
        ByteBuffer buf2 = newTestBuffer(false);
        fillBuffer(buf2, (byte) -7);
        writeBlob = xsFile.writeBlob(xid2, 333);
        writeBlob.fileChannel.write(buf2);
        writeBlob.close();
        xsFile.acquireTransactionLock(xid);
        xsFile.prepareTransaction(xid);
        
        Recovery recovery = TransactionalStreamFile.recover(targetFile, fsId);
        recovery.mergeRecovery(xid2, false);
        recovery.completeRecovery();
        
        recovery.mergeRecovery(xid, true);
        recovery.completeRecovery();
        
        //Make sure the correct transaction was committed
        TransactionalStreamFile reloaded = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        Xid xidReload = new FakeXid(333, 333);
        reloaded.beginTransaction(xidReload, 1, mockedJournal);
        ReadableBlob readBlob = reloaded.readBlob(xidReload);
        ByteBuffer reloadedBuf = newTestBuffer(false);
        readBlob.fileChannel.read(reloadedBuf);
        buf.position(0);
        reloadedBuf.position(0);
        assertEquals(diffBuffer(buf, reloadedBuf), buf, reloadedBuf);
        
        //Make sure transaction files have been removed.
        File transactionDirectory = 
            TransactionalStreamFile.transactionDirectory(targetFile, fsId);
        assertFalse("Transaction directory should have been deleted.", transactionDirectory.exists());
        mockedJournal.checkExpectationsWereFulfilled();
    }

    /**
     * Create an initial file. Create multiple readers and writers.
     * 
     * @throws Exception
     */
    @Test
    public void multipleWriters() throws Exception {
        List<Thread> threads = new ArrayList<Thread>();
        final File targetFile = new File(rootDir, "target");
        final FsId fsId = new FsId("/stream/1");
        final Random rand = new Random(23);
        final boolean[] threadOK = new boolean[4];
        final TransactionalStreamFile xsFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        Xid initXid = new FakeXid(44445,443);
        ByteBuffer initBuf = newTestBuffer(false);
        fillBuffer(initBuf, (byte) 23);
        write(xsFile, initBuf, initXid, mockedJournal);

        final AtomicBoolean writeFirst = new AtomicBoolean(true);
        final AtomicInteger readCounter = new AtomicInteger(0);
        final int lockTimeOutSecs = 10;  //we blow past the 5s mark on occasion
        
        for (int i = 0; i < threadOK.length; i++) {
            final int index = i;

            Runnable r = new Runnable() {

                public void run() {
                    try {

                        Thread.sleep(rand.nextInt(3));
                        FakeXid xid = new FakeXid(index, 2);
                        xsFile.beginTransaction(xid, lockTimeOutSecs, mockedJournal);

                        if ((index % 2) == 0 || writeFirst.getAndSet(false)) {
                            addJournalExpectation(xid, fsId);
                            // write
                            WritableBlob writable = 
                                xsFile.writeBlob(xid, index + 1); 
                            ByteBuffer buf = newTestBuffer(false);
                            fillBuffer(buf, (byte) (index + 1));
                            writable.fileChannel.write(buf);
                            writable.close();
                            assertEquals(127L, xsFile.length(xid));
                            assertEquals((long) (index + 1), xsFile.origin(xid));

                            xsFile.acquireTransactionLock(xid);
                            xsFile.prepareTransaction(xid);

                            xsFile.commitTransaction(xid);
                        } else {
                            // read
                            ByteBuffer buf = newTestBuffer(false);
                            xsFile.acquireReadLock(xid, lockTimeOutSecs);
                            long origin = -1;
                            try {
                                ReadableBlob readable = xsFile.readBlob(xid);
                                readable.fileChannel.read(buf);
                                readable.close();
                                origin = xsFile.origin(xid);
                                assertEquals(127L, xsFile.length(xid));
                            } finally {
                                xsFile.releaseReadLock(xid);
                            }

                            xsFile.rollbackTransaction(xid);

                            buf.position(0);
                            ByteBuffer testValue = newTestBuffer(false);
                            fillBuffer(testValue, (byte) origin);
                            assertEquals(diffBuffer(testValue, buf), testValue, buf);
                        }
                        readCounter.incrementAndGet();
                        threadOK[index] = true;
                    } catch (Exception x) {
                        error.compareAndSet(null, x);
                        log.error("In thread.", x);
                        x.printStackTrace();
                        throw new IllegalStateException(x);
                    }
                }
            };

            threads.add(new Thread(r));
            threads.get(i).start();

        }

        for (Thread t : threads) {
            t.join();
        }

        log.info("Reads ok:" + readCounter);
        for (boolean ok : threadOK) {
             if (!ok) {
                 AssertionError ae = new AssertionError("A thread was not successful with writing.");
                 ae.initCause(error.get());
                 throw ae;
             }
        }

        TransactionalStreamFile readFile = 
            TransactionalStreamFile.loadFile(targetFile, fsId);
        FakeXid readXid = new FakeXid(324,2);
        readFile.beginTransaction(readXid, 30, mockedJournal);
        ReadableBlob readable = readFile.readBlob(readXid);
        ByteBuffer buf = newTestBuffer(false);
        readable.fileChannel.read(buf);
        readable.close();

        long origin = readFile.origin(readXid);
        assertEquals(127L, readFile.length(readXid));
        buf.position(0);
        ByteBuffer testValue = newTestBuffer(false);
        fillBuffer(testValue, (byte) origin);
        assertEquals(diffBuffer(testValue, buf), testValue, buf);
        mockedJournal.checkExpectationsWereFulfilled();

    }

    /**
     * Commit a transaction that does not make any modifications.
     * @throws Exception
     */
    @Test
    public void readOnly() throws Exception {
        File sfile = new File(this.rootDir, "sfile");
        FsId fsId = new FsId("/stream/1");
        TransactionalStreamFile xstream =
            TransactionalStreamFile.loadFile(sfile, fsId);
        FakeXid xid = new FakeXid(72, 0);
        ByteBuffer obuf = newTestBuffer(true);
        write(xstream, obuf, xid, mockedJournal);

        xstream = TransactionalStreamFile.loadFile(sfile, fsId);
        xid = new FakeXid(73, 0);
        xstream.beginTransaction(xid, 0, mockedJournal);
        ReadableBlob rchannel = xstream.readBlob(xid);
        ByteBuffer rbuf = newTestBuffer(false);
        rchannel.fileChannel.read(rbuf);
        rbuf.position(0);
        obuf.position(0);
        assertEquals(diffBuffer(obuf, rbuf), obuf, rbuf);
        rchannel.close();
        xstream.acquireTransactionLock(xid);
        xstream.prepareTransaction(xid);
        xstream.commitTransaction(xid);
        mockedJournal.checkExpectationsWereFulfilled();
    }

    private void fillBuffer(ByteBuffer byteBuffer, byte fillValue) {
        for (int i = 0; i < byteBuffer.capacity(); i++) {
            byteBuffer.put(fillValue);
        }
        byteBuffer.position(0);
    }

    private String diffBuffer(ByteBuffer a, ByteBuffer b) {
        if (a.position() != b.position()) {
            return "positions not equal.";
        }

        if (a.capacity() != b.capacity()) {
            return "capacity not equal.";
        }

        for (int i = 0; i < b.capacity(); i++) {
            byte abyte = a.get();
            byte bbyte = b.get();
            if (abyte != bbyte) {
                return "" + abyte + " != " + bbyte + " at pos " + i;
            }
        }

        return null;
    }
}
