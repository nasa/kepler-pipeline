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

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.util.PersistableXid;
import gov.nasa.kepler.fs.query.QueryEvaluator;
import gov.nasa.kepler.fs.server.AcquiredPermits;
import gov.nasa.kepler.fs.server.FileTransactionManagerInterface;
import gov.nasa.kepler.fs.server.ThrottleInterface;
import gov.nasa.kepler.fs.server.UnboundedThrottle;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.index.PersistentSequence;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringInfo;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocation;
import gov.nasa.kepler.fs.server.scheduler.FsIdLocationFactory;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrder;
import gov.nasa.kepler.fs.server.scheduler.FsIdOrderCompareById;
import gov.nasa.kepler.fs.server.xfiles.FTMContext.ErrorState;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;
import gov.nasa.spiffy.common.concurrent.ServerLock;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.lang.management.ManagementFactory;
import java.net.InetAddress;
import java.util.*;
import java.util.concurrent.*;

import javax.management.openmbean.OpenDataException;
import javax.transaction.xa.XAException;
import javax.transaction.xa.Xid;

import org.antlr.runtime.RecognitionException;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Manages transactions spanning multiple transactional files.
 * 
 * @author Sean McCauliff
 * 
 */
public class FileTransactionManager implements FileTransactionManagerInterface {
    
    /**
     * Logger for this class.
     */
    private static final Log log = LogFactory.getLog(FileTransactionManager.class);
    private static final int XFILE_HASH_SIZE = 283;
    public static final String FILE_SYSTEM_ROOT_CONF_FILE_NAME = 
        "fsdataroots.xml";
    
    public static class Factory {
        private FileTransactionManagerInterface inst;
        
        /**
         * 
         * @return The singleton instance of the FileTransactionManager.
         * @throws PipelineException
         */
        public synchronized FileTransactionManagerInterface instance(Configuration config)
            throws FileStoreException, IOException, Exception {

            if (inst != null) {
                return inst;
            }

            try {
                inst = new FileTransactionManager(config);
            } catch (IOException ioe) {
                throw new FileStoreException("Configuration service factory problem.", ioe);
            }
            return inst;
        }
        
        /**
         * This is useful to testing purposes.
         */
        public synchronized void clear() {
            inst = null;
        }
    }
    
    /**
     * The next id to use for local transactions.
     */
    private final PersistentSequence nextTransactionId;
    
    /**
     * Each transaction has a TransactionContext (see below) that has all the
     * per transaction bookkeeping.
     */
    private final ConcurrentNavigableMap<Xid, FTMContext> transactionContexts = 
        new ConcurrentSkipListMap<Xid, FTMContext>(XidComparator.INSTANCE);
    private final Map<Xid, FTMContext> unmodifiableTransactionContexts = 
        Collections.unmodifiableMap(transactionContexts);

    /**
     * All the transactional files that are in use across all transactions. Only
     * stream files have open file descriptors.
     */
    private final Map<FsId, TransactionalFile>[] transactionalFiles;

    /** The timeout to wait for a lock. */
    private final int lockTimeOutSeconds;

    /**
     * This is where transaction logs are stored.
     */
    private final File transactionLogDir;

    private final ScheduledThreadPoolExecutor xactionAutoRollbackExecutor =
        new ScheduledThreadPoolExecutor(1);

    private final RecoveryCoordinator recoveryCoordinator;
    private final RecoveryStartup recoveryStartup;

    private final DirectoryHashFactory blobDirHashFactory;
    private final DirectoryHashFactory timeSeriesDirHashFactory;
    private final DirectoryHashFactory mjdTimeSeriesDirHashFactory;
    
    private final RandomAccessAllocatorFactory randAllocatorFactory;
    private final MjdTimeSeriesStorageAllocatorFactory mjdAllocatorFactory;

    private final File dataDir;
    private final ServerLock dataDirLock;

    private final CommitOrderIdGenerator orderGenerator;
    
    private final ThrottleInterface forceRollbackThrottle = new UnboundedThrottle(4);
    
    private final boolean syncOnCommit;
    
    /**
     * The time in seconds to automatically rollback a transaction.
     */
    private final int XACTION_AUTOROLLBACK_SECS;
    
    private final TransactionalRandomAccessFileMetadataCache trafMetadataCache;

    private static int index(FsId id) {
        return Math.abs(id.path().hashCode()) % XFILE_HASH_SIZE;
    }
    
    @SuppressWarnings("unchecked")
    FileTransactionManager(Configuration config) throws Exception {

        transactionalFiles = new Map[XFILE_HASH_SIZE];
        for (int i=0; i < XFILE_HASH_SIZE; i++) {
            transactionalFiles[i] = Collections.checkedMap(
                new HashMap<FsId, TransactionalFile>(), FsId.class,
                TransactionalFile.class);
        }
        
        
        syncOnCommit = config.getBoolean(FS_SERVER_SYNC_ON_COMMIT, FS_SERVER_SYNC_ON_COMMIT_DEFAULT);
        String dataDirStr = config.getString(FS_DATA_DIR_PROPERTY);
        if (dataDirStr == null || dataDirStr.length() == 0) {
            dataDirStr = FS_DATA_DIR_DEFAULT;
            log.info(FS_DATA_DIR_PROPERTY + " is not assigned using default "
                + FS_DATA_DIR_DEFAULT);

        }

        int maxFilesPerDir = config.getInt(MAX_FILES_PER_DIR_PROPERTY,
            MAX_FILES_PER_DIR_DEFAULT);
        int maxFilesPerStore = config.getInt(FILES_PER_STORE_PROPERTY,
            FILES_PER_STORE_DEFAULT);

        dataDir = new File(dataDirStr);
        if (!dataDir.exists()) {
            log.info("Directory \"" + dataDir.getAbsolutePath()
                + "\" does not exist, creating it.");

            dataDir.mkdirs();
        }

        FsIdFileSystemLocator fsIdPathLocator = 
            new UserConfigurableFsIdFileSystemLocator(new File(dataDir, FILE_SYSTEM_ROOT_CONF_FILE_NAME), dataDir.getCanonicalPath());
        
        initDataDirs(fsIdPathLocator);
        

        blobDirHashFactory = new DirectoryHashFactory(fsIdPathLocator,
             new File(BLOB_DIR_NAME), maxFilesPerStore, maxFilesPerDir);
        
        timeSeriesDirHashFactory = new DirectoryHashFactory(fsIdPathLocator,
            new File(TIME_SERIES_DIR_NAME), maxFilesPerStore, maxFilesPerDir);
        randAllocatorFactory = new RandomAccessAllocatorFactory(timeSeriesDirHashFactory);

        mjdTimeSeriesDirHashFactory = 
            new DirectoryHashFactory(fsIdPathLocator, new File(MJD_TIME_SERIES_DIR_NAME),
                maxFilesPerStore, maxFilesPerDir);
        
        mjdAllocatorFactory = new MjdTimeSeriesStorageAllocatorFactory(mjdTimeSeriesDirHashFactory);
        
        File serverLockFile = new File(dataDir, SERVER_LOCK_NAME);
        dataDirLock = new ServerLock(serverLockFile);
        String processInfo = ManagementFactory.getRuntimeMXBean().getName();
        dataDirLock.tryLock(processInfo);

        transactionLogDir = new File(dataDir, TRANSACTION_LOG_DIR_NAME);
        if (!transactionLogDir.exists()) {
            FileUtil.mkdirs(transactionLogDir);
        }

        recoveryStartup = new RecoveryStartup(transactionLogDir,
            blobDirHashFactory, randAllocatorFactory, mjdAllocatorFactory);

        recoveryStartup.recover();

        
        File orderFile = new File(dataDir, "commitorder.seq");
        orderGenerator = new CommitOrderIdGeneratorImpl(orderFile);
        
        recoveryCoordinator = new RecoveryCoordinator(transactionLogDir,
            blobDirHashFactory, randAllocatorFactory, mjdAllocatorFactory,
            orderGenerator);

        XACTION_AUTOROLLBACK_SECS = config.getInt(
            FS_XACTION_AUTOROLLBACK_SEC_PROPERTY,
            FS_XACTION_AUTOROLLBACK_SEC_DEFAULT);
        
        lockTimeOutSeconds = config.getInt(FS_SERVER_FSID_LOCK_TIMEOUT_SEC,
                                           FS_SERVER_FSID_LOCK_TIMEOUT_SEC_DEFAULT);

        trafMetadataCache = 
            new TransactionalRandomAccessFileMetadataCache();
        
        File localTransactionIdSequenceFile = 
            new File(dataDir, "localTransactionCounter");
        nextTransactionId = 
            new PersistentSequence(localTransactionIdSequenceFile, 10000);

    }

    /**
     * Creates all the "ts", "blob", etc directories.
     * @throws IOException 
     */
    private static void initDataDirs(FsIdFileSystemLocator fileSystemLocator) throws IOException {
        for (File fileSystemRoot : fileSystemLocator.fileSystemRoots()) {
            FileUtil.mkdirs(new File(fileSystemRoot, BLOB_DIR_NAME));
            FileUtil.mkdirs(new File(fileSystemRoot, TIME_SERIES_DIR_NAME));
            FileUtil.mkdirs(new File(fileSystemRoot, MJD_TIME_SERIES_DIR_NAME));
        }
    }
    
    private Map<FsId, TransactionalFile> getMap(FsId id) {
        return transactionalFiles[index(id)];
    }
    
    @Override
    public boolean isReadOnly(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException {
        FTMContext context = getContext(xid);
        return context.isReadOnly();
    }
    
    /**
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#beginLocalFsTransaction()
     */
    @Override
    public PersistableXid beginLocalTransaction(
        InetAddress clientAddress, ThrottleInterface throttle) throws IOException {

        LocalXid xid = new LocalXid(nextTransactionId.next());
        recoveryCoordinator.beginTransaction(xid, false);
        FTMContext context = new FTMContext(xid, false, clientAddress,
            new AutoRollbackRunnable(xid, XACTION_AUTOROLLBACK_SECS, xactionAutoRollbackExecutor, this, throttle));
        transactionContexts.putIfAbsent(xid, context);
        if (log.isDebugEnabled()) {
            log.debug("Begun local transaction \"" + xid + "\".");
        }
        return xid;
    }

    /**
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#startXaTransaction(javax.transaction.xa.Xid)
     */
    @Override
    public void startXaTransaction(Xid xaXid, int timeOut,
        InetAddress clientAddress, ThrottleInterface throttle) throws XAException {

        log.info("Starting XA transaction \"" + xaXid
            + ", which will time out in " + timeOut + " seconds.");

        if (transactionContexts.containsKey(xaXid)) {
            log.warn("Already know about transaction \"" + xaXid
                + "\".");

            return; // Already know about this transaction.
        }

        try {
            recoveryCoordinator.beginTransaction(xaXid, true);
            FTMContext context = new FTMContext(xaXid, true, clientAddress,
                new AutoRollbackRunnable(xaXid, timeOut, xactionAutoRollbackExecutor, this, throttle));
            transactionContexts.putIfAbsent(xaXid, context);
        } catch (IOException ioe) {
            log.error("Not able to log transaction.", ioe);
            XAException xax = new XAException("Not able to log transaction." + ioe);
            xax.initCause(ioe);
        }

    }

    @Override
    public TransactionalRandomAccessFile openRandomAccessFile(final Xid xid, 
        final FsId id, final boolean createNew) 
        throws IOException, FileStoreException, InterruptedException {

        final RandomAccessAllocator allocator = 
            randAllocatorFactory.findAllocator(id, createNew, true);

        if (allocator == null) {
            return null;
        }

        final FTMContext context = getContext(xid);


        TransactionalFileOpener<TransactionalRandomAccessFile> xFileOpener =
            new TransactionalFileOpener<TransactionalRandomAccessFile>() {
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return getMap(id);
                }
                
                @Override
                protected TransactionalRandomAccessFile loadFile(FsId id) 
                throws FileStoreTransactionTimeOut, IOException, InterruptedException {
                    if (!createNew && !allocator.hasSeries(id)) {
                        return null;
                    }
                    RandomAccessStorage storage = allocator.randomAccessStorage(id);
                    return TransactionalRandomAccessFile.loadFile(storage, trafMetadataCache);
                }
                
                @Override
                protected void beginTransaction(TransactionalRandomAccessFile xFile) 
                    throws FileStoreTransactionTimeOut, IOException, InterruptedException {
                    xFile.beginTransaction(xid, lockTimeOutSeconds, recoveryCoordinator.journalWriter(xid));
                }
            };
 
        TransactionalRandomAccessFile traf = 
            xFileOpener.openFile(xid, id, lockTimeOutSeconds, unmodifiableTransactionContexts);
        if (traf == null) {
            return null;
        }
        context.addXFileToTransaction(traf);
        recoveryCoordinator.addRandomAccess(id, xid);

        return traf;

    }

    @Override
    public void doneWithFile(Xid xid, TransactionalFile xfile)
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {

        FTMContext context = getContext(xid);
        if (context.removeXFileFromTransaction(xfile)) {
            Map<FsId, TransactionalFile> xfMap = getMap(xfile.id());
            synchronized (xfMap) {
                if (!xfile.hasTransactions()) {
                    xfMap.remove(xfile.id());
                }
            }
        }
    }

    @Override
    public TransactionalMjdTimeSeriesFile openMjdFile(final Xid xid, FsId id,
        final boolean createNew) throws IOException, FileStoreException,
        InterruptedException {

        final MjdTimeSeriesStorageAllocator allocator = 
            mjdAllocatorFactory.findAllocator(id, createNew);

        if (allocator == null) {
            return null;
        }

        final FTMContext context = getContext(xid);

        TransactionalFileOpener<TransactionalMjdTimeSeriesFile> xFileOpener =
            new TransactionalFileOpener<TransactionalMjdTimeSeriesFile>() {
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return getMap(id);
                }
                
                @Override
                protected TransactionalMjdTimeSeriesFile loadFile(FsId id)
                    throws FileStoreTransactionTimeOut, IOException, InterruptedException {
                    if (!createNew && !allocator.hasSeries(id)) {
                        return null;
                    }
                    
                    RandomAccessStorage storage = 
                        allocator.randomAccessStorage(id, true);
        
                    return TransactionalMjdTimeSeriesFile.loadFile(storage);
                }
                
                @Override
                protected void beginTransaction(TransactionalMjdTimeSeriesFile xFile)
                    throws FileStoreTransactionTimeOut, IOException, InterruptedException {

                    xFile.beginTransaction(xid,
                        recoveryCoordinator.mjdJournalWriter(xid),
                        lockTimeOutSeconds);
                }
            };
        TransactionalMjdTimeSeriesFile xfile = 
            xFileOpener.openFile(xid, id, lockTimeOutSeconds, unmodifiableTransactionContexts);
        if (xfile == null) {
            return null;
        }
        context.addXFileToTransaction(xfile);
        recoveryCoordinator.addMjdFile(id, xid);
        return xfile;

    }

    /**
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#openStreamFile(javax.transaction.xa.Xid,
     * java.io.File)
     */
    @Override
    public TransactionalStreamFile openStreamFile(final Xid xid, FsId id,
        final boolean createNew) throws IOException, FileStoreException,
        InterruptedException {

        final DirectoryHash dirHash = 
            blobDirHashFactory.findDirHash(id, createNew, true);

        if (dirHash == null) {
            throw new FileStoreIdNotFoundException(id);
        }

        final File blobFile = dirHash.idToFile(id.name());

        final FTMContext context = getContext(xid);

        TransactionalFileOpener<TransactionalStreamFile> xFileOpener = 
            new TransactionalFileOpener<TransactionalStreamFile>() {
                
                @Override
                protected Map<FsId, TransactionalFile> openFileMap(FsId id) {
                    return getMap(id);
                }
                
                @Override
                protected TransactionalStreamFile loadFile(FsId id)
                    throws FileStoreTransactionTimeOut, IOException, InterruptedException {
                    if (!createNew && !blobFile.exists()) {
                        throw new FileStoreIdNotFoundException(id);
                    }
                    return TransactionalStreamFile.loadFile(blobFile, id);
                }
                
                @Override
                protected void beginTransaction(TransactionalStreamFile xFile)
                    throws FileStoreTransactionTimeOut, IOException, InterruptedException {
                    xFile.beginTransaction(xid, lockTimeOutSeconds, recoveryCoordinator);
                }
            };
        
        TransactionalStreamFile xf = 
            xFileOpener.openFile(xid, id, lockTimeOutSeconds, unmodifiableTransactionContexts);
        //Not adding to recovery coordinator here.  TransactionalStreamFile will
        //do that as needed.  This lazy adding to the recovery coordinator saves
        //some file accesses when using the file in read-only mode.
        context.addXFileToTransaction(xf);
        return xf;
    }

    /**
     * @throws InterruptedException
     * @throws IOException
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#streamFileExists(javax.transaction.xa.Xid,
     * java.io.File)
     */
    @Override
    public boolean streamFileExists(Xid xid, FsId id)
        throws FileStoreException, InterruptedException, IOException {
        DirectoryHash dirHash;
        try {
            dirHash = blobDirHashFactory.findDirHash(id);
        } catch (IOException e) {
            throw new FileStoreException("Failed to find file with id \"" + id
                + "\".", e);
        }

        if (dirHash == null) {
            return false;
        }

        Map<FsId, TransactionalFile> xfMap = getMap(id);
        synchronized (xfMap) {
            TransactionalFile xfile = xfMap.get(id);
            if (xfile != null) {
                if (!(xfile instanceof TransactionalStreamFile)) {
                    return false;
                }
                if (xfile.knowsTransaction(xid) && !xfile.isDeleted(xid)) {
                    return true;
                }
            }
            File f = dirHash.idToFile(id.name());
            return f.exists();
        }

    }

    /**
     * @throws FileStoreException
     * @throws IOException
     * @throws InterruptedException
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#streamFileExists(javax.transaction.xa.Xid,
     * java.io.File)
     */
    @Override
    public boolean randomAccessExists(Xid xid, FsId id)
        throws FileStoreException, IOException, InterruptedException {
        RandomAccessAllocator randAllocator;
        try {
            randAllocator = randAllocatorFactory.findAllocator(id);
        } catch (IOException e) {
            throw new FileStoreException("Failed to find file with id \"" + id
                + "\".", e);
        }

        if (randAllocator == null) {
            return false;
        }

        TransactionalFile xfile = null;
        Map<FsId, TransactionalFile> xfMap = getMap(id);
        synchronized (xfMap) {
            xfile = xfMap.get(id);
        }

        // The following does not need to be in a synchronized block.
        // If xfile is removed from transactionalFiles and is then accessed here
        // it will still give the correct answers. If xfile being in a
        // transaction
        // vs. not being in the transaction changes during the course of this
        // call then this is file store users problem of not synchronizing
        // transaction commits/rollbacks with data access on a different client
        // thread.
        if (xfile != null) {
            if (!(xfile instanceof TransactionalRandomAccessFile)) {
                return false;
            }
            if (xfile.knowsTransaction(xid) && !xfile.isDeleted(xid)) {
                return true;
            }
        }
        return randAllocator.hasSeries(id) && !randAllocator.isNew(id);

    }

    /**
     * This is non-transactional.
     * 
     * @param id
     * @return
     * @throws InterruptedException
     * @throws IOException
     */
    @Override
    public Set<FsId> findFsIds(FsId series) throws FileStoreException,
        InterruptedException {

        try {
            // TODO: There should be some way of specifying if the user wants
            // time series or blob.
            RandomAccessAllocator tsDirHash = randAllocatorFactory.findAllocator(series);
            if (tsDirHash != null) {
                return tsDirHash.findIds();
            }

            DirectoryHash dirHash = blobDirHashFactory.findDirHash(series);

            if (dirHash == null) {
                return Collections.emptySet();
            }

            Set<String> nameSet = dirHash.findAllIds();
            Set<FsId> fsIdSet = new HashSet<FsId>((int) (nameSet.size() * 1.3));
            for (String name : nameSet) {
                fsIdSet.add(new FsId(series.path(), name));
            }
            return fsIdSet;

        } catch (IOException ioe) {
            String msg = "While trying to find all the ids for time series \""
                + series + "\".";
            log.error(msg, ioe);
            throw new FileStoreException(msg, ioe);
        }

    }

    @Override
    public Set<FsId> queryFsId(String query) throws FileStoreException, IOException {
        QueryEvaluator qEval;
        try {
            qEval = new QueryEvaluator(query);
        } catch (RecognitionException e) {
            throw new FileStoreException("Bad query \"" + query + "\".", e);
        }
        
        switch(qEval.dataType()) {
            case Blob:
                return blobDirHashFactory.find(qEval,true);
            case MjdTimeSeries:
                return mjdAllocatorFactory.find(qEval, true);
            case TimeSeries:
                return randAllocatorFactory.find(qEval, true);
            default:
                throw new IllegalStateException("Missing case \"" + 
                    qEval.dataType() + "\".");
        }

    }
    
    
    @Override
    public Set<FsId> queryFsIdPath(String query) 
        throws FileStoreException, IOException {
        
        //So that pathMatched will work correctly.
        if (!query.endsWith("*")) {
            query = query + "/_";
        }
        QueryEvaluator qEval;
        try {
            qEval = new QueryEvaluator(query);
        } catch (RecognitionException e) {
            throw new FileStoreException("Bad query \"" + query + "\".", e);
        }
        
        switch(qEval.dataType()) {
            case Blob:
                return blobDirHashFactory.findPath(qEval);
            case MjdTimeSeries:
                return mjdTimeSeriesDirHashFactory.findPath(qEval);
            case TimeSeries:
                return timeSeriesDirHashFactory.findPath(qEval);
            default:
                throw new IllegalStateException("Missing case \"" + 
                    qEval.dataType() + "\".");
        }
        
    }
    
    @SuppressWarnings("unchecked")
    @Override
    public Set<FsId> listMjdTimeSeries(FsId rootId) throws FileStoreException,
        IOException {

        MjdTimeSeriesStorageAllocator allocator;
        allocator = mjdAllocatorFactory.findAllocator(rootId, false);

        if (allocator == null) {
            return Collections.EMPTY_SET;
        }

        return allocator.findIds();
    }

    /**
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#executorService(javax.transaction.xa.Xid)
     */
    @Override
    public ExecutorService executorService(Xid xid, AcquiredPermits permits) throws FileStoreTransactionTimeOut, InterruptedException {
        FTMContext context = getContext(xid);
        return context.executorService(permits);
    }

    /**
     * @throws ClassNotFoundException
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#rollback(javax.transaction.xa.Xid)
     */
    @Override
    public void rollback(Xid xid, ThrottleInterface throttle) 
        throws IOException, FileStoreException, InterruptedException{
        log.info("Rollingback transaction \"" + xid + "\".");
        
        recoveryCoordinator.rollback(xid);
        
        FTMContext context = null;
        context = getContext(xid);
        context.rollback(throttle);
        
        Set<RandomAccessAllocator> randCleanMe = new HashSet<RandomAccessAllocator>();
        Set<MjdTimeSeriesStorageAllocator> mjdCleanMe = new HashSet<MjdTimeSeriesStorageAllocator>();
        
        //TODO:  This is O(context.transactionalFiles^2)
        for (int i=0; i < transactionalFiles.length; i++) {
            //log.info("Rollback on transactionalFiles[" + i + "] for xid \"" + xid + "\".");
            Map<FsId, TransactionalFile> xfMap = transactionalFiles[i];
            synchronized (xfMap) {
                cleanIds(xfMap, context, randCleanMe, mjdCleanMe);
            }
        }
            
        recoveryCoordinator.completeTransaction(xid);
        transactionContexts.remove(xid);
        context.done();
        
        // GC files.
        log.info("Garbage collect empty container files.");
        for (RandomAccessAllocator randAllocator : randCleanMe) {
            randAllocator.gcFiles();
        }
        for (MjdTimeSeriesStorageAllocator mjdAllocator : mjdCleanMe) {
            mjdAllocator.gcFiles();
        }
        log.info("Rollback complete.");
    }

    //You should be synchronzed(xfMap) before calling this
    private void cleanIds(Map<FsId, TransactionalFile> xfMap, 
        FTMContext context,
        Set<RandomAccessAllocator> randCleanMe, 
        Set<MjdTimeSeriesStorageAllocator> mjdCleanMe) 
    throws FileStoreException, IOException, InterruptedException {
        
        if (context.isEmpty()) {
            return;
        }
        
        List<FsId> removableIds = new ArrayList<FsId>(context.xfiles().size());
        
        for (TransactionalFile xfile : context.xfiles()) {
            if (!xfile.hasTransactions()) {
                xfMap.remove(xfile.id());
                removableIds.add(xfile.id());
            }
        }
        
        //This is not required but may accelerate B-Tree lookups.
        Collections.sort(removableIds);
        
        // Clean space allocated for TimeSeries and CosmicRaySeries ids.
        for (String path : recoveryCoordinator.randomAccessPath(context.xid())) {
            FsId pathId = new FsId(path, "_");
            RandomAccessAllocator randAlloc = 
                randAllocatorFactory.findAllocator(pathId);
            randAlloc.removeAllNewIds(removableIds);
            randCleanMe.add(randAlloc);
        }
        
        for (String path : recoveryCoordinator.mjdPath(context.xid())) {
            FsId pathId = new FsId(path, "_");
            MjdTimeSeriesStorageAllocator mjdAllocator;
            mjdAllocator = mjdAllocatorFactory.findAllocator(pathId, false);
            mjdAllocator.removeAllNewIds(removableIds);
            mjdCleanMe.add(mjdAllocator);
        }
    }
    
    /**
     * @throws ClassNotFoundException
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#commitLocal(javax.transaction.xa.Xid)
     */
    @Override
    public void commitLocal(Xid xid, ThrottleInterface throttle) throws IOException, FileStoreException,
        InterruptedException {

        log.info("Committing transaction \"" + xid + "\".");
        FTMContext context = null;
        boolean ok = false;
        try {
            context = getContext(xid);
            recoveryCoordinator.commit(xid);

            context.commit(recoveryCoordinator.journalEntryIterator(xid),
                randAllocatorFactory, recoveryCoordinator.mjdJournalEntryIterator(xid), mjdAllocatorFactory);

            // Keeping 2M time series files around will fill up memory.
            for (TransactionalFile xfile : context.xfiles()) {
                Map<FsId, TransactionalFile> xfMap = getMap(xfile.id());
                synchronized (xfMap) {
                    if (!xfile.hasTransactions()) {
                        xfMap.remove(xfile.id());
                    }
                }
            }
            transactionContexts.remove(xid);
            commitBtreeModifications(xid);
            if (syncOnCommit) {
                log.info("Synching data to disk.");
                FileUtil.sync();
            }
            log.info("Transaction \"" + xid + "\" complete.");
            ok = true;
        } catch (ClassNotFoundException cnfe) {
            throw new IllegalStateException(cnfe);
        } finally {

            if (context != null) {
                // Skip cleaning this up when XA fails on commit so that XA can
                // attempt rollback.
                if (context.isXa()) {
                    if (ok) {
                        recoveryCoordinator.completeTransaction(xid);
                        context.done();
                    }
                } else {
                   recoveryCoordinator.completeTransaction(xid);
                   context.done();
                }
            }
        }
    }

    private void commitBtreeModifications(Xid xid) throws IOException,
        ClassNotFoundException, InterruptedException {
        // Write pending btree modifications.
        for (String path : recoveryCoordinator.randomAccessPath(xid)) {
            FsId pathId = new FsId(path, "_");
            RandomAccessAllocator allocator = randAllocatorFactory.findAllocator(pathId);
            allocator.commitPendingModifications();
        }

        for (String path : recoveryCoordinator.mjdPath(xid)) {
            FsId pathId = new FsId(path, "_");
            MjdTimeSeriesStorageAllocator allocator = mjdAllocatorFactory.findAllocator(
                pathId, false);
            allocator.commitPendingModifications();
        }
    }

    @Override
    public boolean prepareLocal(Xid xid, ThrottleInterface throttle) 
        throws IOException, InterruptedException, FileStoreTransactionTimeOut {

        FTMContext context = getContext(xid);

        try {
            commitBtreeModifications(xid);
        } catch (ClassNotFoundException e) {
            throw new IOException("Nested exception.", e);
        }
        
        recoveryCoordinator.prepare(xid);

        if (context.prepare(throttle, ErrorState.ROLLBACK_ON_ERROR)) {
            recoveryCoordinator.commit(xid);
            transactionContexts.remove(xid);
            recoveryCoordinator.completeTransaction(xid);
            context.done();
            return true; //read-only
        }
        return false;
    }

    /**  This is not synchronzied because this is a test method and there is
     * no longer any global synchronization.
     * @see gov.nasa.kepler.fs.server.xfiles.FileTransactionManagerInterface#cleanUp()
     */
    @Override
    public void cleanUp() throws IOException {

        cleanUpInMemoryOnly();
        if (dataDir.exists()) {
            FileUtil.removeAll(dataDir);
        }
        FileUtil.mkdirs(transactionLogDir);
    }

    private void cleanUpInMemoryOnly() throws IOException {
        dataDirLock.releaseLock();
        randAllocatorFactory.clear();
        blobDirHashFactory.clear();
        mjdAllocatorFactory.clear();
        
        ConcurrentLruCache.clearAllCaches();
    }

    @Override
    public void commitXa(Xid xid, boolean singlePhase, ThrottleInterface throttle) throws XAException {
        XAException xax = null;
        
        try {
            throwRecoveredXaException(xid);

            boolean readOnly = false;
            if (singlePhase) {
                readOnly = prepareXa(xid, throttle);
            }
            if (!readOnly) {
                commitLocal(xid, throttle);
            }
            log.info("Commit XA transaction \"" + xid + "\" complete.");
        } catch (FileStoreTransactionTimeOut e) {
            log.error("XA commit failed for transaction \"" + xid + "\".", e);
            xax = new XAException(XAException.XA_RBDEADLOCK);
            xax.initCause(e);
        } catch (IOException e) {
            log.error("XA commit failed for transaction \"" + xid + "\".");
            xax = new XAException(XAException.XA_RBCOMMFAIL);
            xax.initCause(xax);
        } catch (InterruptedException e) {
            log.error("Interrupted exception during xa rollback on transaction \""
                + xid + "\".");
            xax = new XAException(XAException.XA_RBOTHER);
            xax.initCause(e);
        } catch (FileStoreException fse) {
            log.error("XA commit failed for transaction \"" + xid + "\".");
            xax = new XAException(XAException.XA_RBOTHER);
            xax.initCause(fse);
        } catch (RuntimeException re) {
            log.error("Unexpected runtime exception during XA commit for"
                + " transaction \"" + xid + "\".", re);
            xax = new XAException(XAException.XA_HEURHAZ);
            xax.initCause(re);
        }
        if (xax != null) {
            throw xax;
        }
    }

    @Override
    public void rollbackXa(Xid xid, ThrottleInterface throttle) throws XAException {

        try {
            throwRecoveredXaException(xid);

            rollback(xid, throttle);
        } catch (FileStoreTransactionTimeOut e) {
            log.error("XA rollback failed for transaction \"" + xid + "\".", e);
            throw new XAException(XAException.XA_RBDEADLOCK);
        } catch (IOException e) {
            log.error("XA rollback failed for transaction \"" + xid + "\".");
            throw new XAException(XAException.XA_RBCOMMFAIL);
        } catch (InterruptedException e) {
            log.error("Interrupted exception during xa rollback on transaction \""
                + xid + "\".");
            throw new XAException(XAException.XA_RBOTHER);
        } catch (FileStoreException fse) {
            log.error("XA rollback failed for transaction \"" + xid + "\".");
            throw new XAException(XAException.XA_RBOTHER);
        } catch (RuntimeException re) {
            log.error("Unexpected runtime exception during XA rollback for "
                + "transaction \"" + xid + "\".", re);
            throw new XAException(XAException.XA_RBOTHER);
        }
    }

    /**
     * Throws the correct XAException if the specified transaction id has been
     * found to
     * 
     * @param xid
     * @throws XAException
     */
    private void throwRecoveredXaException(Xid xid) throws XAException {
        XidStatus xidStatus = recoveryStartup.staleXaTransaction(xid);
        if (xidStatus != null) {
            if (xidStatus.isXa) {
                switch (xidStatus.state) {
                    case ROLLBACK:
                        throw new XAException(XAException.XA_HEURRB);
                    case HEURISTIC_MIXED:
                        throw new XAException(XAException.XA_HEURMIX);
                    case ERROR:
                        throw new XAException(XAException.XA_HEURHAZ);
                    case COMMITTED:
                        throw new XAException(XAException.XA_HEURCOM);
                    default:
                        throw new XAException("Missing state.");
                }
            }
        }
    }

    @Override
    public void forgetXa(Xid xid) throws XAException {
        try {
            recoveryStartup.forgetXa(xid);
        } catch (IllegalArgumentException iae) {
            throw new XAException(XAException.XAER_NOTA);
        } catch (IOException ioe) {
            throw new XAException(XAException.XAER_RMERR);
        }
    }

    public int getTransactionTimeout(Xid xid) throws XAException {
        return XACTION_AUTOROLLBACK_SECS;
    }

    @Override
    public boolean prepareXa(Xid xid, ThrottleInterface throttle) throws XAException {
        log.info("Prepare XA transaction \"" + xid + "\".");
        boolean ok = false;

        try {
            FTMContext context = getContext(xid);
            try {
                commitBtreeModifications(xid);
            } catch (ClassNotFoundException e) {
                throw new IOException("Nested exception.", e);
            }

            recoveryCoordinator.prepare(xid);

            boolean readOnly = false;
            if (context.prepare(throttle, ErrorState.NO_ROLLBACK_ON_ERROR)) {
                recoveryCoordinator.commit(xid);
                transactionContexts.remove(xid);
                readOnly =  true;
            }
            log.info("Prepare XA transaction \"" + xid + "\" complete.");
            ok = true;
            return readOnly;
        } catch (Exception e) {
            int xaErrCode = XAException.XA_RBOTHER;
            if (e instanceof IOException) {
                xaErrCode = XAException.XA_RBCOMMFAIL;
            } else if (e instanceof FileStoreTransactionTimeOut) {
                xaErrCode = XAException.XA_RBDEADLOCK;
            }
            log.error("XA prepare failed for transaction \"" + xid + "\".", e);
            throw new XAException(xaErrCode);
        } finally {
            if (!ok) {
                log.info("Prepare XA transaction \"" + xid
                    + "\" failed, rolling back.");
                rollbackXa(xid, throttle);
            }
        }
    }

    @Override
    public Xid[] recoverXa(int flags) throws XAException {

        Set<Xid> xidSet = new TreeSet<Xid>(XidComparator.INSTANCE);
        for (XidStatus status : recoveryStartup.staleXaTransactions()) {
            xidSet.add(status.xid);
        }

        xidSet.addAll(transactionContexts.keySet());

        Xid[] xid_a = new Xid[xidSet.size()];
        xidSet.toArray(xid_a);
        return xid_a;
    }

    @Override
    public boolean setTransactionTimeout(Xid xid, int toSecs)
        throws XAException {
        log.info("Set transaction \"" + xid + "\" auto rollbaclk time to "
            + toSecs + "\" seconds.");
        FTMContext context = transactionContexts.get(xid);
        if (context == null) {
            throw new XAException("Transaction \"" + xid + "\" does not exist.");
        }
        context.setRollbackTimeOutSecs(toSecs);
        return true;
    }

    private FTMContext getContext(Xid xid) {
        FTMContext context = transactionContexts.get(xid);
        if (context == null) {
            throw new TransactionNotExistException(xid);
        }
        return context;
    }

    @Override
    public List<TransactionMonitoringInfo> transactionMonitoringInfo()
        throws FileStoreException {
        List<TransactionMonitoringInfo> rv = new ArrayList<TransactionMonitoringInfo>();
        for (FTMContext xContext : transactionContexts.values()) {
            try {
                rv.add(xContext.getMonitoringInfo());
            } catch (OpenDataException e) {
                throw new FileStoreException("Failed to get transaction info.",
                    e);
            }
        }
        return rv;
    }

    /**
     * Used by JMX.
     */
    @Override
    public boolean forceRollback(int simpleId) {
        SortedMap<Xid, FTMContext> xContextCopy = null;
        xContextCopy = new TreeMap<Xid, FTMContext>(transactionContexts);

        FTMContext found = null;
        for (FTMContext xaction : xContextCopy.values()) {
            if (xaction.simpleId() == simpleId) {
                found = xaction;
                break;
            }
        }

        if (found == null) {
            log.warn("Failed to find  transaction with simple id " + simpleId
                + " for rollback.");
            return false;
        }

        try {
            rollback(found.xid(), forceRollbackThrottle);
            log.info("Forced rollback success");
        } catch (Exception e) {
            log.error("Forced rollback failed for transaction with simple id "
                + simpleId + ", xid \"" + found.xid() + "\" and client "
                + found.client() + "\".", e);

            return false;
        }

        return true;

    }

    /**
     * Used by JMX.
     */
    @Override
    public synchronized boolean forceRollback() {
        FTMContext currentTransaction = null;
        try {
            log.info("Forcing rollback of all transactions.");
            SortedMap<Xid, FTMContext> xContextCopy = new TreeMap<Xid, FTMContext>(
                transactionContexts);

            for (FTMContext xaction : xContextCopy.values()) {
                currentTransaction = xaction;
                log.info("Forcing rollback of \"" + xaction.xid()
                    + "\" from client \"" + xaction.client());
                rollback(xaction.xid(), forceRollbackThrottle);
            }

        } catch (Exception e) {
            log.error("Failed to force rollback of transaction \""
                + currentTransaction.xid() + "\" from client \""
                + currentTransaction.client() + "\".");

            log.error("Force rollback of all transactions stopped with "
                + transactionContexts.size() + " remaining.");

            return false;
        }
        return true;
    }

    /**
     * TODO:  allow allocation for scheduling writes.
     * @param xid
     * @param mjdTimeSeries When true schedule for MJD time series when false
     * schedule for TimeSeries.
     * @return
     */
    @Override
    public FsIdLocationFactory locationFactory(Xid xid, boolean mjdTimeSeries) {
        final StorageAllocatorFactory<?> storageAllocatorFactory = (mjdTimeSeries) ?
                FileTransactionManager.this.mjdAllocatorFactory
            :
                FileTransactionManager.this.randAllocatorFactory;
        
        return new FsIdLocationFactory() {
            @Override
            public List<FsIdLocation> locationFor(List<FsIdOrder> ids)
                throws FileStoreException, IOException, InterruptedException {
                    
                Collections.sort(ids, new FsIdOrderCompareById());  //optimize btree access.
                ArrayList<FsIdLocation> rv = new ArrayList<FsIdLocation>(ids.size());
                for (FsIdOrder idOrder : ids) {
                    StorageAllocatorInterface allocator = storageAllocatorFactory
                        .findAllocator(idOrder.id(), false);
                    if (allocator == null) {
                        rv.add(new FsIdLocation(idOrder.id(), idOrder.originalOrder()));
                    } else {
                        rv.add(allocator.locationFor(idOrder));
                    }
                }
                return rv;
            }
        };
    }

    @Override
    public Pair<Long, Long> metadataCounterStats() {
        return Pair.of(trafMetadataCache.metadataMissCount(),
                trafMetadataCache.metdataHitCount());
    }
    
}
