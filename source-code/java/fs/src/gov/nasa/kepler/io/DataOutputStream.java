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

import java.io.DataOutput;
import java.io.IOException;
import java.io.OutputStream;

/**
 * This is meant to be a replacement for java.io.DataOutputStream.  Unlike
 * its replacement this not do writeByte() in a synchronized block and does not
 * count the number of bytes written.
 * 
 * @author Sean McCauliff
 *
 */
public final class DataOutputStream extends OutputStream implements DataOutput {

	private final OutputStream out;
	
	public DataOutputStream(OutputStream out) {
		this.out = out;
	}
	
	@Override
	public void write(int b) throws IOException {
		out.write(b);
	}

	@Override
	public void write(byte[] b) throws IOException {
		out.write(b);
	}

	@Override
	public void write(byte[] b, int off, int len) throws IOException {
		out.write(b, off, len);
	}

	@Override
	public void writeBoolean(boolean v) throws IOException {
		write(v ? 1 : 0);
	}

	@Override
	public void writeByte(int v) throws IOException {
		write(v);
	}

	@Override
	public void writeBytes(String s) throws IOException {
		for (int i=0; i < s.length(); i++) {
			write(s.charAt(i) & 0xFF);
		}
	}

	@Override
	public void writeChar(int v) throws IOException {
        write((byte)(0xff & (v >> 8)));
        write((byte)(0xff & v));
	}

	@Override
	public void writeChars(String s) throws IOException {
		for (int i=0; i < s.length(); i++) {
			writeChar(s.charAt(i));
		}
	}

	@Override
	public void writeDouble(double v) throws IOException {
		  writeLong(Double.doubleToLongBits(v));
	}

	@Override
	public void writeFloat(float v) throws IOException {
        writeInt(Float.floatToIntBits(v));
	}

	@Override
	public void writeInt(int v) throws IOException {
        write((byte)(0xff & (v >> 24)));
        write((byte)(0xff & (v >> 16)));
        write((byte)(0xff & (v >>    8)));
        write((byte)(0xff & v));
	}

	@Override
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

	@Override
	public void writeShort(int v) throws IOException {
        write((byte)(0xff & (v >> 8)));
        write((byte)(0xff & v));
	}

	/**
     * See the documentation for DataInput.writeUTF for how this
     * encoding works.
     */
	@Override
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

    public static int utf8Length(String str) {
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
    
    /**
     * This calls flush on the underlying output stream.
     */
	@Override
	public void flush() throws IOException {
		out.flush();
	}
	
	/**
	 * Flushes the underlying output stream and then closes it.
	 */
	@Override
	public void close() throws IOException {
		try {
			flush();
		} catch (IOException ignored) {
		}
		out.close();
	}
	
}
