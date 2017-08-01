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

import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/*
 * This class reads files containing CCSDS packets,
 * and writes out a version of the Storage Correlation Table
 * that will allow VcduPacker to run in batches.
 * 
 * Example:
 * 
 * File ccsds.0-95.dat contains one day's worth of packetized cadences.
 * Each packet is 16636 bytes long, but the number of packets will
 * vary according to Huffman compression.
 * Let's say file ccsds.0-95.dat is 12,000,800 bytes long.
 * These bytes will be divided into 1107 byte chunks for VCDUs.
 *		12,000,800 / 1107 = 10840 VCDUs
 *		1107 * 10840 = 11,999,880 bytes, leaving 920 left over.
 * So when VcduPacker runs, it will read file ccsds.0-95.dat
 * and create the file vcdu.0-10839.dat with 10840 VCDUs containing all but
 * the final 920 bytes of ccsds.0-95.dat.
 * These final 920 bytes of ccsds.0-95.dat will go into 
 * the first VCDU packet in the 2nd VCDU output file.
 * 
 * The next CCSDS file is ccsds.96-191.dat with 12,000,401 bytes.
 * This gives 10840 VCDUs with 421 bytes left over (12,000,401-11,999,880=521).
 * We already have 920 bytes that must go into this new VCDU output file,
 * and 920+521=1441 which is >1107, so this VCDU file will have 
 * an extra VCDU packet, or 10841, with 1441-1107=334 bytes left over.
 * So when VcduPacker runs, it will read file ccsds.96-191.dat
 * and create the file vcdu.10840-21680.dat with 10841 VCDUs containing all but
 * the final 334 bytes of ccsds.96-191.dat.
 * These final 334 bytes of ccsds.96-191.dat will go into 
 * the first VCDU packet in the 3rd VCDU output file.
 * 
 * This PacketMapper class builds a CCSDS-VCDU packet map
 * that will be used by the VcduPacker class.
 * Each instance of the VcduPacker class will be assigned to
 * operate upon a given ccsds.dat file,
 * and the map entry for that ccsds.dat file will tell it
 * how many bytes of the previous ccsds.dat file it must include
 * in the first VCDU.
 * 
 * The map entries are:
 *		<starting VCDU Packet Id>,<starting Cadence #>,<# bytes leftover from previous Cadence)
 * So in our example the map entries would be:
 *		0,0,0			VCDU Packet Id 0, 
 *						cadence 0 (file ccsds.0-95.dat),
 *						no left over bytes
 *		10840,96,920	VCDU Packet Id 10840,
 *						cadence 96 (file ccsds.96-191.dat),
 *						final 920 bytes of ccsds.0-95.dat go into VCDU #10840
 *		21681,192,754	VCDU Packet Id 21681,
 *						cadence 192 (file ccsds.192-287.dat),
 *						final 754 bytes of ccsds.96-191.dat go into VCDU #21681
 * 
 * By reading the map file,
 * one instance of VcduPacker can create vcdu.0-10839.dat
 * while another instance simultaneously creates vcdu.10840-21680.dat,
 * and another instance creates vcdu.21681-?????.dat.
 */

class PacketMapper {

	// Constants.

    // Science Data Buffer specs, FSGS-116 ICD 5.3.1.3 Figure 5.3.1-2
    static final int VCDU_DATA_ZONE_SIZE	= 1107;

	// Logging setup
    private static final Log log = LogFactory.getLog(PacketMapper.class);

	// main simply passes arguments to run()
    public static void main( String[] args ) throws Exception {

		if ( args.length != 3 ) {
	    	error( 
				"usage:  java PacketMapper\n" +
				"                inputDirPathname\n" +
				"                mapFilePath\n" +
				"                longCadencesPerInputFile\n" 
			);
	    	throw new Exception( "expecting 3 arguments, got " + args.length );
		}

		PacketMapper pm = new PacketMapper();
		pm.run(				    
									args[ 0],
									args[ 1],
				Integer.valueOf(	args[ 2] )
		);
    } // PacketMapper main


	/*
     * run() reads cadence files and generates the output file
     */
    public void run(	
			String  	inputDirPath,
			String  	mapFilePath,
			int			longCadencesPerInputFile
	) throws Exception {

		try {
			File inputDir = new File( inputDirPath );
			if ( ! inputDir.exists() ) {
				throw new Exception( "missing input dir:" + inputDirPath );
			}
			
			BufferedWriter mapFile = new BufferedWriter( 
										new FileWriter( mapFilePath ) );

			String ccsdsFilename = null;
			String prevCcsdsFilename;
			int startCadence  = 0;
			int endCadence    = longCadencesPerInputFile - 1;
			File input;
			long inLength;

			String vcduFilename;
			long numVcdusInVcduFile = 0;
			long prevTotalVcdus = 0;
			long newTotalVcdus = 0;
			long numLeftoverBytesFromPreviousCcsds = 0;
			long numLeftoverBytesInCurrentCcsds = 0;
			long totalExcessBytes = 0;

			String mapEntry = null;
			
			while (	true ) {
				prevCcsdsFilename = ccsdsFilename;
				ccsdsFilename = "ccsds." + 
								startCadence + "-" + endCadence + ".dat";
				input = new File(	inputDir, ccsdsFilename );
				if ( ! input.exists() ) {
					// the final ccsds file may contain a shortened range,
					// e.g.		ccsds.0-95.dat		(96)
					//			ccsds.96-191.dat	(96)
					//			ccsds.192-199.dat	(only 8)
					// so when  ccsds.192-287.dat isn't found, we search for
					//			ccsds.192-193.dat
					//			ccsds.192-194.dat
					//			...
					// until we find the final file or we count through 
					// the range of possibilities.
					for ( int i = startCadence + 1;
							i < startCadence + longCadencesPerInputFile;
							i++ ) {
						ccsdsFilename = "ccsds." + 
								startCadence + "-" + i + ".dat";
						input = new File(	inputDir, ccsdsFilename );
						if ( input.exists() ) {
							// found e.g. ccsds.192-199.dat
							break;
						}
					}
					if ( input.exists() ) {
						// we process it, and go around one more time
						// to discover it was the last one
					} else {
						// didn't find a file, so we exit the loop
						// where we touch up the final map entry
						break;
					}
				}

				// write out the previous map entry.
				// the final map entry will be written after the loop.
				if ( null != mapEntry ) {
					mapFile.write( mapEntry + "\n" );
				}

				prevTotalVcdus = newTotalVcdus;

				numLeftoverBytesFromPreviousCcsds = 
					numLeftoverBytesInCurrentCcsds;

				inLength = input.length();

				numVcdusInVcduFile = inLength / VCDU_DATA_ZONE_SIZE;
				numLeftoverBytesInCurrentCcsds = 
					inLength - 
					( numVcdusInVcduFile * VCDU_DATA_ZONE_SIZE );
				totalExcessBytes = 
					numLeftoverBytesInCurrentCcsds + 
					numLeftoverBytesFromPreviousCcsds;

				if ( totalExcessBytes > VCDU_DATA_ZONE_SIZE ) {
					numVcdusInVcduFile++;
					totalExcessBytes -= VCDU_DATA_ZONE_SIZE;
					numLeftoverBytesInCurrentCcsds = totalExcessBytes;
				}

				newTotalVcdus = prevTotalVcdus + numVcdusInVcduFile;
					
				mapEntry =	prevTotalVcdus + "," + 
							startCadence + "," + 
							numLeftoverBytesFromPreviousCcsds;
/*
				mapEntry =	"vcdu." + 
							prevTotalVcdus + "-" + ( newTotalVcdus - 1 ) +
							".dat," + 
							ccsdsFilename + "," +
							numLeftoverBytesFromPreviousCcsds;
*/

				startCadence += longCadencesPerInputFile;
				endCadence   += longCadencesPerInputFile;
			}

			// reset the final map entry to indicate final vcdu file 
			// should contain as many VCDUs as needed.
			// The last VCDU will have its data zone padded,
			// and will be followed by another VCDU with a data zone
			// containing a special end-of-stream pattern.
			mapEntry =	prevTotalVcdus + "," + 
						( startCadence - longCadencesPerInputFile ) + "," + 
						numLeftoverBytesFromPreviousCcsds;

			mapFile.write( mapEntry + "\n" );

			mapFile.close();

		} catch ( Exception e ) {
	    	error( "PacketMapper failed" );
	    	e.printStackTrace();
	    	throw e;
		}

/*
		try {
			SctCatenater sctCat = new SctCatenater();
			sctCat.run(	inputDirPath,
						inputDirPath + "/sct.complete.dat",
						longCadencesPerInputFile );
		} catch ( Exception e ) {
			throw new Exception( "PacketMapper: error running SctCatenater" );
		}
*/
		

    } // PacketMapper run

	public static void debug( String s ) {
		log.debug(s);
//		System.out.println( s );
	}

	public static void status( String s ) {
		log.info(s);
//		System.out.println( s );
	}

	public static void error( String s ) {
		log.error(s);
//		System.out.println( s );
	}

} // class PacketMapper
