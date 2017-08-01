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

import static gov.nasa.kepler.fs.server.journal.JournalCommon.FINISHED_MAGIC;
import static gov.nasa.kepler.fs.server.journal.JournalCommon.VERSION;
import gnu.trove.TLongArrayList;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.channels.FileChannel.MapMode;
import java.util.ArrayList;
import java.util.List;


import javax.transaction.xa.Xid;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Allows multiple threads to be writing simultaneously to the journal file.
 * The outputStream() method is not implemented as it is slow.  Internally this
 * uses a memory mapped file for the journal which it expands and remaps 
 * as the journal gets larger.
 * 
 * This class is MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
public final class MmapJournalWriter implements JournalWriter {

    private final static Log log = LogFactory.getLog(MmapJournalWriter.class);
    
    /** This should never be more than 2G due to mappedbytebuffer
     * restrictions.
     */
    private final static long JOURNAL_SIZE_INCREMENT = 1024L*1024*1024*1;
    /** This should never be more than 2G. */
    private final static long INITIAL_JOURNAL_SIZE = 1024L*1024;
    
    /** This should only be read or written to in a synchronized block. */
    private long endOfFile;
    
    private final File journalFile;
    
    /** This should only be read or written to in a synchronized block. */
    private final List<MappedByteBuffer> mappedByteBuffers = 
            new ArrayList<MappedByteBuffer>();
    
    /** This should be only accessed within a monitor. This is inclusive.  */
    private final TLongArrayList mmapOnDiskStart = new TLongArrayList();
    
    /** This should only be access within a monitor. This is exclusive. */
    private final TLongArrayList mmapOnDiskEnd = new TLongArrayList();
    
    
    private final FileChannel fchannel;
    private final RandomAccessFile raf;
    
    private volatile boolean isClosed = false;
    
    private boolean errorOccurredDuringAllocation = false;
    
    public MmapJournalWriter(File journalFile, Xid xid) throws IOException {
        if (journalFile == null) {
            throw new NullPointerException("journalFile");
        }
        this.journalFile = journalFile;
        
        raf = new RandomAccessFile(journalFile, "rw");
        raf.setLength(INITIAL_JOURNAL_SIZE);
        fchannel = raf.getChannel();
        MappedByteBuffer initialBuffer =
            fchannel.map(MapMode.READ_WRITE, 0, INITIAL_JOURNAL_SIZE);
        mappedByteBuffers.add(initialBuffer);
        /** initialize the journal. */
        initialBuffer.put(VERSION);
        String xidString = Util.xidToString(xid);
        ByteArrayOutputStream xidStringBuf = new ByteArrayOutputStream();
        @SuppressWarnings("resource")
        DataOutputStream dout = new DataOutputStream(xidStringBuf);
        dout.writeUTF(xidString);
        
        initialBuffer.put(xidStringBuf.toByteArray());
        endOfFile = initialBuffer.position();
        
        mmapOnDiskStart.add(0);
        mmapOnDiskEnd.add(INITIAL_JOURNAL_SIZE);
    }
    
    @Override
    public long write(FsId fsId, long start, byte[] data, int off, int len)
        throws IOException, InterruptedException {
        return writeInternal(fsId, start, data, off, len, null);
    }

    private long writeInternal(FsId fsId, long start, byte[] data, int off, int len,
        ByteArrayOutputStream bout) throws IOException, InterruptedException {
        
        if (isClosed) {
            throw new IOException("Attempt to write to closed journal \"" + journalFile + "\".");
        }
        
        if (!( (data == null) ^ (bout == null))) {
            throw new IllegalArgumentException("data == null xor bout == null is not true");
        }
        
        //Yes, copying this to an intermediate array is actually faster.
        int headerSize = fsId.writeToLength() + CONSTANT_HEADER_SIZE;
        int entryLength = headerSize + len + JournalCommon.CHECKSUM_SIZE;
        
        ByteArrayOutputStream entryBuffer = new ByteArrayOutputStream(entryLength);
        Crc32OutputStream crc32Output = new Crc32OutputStream(entryBuffer);
        DataOutputStream entryDataOutput = new DataOutputStream(crc32Output);
        fsId.writeTo(entryDataOutput);
        entryDataOutput.writeInt(len);
        entryDataOutput.writeLong(start);

        if (data != null) {
            entryDataOutput.write(data, off, len);
        } else {
            bout.writeTo(entryDataOutput);
        }
        int checksum = (int) crc32Output.checksum();
        entryDataOutput.writeInt(checksum);
        byte[] journalEntryData = entryBuffer.toByteArray();
        entryBuffer = null;
        entryDataOutput = null;
       
       
        Pair<Long, ByteBuffer> locationAndBuffer = findMmap(journalEntryData.length);
        locationAndBuffer.right.put(journalEntryData);
        return locationAndBuffer.left;
    }

    private String stateDescription() {
        StringBuilder bldr = new StringBuilder();
        bldr.append("mmapOnDiskStart: ").append(mmapOnDiskStart)
            .append(" mmapOnDisEnd: ").append(mmapOnDiskEnd);
        return bldr.toString();
    }
    
    /** Find the byte buffer to use.  Allocate a new one if needed.
     * 
     * @param   entryLength the length of the journal entry including headers
     * and footers.
     * @return The index into the mmap arrays to use to write this journal entry.
     * @throws IOException
     */
    private synchronized Pair<Long, ByteBuffer> findMmap(int entryLength)
            throws IOException, InterruptedException {
        //I would prefer not to use synchronized and instead use read/write locks
        //but the Condition of the read/write lock is always associated with the
        //write lock which makes all the code way more complicated.
        
        if (errorOccurredDuringAllocation) {
            throw new IllegalStateException("Error occurred during allocation on a different thread.");
        }
    	
        long journalEntryStart = endOfFile;
        endOfFile += entryLength;
        long journalEntryEnd = endOfFile;
        
        boolean found = false;
        boolean willAllocate = false;
        int endIndex = mmapOnDiskEnd.binarySearch(journalEntryEnd);
        if (endIndex >= 0) {
            //ends are exclusive
            endIndex++;
        } else {
            endIndex = -endIndex -1;
        }
        int startIndex = -1;
        if (endIndex < mmapOnDiskEnd.size()) {
            found = true;
        } else {
            startIndex = mmapOnDiskStart.binarySearch(journalEntryEnd);
            if (startIndex >= 0) {
                startIndex++;
            } else {
                startIndex = -startIndex - 1;
            }
            if (startIndex != endIndex || journalEntryStart != mmapOnDiskEnd.get(mmapOnDiskEnd.size() - 1)) {
                //this is the boundary crossing thread.
                willAllocate = true;
            }
        }
        if (!(willAllocate || found)) {
            throw new IllegalStateException("Failed to find or allocate mmap byte byffer.");
        }

        
        //Allocate a new mmap buffer whos start is aligned with the start
        //of the journal entry.
        if (willAllocate) {
            allocateNewMmapBuffer(journalEntryStart, endIndex);
        }
        
        MappedByteBuffer myBuffer = mappedByteBuffers.get(endIndex);
        
        long startPositionInMap = journalEntryStart - mmapOnDiskStart.get(endIndex);
        if (startPositionInMap >= Integer.MAX_VALUE-1) {
            throw new IllegalStateException("Bad position in mmap: " + 
                startPositionInMap + "." + stateDescription());
        }
        if (startPositionInMap < 0) {
            throw new IllegalStateException("Bad position in mmap: " +
                startPositionInMap + "." + stateDescription());
        }
        
        ByteBuffer myBufferCopy = myBuffer.duplicate();
        myBufferCopy.position((int) startPositionInMap);
        
        return Pair.of(journalEntryStart, myBufferCopy);
    }
    
    /**
     * This should only be called inside the synchronized block.
     * @param journalEntryStart
     * @param endIndex
     * @throws IOException
     * @throws InterruptedException
     */
    private void allocateNewMmapBuffer(long journalEntryStart, int endIndex) throws IOException, InterruptedException {
        boolean ok = false;
        try {
            long newFileLength = journalEntryStart + JOURNAL_SIZE_INCREMENT;
            raf.setLength(newFileLength);
            MappedByteBuffer newBuffer = 
                fchannel.map(MapMode.READ_WRITE, journalEntryStart, JOURNAL_SIZE_INCREMENT);
            mappedByteBuffers.add(newBuffer);
            mmapOnDiskStart.add(journalEntryStart);
            mmapOnDiskEnd.add(newFileLength);
            log.info("Created new mmap for journal file \"" + journalFile +
                  "\" address [" + mmapOnDiskStart.get(endIndex) + "," + mmapOnDiskEnd.get(endIndex) + ").");
            if (journalEntryStart < mmapOnDiskStart.get(endIndex)) {
                throw new IllegalStateException("journalEntryStart(" +
                    journalEntryStart + ") mmapOnDiskStart[" + endIndex + "]("
                    + mmapOnDiskStart.get(endIndex) + ")");
            }
            ok = true;
        } finally {
            errorOccurredDuringAllocation = !ok;
        }
    }

    
    @Override
    public long write(FsId fsId, long start, ByteArrayOutputStream bout)
        throws IOException, InterruptedException {

        return writeInternal(fsId, start, null, 0, bout.size(), bout);
    }

    /**
     * Unsupported.
     */
    @Override
    public Pair<Long, DataOutputStream> outputStream(FsId fsId, long start)
        throws InterruptedException, IOException {

        throw new UnsupportedOperationException();
    }

    @Override
    public synchronized void close() throws IOException {
        try {
            if (isClosed) {
                return;
            }
            try {
                flush();
            } catch (InterruptedException ix) {
                throw new IOException(ix);
            }
            fchannel.position(endOfFile);
            ByteBuffer bbuf = ByteBuffer.allocate(4);
            bbuf.putInt(FINISHED_MAGIC);
            bbuf.position(0);
            fchannel.write(bbuf);
            endOfFile += 4;
            fchannel.force(true);
            for (MappedByteBuffer mmap : mappedByteBuffers) {
                FileUtil.unmap(mmap);
            }
        } finally {
            isClosed = true;
            FileUtil.close(fchannel);  //This also closes raf.            
        }
        
        RandomAccessFile tmpHandle = new RandomAccessFile(journalFile, "rw");
        try {
            tmpHandle.setLength(endOfFile); //Trim any excess from the mmapping.)
        } finally {
            tmpHandle.close();
        }
        log.debug("Wrote " + endOfFile+ " bytes into journal \"" + journalFile + "\".");
    }

    @Override
    public boolean isClosed() {
        return isClosed;
    }
    
    @Override
    public File file() {
        return journalFile;
    }

    /**
     * 
    */
    @Override
    public synchronized void flush() throws IOException, InterruptedException {
        List<MappedByteBuffer> cpy = null;
        synchronized (this) {
            cpy = new ArrayList<MappedByteBuffer>(mappedByteBuffers);
        }
        for (MappedByteBuffer mmap : cpy) {
            mmap.force();
        }
    }

}
