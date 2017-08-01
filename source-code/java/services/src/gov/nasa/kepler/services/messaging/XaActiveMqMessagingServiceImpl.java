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

import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.XAService;
import gov.nasa.spiffy.common.pi.PipelineException;

import javax.jms.JMSException;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.XAConnection;
import javax.jms.XASession;
import javax.transaction.xa.XAResource;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.ActiveMQXAConnectionFactory;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * The XA version of the ActiveMQ messaging service. Basically all this does is
 * create an XAConnection as opposed to a normal connection.
 * 
 * @author Sean McCauliff
 * 
 */
public class XaActiveMqMessagingServiceImpl extends ActiveMqMessagingServiceImpl implements XAService {
    private static final Log log = LogFactory.getLog(XaActiveMqMessagingServiceImpl.class);

    public XaActiveMqMessagingServiceImpl(boolean transacted) {
        super(transacted);
    }

    @Override
    protected ActiveMQConnectionFactory createConnectionFactory(String url) {
        log.info("Creating ActiveMQXAConnectionFactory for URL: " + url);

        return new ActiveMQXAConnectionFactory(url);
    }

    @Override
    protected Session createSession(boolean transacted) throws JMSException {
        if(!transacted){
            throw new PipelineException("Illegal state: XaActiveMqMessagingServiceImpl does not support non-transacted sessions");
        }

        if(!(connection instanceof XAConnection)){
            throw new PipelineException("Unexpected state: connection is not a XAConnection");
        }
        return ((XAConnection)connection).createXASession();
    }

    @Override
    public XAResource getXAResource() {
        XASession xaSession = (XASession) getSessionForThread();
        return xaSession.getXAResource();
    }

    /**
     * This does nothing.
     */
    @Override
    public void initialize(TransactionService xService) {
        // Nothing.
    }

    @Override
    public MessageContext request(String destination, PipelineMessage pipelineMessage, long timeout)
        {

        throw new PipelineException("Requests not supported in XA " + "transactions. Use send()/ receieve() instead.");
    }

    @Override
    public TemporaryQueue requestNoWait(String destination, PipelineMessage pipelineMessage) {

        throw new PipelineException("Requests not supported in XA " + "transactions. Use send()/ receieve() instead.");
    }
}
