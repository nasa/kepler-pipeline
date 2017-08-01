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

import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TransactionNotExistException;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.server.ReadableBlob;
import gov.nasa.kepler.fs.server.WritableBlob;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.journal.ModifiedFsIdJournal;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.*;
import java.nio.channels.FileChannel;
import java.util.*;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Streams changes to files transactionally. Can only be opened in read or write
 * mode by a single transaction. This is faster than using
 * TransactionalRandomAccessFile when entire files need to be written to or read
 * from. There should only be one instance of this class for a particular file.
 * Only one transaction can be in the processing of committing at a time.
 * 
 * <pre>
 * This file is stored as:
 *  [1 byte version]
 *  [1 byte new flag]
 *  [8 byte origin]
 *  [data]
 * </pre>
 * 
 * @author Sean McCauliff
 * 
 */
public class TransactionalStreamFile extends TransactionalFile {

    /**
     * The version of the on disk format. This should be incremented every time
     * the format changes. 
     * 0 -Initial revision. 
     * 1- origin size is long, removed
     * some useless header info 
     * 2 - actually this did not change, but there was
     * a bug higher up with some garbage data being put at the beginning of this
     * file.
     * 3 - Add deleted state, so the new flag actually becomes a state
     * field.  This is backwards compatible with version 2.
     */
    private static final byte COMPATIBLE_VERSION = 2;
    private static final byte FORMAT_VERSION = 3;
    
    private static final byte OLD_STATE = 0;
    private static final byte NEW_STATE = 1;
    private static final byte DELETED_STATE = 2;

    private static final long UNKNOWN_ORIGIN = -1L;

    private static final Log log = LogFactory.getLog(TransactionalStreamFile.class);

    private final Map<Xid, TransactionContext> xactions = 
        Collections.synchronizedSortedMap(new TreeMap<Xid, TransactionContext>(XidComparator.INSTANCE));

    private static final int HEADER_SIZE = 10;

    private static final String ROLLBACK = "rollback";

    private static final String DIRTY_SUFFIX = ".dirty";

    
    
    private long origin = UNKNOWN_ORIGIN;
    
    private byte newState = NEW_STATE;
    
    /** The file that should be restored if a transaction is rolledback. */
    private File rollbackFile;

    /** The file containing committed data, this file should always be
     * consistent.
     */
    private final File targetFile;
    
    /**
     * Where to place dirty transaction data.
     */
    private final File transactionDirectory;
    
    /** The ID of this file. */
    private final FsId id;

    /**
     * When this file needs to be transactionally modified.
     * @param targetFile
     * @param id
     * @return
     * @throws IOException
     */
    static TransactionalStreamFile loadFile(File targetFile, FsId id) throws IOException {
        return new TransactionalStreamFile(targetFile, id);
    }
    
    /**
     * Use this during recovery to put the TransactionalStreamFile associated
     * with the targetFile into a consistent state.
     * 
     * @param targetFile
     * @return
     */
    static Recovery recover(File targetFile, FsId id) {
        return new Recovery(targetFile, id);
    }
    
    static File transactionDirectory(File targetFile, FsId id) {
        return new File(targetFile.getParentFile(), id.name()
            + ".xactions");
    }
    
    private static File dirtyFile(File transactionDirectory, Xid xid) {
        return new File(transactionDirectory, Util.xidToString(xid) + DIRTY_SUFFIX);
    }
    
    /**
     * @param targetFile
     */
    private TransactionalStreamFile(File targetFile, FsId id) throws IOException {
        super();

        this.id = id;
        this.targetFile = targetFile;
        transactionDirectory = new File(targetFile.getParentFile(), id.name()
            + ".xactions");
        rollbackFile = new File(transactionDirectory, ROLLBACK);

        gov.nasa.kepler.io.DataInputStream din = null;

        try {

            if (targetFile.exists() && targetFile.length() >= HEADER_SIZE) {
                din = new gov.nasa.kepler.io.DataInputStream(new BufferedInputStream(
                    new FileInputStream(targetFile)));
                byte version = (byte) din.readUnsignedByte();
                if (version != FORMAT_VERSION && version != COMPATIBLE_VERSION) {
                    throw new IOException(
                        "File read does not have correct file format version."
                            + "Expected " + HEADER_SIZE + " but found "
                            + version + ".");
                }

                // The newness of this file may change depending on what the
                // rollback file (if any) says
                newState = din.readByte();
                if (newState == DELETED_STATE || newState == NEW_STATE) {
                    throw new IllegalStateException("Existing file being loaded" +
                        " must be in old state but was in state " + newState +".");
                }
                origin = din.readLong();
            }

        } finally {
            if (din != null) {
                din.close();
            }
        }
    }

    private TransactionContext findContext(Xid xid) {
        TransactionContext context = xactions.get(xid);
        if (context == null) {
            throw new TransactionNotExistException(xid, "Transaction \"" + xid +
                "\" has not been started with stream file \"" + id() + "\".");
        }

        return context;
    }

    @Override
    protected final int lockTimeOutForTransaction(Xid xid) {
        return findContext(xid).timeOutSeconds;
    }
    
    @Override
    public FsId id() {
        return id;
    }
    
    /**
     * If you want to know the length of the file before reading or writing you
     * should acquire the read lock first and release it after the call to
     * read() or write().
     * 
     * @param xid
     * @return
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     * @throws IOException
     */

    public long length(Xid xid) throws InterruptedException,
        FileStoreTransactionTimeOut, IOException {

        TransactionContext context = findContext(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            return context.length();
        } finally {
            releaseReadLock(xid);
        }
    }

    /**
     * If you want to know the origin of the file before reading or writing you
     * should acquire the read lock first and release it after the call to
     * read() or write().
     * 
     * @param xid
     * @return
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     * @throws IOException
     */
    public long origin(Xid xid) throws InterruptedException,
        FileStoreTransactionTimeOut, IOException {

        TransactionContext context = findContext(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            return context.origin();
        } finally {
            releaseReadLock(xid);
        }
    }

    /**
     * Allocates a transaction context for the specified file. This is requred
     * before writing to the file and optional for reading from the file..
     * 
     * @param xid
     * @param timeOutSeconds the number of seconds to wait to acquire a lock
     * note, this may be different from the total transaction time out.
     * @param modifiedFsIdJournal Where to record modifications made by this
     * transaction.
     * @throws IOException
     */
    void beginTransaction(Xid xid, int timeOutSeconds, 
        ModifiedFsIdJournal modifiedFsIdJournal) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {

        if (xid == null) {
            throw new NullPointerException("Xid may not be null.");
        }
        acquireReadLock(xid, timeOutSeconds);

        try {
            synchronized (xactions) {
                if (xactions.containsKey(xid)) {
                    return;
                }
    
                TransactionContext context = new TransactionContext(xid,
                    timeOutSeconds, modifiedFsIdJournal);
                xactions.put(xid, context);
            }
        } finally {
            releaseReadLock(xid);
        }

    }

    /**
     * Removes rollback file.
     * 
     * @see gov.nasa.kepler.fs.server.xfiles.TransactionalFile#commitTransaction(javax.transaction.xa.Xid)
     */
    @Override
    protected final void doCommit(Xid xid) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {

        TransactionContext context = findContext(xid);

        context.commit();
        // It's ok to delete this since any open files have been closed at
        // this point (the write lock has been acquired).
        if (rollbackFile.exists() && !rollbackFile.delete()) {
            log.error("Failed to remove rollback file \"" + rollbackFile
                + "\".");
        }
        this.origin = context.origin();

        xactions.remove(xid);
       
        if (context.isDeleted) {
            for (TransactionContext otherContext : xactions.values()) {
                if (!otherContext.isDirty()) {
                    otherContext.isDeleted = true;
                }
            }
            if (targetFile.exists() && !targetFile.delete()) {
                log.error("Failed to remove target file \"" + this.id() + "\".");
            }
        }
        newState = OLD_STATE;
    }

    /**
     * After prepare the rollback file will be hardlinked to the sentinel file,
     * if it is new else it will be hardlinked to the rollbackFile.
     * @see gov.nasa.kepler.fs.server.xfiles.TransactionalFile#prepareTransaction(javax.transaction.xa.Xid,
     * long, java.util.concurrent.TimeUnit)
     */
    @Override
    protected final void doPrepare(Xid xid) throws IOException, InterruptedException,
        FileStoreTransactionTimeOut {

        TransactionContext context = findContext(xid);

        if (context.isOpen()) {
            throw new IllegalStateException("File must be closed.");
        }

        if (newState == NEW_STATE) {
            FileUtil.hardlink(newFileSentinel(), rollbackFile);
        } else if (context.dirtyFile.exists()) {
            FileUtil.hardlink(targetFile, rollbackFile);
        }

    }

    /**
     * Creates a file for the rollback file to point at when this is in the new
     * state.
     * 
     * @return
     */
    private File newFileSentinel() throws IOException {
        // TODO: We really only need one of these files. All the rollback files
        // can then just hardlink to global sentinel file. On the other hand
        // Doing this on a per directory
        // basis has the advantage of being able to have different file systems,
        // since hardlinks can not point across file systems.

        File sentinel = new File(targetFile.getParent(), "sentinel");
        if (sentinel.exists() && sentinel.length() >= HEADER_SIZE) {
            return sentinel;
        }

        // This might concurrently create the same sentinel file, but this
        // should
        // be ok since they would all have the same contents.
        gov.nasa.kepler.io.DataOutputStream dout = null;
        try {
            dout = new gov.nasa.kepler.io.DataOutputStream(new BufferedOutputStream(
                new FileOutputStream(sentinel)));
            dout.writeByte(FORMAT_VERSION);
            dout.writeBoolean(true); // file is new.
            dout.writeLong(UNKNOWN_ORIGIN); // bogus origin.
        } finally {
            dout.close();
        }

        return sentinel;
    }

    /**
     * The calling thread should not be holding the readLock. Unfortunately
     * there does not seem to be a way to test for this.
     * 
     * @see gov.nasa.kepler.fs.server.xfiles.TransactionalFile#rollbackTransaction(javax.transaction.xa.Xid)
     */
    @Override
    protected final void doRollback(Xid xid) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {

        TransactionContext context = findContext(xid);

        context.rollback();
        if (newState == NEW_STATE) {
            if (targetFile.exists()) {
                if (!targetFile.delete()) {
                    log.warn("Failed to delete targetFile \"" + targetFile
                        + "\".");
                }
            }

            if (rollbackFile.exists()) {
                rollbackFile.delete();
            }
        } else if (rollbackFile.exists()) {
            rollbackFile.renameTo(targetFile);
            if (rollbackFile.exists() && !rollbackFile.delete()) {
                log.error("Failed to remove rollback file \"" + rollbackFile
                    + "\".");
            }
        }
        xactions.remove(xid);

    }
    
    @Override
    protected final void doCleanRollback(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext context = findContext(xid);
        if (context.isDirty()) {
            throw new IllegalStateException("Transaction \"" + xid + "\" has dirtied \"" + id() + "\" expected clean.");
        }
        context.rollback();
        xactions.remove(xid);
    }

    /**
     * @see gov.nasa.kepler.fs.server.xfiles.TransactionalFile#transactions()
     */
    @Override
    boolean hasTransactions() {
        return !xactions.isEmpty();
    }

    /**
     * @return true if this file is known to the specified transaction.
     */
    @Override
    boolean knowsTransaction(Xid xid) {
        // This is ok since xactions is synchronized.
        return xactions.containsKey(xid);
    }

    /**
     * The writable channel return holds a read lock on this file until it is
     * closed. Gets the WritableByteChannel associated with this
     * transaction/file. The transaction can not be comitted until this is
     * closed.
     * 
     * @param xid
     * @return
     */
    public WritableBlob writeBlob(Xid xid, long origin)
        throws InterruptedException, IOException, FileStoreTransactionTimeOut {

        TransactionContext context = findContext(xid);
        boolean unlockOnError = true;
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            WritableBlob writableBlob = context.writeBlob(origin);
            unlockOnError = false;
            return writableBlob;
        } finally {
            // readLock.unlock() is in channel's close method.
            if (unlockOnError) {
                releaseReadLock(xid);
            }
        }
    }

    /**
     * The readable channel return holds a read lock on this file until it is
     * closed. The transaction can not be comitted until this channel is closed.
     * 
     * @param xid
     * @return
     */
    public ReadableBlob readBlob(Xid xid) throws InterruptedException,
        IOException, FileStoreTransactionTimeOut {

        TransactionContext context = findContext(xid);
        boolean unlockOnError = true;
        acquireReadLock(xid, context.timeOutSeconds);
        try {
            ReadableBlob readableBlob = context.readBlob();
            unlockOnError = false;
            return readableBlob;
        } finally {
            // readLock.unlock() is in channel's close method.
            if (unlockOnError) {
                releaseReadLock(xid);
            }
        }
    }


    static class NonTransactionalReader {
        final File targetFile;
        final long originator;
        final long size;
        final DataInputStream in;

        NonTransactionalReader(File targetFile) throws IOException {
            this.targetFile = targetFile;
            this.in = new DataInputStream(new BufferedInputStream(
                new FileInputStream(targetFile)));
            byte version = in.readByte();
            if (version != FORMAT_VERSION) {
                FileUtil.close(in);
                throw new IllegalArgumentException("Expected format version "
                    + FORMAT_VERSION + " but found " + version);
            }

            in.readBoolean();  //read the new flag.
            originator = in.readLong();
            size = targetFile.length() - HEADER_SIZE;
        }
    }

    /**
     * Per transaction state information. This does not handle the rollback
     * files. That is handled by the enclosing class.
     * 
     */
    private class TransactionContext {
        private WritableBlob writeBlob;
        private ReadableBlob readBlob;
        private final Xid xid;
        private volatile boolean isDeleted = false;
        private volatile boolean isDirty = false;
        private final ModifiedFsIdJournal modifiedFsIdJournal;

        /**
         * When writing this this is where the bytes are stored. This file is
         * not accessed for reading.
         */
        private final File dirtyFile;
        private final Lock xLock = new ReentrantLock(true);
        private final int timeOutSeconds;
        private RandomAccessFile raf;
        private long origin = UNKNOWN_ORIGIN;

        TransactionContext(Xid xid, int timeOutSeconds, 
            ModifiedFsIdJournal modifiedFsIdJournal) {
            
            this.modifiedFsIdJournal = modifiedFsIdJournal;
            this.xid = xid;
            dirtyFile = dirtyFile(transactionDirectory, xid);
            this.timeOutSeconds = timeOutSeconds;
        }

        boolean isDirty() throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                return isDirty|| isDeleted;
            } finally {
                xLock.unlock();
            }
        }
        
        WritableBlob writeBlob(long origin) throws IOException,
            InterruptedException, FileStoreTransactionTimeOut {
            openChannel(true, origin);

            isDirty = true;
            return writeBlob;
        }
        private void openChannel(boolean writeOK, long origin)
            throws InterruptedException, IOException,
            FileStoreTransactionTimeOut {
            acquireLock();

            boolean unlockOnError = true;
            try {
                if (writeOK) {
                    if (writeBlob != null) {
                        unlockOnError = false;
                        return;
                    }
                    if (readBlob != null) {
                        throw new IllegalStateException(
                            "Transaction is in read mode.");
                    }
                    if (this.origin != origin && this.origin != UNKNOWN_ORIGIN) {
                        throw new IllegalStateException(
                            "Transaction can only be written from the same originator.");
                    }
                } else {
                    checkDeleted();
                    if (readBlob != null) {
                        unlockOnError = false;
                        return;
                    }
                    if (writeBlob != null) {
                        throw new IllegalStateException(
                            "Transaction is in write mode.");
                    }
                }

                File fileToUse = null;
                if (writeOK) {
                    fileToUse = dirtyFile;
                    modifiedFsIdJournal.fileModified(xid, id);
                    if (!transactionDirectory.exists()) {
                        transactionDirectory.mkdirs();
                    }
                } else {
                    if (dirtyFile.exists()) {
                        // read uncommitted data from this transaction.
                        fileToUse = dirtyFile;
                    } else if (targetFile.exists()) {
                        fileToUse = targetFile;
                    } else {
                        throw new FileNotFoundException("File \"" + targetFile
                            + "\" does not exist for reading.");
                    }
                }

                raf = new RandomAccessFile(fileToUse, (writeOK) ? "rw" : "r");

                if (writeOK) {
                    if (raf.length() > 0) {
                        //truncate if writing again in the same transaction
                        raf.setLength(0);
                    }
                    this.origin = origin;
                } else {
                    raf.readChar();
                    this.origin = raf.readLong();
                }

                if (writeOK) {
                    raf.writeByte(FORMAT_VERSION);
                    raf.writeByte(OLD_STATE);
                    raf.writeLong(origin);
                } else {
                    raf.seek(HEADER_SIZE);
                }

                FileChannel fileChannel = raf.getChannel();
                if (writeOK) {
                    writeBlob = new TransactionalWritableBlob(HEADER_SIZE,
                        fileChannel, this, TransactionalStreamFile.this);
                } else {
                    readBlob = new TransactionalReadableBlob(origin(),
                        HEADER_SIZE, fileChannel, fileToUse.length()
                            - HEADER_SIZE, this, TransactionalStreamFile.this);
                }
                unlockOnError = false;

            } finally {
                // xLock.unlock(); is usually called from the channel's close() method.
                if (unlockOnError) {
                    xLock.unlock();
                }
            }

        }

        ReadableBlob readBlob() throws IOException, InterruptedException,
            FileStoreTransactionTimeOut {
            
            openChannel(false, UNKNOWN_ORIGIN);
            return readBlob;
        }

        long length() throws InterruptedException, FileStoreTransactionTimeOut,
            IOException {
            acquireLock();

            try {
                if (writeBlob != null && writeBlob.fileChannel.isOpen()) {
                    throw new IllegalStateException("Close channel.");
                }

                if (dirtyFile.exists()) {
                    return dirtyFile.length() - HEADER_SIZE;
                } else {
                    return targetFile.length() - HEADER_SIZE;
                }
            } finally {
                xLock.unlock();
            }
        }

        long origin() throws InterruptedException, FileStoreTransactionTimeOut {

            acquireLock();

            try {
                if (writeBlob != null && writeBlob.fileChannel.isOpen()) {
                    throw new IllegalStateException("Close channel.");
                }

                if (this.origin == UNKNOWN_ORIGIN) {
                    return TransactionalStreamFile.this.origin;
                }
                return origin;
            } finally {
                xLock.unlock();
            }
        }

        boolean isOpen() throws InterruptedException,
            FileStoreTransactionTimeOut {

            acquireLock();

            try {
                if (writeBlob != null) {
                    return writeBlob.fileChannel.isOpen();
                }
                if (readBlob != null) {
                    return readBlob.fileChannel.isOpen();
                }
                return false;
            } finally {
                xLock.unlock();
            }
        }

        /**
         * Closes any resources.
         * 
         * @throws FileStoreTransactionTimeOut
         * @throws InterruptedException
         */
        void rollback() throws FileStoreTransactionTimeOut,
            InterruptedException {
            acquireLock();

            try {
                try {
                    if (writeBlob != null) {
                        writeBlob.close();
                    }
                    if (readBlob != null) {
                        readBlob.close();
                    }
                } catch (IOException ioe) {
                    log.warn("Could not close channel.", ioe);
                }
                FileUtil.close(raf);
                if (dirtyFile.exists() && !dirtyFile.delete()) {
                    log.warn("Failed to delete dirty file \"" + dirtyFile
                        + "\".");
                }
            } catch (Throwable t) {
                log.warn("Rollback failed for transaction \"" + xid + "\".", t);
            } finally {
                xLock.unlock();
            }

        }

        void commit() throws FileStoreTransactionTimeOut, InterruptedException,
            IOException {

            acquireLock();

            try {

                FileUtil.close(raf);

                if (isDeleted) {
                    if (dirtyFile.exists() && !dirtyFile.delete()) {
                        log.error("Failed to delete dirtyFile \"" + dirtyFile
                            + "\".");
                    }
                    
                    if (transactionDirectory.list().length == 0) {
                        if (!transactionDirectory.delete()) {
                            log.warn("Failed to delete the transactionDirectory \"" + transactionDirectory + "\".");
                        }
                    }
                } else {
                    if (dirtyFile.exists() && !dirtyFile.renameTo(targetFile)) {
                        throw new IOException("Rename of \"" + dirtyFile
                            + "\" to \"" + targetFile + "\" failed.");
                    }
                    if (dirtyFile.exists() && !dirtyFile.delete()) {
                        log.error("Failed to delete dirtyFile \"" + dirtyFile
                            + "\".");
                    }
//                    raf = new RandomAccessFile(targetFile, "rw");
//                    FileUtil.close(raf);
                }
            } finally {
                xLock.unlock();
            }
        }

        void acquireLock() throws InterruptedException,
            FileStoreTransactionTimeOut {
            if (!xLock.tryLock(timeOutSeconds, TimeUnit.SECONDS)) {
                throw new FileStoreTransactionTimeOut(
                    "Did not acquire lock within time out.");
            }
        }

        void delete() throws FileStoreTransactionTimeOut, 
                             InterruptedException, IOException {
            acquireLock();
            try {
                if (isOpen()) {
                    throw new IllegalStateException("Can't delete file " +
                            "while channel is open.");
                }
                isDeleted = true;
                isDirty = true;
                DataOutputStream dout = 
                    new DataOutputStream(new BufferedOutputStream(new FileOutputStream(dirtyFile)));
                dout.writeByte(FORMAT_VERSION);
                dout.writeByte(DELETED_STATE);
                dout.writeLong(origin);
                dout.close();
                modifiedFsIdJournal.fileModified(xid, id);
            } finally {
                xLock.unlock();
            }
        }
        
        boolean isDeleted() throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                return isDeleted;
            } finally {
                xLock.unlock();
            }
        }
        
        private void checkDeleted() {
            if (isDeleted) {
                throw new FileStoreIdNotFoundException(id, "File has been deleted with delete().");
            }
        }

    }

    private static class TransactionalReadableBlob extends ReadableBlob {

        private final TransactionContext context;
        private final TransactionalStreamFile streamFile;

        protected TransactionalReadableBlob(long origin, long fileStart,
            FileChannel fileChannel, long length, TransactionContext context,
            TransactionalStreamFile streamFile) throws IOException {
            super(origin, fileStart, fileChannel, length);

            this.context = context;
            this.streamFile = streamFile;
        }

        public void close() throws IOException {
            try {
                fileChannel.close();
            } finally {
                context.readBlob = null;
                context.xLock.unlock();
                streamFile.releaseReadLock(context.xid);
            }
        }

        // No finally here because the locks can only be unlocked from the
        // calling thread.
    }

    private static class TransactionalWritableBlob extends WritableBlob {

        private final TransactionalStreamFile streamFile;
        private final TransactionContext context;

        protected TransactionalWritableBlob(long fileStart,
            FileChannel fileChannel, TransactionContext context,
            TransactionalStreamFile streamFile) throws IOException {
            super(fileStart, fileChannel);

            this.streamFile = streamFile;
            this.context = context;

        }

        public void close() throws IOException {
            try {
                //This should call fsync() on the file.  This deals with some
                //corner cases where ext4 will buffer everything for an arbitrary
                //long period of time.
                fileChannel.force(false);
                fileChannel.close();
            } finally {
                context.writeBlob = null;
                context.xLock.unlock();
                streamFile.releaseReadLock(context.xid);
            }

        }

        // No finalize here because the locks can only be unlocked from the
        // calling thread.

    }

    @Override
    boolean isDirty(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext xaction = findContext(xid);
        acquireReadLock(xid, xaction.timeOutSeconds);
        try {
            return xaction.isDirty();
        } finally {
            releaseReadLock(xid);
        }
    }

    @Override
    public void delete(Xid xid) throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext xaction = findContext(xid);
        acquireReadLock(xid, xaction.timeOutSeconds);
        try {
            xaction.delete();
        } finally {
            releaseReadLock(xid);
        }
    }

    @Override
    public boolean isDeleted(Xid xid) throws 
        FileStoreTransactionTimeOut, InterruptedException {

        TransactionContext xaction = findContext(xid);
        acquireReadLock(xid, xaction.timeOutSeconds);
        try {
            return xaction.isDeleted();
        } finally {
            releaseReadLock(xid);
        }
        
    }
    
    /**
     * Recover from a failure.  Put the file back into a consistent state.
     *
     */
    static class Recovery {
        private final File targetFile;
        private final File transactionDirectory;
        
        private Recovery(File targetFile, FsId id) {
            this.targetFile = targetFile;
            this.transactionDirectory = transactionDirectory(targetFile, id);
        }
        
        /**
         * 
         * @param xid
         * @param isCommitted  This should be true if the transaction was
         * committed else false.
         */
        void mergeRecovery(Xid xid, boolean isCommitted) throws IOException {
            if (isCommitted) {
            
                File dirtyFile = dirtyFile(transactionDirectory, xid);
                if (!dirtyFile.exists()) {
                    log.debug("Dirty file does not exist, assuming " +
                            "transaction \"" + xid + "\" already committed.");
                    return;
                }
                
                
                File rollbackFile = new File(transactionDirectory, ROLLBACK);
                if (rollbackFile.exists() && !rollbackFile.delete()) {
                    throw new IOException("Failed to delete rollback file \"" 
                        + rollbackFile + "\".");
                }
                
                gov.nasa.kepler.io.DataInputStream din = 
                    new gov.nasa.kepler.io.DataInputStream(new BufferedInputStream(new FileInputStream(dirtyFile)));
                byte version = din.readByte();
                if (version != FORMAT_VERSION && version != COMPATIBLE_VERSION) {
                    throw new IllegalStateException("Found dirty file with version " + 
                        version + " but expected version " + FORMAT_VERSION + ".");
                }
                byte state = din.readByte();
                din.close();
                switch (state) {
                    case NEW_STATE:
                    case DELETED_STATE:
                        if (targetFile.exists() && !targetFile.delete()) {
    
                            log.error("Failed to delete target file \"" + 
                                targetFile + "\".");
                        }
                        break;
                    case OLD_STATE:
                        if (dirtyFile.exists() && !dirtyFile.renameTo(targetFile)) {
                            throw new IOException("Rename of \"" + dirtyFile
                                + "\" to \"" + targetFile + "\" failed.");
                        }
                        if (dirtyFile.exists() && !dirtyFile.delete()) {
                            log.error("Failed to delete dirtyFile \"" + dirtyFile
                                + "\".");
                        }
                        break;
                    default:
                        throw new IllegalStateException("Unhandled case "+ state);
                }
            } else {
                File dirtyFile = dirtyFile(transactionDirectory, xid);
                if (!dirtyFile.exists()) {
                    log.debug("Dirty file does not exist, assuming " +
                            "transaction \"" + xid + "\" already committed.");
                    return;
                }
                if (!dirtyFile.delete()) {
                    log.warn("Failed to delete dirtyFile \"" + dirtyFile + "\".");
                }
                
            }
        }
        
        /**
         * Removes transaction directory and knowledge of all transactions.
         * @throws IOException 
         */
        void completeRecovery() throws IOException {
            if (transactionDirectory.exists()  && transactionDirectory.list().length == 0) {
                if (!transactionDirectory.delete()) {
                    log.warn("Failed to delete transaction directory \"" + transactionDirectory + "\".");
                }
            }
        }
    }

}