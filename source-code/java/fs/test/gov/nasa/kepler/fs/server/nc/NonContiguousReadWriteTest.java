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
import gov.nasa.kepler.io.DataOutputStream;

import static gov.nasa.spiffy.common.collect.ArrayUtils.arrayEquals;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.ByteArrayOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.IOException;
import java.io.RandomAccessFile;
import java.util.Arrays;

import junit.framework.AssertionFailedError;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author smccauliff
 * 
 */
public class NonContiguousReadWriteTest {

    private final byte[] data = new byte[1024 * 1024 * 2];
    private static final int HEADER_SIZE = 2;
    private final ReservedAddressSpace reservedMeta = new MetaSpace(HEADER_SIZE, true);
    private final ReservedAddressSpace reservedNormal = new MetaSpace(HEADER_SIZE, false);
    private final CheckeredSpace checked = new CheckeredSpace();
    private RandomAccessFile raf;
    private File testFile;

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {

        setupData(data);
        File testDir = new File(Filenames.BUILD_TEST,
               "NonContiguousReadWriteTest.test");
        testDir.mkdirs();
        testFile = new File(testDir, "testfile");

        raf = new RandomAccessFile(testFile, "rw");
    }

    static void setupData(byte[] data) {
        for (int i = 0; i < data.length; i++) {
            byte b = (byte) i;
            if (b == 0) {
                b = 42;
            }
            data[i] = b;
        }
    }
    
    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        try {
            raf.close();
        } catch (IOException ioe) {
            // nothing.
        }
        testFile.delete();
    }

    /**
     * Writes bytes into metaspace. Writes the same data into the metadata
     * space. This should generate a large, sparse file.
     * 
     */
    @Test
    public void writeBytes() throws Exception {
        writeBytes(false);
    }
    
    @Test
    public void writeBytesStoreLength() throws Exception {
        writeBytes(true);
    }
    
    private void writeBytes(boolean storeLength) throws Exception {

        NonContiguousReadWrite normalIo = null;
        if (storeLength) {
            normalIo = new NonContiguousReadWrite(raf, reservedMeta, true, true);
        } else {
            normalIo = new NonContiguousReadWrite(raf, reservedMeta);
        }
            
        normalIo.write(data);
        byte[] readData = new byte[data.length];
        normalIo.seek(0);
        normalIo.read(readData, 0, readData.length);
        assertTrue("Written data must be equal to read data.", Arrays.equals(
            readData, data));

        RandomAccessFile metaRaf = new RandomAccessFile(this.testFile, "rw");
        NonContiguousReadWrite metaIo = null;
        if (storeLength) {
            metaIo = new NonContiguousReadWrite(metaRaf, reservedNormal, true, true);
        } else {
            metaIo = new NonContiguousReadWrite(metaRaf, reservedNormal);
        }
            
        metaIo.seek(0);
        metaIo.write(data, 0, data.length);

        metaIo.seek(0);
        metaIo.read(readData, 0, readData.length);
        assertTrue("Written data must be equal to read data.", Arrays.equals(
            readData, data));

        normalIo.seek(0);
        normalIo.read(readData, 0, readData.length);
        assertTrue("Written data must be equal to read data.", Arrays.equals(
            readData, data));

        if (storeLength) {
            assertEquals(data.length, normalIo.length());
            assertEquals(data.length, metaIo.length());
        }
        metaIo.close();
        normalIo.close();
        

        //Read from a new random access file.
        RandomAccessFile raf2 = new RandomAccessFile(testFile, "rw");
        
        if (storeLength) {
            byte[] rawData = new byte[(int) MetaSpace.USED_PLUS_UNUSED * 3];
            raf2.readFully(rawData);
            
            ByteArrayOutputStream bout = new ByteArrayOutputStream();
            DataOutputStream dout = new DataOutputStream(bout);
            dout.writeLong(data.length);
            
            //Check that length is stored correctly
            assertTrue(arrayEquals(bout.toByteArray(), 0, rawData, HEADER_SIZE, 8));
            
            //Check normal data stream.
            final int prefixLen = HEADER_SIZE + 8;
            final int firstChunkSize = (int) MetaSpace.BLOCK_SIZE - prefixLen;
            assertTrue(arrayEquals(data, 0, rawData, prefixLen , firstChunkSize));

            final int secondChunkStart = (int) MetaSpace.USED_PLUS_UNUSED;
            assertTrue(arrayEquals(data, firstChunkSize, rawData, 
                                   secondChunkStart, (int) MetaSpace.BLOCK_SIZE));
                                   
        } else {
            byte[] rawData = new byte[(int) MetaSpace.USED_PLUS_UNUSED * 2];
            raf2.readFully(rawData);
            // Check first part of metadata.
            assertTrue(arrayEquals(data, 0, rawData, 2,
                (int) MetaSpace.BLOCK_SIZE - 2));
            // Check first part of data
            assertTrue(arrayEquals(data, 0, rawData, (int) MetaSpace.BLOCK_SIZE,
                (int) MetaSpace.BLOCK_SPACING));
            // Check second part of metadata.
            assertTrue(arrayEquals(data, (int) MetaSpace.BLOCK_SIZE - 2, rawData,
                (int) MetaSpace.USED_PLUS_UNUSED, (int) MetaSpace.BLOCK_SIZE));
    
            // Check second part of data.
            assertTrue(arrayEquals(data, (int) MetaSpace.BLOCK_SPACING, rawData,
                (int) (MetaSpace.USED_PLUS_UNUSED + MetaSpace.BLOCK_SIZE),
                (int) MetaSpace.BLOCK_SPACING));
        }
        raf2.close();
    }

    /**
     * Writes bytes into metaspace with an offset.
     */
    @Test
    public void writeBytesOffset() throws Exception {
        writeBytesOffset(false);
    }
    
    @Test
    public void writeBytesOffsetStoreLength() throws Exception {
        writeBytesOffset(true);
    }
    
    private void writeBytesOffset(boolean storeLength) throws Exception {

        NonContiguousReadWrite normalIo = null;
        if (storeLength) {
            normalIo = new NonContiguousReadWrite(raf, reservedMeta, true, true);
        } else {
            normalIo = new NonContiguousReadWrite(raf, reservedMeta);
        }
            
        final int offset = 1 << 30;
        normalIo.seek(offset);
        normalIo.write(data, 0, data.length);
        byte[] readData = new byte[data.length];
        normalIo.seek(offset);
        normalIo.read(readData, 0, readData.length);
        assertTrue("Written data must be equal to read data.", Arrays.equals(
            readData, data));
        if (storeLength) {
            assertEquals(offset + data.length, normalIo.length());
        }
    }

    /**
     * Write/read primitives.
     */
    @Test
    public void writeByte() throws Exception {
        // Byte
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeByte(0xFF);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals((byte) 0xFF, io.readByte());
    }
    
    @Test
    public void writeLotsOfBytes() throws Exception {
        writeLotsOfBytes(false);
    }
    
    @Test
    public void writeLotsOfBytesStoreLength() throws Exception {
        writeLotsOfBytes(true);
    }
    
    public void writeLotsOfBytes(boolean storeLength) throws Exception {
        NonContiguousReadWrite io = null;
        if (storeLength) {
            io = new NonContiguousReadWrite(raf, checked, true, true);
        } else {
            io = new NonContiguousReadWrite(raf, checked);
        }
        
        for (byte b : data) {
            io.write(b);
        }
        
        io.seek(0L);
        
        for (int i=0; i < data.length; i++) {
            //Not using assertEquals since autoboxing slows everything down
            byte read = (byte) io.read();
            if (data[i] != read) {
                String m = 
                    String.format("Read different data at index %d.  Expected %x, but found %x",
                                    i, data[i], read);
                throw new AssertionFailedError(m);
            }
        }
        
        if (storeLength) {
            assertEquals(data.length, io.length());
            assertEquals(-1, io.read());
            try {
                io.readByte();
                assertTrue("Should not have reached here.", false);
            } catch (EOFException eof) {
                //ok
            }
        }
        
    }

    @Test
    public void writeDouble() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeDouble(Math.PI);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals(Double.MIN_VALUE,Math.PI, io.readDouble());
    }
    
    @Test
    public void writeFloat() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        float fPi = (float) Math.PI;
        io.writeFloat(fPi);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals(Float.MIN_VALUE, fPi, io.readFloat());
    }
    
    /**
     * Write/read primitives.
     */
    @Test
    public void writeBoolean() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeBoolean(true);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals(true, io.readBoolean());
    }

    /**
     * Write/read primitives.
     */
    @Test
    public void writeChar() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeChar('\u221E');
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals('\u221E', io.readChar());
    }

    /**
     * Write/read primitives.
     */
    @Test
    public void writeShort() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeShort((short) 0xAFFE);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals((short) 0xAFFE, io.readShort());
    }

    /**
     * Write/read primitives.
     */
    @Test
    public void writeInt() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeInt(0xAFFE1234);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals(0xAFFE1234, io.readInt());
        raf.close();
        RandomAccessFile raf2 = null;
        try {
            raf2 = new RandomAccessFile(testFile, "rw");
            byte[] rawBytes = new byte[7];
            raf2.readFully(rawBytes);
            assertEquals(0xAF, rawBytes[0] & 0xFF);
            assertEquals(0xFE, rawBytes[2] & 0xFF);
            assertEquals(0x12, rawBytes[4] & 0xFF);
            assertEquals(0x34, rawBytes[6] & 0xFF);
        } finally {
            raf2.close();
        }
    }

    @Test
    public void writeLong() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        io.writeLong(0xAFFE12345678L);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals(0xAFFE12345678L, io.readLong());
    }

    /**
     * Tests that modified UTF8 encoding works.
     */
    @Test
    public void writeUTF8() throws Exception {
        NonContiguousReadWrite io = new NonContiguousReadWrite(raf, checked);
        String testString = "123abc\u0000\u07ff\uaffe";
        // String testString = "abc";
        io.writeUTF(testString);
        io = new NonContiguousReadWrite(raf, checked);
        assertEquals(testString, io.readUTF());
    }

 
    /**
     * Unused addresses : 0, 2, 4, ...
     * 
     */
    static final class CheckeredSpace implements ReservedAddressSpace {

        private File file;

        public void setFile(File file) {
            this.file = file;
        }

        public boolean isUsed(long addr) {
            if ((addr % 2L) == 0) {
                return false;
            } else {
                return true;
            }
        }

        public long nextUnusedAddress(long start) {
            if (isUsed(start)) {
                return start + 1;
            } else {
                return start;
            }
        }

        public long xlateAddress(long start) {
            return start << 1;
        }

        public long lastVirtualAddress() {
            long fileLength = file.length();
            if (fileLength == 0) {
                return 0;
            }
            return fileLength / 2 + 1;
        }

    }
}
