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
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;

import java.io.IOException;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Condition;
import java.util.concurrent.locks.Lock;

import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The base class of transactional files.  Most of the abstract methods
 * here are for use by the FileTransactionManager.
 * 
 * TransactionalFile has three levels of locking: read, write and transaction. 
 * The transaction lock excludes writers and readers.  The writers exclude the 
 * readers.  The read lock allows multiple readers to be in the critical section and
 * prevent writers and transaction lock holders from gaining their locks until 
 * all the readers have released their locks.  The read and write lock holders are
 * the thread which called acquireXLock(), but the transaction lock holder is the xid
 * of that was used when acquireTransactionLock() was called.  This means
 * multiple threads of the same transaction can run over each other using
 * the transaction lock.  Be careful out there.
 * 
 * @author Sean McCauliff
 *
 */
public abstract class TransactionalFile implements  Comparable<TransactionalFile> {

    private static final Log log = 
        LogFactory.getLog(TransactionalFile.class);

    /**
     * This is used by the caching mechanisms to see when this file no longer
     * has any transactions associated with it.
     * 
     * @return True if there is one or more transactions associated with this
     * file else false.  This is not even read comitted level.
     */
    abstract boolean hasTransactions();

    /**
     * Checks if a file knows about the specified transaction.
     * @return true if begin transaction bas been called and rollback
     * or commit has not yet been called.
     */
    abstract boolean knowsTransaction(Xid xid);

    /**
     * 
     * @param xid  Must be known to the file.
     * @return true if the specified transaction modified the file.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws IOException 
     */
    abstract boolean isDirty(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException, IOException;

    /**
     * Some unique value for this file.
     */
    public abstract FsId id();
    
    /**
     * The implementer of this method can assume the write lock and transaction lock
     * has been acquired.
     * 
     * @param xid
     * @param timeOutSeconds
     */
    protected abstract void doPrepare(Xid xid)
        throws IOException, FileStoreTransactionTimeOut, InterruptedException;
    
    /**
     * The implementer of this method can assume the write lock and transaction lock
     * has been acquired.
     * 
     * @param xid
     * @param timeOutSeconds
     */
    protected abstract void doCommit(Xid xid) 
        throws IOException, FileStoreTransactionTimeOut, InterruptedException;
    
    /**
     * The implementer of this method can assume the write lock and transaction lock
     * has been acquired.
     * 
     * @param xid
     * @param timeOutSeconds
     */
    protected abstract void doRollback(Xid xid)
        throws IOException, FileStoreTransactionTimeOut, InterruptedException;
    
    /**
     * If a transaction is not dirty then perform a clean rollback without
     * needing to acquire the write lock on the file.
     * 
     * @param xid
     * @throws IOException
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    protected abstract void doCleanRollback(Xid xid) 
        throws IOException, FileStoreTransactionTimeOut, InterruptedException;
    
    /**
     * This can be called without acquiring a lock on this file.
     * 
     * @param xid
     * @return The lock timeout associated with this transaction.
     */
    protected abstract int lockTimeOutForTransaction(Xid xid);

    private final DebugReentrantReadWriteLock rwLock;

    /** This is assigned a value when the transaction lock is held.  It can
     * safely be referenced when the read or write lock is held.
     */
    private volatile Xid xLockHolder;
    
    /** The number of times the transaction lock has been locked.  This is to provide
     * reentrant locking.
     */
    private int xLockCount = 0;

    /**
     * This condition can only be waited on when the write lock has been
     * acquired.  This variable is initialized if there is a need to wait
     * which usually happens very infrequently.
     */
    private Condition xLockWaiters;

    /**
     * This lock should be acquired before reading internal data structures.  
     * This is associated with 
     * the rwLock variable.  If internal data structures also have locks then
     * readLock or writeLock() should be acquired first, before acquiring other
     * locks.
     */
    private Lock readLock() {
        return rwLock.readLock();
    }

    /**
     * This lock should be acquired before writing internal data structures or
     * changing the transaction state.  This is associated with the
     * rwLock variable.  If internal data structures also have locks then
     * readLock or writeLock() should be acquired first, before acquiring other
     * locks.  Note that acquiring this lock may not be needed before writing
     * to a file since only on disk state is modified.
     */
    private Lock writeLock(){
        return rwLock.writeLock();
    }

    /**
     * 
     * @param name Some unique value.
     * @param rootDir The root of the directory tree where data about this
     *  file is stored.
     */
    protected TransactionalFile() {
        //You can set this to fair, but using tryLock(void) causes it to ignore fairness.
        rwLock = new DebugReentrantReadWriteLock(false);
    }

    /**
     * If the transaction lock is held then by a different transaction then this will
     * block indefinitely regardless of the time out.
     * 
     * @param xid
     * @param xLockWait When true wait for the transaction lock, else do not
     * @return true if the lock was acquired else false
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    boolean acquireWriteLock(Xid xid, int timeOutSeconds, boolean xLockWait) 
        throws FileStoreTransactionTimeOut, InterruptedException {

        if (!writeLock().tryLock(timeOutSeconds, TimeUnit.SECONDS)) {
            if (!writeLock().tryLock()) {
                //For whatever reason  this seems to fail when there is nothing
                //going on.
                if (log.isDebugEnabled()) {
                    log.debug("Failed to acquire write lock from transaction \"" + xid + "\".");
                    log.debug(rwLock.dumpLockState(id().toString()));
                }
                int queueLength = rwLock.getQueueLength();
                String lockOwner = rwLock.getWriteLockOwnerName();
                String lockOwnerStack = rwLock.getWriteLockOwnerName();
                throw new FileStoreTransactionTimeOut("Transaction \"" + xid + 
                    "\" timed out  while acquiring write lock on FsId \""+ 
                    id() +"\".  Current lock holder is \"" + lockOwner +
                    "\".\n" + lockOwnerStack +
                    "\n Lock queue length:" + queueLength + ". tryLock timeout is " + 
                    timeOutSeconds +"s.");
            }
            
        }

        if (log.isTraceEnabled()) {
            log.trace("Transaction \"" + xid + 
                "\"acquired write lock on file \"" + id() + "\".");
        }

        while (xLockHolder != null && !xLockHolder.equals(xid)) {
            if (!xLockWait) {
                writeLock().unlock();
                return false;
            }
            if (xLockWaiters == null) {
                xLockWaiters = writeLock().newCondition();
            }
            if (log.isInfoEnabled()) {
                log.info(xid + " waiting for " + xLockHolder + 
                    " to finish with FsId \"" + id() + "\".");
            }
            xLockWaiters.await();
        }
        return true;
    }
    
    protected void acquireWriteLock(Xid xid, int timeOutSeconds) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        acquireWriteLock(xid, timeOutSeconds, true);
    }

    protected void releaseWriteLock() {
        writeLock().unlock();
        if (log.isTraceEnabled()) {
            log.trace("Write lock on file \"" + id() +
                "\" released outside of transaction.  Hold count is " +
                rwLock.getWriteHoldCount() + ".");
        }
    }

    /**
     * 
     * @return  This may return null or an out-of-date transaction id.
     */
    Xid transactionLockHolder() {
        return xLockHolder;
    }
    
    void releaseWriteLock(Xid xid) {
        writeLock().unlock();
        if (log.isTraceEnabled()) {
            log.trace("Transaction \"" + xid + 
                "\"released write lock on file \"" + id() +  "\". Hold count is " +
                rwLock.getWriteHoldCount() + ".");
        }
    }

    /**
     * Equivalent to acquireReadLock(xid, timeOutSeconds, true).
     * @param xid non-null
     * @param timeOutSeconds
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    public void acquireReadLock(Xid xid, int timeOutSeconds) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        acquireReadLock(xid, timeOutSeconds, true);
    }
    
    /**
     * Get the read lock on this file.  
     * @param xid This may not be null.
     * @param timeOutSeconds 0 or less indicates no waiting.
     * @param xLockWait if a transaction holds the lock on this file rather
     * than a specific thread and you want to wait for that transaction to
     * complete then set to this true.
     * @return true if the lock was acquired, false if the lock could be
     * acquired, but a transaction owns the lock on this file currently.
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    boolean acquireReadLock(Xid xid, int timeOutSeconds, boolean xLockWait) 
    throws FileStoreTransactionTimeOut, InterruptedException {

        if (!readLock().tryLock(timeOutSeconds, TimeUnit.SECONDS)) {
            if (log.isDebugEnabled()) {
                log.debug("Failed to acquire read lock for transaction \"" + xid + "\".");
                log.debug(rwLock.dumpLockState(id().toString()));
            }
            throw new FileStoreTransactionTimeOut("Transaction \"" + xid + 
                "\" timed out  while acquiring read lock on file\""+ 
                id() +"\".  Lock is currently held by \"" + 
                rwLock.getWriteLockOwnerName() + "\".");
        }

        if (log.isTraceEnabled()) {
            log.trace("Transaction \"" + xid + 
                "\"acquired read lock on file \"" + id() + "\".");
        }

        if (xLockHolder != null && !xLockHolder.equals(xid)) {
            readLock().unlock();
            if (!xLockWait) {
                return false;
            }
            //Acquire the write lock because only the write lock can have a
            //Condition variable associated with it and this thread needs to be able
            //to create a condition variable if none-exists.  Doing the acqusition
            //will cause this thread to wait until the transaction lock holder 
            //is finished.  The ReadWriteLock implementation allows downgrading
            //of locks by acquiring the read lock inside the write lock critical section
            //and then releasing the writelock.
            acquireWriteLock(xid, timeOutSeconds);
            readLock().lock();
            writeLock().unlock();
        }
        
        return true;
    }

    public void releaseReadLock(Xid xid) {
        readLock().unlock();
        if (log.isTraceEnabled()) {
            log.trace("Transaction \"" + xid + 
                "\"released read lock on file \"" + id() + "\". Hold count is " +
                rwLock.getReadHoldCount() + ".");
        }
    }

    /**
     * Acquire the transaction lock.  Unlock other locks the transaction lock is held
     * by the Xid and not by the thread calling this method.  Obtaining the transaction
     * lock is interruptible but does not timeout. 
     * 
     * @param xid  This transaction will hold the transaction lock.
     * @param timeOutSeconds This is the write lock timeout not the transaction
     * lock time out.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    public void acquireTransactionLock(Xid xid, int timeOutSeconds) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        
        acquireWriteLock(xid, timeOutSeconds);
        try {
            if (xLockHolder == null) {
                xLockHolder = xid;
            } else if (!xLockHolder.equals(xid)) {
                throw new IllegalStateException("Expected unassigned or xid " +
                    xid + " transaction lock state but found holder " + 
                    xLockHolder);
            }
            xLockCount++;
        } finally {
            releaseWriteLock(xid);
        }
    }
    
    /**
     * Acquire the transaction lock.  Unlock other locks the transaction lock is held
     * by the Xid and not by the thread calling this method.  Obtaining the transaction
     * lock is interruptible but does not timeout. 
     * 
     * @param xid  This transaction will hold the transaction lock.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    public void acquireTransactionLock(Xid xid) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        acquireTransactionLock(xid, lockTimeOutForTransaction(xid));
    }
    
    /**
     * If the transaction lock had been acquired multiple times then this will only
     * decrement one level of locking.
     * @param xid The xid holding the transaction lock.
     * @param timeOutSeconds This it the time out for the write lock.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    public void releaseTransactionLock(Xid xid) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        releaseTransactionLock(xid, lockTimeOutForTransaction(xid));
    }
    
    /**
     * If the transaction lock had been acquired multiple times then this will only
     * decrement one level of locking.
     * @param xid The xid holding the transaction lock.
     * @param timeOutSeconds This it the time out for the write lock.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    public void releaseTransactionLock(Xid xid, int timeOutSeconds) 
        throws FileStoreTransactionTimeOut, InterruptedException {
        
        acquireWriteLock(xid, timeOutSeconds);
        try {
            if (xLockHolder == null || !xLockHolder.equals(xid) || xLockCount <= 0) {
                throw new IllegalStateException("Exclusive lock not held by " + xid);
            }
            xLockCount--;
            if (xLockCount == 0) {
                if (xLockWaiters != null) {
                    xLockWaiters.signalAll();
                }
                xLockHolder = null;
            }
        } finally {
            releaseWriteLock(xid);
        }
    }

    final boolean hasTransactionLock(Xid xid) {
        Xid xLockHolderCopy = xLockHolder;
        if (xLockHolderCopy == null) {
            return false;
        }
        return xLockHolderCopy.equals(xid);
    }
    
    /**
     * Writes out lock information to this classes logger.
     *
     */
    public void lockDump() {
        log.info(rwLock.dumpLockState(id().toString()));
        log.info("Exclusive lock holder " + xLockHolder);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null) {
            return false;
        }

        if (o.getClass() != this.getClass()) {
            return false;
        }

        TransactionalFile other = (TransactionalFile) o;

        return this.id().equals(other.id());
    }

    @Override
    public int hashCode() {
        return id().hashCode() ^ getClass().getName().hashCode();
    }

    public int compareTo(TransactionalFile o) {
        if (o.getClass() != this.getClass()) {
           return o.getClass().getName().compareTo(this.getClass().getName());
        }
        return this.id().compareTo(o.id());
    }

    @Override
    public String toString() {
        return "[" + this.getClass().getSimpleName() + id() + "]";
    }


    /**
     * Transactionally removes a file.
     * @throws FileStoreException
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException 
     */
    public abstract void delete(Xid xid) throws IOException, FileStoreTransactionTimeOut, InterruptedException;

    /**
     * 
     * @param xid
     * @return true if the specified transaction has deleted this file.
     * @throws IOException
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     * @throws IOException 
     */
    public abstract boolean isDeleted(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException, IOException;
    
    /**
     *   Prepare the transaction.  Acquires the transaction lock to this file.  The
     *   write lock is not released at the end of this method.  To release 
     *   the transaction lock either commit() needs to be called
     *   or else rollback().
     * @param xid
     * @param timeOut
     * @param tunit
     * @throws IOException
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     */
    public final void prepareTransaction(Xid xid) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        if (xid == null) {
            throw new NullPointerException("Xid may not be null.");
        }
        
        if (!hasTransactionLock(xid)) {
            throw new IllegalStateException("Xid \"" + xid + 
                "\" does not hold transaction lock on \"" + id() + "\".");
        }
        acquireWriteLock(xid, lockTimeOutForTransaction(xid));
        boolean done = false;
        try {
            doPrepare(xid);
            done = true;
        } finally {
            try {
                releaseWriteLock(xid);
            } finally {
                if (!done) {
                    releaseTransactionLock(xid, lockTimeOutForTransaction(xid));
                }
            }
        }
    }
    
    /**
     * Commit may make changes durable or just make in-memory changes,
     *  other transactions will see the formerly dirty data after a commit.
     *  Commit will release the transaction lock, even on error.  This
     * can only be called after prepare() has been called.  Commit cleans up
     * all the transaction state.  Subsequent calls with the specified xid will
     * no longer work.
     * 
     * @param xid
     * @throws IOException
     */
    public final void commitTransaction(Xid xid) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {

        if (rwLock.isWriteLockedByCurrentThread()) {
            throw new IllegalStateException("This thread should not hold write lock.");
        }
        
        //Use this because we don't want to wait forever if we don't have the 
       //transaction lock.
        if (!writeLock().tryLock(this.lockTimeOutForTransaction(xid), TimeUnit.SECONDS)) {
            throw new FileStoreTransactionTimeOut("timed out waiting for lock");
        }

        try {
            if (xLockHolder == null || !xLockHolder.equals(xid)) {
                throw new IllegalStateException("Exclusive lock not held by current thread. " +
                    " Lock is owned by \"" + rwLock.getWriteLockOwnerName() +
                    "\", current thread is \""+ Thread.currentThread().getName() + "\".");
            }
            doCommit(xid);
        } finally {
            try {
                releaseTransactionLock(xid, 1);
            } finally {
                writeLock().unlock();
            }
        }
    }
    
    /**
     * Rollsback any changes and cleans up any transient state.  It is safe to
     * call this at any time.  An error may leave the file in an inconsistent
     * state.  This releases any write locks even on error.  Rollback cleans up
     * all the transaction state.  Subsequent calls with the specified xid will
     * no longer work.
     * 
     * @param xid
     * @throws IOException
     */
    public final void rollbackTransaction(Xid xid) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
        if (xid == null) {
            throw new NullPointerException("Transaction id may not be null.");
        }

        if (isDirty(xid)) {
            acquireWriteLock(xid, lockTimeOutForTransaction(xid));
            
            try {
                doRollback(xid);
            } finally {
                try {
                    if (xLockHolder != null) {
                        releaseTransactionLock(xid, 1);
                    }
                } finally {
                    releaseWriteLock(xid);
                }
            }
        } else { //clean state
            acquireReadLock(xid, lockTimeOutForTransaction(xid));
            try {
                doCleanRollback(xid);
            } finally {
                releaseReadLock(xid);
            }
        }
    }

}