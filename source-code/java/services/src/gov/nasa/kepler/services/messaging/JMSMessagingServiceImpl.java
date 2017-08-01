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

import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.ObjectMessage;
import javax.jms.Queue;
import javax.jms.QueueBrowser;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.naming.InitialContext;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Provides a JMS implementation of the messaging service
 * 
 * @author tklaus
 * 
 */
abstract class JMSMessagingServiceImpl implements MessagingService {
    private static final Log log = LogFactory.getLog(JMSMessagingServiceImpl.class);

    public static final String JMS_URL_PROPERTY = "jms.url";
    public static final String JMS_URL_DEFAULT = "failover:tcp://host:port";

    private static final long DEFAULT_QUEUE_TTL_MILLIS = Message.DEFAULT_TIME_TO_LIVE; // no expiry
    private static final long DEFAULT_TOPIC_TTL_MILLIS = 5* 60 * 1000; // 5 minutes
    
    private static final int DEFAULT_QUEUE_DEL_MODE = DeliveryMode.PERSISTENT;
    private static final int DEFAULT_TOPIC_DEL_MODE = DeliveryMode.NON_PERSISTENT;
    
    private Set<String> registeredQueueNames = new HashSet<String>();
    private Set<String> registeredTopicNames = new HashSet<String>();
    
    public Map<String, Destination> destinationCache = new HashMap<String, Destination>();

    protected ThreadLocal<SessionData> threadSession = new ThreadLocal<SessionData>();

    protected InitialContext context = null;

    private boolean transacted;

    protected JMSMessagingServiceImpl(boolean transacted) {
        this.transacted = transacted;
        
        registerTopic(MessagingDestinations.PIPELINE_EVENTS_DESTINATION);
        registerTopic(MessagingDestinations.PIPELINE_ALERTS_DESTINATION);
        registerTopic(MessagingDestinations.PIPELINE_LOG_DESTINATION);
        registerTopic(MessagingDestinations.PIPELINE_STATUS_DESTINATION);
        registerTopic(MessagingDestinations.PIPELINE_METRICS_DESTINATION);
        registerTopic(MessagingDestinations.PIPELINE_ADMIN_DESTINATION);
        registerTopic(MessagingDestinations.NOTIFICATION_MESSAGE_EVENTS_DESTINATION);
        registerTopic(MessagingDestinations.TEST_COPIER_EVENTS_DESTINATION);
        
        for (int priority = PipelineInstance.HIGHEST_PRIORITY; priority <= PipelineInstance.LOWEST_PRIORITY; priority++) {
            registerQueue(MessagingDestinations.WORKER_TASK_REQUEST_QUEUE_NAMES[priority]);
        }
    }

    @Override
    public abstract MessagingService initialize() throws PipelineException;

    @Override
    public Session getSessionForThread() {
        return getSessionDataForThread().session;
    }

    /**
     * Pre-load the {@link MessageConsumer} for the specified destination and (optional)
     * selector.  Messages received after this method is called will be held by the 
     * {@link MessageConsumer} until one of the various receive methods are called.
     */
    @Override
    public void initializeReceiver(String destinationName, String selector) {
        SessionData sessionData = getSessionDataForThread();
        
        try{
            if(selector != null){
                sessionData.getConsumer(getDestination(destinationName), selector);
            }else{
                sessionData.getConsumer(getDestination(destinationName));
            }
        } catch (Exception e) {
            log.error("failed to initialize receiver, caught e = ", e);
            throw new PipelineException("Failed to initializereceiver", e);
        }
    }

    @Override
    public void initializeReceiver(String destinationName) {
        initializeReceiver(destinationName, null);
    }

    @Override
    public Message send(String destinationName, PipelineMessage message) {
        log.debug("send(String, PipelineMessage) - start");

        initializationCheck();

        ObjectMessage jmsMessage = null;

        try {
            SessionData sessionData = getSessionDataForThread();
            jmsMessage = createJmsMessage(message, sessionData);
            
            log.debug("send() - sending a message on [" + destinationName + "], jmsId: " + jmsMessage.getJMSMessageID());
            
            Destination destination = getDestination(destinationName);
            sendInternal(jmsMessage, destination, sessionData);
        } catch (Exception e) {
            log.error("failed to send, caught e = ", e);
            throw new PipelineException("failed to send message.", e);
        }

        return jmsMessage;
    }

    /**
     * Request with no timeout (wait forever)
     * 
     * @param destinationName
     * @param pipelineMessage
     * @return
     */
    @Override
    public MessageContext request(String destinationName, PipelineMessage pipelineMessage){
        return request(destinationName, pipelineMessage, 0);
    }

    @Override
    public MessageContext request(String destinationName, PipelineMessage pipelineMessage, long timeout)
        {
        log.debug("request(String, PipelineMessage, long) - start");

        TemporaryQueue replyQueue = null;
        SessionData sessionData = null;
        MessageConsumer consumer = null;

        try {
            sessionData = getSessionDataForThread();

            ObjectMessage jmsRequest = createJmsMessage(pipelineMessage, sessionData);
            
            replyQueue = sessionData.getReplyQueue();
            
            log.info("reply-to destination: " + replyQueue);

            jmsRequest.setJMSReplyTo(replyQueue);

            sendInternal(jmsRequest, getDestination(destinationName), sessionData);
            
            String requestMessageId = jmsRequest.getJMSMessageID();

            log.debug("Sent request, JMSMessageID: " + requestMessageId);
            
            consumer = sessionData.getConsumer(replyQueue);

            log.debug("request() - waiting for response");
            ObjectMessage jmsResponse = null;
            
            while(true){
                if(timeout > 0){
                    jmsResponse = (ObjectMessage) consumer.receive(timeout);
                }else{
                    jmsResponse = (ObjectMessage) consumer.receive();
                }
                
                if (jmsResponse == null) {
                    log.warn("request timed out!");
                    log.debug("request(String, PipelineMessage, long) - end");
                    return null;
                } else {
                    String responseCorrelationId = jmsResponse.getJMSCorrelationID();

                    log.debug("Got a response, JMSCorrelationID: " + responseCorrelationId);

                    if(responseCorrelationId.equals(requestMessageId)){
                        MessageContext messageContext = new MessageContext(jmsResponse);
                        log.debug("request() - got response");

                        log.debug("request(String, PipelineMessage, long) - end");
                        return messageContext;
                    }else{
                        log.info("Got a response to a different request, ignoring.  JMSCorrelationID: " + responseCorrelationId);
                    }
                }
            }

        } catch (Exception e) {
            log.error("failed to complete request/response, caught e = ", e);
            throw new PipelineException("failed to complete request/response.", e);
        }
    }

    /**
     * 
     * 
     * @param destinationName
     * @param pipelineMessage
     * @param timeout
     * @return
     * @throws PipelineException
     */
    @Override
    public TemporaryQueue requestNoWait(String destinationName, PipelineMessage pipelineMessage)
        {
        log.debug("requestNoWait(String, PipelineMessage) - start");

        try {
            SessionData sessionData = getSessionDataForThread();

            ObjectMessage jmsRequest = createJmsMessage(pipelineMessage, sessionData);

            TemporaryQueue replyQueue = sessionData.getReplyQueue();
            jmsRequest.setJMSReplyTo(replyQueue);

            sendInternal(jmsRequest, getDestination(destinationName), sessionData);

            return replyQueue;

        } catch (Exception e) {
            log.error("failed to complete request/response, caught e = ", e);
            throw new PipelineException("failed to complete request/response.", e);
        }
    }

    /**
     * 
     * @param request
     * @param response
     * @throws PipelineException
     */
    @Override
    public Message respond(MessageContext request, PipelineMessage response) {

        initializationCheck();

        ObjectMessage jmsResponseMessage = null;

        try {
            Destination dest = request.getJmsMessage().getJMSReplyTo();
            
            log.info("reply-to destination: " + dest);
            
            SessionData sessionData = getSessionDataForThread();

            jmsResponseMessage = createJmsMessage(response, sessionData);
            jmsResponseMessage.setJMSCorrelationID(request.jmsMessage.getJMSMessageID());
            
            sendInternal(jmsResponseMessage, dest, sessionData);
        } catch (Exception e) {
            log.error("failed to send, caught e = ", e);
            throw new PipelineException("failed to send message.", e);
        }

        return jmsResponseMessage;
    }

    @Override
    public MessageContext receive(String destinationName) {
        return receive(destinationName, null, 0);
    }

    @Override
    public MessageContext receive(String destinationName, String selector) {
        return receive(destinationName, selector, 0);
    }

    @Override
    public MessageContext receive(String destinationName, long timeout) {
        return receive(destinationName, null, timeout);
    }

    @Override
    public MessageContext receive(String destinationName, String selector, long timeout) {

        initializationCheck();

        try {

            SessionData sessionData = getSessionDataForThread();
            MessageConsumer consumer;
            
            if(selector != null){
                consumer = sessionData.getConsumer(getDestination(destinationName), selector);
            }else{
                consumer = sessionData.getConsumer(getDestination(destinationName));
            }

            log.debug("receive - waiting for a message on [" + destinationName + "]...");
            ObjectMessage jmsMessage = null;
            if (timeout > 0) {
                jmsMessage = (ObjectMessage) consumer.receive(timeout);
            } else if (timeout == 0) {
                jmsMessage = (ObjectMessage) consumer.receive();
            } else {
                jmsMessage = (ObjectMessage) consumer.receiveNoWait();
            }

            if (jmsMessage == null) {
                // timeout
                return null;
            }

            MessageContext messageContext = new MessageContext(jmsMessage);

            log.debug("receive(String) - end");

            return messageContext;

        } catch (Exception e) {
            log.error("failed to receive, caught e = ", e);
            throw new PipelineException("Failed to receive message.", e);
        }
    }
    
    @Override
    public MessageContext receiveNoWait(String destinationName) {
        return receive(destinationName, -1);
    }

    @Override
    public void commitTransaction() {
        log.debug("commitTransaction() - start");

        initializationCheck();

        try {
            // This is safe for XA because XASession will throw an exception.
            getSessionForThread().commit();

        } catch (Exception e) {
            log.error("failed to commit, caught e = ", e);
            throw new PipelineException("failed to commit transaction.", e);
        }

        log.debug("commitTransaction() - end");
    }

    @Override
    public void rollbackTransaction() {
        log.debug("rollbackTransaction() - start");
        initializationCheck();

        try {
            // This is OK for XA since XASession.rollback will throw an
            // exception.
            getSessionForThread().rollback();

        } catch (Exception e) {
            log.error("failed to rollback, caught e = ", e);
            throw new PipelineException("failed to rollback transaction.", e);
        }

        log.debug("rollbackTransaction() - end");
    }

    @Override
    public void closeConsumerForThread(String destinationName) {

        initializationCheck();

        try {
            log.debug("closeConsumerForThread() - closing consumer for [" + destinationName + "]");
            getSessionDataForThread().closeConsumer(getDestination(destinationName));
            threadSession.remove();
        } catch (Exception e) {
            log.error("failed to close consumer, caught e = ", e);
            throw new PipelineException("Failed to send message.", e);
        }
    }

    @Override
    public void closeProducerForThread(String destinationName) {

        initializationCheck();

        try {
            log.debug("closeProducerForThread() - closing producer for [" + destinationName + "]");
            getSessionDataForThread().closeProducer(getDestination(destinationName));
            threadSession.remove();
        } catch (Exception e) {
            log.error("failed to close producer, caught e = ", e);
            throw new PipelineException("failed to send message.", e);
        }
    }

    @Override
    public void closeSessionForThread() throws PipelineException{
        initializationCheck();

        try {
            log.debug("closeSessionForThread() - closing session");
            getSessionDataForThread().close();
            threadSession.remove();
        } catch (Exception e) {
            log.error("failed to close session, caught e = ", e);
            throw new PipelineException("failed to send message.", e);
        }
    }

    @Override
    public void createQueue(String queueName) {
        registerQueue(queueName);
    }

    @Override
    public void createTopic(String topicName) {
        registerTopic(topicName);
    }

    /* (non-Javadoc)
     * @see gov.nasa.kepler.services.messaging.MessagingService#createQueueBrowser(java.lang.String)
     */
    @Override
    public QueueBrowser createQueueBrowser(String queueName) throws PipelineException {
        initializationCheck();

        try {
            SessionData sessionData = getSessionDataForThread();
            QueueBrowser browser = sessionData.getQueueBrowser((Queue) getDestination(queueName));

            return browser;

        } catch (Exception e) {
            log.error("failed to create QueueBrowser, caught e = ", e);
            throw new PipelineException("Failed to create QueueBrowser.", e);
        }
    }

    private String getProp(String propName, String defaultValue) {
        Configuration config = ConfigurationServiceFactory.getInstance();
        String value = config.getString(propName, defaultValue);
        return value;
    }

    protected String getURL() {
        return getProp(JMS_URL_PROPERTY, JMS_URL_DEFAULT);
    }

    private void initializationCheck() {
        if (!isInitialized()) {
            throw new PipelineException("Messaging service not initialized!");
        }
    }

    protected void registerQueue(String queueName) {
        registeredQueueNames.add(queueName);
    }

    protected void registerTopic(String topicName) {
        registeredTopicNames.add(topicName);
    }

    /**
     * Create (if not in cache) the appropriate {@link Destination} object based
     * on the registered type (queue or topic)
     * 
     * @param destinationName
     * @return
     * @throws PipelineException
     */
    protected Destination getDestination(String destinationName) {

        Destination d = destinationCache.get(destinationName);

        if (d == null) {

            SessionData sessionData = getSessionDataForThread();

            try {
                if (registeredQueueNames.contains(destinationName)) {
                    d = sessionData.session.createQueue(destinationName);
                } else if (registeredTopicNames.contains(destinationName)) {
                    d = sessionData.session.createTopic(destinationName);
                } else {
                    throw new PipelineException("destinationName not registered: " + destinationName);
                }
            } catch (JMSException e) {
                throw new PipelineException("caught JMSException trying to create destination for destinationName: "
                    + destinationName);
            }

            destinationCache.put(destinationName, d);
        }
        return d;
    }

    /**
     * Create a new session with Sessioin.AUTO_ACKNOWLEDGE on and transactions
     * enabled.
     * 
     * @return
     * @throws PipelineException 
     */
    protected abstract Session createSession(boolean transacted) throws JMSException, PipelineException;

    private SessionData getSessionDataForThread() {
        log.debug("getSessionForThread() - start");

        try {
            SessionData sessionData = threadSession.get();
            if (sessionData == null) {
                // first access by this thread
                log.debug("Creating session data for thread = " + Thread.currentThread());

                sessionData = new SessionData();
                sessionData.session = createSession(transacted);
                threadSession.set(sessionData);
            }

            log.debug("getSessionForThread() - end");
            return sessionData;
        } catch (JMSException e) {
            log.error("caught JMS exception trying to create session data", e);
            throw new PipelineException("caught JMS exception trying to create Session" + e);
        }
    }

    /**
     * Turns a {@link PipelineMessage} into a a JMS {@link ObjectMessage}.
     * Copies properties from the {@link PipelineMessage} map into the JMS
     * header.
     * 
     * @param message
     * @param sessionData
     * @return
     * @throws JMSException
     */
    private ObjectMessage createJmsMessage(PipelineMessage message, 
        SessionData sessionData) throws JMSException {
        ObjectMessage jmsMessage = sessionData.session.createObjectMessage();
        jmsMessage.setObject(message);
        
        Map<String, String> messageProperties = message.getJmsProperties();
        for (String propertyName : messageProperties.keySet()) {
            String propertyValue = messageProperties.get(propertyName);
            
            log.debug("Adding JMS property: " + propertyName + " = " + propertyValue);
            
            jmsMessage.setStringProperty(propertyName, propertyValue);
        }
        
        return jmsMessage;
    }

    /**
     * Internal method for sending a message.
     * Sets message time-to-live and delivery mode based on destination type (queue or topic)
     * 
     * @param message
     * @param destination
     * @param sessionData
     * @throws Exception
     */
    private Message sendInternal(Message message, Destination destination, SessionData sessionData) throws Exception{
        MessageProducer producer = sessionData.getProducer(destination); 
        
        log.debug("sending request on [" + destination + "]");
        
        if(destination instanceof Queue){
            producer.send(message, DEFAULT_QUEUE_DEL_MODE, Message.DEFAULT_PRIORITY, DEFAULT_QUEUE_TTL_MILLIS);
        }else{ // Topic
            producer.send(message, DEFAULT_TOPIC_DEL_MODE, Message.DEFAULT_PRIORITY, DEFAULT_TOPIC_TTL_MILLIS);
        }
        
        return message;
    }
}
