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

package gov.nasa.kepler.fs.transport;

import static gov.nasa.kepler.fs.transport.TransportConstantsV1.*;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.SocketChannel;


/**
* Some goals of the file store transport protocol:
    * 1) Allow errors to be transmitted at any point in the protocol.  The 
    * receiving side should throw these errors back to the caller.
    * 2) Symmetric:  the client and server side should use the same protocol.
    * 3) Avoid buffering.
    * 4) Allow use of FileChannel.transferTo and FileChannel.transferFrom
    * 
    * @author Sean McCauliff
    */
abstract class TransportV1 {

    protected static final byte ADMIT_YES = 23;
    protected static final byte ADMIT_NO = 42;
    
    protected static final int DEFAULT_CONNECT_TIMEOUT_SECS = 60;
    /**
     * The size of the kernel socket buffer for incoming packets.
     */
    protected static final int RECV_BUF_SIZE = 1024*512;
    /**
     * The size of the kernel socket buffer for outgoing packets.
     */
    protected static final int SEND_BUF_SIZE = 1024*512;

    protected static final byte BIG_ENDIAN_BYTE = 0;
    protected static final byte LITTLE_ENDIAN_BYTE = 1;
    protected static final byte MY_ENDIANNESS;
    
    static {
        ProtocolUtils.workAround6427854();

        MY_ENDIANNESS = ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN ?
            BIG_ENDIAN_BYTE : LITTLE_ENDIAN_BYTE;
    }
    
    protected TOutV1 outputStream;
    protected TInV1 inputStream;
    private int expectedBytes = NO_EXPECTED_BYTES;

    protected TransportV1() {
        super();
    }

    public OutputStream outputStream() throws IOException {
        initConnection();
        
        return outputStream;
    }

    public InputStream inputStream() throws IOException {
        initConnection();
        
        return inputStream;
    }

    public void sendThrowable(Throwable t) throws IOException {
        outputStream();
        outputStream.sendThrowable(t);
    }
    
    /**
     * Send file over the network.  Likely this will be acclerated by the OS.
     * 
     * @param src  File's channel.
     * @param startPos Where to start sending data in the channel.
     * @param count The number of bytes to send.
     * @throws IOException
     */
    public void sendFile(FileChannel src, long startPos, long count)
        throws IOException {
        
        initConnection();
        
        SocketChannel socketChannel  = socketChannel();
        if (!socketChannel.isConnected()) {
            throw new TransportException("socket channel closed");
        }

        ByteBuffer buf = ByteBuffer.allocateDirect(SIZE_OF_SIZE+1);
        boolean wasBlocking = socketChannel.isBlocking();
        if (!wasBlocking) {
            socketChannel.configureBlocking(true);
        }
        
        try {
            int messageSize = 0;
            while (count > 0) {
    
                if (messageSize == 0) {
                    messageSize =(int) Math.min(MAX_MESSAGE_SIZE, count);
                
                    buf.position(0);
                    buf.put((byte)0);
                    buf.put((byte) ((messageSize >> 24) & 0xff));
                    buf.put((byte) ((messageSize >> 16) & 0xff));
                    buf.put((byte) ((messageSize >> 8) & 0xff));
                    buf.put((byte) ((messageSize & 0xff)));
                    buf.position(0);
                }
                
                socketChannel.write(buf);
                long nwrite = src.transferTo(startPos, messageSize, socketChannel);
                
                startPos += nwrite;
                count -= nwrite;
                messageSize -= nwrite;
            }
        } finally {
            if (!wasBlocking) {
                socketChannel.configureBlocking(false);
            }
        }
    }
    
    /**
     * Writes bytes directly from the socket into a file.  Likely this will not be
     * very accelerated.
     * 
     * @param dest
     * @param count The number of bytes expected to receive.  This may be
     * the entire file or just part of a file.  If the other side does not know
     * how long the file is going to be then this will just be part of the file.
     * 
     */
    public void receiveFile(FileChannel dest, long destStart, long count)
        throws IOException {
        
        initConnection();
        SocketChannel socketChannel  = socketChannel();
        if (!socketChannel.isConnected()) {
            throw new TransportException("socket channel closed");
        }
        
        boolean wasBlocking = socketChannel.isBlocking();
        if (!wasBlocking) {
            socketChannel.configureBlocking(true);
        }

        try {
            InputStream chin = Channels.newInputStream(socketChannel);
            while (count > 0) {
                //Expected bytes are the number of bytes expected by the transport layer
                if (expectedBytes == 0) {
                    if (chin.read() != 0) {
                        TInV1.decodeRemoteException(chin);
                    }
                    expectedBytes = TInV1.readInt(chin);
                }
                
                long numberToRead = Math.min(count, expectedBytes);
                long nread = dest.transferFrom(socketChannel, destStart, numberToRead);
                count -= nread;
                destStart += nread;
                expectedBytes -= nread;
            }
        } finally {
            if (!wasBlocking) {
                socketChannel.configureBlocking(false);
            }
        }
    }

    int expectedBytes()  {
        return expectedBytes;
    }
    
    
    void setExpectedBytes(int newValue) {
        expectedBytes = newValue;
    }
    
    void decrementExpectedBytes() {
        decrementExpectedBytes(1);
    }
    
    void decrementExpectedBytes(int dec) {
        expectedBytes -= dec;
        if (expectedBytes < 0) {
            throw new IllegalStateException("Expected bytes is less than zero.");
        }
    }
 
    void skipExpectedBytes() throws IOException {
        ByteBuffer buf = ByteBuffer.allocateDirect(expectedBytes);
        while (buf.position() != expectedBytes) {
            socketChannel().read(buf);
        }
        expectedBytes = 0;
    }
    
    /**
     * Creates a populated byteBuffer that has protocol version and endianness
     * information. 
     * @return a non-direct byte buffer that has contents, but whose position 
     * is zero.
     */
    protected ByteBuffer versionBuffer() {
        ByteBuffer byteBuffer = ByteBuffer.allocate(5);
        byteBuffer.put(MY_ENDIANNESS);
        byteBuffer.putInt(CURRENT_PROTOCOL_VERSION);
        byteBuffer.position(0);
        return byteBuffer;
    }
    protected  abstract void initConnection() throws IOException;
    
    protected abstract SocketChannel socketChannel() throws IOException;
    
    public abstract void close() throws IOException;
    
}