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
import gov.nasa.kepler.io.DataInputStream;
import gov.nasa.kepler.io.DataOutputStream;

import static gov.nasa.kepler.fs.server.journal.JournalCommon.*;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.util.Util;

import java.io.BufferedInputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.Iterator;
import java.util.NoSuchElementException;

import javax.transaction.xa.Xid;

import org.apache.commons.io.input.CountingInputStream;

/**
 * Reads sections of the journal in the order they were written.
 * 
 * This class is MT safe.  See JournalWriter for the file format.  When used as
 * an Iterator this is not MT-safe because the availability of more items may
 * change between invocations of hasNext() and next().
 * 
 * @author Sean McCauliff
 *
 */
public class JournalStreamReader implements Closeable, Iterator<JournalEntry>, Iterable<JournalEntry>{

    private static final int BUFFER_SIZE = 1024*1024;
    private static final int FINISHED_MAGIC_SIZE = 4;
    
    private final File journalFile;
    private final DataInputStream input;
    private final Xid xid;
    private final CountingInputStream counter;
    private final Crc32InputStream crc32InputStream;
    private final long journalLength;
    
    public JournalStreamReader(File journalFile) throws IOException {
        this.journalFile = journalFile;
        this.journalLength = journalFile.length() - FINISHED_MAGIC_SIZE;
        RandomAccessFile raf = new RandomAccessFile(journalFile, "rw");
        raf.seek(journalLength);
        int readMagic = raf.readInt();
        raf.close();

        if (readMagic != JournalCommon.FINISHED_MAGIC) {
            throw new IllegalStateException("Journal file not correctly terminated.");
        }
        
        FileInputStream fileIn = new FileInputStream(journalFile);
        BufferedInputStream bufIn = new BufferedInputStream(fileIn, BUFFER_SIZE);
        counter = new CountingInputStream(bufIn);
        crc32InputStream = new Crc32InputStream(counter);
        input = new DataInputStream(crc32InputStream);

        byte readVersion = input.readByte();
        if (readVersion != VERSION) {
            throw new IllegalStateException("Expected journal version " + 
                VERSION + " but found " + readVersion + ".");
        }
        String xidString = input.readUTF();
        xid = Util.stringToXid(xidString);
        crc32InputStream.resetChecksumCalculation();
    }
    
    /**
     * 
     * @return The next entry in the file or null if at EOF.
     */
    public synchronized JournalEntry nextEntry() throws IOException {
        if (counter.getByteCount() == journalLength) {
            return null;
        }
        
        long entryLocation = counter.getByteCount();
        FsId id = FsId.readFrom(input);
        int dataSize = input.readInt();
        long sourceStart = input.readLong();
        byte[] data = null;
        if (dataSize == CHUNK_ENCODING_SIZE) {
            data = readChunkEncoding(input);
        } else {
            data = new byte[dataSize];
            input.readFully(data);
        }
        int computedChecksum = (int) crc32InputStream.checksum();
        int ondiskChecksum = input.readInt();
        crc32InputStream.resetChecksumCalculation();

        if (computedChecksum != ondiskChecksum) {
            throw new BadChecksumException("Invalid CRC32 for journal file \""
                + journalFile + "\".  Entry location at offset " + 
                entryLocation + " for FsId \"" + id + "\".");
        }
        return new JournalEntry(id, data, sourceStart, entryLocation);
    }
    
    
    public synchronized void close() throws IOException {
        input.close();
    }
    
    public File file() {
        return journalFile;
    }
    
    public Xid xid() {
        return xid;
    }

    @Override
    public synchronized boolean hasNext() {
        return counter.getByteCount() != journalLength;
    }

    @Override
    public JournalEntry next() {
        JournalEntry entry;
        try {
            entry = nextEntry();
        } catch (IOException e) {
            throw new FileStoreException("From iterator.", e);
        }
        if (entry == null) {
            throw new NoSuchElementException();
        }
        return entry;
    }

    /**
     * This method is not implemented.
     */
    @Override
    public void remove() {
        throw new UnsupportedOperationException();
    }
    
    @Override
    public Iterator<JournalEntry> iterator() {
        return this;
    }
    
}
