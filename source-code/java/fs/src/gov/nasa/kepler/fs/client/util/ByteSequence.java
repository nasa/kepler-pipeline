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

package gov.nasa.kepler.fs.client.util;

import java.io.DataOutput;
import java.io.IOException;

/**
 * Wraps floats or ints into a sequence of bytes.
 * 
 * @author Sean McCauliff
 *
 */
abstract class ByteSequence {

    protected int index;
    
    static ByteSequence fromInt(int[] ints) {
        return new IntByteSequence(ints);
    }
    
    static ByteSequence fromFloat(float[] floats) {
        return new FloatByteSequence(floats);
    }
    
    abstract void writeNextBytes(byte[] buf, int offset);
    
    abstract void writeNextBytes(DataOutput dos) throws IOException;
    abstract int length();
    void seek(int pos) {
        index = pos;
    }
    
    static private class IntByteSequence extends ByteSequence {
        private final int[] ints;
        IntByteSequence(int[] ints) {
            this.ints = ints;
            index = 0;
        }
        
        void writeNextBytes(DataOutput dos) throws IOException {
            dos.writeInt(ints[index++]);
        }
        
        void writeNextBytes(byte[] buf, int offset) {
            buf[offset] = (byte) ((ints[index] >> 24) & 0x000000FF);
            buf[offset+1] = (byte) ((ints[index] >> 16) & 0x000000FF);
            buf[offset+2] = (byte) ((ints[index] >> 8) & 0x000000FF);
            buf[offset+3] = (byte) (ints[index] & 0x000000FF);
            index++;
        }
        int length() {
            return ints.length;
        }
    }
    
    static private class FloatByteSequence extends ByteSequence {
        private final float[] floats;

        FloatByteSequence(float[] floats) {
            this.floats = floats;
            index = 0;
        }
        
        void writeNextBytes(DataOutput dos) throws IOException {
            dos.writeFloat(floats[index++]);
        }
        
        void writeNextBytes(byte[] buf, int offset) {
            int intValue = Float.floatToIntBits(floats[index]);
            buf[offset] = (byte) ((intValue >> 24) & 0x000000FF);
            buf[offset+1] = (byte) ((intValue >> 16) & 0x000000FF);
            buf[offset+2] = (byte) ((intValue >> 8) & 0x000000FF);
            buf[offset+3] = (byte) (intValue & 0x000000FF);
            index++;
        }
        
        int length() {
            return floats.length;
        }
    }
}
