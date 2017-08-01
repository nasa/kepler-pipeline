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


import java.io.DataInput;
import java.io.IOException;

import org.apache.commons.io.output.ByteArrayOutputStream;

/**
 * Common constants and methods for reading.writing journals.
 * 
 * @author Sean McCauliff
 *
 */
class JournalCommon {

    static final int FINISHED_MAGIC = 709306978;
    
    static final int[] CHUNK_SCHEDULE = { 64, 256, 1024*4, 1024*8 };
    
    static final int CHECKSUM_SIZE = 4;
    
    /**
     * 3 - Changed Xid encoding to use base64.
     * 4 - Use FsId.writeTo() to encode FsIds.  Allow for chunk encoding for
     * journal sizes.
     * 5 - Add journal entry crc32.
     */
    static final byte VERSION = 5;
    
    static final int CHUNK_ENCODING_SIZE = -1;
    
    private static final ThreadLocal<byte[]> chunkBuf = new ThreadLocal<byte[]>() {
        @Override
        protected byte[] initialValue() {
            return new byte[CHUNK_SCHEDULE[CHUNK_SCHEDULE.length - 1]];
        }
    };
    
    
    static int nextChunkIndex(int currentIndex) {
        return Math.min(currentIndex + 1, CHUNK_SCHEDULE.length - 1);
    }
    
    /**
     * Reads data payload that has been chunked.
     * @param input
     * @return
     * @throws IOException
     */
    static byte[] readChunkEncoding(DataInput input) throws IOException {
        ByteArrayOutputStream totalBuf = new ByteArrayOutputStream();
        int chunkSizeIndex  = 0;
        long readLength = 0;
        input.readFully(chunkBuf.get(), 0, CHUNK_SCHEDULE[chunkSizeIndex]);
        for (boolean more = input.readBoolean(); more; more = input.readBoolean()) {
            totalBuf.write(chunkBuf.get(), 0, CHUNK_SCHEDULE[chunkSizeIndex]);
            readLength += CHUNK_SCHEDULE[chunkSizeIndex];
            chunkSizeIndex = nextChunkIndex(chunkSizeIndex);
            input.readFully(chunkBuf.get(), 0, CHUNK_SCHEDULE[chunkSizeIndex]);
        }
        
        long totalLength = input.readLong();
        int diff = (int) (totalLength - readLength);
        totalBuf.write(chunkBuf.get(), 0, diff);
        
        return totalBuf.toByteArray();
    }
}
