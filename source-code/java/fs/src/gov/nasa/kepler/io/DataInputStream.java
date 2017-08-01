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

import java.io.DataInput;
import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.PushbackInputStream;

/**
 * This is meant as a replacement for java.io.DataInputStream.  Unlike the class
 * it is replacing this class does not do a synchronize every time write() is
 * called and does not track the number of bytes written.
 * 
 * @author Sean McCauliff
 *
 */
public final class DataInputStream extends InputStream implements DataInput {

	private final InputStream in;

	public DataInputStream(InputStream in) {
		this.in = in;
	}
	
	@Override
	public int read() throws IOException {
		return in.read();
	}
	
	@Override
	public int read(byte[] b) throws IOException {
		return in.read(b);
	}
	
	@Override
	public int read(byte[] b, int off, int len) throws IOException {
		return in.read(b, off, len);
	}
	
	@Override
	public boolean readBoolean() throws IOException {
		int v = read();
		if (v < 0) {
			    throw new EOFException();
		}
		return v != 0;
	}


	@Override
	public byte readByte() throws IOException {
		int v = read();
		if (v < 0) {
			throw new EOFException();
		}
		return (byte) v;
	}


	@Override
	public char readChar() throws IOException {
		int b1 = this.read();
        int b2 = this.read();
        if ( (b1 | b2) < 0) {
        	throw new EOFException();
        }
        return (char)((b1 << 8) | b2);
	}


	@Override
	public double readDouble() throws IOException {
		return Double.longBitsToDouble(readLong());
	}


	@Override
	public float readFloat() throws IOException {
		return Float.intBitsToFloat(readInt());
	}


	@Override
	public void readFully(byte[] b) throws IOException {
		readFully(b, 0, b.length);
	}


	@Override
	public void readFully(byte[] b, int off, int len) throws IOException {
		while (len > 0) {
			int nRead = in.read(b, off, len);
			if (nRead < 0) {
				throw new EOFException();
			}
			len -= nRead;
			off += nRead;
		}
	}


	@Override
	public int readInt() throws IOException {
		int a = readUnsignedByte();
	    int b = readUnsignedByte();
	    int c = readUnsignedByte();
	    int d = readUnsignedByte();
	    
	    return (((a & 0xff) << 24) | ((b & 0xff) << 16) |
	            ((c & 0xff) << 8) | (d & 0xff));
    }

	public long readLong() throws IOException {
		int a = readUnsignedByte();
		int b = readUnsignedByte();
		int c = readUnsignedByte();
		int d = readUnsignedByte();
		int e = readUnsignedByte();
		int f = readUnsignedByte();
		int g = readUnsignedByte();
		int h = readUnsignedByte();

		return (((long)(a & 0xff) << 56) |
				((long)(b & 0xff) << 48) |
				((long)(c & 0xff) << 40) |
				((long)(d & 0xff) << 32) |
				((long)(e & 0xff) << 24) |
				((long)(f & 0xff) << 16) |
				((long)(g & 0xff) <<  8) |
				((long)(h & 0xff)));
	}


	/**
	 * This method is required by DataInput, but is lame because it cannot
	 * correctly decode \r\n without the underlying streaming being a pushback
	 * stream and does not decode unicode characters.
	 */
	@Override
	@Deprecated
	public String readLine() throws IOException {
		StringBuilder bldr = new StringBuilder();
		int b = in.read();
		if (b < 0) {
			return null;
		}
		loop: for (; b >= 0; b = in.read()) {
			switch (b) {
			case -1:
			case '\n': break loop;
			case '\r':
				int nextChar = in.read();
				if (nextChar != '\n' && in instanceof PushbackInputStream) {
					PushbackInputStream pushIn = (PushbackInputStream) in;
					pushIn.unread(nextChar);
				}
				break loop;
			default:
				bldr.append((char)b);
			}
		}
		
		return bldr.toString();
	}


	@Override
	public short readShort() throws IOException {
        int a = readUnsignedByte();
        int b = readUnsignedByte();
        
        return (short)((a << 8)  | (b & 0xff));
	}

	/**
     * See the documentation for DataInput for how this is encoded..
     */
	@Override
    public String readUTF() throws IOException {
        StringBuilder bldr = new StringBuilder();
        int byteLength = readUnsignedShort();
        for (int i=0; i < byteLength; i++) {
            int first = readUnsignedByte();
            if ( (first & 0x80) == 0) {
                bldr.append((char) first);
            } else if ( (first >> 4) == 0xE) {
                int second = readUnsignedByte();
                int third= readUnsignedByte();
                i += 2;
                int v = (((first & 0x0F) << 12) | ((second & 0x3F) << 6) | (third & 0x3F));
                bldr.append((char) v);
            } else {
                int second = readUnsignedByte();
                i++;
                bldr.append( (char)(((first& 0x1F) << 6) | (second & 0x3F)) );
            }
        }
        return bldr.toString();
    }


	@Override
	public int readUnsignedByte() throws IOException {
		int v = read();
		if (v < 0) {
			throw new EOFException();
		}
		return v;
	}


	@Override
	public int readUnsignedShort() throws IOException {
        int a = readUnsignedByte();
        int b = readUnsignedByte();
        
        return (a << 8)  | (b & 0xff);
	}


	@Override
	public int skipBytes(final int n) throws IOException {
		int total = 0;
		int current = 0;

		while ((total<n) && ((current = (int) in.skip(n-total)) > 0)) {
		    total += current;
		}

		return total;
	}
	

}
