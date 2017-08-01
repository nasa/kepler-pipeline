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

package gov.nasa.kepler.fs.storage;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.ErrorInjector;
import gov.nasa.kepler.fs.server.scheduler.DefaultFsIdOrder;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import org.jmock.Expectations;
import org.jmock.Mockery;
import org.jmock.integration.junit4.JMock;
import org.jmock.lib.legacy.ClassImposteriser;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;

/**
 * @author Sean McCauliff
 * 
 */
@RunWith(JMock.class)
public class RandomAccessAllocatorTest {

    private static final File testDir = 
        new File(Filenames.BUILD_TEST, "RandomAccessAllocatorTest.test");
    private static final File tsDir = new File(testDir, "ts");

    private Mockery mockery;
    private FsIdFileSystemLocator fileSystemLocator;
    
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        FileUtil.mkdirs(tsDir);
        mockery = new Mockery() {{
            setImposteriser(ClassImposteriser.INSTANCE);
        }};
        
        fileSystemLocator = mockery.mock(FsIdFileSystemLocator.class);
        mockery.checking(new Expectations() {{
            allowing(fileSystemLocator).directoryForFsIdPath(with(aNonNull(FsId.class)));
            will(returnValue(testDir));
            allowing(fileSystemLocator).fileSystemRoots();
            will(returnValue(Collections.singleton(testDir)));
        }});
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testDir);
        ErrorInjector.setMisMatchedMetaData(false);
    }

    
    @Test
    public void saveAndRemoveFsIdFromHash() throws Exception {
        final int nFiles = 100;
        final int maxFilesPerDir = 10;

        FsId id = new FsId("/blah/blah");

        DirectoryHash forTimeSeries = new DirectoryHash(nFiles, maxFilesPerDir, testDir);
        RandomAccessAllocator randAllocator = new RandomAccessAllocator(forTimeSeries);
        final int nBins = forTimeSeries.getNumberBins();
        final int nLevels = forTimeSeries.getNumberLevels();

        RandomAccessStorage storage = randAllocator.randomAccessStorage(id);
        assertTrue("storage must be new", storage.isNew());
        randAllocator.markIdsPersistent(Collections.singleton(id));
        randAllocator.commitPendingModifications();
        
        DirectoryHash forTimeSeries2 = new DirectoryHash(testDir, nBins, nLevels, maxFilesPerDir);
        RandomAccessAllocator randAllocator2 = new RandomAccessAllocator(forTimeSeries2);

        RandomAccessStorage storage2 = randAllocator2.randomAccessStorage(id);

        Set<FsId> series = randAllocator2.findIds();
        assertEquals(1, series.size());
        assertTrue(series.contains(id));

        assertFalse("storage must not be new", storage.isNew());
        assertFalse("storage2 must not be new", storage2.isNew());

        randAllocator2.removeId(id);
        storage2 = randAllocator2.randomAccessStorage(id);
        assertTrue("storage2 must be new", storage2.isNew());

        randAllocator.close();
        randAllocator2.close();
        Thread.sleep(1000);
    }

    /**
     * Remove newer time series.
     */
    @SuppressWarnings("static-access")
    @Test
    public void testRemoveSomeNewerTimeSeries() throws Exception {
        FsId id1 = new FsId("/blah/blah1");
        FsId id2 = new FsId("/blah/blah2");

        final int nFiles = 100;
        final int maxFilesPerDir = 10;

        DirectoryHash forTimeSeries = new DirectoryHash(nFiles, maxFilesPerDir, testDir);
        RandomAccessAllocator allocator = new RandomAccessAllocator(forTimeSeries);
        allocator.randomAccessStorage(id1);
        allocator.randomAccessStorage(id2);
        allocator.markIdsPersistent(Arrays.asList(new FsId[] { id2 }));
        allocator.removeAllNewIds(Arrays.asList(new FsId[] { id1, id2 }));
        allocator.testClearBtreeCache();
        assertFalse("id " + id1 + " must not be allocated", allocator.isAllocated(id1));
        assertTrue("id " + id2 + " must be allocated", allocator.isAllocated(id2));
        
        RandomAccessAllocator allocator2 = new RandomAccessAllocator(forTimeSeries);
        assertFalse("id " + id1 + " must not be allocated", allocator2.isAllocated(id1));
        assertTrue("id " + id2 + " must be allocated", allocator2.isAllocated(id2));

    }

    /**
     * Find time series.
     */
    @Test
    public void testFindAllTimeSeries() throws Exception {
        FsId id0 = new FsId("/test-level0/0");
        FsId id1 = new FsId("/test-another0/1");
        FsId id2 = new FsId("/test-level0/test-level2/test-level3/2");

        Set<FsId> allIds = new HashSet<FsId>();
        allIds.add(id0);
        allIds.add(id1);
        allIds.add(id2);

        DirectoryHashFactory forTimeSeries = new DirectoryHashFactory(fileSystemLocator, tsDir, 1000, 10);
        RandomAccessAllocatorFactory randAllocatorFactory = new RandomAccessAllocatorFactory(forTimeSeries);

        RandomAccessAllocator allocator = randAllocatorFactory.findAllocator(id0, true, true);
        allocator.randomAccessStorage(id0);
        allocator.markIdsPersistent(allIds);
        allocator.commitPendingModifications();
        allocator =  randAllocatorFactory.findAllocator(id1, true, true);
        allocator.randomAccessStorage(id1);
        allocator.markIdsPersistent(allIds);
        allocator.commitPendingModifications();
        allocator =  randAllocatorFactory.findAllocator(id2, true, true);
        allocator.randomAccessStorage(id2);
        allocator.markIdsPersistent(allIds);
        allocator.commitPendingModifications();
        RandomAccessAllocator.testClearBtreeCache();

        DirectoryHashFactory factoryForTimeSeries = new DirectoryHashFactory(fileSystemLocator, tsDir);
        RandomAccessAllocatorFactory readFactory = 
            new RandomAccessAllocatorFactory(factoryForTimeSeries);

        assertEquals(allIds, readFactory.find(null, false));
        
     
    }

    @Test
    public void locationTest() throws Exception {
        FsId id0 = new FsId("/over/there");
        FsId id1 = new FsId("/over/here");
        FsId id2 = new FsId("/over/where");

        Set<FsId> allIds = new HashSet<FsId>();
        allIds.add(id0);
        allIds.add(id1);
        allIds.add(id2);

        DirectoryHashFactory forTimeSeries = new DirectoryHashFactory(fileSystemLocator, tsDir, 1000, 10);
        RandomAccessAllocatorFactory randAllocatorFactory = new RandomAccessAllocatorFactory(forTimeSeries);

        RandomAccessAllocator allocator = randAllocatorFactory.findAllocator(id0, true, true);
        allocator.randomAccessStorage(id0, true);
        allocator.randomAccessStorage(id1, true);
        allocator.randomAccessStorage(id2, true);
        
        FsIdLocation location0 = allocator.locationFor(new DefaultFsIdOrder(id0, 0));
        FsIdLocation location1 = allocator.locationFor(new DefaultFsIdOrder(id1, 1));
        FsIdLocation location2 = allocator.locationFor(new DefaultFsIdOrder(id2, 2));
        
        assertTrue(location0.exists());
        assertTrue(location1.exists());
        assertTrue(location2.exists());
        assertEquals(0, location0.fileLocation());
        assertEquals(location0.fileLocation(), location1.fileLocation());
        assertEquals(location1.fileLocation(), location2.fileLocation());
        assertEquals(0L, location0.offsetInFile());
        assertEquals(1L, location1.offsetInFile());
        assertEquals(2L, location2.offsetInFile());
        assertEquals(0, location0.originalOrder());
        assertEquals(1, location1.originalOrder());
        assertEquals(2, location2.originalOrder());
        
        FsId missingId = new FsId("/no/where");
        FsIdLocation locationMissing = allocator.locationFor(new DefaultFsIdOrder(missingId, 10));
        assertFalse(locationMissing.exists());
        assertEquals(10, locationMissing.originalOrder());

    }
    
    /**
     * Multi-threaded read/write into the time series directory hash.
     */
    @Test
    public void mtReadWrite() throws Exception {
        final int MAX_IDS = 10000;
        final AtomicInteger idCount = new AtomicInteger(0);
        final AtomicReference<Exception> caughtError = new AtomicReference<Exception>();
        final int MAX_THREADS = 2;
        final CountDownLatch start = new CountDownLatch(1);
        final CountDownLatch done = new CountDownLatch(MAX_THREADS);
        File tsDir = new File(this.testDir, "ts");
        DirectoryHash forTimeSeries = new DirectoryHash(1000, 10000, tsDir);
        final RandomAccessAllocator randAllocator = new RandomAccessAllocator(forTimeSeries);

        // write
        for (int i = 0; i < MAX_THREADS; i++) {
            final int threadId = i;
            Runnable r = new Runnable() {

                public void run() {
                    try {
                        start.await();

                        while (true) {
                            int fsIdNumber = idCount.getAndIncrement();
                            if (fsIdNumber > MAX_IDS) {
                                return;
                            }
                            FsId fsId = new FsId("/test/id" + fsIdNumber);
                            randAllocator.randomAccessStorage(fsId);
                        }

                    } catch (Exception e) {
                        caughtError.compareAndSet(null, e);
                    } finally {
                        done.countDown();
                    }
                }

            };

            Thread t = new Thread(r, "TimeSeriesDirHashTest_thread" + threadId);
            t.setDaemon(true);
            t.start();
        }

        start.countDown();

        done.await();

        assertEquals(null, caughtError.get());
        List<FsId> allIds = new ArrayList<FsId>(MAX_IDS);
        for (int i = 0; i < MAX_IDS; i++) {
            allIds.add(new FsId("/test/id" + i));
        }

        randAllocator.markIdsPersistent(allIds);

        // read
        for (FsId fsId : allIds) {
            assertTrue(randAllocator.hasSeries(fsId));
        }

        randAllocator.close();
    }

}
