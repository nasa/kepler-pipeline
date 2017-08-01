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

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.commons.configuration.ConfigurationConverter;
import org.apache.commons.configuration.ConfigurationUtils;
import org.apache.commons.configuration.PropertiesConfiguration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Generates a cluster-specific kepler.properties file for deployment.
 * 
 * Prompts the user for the Oracle user/password, then merges the cluster-specific
 * template with a base kepler.properties and writes out a new
 * kepler.properties
 * 
 * @author tklaus
 * 
 */
public class ConfigMaker {
    private static final Log log = LogFactory.getLog(ConfigMaker.class);

    private String clusterTemplate;
    private String baseProperties;
    private String outputProperties;
    private String dbUser;
    private String dbPassword;

    public ConfigMaker(String clusterTemplate, String baseProperties, String outputProperties, String dbUser,
        String dbPassword) {
        this.clusterTemplate = clusterTemplate;
        this.baseProperties = baseProperties;
        this.outputProperties = outputProperties;
        this.dbUser = dbUser;
        this.dbPassword = dbPassword;
    }

    public void makeConfig() throws Exception {

        // Read cluster-specific template file
        File clusterTemplateFile = new File(clusterTemplate);
        log.info("reading cluster template file: " + clusterTemplateFile);

        if (!clusterTemplateFile.exists()) {
            throw new Exception("clusterTemplateFile: " + clusterTemplateFile + " does not exist");
        }

        PropertiesConfiguration clusterTemplateConfig = new PropertiesConfiguration(clusterTemplateFile);

        // Override database user & password in the template config
        clusterTemplateConfig.setProperty(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_USERNAME_PROP, dbUser);
        clusterTemplateConfig.setProperty(KeplerHibernateConfiguration.HIBERNATE_CONNECTION_PASSWORD_PROP, dbPassword);
                
        // Read the base kepler.properties
        File basePropertiesFile = new File(baseProperties);
        log.info("reading base file: " + basePropertiesFile);
        
        if (!basePropertiesFile.exists()) {
            throw new Exception("basePropertiesFile: " + basePropertiesFile + " does not exist");
        }

        PropertiesConfiguration baseConfig = new PropertiesConfiguration(basePropertiesFile);

        // Override the cluster-specific values in the base config
        ConfigurationUtils.copy(clusterTemplateConfig, baseConfig);
        
        // verify database creds
        log.info("verifying db connection");
        try {
            DatabaseServiceFactory.getInstance(ConfigurationConverter.getProperties(baseConfig));
        } catch (Exception e) {
            throw new Exception("login failed: " + e.getMessage());
        }

        // Write out the merged config .properties file
        File outputPropertiesFile = new File(outputProperties);
        log.info("writing merged file: " + outputPropertiesFile);
        BufferedWriter outputWriter = new BufferedWriter(new FileWriter(outputPropertiesFile));
        
        baseConfig.save(outputWriter);
    }

    /**
     * Hackey way to read a passwd from stdin without echoing the chars to the screen
     * @param in 
     * 
     * @param prompt The prompt to display to the user
     * @return The password as entered by the user
     */
    public static String readPassword(BufferedReader in, String prompt) {
        EraserThread et = new EraserThread(prompt);
        Thread mask = new Thread(et);
        mask.start();

        String password = "";

        try {
            password = in.readLine();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
        // stop masking
        et.stopMasking();
        // return the password entered by the user
        return password;
    }

    private static class EraserThread implements Runnable {
        private boolean stop;

        /**
         * @param The prompt displayed to the user
         */
        public EraserThread(String prompt) {
            System.out.print(prompt);
        }

        /**
         * Begin masking...display nothing
         */
        @SuppressWarnings("static-access")
        public void run() {
            stop = true;
            while (stop) {
                System.out.print("\010 ");
                try {
                    Thread.currentThread()
                        .sleep(1);
                } catch (InterruptedException ie) {
                    ie.printStackTrace();
                }
            }
        }

        /**
         * Instruct the thread to stop masking
         */
        public void stopMasking() {
            this.stop = false;
        }
    }

    /**
     * @param args
     * @throws IOException
     */
    public static void main(String[] args) {

        if (args.length != 3) {
            System.err.println("USAGE: config-maker CLUSTERFILE BASEPROPSFILE OUTPUTFILE");
            System.err.println("  example: config-maker ../etc/ops.template ../etc/kepler.properties ../etc/kepler.properties.production");
            System.exit(-1);
        }

        try {
            String clusterTemplate = args[0];
            String baseProperties = args[1];
            String outputfile = args[2];

            log.info("reading inputs");
            
            InputStreamReader converter = new InputStreamReader(System.in);
            BufferedReader in = new BufferedReader(converter);
            System.out.print("Database User: ");
            String dbUser = in.readLine();
            String dbPasswd = readPassword(in, "Database Password: ");
            in.readLine();

            ConfigMaker configMaker = new ConfigMaker(clusterTemplate, baseProperties, outputfile, dbUser, dbPasswd);
            configMaker.makeConfig();

        } catch (Throwable e) {
            System.err.println("config-maker failed: " + e.getMessage());
            e.printStackTrace();
            System.exit(-1);
        }
        System.exit(0);
    }
}
