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

import gov.nasa.kepler.common.KeplerSocBuild;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.hibernate.pi.PipelineInstanceCrud;
import gov.nasa.kepler.hibernate.pi.PipelineTask;
import gov.nasa.kepler.hibernate.pi.PipelineTaskCrud;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.hibernate.services.AlertLogCrud;
import gov.nasa.kepler.pi.worker.InstanceReporter;
import gov.nasa.kepler.pi.worker.TaskReporter;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent.Type;
import gov.nasa.spiffy.common.jmock.JMockTest;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.List;

import org.junit.Test;

import com.google.common.collect.ImmutableList;

/**
 * @author Miles Cote
 * 
 */
public class PipelineEventNotifierTest extends JMockTest {

    private static final long PIPELINE_INSTANCE_ID = 1;
    private static final long PIPELINE_TASK_ID = 3;
    
    private static final File TASK_REPORT_FILE = new File("TASK_REPORT_FILE");
    private static final File INSTANCE_REPORT_FILE = new File(
        "INSTANCE_REPORT_FILE");
    private static final String MESSAGE = "MESSAGE";

    private Type eventType;
    private PipelineInstance pipelineInstance = mock(PipelineInstance.class);
    private PipelineTask pipelineTask = mock(PipelineTask.class);
    private AlertLog alertLog = mock(AlertLog.class);
    private List<AlertLog> alertLogs = ImmutableList.of(alertLog);
    private Alert alert = mock(Alert.class);

    private InstanceReporter instanceReporter = mock(InstanceReporter.class);
    private TaskReporter taskReporter = mock(TaskReporter.class);
    private PipelineInstanceCrud pipelineInstanceCrud = mock(PipelineInstanceCrud.class);
    private PipelineTaskCrud pipelineTaskCrud = mock(PipelineTaskCrud.class);
    private AlertLogCrud alertLogCrud = mock(AlertLogCrud.class);
    private FileMailer fileMailer = mock(FileMailer.class);
    private DatabaseService databaseService = mock(DatabaseService.class);

    private PipelineEventNotifier pipelineEventNotifier = new PipelineEventNotifier(
        instanceReporter, taskReporter, pipelineInstanceCrud, pipelineTaskCrud,
        alertLogCrud, fileMailer, databaseService);
    
    
    @Test
    public void testMonitorWithFailureEvent() throws Exception {
        eventType = Type.FAILURE;

        setAllowances();

        oneOf(databaseService).closeCurrentSession();

        oneOf(fileMailer).mail(TASK_REPORT_FILE);

        pipelineEventNotifier.processEvent(new PipelineInstanceEvent(eventType,
            PIPELINE_INSTANCE_ID, 0));
    } 

    @Test
    public void testMonitorWithFinishEvent() throws Exception {
        eventType = Type.FINISH;

        setAllowances();

        oneOf(databaseService).closeCurrentSession();

        oneOf(fileMailer).mail(INSTANCE_REPORT_FILE);

        pipelineEventNotifier.processEvent(new PipelineInstanceEvent(eventType,
            PIPELINE_INSTANCE_ID, 0));
    }

    @Test
    public void testMonitorWithStartEvent() throws Exception {
        eventType = Type.START;

        setAllowances();

        oneOf(databaseService).closeCurrentSession();

        oneOf(fileMailer).mail(INSTANCE_REPORT_FILE);

        pipelineEventNotifier.processEvent(new PipelineInstanceEvent(eventType,
            PIPELINE_INSTANCE_ID, 0));
    }

    @Test
    public void testMonitorWithTwoStartEvents() throws Exception {
        eventType = Type.START;

        setAllowances();

        oneOf(databaseService).closeCurrentSession();

        oneOf(fileMailer).mail(INSTANCE_REPORT_FILE);

        oneOf(databaseService).closeCurrentSession();

        pipelineEventNotifier.processEvent(new PipelineInstanceEvent(eventType,
            PIPELINE_INSTANCE_ID, 0));
        pipelineEventNotifier.processEvent(new PipelineInstanceEvent(eventType,
            PIPELINE_INSTANCE_ID, 0));
    }

    private void setAllowances() throws Exception {
    	final String taskArchivePrefix = ConfigurationServiceFactory.getInstance().getString(PipelineEventNotifier.TASK_ARCHIVE_DIR_PROP_NAME);
		
      if (taskArchivePrefix == null || taskArchivePrefix.isEmpty()) {
            throw new PipelineException("TASK_ARCHIVE_DIR_PROP_NAME is not defined");
        }
        File OUTPUT_DIR = new File(taskArchivePrefix, KeplerSocBuild.getId());

        allowing(pipelineInstanceCrud).retrieve(PIPELINE_INSTANCE_ID);
        will(returnValue(pipelineInstance));

        allowing(pipelineTaskCrud).retrieve(PIPELINE_TASK_ID);
        will(returnValue(pipelineTask));

        allowing(alertLogCrud).retrieveForPipelineInstance(PIPELINE_INSTANCE_ID);
        will(returnValue(alertLogs));

        allowing(alertLog).getAlertData();
        will(returnValue(alert));

        allowing(alert).getSeverity();
        will(returnValue(PipelineEventNotifier.SEVERITY_TYPE_TO_MONITOR.toString()));

        allowing(alert).getSourceTaskId();
        will(returnValue(PIPELINE_TASK_ID));

        allowing(alert).getMessage();
        will(returnValue(MESSAGE));

        allowing(pipelineInstance).getId();
        will(returnValue(PIPELINE_INSTANCE_ID));

        allowing(taskReporter).report(pipelineTask, OUTPUT_DIR);
        will(returnValue(TASK_REPORT_FILE));

        allowing(instanceReporter).report(pipelineInstance, OUTPUT_DIR);
        will(returnValue(INSTANCE_REPORT_FILE));
    }

}
