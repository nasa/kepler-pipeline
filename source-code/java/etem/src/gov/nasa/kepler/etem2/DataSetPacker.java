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

import gov.nasa.kepler.common.FcConstants;
import gov.nasa.kepler.hibernate.gar.CompressionCrud;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.EOFException;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FileWriter;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/*
 * This class reads cadence data files 
 * and generates an output file containing CCSDS packets.
 * (Data files are under flux:/path/to/etem2/auto/{short,long}/merged)
 *
 * A Data Set (FSGS-116 5.3.1-2) is a series of CCSDS packets.
 * Each CCSDS packet has two telemetry source packet headers
 * followed by a Science Data Buffer.
 *
 * Each Science Data Buffer has a 16 byte header containing
 *		photometer config ID
 *		first pixel ID
 *		num pixels
 * followed by (possibly) Huffman encoded pixel data.
 *
 * Pixel values read from the cadences data files are 
 * index values from the quantization table.  
 * These index values are in the range of 0 through 2^16-1.
 *
 * For cadences establishing new baselines,
 * the pixel values are not Huffman encoded.
 *
 * Otherwise, the cadence values are subtracted
 * from the baseline pixel value at the same offset
 * to give the differenced (diffed) value, which may be negative.
 * The values then span the range of minus 2^16-1 through plus 2^16-1
 *  [-65535 through 65535] for a total of 2^17-1 values [131071] ).
 *
 * The pixel data can be 0 to 16350 bytes in blocks of 16.
 * Thus each Science Data Buffer will be between 16 and 16366 bytes long.
 *
 * To create Science Data Buffers, we read files containing 
 * Short Cadences and Long Cadences and FFIs.
 * All FFIs are chunked into CCSDS packets with no Huffman encoding.
 * All cadence files are Huffman encoded and then chunked into CCSDS packets.
 *
 * Some cadence files are baselines.  
 * An SC baseline is held in memory to allow subsequent SC index values
 * to be differenced (by numerical subtraction) before Huffman encoding.
 * Similarly, an LC baseline is held in memory to allow subsequent LC
 * index values to be differenced before Huffman encoding.
 *
 * The cadence files are read in this order (* = diffed against baseline):
 *  --- A) starting off:
 *	 1 SC  baseline (no "residual baseline because no previous baseline)
 *	29 SC* (diffed against the SC baseline)
 *	 1 LC  baseline (no "residual baseline because no previous baseline)
 *	30 SC* (diffed against the SC baseline)
 *	 1 LC* (diffed against the LC baseline) 
 *	----B) for subsequent days we process residual baselines
 *	 1 SC* baseline "residual" (diffed against prev SC baseline)
 *	 1 SC  baseline (reprocess same SC cadence to produce new SC baseline,
 *                  not diffed against prev SC baseline)
 *	29 SC* (diffed against the SC baseline)
 *	 1 LC* baseline "residual" (diffed against prev LC baseline)
 *	 1 LC  baseline (reprocess same LC cadence to produce new LC baseline,
 *                  not diffed against prev LC baseline)
 *	30 SC* (diffed against the SC baseline)
 *	----C) repeating from (B) through the chosen number of days
 * 
 * To perform Huffman encoding,
 * we read a file containing a Huffman coding table
 * prepared in MatLab code developed by Hema.
 * Each line in the file contains a binary code value expressed 
 * as an ASCII string of '1' and '0' characters.
 * The lines are in order of the index values; the first line
 * contains the Huffman code for the index value 0, 
 * the second line contains the code for the index value 1, and so forth.
 *
 * NOTE:  It may make sense to have this class also divide the generated
 * CCSDS packet stream into VCDU chunks.
 */

class DataSetPacker {

	// Constants.

	// primitive boundaries
    static final int	TWO_16			= 65536;
    static final int	TWO_16_minus_1	= TWO_16 - 1;
    static final long	TWO_31			= 2147483648L;

	// Java sizes
    static final int BITS_PER_BYTE  = Byte.SIZE;						// 8
    static final int BITS_PER_SHORT	= Short.SIZE;						// 16
    static final int BITS_PER_INT  	= Integer.SIZE;						// 32
    static final int BYTES_PER_SHORT= BITS_PER_SHORT / BITS_PER_BYTE;	// 2
    static final int BYTES_PER_INT	= BITS_PER_INT   / BITS_PER_BYTE;	// 4

    // Science Data Buffer specs, FSGS-116 ICD 5.3.1.3 Figure 5.3.1-2
    static final short	SCIENCE_DATA_HEADER_SIZE						= 16;
    static final int	PAYLOAD_BYTES									= 16350;
	// To create the payload of 16350 bytes, we use an array of 4088 ints.
	// 4088 * BYTES_PER_INT = 16352
    static final int	BUFFER_INTS	= 4088;

    // CCSDS Packet Header specs, FSGS-116 ICD 5.3.3 Figure 5.3.3-1
    static final short TELEMETRY_SOURCE_PACKET_PRIMARY_HEADER_SIZE		= 6;
    static final short TELEMETRY_SOURCE_PACKET_SECONDARY_HEADER_SIZE	= 8;

    static final boolean	NOT_FINAL_PACKET	= false;
    static final boolean	FINAL_PACKET		= true;

	// Logging setup
    private static final Log log = LogFactory.getLog(DataSetPacker.class);

	// Science Data Set Application ID and Packet ID, FSGS-116 ICD 5.3.1.5
    static final byte FETCH_PREVIOUS_BASELINE		= -1;	// magic value
	// 		Long Cadence (per FG1295)
    static final byte LC_APP_ID						=  40;
    static final byte LC_PKT_ID_BASELINE			= 100;
    static final byte LC_PKT_ID_RESIDUAL_BASELINE	= 101;
    static final byte LC_PKT_ID_ENCODED				= 102;
    static final byte LC_PKT_ID_RAW					= 103;
    static final byte LC_PKT_ID_REQUANTIZED			= 104;
	// 		Short Cadence
    static final byte SC_APP_ID						=  41;
    static final byte SC_PKT_ID_BASELINE			= 100;
    static final byte SC_PKT_ID_RESIDUAL_BASELINE	= 101;
    static final byte SC_PKT_ID_ENCODED				= 102;
    static final byte SC_PKT_ID_RAW					= 103;
    static final byte SC_PKT_ID_REQUANTIZED			= 104;
	// 		FFI (per FG1296)
    static final byte FFI_APP_ID					=  42;
    static final byte FFI_PKT_ID_BASE_NUM_PER_MODULE= 100;
/*
    static final int[]  MODULE_NUMBERS = {       2,	 3,  4,
											 6,  7,  8,  9, 10, 
											11, 12, 13, 14, 15, 
											16, 17, 18, 19, 20, 
											    22, 23, 24 };
*/
	// FFI data set module  2, 			Packet ID 	= 102
	// ...
	// FFI data set module 24, 			Packet ID 	= 124

	// output simulating MOC to DMC files;
	// see MOC to DMC ICD section 3.3.1.3
    private DataOutputStream	mocDmcOutput;	// per data-type output files
    private String				mocDmcOutputExt;// file extension per data-type
    //public static final String[]	MOC_DMC_FILE_EXTENSIONS = new String[]{ "scb", "scr", "scs", "scX", "lcb", "lcr", "lcs", "lcX" };
    public static final String[]	MOC_DMC_FILE_EXTENSIONS = new String[]{ "scb", "scr", "scs", "lcb", "lcr", "lcs", "ffi" };
    public static final int 	SCB = 0;
	public static final int 	SCR = 1;
	public static final int 	SCS = 2;
	//public static final int 	SC_UNKNOWN = 3;
	public static final int 	LCB = 3;
	public static final int 	LCR = 4;
	public static final int 	LCS = 5;
	//public static final int 	LC_UNKNOWN = 7;
	public static final int 	FFI = 6;
	
    //public static final int			NUM_SHORT_LONG_TYPES = 8;
    public static final int			NUM_SHORT_LONG_TYPES = 6;
    public static final int			NUM_PKT_TYPES = 
									NUM_SHORT_LONG_TYPES + FcConstants.modulesList.length;
	
    public static final int[] 	CCSDS_ENCODED_PACKET_TYPES = new int[] {
        ( (int) SC_APP_ID << 8 ) | SC_PKT_ID_BASELINE,
        ( (int) SC_APP_ID << 8 ) | SC_PKT_ID_BASELINE,
    	( (int) SC_APP_ID << 8 ) | SC_PKT_ID_RESIDUAL_BASELINE,
    	( (int) SC_APP_ID << 8 ) | SC_PKT_ID_ENCODED,
    	( (int) LC_APP_ID << 8 ) | LC_PKT_ID_BASELINE,
    	( (int) LC_APP_ID << 8 ) | LC_PKT_ID_RESIDUAL_BASELINE,
    	( (int) LC_APP_ID << 8 ) | LC_PKT_ID_ENCODED,
    	( (int) FFI_APP_ID << 8 ) | ( FFI_PKT_ID_BASE_NUM_PER_MODULE + 2 )
    };
	
    /*
    public static final int 	SCB_TYPE_ENCODED = ( (int) SC_APP_ID << 8 ) | SC_PKT_ID_BASELINE;
	public static final int 	SCR_TYPE_ENCODED = ( (int) SC_APP_ID << 8 ) | SC_PKT_ID_RESIDUAL_BASELINE;
	public static final int 	SCS_TYPE_ENCODED = ( (int) SC_APP_ID << 8 ) | SC_PKT_ID_ENCODED;
	public static final int 	LCB_TYPE_ENCODED = ( (int) LC_APP_ID << 8 ) | LC_PKT_ID_BASELINE;
	public static final int 	LCR_TYPE_ENCODED = ( (int) LC_APP_ID << 8 ) | LC_PKT_ID_RESIDUAL_BASELINE;
	public static final int 	LCS_TYPE_ENCODED = ( (int) LC_APP_ID << 8 ) | LC_PKT_ID_ENCODED;
	*/

	// Most cadences are diffed (against the previous baseline)
	// and compressed (using Huffman table).
	// New baselines are neither diffed nor compressed.
	static final boolean DIFF_AND_COMPRESS = true;
	static final boolean NO_DIFF_NO_COMPRESS = false;

    static final short SEQ_FLAG_FIRST		= 0x6000;
    static final short SEQ_FLAG_MIDDLE		= 0x0000;
    static final short SEQ_FLAG_FINAL		= ( 0x800 << 1 );
    static final short SEQ_FLAG_UNSEGMENTED = ( 0xC00 << 2 );

    static final short SSR_OFFSET_UNIT_SIZE = 16;

	// DataSetPacker data members.

	// Per cadence counters
    private int startPixels = 0;
    private int numPixels = 0;

	// primary output files
    private DataOutputStream	output;			// CCSDS output file
    private DataOutputStream	sctOutput;		// Storage Correlation Table

	// output packets have packet ID numbers
    private short				perCadencePacketCount = 0;
	private short[]				packetSeqCounts;
	private int					packetSeqCountType;

	public static final			String CCSDS_OUTPUT_SUBDIR = "/ccsds/";
//	public static final			String CCSDS_DATA_FILENAME_PREFIX = "ccsds.";
	public static final			String CCSDS_OUTPUT_FILENAME = "ccsds.dat";
//	public static final			String PACKET_LENGTHS_FILENAME_PREFIX = "packet_lengths.";
	public static final			String PACKET_SEQ_COUNT_FILENAME = "packetSeqCounts.txt";

    //private BufferedWriter		packetLengthsOutput;
    private long				photometerConfigID;
    private HuffmanTable		huffTable;
	private double				vtc;
	private double				vtcInc;

	// each day we need a new short cadence baseline
	private boolean needNewShortBaseline	= true;
	// when we start we have no short cadence baseline
	private boolean havePrevShortBaseline	= false;
	// a baseline is an undiffed set of pixels from a cadence file
	private int[]	shortBaseline			= null;

	// each day we need a new long cadence baseline
	private boolean needNewLongBaseline		= true;
	// when we start we have no long cadence baseline
	private boolean havePrevLongBaseline	= false;
	// a baseline is an undiffed set of pixels from a cadence file
	private int[]	longBaseline			= null;

	// Flags to control runtime log output and other behavior.
	// Each flag is a single character added to the first parameter.
	private boolean babbleDebug				= false;	// 'd'
	private boolean babbleStatus			= false;	// 's'
	private boolean doBitPrinting			= false;	// 'b'
	private boolean doSctBitPrinting		= false;	// 'B'
		// 't':  disable packet generation (to see order of cadence processing)
	private boolean testBunching			= false;
		// '1':  stop at a single SC baseline (delivery to MOC, prelim testing)
	private boolean oneSC					= false;
		// 'F':  generate FFI output before processing any cadence files
	private boolean doingFFI				= false;
	private boolean onlyFFI					= false;

		// create a file for each Data Type listed in the MOC to DMC ICD,
		// table 5
	private boolean writeFilePerDataType	= false;	// 'p'
	private String	writtenTypes			= ".ffi.lcb.lcr.lcs.scb.scr.scs.";

	private String	prevRunOutputPath;
	private String	outputPath;
	private int		startingLongCadenceFileNumber;
	private int		numLongCadenceFilesToProcess;
	
	
	private boolean rawInput				= false;	// 'r'

		// 'H':  create output stream of '0' and '1' chars for Hema's testing
	private boolean dumpForHema				= false;
		// works with dumpForHema to limit output for Hema to one cadence
	private boolean oneForHemaToTest		= false;

	private String	packetLengths			= "";
	private String	comma					= "";

	private int		dataSetSize				= 0;

	// The offsets we write to the sct output file will be corrected
	// by the SctEntryCatenator class.
	private int		ssrOffset				= 0;
    
    // how many ccsds packets have we written?  For debugging
    private int ccsdsPacketCount = 0;

	private int scCounter = 0;

	// main() provides a way to test this class using a shell script
    public static void main(String[] args) throws Exception {

//		error( "Short.SIZE=" + Short.SIZE);
//		error( "args.length=" + args.length);
//		error( "SEQ_FLAG_FINAL  ='" + ((int)SEQ_FLAG_FINAL)   + "'" );
//		error( "TWO_31=" + TWO_31);
//System.out.println( "args.length='" + args.length + "'" );
		if ( args.length != 11 ) {
			System.err.println( 
				"usage:  java DataSetPacker\n" +
				"                babbleFlags\n" +
				"                inputDirPathname\n" +
				"                outputDirPath\n" +
				"                prevRunOutputDirPath\n" +
				"                numShortCadencesPerLongCadence\n" +
				"                numLongCadencesPerBaseline\n" +
				"                startingLongCadenceFileNumber\n" +
				"                numLongCadenceFilesToProcess\n" +
				"                photometerID\n" +
				"                vtcStart\n" +
				"                vtcIncrement\n"
			);
	    	throw new Exception( "bad arguments" );
		}

		Logger logger = Logger.getLogger(DataSetPacker.class);
		logger.setLevel( Level.WARN );
		org.apache.log4j.BasicConfigurator.configure();

		int i = 0;

		DataSetPacker dsp = new DataSetPacker();
		dsp.run(				    
									args[ i++ ],
									args[ i++ ],
									args[ i++ ],
									args[ i++ ],

				Integer.valueOf(    args[ i++ ] ),
				Integer.valueOf(    args[ i++ ] ),
				Integer.valueOf(    args[ i++ ] ),

				Integer.valueOf(    args[ i++ ] ),

						    		1,

				Long.valueOf(	    args[ i++ ] ),
				Double.valueOf(    	args[ i++ ] ),
				Double.valueOf(    	args[ i++ ] )
		);
    } // DataSetPacker main


	/*
     * run() reads cadence files and directs the generation of the output file
     */
    public void run(	
			String  	babbleFlags,
			String  	inputDirPath,
			String  	outputDirPath,
			String  	prevRunOutputDirPath,

			int			numShortCadencesPerLongCadence,

			int			numLongCadencesPerBaseline,
			int			startingLongCadenceFileNum,
			int			numLongCadenceFiles,

			int         huffmanTableExternalId,

			long		photometerID,
			double		vtcStart,
			double		vtcIncrement
	) throws Exception {
		log.warn( "babbleFlags = " + babbleFlags );
		log.warn( "inputDirPath = " + inputDirPath );
		log.warn( "outputDirPath = " + outputDirPath );
		log.warn( "prevRunOutputDirPath = " + prevRunOutputDirPath );
		log.warn( "numShortCadencesPerLongCadence = " +	numShortCadencesPerLongCadence );
		log.warn( "numLongCadencesPerBaseline = " +	numLongCadencesPerBaseline );
		log.warn( "startingLongCadenceFileNum = " +	startingLongCadenceFileNum );
		log.warn( "numLongCadenceFiles = " + numLongCadenceFiles );
		log.warn( "huffmanTableExternalId = " + huffmanTableExternalId );
		log.warn( "photometerID = " + photometerID );
		log.warn( "vtcStart = " + vtcStart );
		log.warn( "vtcIncrement = " + vtcIncrement );

		// control flags
		babbleDebug				= ( -1 != babbleFlags.indexOf( "d" ) );
		babbleStatus			= ( -1 != babbleFlags.indexOf( "s" ) );
		doBitPrinting			= ( -1 != babbleFlags.indexOf( "b" ) );
		doSctBitPrinting		= ( -1 != babbleFlags.indexOf( "B" ) );
		dumpForHema				= ( -1 != babbleFlags.indexOf( "H" ) );
		testBunching			= ( -1 != babbleFlags.indexOf( "t" ) );
		oneSC					= ( -1 != babbleFlags.indexOf( "1" ) );
		doingFFI				= ( -1 != babbleFlags.indexOf( "F" ) );
		onlyFFI					= ( -1 != babbleFlags.indexOf( "f" ) );
		writeFilePerDataType	= ( -1 != babbleFlags.indexOf( "p" ) );
		rawInput				= ( -1 != babbleFlags.indexOf( "r" ) );
		
		if ( rawInput ) {
			log.error("raw input mode not yet implemented.");
			// must read different filenames
		}
		
		if ( doingFFI ) {
		    // we no longer "piggyback" an FFI onto another run
		    onlyFFI = true;
		}

		this.outputPath		   = outputDirPath;
		this.prevRunOutputPath = prevRunOutputDirPath;

		this.startingLongCadenceFileNumber	= startingLongCadenceFileNum;
		this.numLongCadenceFilesToProcess	= numLongCadenceFiles;

		this.photometerConfigID	= photometerID;

		// load packet sequence counts leftover from last dataset
		prevRunOutputPath = prevRunOutputDirPath;
		packetSeqCounts = new short[ NUM_PKT_TYPES ];
		loadPacketSequenceCounts();

		if ( writeFilePerDataType ) {
			writtenTypes = ".";	// prepare to track the types we've written
		}

		vtc = vtcStart + 
				(	startingLongCadenceFileNumber * 
					numShortCadencesPerLongCadence *
					vtcIncrement );
		vtcInc = vtcIncrement;

		String cadenceRangeFilenameSuffix = 
									+ startingLongCadenceFileNumber
									+ "-"
									+ ( startingLongCadenceFileNumber +
										numLongCadenceFilesToProcess - 1 )
									+ ".dat";

		// open output file to contain the segment of the 
		// Storage Correlation Table corresponding to the 
		// range of cadences/FFIs being processed
		String sctFilename =		"/sct." + cadenceRangeFilenameSuffix;
		try {
	    	sctOutput = new DataOutputStream( 
							new BufferedOutputStream(
								new FileOutputStream(
									new File( outputDirPath, sctFilename ))));
		} catch ( Exception e ) {
	    	error( "DataSetPacker failed to open " +
								outputDirPath + "/" + sctFilename );
	    	e.printStackTrace();
	    	throw e;
		}

/*
		// open output file to contain 
		// comma-separated list of header offsets
		String packetLengthsFilename =		
				PACKET_LENGTHS_FILENAME_PREFIX + cadenceRangeFilenameSuffix;
		try {
			packetLengthsOutput = new BufferedWriter( 
				new FileWriter( 
						new File( outputDirPath, 
									packetLengthsFilename )));
		} catch ( Exception e ) {
	    	error( "DataSetPacker failed to open " +
								outputDirPath + "/" + packetLengthsFilename );
	    	e.printStackTrace();
	    	throw e;
		}
*/

		// proceed handling Short and Long Cadence files

		// open output file to contain the CCSDS Packets generated from the
		// range of cadences/FFIs being processed
/*
		String outputFilename =		CCSDS_DATA_FILENAME_PREFIX + 
									+ startingLongCadenceFileNumber
									+ "-"
									+ ( startingLongCadenceFileNumber +
										numLongCadenceFilesToProcess - 1 )
									+ ".dat";
*/
		String outputFilename =		CCSDS_OUTPUT_FILENAME;
		try {
	    	output = new DataOutputStream( 
						new BufferedOutputStream(
							new FileOutputStream(
								new File( outputDirPath, outputFilename ))));
		} catch ( Exception e ) {
	    	error( "DataSetPacker failed to open " +
								outputDirPath + "/" + outputFilename );
	    	e.printStackTrace();
	    	throw e;
		}

		int startingShortCadenceFileNumber = 
			startingLongCadenceFileNumber * numShortCadencesPerLongCadence;
		int numShortCadenceFilesToProcess = 
			numLongCadenceFilesToProcess  * numShortCadencesPerLongCadence;

		InputDataFileSet scFiles  = new InputDataFileSet( 
					    					inputDirPath + "/short/merged/",
											"mergedCadenceData-",
											startingShortCadenceFileNumber,
											numShortCadenceFilesToProcess );
		InputDataFileSet lcFiles  = new InputDataFileSet( 
					    					inputDirPath + "/long/merged/",
											"mergedCadenceData-",
											startingLongCadenceFileNumber,
											numLongCadenceFilesToProcess );
/*
		InputDataFileSet ffiFiles = new InputDataFileSet( 
					    					inputDirPath + "/ffi/merged/",
											"mergedFfiData-",
											0, 0
											);
*/

		huffTable = new HuffmanTable( huffmanTableExternalId );

		File sc = null;
		File lc = null;
//		File ffi = null;

		// fix up the arguments for very short debugging runs
		if ( 0 == numLongCadencesPerBaseline ) {
	    	numLongCadencesPerBaseline = 1;
		}
		if ( 0 == numLongCadenceFilesToProcess ) {
			// force processing of SC's even if no LC's
	    	numLongCadenceFilesToProcess++;
		}

if ( ! onlyFFI ) {
		if ( 0 != startingShortCadenceFileNumber ) {
			// not the first batch of cadence files to be processed,
			// so a previous baseline exists.
			sc = scFiles.getFile( 
					startingShortCadenceFileNumber - 
					( numShortCadencesPerLongCadence * numLongCadencesPerBaseline ) );
			processSC(	sc, NO_DIFF_NO_COMPRESS, FETCH_PREVIOUS_BASELINE );
			havePrevShortBaseline = true;
		}

		if ( 0 != startingLongCadenceFileNumber ) {
			// not the first batch of cadence files to be processed,
			// so a previous baseline exists.
			lc = lcFiles.getFile( 
					startingLongCadenceFileNumber - 
					numLongCadencesPerBaseline );
			processLC(	lc, NO_DIFF_NO_COMPRESS, FETCH_PREVIOUS_BASELINE );
			havePrevLongBaseline = true;
		}

		for ( int l = 0; l < numLongCadenceFilesToProcess; l++ ) {

			// Short Cadences first
			for ( int s = 0; s < numShortCadencesPerLongCadence; s++ ) {

				// bump timestamp
				vtc += vtcInc;

				sc = scFiles.nextFile();
				if ( havePrevShortBaseline ) {
					// We do this for every SC except the very 1st.
					oneForHemaToTest = true;
					processSC(	sc,
								DIFF_AND_COMPRESS,
								needNewShortBaseline ? 
									SC_PKT_ID_RESIDUAL_BASELINE	:
									SC_PKT_ID_ENCODED	);
				} else {
					// We will be here only once.
					// The very 1st SC will be processed (just below)
					// as the new SC baseline.
					// But for the very 1st SC, there is no prev baseline
					// and so we do not process a compressed residual.
status( "Here only once!");
				}
				if ( needNewShortBaseline ) {
					// reprocess same SC for new baseline
status( "Reprocessing same SC for new baseline" );
					processSC(	sc, 
								NO_DIFF_NO_COMPRESS,
								SC_PKT_ID_BASELINE	);
					needNewShortBaseline = false;
				}

				scCounter++;
			}

// This break was put in to run my dpS script to produce the kplr.scb file.
if ( oneSC ) break;

			// Long Cadence follows a bunch of Short Cadences
			lc = lcFiles.nextFile();
			// handle Long Cadences and Baselines similarly to Short ones.
			if ( havePrevLongBaseline ) {
				processLC(	lc,
							DIFF_AND_COMPRESS,
							needNewLongBaseline ? 
								LC_PKT_ID_RESIDUAL_BASELINE	:
								LC_PKT_ID_ENCODED	);
			}
			if ( needNewLongBaseline ) {
				// reprocess same LC for new baseline
status( "Reprocessing same LC for new baseline" );
				processLC(	lc,
							NO_DIFF_NO_COMPRESS,
							LC_PKT_ID_BASELINE	);
				needNewLongBaseline = false;
			}


status("l="+l+", per="+numLongCadencesPerBaseline +", mod="+((l+1) % numLongCadencesPerBaseline ) );
			if ( 0 == ( l + 1 ) % numLongCadencesPerBaseline ) {
				needNewLongBaseline  = true;
				needNewShortBaseline = true;
			}
		} // for each lc

		output.close();
//		sctOutput.close();

		status( "\n\naverage Huffman code length = " + huffTable.averageCodeLength() );
} // ! onlyFFI

		// FFI files are handled as a special case 
		if ( doingFFI ) {

			// process FFI files separately
			try {
				output = new DataOutputStream( 
							new BufferedOutputStream(
								new FileOutputStream(
									new File( outputDirPath,
									    //CCSDS_DATA_FILENAME_PREFIX + "ffi.dat" 
									    CCSDS_OUTPUT_FILENAME
						) ) ) );
			} catch ( Exception e ) {
				error( "DataSetPacker failed to create FFI output file" );
				e.printStackTrace();
				throw e;
			}

			// per discussion with S.Bryson & T.Klaus, 10/9/07
//			vtc += ( 30 * vtcInc );
			vtc += ( numShortCadencesPerLongCadence * vtcInc );

			for ( int i = 0; i < FcConstants.modulesList.length; i++ ) {
				int mod = FcConstants.modulesList[i];
				packetSeqCountType = NUM_SHORT_LONG_TYPES + i;
				File ffi = new File( inputDirPath + "/long/merged/",
										"mergedFfiData-" + mod + ".dat" );
				processFFI( ffi, mod );  // mod is part of dest. pkt. id (FG1269)
			}

			output.close();
//			sctOutput.close();	// TODO SCT entries for FFIs?

		}

		sctOutput.close();
		writePacketSequenceCounts();

    } // DataSetPacker run

	// processSC creates SC baseline array and processes the Short Cadence
    public void processSC( File sc, boolean diffAndCompress,
			byte  destinationPacketId 
	) throws Exception {
		// create arrays now that we know the size of the Short Cadence files.
		// Note!  we assume they are all the same size.
		// Otherwise, how could we diff a bigger SC against a smaller baseline?
		if ( null == shortBaseline ) {
			shortBaseline = new int[ (int) sc.length() / BYTES_PER_SHORT ];
			havePrevShortBaseline	= true;
		}

		if ( ! diffAndCompress ) {
			packetSeqCountType = SCB;
		} else if ( destinationPacketId == SC_PKT_ID_RESIDUAL_BASELINE ) {
			packetSeqCountType = SCR;
		} else if ( destinationPacketId == SC_PKT_ID_ENCODED ) {
			packetSeqCountType = SCS;
		} else {
		    throw new Exception("Unable to determine SC packet type: diffAndCompress=" + diffAndCompress
		        + ", destinationPacketId=" + destinationPacketId );
			//packetSeqCountType = SC_UNKNOWN;
		}
		mocDmcOutputExt = MOC_DMC_FILE_EXTENSIONS[ packetSeqCountType ];

		if ( testBunching ) {
			status( "Short Cadence #" + scCounter + ": " 
				+ mocDmcOutputExt + ", " + sc.getName() 
				+ " " + getTimestamp() + " "
				+ " " + vtc + " "
				+ ", diffAndCompress = " + diffAndCompress );
		}

		processDataset( sc, diffAndCompress, 
				havePrevShortBaseline, shortBaseline,
				SC_APP_ID, destinationPacketId );

		bumpSsrOffset();
	}

	// processLC creates LC baseline array and processes the Long Cadence
    public void processLC( File lc, boolean diffAndCompress, 
			byte destinationPacketId 
	) throws Exception {
		// create arrays now that we know the size of the Long Cadence files.
		// Note!  we assume they are all the same size.
		// Otherwise, how could we diff a bigger LC against a smaller baseline?
		if ( null == longBaseline ) {
			longBaseline = new int[ (int) lc.length() / BYTES_PER_SHORT ];
			havePrevLongBaseline	= true;
		}

		scCounter = 0;

		if ( ! diffAndCompress ) {
			packetSeqCountType = LCB;
		} else if ( destinationPacketId == LC_PKT_ID_RESIDUAL_BASELINE ) {
			packetSeqCountType = LCR;
		} else if ( destinationPacketId == LC_PKT_ID_ENCODED ) {
			packetSeqCountType = LCS;
		} else {
		    throw new Exception("Unable to determine LC packet type: diffAndCompress=" + diffAndCompress
		        + ", destinationPacketId=" + destinationPacketId );
			//packetSeqCountType = LC_UNKNOWN;
		}
		mocDmcOutputExt = MOC_DMC_FILE_EXTENSIONS[ packetSeqCountType ];

		if ( testBunching ) {
			status( "=== Long Cadence:  " + mocDmcOutputExt + ", " + lc.getName() 
				+ " " + getTimestamp() + " "
				+ " " + vtc + " "
					+ ", diffAndCompress = " + diffAndCompress );
		}

		processDataset( lc, diffAndCompress, 
				havePrevLongBaseline, longBaseline,
				LC_APP_ID, destinationPacketId );

		writeStorageCorrelationTableEntry(
				LC_APP_ID, destinationPacketId );

		bumpSsrOffset();
    }

	// processFFI processes the FFI file
    public void processFFI( File ffi, int moduleNumber ) throws Exception{
		status( "FFI:  " + ffi.getName() );

		// for FFI, packetSeqCountType is different for each mod/out
		mocDmcOutputExt = ".ffi";

		byte pktId = (byte) ( FFI_PKT_ID_BASE_NUM_PER_MODULE + moduleNumber );

		processFfiDataset( ffi, 
			FFI_APP_ID, 
			(byte) ( FFI_PKT_ID_BASE_NUM_PER_MODULE + moduleNumber ) );

		writeStorageCorrelationTableEntry( FFI_APP_ID, pktId );

		bumpSsrOffset();
    }

	/*
	 * Increment the ssrOffset used to create the Storage Correlation Table
	 */
	public void bumpSsrOffset() {
		ssrOffset   += dataSetSize;
    }

	/*
     * FFIs have 32-bit pixel values
     * that we simply pack into the Science Data Buffer
     */
    public void processFfiDataset( 
			File f,
			byte destinationApplicationId, 
			byte destinationPacketId
	) throws Exception {
		if ( testBunching ) return;
	
		if (! f.exists()) {
			log.error("Missing file: " + f.getAbsolutePath());
			return;
		}
		if (f.length() == 0) {
			log.error("Empty file: " + f.getAbsolutePath());
			return;
		}

		dataSetSize = 0;

		DataInputStream dis = null;
		try {
	    	dis = new DataInputStream( 
					new BufferedInputStream( new FileInputStream ( f ) ) );

	    	int[]	buf = new int[ BUFFER_INTS ];
	    	int		currentInt = 0;		// position in output buffer
	    	int		pixel = 0;			// latest value read from cadence file
			int		packetDataBytes	 = 0;	// # of data bits in the packet

			openMocDmcOutput();

	    	startPixels = 0;
	    	numPixels = 0;

	    	while ( true ) {  // go until dis.readInt throws EOF exception
				try {
					pixel = dis.readInt();

					packetDataBytes += BYTES_PER_INT;

					if ( packetDataBytes > PAYLOAD_BYTES ) {
						// this int puts us over the payload size,
						// so write out the packet.
						writeCcsdsPacket( 
								NOT_FINAL_PACKET,
				    			buf,
								currentInt,
                                PAYLOAD_BYTES,
				    			( perCadencePacketCount == 0 ) ?
									SEQ_FLAG_FIRST : SEQ_FLAG_MIDDLE, 
								destinationApplicationId, 
								destinationPacketId );

						startPixels		= numPixels;
						currentInt		= 0;
						packetDataBytes = BYTES_PER_INT;
						for ( int i = 0; i < BUFFER_INTS; i++ ) {
							buf[ i ] = 0;
						}
					}

		    		buf[ currentInt++ ] = pixel;
		    		numPixels++;

				} catch ( EOFException e ) {
		    		if ( packetDataBytes > 0 ) {
						// write out previous buffer
						writeCcsdsPacket( 
								FINAL_PACKET,
								buf,
								currentInt,
								packetDataBytes,
								SEQ_FLAG_FINAL,
								destinationApplicationId, 
								destinationPacketId );
		    		}
		    		// end of file, stop processing it.
		    		break;
				} catch ( Exception e ) {
	    	    	error( "DataSetPacker failure in FFI loop" );
		    		e.printStackTrace();
					throw e;
				}
	    	}

			if ( null != mocDmcOutput ) {
				mocDmcOutput.close();
//				mocDmcOutput	= null;
//				mocDmcOutputExt	= null;
			}

		} catch ( Exception e ) {
	    	error( "DataSetPacker failure in processFfiDataSet" );
	    	e.printStackTrace();
			throw e;
		} finally {
	    	if ( null != dis )
			try {
		    	dis.close();
			} catch ( Exception e ) {
	    	    error( "DataSetPacker processFfiDataSet failed to close input file" );
		    	e.printStackTrace();
				throw e;
			}
		}

    }  // processFfiDataSet

	private void openMocDmcOutput() throws Exception {
		if ( writeFilePerDataType ) {
			if ( -1 == writtenTypes.indexOf( mocDmcOutputExt + "." ) ) {
				writtenTypes = mocDmcOutputExt + writtenTypes;

				// open mocDmc output file to contain a single instance
				// of data for a particular data type
/*
				String middle =	startingLongCadenceFileNumber
								+ "-"
								+ ( startingLongCadenceFileNumber +
									numLongCadenceFilesToProcess - 1 );
*/
				String mocDmcOutputFilename =
								"/kplr" + getTimestamp() + "a" + 
								mocDmcOutputExt;
				try {
					mocDmcOutput = new DataOutputStream( 
								new BufferedOutputStream(
									new FileOutputStream(
										new File( outputPath, 
													mocDmcOutputFilename ))));
				} catch ( Exception e ) {
					error( "DataSetPacker failed to open " +
									outputPath + "/" + mocDmcOutputFilename );
					e.printStackTrace();
					throw e;
				}
			}
		}
	}

	private void closeMocDmcOutput() throws Exception {
		if ( null != mocDmcOutput ) {
			mocDmcOutput.close();
		}
		mocDmcOutput	= null;
		mocDmcOutputExt	= null;
	}

	/*
     * processDataset reads the source data and performs differencing
     * (by subtraction from the previous baseline value)
     * and performs compresssion (using Huffman codes we look up).
     * 
     * The result is a science data buffer ready for headers.
     */
    public void processDataset( 
			File f,
			boolean diffAndCompress,
			boolean havePrevBaseline,
			int[]	baseline,
			byte destinationApplicationId, 
			byte destinationPacketId
	) throws Exception {
		if ( testBunching ) return;
		
		if (! f.exists()) {
			log.error("Missing file: " + f.getAbsolutePath());
			return;
		}

		dataSetSize = 0;

		DataInputStream dis = null;
		try {
	    	dis = new DataInputStream( 
					new BufferedInputStream( new FileInputStream ( f ) ) );

	    	int[]	buf = new int[ BUFFER_INTS ];
	    	int		currentInt = 0;		// position in output buffer
	    	int		numBits = 0;		// num of bits used in buffer
	    	int		pixel = 0;			// latest value read from cadence file

	    	String	code;				// Huffman string of 1's and 0's
	    	int		numNewBits;			// length of code string
	    	long	newBits;			// the code bits made ready for use
	    	int		roomInCurrentInt;	// num of bits free in current spot
	    	int		roomInNewInt;		// num of bits free in newBits
	    	int		numShift;			// num of shifts to pack newBits

			int		packetDataBits	 = 0;	// # of data bits in the packet
			int		packetDataBytes	 = 0;	// # of data bits in the packet
			int		totalCodeLengths = 0;	// for reporting Huffman efficiency

			openMocDmcOutput();

	    	startPixels = 0;
	    	numPixels = 0;

	    	while ( true ) {  // go until dis.readShort throws EOF exception
				try {
					// "pixel" is really an index into a quantization table
					short pixelShort = dis.readShort();

					// we have read an unsigned short from the file
					// into a signed short Java variable
					// and the high data bit is now the sign bit.
					// To get the full unsigned (positive) short value,
					// we need more bits, and so we put it in an int.
					pixel = pixelShort;

					// This causes the sign bit to be extended through
					// the high-order bits of the int.
					// So we do a signed left shift to eliminate 
					// the extended sign bits, and then do an 
					// unsigned right shift (glad java provided at least that)
					// to get our original unsigned short value back.
					pixel = pixel <<  BITS_PER_SHORT;
					pixel = pixel >>> BITS_PER_SHORT;

					if ( ! diffAndCompress ) {
						// setting a new baseline
						if ( null != baseline ) {
							// FFIs will have no baseline
							baseline[ numPixels ] = pixel;
							if ( FETCH_PREVIOUS_BASELINE == destinationPacketId ) {
								continue;
							}
						}

						// prepare to pack pixel into buffer
						numNewBits 		= BITS_PER_SHORT;
						newBits 		= (long) pixel;
					} else {
//int p1 = 0;
//int p2 = 0;
//int p3 = 0;
						// processing a residual baseline
						// or a cadence diffed against the prev baseline
						if ( havePrevBaseline ) {
							// compute difference between pixel and baseline.
							// see FSGS-116 ICD 5.3.1.1 (FG924)
//p1 = pixel;
							pixel = pixel - baseline[ numPixels ];
//p2 = pixel;
							pixel += TWO_16_minus_1;
//p3 = pixel;

						}

						// Huffman code may be >16 bits in length
		    			code  			= huffTable.getCode( pixel );
		    			numNewBits 		= code.length();
if ( havePrevBaseline ) {
//debug( "p1="+p1+",b["+numPixels+"]="+baseline[numPixels]+", p2="+p2+", p3="+p3 +", numNewBits="+numNewBits+", code="+code);
}
						totalCodeLengths += numNewBits;
		    			newBits 		= (long) Integer.parseInt( code, 2 );
					}

					packetDataBits += numNewBits;

					packetDataBytes = packetDataBits / BITS_PER_BYTE;
					if ( packetDataBytes * BITS_PER_BYTE < packetDataBits ) {
						packetDataBytes++;
					}
					if ( packetDataBytes > PAYLOAD_BYTES ) {
						packetDataBits -= numNewBits;
						packetDataBytes = packetDataBits / BITS_PER_BYTE;
//debug( "packetDataBits ='" + packetDataBits  + "'" );
						if ( packetDataBytes * BITS_PER_BYTE < packetDataBits ) {
							packetDataBytes++;
						}
						// this pixel puts us over the payload size,
						// so write out the packet.
						writeCcsdsPacket( 
								NOT_FINAL_PACKET,
				    			buf,
								currentInt,
/* the following arg WAS packetDataBytes,
 * but since this is not the final packet of the dataset,
 * shouldn't it always be PAYLOAD_BYTES?  Normally it is,
 * but we are seeing a case where we are trying to add a 9-bit codeword
 * to a buffer that already has 16349 bytes.  The logic above correctly holds that
 * 9-bit codeword for the next packet, but it passes 16349 here, resulting in a 
 * short packet in the middle of the dataset, and what's worse, it puts 16350
 * in the packet header (because we pass NOT_FINAL_PACKET), but actually only
 * writes 16349 bytes to the payload
 */
                                PAYLOAD_BYTES,
				    			( perCadencePacketCount == 0 ) ?
									SEQ_FLAG_FIRST : SEQ_FLAG_MIDDLE, 
								destinationApplicationId, 
								destinationPacketId );

						packetDataBits	= numNewBits;
						startPixels		= numPixels;
						currentInt		= 0;
						numBits			= 0;
						for ( int i = 0; i < BUFFER_INTS; i++ ) {
							buf[ i ] = 0;
						}
					}

		    		numPixels++;

		    		// The Huffman code value will be an int,
		    		// but newBits is a long.
		    		// We will left shift the bits in newBits
		    		// to align them with the space remaining in
		    		// the int at buf[currentInt].
		    		// We will fill up those remaining bits in buf[currentInt]
		    		// and then fill bits in buf[++currentInt].

		    		roomInCurrentInt =
			    		BITS_PER_INT - ( numBits % BITS_PER_INT );
		    		roomInNewInt     = 
			    		BITS_PER_INT - numNewBits;

		    		numShift = roomInCurrentInt + roomInNewInt;

//debug( "roomInCurrentInt ='" + roomInCurrentInt  + "'" );
//debug( "roomInNewInt ='" + roomInNewInt  + "'" );
//debug( "numShift ='" + numShift  + "'" );

		    		for ( int k = 0; k < numShift; k++ ) {
						newBits = newBits << 1;
		    		}
//debug( "newBits ='" + newBits  + "'" );

					// Example:
					//
					// If the Huffman code is
					//		"101010"
					// then numNewBits is 6
					// and newBits (a long) is
					//		00000000000000000000000000000000
					//		00000000000000000000000000101010
					// We are only concerned with the lower int part
					// of newBits.  The upper part we use to shift
					// the bits into alignment with the available
					// bits in buf[currentInt].
					//
					// Since newBits=6, roomInNewInt=26 (32-6).
					// That is, there are 26 unused left-hand bits
					// in the new int (the code we looked up).
					// 
					// If buf[currentInt] is almost full,
					// with only the far right bit available,
					// then roomInCurrentInt would be 1.
					// That is, there is only 1 unused right-hand bit
					// in the current int we are filling in the buffer.
					//
					// We add roomInNewInt to roomInCurrentInt
					// to get numShift=27 (26+1).
					// So we shift newBits left 27 times.
					//		00000000000000000000000000000001
					//		01010000000000000000000000000000
					//
					// The upper int of (long) newBits
					// we want to OR with buf[currentInt],
					// and the lower int of newBits
					// we want to Or with buf[currentInt+1].
					//
					// We simply mask away the upper int to get the lowerInt:
					//		01010000000000000000000000000000
					// We then right shift newBits 32 times to get the upperInt:
					//		00000000000000000000000000000001
					//
					// Now we OR the upperInt with buf[currentInt],
					// and we OR the lowerInt with buf[currentInt+1].
					int mask = 0xffffffff;
					int lowerInt = (int) ( newBits & mask );
					int upperInt = (int) ( newBits >> 32 );

//printInt( "lowerInt", lowerInt );
//printInt( "upperInt", upperInt );
//debug( "lowerInt ='" + lowerInt  + "'" );
//debug( "upperInt ='" + upperInt  + "'" );

					buf[ currentInt ] |= upperInt;
//System.out.println( "BBBBBBBBBBBBBBBBBBBBBB currentInt="+ currentInt);
//					printInt( "buf["+currentInt, buf[ currentInt ] );

					if ( numNewBits >= roomInCurrentInt ) {
						buf[ ++currentInt ] |= lowerInt;
//printInt( "buf["+currentInt, buf[ currentInt ] );
					}

//System.out.println( "numPixels='" + numPixels + "', currentInt ='" + currentInt  + "'" );
		    		numBits += numNewBits;

				} catch ( EOFException e ) {
		    		if ( packetDataBytes > 0 ) {
						// write out previous buffer
						writeCcsdsPacket( 
								FINAL_PACKET,
								buf,
								currentInt,
								packetDataBytes,
//				    			( currentInt + 1 ) * BYTES_PER_INT,
								SEQ_FLAG_FINAL,
								destinationApplicationId, 
								destinationPacketId );
		    		}
		    		// end of file, stop processing it.
		    		break;
				} catch ( Exception e ) {
	    	    	error( "DataSetPacker failure in main loop" );
		    		e.printStackTrace();
					throw e;
				}
	    	}

//			debug( "sumCodeLengths ='" + sumCodeLengths + "'" );
//			debug( "numPixels ='" + numPixels + "'" );

			closeMocDmcOutput();

		} catch ( Exception e ) {
	    	error( "DataSetPacker failure in processDataSet" );
	    	e.printStackTrace();
			throw e;
		} finally {
	    	if ( null != dis )
			try {
		    	dis.close();
			} catch ( Exception e ) {
	    	    error( "DataSetPacker processDataSet failed to close input file" );
		    	e.printStackTrace();
				throw e;
			}
		}

    }  // processDataSet

	/*
	 * writes a Log Entry in the section of the Storage Correlation Table
	 * for the Long Cadence (regular, baseline, or residual)
     * to the file containing the SCT Log Entries for the 
     * cadence range being processed.
	 */
	public void writeStorageCorrelationTableEntry(
			byte applicationId, 
			byte packetId
	) throws Exception{
		debug( "Writing SCT Log Entry" );

		// FSGS-ICD Figure 5.3.2-5 shows layout of SCT Log Entry:
		//	1)	Log Entry Timestamp Seconds		(unsigned 4 bytes)
		//	2)	Log Entry Timestamp SubSeconds	(unsigned 1 byte) 
		//			(1 count = 4.096 milliseconds)
		//	3)	Log Entry Timestamp RRS Alignment Pad	 (3 bytes)
		//
		// FSGS-ICD Table 5.3.2-19 shows layout of Log Entry Data,
		// but Jeremy Stober (email 9/25/2007) added fields 4, 5 & 10:
		//	4)	SSR Timestamp Seconds			(unsigned 4 bytes)
		//	5)	SSR Timestamp Subsecs			(unsigned 1 byte)
		//	6)	ApID	 of the data set				 (1 byte)
		//	7)	PacketID of the data set				 (1 byte)
		//	8)	Data Set SSR Offset	in 16-byte units	 (4 bytes)
		//	9)	Data Set Length     in 16-byte units	 (4 bytes)
		//	10)	padding									 (1 byte)
		//
		//	Total bytes per Log Entry:					 16 bytes

		// 1)	Assume top 32 bits of VTC is the value we want.
		byte ts_subsecs = VtcFormat.getLowerByte( vtc );
		int  ts_secs    = VtcFormat.getUpperBytes( vtc );
//System.out.println( "vtc ='" + vtc  + "'" );
//System.out.println( "ts_subsecs ='" + ts_subsecs  + "'" );
//System.out.println( "ts_secs    ='" + ts_secs     + "'" );
		sctOutputInt( (int) ts_secs,	"STC Log Entry Timestamp, Seconds" );

		// 2)	Assume low 8 bits of VTC is the value we want.
		sctOutputByte( ts_subsecs,		"STC Log Entry Timestamp, Subseconds" );

		// 3)	
		sctOutputByte( (byte) 0, "Log Entry Timestamp RRS Alignment Pad byte 1" );
		sctOutputByte( (byte) 0, "Log Entry Timestamp RRS Alignment Pad byte 2" );
		sctOutputByte( (byte) 0, "Log Entry Timestamp RRS Alignment Pad byte 3" );

		// 4)
		sctOutputInt(  (int) ts_secs, "Log Entry Data, SSR Timestamp Seconds" );
		// 5)
		sctOutputByte( ts_subsecs, "Log Entry Data, SSR Timestamp Subseconds" );

		// 6)
		sctOutputByte( applicationId,	"Log Entry Data, ApID" );
		// 7)
		sctOutputByte( packetId,		"Log Entry Data, PacketID" );

		// 8)
//System.out.println( "ssrOffset ='" + ssrOffset  + "'" );
		sctOutputInt(  ssrOffset,		"Log Entry Data, Data Set SSR Offset" );
		// 9)
//System.out.println( "dataSetSize='" + dataSetSize + "'" );
		sctOutputInt(  (int) dataSetSize,	"Log Entry Data, Data Set Length" );
		
		// 10)
		sctOutputByte( (byte) 0,		"Log Entry Data, final pad byte" );

	} // writeStorageCorrelationTableEntry

	/*
     * writeCcsdsPacket emits the telemetry headers,
     * sets the science data headers,
     * and writes out the finished packet.
     */
    public void writeCcsdsPacket(   
					boolean	lastPacket,
					int[]	buf, 
				    int		currentInt,
				    int		packetDataBytes,
				    short	segmentIndicator,
					byte	destinationApplicationId, 
					byte	destinationPacketId
	) throws Exception{
//System.out.println( "Writing CCSDS Packet #" + getPacketSequenceCount() + " starting with pixel ID = " + startPixels + ": packetDataBytes=" + packetDataBytes + ": packetLengths=" + packetLengths );
//		debug( "Writing CCSDS Packet #" + getPacketSequenceCount() + " starting with pixel ID = " + startPixels + ": packetDataBytes=" + packetDataBytes);

        if(packetDataBytes != PAYLOAD_BYTES && !lastPacket){
            throw new Exception("packet is short, but it's not the last packet -- packetDataBytes="+ packetDataBytes + ", lastPacket=" + lastPacket);            
        }
        
        // temporary buffer for the packet so we can validate it 
        // before writing it to the file
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        DataOutputStream dos = new DataOutputStream(baos);
        
		// Now that the Science Data Buffer is full,
		// we know how many pixels went into it,
		// and we can create the Science Data Header (FSGS 5.3.1-2).
debug( "photometerConfigID ='" + photometerConfigID  + "'" );
		int lowerhalf = (int) (photometerConfigID & 0xffffffff);
		int upperhalf = (int) (photometerConfigID >> 32);
		int ccsdsHeader1 = upperhalf;
		int ccsdsHeader2 = lowerhalf;
		// First Pixel ID
		int ccsdsHeader3 =  startPixels;  
		// Num Pixels
		int ccsdsHeader4 =  numPixels - startPixels;

		try {
	    	// CCSDS header is the 
	    	// Telemetry Source Packet Primary Header and Secondary Header
	    	// FSGS-ICD 5.3.3 p.83
	    	//
	    	// field(#bits)=value, ...
	    	// ------------------------------------------------

	    	// Primary Header:

	    	// version#(3)=000, type(1)=0, sec. flag(1)=1, app id(11)=0
	    	short telemetryHeader1 = (short) 
								( 0x0800 | destinationApplicationId );
//System.out.println( "telemetryHeader1 ='" + telemetryHeader1  + "'" );

	    	// seq flags(2), packet seq count(14)
//	    short telemetryHeader2 = segmentIndicator | getPacketSequenceCount();
//System.out.println( "getPacketSequenceCount()='" + getPacketSequenceCount() + "'" );
//System.out.println( "segmentIndicator ='" + segmentIndicator  + "'" );
			// override segment indicator per jjenkins
//	    	segmentIndicator = SEQ_FLAG_UNSEGMENTED; 
//	    	int tmp = segmentIndicator | (int) getPacketSequenceCount();
	    	int tmp = 0xC000 | (int) getPacketSequenceCount();
	    	short telemetryHeader2 = (short) tmp;
//System.out.println( "telemetryHeader2 ='" + telemetryHeader2  + "'" );

	    	// packet length(16) 
	    	// "Length of entire packet in bytes minus primary header minus one"
//debug( "packetDataBytes ='" + packetDataBytes  + "'" );
			if ( ! lastPacket ) {
				// all non-final packets must be 16380 bytes
				tmp = 16380 - TELEMETRY_SOURCE_PACKET_PRIMARY_HEADER_SIZE - 1;
			} else {
//System.out.println( "packetDataBytes ='" + packetDataBytes  + "'" );
				int to14 = 0;
				if ( packetDataBytes < 14 ) {
					to14 = 14 - packetDataBytes;
				}

				int headersSize = 
					  TELEMETRY_SOURCE_PACKET_PRIMARY_HEADER_SIZE 
					+ TELEMETRY_SOURCE_PACKET_SECONDARY_HEADER_SIZE
					+ SCIENCE_DATA_HEADER_SIZE
					+ 4;	// 4 byte MUB Sync Word
//System.out.println( "headersSize ='" + headersSize  + "'" );

				int totalPacketSize = 
					  headersSize
					+ packetDataBytes 
					+ to14;
//System.out.println( "totalPacketSize ='" + totalPacketSize  + "'" );

				// total Packet Size must be a multiple of SSR_OFFSET_UNIT_SIZE
				// bug 532: fix on behalf of jgunter
//				totalPacketSize += 
//					SSR_OFFSET_UNIT_SIZE - 
//					( totalPacketSize % SSR_OFFSET_UNIT_SIZE );

			    int modulo = totalPacketSize % SSR_OFFSET_UNIT_SIZE;
			    if ( modulo > 0 ) {
			        totalPacketSize += SSR_OFFSET_UNIT_SIZE - modulo;
			    }
//System.out.println( "totalPacketSize ='" + totalPacketSize  + "'" );

				// any increase in packet size is done by padding data bytes
				packetDataBytes = totalPacketSize - headersSize;
//System.out.println( "packetDataBytes ='" + packetDataBytes  + "'" );

				// CCSDS packet length field is strangely less than true size.
				tmp = TELEMETRY_SOURCE_PACKET_SECONDARY_HEADER_SIZE
					+ SCIENCE_DATA_HEADER_SIZE
					+ packetDataBytes 
					- 1;
//System.out.println( "tmp ='" + tmp  + "'" );
/*
				tmp = TELEMETRY_SOURCE_PACKET_SECONDARY_HEADER_SIZE
					+ SCIENCE_DATA_HEADER_SIZE
					+ packetDataBytes 
					- 1;
				if ( packetDataBytes < 14 ) {
					// minimum of 14 bytes in CCSD payload
					tmp += ( 14 - packetDataBytes );
				} else {
					// packet size (including 4 byte MUB Sync Word) must be
					// a multiple of 16 bytes
					int x = tmp + 4;
System.out.println( "tmp ='" + tmp  + "'" );
System.out.println( "x ='" + x  + "'" );
					tmp += tmp % SSR_OFFSET_UNIT_SIZE;
System.out.println( "tmp ='" + tmp  + ", mod=" + (tmp%16));
				}
*/
			}
	    	short telemetryHeader3 = (short) tmp;
if ( telemetryHeader3 > 16373 )
System.out.println( "getPacketSequenceCount()=" + getPacketSequenceCount() + ", telemetryHeader3=" +  telemetryHeader3);
			// assemble comma-separated list of header offsets in output file
			int actualPacketSize = 
				tmp + TELEMETRY_SOURCE_PACKET_PRIMARY_HEADER_SIZE + 1;
			packetLengths += comma + actualPacketSize;
			comma = ",";

			// update dataSetSize for creation of SCT Log Entry
			int packetWithMub = actualPacketSize 
								+ 4; // MUB Sync word size
			// convert packet size to SSR units
			int packetInSsrUnits = (int) packetWithMub / SSR_OFFSET_UNIT_SIZE;
			if ( 0 != packetWithMub % SSR_OFFSET_UNIT_SIZE ) {
				throw new Exception( "DataSetPacker: "
					+ "error in resizing packet to SSR unit boundary: "
					+ "actualPacketSize=" + actualPacketSize 
					+ ", packetWithMub = " + packetWithMub );
			}
			// add # SSR units to dataSetSize
			dataSetSize += packetInSsrUnits;

	    	// Secondary Header

	    	// 8 most-significant-bits of vehicle time code 
			// (only lowermost 40 bits of variable vtc are used,
			//   upper 24 bits are considered empty)
			long  vtc5Bytes = VtcFormat.toWholeAndFraction( vtc );
			long  l = vtc5Bytes >> 32;
	    	byte  telemetryHeader4 = (byte) l;

	    	// following 32 bits of VTC
			l = vtc5Bytes << 32;
			l = l >>> 32;
	    	int   telemetryHeader5 = (int) l;

	    	// packet ID(8) per C&T handbook
	    	byte  telemetryHeader6 = destinationPacketId;	

	    	// packet dest app ID(8)=0 per FSGS-116 ICD 5.3.1.3 FS1297 p.51
	    	byte  telemetryHeader7 = 0;	
			// but see 5.3.1.5 table 5.3.1.2a p.60
//	    	telemetryHeader7 = destinationApplicationId;

	    	// packet dest ID(8)=0 per FSGS-116 ICD 5.3.1.3 FS1297 p.51
	    	byte  telemetryHeader8 = 0;
			// but see 5.3.1.5 table 5.3.1.2a p.60
//	    	telemetryHeader8 = destinationPacketId;

//debug( "+++getPacketSequenceCount()="+getPacketSequenceCount());
	    	outputHeaderShort(	dos, telemetryHeader1,
				"FSGS-116 ICD 5.3.3 p. 82-83 version#(3)=000, type(1)=0, sec. flag(1)=1, app id(11)=???" );
	    	outputHeaderShort(	dos, telemetryHeader2,
				"seq flags(2), packet seq count(14)" );
	    	outputHeaderShort(	dos, telemetryHeader3,
				"packet length(16) 'Length of entire packet in bytes minus primary header minus one'" );
	    	outputHeaderByte(	dos, telemetryHeader4,
				"8 most-significant-bits of vehicle time code" );
	    	outputHeaderInt(	dos, telemetryHeader5,
				"following 32 bits of VTC" );
	    	outputHeaderByte(	dos, telemetryHeader6,
				"packet ID(8) per C&T handbook" );
	    	outputHeaderByte(	dos, telemetryHeader7,
				"packet dest app ID(8)=0 per FSGS-116 ICD 5.3.1.3 FS1297 p.51");
	    	outputHeaderByte(	dos, telemetryHeader8,
				"packet dest ID(8)=0 per FSGS-116 ICD 5.3.1.3 FS1297 p.51" );

	    	outputHeaderInt(	dos, ccsdsHeader1, 
				"the Science Data Header (FSGS 5.3.1-2), upper half of photometer ID" );
	    	outputHeaderInt(	dos, ccsdsHeader2,
				"lower half of photometer ID" );
	    	outputHeaderInt(	dos, ccsdsHeader3,
				"First Pixel ID" );
	    	outputHeaderInt(	dos, ccsdsHeader4,
				"Num Pixels" );

	    	// write out the Science Data Buffer
			int intsToWrite = packetDataBytes / BYTES_PER_INT;
            //debug( "intsToWrite ='" + intsToWrite  + "'" );
	    	for ( int i = 0; i < intsToWrite; i++ ) {
				outputInt( dos, buf[ i ] );
	    	}
			int remainingBytesToWrite = 
					packetDataBytes - ( BYTES_PER_INT * intsToWrite );
            
            //debug( "remainingBytesToWrite ='" + remainingBytesToWrite  + "'" );

            if ( remainingBytesToWrite > 0 ) {
				byte[] data = new byte[ BYTES_PER_INT ];
				int finalInt = buf[ intsToWrite ];
				data[ 3 ] = (byte) ( finalInt & 0xff );
				finalInt = finalInt >>> BITS_PER_BYTE;
				data[ 2 ] = (byte) ( finalInt & 0xff );
				finalInt = finalInt >>> BITS_PER_BYTE;
				data[ 1 ] = (byte) ( finalInt & 0xff );
				finalInt = finalInt >>> BITS_PER_BYTE;
				data[ 0 ] = (byte) ( finalInt & 0xff );
				for ( int j = 0; j < remainingBytesToWrite; j++ ) {
					outputByte( dos, data[ j ] );
				}
			}
			// FSGS-116 ICD Rev. B, 5.3.1.3, FG1297, second note says:
			// "The length of the Pixel Data zone is 
			//  (14 bytes + (n multiples of 16 bytes))."
			// That is, each packet needs a minimum of 14 bytes of data.
			int needPadBytes = 14 - packetDataBytes;
			for ( int i = 0; i < needPadBytes; i++ ) {
                dos.writeByte( 0 );
			}

			if ( dumpForHema && oneForHemaToTest ) {
				dumpScienceBufferData( buf );
				dumpForHema = false;
			}

	    	incPacketSequenceCount();
			++perCadencePacketCount;
	    	if ( segmentIndicator == SEQ_FLAG_FINAL ) {
//				zeroPacketSequenceCount();
				perCadencePacketCount = 0;
			}
	    	
            byte[] ccsdsPacketBytes = baos.toByteArray();
            
            validateCcsds(ccsdsPacketBytes);
            
            output.write(ccsdsPacketBytes);
            
		} catch ( Exception e ) {
	    	error( "DataSetPacker.writeCcsdsPacket failed" );
	    	e.printStackTrace();
			throw e;
		}
    } // writeCcsdsPacket

	private void loadPacketSequenceCounts() throws Exception {
		if ( null != prevRunOutputPath && 0 < prevRunOutputPath.length() ) {
			String countsFilename = 
					prevRunOutputPath + CCSDS_OUTPUT_SUBDIR + PACKET_SEQ_COUNT_FILENAME;
			log.warn( "Attempting to load: " + countsFilename );
			try {
				File prevCounts = new File( countsFilename );
				if ( ! prevCounts.exists() ) {
//					log.warn( "WARNING: missing file: " + countsFilename );
					throw new Exception( "ERROR: missing file: " + countsFilename );
				} else {

					BufferedReader c = new BufferedReader( new FileReader( prevCounts ) );

					String line;
					int type = 0;
					for ( ; null != ( line = c.readLine() ); type++ ) {
						packetSeqCounts[ type ] = Short.valueOf( line );
					}
					if ( type != NUM_PKT_TYPES ) {
						throw new Exception( "ERROR: expected " + NUM_PKT_TYPES +
							", but read " + type + " packet seq counters from " +
							countsFilename );
					}
					c.close();
				}
			} catch ( Exception e ) {
				e.printStackTrace();
				throw e;
			}
		}
	}

	private void writePacketSequenceCounts() throws Exception {
		String countsFilename = outputPath + "/" + PACKET_SEQ_COUNT_FILENAME;
		try {
			BufferedWriter w = new BufferedWriter( 
				new FileWriter( 
					new File( countsFilename ) ) );

			for ( int type = 0; type < NUM_PKT_TYPES; type++ ) {
				w.write( packetSeqCounts[ type ] + "\n" );
			}
			w.flush();
			w.close();
		} catch ( Exception e ) {
			e.printStackTrace();
			throw e;
		}
	}

	private short getPacketSequenceCount() {
//System.out.println( "packetSeqCounts[ " + packetSeqCountType + "]=" + packetSeqCounts[ packetSeqCountType ] + ", perCadencePacketCount" + perCadencePacketCount);
		return packetSeqCounts[ packetSeqCountType ];
	}

	private void incPacketSequenceCount() {
		// 14-bit value, max = 2^14-1 = 16383
		if ( ++packetSeqCounts[ packetSeqCountType ] > 16383 ) {
			packetSeqCounts[ packetSeqCountType ] = 0;
		}
	}

	/*
	private void zeroPacketSequenceCount() {
		packetSeqCounts[ packetSeqCountType ] = 0;
	}
	*/


    /**
     * Validate that the CCSDS packet we are writing out is valid.
     * Currently only checks that the packet length matches the number of bytes
     * actually written.
     * TODO: add validation for other header fields
     * 
     * @param ccsdsPacketBytes
     * @throws Exception
     */
	private void validateCcsds(byte[] ccsdsPacketBytes) throws Exception {
        ccsdsPacketCount++;
        DataInputStream dis = new DataInputStream(new ByteArrayInputStream(ccsdsPacketBytes));
        
        short header1 = dis.readShort();
        short header2 = dis.readShort();
        short header3 = dis.readShort();
        
        log.debug("header1 = " + header1);
        log.debug("header2 = " + header2);
        log.debug("header3 = " + header3);

        int actualPacketLength = ccsdsPacketBytes.length - TELEMETRY_SOURCE_PACKET_PRIMARY_HEADER_SIZE - 1;
        
        if(header3 != actualPacketLength){
            throw new Exception("actualPacketLength(" + actualPacketLength + ") does not match " +
                    "headerPacketLength(" + header3 + "), getPacketSequenceCount()=" 
                    + getPacketSequenceCount() + ", ccsdsPacketCount=" + ccsdsPacketCount);
        }
    }

	/*
    private short bytes2short(byte b1, byte b2){
        return (short) ((b1 << 8) + (b2 << 0));
    }
    */

    private void outputHeaderByte( DataOutputStream dos, byte b, String s ) throws Exception {
		if ( doBitPrinting && getPacketSequenceCount() < 4 )	printByte( s, b );
		dos.writeByte(	b );
		if ( null != mocDmcOutput ) {
			mocDmcOutput.writeByte(	b );
		}
	}

	private void outputHeaderShort( DataOutputStream dos, short b, String s ) throws Exception {
		if ( doBitPrinting && getPacketSequenceCount() < 4 ) printShort( s, b );
		dos.writeShort(	b );
		if ( null != mocDmcOutput ) {
			mocDmcOutput.writeShort(	b );
		}
	}

	private void outputHeaderInt( DataOutputStream dos, int b, String s ) throws Exception {
		if ( doBitPrinting && getPacketSequenceCount() < 4 ) printInt( s, b );
		dos.writeInt(	b );
		if ( null != mocDmcOutput ) {
			mocDmcOutput.writeInt(	b );
		}
	}

	private void outputInt( DataOutputStream dos, int b ) throws Exception {
		dos.writeInt(	b );
		if ( null != mocDmcOutput ) {
			mocDmcOutput.writeInt(	b );
		}
	}

	private void outputByte( DataOutputStream dos, byte b ) throws Exception {
		dos.writeByte(	b );
		if ( null != mocDmcOutput ) {
			mocDmcOutput.writeByte(	b );
		}
	}

	private void sctOutputByte( byte b, String s ) throws Exception {
		if ( doSctBitPrinting )	printByte( s, b );
		sctOutput.writeByte(	b );
	}

	/*
	private void sctOutputShort( short b, String s ) throws Exception {
		if ( doSctBitPrinting ) printShort( s, b );
		sctOutput.writeShort(	b );
	}
	*/

	private void sctOutputInt( int b, String s ) throws Exception {
		if ( doSctBitPrinting ) printInt( s, b );
		sctOutput.writeInt(	b );
	}

    public void printByte( String s, byte i ) {
			debug( s + ":\n       decimal: " + i + 
						 "\n       binary:  " + getBits( i, 128 ) );
	}

    public void printShort( String s, short i ) {
			debug( s + ":\n       decimal: " + i + 
						 "\n       binary:  " + getBits( i, 32768 ) );
	}

    public void printInt( String s, int i ) {
			debug( s + ":\n       decimal: " + i + 
						 "\n       binary:  " + getBits( i, TWO_31 ) );
	}


    public static String getBits( int i, long shifter ) {
//	    long shifter = TWO_31;
	    //debug( shifter+"@"+i + ":" );
	    String s = "";
		long x = i;
		x = x << 32;
		x = x >>> 32;
int j = 0;
	    while ( shifter != 0 ) {
j++;
//debug( shifter+"@");
			if ( 0 != ( shifter & x ) )
		    	s += "1";
			else
		    	s += "0";
			shifter = shifter >>> 1;
	    }
//System.out.println( "j='" + j + "'" );
	    return s;
    } // getBits

	public void debug( String s ) {
		log.debug(s);
		if ( babbleDebug )
			System.out.println( s );
	}

	public void status( String s ) {
		log.info(s);
		if ( babbleStatus )
			System.out.println( s );
	}

	public void error( String s ) {
		log.error(s);
		System.out.println( s );
	}

	private String getTimestamp() {
		return VtcFormat.toDateString( vtc );
	}

	public void dumpScienceBufferData( int[] buf ) {
		try {
			BufferedWriter w = new BufferedWriter( 
				new FileWriter( 
					new File( Filenames.BUILD_TMP, "data_for_Hema.dat" ) ) );

			for ( int i = 0; i < 30; i++ ) {
//System.out.println( "############## i="+i+" : " + getBits( buf[i], TWO_31 )  );
//				w.write( getBits( buf[i], TWO_31 ) );
			}

//System.out.println( "##############" );
			w.write( huffTable.getBitStream() ); 
			
			w.flush();
			w.close();
		} catch ( Exception e ) {
			e.printStackTrace();
		}
	}

	/*
	 * HuffmanTable turns Hema's file into a Hashtable 
     */
    class HuffmanTable {

		String[] codes = new String[ 131072 ];

		int[] hits = new int[ 131072 ];

//		Hashtable<Integer,String> huffEncodeTable;

		public HuffmanTable( int huffmanTableExternalId ) throws Exception {
	    	try {
	    	    CompressionCrud compressionCrud = new CompressionCrud();
	    	    codes = compressionCrud.retrieveUplinkedHuffmanBitstrings(huffmanTableExternalId);
	    	    
////				huffEncodeTable = new Hashtable<Integer,String>();
//
//				BufferedReader c = new BufferedReader( new FileReader( 
//				    					new File( filenameHuffmanTable ) ) );
//
//				String line;
//				//int low = - TWO_16_minus_1;
//				int low = 0;
//				for (	int i = low; null != ( line = c.readLine() ); i++ ) {
////debug( "@@@ index=" + i + ", line=" + line );
////		    		huffEncodeTable.put( new Integer( i ), line );
//					codes[ i ] = line;
//				}
//
///*
//int[] test_values = { 0, 1, 10, 1000, 32000, 65535, 80000, 131070 };
//for ( int x = 0; x < test_values.length; x++ ) {
//String code = getCode( test_values[x] );
//debug( "value = " + test_values[x] + ", code = " + code );
//}
//*/
//
//				c.close();
	    	} catch (Exception e) {
				error( 
		    		e + ": Could not retrieve huffman table database.  huffmanTableExternalId = " + huffmanTableExternalId );
				e.printStackTrace();
				throw e;
	    	}
		}

		private long numLookups = 0;
		private float avgCodeLen = 0;
		private long totalCodeBits = 0;

		private StringBuffer bitStream = new StringBuffer(130000);
		public String getBitStream() {
			return bitStream.toString();
		}

		public String getCode( int index ) throws Exception {
//	    	String code = huffEncodeTable.get( new Integer( index ) );
//debug( "index=" + index + ", code=" + code );

			String code = codes[ index ];

	    	if ( null == code ) {
				throw new Exception( "HuffmanTable.getCode found no code for integer value " + index );
			}

			if ( dumpForHema ) {
				bitStream.append( code );
			}

			hits[ index ]++;

	    	avgCodeLen = ( ( avgCodeLen * numLookups ) + code.length() ) / ( numLookups + 1 );
	    	numLookups++;

			totalCodeBits += code.length();

	    	return code;
		}

		public float averageCodeLength() {
	    	return avgCodeLen;
		}

	} // class HuffmanTable


	/*
	 * InputDataFileSet is a helper class for handling cadence files
     */
	class InputDataFileSet {

		private String	dirpath;
		private File	dir;
		private int		max;
		private int		next;
		private String	prefix;

		public InputDataFileSet(	String	dirPath,
									String	filenamePrefix,
									int		startingCadenceFileNumber,
									int		numCadenceFilesToProcess
		) throws Exception {
			try {
				if ( null != dirPath ) {
					dirpath = dirPath;
					dir  = new File( dirPath );
					prefix = filenamePrefix;
					next = startingCadenceFileNumber;
					max = next + numCadenceFilesToProcess;

				}
			} catch ( Exception e ) {
				error( "InputDataFileSet failed to open dir " + dirPath );
				e.printStackTrace();
				throw e;
			}
		}

		public File nextFile() throws Exception {
			String stat;
			if ( next >= max ) {
				stat = "Read max of " + max + " files from " + dirpath;
				status( stat );
				throw new Exception( stat );
			}

			File ret = getFile( next );

			next++;

			return ret;
		}

		public File getFile( int fileNum ) throws Exception {
			String stat;
			String filename = prefix + fileNum + ".dat";
			File f = new File( dir, filename );

			if ( ! f.exists() ) {
				stat = "Missing file " + dirpath + "/" + filename;
				status( stat );
				throw new Exception( stat );
			}

//			status( "Reading " + dirpath + "/" + filename );;

			return f;
		}

    } // class InputDataFileSet


} // class DataSetPacker
