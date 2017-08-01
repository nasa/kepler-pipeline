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

import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;

import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.Queue;
import javax.jms.QueueBrowser;
import javax.jms.Session;
import javax.jms.TemporaryQueue;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Thread cache for JMS objects.
 * 
 * @author tklaus
 * 
 */
public class SessionData {
    private static final Log log = LogFactory.getLog(SessionData.class);

    public Session session;
    public HashMap<Destination, MessageConsumer> consumerCache = new HashMap<Destination, MessageConsumer>();
    public HashMap<Destination, MessageProducer> producerCache = new HashMap<Destination, MessageProducer>();

    public TemporaryQueue replyQueue = null;

    public SessionData() {
    }

    /**
     * 
     * @param context
     * @param destination
     * @return
     * @throws Exception
     */
    public MessageConsumer getConsumer(Destination destination) throws Exception {
        MessageConsumer consumer = consumerCache.get(destination);
        if (consumer == null) {
            consumer = session.createConsumer(destination);
            consumerCache.put(destination, consumer);
        }

        return consumer;
    }

    /**
     * 
     * @param context
     * @param destination
     * @return
     * @throws Exception
     */
    public MessageConsumer getConsumer(Destination destination, String selector) throws Exception {
        MessageConsumer consumer = consumerCache.get(destination);
        String selectorForExistingConsumer = (consumer == null) ? null : consumer.getMessageSelector();
        
        if (consumer == null || (selectorForExistingConsumer == null || !selectorForExistingConsumer.equals(selector))) {
            if(consumer != null){
                // Consumer exists, but with different selector.  Close & recreate.
                consumer.close();
            }
            
            consumer = session.createConsumer(destination, selector);
            consumerCache.put(destination, consumer);
        }

        return consumer;
    }

    /**
     * 
     * @param context
     * @param destination
     * @return
     * @throws Exception
     */
    public MessageProducer getProducer(Destination destination) throws Exception {
        MessageProducer producer = producerCache.get(destination);
        if (producer == null) {
            producer = session.createProducer(destination);
            producerCache.put(destination, producer);
        }

        return producer;
    }

    /**
     * 
     * @param context
     * @param queue
     * @return
     * @throws Exception
     */
    public QueueBrowser getQueueBrowser(Queue queue) throws Exception {
        QueueBrowser browser = session.createBrowser(queue);

        return browser;
    }

    /**
     * @return Returns the responseQueue.
     * @throws JMSException
     */
    public TemporaryQueue getReplyQueue() throws JMSException {
        if (replyQueue == null) {
            replyQueue = session.createTemporaryQueue();
        }
        return replyQueue;
    }

    /**
     * 
     * 
     */
    public void close() {
        for (MessageConsumer consumer : consumerCache.values()) {
            try {
                consumer.close();
            } catch (Exception e) {
                log.error("failed to close consumer = " + consumer, e);
            }
        }
        for (MessageProducer producer : producerCache.values()) {
            try {
                producer.close();
            } catch (Exception e) {
                log.error("failed to close producer = " + producer, e);
            }
        }
        try {
            session.close();
        } catch (Exception e) {
            log.error("failed to close session = " + session, e);
        }
    }

    /**
     * 
     * @param destination
     * @throws PipelineException
     */
    public void closeConsumer(Destination destination) {
        MessageConsumer consumer = consumerCache.get(destination);
        if (consumer != null) {
            try {
                consumer.close();
            } catch (Exception e) {
                log.error("failed to close consumer = " + consumer, e);
            }
            consumerCache.remove(destination);
        } else {
            throw new PipelineException("can't close consumer, destination not found: " + destination);
        }
    }

    /**
     * 
     * @param destination
     * @throws PipelineException
     */
    public void closeProducer(Destination destination) {
        MessageProducer producer = producerCache.get(destination);
        if (producer != null) {
            try {
                producer.close();
            } catch (Exception e) {
                log.error("failed to close producer = " + producer, e);
            }
            producerCache.remove(destination);
        } else {
            throw new PipelineException("can't close producer, destination not found: " + destination);
        }
    }

    /*
     * (non-Javadoc)
     * 
     * @see java.lang.Object#finalize()
     */
    @Override
    protected void finalize() throws Throwable {
        close();
        super.finalize();
    }
}
