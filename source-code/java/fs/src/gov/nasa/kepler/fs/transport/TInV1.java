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

import java.io.EOFException;
import java.io.IOException;
import java.io.InputStream;
import java.io.ObjectInputStream;

/**
 * Transport input stream.
 * 
 * @author Sean McCauliff
 *
 */
class TInV1 extends InputStream {

    private final InputStream sin;
    private final TransportV1 transport;

    
    /**
     * 
     * @param sin
     * @param transport
     */
    
    TInV1(InputStream sin, TransportV1 transport) {
        this.sin = sin;
        this.transport = transport;
    }
    
    @Override
    public int read() throws IOException {
        startMessage();
        
        if (transport.expectedBytes() == 0) {
            return -1;
        }
        
        int b = sin.read();
        transport.decrementExpectedBytes();
        return b;
    } 

    @Override
    public int read(byte[] dest, int off, int len) throws IOException {
        startMessage();

        if (transport.expectedBytes() == 0) {
            return 0;
        }
        
        int canRead = Math.min(len, transport.expectedBytes());
        int nRead = sin.read(dest, off, canRead);
        transport.decrementExpectedBytes(nRead);
        return nRead;
    }
    
    /**
     * Can't be completely certain how many bytes we can read past
     * a message boundry so this will return only the number this
     * actually knows about.
     * 
     * @see java.io.InputStream#available()
     */
    @Override
    public int available() throws IOException {
        
        int socketAvailable = sin.available();
        if (transport.expectedBytes() == NO_EXPECTED_BYTES && 
            socketAvailable > SIZE_OF_SIZE) {
            
            startMessage();
            socketAvailable -= SIZE_OF_SIZE;
        }
        
        if (socketAvailable > transport.expectedBytes()) {
            return transport.expectedBytes();
        } else {
            return socketAvailable;
        }
    }
    
    /**
     * Keeps the socket open for sometime in case it is needed again.
     */
    @Override
    public void close() throws IOException {
        startMessage();
        
        if (transport.expectedBytes() != NO_EXPECTED_BYTES) {
            
            long actualSkipped = sin.skip(transport.expectedBytes());
            if (actualSkipped != transport.expectedBytes()) {
                transport.close();
                throw new IOException("Failed to sync expected bytes.");
            }
            transport.setExpectedBytes(0);
        }
    }
    
    
    /**
     * This method is not supported.
     * @see java.io.InputStream#skip(long)
     */
    @Override
    public long skip(long n) throws IOException {
        throw new IOException("skip() not supported.");
    }
    
    
    /**
     * Gets the size of the message and checks for exceptions.
     * @throws IOException
     */
    private void startMessage() throws IOException {
        if (transport.expectedBytes() != NO_EXPECTED_BYTES) {
            return;
        }

        
        boolean exceptionFollows = readBoolean();
        if (exceptionFollows) {
            decodeRemoteException(sin);
        }
      

        int newSize = readInt(sin);
        if (newSize < 0) {
            throw new TransportException("Got negative message size.");
        }
        
        //This is here to prevent accidental OOM when reading bad messages.
        if (newSize > MAX_MESSAGE_SIZE) {
            throw new TransportException("Message exceeds max message size.");
        }
        
        transport.setExpectedBytes(newSize);
       
    }
    
    /**
     * @throws IOException
     * @throws TransportException
     */
    static void decodeRemoteException(InputStream in) throws IOException, TransportException {
        ObjectInputStream oin = new ObjectInputStream(in) {
            public void close() {
                //This must not close the socket input stream.
            }
        };
        
        try {
            Throwable t =(Throwable) oin.readObject();
            throw new ServerSideException("Server side exception.", t);
        } catch (ClassNotFoundException cnfe) {
            throw new TransportException("Exception while unpacking server side exception.", cnfe);
        }
    }
    
    private static int safeRead(InputStream in) throws IOException {
        int b = in.read();
        if (b == -1) {
            throw new EOFException("Missing message size data.");
        }
        
        return b;
    }
    
    private boolean readBoolean() throws IOException {
        return safeRead(sin) == 1;
    }
    
    /**
     * This is also the way DataOutput requires integers to be encoded.
     * 
     * @param in
     * @return
     * @throws IOException
     */
    static int readInt(InputStream in) throws IOException {
        int first = safeRead(in);
        int second = safeRead(in);
        int third = safeRead(in);
        int fourth= safeRead(in);
        
        return (first << 24) | (second << 16) | (third << 8) | fourth;
    }
}
