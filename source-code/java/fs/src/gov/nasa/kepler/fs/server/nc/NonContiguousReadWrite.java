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

package gov.nasa.kepler.fs.server.nc;

import gov.nasa.kepler.fs.server.raf.RandomAccessIo;

import java.io.EOFException;
import java.io.IOException;
import java.io.RandomAccessFile;

/**
 * Allows for holes in the file address space so that other can be written
 * into this.  This class provides a linear address space to the user of the
 * class.  Example:
 * <pre>
 * 
 *  nnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn
 *             |
 *             V
 *             
 *  HEADERnnnnnnnnnnnnnnHEADERnnnnnnnnnnnnnnn
 *  </pre>
 *  
 *  This class also partially implements the DataOuput and DataInput
 *  interfaces.   The currently unimplemented methods could be implemented,
 *  but are currently not needed.
 *  
 *  This class does not, by default, track the length of the data written into 
 *  a particular address space.  Doing this incurs additional overhead.  Once
 *  this has been done the address space must always be used with the 
 *  virtual length storage enabled.
 *  
 * @author Sean McCauliff
 *
 */
public class NonContiguousReadWrite implements RandomAccessIo {

    private static final long LENGTH_SIZE = 8L;
    
    private static final long UNINIT_LENGTH = -1;
    
    private final ReservedAddressSpace reserved;
    
    /** The current location where DataOutput and DataInput methods,
     * read and write to/from.
     */
    private long realAddr = 0;
    
    /** When realAddr > dioEnd then we need to find the next
     * address range to write into.
     */
    private long dataIoEnd = -1;
    
    /**
     * The current virtual position where the DataInput and Output
     * methods read/write to/from.  Virtual address does not include
     * the size of the virtual length field itself.
     */
    private long virtualAddr = -1;
    
    private final RandomAccessFile raf;
    
    /**
     * When this is true store an 8 byte length at the beginning of the file.
     */
    private boolean storeVirtualLength;
    /** Virtual length does not include the size of the length
     * field itself.
     */
    private long virtualLength = UNINIT_LENGTH;
    private long initialVirtualLength = UNINIT_LENGTH;
    
    
    public NonContiguousReadWrite(RandomAccessFile raf, ReservedAddressSpace reserved) throws IOException {
        this(raf, reserved, false, false);
    }
    
    /**
     * 
     * @param raf
     * @param reserved
     * @param storeLength
     * @param isNew  This is used in conjunction with storeLength.
     * @throws IOException
     */
    public NonContiguousReadWrite(RandomAccessFile raf, ReservedAddressSpace reserved, 
                                  boolean storeLength, boolean isNew) throws IOException {
        if (raf == null) {
            throw new NullPointerException("RandomAccessFile may not be null.");
        }
        this.reserved = reserved;
        this.storeVirtualLength = storeLength;
        this.raf = raf;
        seek(0);
        if (storeLength && isNew) {
            virtualLength = 0;
        }  else if (storeLength) {
            readVirtualLength();
        }
    }
    
    private long readVirtualLength() throws IOException {
        if (!storeVirtualLength) {
            throw new IllegalStateException("Length not stored.");
        }
        
        if (virtualLength != UNINIT_LENGTH) {
            return virtualLength;
        }
        
        long oldVirtualAddr = virtualAddr;
        storeVirtualLength = false;
        seek(0);
        virtualLength = readLong();
        initialVirtualLength = virtualLength;
        seek(oldVirtualAddr);
        storeVirtualLength = true;
        return virtualLength;
    }
    
    private void writeVirtualLength() throws IOException {
        if (virtualLength == UNINIT_LENGTH) {
            throw new IllegalStateException("Can't write uninitialized length.");
        }
        
        long oldVirtualAddr = virtualAddr;
        storeVirtualLength = false;
        seek(0);
        writeLong(virtualLength);
        storeVirtualLength = true;
        seek(oldVirtualAddr);
        virtualAddr = oldVirtualAddr;
    }
    
    private void updateVirtualAddress(int increment) {
        if (storeVirtualLength) {
            virtualLength = Math.max(virtualLength, virtualAddr  + increment - LENGTH_SIZE);
        }
        virtualAddr += increment;
    }
    
    /**
     * Closes the random access file this is attached to.
     *
     */
    public void close() throws IOException {
        if (storeVirtualLength && (initialVirtualLength != virtualLength)) {
            writeVirtualLength();
        }
        raf.close();
    }
   
    
    private void readInternalAbsolute(final byte[] data, int dataStart, 
                      int size, final long fileStart)
        throws IOException { 
        
        readWrite( data, dataStart, size, fileStart, true);
    }

    
    private void writeInternalAbsolute(final byte[] data, int dataStart, 
                      int size, final long fileStart)
        throws IOException { 
        
        readWrite( data, dataStart, size, fileStart, false); 
        
    }
    
    /**
     * Reads size bytes every time a read is performed.
     * 
     * @param data
     * @param dataStart
     * @param size The number of bytes to read.  This method will throw an
     * exception if size bytes are not available.
     * @param fileStart
     * @param read
     * @throws IOException
     */
    private void readWrite(final byte[] data, int dataStart, 
                          int size, final long fileStart, final boolean read )
        throws IOException {
        
        if (data == null) {
            throw new NullPointerException("Will not write null data.");
        }
        if (dataStart < 0) {
            throw new IllegalArgumentException("dataStart must be non-negative.");
        }
        if (size < 0) {
            throw new IllegalArgumentException("size must be non-negative");
        }
        if (fileStart < 0) {
            throw new IllegalArgumentException("fileStart must be non-negative");
        }
      
        
        long currentStart = reserved.xlateAddress(fileStart);
        
        while (size > 0) {
            if (reserved.isUsed(currentStart)) {
                currentStart = reserved.nextUnusedAddress(currentStart);
            }
            long end = reserved.nextUnusedAddress(currentStart);

            long chunkSize = end - currentStart + 1;
            //check for overflow
            chunkSize  = (chunkSize < 0) ? Long.MAX_VALUE : chunkSize;
            
            int currentSize = 
                (int) Math.min(Integer.MAX_VALUE, Math.min(size, chunkSize));
            raf.seek(currentStart);
            if (read) {
                int nread = raf.read(data, dataStart, currentSize);
                if (nread < 0) {
                    throw new EOFException("Attempt to read past end of file.  " +
                                " data.length " + data.length + 
                                " dataStart " + dataStart + 
                                " currentSize " + currentSize + 
                                " fileStart " + fileStart +
                                " currentStart " + currentStart +
                                " raf.length() " + raf.length() +
                                " virtualAddr " + virtualAddr +
                                " storeVirtualLength " + storeVirtualLength +
                                " virtualLength " + virtualLength);
                }
                currentSize = nread;
            } else {
                raf.write(data, dataStart, currentSize);
            }
            currentStart += currentSize;
            size -= currentSize;
            dataStart += currentSize;
        }
    }

    /**
     * 
     * @return  The size of the beginning of the virtual address space used to store
     * length information.
     */
    private long headerLength() {
        if (this.storeVirtualLength) {
            return LENGTH_SIZE;
        } else {
            return 0L;
        }
    }
    
    private void checkAddr() {
        if (dataIoEnd > realAddr) {
            return;
        }
        
        if (reserved.isUsed(realAddr)) {
            realAddr = reserved.nextUnusedAddress(realAddr);
        }
        dataIoEnd = reserved.nextUnusedAddress(realAddr);
    }
    
    private void throwUnimplException() throws IOException {
        throw new IOException("Method not implemented.");
    }
    
    public void write(int b) throws IOException {
        long prevRealPointer = realAddr;
        checkAddr();
        if (realAddr != prevRealPointer) {
            raf.seek(realAddr);
        }
        raf.write(b);
        updateVirtualAddress(1);
        realAddr++;
    }
    /**
    * Read starting at the next virtual address.
    * 
    * Reads a byte of data from this file. The byte is returned as an integer in the range
    *  0 to 255 (0x00-0x0ff). This method blocks if no input is yet available.
    *  Although NonContiguousReadWrite is not a subclass of InputStream, this method
    *  behaves in exactly the same way as the InputStream.read() method of InputStream. 
    *  
    *  @return the next byte of data, or -1 if the end of the file has been reached and throwEOF
    *  is false.
    */
    private int read(boolean throwEOF ) throws IOException {
        if (storeVirtualLength) {
            if (virtualAddr-LENGTH_SIZE >= virtualLength) {
                if (throwEOF) {
                    throw new EOFException("Attempt to read past end " +
                        "of virutalLength " + virtualLength);
                } else {
                    return -1;
                }
            }
        }
        
        long prevRealPointer = realAddr;
        checkAddr();
        if (prevRealPointer != realAddr) {
            raf.seek(realAddr);
        }
        int value = raf.read();
        if (value < 0) {
            if (throwEOF) {
                throw new EOFException();
            } else {
                return -1;
            }
        }
        virtualAddr++;
        realAddr++;
        return value; 
    }
    
    /**
     * Read starting at the next virtual address.
     * 
     * Reads a byte of data from this file. The byte is returned as an integer in the range
     *  0 to 255 (0x00-0x0ff). This method blocks if no input is yet available.
     *  Although NonContiguousReadWrite is not a subclass of InputStream, this method
     *  behaves in exactly the same way as the InputStream.read() method of InputStream. 
     *  @return the next byte of data, or -1 if the end of the file has been reached.
     */
    public int read() throws IOException {
        return read(false);
    }
    
    public void write(byte[] b) throws IOException {
        write(b, 0, b.length);
    }

    public void write(byte[] b, int off, int len) throws IOException {
        checkAddr();
        writeInternalAbsolute(b, off, len, virtualAddr);
        realAddr = raf.getFilePointer();
        updateVirtualAddress(len);
    }

    public void writeBoolean(boolean v) throws IOException {
        if (v) {
            this.write(1);
        } else {
            this.write(0);
        }  
    }

    public void writeByte(int v) throws IOException {
        write(v);
    }

    public void writeBytes(String s) throws IOException {
        throwUnimplException(); 
    }

    public void writeChar(int v) throws IOException {
        write((byte)(0xff & (v >> 8)));
        write((byte)(0xff & v));
    }
    
    public void writeChars(String s) throws IOException {
        throwUnimplException();      
    }


    public void writeDouble(double v) throws IOException {
        writeLong(Double.doubleToLongBits(v));
    }

    public void writeFloat(float v) throws IOException {
        writeInt(Float.floatToIntBits(v));
    }

    public void writeInt(int v) throws IOException {
        write((byte)(0xff & (v >> 24)));
        write((byte)(0xff & (v >> 16)));
        write((byte)(0xff & (v >>    8)));
        write((byte)(0xff & v));
    }

    public void writeLong(long v) throws IOException {
        write((byte)(0xff & (v >> 56)));
        write((byte)(0xff & (v >> 48)));
        write((byte)(0xff & (v >> 40)));
        write((byte)(0xff & (v >> 32)));
        write((byte)(0xff & (v >> 24)));
        write((byte)(0xff & (v >> 16)));
        write((byte)(0xff & (v >>  8)));
        write((byte)(0xff & v));       
    }

    public void writeShort(int v) throws IOException {
        write((byte)(0xff & (v >> 8)));
        write((byte)(0xff & v));
    }

    /**
     * See the documentation for DataInputStream.writeUTF for how this
     * encoding works.
     */
    public void writeUTF(String str) throws IOException {
        int byteLength = utf8Length(str);
        if ( (byteLength & 0xFFFF0000) != 0) {
            throw new IllegalArgumentException("String too long.");
        }
        
        this.writeShort(byteLength);
        for (int i=0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (c == '\u0000') {
                writeByte(0xC0);
                writeByte(0x80);
            } else if (c <= '\u007f') {
                writeByte(c & 0xFF);
            } else if (c <= '\u07ff' ) {
                writeByte( (c >> 6) | 0xC0 );
                writeByte( ( c & 0x3F) | 0x80);
            } else {
                writeByte( ( c >> 12) | 0xE0);
                writeByte (  ( ( c >> 6) & 0x3F) | 0x80 );
                writeByte(   ( c & 0x3F) | 0x80);
            }
        }
    }

    private int utf8Length(String str) {
        int length = 0;
        for (int i=0; i < str.length(); i++) {
            char c = str.charAt(i);
            if (c == '\u0000') {
                length += 2;
            } else if (c <= '\u007f') {
                length++;
            } else if (c <= '\u07ff' ) {
                length += 2;
            } else {
                length +=3;
            }
        }
        
        return length;
    }
    
    public boolean readBoolean() throws IOException {
        byte bool = this.readByte();
        if (bool < 0) {
            throw new EOFException();
        }
        return bool != 0;
    }

    public byte readByte() throws IOException {
        int v = read(true);
        return (byte) v;  
    }

    public char readChar() throws IOException {
        int b1 = this.read(true);
        int b2 = this.read(true);
        return (char)((b1 << 8) | (b2 << 0));
    }

    public double readDouble() throws IOException {
        return Double.longBitsToDouble(readLong());
    }

    public float readFloat() throws IOException {
        return Float.intBitsToFloat(readInt());
    }

    public void readFully(byte[] b) throws IOException {
        readFully(b, 0, b.length);
    }

    /**
     * When an EOF error occurs the file pointer may not be at EOF.
     */
    public void readFully(byte[] b, int off, int len) throws IOException {
        if (len == 0) {
            return;
        }
        if (storeVirtualLength && virtualAddr+len-LENGTH_SIZE > virtualLength) {
            throw new EOFException("Attempt to read past end " +
                    "of virutalLength " + virtualLength);
        }
        checkAddr();
        readInternalAbsolute(b, off, len, virtualAddr);
        virtualAddr += len;
        realAddr = raf.getFilePointer();
    }

    /**
     * This works like InputStream.read(byte[], int, int).  This will
     * read as many bytes from the current chunk before needed to move
     * to a new chunk.
     * 
     * @param buf
     * @param off
     * @param len
     * @return
     */
    public int read(byte[] buf, int off, int len) throws IOException {
        
        if (len < 0) {
            throw new IllegalArgumentException("len must be non-negative, got " + len);
        }
        if (off < 0) {
            throw new IllegalArgumentException("off must be non-negative, got " + off);
        }
        if (buf == null) {
            throw new NullPointerException("buf must not be null.");
        }
        if (len == 0) {
            return 0;
        }
        
        checkAddr();
        if (storeVirtualLength) {
            len = (int) Math.min(len, virtualLength - (virtualAddr - LENGTH_SIZE));
            if (len <= 0) {
                return -1;
            }
        } else {
            //Don't run off end of actual file.
            long endVirtualAddress =
                Math.min(virtualAddr+len, reserved.lastVirtualAddress());
            if (virtualAddr >= endVirtualAddress) {
                return -1;
            }
            len = (int) Math.min(Math.min(endVirtualAddress - virtualAddr, Integer.MAX_VALUE), len);
        }
        
        readInternalAbsolute(buf, off, len, virtualAddr);
        virtualAddr += len;
        realAddr = raf.getFilePointer();
        return len;
    }
  
    
    public int readInt() throws IOException {
        int a = read(true);
        int b = read(true);
        int c = read(true);
        int d = read(true);
        
        return (((a & 0xff) << 24) | ((b & 0xff) << 16) |
                ((c & 0xff) << 8) | (d & 0xff));
    }

    /**
     * Unimplemented.
     */
    public String readLine() throws IOException {
        throwUnimplException();
        return "null";
    }

    public long readLong() throws IOException {
        int a = read(true);
        int b = read(true);
        int c = read(true);
        int d = read(true);
        int e = read(true);
        int f = read(true);
        int g = read(true);
        int h = read(true);
        
        return (((long)(a & 0xff) << 56) |
                ((long)(b & 0xff) << 48) |
                ((long)(c & 0xff) << 40) |
                ((long)(d & 0xff) << 32) |
                ((long)(e & 0xff) << 24) |
                ((long)(f & 0xff) << 16) |
                ((long)(g & 0xff) <<  8) |
                ((long)(h & 0xff)));
    }

    public short readShort() throws IOException {
        int a = read(true);
        int b = read(true);
        
        return (short)((a << 8)  | (b & 0xff));
    }
    
    /**
     * See the documentation for DataInput for how this is encoded..
     */
    public String readUTF() throws IOException {
        StringBuilder bldr = new StringBuilder();
        int byteLength = readUnsignedShort();
        for (int i=0; i < byteLength; i++) {
            int first = read(true);
            if ( (first & 0x80) == 0) {
                bldr.append((char) first);
            } else if ( (first >> 4) == 0xE) {
                int second = read(true);
                int third= read(true);
                i += 2;
                int v = (((first & 0x0F) << 12) | ((second & 0x3F) << 6) | (third & 0x3F));
                bldr.append((char) v);
            } else {
                int second = read(true);
                i++;
                bldr.append( (char)(((first& 0x1F) << 6) | (second & 0x3F)) );
            }
        }
        return bldr.toString();
    }

    public int readUnsignedByte() throws IOException {
        return read(true);
    }

    public int readUnsignedShort() throws IOException {
        int a = read(true);
        int b = read(true);
        return (((a & 0xff) << 8) | (b & 0xff));
    }


    public int skipBytes(int n) throws IOException {
        throwUnimplException();
        return 0;
    }
    /**
     * Sets the file-pointer offset, measured from the beginning of this file, at 
     * which the next read or write occurs. The offset may be set beyond the end of 
     * the file. Setting the offset beyond the end of the file does not change the 
     * file length. The file length will change only by writing after the offset
     *  has been set beyond the end of the file.
     */
    public void seek(long pos)  throws IOException {
        long newVirtualAddr = pos + headerLength();
        if (newVirtualAddr == virtualAddr) {
            return;
        }
        virtualAddr = newVirtualAddr;
        realAddr = reserved.xlateAddress(virtualAddr);
        dataIoEnd = reserved.nextUnusedAddress(realAddr);
        raf.seek(realAddr);
    }

    @Override
    public long length() throws IOException {
        return readVirtualLength();
    }

    /**
     * Unlike an actual setLength() on a file this will not shrink the physical
     * size of the file and space is reserved for the data needed from the
     * current end of the current virtual length to the beginning of the 
     * new virtual length.
     */
    @Override
    public void setLength(long newVirtualLength) throws IOException {
        if (!this.storeVirtualLength) {
            throw new IllegalStateException("Not storing virtual length.");
        }
        if (newVirtualLength > virtualLength) {
            long diff =  newVirtualLength - virtualLength;
            if (diff > Integer.MAX_VALUE) {
                throw new IllegalStateException("Extending file too much.");
            }
            byte[] zeros = new byte[(int)diff];
            seek(virtualLength);
            write(zeros);
        } else {
            virtualLength = newVirtualLength;
            if (virtualAddr - LENGTH_SIZE > newVirtualLength) {
                seek(newVirtualLength);
            }
        }
    }

}
