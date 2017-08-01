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

import static gov.nasa.kepler.common.FilenameConstants.HSQLDB_SCHEMA;
import static gov.nasa.kepler.common.FilenameConstants.MCR_CURRENT;
import static gov.nasa.kepler.common.FilenameConstants.SOC_LOCAL_ROOT;
import static gov.nasa.kepler.common.FilenameConstants.SOC_ROOT;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.File;
import java.util.Properties;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class has methods to set various properties for various tests.
 * 
 * @author Miles Cote
 * @author Bill Wohler
 * @author Forrest Girouard
 */
public class DefaultProperties {
    private static final Log log = LogFactory.getLog(DefaultProperties.class);

    private static final String BUILD_SCHEMA = "/dist/etc/schema";

    private static final String UNIT_TEST_DATA_DIR_PROP = "soc.test.data.dir";

    private static final String UNIT_TEST_LOCAL_DATA_DIR_PROP = "soc.test.local.data.dir";

    private static final String USE_LOCAL_DATA_PROP = "use.local.data";

    private static final String UNIT_TEST_DATA_DIR_DEFAULT = SOC_ROOT + "/java";

    private static final String UNIT_TEST_LOCAL_DATA_DIR_DEFAULT = SOC_LOCAL_ROOT
        + "/java";

    public static final String TEST_SCHEMA_DIR_PROP = "soc.test.schema.dir";

    private static final String TEST_SCHEMA_DIR_DEFAULT = "../../dist/etc/schema";

    private static final String HSQLDB_SCHEMA_DIR_PROP = "soc.hsqldb.schema.dir";

    private static final String HSQLDB_SCHEMA_DIR_DEFAULT = Filenames.BUILD_TEST
        + "/" + HSQLDB_SCHEMA;

    private static final String SOC_HOME_DIR_PROP = "soc.home.dir";

    private static final String SOC_HOME_DIR_DEFAULT = Filenames.DIST_ROOT;

    private static final String MATLAB_LIB_PATH = MCR_CURRENT
        + "/sys/os/glnx86:" + MCR_CURRENT + "/runtime/glnx86:" + MCR_CURRENT
        + "/bin/glnx86:" + MCR_CURRENT
        + "/sys/java/jre/glnx86/jre1.5.0/lib/i386/native_threads:"
        + MCR_CURRENT + "/sys/java/jre/glnx86/jre1.5.0/lib/i386/server:"
        + MCR_CURRENT + "/sys/java/jre/glnx86/jre1.5.0/lib/i386:" + ".";

    /**
     * Name of the property that indicates where the XML files are stored
     */
    public static final String MODULE_XML_DIR_PROPERTY_NAME = "pi.worker.module.xmlDir";

    public enum DatabaseType {
        HSQLDB, HSQLDB_FILE, ORACLE, DERBY, DERBY_EMBEDDED
    }

    /**
     * Returns the location of the unit test data repository for the given CSCI.
     * <p>
     * The basename for this directory is defined by the system property
     * {@code soc.test.data.dir} which is typically set by {@code ant test}.
     * Otherwise, the value of {@link UNIT_TEST_DATA_DIR_DEFAULT}, or {@value
     * UNIT_TEST_DATA_DIR_DEFAULT} is used. The CSCI name is appended to this
     * directory name and this result is returned.
     * 
     * @return the unit test data directory for the given CSCI.
     */
    public static String getUnitTestDataDir(String csci) {

        String unitTestDataDir = null;
        boolean useLocalData = false;
        String useLocalDataStr = System.getProperty(USE_LOCAL_DATA_PROP);
        if (useLocalDataStr != null && useLocalDataStr.length() > 0) {
            useLocalData = Boolean.valueOf(useLocalDataStr);
            log.debug(String.format("%s=%s", USE_LOCAL_DATA_PROP, useLocalData));
        }
        if (useLocalData) {
            unitTestDataDir = System.getProperty(UNIT_TEST_LOCAL_DATA_DIR_PROP);
            if (unitTestDataDir == null) {
                File dir = new File(UNIT_TEST_LOCAL_DATA_DIR_DEFAULT);
                if (dir.exists()) {
                    unitTestDataDir = UNIT_TEST_LOCAL_DATA_DIR_DEFAULT;
                    log.debug(String.format("%s=%s", "unitTestDataDir",
                        unitTestDataDir));
                }
            }
        }

        if (unitTestDataDir == null) {
            unitTestDataDir = System.getProperty(UNIT_TEST_DATA_DIR_PROP);
            if (unitTestDataDir == null) {
                File dir = new File(UNIT_TEST_DATA_DIR_DEFAULT);
                if (dir.exists()) {
                    unitTestDataDir = UNIT_TEST_DATA_DIR_DEFAULT;
                } else {
                    unitTestDataDir = UNIT_TEST_LOCAL_DATA_DIR_DEFAULT;
                }
                log.debug(String.format("%s=%s", "unitTestDataDir",
                    unitTestDataDir));
            }
        }

        return unitTestDataDir + File.separator + csci;
    }

    /**
     * Returns the location of the directory containing schema files.
     * <p>
     * The basename for this directory is defined by the system property
     * {@code soc.test.schema.dir} which is typically set by {@code ant test}.
     * Otherwise, the value of {@link TEST_SCHEMA_DIR_DEFAULT}, or {@value
     * TEST_SCHEMA_DIR_DEFAULT} is used.
     * 
     * @return the test schema directory.
     */
    public static synchronized String getTestSchemaDir() {

        String testSchemaDir = System.getProperty(TEST_SCHEMA_DIR_PROP);
        if (testSchemaDir == null) {
            String socHomeDir = getSocHomeDir();
            if (socHomeDir != null && socHomeDir.length() > 0) {
                File socHome = new File(socHomeDir);
                String parent = socHome.getParent();
                if (parent == null) {
                    parent = "../..";
                }
                testSchemaDir = parent + BUILD_SCHEMA;
            }
        }
        if (testSchemaDir == null) {
            testSchemaDir = TEST_SCHEMA_DIR_DEFAULT;
        }
        return testSchemaDir;
    }

    /**
     * Returns the location of the HSQLDB schema directory.
     * <p>
     * The basename for this directory is defined by the system property
     * {@code soc.hsqldb.schema.dir} which is typically set by {@code ant test}.
     * Otherwise, the value of {@link HSQLDB_SCHEMA_DIR_DEFAULT}, or {@value
     * HSQLDB_SCHEMA_DIR_DEFAULT} is used.
     * 
     * @return the test schema directory.
     */
    public static synchronized String getHsqldbSchemaDir() {

        String hdqldbSchemaDir = System.getProperty(HSQLDB_SCHEMA_DIR_PROP);
        if (hdqldbSchemaDir == null) {
            hdqldbSchemaDir = HSQLDB_SCHEMA_DIR_DEFAULT;
        }
        return hdqldbSchemaDir;
    }

    /**
     * Returns the location of the SOC dist directory.
     * <p>
     * The basename for this directory is defined by the system property
     * {@code soc.home.dir} which is typically set by {@code ant test}.
     * Otherwise, the value of {@link SOC_HOME_DIR_DEFAULT}, or {@value
     * SOC_HOME_DIR_DEFAULT} is used.
     * 
     * @return the test schema directory.
     */
    public static synchronized String getSocHomeDir() {

        String socHomeDir = System.getProperty(SOC_HOME_DIR_PROP);
        if (socHomeDir == null) {
            socHomeDir = System.getenv("SOC_HOME");
        }
        if (socHomeDir == null) {
            socHomeDir = SOC_HOME_DIR_DEFAULT;
        }
        return socHomeDir;
    }

    /**
     * Sets the necessary properties for PipelineModules to default values. Use
     * {@link #getUnitTestDataDir(String)} to generate a good starting point for
     * {@code dataDir}.
     */
    public static void setPropsPipelineModule(String dataDir) {
        Properties systemProperties = System.getProperties();
        setPropsPipelineModule(dataDir, dataDir, systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsPipelineModule(String dataDir,
        String workingDir, Properties databaseProperties) {

        setPropsPipelineModule(dataDir, FilenameConstants.DIST_SEED_DATA,
            FilenameConstants.XML, Filenames.DIST_ROOT + "/mbin",
            MATLAB_LIB_PATH, workingDir, databaseProperties);
    }

    public static void setPropsPipelineModule(String dataDir,
        String seedDataDir, String xmlDir, String binDir, String libPath,
        String workingDir, Properties databaseProperties) {

        databaseProperties.setProperty(MODULE_XML_DIR_PROPERTY_NAME, xmlDir);
        databaseProperties.setProperty("pi.worker.moduleExe.libPath", libPath);
        databaseProperties.setProperty("pi.worker.moduleExe.binDir", binDir);
        databaseProperties.setProperty("pi.worker.moduleExe.dataDir", dataDir);
        databaseProperties.setProperty("pi.worker.moduleExe.workingDir",
            workingDir);
        databaseProperties.setProperty("seedData.dir", seedDataDir);
    }

    public static void setPropsHsqldbMem() {
        Properties systemProperties = System.getProperties();
        setPropsHsqldbMem(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsHsqldbMem(Properties databaseProperties) {
        setPropsHsqldb(databaseProperties);
        databaseProperties.setProperty("hibernate.connection.url",
            "jdbc:hsqldb:mem:db");
    }

    public static void setPropsHsqldbServer() {
        Properties systemProperties = System.getProperties();
        setPropsHsqldbServer(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsHsqldbServer(Properties databaseProperties) {
        setPropsHsqldb(databaseProperties);
        databaseProperties.setProperty("hibernate.connection.url",
            "jdbc:hsqldb:hsql://host/db");
    }

    public static void setPropsHsqldbFile() {
        Properties systemProperties = System.getProperties();
        setPropsHsqldbFile(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsHsqldbFile(Properties databaseProperties) {
        setPropsHsqldb(databaseProperties);
        databaseProperties.setProperty("hibernate.connection.url",
            "jdbc:hsqldb:file:" + getHsqldbSchemaDir() + "/db");
    }

    public static void setPropsHsqldb() {
        Properties systemProperties = System.getProperties();
        setPropsHsqldb(systemProperties);
        System.setProperties(systemProperties);
    }

    private static void setPropsHsqldb(Properties databaseProperties) {
        databaseProperties.setProperty("hibernate.connection.driver_class",
            "org.hsqldb.jdbcDriver");
        databaseProperties.setProperty("hibernate.connection.username", "username");
        databaseProperties.setProperty("hibernate.connection.password", "password");
        databaseProperties.setProperty("hibernate.dialect",
            "org.hibernate.dialect.HSQLDialect");
        databaseProperties.setProperty("hibernate.jdbc.batch_size", "0");
        databaseProperties.setProperty("hibernate.show_sql", "false");
    }

    public static void setPropsOracle() {
        Properties systemProperties = System.getProperties();
        setPropsOracle(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsOracle(Properties databaseProperties) {
        databaseProperties.setProperty("hibernate.connection.driver_class",
            "oracle.jdbc.driver.OracleDriver");
        databaseProperties.setProperty("hibernate.connection.url",
            "jdbc:oracle:thin:@host:port:db");
        databaseProperties.setProperty("hibernate.connection.username",
            databaseProperties.getProperty("user.name"));
        databaseProperties.setProperty("hibernate.connection.password",
            databaseProperties.getProperty("user.name"));
        databaseProperties.setProperty("hibernate.dialect",
            "org.hibernate.dialect.OracleDialect");
        databaseProperties.setProperty("hibernate.jdbc.batch_size", "0");
        databaseProperties.setProperty("hibernate.show_sql", "false");
    }

    public static void setPropsDerby() {
        Properties systemProperties = System.getProperties();
        setPropsDerby(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsDerby(Properties databaseProperties) {
        databaseProperties.setProperty("hibernate.connection.driver_class",
            "org.apache.derby.jdbc.ClientDriver");
        databaseProperties.setProperty("hibernate.connection.url",
            "jdbc:derby://host:port/db;create=true");
        databaseProperties.setProperty("hibernate.connection.username",
            "username");
        databaseProperties.setProperty("hibernate.connection.password",
            "password");
        databaseProperties.setProperty("hibernate.dialect",
            "org.hibernate.dialect.DerbyDialect");
    }

    public static void setPropsDerbyEmbedded() {
        Properties systemProperties = System.getProperties();
        setPropsDerbyEmbedded(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsDerbyEmbedded(Properties databaseProperties) {
        databaseProperties.setProperty("hibernate.connection.driver_class",
            "org.apache.derby.jdbc.EmbeddedDriver");
        databaseProperties.setProperty("hibernate.connection.url",
            "jdbc:derby:db;create=true");
        databaseProperties.setProperty("hibernate.connection.username",
            "username");
        databaseProperties.setProperty("hibernate.connection.password", "password");
        databaseProperties.setProperty("hibernate.dialect",
            "org.hibernate.dialect.DerbyDialect");
    }

    public static void setPropsLocalFs() {
        Properties systemProperties = System.getProperties();
        setPropsLocalFs(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsLocalFs(Properties databaseProperties) {
        databaseProperties.setProperty("fs.driver.name", "local");
        databaseProperties.setProperty("fs.allow-cleanup", "true");
    }

    public static void setPropsHttpFs() {
        Properties systemProperties = System.getProperties();
        setPropsHttpFs(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsHttpFs(Properties databaseProperties) {
        databaseProperties.setProperty("fs.driver.name", "http");
        databaseProperties.setProperty("fs.server.base.url",
            "http://host:port/filestore");
    }

    public static void setPropsForUnitTest() {
        Properties systemProperties = System.getProperties();
        setPropsForUnitTest(systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsForUnitTest(Properties databaseProperties) {
        setPropsPipelineModule(Filenames.BUILD_TEST, Filenames.BUILD_TEST,
            databaseProperties);
        setPropsLocalFs(databaseProperties);
        setPropsHsqldbMem(databaseProperties);
    }

    /**
     * Sets up the properties for a feature test using Oracle. Use
     * {@link #getUnitTestDataDir(String)} to generate a good starting point for
     * {@code dataDir}.
     */
    public static void setPropsForFeatureTest(String dataDir) {
        setPropsForFeatureTest(dataDir, DatabaseType.ORACLE);
    }

    /**
     * Sets up the properties for a feature test using the given directory and
     * database type. Use {@link #getUnitTestDataDir(String)} to generate a good
     * starting point for {@code dataDir}.
     */
    public static void setPropsForFeatureTest(String dataDir,
        DatabaseType databaseType) {
        Properties systemProperties = System.getProperties();
        setPropsForFeatureTest(dataDir, FilenameConstants.XML,
            Filenames.DIST_ROOT + "/mbin", dataDir, databaseType,
            systemProperties);
        System.setProperties(systemProperties);
    }

    public static void setPropsForFeatureTest(String dataDir, String xmlDir,
        String binDir, String workingDir, DatabaseType databaseType,
        Properties databaseProperties) {
        setPropsPipelineModule(dataDir, FilenameConstants.DIST_SEED_DATA,
            xmlDir, binDir, MATLAB_LIB_PATH, workingDir, databaseProperties);
        setPropsLocalFs(databaseProperties);

        switch (databaseType) {
            case HSQLDB:
                setPropsHsqldbMem(databaseProperties);
                break;
            case HSQLDB_FILE:
                setPropsHsqldbFile(databaseProperties);
                break;
            case ORACLE:
                setPropsOracle(databaseProperties);
                break;
            case DERBY:
                setPropsDerby(databaseProperties);
                break;
            case DERBY_EMBEDDED:
                setPropsDerbyEmbedded(databaseProperties);
                break;
        }
    }
}
