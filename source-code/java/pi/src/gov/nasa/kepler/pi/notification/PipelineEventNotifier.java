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

package gov.nasa.kepler.pi.notification;

import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;
import gov.nasa.kepler.common.KeplerSocBuild;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.pi.worker.InstanceReporter;
import gov.nasa.kepler.pi.worker.PipelineEventHandler;
import gov.nasa.kepler.pi.worker.PipelineEventListener;
import gov.nasa.kepler.pi.worker.TaskReporter;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent.Type;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 * Notifies listeners of pipeline events.
 * 
 * @author Miles Cote
 * 
 */
public class PipelineEventNotifier implements PipelineEventHandler {

    static final Severity SEVERITY_TYPE_TO_MONITOR = Severity.INFRASTRUCTURE;

    private static final String FAILURE_ENABLED_PROP_NAME = "pi.notification.PipelineEventNotifier.failureEnabled";
    private static final String START_ENABLED_PROP_NAME = "pi.notification.PipelineEventNotifier.startEnabled";
    private static final String FINISH_ENABLED_PROP_NAME = "pi.notification.PipelineEventNotifier.finishEnabled";
    static String TASK_ARCHIVE_DIR_PROP_NAME = "pi.notification.PipelineEventNotifier.taskArchiveDir";

    private File archiveDir;
    private Map<Long, Set<String>> pipelineInstanceIdToReportedAlertMessages = newHashMap();
    private Set<Long> startReportedPipelineInstanceIds = newHashSet();

    private final InstanceReporter instanceReporter;
    private final TaskReporter taskReporter;
    private final PipelineInstanceCrud pipelineInstanceCrud;
    private final PipelineTaskCrud pipelineTaskCrud;
    private final AlertLogCrud alertLogCrud;
    private final FileMailer fileMailer;
    private final DatabaseService databaseService;

    public PipelineEventNotifier() {
        this(new InstanceReporter(), new TaskReporter(),
            new PipelineInstanceCrud(), new PipelineTaskCrud(),
            new AlertLogCrud(), new FileMailer(),
            DatabaseServiceFactory.getInstance());
    }

    PipelineEventNotifier(InstanceReporter instanceReporter,
        TaskReporter taskReporter, PipelineInstanceCrud pipelineInstanceCrud,
        PipelineTaskCrud pipelineTaskCrud, AlertLogCrud alertLogCrud,
        FileMailer fileMailer, DatabaseService databaseService) {
        this.instanceReporter = instanceReporter;
        this.taskReporter = taskReporter;
        this.pipelineInstanceCrud = pipelineInstanceCrud;
        this.pipelineTaskCrud = pipelineTaskCrud;
        this.alertLogCrud = alertLogCrud;
        this.fileMailer = fileMailer;
        this.databaseService = databaseService;
    }

    @Override
    public void processEvent(PipelineInstanceEvent event) {
        try {
            databaseService.closeCurrentSession();

            Type eventType = event.getEventType();

            PipelineInstance pipelineInstance = pipelineInstanceCrud.retrieve(event.getInstanceId());

         
            String taskArchivePrefix = ConfigurationServiceFactory.getInstance().getString(TASK_ARCHIVE_DIR_PROP_NAME);
            
            if (taskArchivePrefix == null || taskArchivePrefix.isEmpty()) {
            	throw new PipelineException("TASK_ARCHIVE_DIR_PROP_NAME is not defined");
            }
             archiveDir = new File(taskArchivePrefix, KeplerSocBuild.getId());
            
            File reportFile = instanceReporter.report(pipelineInstance,
                archiveDir);

            switch (eventType) {
                case FAILURE:
                    if (failureEnabled()) {
                        reportAlerts(pipelineInstance);
                    }
                    break;
                case START:
                    if (startEnabled() && !startReported(pipelineInstance)) {
                        report(reportFile);
                    }
                    break;
                case FINISH:
                    if (finishEnabled()) {
                        report(reportFile);
                    }
                    break;
                default:
                    break;
            }
        } catch (Exception e) {
            throw new IllegalArgumentException("Unable to process event.", e);
        }
    }

    private boolean startReported(PipelineInstance pipelineInstance) {
        boolean startReported = startReportedPipelineInstanceIds.contains(pipelineInstance.getId());

        startReportedPipelineInstanceIds.add(pipelineInstance.getId());

        return startReported;
    }

    private boolean failureEnabled() {
        return ConfigurationServiceFactory.getInstance()
            .getBoolean(FAILURE_ENABLED_PROP_NAME, true);
    }

    private boolean startEnabled() {
        return ConfigurationServiceFactory.getInstance()
            .getBoolean(START_ENABLED_PROP_NAME, true);
    }

    private boolean finishEnabled() {
        return ConfigurationServiceFactory.getInstance()
            .getBoolean(FINISH_ENABLED_PROP_NAME, true);
    }

    private void report(File reportFile) throws Exception {
        fileMailer.mail(reportFile);
    }

    private void reportAlerts(PipelineInstance pipelineInstance)
        throws Exception {
        List<AlertLog> alertLogs = alertLogCrud.retrieveForPipelineInstance(pipelineInstance.getId());
        for (AlertLog alertLog : alertLogs) {
            if (isMonitored(alertLog)) {
                Set<String> reportedAlertMessages = getReportedAlertMessages(pipelineInstance);
                reportAlert(alertLog, reportedAlertMessages);
            }
        }
    }

    private void reportAlert(AlertLog alertLog,
        Set<String> reportedAlertMessages) throws Exception {
        String alertMessage = getAlertMessage(alertLog);

        if (!reportedAlertMessages.contains(alertMessage)) {
            PipelineTask pipelineTask = pipelineTaskCrud.retrieve(alertLog.getAlertData()
                .getSourceTaskId());
            report(pipelineTask);
            reportedAlertMessages.add(alertMessage);
        }
    }

    private String getAlertMessage(AlertLog alertLog) {
        String alertMessage = alertLog.getAlertData()
            .getMessage();
        if (!isMatlabAlert(alertMessage)) {
            alertMessage = getFirstWord(alertMessage);
        }

        return alertMessage;
    }

    private boolean isMatlabAlert(String alertMessage) {
        return alertMessage.startsWith("MATLAB");
    }

    private String getFirstWord(String alertMessage) {
        return alertMessage.split(" ")[0];
    }

    private Set<String> getReportedAlertMessages(
        PipelineInstance pipelineInstance) {
        long pipelineInstanceId = pipelineInstance.getId();

        Set<String> reportedAlertMessages = pipelineInstanceIdToReportedAlertMessages.get(pipelineInstanceId);
        if (reportedAlertMessages == null) {
            reportedAlertMessages = newHashSet();
            pipelineInstanceIdToReportedAlertMessages.put(pipelineInstanceId,
                reportedAlertMessages);
        }

        return reportedAlertMessages;
    }

    private boolean isMonitored(AlertLog alertLog) {
        return alertLog.getAlertData()
            .getSeverity()
            .equals(SEVERITY_TYPE_TO_MONITOR.toString());
    }

    private void report(PipelineTask pipelineTask) throws Exception {
        File reportFile = taskReporter.report(pipelineTask, archiveDir);

        fileMailer.mail(reportFile);
    }

    public static void main(String[] args) throws Exception {
        Thread thread = new Thread() {
            @Override
            public void run() {
                try {
                    PipelineEventNotifier pipelineEventNotifier = new PipelineEventNotifier();

                    PipelineEventListener pipelineEventListener = new PipelineEventListener();
                    pipelineEventListener.addHandler(pipelineEventNotifier);
                    pipelineEventListener.start();
                } catch (Exception e) {
                    new ExceptionHandler().handle(e);
                }
            }
        };
        thread.start();
    }

}
