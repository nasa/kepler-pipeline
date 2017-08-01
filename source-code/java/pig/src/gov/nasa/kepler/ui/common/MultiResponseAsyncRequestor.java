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

package gov.nasa.kepler.ui.common;

import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.messaging.PipelineMessage;

import java.awt.Container;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.ObjectMessage;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.swing.ProgressMonitor;
import javax.swing.Timer;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * TODO: This class....
 * @author Todd Klaus
 *
 */
public class MultiResponseAsyncRequestor implements ActionListener {
	private static Log log = LogFactory.getLog(MultiResponseAsyncRequestor.class);

	private Container m_rootContainer = null;
    private Session m_session = null;
    @SuppressWarnings("unused")
    private MessageProducer m_producer = null;
    private MessageConsumer m_consumer = null;

    private long m_timeout = 0;
    private long m_startTime = 0;

    private ProgressMonitor m_monitor = null;
    private Timer m_timer = null;
    
    private int m_replyCount = 0;

	private TemporaryQueue m_replyQueue;

	private AsyncListener m_listener;
    
    /**
     * @param m_session
     * @param m_probes
     */
    public MultiResponseAsyncRequestor(Container rootContainer, AsyncListener listener) {
        this.m_rootContainer = rootContainer;
        this.m_listener = listener;
    }
    
	/**
	 * 
	 * send the request, start the timer
	 * @param timeout
	 * @return
	 */
	public void sendRequest( String destination, PipelineMessage request, long timeout ){

	    m_timeout = timeout;
	    m_replyCount = 0;
	    
	    try{	
			log.info("creating request");
			
			MessagingService ms = MessagingServiceFactory.getInstance();
			m_session = ms.getSessionForThread();
			
			log.debug("sendRequest() - sending request");
			m_replyQueue = ms.requestNoWait( destination, request );
			
			m_consumer = m_session.createConsumer( m_replyQueue );
			
			log.info("waiting for responses...");
			m_startTime = System.currentTimeMillis();
			m_timer = new Timer( 500, this );
			m_monitor = new ProgressMonitor( m_rootContainer, "Waiting for responses...", "Found 0 responses so far...", 0, (int) (m_timeout/1000));
			m_monitor.setMillisToPopup(0);
			m_timer.start();
			
		} catch (Exception e) {
			log.fatal("caught exception sending JMS message, e = " + e);
			e.printStackTrace();
		}
	}

	/**
	 * 
	 * invoked by the timer, check for new messages, 
	 * call listener, stop timer if done
	 * @param e
	 */
    public void actionPerformed(ActionEvent e) {
        try{
            
            log.debug("checking for responses...");
            
    		long elapsed = System.currentTimeMillis() - m_startTime;
    		int elapsedSecs = (int) (elapsed/1000);
    		
    		log.debug("elapsed = " + elapsed );
    		log.debug("elapsedSecs = " + elapsedSecs );

    		if( elapsed < m_timeout && !m_monitor.isCanceled() ){
    			ObjectMessage replyMsg = null;
    			
    			replyMsg = (ObjectMessage) m_consumer.receiveNoWait();
    			
    			while( replyMsg != null ){
    				PipelineMessage reply = (PipelineMessage) replyMsg.getObject();

    				m_listener.receive( reply );
        			m_replyCount++;
        			
        			replyMsg = (ObjectMessage) m_consumer.receiveNoWait();
    			}

    			// update monitor
    			m_monitor.setProgress( elapsedSecs );
    			m_monitor.setNote("Found "+ m_replyCount+" responses so far...");
    		}else{
    		    // timeout
    		    log.debug("timeout reached!");
    		    m_timer.stop();
    		    m_monitor.close();
        		m_consumer.close();
//        		m_replyQueue.delete();
        		m_listener.timeoutReached();
    		}
        } catch (Exception ex) {
			log.fatal("caught exception reading JMS message, e = " + ex);
		}
    }
}
