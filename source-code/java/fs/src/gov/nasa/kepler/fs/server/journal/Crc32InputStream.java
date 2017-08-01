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

import java.io.IOException;
import java.io.InputStream;

import com.jcraft.jzlib.CRC32;

public final class Crc32InputStream extends InputStream {

    private final CRC32 crc32 = new CRC32();
    private final InputStream in;
    private final byte[] singleByteBuf = new byte[1];
    
    public Crc32InputStream(InputStream in) {
        this.in = in;
    }
    
    @Override
    public int read() throws IOException {
        int b = in.read();
        if (b != -1) {
        	singleByteBuf[0] = (byte)b;
            crc32.update(singleByteBuf, 0, 1);
        }
        return b;
    }

    //These methods are much faster, but the checksum computation seems
    //sensitve to read(), read(), read(), read() vs read(new byte[4])
//    @Override
//    public int read(byte[] b) throws IOException {
//        int nRead = super.read(b);
//        if (nRead != -1) {
//            crc32.update(b, 0, nRead);
//        }
//        return nRead;
//    }
//    
//
//    @Override
//    public int read(byte[] b, int off, int len) throws IOException {
//        int nRead = super.read(b, off, len);
//        if (nRead != -1) {
//            crc32.update(b, off,nRead);
//        }
//        return nRead;
//    }
    
    @Override
    public void close() throws IOException {
        in.close();
    }
    
    @Override
    public int available() throws IOException {
    	return in.available();
    }
    
    @Override
    public boolean markSupported() {
    	return in.markSupported();
    }
    
    @Override
    public void mark(int readlimit) {
        in.mark(readlimit);
    }
    
    @Override
    public void reset() throws IOException {
    	in.reset();
    }
    
    @Override
    public long skip(long nBytes) throws IOException {
    	return in.skip(nBytes);
    }
    
    public long checksum() {
        return crc32.getValue();
    }
    
    public void resetChecksumCalculation() {
        crc32.reset();
    }
}
