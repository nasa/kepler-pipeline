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

package gov.nasa.spiffy.common.io;

import java.io.DataInput;
import java.io.DataOutput;
import java.io.IOException;

/**
 * Encodes a primitive long as a variable length sequence of bytes.  
 * 
 * @author Sean McCauliff
 *
 */
public class LongEncoder {
    
    /**
     * Encodes a long value as a sequence of bytes.
     * @throws IOException 
     */
    public static void longToBytes(long v, DataOutput dataOutput) throws IOException {
        boolean negative = false;
        if ( v < 0) {
            negative = true;
            v++;
            v = -v;
        }
        
        int byteValue = (int) (v & 0x000000000000003F);
        if (v > 63) {
            byteValue  |= 0x00000080;
        }
        if (negative) {
            byteValue |= 0x00000040;
        }
        dataOutput.writeByte(byteValue);
        
        v = v >>> 6;
        
        while (v > 0) {
            int bv = (int) (v & 0x000000000000007F);
            v = v >>> 7;
            if (v != 0) {
                bv = bv | 0x00000080;
            }
            dataOutput.writeByte(bv);
        }
    }
    
    /**
     * Decodes a long value encoded with longToBytes.
     * @throws IOException 
     */
    public static long bytesToLong(DataInput dataInput) throws IOException {
        byte b1 = dataInput.readByte();
        
        long v = (b1 & 0x3FL);
        boolean negative = (b1 & 0x40) != 0;
        int shift = 6;
        while ( (b1 & 0x80) > 0) {
            b1 = dataInput.readByte();
            v += (b1 & 0x7FL) << shift;
            shift += 7;
        }
        
        if (negative) {
            return -v - 1;
        }
        return v;
    }
}
