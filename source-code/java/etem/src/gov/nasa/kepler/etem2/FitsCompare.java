/**
 * FitsCompare - compares two FITS files by examining 2880-byte blocks
 * Does not use the nom.tam.fits libraries.
 * The class FitsDiff does use the nom.tam.fits libraries to compare two FITS files.
 * 
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

import static gov.nasa.kepler.common.FitsConstants.*;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

/**
 * Compares two FITS files.
 * 
 * @author Jay Gunter
 * 
 */
public class FitsCompare {
	private static final Log log =
		LogFactory.getLog(FitsCompare.class);

    private static final int BLOCK_SIZE = 2880;
    private static final int LINE_LEN   = 80;
    private static final int LINES_PER_BLOCK = 36;

	private class Fits {
		String filename;
		File file;
		long size;
		BufferedInputStream bis;
		byte[] block = new byte[ BLOCK_SIZE ];
		String str;
		int got;
		int offset = 0;
		int next_offset = 0;
		int modOutDataStart = 0;
		int module= -1;
		int output = -1;
		boolean isHeader = true;
		boolean lastWasHeader = true;

		public Fits( String filename ) throws Exception {
			this.filename = filename;
			file = new File( filename );
			if ( ! file.exists() ) {
				file = null;
				log.error( "no such file: " + filename );
				return;
			}
			size = file.length();
			bis = new BufferedInputStream( new FileInputStream( file ) );
		}

		public boolean readBlock() throws Exception {
			offset = next_offset;
			next_offset += BLOCK_SIZE;
//System.out.println( filename + " offset ='" + offset  + "'" );

			got = bis.read( block, 0, BLOCK_SIZE );

			if ( got != BLOCK_SIZE && got != -1 ) {
				log.error( 
					"file " + filename + " final block too short: " + got );
				return false;
			}

			lastWasHeader = isHeader;
			isHeader = ( -1 != "= ".indexOf( (char) block[9] ) );

			if ( isHeader ) {
				str = new String( block );

				String s = find( MODULE_KW, false );
				if ( null != s ) {
					module = Integer.valueOf( s );
					output = -1;	// OUTPUT attribute may be in next block
				}
				s = find( OUTPUT_KW, false );
				if ( null != s ) {
					output = Integer.valueOf( s );
				}

				modOutDataStart = 0;
			} else {
				if ( lastWasHeader ) {
					modOutDataStart = offset;
				}
			}

			return true;
		}

		public String find( String s, boolean report ) {
			String o = s;
			String ret = null;
			for ( int i = 8 - s.length(); i > 0; i-- ) {
				s += " ";
			}
			s += "=";
			int x;
			int i;
			if ( -1 != ( x = str.indexOf( s ) ) ) {
				// skip spaces after "="
				for ( i = x + 9; ' ' == str.charAt( i ); i++ );
				if ( i > x + 30 ) {
					ret = "";	// too many spaces after "=" means empty value
				} else {
					x = i;  // x = start of value for attribute named by s.
					// find end of value
					for ( i = x + 1; ' ' != str.charAt( i ); i++ );
					ret = str.substring( x, i );
					if ( report ) {
						log.info( 
//							"found string '" + s + ret +
							o + "=" + ret +
							" at offset " + ( offset + x ) +
							" in " + filename );
					}
				}
			}
			return ret;
		}

		public int intAt( int off ) {
			int ret = block[ off ];
			for ( int i = 1; i <= 3 && off + i < BLOCK_SIZE; i++ ) {
				ret = ret << 8;
				ret |= block[ off + i ];
			}
/*
			ret = ret << 8;
			ret |= block[ off + 1 ];
			ret = ret << 8;
			ret |= block[ off + 2 ];
			ret = ret << 8;
			ret |= block[ off + 3 ];
*/
			return ret;
		}
	} // class Fits

    private Fits[] fits;

    private String[] searchStrings;

    private int ccdModule;
    private int ccdOutput;

    /**
     */
    public FitsCompare( String filename1, String filename2, 
		String searchStrings, int ccdModule, int ccdOutput ) throws Exception {
		fits = new Fits[ 2 ];
		fits[0] = new Fits( filename1 );
		fits[1] = new Fits( filename2 );

		
		this.searchStrings = searchStrings.split( "," );

		// TODO could use these to examine data for a specific mod/out.
		this.ccdModule = ccdModule;
		this.ccdOutput  = ccdOutput;
    }

    /**
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) throws Exception {
		Logger logger = Logger.getLogger(FitsCompare.class);
		logger.setLevel(Level.DEBUG);

		org.apache.log4j.BasicConfigurator.configure();

        FitsCompare fc = new FitsCompare(
			args[0], args[1], args[2], 
			Integer.valueOf( args[ 3 ] ),
			Integer.valueOf( args[ 4 ] )
		);

        fc.compare();
    }

	private boolean checkModOut() {
		return (	( ccdModule == 0 || ccdModule == fits[0].module )
				&&	( ccdOutput == 0 || ccdOutput == fits[0].output ) );
	}

	private void compare() throws Exception {
		if ( null == fits[0].file || null == fits[1].file ) {
			return;
		}

		if ( fits[0].size != fits[0].size ) {
			log.error(	"file " + fits[0].filename + 
						" size is " + fits[0].size + "\n" +
						"file " + fits[0].filename + 
						" size is " + fits[0].size + "\n" );
		}

		while ( true ) {
			if ( !  fits[0].readBlock() || ! fits[1].readBlock() ) {
				return;
			}

			if ( ! fits[0].isHeader && ! fits[1].isHeader ) {
				if ( ! (	fits[0].module == fits[1].module && 
							fits[0].output == fits[1].output ) ) {
					log.error(	"mod/out disagree:\n" +
							"file " + fits[0].filename + 
							", offset " + fits[0].offset +
							", m" + fits[0].module + "o" + fits[0].output +
							"\nfile " + fits[1].filename + 
							", offset " + fits[1].offset +
							", m" + fits[1].module + "o" + fits[1].output );
					return;
				}

				if ( checkModOut() ) {
					for ( int i = 0; i < BLOCK_SIZE; i++ ) {
						if ( fits[0].block[i] != fits[1].block[i] ) {
							int i0 = fits[0].intAt( i );
							int i1 = fits[1].intAt( i );
							log.error(	"values differ:\n" +
								"file " + fits[0].filename + 
								", m" + fits[0].module + "o" + fits[0].output +
								", offsets " + 
								( fits[0].offset + i ) + "/" +
								( fits[0].offset + i - fits[0].modOutDataStart ) + 
								", value " + Integer.toHexString( i0 ) +
								"\nfile " + fits[1].filename + 
								", m" + fits[0].module + "o" + fits[0].output +
								", offsets " + 
								( fits[0].offset + i ) + "/" +
								( fits[0].offset + i - fits[0].modOutDataStart ) + 
								", value " + Integer.toHexString( i1 ) );
							return;
						}
					}
				}
			} else { // one or both files are in headers
				if ( checkModOut() ) {
					for ( int i = 0; i < searchStrings.length; i++ ) {
						for ( int j = 0; j < 2; j++ ) {
							fits[j].find( searchStrings[i], true );
						}
					}
				}
			}
		}
	}
}

