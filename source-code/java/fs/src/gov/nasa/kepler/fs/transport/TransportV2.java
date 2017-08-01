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

import static gov.nasa.kepler.fs.transport.TransportConstants.*;
import static gov.nasa.kepler.fs.transport.ProtocolVersion.*;
import gov.nasa.kepler.fs.client.ClientSideException;
import gov.nasa.spiffy.common.io.FileUtil;

import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.Channels;
import java.nio.channels.FileChannel;
import java.nio.channels.ReadableByteChannel;
import java.nio.channels.SocketChannel;
import java.util.Deque;
import java.util.concurrent.LinkedBlockingDeque;

import org.apache.commons.io.input.CloseShieldInputStream;
import org.apache.commons.io.output.CloseShieldOutputStream;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
* Some goals of the file store transport protocol:
* 1) Allow errors to be transmitted at any point in the protocol.  The 
* receiving side should throw these errors back to the caller.
* 2) Symmetric:  the client and server side should use the same protocol.
* 3) Avoid buffering.
* 4) Allow use of FileChannel.transferTo and FileChannel.transferFrom.
* 
* Transport configures its SocketChannel to be blocking.
* 
* This class is not MT-safe
* 
* @author Sean McCauliff
*/
abstract class TransportV2 {

    private static final Log log = LogFactory.getLog(TransportV2.class);
    
    protected static final int METHOD_ORDER_START = -1;
    
    protected static final byte ADMIT_YES = 23;
    protected static final byte ADMIT_NO = 42;
    
    protected static final int DEFAULT_CONNECT_TIMEOUT_SECS = 60;
    /**
     * The size of the kernel socket buffer for incoming packets.
     */
    protected static final int RECV_BUF_SIZE = 1024*1024;
    /**
     * The size of the kernel socket buffer for outgoing packets.
     */
    protected static final int SEND_BUF_SIZE = 1024*1024;
    
    protected static final byte BIG_ENDIAN_BYTE = 0;
    protected static final byte LITTLE_ENDIAN_BYTE = 1;
    protected static final byte MY_ENDIANNESS;
    
    /** A place to store used Byte Buffers that are no longer in use.
     * This is here because there is no good way to cleanup direct byte buffers after
     * they have been allocated except if the garbage collector runs finalize()
     * which it is not required to.
     * */
    private static Deque<ByteBuffer> byteBufferCache = 
        new LinkedBlockingDeque<ByteBuffer>();
    
    static {
        ProtocolUtils.workAround6427854();
        
        MY_ENDIANNESS = ByteOrder.nativeOrder() == ByteOrder.BIG_ENDIAN ?
            BIG_ENDIAN_BYTE : LITTLE_ENDIAN_BYTE;
    }
    
    protected TOutV2 outputStream;
    protected TInV2 inputStream;
    ByteBuffer receiveMessageBuffer;
    ByteBuffer sendMessageBuffer;
    private final ByteBuffer ackBuffer = ByteBuffer.allocate(5);
    /** This is the negotiated protocol version in use for this session. */
    protected ProtocolVersion protocolVersionInUse = CURRENT_PROTOCOL_VERSION;
    private final ByteBufferAsChannel receieveBufferChannel = new ByteBufferAsChannel();
    
    
    /**
     * The method number an incrementing number the client
     * sends the server.
     */
    protected int methodOrder = METHOD_ORDER_START;

    protected TransportV2() {
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
    
    protected ByteBuffer allocateBuffer(ByteBuffer orig) {
        if (orig == null) {
            orig = byteBufferCache.pollFirst();
            if (orig == null) {
                orig = ByteBuffer.allocateDirect(protocolVersionInUse.maxMessageSize());
            }
        }
        
        if (orig.capacity() < protocolVersionInUse.maxMessageSize()) {
            log.warn("Potentially leaking direct byte buffer.");
            orig = null;
            System.gc(); //hopefully this will clean up the direct byte buffer
            orig = ByteBuffer.allocateDirect(protocolVersionInUse.maxMessageSize());
        }
        orig.limit(0);
        orig.position(0);
        if (orig.hasRemaining()) {
            throw new IllegalStateException("Buffer not ready.");
        }
        return orig;
    }
    
    protected static void releaseByteBuffer(ByteBuffer byteBuffer) {
        if (byteBuffer != null) {
            byteBufferCache.addFirst(byteBuffer);
        }
    }
    
    /**
     * Send file over the network.  Likely this will be accelerated by the OS.
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

        boolean wasBlocking = socketChannel.isBlocking();
        if (!wasBlocking) {
            socketChannel.configureBlocking(true);
        }
        
        if (sendMessageBuffer.hasRemaining()) {
            throw new TransportException("There are bytes still to send.");
        }
        
        try {
            //Message size is the protocol message size not the file count
            int payloadSize = 0;
            while (count > 0) {
                if (payloadSize == 0) {
                    payloadSize = (int) Math.min(protocolVersionInUse.maxPayloadSize(), count);
                
                    fillHeader(payloadSize);
                    sendMessageBuffer.limit(protocolVersionInUse.dataMessageHeaderSize());
                    sendMessageBuffer.position(0);
                    socketChannel.write(sendMessageBuffer);
                }
                
                long nwrite = src.transferTo(startPos, payloadSize, socketChannel);
                startPos += nwrite;
                count -= nwrite;
                payloadSize -= nwrite;
                if (payloadSize == 0) {
                    waitForAck();
                }
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
        
        //Expected bytes are the number of file bytes that still need to be read.
        int expectedChannelBytes = 0;
        try {
            while (count > 0) {
                
                if (receiveMessageBuffer.hasRemaining()) {
                    //If was transferred in a message buffer then drain that buffer first
                    //and then use the socket channel itself to transfer data directly.
                    int remainingMessageLimit = receiveMessageBuffer.limit();
                    long readNBytes = Math.min(receiveMessageBuffer.remaining(), count);
                    receiveMessageBuffer.limit((int) readNBytes + receiveMessageBuffer.position());
                    long nread = dest.transferFrom(receieveBufferChannel, destStart, readNBytes);
                    count -= nread;
                    destStart += nread;
                    receiveMessageBuffer.limit(remainingMessageLimit);
                } else {
                    //Read directly from the socket channel.
                    if (expectedChannelBytes == 0) {
                        expectedChannelBytes = receiveMessage(false);
                    }
                    long numberToRead = Math.min(count, expectedChannelBytes);
                    //Sun's implementation of this is faster if you use a socketChannel
                    //directly.
                    long nread = dest.transferFrom(socketChannel, destStart, numberToRead);
                    count -= nread;
                    destStart += nread;
                    expectedChannelBytes -= nread;
                    if (expectedChannelBytes == 0) {
                        sendAck();
                    }
                }
            }
        } finally {
            if (!wasBlocking) {
                socketChannel.configureBlocking(false);
            }
        }
    }
    
    
    /**
     * Fills the start of the send buffer header. This sets the buffer header
     * to limit to payloadSize + headerSize and position to headerSize.
     * Position is left at the point where payload would start.
     * @param payloadSize The number of bytes of payload to expect. 
     * @throws TransportException 
     */
    void fillHeader(int payloadSize) throws TransportException {
        if (sendMessageBuffer.hasRemaining()) {
            throw new TransportException("Can't start new message with data pending.");
        }
        if (payloadSize < 0) {
            throw new IllegalArgumentException("Payload size may not be zero.");
        }
        if (payloadSize > protocolVersionInUse.maxPayloadSize()) {
            throw new IllegalArgumentException("Message size is too large.");
        }
        sendMessageBuffer.position(0);
        sendMessageBuffer.limit(payloadSize + protocolVersionInUse.dataMessageHeaderSize());
        sendMessageBuffer.put(NO_EXCEPTION);
        putIntToBuffer(payloadSize, sendMessageBuffer);
        if (protocolVersionInUse == PROTOCOL_V2) {
            putIntToBuffer(methodOrder, sendMessageBuffer);
        }
    }
    
    /**
     * Parses the contents of receiveMessageBuffer starting from position 0.
     * After parsing the contents of the header the position of the receiveMessageBuffer
     * will be left at the start of the payload if any.  If the message encodes
     * an exception then it will be decoded and thrown.
     * @param getpayload Also fills the buffer with 
     * @return  The number of bytes of payload.
     * @throws IOException 
     */
    int receiveMessage(boolean getpayload) throws IOException {
        final SocketChannel socketChannel = socketChannel();
        //This is in a while loop in case we get an old message and need to 
        //drop the message.
        while (true) {
            receiveMessageBuffer.position(0);
            receiveMessageBuffer.limit(1);
            receive(socketChannel);
            byte expectException = receiveMessageBuffer.get(0);
            switch (expectException) {
                case NO_EXCEPTION: //OK
                    break;
                case EXCEPTION_FOLLOWS:
                    decodeRemoteException();
                    break;
                case ACK:
                    //Ack not expected at this point.
                    receiveMessageBuffer.limit(5);
                    receive(socketChannel);
                    receiveMessageBuffer.position(1);
                    int ackOrder = receiveMessageBuffer.getInt();
                    if (ackOrder < methodOrder) {
                        log.warn("Dropping old ack.");
                        continue; //drop ack.
                    }
                    throw new TransportException("Expected message but got ack.");
                default:
                    throw new TransportException("Got unknown message type " + expectException);
            }
            receiveMessageBuffer.limit(protocolVersionInUse.dataMessageHeaderSize());
            receive(socketChannel);
            receiveMessageBuffer.position(1);
            int payloadBytes = getIntFromBuffer(receiveMessageBuffer);
            if (payloadBytes < 0) {
                throw new TransportException("Number of expected bytes was negative.");
            }
            if (payloadBytes > protocolVersionInUse.maxPayloadSize()) {
                throw new TransportException("Payload exceeds max payload size.");
            }
            if (protocolVersionInUse == PROTOCOL_V2) {
                int receivedMethodOrder = getIntFromBuffer(receiveMessageBuffer);
                if (receivedMethodOrder < methodOrder) {
                    log.warn("Received old message, dropping message.");
                    receiveMessageBuffer.limit(payloadBytes + protocolVersionInUse.dataMessageHeaderSize());
                    receive(socketChannel);
                    //Don't set position back to zero since we want to discard
                    //this message.
                    sendAck();
                    continue;
                } else if (receivedMethodOrder > methodOrder) {
                    //The other side presumably has sent us a valid message, but
                    //we are not able to process that message right now so we
                    //need to save the data we have receieved
                    receiveMessageBuffer.limit(payloadBytes + protocolVersionInUse.dataMessageHeaderSize());
                    receive(socketChannel);
                    receiveMessageBuffer.position(protocolVersionInUse.dataMessageHeaderSize());
                    throw new ClientSideException();
                }
            }
            
            if (getpayload) {
                receiveMessageBuffer.limit(payloadBytes + protocolVersionInUse.dataMessageHeaderSize());
                receive(socketChannel);
                //Ready to read payload data.
                receiveMessageBuffer.position(protocolVersionInUse.dataMessageHeaderSize());
                sendAck();
            }
            
            return payloadBytes;
        }
    }
    
    private void receive(SocketChannel socketChannel) throws IOException {
        while (receiveMessageBuffer.hasRemaining()) {
            if (socketChannel.read(receiveMessageBuffer) == -1) {
                try {
                    socketChannel.close();
                } catch (IOException ignored) {
                }
                throw new IOException("Remote host has disconnected.");
            }
        }
    }
        
    int expectedBytes()  {
        return receiveMessageBuffer.remaining();
    }
    
    
    void setExpectedBytes(int newValue) {
        receiveMessageBuffer.limit(newValue);
    }
 
    void skipExpectedBytes() {
        receiveMessageBuffer.limit(0);
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
        byteBuffer.putInt(CURRENT_PROTOCOL_VERSION.ordinal());
        byteBuffer.position(0);
        return byteBuffer;
    }
    
    /**
     * @throws IOException
     * @throws TransportException
     */
    void decodeRemoteException() throws IOException, TransportException {
        
        ObjectInputStream oin = 
            new ObjectInputStream(new CloseShieldInputStream(Channels.newInputStream(socketChannel())));
        try {
            Throwable t =(Throwable) oin.readObject();
            throw new ServerSideException("Server side exception.", t);
        } catch (ClassNotFoundException cnfe) {
            throw new TransportException("Exception while unpacking server side exception.", cnfe);
        } finally {
            FileUtil.close(oin);
        }
    }
    
    public void sendThrowable(Throwable t) throws IOException {
        sendMessageBuffer.position(0);
        sendMessageBuffer.limit(1);
        //This is an exception.
        sendMessageBuffer.put(EXCEPTION_FOLLOWS);
        sendMessageBuffer.position(0);
        socketChannel().write(sendMessageBuffer);
        ObjectOutputStream oos = new ObjectOutputStream(
            new CloseShieldOutputStream(
                Channels.newOutputStream(socketChannel())));
        try {
            oos.writeObject(t);
            oos.flush();
        } finally {
            FileUtil.close(oos);
        }
        if (expectedBytes() > 0) {
            skipExpectedBytes();
        }
    }
    
    
    /** 
     * Waits for the server to acknowledge the receipt of a message.
     * This does not interfere with the receipt of incoming messages.
     * 
     * @throws IOException
     * @throws TransportException  Usually occurs because of an exception
     * on the other side.
     */
    void waitForAck() throws IOException, TransportException {
        switch (protocolVersionInUse) {
            case PROTOCOL_V1: break; //V1 does not have acknowledgments
            case PROTOCOL_V2: 
                ackBuffer.limit(5);
                ackBuffer.position(0);
                if (socketChannel().read(ackBuffer) == -1) {
                    throw new IOException("Remote host closed connection.");
                }
                ackBuffer.position(0);
                switch (ackBuffer.get()) {
                    case NO_EXCEPTION:
                        throw new TransportException("Got NO_EXCEPTION but expected ACK.");
                    case EXCEPTION_FOLLOWS:
                        decodeRemoteException();
                        break;
                    case ACK:
                        int ackMethodOrder = ackBuffer.getInt();
                        if (ackMethodOrder > methodOrder) {
                            throw new ClientSideException();
                        }
                        break; //OK
                    default:
                        throw new TransportException("Bad ACK message.");
                }
                break;
            default:
                throw new IllegalStateException("Unsupported protocol version " + protocolVersionInUse);
        }
    }
    
    void sendAck() throws IOException, TransportException {
        switch (protocolVersionInUse) {
        case PROTOCOL_V1: break; //V1 does not have acknowledgments
        case PROTOCOL_V2:
            ackBuffer.position(0);
            ackBuffer.put(ACK);
            ackBuffer.putInt(methodOrder);
            ackBuffer.position(0);
            socketChannel().write(ackBuffer);
            break;
        default:
            throw new IllegalStateException("Unsupported protocol version " + protocolVersionInUse);
        }
    }
    
    /**
     * Version dependent writing of ints.
     */
    void putIntToBuffer(int value, ByteBuffer buf) {
        switch (protocolVersionInUse) {
        case PROTOCOL_V1:
            buf.put((byte)((value >> 24) & 0xFF));
            buf.put((byte)((value >> 16) & 0xFF));
            buf.put((byte)((value >> 8)  & 0xFF));
            buf.put((byte) (value & 0xFF));
            break;
        case PROTOCOL_V2:
            buf.putInt(value);
            break;
        default:
            throw new IllegalStateException("Bad protocol version " + protocolVersionInUse + ".");
        } 
    }
    
    int getIntFromBuffer(ByteBuffer buf) {
        switch (protocolVersionInUse) {
        case PROTOCOL_V1:
            return buf.get() << 24 | (buf.get() & 0xff) << 16 | (buf.get() & 0xff) << 8 | (buf.get() & 0xff);
        case PROTOCOL_V2:
            return buf.getInt();
        default:
            throw new IllegalStateException("Bad protocol version " + protocolVersionInUse + ".");
        } 
    }
    
    protected  abstract void initConnection() throws IOException;
    
    /** Returns a socket channel in blocking mode. */
    abstract SocketChannel socketChannel() throws IOException;
    
    public abstract void close() throws IOException;
    
    /**
     * Presents a view of the receive buffer as a channel.  This is so the file
     * transfer methods can work on buffered data.
     *
     */
    private final class ByteBufferAsChannel implements ReadableByteChannel {

        @Override
        public int read(ByteBuffer dst) throws IOException {
            if ( dst.remaining() >= receiveMessageBuffer.remaining()) {
                int bytesTransferred = receiveMessageBuffer.limit() - receiveMessageBuffer.position();
                dst.put(receiveMessageBuffer);
                return bytesTransferred;
            }
            int bytesTransferred = dst.remaining();
            int origLimit = receiveMessageBuffer.limit();
            receiveMessageBuffer.limit(receiveMessageBuffer.position()
                + bytesTransferred);
            dst.put(receiveMessageBuffer);
            receiveMessageBuffer.limit(origLimit);
            return bytesTransferred;
        }

        @Override
        public void close() throws IOException {
            //This does nothing.
        }

        @Override
        public boolean isOpen() {
            return receiveMessageBuffer.hasRemaining();
        }

    }
}