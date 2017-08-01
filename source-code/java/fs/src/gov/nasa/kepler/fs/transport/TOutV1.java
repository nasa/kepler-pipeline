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

import static gov.nasa.kepler.fs.transport.TransportConstantsV1.MAX_MESSAGE_SIZE;

import java.io.IOException;
import java.io.ObjectOutputStream;
import java.io.OutputStream;
import java.net.SocketTimeoutException;

/**
 * Transport output stream.
 * 
 * @author Sean McCauliff
 *
 */
class TOutV1 extends OutputStream {

    private final OutputStream sos;

    private final TransportV1 transport;
    
    
    
    /**
     * 
     * @param sos
     * @param transport
     */
    TOutV1(OutputStream sos, TransportV1 transport) {
        this.sos = sos;
        this.transport = transport;
    }
    
    @Override
    public void write(int b) throws IOException {
        startMessage(1);
        
        sos.write(b);
        
    }
    
    
    @Override
    public void write(byte[] b, int off, int len) throws IOException {
        while (len > 0) {
            int messageSize = Math.min(len, MAX_MESSAGE_SIZE);
            startMessage(messageSize);
            sos.write(b, off, messageSize);
            len -= messageSize;
            off += messageSize;
        }
    }
    
    @Override
    public void flush() throws IOException {
        sos.flush();
    }
    
    @Override
    public void close() throws IOException {
        flush();
    }

    void sendThrowable(Throwable t) throws IOException {
        writeBoolean(true);
        
        ObjectOutputStream oos = new ObjectOutputStream(sos) {
            public void close() {
                //This must not close the socket output stream on close()
            }
        };
        
        oos.writeObject(t);
        oos.flush();
        
        if (transport.expectedBytes() > 0) {
            transport.skipExpectedBytes();
        }
    }
    
    void startMessage(int messageSize) throws IOException {
        try {
            writeBoolean(false);
            writeInt(messageSize);
        } catch (SocketTimeoutException ste) {
            //Likely something has corrupted the protocol  Close the connection
            transport.close();
            throw ste;
        }
    }
    
    private void writeInt(int i) throws IOException {
        sos.write(i >> 24);
        sos.write(i >> 16);
        sos.write(i >>    8);
        sos.write(i);
    }
    
    private void writeBoolean(boolean b) throws IOException {
        if (b) {
            sos.write(1);
        } else {
            sos.write(0);
        }
    }
}
