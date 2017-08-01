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

package gov.nasa.kepler.io;

import static org.junit.Assert.*;

import java.io.ByteArrayInputStream;
import java.io.DataOutput;
import java.io.IOException;
import java.io.InputStream;
import java.io.PushbackInputStream;
import java.util.Arrays;

import org.apache.commons.io.output.ByteArrayOutputStream;
import org.junit.Before;
import org.junit.Test;

/**
 * @author smccauliff
 *
 */
public class DataInputOutputStreamTest {

	private ByteArrayOutputStream kbout;
	private gov.nasa.kepler.io.DataOutputStream kdout;
	private ByteArrayOutputStream jbout;
	private java.io.DataOutputStream jdout;
	private static final String STRING_AS_BYTES = "\uaffe abcd\r efg hij\r\njj\ncdef";
	private static final String allChars;
	private static final int CHUNK_SIZE = 1024;
	
	static {
		StringBuilder bldr = new StringBuilder();
		for (int i=0; i < Character.MAX_VALUE; i++) {
			bldr.append((char) i);
		}
		
		allChars = bldr.toString();
	}
	
	@Before
	public void setup() {
		kbout = new ByteArrayOutputStream();
		kdout = new gov.nasa.kepler.io.DataOutputStream(kbout);
		jbout = new ByteArrayOutputStream();
		jdout = new java.io.DataOutputStream(jbout);
	}
	
	@Test
	public void bytes() throws Exception {
		bytes(kdout);
		bytes(jdout);
			
		byte[] kbytes = kbout.toByteArray();
		byte[] jbytes = jbout.toByteArray();
		assertTrue(Arrays.equals(kbytes, jbytes));
		
		ByteArrayInputStream bin = new ByteArrayInputStream(kbytes);
		gov.nasa.kepler.io.DataInputStream kdin = new gov.nasa.kepler.io.DataInputStream(new ChunkingInputStream(bin));
		assertEquals(0, kdin.read());
		assertEquals(88, kdin.read());
		assertEquals(255, kdin.read());
		assertEquals(127, kdin.read());
		assertEquals(128, kdin.read());
		
		
		assertEquals((byte)0, kdin.readByte());
		assertEquals((byte)88, kdin.readByte());
		assertEquals((byte)-1, kdin.readByte());
		assertEquals((byte)127, kdin.readByte());
		assertEquals((byte)128, kdin.readByte());
		
		assertEquals(0, kdin.readUnsignedByte());
		assertEquals(88, kdin.readUnsignedByte());
		assertEquals(255, kdin.readUnsignedByte());
		assertEquals(127, kdin.readUnsignedByte());
		assertEquals(128, kdin.readUnsignedByte());
	
	}
	
	private static void bytes(DataOutput dout) throws Exception {

		dout.write(0);
		dout.write(88);
		dout.write(-1);
		dout.write(127);
		dout.write(128);
		
		dout.writeByte(0);
		dout.writeByte(88);
		dout.writeByte(-1);
		dout.writeByte(127);
		dout.writeByte(128);
		
		dout.writeByte(0);
		dout.writeByte(88);
		dout.writeByte(-1);
		dout.writeByte(127);
		dout.writeByte(128);
	}
	
	@Test
	public void multipleBytes() throws Exception {
	
		multipleBytes(kdout);
		multipleBytes(jdout);
		
		byte[] kbytes = kbout.toByteArray();
		byte[] jbytes = jbout.toByteArray();
		assertTrue(Arrays.equals(kbytes, jbytes));
		
		ByteArrayInputStream bin = new ByteArrayInputStream(kbytes);
		PushbackInputStream pushIn = new PushbackInputStream(bin, 16*1024);
		gov.nasa.kepler.io.DataInputStream kdin = new gov.nasa.kepler.io.DataInputStream(pushIn);
		byte[] buf = new byte[1024 + 1];
		kdin.read(buf);
		checkByteArray(buf);
		
		pushIn.unread(buf);
		Arrays.fill(buf, (byte)0);
		assertEquals(512, kdin.read(buf, 0, 512));
		assertEquals(513, kdin.read(buf, 512, 513));
		checkByteArray(buf);
		
		pushIn.unread(buf);
		Arrays.fill(buf, (byte) 0);
		kdin.readFully(buf);
		checkByteArray(buf);
		
	}
	
	private static void checkByteArray(byte[] buf) {
		for (int i=0; i < buf.length-1; i++) {
			assertTrue( ((byte) (i+1)) == buf[i]);
		}
		assertEquals((byte) 11, buf[buf.length - 1]);
	}
	
	private static void multipleBytes(DataOutput dout)throws Exception  {
		byte[] ba = new byte[1024];
		for (int i=0; i < ba.length; i++) {
			ba[i] = (byte) (i + 1);
		}
		dout.write(ba);
		dout.write(ba, 10, 1);
	}
		
	@Test
	public void primitives() throws Exception {
		primitives(kdout);
		primitives(jdout);
		
		byte[] kbytes = kbout.toByteArray();
		byte[] jbytes = jbout.toByteArray();
		assertTrue(Arrays.equals(kbytes, jbytes));
		
		ByteArrayInputStream bin = new ByteArrayInputStream(kbytes);
		gov.nasa.kepler.io.DataInputStream kdin = new gov.nasa.kepler.io.DataInputStream(bin);
		
		assertEquals(true, kdin.readBoolean());
		assertEquals(false, kdin.readBoolean());
		
		assertEquals((short) 0, kdin.readShort());
		assertEquals((short) Short.MAX_VALUE, kdin.readShort());
		assertEquals((short) Short.MIN_VALUE, kdin.readShort());
		assertEquals((short) 0xABCD, kdin.readShort());
		
		assertEquals( 0, kdin.readUnsignedShort());
		assertEquals((int) Short.MAX_VALUE, kdin.readUnsignedShort());
		assertEquals(0x8000, kdin.readUnsignedShort());
		assertEquals(0xABCD, kdin.readUnsignedShort());
		
		assertEquals(0, kdin.readInt());
		assertEquals(Integer.MAX_VALUE, kdin.readInt());
		assertEquals(Integer.MIN_VALUE, kdin.readInt());
		assertEquals(0xABCDEF01, kdin.readInt());
		
		assertEquals(0L, kdin.readLong());
		assertEquals(Long.MAX_VALUE, kdin.readLong());
		assertEquals(Long.MIN_VALUE, kdin.readLong());
		assertEquals(0xABCDEF0123456789L, kdin.readLong());
		
		assertEquals('\u0000', kdin.readChar());
		assertEquals(Character.MAX_VALUE, kdin.readChar());
		assertEquals(Character.MIN_VALUE, kdin.readChar());
		assertEquals('\uABCD', kdin.readChar());
		
		assertTrue(0.0f == kdin.readFloat());
		assertTrue(Float.MAX_VALUE == kdin.readFloat());
		assertTrue(Float.MIN_VALUE == kdin.readFloat());
		assertTrue(-Float.MAX_VALUE == kdin.readFloat());
		assertTrue(((float) Math.PI) == kdin.readFloat());
		
		assertTrue(0.0 == kdin.readDouble());
		assertTrue(Double.MAX_VALUE == kdin.readDouble());
		assertTrue(Double.MIN_VALUE == kdin.readDouble());
		assertTrue(-Double.MAX_VALUE == kdin.readDouble());
		assertTrue(Math.PI == kdin.readDouble());
	}
	
	private static void primitives(DataOutput dout) throws Exception {
		dout.writeBoolean(true);
		dout.writeBoolean(false);
		
		dout.writeShort((short) 0);
		dout.writeShort(Short.MAX_VALUE);
		dout.writeShort(Short.MIN_VALUE);
		dout.writeShort((short) 0xABCD);
		
		dout.writeShort((short) 0);
		dout.writeShort(Short.MAX_VALUE);
		dout.writeShort(Short.MIN_VALUE);
		dout.writeShort((short) 0xABCD);
		
		dout.writeInt((int) 0);
		dout.writeInt(Integer.MAX_VALUE);
		dout.writeInt(Integer.MIN_VALUE);
		dout.writeInt(0xABCDEF01);
		
		dout.writeLong(0L);
		dout.writeLong(Long.MAX_VALUE);
		dout.writeLong(Long.MIN_VALUE);
		dout.writeLong(0xABCDEF0123456789L);
		
		dout.writeChar('\u0000');
		dout.writeChar(Character.MAX_VALUE);
		dout.writeChar(Character.MIN_VALUE);
		dout.writeChar('\uABCD');
		
		dout.writeFloat(0.0f);
		dout.writeFloat(Float.MAX_VALUE);
		dout.writeFloat(Float.MIN_VALUE);
		dout.writeFloat(-Float.MAX_VALUE);
		dout.writeFloat((float) Math.PI);
		
		dout.writeDouble(0.0);
		dout.writeDouble(Double.MAX_VALUE);
		dout.writeDouble(Double.MIN_VALUE);
		dout.writeDouble(-Double.MAX_VALUE);
		dout.writeDouble(Math.PI);
		
	}
	
	@SuppressWarnings("deprecation")
    @Test
	public void obsoleteStrings() throws Exception {
		obsoleteStrings(kdout);
		obsoleteStrings(jdout);
		
		byte[] kbytes = kbout.toByteArray();
		byte[] jbytes = jbout.toByteArray();
		assertTrue(Arrays.equals(kbytes, jbytes));
		
		ByteArrayInputStream bin = new ByteArrayInputStream(kbytes);
		PushbackInputStream pushIn = new PushbackInputStream(bin, 16*1024);
		gov.nasa.kepler.io.DataInputStream kdin = new gov.nasa.kepler.io.DataInputStream(pushIn);
		
		assertEquals("\u00fe abcd", kdin.readLine());
		assertEquals(" efg hij", kdin.readLine());
		assertEquals("jj", kdin.readLine());
		assertEquals("cdef", kdin.readLine());
		assertEquals(null, kdin.readLine());
		assertEquals(null, kdin.readLine());
		
	}
	
	private static void obsoleteStrings(DataOutput dout) throws Exception {
		dout.writeBytes(STRING_AS_BYTES);
	}
	
	@Test
	public void utf8() throws Exception {
		utf8(kdout);
		utf8(jdout);
		
		byte[] kbytes = kbout.toByteArray();
		byte[] jbytes = jbout.toByteArray();
		assertTrue(Arrays.equals(kbytes, jbytes));
		
		ByteArrayInputStream bin = new ByteArrayInputStream(kbytes);
		gov.nasa.kepler.io.DataInputStream kdin = new gov.nasa.kepler.io.DataInputStream(bin);
		for (int i=0; i < allChars.length(); i+= CHUNK_SIZE) {
			String part = allChars.substring(i, Math.min(i + CHUNK_SIZE, allChars.length()));
			assertEquals(part, kdin.readUTF());
		}
	}
	
	private static void utf8(DataOutput dout) throws Exception {
	
		final int CHUNK_SIZE = 1024;
		for (int i=0; i < allChars.length(); i += CHUNK_SIZE) {
			dout.writeUTF(allChars.substring(i, Math.min(i + CHUNK_SIZE, allChars.length())));
		}
	}
	
	@Test
	public void skipBytes() throws Exception {
		for (int i=0; i < 13; i++) {
			kdout.write(i);
		}
		kdout.writeDouble(Math.E);
		kdout.write(0);
		kdout.writeLong(0xABCDEF0123456789L);
		
		ByteArrayInputStream bin = new ByteArrayInputStream(kbout.toByteArray());
		gov.nasa.kepler.io.DataInputStream kdin = new gov.nasa.kepler.io.DataInputStream(bin);
		assertEquals(13, kdin.skipBytes(13));
		assertTrue(Math.E == kdin.readDouble());
		assertEquals(1,kdin.skipBytes(1));
		assertEquals(0XABCDEF0123456789L, kdin.readLong());
		assertEquals(0, kdin.skipBytes(1));
	}
	
	private static final class ChunkingInputStream extends InputStream {
		private final InputStream in;
		
		ChunkingInputStream(InputStream in) {
			this.in = in;
		}
		
		@Override
		public int read() throws IOException {
			return in.read();
		}
		
		@Override
		public int read(byte[] buf, int off, int len) throws IOException {
			if (len == 0) {
				return 0;
			}
			
			int v = read();
			if (v < 0) {
				return 0;
			}
			buf[off] = (byte) v;
			return 1;
		}
		
	}
}
