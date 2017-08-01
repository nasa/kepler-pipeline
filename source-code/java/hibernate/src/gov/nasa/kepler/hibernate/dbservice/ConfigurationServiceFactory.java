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

import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.net.URL;

import javax.sql.DataSource;

import org.apache.commons.configuration.CompositeConfiguration;
import org.apache.commons.configuration.Configuration;
import org.apache.commons.configuration.ConfigurationUtils;
import org.apache.commons.configuration.DatabaseConfiguration;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.configuration.SystemConfiguration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 * 
 */
public class ConfigurationServiceFactory {
    private static final Log log = LogFactory.getLog(ConfigurationServiceFactory.class);

    /**
     * Name of the Java system property that contains the path to the
     * configuration file (nominally called kepler.properties). If this system
     * property is set, then the PropertiesConfiguration will be set to this
     * path.
     */
    public static final String CONFIG_SERVICE_PROPERTIES_PATH_PROP = "config.propfile";

    /**
     * Name of the Java system property that contains the path to an override
     * configuration file.  Properties in the override file will be merged with
     * the properties in the base configuration file, with the values in the override
     * file taking precedence.
     */
    public static final String CONFIG_SERVICE_OVERRIDE_PATH_PROP = "config.override.path";
    
    /**
     * Name of the Java system property that contains the name of an override configuration to
     * load, as a shortcut to specifying the full path of the override path.  If this 
     * property is set, the override file will be loaded using the path
     * ~/.soc/NAME.properties, where NAME is the value of this property.
     * Properties in the override file will be merged with the properties in the 
     * base configuration file, with the values in the override file taking precedence.
     * If this property is set, the CONFIG_SERVICE_OVERRIDE_PATH_PROP property is ignored.
     */
    public static final String CONFIG_SERVICE_OVERRIDE_NAME_PROP = "config.override.name";
    
    /**
     * Name of the boolean property that specifies whether the
     * {@link CompositeConfiguration} will include a
     * {@link DatabaseConfiguration} (reading properties from a database table).
     */
    public static final String CONFIG_SERVICE_USE_DB_PROP = "config.use.database.config";

    /**
     * Name of the Java system property that contains the path to the
     * configuration file (nominally called kepler.properties) used by Java code
     * called from MATLAB. If this system property is set, then the
     * CONFIG_SERVICE_PROPERTIES_PATH_ENV (see below) environment variable for
     * the MATLAB process will be set to point to this file instead of the
     * config file used by the invoking Java process (the default).
     */
    public static final String CONFIG_SERVICE_MATLAB_OVERRIDE_PROPERTIES_PATH_PROP = "config.matlab.override.propfile";

    /**
     * Name of the environment variable (as defined by System.getenv()) that
     * contains the path to the configuration file (nominally called
     * kepler.properties). If this environment variable is set *and* the Java
     * system property (see above) is *not* set, then the
     * PropertiesConfiguration will be set to this path.
     */
    public static final String CONFIG_SERVICE_PROPERTIES_PATH_ENV = "KEPLER_CONFIG_PATH";

    public static final String DEFAULT_CONFIG_PROPFILE_NAME = "kepler.properties";

    /**
     * This system property is set by this class to point to the directory that
     * contains the properties file. This allows other properties to be
     * specified relative to the directory that contains the properties file,
     * using the form myFile=${kepler.config.dir}/../foo/bar/myfile.txt
     */
    public static final String KEPLER_CONFIG_DIR_PROP = "kepler.config.dir";

    private static final String DATABASE_CONFIG_TABLE_NAME = "PI_KV_PAIR";
    private static final String DATABASE_CONFIG_TABLE_KEY_COLUMN_NAME = "KEYNAME";
    private static final String DATABASE_CONFIG_TABLE_VALUE_COLUMN_NAME = "VALUE";

    private static CompositeConfiguration instance = null;

    private static File configPropertiesFile = null;

    public ConfigurationServiceFactory() {
    }

    private static void initialize() {
        log.debug("initialize() - start");

        /*
         * The search order for finding the configuration properties file is as
         * follows:
         * 
         * if the CONFIG_SERVICE_PROPERTIES_PATH_PROP system property is set,
         * use this path (in this case, the property file can be found either in
         * the filesystem, or in the classpath, in that order) else if the
         * CONFIG_SERVICE_PROPERTIES_PATH_ENV environment variable is set, use
         * this path else if DEFAULT_CONFIG_PROPFILE_NAME exists in the ./etc
         * directory use this path else don't read any configuration from a
         * properties file
         */
        try {
            configPropertiesFile = null;
            String configFileSystemPropertyValue = System.getProperty(CONFIG_SERVICE_PROPERTIES_PATH_PROP);
            URL configUrl = null;

            if (configFileSystemPropertyValue != null) {
                log.info("found system property: " + CONFIG_SERVICE_PROPERTIES_PATH_PROP + " = "
                    + configFileSystemPropertyValue);

                configPropertiesFile = new File(configFileSystemPropertyValue);

                if (!configPropertiesFile.exists()) {
                    // Try the classpath.
                    configUrl = ConfigurationServiceFactory.class.getResource(configFileSystemPropertyValue);
                    if (configUrl == null) {
                        throw new PipelineException("Config file pointed to by the "
                            + CONFIG_SERVICE_PROPERTIES_PATH_PROP + " system property does not exist: "
                            + configPropertiesFile.getAbsolutePath());
                    }
                }
            } else {
                String configFileEnvValue = System.getenv(CONFIG_SERVICE_PROPERTIES_PATH_ENV);

                if (configFileEnvValue != null) {
                    log.info("found environment variable: " + CONFIG_SERVICE_PROPERTIES_PATH_ENV + " = "
                        + configFileEnvValue);

                    configPropertiesFile = new File(configFileEnvValue);

                    if (!configPropertiesFile.exists()) {
                        throw new PipelineException("Config file pointed to by the "
                            + CONFIG_SERVICE_PROPERTIES_PATH_ENV + " environment variable does not exist: "
                            + configPropertiesFile.getAbsolutePath());
                    }
                } else {
                    String defaultLocation = "etc/" + DEFAULT_CONFIG_PROPFILE_NAME;

                    log.info("looking in default location: " + defaultLocation);

                    // development environment location
                    configPropertiesFile = new File(defaultLocation);
                }
            }

            instance.addConfiguration(new SystemConfiguration());

            if (configUrl != null) {
                log.info("Loading configuration from: " + configUrl.toString());
                instance.addConfiguration(new PropertiesConfiguration(configUrl));
            } else if (configPropertiesFile != null && configPropertiesFile.exists()) {

                log.info("Loading configuration from: " + configPropertiesFile.getAbsolutePath());

                /*
                 * This allows other properties to be specified relative to the
                 * directory that contains kepler.properties, using the form
                 * myFile=${kepler.config.dir}/../foo/bar/myfile.txt
                 */
                System.setProperty(KEPLER_CONFIG_DIR_PROP, configPropertiesFile.getParentFile().getAbsolutePath());

                instance.addConfiguration(new PropertiesConfiguration(configPropertiesFile));
            } else {
                log.info("No config properties file found, not loading any properties from a file");
            }

            boolean useDb = instance.getBoolean(CONFIG_SERVICE_USE_DB_PROP, false);
            if (useDb) {
                log.info("useDb=true, reading properties from the database");

                DataSource dataSource = DataSourceFactory.createDataSource(instance);
                
                instance.addConfiguration(new DatabaseConfiguration(dataSource, DATABASE_CONFIG_TABLE_NAME,
                    DATABASE_CONFIG_TABLE_KEY_COLUMN_NAME, DATABASE_CONFIG_TABLE_VALUE_COLUMN_NAME));
            }
            
            /* next, merge in any properties in the override file, if specified */
            String overridePath;
            String overrideName = System.getProperty(CONFIG_SERVICE_OVERRIDE_NAME_PROP);
            if(overrideName != null && overrideName.length() > 0){
                overridePath = System.getProperty("user.home") + "/.soc/" + overrideName + ".properties"; 
                log.info(CONFIG_SERVICE_OVERRIDE_NAME_PROP + " is set, using config override path: " + overridePath);
            }else{
                overridePath = System.getProperty(CONFIG_SERVICE_OVERRIDE_PATH_PROP);
                if(overridePath != null && overridePath.length() > 0){
                    log.info(CONFIG_SERVICE_OVERRIDE_PATH_PROP + " is set, using config override path: " + overridePath);
                }
            }

            if(overridePath != null && overridePath.length() > 0){
                File overrideFile = new File(overridePath);

                log.info("Loading config override file: " + overrideFile);
                
                if (!overrideFile.exists()) {
                    throw new Exception("Config override file is specified, but this file does not exist: " + overrideFile);
                }

                PropertiesConfiguration overrideConfig = new PropertiesConfiguration(overrideFile);

                // Override the values in the base config with the values from the override file
                ConfigurationUtils.copy(overrideConfig, instance);
            }
        } catch (Exception e) {
            log.error("ConfigurationService failed to initialize", e);
            throw new PipelineException("ConfigurationService failed to initialize", e);
        }

        log.debug("initialize() - end");
    }

    public static synchronized Configuration getInstance() {
        if (instance == null) {
            instance = new CompositeConfiguration();
            initialize();
        }
        return instance;
    }

    public static synchronized void reset() {
        instance = null;
    }

    /**
     * This is the location of the .properties file found by the search
     * algorithm defined in the getInstance() method above. If no .properties
     * file was found, this property will be null.
     * 
     * This value is passed down to MATLAB sub-processes as an environment
     * variable so that Java code called from MATLAB can find it (via this class
     * in the sub-process JVM)
     * 
     * @return the configPropertiesFile
     */
    public static File getConfigPropertiesFile() {
        return configPropertiesFile;
    }

    /**
     * 
     * @param config
     * @return
     * @throws SQLException
     */
    // private static DataSource createDataSource( Configuration config ) throws
    // SQLException{
    //
    // String host = config.getString(
    // DatabaseService.DATABASE_HOST_PROPERTY_NAME );
    // int port = config.getInt( DatabaseService.DATABASE_PORT_PROPERTY_NAME );
    // String sid = config.getString( DatabaseService.DATABASE_SID_PROPERTY_NAME
    // );
    // String user = config.getString(
    // DatabaseService.DATABASE_USER_PROPERTY_NAME );
    // String password = config.getString(
    // DatabaseService.DATABASE_PASSWORD_PROPERTY_NAME );
    //      
    // OracleDataSource ods = new OracleDataSource();
    // ods.setDriverType("thin");
    // ods.setServerName( host );
    // ods.setNetworkProtocol("tcp");
    // ods.setDatabaseName( sid );
    // ods.setPortNumber( port );
    // ods.setUser( user );
    // ods.setPassword( password );
    //
    // return ods;
    // }
}