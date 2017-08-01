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

import static gov.nasa.kepler.fs.server.journal.JournalCommon.*;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.server.nc.NonContiguousInputStream;
import gov.nasa.kepler.io.DataInputStream;

import java.io.BufferedInputStream;
import java.io.Closeable;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * Reads a journal entry from a specific part of the journal.
 * 
 * This class is MT safe.
 * 
 * @author Sean McCauliff
 *
 */
public class RandomAccessJournalReader implements Closeable {
    
    private final RandomAccessFile raf;
    private final File journalFile;
    
    public RandomAccessJournalReader(File journalFile) throws IOException {
        this.raf = new RandomAccessFile(journalFile, "r");
        this.journalFile = journalFile;
    }
    
    public synchronized JournalEntry read(long startPos) throws IOException {
        raf.seek(startPos);
        NonContiguousInputStream ncin = new NonContiguousInputStream(raf);
        BufferedInputStream bin = new BufferedInputStream(ncin);
        Crc32InputStream crc32InputStream = new Crc32InputStream(bin);
        DataInputStream din = new DataInputStream(crc32InputStream);
        FsId id = FsId.readFrom(din);
        int dataSize = din.readInt();
        long sourceLocation = din.readLong();
        byte[] data = null;
        if (dataSize == CHUNK_ENCODING_SIZE) {
            data = readChunkEncoding(din);
        } else {
            data = new byte[dataSize];
            din.readFully(data);
        }
        int computedChecksum = (int) crc32InputStream.checksum();
        int ondiskChecksum = din.readInt();
        if (computedChecksum != ondiskChecksum) {
            throw new BadChecksumException("Bad checksum in journal file \"" +
                journalFile + "\".  Journal entry starts at file offset " + 
                startPos + " for FsId \"" + id + "\".");
        }
        return new JournalEntry(id, data, sourceLocation, startPos);
    }
    
    public synchronized void close() throws IOException {
        raf.close();
    }
}
