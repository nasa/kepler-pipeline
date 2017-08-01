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

package gov.nasa.kepler.dr.dispatch;

import gov.nasa.kepler.common.DateUtils;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.services.alert.AlertServiceFactory;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class monitors a specified directory and notifies registered handlers
 * when a new file appears in the directory.
 * 
 * @author tklaus
 * 
 */
public abstract class FileWatcher extends Thread {
    public static final String COMPLETED_PROCESSING_FOR_DETECTED_FILE = "completed processing for detectedFile: ";

    private static final Log log = LogFactory.getLog(FileWatcher.class);

    public static final String INCOMING_DIR_PROP = "dr.filewatcher.incoming.dir";
    public static final String PROCESSING_ROOT_DIR_PROP = "dr.filewatcher.processing.root.dir";
    public static final String SLEEP_TIME_PROP = "dr.filewatcher.sleepTimeSecs";
    private static final int SLEEP_TIME_DEFAULT = 30;

    private static final String PROCESSING_DIR_FAILED_SUFFIX = "-FAILED";
    private static final String PROCESSING_DIR_SUCCESS_SUFFIX = "-SUCCESS";

    public static final String SPACECRAFT_EPHEMERIS_NOTIFICATION_MSG_EXTENSION = "_senm.xml";
    protected static final String GAP_REPORT_NOTIFICATION_MSG_EXTENSION = "_grnm.xml";
    protected static final String CONFIG_MAP_NOTIFICATION_MSG_EXTENSION = "_scnm.xml";
    protected static final String SCIENCE_FITS_DATA_NOTIFICATION_MSG_EXTENSION = "_sfnm.xml";
    protected static final String ANCILLARY_ENGINEERING_FITS_DATA_NOTIFICATION_MSG_EXTENSION = "_aefnm.xml";
    protected static final String THRUSTER_DATA_NOTIFICATION_MSG_EXTENSION = "_tfrnm.xml";
    protected static final String REFERENCE_PIXEL_NOTIFICATION_MSG_EXTENSION = "_rpnm.xml";
    protected static final String PMRF_NOTIFICATION_MSG_EXTENSION = "_tara.xml";
    public static final String SCLK_NOTIFICATION_MSG_EXTENSION = "_sknm.xml";
    protected static final String CHNM_NOTIFICATION_MSG_EXTENSION = "_chnm.xml";
    protected static final String TLNM_NOTIFICATION_MSG_EXTENSION = "_tlnm.xml";
    protected static final String TLSNM_NOTIFICATION_MSG_EXTENSION = "_tlsnm.xml";
    protected static final String MTNM_NOTIFICATION_MSG_EXTENSION = "_mtnm.xml";
    protected static final String DANM_NOTIFICATION_MSG_EXTENSION = "_danm.xml";
    protected static final String RCLCNM_NOTIFICATION_MSG_EXTENSION = "_rclcnm.xml";
    protected static final String UINM_NOTIFICATION_MSG_EXTENSION = "_uinm.xml";

    private File incomingDirectory = null;
    private long mostRecentNmTimeReceived;
    private File processingDirectory = null;
    private int sleepTimeSecs = 0;
    private FileWatcherFilenameFilter filenameFilter = null;
    private Map<String, FileWatcherHandler> handlers = new HashMap<String, FileWatcherHandler>();

    private Object shutdownSignal = new Object();
    private boolean shuttingDown = false;

    private boolean useXaServices = true;

    public FileWatcher(String threadName) {
        super(threadName);

        try {
            Configuration config = ConfigurationServiceFactory.getInstance();

            String incomingDirectoryStr = config.getString(INCOMING_DIR_PROP);
            incomingDirectory = validateDirectoryString(INCOMING_DIR_PROP,
                incomingDirectoryStr);

            String processingDirectoryStr = config.getString(PROCESSING_ROOT_DIR_PROP);
            processingDirectory = validateDirectoryString(
                PROCESSING_ROOT_DIR_PROP, processingDirectoryStr);

            sleepTimeSecs = config.getInt(SLEEP_TIME_PROP, SLEEP_TIME_DEFAULT);
        } catch (PipelineException e) {
            log.error("FileWatcher()", e);

            throw new DispatchException("Unable to retrieve configuration", e);
        }
        initializeFilter();
    }

    private File validateDirectoryString(String propName, String propValue) {
        if (propValue == null) {
            throw new DispatchException("propValue for " + propName
                + " must be non-null!");
        }
        File dir = new File(propValue);
        if (!dir.isDirectory()) {
            throw new DispatchException(propName
                + " must be a directory! propValue=" + propValue);
        }

        return dir;
    }

    private void initializeFilter() {
        filenameFilter = new FileWatcherFilenameFilter(handlers.keySet());
    }

    /**
     * Signals the FileWatcher thread to shutdown. Will not interrupt current
     * processing
     * 
     */
    public void shutdown() {
        synchronized (shutdownSignal) {
            shuttingDown = true;
            shutdownSignal.notify();
        }
    }

    /**
     * 
     */
    @Override
    public void run() {
        FileStoreClientFactory.getInstance()
            .disassociateThread();

        // Make sure all downstream code uses the same type of services (XA or
        // non-XA).
        TransactionServiceFactory.setXa(useXaServices);
        DatabaseServiceFactory.setUseXa(useXaServices);
        MessagingServiceFactory.setUseXa(useXaServices);

        NotificationMessageHandler handler = null;
        try {
            handler = new NotificationMessageHandler();
        } catch (Exception e) {
            log.error("Unable to create handler.", e);
        }

        addHandlers(handler);

        log.info("incoming dir: " + incomingDirectory);
        log.info("processing dir: " + processingDirectory);

        while (true) {
            try {
                synchronized (shutdownSignal) {
                    if (incomingDirectory.lastModified() > mostRecentNmTimeReceived) {
                        processNewFiles();
                    }

                    try {
                        shutdownSignal.wait(sleepTimeSecs * 1000);
                    } catch (InterruptedException e) {
                    }

                    if (shuttingDown) {
                        log.info("Received shutdown signal, terminating thread");
                        return;
                    }
                }
            } catch (Exception e) {
                log.error("Caught exception in FileWatcher thread", e);

                try {
                    Thread.sleep(1000);// brief delay in case we are in a tight
                    // exception loop
                } catch (InterruptedException e1) {
                }
            } catch (Throwable t) {
                log.fatal(
                    "Caught fatal Throwable in FileWatcher thread, EXITING", t);
                return;
            }
        }
    }

    protected abstract void addHandlers(NotificationMessageHandler handler);

    private void processNewFiles() {
        File[] fileArray = incomingDirectory.listFiles(filenameFilter);

        // Sort files by time received.
        List<File> files = Arrays.asList(fileArray);
        Collections.sort(files, new Comparator<File>() {
            @Override
            public int compare(File o1, File o2) {
                if (o1.lastModified() < o2.lastModified()) {
                    return -1;
                } else if (o1.lastModified() == o2.lastModified()) {
                    return 0;
                } else {
                    return 1;
                }
            }
        });

        for (int fileIndex = 0; fileIndex < files.size(); fileIndex++) {
            Set<String> monitoredSuffixes = handlers.keySet();
            File file = files.get(fileIndex);
            String name = file.getName();
            for (String monitoredSuffix : monitoredSuffixes) {
                if (name.endsWith(monitoredSuffix)) {
                    log.info("processing detected file: " + name);

                    FileWatcherHandler handler = handlers.get(monitoredSuffix);

                    IntervalMetricKey key = IntervalMetric.start();

                    processNewFile(handler, file);

                    IntervalMetric.stop("processFile." + monitoredSuffix, key);

                    long nmTimeReceived = file.lastModified();
                    if (nmTimeReceived > mostRecentNmTimeReceived) {
                        mostRecentNmTimeReceived = nmTimeReceived;
                    }
                }
            }
        }
    }

    private void processNewFile(FileWatcherHandler handler, File detectedFile) {
        File currentProcessingSubdirectory = null;

        // create the processing dir and move the detected file there
        String subDirName = "p--"
            + DateUtils.READABLE_LOCAL_FORMAT.format(new Date()) + "--"
            + detectedFile.getName();
        currentProcessingSubdirectory = new File(processingDirectory,
            subDirName);
        boolean directoryCreated = currentProcessingSubdirectory.mkdir();
        if (!directoryCreated) {
            AlertServiceFactory.getInstance()
                .generateAlert(getClass().getName(),
                    "Unable to mkdir.\n  dir: " + currentProcessingSubdirectory);
        }

        File detectedFileMoved = new File(currentProcessingSubdirectory,
            detectedFile.getName());

        if (!detectedFile.renameTo(detectedFileMoved)) {
            throw new DispatchException(
                "Failed to move detected file to processing dir, s=["
                    + detectedFile + "], d=[" + detectedFileMoved + "]");
        }

        try {
            log.info("invoking handler for detectedFile: " + detectedFile);
            handler.handleFile(incomingDirectory,
                currentProcessingSubdirectory, detectedFileMoved);
            log.info(COMPLETED_PROCESSING_FOR_DETECTED_FILE + detectedFile);

            // Rename the current processing dir to indicate that processing
            // finished.
            File renamedProcessingSubdirectory = new File(processingDirectory,
                currentProcessingSubdirectory.getName()
                    + PROCESSING_DIR_SUCCESS_SUFFIX);
            if (!currentProcessingSubdirectory.renameTo(renamedProcessingSubdirectory)) {
                log.warn("Failed to rename processing dir, s=["
                    + currentProcessingSubdirectory + "], d=["
                    + renamedProcessingSubdirectory + "]");
            }
        } catch (Exception e) {
            log.error("FAILURE processing detectedFile: " + detectedFile, e);

            // Rename the current processing dir to indicate that processing
            // failed.
            File renamedProcessingSubdirectory = new File(processingDirectory,
                currentProcessingSubdirectory.getName()
                    + PROCESSING_DIR_FAILED_SUFFIX);
            if (!currentProcessingSubdirectory.renameTo(renamedProcessingSubdirectory)) {
                log.warn("Failed to rename processing dir, s=["
                    + currentProcessingSubdirectory + "], d=["
                    + renamedProcessingSubdirectory + "]");
            }
        }
    }

    public void clearHandlers() {
        handlers.clear();
        initializeFilter();
        log.info("Cleared all handlers");
    }

    public FileWatcherHandler addHandler(String fileSuffix,
        FileWatcherHandler handler) {
        FileWatcherHandler newHandler = handlers.put(fileSuffix, handler);
        initializeFilter();
        log.info("Added handler: " + handler + " for fileSuffix: " + fileSuffix);
        return newHandler;
    }

    public FileWatcherHandler removeHandler(String fileSuffix) {
        FileWatcherHandler removedHandler = handlers.remove(fileSuffix);
        initializeFilter();
        log.info("Removed handler: " + removedHandler + " for fileSuffix: "
            + fileSuffix);
        return removedHandler;
    }

    public File getIncomingDirectory() {
        return incomingDirectory;
    }

    public void setIncomingDirectory(File incomingDirectory) {
        if (isAlive()) {
            throw new IllegalStateException(
                "Cannot change incoming dir after starting FileWatcher");
        }
        this.incomingDirectory = incomingDirectory;
    }

    public int getSleepTimeSecs() {
        return sleepTimeSecs;
    }

    public void setSleepTimeSecs(int sleepTimeSecs) {
        if (isAlive()) {
            throw new IllegalStateException(
                "Cannot change sleep time after starting FileWatcher");
        }
        this.sleepTimeSecs = sleepTimeSecs;
    }

    public Map<String, FileWatcherHandler> getHandlers() {
        return handlers;
    }

    public void setUseXaServices(boolean useXaServices) {
        this.useXaServices = useXaServices;
    }

}
