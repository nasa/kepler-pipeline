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

package gov.nasa.kepler.common;

import gov.nasa.spiffy.common.io.Filenames;

/**
 * Constants used for standard file and directory names.
 * <p>
 * Directories end with a separator character so that one can simply say, for
 * example, ETC + LOG4J_CONFIG using static imports.
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public class FilenameConstants {

    // Directories.

    /** The name of the xml directory (xml). */
    public static final String XML = "xml/";

    /**
     * The root of the SOC file system containing data files that are not
     * appropriate for inclusion in subversion.
     */
    public static final String SOC_ROOT = "/path/to/nfs";

    public static final String LOCAL_ROOT = "/path";
    
    public static final String SOC_LOCAL_ROOT = LOCAL_ROOT + "/to";

    public static final String LOCAL_VENDOR = LOCAL_ROOT + "/vendor";

    public static final String MATLAB_HOME = LOCAL_VENDOR + "/matlab";

    public static final String MCR_CURRENT = MATLAB_HOME + "/mcr/v76";

    /**
     * The directory path component containing feature test related files.
     */
    public static final String FEATURE_TEST = "aft";

    /**
     * The local directory path to the outputs of the feature tests.
     */
    public static final String LOCAL_FEATURE_TEST_ROOT = SOC_LOCAL_ROOT + "/"
        + FEATURE_TEST;

    public static final String DIST_SEED_DATA = Filenames.DIST_ROOT + "/seed-data";

    /**
     * The directory path containing the transient JMS data.
     * 
     * TODO: Once this is configurable in ActiveMQ (it is hardcoded in 4.0) move
     * it into build/test.
     */
    public static final String ACTIVEMQ_DATA = "activemq-data";

    public static final String HSQLDB = "hsqldb";

    public static final String HSQLDB_SCHEMA = "schema/" + HSQLDB;

    public static final String KEPLER_SCRIPT = "kepler.script";

    // Filenames.

    /** The default name of the Kepler properties file (kepler.properties. */
    public static final String KEPLER_CONFIG = "kepler.properties";

    public static final String DIST_ETC = Filenames.DIST_ROOT + "/etc";

    public static final String DIST_KEPLER_CONFIG = DIST_ETC + KEPLER_CONFIG;

    public static final String PI_SEED_DATABASE = "pipeline";

    /** Directory where the test data generators write their .hsql files */
    public static final String BUILD_TEST_HSQLDB = Filenames.BUILD_TEST + "/" + HSQLDB;

    public static final String BUILD_TEST_KEPLER_SCRIPT = Filenames.BUILD_TEST + "/"
        + HSQLDB_SCHEMA + "/" + KEPLER_SCRIPT;

    public static final String SVN_ADMINISTRATIVE_DIR = ".svn";

    // No instantiation allowed.
    private FilenameConstants() {
    }
}
