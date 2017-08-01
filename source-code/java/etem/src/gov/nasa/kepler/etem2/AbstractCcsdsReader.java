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

package gov.nasa.kepler.etem2;

import static gov.nasa.kepler.etem2.VcduPacker.NO_FIRST_HEADER_POINTER;

import java.io.DataInputStream;

abstract public class AbstractCcsdsReader {

    /**
     * 
     */
    protected static final int CCSDS_HEADER_SIZE = 14;
    protected boolean hitEnd = false;
    public boolean doneProcessing = false;
    protected byte[] pkt = new byte[VcduPacker.CCSDS_PACKET_BYTES];
    protected int pktOffset = 0;
    private int pktIndex = 0;
    protected double pktVtc = 0;
    protected int pktLen = 0;
    protected int pktCount = 0;
    private int bytesRead = 0;
    protected boolean readingToEnd = false;
    protected int firstHeaderPointer = 0;
    protected DataInputStream ccsdsInput;
    protected int pktAppId;
    protected boolean repositioned = false;
    
    protected abstract void nextFile() throws Exception;
    
    protected void readHeader() throws Exception {
//        pktOffset = 0;
        int got = getBytes(CCSDS_HEADER_SIZE);
        if (hitEnd) {
            return;
        }
        if (got < CCSDS_HEADER_SIZE) {
            VcduPacker.log.info("got=" + got);
            throw new Exception("Could not read header from packet #"
                + pktCount);
        }

        pktAppId = pkt[1];
        // PktId is 100 (baseline), 101 (residual), 102 (encoded), 103
        // (raw), 104 (requantized)
//        int pktId = pkt[11];
        // pktType = new PacketType( pktAppId, pktId );
        
//VcduPacker.log.info("A="+pktAppId+", P="+pktId);

        // extract vtc from packet
        pktVtc = VtcFormat.bytesToDouble(pkt[6], pkt[7], pkt[8], pkt[9],
            pkt[10]);

        // extract 16 bit pktLen from packet
        int i = pkt[4];
        i = i << 24;
        i = i >>> 24;
        pktLen = i << 8;
        i = pkt[5];
        i = i << 24;
        i = i >>> 24;
        pktLen |= i;
        pktLen += 7; // pkt length in header is always 7 less than actual

        // log.debug("Packet #" + pktCount + " pkt type = " +
        // pktType.getName() + ", vtc=" + pktVtc + ", len=" + pktLen );
//        VcduPacker.log.debug("Packet #" + pktCount + ", vtc=" + pktVtc + ", len="
//            + pktLen);
    }
 

    protected void readPacket() throws Exception {
        pktOffset = 0;
        
        // If readHeader determines we have hit the end of a desired chunk of input,
        // it will call nextFile/findStart to reposition the input stream.
        // This process itself invokes readPacket, so findStart sets repositioned=true.
        readHeader();   
        
        if (hitEnd) {
            return;
        }
        if ( repositioned ) {
            // Do not continue to read.  
            // readHeader->nextFile->findStart->readPacket has already 
            // loaded the next desired packet into the pkt buffer.
            repositioned = false;
        } else {
            int bytesAfterHeader = pktLen - CCSDS_HEADER_SIZE;
        	int got = getBytes(bytesAfterHeader);
        	if (got < bytesAfterHeader) {
            	throw new Exception("Could not read " + bytesAfterHeader
                	+ " bytes after header from packet #" + pktCount + ", got "
                	+ got + " bytes instead.");
        	}
        }
        pktIndex = 0;
        pktCount++;
    }

    public int readBytes(byte[] frame) throws Exception {
        if (hitEnd) {
            throw new Exception(
                "Trying to read past end of desired packets.");
        }
    
        if (bytesRead == 0) {
            firstHeaderPointer = 0; // beginning of first CCSDS packet will
                                    // begin first VCDU frame
        } else {
            firstHeaderPointer = NO_FIRST_HEADER_POINTER;
        }
    
        int frameLen = frame.length;
        int frameIndex = 0;
    
        while (frameIndex < frameLen) {
            if (pktIndex >= pktLen) {
                repositioned = false;  // we have not just moved to a new input source
                readPacket();
                if (hitEnd) {
                    return frameIndex;
                }
                if (firstHeaderPointer == NO_FIRST_HEADER_POINTER) {
                    firstHeaderPointer = frameIndex;
                }
            }
    
            frame[frameIndex++] = pkt[pktIndex++];
            bytesRead++;
        }
    
        return frameLen;
    }

    public int getFirstHeaderPointer() {
        return firstHeaderPointer;
    }

    protected int getBytes(int numBytes) throws Exception {
//VcduPacker.log.info("getBytes pktOffset="+ pktOffset+", numBytes="+numBytes);
        if ( pktOffset == 16380 ) {
            numBytes = numBytes + 0;
        }
        int got = ccsdsInput.read(pkt, pktOffset, numBytes);
        if (got == -1) {
            nextFile();
            got = ccsdsInput.read(pkt, pktOffset, numBytes);
        }
        pktOffset += numBytes;
        // caller checks what we got
        return got;
    }

}
