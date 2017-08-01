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
import static gov.nasa.spiffy.common.io.FileUtil.close;
import gnu.trove.TLongArrayList;
import gov.nasa.kepler.fs.api.FileStoreIdNotFoundException;
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TsOutOfRangeException;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.journal.JournalEntry;
import gov.nasa.kepler.fs.server.journal.JournalWriter;
import gov.nasa.kepler.fs.server.journal.RandomAccessJournalReader;
import gov.nasa.kepler.fs.server.nc.NonContiguousInputStream;
import gov.nasa.kepler.fs.server.nc.NonContiguousOutputStream;
import gov.nasa.kepler.fs.server.nc.NonContiguousReadWrite;
import gov.nasa.kepler.fs.storage.RandomAccessStorage;

import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

import javax.transaction.xa.Xid;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFileMetadataCache.*;
import gov.nasa.spiffy.common.intervals.IntervalSet;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;


/**
 * Transactional access to a random access file.
 * 
 * The transaction operations supported here to not correspond with the XA
 * transaction standard.  An XA complaint resource adapter should be used to 
 * make this comply with XA transactions.
 * 
 * Header format:
 *  version (1 byte)
 * @author Sean McCauliff
 *
 */
public class TransactionalRandomAccessFile extends TransactionalFile {
    
    @SuppressWarnings("unused")
    private static final Log log = 
        LogFactory.getLog(TransactionalRandomAccessFile.class);
    
    private static final long META_LOCATION = -1;
    
    private static final long OP_LOCATION = -2;
    
    private static final long DELETE_FILE_LOCATION = -3;
    
    private static final int IOBUF_SIZE = 1024*32;

    /** Increment this every time an incompatible  file format change is made.
     *  0 - initial revision
     *  1 - clean up transaction state
     *  2 - change tagged interval to use 8byte tags
     *  3 - Switch to {@link NonContiguousReadWrite} for all io.
     *  4 - Change to journaling writes.
     *  5 - Remove new flag from file since that is stored elsewhere.
     *  6 - Remove tags to save memory, replace with dataType.
     *  7 - Changed Xid encoding to use base64.
     *  8 - Delta compress metadata.
     */
    private static final byte FORMAT_VERSION = (byte) 8;

    static final long HEADER_SIZE = 1;
    private final static SimpleInterval.Factory simpleFactory =
        new SimpleInterval.Factory();
    private final static TaggedInterval.Factory taggedFactory =
        new TaggedInterval.Factory();
    private final static IntervalSet<SimpleInterval, SimpleInterval.Factory> EMPTY_VALID = 
        new IntervalSet<SimpleInterval, SimpleInterval.Factory>(simpleFactory);
    private final static IntervalSet<TaggedInterval, TaggedInterval.Factory> EMPTY_ORIGIN = 
        new IntervalSet<TaggedInterval, TaggedInterval.Factory>(taggedFactory);
    
    private final TransactionalRandomAccessFileMetadataCache mCache;
    
    /**
     * How to store data.
     */
    private final RandomAccessStorage storage;
    
    
    /**
     *  What type is stored in the data portion
     */
    private byte dataType = 0;
    
    /**
     * This should be  synchronized because we need to lookup the transaction
     * context before acquiring a lock in order to get the timeout
     * for that transaction.
     */
    private final List<TransactionContext> xactions =  
        new ArrayList<TransactionContext>(1);

    
    private boolean needsInit = true;
    
    /**
     * Load an existing, clean TRAF or create a new one.
     * @return
     * @throws InterruptedException 
     * @throws IOException 
     * @throws FileStoreTransactionTimeOut 
     */
    static TransactionalRandomAccessFile loadFile(RandomAccessStorage storage,
            TransactionalRandomAccessFileMetadataCache mCache) throws FileStoreTransactionTimeOut, IOException, InterruptedException {
        return new TransactionalRandomAccessFile(storage, mCache);
    }
    
    /**
     * Recover a transactional random access file that was involved in a
     * transaction.
     * @throws InterruptedException 
     * @throws IOException 
     * @throws FileStoreTransactionTimeOut 
     */
    static Recovery recoverFile( RandomAccessStorage storage)  {
        return new Recovery(storage);
    }
    
    /**
     * Do a non-transactional read.  This should only be used off-line, never
     * in the file store server.
     */
    static NonTransactionalReader readFile(RandomAccessStorage storage) throws IOException {
        return new NonTransactionalReader(storage);
    }
    
    /**
     * There is a 1:1 relationship between an instance of this class and an
     * FsId.  There should never be more than one instance for a particular
     * FsId.
     * 
     * @param 
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    private TransactionalRandomAccessFile(RandomAccessStorage storage,
            TransactionalRandomAccessFileMetadataCache mCache) 
        throws IOException, InterruptedException, FileStoreTransactionTimeOut {
        
        super();
        
        this.storage = storage;
        this.mCache = mCache;
    }
    
    /**
     * Initialize metadata to a clean state.
     */
    private void initMetadata(NonContiguousReadWrite metaIo) throws IOException {
        BufferedOutputStream bout = new BufferedOutputStream(new NonContiguousOutputStream(metaIo));
        DataOutputStream dout = new DataOutputStream(bout);
        dout.writeByte(FORMAT_VERSION);
        
        dout.writeByte(dataType);
        EMPTY_VALID.writeTo(dout);   
        EMPTY_ORIGIN.writeTo(dout);
        bout.flush();
    }

    /**
     * @param storage
     * @throws IOException
     * @throws InterruptedException 
     */
    private void init() throws IOException, InterruptedException {
        synchronized (xactions) {
            if (!needsInit) {
                return;
            }
            
            NonContiguousReadWrite metaIo = null;
            
            try {
                metaIo = storage.metaDataRw();
                
                if (storage.isNew()) {
                    initMetadata(metaIo);     
                } else {
                    DataInputStream din = 
                        new DataInputStream(new BufferedInputStream(new NonContiguousInputStream(metaIo), IOBUF_SIZE));
                    int version = din.readUnsignedByte();
                    if (version != FORMAT_VERSION) {
                        throw new IOException("Invalid file format got \"" + version 
                            + "\" expected \"" + FORMAT_VERSION);
                    }
                    
    
                    dataType = din.readByte();
                }
                needsInit = false;
            } finally {
                close(metaIo);
            }
        }
    }
    
    private TransactionContext findContext(Xid xid) {
        synchronized (xactions) {
            for (TransactionContext context : xactions) {
                if (XidComparator.INSTANCE.compare(context.xid, xid) == 0) {
                    return context;
                }
            }
        }

        throw new IllegalArgumentException("Xid \""+xid+
                    "\" has not been started with file \"" + id()+
                    "\".");
    }
    
    @Override
    protected final int lockTimeOutForTransaction(Xid xid) {
        return findContext(xid).timeOutSeconds;
    }

    @Override
    public FsId id() {
        return storage.fsId();
    }
    
    /**
     * 
     * @param xid
     * @return true if this transaction has pending modifications.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws IOException 
     */
    @Override
    boolean isDirty(Xid xid) throws FileStoreTransactionTimeOut, InterruptedException, IOException {
       TransactionContext xaction = findContext(xid);
       acquireReadLock(xid, xaction.timeOutSeconds);
       try {
           init();
           return xaction.isDirty();
       } finally {
           releaseReadLock(xid);
       }
    }
    
    private void removeContext(Xid xid) {
        synchronized (xactions) {
            for (int i=0; i < xactions.size(); i++) {
                if (XidComparator.INSTANCE.compare(xid, xactions.get(i).xid) == 0) {
                    xactions.remove(i);
                    break;
                }
            }
        }
    }
    
    @Override
    public boolean hasTransactions() {
        return !xactions.isEmpty();
    }
    
    /**
     * @see gov.nasa.kepler.fs.server.xfiles.TransactionalFile#knowsTransaction(Xid)
     */
    @Override
    boolean knowsTransaction(Xid xid) {
        synchronized (xactions) {
            for (TransactionContext context : xactions) {
                if (XidComparator.INSTANCE.compare(xid, context.xid) == 0) {
                    return true;
                }
            }
        }
        
        return false;
    }
    
    /**
     * Gets a copy of the interval meta data off of the disk if needed.  This should only
     * be executed within an rwlock.
     * 
     * @return <valid, originators>  Don't modify these.
     * @throws IOException 
     */
    private Metadata  metaData() throws IOException {

        Metadata metadata = mCache.metadata(id());
        NonContiguousReadWrite metaIo = null;
        try {
            metaIo = storage.metaDataRw();
            DataInputStream din = new DataInputStream(new BufferedInputStream(new NonContiguousInputStream(metaIo), 1024*4));

            IntervalSet<SimpleInterval, SimpleInterval.Factory> rvValid = new IntervalSet<SimpleInterval, SimpleInterval.Factory>(simpleFactory);
            din.readByte();  //version
            dataType = din.readByte();
            rvValid.readFrom(din);
            
            IntervalSet<TaggedInterval, TaggedInterval.Factory> rvOrigin = new IntervalSet<TaggedInterval, TaggedInterval.Factory>(taggedFactory);
            rvOrigin.readFrom(din);
            
            metadata = new Metadata(rvValid, rvOrigin);
            mCache.storeMetadata(id(), metadata);
            return metadata;
            
        } finally {
            close(metaIo);
        }
    }
    
    /**
     * 
     * @param xid
     * @return
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     * @throws IOException 
     */
    public FileMetadata metadata(Xid xid) 
        throws InterruptedException, FileStoreTransactionTimeOut, IOException {
        
        TransactionContext context = findContext(xid);
        acquireReadLock(xid, context.timeOutSeconds);
        
        try {
            init();
            
            Metadata metadata = metaData();
            IntervalSet<SimpleInterval, SimpleInterval.Factory> validCopy =
                new IntervalSet<SimpleInterval, SimpleInterval.Factory>(metadata.valid());
            IntervalSet<TaggedInterval, TaggedInterval.Factory> originCopy =
                new IntervalSet<TaggedInterval, TaggedInterval.Factory>(metadata.origin());
            
            context.mergeIntervals(validCopy, originCopy);
        
            
            return 
                new FileMetadata(originCopy.intervals(), 
                                             validCopy.intervals(), 
                                               context.dataType());
        } finally {
            releaseReadLock(xid);
        }
    }
    
    
    public FileMetadata fileMetaData(Xid xid, final long start, final long end) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
         TransactionContext context = findContext(xid);
         acquireReadLock(xid, context.timeOutSeconds);
         
         try {
             init();
             return xactionReadMetadata(start, end, context);
         } finally {
             releaseReadLock(xid);
         }
    }

    /**
     * Computes the originators of the bytes in a transactional read.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws IOException 
     */
    private FileMetadata xactionReadMetadata(long start, long end, 
                                             TransactionContext xaction) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
        TaggedInterval taggedSpanningInterval =
            new TaggedInterval(start , end, -1);
        SimpleInterval simpleSpanningInterval = 
            new SimpleInterval(start, end);
        
        Metadata metadata = metaData();
        IntervalSet<SimpleInterval, SimpleInterval.Factory> validCopy =
            new IntervalSet<SimpleInterval, SimpleInterval.Factory>(metadata.valid());
        IntervalSet<TaggedInterval, TaggedInterval.Factory> originCopy =
            new IntervalSet<TaggedInterval, TaggedInterval.Factory>(metadata.origin());
        
        xaction.mergeIntervals(validCopy, originCopy);
        
        
        return new FileMetadata(originCopy.spannedIntervals(taggedSpanningInterval,true),
                                                 validCopy.spannedIntervals(simpleSpanningInterval,true),
                                                 xaction.dataType());
    }
    
    @Override
    public void delete(Xid xid) throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        if (xid == null) {
            throw new NullPointerException("xid may not be null.");
        }
        TransactionContext context = findContext(xid);
        
        acquireReadLock(xid, context.timeOutSeconds);
        
        try {
            init();
            context.deleteFile();
        } finally {
            releaseReadLock(xid);
        }
    }

    @Override
    public boolean isDeleted(Xid xid) throws 
        FileStoreTransactionTimeOut, InterruptedException, IOException {

        if (xid == null) {
            throw new NullPointerException("xid may not be null.");
        }
        TransactionContext context = findContext(xid);
        
        acquireReadLock(xid, context.timeOutSeconds);
        
        try {
            init();
            return context.isDeleted();
        } finally {
            releaseReadLock(xid);
        }
        
    }
    
    
    /**
     * Reads bytes into buf.
     * 
     * @param buf  The byte buffer.  This may not be null.
     * @param bufStart Where to start writing into the buffer.
     * @param start Where to start reading from the file.
     * @param size The number of bytes to write into the buffer.
     * @param timeOut The number of milliseconds to wait for read
     * access to the file.  Use 0 for infinite.
     * @param xid The transaction id. This may be null for 
     * non-transactional reads.
     * @return The ids of the originating module ids.
     * has not been written before.
     */
    public FileMetadata read(byte[] buf, int bufStart, int size, long start,
                             Xid xid) 
        throws IOException, InterruptedException, TsOutOfRangeException, 
        FileStoreTransactionTimeOut {
        
        if (start < 0) {
            throw new IllegalArgumentException("Invalid start " + start);
        }
        if (buf == null) {
            throw new NullPointerException("Bad pointer for buf.");
        }
        
        if (xid == null) {
            throw new NullPointerException("xid may not be null.");
        }
        TransactionContext context = findContext(xid);
        
        acquireReadLock(xid, context.timeOutSeconds);
        
        try {
            init();
            return xactionRead(buf, bufStart, size, start, xid);

        } finally {
            releaseReadLock(xid);
        }
    }

    /**
     * Read back data that may have not yet been committed within a transaction.
     * This is needed for READ_COMMITTED transaction isolation level.  This is
     * very inefficient if there are many outstanding writes to the file.
     * 
     * @param buf
     * @param bufStart
     * @param size
     * @param start
     * @param xid
     * @param timeOut
     * @param tunit
     * @return
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     * @throws TsOutOfRangeException
     * @throws IOException
     */
    private FileMetadata xactionRead(final byte[] buf, final int bufStart, 
                                                           final int size, 
                                                           final long start, Xid xid)
    
        throws InterruptedException, FileStoreTransactionTimeOut, 
               TsOutOfRangeException, IOException {

        TransactionContext xaction = findContext(xid);
        if (xaction == null) {
            throw new IllegalArgumentException("Transaction not started.");
        }
        xaction.acquireLock();
        xaction.checkDeleted();
        
        NonContiguousReadWrite dataIo = storage.dataRw();
        final long end = start + size - 1;  //inclusive
        
        RandomAccessJournalReader journalReader = null;
        
        Metadata metadata = metaData();
        
        try {
            if (!metadata.valid().intervals().isEmpty()) {
                //first read the committed data.
                List<SimpleInterval> validSubset = 
                    metadata.valid().spannedIntervals(new SimpleInterval(start, end));
                if (!validSubset.isEmpty()) {
                    long clippedStart = Math.max(start, validSubset.get(0).start());
                    long clippedEnd = Math.min(end, validSubset.get(validSubset.size() - 1).end());
                    long clippedLength  = clippedEnd - clippedStart + 1;
                    if (clippedLength > Integer.MAX_VALUE) {
                        throw new IllegalArgumentException("Data too large.");
                    }
                    dataIo.seek(clippedStart);
                    dataIo.readFully(buf, bufStart + (int) (clippedStart - start), (int) clippedLength);
                }
            }
            
            //overwrite committed data with non-committed data.
            List<Operation> xactionOperations = xaction.operations();
            for (Operation op : xactionOperations) {
                if (op instanceof DeleteOperation) {
                    continue;
                }
                
                WriteOperation writeOp = (WriteOperation) op;
                if (writeOp.end() < start || writeOp.start() > end) {
                    //data not in range.
                    continue;
                }
                
                if (journalReader == null) {
                    xaction.journalWriter.flush();
                    journalReader = 
                        new RandomAccessJournalReader(xaction.journalWriter.file());
                }
               
                JournalEntry jentry = journalReader.read(writeOp.journalOffset());
                long srcEnd = jentry.destStart() + jentry.data().length - 1;
                if (srcEnd < start || jentry.destStart() > end) {
                    continue;
                }
                
                int srcStart = -1;
                int copyLength  = -1;
                int destStart = -1;
                
                if (start <= jentry.destStart()) {
                    destStart = (int) (jentry.destStart() - start + bufStart);
                    srcStart = 0;
                    copyLength = 
                        (int) Math.min(size - (destStart - bufStart) , jentry.data().length);
                } else {
                    srcStart = (int) Math.max(0, start - jentry.destStart());
                    destStart = bufStart;
                    copyLength =
                        (int) Math.min(size, jentry.data().length - (srcStart - jentry.destStart()));
                }

                if (copyLength <= 0) {
                    continue;
                }
                
                System.arraycopy(jentry.data(), srcStart, buf, destStart, copyLength);
            }
            
            return xactionReadMetadata(start, end, xaction);
        } finally {
            close(journalReader);
            close(dataIo);
            xaction.releaseLock();
        }
    }
    
    
    /**
     *  Assumes valid is (start, start + size -1)
     * @param buf
     * @param size
     * @param start
     * @param xid
     * @param originator
     * @throws InterruptedException 
     * @throws IOException 
     * @throws FileStoreTransactionTimeOut 
     */
    public void write(byte[] buf, int off, int size, long start, Xid xid, long originator) 
        throws FileStoreTransactionTimeOut, IOException, InterruptedException {
        write(buf, off, size, start, xid, 
            Collections.singletonList(new SimpleInterval(start, start + size - 1)), 
            Collections.singletonList((new TaggedInterval(start, start+size -1, originator))));
    }
    /**
     * 
      * @param buf  The byte buffer.  This may not be null.
      * @param off The offset into the buffer.
     * @param start Where to start reading from the file.
     * @param size The number of bytes to write into the buffer.
     * @param timeOut The number of milliseconds to wait for read
     * access to the file.  Use 0 for infinite.
     * @param xid The transaction id.  This may not be null.
     *  Non-transactional writes are not permitted.
     * @param originator The id of the originator of this information,
     * the module id.
     * @throws IOException
     * @throws InterruptedException
     */
    public void write(byte[] buf, int off, int size, long start, Xid xid,
                      List<SimpleInterval> writeValid, 
                      List<TaggedInterval> writeOriginators)
        throws IOException, InterruptedException, FileStoreTransactionTimeOut {
        
        if (start < 0) {
            throw new IllegalArgumentException("Invalid start " + start);
        }
        if (buf == null) {
            throw new NullPointerException("Bad pointer for buf.");
        }
        if (xid == null ) {
            throw new NullPointerException("Non-transactional writes are not permitted.");
        }
        if (off < 0) {
            throw new IllegalArgumentException("off must be non-negative");
        }
        IntervalMetricKey writeMetricKey = IntervalMetric.start();
        TransactionContext xaction = findContext(xid);
        acquireReadLock(xid, xaction.timeOutSeconds);
        
        try {
            init();
            xaction.write(buf, off, size, start, writeValid, writeOriginators);
        } finally {
            releaseReadLock(xid);
            IntervalMetric.stop(FS_METRICS_PREFIX  + ".timeseries.write", writeMetricKey);
        }
    }

    /**
     * Removes the specified interval of data.
     * @param start inclusive
     * @param stop inclusive
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws IOException 
     */
    public void deleteInterval(long start, long stop, Xid xid) throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        if (start < 0) {
            throw new IllegalArgumentException("Start must be a non-negative number.");
        }
        if (start > stop) {
            throw new IllegalArgumentException("Stop must be greather than or equal to start.");
        }
        if (xid == null) {
            throw new NullPointerException("Xid must not be null.");
        }
        
        TransactionContext xaction = findContext(xid);
        acquireReadLock(xid, xaction.timeOutSeconds);
        
        try {
            init();
            xaction.deleteInterval(start, stop);
        } finally {
            releaseReadLock(xid);
        }
    }
    
    /**
     *  Sets the dataType of this file.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     * @throws IOException 
     */
    public void setDataType(Xid xid, byte newDataType) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
        
        if (xid == null ) {
            throw new IllegalArgumentException("Non-transactional writes are not permitted.");
        }
        
        TransactionContext xaction = findContext(xid);
        acquireReadLock(xid, xaction.timeOutSeconds);
        
        try {
            init();
            xaction.setDataType(newDataType);
        } finally {
            releaseReadLock(xid);
        }
    }


    /**
     * Initializes a transaction for use with file.  If a transaction is
     * already in progress for this file then this does nothing.
     * 
     * @param xid  May not be null.
     * @param timeOutSeconds The time to wait to acquire locks.
     */
    void beginTransaction(Xid xid, int timeOutSeconds, JournalWriter journalWriter) 
        throws IOException, InterruptedException,FileStoreTransactionTimeOut  {
        if (xid == null) {
            throw new NullPointerException("Transaction id may not be null.");
        }
        acquireReadLock(xid, timeOutSeconds);
        try {
            synchronized (xactions) {
                for (TransactionContext context : xactions) {
                    if (XidComparator.INSTANCE.compare(xid, context.xid) == 0) {
                        return;
                    }
                }
                TransactionContext context = 
                    new TransactionContext(xid, timeOutSeconds, journalWriter);
                xactions.add(context);
            }
            
        } finally {
            releaseReadLock(xid);
        }
    }
    
    /**
     * Prepares a transaction by locking this file by acquiring the
     * writeLock and then copying over data that will be overwritten
     * for rollback.  At the end of parepareTransaction() the calling
     * thread will still hold the writeLock and so it must be the
     * thread to call commit() When an exception happens this will 
     * automatically unlock the write lock.
     * 
     * @param xid  May not be null.
     * @param timeOut The time to wait to acquire the writeLock
     * @param tunit  The unit for the timeOut
     * @throws IOException
     */
    @Override
    protected final void doPrepare(Xid xid) 
        throws IOException, InterruptedException, FileStoreTransactionTimeOut  {
        
        IntervalMetricKey prepareMetricKey = IntervalMetric.start();
        TransactionContext xaction = findContext(xid);
        try {
            init();
            xaction.prepare();
        } finally {
            IntervalMetric.stop(FS_METRICS_PREFIX + ".timeseries.prepare", prepareMetricKey);
        }
    }
    
    /**
     * Rollback a transaction.
     */
    @Override
    protected final void doRollback(Xid xid) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext xaction = findContext(xid);

        init();
        if (xaction.isDirty()) {
            mCache.removeMetadata(id());
        }
        removeContext(xid);
    }
    
    /**
     * rollback a transaction on this file when it has not modified anything.
     * @throws InterruptedException 
     * @throws FileStoreTransactionTimeOut 
     */
    @Override
    protected final void doCleanRollback(Xid xid) throws IOException, FileStoreTransactionTimeOut, InterruptedException {
        TransactionContext xaction = findContext(xid);
        
        if (xaction.isDirty()) {
            throw new IllegalStateException("Transaction \"" + xid + "\" has dirtied \"" + id() + "\", expected clean.");
        }
        removeContext(xid);
    }
    
    /**
     * Cleanup committed transaction. This should be called as a second stage of
     * the transaction. In this way if a transaction commit fails on another
     * file the specified transaction can be completely rolledback.
     * 
     * @param f
     * @throws InterruptedException
     * @throws FileStoreTransactionTimeOut
     */
    @Override
    protected final void doCommit(Xid xid) throws IOException,
        FileStoreTransactionTimeOut, InterruptedException {

        IntervalMetricKey commitMetricKey = IntervalMetric.start();
        NonContiguousReadWrite metaIo = null;
        try {
            TransactionContext xaction = this.findContext(xid);
            removeContext(xid);

            if (xaction.isDeleted()) {
                if (xactions.size() == 0) {
                    storage.delete(true);
                } else {
                    boolean realDelete = true;
                    for (TransactionContext other : xactions) {
                        if (!other.isDirty()) {
                            other.deleteFile();
                        } else {
                            realDelete = false;
                        }
                    }

                    storage.delete(realDelete);
                    if (!realDelete) {
                        metaIo = storage.metaDataRw();
                        // outstanding reads will read from cleanly initialized
                        // metadata
                        initMetadata(metaIo);
                    }
                }
            } else {
                xaction.commit();
            }

            storage.markOld();
        } finally {
            close(metaIo);
            IntervalMetric.stop(FS_METRICS_PREFIX + ".timeseries.commit", commitMetricKey);
        }
    }

    /**
     * This contains all the extra information needed to track per transaction
     * information dirty files, etc.  The format for the dirty data file should be
     * the same as for the clean file.  This does not bother writing version
     * numbers here.
     * 
     * @author Sean McCauliff
     *
     */
    private class TransactionContext {

        private final Xid xid;

        private final Lock xLock = new ReentrantLock(true);

        /**
         * Where in the journal file we can find the parts that have been written.
         * Or which sections have been deleted in this transaction.
         */
        private final TLongArrayList journalLocations = new TLongArrayList(2);

        private final JournalWriter journalWriter;
        
        private final int timeOutSeconds;

        private byte dataType;
        
        private boolean isDataTypeSet = false;
        
        /** When true this FsId has been deleted in this transaction. */
        private boolean isDeleted = false;

       
        /**
         * 
         * @param xid
         * @param timeOutSeconds
         * @throws IOException
         */
        TransactionContext(Xid xid, int timeOutSeconds, JournalWriter jw) {
            
            this.timeOutSeconds = timeOutSeconds;
            this.xid = xid;
            this.journalWriter = jw;
        }
        
        boolean isDirty() throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                return journalLocations.size() != 0 || isDeleted;
            } finally {
                releaseLock();
            }
        }

        void deleteFile() throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            try {
                journalLocations.clear();
                isDeleted = true;
                isDataTypeSet = false;
                journalWriter.write(id(), DELETE_FILE_LOCATION, ArrayUtils.EMPTY_BYTE_ARRAY,0,  0);
            } finally {
                releaseLock();
            }
        }
        
        boolean isDeleted() throws FileStoreTransactionTimeOut, InterruptedException { 
                acquireLock();
                try {
                    return isDeleted;
                } finally {
                    releaseLock();
                }
            }
        
        void checkDeleted() {
            if (isDeleted) {
                throw new FileStoreIdNotFoundException(id(), "File has been deleted.");
            }
        }
        
        void deleteInterval(long start, long stop) 
            throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            
            try {
                checkDeleted();
                
                addOperation(new DeleteOperation(start, stop));
            } finally {
                releaseLock();
            }
        }

        void mergeIntervals(IntervalSet<SimpleInterval, SimpleInterval.Factory> valid,
                                         IntervalSet<TaggedInterval, TaggedInterval.Factory> originators) 
        throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            try {
                checkDeleted();
                for (Operation op : operations()) {
                    op.merge(valid);
                    op.mergeOriginators(originators);
                }
            } finally {
                releaseLock();
            }
        }
        
        private void addOperation(Operation op) throws InterruptedException, IOException {
            ByteArrayOutputStream bout = new ByteArrayOutputStream();
            DataOutputStream dout = new DataOutputStream(bout);
            op.writeTo(dout);
            long journalEntryLocation = journalWriter.write(id(), OP_LOCATION, bout);
            mCache.storeOperation(new OperationKey(journalEntryLocation, xid, id()), op);
            journalLocations.add(journalEntryLocation);
        }
        
        List<Operation> operations() 
            throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            RandomAccessJournalReader journalReader = null;
            boolean isFlushed = false;
            acquireLock();
            try {
                checkDeleted();
                final int nLocations = journalLocations.size();
                if (nLocations == 0) {
                    List<Operation> empty = Collections.emptyList();
                    return empty;
                }
                
                List<Operation> rv = new ArrayList<Operation>(nLocations);
                for (int i=0; i < nLocations; i++) {
                    long location = journalLocations.get(i);
                    Operation op = mCache.operation(new OperationKey(location, xid, id()));
                    if (op != null) {
                        rv.add(op);
                        continue;
                    }
                    //Operation is on disk.
                    if (!isFlushed) {
                        journalWriter.flush();
                        isFlushed = true;
                    }
                    if (journalReader == null) {
                        journalReader = new RandomAccessJournalReader(journalWriter.file());
                    }
                    JournalEntry journalEntry = journalReader.read(location);
                    assert journalEntry.fsId().equals(id());
                    DataInputStream din = new DataInputStream(new ByteArrayInputStream(journalEntry.data()));
                    op = Operation.readFrom(din);
                    rv.add(op);
                }
                return rv;
            } finally {
                close(journalReader);
                releaseLock();
            }
        }
        
        /**
         * Writes the combined metadata into the log.
         * @throws IOException 
         * @throws InterruptedException 
         * @throws FileStoreTransactionTimeOut 
         *
         */
        void prepare() throws IOException, FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            
            try {
                if (isDeleted) {
                    return;
                }
            
                org.apache.commons.io.output.ByteArrayOutputStream bout =
                    new org.apache.commons.io.output.ByteArrayOutputStream(128);
                DataOutputStream dout = new DataOutputStream(bout);
                
                Metadata metadata = metaData();
                IntervalSet<SimpleInterval, SimpleInterval.Factory> validCopy =
                    new IntervalSet<SimpleInterval, SimpleInterval.Factory>(metadata.valid());
                IntervalSet<TaggedInterval, TaggedInterval.Factory> originCopy =
                    new IntervalSet<TaggedInterval, TaggedInterval.Factory>(metadata.origin());
                
                mergeIntervals(validCopy,originCopy);
                
                if (isDataTypeSet) {
                    dout.writeByte(this.dataType);
                } else {
                    dout.writeByte(TransactionalRandomAccessFile.this.dataType);
                }
                
                validCopy.writeTo(dout);
                originCopy.writeTo(dout);
                
                journalWriter.write(storage.fsId(), META_LOCATION, bout);
                
            } finally {
                releaseLock();
            }
        }
        
        /**
         * Updates internal state to parent object instance with committed data.  Actual
         * data is updated in the target file with the Recovery object.
         * @throws InterruptedException 
         * @throws FileStoreTransactionTimeOut 
         * @throws IOException 
         *
         */
        void commit() throws FileStoreTransactionTimeOut, InterruptedException, IOException {
            acquireLock();
            try {
                if (isDeleted) {
                    return;
                }

                //Push all our changes into the authoritative copy in the
                //containing class.
                Metadata metadata = metaData();
                mergeIntervals(metadata.valid(), metadata.origin());
                for (int i = 0; i < journalLocations.size(); i++) {
                    mCache.removeOperation(new OperationKey(journalLocations.get(i), xid, id()));
                }

            } finally {
                releaseLock();
            }
        }
        
        
        /**
         * Writes bytes into the transactions data file.
         * @param buf
         * @param off Offset into buf.
         * @param size
         * @param start This is expressed in the clean data files address space.
         * @param originator
         * @throws IOException
         * @throws InterruptedException 
         * @throws FileStoreTransactionTimeOut 
         */
        void write(byte[] buf, int off, int size, long start, 
                   List<SimpleInterval> writeValid, 
                   List<TaggedInterval> writeOrigin) 
            throws IOException, FileStoreTransactionTimeOut, InterruptedException {
            
            acquireLock();
            try {
                checkDeleted();
                if (size == 0) {
                    return;
                }
            
                long journalPosition = 
                    journalWriter.write(storage.fsId(), start, buf, off, size);
                long end = start + size - 1;
               
                IntervalSet<SimpleInterval, SimpleInterval.Factory> writeValidSet = 
                    new IntervalSet<SimpleInterval, SimpleInterval.Factory>(simpleFactory, writeValid);
                IntervalSet<TaggedInterval, TaggedInterval.Factory> writeOriginSet =
                    new IntervalSet<TaggedInterval, TaggedInterval.Factory>(taggedFactory, writeOrigin);
                WriteOperation writeOp =
                    new WriteOperation(start, end, writeValidSet, writeOriginSet, journalPosition);
                addOperation(writeOp);
            } finally {
                releaseLock();
            }
        }
        
        void acquireLock() throws InterruptedException, FileStoreTransactionTimeOut {
            if (!xLock.tryLock(timeOutSeconds, TimeUnit.SECONDS)) {
                throw new FileStoreTransactionTimeOut("Did not acquire lock within time out.");
            }
        }
        
        void releaseLock() {
            xLock.unlock();
        }
        
        void setDataType(byte newType) throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                dataType = newType;
                isDataTypeSet = true;
            } finally {
                releaseLock();
            }
        }
        
        byte dataType() throws FileStoreTransactionTimeOut, InterruptedException {
            acquireLock();
            try {
                if (isDataTypeSet) {
                    return this.dataType;
                } else {
                    return TransactionalRandomAccessFile.this.dataType;
                }
            } finally {
                releaseLock();
            }
        }
    }
    
    
    /**
     * Use this to restore a TransactionalRandomAccessFile to a consistent
     * state if had reached a commit state.  This class is not MT-safe.
     * @author Sean McCauliff
     *
     */
    final static class Recovery implements RandomAccessRecovery {
 
        private final RandomAccessStorage storage;
        private boolean wroteMetaData = false;
        private boolean isDeleted = false;
        
        private Recovery(RandomAccessStorage storage) {
            this.storage = storage;
        }
        
        /**
         * This should be called in the order in which journal entries where written
         * into the journal.
         * @param journalEntry
         * @throws InterruptedException 
         * @see gov.nasa.kepler.fs.server.xfiles.TransactionalRandomAccessFile.TransactionContext#prepare()
         */
        @Override
        public void mergeRecovery(JournalEntry journalEntry) throws IOException, InterruptedException {
            NonContiguousReadWrite io = null;
            try {
                if (journalEntry.destStart() == OP_LOCATION) {
                    //do nothing.
                } else if (journalEntry.destStart() == DELETE_FILE_LOCATION) {
                    storage.delete(true);
                    isDeleted = true;
                } else if (journalEntry.destStart() == META_LOCATION) {
                    if (isDeleted) {
                        throw new IllegalStateException("FsId \"" + 
                            journalEntry.fsId() + "\" was marked deleted.");
                    }
                    io = storage.metaDataRw();
                    io.writeByte(FORMAT_VERSION);
                    io.seek(HEADER_SIZE);
                    io.write(journalEntry.data(), 0, journalEntry.data().length);
                    wroteMetaData = true; 
                } else {
                    if (isDeleted) {
                        throw new IllegalStateException("FsId \"" + 
                            journalEntry + "\" was marked deleted.");
                    }
                    io = storage.dataRw();
                    io.seek(journalEntry.destStart());
                    io.write(journalEntry.data(), 0, journalEntry.data().length);
                }
            } finally {
                close(io);
            }
        }
        
        
        @Override
        public void recoveryComplete() {
            if (!wroteMetaData && !isDeleted) {
                throw new IllegalStateException("No meta data back up for \"" +
                    storage.fsId() + "\"");
            }
        }
    }
    
    /**
     * Non transactional reading.  This is useful when the file store is not
     * currently running.
     * 
     * @author Sean McCauliff
     *
     */
    final static class NonTransactionalReader {
        final IntervalSet<SimpleInterval, SimpleInterval.Factory> valid = 
            new IntervalSet<SimpleInterval, SimpleInterval.Factory>(simpleFactory);
        final IntervalSet<TaggedInterval, TaggedInterval.Factory> originators =
            new IntervalSet<TaggedInterval, TaggedInterval.Factory>(taggedFactory);
        final byte dataType;
        final InputStream in;
        
        private NonTransactionalReader(RandomAccessStorage ras) throws IOException {
            
            NonContiguousReadWrite metaRead  = null;
            NonContiguousReadWrite dataRead = null;
            boolean ok = false;
            try {
                metaRead = ras.metaDataRw();
                DataInputStream metaIn =
                    new DataInputStream(new BufferedInputStream(new NonContiguousInputStream(metaRead), IOBUF_SIZE));
                byte version = metaIn.readByte();
                if (version != FORMAT_VERSION) {
                    throw new IllegalStateException("Expected version " + 
                        FORMAT_VERSION + " but got " + version + ".");
                }
                
                dataType = metaIn.readByte();
                valid.readFrom(metaIn);
                originators.readFrom(metaIn);
            
                dataRead = ras.dataRw();
                if (valid.intervals().size() > 0) {
                    dataRead.seek(valid.intervals().get(0).start());
                }
                in = new BufferedInputStream(new NonContiguousInputStream(dataRead), IOBUF_SIZE);
                ok = true;
            } finally {
                if (!ok) {
                    close(dataRead);
                }
                close(metaRead);
            }
        }
    }
}
 