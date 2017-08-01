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

import gov.nasa.kepler.hibernate.dbservice.LocalTransactionalResource;
import gov.nasa.spiffy.common.pi.PipelineException;

import javax.jms.Connection;
import javax.jms.JMSException;
import javax.jms.Session;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.ActiveMQPrefetchPolicy;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
class ActiveMqMessagingServiceImpl extends JMSMessagingServiceImpl implements LocalTransactionalResource {

    private static final Log log = LogFactory.getLog(ActiveMqMessagingServiceImpl.class);
    protected Connection connection;

    ActiveMqMessagingServiceImpl(boolean transacted) {
        super(transacted);
    }

    @Override
    public MessagingService initialize() {
        try {
            String url = getURL();

            // initSystemProperties();

            ActiveMQConnectionFactory factory = createConnectionFactory(url);
            ActiveMQPrefetchPolicy prefetchPolicy = new ActiveMQPrefetchPolicy();
            /*
             * Only fetch one message at a time from the queue. The default is
             * 1000 (!) which starves other workers
             */
            prefetchPolicy.setQueuePrefetch(0);
            factory.setPrefetchPolicy(prefetchPolicy);

            connection = factory.createConnection();
            connection.start();

            if (url.startsWith("vm")) {
                // wait for internal message queue to startup.
                Thread.sleep(2000);
            }

            return this;
        } catch (Exception e) {
            log.error("failed to initialize messaging service, caught e = ", e);
            throw new PipelineException("Failed to initialize messaging service.", e);
        }
    }

    protected ActiveMQConnectionFactory createConnectionFactory(String url) {
        log.info("Creating ActiveMQConnectionFactory for URL: " + url);

        return new ActiveMQConnectionFactory(url);
    }

    @Override
    protected Session createSession(boolean transacted) throws JMSException {
        return connection.createSession(transacted, Session.AUTO_ACKNOWLEDGE);
    }

    @Override
    public boolean isInitialized() {
        return connection != null;
    }

    /**
     * This does nothing.
     */
    @Override
    public void beginLocalTransaction() {
        // This does nothing.
    }

    @Override
    public void commitLocalTransaction() {
        this.commitTransaction();
    }

    @Override
    public void rollbackLocalTransactionIfActive() {
        this.rollbackTransaction();
    }

    @Override
    public boolean localTransactionIsActive() throws PipelineException {
        try {
            return getSessionForThread().getTransacted();
        } catch (JMSException e) {
            throw new PipelineException(e);
        }
    }
}
