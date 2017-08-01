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

import static gov.nasa.kepler.fs.FileStoreConstants.*;
import static gov.nasa.kepler.fs.transport.TransportConstantsV1.*;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.EOFException;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.channels.Channels;
import java.nio.channels.SocketChannel;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Sean McCauliff
 *
 */
class TransportServerV1 extends TransportV1 implements TransportServer {

    private final static Log log = LogFactory.getLog(TransportServerV1.class);
    
    private final SocketChannel serverChannel;
    private int clientProtocolVersion = -1;
    private ByteOrder clientByteOrder;
    private final boolean admit;
    
    /**
     * 
     * @param serverChannel
     * @param admit When admit is false this will tell signal the client that
     * the server is busy.
     * @throws IOException
     */
    public TransportServerV1(SocketChannel serverChannel, boolean admit) throws IOException {
        if (!serverChannel.isConnected()) {
            throw new IllegalArgumentException("Socket not connected.");
        }
        
        serverChannel.configureBlocking(true);
        this.serverChannel = serverChannel;
        this.admit = admit;
        
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.transport.TransportServer#initConnection()
     */
    @Override
    public void initConnection() throws IOException {
        if (!serverChannel.isConnected()) {
            throw new EOFException("Socket closed.");
        }

        if (clientByteOrder == null) {
            doAdmit();
            doProtocolVersionCheck();
        }
       
        
        if (inputStream == null) {
            inputStream =  new TInV1(Channels.newInputStream(serverChannel), this);
        }
        
        if (outputStream == null) {
            outputStream = new TOutV1(Channels.newOutputStream(serverChannel), this);
        }
    }

    private void doAdmit() throws IOException {
        ByteBuffer admitBuffer = ByteBuffer.allocate(1);
        admitBuffer.put(admit ? ADMIT_YES :ADMIT_NO);
        admitBuffer.position(0);
        serverChannel.write(admitBuffer);
        if (!admit) {
            serverChannel.close();
        }
    }
    
    private void doProtocolVersionCheck() throws IOException {
        Configuration config = ConfigurationServiceFactory.getInstance();
        if (!config.getBoolean(FS_PROTOCOL_VERSION_CHECK_PROP, 
                FS_PROTOCOL_VERSION_CHECK_DEFAULT)) {
            log.info("Skipping protocol version check.");
            return;
        }
        
        ByteBuffer versionBuf = versionBuffer();
        serverChannel.read(versionBuf);
        versionBuf.position(0);
        byte clientByteOrderByte = versionBuf.get();
        clientByteOrder = clientByteOrderByte == BIG_ENDIAN_BYTE ?
            ByteOrder.BIG_ENDIAN : ByteOrder.LITTLE_ENDIAN;
        
        if (!clientByteOrder.equals(ByteOrder.nativeOrder())) {
            log.warn("Client byte order is different from server ordering. " +
                " Expected " + ByteOrder.nativeOrder() + " but found " + 
                clientByteOrder + ".");
        }
       
        clientProtocolVersion = versionBuf.getInt();
        if (clientProtocolVersion != CURRENT_PROTOCOL_VERSION) {
            log.warn("Client (" +
                serverChannel.socket().getRemoteSocketAddress()
                + ")  protocol version (" + clientProtocolVersion + 
                ") does not match server protcol version(" + 
                CURRENT_PROTOCOL_VERSION + ")");
        }
        
        versionBuf = versionBuffer();
        serverChannel.write(versionBuf);
    }
    
    @Override
    protected SocketChannel socketChannel() throws IOException {
        return serverChannel;
    }
    
    /* (non-Javadoc)
     * @see gov.nasa.kepler.fs.transport.TransportServer#close()
     */
    @Override
    public void close() throws IOException {
        serverChannel.close();
    }
    
    /**
     * This does nothing.
     */
    @Override
    public void doneWithMethod() throws IOException {
        
    }

}
