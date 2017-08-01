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

package gov.nasa.kepler.fs.server.raf;

import java.io.IOException;

/**
 * Ignore close().
 * 
 * @author Sean McCauliff
 *
 */
public final class IgnoreCloseRandomAccessIo implements RandomAccessIo {

    private final RandomAccessIo impl;
    
    public IgnoreCloseRandomAccessIo(RandomAccessIo impl) {
        if (impl == null) {
            throw new NullPointerException("impl must not be null");
        }
        this.impl = impl;
    }
    
    
    /**
     * This does nothing.
     */
    @Override
    public void close() throws IOException {
        
    }

    
    
    @Override
    public void readFully(byte[] b) throws IOException {
        impl.readFully(b);
    }


    @Override
    public void readFully(byte[] b, int off, int len) throws IOException {
        impl.readFully(b, off, len);
    }

    @Override
    public int skipBytes(int n) throws IOException {
        return impl.skipBytes(n);
    }


    @Override
    public boolean readBoolean() throws IOException {
        return impl.readBoolean();
    }

    @Override
    public byte readByte() throws IOException {
        return impl.readByte();
    }

    @Override
    public int readUnsignedByte() throws IOException {
        return impl.readUnsignedByte();
    }

    @Override
    public short readShort() throws IOException {
        return impl.readShort();
    }

    @Override
    public int readUnsignedShort() throws IOException {
        return impl.readUnsignedShort();
    }

    @Override
    public char readChar() throws IOException {
        return impl.readChar();
    }

    @Override
    public int readInt() throws IOException {
        return impl.readInt();
    }


    @Override
    public long readLong() throws IOException {
        return impl.readLong();
    }


    @Override
    public float readFloat() throws IOException {
        return impl.readFloat();
    }

    @Override
    public double readDouble() throws IOException {
        return impl.readDouble();
    }

    @Override
    public String readLine() throws IOException {
        return impl.readLine();
    }

    @Override
    public String readUTF() throws IOException {
        return impl.readUTF();
    }

    @Override
    public void write(byte[] b) throws IOException {
        impl.write(b);
    }

    @Override
    public void writeBoolean(boolean v) throws IOException {
        impl.writeBoolean(v);
    }

    @Override
    public void writeByte(int v) throws IOException {
        impl.writeByte(v);
    }

    @Override
    public void writeShort(int v) throws IOException {
        impl.writeShort(v);
    }

    @Override
    public void writeChar(int v) throws IOException {
        impl.writeChar(v);
    }


    @Override
    public void writeInt(int v) throws IOException {
        impl.writeInt(v);
    }

    @Override
    public void writeLong(long v) throws IOException {
        impl.writeLong(v);
    }

    @Override
    public void writeFloat(float v) throws IOException {
        impl.writeFloat(v);
    }

    @Override
    public void writeDouble(double v) throws IOException {
        impl.writeDouble(v);
    }

    @Override
    public void writeBytes(String s) throws IOException {
        impl.writeBytes(s);
    }

    @Override
    public void writeChars(String s) throws IOException {
        impl.writeChars(s);
    }

    @Override
    public void writeUTF(String s) throws IOException {
        impl.writeUTF(s);
    }

    @Override
    public void seek(long pos) throws IOException {
        impl.seek(pos);
    }

    @Override
    public long length() throws IOException {
        return impl.length();
    }

    @Override
    public void setLength(long newLength) throws IOException {
        impl.setLength(newLength);
    }

    @Override
    public int read() throws IOException {
        return impl.read();
    }

    @Override
    public int read(byte[] buf, int off, int len) throws IOException {
        return impl.read(buf, off, len);
    }


    @Override
    public void write(int b) throws IOException {
        impl.write(b);
    }

    @Override
    public void write(byte[] data, int off, int len) throws IOException {
        impl.write(data, off, len);
    }

}
