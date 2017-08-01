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

import gov.nasa.kepler.fs.api.FileStoreException;

import java.io.IOException;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This is a kind of producer consumer type problem where there is one producer
 * and 1 or more consumers.  Consumers are fed items to consume based on the
 * hash code of the item produced.  So that item.hashCode % nConsumers determines
 * which consumer receives an item.  The number of consumers can increase
 * dynamically which is why this class exists as this is more complex than just
 * threads with queues.
 * 
 * @author Sean McCauliff
 *
 */
final class OneToManyRouter<T> {

    private static final Log log = LogFactory.getLog(OneToManyRouter.class);
    private static final int LOG_MOD = 1024 * 5;
    

    
    interface Consumer<T> {
        /** This should be MT-safe. */
        void consume(T item) throws IOException, InterruptedException;
    }
    
    interface HashFunction<T> {
        /** This should be MT-safe. */
        int hash(T item);
    }
    
    final static class IdentityHashFunction<T> implements HashFunction<T> {
        public int hash(T item) {
            return item.hashCode();
        }
    }
    
    static final HashFunction<? extends Object> IDENTITY = new IdentityHashFunction<Object>();
    @SuppressWarnings("unchecked")
    static <T> HashFunction<T> identity() { return (IdentityHashFunction<T>) IDENTITY ; }
    
    private static enum ConsumerMessageType {
        CONSUME_ITEM, TERMINATE, PAUSE;
    }
    
    private static enum ProducerMessageType {
        CONSUMER_TERMINATED, CONSUMER_PAUSED;
    }
    
    /**
     * 
     * @param <T>
     */
    private final static class ConsumerQueueMessage<T> {
        private final T item;
        private final ConsumerMessageType messageType;
        
        ConsumerQueueMessage(T item, ConsumerMessageType messageType) {
            this.item = item;
            this.messageType = messageType;
        }
    }
    
    /**
     * This assumes that the producing thread will eventually produce something
     * that will cause it to wake up and check error and pauseRequested flags.
     *
     */
    private final class ProducerRunner implements Runnable {
        private volatile boolean done = false;
        private volatile long lastWarningMessageMilliS = 0;
        private int activeConsumerCount = 0;
        
        /**Currently this is just used by consumer runners to signal their
         * termination.
         */
        private final ConcurrentLinkedQueue<ProducerMessageType> incomingMessages = 
            new ConcurrentLinkedQueue<ProducerMessageType>();
        
        public boolean done() {
            return done;
        }
        
        public void run() {
            log.debug("Production started.");
            try {
                while (producer.hasNext() && noError()) {
                    if (consumerQueues.size() != activeConsumerCount) {
                        resize();
                    }
                    produceOneItem();
                }
            } catch (Throwable t) {
                error.compareAndSet(null, t);
            } finally {
                sendTerminators();
            }
            log.debug("Done producing.");
        }
        
        /**
         * Up the number of active consumers.  This does busy waiting to avoid
         * synchronization.
         * @throws InterruptedException 
         */
        private void resize() throws InterruptedException {
            //wait for consumers to be done with their existing messages
            int expectedMessages = activeConsumerCount;
            synchronized (this) {
                for (int i=0; i < activeConsumerCount; i++) {
                    BlockingQueue<ConsumerQueueMessage<T>> consumerQueue = consumerQueues.get(i);
                    consumerQueue.put(new ConsumerQueueMessage<T>(null, ConsumerMessageType.PAUSE));
                }
            }
            while (noError() && expectedMessages > 0) {
                ProducerMessageType messageFromConsumer = incomingMessages.poll();
                if (messageFromConsumer == null) {
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException ignored) {
                        //Don't care. 
                    }
                } else {
                    switch (messageFromConsumer) {
                        case CONSUMER_PAUSED: expectedMessages--; break;
                        case CONSUMER_TERMINATED: 
                            //bail out
                            incomingMessages.add(ProducerMessageType.CONSUMER_TERMINATED);
                            return;
                        default:
                            throw new IllegalStateException("Unhandled case : " + messageFromConsumer);
                    }
                }
            }
            synchronized (this) {
                activeConsumerCount = consumerQueues.size();
            }
        }
        
        /**
         * Sends termination messages to consumer threads.  Waits for responses.
         */
        private synchronized void sendTerminators() {
            ConsumerQueueMessage<T> terminateMessage = 
                new ConsumerQueueMessage<T>(null, ConsumerMessageType.TERMINATE);
            for (BlockingQueue<ConsumerQueueMessage<T>> q : consumerQueues) {
                boolean sendOk = false;
                boolean exceptionReported = false;
                while (!sendOk) {
                    try {
                        q.put(terminateMessage);
                        sendOk = true;
                    } catch (Throwable t) {
                        if (!exceptionReported) {
                            log.warn("Received exception while trying to send termination message to consumer threads.  Ignoring exception.", t);
                        }
                        exceptionReported = true;
                    }
                }
            }
            
            int expectedResponses = consumerQueues.size();
            while (expectedResponses != 0) {
                ProducerMessageType messageFromConsumer = incomingMessages.poll();
                if (messageFromConsumer == null) {
                    try {
                        Thread.sleep(1);
                    } catch (InterruptedException ignored) {
                        //I don't care.
                    }
                } else {
                    switch (messageFromConsumer) {
                        case CONSUMER_TERMINATED: expectedResponses--; break;
                        case CONSUMER_PAUSED: break;
                        default:
                            log.warn("Illegal message during termination " + messageFromConsumer + ".");
                    }
                }
            }
            
            done = true;
            this.notifyAll();
        }
        

        private void waitingWarn(BlockingQueue<?> consumerQueue) {
            long thisLogTime = System.currentTimeMillis();
            if (thisLogTime < lastWarningMessageMilliS + 1000 * 60 * 5) {
                return;
            }
            log.warn("Producer thread waiting on consumer queue to empty.");
            StringBuilder logMsg = new StringBuilder("Consumer queue lengths: ");
            for (BlockingQueue<?> bq : consumerQueues) {
                if (bq == consumerQueue) {
                    logMsg.append('[').append(consumerQueue.size()).append("],");
                } else {
                    logMsg.append(consumerQueue.size()).append(',');
                }
            }
            lastWarningMessageMilliS = thisLogTime;
            log.warn(logMsg);
        }
        
        private void produceOneItem() {
            try {
                T item = producer.next();
                ConsumerQueueMessage<T> consumerMessage = 
                    new ConsumerQueueMessage<T>(item, ConsumerMessageType.CONSUME_ITEM);
                int hashCode = Math.abs(itemHashFunction.hash(item));
                int queueNo = hashCode % activeConsumerCount;
                BlockingQueue<ConsumerQueueMessage<T>> consumerQueue = consumerQueues.get(queueNo);
                if (!consumerQueue.offer(consumerMessage)) { //non-blocking
                    waitingWarn(consumerQueue);
                    consumerQueue.put(consumerMessage); //blocking
                }
                
            } catch (Throwable t) {
                if (error.compareAndSet(null, t)) {
                    log.error("Error in producer thread.", t);
                }
            }
        }
        
        public void cancel(Throwable cancelError) {
             error.compareAndSet(null, cancelError);
        }
        
        /**
         * Adds the calling thread as a consumer thread.
         */
        public void addMeAsConsumer() {
            ConsumerRunner consumerRunner = null;
            synchronized (this) {
                if (done || error.get() != null) {
                    return;
                }
                
                BlockingQueue<ConsumerQueueMessage<T>> q = createQueue();
                consumerRunner = new ConsumerRunner(q, consumer, incomingMessages);
                consumerQueues.add(q);
            }
            
            consumerRunner.run();
        }
    }
    
    private final class ConsumerRunner implements Runnable {
        private final BlockingQueue<ConsumerQueueMessage<T>> queue;
        private final Consumer<T> consumer;
        private boolean terminatorSeen = false;
        private final ConcurrentLinkedQueue<ProducerMessageType> producerQueue;
        
        /**
         * 
         * @param queue
         * @param consumer
         * @param produceQueue I'm using a concrete class because Queue<T> can
         * be blocking or non-blocking, but it's important that we use a
         * non-blocking, unbounded queue.
         */
        ConsumerRunner(BlockingQueue<ConsumerQueueMessage<T>> queue, Consumer<T> consumer,
            ConcurrentLinkedQueue<ProducerMessageType> producerQueue) {
            this.queue = queue;
            this.consumer = consumer;
            this.producerQueue = producerQueue;
        }
        
        public void run() {
            try {
                while (!terminatorSeen && noError()) {
                    processOneItem();
                }
            } finally {
                producerQueue.add(ProducerMessageType.CONSUMER_TERMINATED); // non-blocking
                queue.clear(); // non-blocking
            }
        }
        
        private void processOneItem() {
            try {
                ConsumerQueueMessage<T> message = queue.take(); //blocking
                switch (message.messageType) {
                    case CONSUME_ITEM:
                        consumer.consume(message.item);
                        int nProcessed = itemsProcessed.incrementAndGet();
                        if ( (nProcessed % LOG_MOD) == 0) {
                            log.info(String.format(logMessageFormat,  nProcessed));
                        }
                    break;
                    case PAUSE:
                        //This is here so when we reply back to the producer it
                        //knows that we are actually done writing stuff or doing
                        //whatever with the last message before the pause.  This
                        //is important so that some other thread does not come
                        //in while the consumer is performing work on the item
                        //being consumed.
                        producerQueue.add(ProducerMessageType.CONSUMER_PAUSED);
                        break;
                    case TERMINATE:
                        terminatorSeen = true;
                        break;
                    default:
                        throw new IllegalStateException("Unhandled case : " + message.messageType);
                }
            } catch (Throwable t) {
                if (error.compareAndSet(null, t)) {
                    log.error("Error in consumer thread.", t);
                }
               
            }
        }
    }
    
    private final int consumerQueueLength;
    private List<BlockingQueue<ConsumerQueueMessage<T>>> consumerQueues;
    
    private final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
    private final Consumer<T> consumer;
    private final Iterator<T> producer;
    private final Thread producerThread;
    private final ProducerRunner producerRunner;
    
    private final AtomicInteger itemsProcessed = new AtomicInteger();
    private final String logMessageFormat;
    private final HashFunction<T> itemHashFunction;

    
    /**
     * 
     * @param nConsumer  The number of initial consumer threads.
     * @param threadFactory How to make more threads.
     * @param consumerQueueLength The length of each queue to each consumer.
     * @param terminator This is a special value placed on the queue.  No methods
     * are ever called on this instance.  Equality is tested via referential equality.
     * @param consumer  One consumer instance is passed to all the consumer threads.
     * @param producer The producer.
     * @param logMessageFormat This should include one %d parameter.  Every so often
     * this is used to produce a log message indicating the number of successfully
     * consumed items across all threads.
     */
    public OneToManyRouter(int nConsumer, ThreadFactory threadFactory,
            int consumerQueueLength,
            Consumer<T> consumer, Iterator<T> producer, HashFunction<T> itemHashFunction,
            String logMessageFormat) {
        if (nConsumer < 1) {
            throw new IllegalArgumentException("nConsumer must be a positive integer, but was " + nConsumer + ".");
        }
        if (consumerQueueLength < 1) {
            throw new IllegalArgumentException("consumerQueueLength must be a positive integer, but was " + consumerQueueLength + ".");
        }
        if (producer == null) {
            throw new NullPointerException("producer");
        }
        if (consumer == null) {
            throw new NullPointerException("consumer");
        }

        this.consumerQueueLength = consumerQueueLength;
        this.consumer = consumer;
        this.producer = producer;
        this.producerRunner = new ProducerRunner();
        this.consumerQueues = Collections.synchronizedList(new ArrayList<BlockingQueue<ConsumerQueueMessage<T>>>(nConsumer));
        for (int i=0; i < nConsumer; i++) {
            BlockingQueue<ConsumerQueueMessage<T>> q = createQueue();
            Runnable r = new ConsumerRunner(q, consumer, producerRunner.incomingMessages);
            Thread t = threadFactory.newThread(r);
            consumerQueues.add(q);
            t.start();
        }

        this.producerThread = threadFactory.newThread(producerRunner);
        this.logMessageFormat = logMessageFormat;
        this.itemHashFunction = itemHashFunction;
    }
    
    private boolean noError() {
        return error.get() == null;
    }
    
    private <Q> BlockingQueue<Q> createQueue() {
        return new ArrayBlockingQueue<Q>(consumerQueueLength);
    }
    
    public void start() {
        producerThread.start();
    }
    
    public void waitForConsumersToComplete() throws InterruptedException, IOException {
        
        synchronized (producerRunner) {
            while (!producerRunner.done()) {
                producerRunner.wait();
            }
        }
        
        if (error.get() != null) {
             if (error.get() instanceof IOException) {
                 throw new IOException(error.get());
             } else if (error.get() instanceof InterruptedException) {
                 throw (InterruptedException) error.get();
             } else if (error.get() instanceof RuntimeException) {
                 throw (RuntimeException) error.get();
             } else if (error.get() instanceof OutOfMemoryError) {
                 throw (OutOfMemoryError) error.get();
             } else {
                 throw new FileStoreException("Wrapped exception.", error.get());
             }
        }
    }
    
    /**
     * The calling thread is used as an additional consumer.
     * @param increment
     */
    public void useMeAsConsumer() {
        producerRunner.addMeAsConsumer();
    }
   
    
    public void cancel(Throwable cancelError) {
        producerRunner.cancel(cancelError);
    }
    
}
