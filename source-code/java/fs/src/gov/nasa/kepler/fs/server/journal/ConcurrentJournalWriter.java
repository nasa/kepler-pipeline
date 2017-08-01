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

package gov.nasa.kepler.fs.server.journal;

import static gov.nasa.kepler.fs.server.journal.JournalCommon.CHUNK_ENCODING_SIZE;
import static gov.nasa.kepler.fs.server.journal.JournalCommon.FINISHED_MAGIC;
import static gov.nasa.kepler.fs.server.journal.JournalCommon.VERSION;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.fs.server.nc.NonContiguousOutputStream;
import gov.nasa.kepler.fs.server.raf.RandomAccessFileProxy;
import gov.nasa.kepler.fs.server.xfiles.DebugReentrantReadWriteLock;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.concurrent.atomic.AtomicLong;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantReadWriteLock;
import java.util.zip.CRC32;

import javax.transaction.xa.Xid;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.commons.io.output.CountingOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Allows multiple threads to be writing simultaneously to the journal file.
 * The OutputStream returned by the outputStream() method still causes other
 * threads to block.
 * 
 * This object uses an internal read-write lock internally.  Do not use synchronized
 * to coordinate thread synchronization with this object.
 * 
 * This class is MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public final class ConcurrentJournalWriter implements JournalWriter {

    private final static Log log = LogFactory.getLog(ConcurrentJournalWriter.class);
    
    private final ReentrantReadWriteLock rwLock = new DebugReentrantReadWriteLock(true /* fair */);
    private final Lock readLock = rwLock.readLock();
    private final Lock writeLock = rwLock.writeLock();
    private final AtomicLong endOfFile = new AtomicLong();
    private final File journalFile;
    
    private volatile boolean isClosed = false;
    
    public ConcurrentJournalWriter(File journalFile, Xid xid) throws IOException {
        if (journalFile == null) {
            throw new NullPointerException("journalFile");
        }
        this.journalFile = journalFile;
        
        /** initialize the journal. */
        FileOutputStream fout = new FileOutputStream(journalFile);
        BufferedOutputStream bufOut = new BufferedOutputStream(fout);
        CountingOutputStream counter = new CountingOutputStream(bufOut);
        DataOutputStream dout = new DataOutputStream(counter);
        dout.writeByte(VERSION);
        dout.writeUTF(Util.xidToString(xid));
        dout.close();
        endOfFile.addAndGet(counter.getByteCount());
    }
    
    @Override
    public long write(FsId fsId, long start, byte[] data, int off, int size)
        throws IOException, InterruptedException {

        readLock.lockInterruptibly();
        RandomAccessFile output = null;
        try {
            
            if (isClosed) {
                throw new IOException("journal \"" + journalFile + "\" is closed");
            }
            
            output = new RandomAccessFile(journalFile, "rw");
            
            int headerLength = fsId.writeToLength() + 4 + 8;
            int entryLength =  headerLength + size + 4 /*footer length*/;
            long journalEntryStart = endOfFile.getAndAdd(entryLength);
            output.seek(journalEntryStart);
            
            //Yes, copying this to an intermediate array is actually faster.
            ByteArrayOutputStream entryBuffer = new ByteArrayOutputStream(entryLength);
            Crc32OutputStream crc32 = new Crc32OutputStream(entryBuffer);
            DataOutputStream entryDataOutput = new DataOutputStream(crc32);
            
            fsId.writeTo(entryDataOutput);
            entryDataOutput.writeInt(size);
            entryDataOutput.writeLong(start);
            entryDataOutput.write(data, off, size);
            entryDataOutput.writeInt((int)crc32.checksum());
            output.write(entryBuffer.toByteArray());
            return journalEntryStart;
        } finally {
            readLock.unlock();
            FileUtil.close(output);
        }
    }

    @Override
    public long write(FsId fsId, long start, ByteArrayOutputStream bout)
        throws IOException, InterruptedException {

        readLock.lockInterruptibly();
        RandomAccessFile output = null;
        try {
            
            if (isClosed) {
                throw new IOException("journal \"" + journalFile + "\" is closed");
            }
            
            output = new RandomAccessFile(journalFile, "rw");
            
            int headerSize = fsId.writeToLength() + 4 + 8;
            int entryLength = headerSize + bout.size() + JournalCommon.CHECKSUM_SIZE;
            long journalEntryStart = endOfFile.getAndAdd(entryLength);
            output.seek(journalEntryStart);
            
            ByteArrayOutputStream entryBuffer = new ByteArrayOutputStream(entryLength);
            Crc32OutputStream crc32OutputStream = new Crc32OutputStream(entryBuffer);
            DataOutputStream entryDataOutput = new DataOutputStream(crc32OutputStream);

            //Yes, copying this to an intermediate array is actually faster.
            fsId.writeTo(entryDataOutput);
            entryDataOutput.writeInt(bout.size());
            entryDataOutput.writeLong(start);
            bout.writeTo(entryDataOutput);
            entryDataOutput.writeInt((int) crc32OutputStream.checksum());
            output.write(entryBuffer.toByteArray());
            return journalEntryStart;
        } finally {
            readLock.unlock();
            FileUtil.close(output);
        }
    }

    /**
     * This is not concurrent and acquires the write lock on this object.
     */
    @Override
    public Pair<Long, DataOutputStream> outputStream(FsId fsId, long start)
        throws InterruptedException, IOException {

        writeLock.lockInterruptibly();
        boolean ok = false;
        RandomAccessFile output = null;
        try {
            output = new RandomAccessFile(journalFile, "rw");
            output.seek(endOfFile.get());
            RandomAccessFileProxy raf = new RandomAccessFileProxy(output);
            NonContiguousOutputStream rafAsOutputStream = new NonContiguousOutputStream(raf);
            BufferedOutputStream bufOut = new BufferedOutputStream(rafAsOutputStream);
            final CountingOutputStream countOut = new CountingOutputStream(bufOut);
            Crc32OutputStream crc32OutputStream = new Crc32OutputStream(countOut);
            final DataOutputStream dout0 = new DataOutputStream(crc32OutputStream);
            
            
            fsId.writeTo(dout0);
            dout0.writeInt(CHUNK_ENCODING_SIZE);
            dout0.writeLong(start);
            
            JournalOutputStream journalOutputStream = new JournalOutputStream(dout0, crc32OutputStream, writeLock) {
                @Override
                protected void doneWriting() throws IOException {
                    if (log.isDebugEnabled()) {
                        log.debug("Closed journal output stream.  Wrote " + countOut.getByteCount() + " bytes.");
                    }
                    dout0.close();
                    endOfFile.addAndGet(countOut.getByteCount());
                }
            };
            //Yes, this is the second level of data output stream.  *sigh*
            DataOutputStream dout1 = new DataOutputStream(journalOutputStream);
            ok = true;
            return Pair.of(endOfFile.get(), dout1);
        } finally {
            if (!ok) {
                writeLock.unlock();
                FileUtil.close(output);
            }
        }
    }

    @Override
    public void close() throws IOException {
        try {
            writeLock.lockInterruptibly();
        } catch (InterruptedException ix) {
            throw new IOException(ix);
        }
        RandomAccessFile raf = null;
        try {
            if (isClosed) {
                return;
            }
            raf = new RandomAccessFile(journalFile, "rw");
            raf.seek(endOfFile.get());
            raf.writeInt(FINISHED_MAGIC);
            endOfFile.addAndGet(4);
            raf.getFD().sync();
            isClosed = true;
        } finally {
            FileUtil.close(raf);
            writeLock.unlock();
        }
    }

    public boolean isClosed() {
        return isClosed;
    }
    
    @Override
    public File file() {
        return journalFile;
    }

    /**
     * This implementation does nothing since we don't have an instance buffer
     * here.
     */
    @Override
    public void flush() throws IOException, InterruptedException {
        //This does nothing.
    }

}
