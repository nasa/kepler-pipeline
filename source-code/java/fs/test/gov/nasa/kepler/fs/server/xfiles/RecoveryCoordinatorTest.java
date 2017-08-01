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
import static gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFileTest.commitTransaction;
import static gov.nasa.kepler.fs.server.xfiles.TransactionalMjdTimeSeriesTest.commitTransaction;

import static org.junit.Assert.*;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.server.*;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.journal.SerialJournalWriter;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.io.FileFilter;
import java.io.IOException;
import java.math.BigInteger;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.*;

import javax.transaction.xa.Xid;

import junit.framework.AssertionFailedError;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;


/**
 * @author Sean McCauliff
 * 
 */
public class RecoveryCoordinatorTest {

    private final static File testRoot = 
        new File(Filenames.BUILD_TEST,  "RecoveryCoordinator.test");
    
    private final static File logDir = new File(testRoot, "logDir");
    private final static File fileRoot = new File(testRoot, "fileRoot");
    private final static File orderFile = new File(testRoot, "order.seq");
    private final static File tsFileRoot = new File(fileRoot, "ts");
    private final static File blobFileRoot = new File(fileRoot, "blob");
    private final static File rayFileRoot = new File(fileRoot, "mjd");
    
    private RandomAccessAllocatorFactory tsStorageAllocatorFactory;
    private DirectoryHashFactory blobDirHashFactory;
    private MjdTimeSeriesStorageAllocatorFactory rayAllocatorFactory;
    
    private int xidSequence = 1;
    private final Map<FsId, TransactionalFile> xFiles = new HashMap<FsId, TransactionalFile>();
    
    private CommitOrderIdGenerator orderGenerator;
;
    
    private FsIdFileSystemLocator pathLocator;
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        FileUtil.cleanDir(testRoot);
        FileUtil.mkdirs(logDir);
        FileUtil.mkdirs(tsFileRoot);
        FileUtil.mkdirs(blobFileRoot);
        FileUtil.mkdirs(rayFileRoot);
        
        orderGenerator = new CommitOrderIdGeneratorImpl(orderFile);
        File pathConfig = new File(fileRoot, "fileSystemConfig.xml");
        pathLocator = new UserConfigurableFsIdFileSystemLocator(pathConfig, fileRoot.getCanonicalPath());
        
        newAllocatorFactories();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }

    private void newAllocatorFactories() {
        
        DirectoryHashFactory forTimeSeries = 
            new DirectoryHashFactory(pathLocator, tsFileRoot, 64, 8);
        DirectoryHashFactory forCosmicRay = 
            new DirectoryHashFactory(pathLocator, rayFileRoot, 64, 8);
        
        tsStorageAllocatorFactory = new RandomAccessAllocatorFactory(forTimeSeries);
        blobDirHashFactory = new DirectoryHashFactory(pathLocator, blobFileRoot, 64, 8);
        rayAllocatorFactory = new MjdTimeSeriesStorageAllocatorFactory(forCosmicRay);
        
        xFiles.clear();
    }

    /**
     * No files to recover.
     * 
     */
    @Test
    public void recoverFromNothing() throws Exception {
        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        List<XidStatus> status = startup.recover();
        assertEquals(0, status.size());
    }

    /**
     * No files to recover, but they where once in use.
     * 
     */
    @Test
    public void recoverFromClean() throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory, 
            orderGenerator);
        
        FsId id = new FsId("/recoverFromClean/target");

        FakeXid xid = new FakeXid(new BigInteger("" + xidSequence++),
            new BigInteger("0"));
        coord.beginTransaction(xid, true);

        TransactionalRandomAccessFile[] xraf =
            writeStuffIntoTraf(coord, xid,  new FsId[] { id }, (byte)1);

        coord.prepare(xid);
        for (TransactionalRandomAccessFile xfile : xraf) {
            xfile.acquireTransactionLock(xid);
            xfile.prepareTransaction(xid);
        }
        coord.completeTransaction(xid);

        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        List<XidStatus> status = startup.recover();
        assertEquals(0, status.size());
        checkJournals();

    }

    /**
     * Write some data into TransactionalFiles then recover.  This should
     * restore everything back to the empty state.
     * 
     */
    @Test
    public void recoverNonCommit() throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);

        FsId targetId = new FsId("/recoverNonCommit/target");

        FakeXid xid = new FakeXid(xidSequence++, 0);
        coord.beginTransaction(xid, true);

        //Create TransactionalRandomAccessFile
        RandomAccessAllocator tsAllocator =  
            tsStorageAllocatorFactory.findAllocator(targetId, true, true);
        
        RandomAccessStorage storage = tsAllocator.randomAccessStorage(targetId);
        TransactionalRandomAccessFileMetadataCache mdCache =
        		new TransactionalRandomAccessFileMetadataCache();
        TransactionalRandomAccessFile xraf = 
            TransactionalRandomAccessFile.loadFile(storage, mdCache);
        JournalWriter journalWriter = coord.journalWriter(xid);
        coord.addRandomAccess(targetId, xid);
        xraf.beginTransaction(xid, 0, journalWriter);
        xraf.write(new byte[] { (byte) 0 }, 0 ,1, 0, xid, 45);

        tsAllocator.close();

        //Create cosmic ray file.
        FsId ray1 = new FsId("/death/ray");
        writeSomeRays(xid, coord, new FsId[] { ray1 }, 23.0f);
        
        //Create stream file.
        FsId blobId = new FsId("/beware/of/the/blob");
        FsId deleteBlob = new FsId("/beware/of/the/delete");
        TransactionalStreamFile[] xStream = 
            writeStuffIntoBlobs(xid, coord, new FsId[] { blobId, deleteBlob }, (byte) 1);
        xStream[1].delete(xid);
        
        newAllocatorFactories();

        //Recovery
        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        List<XidStatus> status = startup.recover();
        assertEquals(1, status.size());
        assertTrue("Must be XA transaction.", status.get(0).isXa);
        assertFalse("Must not be comitting.", status.get(0).wasPrepared);
        assertEquals(XidStatus.State.ROLLBACK, status.get(0).state);
        assertEquals(0, XidComparator.INSTANCE.compare(xid, status.get(0).xid));
        assertEquals(0, startup.staleXaTransactions().size());
        
        assertFalse(tsStorageAllocatorFactory.findAllocator(targetId).hasSeries(targetId));
        assertFalse( blobDirHashFactory.findDirHash(blobId).idToFile(blobId.name()).exists());
        assertFalse( blobDirHashFactory.findDirHash(blobId).idToFile(deleteBlob.name()).exists());
        assertFalse(rayAllocatorFactory.findAllocator(ray1, false).hasSeries(ray1));
        
        checkJournals();

    }

    /**
     * Transaction has reached prepared state, but files have not
     * been prepared.
     */
    @Test
    public void recoverComittingRecoverRollback() throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);
        
        FsId targetId = new FsId("/blah/target");

        FakeXid xid = new FakeXid(xidSequence++, 0);
        String xidFileName = Util.xidToString(xid);
        coord.beginTransaction(xid, false);

        //Write to random access file
        RandomAccessAllocator tsAllocator =  (RandomAccessAllocator)
            tsStorageAllocatorFactory.findAllocator( targetId, true, true);
        RandomAccessStorage storage = tsAllocator.randomAccessStorage(targetId);

        TransactionalRandomAccessFileMetadataCache mdCache = 
        		new TransactionalRandomAccessFileMetadataCache();
        TransactionalRandomAccessFile xraf = 
            TransactionalRandomAccessFile.loadFile(storage, mdCache);
        JournalWriter journalWriter = coord.journalWriter(xid);
        coord.addRandomAccess(targetId, xid);
        xraf.beginTransaction(xid, 0, journalWriter);
        xraf.write(new byte[] { (byte) 0 }, 0, 1, 0, xid,  45);

        //Blob stuff
        FsId blobId = new FsId("/blah/blah/blah");
        FsId deleteBlob = new FsId("/blah/blah/deleteme");
        TransactionalStreamFile[] xStream = 
            writeStuffIntoBlobs(xid, coord, new FsId[] { blobId, deleteBlob} , (byte) 1);
        xStream[1].delete(xid);
        
        //CosmicRay
        FsId cosmicId = new FsId("/death/ray");
        writeSomeRays(xid, coord, new FsId[] { cosmicId}, 66.6f);
        
        coord.prepare(xid);

        tsAllocator.close();
        
        newAllocatorFactories();
        
        //Recover
        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        List<XidStatus> status = startup.recover();
        assertEquals(1, status.size());
        assertFalse("Must not be XA transaction.", status.get(0).isXa);
        assertTrue("Must be committing.", status.get(0).wasPrepared);
        assertEquals(XidStatus.State.ROLLBACK, status.get(0).state);
        assertEquals(0, XidComparator.INSTANCE.compare(xid, status.get(0).xid));

        assertFalse(tsStorageAllocatorFactory.findAllocator(targetId).hasSeries(targetId));
        assertFalse(blobDirHashFactory.findDirHash(blobId).idToFile(blobId.name()).exists());
        assertFalse(blobDirHashFactory.findDirHash(blobId).idToFile(deleteBlob.name()).exists());
        assertFalse(rayAllocatorFactory.findAllocator(cosmicId, false).hasSeries(cosmicId));
        
        File transactionLogFile = new File(logDir, xidFileName);
        assertFalse(transactionLogFile.exists());
        checkJournals();
    }

    /**
     * Recover committing file, where at least one of the files has not been
     * committed, but at least one has.
     */
    @Test
    public void recoverCommitting() throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);
        
        FsId id1 = new FsId("/targets/target1");
        FsId id2 = new FsId("/targets/target2");

        FakeXid xid = new FakeXid(xidSequence++,0);
        coord.beginTransaction(xid, false);
        File journalFile = coord.journalWriter(xid).file();
        File mjdJournalFile = coord.mjdJournalWriter(xid).file();

        //TransactionalRandomAccessFile
        TransactionalRandomAccessFile[] xraf = 
            writeStuffIntoTraf(coord, xid,   new FsId[] { id1, id2 }, (byte)1);
        
        //TransactionalStreamFile
        FsId blob1 = new FsId("/blob/1");
        FsId blob2 = new FsId("/blob/2");
        FsId blobDelete = new FsId("/blob/deleteMe");
        
        TransactionalStreamFile[] xStream =
            writeStuffIntoBlobs(xid, coord, new FsId[] { blob1, blob2, blobDelete} , (byte)1);
        
        xStream[2].delete(xid);
        
        //CosmicRay
        FsId ray1 = new FsId("/ray/1");
        FsId ray2 = new FsId("/ray/2");
        
        TransactionalMjdTimeSeriesFile[] xRays = 
            writeSomeRays(xid, coord, new FsId[] { ray1, ray2}, 67.1f);
        
        //Prepare all commit some.
        coord.prepare(xid);
        prepareAll(xid, xraf);
        prepareAll(xid, xStream);
        prepareAll(xid, xRays);
        
        coord.commit(xid);
        xStream[0].commitTransaction(xid);
        xStream[2].commitTransaction(xid);
        
        RandomAccessAllocator tsAllocator = 
                (RandomAccessAllocator) tsStorageAllocatorFactory.findAllocator(id1);
            MjdTimeSeriesStorageAllocator mjdAllocator =
                (MjdTimeSeriesStorageAllocator) rayAllocatorFactory.findAllocator(ray1, false);
            
        commitTransaction(journalFile, xid, xraf[0], tsAllocator.randomAccessStorage(xraf[0].id(), false));
        //xraf[0].commitTransaction(xid);
        commitTransaction(xid, mjdJournalFile, xRays[0], mjdAllocator.randomAccessStorage(xRays[0].id(), false));
        
        //xRays[0].commitTransaction(xid);
        
      
        
        tsAllocator.markIdsPersistent(Collections.singleton(id1));
        mjdAllocator.markIdsPersistent(Collections.singleton(ray1));

        tsAllocator.close();
        
        newAllocatorFactories();
        
        //Recover
        RecoveryStartup startup = 
            new RecoveryStartup(logDir, blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        List<XidStatus> status = startup.recover();
        assertEquals(1, status.size());
        assertEquals(XidStatus.State.COMMITTED, status.get(0).state);
        assertEquals(0, XidComparator.INSTANCE.compare(xid, status.get(0).xid));
        
        RandomAccessAllocator dirHashRecovered = 
            (RandomAccessAllocator) tsStorageAllocatorFactory.findAllocator(id1);
        
        assertTrue("Id must exist.", dirHashRecovered.hasSeries(id1));
        assertTrue("Id must exist.",dirHashRecovered.hasSeries(id2));
        
        assertSame(dirHashRecovered, tsStorageAllocatorFactory.findAllocator(id2));
        
        assertTrue(blobDirHashFactory.findDirHash(blob1).idToFile(blob1.name()).exists());
        assertTrue(blobDirHashFactory.findDirHash(blob2).idToFile(blob2.name()).exists());
        assertFalse(blobDirHashFactory.findDirHash(blobDelete).idToFile(blobDelete.name()).exists());
        assertTrue(rayAllocatorFactory.findAllocator(ray1, false).hasSeries(ray1));
        assertTrue(rayAllocatorFactory.findAllocator(ray2, false).hasSeries(ray2));
        checkJournals();
        
    }

    /**
     * Recover files that have been involved in more than one transaction. But
     * only one transaction was committing.
     * 
     * Note that the deleteMe locals are here to be deleted by the recovery,
     * they where not involved in the committing transaction.
     */
    @Test
    public void recoverCommittingMultiTransaction() throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);
        
        FsId id1 = new FsId("/recoverCommittingMultiTransaction/id1");
        FsId id2 = new FsId("/recoverCommittingMultiTransaction/id2");
        FsId idDeleteMe = new FsId("/recoverCommittingMultiTransaction/deleteme");

        FakeXid commitingXid = new FakeXid(xidSequence++,0);
        FakeXid xid2 = new FakeXid(xidSequence++,0);
        
        //Begin/write transaction
        coord.beginTransaction(commitingXid, false);
        coord.beginTransaction(xid2, false);

        FsId[] targetIds = new FsId[] { id1, id2 };
        TransactionalRandomAccessFile[] xraf = 
            writeStuffIntoTraf(coord, commitingXid,  targetIds, (byte)1);

        FsId blob1 = new FsId("/blob/1");
        FsId blob2 = new FsId("/blob/2");
        FsId blobDeleteme = new FsId("/blob/deleteme");
        
        TransactionalStreamFile[] xStream =
            writeStuffIntoBlobs(commitingXid, coord, new FsId[] { blob1, blob2}, (byte) 1);
        
        FsId ray1 = new FsId("/ray/1");
        FsId ray2 = new FsId("/ray/2");
        FsId rayDeleteMe = new FsId("/ray/deleteMe");
        TransactionalMjdTimeSeriesFile[] xRays = 
            writeSomeRays(commitingXid, coord, new FsId[] { ray1, ray2}, 77.3f);
        
        //Write stuff into the other transaction
        FsId[] rollbackIds = new FsId[] { id1, id2, idDeleteMe };
        writeStuffIntoTraf(coord, xid2, rollbackIds, (byte) 2);
        writeStuffIntoBlobs(xid2, coord, new FsId[] { blob1, blob2, blobDeleteme}, (byte) 2);
        writeSomeRays(xid2, coord, new FsId[] { id1, id2, rayDeleteMe}, 2.0f);
        
        xStream[1].delete(xid2);
        
        //Prepare Reached for Transaction committing
        coord.prepare(commitingXid);
        
        
        prepareAll(commitingXid, xStream);
        prepareAll(commitingXid, xraf);
        prepareAll(commitingXid, xRays);

        RandomAccessAllocator randAlloc = tsStorageAllocatorFactory.findAllocator(xraf[0].id());
        Set<FsId> xrafIds = new HashSet<FsId>();
        for (TransactionalRandomAccessFile x : xraf) {
            xrafIds.add(x.id());
        }
        randAlloc.markIdsPersistent(xrafIds);
        
        MjdTimeSeriesStorageAllocator mjdAlloc = 
            rayAllocatorFactory.findAllocator(xRays[0].id(), false);
        Set<FsId> xRayIds = new HashSet<FsId>();
        for (TransactionalMjdTimeSeriesFile x : xRays) {
            xRayIds.add(x.id());
        }
        mjdAlloc.markIdsPersistent(xRayIds);
        
        coord.commit(commitingXid);
        xraf[0].commitTransaction(commitingXid);
        xStream[0].commitTransaction(commitingXid);
        xRays[0].commitTransaction(commitingXid);

        // At this point id1 would have been written with committed data
        // id2 will be in committed state, but no data has been written.
        // idDeleteMe will not be committed and should be deleted.

        newAllocatorFactories();

        //Recover
        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        List<XidStatus> status = startup.recover();
        assertEquals(2, status.size());

        XidStatus commitingStatus = findXidStatus(commitingXid, status);

        assertEquals(XidStatus.State.COMMITTED, commitingStatus.state);
        RandomAccessAllocator dirHash = 
            (RandomAccessAllocator) tsStorageAllocatorFactory.findAllocator(id1);

        // check that recovery stuff that should still be there is there and
        // stuff that should have been deleted has been deleted.
        assertTrue("Id must exist.", dirHash.hasSeries(id1));
        assertTrue("Id must exist.", dirHash.hasSeries(id2));
        assertFalse("Id must not exist", dirHash.hasSeries(idDeleteMe));
        assertSame(dirHash, tsStorageAllocatorFactory.findAllocator(id2));

        XidStatus nonCommittingStatus = findXidStatus(xid2, status);
        assertEquals(XidStatus.State.ROLLBACK, nonCommittingStatus.state);

        
        // Check that the data is consistent.
        Xid readXid = new FakeXid(8888, 99);
        RandomAccessStorage xid2Storage = dirHash.randomAccessStorage(id2);
        ConcurrentLruCache.clearAllCaches();
        TransactionalRandomAccessFileMetadataCache mdCache =
        		new TransactionalRandomAccessFileMetadataCache();
        TransactionalRandomAccessFile id2File = loadFile(xid2Storage, mdCache);
        byte[] readBuf = new byte[1];
        id2File.beginTransaction(readXid, 2, new SerialJournalWriter(new File(
            fileRoot, "read.journal"), readXid));
        id2File.read(readBuf, 0, 1, 0, readXid);
        assertEquals((byte) 1, readBuf[0]);
        
        assertTrue(blobDirHashFactory.findDirHash(blob1).idToFile(blob1.name()).exists());
        assertTrue(blobDirHashFactory.findDirHash(blob2).idToFile(blob2.name()).exists());
        assertFalse(blobDirHashFactory.findDirHash(blobDeleteme).idToFile(blobDeleteme.name()).exists());
        
        assertTrue(rayAllocatorFactory.findAllocator(ray1, false).hasSeries(ray1));
        assertTrue(rayAllocatorFactory.findAllocator(ray2, false).hasSeries(ray2));
        assertFalse(rayAllocatorFactory.findAllocator(rayDeleteMe, false).hasSeries(rayDeleteMe));
        
        //Check data consistency
        File readStreamFile =
            blobDirHashFactory.findDirHash(blob1).idToFile(blob1.name());
        TransactionalStreamFile readXStream =
            TransactionalStreamFile.loadFile(readStreamFile, blob1);
        readXStream.beginTransaction(readXid, 2, coord);
        ReadableBlob rBlob = readXStream.readBlob(readXid);
        ByteBuffer readByteBuffer = ByteBuffer.allocate(1024);
        rBlob.fileChannel.read(readByteBuffer);
        readByteBuffer.position(0);
        for (int i=0; i < readByteBuffer.capacity(); i++) {
            if (readByteBuffer.get() != (byte) 1) {
                throw new AssertionFailedError("buffer does not compare");
            }
        }
        
        checkJournals();
    }
    
    /**
     * Tests various corner cases when explicit delete of files are involved.
     */
    @Test
    public void explicitDeleteRecoveryFromPrepare() throws Exception {
        explicitDeleteRecovery(false);
    }
    
    @Test
    public void explicitDeleteRecoveryFromCommit() throws Exception {
        explicitDeleteRecovery(true);
    }
    
    private void explicitDeleteRecovery(boolean doCommit) throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);

        //write some initial data.
        FakeXid xid = new FakeXid(xidSequence++,0);
        
        coord.beginTransaction(xid, false);
        FsId blobId = new FsId("/blob/1");
        TransactionalStreamFile streamFile = 
            writeStuffIntoBlobs(xid, coord, new FsId[] { blobId}, (byte) 0x87)[0];
        
        FsId tsId = new FsId("/time.series/1");
        TransactionalRandomAccessFile randFile = 
            writeStuffIntoTraf(coord, xid, new FsId[] { tsId}, (byte) 0x77)[0];
        
        FsId mjdId = new FsId("/mjd.time.series/1");
        TransactionalMjdTimeSeriesFile mjdFile = 
            writeSomeRays(xid, coord, new FsId[] { mjdId} ,23.42f)[0];
        
        
        coord.prepare(xid);
        streamFile.acquireTransactionLock(xid);
        streamFile.prepareTransaction(xid);
        randFile.acquireTransactionLock(xid);
        randFile.prepareTransaction(xid);
        mjdFile.acquireTransactionLock(xid);
        mjdFile.prepareTransaction(xid);
        coord.commit(xid);
        streamFile.commitTransaction(xid);
        randFile.commitTransaction(xid);
        mjdFile.commitTransaction(xid);
        coord.completeTransaction(xid);
        
        xid = new FakeXid(xidSequence++, 0);
        
        coord.beginTransaction(xid, false);
        JournalWriter trafWriter = coord.journalWriter(xid);
        JournalWriter mjdWriter = coord.mjdJournalWriter(xid);
        
        streamFile.beginTransaction(xid, 20, coord);
        
        coord.addRandomAccess(randFile.id(), xid);
        randFile.beginTransaction(xid, 20, trafWriter);
        
        coord.addMjdFile(mjdId, xid);
        mjdFile.beginTransaction(xid, mjdWriter, 20);
        
        streamFile.delete(xid);
        randFile.delete(xid);
        mjdFile.delete(xid);
        coord.prepare(xid);
        randFile.acquireTransactionLock(xid);
        randFile.prepareTransaction(xid);
        streamFile.acquireTransactionLock(xid);
        streamFile.prepareTransaction(xid);
        mjdFile.acquireTransactionLock(xid);
        mjdFile.prepareTransaction(xid);
        
        if (doCommit) {
            coord.commit(xid);
        }
       
        ///Crash
        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        startup.recover();
        
        DirectoryHash dirHash = blobDirHashFactory.findDirHash(blobId, true, false);
        File recoveredFile = dirHash.idToFile(blobId.name());
        
        if (doCommit) {
            assertFalse(recoveredFile.exists());
            
            assertFalse(tsStorageAllocatorFactory.findAllocator(tsId).isAllocated(tsId));
            assertFalse(rayAllocatorFactory.findAllocator(mjdId, false).isAllocated(mjdId));
        } else {
            assertTrue(recoveredFile.exists());
            
            assertTrue(tsStorageAllocatorFactory.findAllocator(tsId).isAllocated(tsId));
            assertTrue(rayAllocatorFactory.findAllocator(mjdId, false).isAllocated(mjdId));
        }

    }

    /**
     * commitTransaction where no files involved.
     * 
     * @param xid
     * @param status
     * @return
     * @throws Exception
     */
    @Test
    public void emptyTransaction() throws Exception {
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);
        FakeXid xid = new FakeXid(new BigInteger("" + xidSequence++),
            new BigInteger("0"));
        coord.beginTransaction(xid, true);
        coord.prepare(xid);
        coord.commit(xid);

        try {
            FsId id = new FsId("/test/b0gus");
            coord.addRandomAccess(id, xid);
            assertFalse("Exception should have been thrown.", false);
        } catch (IllegalArgumentException ok) {
            // OK
        }
    }

    /**
     * Commit an XA transaction where there should have been an an XA status
     * left around that we care about.
     */
    @Test
    public void xaKeepState() throws Exception {
        FsId targetId = new FsId("/blah/blah");
        RecoveryCoordinator coord = new RecoveryCoordinator(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory,
            orderGenerator);
        
        Xid xid = new FakeXid(new BigInteger("" + xidSequence++),
            new BigInteger("0"));
        coord.beginTransaction(xid, true);

        TransactionalRandomAccessFile[] xraf =
            writeStuffIntoTraf(coord, xid,  new FsId[] { targetId }, (byte)1);
		
		coord.prepare(xid);
        prepareAll(xid, xraf);
        
        newAllocatorFactories();

        RecoveryStartup startup = new RecoveryStartup(logDir,
            blobDirHashFactory, tsStorageAllocatorFactory, rayAllocatorFactory);
        startup.recover();
        assertEquals(1, startup.staleXaTransactions().size());
        XidStatus status = startup.staleXaTransactions().get(0);

        assertEquals(0, XidComparator.INSTANCE.compare(xid, status.xid));
        assertEquals(XidStatus.State.ROLLBACK, status.state);
        assertTrue(status.isXa);
        assertTrue(status.wasPrepared);
        RandomAccessAllocator dirHash = 
            (RandomAccessAllocator) tsStorageAllocatorFactory.findAllocator(targetId);
        assertFalse("Id must not exist.", dirHash.isAllocated(targetId));

        newAllocatorFactories();

        // Check if the third time it can still read the dead file.
        startup = new RecoveryStartup(logDir, blobDirHashFactory,
            tsStorageAllocatorFactory, rayAllocatorFactory);
        startup.recover();

        assertEquals(1, startup.staleXaTransactions().size());
        status = startup.staleXaTransactions().get(0);

        assertEquals(0, XidComparator.INSTANCE.compare(xid, status.xid));
        assertEquals(XidStatus.State.ROLLBACK, status.state);
        assertTrue(status.isXa);
        assertTrue(status.wasPrepared);

        // Check that we can clean out any bad state.
        startup.forgetXa(xid);
        assertEquals(0, startup.staleXaTransactions().size());

    }

    /**
     * 
     * @param xid
     * @param status
     * @return
     * @throws Exception
     */
    private XidStatus findXidStatus(Xid xid, List<XidStatus> status)
        throws Exception {
        for (XidStatus s : status) {
            if (XidComparator.INSTANCE.compare(xid, s.xid) == 0) {
                return s;
            }
        }
        throw new IllegalArgumentException("Xid not found.");
    }

    /**
     * Creates the specified target ids as TransactionalRandomAccessFiles
     * writes something to them and optionally prepares them.
     * 
     * @param coord
     * @param xid
     * @throws IOException
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     */
    private TransactionalRandomAccessFile[] writeStuffIntoTraf(
        RecoveryCoordinator coord, Xid xid,  FsId[] targetIds, byte dataFill)
        throws IOException, InterruptedException, FileStoreException {

        TransactionalRandomAccessFileMetadataCache mdCache =
        		new TransactionalRandomAccessFileMetadataCache();
        TransactionalRandomAccessFile[] xraf = new TransactionalRandomAccessFile[targetIds.length];
        for (int i = 0; i < targetIds.length; i++) {
            FsId id = targetIds[i];
            RandomAccessAllocator allocator =  tsStorageAllocatorFactory.findAllocator(id,  true, true);
            JournalWriter journalWriter = coord.journalWriter(xid);
            if (xFiles.containsKey(id)) {
                xraf[i] = (TransactionalRandomAccessFile) xFiles.get(id);
            } else {
                RandomAccessStorage storage = allocator.randomAccessStorage(id);
                xraf[i] = TransactionalRandomAccessFile.loadFile(storage, mdCache);
                xFiles.put(id, xraf[i]);
            }
            coord.addRandomAccess(id, xid);
            xraf[i].beginTransaction(xid, 0, journalWriter);
            xraf[i].write(new byte[] { dataFill }, 0, 1, 0, xid, 45);
        }

        return xraf;
    }
    
    private TransactionalStreamFile[]
            writeStuffIntoBlobs(Xid xid, RecoveryCoordinator coord, FsId[] ids, byte fillValue)
        throws FileStoreException, IOException, InterruptedException {
        
        ByteBuffer bBuf = ByteBuffer.allocate(1024);
        for (int i=0; i < bBuf.capacity(); i++) {
            bBuf.put ( fillValue);
        }
        
        TransactionalStreamFile[] rv = new TransactionalStreamFile[ids.length];
        int i=0;
        for (FsId blobId : ids) {
            TransactionalStreamFile xStream = null;
            if (xFiles.containsKey(blobId)) {
                xStream = (TransactionalStreamFile) xFiles.get(blobId);
            } else {
                DirectoryHash dirHash = blobDirHashFactory.findDirHash(blobId, true, false);
                File streamFile = dirHash.idToFile(blobId.name());
                xStream =
                    TransactionalStreamFile.loadFile(streamFile, blobId);
                xFiles.put(blobId, xStream);
            }
            rv[i++] = xStream;
            xStream.beginTransaction(xid, 30, coord);
            WritableBlob wBlob = xStream.writeBlob(xid, 23);
            FileChannel fChannel = wBlob.fileChannel;
            bBuf.position(0);
            fChannel.write(bBuf);
            wBlob.close();
        }
        
        return rv;
    }
    
    private TransactionalMjdTimeSeriesFile[] writeSomeRays(Xid xid, RecoveryCoordinator coord, FsId[] ids, float fillValue) 
        throws FileStoreException, IOException, ClassNotFoundException, InterruptedException {
        
        TransactionalMjdTimeSeriesFile[] rv = new TransactionalMjdTimeSeriesFile[ids.length];

        for (int i=0; i < ids.length; i++) {
            FsId id = ids[i];
            MjdTimeSeriesStorageAllocator allocator =
                rayAllocatorFactory.findAllocator(id, true);
            RandomAccessStorage storage =allocator.randomAccessStorage(id, true);
            coord.addMjdFile(id, xid);

            rv[i] =  TransactionalMjdTimeSeriesFile.loadFile(storage);
            rv[i].beginTransaction(xid, coord.mjdJournalWriter(xid), 20);
            FloatMjdTimeSeries series = 
                new FloatMjdTimeSeries(id, 0.0, 1.0, new double[] { 0.5}, new float[] { fillValue }, 55);
            rv[i].write(series, true, xid);
        }
        
        return rv;
    }
    
    private void prepareAll(Xid xid, TransactionalFile[] xfiles) 
        throws FileStoreTransactionTimeOut, IOException, InterruptedException {
        for (TransactionalFile xf : xfiles) {
            xf.acquireTransactionLock(xid);
            xf.prepareTransaction(xid);
        }
    }
    
    /**
     * Verify journal files and stream tmp files where deleted.
     *
     */
    private void checkJournals() {
        File[] journalFiles = logDir.listFiles(new FileFilter() {

            public boolean accept(File pathname) {
            	String fname = pathname.getName();
                return fname.endsWith(".journal") || 
                	fname.endsWith(".crjournal") || 
                		fname.endsWith(".dirtyLog") ||
                		fname.equals("rollback") ||
                		fname.endsWith(".dirty") ||
                		fname.endsWith(".xactions");
                
            }
            
        });
        
        assertEquals(0, journalFiles.length);
    }
}
