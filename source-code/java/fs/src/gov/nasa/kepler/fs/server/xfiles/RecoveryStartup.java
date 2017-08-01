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
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.journal.JournalStreamReader;
import gov.nasa.kepler.fs.storage.*;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.concurrent.DaemonThreadFactory;
import gov.nasa.spiffy.common.concurrent.MiniWork;
import gov.nasa.spiffy.common.concurrent.MiniWorkPool;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.util.*;
import java.util.concurrent.ConcurrentSkipListSet;
import java.util.concurrent.ThreadFactory;

import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import static gov.nasa.kepler.fs.server.xfiles.CommitUtils.*;


/**
 * Cleans up the state of previous transactions during system startup.  Puts
 * database back into a consistent state.
 * 
 * @author Sean McCauliff
 *
 */
public class RecoveryStartup extends RecoveryBase {

    private static final Log log = LogFactory.getLog(RecoveryStartup.class);
    
    /**
     * This holds the state of the recovered XA transactions until the
     * XA transaction manager needs them.
     */
    private final Map<Xid, XidStatus> recoveredXa =
        Collections.synchronizedMap(new TreeMap<Xid, XidStatus>(XidComparator.INSTANCE));
    
    /**
     * @param logDir
     * @param tsDirHashFactory
     * @param blobDirHashFactory
     * @throws IOException
     */
    public RecoveryStartup(File logDir, 
        DirectoryHashFactory blobDirHashFactory,
        RandomAccessAllocatorFactory tsDirHashFactory,
        MjdTimeSeriesStorageAllocatorFactory crAllocatorFactory) throws IOException {
        super(logDir, blobDirHashFactory, tsDirHashFactory, crAllocatorFactory);
    }

    
    /**
     * Finds all the TransactionalFiles that were open and puts them into
     * a clean state.  For each Xid that was in progress it reports if it was
     * rolledback successfully, there is a heuristic mixed result or an error
     * occurred.  XA transaction files are held until a transactionComplete()
     * is called for that transaction.
     *
     *@exception java.lang.Exception This throws Exception  because 
     * otherwise there would be
     * a dozen or so different exceptions that might get thrown.
     */
    public synchronized List<XidStatus> recover() throws Exception {
        
        log.info("Starting recovery.");
        
        List<XidStatus> status = new ArrayList<XidStatus>();
        File[] foundLogs = logDir.listFiles(new FileFilter() {

            public boolean accept(File pathname) {
                String name = pathname.getName();
                return name.endsWith(LOG_FILE_SUFFIX_LOCAL) ||
                            name.endsWith(LOG_FILE_SUFFIX_XA);
            }
        });
        
        log.info("Found " + foundLogs.length +
                                " transactions needing recovery.");
        
        //These hold the roots of the directory hashes that were
        //modified in all transactions.  These are accumulated so that
        //later we can update the state of their storage allocators to either
        //rollback their storage allocation or commit it.
        Set<String> randFileDirectories = new HashSet<String>();
        Set<String> mjdFileDirectories = new HashSet<String>();
        
        boolean performRecovery = true;
        for (File found : foundLogs) {
            Xid xid = xidFromFile(found);
            boolean isXa = found.getName().endsWith(LOG_FILE_SUFFIX_XA);
            ParsedLogFile parsedLogFile = 
                recoverSingleTransaction(xid, found, isXa);
            if (parsedLogFile.status.state == XidStatus.State.ERROR) {
                log.error("Will not perform recovery since transaction \"" + xid + 
                    "\" is in error state.");
                performRecovery = false;
            }
            status.add(parsedLogFile.status);
            randFileDirectories.addAll(parsedLogFile.randFileDirectories);
            mjdFileDirectories.addAll(parsedLogFile.mjdFileDirectories);
        }
        
        if (!performRecovery) {
            throw new RecoveryException("Recovery can not proceed.");
        }

        removeNewFiles(randFileDirectories, mjdFileDirectories);

        deleteTransactionLogs(foundLogs);
        
        boolean doFileSync = 
            ConfigurationServiceFactory.getInstance().getBoolean(
                FS_SERVER_SYNC_ON_RECOVERY, FS_SERVER_SYNC_ON_RECOVERY_DEFAULT);
                
        if (doFileSync) {
            log.info("Syncing data to disk.");
            FileUtil.sync();
        }
        
        log.info("Recovery complete.");
        return status;
    }


    /**
     * Cleans random access files and mjd indexed files that need to be removed
     * .
     * @param randFileDirectories
     * @param crFileDirectories
     * @throws FileStoreException
     * @throws IOException
     * @throws ClassNotFoundException
     * @throws InterruptedException 
     */
    private void removeNewFiles(Set<String> randFileDirectories, 
        Set<String> crFileDirectories) 
    throws FileStoreException, IOException, ClassNotFoundException, InterruptedException {
        
        log.info("Remove new random access files that were rolledback.");
        for (String dirName : randFileDirectories) {
            FsId idBase = new FsId(dirName, "a");
            RandomAccessAllocator allocator = 
                    randAllocatorFactory.findAllocator(idBase);
            if (allocator == null) {
                log.warn("Expected to find a storage allocator for \"" + idBase
                    + "\" but did not find one.  This can happen if the" +
                    " transaction neeed a new directory, registered with the" +
                    " RecoveryCoordinator and was then interrupted.  Or it" +
                    " could be a sign of a missing directory which could" +
                    " have dire consequences.");
                continue;
            }
            allocator.removeAllNewIds();
            allocator.commitPendingModifications();
            allocator.gcFiles();
        }
        for (String dirName : crFileDirectories) {
            FsId idBase = new FsId(dirName, "a");
            MjdTimeSeriesStorageAllocator allocator =
                mjdAllocatorFactory.findAllocator(idBase, false);
            if (allocator == null) {
                log.warn("Expected to find a storage allocator for \"" + idBase
                    + "\" but did not find one.  This can happen if the" +
                    " transaction neeed a new directory, registered with the" +
                    " RecoveryCoordinator and was then interrupted.  Or it" +
                    " could be a sign of a missing directory which could" +
                    " have dire consequences.");
                continue;
            }
            allocator.removeAllNewIds();
            allocator.commitPendingModifications();
            allocator.gcFiles();
        }
    }


    /**
     * @param foundLogs
     * @throws IOException
     */
    private void deleteTransactionLogs(File[] foundLogs) throws IOException {
        log.info("Delete transaction logs.");
        for (File logFile : foundLogs) {
            Xid xid = xidFromFile(logFile);
            if (logFile.getName().endsWith(LOG_FILE_SUFFIX_XA)) {
                if (recoveredXa.containsKey(xid)) {
                    //Save this state until the transaction manager needs to remove it.
                    saveXaState(logFile);
                } else {
                    if (!logFile.delete()) {
                        log.error("Unable to delete XA " +
                            "transaction log file \"" + logFile + "\".");
                    }
                }
            } else if  (!logFile.delete()) {
                log.error("Unable to delete transaction log file \"" + logFile + "\".");
            }
           
            
            String journalFileName =
                Util.xidToString(xid) + JOURNAL_SUFFIX;
            File journalFile = new File(logDir, journalFileName);
            if (journalFile.exists()) {
                if (!journalFile.delete()) {
                    log.warn("Failed clean up journal file \"" + journalFile + "\".");
                }
            }
            
            String mjdJournalFileName =
            	Util.xidToString(xid) + MJD_JOURNAL_SUFFIX;
            File mjdJournalFile = new File(logDir, mjdJournalFileName);
            if (mjdJournalFile.exists()) {
            	if (!mjdJournalFile.delete()) {
            		log.warn("Failed to clean up mjd journal file \"" + journalFile + "\".");
            	}
            }
            
        }
    }
    


    /**
     * Recover a single transaction.  Do not complete the recovery on
     * stream files since they need to know about all the transactions they
     * were involved with.
     */
    private ParsedLogFile recoverSingleTransaction(Xid xid, File logFile, 
                              boolean isXa) 
        throws Exception {
        
        BufferedReader reader = null;
        JournalStreamReader journalReader = null;
        JournalStreamReader mjdJournalReader  = null;
        
        String journalFileName =  Util.xidToString(xid) + JOURNAL_SUFFIX;
        String mjdJournalFileName =  Util.xidToString(xid) + MJD_JOURNAL_SUFFIX;

        File journalFile = new File(logDir, journalFileName);
        File mjdJournalFile = new File(logDir, mjdJournalFileName);
        
        boolean prepared = false;
        
        try {
            reader = new BufferedReader(new FileReader(logFile));
            String statusLine = reader.readLine();
            if (statusLine == null) {
                //The last process did not completely finish writing this line so it is ok
                //to just ignore this transaction.
                XidStatus xidStatus = new XidStatus(XidStatus.State.ROLLBACK, xid, isXa, false, BAD_ORDER);
                return new ParsedLogFile(xidStatus);
            }
            
            XStateReached stateReached = XStateReached.valueOf(statusLine.charAt(0));
            prepared = stateReached == XStateReached.PREPAIRING || 
                                    stateReached == XStateReached.COMMITTING;
            
            if (stateReached == XStateReached.DEAD) {
                log.warn("Found dead XA transaction that no one has asked about." +
                        " Consider removing file \"" + logFile +  "\".");
                String statusString = statusLine.substring(1);
                XidStatus.State actualState = XidStatus.State.valueOf(statusString);
                
                XidStatus dead = new XidStatus(actualState,xid, true, true, BAD_ORDER);
                recoveredXa.put(xid, dead);
                return new ParsedLogFile(dead);
            }
            
            XidStatus.State state = null;
            if (stateReached == XStateReached.COMMITTING) {
            	if (journalFile.exists()) {
            	    journalReader = new JournalStreamReader(journalFile);
                }
                if (mjdJournalFile.exists()) {
                    mjdJournalReader = new JournalStreamReader(mjdJournalFile);
                }
                state = XidStatus.State.COMMITTED;
            } else {
                if (journalFile.exists()) {
                    if (!journalFile.delete()) {
                        log.warn("Failed to remove journal file \"" + journalFile + "\".");
                    }
                }
                if (mjdJournalFile.exists()) {
                    if (!mjdJournalFile.delete()) {
                        log.warn("Failed to remove journal file \"" + mjdJournalFileName + "\".");
                    }
                }
                state = XidStatus.State.ROLLBACK;
            }
            
            ParsedLogFile parsedLogFile = 
                parseLogFile(xid, reader, state, prepared, isXa);
            
            //recover all the random access and cosmic ray transactional files.
            if (stateReached == XStateReached.COMMITTING) {
                recoverRandomAccess(journalReader, xid);
                recoverMjd(mjdJournalReader, xid);
                recoverStream(parsedLogFile.streamFsIds, xid, true);
            } 
            
                
            if (prepared && isXa) {
                recoveredXa.put(xid, parsedLogFile.status);
            }
            
            return parsedLogFile;
            
        } finally {
            FileUtil.close(journalReader);
            FileUtil.close(mjdJournalReader);
            FileUtil.close(reader);
        }
    }

    /**
     * Gathers all the recoverable FsIds forTransactionalStreamFiles from a
     * particular transaction.
     * 
     * @param xid the transaction for the log.
     * @param reader A reader open the the log file to be parsed.
     * @param prepared True if the transaction reached the commit state.
     * @return
     * @throws IOException
     * @throws FileStoreException
     * @throws InterruptedException
     */
    private ParsedLogFile parseLogFile(Xid xid, 
                                       BufferedReader reader,
                                       XidStatus.State state,
                                       boolean prepared,
                                       boolean isXa) 
        throws IOException, FileStoreException, InterruptedException {
        
        Set<String> randFileDirectories = new HashSet<String>();
        Set<String> mjdFileDirectories = new HashSet<String>();
        Set<FsId> streamFsIds = new HashSet<FsId>();
        int commitOrder = BAD_ORDER;
        
        // Not using readLine() here because I might not be able to detect a
        // line that was partially written.
        StringBuilder bldr = new StringBuilder();
        for (int intChar = reader.read();
                intChar != -1; 
                intChar = reader.read()) { 
            
            char c = (char) intChar;
            if (c != '\n') {
                bldr.append(c);
                continue;
            }

            String line = bldr.toString();
            bldr.setLength(0);

            int spaceIndex = line.indexOf(' ');
            if (spaceIndex != 1) {
                throw new RecoveryException("Invalid recovery log for \"" + xid 
                    + "\".  Bad line \"" + line + "\".");
            }
            String[] parts = line.split("\\s+");

            String type = parts[0];
            String fileOrDirName = parts[1];
            
            if (type.equals(TYPE_STREAM)) {
                FsId fsId = new FsId(parts[1]);
                streamFsIds.add(fsId);
            } else if (type.equals(TYPE_RANDOM)){
                randFileDirectories.add(fileOrDirName);
            } else if (type.equals(TYPE_MJD)) {
                mjdFileDirectories.add(fileOrDirName);
            } else if (type.equals(ORDER)) {
                //TODO:  This does not matter much right now, but when we allow for
                //more than one unmerged commit per FsId it will be needed to get
                //the merge order right.
                commitOrder = Integer.parseInt(fileOrDirName);
                break;
            } else {
                throw new RecoveryException("Invalid recovery log for \"" + xid 
                    + "\".  Bad line \"" + line + "\".");
            }
        }
        
        XidStatus status = new XidStatus(state, xid, isXa, prepared, commitOrder);
        return new ParsedLogFile(streamFsIds, randFileDirectories, 
            mjdFileDirectories, status);
    }
    
    private void recoverStream(Set<FsId> streamFsIds, Xid xid, boolean isCommitted) 
        throws FileStoreException, IOException {
        
        log.info("Recovering " + streamFsIds.size() + " transactional stream files.");
        for (FsId streamFsId : streamFsIds) {
            DirectoryHash dirHash = blobDirHashFactory.findDirHash(streamFsId, true);
            File targetFile = dirHash.idToFile(streamFsId.name());
            TransactionalStreamFile.Recovery xsFileRecovery = 
                TransactionalStreamFile.recover(targetFile, streamFsId);
            xsFileRecovery.mergeRecovery(xid, isCommitted);
            xsFileRecovery.completeRecovery();
        }
    }
    
    private void recoverRandomAccess(JournalStreamReader journalReader, Xid xid) 
        throws IOException, FileStoreException, InterruptedException {
        
    
        if (journalReader == null) {
            return;
        }
        
        ThreadFactory threadFactory = 
            new DaemonThreadFactory(xid.toString() + " time series recovery");
        
        final Set<FsId> seenSet = new ConcurrentSkipListSet<FsId>();
        final int nThreads = numberOfRecoveryDistributerThreads();
        RandomAccessJournalConsumer<RandomAccessAllocator> consumer = 
            new RandomAccessJournalConsumer<RandomAccessAllocator>(seenSet, randAllocatorFactory, randomAccessRecoveryFactory);
        OneToManyRouter<JournalEntry> journalEntryRouter =
            new OneToManyRouter<JournalEntry>(nThreads, threadFactory,
                RECOVERY_CONSUMER_QUEUE_LENGTH,
                 consumer, journalReader, HashJournalEntryByFsId.INSTANCE,
                "Processed %d recovery entries.");
        journalEntryRouter.start();
        
        journalEntryRouter.waitForConsumersToComplete();
        
        consumer.completeRecovery();
        
        markIdsPersistent(randAllocatorFactory.accessedAllocators(), seenSet);
    }
    
    
    private int numberOfRecoveryDistributerThreads() {
        int nThreads = ConfigurationServiceFactory.getInstance().getInt(FS_SERVER_MAX_CONCURRENT_READ_WRITE,
                                                         FS_SERVER_MAX_CONCURRENT_READ_WRITE_DEFAULT);
        if (nThreads < 1) {
            throw new IllegalStateException(FS_SERVER_MAX_CONCURRENT_READ_WRITE + " must be greater than 0");
        }
        return nThreads;
    }
    
    /**
     * Marks new files as committed in parallel.
     * @param <W>
     * @param involvedAllocators
     * @param fsIds
     * @throws InterruptedException
     * @throws IOException
     */
    private <W  extends StorageAllocatorInterface> 
    void markIdsPersistent(final Collection<W> involvedAllocators, final Set<FsId> fsIds) 
        throws InterruptedException, IOException {
        
        if (fsIds.isEmpty()) {
            return;
        }
        
        log.info("Marking " + fsIds.size() + " FsIds persistent.");
        MiniWorkPool<W> workerPool = 
            new MiniWorkPool<W>("fs recovery", 
                involvedAllocators, new MiniWork<W>() {

                    @Override
                    protected void doIt(W work) throws Throwable {
                        work.markIdsPersistent(fsIds);
                        work.commitPendingModifications();
                    }
                });
        workerPool.performAllWork();
    }
    
    private void recoverMjd(JournalStreamReader journalReader, Xid xid) 
        throws FileStoreTransactionTimeOut, FileStoreException, IOException,
               InterruptedException, ClassNotFoundException {
        
        if (journalReader == null) {
            return;
        }
        
        ThreadFactory threadFactory = 
            new DaemonThreadFactory(xid.toString() + " mjd time series recovery");
        
        final Set<FsId> seenSet = new ConcurrentSkipListSet<FsId>();
        final int nThreads = numberOfRecoveryDistributerThreads();
        RandomAccessJournalConsumer<MjdTimeSeriesStorageAllocator> consumer = 
            new RandomAccessJournalConsumer<MjdTimeSeriesStorageAllocator>(seenSet, mjdAllocatorFactory, mjdRecoveryFactory);
        OneToManyRouter<JournalEntry> journalEntryRouter =
            new OneToManyRouter<JournalEntry>(nThreads, threadFactory,
                RECOVERY_CONSUMER_QUEUE_LENGTH,
                consumer, journalReader, HashJournalEntryByFsId.INSTANCE,
                "Processed %d recovery entries.");
        journalEntryRouter.start();
        
        journalEntryRouter.waitForConsumersToComplete();
        
        consumer.completeRecovery();
        
        markIdsPersistent(mjdAllocatorFactory.accessedAllocators(), seenSet);
       
    }
    
    /**
     * Overwrites an xa transaction file with dead information.
     *
     */
    private void saveXaState(File xaFile) throws IOException {
        Xid xid = xidFromFile(xaFile);
        XidStatus status = this.recoveredXa.get(xid);
        StringBuilder bldr = new StringBuilder();
        bldr.append(XStateReached.DEAD.toChar());
        bldr.append(status.state.name());
        bldr.append('\n');
        FileWriter fWriter = new FileWriter(xaFile);
        fWriter.append(bldr);
        fWriter.close();
    } 
    
    /**
     * Gets the status information for a recovered XA transaction.
     * @param xid
     * @return
     */
    XidStatus staleXaTransaction(Xid xid) {
        return recoveredXa.get(xid);
    }
    
    /** 
     * All the Xa transactions that we know about that the XA transaction
     * manager may still need to know about.
     * 
     * @return A list of zero length if none are known.
     */
    List<XidStatus> staleXaTransactions() {
        synchronized (this.recoveredXa) {
            List<XidStatus> stale = 
                new ArrayList<XidStatus>(recoveredXa.values());
            return stale;
        }
    }
    
    public synchronized void forgetAllXa() throws IllegalArgumentException, IOException {
        for (XidStatus xidStatus : staleXaTransactions()) {
            log.info("Removing stale xid \"" + xidStatus.xid + "\".");
            forgetXa(xidStatus.xid);
        }
    }
    /**
     * @excepton java.lang.IllegalArgumentException If the xid can not be
     * found.
     */
    synchronized void forgetXa(Xid xid) 
                    throws IllegalArgumentException, IOException {

        if (!recoveredXa.containsKey(xid)) {
            throw new IllegalArgumentException("Xid not found.");
        }
        recoveredXa.remove(xid);

        File transactionLog =
            new File(logDir, Util.xidToString(xid) + LOG_FILE_SUFFIX_XA);
        if (!transactionLog.delete()) {
            log.error("Failed to delete xa transaction log \"" + transactionLog 
                + "\".");
            throw new IOException("Failed to forget XA transaction.");

        }
    }
    
    /**
     * What is known about a recovered transaction from parsing the transaction
     * log.
     *
     */
    private static class ParsedLogFile {
        final Set<FsId> streamFsIds; 
        final Set<String> randFileDirectories;
        final Set<String> mjdFileDirectories; 
        final XidStatus status;
        
        private ParsedLogFile(Set<FsId> streamFsIds,
            Set<String> randFileDirectories, Set<String> crFileDirectories,
            XidStatus xidStatus) {
            
            this.streamFsIds = Collections.unmodifiableSet(streamFsIds);
            this.randFileDirectories = Collections.unmodifiableSet(randFileDirectories);
            this.mjdFileDirectories = Collections.unmodifiableSet(crFileDirectories);
            this.status = xidStatus;
        }
        
        private ParsedLogFile(XidStatus xidStatus) {
            this.status = xidStatus;
            streamFsIds = Collections.emptySet();
            randFileDirectories = Collections.emptySet();
            mjdFileDirectories = Collections.emptySet();
        }
    }
    
}
