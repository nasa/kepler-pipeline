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

import java.util.ArrayList;
import java.util.List;

import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingDestinations;
import gov.nasa.kepler.services.messaging.MessagingListener;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 *
 */
public class PipelineEventListener extends MessagingListener {
    private static final Log log = LogFactory.getLog(PipelineEventListener.class);

    private long instanceId = -1;
    
    private class PipelineCompleteLock{}
    private Object pipelineCompleteLock = new PipelineCompleteLock();
    protected volatile boolean pipelineComplete = false;
    private List<PipelineEventHandler> handlers = new ArrayList<PipelineEventHandler>();
    private PipelineInstanceEvent.Type eventType;
    
    public PipelineEventListener() {
        super(MessagingDestinations.PIPELINE_EVENTS_DESTINATION, false);
    }

    public void addHandler(PipelineEventHandler handler){
        handlers.add(handler);
    }
    
    public boolean removeHandler(PipelineEventHandler handler){
        return handlers.remove(handler);
    }
    
    private void notifyHandlers(PipelineInstanceEvent event){
        for (PipelineEventHandler handler : handlers) {
            handler.processEvent(event);
        }
    }
    
    @Override
    protected void processMessage(MessageContext messageContext) {
        
        PipelineInstanceEvent event = (PipelineInstanceEvent) messageContext.getPipelineMessage();
        
        log.info("got a mesg: " + event);
        
        notifyHandlers(event);
        
        eventType = event.getEventType();
        if(eventType == PipelineInstanceEvent.Type.FINISH || eventType == PipelineInstanceEvent.Type.FAILURE){
            instanceId = event.getInstanceId();
            synchronized(pipelineCompleteLock){
                pipelineComplete = true;
                log.info("FINISH: notifying waiter.");
                pipelineCompleteLock.notify();
            }
        }
    }
    
    public void waitForPipelineComplete() throws InterruptedException{
        synchronized(pipelineCompleteLock){
            if(!pipelineComplete){
                pipelineCompleteLock.wait();
            }
            pipelineComplete = false;
            log.info("FINISH: woke up");
        }
    }

    public long getInstanceId() {
        return instanceId;
    }

    public PipelineInstanceEvent.Type getEventType() {
        return eventType;
    }
}
