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

/**
 * Environment variables used at runtime by the SOC code.
 * 
 * @author Forrest Girouard
 * 
 */
public class SocEnvVars {
    
    /**
     * Optional environment variable used to specify the root of the actual AFT
     * run tree.
     */
    private static final String SOC_AFT_ROOT_VAR = "SOC_AFT_ROOT";

    /**
     * Optional environment variable used to specify the root of the data
     * tree.
     */
    private static final String SOC_DATA_ROOT_VAR = "SOC_DATA_ROOT";

    /**
     * Optional environment variable used to specify the root of the
     * test data tree.
     */
    private static final String SOC_TESTDATA_ROOT_VAR = "SOC_TESTDATA_ROOT";

    /**
     * Required environment variable used to specify the root of the code tree.
     */
    public static final String SOC_CODE_ROOT_VAR = "SOC_CODE_ROOT";
    
    private static final String DIST = "/dist";

    private static final String LOCAL_DIST = FilenameConstants.LOCAL_ROOT + "/dist";

    private static final String LOCAL_DATA = FilenameConstants.LOCAL_ROOT + "/rec";

    private static final String LOCAL_TESTDATA = FilenameConstants.LOCAL_ROOT + "/test-data";

    /**
     * Return the configured default path to the root of the aft tree (default
     * is {@literal /path/to/aft}).
     * 
     * @return a {@code String} whose value is directory path in the file
     * system.
     */
    public static String getLocalAftDir() {
        String localDataDir = System.getenv(SOC_AFT_ROOT_VAR);
        if (localDataDir == null || localDataDir.length() == 0) {
            localDataDir = FilenameConstants.LOCAL_FEATURE_TEST_ROOT;
        }
        return localDataDir;
    }

    /**
     * Return the configured default path to the root of the data tree
     * (default is {@literal /path/to/rec}).
     * 
     * @return a {@code String} whose value is directory path in the file
     * system.
     */
    public static String getLocalDataDir() {
        String localDataDir = System.getenv(SOC_DATA_ROOT_VAR);
        if (localDataDir == null || localDataDir.length() == 0) {
            localDataDir = SocEnvVars.LOCAL_DATA;
        }
        return localDataDir;
    }

    /**
     * Return the configured default path to the root of the dist tree (default
     * is {@literal /path/to/dist}).
     * 
     * @return a {@code String} whose value is directory path in the file
     * system.
     */
    public static String getLocalDistDir() {
        String localCodeDir = System.getenv(SOC_CODE_ROOT_VAR);
        if (localCodeDir == null || localCodeDir.length() == 0) {
            return LOCAL_DIST;
        }
        return localCodeDir + DIST;
    }

    /**
     * Return the configured default path to the root of the test data
     * tree (default is {@literal /path/to/test-data}).
     * 
     * @return a {@code String} whose value is directory path in the file
     * system.
     */
    public static String getLocalTestDataDir() {
        String localDataDir = System.getenv(SOC_TESTDATA_ROOT_VAR);
        if (localDataDir == null || localDataDir.length() == 0) {
            localDataDir = SocEnvVars.LOCAL_TESTDATA;
        }
        return localDataDir;
    }
}
