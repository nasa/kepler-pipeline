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

package gov.nasa.kepler.services.alert;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DdlInitializer;
import gov.nasa.kepler.hibernate.services.Alert;
import gov.nasa.kepler.hibernate.services.AlertLog;
import gov.nasa.kepler.services.alert.AlertService.Severity;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.List;

import org.hibernate.Query;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class AlertServiceTest {
    private static final Log log = LogFactory.getLog(AlertServiceTest.class);

    private static final String TEST_ALERT_MESSAGE = "Test Alert Message";
    private static final Severity TEST_SEVERITY = Severity.INFRASTRUCTURE;
    private static final String TEST_COMPONENT_NAME = "Test";

    protected AlertMessage alertMessage = null;
    private DatabaseService databaseService;
    private DdlInitializer ddlInitializer;

    @Before
    public void setUp() throws Exception {
        databaseService = DatabaseServiceFactory.getInstance();

        ddlInitializer = databaseService.getDdlInitializer();
        ddlInitializer.initDB();
    }

    @After
    public void tearDown() throws Exception {
        databaseService.closeCurrentSession();
        ddlInitializer.cleanDB();
    }

    @Test
    public void testAlertService() throws Exception {
        // initialize the messaging service:
        System.setProperty("jms.url", "vm://host");
        MessagingServiceFactory.reset();
        MessagingServiceFactory.getNonTransactedInstance();
        final Object readyLock = new Object();
        
        log.info("Starting");
        
        Runnable receiverRunner = new Runnable() {
            @Override
            public void run() {
                try {
                    alertMessage = null;
                    MessagingService messagingService = MessagingServiceFactory.getNonTransactedInstance();
                    messagingService.initializeReceiver(MessagingDestinations.PIPELINE_ALERTS_DESTINATION);
                    synchronized(readyLock){
                        log.info("readyLock.notify()");
                        readyLock.notify();
                    }
                    log.info("Waiting for message...");
                    MessageContext mc = messagingService.receive(
                        MessagingDestinations.PIPELINE_ALERTS_DESTINATION, 5000);
                    log.info("...Got a message");
                    if(mc != null){
                        alertMessage = (AlertMessage) mc.getPipelineMessage();
                    }
                } catch (PipelineException e) {
                    e.printStackTrace();
                }
            }
        };

        Thread receiver = new Thread(receiverRunner);
        receiver.start();

        // Give time for the receiver thread and the JMS broker to initialize
        synchronized(readyLock){
            log.info("readyLock.wait()...");
            readyLock.wait();
            log.info("...readyLock.wait() returned");
        }
                
        databaseService.beginTransaction();

        AlertService alertService = AlertServiceFactory.getInstance();
        log.info("Sending alert...");
        alertService.generateAlert(TEST_COMPONENT_NAME, TEST_SEVERITY,
            TEST_ALERT_MESSAGE);

        databaseService.commitTransaction();

        log.info("Waiting for receiver thread");
        
        receiver.join();

        assertNotNull("alertMessage is null (receive timed-out)", alertMessage);

        verifyAlert(alertMessage.getAlertData());

        List<AlertLog> storedAlerts = retrieveAllAlerts();

        assertEquals("storedAlerts.size()", 1, storedAlerts.size());

        AlertLog alertLog = storedAlerts.get(0);
        verifyAlert(alertLog.getAlertData());
    }

    private void verifyAlert(Alert alert) {
        assertEquals("Alert.compnentName mismatch", TEST_COMPONENT_NAME,
            alert.getSourceComponent());
        assertEquals("Alert.message mismatch", TEST_ALERT_MESSAGE,
            alert.getMessage());
        assertEquals("Alert.severity mismatch", TEST_SEVERITY,
            Severity.valueOf(alert.getSeverity()));
    }

    private List<AlertLog> retrieveAllAlerts() {
        Query query = databaseService.getSession().createQuery("from AlertLog");

        List<AlertLog> results = query.list();
        return results;
    }
}
