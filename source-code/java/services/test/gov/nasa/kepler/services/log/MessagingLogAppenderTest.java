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

package gov.nasa.kepler.services.log;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.apache.commons.logging.impl.Log4JLogger;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.apache.log4j.spi.LoggingEvent;
import org.junit.Test;


/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class MessagingLogAppenderTest {
    private static final Log log = LogFactory.getLog(MessagingLogAppenderTest.class);
    
    private static final String TEST_LOG_MESSAGE = "Test Log Message";

    protected LogMessage logMessage = null;
    
    @Test
    public void testMessagingLogAppender() throws Exception{

        //initialize the messaging service:
        System.setProperty("jms.url", "vm://host");
        MessagingServiceFactory.reset();
        final Object readyLock = new Object();

        Runnable receiverRunner = new Runnable() {
            @Override
            public void run() {
                try {
                    logMessage = null;
                    MessagingService messagingService = MessagingServiceFactory.getNonTransactedInstance();
                    messagingService.initializeReceiver(MessagingDestinations.PIPELINE_LOG_DESTINATION);

                    synchronized(readyLock){
                        log.info("readyLock.notify()");
                        readyLock.notify();
                    }

                    MessageContext mc = messagingService.receive(MessagingDestinations.PIPELINE_LOG_DESTINATION, 5000);
                    log.info("Waiting for message...");
                    if(mc != null){
                        logMessage = (LogMessage) mc.getPipelineMessage();
                    }
                    log.info("...Got a message");
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
        
        /* We call the MessagingLogAppender directly here rather than
         * using the Log4j API because we are only testing the appender here,
         * not the Log4j framework (which normally calls the appender)
         */
        MessagingLogAppender appender = new MessagingLogAppender();
        long timestamp = System.currentTimeMillis();
        Logger logger = ((Log4JLogger) log).getLogger();
        LoggingEvent loggingEvent = new LoggingEvent("fqnOfCategoryClass", logger, timestamp, Level.ERROR, TEST_LOG_MESSAGE, null);

        appender.append(loggingEvent);
        
        receiver.join();
        
        assertNotNull("logMessage is null (receive timed-out)", logMessage);
        
        assertEquals("Log.message mismatch", TEST_LOG_MESSAGE, logMessage.getMessage());
        assertEquals("Log.timestamp mismatch", timestamp, logMessage.getTimestamp().getTime());
    }
}
