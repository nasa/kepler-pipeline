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


import java.io.*;

/**
 * Transport input stream.
 * 
 * This class is not MT-safe.
 * 
 * @author Sean McCauliff
 *
 */
class TInV2 extends InputStream {

    private final TransportV2 transport;

    
    /**
     * 
     * @param sin
     * @param transport
     */
    
    TInV2(TransportV2 transport) {
        this.transport = transport;
    }
    
    @Override
    public int read() throws IOException {
        readMessage();
        
        if (transport.expectedBytes() == 0) {
            return 0;
        }
        
        return transport.receiveMessageBuffer.get() & 0xff;
    } 

    @Override
    public int read(byte[] dest, int off, int len) throws IOException {
        readMessage();

        if (!transport.receiveMessageBuffer.hasRemaining()) {
        	return 0;
        }
        
        int canRead = Math.min(len, transport.receiveMessageBuffer.remaining());
        transport.receiveMessageBuffer.get(dest, off, canRead);
        return canRead;
    }
    
    /**
     * Can't be completely certain how many bytes we can read past
     * a message boundary so this will return only the number this
     * actually knows about.
     * 
     * @see java.io.InputStream#available()
     */
    @Override
    public int available() throws IOException {
        
        return transport.receiveMessageBuffer.remaining();
    }
    
    /**
     * Keeps the socket open for sometime in case it is needed again.
     */
    @Override
    public void close() throws IOException {
        transport.close();
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
     * Gets the size of the message and checks for exceptions and reads the
     * message chunk.
     * 
     * @throws IOException
     */
    private void readMessage() throws IOException {
        if (transport.receiveMessageBuffer.hasRemaining()) {
            return;
        }
        transport.receiveMessage(true);
       
    }

}
