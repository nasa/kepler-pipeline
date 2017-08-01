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

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * @author tklaus
 * 
 */
public abstract class MessagingListener extends Thread {
    private static final Log log = LogFactory.getLog(MessagingListener.class);

    private static final int THREAD_PRIORITY = Thread.NORM_PRIORITY+1;

    private String destination = null;
    private boolean transacted = true;
    private String selector = null;
    
    private class ShutdownLock{}
    private ShutdownLock shutdownLock = new ShutdownLock();
    protected volatile boolean shuttingDown = false;

    private class ReadyLock{}
    private ReadyLock readyLock = new ReadyLock();
    protected volatile boolean ready = false;

    private static final int DELAY_AFTER_ERROR = 5000;

    public MessagingListener(String destination) {
        this(destination, null, true);
    }

    public MessagingListener(String destination, boolean transacted) {
        this(destination, null, transacted);
    }

    public MessagingListener(String destination, String selector) {
        this(destination,selector,true);
    }

    public MessagingListener(String destination, String selector, boolean transacted) {
        super("MessageListener[" + destination + "(selector=" + selector + ")]");
        this.destination = destination;
        this.selector = selector;
        this.transacted = transacted;
        setPriority(THREAD_PRIORITY);
    }

    /**
     * 
     * @param messageContext
     */
    protected abstract void processMessage(MessageContext messageContext) throws PipelineException;

    /**
     */
    @Override
    public void run() {
        log.debug("start");

        MessagingService messagingService = null;
        try {
            if(transacted){
                messagingService = MessagingServiceFactory.getInstance();
            }else{
                messagingService = MessagingServiceFactory.getNonTransactedInstance();
            }
            
            if(selector != null){
                messagingService.initializeReceiver(destination, selector);
            }else{
                messagingService.initializeReceiver(destination);                
            }
        } catch (PipelineException e1) {
            log.error("Failed to initialize messaging service, caught e", e1);
            return;
        }

        synchronized(readyLock) {
            ready = true;
            log.info("Ready for messages..");
            readyLock.notifyAll();
        }

        while (true) {
            try {
                MessageContext messageContext;
                
                if(selector != null){
                    messageContext = messagingService.receive(destination, selector, 500);
                }else{
                    messageContext = messagingService.receive(destination, 500);
                }

                if(messageContext != null){
                    log.info("got a message, processing");
                    processMessage(messageContext);
                    log.info("Waiting for message....");
                }
                
                synchronized(shutdownLock) {
                    if(shuttingDown){
                        log.info("Got shutdown signal, shutting down...");
                        
                        messagingService.closeConsumerForThread(destination);
                        
                        shutdownLock.notifyAll();
                        return;
                    }
                }
            } catch (Exception e) {
                log.error("run(): caught exception processing message on dest=" + destination, e);
                try {
                    Thread.sleep(DELAY_AFTER_ERROR);
                } catch (InterruptedException ignore) {
                }
            }
        }
    }
    
    public void waitForReadyToProcess() throws InterruptedException{
        synchronized(readyLock) {
            if(!ready){
                log.info("Waiting for initialization to complete...");
                readyLock.wait();
            }
        }
    }

    public void shutdown() throws InterruptedException{
        synchronized(shutdownLock) {
            shuttingDown = true;
            
            log.info("Waiting for shutdown to complete...");
            shutdownLock.wait();
        }
    }
}
