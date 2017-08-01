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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.util.Util;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.concurrent.locks.ReentrantLock;

import javax.transaction.xa.Xid;

import org.apache.commons.io.output.CountingOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static gov.nasa.kepler.fs.server.journal.JournalCommon.*;
/**
 *
 *   This class is MT safe.
 *   
 * @author Sean McCauliff
 *
 */
public final class SerialJournalWriter implements JournalWriter {

    @SuppressWarnings("unused")
    private static final Log log = LogFactory.getLog(SerialJournalWriter.class);
    
   
    private static final int BUFFER_SIZE = 1024*1024;
    private final File journalFile;
    private volatile FileOutputStream fout;
    private DataOutputStream output;
    private CountingOutputStream counter;
    private Crc32OutputStream crc32Output;
    
    /**
     * Hand this out.  Don't use it internally.
     */
    private DataOutputStream unlockOutputStream;
    private final ReentrantLock mutex = new ReentrantLock(true);
    
    public SerialJournalWriter(File journalFile,  Xid xid) throws IOException {
        this.journalFile = journalFile;
        fout = new FileOutputStream(journalFile);
        BufferedOutputStream bufOut = 
            new BufferedOutputStream(fout, BUFFER_SIZE);
        counter = new CountingOutputStream(bufOut);
        crc32Output = new Crc32OutputStream(counter);
        output = new DataOutputStream(crc32Output);
        output.writeByte(VERSION);
        output.writeUTF(Util.xidToString(xid));
        
        crc32Output.resetChecksumComputation();
        unlockOutputStream = new DataOutputStream(new JournalOutputStream(output, crc32Output, mutex));
    }
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.server.journal.JournalWriter#write(gov.nasa.kepler.fs.api.FsId, long, byte[], int, int)
     */
    @Override
    public long write(FsId fsId, long start, byte[] data, int off, int size) 
        throws IOException, InterruptedException {
        
        
        mutex.lockInterruptibly();
        try {

            long journalStart = counter.getByteCount();
            fsId.writeTo(output);
            output.writeInt(size);
            output.writeLong(start);
            output.write(data, off, size);
            int checksum = (int) crc32Output.checksum();
            output.writeInt(checksum);
            crc32Output.resetChecksumComputation();
            return journalStart;
        } finally {
            mutex.unlock();
        }
    }
    
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.server.journal.JournalWriter#write(gov.nasa.kepler.fs.api.FsId, long, org.apache.commons.io.output.ByteArrayOutputStream)
     */
    @Override
    public long write(FsId fsId, long start, 
            org.apache.commons.io.output.ByteArrayOutputStream bout) 
         throws IOException, InterruptedException {
        

        mutex.lockInterruptibly();
        try {
            
          /*  log.info("Writing journal entry " + fsId + " start " + start + " data.length " + bout.size()
                + " data: " + Arrays.toString(bout.toByteArray()));
            */
            
            long journalStart = counter.getByteCount();
            fsId.writeTo(output);
            output.writeInt(bout.size());
            output.writeLong(start);
            bout.writeTo(output);
            output.writeInt((int)crc32Output.checksum());
            crc32Output.resetChecksumComputation();
            //output.write(bout.toByteArray());
            return journalStart;
        } finally {
            mutex.unlock();
        }
    }
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.server.journal.JournalWriter#outputStream(gov.nasa.kepler.fs.api.FsId, long)
     */
    @Override
    public Pair<Long,DataOutputStream> outputStream(FsId fsId, long start) 
        throws InterruptedException, IOException {
        mutex.lockInterruptibly();
        
        long journalStart = counter.getByteCount();
        fsId.writeTo(output);
        output.writeInt(CHUNK_ENCODING_SIZE);
        output.writeLong(start);
        return Pair.of(journalStart,unlockOutputStream);
    }
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.server.journal.JournalWriter#close()
     */
    @Override
    public void close() throws IOException {
        try {
            mutex.lockInterruptibly();
        } catch (InterruptedException ix) {
            throw new IOException(ix);
        }
        try {
            if (output == null) {
                return;
            }
            
            output.writeInt(FINISHED_MAGIC);
            output.flush();
            fout.getFD().sync();
            output.close();
            //Release memory stored in the buffers of these classes.
            output = null;
            counter = null;
            fout = null;
            unlockOutputStream = null;
        } finally {
            mutex.unlock();
        }
    }
    
    @Override
    public boolean isClosed() {
        return fout == null;
    }
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.server.journal.JournalWriter#file()
     */
    @Override
    public File file() {
        return journalFile;
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.server.journal.JournalWriter#flush()
     */
    @Override
    public void flush() throws IOException, InterruptedException {
        mutex.lockInterruptibly();
        try {
            if (output != null) {
                output.flush();
            }
        } finally {
            mutex.unlock();
        }
    }
        
}
