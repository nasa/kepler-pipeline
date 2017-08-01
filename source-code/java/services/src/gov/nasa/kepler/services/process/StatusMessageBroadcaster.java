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

package gov.nasa.kepler.services.process;

import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.Map;
import java.util.Timer;
import java.util.TimerTask;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * This class periodically broadcasts status messages to the "pipeline-status" JMS topic.
 * Status providers register with this class and provide their status messages (extend {@link StatusMessage}
 * via the {@link StatusReporter} interface.
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class StatusMessageBroadcaster{
    private static final Log log = LogFactory.getLog(StatusMessageBroadcaster.class);

    private static final String TIMER_THREAD_NAME = "StatusMessageBroadcaster.timerThread";
    
    private ProcessInfo processInfo;
    private Timer broadcastScheduler = new Timer(TIMER_THREAD_NAME);
    
    // Map[reporter, reportIntervalMillis]
    private Map<StatusReporter,Integer> reporters = new HashMap<StatusReporter,Integer>();
    
	/**
	 * @param jvmid 
	 * @param pid 
	 * @param process 
	 * @throws PipelineException 
	 * 
	 */
	public StatusMessageBroadcaster(ProcessInfo processInfo) {
        this.processInfo = processInfo;
	}

    public synchronized void addStatusReporter(final StatusReporter reporter, final int reportIntervalMillis) {
        reporters.put(reporter, reportIntervalMillis);
        
        broadcastScheduler.schedule(new TimerTask(){
            @Override
            public void run() {
                sendUpdate(reporter, reportIntervalMillis);
            }}, reportIntervalMillis, reportIntervalMillis);
    }

    public synchronized void clearStatusReporters() {
        broadcastScheduler.cancel();
        broadcastScheduler = new Timer(TIMER_THREAD_NAME);
        reporters.clear();
    }

    private void sendUpdate(StatusReporter reporter, int reportInterval){
        try {
            MessagingService msgService = MessagingServiceFactory.getNonTransactedInstance();
            
            StatusMessage statusMessage = reporter.reportCurrentStatus();
            String destination = reporter.destination();
            
            statusMessage.setSourceProcess(processInfo);
            statusMessage.setReportIntervalMillis(reportInterval);
            
            log.debug("sending StatusMessage: " + statusMessage.getClass().getSimpleName());
            
            msgService.send(destination, statusMessage);
        } catch (Exception e) {
            log.error("failed to send status messages", e);
        }
    }
}
