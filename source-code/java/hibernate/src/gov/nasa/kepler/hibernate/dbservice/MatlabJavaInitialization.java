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

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.spiffy.common.os.OperatingSystemType;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.net.InetAddress;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.xml.DOMConfigurator;

/**
 * Provides initialization logic for java code called from MATLAB
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class MatlabJavaInitialization {
    private static final Log log = LogFactory.getLog(MatlabJavaInitialization.class);

    /**
     * Property in the config service that points to the log4j.xml file used by
     * Java code called from MATLAB
     */

    public static final String LOG4J_MATLAB_CONFIG_FILE_PROP = "matlab.log4j.config";
    public static final String LOG4J_MATLAB_CONFIG_INITIALIZE_PROP = "matlab.log4j.initialize";
    public static final String LOG4J_LOGFILE_PREFIX = "log4j.logfile.prefix";
    public static final String MATLAB_PIDS_FILENAME = ".matlab.pids";

    private static final String DEFAULT_LOG4J_LOGFILE_PREFIX = "${kepler.config.dir}/../logs/matlab";

    private static boolean initialized = false;

    /**
     * Initialize log4j and the Config service for Java code called from MATLAB.
     * 
     * We have a bootstrapping problem here. We'd like to have a config property
     * that points to the log4j.xml file that the MATLAB/Java code should use,
     * but we would also like to have logging configured before we initialize
     * the Config service so that we can see that the config is coming from the
     * correct source. So, we follow this sequence:
     * 
     * 1- Initialize log4j with the BasicConfigurator (just log to console,
     * which gets captured by the java worker process that launched MATLAB) 
     * 2- Initialize the config service 
     * 3- Re-initialize log4j with the config service property
     * 
     * @throws PipelineException
     * 
     */
    public static synchronized void initialize() {

        if (!initialized) {
            System.out.println("MatlabJavaInitialization: Initializing log4j with BasicConfigurator");

            BasicConfigurator.configure();

            log.info("Log4j initialized with BasicConfigurator, initializing Config service");

            Configuration config = ConfigurationServiceFactory.getInstance();

            if(config.getBoolean(LOG4J_MATLAB_CONFIG_INITIALIZE_PROP, false)){
                String log4jConfigFile = config.getString(LOG4J_MATLAB_CONFIG_FILE_PROP);

                log.info(LOG4J_MATLAB_CONFIG_FILE_PROP + " = " + log4jConfigFile);

                if (log4jConfigFile != null) {
                    log.info("Log4j initialized with DOMConfigurator from: "
                        + log4jConfigFile);
                    System.setProperty(LOG4J_LOGFILE_PREFIX,
                        DEFAULT_LOG4J_LOGFILE_PREFIX);
                    DOMConfigurator.configure(log4jConfigFile);
                }
            }

            log.info("jvm version:");
            log.info("  java.runtime.name="
                + System.getProperty("java.runtime.name"));
            log.info("  sun.boot.library.path="
                + System.getProperty("sun.boot.library.path"));
            log.info("  java.vm.version="
                + System.getProperty("java.vm.version"));

            log.info(KeplerSocVersion.getProject());
            log.info("  Release: " + KeplerSocVersion.getRelease());
            log.info("  Revision: " + KeplerSocVersion.getRevision());
            log.info("  SVN URL: " + KeplerSocVersion.getUrl());
            log.info("  Build Date: " + KeplerSocVersion.getBuildDate());
            
            try{
                int pid = OperatingSystemType.getInstance().getProcInfo().getPid();
                log.info("process ID: " + pid);
                recordPid(pid);
            }catch(Throwable t){
                log.warn("Unable to get process ID: " + t);
            }
            
            initialized = true;
        }
    }
    
    private static void recordPid(int pid) throws Exception{
        String hostname = "<unknown>";
        try {
            hostname = InetAddress.getLocalHost().getHostName();
            int dot = hostname.indexOf(".");
            if(dot != -1){
                hostname = hostname.substring(0,  dot);
            }
        } catch (Exception e) {
            log.warn("failed to get hostname", e);
        }
       
        String PID_FILE = MATLAB_PIDS_FILENAME;
        
        File pidFile = new File(PID_FILE);
        FileUtils.writeStringToFile(pidFile, hostname + ":" + pid + "\n");
    }
}
