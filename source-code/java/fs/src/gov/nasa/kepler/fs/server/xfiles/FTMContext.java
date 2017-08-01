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

import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TransactionNotExistException;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.perf.StackTraceDumper;
import gov.nasa.kepler.fs.server.AcquiredPermits;
import gov.nasa.kepler.fs.server.ErrorInjector;
import gov.nasa.kepler.fs.server.ThrottleInterface;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringInfo;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.xfiles.OneToManyRouter.Consumer;
import gov.nasa.kepler.fs.server.xfiles.OneToManyRouter.HashFunction;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.IOException;
import java.net.InetAddress;
import java.util.*;
import java.util.concurrent.*;
import java.util.concurrent.atomic.*;
import java.util.concurrent.locks.*;

import javax.management.openmbean.OpenDataException;
import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.lang.StringUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.base.Function;
import com.google.common.collect.Iterators;

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import static gov.nasa.kepler.fs.server.xfiles.CommitUtils.*;

/**
 * Per transaction information needed by the FileTransactionManager.
 * 
 * @author Sean McCauliff
 *
 */
@SuppressWarnings("unchecked")
class FTMContext {

    public enum ErrorState {
        ROLLBACK_ON_ERROR, NO_ROLLBACK_ON_ERROR;
    }
    
    /**
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(FTMContext.class);
   
    //Per transaction thread pool parameters.
    /** The maximum number of worker threads per transaction for read and write operations. */
    private static final int MAX_THREAD_POOL_SIZE = 2;
    private static final int CORE_THREAD_POOL_SIZE = 0;
   // private static final int PREPARE_TIMEOUT_SECS = 60*60*12;
    
    /**  Creates new threads for each transaction's executor service.
     */
    private static final IoThreadFactory threadFactory = 
        new IoThreadFactory( "FileStore-I/O-Thread-");

    
    /** The number of seconds the thread pool executor should keep threads
     * around that are not being used.
     */
    private static final int MAX_THREAD_IDLE_SECS = 1;
    
    /** This is used by JMX to identify a transaction. */
    private static final AtomicInteger simpleIdFactory =
        new AtomicInteger(0);

    public static final int UPDATE_MOD = 1024*16;

    
    private final Xid xid;

    private final ConcurrentSkipListSet<TransactionalFile> xfiles;

    /**
     * Threads that can be used to execute public read/write.  In this pool
     * the core threads and the non-core threads are treated the same.
     */
    private final ThreadPoolExecutor publicThreadPool;
    
    /**
     * Creates new threads for each transaction's c/p/r threads.
     */
    private final IoThreadFactory  cprThreadFactory;
    
    private final boolean isXa;
    
    private final AutoRollback autoRollback;
    
    /**
     * A human readable string describing the current transaction state.
     */
    private final AtomicReference<String> state = 
        new AtomicReference<String>("init");
    
    private final Date startTime = new Date();
    
    private final DebugReentrantReadWriteLock rwLock = new DebugReentrantReadWriteLock(true);
   
    /**
     * Acquire the read lock when updating or checking the transactional file
     * set, but not changing the state of the transaction.  Acquire the write lock
     * when changing the state of the transaction.
     */
    private final Lock readLock = rwLock.readLock();
    
    private final Lock writeLock = rwLock.writeLock();
    
    
    /**
     * A human referrable id that is not a 100 characters long.  This
     * gets reset between instances of the FileStore server.
     */
    private final int simpleId;
    
    private volatile boolean isDead = false;
    
    private final InetAddress clientAddress;
    
    private final int lockTimeOutSec;
    
    private AcquiredPermits permitsHeldForCommit;
    
    private volatile OneToManyRouter<?> commitPrepareRollbackThreads;
    
    private volatile OneToManyRouter<TransactionalFile> completeCommitRouter;
    
    private final Object waitingForCommitToBeginMonitor = new Object();
    
    private volatile boolean commitHasBegun = false;
    
    
    
        
    FTMContext(Xid xid, boolean xa, InetAddress clientAddress, AutoRollback autoRollback)
        throws IOException {
        
        this.clientAddress = clientAddress;
        this.xid = xid;
        this.xfiles = new ConcurrentSkipListSet<TransactionalFile>();
        
        this.publicThreadPool =
            new ThreadPoolExecutor(CORE_THREAD_POOL_SIZE, 
                                                    MAX_THREAD_POOL_SIZE,
                                                    MAX_THREAD_IDLE_SECS, 
                                                    TimeUnit.SECONDS, 
            new LinkedBlockingQueue<Runnable>(), threadFactory);
        publicThreadPool.allowCoreThreadTimeOut(true);
        
        this.isXa = xa;
        this.autoRollback = autoRollback;
        String threadNamePrefix = "C/P/R" + xid + "/" + clientThreadName() + "-";
        this.cprThreadFactory = new IoThreadFactory(threadNamePrefix);
        this.simpleId = simpleIdFactory.getAndIncrement();
        Configuration config = ConfigurationServiceFactory.getInstance();
        this.lockTimeOutSec = config.getInt(FS_SERVER_FTM_CONTEXT_LOCK_TIMEOUT,
                FS_SERVER_FTM_CONTEXT_LOCK_TIMEOUT_DEFAULT);
    }
        
    TransactionMonitoringInfo getMonitoringInfo() throws OpenDataException {
            return new TransactionMonitoringInfo(clientAddress.toString() + "/" + clientThreadName(),
                                               xid.toString(),  simpleId,
                                               isXa,
                                               startTime, 
                                               autoRollback.autoRollbackTime(),
                                               state.get());
    }
    
    private String clientThreadName() {
        if (xid instanceof PersistableXid) {
            return ((PersistableXid)xid).getXactionThreadName();
        }
        return "";
    }
    
    
    boolean isEmpty() {
        return xfiles.isEmpty();
    }
    
    /**
     * This methods assumes you already have a mechanism to prevent the creation
     * of more than one TransactionalFile instance per database server per FsId.
     * @param xfile
     * @throws IOException
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    void addXFileToTransaction(TransactionalFile xfile) 
        throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        
        acquireReadLock();
        try {
            checkDead();
            xfiles.add(xfile);
        } finally {
            releaseReadLock();
        }
    }
    

    /**
     * Removes the xfile from the transaction if this transaction did not modify it.
     * 
     * @param xf
     * @return true if the file was removed from this transaction.
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     * @throws IOException 
     */
    public boolean removeXFileFromTransaction(TransactionalFile xf) throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        acquireReadLock();
        try {
            checkDead();
            if (!xf.isDirty(xid)) {
                xfiles.remove(xf);
                xf.rollbackTransaction(xid);
                return true;
            }
            return false;
        } finally {
            releaseReadLock();
        }
    }
        
    /**
     * 
     * @return A defensive copy of the internal set of TransactionalFiles associated
     * with this transaction.
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    Set<TransactionalFile> xfiles() throws FileStoreTransactionTimeOut, InterruptedException {
        acquireReadLock();
        try {
            return new HashSet<TransactionalFile>(xfiles);
        } finally {
            releaseReadLock();
        }
    }
    
    /**
     * This executor service associated with this transaction should be used to read
     * or write data from/to the transactional files.
     * @param permits number of permits acquired by the top level reading or
     * writing thread.
     * @return A non null value.
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    ExecutorService executorService(AcquiredPermits permits) throws FileStoreTransactionTimeOut, InterruptedException {
        acquireReadLock();
        try {
            checkDead();
            if (permits.nPermits() <= 0) {
                throw new IllegalArgumentException("npermits <= 0");
            }
            publicThreadPool.setCorePoolSize(permits.nPermits());
            publicThreadPool.setMaximumPoolSize(permits.nPermits());
            return publicThreadPool;
        } finally {
            releaseReadLock();
        }
    }
    
    void setRollbackTimeOutSecs(int secs) {
        checkDead();
        autoRollback.reschedule(secs);
    }
    
    
    void acquireReadLock() throws FileStoreTransactionTimeOut, InterruptedException {
        acquireLock(readLock);
    }
    
    void acquireWriteLock() throws FileStoreTransactionTimeOut, InterruptedException {
        acquireLock(writeLock);
    }
    
    private void acquireLock(Lock lock)throws FileStoreTransactionTimeOut, InterruptedException {
        double startTime = System.currentTimeMillis();
        if (lock.tryLock(lockTimeOutSec, TimeUnit.SECONDS)) {
            return;
        }
        double endTime = System.currentTimeMillis();
        
        double lockWaitTimeS = (endTime - startTime)/1000.0;
        
        //This is here because tryLock() timesout when there is apparently no one
        //holding the lock.  So I suspect the timedout thread is just never
        //scheduled because there are so many others that are ready to run or are
        //running at the time.
        if (lock.tryLock()) {
            return;
        }
        StringBuilder err = new StringBuilder(1024*16);
        String writeLockOwnerName = rwLock.getWriteLockOwnerName();
        err.append("Attempt to get FTMContext lock for transaction \"");
        err.append(xid);
        err.append("\" failed.  Lock queue length: ");
        err.append(rwLock.getQueueLength());
        err.append("Lock wait time [s]: " + lockTimeOutSec + " actual time waited [s] " + lockWaitTimeS);

        if (StringUtils.isBlank(writeLockOwnerName)) {
            err.append("The lock says the lock owner of this lock is null, since it has nothing useful to say I'm going to go \"whole hog\" and just dump out all the threads' stacks.  Take that useless method!");
            StackTraceDumper stackTraceDumper = new StackTraceDumper();
            try {
                stackTraceDumper.dumpStack(err, Collections.EMPTY_LIST, Collections.EMPTY_LIST);
            } catch (IOException e) {
                //This won't actually throw an IOException since there is no
                //output at this time.  Log away.
                log.error("This can't happen.", e);
            }

        } else {
            err.append("Lock owner:\n");
            err.append(writeLockOwnerName);
            err.append("Lock owners stack trace:\n");
            err.append(rwLock.getWriteLocksOwnersStack());
        }
 
        String errStr = err.toString();
        log.error(errStr);
        throw new FileStoreTransactionTimeOut(errStr);
    }
    
    void releaseReadLock() {
        readLock.unlock();
    }
    
    void releaseWriteLock() {
        writeLock.unlock();
    }
    
    
    /**
     * Wait for all the public thread pool tasks to complete.
     * @throws InterruptedException 
     *
     */
    private void waitForUserShutdown() throws InterruptedException {
        try {
            publicThreadPool.shutdown();
            publicThreadPool.awaitTermination(lockTimeOutSec, TimeUnit.SECONDS);
        } catch (InterruptedException ie) {
            log.warn("Shutdown of executor service for transaction \"" + xid + "\" failed.", ie);
            throw ie;
        }
    }
    
    /**
     * Gain the exclusive lock serially and in a deterministic order so we can 
     * prevent deadlock.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    private void acquireTransactionLocks() 
        throws FileStoreTransactionTimeOut, InterruptedException {

        //Xfiles must be a sorted set in order for this to not deadlock.
        for (TransactionalFile xfile : xfiles) {
            //TODO:  if we would block on acquiring the transaction lock then we should
           //instead wait for the transaction to complete and donate our permits/threads
           //in order to complete the transaction we are waiting on.
            xfile.acquireTransactionLock(xid);
        }
    }

    /**
     * Locks all the files xfiles and then calls prepare on all the xfiles.
     * 
     * @return true if this transaction was read only in which case calling
     * commit() after this method will do nothing.  Else this returns false.
     * 
     * @throws IOException
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    boolean prepare(ThrottleInterface throttle, ErrorState errorState)
        throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        
        acquireWriteLock();

        state.set("Prepare started.");
        if (xfiles.isEmpty()) {
            this.isDead = true;
            releaseWriteLock();
            autoRollback.remove();  //do this while not holding any locks.
            return true;
        }
        
        boolean ok = false;
        try {
            checkDead();
            waitForUserShutdown();
            permitsHeldForCommit = throttle.greedyAcquirePermits();
            acquireTransactionLocks();
            int nConsumerThreads = permitsHeldForCommit.nPermits();
            
            HashFunction<TransactionalFile> hashFunction = OneToManyRouter.identity();
            OneToManyRouter<TransactionalFile> prepareRouter = 
                new OneToManyRouter<TransactionalFile>(nConsumerThreads, cprThreadFactory,
                    RECOVERY_CONSUMER_QUEUE_LENGTH,
                    new PrepareConsumer(), xfiles.iterator(),
                    hashFunction, "Prepared %d of " + xfiles.size() + " files.\n");
            this.commitPrepareRollbackThreads = prepareRouter;
            prepareRouter.start();
            prepareRouter.waitForConsumersToComplete();
            ok = true;
            return false;
        } finally {
            commitPrepareRollbackThreads = null;
            if (ok) {
                state.set("Prepare complete.");
            } else {
                state.set("Prepare failed.");
                if (errorState == ErrorState.ROLLBACK_ON_ERROR) {
                   rollback(throttle);
                }
            }
            releaseWriteLock();
        }
    }
    
    /**
     * @throws IOException
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    void rollback(ThrottleInterface throttle) 
        throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        
        acquireReadLock();
        try {
            checkDead();
            waitForUserShutdown();
        } finally {
            releaseReadLock();
        }
        acquireWriteLock();
        boolean ok = false;
        try {
            checkDead();
            if (xfiles.isEmpty()) {
                this.isDead = true;
                ok = true;
            } else {
                if (permitsHeldForCommit == null) {
                    permitsHeldForCommit = throttle.greedyAcquirePermits();
                }
                state.set("Rollback started.");
                int nConsumerThreads = permitsHeldForCommit.nPermits();
                    
                HashFunction<TransactionalFile> hashFunction = OneToManyRouter.identity();
                OneToManyRouter<TransactionalFile> rollbackRouter = 
                        new OneToManyRouter<TransactionalFile>(nConsumerThreads, cprThreadFactory,
                            RECOVERY_CONSUMER_QUEUE_LENGTH,
                            new RollbackConsumer(), xfiles.iterator(),
                            hashFunction, "Rolledback %d of " + xfiles.size() + " files.\n");
                    this.commitPrepareRollbackThreads = rollbackRouter;
                    rollbackRouter.start();
                    rollbackRouter.waitForConsumersToComplete();
                
                isDead = true;
                ok = true;
            }
        } finally {
                if (ok) {
                    state.set("Rollback ok.");
                } else {
                    state.set("Rollback failed.");
                }
            //}
            if (permitsHeldForCommit != null) {
                permitsHeldForCommit.releasePermits();
            }
            
            synchronized (waitingForCommitToBeginMonitor) {
                waitingForCommitToBeginMonitor.notifyAll();
            }
            
            releaseWriteLock();
        }
        //do this outside of a lock
        autoRollback.remove();
    }
    
    /**
     * Adds one additional thread to work on committing this transaction.
     * @throws InterruptedException 
     */
    void acclerateCommit() throws InterruptedException {
        
        //Don't use checkDead() since we don't want an exception thrown
        //Can't use read lock to synchronize this state since the committing
        //thread holds the write lock.
        synchronized (waitingForCommitToBeginMonitor) {
            if (isDead) {
                return; 
            }
            while (!commitHasBegun && ! isDead) {
                waitingForCommitToBeginMonitor.wait();
            }
        }
        
        if (commitHasBegun && !isDead && commitPrepareRollbackThreads != null) {
            commitPrepareRollbackThreads.useMeAsConsumer();
        }
    }
    
    /**
     * 
     * @param randomAccessFileIterator  this may be null
     * @param randAllocatorFactory 
     * @param mjdFileIterator this may be null
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     * @throws IOException
     */
    void commit(Iterator<JournalEntry> randomAccessFileIterator,
                 RandomAccessAllocatorFactory randAllocatorFactory,
                 Iterator<JournalEntry> mjdFileIterator, 
                 MjdTimeSeriesStorageAllocatorFactory mjdAllocatorFactory)
                    throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
        acquireReadLock();
        try {
            checkDead();
            waitForUserShutdown();
        } finally {
            releaseReadLock();
        }
        acquireWriteLock();

       
        boolean ok = false;
        try {
            checkDead();
            commitHasBegun = true;
            state.set("Commit started.");

            int nThreads = permitsHeldForCommit.nPermits();
            if (randomAccessFileIterator != null || mjdFileIterator != null) {
                //We are going to stream all the journal entries into their
                //destination files with multiple threads.
                Iterator<JournalWork> workIterator = null;
                RandomAccessJournalConsumer<RandomAccessAllocator> randomAccessConsumer = null;
                if (randomAccessFileIterator != null) {
                    workIterator = Iterators.transform(randomAccessFileIterator,
                        new MapJournalEntryToRandomAccessJournalWork());
                    ConcurrentSkipListSet<FsId> seenSet = new ConcurrentSkipListSet<FsId>();
                    randomAccessConsumer = 
                        new RandomAccessJournalConsumer<RandomAccessAllocator>(
                            seenSet, randAllocatorFactory, randomAccessRecoveryFactory);
                }
                
                RandomAccessJournalConsumer<MjdTimeSeriesStorageAllocator> mjdConsumer = null;
                if (mjdFileIterator != null) {
                    Iterator<JournalWork> mjdWorkIterator = 
                        Iterators.transform(mjdFileIterator,
                            new MapJournalEntryToMjdJournalWork());
                    if (workIterator == null) {
                        workIterator = mjdWorkIterator;
                    } else {
                        workIterator = Iterators.concat(workIterator, mjdWorkIterator);
                    }
                   ConcurrentSkipListSet<FsId> seenSet = new ConcurrentSkipListSet<FsId>();
                   mjdConsumer = new RandomAccessJournalConsumer<MjdTimeSeriesStorageAllocator>(
                       seenSet, mjdAllocatorFactory, mjdRecoveryFactoryCommitTime);
                }
    
                UnifiedJournalConsumer unifiedJournalConsumer = 
                    new UnifiedJournalConsumer(randomAccessConsumer, mjdConsumer);
                
                HashFunction<JournalWork> workHashFunction = OneToManyRouter.identity();
                OneToManyRouter<JournalWork> recoverThreads =
                    new OneToManyRouter<JournalWork>(nThreads,
                        cprThreadFactory, 256,
                        unifiedJournalConsumer, workIterator,
                        workHashFunction,
                        "Processed %d journal entries for transaction \"" + xid + "\".");
                commitPrepareRollbackThreads = recoverThreads;
                recoverThreads.start();
                synchronized (waitingForCommitToBeginMonitor) {
                    waitingForCommitToBeginMonitor.notifyAll();
                }
                recoverThreads.waitForConsumersToComplete();
                
                //TODO:  any threads that have called acclerateCommit() will have 
                //be let loose at this point when they could still be used to
                //parallelize the next few processes.  I suspect all the heavy lifting
                //is complete with respect to parallelization, however.
                if (randomAccessConsumer != null) {
                    randomAccessConsumer.completeRecovery();
                }
                
                if (mjdConsumer != null) {
                    mjdConsumer.completeRecovery();
                }
                
            } 

            ErrorInjector.generateMidCommitRuntimeException();
            
            HashFunction<TransactionalFile> hashFunction = OneToManyRouter.identity();
            completeCommitRouter = 
                new OneToManyRouter<TransactionalFile>(nThreads,
                    cprThreadFactory, RECOVERY_CONSUMER_QUEUE_LENGTH,
                     new CommitConsumer(), xfiles.iterator(),
                    hashFunction, "Committed %d of " + xfiles.size() + " xfiles.\n");
            commitPrepareRollbackThreads = completeCommitRouter;
            completeCommitRouter.start();
            completeCommitRouter.waitForConsumersToComplete();
            ok = true;
        } finally {
            if (ok) {
                state.set("Commit complete.");
            } else {
                state.set("Commit failed.");
            }
            
            synchronized (waitingForCommitToBeginMonitor) {
                waitingForCommitToBeginMonitor.notifyAll();
            }
            if (permitsHeldForCommit != null) {
                permitsHeldForCommit.releasePermits();
            }
            releaseWriteLock();
        }
       
        if (ok) {
            autoRollback.remove();
        }
    }
    
    
    /**
     * This must be called in order to correctly clean up this transaction.
     * @throws FileStoreTransactionTimeOut 
     *
     */
    void done() throws InterruptedException, FileStoreTransactionTimeOut {
        acquireWriteLock();
        try {
            waitForUserShutdown();
            isDead = true;
        } finally {
            releaseWriteLock();
        }
        
    }
  
    private void checkDead() {
        if (isDead) {
            throw new TransactionNotExistException(xid);
        }
    }
    
    boolean isXa() {
        return isXa;
    }
    
    boolean isReadOnly() throws FileStoreTransactionTimeOut, InterruptedException {
        acquireWriteLock();
        try {
            return this.xfiles.isEmpty();
        } finally {
            releaseWriteLock();
        }
    }
    
    int simpleId() {
        return simpleId;
    }
    
    Xid xid() {
        return xid;
    }
    
    InetAddress client() {
        return clientAddress;
    }

    private final class RollbackConsumer implements Consumer<TransactionalFile> {

        @Override
        public void consume(TransactionalFile xfile) throws IOException,InterruptedException {
            xfile.rollbackTransaction(xid);
        }
        
    }
    
    private final class PrepareConsumer implements Consumer<TransactionalFile> {

        @Override
        public void consume(TransactionalFile xfile) throws IOException, InterruptedException {
            xfile.prepareTransaction(xid);
        }
        
    }

    private final class CommitConsumer implements Consumer<TransactionalFile> {

        @Override
        public void consume(TransactionalFile xfile) throws IOException, InterruptedException {
            xfile.commitTransaction(xid);
        }
    }
    
    private static abstract class JournalWork {
        private final JournalEntry journalEntry;
        protected JournalWork(JournalEntry journalEntry) {
            if (journalEntry == null) {
                throw new NullPointerException("journalEntry");
            }
            this.journalEntry = journalEntry;
        }
        @Override
        public int hashCode() {
            return journalEntry.fsId().hashCode();
        }
        
        @Override
        public boolean equals(Object obj) {
            if (this == obj) {
                return true;
            }
            if (obj == null) {
                return false;
            }
            if (getClass() != obj.getClass()) {
                return false;
            }
            JournalWork other = (JournalWork) obj;
            return this.journalEntry.fsId().equals(other.journalEntry.fsId());
        }
    }
    
    
    private static final class MjdJournalEntry extends JournalWork {
        MjdJournalEntry(JournalEntry journalEntry) {
            super(journalEntry);
        }
    }
    
    private static final class RandomAccessJournalEntry extends JournalWork {
        public RandomAccessJournalEntry(JournalEntry journalEntry) {
            super(journalEntry);
        }
    }
    
    private static final class MapJournalEntryToRandomAccessJournalWork implements Function<JournalEntry, JournalWork>{
        public JournalWork apply(JournalEntry journalEntry) {
            return new RandomAccessJournalEntry(journalEntry);
        }
    }
    
    private static final class MapJournalEntryToMjdJournalWork implements Function<JournalEntry, JournalWork>{
        public JournalWork apply(JournalEntry journalEntry) {
            return new MjdJournalEntry(journalEntry);
        }
    }
    
    /**
     * TODO: This is kind of lame and needs to be fixed.
     * @author Sean McCauliff
     *
     * @param <A>
     */
    private static final class UnifiedJournalConsumer
        implements Consumer<JournalWork> {
        
        private final RandomAccessJournalConsumer<RandomAccessAllocator> randomAccessConsumer;
        private final RandomAccessJournalConsumer<MjdTimeSeriesStorageAllocator> mjdConsumer;
        
        public UnifiedJournalConsumer(
            RandomAccessJournalConsumer<RandomAccessAllocator> randomAccessConsumer,
            RandomAccessJournalConsumer<MjdTimeSeriesStorageAllocator> mjdConsumer) {

            this.randomAccessConsumer = randomAccessConsumer;
            this.mjdConsumer = mjdConsumer;
        }



        @Override
        public void consume(JournalWork journalWork) throws IOException, InterruptedException {
            if (journalWork instanceof RandomAccessJournalEntry) {
                randomAccessConsumer.consume(journalWork.journalEntry);
            } else if (journalWork instanceof MjdJournalEntry ){
                mjdConsumer.consume(journalWork.journalEntry);
            }
        }
    }
    
}
