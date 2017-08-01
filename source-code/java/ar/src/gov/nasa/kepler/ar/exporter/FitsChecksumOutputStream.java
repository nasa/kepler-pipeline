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

package gov.nasa.kepler.ar.exporter;

import static gov.nasa.kepler.common.FitsConstants.*;

import java.io.IOException;
import java.io.OutputStream;

/**
 * Calculate the value of the FITS checksum and datasum keywords.  This does not
 * wrap another output stream, the data is just dropped similar to apache 
 * commons NullOutputStream.  The checksum of the data is computed as this
 * receives bytes from the source.  This is similar to java.security.DigestOutputStream.
 * The checksum is only valid when complete HDUs have been consumed
 * checksumString() will throw an exception if it has not seen the a number of
 * bytes that is not a multiple of 2880.
 * 
 * 
 * See _FITS Checksum Proposal_, R.L. Seaman, W.D. Pence, A.H. Rots 2002
 * 
 * @author Sean McCauliff
 * @author R J Mathar
 *
 */
public final class FitsChecksumOutputStream extends OutputStream {

    /** ASCII checksum encoder parameters. */
    private static final int[] exclude = { 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x40, 0x5b, 0x5c, 0x5d, 0x5e, 0x5f, 0x60 } ;
    private static final long[] mask = { 0xff000000L, 0xff0000L, 0xff00L, 0xffL} ;
    private static final int offset = 0x30 ;   /* ASCII 0 (zero */
    
    private long bytesWritten = 0;
    
    /** high order 16-bit sum */
    private long hiSum = 0;
    
    /** lower order 16-bit sum */
    private long lowSum = 0;
    
    private int prevByte = 0;
    
    @Override
    public void write(int b) throws IOException {
        b = b & 0xff;
        switch ((int)(bytesWritten &  0x03)) {
            case 0: prevByte = b << 8; break;
            case 1: hiSum += (prevByte | b); break;
            case 2: prevByte = b << 8; break;
            case 3: lowSum += (prevByte | b); break;
            default:
                throw new IllegalStateException();
        }
        bytesWritten++;
    }
    
  
    /**
     * This optimized version will perform fewer function calls and potentially
     * exploits much more instruction level parallelism.
     */
    @Override
    public void write(byte[] buf, int off, int len) throws IOException {
        if (len == 0) {
           return;
        }
        
        if (off < 0) {
            throw new IllegalArgumentException("Offset may not be negative.");
        }
        
        if (len < 0) {
            throw new IllegalArgumentException("Length may not be negative.");
        }
        
        int stop = off+len;
        if (stop > buf.length) {
            throw new IllegalArgumentException("Offset is greater than buffer length.");
        }

        //Advance to some point where the byte counter is at a 4 byte alignment.
        int i = off;
        for (; i < stop && (bytesWritten & 0x03) != 0; i++) {
            write(buf[i]);
        }

        //This is the 4 byte aligned end of the requested write region.
        int alignedStop = (stop & 0xFFFFFFFC) - 4;
        if (i < alignedStop) {
            bytesWritten += alignedStop - i;
            for (; i < alignedStop; i += 4) {
                hiSum += ((buf[i] & 0xFF )  << 8)| (buf[i + 1] & 0xFF);
                lowSum += ((buf[i + 2] & 0xFF) << 8) | (buf[i + 3] & 0xFF);
            }
        }
        
        //Checksum any trailing non-aligned bytes
        for (; i < stop; i++) {
            write(buf[i]);
        }
    }
    
    private long checksum() {
        if (bytesWritten % HDU_BLOCK_SIZE != 0) {
            throw new IllegalStateException("Number of bytes written (" + 
                bytesWritten + ") must be multiple of HDU block size.");
        }
        
        /* fold carry bits from each 16-bit sum into the other sums */
        long hiCarry = hiSum >>> 16;
        long lowCarry = lowSum >>> 16;
            
        while ((hiCarry | lowCarry) != 0) {
            hiSum = (hiSum & 0xffffL) + lowCarry;
            lowSum = (lowSum & 0xffffL) + hiCarry;
            hiCarry = hiSum >>> 16;
            lowCarry = lowSum >>> 16;
        }
        
        return (hiSum << 16) | lowSum;
    }
    
    /**
     * 
     * This is the difference between the checksum and negative zero in 
     * 1s-compliment notation.
     * 
     * I don't know why FITS can't just have you print out the numerical version
     * of this in a hexadecimal string.  Instead they have their own hokey
     * encoding.
     * 
     * 
     * @return
     */
    public String checksumString() {
        long checksum = checksum();
        
        return checksumEnc(checksum, true);
    }
    
    /** 
     * I got this from nom.tam.fits.Fits
     * 
     * Encode a 32bit integer according to the Seaman-Pence proposal.
     * @param c the checksum previously calculated
     * @return the encoded string of 16 bytes.
     * @see http://heasarc.gsfc.nasa.gov/docs/heasarc/ofwg/docs/general/checksum/node14.html#SECTION00035000000000000000
     * @author R J Mathar
     * @since 2005-10-05
     */
    private static String checksumEnc(final long c, final boolean compl) {
        byte[] asc = new byte[16] ;
       
        final long value = compl ? ~c: c ;
        for (int i=0 ; i < 4 ; i++) {
            final int byt = (int) ((value & mask[i]) >>> (24 - 8*i)) ;  // each byte becomes four
            final int quotient = byt /4 + offset ;
            final int remainder = byt % 4 ;
            int[] ch = new int[4] ;
            for (int j=0 ; j < 4 ; j++) {
                ch[j] = quotient ;
            }

            ch[0] += remainder ;
            boolean check = true ;
            for(; check ; ) { // avoid ASCII punctuation
                check= false ;
                for (int k=0; k < exclude.length ; k++) {
                    for (int j=0; j < 4 ; j +=2) {
                        if ( ch[j] == exclude[k] || ch[j+1] == exclude[k]) {
                            ch[j]++ ;
                            ch[j+1]-- ;
                            check = true ;
                        }
                    }
                }
            }

            for (int j=0; j < 4 ; j++) { // assign the bytes
                asc[4*j+i] = (byte)(ch[j]) ;
            }
        }

        // shift the bytes 1 to the right circularly.
        StringBuilder bldr = new StringBuilder(16);
        bldr.append((char) asc[15]);
        for (int i=0; i < 15; i++) {
            bldr.append((char) asc[i]);
        }
        return bldr.toString();
    }

}
