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

package gov.nasa.kepler.services.configuration;

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.File;
import java.io.IOException;

import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Update properties files in place.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class ConfigWorker {
    private static final Log log = LogFactory.getLog(ConfigWorker.class);

    private static final String JVM_MAX_HEAP_PROP_NAME = "wrapper.java.maxmemory";
    private static final String WORKER_NUM_TASK_THREADS_PROP_NAME = "pi.worker.numTaskThreads";
    private static final String WORKER_WRAPPER_CONF_PATH = "worker.wrapper.conf";
    private static final String KEPLER_PROPERTIES_PATH = "kepler.properties";

    private String numThreads;
    private String jvmMaxHeapMb;

    public ConfigWorker() {
    }
    
    public ConfigWorker(String numThreads, String jvmMaxHeapMb) {
        this.numThreads = numThreads;
        this.jvmMaxHeapMb = jvmMaxHeapMb;
    }

    /**
     * Update kepler.properties and worker.wrapper.conf in a built dist
     * tree with the specified worker heap size and number of threads.
     * 
     * The following files and properties are updated:
     * 
     * dist/etc/kepler.properties:pi.worker.numTaskThreads
     * dist/etc/worker.wrapper.conf:wrapper.java.maxmemory (in MB)
     * 
     * @throws Exception
     */
    public void merge() throws Exception {
        ConfigurationServiceFactory.getInstance(); // initialize config service
        String configDirPath = System.getProperty(ConfigurationServiceFactory.KEPLER_CONFIG_DIR_PROP);
        File keplerPropsFile = new File(configDirPath, KEPLER_PROPERTIES_PATH);
        File workerConfFile = new File(configDirPath, WORKER_WRAPPER_CONF_PATH);
        
        update(keplerPropsFile, WORKER_NUM_TASK_THREADS_PROP_NAME, numThreads);
        update(workerConfFile, JVM_MAX_HEAP_PROP_NAME, jvmMaxHeapMb);
    }

    /**
     * Update the specified file with the specified property change.
     * 
     * @param propertiesFile
     * @param propertyName
     * @param newPropertyValue
     * @throws Exception
     */
    public void update(File propertiesFile, String propertyName, String newPropertyValue) throws Exception{
        if (!propertiesFile.exists()) {
            throw new Exception("propertiesFile: " + propertiesFile + " does not exist");
        }

        String oldInclude = PropertiesConfiguration.getInclude();
        
        try{
            PropertiesConfiguration config = new PropertiesConfiguration(propertiesFile);
            PropertiesConfiguration.setInclude("#include"); 
            config.setAutoSave(true);
            
            String oldValue = config.getString(propertyName);
            
            config.setProperty(propertyName, newPropertyValue);

            log.info("Updated properties file: " + propertiesFile 
                + ", name: " + propertyName + " = " + oldValue + " -> " + newPropertyValue);
        }finally{
            PropertiesConfiguration.setInclude(oldInclude); 
        }
    }
    
    /**
     * Command-line interface
     * 
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) {

        if (args.length != 2) {
            System.err.println("USAGE: config-worker NUM_THREADS JVM_MAX_HEAP");
            System.err.println("  example: config-worker 4 32768");
            System.exit(-1);
        }

        try {
            String numThreads = args[0];
            String jvmMaxHeapMb = args[1];

            ConfigWorker configMerge = new ConfigWorker(numThreads, jvmMaxHeapMb);
            configMerge.merge();

        } catch (Throwable e) {
            System.err.println("config-worker failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(-1);
        }
        System.exit(0);
    }
}
