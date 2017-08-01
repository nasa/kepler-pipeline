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

import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.dr.DispatchLog;
import gov.nasa.kepler.hibernate.dr.DispatchLog.DispatcherType;
import gov.nasa.kepler.hibernate.dr.DispatcherStatus;
import gov.nasa.kepler.hibernate.dr.DispatcherStatusCrud;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.dr.ReceiveLog.State;
import gov.nasa.kepler.nm.DataProductMessageDocument;
import gov.nasa.kepler.nm.DataProductMessageXB;
import gov.nasa.kepler.nm.FileXB;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.metrics.IntervalMetric;
import gov.nasa.spiffy.common.metrics.IntervalMetricKey;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

import org.apache.commons.io.FileUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.xmlbeans.XmlError;
import org.apache.xmlbeans.XmlOptions;

/**
 * Parses DMC notification messages (SDNM/GRNM/SENM) and populates the proper
 * Dispatchers with the contents
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 * @author Miles Cote
 * 
 */
public class NotificationMessageHandler implements FileWatcherHandler {
    private static final Log log = LogFactory.getLog(NotificationMessageHandler.class);

    private static final String FILENAME_PREFIX = "kplr";
    public static final String FILENAME_SEPARATOR = "_";

    /**
     * Controls whether files are files are moved from incoming -> processing,
     * or copied Normally true (move), but may be set to false for unit testing
     */
    private boolean moveToProcessingDir = true;

    private ReceiveLog receiveLog = null;

    /**
     * Defines the order in which dispatchers are called. This is needed because
     * different types of files are listed in the same notification message.
     */
    @SuppressWarnings("serial")
    public static final List<DispatcherType> DISPATCHER_ORDERING = new ArrayList<DispatcherType>() {
        {
            // Needed by pdq pipeline.
            add(DispatcherType.CONFIG_MAP);
            add(DispatcherType.SPACECRAFT_EPHEMERIS);
            add(DispatcherType.PLANETARY_EPHEMERIS);
            add(DispatcherType.LEAP_SECONDS);
            add(DispatcherType.SCLK);

            // Data for pdq pipeline.
            add(DispatcherType.REF_PIXEL);

            // Files not needed by any pipeline.
            add(DispatcherType.CRCT);
            add(DispatcherType.FFI);
            add(DispatcherType.HISTORY);
            add(DispatcherType.CLOCK_STATE_MASK);

            // Target lists and sets and mask tables.
            add(DispatcherType.TARGET_LIST);
            add(DispatcherType.TARGET_LIST_SET);
            add(DispatcherType.MASK_TABLE);

            // Needed for PixelDispatcher.
            add(DispatcherType.LONG_CADENCE_TARGET_PMRF);
            add(DispatcherType.SHORT_CADENCE_TARGET_PMRF);
            add(DispatcherType.BACKGROUND_PMRF);
            add(DispatcherType.LONG_CADENCE_COLLATERAL_PMRF);
            add(DispatcherType.SHORT_CADENCE_COLLATERAL_PMRF);

            // Needed for monthly science pipeline.
            add(DispatcherType.GAP_REPORT);
            add(DispatcherType.HISTOGRAM);
            add(DispatcherType.ANCILLARY);
            add(DispatcherType.THRUSTER_DATA);
            add(DispatcherType.DATA_ANOMALY);

            // Data for monthly science pipeline.
            add(DispatcherType.LONG_CADENCE_PIXEL);
            add(DispatcherType.SHORT_CADENCE_PIXEL);
            add(DispatcherType.RCLC_PIXEL);

            // Images for DV report.
            add(DispatcherType.UKIRT_IMAGE);
        }
    };

    private TransactionService transactionService;

    private List<DispatchLog> dispatchLogs = new ArrayList<DispatchLog>();

    public NotificationMessageHandler() {
        try {
            transactionService = TransactionServiceFactory.getInstance();
        } catch (Exception e) {
            throw new DispatchException("Unable to initialize services.", e);
        }
    }

    @Override
    public void handleFile(File incomingDirectory, File processingDirectory,
        File file) {
        try {
            log.info("handling file: " + file.getName());

            DispatcherWrapperFactory dispatcherFactory = null;

            dispatcherFactory = parseMessage(incomingDirectory,
                processingDirectory, file);

            createReceiveLogPreProcessing();

            Map<DispatcherType, DispatcherWrapper> dispatcherWrappers = dispatcherFactory.getDispatcherWrappers();

            dispatchLogs = new ArrayList<DispatchLog>();

            // Call dispatchers in the correct order.
            try {
                log.info("Starting distributed transaction.");
                transactionService.beginTransaction();

                for (DispatcherType dispatcherType : DISPATCHER_ORDERING) {
                    DispatcherStatusCrud dispatcherStatusCrud = new DispatcherStatusCrud();
                    DispatcherStatus dispatcherStatus = dispatcherStatusCrud.retrieve(dispatcherType);

                    if (dispatcherStatus == null) {
                        log.info("No DispatcherStatus was found.  Therefore, assume that the dispatcher is enabled.");
                    }

                    if (dispatcherStatus == null
                        || dispatcherStatus.isEnabled()) {
                        DispatcherWrapper dispatcherWrapper = dispatcherWrappers.get(dispatcherType);
                        if (dispatcherWrapper != null) {
                            dispatch(dispatcherWrapper);
                        }
                    }
                }

                log.info("Committing distributed transaction.");
                transactionService.commitTransaction();
            } catch (Throwable t) {
                log.error("Logging error before rollback.", t);
                if (t instanceof RuntimeException) {
                    throw (RuntimeException) t;
                }
                if (t instanceof Error) {
                    throw (Error) t;
                }
                throw (Exception) t;
            } finally {
                transactionService.rollbackTransactionIfActive();
            }

            updateReceiveLogPostProcessing(true);

            // Set receiveLog to null so that if the next nm fails it won't
            // corrupt the previous receiveLog.
            receiveLog = null;

            log.info("DONE handling file: " + file.getName());

        } catch (Exception e) {
            updateReceiveLogPostProcessing(false);
            throw new DispatchException("Unable to handle file.  ", e);
        }
    }

    private DispatcherWrapperFactory parseMessage(File incomingDirectory,
        File processingDirectory, File messageFile) throws Exception {
        String messageFileName = messageFile.getName();
        File xmlFile = new File(processingDirectory.getAbsolutePath(),
            messageFileName);

        log.info("parsing notification message = " + xmlFile);

        DataProductMessageDocument doc = DataProductMessageDocument.Factory.parse(xmlFile);

        DataProductMessageXB message = doc.getDataProductMessage();
        FileXB[] fileList = message.getFileList()
            .getFileArray();

        log.info("moving files to processingDirectory: " + processingDirectory);

        // Before processing, move all files listed in the NM to the
        // processing dir.
        for (FileXB file : fileList) {
            File srcFile = new File(incomingDirectory, file.getFilename());
            File destFile = new File(processingDirectory, file.getFilename());
            if (moveToProcessingDir) {
                if (!srcFile.renameTo(destFile)) {
                    throw new DispatchException(
                        "Failed to move file to processing dir, s=[" + srcFile
                            + "], d=[" + destFile + "]");
                }
            } else {
                FileUtils.copyFile(srcFile, destFile);
            }
        }

        // Validate nm xml.
        XmlOptions xmlOptions = new XmlOptions();
        List<XmlError> errors = new ArrayList<XmlError>();
        xmlOptions.setErrorListener(errors);
        if (!doc.validate(xmlOptions)) {
            throw new DispatchException("XML validation error.  " + errors);
        }

        receiveLog = new ReceiveLog(new Date(), message.getMessageType(),
            message.getIdentifier());
        receiveLog.setTotalFileCount(fileList.length);
        String firstCadence = "9999"; // max year
        String lastCadence = "0000"; // min year
        int cadenceFileCount = 0;

        DispatcherWrapperFactory dispatcherFactory = new DispatcherWrapperFactory();

        if (messageFileName.endsWith(FileWatcher.TLNM_NOTIFICATION_MSG_EXTENSION)
            || messageFileName.endsWith(FileWatcher.TLSNM_NOTIFICATION_MSG_EXTENSION)
            || messageFileName.endsWith(FileWatcher.MTNM_NOTIFICATION_MSG_EXTENSION)
            || messageFileName.endsWith(FileWatcher.RCLCNM_NOTIFICATION_MSG_EXTENSION)) {

            // Use one dispatcher for the entire nm.
            DispatcherWrapper dispatcherWrapper = dispatcherFactory.createDispatcherByNmFile(
                processingDirectory.getAbsolutePath(), messageFileName, this);
            for (FileXB file : fileList) {
                dispatcherWrapper.addFileName(file.getFilename());
            }
        } else {

            // Use multiple dispatchers for the nm.
            for (FileXB file : fileList) {
                String fileName = file.getFilename();

                // Special case for ephemeris and sclk. They do not conform to
                // the normal naming.
                if (fileName.endsWith(DispatcherWrapperFactory.SPACECRAFT_EPHEMERIS)
                    || fileName.endsWith(DispatcherWrapperFactory.PLANETARY_EPHEMERIS_SUFFIX)
                    || fileName.endsWith(DispatcherWrapperFactory.LEAP_SECONDS)
                    || fileName.endsWith(DispatcherWrapperFactory.SCLK)
                    || fileName.endsWith(DispatcherWrapperFactory.UKIRT_PNG)) {
                    dispatcherFactory.createDispatcherWrapper(
                        processingDirectory.getAbsolutePath(), fileName, this)
                        .addFileName(fileName);
                } else {
                    Pair<String, String> filenameTimestampSuffix = getFilenameTimestampSuffixPair(fileName);
                    String timestamp = filenameTimestampSuffix.left;
                    String suffix = filenameTimestampSuffix.right;

                    // Creates the Dispatcher for this suffix if it doesn't
                    // already exist and adds this fileName to it,
                    // otherwise just adds this fileName to the existing
                    // Dispatcher
                    dispatcherFactory.createDispatcherWrapper(
                        processingDirectory.getAbsolutePath(), suffix, this)
                        .addFileName(fileName);
                    cadenceFileCount++;

                    if (timestamp.compareTo(firstCadence) < 0) {
                        // this cadence is earlier than the current firstCadence
                        firstCadence = timestamp;
                    }

                    if (timestamp.compareTo(lastCadence) > 0) {
                        // this cadence is later than the current lastCadence
                        lastCadence = timestamp;
                    }

                    if (cadenceFileCount % 100 == 0) {
                        log.info("cadenceFileCount = " + cadenceFileCount);
                    }
                }
            }
        }

        log.info("Completed parsing for message " + messageFile);
        log.info("firstCadence = " + firstCadence);
        log.info("lastCadence = " + lastCadence);
        log.info("# of cadence files = " + cadenceFileCount);

        receiveLog.setFirstTimestamp(firstCadence);
        receiveLog.setLastTimestamp(lastCadence);

        return dispatcherFactory;
    }

    public static Pair<String, String> getFilenameTimestampSuffixPair(
        String fileName) {
        int cadenceTimestampStartIndex = FILENAME_PREFIX.length();
        int cadenceTimestampEndIndex = fileName.indexOf(FILENAME_SEPARATOR);

        String cadenceTimestamp = fileName.substring(
            cadenceTimestampStartIndex, cadenceTimestampEndIndex);
        String suffix = fileName.substring(cadenceTimestampEndIndex);

        Pair<String, String> filenameTimestampSuffix = Pair.of(
            cadenceTimestamp, suffix);
        return filenameTimestampSuffix;
    }

    private void createReceiveLogPreProcessing() {
        try {
            // Create the receiveLog.
            LogCrud logCrud = new LogCrud(DatabaseServiceFactory.getInstance());
            try {
                transactionService.beginTransaction(true, false, false);

                receiveLog.setState(State.PROCESSING);
                receiveLog.setStartProcessingTime(new Date());
                logCrud.createReceiveLog(receiveLog);

                transactionService.commitTransaction();
            } finally {
                transactionService.rollbackTransactionIfActive();
            }

            // Send a status message.
            MessagingService nonTransactedInstance = MessagingServiceFactory.getNonTransactedInstance();
            nonTransactedInstance.send(
                MessagingDestinations.NOTIFICATION_MESSAGE_EVENTS_DESTINATION,
                new NotificationMessageEvent(receiveLog));
        } catch (Exception e) {
            log.error("Unable to create receiveLog.  ", e);
        }
    }

    private void dispatch(DispatcherWrapper dispatcherWrapper) {
        String dispatcherClassName = dispatcherWrapper.getName();
        log.info("Processing " + dispatcherClassName);
        IntervalMetricKey key = null;

        try {
            key = IntervalMetric.start();
            dispatcherWrapper.dispatch();
        } finally {
            IntervalMetric.stop("dr.dispatch." + dispatcherClassName
                + ".process", key);
        }

        log.info("DONE Processing " + dispatcherClassName);
    }

    private void updateReceiveLogPostProcessing(boolean successful) {
        try {
            // Update the receiveLog.
            LogCrud logCrud = new LogCrud(DatabaseServiceFactory.getInstance());
            try {
                transactionService.beginTransaction(true, false, false);

                receiveLog = logCrud.retrieveReceiveLog(receiveLog.getId());
                receiveLog.setEndProcessingTime(new Date());

                if (successful) {
                    receiveLog.setState(State.SUCCESS);

                    // Don't need to create dispatchLogs because in this case,
                    // they are created by the Dispatcher.
                } else {
                    receiveLog.setState(State.FAILURE);

                    // Do need to create dispatchLogs because in this case, the
                    // dispatch transaction was rolled back.
                    for (DispatchLog dispatchLog : dispatchLogs) {
                        // Move any PROCESSING logs to FAILURE.
                        if (dispatchLog.getState()
                            .equals(State.PROCESSING)) {
                            dispatchLog.setState(State.FAILURE);
                        }

                        logCrud.createDispatchLog(dispatchLog);
                    }
                }

                transactionService.commitTransaction();
            } finally {
                transactionService.rollbackTransactionIfActive();
            }

            log.info("nm status: " + receiveLog.getState());

            // Send a status message.
            MessagingService nonTransactedInstance = MessagingServiceFactory.getNonTransactedInstance();
            nonTransactedInstance.send(
                MessagingDestinations.NOTIFICATION_MESSAGE_EVENTS_DESTINATION,
                new NotificationMessageEvent(receiveLog));
        } catch (Exception e) {
            log.error("Unable to update receiveLog.  ", e);
        }
    }

    /**
     * @return the moveToProcessingDir
     */
    public boolean isMoveToProcessingDir() {
        return moveToProcessingDir;
    }

    /**
     * @param moveToProcessingDir the moveToProcessingDir to set
     */
    public void setMoveToProcessingDir(boolean moveToProcessingDir) {
        this.moveToProcessingDir = moveToProcessingDir;
    }

    /**
     * @return the receiveLog
     */
    public ReceiveLog getReceiveLog() {
        return receiveLog;
    }

    public void setReceiveLog(ReceiveLog receiveLog) {
        this.receiveLog = receiveLog;
    }

    public List<DispatchLog> getDispatchLogs() {
        return dispatchLogs;
    }

    public void setDispatchLogs(List<DispatchLog> dispatchLogs) {
        this.dispatchLogs = dispatchLogs;
    }

}
