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

package gov.nasa.kepler.ar.exporter.collateral;

import java.io.DataOutput;
import java.io.IOException;
import java.lang.reflect.Method;

import nom.tam.util.ArrayDataOutput;

/**
 * This implements a simple ArrayDataOutput in order to bypass the broken
 * streaming implementation.
 * 
 * @author Sean McCauliff
 *
 */
public class ArrayDataOutputPassThrough implements ArrayDataOutput{

    private final DataOutput out;
    
    private long count = 0;
    
    public ArrayDataOutputPassThrough(DataOutput out) {
        if (out == null) {
            throw new NullPointerException("out == null");
        }
        this.out = out;
    }

    public long count() {
        return count;
    }
    
    @Override
    public void write(int b) throws IOException {
        out.writeByte(b);
        count++;
    }

    @Override
    public void writeBoolean(boolean v) throws IOException {
        out.writeBoolean(v);
        count++;
    }

    @Override
    public void writeByte(int v) throws IOException {
        out.writeByte(v);
        count++;
    }

    @Override
    public void writeShort(int v) throws IOException {
        out.writeShort(v);
        count += 2;
    }

    @Override
    public void writeChar(int v) throws IOException {
        out.writeChar(v);
        count += 2;
    }

    @Override
    public void writeInt(int v) throws IOException {
        out.writeInt(v);
        count += 4;
    }

    @Override
    public void writeLong(long v) throws IOException {
        out.writeLong(v);
        count += 8;
    }

    @Override
    public void writeFloat(float v) throws IOException {
        out.writeFloat(v);
        count += 4;
    }

    @Override
    public void writeDouble(double v) throws IOException {
        out.writeDouble(v);
        count += 8;
    }

    @Override
    public void writeBytes(String s) throws IOException {
        out.writeBytes(s);
        count += s.length();
    }

    @Override
    public void writeChars(String s) throws IOException {
        out.writeChars(s);
        count += s.length() * 2;
    }

    /**
     * TODO:  This does not correctly track the length of the characters
     * written to output when the output characters are not ASCII encoded.
     */
    @Override
    public void writeUTF(String s) throws IOException {
        out.writeUTF(s);
        count += 2 + s.length();
    }

    @Override
    public void writeArray(Object o) throws IOException {
        throw new IllegalStateException();
    }

    @Override
    public void write(byte[] buf) throws IOException {
        out.write(buf);
        count += buf.length;
    }

    @Override
    public void write(boolean[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeBoolean(buf[i]);
        }
        count += buf.length;
    }

    @Override
    public void write(short[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeShort(buf[i]);
        }
        count += buf.length * 2;
    }

    @Override
    public void write(char[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeChar(buf[i]);
        }
        count += buf.length * 2;
    }

    @Override
    public void write(int[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeInt(buf[i]);
        }
        count += buf.length * 4;
    }

    @Override
    public void write(long[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeLong(buf[i]);
        }
        count += buf.length * 8;
    }

    @Override
    public void write(float[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeFloat(buf[i]);
        }
        count += buf.length * 4;
    }

    @Override
    public void write(double[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeDouble(buf[i]);
        }
        count += buf.length * 8;
    }
    
    /*
    * TODO:  This does not correctly track the length of the characters
    * written to output when the output characters are not ASCII encoded.
    * */
    @Override
    public void write(String[] buf) throws IOException {
        for (int i=0; i < buf.length; i++) {
            out.writeUTF(buf[i]);
            count += 2 + buf[i].length();
        }
    }

    @Override
    public void write(byte[] buf, int offset, int size) throws IOException {
        out.write(buf, offset, size);
        count += size;
    }

    @Override
    public void write(boolean[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeBoolean(buf[i]);
        }
        count += size;
    }

    @Override
    public void write(char[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeChar(buf[i]);
        }
        count += size;
    }

    @Override
    public void write(short[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeShort(buf[i]);
        }
        count += size * 2;
    }

    @Override
    public void write(int[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeInt(buf[i]);
        } 
        count += size * 4;
    }

    @Override
    public void write(long[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeLong(buf[i]);
        } 
        count += size * 8;
    }

    @Override
    public void write(float[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeFloat(buf[i]);
        } 
        count += size * 4;
    }

    @Override
    public void write(double[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeDouble(buf[i]);
        }
        count += size * 8;
    }
    /**
    * TODO:  This does not correctly track the length of the characters
    * written to output when the output characters are not ASCII encoded.
    */
    @Override
    public void write(String[] buf, int offset, int size) throws IOException {
        for (int i=offset; i < (offset + size); i++) {
            out.writeUTF(buf[i]);
            count += 2 + buf[i].length();
        } 
    }

    /**
     * If the underlying data output implementation has a flush method then it is called.
     */
    @Override
    public void flush() throws IOException {
        try {
            Method flushMethod = out.getClass().getMethod("flush");
            flushMethod.invoke(out);
        } catch (Exception e) {
            //OK
        }
    }

    /**
     * If the underlying data output implementation has a close method then it is called.
     */
    @Override
    public void close() throws IOException {
        try {
            Method closeMethod = out.getClass().getMethod("close");
            closeMethod.invoke(out);
        } catch (Exception e) {
            //OK
        }
    }
}
