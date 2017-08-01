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

import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.io.DataOutputStream;
import gov.nasa.spiffy.common.collect.Pair;

import java.io.Closeable;
import java.io.File;
import java.io.IOException;

/**
 * A place to write TransactionalFile data before it is committed.
 *
* 
* File format:
*  version (1 byte)
*  xid (utf encoded)
*  record*
*  
*  where a record is formatted as:
*   fsid (utf encoded)
*   data size (4 bytes)
*   source data address (8 bytes)
*   data bytes*
*   checksum the crc32 (4 bytes)
*   
*   if data size == -1 then data is formatted as follows
*     chunk+
*     total data size (8 bytes)
*     
*    chunk is
*      bytes of length JournalCommon.CHUNK_SCHEDULE
*      more boolean indicating if there is a next chunk.
*   
*  Implementations must be MT-safe.
*/
public interface JournalWriter extends Closeable {

    final int SIZE_SIZE = 4;
    final int SOURCE_DATA_ADDRESS_SIZE = 8;
    final int CONSTANT_HEADER_SIZE = SIZE_SIZE + SOURCE_DATA_ADDRESS_SIZE;
    
    /**
     * 
     * @param fsId
     * @param start Where in the actual file this data would have been written.
     * @param data
     * @param size How many bytes from data to write.
     * @param off The offset into buf to start.
     * @return  The address in the file where the record starts.
     * @throws IOException 
     * @throws InterruptedException 
     */
    long write(FsId fsId, long start, byte[] data, int off, int size)
        throws IOException, InterruptedException;

    /**
     * Writes the contents of the ByteArrayOutputStream to the journal.
     * @param fsId
     * @param start
     * @param bout
     * @return
     * @throws IOException
     * @throws InterruptedException
     */
    long write(FsId fsId, long start,
        org.apache.commons.io.output.ByteArrayOutputStream bout)
        throws IOException, InterruptedException;

    /**
     * This locks the journal until the stream is closed.  Closing this stream
     * does not close the underlying journal.
     * @return (journal start, output stream)
     * @param start This is the location in the users file.  This output is
     * already buffered.
     * @throws InterruptedException 
     * @throws IOException 
     */
    Pair<Long, DataOutputStream> outputStream(FsId fsId, long start)
        throws InterruptedException, IOException;

    void close() throws IOException;
    
    boolean isClosed() throws IOException;

    File file();

    void flush() throws IOException, InterruptedException;

}