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

import gov.nasa.kepler.services.AbstractService;
import gov.nasa.spiffy.common.pi.PipelineException;

import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.QueueBrowser;
import javax.jms.Session;
import javax.jms.TemporaryQueue;

/**
 * @author tklaus
 * 
 */
public interface MessagingService extends AbstractService {

    /**
     * @throws PipelineException
     * 
     */
    @Override
    public MessagingService initialize() throws PipelineException;

    /**
     * @throws PipelineException
     * 
     * 
     */
    public void commitTransaction() throws PipelineException;

    /**
     * 
     * 
     */
    public void rollbackTransaction() throws PipelineException;

    /**
     * 
     * @param destination
     * @param message
     * @throws PipelineException
     */
    public Message send(String destination, PipelineMessage message) throws PipelineException;

    /**
     * Pre-load the consumer for the specified destination and (optional)
     * selector.  Messages received after this method is called will be held by the 
     * consumer until one of the various receive methods are called.
     * 
     * @param destinationName
     * @param selector
     * @throws PipelineException
     */
    public void initializeReceiver(String destinationName, String selector) throws PipelineException;
    
    /**
     * 
     * @param destinationName
     * @throws PipelineException
     */
    public void initializeReceiver(String destinationName) throws PipelineException;
    
    /**
     * 
     * @param destination
     * @return
     * @throws PipelineException
     */
    public MessageContext receive(String destination) throws PipelineException;

    /**
     * 
     * @param destination
     * @param timeoutMilliseconds non-negative timeout in milliseconds.
     * @return
     * @throws PipelineException
     */
    public MessageContext receive(String destination, long timeoutMillis) throws PipelineException;

    /**
     * 
     * @param destination
     * @param timeoutMillis
     * @return
     * @throws PipelineException
     */
    public MessageContext receive(String destination, String selector, long timeoutMillis) throws PipelineException;

    /**
     * 
     * @param destinationName
     * @param selector
     * @return
     * @throws PipelineException
     */
    public MessageContext receive(String destinationName, String selector) throws PipelineException;
    
    /**
     * 
     * @param destination
     * @return
     * @throws PipelineException
     */
    public MessageContext receiveNoWait(String destination) throws PipelineException;

    /**
     * 
     * @param destination
     * @param pipelineMessage
     * @return
     * @throws PipelineException
     */
    public MessageContext request(String destination, PipelineMessage pipelineMessage)
        throws PipelineException;

    /**
     * 
     * @param destination
     * @param pipelineMessage
     * @param timeout
     * @return
     * @throws PipelineException
     */
    public MessageContext request(String destination, PipelineMessage pipelineMessage, long timeout)
        throws PipelineException;

    /**
     * 
     * @param destination
     * @param pipelineMessage
     * @return
     * @throws PipelineException
     */
    public TemporaryQueue requestNoWait(String destination, PipelineMessage pipelineMessage) throws PipelineException;

    /**
     * 
     * @param request
     * @param response
     * @throws PipelineException
     */
    public Message respond(MessageContext request, PipelineMessage response) throws PipelineException;

    /**
     * 
     * @return
     * @throws JMSException
     */
    public Session getSessionForThread() throws PipelineException;

    /**
     * 
     * @param destination
     * @throws PipelineException
     */
    public void closeConsumerForThread(String destination) throws PipelineException;

    /**
     * 
     * @param destination
     * @throws PipelineException
     */
    public void closeProducerForThread(String destination) throws PipelineException;

    /**
     * 
     * @throws PipelineException
     */
    public void closeSessionForThread() throws PipelineException;
    
    /**
     * Creates a new queue if one did not exist (non-transactional)
     * 
     * @param queueName
     * @throws PipelineException
     */
    public void createQueue(String queueName) throws PipelineException;

    /**
     * Register a destination name as a JMS topic (non-transactional)
     * 
     * @param topicName
     * @throws PipelineException
     */
    public void createTopic(String topicName) throws PipelineException;

    /**
     * Creates a QueueBrowser for the specified queueName
     * 
     * @param queueName
     * @throws PipelineException
     */
    public QueueBrowser createQueueBrowser(String queueName) throws PipelineException;
}
