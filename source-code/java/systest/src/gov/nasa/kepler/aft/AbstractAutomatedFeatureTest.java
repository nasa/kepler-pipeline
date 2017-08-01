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

package gov.nasa.kepler.aft;

import static gov.nasa.kepler.common.FilenameConstants.KEPLER_CONFIG;
import static gov.nasa.kepler.ops.seed.CommonPipelineSeedData.CADENCE_TYPE;
import static gov.nasa.kepler.ops.seed.CommonPipelineSeedData.DATA_GEN;
import static gov.nasa.kepler.ops.seed.CommonPipelineSeedData.PACKER;
import static gov.nasa.kepler.ops.seed.CommonPipelineSeedData.PLANNED_PHOTOMTER_CONFIG;
import static gov.nasa.kepler.ops.seed.CommonPipelineSeedData.PLANNED_SPACECRAFT_CONFIG;
import static junit.framework.Assert.assertNotNull;
import static junit.framework.Assert.assertTrue;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptor;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory;
import gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory.Type;
import gov.nasa.kepler.aft.misc.AftFileStoreServer;
import gov.nasa.kepler.aft.seeder.SpiceSeeder;
import gov.nasa.kepler.common.Cadence.CadenceType;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.common.ModifiedJulianDate;
import gov.nasa.kepler.common.RegexEditor;
import gov.nasa.kepler.common.RegexEditor.FindAction;
import gov.nasa.kepler.common.SocEnvVars;
import gov.nasa.kepler.common.pi.CadenceRangeParameters;
import gov.nasa.kepler.common.pi.CadenceTypePipelineParameters;
import gov.nasa.kepler.common.pi.PlannedPhotometerConfigParameters;
import gov.nasa.kepler.common.pi.PlannedSpacecraftConfigParameters;
import gov.nasa.kepler.dev.seed.ModelImportParameters;
import gov.nasa.kepler.dev.seed.QuarterlyPipelineLauncherPipelineModule;
import gov.nasa.kepler.etem2.DataGenParameters;
import gov.nasa.kepler.etem2.DataGenTimeOperations;
import gov.nasa.kepler.etem2.PackerParameters;
import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.fs.server.Server;
import gov.nasa.kepler.hibernate.cm.TargetList;
import gov.nasa.kepler.hibernate.cm.TargetSelectionCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.ConnectInfo;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.HsqldbManager;
import gov.nasa.kepler.hibernate.dbservice.HsqldbUtils;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.pi.ParameterSet;
import gov.nasa.kepler.hibernate.pi.ParameterSetCrud;
import gov.nasa.kepler.hibernate.pi.PipelineDefinitionNode;
import gov.nasa.kepler.pi.configuration.PipelineConfigurationOperations;
import gov.nasa.kepler.pi.parameters.ParametersOperations;
import gov.nasa.kepler.pi.pipeline.PipelineOperations;
import gov.nasa.kepler.pi.worker.EmbeddedWorkerCluster;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.ParseException;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Superclass for classes that provide Test Data Generators and Automated
 * Feature Tests (AFTs). Supplies these with basic, common functionality for
 * configuration. This includes file properties, environment variables, seeding
 * of the datastore, and capture of test outputs.
 * <p>
 * Test data generators and AFTs must override the abstract method
 * {@link #createDatabaseContents()}, which is called within a transaction, to
 * seed or populate the database. You may also need to override
 * {@link #process()} to perform additional processing outside of the
 * transaction surrounding {@link #createDatabaseContents()}. The method
 * {@link #runPipeline(String)} can be called from within {@link #process()} to
 * run pipelines. Finally, you may override the {@link #done()} method to
 * perform additional processing after the database state has been preserved.
 * 
 * @see gov.nasa.kepler.aft.descriptor.TestDataSetDescriptorFactory.Type
 * @see gov.nasa.kepler.common.FilenameConstants
 * @see gov.nasa.kepler.common.SocEnvVars
 * 
 * @author Forrest Girouard
 * @author Bill Wohler
 */
public abstract class AbstractAutomatedFeatureTest {

    private static final Log log = LogFactory.getLog(AbstractAutomatedFeatureTest.class);

    private static enum Scheme {
        HSQLDB;

        public static Scheme byName(String name) {
            for (Scheme scheme : Scheme.values()) {
                if (scheme.toString()
                    .equalsIgnoreCase(name) || scheme.toString()
                    .replace('_', '-')
                    .equalsIgnoreCase(name)) {
                    return scheme;
                }
            }
            throw new IllegalArgumentException(String.format(
                "%s: invalid scheme name", name));
        }
    }

    public static final String HSQL_EXTENSION = ".hsql";

    /**
     * The name of the properties file used by this test (
     * {@value #AFT_KEPLER_CONFIG}).
     */
    public static final String AFT_KEPLER_CONFIG = "aft-" + KEPLER_CONFIG;

    /**
     * A property ({@value #AFT_ACTUAL_DIR_PROPERTY}) whose value is the root
     * directory in which the inputs and outputs of the AFTs are stored. This
     * includes copies of the log files and MATLAB runtime directories. If this
     * property is not set, then the value of {@code SOC_AFT_ROOT} is used;
     * otherwise {@code /path/to/aft} is used.
     */
    public static final String AFT_ACTUAL_DIR_PROPERTY = "aft.actualDir";

    /**
     * A property ({@value #AFT_EXISTING_HSQLDB_PROPERTY}) whose value is used
     * to specify the URI of an existing HSQLDB.
     */
    public static final String AFT_EXISTING_HSQLDB_PROPERTY = "aft.existingHsqldb";

    /**
     * A property ({@value #AFT_SEED_FS_PROPERTY}) whose value is the root
     * directory of an existing filestore that is used to seed the filestore.
     */
    public static final String AFT_SEED_FS_PROPERTY = "aft.fs.data.seed.dir";

    /**
     * A property ({@value #AFT_SEEDING_ENABLED_PROPERTY}) that controls whether
     * or not the datastore is to be seeded. Setting this property to
     * {@code false} is useful for debugging and for re-running a test with a
     * previously seeded datastore. The default value is {@code true}.
     */
    public static final String AFT_SEEDING_ENABLED_PROPERTY = "aft.seedingEnabled";

    /**
     * A property ({@value #TEST_DESCRIPTOR_PROPERTY}) whose value is the
     * current test data set descriptor. If this property is not set, then
     * {@code BASIC} is used.
     */
    public static final String TEST_DESCRIPTOR_PROPERTY = "test.descriptor";

    /**
     * A path at which the test data set descriptor parameter library files are
     * located.
     */
    public static final String AFT_DESCRIPTORS_PARAMETERS_ROOT = "dev/aft/test-data-set-descriptors/";

    /**
     * A path at which the AFT pipeline configuration files are located.
     */
    public static final String AFT_PIPELINE_CONFIGURATION_ROOT = "dev/aft/pipelines/";

    /**
     * List of prefix regular expressions of the names of the database tables
     * that are created by this seed data. This list can be used to set the
     * table type from MEMORY to CACHED to save memory.
     */
    public static final List<String> TABLE_PREFIXES = Arrays.asList("PUBLIC\\.FC_");

    protected static final String MODEL_IMPORT_PARAMS = "modelImport";

    private static final String AFT_IMPORTER_TRIGGER = "AFT_IMPORTER";

    private static final boolean USE_XA_TRANSACTIONS = false;

    private static final int PING_DURATION = 1000 * 120;

    private String logName;
    private TestDataSetDescriptor testDescriptor;
    private String testActualRoot;
    private HsqldbManager hsqldbManager;

    private boolean seedingEnabled;
    private boolean importFcModels = true;
    private boolean allowFilestoreOverwrite;
    private EmbeddedWorkerCluster workerCluster;

    private int startCadence = -1;

    /**
     * Creates an {@code AbstractAutomatedFeatureTest} in the context of a test
     * data generator.
     */
    public AbstractAutomatedFeatureTest(String generatorName,
        TestDataSetDescriptor testDescriptor) {

        this(generatorName, null, testDescriptor);
    }

    /**
     * Creates an {@code AbstractAutomatedFeatureTest} in the context of a
     * automated feature test.
     */
    public AbstractAutomatedFeatureTest(String dirName, String testName) {
        this(dirName, testName, null);
    }

    /**
     * Creates an {@code AbstractAutomatedFeatureTest} overriding the default
     * test data set descriptor given by the {@value #TEST_DESCRIPTOR_PROPERTY}
     * property or {@code BASIC} if the property does not exist.
     * 
     * @param testDescriptor the test data set descriptor
     */
    public AbstractAutomatedFeatureTest(String dirName, String testName,
        TestDataSetDescriptor testDescriptor) {

        if (dirName == null) {
            throw new NullPointerException("dirName can't be null");
        }
        logName = dirName + (testName != null ? "/" + testName : "");

        if (testDescriptor == null) {
            this.testDescriptor = getTestDataSetDescriptor();
        } else {
            this.testDescriptor = testDescriptor;
        }
        log.info(logName + ": Using TestDataSetDescriptor = "
            + this.testDescriptor.getClass()
                .getName());

        String configPath = "etc/" + AFT_KEPLER_CONFIG;
        System.setProperty(
            ConfigurationServiceFactory.CONFIG_SERVICE_PROPERTIES_PATH_PROP,
            configPath);
        Configuration config = ConfigurationServiceFactory.getInstance();

        StringBuilder aftFullName = new StringBuilder(dirName);
        aftFullName.append(File.separator);
        if (testName != null) {
            aftFullName.append(testName);
            aftFullName.append("-");
        }
        aftFullName.append(TestDataSetDescriptorFactory.getName(getTestDescriptor()));

        testActualRoot = config.getString(AFT_ACTUAL_DIR_PROPERTY,
            SocEnvVars.getLocalAftDir())
            + File.separator + aftFullName;
        log.info(logName + ": testActualRoot = " + testActualRoot);

        hsqldbManager = new HsqldbManager();

        // Solution to KSOC-3711 (r54225) introduced an issue that causes all 
        // the AFTs to fail but running the HSQLDB server in a separate VM 
        // (process) is a viable workaround.
        hsqldbManager.setHsqldbInSeparateVm(true);

        seedingEnabled = ConfigurationServiceFactory.getInstance()
            .getBoolean(AFT_SEEDING_ENABLED_PROPERTY, true);
        log.info(logName + ": seedingEnabled = " + seedingEnabled);

        log.info(logName + ": Initializing transaction service");
        TransactionServiceFactory.setXa(USE_XA_TRANSACTIONS);
        MessagingServiceFactory.setUseXa(USE_XA_TRANSACTIONS);
        DatabaseServiceFactory.setUseXa(USE_XA_TRANSACTIONS);
    }

    /**
     * Creates a test data set descriptor. It uses the property
     * {@value #TEST_DESCRIPTOR_PROPERTY} to obtain the name of the descriptor.
     * If this property is not set, then {@code BASIC} is used.
     */
    private static final TestDataSetDescriptor getTestDataSetDescriptor() {

        // Get test descriptor from test.descriptor property, or fall back to
        // BASIC.
        String testDataSetAlias = System.getProperty(TEST_DESCRIPTOR_PROPERTY,
            "BASIC");
        TestDataSetDescriptor testDescriptor = null;
        try {
            testDescriptor = TestDataSetDescriptorFactory.createTestDescriptor(testDataSetAlias);
        } catch (InstantiationException e) {
            throw new PipelineException(
                "failure to determine test data set descriptor: "
                    + e.getMessage(), e);
        } catch (IllegalAccessException e) {
            throw new PipelineException(
                "failure to determine test data set descriptor: "
                    + e.getMessage(), e);
        }

        return testDescriptor;
    }

    /**
     * Returns the name of this generator or test. It is suggested to prefix
     * each log message with this.
     */
    protected String getLogName() {
        return logName;
    }

    /**
     * Returns the test data set descriptor for this test.
     */
    protected TestDataSetDescriptor getTestDescriptor() {
        return testDescriptor;
    }

    /**
     * Returns the root directory for the test products. For example,
     * {@code /path/to/aft/initdb/BASIC} or
     * {@code /path/to/aft/pa/Nominal-BASIC}.
     */
    protected String getTestActualRoot() {
        return testActualRoot;
    }

    HsqldbManager getHsqldbManager() {
        return hsqldbManager;
    }

    /**
     * Copies the content of the database into
     * {@value gov.nasa.kepler.common.FilenameConstants#KEPLER_SCRIPT} in the
     * specified directory.
     * 
     * @param directory the target directory
     */
    protected void captureDatabaseSnapshot(String directory) throws Exception {
        hsqldbManager.captureDatabaseSnapshot(directory);
    }

    /**
     * Run HSQLDB in separate VM.
     * 
     * @param hsqldbInSeparateVm {@code true}, if HSQLDB should be run in a
     * separate VM (default: {@code false})
     */
    protected void setHsqldbInSeparateVm(boolean hsqldbInSeparateVm) {
        hsqldbManager.setHsqldbInSeparateVm(hsqldbInSeparateVm);
    }

    /**
     * Controls whether the FC models are imported or not. The default is
     * {@code true}.
     * 
     * @param importFcModels {@code true} if this test data generator should
     * import FC models
     */
    protected void setImportFcModels(boolean importFcModels) {
        this.importFcModels = importFcModels;
    }

    /**
     * Sets whether or not a filestore is wiped out before it is seeded. The
     * default is {@code false}.
     * 
     * @param allowFilestoreOverwrite if {@code true}, the filestore is not
     * wiped out before it is seeded
     */
    protected void setAllowFilestoreOverwrite(boolean allowFilestoreOverwrite) {
        this.allowFilestoreOverwrite = allowFilestoreOverwrite;
    }

    final void run() throws InterruptedException {
        log.info(logName + ": Initializing transaction service");
        TransactionService transactionService = TransactionServiceFactory.getInstance();
        boolean databaseCreated = false;

        try {

            File schemaHsqldb = getExistingSchemaHsqldb(getTestDescriptor());
            if (schemaHsqldb != null) {
                log.info(logName + ": Using existing database: "
                    + schemaHsqldb.getPath());
                hsqldbManager.createDatabase(schemaHsqldb);
                removeStaleCacheIndicesFromSchema();
            } else {
                log.info(logName + ": Creating database");
                FileUtil.cleanDir(Filenames.BUILD_TEST);
                hsqldbManager.createDatabase();
                databaseCreated = true;
            }

            log.info(logName + ": Starting database");
            hsqldbManager.startDatabase();

            FileUtil.cleanDir(FilenameConstants.ACTIVEMQ_DATA);

            if (seedingEnabled) {
                log.info(logName + ": Seeding filestore");
                seedFilestore(allowFilestoreOverwrite);
            }

            log.info(logName + ": Starting filestore");
            startFilestore();

            if (databaseCreated) {
                transactionService.beginTransaction(true, false, false);
                configureAft();
                transactionService.commitTransaction();
            } else if (importFcModels) {
                log.info(logName + ": Running AFT pipeline");
                runPipeline(AFT_IMPORTER_TRIGGER);

                transactionService.beginTransaction(true, false, false);
                QuarterlyPipelineLauncherPipelineModule.setModuleOutputListsParameters();
                transactionService.commitTransaction();
            }

            if (seedingEnabled) {
                log.info(logName + ": Creating database contents");
                transactionService.beginTransaction(true, false, true);
                // TODO Remove the following if conditional and code block
                // when it is no longer needed for development.
                // if (new File(SocEnvVars.getLocalDataDir(),
                // AFT_DESCRIPTORS_PARAMETERS_ROOT + "debug.xml").exists()) {
                // new ParametersOperations().importParameterLibrary(new File(
                // SocEnvVars.getLocalDataDir(),
                // AFT_DESCRIPTORS_PARAMETERS_ROOT + "debug.xml"), null,
                // false);
                // }
                createDatabaseContents();
                transactionService.commitTransaction();
            }

            log.info(logName + ": Running process()");
            process();

            log.info(logName + ": Capture database snapshot");
            hsqldbManager.captureDatabaseSnapshot(getTestActualRoot());

            log.info(logName + ": Running done()");
            done();
        } catch (Exception e) {
            log.error(logName + ": " + e.getMessage());
            throw new PipelineException(e.getMessage(), e);
        } finally {
            transactionService.rollbackTransactionIfActive();

            if (workerCluster != null) {
                log.info(logName + ": Shutting down worker cluster");
                workerCluster.shutdown();
            }

            log.info(logName + ": Stopping filestore");
            stopFilestore();

            log.info(logName + ": Shutting down database");
            HsqldbUtils.shutdown(new ConnectInfo());
        }

        if (databaseCreated) {
            try {
                cacheTablesInSchema();
            } catch (IOException e) {
                log.error(logName + ": " + e.getMessage());
                throw new PipelineException(e.getMessage(), e);
            }
        }

        log.info(logName + ": Done");
    }

    /**
     * Determine the explicitly specified existing schema to use, if any. When
     * an AFT uses an existing HSQL schema the specific instance can be
     * specified using a system property, {@value #AFT_EXISTING_HSQLDB_PROPERTY}
     * . A simple property value is not sufficient as two pieces of information
     * are needed, the name of a test or data generator class and the name of a
     * data set.
     * <p>
     * A URI format is used for the value as follows:
     * 
     * <pre>
     *   hsqldb://&lt;i&gt;java-classname&lt;/i&gt;/&lt;i&gt;test-descriptor&lt;/i&gt;
     * </pre>
     * 
     * where the <i>java-classname</i> is the name of a class that extends
     * either {@link PipelineAutomatedFeatureTest} or
     * {@code AbstractTestDataGenerator} and the <i>test-descriptor</i> is the
     * name of the test data set descriptor.
     * <p>
     * To determine the HDQLDB instance from the configured property value first
     * an instance of the Java class is created in the context of the specified
     * test data set descriptor. Then the {@code getTestActualRoot} method is
     * invoked on that instance to get the top level write directory for that
     * test or data generator. Finally, the {@code File} return instance is
     * created by combining the actual test root directory and the value of the
     * {@code FilenameConstants.HSQLDB_SCHEMA} constant.
     * 
     * @param testDescriptor the test data set descriptor to use
     * @return a {@code File} instance for the location of the configured HSQLDB
     * schema
     * @throws ClassNotFoundException if the class specified by
     * {@value #AFT_EXISTING_HSQLDB_PROPERTY} cannot be located
     * @exception IllegalAccessException if the class specified by
     * {@value #AFT_EXISTING_HSQLDB_PROPERTY} or its nullary constructor is not
     * accessible
     * @exception InstantiationException if the class specified by
     * {@value #AFT_EXISTING_HSQLDB_PROPERTY} represents an abstract class, an
     * interface, an array class, a primitive type, or void; or if the class has
     * no nullary constructor; or if the instantiation fails for some other
     * reason
     * @throws URISyntaxException if the given string violates RFC&nbsp;2396, as
     * augmented by deviations listed in {@link URI#URI(String)}.
     */
    @SuppressWarnings("unchecked")
    private File getExistingSchemaHsqldb(TestDataSetDescriptor testDescriptor)
        throws ClassNotFoundException, IllegalAccessException,
        InstantiationException, URISyntaxException {

        String propertyValue = null;
        Type dataSetType = Type.valueOf(testDescriptor);

        propertyValue = System.getProperty(AFT_EXISTING_HSQLDB_PROPERTY);
        log.info(String.format(logName + ": %s has value of '%s'",
            AFT_EXISTING_HSQLDB_PROPERTY, propertyValue));
        if (propertyValue == null || propertyValue.length() == 0) {
            return null;
        }

        URI uri = new URI(propertyValue);
        String schemeName = uri.getScheme();
        Scheme scheme = null;

        try {
            if (schemeName == null || schemeName.length() == 0) {
                throw new IllegalArgumentException();
            }
            scheme = Scheme.byName(schemeName);
            if (scheme != Scheme.HSQLDB) {
                throw new IllegalArgumentException();
            }
        } catch (IllegalArgumentException iae) {
            throw new URISyntaxException(propertyValue, String.format(
                "Expected '%s' in URI scheme component but found '%s'",
                Scheme.HSQLDB.toString()
                    .toLowerCase(), schemeName));
        }

        String query = uri.getQuery();
        if (query != null && query.length() > 0) {
            log.warn(logName + ": Ignoring unexpected URI query component: "
                + propertyValue);
        }

        String className = uri.getHost();
        @SuppressWarnings("rawtypes")
        Class testClass = Class.forName(className);

        String path = uri.getPath();
        String dataSetName = path != null && path.length() > 1 ? path.substring(1)
            : null;
        if (dataSetName != null) {
            dataSetType = Type.valueOf(dataSetName);
        }

        log.info(String.format(
            "%s: Resolve dependency: creating instance of %s class"
                + " using %s test data set type to determine"
                + " relevant actual root from which to load"
                + " the existing database.", logName, className, dataSetType));

        String actualRoot = null;
        if (AutomatedFeatureTest.class.isAssignableFrom(testClass)) {
            actualRoot = AutomatedFeatureTest.getInstance(dataSetType,
                testClass)
                .getTestActualRoot();
        } else if (AbstractTestDataGenerator.class.isAssignableFrom(testClass)) {
            actualRoot = AbstractTestDataGenerator.getInstance(dataSetType,
                testClass)
                .getTestActualRoot();
        } else {
            throw new IllegalArgumentException(
                "unexpected Java classname in URI authority component: "
                    + propertyValue);
        }
        File schema = new File(actualRoot, FilenameConstants.HSQLDB_SCHEMA);
        assertReadableDirectory(schema);

        return schema;
    }

    /**
     * Asserts that the given file exists, is readable, is a directory, and is
     * not empty.
     * 
     * @param directory the directory
     */
    private void assertReadableDirectory(File directory) {
        assertNotNull(directory);
        assertTrue(directory + ": does not exist", directory.exists());
        assertTrue(directory + ": is unreadable", directory.canRead());
        assertTrue(directory + ": is not a directory", directory.isDirectory());
        assertTrue(directory + ": is empty", directory.list().length > 0);
    }

    /**
     * Loads the pipeline parameters and configuration.
     */
    private void configureAft() throws Exception {
        log.info(logName + ": Seeding AFT test descriptor parameters");
        new ParametersOperations().importParameterLibrary(
            new File(SocEnvVars.getLocalDataDir(),
                AFT_DESCRIPTORS_PARAMETERS_ROOT
                    + TestDataSetDescriptorFactory.getName(getTestDescriptor())
                        .replaceAll("_", "-")
                        .toLowerCase()), null, false);

        log.info(logName + ": Seeding AFT pipeline configuration");
        new PipelineConfigurationOperations().importPipelineConfiguration(new File(
            SocEnvVars.getLocalDataDir(), AFT_PIPELINE_CONFIGURATION_ROOT
                + "aft-importer.xml"));
    }

    /**
     * Creates a modified version of the default database initialization file
     * where specified tables have been removed from memory.
     */
    private void cacheTablesInSchema() throws IOException {
        log.info(logName
            + ": Creating cached tables with the following prefixes: "
            + TABLE_PREFIXES);
        updateSchema("CREATE MEMORY TABLE ", new CachedTableUpdater(
            "CREATE CACHED TABLE "));
    }

    /**
     * Creates a modified version of the database by removing stale indices for
     * cached tables.
     */
    private void removeStaleCacheIndicesFromSchema() throws IOException {
        log.info(logName
            + ": Removing stale indices for cached tables with the following prefixes: "
            + TABLE_PREFIXES);
        updateSchema("SET TABLE ", new CachedTableIndexDeleter());
    }

    private void updateSchema(String sqlCommand, FindAction tableUpdater)
        throws IOException {

        File scriptFile = new File(FilenameConstants.BUILD_TEST_KEPLER_SCRIPT);

        if (!scriptFile.exists()) {
            throw new IllegalStateException(scriptFile + ": no such directory");
        }

        Pattern tablesPattern = createFindPattern(sqlCommand, TABLE_PREFIXES);
        File tmpFile = RegexEditor.findAndReplace(scriptFile, tablesPattern,
            tableUpdater, new File(Filenames.BUILD_TMP));

        if (!scriptFile.delete()) {
            throw new IOException("Could not delete " + scriptFile);
        }
        FileUtils.moveFile(tmpFile, scriptFile);
    }

    private Pattern createFindPattern(String sqlCommand, List<String> tables) {

        if (sqlCommand == null) {
            throw new NullPointerException("sqlCommand can't be null");
        }
        if (sqlCommand.length() == 0) {
            throw new IllegalArgumentException(
                "There must be an SQL schema command");
        }
        if (tables == null) {
            throw new NullPointerException("tables can't be null");
        }
        if (tables.size() == 0) {
            throw new IllegalArgumentException(
                "There must be at least one table");
        }

        StringBuffer regex = new StringBuffer();
        regex.append("^(")
            .append(sqlCommand)
            .append(")(")
            .append(RegexEditor.createCompoundRegex(tables))
            .append(")([^\\(]*)(.*)$");

        return Pattern.compile(regex.toString());
    }

    /**
     * Seeds the test's filestore (target) specified by the {@code fs.data.dir}
     * system property using an existing filestore (source) specified by the
     * {@value #AFT_SEED_FS_PROPERTY} property. The target filestore data is a
     * direct copy of the source filestore. In other words, all files are
     * removed from the target filestore location and the source filestore is
     * copied into it.
     * <p>
     * When the {@code allowOverwrite} parameter is {@code true} the target file
     * store is not wiped out before the source is copied.
     * 
     * @param allowOverwrite the target filestore is whatever was pre-existing
     * plus the source filestore data
     * @throws IOException if the directory specified by the {@code fs.data.dir}
     * property can't be cleaned out or created, or the files can't be copied to
     * it, or the files can't be read from the directory specified by the
     * {@value #AFT_SEED_FS_PROPERTY} property
     * @throws InterruptedException if the copy command was interrupted by
     * another thread
     */
    private void seedFilestore(boolean allowOverwrite) throws IOException,
        InterruptedException {

        Configuration config = ConfigurationServiceFactory.getInstance();

        String fsDataDir = config.getString(
            FileStoreConstants.FS_DATA_DIR_PROPERTY,
            FileStoreConstants.FS_DATA_DIR_DEFAULT);
        File fsData = new File(fsDataDir);
        if (fsData.exists() && fsData.isDirectory() && !allowOverwrite) {
            FileUtil.removeAll(fsData);
        }
        if (!fsData.exists()) {
            FileUtils.forceMkdir(fsData);
        }
        assertWritableDirectory(fsData, allowOverwrite);

        String fsDataSeedDir = config.getString(AFT_SEED_FS_PROPERTY);
        if (fsDataSeedDir != null && fsDataSeedDir.length() > 0) {
            File fsDataSeed = new File(fsDataSeedDir);
            assertReadableDirectory(fsDataSeed);
            log.info(String.format("%s: Seeding filestore: \n"
                + "\tsource='%s' (from '%s' configuration property)\n"
                + "\ttarget='%s' (from '%s' configuration property)", logName,
                fsDataSeedDir, AFT_SEED_FS_PROPERTY, fsDataDir,
                FileStoreConstants.FS_DATA_DIR_PROPERTY));

            FileUtil.copySparseFiles(fsDataSeed, fsData);
        } else {
            log.warn(String.format(
                "%s: %s configuration property not found or empty, "
                    + "%s target filestore not seeded", logName,
                AFT_SEED_FS_PROPERTY, fsDataDir));
        }
    }

    /**
     * Asserts that the given file exists, is writable, is a directory, and is
     * empty (unless {@code allowOverwrite} is true).
     * 
     * @param directory the directory
     * @param allowOverwrite if {@code true}, {@code directory} does not have to
     * be empty
     */
    private void assertWritableDirectory(File directory, boolean allowOverwrite) {
        assertNotNull(directory);
        assertTrue(directory + ": does not exist", directory.exists());
        assertTrue(directory + ": is unwritable", directory.canWrite());
        assertTrue(directory + ": is not a directory", directory.isDirectory());
        assertTrue(directory + ": is not empty",
            allowOverwrite || directory.list().length == 0);
    }

    /**
     * Start filestore in its own thread.
     * 
     * @throws InterruptedException
     */
    private void startFilestore() throws InterruptedException {

        Thread filestore = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    AftFileStoreServer.startupServer();
                } catch (Exception e) {
                    throw new PipelineException(e.getMessage(), e);
                }
            }
        }, "AFT Filestore");

        filestore.setDaemon(true);
        filestore.start();

        // Test filestore client connectivity
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        long startTime = System.currentTimeMillis();
        long endTime = startTime + PING_DURATION;
        boolean pingable = false;
        do {
            Thread.sleep(1000);
            try {
                fsClient.ping();
                pingable = true;
                break;
            } catch (FileStoreException e) {
                // wait.
            }
        } while (System.currentTimeMillis() < endTime);

        if (!pingable) {
            throw new IllegalStateException(String.format(
                "Can't successfully ping filestore "
                    + "within %d seconds of startup", PING_DURATION / 1000));
        }
    }

    private void stopFilestore() throws InterruptedException {

        Thread filestore = new Thread(new Runnable() {
            @Override
            public void run() {
                try {
                    Server.main(new String[] { "shutdown" });
                } catch (Exception e) {
                    throw new PipelineException(e.getMessage(), e);
                }
            }
        }, "AFT Filestore (shutdown)");

        filestore.start();
        Thread.sleep(10000);
    }

    /**
     * Seeds the database. Note that the database may already have contents if
     * {@link HsqldbManager#isUseExistingInstance()} is {@code true}. Data is
     * typically added to the database programmatically by calling a
     * {@code FooSeedData.loadSeedData} method. However, a notification message
     * for data receipt can be generated as well.
     * <p>
     * The {@code FooSeedData.loadSeedData} method typically only adds enough
     * information to run a pipeline. It is a subsequent run of the pipeline
     * called from {@link #process()} that is responsible for the actual
     * population of the datastore.
     * <p>
     * This method is called within the context of a transaction.
     */
    protected abstract void createDatabaseContents() throws Exception;

    /**
     * Retrieves the name of the planetary target list from the database. Note
     * this method must be called within the context of a transaction.
     * 
     * @return the name of the planetary target list
     */
    protected String getPlanetaryTargetListName() {

        List<TargetList> targetLists = new TargetSelectionCrud().retrieveAllTargetLists();
        for (TargetList targetList : targetLists) {
            if (targetList.getCategory()
                .equalsIgnoreCase("planetary")) {
                return targetList.getName();
            }
        }

        return null;
    }

    /**
     * Populates the datastore. Typically, this method contains a call to
     * {@link #runPipeline(String)} to populate the datastore.
     * <p>
     * This is run outside of a transaction. This method is optional. The
     * default implementation does nothing. This method is called within a
     * try/catch block that rolls back any open transactions using the
     * transaction service returned by the {@link TransactionServiceFactory}.
     * 
     * @see #runPipeline(String)
     * @see TransactionService
     * @see TransactionServiceFactory
     */
    protected void process() throws Exception {
    }

    /**
     * Runs the pipeline associated with the given trigger name.
     * 
     * @param triggerName the trigger name
     * @throws Exception if there is a problem running the pipeline
     */
    protected void runPipeline(String triggerName) throws Exception {
        runPipeline(triggerName, null, null);
    }

    /**
     * Runs the pipeline associated with the given trigger name.
     * 
     * @param triggerName the trigger name
     * @param startNode the starting node, or {@code null} to start at the
     * beginning of the pipeline
     * @param endNode the ending node, or {@code null} to run to the end of the
     * pipeline
     * @throws Exception if there is a problem running the pipeline
     */
    protected void runPipeline(String triggerName,
        PipelineDefinitionNode startNode, PipelineDefinitionNode endNode)
        throws Exception {

        log.info(String.format("%s: Running %s pipeline", logName, triggerName));
        getWorkerCluster().runPipeline(triggerName, startNode, endNode);
    }

    private EmbeddedWorkerCluster getWorkerCluster() {
        if (workerCluster == null) {
            // No transaction needed for the workers since they manage their own
            // transactions
            workerCluster = new EmbeddedWorkerCluster();
            // The internal HSQLDB database is not thread-safe.
            workerCluster.setNumWorkerThreads(1);
            workerCluster.start();
        }

        return workerCluster;
    }

    /**
     * Performs additional processing after the database state has been
     * preserved.
     * <p>
     * This is run outside of a transaction. This method is optional. The
     * default implementation does nothing. This method is called within a
     * try/catch block that rolls back any open transactions using the
     * transaction service returned by the {@link TransactionServiceFactory}.
     * 
     * @see TransactionService
     * @see TransactionServiceFactory
     */
    protected void done() throws Exception {
    }

    protected CadenceType getCadenceType() {
        ParameterSet parameters = retrieveParameterSet(CADENCE_TYPE);
        if (parameters == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", CADENCE_TYPE));
        }
        CadenceTypePipelineParameters cadenceTypePipelineParameters = parameters.parametersInstance();

        return cadenceTypePipelineParameters.cadenceType();
    }

    protected int getStartCadence() {
        if (startCadence < 0) {
            DataGenParameters dataGenParameters = new DataGenParameters();
            ParameterSet parameters = retrieveParameterSet(dataGenParameterSetName());
            if (parameters != null) {
                dataGenParameters = parameters.parametersInstance();
            }

            PlannedSpacecraftConfigParameters spacecraftConfigParameters = new PlannedSpacecraftConfigParameters();
            parameters = retrieveParameterSet(PLANNED_SPACECRAFT_CONFIG);
            if (parameters != null) {
                spacecraftConfigParameters = parameters.parametersInstance();
            }

            PackerParameters packerParameters = new PackerParameters();
            parameters = retrieveParameterSet(PACKER);
            if (parameters != null) {
                packerParameters = parameters.parametersInstance();
            }

            try {
                startCadence = new DataGenTimeOperations().getCadence(
                    dataGenParameters, spacecraftConfigParameters,
                    getCadenceType(), packerParameters.getStartDate());
            } catch (ParseException e) {
                throw new IllegalStateException(
                    "Could not calculate start cadence", e);
            }
        }

        return startCadence;
    }

    protected int getLongCadenceCount() {
        ParameterSet parameters = retrieveParameterSet(PACKER);
        if (parameters == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", PACKER));
        }
        PackerParameters packerParameters = parameters.parametersInstance();

        return packerParameters.getLongCadenceCount();
    }

    protected int getCadenceCount() {
        int cadenceCount = getLongCadenceCount();

        if (getCadenceType() == CadenceType.SHORT) {
            ParameterSet spacecraftConfigParameterSet = retrieveParameterSet(PLANNED_SPACECRAFT_CONFIG);
            if (spacecraftConfigParameterSet == null) {
                throw new NullPointerException(String.format(
                    "Missing \'%s\' parameter set", PLANNED_SPACECRAFT_CONFIG));
            }
            PlannedSpacecraftConfigParameters spacecraftConfigParameters = spacecraftConfigParameterSet.parametersInstance();

            cadenceCount *= spacecraftConfigParameters.getShortCadencesPerLongCadence();
        }

        return cadenceCount;
    }

    /**
     * Returns the ending cadence. The default is {@link #getStartCadence()} +
     * {@link TestDataSetDescriptor#getCadenceCount()} - 1.
     */
    protected int getEndCadence() {
        return getStartCadence() + getCadenceCount() - 1;
    }

    protected void updateCadenceRangeParameters() {

        ParameterSet lcCadenceRangeParameterSet = retrieveParameterSet("cadenceRange (LC)");
        if (lcCadenceRangeParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", "cadenceRange (LC)"));
        }
        CadenceRangeParameters lcCadenceRangeParameters = lcCadenceRangeParameterSet.parametersInstance();

        ParameterSet scCadenceRangeParameterSet = retrieveParameterSet("cadenceRange (SC)");
        if (scCadenceRangeParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", "cadenceRange (SC)"));
        }
        CadenceRangeParameters scCadenceRangeParameters = scCadenceRangeParameterSet.parametersInstance();

        if (getCadenceType() == CadenceType.LONG) {
            lcCadenceRangeParameters.setStartCadence(getStartCadence());
            lcCadenceRangeParameters.setEndCadence(getEndCadence());
            Pair<Integer, Integer> shortCadences = ModifiedJulianDate.longToShortCadences(Pair.of(
                lcCadenceRangeParameters.getStartCadence(),
                lcCadenceRangeParameters.getEndCadence()));
            scCadenceRangeParameters.setStartCadence(shortCadences.left);
            scCadenceRangeParameters.setEndCadence(shortCadences.right);
        } else {
            scCadenceRangeParameters.setStartCadence(getStartCadence());
            scCadenceRangeParameters.setEndCadence(getEndCadence());
            Pair<Integer, Integer> longCadences = ModifiedJulianDate.shortToLongCadences(Pair.of(
                scCadenceRangeParameters.getStartCadence(),
                scCadenceRangeParameters.getEndCadence()));
            lcCadenceRangeParameters.setStartCadence(longCadences.left);
            lcCadenceRangeParameters.setEndCadence(longCadences.right);
        }

        new PipelineOperations().updateParameterSet(lcCadenceRangeParameterSet,
            lcCadenceRangeParameters, false);
        new PipelineOperations().updateParameterSet(scCadenceRangeParameterSet,
            scCadenceRangeParameters, false);
    }

    /**
     * Returns the dataGen parameter set name based upon the cadence type.
     */
    protected String dataGenParameterSetName() {
        return dataGenParameterSetName(getCadenceType());
    }

    /**
     * Returns the dataGen parameter set name based upon the cadence type.
     */
    protected String dataGenParameterSetName(CadenceType cadenceType) {
        return DATA_GEN + " ("
            + (cadenceType == CadenceType.LONG ? "LC" : "SC") + ")";
    }

    /**
     * Retrieves the named parameter set from the database.
     * 
     * @param name parameter set name
     * @return a {@link ParameterSet}
     */
    protected ParameterSet retrieveParameterSet(String name) {
        return new ParameterSetCrud().retrieveLatestVersionForName(name);
    }

    /**
     * Retrieves the planned photometer configuration parameters associated with
     * the data set named in the packer parameters.
     * 
     * @return a {@link PlannedPhotometerConfigParameters} object
     */
    protected PlannedPhotometerConfigParameters retrievePlannedPhotometerConfigParameters() {

        ParameterSet packerParameterSet = retrieveParameterSet(PACKER);
        if (packerParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", PACKER));
        }
        PackerParameters packerParameters = packerParameterSet.parametersInstance();

        String plannedPhotometerConfigName = PLANNED_PHOTOMTER_CONFIG
            + QuarterlyPipelineLauncherPipelineModule.parameterSetNameVariantString(packerParameters.getDataSetName());
        ParameterSet plannedPhotometerParameterSet = retrieveParameterSet(plannedPhotometerConfigName);
        if (plannedPhotometerParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", plannedPhotometerConfigName));
        }
        PlannedPhotometerConfigParameters plannedPhotometerConfigParameters = plannedPhotometerParameterSet.parametersInstance();

        return plannedPhotometerConfigParameters;
    }

    /**
     * Seeds the spice kernel.
     */
    protected void seedSpice() {
        log.info(getLogName() + ": Seeding spice files");
        ParameterSet modelImportParameterSet = retrieveParameterSet(MODEL_IMPORT_PARAMS);
        if (modelImportParameterSet == null) {
            throw new NullPointerException(String.format(
                "Missing \'%s\' parameter set", MODEL_IMPORT_PARAMS));
        }
        ModelImportParameters modelImportParameters = modelImportParameterSet.parametersInstance();
        new SpiceSeeder(getTestDescriptor()).seed(modelImportParameters);
    }

    /**
     * A find action to perform on text matching a regular expression that
     * replaces the first capture group in the matched input with the given
     * prefix.
     * 
     * @author Forrest Girouard
     */
    private static class CachedTableUpdater implements FindAction {

        private final String prefix;

        public CachedTableUpdater(String prefix) {
            this.prefix = prefix;
        }

        @Override
        public String update(Matcher matcher) {

            if (matcher.groupCount() < 2) {
                throw new IllegalStateException(matcher.groupCount()
                    + ": expected at least two capture groups");
            }
            StringBuilder builder = new StringBuilder(prefix);
            for (int group = 2; group <= matcher.groupCount(); group++) {
                builder.append(matcher.group(group));
            }

            return builder.toString();
        }
    }

    /**
     * A find action to perform on text matching a regular expression that
     * deletes the matched input.
     * 
     * @author Bill Wohler
     */
    private static class CachedTableIndexDeleter implements FindAction {

        @Override
        public String update(Matcher matcher) {

            return null;
        }
    }
}