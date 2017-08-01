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

package gov.nasa.kepler.fs.server;

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringInfo;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocationFactory;
import gov.nasa.kepler.fs.server.xfiles.TransactionalFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalMjdTimeSeriesFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFile;
import gov.nasa.kepler.fs.server.xfiles.TransactionalStreamFile;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.IOException;
import java.net.InetAddress;
import java.util.List;
import java.util.Set;
import java.util.concurrent.ExecutorService;

import javax.transaction.xa.XAException;
import javax.transaction.xa.Xid;

public interface FileTransactionManagerInterface {

    /**
     * Starts a new local transaction that is not associated with a transaction
     * manager.
     * @param clientAddr Used for informational purposes like logging.
     * @param throttle Only used if auto rollback is needed at a later time.
     * @return  The new transaction id.
     */
    PersistableXid beginLocalTransaction(InetAddress clientAddr, ThrottleInterface throttle) throws IOException;

    /**
     * Joins the file store with the specified external transaction id.
     * @param xaXid xid from the transaction manager.
     * @param timeOutSecs when the transaction should time out.
     * @param clientAddr Used for informational purposes like logging.
     * @param throttle nly used if auto rollback is needed at a later time.
     */
    void startXaTransaction(Xid xaXid, int timeOutSecs, InetAddress clientAddr, ThrottleInterface throttle) throws XAException;

    /**
     * Commits the XA transactions.  This is the second phase of 2PC.
     * @param acquiredPermits This may be null if singlePhase is false.
     * @param singlePhase When true the distributed transaction manager has told us
     * this is not a distributed transaction.
     */
    void commitXa(Xid xid, boolean singlePhase, ThrottleInterface throttle) throws XAException;

    /**
     * Forget about a heuristically completed transaction.  If this transaction
     * was not heuristically completed then it should
     * see page 40 of the XA spec.
     */
    void forgetXa(Xid xid) throws XAException;

    /**
     * The first stage of 2PC.
     * @return true if the transaction was read-only else return fasle.
     */
    boolean prepareXa(Xid xid,  ThrottleInterface throttle) throws XAException;

    /**
     * Rollback.
     */
    void rollbackXa(Xid xid, ThrottleInterface throttle) throws XAException;

    /**
     * @param This parameter is ignored.  All Xids will be returned with
     * every call.
     * @return All known transactionsl.  It's up to the calling transaction
     * manager to be able to identify which ones are owned my them
     */
    Xid[] recoverXa(int flags) throws XAException;

    /**
     * Get the current transaction time out.  After this amount of time the
     * transaction is automatically rolledback.
     * 
     * @return TimeOut in seconds.
     */
    int getTransactionTimeout(Xid xid) throws XAException;

    /**
     * Set the transaction timeout for the current transaction.  This may
     * refuse to set the timeout.
     * @return true If the timeout was set, otherwise false.
     */
    boolean setTransactionTimeout(Xid xid, int toSecs) throws XAException;


    /** 
     * When opened a TransactionalRandomAccessFile joins the specified
     * transaction.
     * 
     * @param xid
     * @param f
     * @return
     * @throws IOException
     */
    TransactionalRandomAccessFile openRandomAccessFile(Xid xid, FsId id, 
        boolean createNew)
    throws IOException, FileStoreException,
    InterruptedException;

    /**
     * Try and free resources associated with the specified file if the
     * transaction is read only for this file.
     * 
     * @param xid
     * @param xraf
     * @throws IOException
     * @throws FileStoreException
     * @throws InterruptedException
     */
    void doneWithFile(Xid xid, TransactionalFile xfile)
    throws IOException, FileStoreException,
    InterruptedException;

    /**
     * When opened a TransactionalRandomAccessFile joins the specified
     * transaction.
     * 
     * @param xid
     * @param f
     * @return
     * @throws IOException
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    TransactionalStreamFile openStreamFile(Xid xid, FsId id, boolean createNew)
    throws IOException,FileStoreException, InterruptedException;

    /**
     * When opened a TransactionalCosmicRayFile joins the specified
     * transaction.
     * @throws ClassNotFoundException 
     */
    TransactionalMjdTimeSeriesFile openMjdFile(Xid xid, FsId id, boolean createNew)
    throws IOException, FileStoreException, InterruptedException;

    /**
     * 
     * @param xid
     * @param file 
     * @return true fi the file exists
     * @throws InterruptedException 
     * @throws IOException 
     */
    boolean streamFileExists(Xid xid, FsId file) throws FileStoreException, InterruptedException, IOException;

    /**
     * 
     * @param xid
     * @param file 
     * @return true fi the file exists
     * @throws IOException 
     * @throws InterruptedException 
     */
    boolean randomAccessExists(Xid xid, FsId file) throws FileStoreException, IOException, InterruptedException;

    /**
     * 
     * @param xid
     * @param acquiredPermits The new max threads.
     * @return The ExecutorService for this transaction or null if this
     * transaction has not been started/rolled back, etc.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    ExecutorService executorService(Xid xid, AcquiredPermits permits) throws FileStoreTransactionTimeOut, InterruptedException;

    /**
     * Non-transactional.
     * 
     * @param series
     * @return
     * @throws FileStoreException
     * @throws InterruptedException
     */
    public Set<FsId> findFsIds(FsId series) throws FileStoreException,
    InterruptedException;

    /**
     * Rollsback all the files involved in this transaction. You do not need to
     * call prepare() first.
     * @param xid  The transaction involved in the commit.  This may not be null.
     * @throws IOException
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws FileStoreException 
     * @throws ClassNotFoundException 
     */
    void rollback(Xid xid, ThrottleInterface throttle) throws IOException,
    FileStoreTransactionTimeOut, InterruptedException, FileStoreException;;

    /**
     * Commits changes to files.  You must call prepare() first before calling
     * this method.  commit() must be called from the same thread as prepare()
     * was called from.
     * 
     * @param xid The transaction involved in the commit.  This may not be null.
     * @throws IOException
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws FileStoreException 
     * @throws ClassNotFoundException 
     */
    void commitLocal(Xid xid, ThrottleInterface throttle) throws IOException,
    FileStoreTransactionTimeOut, InterruptedException, FileStoreException;

    /**
     * Prepares to rollback changes made within the specified transaction
     * to all files, allocates disk space needed for commit.  This must be called
     * before commit(). 
     * 
     * 
     * @param xid  This may not be null.
     * @param throttle This controls how many threads are going to do work when
     * preparing the transaction.
     * @return true if the prepare() was on a read-only transaction else this
     * returns false.
     * @throws IOException  Allocating space or writeing did not go as expected.
     * @throws InterruptedException  The thread was interrupted while trying
     *  to acquire the lock on the file.
     * @throws FileStoreTransactionTimeOut The thread reached its timeout while
     * waiting to acquire the lock on the file.
     */
    boolean prepareLocal(Xid xid, ThrottleInterface throttle) throws IOException,
    InterruptedException, FileStoreTransactionTimeOut;


    /** Cleans up inmemory state as much as possiable.  Note that cleaning up
     * stuck threads may not be possiable.  On disk data will need to be removed
     * manually.  This method is here for testing purposes.
     * 
     * @throws IOException
     */
    void cleanUp() throws IOException;

    List<TransactionMonitoringInfo> transactionMonitoringInfo() throws FileStoreException;

    /**
     * This is intended to be called from JMX.
     * @param simpleId
     * @return True on success, else false.
     */
    boolean  forceRollback(int simpleId);

    /**
     * This is intended to be called from JMX.
     * @return True on success, else false.
     */
    boolean  forceRollback();

    //void cleanUpInMemoryOnly() throws IOException;

    /**
     * Non-Transactional method to list all the CosmicRaySeries available.
     * 
     * @param rootId
     * @return
     * @throws ClassNotFoundException 
     */
    Set<FsId> listMjdTimeSeries(FsId rootId) throws FileStoreException, IOException;

    /**
     * Finds FsIds.  This is non-transactional.
     * 
     * @param query
     * @return
     * @throws FileStoreException
     * @throws IOException
     */
    Set<FsId> queryFsId(String query) throws FileStoreException, IOException;

    /**
     * Finds the roots of FsIds.  This is non-transactional.
     * 
     * @param query
     * @return
     * @throws FileStoreException
     * @throws IOException
     */
    Set<FsId> queryFsIdPath(String query) throws FileStoreException,
    IOException;

    /**
     * Transaction should be in prepared state in order to get an
     * authoritative answer.
     * 
     * @param xid
     * @return
     * @throws FileStoreTransactionTimeOut
     * @throws InterruptedException
     */
    boolean isReadOnly(Xid xid) throws FileStoreTransactionTimeOut,
    InterruptedException;

    /**
     * Gets the FsIdLocationFactory.
     */
    FsIdLocationFactory locationFactory(Xid xid, boolean mjdTimeSeries);

    /**
     * Metadata counter stats.
     * @return a non-null pair of (missCount, hitCount)
     */
    Pair<Long, Long> metadataCounterStats();
}