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

package gov.nasa.kepler.services.process;

import gov.nasa.kepler.common.KeplerSocVersion;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactory;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.metrics.Metric;

import java.net.InetAddress;
import java.net.UnknownHostException;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.tanukisoftware.wrapper.WrapperManager;

/**
 * Superclass for all pipeline process bootstrap classes. Provides common
 * functionality, including starting the {@link StatusMessageBroadcaster} for
 * broadcasting {@link Metric}s, and a JMS listener for handling basic
 * administrative functions (shutdown, restart, status, pause, resume, etc.)
 * 
 * "Pipeline processes" include daemons such as Data Receipt, Worker, File
 * Store, etc.
 * 
 * @author tklaus
 * 
 */
public abstract class AbstractPipelineProcess {
    private static final Log log = LogFactory.getLog(AbstractPipelineProcess.class);

    private static final String STATUS_BROADCASTER_ENABLED_PROP = "services.process.statusBroadcaster.enabled";
    private static final boolean STATUS_BROADCASTER_ENABLED_DEFAULT = true;
    private static final String ADMIN_LISTENER_ENABLED_PROP = "services.process.adminListener.enabled";
    private static final boolean ADMIN_LISTENER_ENABLED_DEFAULT = true;

    public static final String PROCESS_STATUS_REPORT_INTERVAL_MILLIS_PROP = "services.statusReport.process.reportIntervalMillis";
    public static final String METRICS_STATUS_REPORT_INTERVAL_MILLIS_PROP = "services.statusReport.metrics.reportIntervalMillis";

    public static final int REPORT_INTERVAL_MILLIS_DEFAULT = 60000;
    
    private boolean initMessagingService = true;
    private boolean initDatabaseService = true;

    protected static long startTime = System.currentTimeMillis();

    private static ProcessInfo processInfo = null;

    private StatusMessageBroadcaster processStatusBroadcaster;
    private PipelineProcessAdminListener adminListener;

    private ProcessStatusReporter processStatusReporter;
    //private MetricsStatusReporter metricsStatusReporter;

    public AbstractPipelineProcess(String name) {
        this(name, true, true);
    }

    public AbstractPipelineProcess(String name,
        boolean initMessagingService,
        boolean initDatabaseService) {

        this.initMessagingService = initMessagingService;
        this.initDatabaseService = initDatabaseService;

        String host = "?";
        try {
            host = InetAddress.getLocalHost().getHostName();
        } catch (UnknownHostException e) {
            log.warn("failed to get hostname", e);
        }

        int dotIdx = host.indexOf(".");
        if (dotIdx != -1) {
            host = host.substring(0, dotIdx);
        }

        int pid = 0;
        int jvmid = 0;
        if (WrapperManager.isControlledByNativeWrapper()) {
            pid = WrapperManager.getJavaPID();
            jvmid = WrapperManager.getJVMId();
        } else {
            log.info("JVM is NOT controlled by Native Wrapper");
        }

        processInfo = new ProcessInfo(name, host, pid, jvmid);
        XANodeNameFactory.setInstance(new XANodeNameFactory(name));
    }

    protected void initialize() {
        log.debug("initialize(String[]) - start");

        log.info("Starting initialization for Process: " + processInfo);
        log.info(KeplerSocVersion.getProject());
        log.info("  Release: " + KeplerSocVersion.getRelease());
        log.info("  Revision: " + KeplerSocVersion.getRevision());
        log.info("  SVN URL: " + KeplerSocVersion.getUrl());
        log.info("  Build Date: " + KeplerSocVersion.getBuildDate());

        log.info("jvm version:");
        log.info("  java.runtime.name="
            + System.getProperty("java.runtime.name"));
        log.info("  sun.boot.library.path="
            + System.getProperty("sun.boot.library.path"));
        log.info("  java.vm.version=" + System.getProperty("java.vm.version"));

        log.info("Initializing ConfigurationService...");
        Configuration configService = ConfigurationServiceFactory.getInstance();

        if (initDatabaseService) {
            log.info("Initializing DatabaseService...");
            DatabaseServiceFactory.getInstance();
        }

        if (initMessagingService) {
            log.info("Initializing MessagingService...");
            MessagingServiceFactory.getInstance();
        }

        boolean statusBroadcasterEnabled = configService.getBoolean(STATUS_BROADCASTER_ENABLED_PROP, 
            STATUS_BROADCASTER_ENABLED_DEFAULT);
        boolean adminListenerEnabled = configService.getBoolean(ADMIN_LISTENER_ENABLED_PROP, 
            ADMIN_LISTENER_ENABLED_DEFAULT);

        if(statusBroadcasterEnabled){
            log.info("Initializing StatusMessageBroadcaster...");
            processStatusBroadcaster = new StatusMessageBroadcaster(processInfo);

            processStatusReporter = new ProcessStatusReporter();
            //metricsStatusReporter = new MetricsStatusReporter();

            int processReportIntervalMillis = configService.getInt(PROCESS_STATUS_REPORT_INTERVAL_MILLIS_PROP, REPORT_INTERVAL_MILLIS_DEFAULT);
            processStatusBroadcaster.addStatusReporter(processStatusReporter, processReportIntervalMillis);

//            int metricsReportIntervalMillis = configService.getInt(METRICS_STATUS_REPORT_INTERVAL_MILLIS_PROP, REPORT_INTERVAL_MILLIS_DEFAULT);
//            processStatusBroadcaster.addStatusReporter(metricsStatusReporter, metricsReportIntervalMillis);
        }

        if(adminListenerEnabled){
            log.info("Initializing AdminListener...");
            adminListener = new PipelineProcessAdminListener(processInfo.getName(), processInfo.getHost());
            adminListener.start();
        }
        
        log.debug("initialize(String[]) - end");
    }

    protected void updateProcessState(ProcessStatusReporter.State newState){
        if(processStatusReporter != null){
            processStatusReporter.setState(newState);
        }
    }
    
    protected void addProcessStatusReporter(StatusReporter reporter, int reportIntervalMillis){
        if(processStatusBroadcaster != null){
            processStatusBroadcaster.addStatusReporter(reporter, reportIntervalMillis);
        }
    }
    
    public static long getStartTime() {
        return startTime;
    }

    public boolean isInitDatabaseService() {
        return initDatabaseService;
    }

    public boolean isInitMessagingService() {
        return initMessagingService;
    }

    public static ProcessInfo getProcessInfo() {
        return processInfo;
    }

    public void setInitMessagingService(boolean initMessagingService) {
        this.initMessagingService = initMessagingService;
    }

    public void setInitDatabaseService(boolean initDatabaseService) {
        this.initDatabaseService = initDatabaseService;
    }
    
    public void shutdownListeners(){
        try {
            adminListener.shutdown();
        } catch (InterruptedException e) {
            log.warn("failed to shut down listener, caught e = " + e, e );
        }
    }
}
