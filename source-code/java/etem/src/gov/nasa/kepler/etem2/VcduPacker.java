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

import gov.nasa.spiffy.common.collect.Pair;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.DataOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.math.BigInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

//import static gov.nasa.kepler.etem2.DataSetPacker.CCSDS_OUTPUT_FILENAME;
//import static gov.nasa.kepler.etem2.DataSetPacker.MOC_DMC_FILE_EXTENSIONS;
//import static gov.nasa.kepler.etem2.DataSetPacker.CCSDS_ENCODED_PACKET_TYPES;
//import static gov.nasa.kepler.etem2.DataSetPacker.SCB;
//import static gov.nasa.kepler.etem2.DataSetPacker.SCR;
//import static gov.nasa.kepler.etem2.DataSetPacker.SCS;
//import static gov.nasa.kepler.etem2.DataSetPacker.LCB;
//import static gov.nasa.kepler.etem2.DataSetPacker.LCR;
//import static gov.nasa.kepler.etem2.DataSetPacker.LCS;

//import static gov.nasa.kepler.etem2.DataSetPacker.LC_APP_ID;
//import static gov.nasa.kepler.etem2.DataSetPacker.LC_PKT_ID_BASELINE;
//import static gov.nasa.kepler.etem2.DataSetPacker.LC_PKT_ID_RESIDUAL_BASELINE;
//import static gov.nasa.kepler.etem2.DataSetPacker.LC_PKT_ID_ENCODED;
//import static gov.nasa.kepler.etem2.DataSetPacker.LC_PKT_ID_RAW;
//import static gov.nasa.kepler.etem2.DataSetPacker.LC_PKT_ID_REQUANTIZED;
//import static gov.nasa.kepler.etem2.DataSetPacker.SC_APP_ID;
//import static gov.nasa.kepler.etem2.DataSetPacker.SC_PKT_ID_BASELINE;
//import static gov.nasa.kepler.etem2.DataSetPacker.SC_PKT_ID_RESIDUAL_BASELINE;
//import static gov.nasa.kepler.etem2.DataSetPacker.SC_PKT_ID_ENCODED;
//import static gov.nasa.kepler.etem2.DataSetPacker.SC_PKT_ID_RAW;
//import static gov.nasa.kepler.etem2.DataSetPacker.SC_PKT_ID_REQUANTIZED;
//import static gov.nasa.kepler.etem2.DataSetPacker.FFI_APP_ID;
//import static gov.nasa.kepler.etem2.DataSetPacker.FFI_PKT_ID_BASE_NUM_PER_MODULE;

/*
 * This class reads one or more files containing CCSDS packets, breaks them into
 * chunks of 1107 bytes, and writes a file containing VCDUs (Virtual Channel
 * Data Unit). A list of start-times and end-times indicate which segments of
 * the input stream to process.
 * 
 * FSGS-116 5.3.3 Figure 5.3.3-1 describes CADU construction. A CADU is a 4 byte
 * Synch Marker followed by a VCDU. A VCDU consists of a Primary Header, an
 * M_PDU Header, 1107 bytes of data called in an M_PDU Packet Data Zone,
 * followed by 160 bytes of VCDU Error Control (Reed-Solomon). The 160 bytes of
 * Reed-Solomon code are added by another program.
 */

public class VcduPacker {

    public static final String VCDU_OUTPUT_FILENAME = "vcdu.dat";
    public static final int ANY_TYPE = -1;
    public static final int ANY_TIME = -1;

    // Constants.
    private final static String NEXT_ID_FILENAME = "vcdu.nextId.txt";

    // VCDU Data Zone size, FSGS-116 ICD 5.3.1.3 Figure 5.3.1-2
    static final int PAYLOAD_BYTES = 1107;
    static final int CCSDS_PACKET_BYTES = 16380;

    // negative values used to indicate status of header position
    // within final VCDUs
    static final int NO_FIRST_HEADER_POINTER = -1;
    private static final int IDLE_PACKET = -2;

    // Logging setup
    static final Log log = LogFactory.getLog(VcduPacker.class);

    private AbstractCcsdsReader ccsdsReader;
    private String prevRunOutputDirPath;
    private String outputDirPath;
    private int channel;
    
    private byte[] vcduDataZone = new byte[PAYLOAD_BYTES];
    private int vcduCounter = 0;
    private DataOutputStream vcduOutput;

    private File nextIdFile;

    private boolean channel15 = false;

    // main() provides a way to test this class using a shell script
    public static void main(String[] args) throws Exception {

        Logger logger = Logger.getLogger(VcduPacker.class);
        logger.setLevel(Level.INFO);
        org.apache.log4j.BasicConfigurator.configure();
        
        /*
        log.info("Date1=" + VtcFormat.toDateString((new Double("2.90584802544768E8")).doubleValue()));
        log.info("date2=" + VtcFormat.toDateString( new Double("2.9058303808000034E8")));
        
        double inputStart =2.9058303808000034E8;
        int upper = VtcFormat.getUpperBytes(inputStart);
        //upper = 255;
        log.info("upper as int = " + upper + " = " + Integer.toHexString(upper));
        byte[] b = VtcFormat.intToBytes(upper);
        int x = VtcFormat.bytesToInt(b);
        log.info("upper as int again = " + x + " = " + Integer.toHexString(x));
        byte lower = VtcFormat.getLowerByte(inputStart);
        double d = VtcFormat.bytesToDouble(b[0], b[1], b[2], b[3], lower);
        log.info("d="+d);
        log.info("date3=" + VtcFormat.toDateString( new Double(d)));
        
        GregorianCalendar g = new GregorianCalendar(2009,3,17,30,04);
        long ll = g.getTimeInMillis();
        log.info("ll="+ll);
        */
        
        VcduPacker vp = null;
       
        int i = 0;
        
        if ( "vtc".equals(args[i++])) {
            String[] inputCcsdsFilenames = args[i++].split(",");
            String prevRunOutputDir = args[i++];
            String outputDir = args[i++];
            int channel = Integer.parseInt( args[i++] );
            
            Pair<Double, Double> startEndTime = Pair.of(new Double(args[i++]),
                new Double(args[i++]));
            //Pair<Double,Double>[] startEndTimes2 = { startEndTime };
            @SuppressWarnings("unchecked")
            Pair<Double,Double>[] startEndTimes = new Pair[1];
            startEndTimes[0] = startEndTime;
            
            vp = new VcduPacker(
                inputCcsdsFilenames,
                prevRunOutputDir,
                outputDir,
                channel,
                59.3,
                30,
                startEndTimes);
        } else { // long cadence periods
            String datasetRootDir = args[i++];
            String inputSpecs = args[i++];
            String prevRunOutputDir = args[i++];
            String outputDir = args[i++];
            int channel = Integer.parseInt( args[i++] );
            
            vp = new VcduPacker(
                datasetRootDir, 
                inputSpecs,
                prevRunOutputDir,
                outputDir,
                channel);
        }
        
        vp.makeVcdus();
    }

    /**
     * Construct a VcduPacker instance that reads from one or more
     * ccsds.dat files extracting data between a list of start/end times.
     * @param inputCcsdsFilenames array of full pathnames
     * @param prevRunOutputDirPath value of outputDirPath on the previous run (allows VcduPacker to find the vcdu.nextId.dat file)
     * @param outputDirPath where to put the vcdu.dat file
     * @param channel 14 or 15
     * @param secsPerShortCadence usually 59.xxx
     * @param shortCadencesPerLongCadence usually 30
     * @param startEndTimes array of Pairs of Doubles, .left is start and .right is end
     * @throws Exception
     */
    public VcduPacker(String[] inputCcsdsFilenames,
        String prevRunOutputDirPath, String outputDirPath, int channel,
        double secsPerShortCadence,
        int shortCadencesPerLongCadence,
        Pair<Double, Double>[] startEndTimes
    ) throws Exception {
        ccsdsReader = new CcsdsReaderByVtc(
            inputCcsdsFilenames,
            secsPerShortCadence,
            shortCadencesPerLongCadence,
            startEndTimes
        );
        this.prevRunOutputDirPath = prevRunOutputDirPath;
        this.outputDirPath = outputDirPath;
        this.channel = channel;
    }

    /**
     * Construct a VcduPacker instance that reads from one or more
     * ccsds.dat files extracting data between specified long cadence periods.
     * @param datasetRootDir dir just above "p1/"
     * @param inputSpecs e.g. p1:0-7,p2,p3:55-END
     * @param prevRunOutputDirPath value of outputDirPath on the previous run (allows VcduPacker to find the vcdu.nextId.dat file)
     * @param outputDirPath where to put the vcdu.dat file
     * @param channel 14 or 15
     * @throws Exception
     */
    public VcduPacker(String datasetRootDir, String inputSpecs,
        String prevRunOutputDirPath, String outputDirPath, int channel
    ) throws Exception {
        ccsdsReader = new CcsdsReaderByLcPeriod( datasetRootDir, inputSpecs );
        this.prevRunOutputDirPath = prevRunOutputDirPath;
        this.outputDirPath = outputDirPath;
        this.channel = channel;
    }

    private void init() throws Exception {
        String err = "";
 
        log.info("prevRunOutputDirPath=" + prevRunOutputDirPath);
        log.info("outputDirPath=" + outputDirPath);
        log.info("channel=" + channel);
    
        File outDir = new File(outputDirPath);
        if (!outDir.exists()) {
            log.info("creating output directory " + outputDirPath);
            outDir.mkdirs();
        }

        vcduCounter = 0;
        if (prevRunOutputDirPath != null && prevRunOutputDirPath.length() > 0) {
            nextIdFile = new File(prevRunOutputDirPath, NEXT_ID_FILENAME);
            if (!nextIdFile.exists()) {
                err += "Missing file: " + prevRunOutputDirPath + "/"
                    + NEXT_ID_FILENAME + "\n";
            }

            BufferedReader r = new BufferedReader(new FileReader(nextIdFile));
            String vcduPacketIdAddValue = r.readLine();
            String vcduPrevRunVirtualChannel = r.readLine();
            r.close();

            log.info("vcduPrevRunVirtualChannel=" + vcduPrevRunVirtualChannel
                + ", vcduPacketIdAddValue=" + vcduPacketIdAddValue);

            try {
                if (channel == Integer.valueOf(vcduPrevRunVirtualChannel)) {
                    vcduCounter = Integer.valueOf(vcduPacketIdAddValue);
                } else {
                    log.info("current channel(" + channel
                        + ") != prev channel(" + vcduPrevRunVirtualChannel
                        + "): not using vcduPacketIdAddValue("
                        + vcduPacketIdAddValue + "), vcduCounter is set to 0");
                }
            } catch (Exception e) {
                throw new Exception(
                    "VcduPacker failed to set vcduCounter, non-Integer value. ");
            }
        } else {
            log.info("prevRunOutputDirPath is unset, not looking for "
                + NEXT_ID_FILENAME);
            log.info("vcduCounter will start at 0");
        }

        log.info("vcduCounter = " + vcduCounter);

        channel15 = (channel == 15);

    } // init

    public void makeVcdus() throws Exception {
        init();

        String vcduFilename = VCDU_OUTPUT_FILENAME;

        File vcduFile = new File(outputDirPath, vcduFilename);
        vcduOutput = new DataOutputStream(new BufferedOutputStream(
            new FileOutputStream(vcduFile)));
        
        int got = 0;
        while (true) {
            got = ccsdsReader.readBytes(vcduDataZone);
            if (got != PAYLOAD_BYTES || ccsdsReader.doneProcessing ) {
                log.info("got="+got+", done="+ccsdsReader.doneProcessing);
                // insufficient data to write another VCDU frame
                break;
            }
            writeVcdu(vcduOutput, ccsdsReader.getFirstHeaderPointer(),
                vcduDataZone, PAYLOAD_BYTES);
        }
        writeFinalVcdus(got);
        vcduOutput.close();

        // write out the next VCDU number to use.
        // NOTE: this number is also findable as the first value
        // on the next line in the map file, but that is harder for
        // the pipeline to extract.
        try {
            BufferedWriter w = new BufferedWriter(new FileWriter(new File(
                outputDirPath, NEXT_ID_FILENAME)));
            w.write("" + vcduCounter + "\n");
            w.write("" + channel);
            w.close();
        } catch (Exception e) {
            e.printStackTrace();
            throw new Exception(
                "VcduPacker failed to write VCDU counter to file "
                    + outputDirPath + "/" + NEXT_ID_FILENAME);
        }
        log.info("VcduPacker done.");
    } // makeVcdus

    private void writeFinalVcdus(int gotBytes) throws Exception {
        log.info("Writing final data packet");
        // this is the final VCDU file.
        // it will contain the final CCSDS file data, padded if necessary.
        // it will also contain an "idle" packet, also padded.

        // CCSDS Idle packet header
        // per doc CCSDS 701.0-B-3 section 5.3.8.2.2.3.b, p.5-30
        int CCSDS_HEADER_LEAD = 0x07FFC000;
        int CCSDS_HEADER_SIZE = 6;

        int partialPayloadPlusIdlePacketHeader = gotBytes + CCSDS_HEADER_SIZE;
        // System.out.println( "gotBytes ='" + gotBytes + "'" );
        // System.out.println( "partialPayloadPlusIdlePacketHeader ='" +
        // partialPayloadPlusIdlePacketHeader + "'" );
        // System.out.println( "firstHeaderPointer ='" + firstHeaderPointer +
        // "'" );

        int ccsdsIdlePacketLength;

        if (partialPayloadPlusIdlePacketHeader < PAYLOAD_BYTES) {
            // CCSDS Idle Packet Header fits inside last VCDU frame.
            // Next is the final VCDU frame on channel 17, all 0x5A's.
            ccsdsIdlePacketLength = (PAYLOAD_BYTES - partialPayloadPlusIdlePacketHeader)
                + PAYLOAD_BYTES;
        } else {
            // CCSDS Idle Packet Header does not fit in last VCDU frame.
            // Next VCDU frame is still channel 14 and contains
            // the remainder of the CCSDS Idle Packet Header and 0x5A's.
            // Then, the final VCDU frame is channel 17 and has all 0x5A's.
            ccsdsIdlePacketLength = PAYLOAD_BYTES
                - (partialPayloadPlusIdlePacketHeader - PAYLOAD_BYTES)
                + PAYLOAD_BYTES;
            // or 3 * PAYLOAD_BYTES - partialPayloadPlusIdlePacketHeader
        }
        // System.out.println( "ccsdsIdlePacketLength ='" +
        // ccsdsIdlePacketLength + "'" );
        log.info("VcduPacker: partialPayloadPlusIdlePacketHeader="
            + partialPayloadPlusIdlePacketHeader);
        log.info("VcduPacker: ccsdsIdlePacketLength=" + ccsdsIdlePacketLength);

        // create CCSDS Idle Packet Header byte array
        BigInteger bi = new BigInteger("" + CCSDS_HEADER_LEAD);
        byte[] headerLeadBytes = bi.toByteArray();
        if (4 != headerLeadBytes.length) {
            log.error("VcduPacker: headerLeadBytes.length="
                + headerLeadBytes.length + ", CCSDS_HEADER_LEAD="
                + CCSDS_HEADER_LEAD);
        }
        bi = new BigInteger("" + ccsdsIdlePacketLength);
        byte[] packetLengthBytes = bi.toByteArray();
        if (2 != packetLengthBytes.length) {
            log.error("VcduPacker: packetLengthBytes.length="
                + packetLengthBytes.length + ", ccsdsIdlePacketLength="
                + ccsdsIdlePacketLength);
        }
        byte[] headerBytes = new byte[CCSDS_HEADER_SIZE];
        headerBytes[0] = headerLeadBytes[0];
        headerBytes[1] = headerLeadBytes[1];
        headerBytes[2] = headerLeadBytes[2];
        headerBytes[3] = headerLeadBytes[3];
        headerBytes[4] = packetLengthBytes[0];
        headerBytes[5] = packetLengthBytes[1];

        int i, j;

        // some, perhaps all, of CCSDS Idle Packet Header will fit
        // in last VCDU frame containing real data
        for (i = 0, j = gotBytes; i < CCSDS_HEADER_SIZE && 0 < j
            && j < PAYLOAD_BYTES; i++, j++) {
            vcduDataZone[j] = headerBytes[i];
            // int x = headerBytes[ i ];
            // x = x << 24;
            // x = x >>> 24;
            // String s = Integer.toHexString( x );
            // System.out.println( "headerBytes["+ i +"]='" + headerBytes[ i ] +
            // " = " + s);
        }
        // System.out.println( "i ='" + i + "'" );
        // System.out.println( "j='" + j + "'" );
        // if all of the CCSDS Idle Packet Header fit, pad VCDU
        for (; 0 < j && j < PAYLOAD_BYTES; j++) {
            vcduDataZone[j] = (byte) 0x5A;
        }
        // System.out.println( "j ='" + j + "'" );
        writeVcdu(vcduOutput, gotBytes, vcduDataZone, PAYLOAD_BYTES);

        if (partialPayloadPlusIdlePacketHeader > PAYLOAD_BYTES) {
            // The final VCDU containing real data did not have enough
            // room for the whole CCSDS Idle Packet Header.
            // Create a new VCDU to hold
            // the rest of the CCSDS Idle Packet Header.
            // After header, pad that VCDU and write it out.
            for (j = 0; i < CCSDS_HEADER_SIZE && j < PAYLOAD_BYTES; j++, i++) {
                vcduDataZone[j] = headerBytes[i];
            }
            for (; j < PAYLOAD_BYTES; j++) {
                vcduDataZone[j] = (byte) 0x5A;
            }
            writeVcdu(vcduOutput, PAYLOAD_BYTES, vcduDataZone, PAYLOAD_BYTES);
        }

        // create final VCDU, all padding
        for (j = 0; j < PAYLOAD_BYTES; j++) {
            vcduDataZone[j] = (byte) 0x5A;
        }
        // write out final VCDU
        writeVcdu(vcduOutput, IDLE_PACKET, vcduDataZone, PAYLOAD_BYTES);
    } // writeFinalVcdus

    /*
     * writeVcdu emits the Primary and M_PDU headers, and writes out the
     * finished VCDU.
     */
    public void writeVcdu(DataOutputStream vcduOutput, int firstHeaderPointer,
        byte[] buf, int len) throws Exception {
        log.debug("Writing VCDU #" + vcduCounter);
        // log.debug( "firstHeaderPointer ='" + firstHeaderPointer + "'" );

        // FSGS-116 ICD Table 5.3.3-2 p.84 Ka-Band CADU Content

        // int header1 = 0x1ACFFC1D; // synchMarker

        // version#(2 bits)
        // 01
        // craftId(8 bits)=0xE6 (sim, Table 5.2.1-4 p.24 says 0xE3 for flight)
        // 11100110
        // virtual channel id(6 bits)=0xE (Table 5.3.5-1 p.91)
        // 001110
        // all together: 0111100110001110
        // or 0111 1001 1000 1110
        // or 0x798E
        short header2 = 0x798E;
        if (channel15) {
            header2 = 0x798F;
        }

        /*
         * if ( IDLE_PACKET == firstHeaderPointer ) { // Final Idle packet goes
         * on Channel 17 (0x11) // virtual channel id(6 bits)=0x11 // 010001 //
         * all together: 0111100011010001 header2 = 0x78D1; }
         */

        // TODO use printInt to check the results of these byte casts.
        // 
        // lower 24 bits of vcduCounter
        int pktNum = vcduCounter;
        byte counter3 = (byte) (pktNum & 0xFF);
        pktNum = pktNum >>> 8;
        byte counter2 = (byte) (pktNum & 0xFF);
        pktNum = pktNum >>> 8;
        byte counter1 = (byte) (pktNum & 0xFF);

        // signalling field(8 bits), high bit is replay flag=1
        byte signallingField = (byte) 0x80;

        // M_PDU header(16 bits), lower 11 bits are firstHeaderPointer
        short m_pdu = (short) firstHeaderPointer;
        if (NO_FIRST_HEADER_POINTER == firstHeaderPointer) {
            // CCSDS document (see Jon Jenkins) 701.0-B-3 p.5-29
            // if a CCSCS header does not begin within the VCDU data zone,
            // the value of the First Header Pointer field shall be
            // 111 1111 1111
            m_pdu = 0x7FF;
        } else if (IDLE_PACKET == firstHeaderPointer) {
            // 111 1111 1110
            m_pdu = 0x7FE;
        } else if (firstHeaderPointer > PAYLOAD_BYTES || firstHeaderPointer < 0) {
            /*
             * TODO: hack to fix two cases (packet #'s 11416 and 202356) where
             * firstHeaderPointer was negative. This occured in the packet
             * immediately following a packet containing 2 ccsds headers
             * surrounding a very small partial ccsds payload.
             */
            log.info("firstHeaderPointer=" + firstHeaderPointer
                + " < 0, vcduCounter=" + this.vcduCounter);
            m_pdu = NO_FIRST_HEADER_POINTER;
        }

        if (false) {
            System.out.println("ver#(2 bits)=01, craftId(8bits)=0xE3, vchanId(6 bits)=0xE\n         "
                + DataSetPacker.getBits(header2, 32768));
            System.out.println("1st byte of vcduCounter: "
                + DataSetPacker.getBits(counter1, 128));
            System.out.println("2nd byte of vcduCounter: "
                + DataSetPacker.getBits(counter2, 128));
            System.out.println("3rd byte of vcduCounter: "
                + DataSetPacker.getBits(counter3, 128));
            System.out.println("signalling field:      "
                + DataSetPacker.getBits(signallingField, 128));
            System.out.println("M_PDU:  lower 11 bits are First Header Pointer: "
                + DataSetPacker.getBits(m_pdu, 32768));
        }

        // Jon Jenkin's CADU-maker adds the Synch Marker, so don't output that.
        // vcduOutput.writeInt( header1 );

        vcduOutput.writeShort(header2);
        vcduOutput.writeByte(counter1);
        vcduOutput.writeByte(counter2);
        vcduOutput.writeByte(counter3);
        vcduOutput.writeByte(signallingField);
        vcduOutput.writeShort(m_pdu);

        // write out the M_PDU Packet Data Zone
        for (int i = 0; i < PAYLOAD_BYTES; i++) {
            vcduOutput.writeByte(buf[i]);
        }

        // if ( IDLE_PACKET != firstHeaderPointer ) {
        incrementVcduCounter();
        // }
    } // writeVcdu

    private void incrementVcduCounter() {
        vcduCounter++;
        if (vcduCounter >= 16777216) {
            // vcduCounter >= 2^24 so has overflowed 24 bits
            vcduCounter = 0;
        }
    }
} // class VcduPacker
