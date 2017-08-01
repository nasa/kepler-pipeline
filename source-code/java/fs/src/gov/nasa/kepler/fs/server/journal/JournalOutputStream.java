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
import gov.nasa.kepler.io.DataOutputStream;

import java.io.IOException;
import java.io.OutputStream;
import java.util.concurrent.locks.Lock;
import static gov.nasa.kepler.fs.server.journal.JournalCommon.*;


/**
 * Implements chunked encoding for the journal.
 * 
 * This class is not MT-safe, the thread that has this should hold the lock
 * on the journal which should prevent more than one thread from overwriting
 * it's sections.
 * 
 * @author Sean McCauliff
 *
 */
public class JournalOutputStream extends OutputStream {

    
    private final DataOutputStream out;
    private final Lock closeLock;
    private final Crc32OutputStream checksumOut;
    
    /**
     * The number of bytes within the current chunk that has been written.
     */
    private int count = 0;
    private int chunkSizeIndex = 0;
    private long totalCount = 0;
    
    JournalOutputStream(DataOutputStream out, Crc32OutputStream checksumOut, Lock closeLock) {
        this.out = out;
        this.closeLock = closeLock;
        this.checksumOut = checksumOut;
    }

    @Override
    public void write(int b) throws IOException {
        if (count >= CHUNK_SCHEDULE[chunkSizeIndex]) {
            out.writeBoolean(true);
            chunkSizeIndex = nextChunkIndex(chunkSizeIndex);
            count = 0;
        }
        out.write(b);
        totalCount++;
        count++;
    }
    
    @Override
    public void write(byte[] buf, int off, int len) throws IOException {
        while (count + len > CHUNK_SCHEDULE[chunkSizeIndex]) {
            int canWriteBytes = CHUNK_SCHEDULE[chunkSizeIndex] - count;
            out.write(buf, off, canWriteBytes);
            out.writeBoolean(true);
            count = 0;
            chunkSizeIndex = nextChunkIndex(chunkSizeIndex);
            off += canWriteBytes;
            len -= canWriteBytes;
            totalCount += canWriteBytes;
        }
        
        if (len == 0) {
            return;
        }
        totalCount += len;
        count += len;
        out.write(buf, off, len);
    }
    
    
    /**
     * This writes an end of chunk when closed and resets the state.   This does
     * not close the underlying output stream.
     */
    @Override
    public void close() throws IOException  {
        int remainingBytes = CHUNK_SCHEDULE[chunkSizeIndex] - count;
        if (remainingBytes > 0) {
            for (int i=0; i < remainingBytes; i++) {
                out.write(0xa1);
            }
        }
        out.writeBoolean(false);
        out.writeLong(totalCount);
        out.writeInt((int)checksumOut.checksum());
        checksumOut.resetChecksumComputation();
        //hey, this does not call close.
        doneWriting();
        count = 0;
        chunkSizeIndex = 0;
        totalCount  = 0;
        closeLock.unlock();
    }

    /**
     * This gets called after all bytes have been written, but before unlock()
     * has been called.
     * @throws IOException
     */
    protected void doneWriting() throws IOException {
        //This does nothing.
    }
    
    @Override
    public void flush() throws IOException {
        out.flush();
    }
}
