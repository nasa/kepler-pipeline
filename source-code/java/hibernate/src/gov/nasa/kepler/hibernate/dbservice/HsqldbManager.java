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

package gov.nasa.kepler.hibernate.dbservice;

import gov.nasa.kepler.common.DefaultProperties;
import gov.nasa.kepler.common.FilenameConstants;

import java.io.File;
import java.io.IOException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class manages an instance of the HSQLDB database server.
 * 
 * This class is typically used by automated feature tests (AFTs) and classes
 * that generate .hsql seed data files for use by AFTs.
 * 
 * It provides the following functionality.
 * 
 * <pre>
 *  - Setup the config service to use HSQLDB
 *  - Setup the HSQLDB files using .hsql files specified by the user
 *  - Start the HSQLDB server
 *  - Checkpoint and capture the state (or a subset) of the database after a test
 * </pre>
 * 
 * @author Forrest Girouard
 * @author tklaus
 * 
 */
public class HsqldbManager {
    private static final Log log = LogFactory.getLog(HsqldbManager.class);

    /** Set this property to override the location of the seed .hsql files */
    public static final String HSQL_DIR_PROP = "aft.hsqlDir";

    /**
     * Otherwise, this field holds the fallback location of the seed .hsql
     * files.
     */
    private String hsqldbDir = FilenameConstants.BUILD_TEST_HSQLDB;

    private ConnectInfo connectInfo;
    private boolean hsqldbInSeparateVm = false;
    private boolean initialize = false;

    public HsqldbManager() {
        connectInfo = new ConnectInfo();
    }

    public void createDatabase() throws Exception {
        shutdown();

        log.info("Cleaning schema directory");
        HsqldbUtils.cleanSchemaDir();

        initialize = true;
    }

    public void createDatabase(File schemaHsqldb) throws Exception {

        if (schemaHsqldb != null && schemaHsqldb.exists()
            && new File(schemaHsqldb, FilenameConstants.KEPLER_SCRIPT).exists()) {

            shutdown();

            log.info("Cleaning schema directory");
            HsqldbUtils.cleanSchemaDir();

            log.info("Initializing database with " + schemaHsqldb.getPath());
            FileUtils.copyDirectory(schemaHsqldb, new File(
                DefaultProperties.getHsqldbSchemaDir()));
        } else {
            log.info("Using existing schema directory "
                + DefaultProperties.getHsqldbSchemaDir());
        }
    }

    public void startDatabase() throws IOException {

        if (hsqldbInSeparateVm) {
            log.info("Starting HSQLDB Server in separate VM");
            HsqldbUtils.startNetworkDatabaseInNewVm(false);
        } else {
            log.info("Starting HSQLDB Server in same VM");
            HsqldbUtils.startNetworkDatabase(false);
        }

        log.info("Creating database service instance");
        DatabaseService databaseService = DatabaseServiceFactory.getInstance();
        databaseService.rollbackTransactionIfActive();

        if (initialize) {
            log.info("Clearing database");
            databaseService.clear();

            log.info("Initializing database with DdlInitializer");
            databaseService.getDdlInitializer()
                .initDB();
        }

        databaseService.closeCurrentSession();
    }

    /**
     * try to shutdown any existing instances
     */
    public void shutdown() {
        try {
            log.info("Checking for existing server instances");
            log.info("connecting to: " + connectInfo.getUrl());
            HsqldbUtils.shutdown(connectInfo);
        } catch (Throwable justInCaseThereWasAnInstanceRunning) {
        }
    }

    public String getHsqldbDir() {
        Configuration config = ConfigurationServiceFactory.getInstance();

        return config.getString(HSQL_DIR_PROP, hsqldbDir);
    }

    public void captureDatabaseSnapshot(String directory) throws Exception {

        File schemaDir = new File(DefaultProperties.getHsqldbSchemaDir());
        if (schemaDir.exists()) {

            log.info("Close database session ...");
            DatabaseServiceFactory.getInstance()
                .closeCurrentSession();

            log.info("Checkpointing database");
            HsqldbUtils.checkpoint(connectInfo);
            Thread.sleep(5000);

            log.info("Taking database snapshot");
            File output = new File(directory, FilenameConstants.HSQLDB_SCHEMA);
            FileUtils.deleteDirectory(output);
            FileUtils.forceMkdir(output);
            File script = new File(schemaDir, FilenameConstants.KEPLER_SCRIPT);
            FileUtils.copyFileToDirectory(script, output);
        } else {
            log.info(schemaDir + ": does not exist, snapshot failed.");
        }

    }

    /**
     * @return the hsqldbInSeparateVm
     */
    public boolean isHsqldbInSeparateVm() {
        return hsqldbInSeparateVm;
    }

    /**
     * @param hsqldbInSeparateVm the hsqldbInSeparateVm to set
     */
    public void setHsqldbInSeparateVm(boolean hsqldbInSeparateVm) {
        this.hsqldbInSeparateVm = hsqldbInSeparateVm;
    }
}
