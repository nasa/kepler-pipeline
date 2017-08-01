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

import java.io.File;
import java.util.StringTokenizer;

public class EtemUtils {

    /**
     * The name of the ETEM2 outputs directory.  
     * This format is defined in ETEM2.
     * 
     * @param ccdModule
     * @param ccdOutput
     * @param observingSeason
     * @param cadenceType
     * @return
     */
    public static String runDir(int ccdModule, int ccdOutput, String observingSeason, String cadenceType){
        return "run_" + cadenceType + "_m" + ccdModule + "o" + ccdOutput + "s" + observingSeason;
    }

	/**
	 * Location of dataset.config file
	 */
	public static final String	DATASET_CONFIG_FILENAME = "dataset.config";
	private static String		datasetConfigFilename;
	private static File			datasetHome;

	/**
	 * Set the home dir of the datasets.
	 * For example, the datasetHome /path/to/etem2/auto/gsit3b/
	 * contains the following dataset dirs: vc15, 7d-1, 30d, 7d-2
	 * Note:  implementation could change to store path in database
     * @param datasetHome - path to dir containing dataset subdirs, e.g. vc15/../
	 */
	public static void setDatasetHome( String path )
	throws Exception {
		if ( null == path ) {
			throw new Exception( "ERROR: null passed for datasetHome" );
		}
		File home = new File( path );
		if ( ! home.isDirectory() ) {
			throw new Exception( "ERROR: not a directory: " + path );
		}
		datasetHome = home;
		datasetConfigFilename = home + DATASET_CONFIG_FILENAME;
	}

	/**
	 * Get the home dir of the datasets.  Must be set first.
	 * Note:  implementation could change to retrieve path from database
     * @return datasetHome
	 */
	public static File getDatasetHome() {
		return datasetHome;
	}

	private static final int	MAX_DATASETS = 20;
	private static String		datasetSubdirList;
	private static String[]		datasetSubdirs	= new String[  MAX_DATASETS ];
	private static boolean[]	atStartOfSsr	= new boolean[ MAX_DATASETS ];
	private static int			numDatasetSubdirs;

	/**
	 * Set the comma-separated list of dataset dirs located in the home dir.
	 *
	 * For example, the datasetHome /path/to/etem2/auto/gsit3b/
	 * contains the following dataset dirs: vc15, 7d-1, 30d, 7d-2
	 * and the list might be:  vc15:0,7d-1:0,30d:0,7d-2
	 *
	 * The order of the dataset dirs indicates their order in the simulated SSR.
	 *
	 * The :0 appended to a dataset dirname indicates the DataSetPacker should
	 * initialize packet sequence counters to zero when processing that dataset.
	 *
	 * The absense of :0 indicates the DataSetPacker should
	 * initialize packet sequence counters to follow those of the previous dataset.
	 *
	 * Note:  implementation could change to store list in database
	 */
	public static void setDatasetList( String list ) 
	throws Exception {
		StringTokenizer st = new StringTokenizer( list, "," );
		int i = 0;
		for ( ; st.hasMoreTokens(); i++ ) {
			String datasetSubdir = st.nextToken();
			int z = datasetSubdir.indexOf( ":0" );
			if ( -1 != z ) {
				atStartOfSsr[ i ] = true;
				datasetSubdir = datasetSubdir.substring( 0, z );
			} else {
				atStartOfSsr[ i ] = false;
			}
			File dir = new File( datasetHome, datasetSubdir );
			if ( ! dir.isDirectory() ) {
				throw new Exception( "ERROR: not a directory: " +
					datasetHome.getAbsolutePath() + "/" + datasetSubdir );
			}
			datasetSubdirs[ i ] = datasetSubdir;
		}
		numDatasetSubdirs = i;
		datasetSubdirList = list;
	}

	/**
	 * Return true if dataset starts at beginning of simulated SSR.
	 * That is, return true if packet sequence counts for that dataset
	 * should begin at zero.
	 * Note:  implementation could change to retrieve value from database
	 * @param datasetSubdir the subdir name of the dataset, e.g. "30d"
	 * @return true if dataset packet sequence counts should start at zero
	 */
	public static boolean isDatasetAtStartOfSsr( String datasetSubdir ) 
	throws Exception {
		if ( 0 == numDatasetSubdirs ) {
			throw new Exception( "ERROR: call setDatasetList() first!" );
		}
		for ( int i = 0; i < numDatasetSubdirs; i++ ) {
			if ( datasetSubdir.equals( datasetSubdirs[ i ] ) ) {
				return atStartOfSsr[ i ];
			}
		}
		throw new Exception( "ERROR: dataset directory: " + datasetSubdir + 
			" not found in list set by setDatasetList: " + datasetSubdirList );
	}

	/**
	 * Return dataset subdir from full dirpath 
	 * E.g.  if setDatasetList was passed "vc15:0,7d-1:0,30d:0,7d-2",
	 * and setDatasetHome was passed "blah/blah"
	 * then passing 
	 *		blah/blah/30d/ccsds
	 * will return 
	 *		30d
	 *
	 * This is useful for extracting the dataset subdir the output dir,
	 * so that the subdir can be passed to isDatasetAtStartOfSsr()
	 *
	 * @param fullDirpath the full dirpath of the dataset
	 * @return dataset subdir
	 */
	public static String getDatasetSubdir( String fullDirpath )
	throws Exception {
		if ( 0 == numDatasetSubdirs ) {
			throw new Exception( "ERROR: call setDatasetList() first!" );
		}
		fullDirpath += "/";	// in case of e.g. "blah/blah/30d"
		for ( int i = 0; i < numDatasetSubdirs; i++ ) {
			if ( -1 == fullDirpath.indexOf( "/" + datasetSubdirs[ i ] + "/" ) ) {
				return datasetSubdirs[ i ];
			}
		}
		throw new Exception( "ERROR: for dir " + fullDirpath + 
			" no dataset subdir found in list set by setDatasetList: " +
			datasetSubdirList );
	}

	/**
	 * Return name of subdir of dataset processed previous to this dataset.
	 * E.g.  if setDatasetList was passed "vc15:0,7d-1:0,30d:0,7d-2",
	 * then passing "30d" will return "7d-1"
	 * Note:  implementation could change to retrieve value from database
	 * @param thisDatasetSubdir the subdir name of the dataset, e.g. "30d"
	 * @return subdir name of previous dataset,
	 * or null if thisDatasetSubdir is first in list set by setDatasetList()
	 */
	public static String getPrevDatasetSubdir( String thisDatasetSubdir ) 
	throws Exception {
		if ( 0 == numDatasetSubdirs ) {
			throw new Exception( "ERROR: call setDatasetList() first!" );
		}
		if ( thisDatasetSubdir.equals( datasetSubdirs[ 0 ] ) ) {
			return null;
		}
		String prevSubdir = datasetSubdirs[ 0 ];
		for ( int i = 1; i < numDatasetSubdirs; i++ ) {
			if ( thisDatasetSubdir.equals( datasetSubdirs[ i ] ) ) {
				return datasetHome.getAbsolutePath() + "/" + prevSubdir;
			}
			prevSubdir = datasetSubdirs[ i ];
		}
		throw new Exception( "ERROR: dataset directory: " + thisDatasetSubdir + 
			" not found in list set by setDatasetList: " + datasetSubdirList );
	}

	/**
	 * Return full dirpath of dataset processed previous to this dataset.
	 * E.g.  if setDatasetList was passed "vc15:0,7d-1:0,30d:0,7d-2",
	 * and setDatasetHome was passed "blah/blah"
	 * then passing 
	 *		blah/blah/30d/ccsds
	 * will return 
	 *		blah/blah/7d-1/ccsds
	 *
	 * This is useful for finding the output dir for a previous run,
	 * given the output dir for the current run of the DataSetPacker or VcduPacker.
	 *
	 * Note:  implementation could change to retrieve value from database
	 * @param thisDatasetFullDirpath the full dirpath of the dataset
	 * @return full dirpath to corresponding dir for previous dataset
	 * or null if thisDatasetSubdir is first in list set by setDatasetList()
	 */
	public static String getPrevDatasetFullDirpath( String thisDatasetFullDirpath )
	throws Exception {
		if ( 0 == numDatasetSubdirs ) {
			throw new Exception( "ERROR: call setDatasetList() first!" );
		}
		thisDatasetFullDirpath += "/";	// in case of e.g. "blah/blah/30d"
		if ( -1 != thisDatasetFullDirpath.indexOf( "/" + datasetSubdirs[0] + "/" ) ) {
			return null;
		}
		String ret = null;
		String prevSubdir = datasetSubdirs[ 0 ];
		for ( int i = 1; i < numDatasetSubdirs; i++ ) {
			ret = thisDatasetFullDirpath.replaceFirst( 
						"/" + datasetSubdirs[ i ] + "/", 
						"/" + prevSubdir + "/" );
			if ( ! ret.equals( thisDatasetFullDirpath ) ) {
				// current dataset subdir has been replaced
				// with the previous dataset subdir
				return ret;
			}
			prevSubdir = datasetSubdirs[ i ];
		}
		throw new Exception( "ERROR: for dir " + thisDatasetFullDirpath + 
			" unable to convert to previous dir using list set by setDatasetList: " +
			datasetSubdirList );
	}

	/**
	 * Return full pathname of dataset, given subdir name of dataset.
	 * E.g.  if setDatasetHome was passed "blah/blah",
	 * then passing "30d" will return "blah/blah/30d".
	 * Note:  implementation could change to retrieve value from database
	 * @param datasetDir the subdir name of the dataset, e.g. "30d"
	 * @return full pathname of dataset
	 */
	public static String getFullDatasetPath( String datasetDir )
	throws Exception {
		isDatasetAtStartOfSsr( datasetDir );	// validate argument
		return datasetHome.getAbsolutePath() + "/" + datasetDir;
	}
    
}
