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

package gov.nasa.kepler.pi.worker;

import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.pi.worker.messages.WorkerTaskRequest;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.spiffy.common.pi.PipelineException;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/** 
 * This class abstracts access to the pool of queues for active pipeline
 * instances.  It provides a method to retrieve the next available task 
 * message from the pool, servicing the queues first by pipeline instance
 * priority, then round-robin within queues of the same priority.  The
 * getNextMessage() method will block until a new message is available.
 * 
 * @author Todd Klaus todd.klaus@nasa.gov
 *
 */
public class PipelineInstanceQueuePool{
    private static final Log log = LogFactory.getLog(PipelineInstanceQueuePool.class);

    public PipelineInstanceQueuePool() {
    }

    /** 
     * Implements priority-based message dispatching for the WorkerTaskRequestListener.
     * 
     * Implementation is round-robin within each priority group.
     * Lower-priority groups are only serviced when there are no 
     * messages at the higher priority groups.
     * 
     * @throws PipelineException 
     */
    public WorkerTaskRequest getNextMessage() {
        
        while(true){
            MessagingService messagingService = MessagingServiceFactory.getInstance();

            // check for messages in priority order (highest to lowest)
            for (int priority = PipelineInstance.HIGHEST_PRIORITY; priority <= PipelineInstance.LOWEST_PRIORITY; priority++) {
                WorkerTaskRequest message = checkForMessages(messagingService, priority);
                
                if(message != null){
                    return message;
                }
            }
            
            // if we got here, all queues are empty.  
            return null;
        }
    }

    /**
     * Check for messages at the specified priority, making at most one pass
     * through the queue list for this priority
     * 
     * @param messagingService
     * @param priority
     */
    private WorkerTaskRequest checkForMessages(MessagingService messagingService, Integer priority) {
        log.debug("checking for messages at priority: " + priority);
        
        String queueName = MessagingDestinations.WORKER_TASK_REQUEST_QUEUE_NAMES[priority];
        
        /* This needs to be a receiveNoWait() so that we don't get stuck waiting on
         * an empty queue when there are other non-empty queues waiting */
        MessageContext msgContext = messagingService.receiveNoWait(queueName);
        
        if( msgContext != null ){
            
            if(msgContext.isRedelivered()){
                log.info("Found a message at priority: " + priority + ", but JMSRedelivered == true, discarding message");
                return null;
            }
            
            // found a message
            log.info("Found a message at priority: " + priority);

            WorkerTaskRequest workerRequest = (WorkerTaskRequest) msgContext.getPipelineMessage();

            return workerRequest;
        }else{
            log.debug("No message found for queueName: " + queueName);
        }
        
        // no messages found at this priority level
        return null;
    }
}
