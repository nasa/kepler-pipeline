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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TransactionClosedException;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.journal.ConcurrentJournalWriter;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.journal.JournalStreamReader;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.journal.SerialJournalWriter;
import gov.nasa.kepler.fs.server.journal.ModifiedFsIdJournal;
import gov.nasa.kepler.fs.storage.DirectoryHashFactory;
import gov.nasa.kepler.fs.storage.MjdTimeSeriesStorageAllocatorFactory;
import gov.nasa.kepler.fs.storage.RandomAccessAllocatorFactory;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.*;

import static java.util.Collections.synchronizedMap;
import static java.util.Collections.synchronizedSet;

import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import com.google.common.collect.ImmutableSet;

/**
 * Coordinates the startup of the server; makes sure that all files that where
 * involved in transactions when the server shutdown are in a clean state.
 * 
 * Each transaction log file is formatted as follows.  Each line is terminated
 * by a new line character.  The first line contains the status of the file. It is
 * either prepairing, committing, clean or dead.  If it is dead then it is an xa transaction
 * that has been prepared and recovered and we are waiting for the
 * transaction manager to ask about it so we can remove the file.  This file
 * has one line.  The first character marks it as dead, the remaining 
 * characters indicate the state of the transaction.  Other files are formatted
 * so that the first line contains one character which indicates if the
 * transaction was prepaired or not.  The subsequent lines contain space
 * seperated pairs of file type R (TransactionalRandomAccessFile) followed by
 * the directory of the TimeSeriesDirHash.  Or S (TransactionalStreamFile)
 * followed by the FsId of the stream file. The final line in the file is
 * suffixed with an O and then followed by an integer.
 * 
 * @author Sean McCauliff
 *
 */
class RecoveryCoordinator extends RecoveryBase implements ModifiedFsIdJournal {

    private static final Log log = LogFactory.getLog(RecoveryCoordinator.class);
    private final Map<Xid, TransactionContext> xactions =
        synchronizedMap(new TreeMap<Xid, TransactionContext>(XidComparator.INSTANCE));
    
    private final CommitOrderIdGenerator orderGenerator;
    
    /**
     * Create a new recovery coordinator.  This won't do any recovery.  You
     * need to call the recover() method.
     * 
     * @param logDir
     * @param tsDirHashFactory The directory hash factory used when 
     * recovery TransactionalRandomAccessFile.
     * @throws IOException
     */
    RecoveryCoordinator(File logDir, DirectoryHashFactory blobDirHashFactory,
                                                   RandomAccessAllocatorFactory tsDirHashFactory,
                                                   MjdTimeSeriesStorageAllocatorFactory crAllocatorFactory,
                                                   CommitOrderIdGenerator orderGenerator)
        throws IOException {
        
        super(logDir, blobDirHashFactory, tsDirHashFactory, crAllocatorFactory);
        this.orderGenerator = orderGenerator;
        
    }
    
    void addRandomAccess(FsId id, Xid xid) throws IOException {
        TransactionContext xaction = xactions.get(xid);
        xaction.addRandomAccess(id);
    }
    
    
    
    /**
     * Lazly allocates a file that tracks the TransactionalFiles involved in a
     * transaction.
     * 
     * @param xis
     * @throws IOException
     */
    synchronized void beginTransaction(Xid xid, boolean isXa) throws IOException {
        if (xactions.containsKey(xid)) {
            return; //transaction has already begun.
        }
        
       xactions.put(xid, new TransactionContext(xid, isXa));
    }
    
    JournalWriter journalWriter(Xid xid) throws IOException {
        TransactionContext xaction = xactions.get(xid);
        return xaction.journalWriter();
    }
    
    JournalWriter mjdJournalWriter(Xid xid) throws IOException {
        TransactionContext xaction = xactions.get(xid);
        return xaction.cosmicRayJournalWriter();
    }
    

    void addMjdFile(FsId id, Xid xid) throws IOException {
        TransactionContext context = xactions.get(xid);
        context.addMjdFile(id);
    }

    
    /**
     * This should be called after commit. It removes all journal files and
     * removes the transaction file.  All state has been removed after this
     * method returns.
     * 
     * @param xid
     * @throws IOException
     * @throws InterruptedException 
     */
   synchronized void completeTransaction(Xid xid) throws IOException, InterruptedException {
       TransactionContext context = xactions.get(xid);
       context.completeTransaction();
       xactions.remove(xid);
    }
    
    
//    void addStreamFile(Xid xid, TransactionalStreamFile xfile, FsId id) throws IOException {
//        TransactionContext xaction = xactions.get(xid);
//        xaction.addStreamFile(xfile, id);
//    }
   
   /**
    * This should be called when a TransactionalStreamFile has been modified
    * by a transaction.
    * @param xid The transaction
    * @param id The FsId of a TransactionalStreamFile
    */
   public void fileModified(Xid xid, FsId id) throws IOException {
       TransactionContext xaction = xactions.get(xid);
       xaction.addStreamFile(id);
   }
   
    
    /**
     * This must be called when the transaction first starts into the prepare 
     * phase.  
     * 
     * @param xid
     * @throws IOException
     */
    void prepare(Xid xid) throws IOException {
        TransactionContext xaction = xactions.get(xid);
        xaction.prepareReached();
    }
    
    /**
     * This must be called if the transaction starts a rollback before the 
     * prepare state has been reached.  If prepare has been reached then calling
     * this method is optional.
     */
    void rollback(Xid xid) throws IOException {
        TransactionContext xaction = xactions.get(xid);
        xaction.rollbackReached();
    }
    
    /**
     * This must be called when the transaction first starts into the commit
     * phase.
     * @param xid
     * @throws IOException
     * @throws InterruptedException 
     */
    void commit(Xid xid) throws IOException, InterruptedException {
        TransactionContext xaction = xactions.get(xid);
        xaction.commitReached();
    }
    
    Set<String> randomAccessPath(Xid xid) {
        TransactionContext xaction = xactions.get(xid);
        return xaction.randomAccessPath();
    }
    
    Set<String> mjdPath(Xid xid) {
        TransactionContext xaction = xactions.get(xid);
        return xaction.mjdPath();
    }
    
    Iterator<JournalEntry> journalEntryIterator(Xid xid) throws IOException {
        TransactionContext xaction = xactions.get(xid);
        return xaction.journalEntries();
    }
    
    Iterator<JournalEntry> mjdJournalEntryIterator(Xid xid) throws IOException  {
        TransactionContext xaction = xactions.get(xid);
        return xaction.mjdJournalEntries();
    }
    private class TransactionContext {
        private final File logFile;
        private BufferedWriter logWriter;
        private JournalWriter journalWriter;
        private final Xid xid;
        private boolean logWriterClosed = false;
        private JournalWriter mjdJournalWriter;
        private JournalStreamReader journalReader;
        private JournalStreamReader mjdJournalReader;
        
        /**
         * Directory hashes that may need cleaning up.
         */
        private Set<String> randomAccessPath = 
            synchronizedSet(new HashSet<String>());
        
        private Set<String> mjdPath = 
            synchronizedSet(new HashSet<String>());
        
        TransactionContext(Xid xid, boolean isXa) {
            this.xid = xid;
            String fname = Util.xidToString(this.xid);
            fname += ((isXa) ? LOG_FILE_SUFFIX_XA : LOG_FILE_SUFFIX_LOCAL);
            logFile = new File(logDir, fname);
        }

        synchronized Set<String> mjdPath() {
            return ImmutableSet.copyOf(mjdPath);
        }

        synchronized void addRandomAccess(FsId id) throws IOException {
            String path = id.path();
            if (randomAccessPath.contains(path)) {
                return;
            }
            
           randomAccessPath.add(path);
           initLogFile();
           logWriter.append(TYPE_RANDOM);
           logWriter.append(" ");
           logWriter.append(path);
           logWriter.append("\n");
           logWriter.flush();
        }
        
        synchronized void addMjdFile(FsId id) throws IOException {
            String path = id.path();
            
            if (mjdPath.contains(path)) {
                return;
            }
            
            initLogFile();
            
            mjdPath.add(id.path());
            
            logWriter.append(TYPE_MJD);
            logWriter.append(" ");
            logWriter.append(path);
            logWriter.append("\n");
            logWriter.flush();
            
        }
        
        synchronized void addStreamFile(FsId id) throws IOException {
            initLogFile();
          
            logWriter.append(TYPE_STREAM);
            logWriter.append(" ");
            logWriter.append(id.toString());
            logWriter.append('\n');
            logWriter.flush();
        }
        
        private void initLogFile() throws IOException {
            if (logWriterClosed) {
                throw new TransactionClosedException("Transaction \"" + xid + 
                    "\" can no longer enroll new files.");
            }
            if (logWriter == null) {
                logWriter = new BufferedWriter(new FileWriter(logFile));
                logWriter.write(XStateReached.CLEAN.toChar());
                logWriter.write('\n');
            }
        }
        
        //Leave file open for later.
        synchronized JournalWriter journalWriter() throws IOException {
            initLogFile();
            
            if (journalWriter == null) {
                File journalFile = new File(logDir, Util.xidToString(xid) + JOURNAL_SUFFIX);
                journalWriter = new ConcurrentJournalWriter(journalFile, xid);
            }
            return journalWriter;
        }
        
        //Leave file open for later.
        synchronized JournalWriter cosmicRayJournalWriter() throws IOException {
            initLogFile();
            
            if (mjdJournalWriter == null) {
                File journalFile = new File(logDir, Util.xidToString(xid) + MJD_JOURNAL_SUFFIX);
                //TODO:  the concurrent journal writer's openStream method is
                //not very concurrent so there is not much point in using the
                //concurrent version of a journal writer.
                mjdJournalWriter = new SerialJournalWriter(journalFile, xid);
            }
            return mjdJournalWriter;
        }
        
        synchronized Set<String> randomAccessPath() {
            return ImmutableSet.copyOf(randomAccessPath);
        }
        synchronized void commitReached() throws IOException, InterruptedException {
            if (journalWriter != null) {
                journalWriter.close();
            }
            if (mjdJournalWriter != null) {
                mjdJournalWriter.close();
            }
            newStateReached(XStateReached.COMMITTING);
        }
        
        synchronized void prepareReached() throws IOException {
            newStateReached(XStateReached.PREPAIRING);
        }
        
        synchronized void rollbackReached() throws IOException {
            newStateReached(XStateReached.ROLLBACK);
        }
        
        synchronized Iterator<JournalEntry> journalEntries() throws IOException {
            if (journalWriter == null) {
                return null;
            }
            if (!journalWriter.isClosed()) {
                throw new IllegalStateException("journal is not closed");
            }
            if (journalReader != null) {
                throw new IllegalStateException("journal entry iterator already initialized");
            }
            journalReader = new JournalStreamReader(journalWriter.file());
            return journalReader;
        }
        
        synchronized Iterator<JournalEntry> mjdJournalEntries() throws IOException {
            if (mjdJournalWriter == null) {
                return null;
            }
            if (!mjdJournalWriter.isClosed()) {
                throw new IllegalStateException("mjd journal is not closed");
            }
            if (mjdJournalReader != null) {
                throw new IllegalStateException("mjd journal entry iterator already initialized");
            }
            mjdJournalReader = new JournalStreamReader(mjdJournalWriter.file());
            return mjdJournalReader;
        }
        private void newStateReached(XStateReached newState) throws IOException {
            
            if (logWriter == null) {
                //No files where ever involved in this transaction.
                return;
            }

            if (!logWriterClosed) {
                logWriter.append(ORDER + " " + orderGenerator.nextOrder() + "\n");
                logWriter.close();
                logWriterClosed = true;
            }

            //We don't need to persist knowledge of a rollback since the
            //recovery code will perform a rollback.
            if (newState != XStateReached.ROLLBACK) {
                RandomAccessFile raf = new RandomAccessFile(logFile, "rw");
                try {
                    raf.writeByte(newState.toByte());
                } finally {
                    raf.close();
                }
            }
        }
        
        /**
         * This can throw Interrupted excpetion but really we don't want it to throw any
         * other exception.
         * 
         * @throws InterruptedException
         */
        synchronized void completeTransaction() throws InterruptedException {
            
            if (!logWriterClosed) {
                FileUtil.close(logWriter);
            }
            
            if (!logFile.delete()) {
                log.warn("Failed to delete transaction log \"" + logFile + "\".");
            }
            
            if (journalWriter != null) {
                FileUtil.close(journalWriter);
                if (!journalWriter.file().delete()) {
                    log.warn("Failed to delete journal file \"" + journalWriter.file() + "\".");
                }
                journalWriter = null;
            }
            if (mjdJournalWriter != null) {
                FileUtil.close(mjdJournalWriter);
                if (!mjdJournalWriter.file().delete()) {
                    log.warn("Failed to delete mjd journal file \"" +
                            mjdJournalWriter.file() + "\".");
                }
                mjdJournalWriter = null;
            }
            
            if (journalReader != null) {
               FileUtil.close(journalReader);
               journalReader = null;
            }
            if (mjdJournalReader != null) {
                FileUtil.close(mjdJournalReader);
                mjdJournalReader = null;
            }
            
        }
        
    }

}
