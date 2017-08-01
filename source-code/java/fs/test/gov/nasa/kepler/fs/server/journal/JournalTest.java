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

package gov.nasa.kepler.fs.server.journal;
import gov.nasa.kepler.io.DataOutputStream;

import static org.junit.Assert.*;
import gnu.trove.TLongArrayList;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.concurrent.DaemonThreadFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.math.BigInteger;
import java.util.*;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sean McCauliff
 * 
 */
public class JournalTest {

    private final File testRoot = 
        new File(Filenames.BUILD_TEST, "/JournalTest.test");
    private final FakeXid xid = new FakeXid(new BigInteger("55"), new BigInteger("4343"));
    private final File journalFile = new File(testRoot, "journal");
    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testRoot.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        FileUtil.removeAll(testRoot);
    }

    @Test
    public void serialJournalReadWriteTest() throws Exception {
        JournalWriter writer = new SerialJournalWriter(journalFile, xid);
        journalReadWriteTest(writer);
    }
    
    @Test
    public void concurrentJournalReadWriteTest() throws Exception {
        JournalWriter writer = new ConcurrentJournalWriter(journalFile, xid);
        journalReadWriteTest(writer);
    }
    
    @Test
    public void mmapJournalReadWriteTest() throws Exception {
        JournalWriter writer = new MmapJournalWriter(journalFile, xid);
        journalReadWriteTest(writer);
    }
    
    private void journalReadWriteTest(final JournalWriter writer) throws Exception {
        final int MAX_IDS = 40;
        final int DATA_SIZE = 1024;

        List<Long> startPoints = new ArrayList<Long>();
        for (int i = 0; i < MAX_IDS; i++) {
            FsId id = new FsId("/journal/" + i);
            byte[] data = new byte[DATA_SIZE];
            Arrays.fill(data, (byte) i);
            Long entryStart = writer.write(id, i, data, 0, data.length);
            startPoints.add(entryStart);
        }

        ByteArrayOutputStream bout = new ByteArrayOutputStream();
        for (int i = 0; i < 777; i++) {
            bout.write(i);
        }
        FsId boutId = new FsId("/blah/bytearray");
        @SuppressWarnings("unused")
        Long boutStart = writer.write(boutId, 777, bout);
        writer.close();

        JournalStreamReader streamReader = new JournalStreamReader(journalFile);
        assertEquals(0, XidComparator.INSTANCE.compare(xid, streamReader.xid()));
        byte[] truthData = new byte[DATA_SIZE];
        for (int i = 0; i < MAX_IDS; i++) {
            FsId id = new FsId("/journal/" + i);
            JournalEntry entry = streamReader.nextEntry();
            assertEquals(id, entry.fsId());
            Arrays.fill(truthData, (byte) i);
            assertArrayEquals(truthData, entry.data());
        }
        @SuppressWarnings("unused")
        JournalEntry boutEntry = streamReader.nextEntry();
        assertEquals(null, streamReader.nextEntry());

        streamReader.close();

        RandomAccessJournalReader randReader = new RandomAccessJournalReader(
            journalFile);
        for (int i = 0; i < MAX_IDS; i++) {
            FsId id = new FsId("/journal/" + i);
            JournalEntry entry = randReader.read(startPoints.get(i));
            assertEquals(id, entry.fsId());
            Arrays.fill(truthData, (byte) i);
            assertArrayEquals(truthData, entry.data());
        }
        randReader.close();
    }
    
    
    /**
     * Write bunch of different journal entries with increasing sizes.  Then use
     * do multiple writes into the same journal entry to make sure the journal
     * output stream does the right thing.
     * 
     * @throws Exception
     */
    @Test
    public void serialJournalOutputStreamTest() throws Exception {
        JournalWriter writer = new SerialJournalWriter(journalFile, xid);
        journalOutputStreamTest(writer);
    }
    
    @Test
    public void concurrentJournalOutputStreamTest() throws Exception {
        JournalWriter writer = new ConcurrentJournalWriter(journalFile, xid);
        journalOutputStreamTest(writer);
    }
    
//    @Test
//    public void mmapJournalOutputStreamTest() throws Exception {
//        JournalWriter writer = new MmapJournalWriter(journalFile, xid);
//        journalOutputStreamTest(writer);
//    }
    
    private void journalOutputStreamTest(final JournalWriter writer) throws Exception {
        final int seed = 343434;
        final int maxJournalEntrySize = 
            JournalCommon.CHUNK_SCHEDULE[JournalCommon.CHUNK_SCHEDULE.length - 1]+1;
        
        ///////Write journal
        TLongArrayList journalLocations = new TLongArrayList();
        Random rand = new Random(seed);
        for (int len=0; len <= maxJournalEntrySize; len++) {
            byte[] buf = new byte[len];
            rand.nextBytes(buf);
            Pair<Long,DataOutputStream> pair = 
                writer.outputStream(new FsId("/stream-test/" + len), len+1);
            pair.right.write(buf);
            pair.right.close();
            journalLocations.add(pair.left);
        }
        
        FsId multiId = new FsId("/multi-path/multi-name");
        Pair<Long,DataOutputStream> multiWritePair =
            writer.outputStream(multiId, 666);
        byte[] multiWriteBytes = new byte[1024*15+23];
        Arrays.fill(multiWriteBytes, (byte) 23);
        multiWritePair.right.write(multiWriteBytes);
        Arrays.fill(multiWriteBytes, (byte) 42);
        multiWritePair.right.write(multiWriteBytes);
        multiWritePair.right.write(77);
        multiWritePair.right.close();
        
        writer.close();
       
        ////Read journal
        rand = new Random(seed);
        
        double startTime = System.currentTimeMillis();
        JournalStreamReader streamReader = new JournalStreamReader(journalFile);
        
        for (int len=0; len <= maxJournalEntrySize; len++) {
            byte[] buf = new byte[len];
            rand.nextBytes(buf);
            JournalEntry journalEntry = streamReader.nextEntry();
            assertTrue(Arrays.equals(buf, journalEntry.data()));
        }
        
        byte[] allMultiWriteBytes = new byte[multiWriteBytes.length * 2 + 1];
        Arrays.fill(allMultiWriteBytes, (byte) 23);
        Arrays.fill(allMultiWriteBytes, multiWriteBytes.length, allMultiWriteBytes.length - 1, (byte) 42);
        allMultiWriteBytes[allMultiWriteBytes.length - 1] = (byte) 77;
        
        JournalEntry multiWriteEntry = streamReader.nextEntry();
        assertTrue(Arrays.equals(allMultiWriteBytes, multiWriteEntry.data()));
        
        streamReader.close();
        double endTime= System.currentTimeMillis();
        double duration = endTime - startTime;
        System.out.println("Stream reader milliseconds: " + duration);
        
        rand = new Random(seed);
        startTime = System.currentTimeMillis();
        RandomAccessJournalReader randJournal = new RandomAccessJournalReader(journalFile);
        for (int i=0; i < journalLocations.size() - 1; i++) {
            JournalEntry entry = randJournal.read(journalLocations.get(i));
            byte[] buf = new byte[i];
            rand.nextBytes(buf);
            assertTrue(Arrays.equals(buf,entry.data()));
        }
        
        multiWriteEntry = randJournal.read(multiWritePair.left);
        assertTrue(Arrays.equals(allMultiWriteBytes, multiWriteEntry.data()));
        randJournal.close();
        endTime = System.currentTimeMillis();
        duration = endTime - startTime;
        System.out.println("Rand journal reader milliseconds " + duration);
    }
    
    @Test
    public void serialJournalOutputStreamWriteSingleBytesTest() throws Exception {
        JournalWriter writer = new SerialJournalWriter(journalFile, xid);
        journalOutputStreamWriteSingleBytesTest(writer);
    }
    
    @Test
    public void concurrentJournalOutputStreamWriteSingleBytesTest() throws Exception {
        JournalWriter writer = new ConcurrentJournalWriter(journalFile, xid);
        journalOutputStreamWriteSingleBytesTest(writer);
    }
    
//    @Test
//    public void mmapJournalOutputStreamWriteSingleBytesTest() throws Exception {
//        JournalWriter writer = new MmapJournalWriter(journalFile, xid);
//        journalOutputStreamWriteSingleBytesTest(writer);
//    }
    
    private void journalOutputStreamWriteSingleBytesTest(final JournalWriter writer) throws Exception {
        
        FsId id = new FsId("/test/id");
        Pair<Long, DataOutputStream> pair = writer.outputStream(id, 0);
        for (int i=0; i < 65; i++) {
            pair.right.write(i + 'a');
        }
        pair.right.close();
        
        writer.close();
        
        RandomAccessJournalReader reader = new RandomAccessJournalReader(journalFile);
        JournalEntry entry = reader.read(pair.left);
        entry.data();
        reader.close();
    }
    
    /**
     * Writes a large file to the mmap journal writer.
     */
    @Test
    public void bigWritesMmap() throws Exception  {
        MmapJournalWriter mmapJW = new MmapJournalWriter(journalFile, xid);
        FsId id = new FsId("/big/one");
        final int nEntries = 128;
        byte[] buf = new byte[1024*1024*10];
        for (int i=0; i < nEntries; i++) {
            Arrays.fill(buf, (byte)i);
            mmapJW.write(id, 0, buf, 0, buf.length);
        }
        mmapJW.close();
        
        JournalStreamReader streamReader = new JournalStreamReader(journalFile);
        for (int i=0; i < nEntries; i++) {
            Arrays.fill(buf, (byte)i);
            JournalEntry e = streamReader.nextEntry();
            assertTrue(Arrays.equals(buf, e.data()));
        }
        assertFalse(streamReader.hasNext());
        streamReader.close();
    }
    
    @Test //Currently this crashes the JVM.  I suspect this is due to unmap().
    public void multiThreadWriteMmap() throws Exception {
        final MmapJournalWriter mmapJW = new MmapJournalWriter(journalFile, xid);
        final FsId id = new FsId("/big/one");
        int nEntries = 127;
        final int bufSize = 1024*1024*10;
        final AtomicInteger entryNo = new AtomicInteger();
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        final CountDownLatch done = new CountDownLatch(nEntries);
        Set<Integer> allFillValues = new HashSet<Integer>();
        ExecutorService threadPool = Executors.newFixedThreadPool(10, new DaemonThreadFactory("multiThreadWriteMmapTest"));
        for (int i=0; i < nEntries; i++) {
        	allFillValues.add(i);
        	Runnable r = new Runnable() {
        		public void run() {
        			try {
        				byte[] buf = new byte[bufSize];
        				Arrays.fill(buf, (byte) entryNo.getAndIncrement());
        				mmapJW.write(id, 0, buf, 0, bufSize);
        			} catch (Throwable t) {
        				error.compareAndSet(null, t);
        			} finally {
        				done.countDown();
        			}
        		}
        	};
        	threadPool.submit(r);
        }
        done.await();
        mmapJW.close();
        threadPool.shutdown();
        
      
        assertEquals(null, error.get());
        JournalStreamReader streamReader = new JournalStreamReader(journalFile);
        for (int i=0; i < nEntries; i++) {
            JournalEntry e = streamReader.nextEntry();
            int fillValue = e.data()[0];
            allFillValues.remove(fillValue);
        }
        assertFalse(streamReader.hasNext());
        streamReader.close();
        assertTrue(allFillValues.isEmpty());
    }
}
