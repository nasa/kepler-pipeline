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

package gov.nasa.kepler.services.messaging;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.net.URI;

import javax.jms.DeliveryMode;
import javax.jms.JMSException;
import javax.jms.Message;

import org.apache.activemq.broker.BrokerFactory;
import org.apache.activemq.broker.BrokerService;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

public class JMSMessagingServiceImplTest{
    private static final Log log = LogFactory.getLog(JMSMessagingServiceImplTest.class);
    
    private static final String BROKER_URL = "vm://db?create=false&waitForStart=10000";
    private static final String BROKER_URI = "broker:(vm://db)/db?persistent=false&deleteAllMessagesOnStartup=true";
    
    private static final String QUEUE_DESTINATION = "the-test-queue";
    private static final String TOPIC_DESTINATION = "the-test-topic";

    private static final String MESSAGE_NAME = "gray squirrel";
    
    private static final String PROCESS_1_NAME = "Worker:host:port";
    private static final String PROCESS_2_NAME = "Worker:host:port";
    private static final String PROCESS_PROP_NAME = "PipelineProcessName";

    protected static final int TIMEOUT = 3000;

    private String processName = null;
    private String selector = null;
    
    private String receivedMessageContent;
    private Message receivedMessage;

    private static BrokerService jmsBroker;

    private class Sender extends Thread{
        private String destination;
        
        public Sender(String destination) {
            this.destination = destination;
        }

        @Override
        public void run() {
            try {
                MessagingService messagingService = MessagingServiceFactory.getInstance();
                TestMessage message = new TestMessage(MESSAGE_NAME);
                
                Message sentMessage = messagingService.send(destination, message);

                try {
                    log.info("sent message, jmsId: " + sentMessage.getJMSMessageID());
                } catch (JMSException e) {
                    log.warn("caught exception getting JMS messageId, e = " + e,e);
                }
                
                messagingService.commitTransaction();
            } catch (PipelineException e) {
                e.printStackTrace();
            }
        }
    }
    
    private class Receiver extends Thread{
        private String destination;
        private boolean wait = true;
        private Object readyLock = new Object();
        private Object receiveLock = new Object();
        
        public Receiver(String destination, boolean wait) {
            this.destination = destination;
            this.wait = wait;
        }

        // don't return until the receiver has been initialized
        @Override
        public synchronized void start(){            
            synchronized(readyLock){
                try {
                    super.start();
                    readyLock.wait();
                } catch (InterruptedException e) {
                }
            }
        }
        
        public void readyForReceive(){
            synchronized(receiveLock){
                receiveLock.notifyAll();
            }
        }
        
        @Override
        public void run() {
            try {
                MessagingService messagingService = MessagingServiceFactory.getInstance();
                messagingService.initializeReceiver(destination);
                
                synchronized(readyLock){
                    readyLock.notify();
                }
                
                if(!wait){
                    synchronized(receiveLock){
                        try {
                            log.info("waiting for readyForReceive() to be called...");
                            receiveLock.wait();
                        } catch (InterruptedException e) {
                        }
                    }
                }
                
                log.info("calling receive...");
                MessageContext mc;
                if(wait){
                    mc = messagingService.receive(destination, TIMEOUT);
                }else{
                    mc = messagingService.receiveNoWait(destination);
                }

                log.info("...back from receive, mc=" + mc);
                if(mc != null){
                    TestMessage message = (TestMessage) mc.getPipelineMessage();
                    receivedMessage = mc.getJmsMessage();
                    receivedMessageContent = message.getContent();
                }else{
                    receivedMessage = null;
                    receivedMessageContent = null;
                }
                messagingService.commitTransaction();
                // close the consumer for this thread so it doesn't eat messages for subsequent tests
                messagingService.closeConsumerForThread(destination);
                
            } catch (PipelineException e) {
                e.printStackTrace();
            }
        }
    }
    
    private class Requestor extends Thread{
        private String destination;
        
        public Requestor(String destination) {
            this.destination = destination;
        }

        @Override
        public void run() {
            try {
                MessagingService messagingService = MessagingServiceFactory.getNonTransactedInstance();
                TestMessage request = new TestMessage(MESSAGE_NAME);
                
                if(processName != null){
                    request.putJmsProperty(PROCESS_PROP_NAME, processName);
                }

                log.info("calling request...");
                MessageContext responseContext = messagingService.request(
                    destination, request, TIMEOUT);
                log.info("...back from request, mc=" + responseContext);

                TestMessage response = (TestMessage) responseContext.getPipelineMessage();
                receivedMessageContent = response.getContent();
                receivedMessage = responseContext.getJmsMessage();
            } catch (Exception e) {
            }
        }
    }
    
    private class Responder extends Thread{
        private String destination;
        private Object readyLock = new Object();
        
        public Responder(String destination) {
            this.destination = destination;
        }

        // don't return until the receiver has been initialized
        @Override
        public synchronized void start(){
            synchronized(readyLock){
                try {
                    super.start();                    
                    readyLock.wait();
                } catch (InterruptedException e) {
                }
            }
        }
        
        @Override
        public void run() {
            try {
                MessagingService messagingService = MessagingServiceFactory.getNonTransactedInstance();              
                MessageContext requestContext;
                
                log.info("initializing receiver...");
                messagingService.initializeReceiver(destination);
                
                synchronized(readyLock){
                    readyLock.notify();
                }
                
                log.info("calling receive...");
                if(selector != null){
                    requestContext = messagingService.receive(destination, selector, TIMEOUT);
                }else{
                    requestContext = messagingService.receive(destination, TIMEOUT);
                }
                log.info("...back from receive, mc=" + requestContext);

                if(requestContext != null){
                    TestMessage response = new TestMessage(MESSAGE_NAME);

                    log.info("calling respond...");
                    messagingService.respond(requestContext, response);
                    log.info("...back from respond");
                }
                // close the consumer for this thread so it doesn't eat messages for subsequent tests
                messagingService.closeConsumerForThread(destination);
            } catch (Exception e) {
            }
        }
    }
    
	public JMSMessagingServiceImplTest() throws Exception {	
	}

    private String createSelector(String processName){
        return PROCESS_PROP_NAME + " = '" + processName + "' OR " + PROCESS_PROP_NAME + " = '*'";
    }
    
    @BeforeClass
    public static void beforeClassSetup() throws Exception{
        log.info("Creating JMS broker...");
        jmsBroker = BrokerFactory.createBroker(new URI(BROKER_URI));
        log.info("Starting JMS broker...");
        jmsBroker.start();
        log.info("JMS broker initialization complete.");

        //initialize the messaging service:
        System.setProperty("jms.url", BROKER_URL);
        MessagingServiceFactory.reset();
        MessagingServiceFactory.getInstance(); // initialize
        
        MessagingService messagingService = MessagingServiceFactory.getInstance();
        messagingService.createQueue(QUEUE_DESTINATION);
        messagingService.createTopic(TOPIC_DESTINATION);

        messagingService = MessagingServiceFactory.getNonTransactedInstance();
        messagingService.createQueue(QUEUE_DESTINATION);
        messagingService.createTopic(TOPIC_DESTINATION);
    }

    @Before
	public void setUp() {				
        receivedMessage = null;
        receivedMessageContent = null;
		selector = null;
        processName = null;
	}

    @After
    public void tearDown() {
	}

    /**
     * Verify that the message attributes (expiry and delivery mode) are 
     * consistent with the destination type (queue/topic)
     * @param isQueue
     * @throws JMSException
     */
    private void assertCorrectMessageAttributes(boolean isQueue) throws JMSException{
        long expiry = receivedMessage.getJMSExpiration();
        int deliveryMode = receivedMessage.getJMSDeliveryMode();
        
        log.info("expiry = " + expiry);
        log.info("deliveryMode = " + deliveryMode);
        
        if(isQueue){
            assertTrue("expiry == 0", expiry == 0);
            assertTrue("deliveryMode == PERSISTENT", deliveryMode == DeliveryMode.PERSISTENT);
        }else{
            assertTrue("expiry > 0", expiry > 0);
            assertTrue("deliveryMode == NON_PERSISTENT", deliveryMode == DeliveryMode.NON_PERSISTENT);
        }
    }
    
    @Test
    public void testInitialize() {
        log.info("**** TEST **** : testInitialize");
        MessagingService messagingService = MessagingServiceFactory.getInstance();
		messagingService.initialize();
	}

    @Test
	public void testIsInitialized() {
        log.info("**** TEST **** : testIsInitialized");
        MessagingService messagingService = MessagingServiceFactory.getInstance();
		assertTrue(messagingService.isInitialized());
	}

    @Test
	public void testGetSessionForThread() {
        log.info("**** TEST **** : testGetSessionForThread");
		MessagingService ms = MessagingServiceFactory.getInstance();
		
		assertTrue(ms.getSessionForThread().equals(ms.getSessionForThread()));
	}

    @Test
    public void testQueueReceiveNoWait() throws Exception {
        log.info("**** TEST **** : testQueueReceiveNoWait");
        
        Receiver receiver = new Receiver(QUEUE_DESTINATION, false);
        receiver.start();
        
        Sender sender = new Sender(QUEUE_DESTINATION);
        sender.start();
        sender.join();
        
        receiver.readyForReceive();
        receiver.join();

        //The receiver thread will set receivedMessage to the message it receives.
        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
        assertCorrectMessageAttributes(true);
    }

    @Test
    public void testTopicReceiveNoWait() throws Exception {
        log.info("**** TEST **** : testTopicReceiveNoWait");
        
        Receiver receiver = new Receiver(TOPIC_DESTINATION, false);
        receiver.start();
        
        Sender sender = new Sender(TOPIC_DESTINATION);
        sender.start();
        sender.join();
        
        receiver.readyForReceive();
        receiver.join();

        //The receiver thread will set receivedMessage to the message it receives.
        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
        assertCorrectMessageAttributes(false);
    }

    @Test
    public void testQueueReceiveWait() throws Exception{
        log.info("**** TEST **** : testQueueReceiveWait");
        Sender sender = new Sender(QUEUE_DESTINATION);
        sender.start();
        sender.join();
        
        Receiver receiver = new Receiver(QUEUE_DESTINATION, true);
        receiver.start();
        receiver.join();

        //The receiver thread will set receivedMessage to the message it receives.
        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
        assertCorrectMessageAttributes(true);
    }

    @Test
    public void testTopicReceiveWait() throws Exception{
        log.info("**** TEST **** : testTopicReceiveWait");
        
        Receiver receiver = new Receiver(TOPIC_DESTINATION, true);
        receiver.start();
        
        Sender sender = new Sender(TOPIC_DESTINATION);
        sender.start();
        sender.join();
        
        receiver.join();

        //The receiver thread will set receivedMessage to the message it receives.
        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
        assertCorrectMessageAttributes(false);
    }

    @Test
    public void testQueueRequest() throws Exception {
        log.info("**** TEST **** : testQueueRequest");

        selector = null;
        
        Responder responder = new Responder(QUEUE_DESTINATION);
        responder.start();

        Requestor requester = new Requestor(QUEUE_DESTINATION);
        requester.start();
        
        requester.join();

        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
        assertCorrectMessageAttributes(true);
    }

    @Test
    public void testTopicRequest() throws Exception {
        log.info("**** TEST **** : testTopicRequest");

        selector = null;
        
        Responder responder = new Responder(TOPIC_DESTINATION);
        responder.start();

        Requestor requester = new Requestor(TOPIC_DESTINATION);
        requester.start();
        
        requester.join();

        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
        // even when using a topic for the request, the reply dest is 
        // always a queue
        assertCorrectMessageAttributes(true);
    }

    @Test
    public void testRollbackTransaction() {
        log.info("**** TEST **** : testRollbackTransaction");
        MessagingService messagingService = MessagingServiceFactory.getInstance();
        
        TestMessage message = new TestMessage(MESSAGE_NAME);
        
        Message sentMessage = messagingService.send(QUEUE_DESTINATION, message);
        
        try {
            log.info("sent message, jmsId: " + sentMessage.getJMSMessageID());
        } catch (JMSException e) {
            log.warn("caught exception getting JMS messageId, e = " + e,e);
        }
        
        messagingService.rollbackTransaction();
        //messagingService.commitTransaction();
        
        MessageContext mc = messagingService.receiveNoWait(QUEUE_DESTINATION);
        
        log.info("...back from receiveNoWait, mc=" + mc);
        
        //Expect that no message was sent:
        boolean noMessageSent = (mc == null);
        assertTrue(noMessageSent);
    }

    @Test
    public void testNonTransactedSend() {
        log.info("**** TEST **** : testNonTransactedSend");
        TestMessage message = new TestMessage(MESSAGE_NAME);
        
        MessagingService nonTransactedMessagingService = MessagingServiceFactory.getNonTransactedInstance();
        nonTransactedMessagingService.createQueue(QUEUE_DESTINATION);

        nonTransactedMessagingService.send(QUEUE_DESTINATION, message);
        
        try {
            Thread.sleep(1000);
        } catch (InterruptedException e) {
        }

        MessageContext mc = nonTransactedMessagingService.receiveNoWait(QUEUE_DESTINATION);

        assertNotNull("receive timed out", mc);
        
        message = (TestMessage) mc.getPipelineMessage();
        receivedMessageContent = message.getContent();
        
        //Expect that message was sent:
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
    }

    @Test
    public void testRequestWithMatchingSelector() throws InterruptedException {
        log.info("**** TEST **** : testRequestWithMatchingSelector");

        selector = createSelector(PROCESS_1_NAME);
        processName = PROCESS_1_NAME;
        
        Thread responder = new Responder(QUEUE_DESTINATION);
        responder.start();

        Thread requester = new Requestor(QUEUE_DESTINATION);
        requester.start();
        
        requester.join();

        assertNotNull("receive timed out", receivedMessageContent);
        assertTrue(receivedMessageContent.equals(MESSAGE_NAME));
    }

    @Test
    public void testRequestWithNonMatchingSelector() throws InterruptedException {
        log.info("**** TEST **** : testRequestWithNonMatchingSelector");

        selector = createSelector(PROCESS_1_NAME);
        processName = PROCESS_2_NAME;
        
        Thread responder = new Responder(QUEUE_DESTINATION);
        responder.start();

        Thread requester = new Requestor(QUEUE_DESTINATION);
        requester.start();
        
        requester.join();

        assertEquals(receivedMessageContent, null);
    }
}
