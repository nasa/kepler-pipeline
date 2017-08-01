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

import static org.junit.Assert.*;
import gov.nasa.kepler.fs.server.xfiles.OneToManyRouter.Consumer;
import gov.nasa.kepler.fs.server.xfiles.OneToManyRouter.HashFunction;
import gov.nasa.spiffy.common.concurrent.DaemonThreadFactory;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.*;


public class OneToManyRouterTest {

    private static final File testDir = 
        new File(Filenames.BUILD_TEST, "OneToManyRouterTest");
    
    @Before
    public void setup() throws Exception  {
        FileUtil.cleanDir(testDir);
        FileUtil.mkdirs(testDir);
    }
    
    @After
    public void teardown() {
        //TODO:  remove files.
    }
    
    private static final class CountingConsumer implements Consumer<Integer> {

        private final Set<Integer> seen = new ConcurrentSkipListSet<Integer>();
        private final AtomicInteger nInvocations = new AtomicInteger();
        @Override
        public void consume(Integer item) throws IOException,
                InterruptedException {

            seen.add(item);
            nInvocations.incrementAndGet();
        }
        
    }
    
    private final ThreadFactory threadFactory = new DaemonThreadFactory(OneToManyRouterTest.class.getSimpleName());
    private final HashFunction<Integer> identityHashFunction = new HashFunction<Integer>() {
        public int hash(Integer item) {
            return item;
        }
    };
    
    /**
     * Use the iterator() method to generate a sequence of integers.
     *
     */
    private static final class SequenceList extends AbstractList<Integer> {
        private final int sequenceStart;
        private final int sequenceLength;
        
        SequenceList(int sequenceStart, int sequenceLength) {
            this.sequenceStart = sequenceStart;
            this.sequenceLength = sequenceLength;
        }
        
        @Override
        public Integer get(int index) {
            if ( index >= sequenceLength|| index < 0) {
                throw new IndexOutOfBoundsException(Integer.toString(index));
            }
            return index + sequenceStart;
        }
        @Override
        public int size() {
            return sequenceLength;
        }
    };
    
    /**
     * Actually write some data to a file.  Useful for checking if something is
     * written out in order.
     */
    private static final class FileWriterConsumer implements Consumer<Integer> {

        private final File outputDir;
        private final HashFunction<Integer> dataFileHashFunction;
        
        
        public FileWriterConsumer(File outputDir, HashFunction<Integer> dataFileHashFunction) {
            this.outputDir = outputDir;
            this.dataFileHashFunction = dataFileHashFunction;
        }


        @Override
        public void consume(Integer item) throws IOException, InterruptedException {
            
            int dataFileId = dataFileHashFunction.hash(item);
            File dataFile = new File(outputDir, Integer.toString(dataFileId) + ".data");
//            RandomAccessFile raf = new RandomAccessFile(dataFile, "rwd");
//            raf.seek(raf.length());
//            byte[] data = (item.toString() + "\n").getBytes();
//            raf.write(data, 0, data.length);
//            raf.close();
            FileWriter fileWriter = new FileWriter(dataFile, true);
            fileWriter.write(item.toString() + "\n");
            fileWriter.close();
        }
        
        public void validateOutput(int maxFiles) throws IOException {
            for (int fileIndex = 0; fileIndex < maxFiles; fileIndex++) {
                File dataFile = new File(outputDir, Integer.toString(fileIndex) + ".data");
                BufferedReader breader = new BufferedReader(new FileReader(dataFile));
                int prevNumber = -1;
                for (String line = breader.readLine(); line != null; line = breader.readLine()) {
                    int currentNumber = Integer.parseInt(line);
                    if (prevNumber > currentNumber) {
                        throw new IllegalArgumentException("prevNumber " + prevNumber + " > currentNumber " + currentNumber );
                    }
                    prevNumber = currentNumber;
                }
                
                breader.close();
            }
        }
        
        
    }
    
    private static final class InMemoryFileWriterConsumer implements Consumer<Integer> {
        private final HashFunction<Integer> dataFileHashFunction;
        private final List<Queue<Integer>> fileLikeQueues;
        
        public InMemoryFileWriterConsumer(HashFunction<Integer> dataFileHashFunction,
            List<Queue<Integer>> fileLikeQueues) {
            this.dataFileHashFunction = dataFileHashFunction;
            this.fileLikeQueues = fileLikeQueues;
        }


        @Override
        public void consume(Integer item) throws IOException, InterruptedException {
            
            int dataFileId = dataFileHashFunction.hash(item);
            fileLikeQueues.get(dataFileId).add(item);
            //Thread.sleep(1);
        }
    }
    
    private static final class ErrorGenerator implements Consumer<Integer> {
        private final AtomicInteger itemCount = new AtomicInteger();
        private final int generateErrorAtCount;
        
        ErrorGenerator(int generateErrorAtCount) {
            this.generateErrorAtCount = generateErrorAtCount;
        }
        
        @Override
        public void consume(Integer item) throws IOException, InterruptedException {
            int currentCount = itemCount.getAndIncrement();
            if (currentCount == generateErrorAtCount) {
                throw new IOException("Error generated.");
            }
        }
    }
    
    /**
     * 
     * @throws Exception
     */
    
    @Test
    public void emptyProducer() throws Exception {
        @SuppressWarnings("unchecked")
        Iterator<Integer> emptyIt = Collections.EMPTY_LIST.iterator();
        
        CountingConsumer counter = new CountingConsumer();
        OneToManyRouter<Integer> oneToManyRouter = 
                new OneToManyRouter<Integer>(2, threadFactory, 128,
                        counter, emptyIt, identityHashFunction,
                        "Processed %d items.");
        oneToManyRouter.start();
        oneToManyRouter.waitForConsumersToComplete();
        
        assertEquals(0, counter.nInvocations.get());
        assertTrue(counter.seen.isEmpty());
    }
    
    @Test
    public void produceSomething() throws Exception {
        final int maxProduce = 1024*1024;
        List<Integer> srcList = new SequenceList(0, maxProduce);
        CountingConsumer counter = new CountingConsumer();;
        OneToManyRouter<Integer> oneToManyRouter = 
                new OneToManyRouter<Integer>(3, threadFactory, 128,
                         counter, srcList.iterator(), identityHashFunction,
                        "Processed %d items.");
        oneToManyRouter.start();
        oneToManyRouter.waitForConsumersToComplete();
        
        assertEquals(maxProduce, counter.nInvocations.get());
    }
    
    @Test
    public void testOrdering() throws Exception {
        final int maxProduce = 1024 * 1024;
        final int maxDataFiles = 10;
        Iterator<Integer> seq = new SequenceList(0, maxProduce).iterator();
        HashFunction<Integer> dataFileHashFunction = new HashFunction<Integer>() {

            @Override
            public int hash(Integer item) {
                return item % maxDataFiles;
            }
            
        };
        
        FileWriterConsumer fileWriterConsumer = 
            new FileWriterConsumer(testDir, dataFileHashFunction);
//        List<Queue<Integer>> fileLikeQueues = Lists.newArrayList();
//        int fileLikeQueueCapacity = (int) Math.ceil(maxProduce / (double) maxDataFiles);
//        for (int i=0; i < maxDataFiles; i++) {
//            fileLikeQueues.add(new ArrayBlockingQueue<Integer>( fileLikeQueueCapacity));
//        }
//        InMemoryFileWriterConsumer inMemoryConsumer = 
//            new InMemoryFileWriterConsumer(dataFileHashFunction, fileLikeQueues);
        final OneToManyRouter<Integer> oneToManyRouter = 
                new OneToManyRouter<Integer>(1, threadFactory, 64,
                         fileWriterConsumer, seq, dataFileHashFunction,
                        "Processed %d items.");
        oneToManyRouter.start();
        
        for (int i=0; i < 10; i++) {
            Thread.sleep(1000);
            Runnable addMe = new Runnable() {
    
                @Override
                public void run() {
                    oneToManyRouter.useMeAsConsumer();
                }
            };
            Thread t = new Thread(addMe);
            t.setDaemon(true);
            t.start();
        }
       
        oneToManyRouter.waitForConsumersToComplete();
        
        fileWriterConsumer.validateOutput(maxDataFiles);
        
//        for (Queue<Integer> q : fileLikeQueues) {
//            int lastItem = -1;
//            for (Integer queueItem = q.poll(); queueItem != null; queueItem = q.poll()) {
//                if (lastItem > queueItem) {
//                    throw new IllegalStateException("Invalid output queue.");
//                }
//                lastItem = queueItem;
//            }
//        }
    }
    
    @Test
    public void consumerException() throws Exception {
        final int maxProduce = 1024*1024;
        List<Integer> srcList = new SequenceList(0, maxProduce);
        ErrorGenerator errorGenerator = new ErrorGenerator(maxProduce / 3);
        OneToManyRouter<Integer> oneToManyRouter = 
                new OneToManyRouter<Integer>(3, threadFactory, 64,
                         errorGenerator, srcList.iterator(), identityHashFunction,
                        "Processed %d items.");
        oneToManyRouter.start();
        
        try {
            oneToManyRouter.waitForConsumersToComplete();
            assertFalse(true);
        } catch (IOException expected) {
            assertTrue(expected.getMessage().contains("Error generated."));
        }
        
    }
    
    
   
}
