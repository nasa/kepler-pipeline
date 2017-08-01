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

import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.pi.module.WorkerMemoryManager;
import gov.nasa.kepler.pi.worker.messages.WorkerTaskRequest;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.process.ProcessInfo;
import gov.nasa.spiffy.common.io.FileUtil;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Interacts with the Messaging Service to receive task request messages.
 * Hands off incoming messages to the WorkerTaskRequestDispatcher for processing.
 * Manages a list of active worker-task queues by fetching the list from the 
 * database at startup, then listing for pipeline start/finish events 
 * on the pipeline-events topic.
 * 
 * @author tklaus
 *
 */
public class WorkerTaskRequestListener extends Thread{
	private static final Log log = LogFactory.getLog(WorkerTaskRequestListener.class);
	
    static final String USE_XA_PROP = "pi.worker.xaEnabled";
    static final boolean USE_XA_DEFAULT = false;

	private PipelineInstanceQueuePool queueList = null;
    
	private WorkerTaskRequestDispatcher taskDispatcher = null;
	
    /** Indicates whether this worker task thread will use the XA services.
     * Normally true, but some tests may set it to false. */
    private boolean useXa = false;

    private class ShutdownLock{}
    private ShutdownLock shutdownLock = new ShutdownLock();
    private volatile boolean shuttingDown = false;

	/**
	 * @param queueList
	 * @param memoryManager 
	 */
	public WorkerTaskRequestListener(ProcessInfo processInfo, int threadNum, PipelineInstanceQueuePool queueList, WorkerMemoryManager memoryManager) {
		super("task-" + threadNum);
		this.queueList = queueList;

        Configuration config = ConfigurationServiceFactory.getInstance();
        useXa  = config.getBoolean(USE_XA_PROP, USE_XA_DEFAULT);
        
        log.info("useXa = " + useXa);

        taskDispatcher = new WorkerTaskRequestDispatcher(processInfo, threadNum, memoryManager);
	}

	@Override
    public void run(){
		log.debug("run() - start");
		
		FileStoreClientFactory.getInstance().disassociateThread();
		
        // make sure all downstream code uses the same type of services (XA or non-XA)
        TransactionServiceFactory.setXa(useXa);
        DatabaseServiceFactory.setUseXa(useXa);

        // always false so that we can commit messaging on ModuleFatalProcessingException, but
        // rollback db and fs.
        MessagingServiceFactory.setUseXa(false);
        
        log.info("Listening for messages...");
        
		while( true ){
			try {			    
                WorkerTaskRequest workerRequest = queueList.getNextMessage();
                
                if(workerRequest != null){
                    log.info("Got a message, processing...");
                    taskDispatcher.processMessage( workerRequest );
                }else{
                    // no messages available, sleep a bit sp we're not spinning
                    try {
                        Thread.sleep(1000);
                    } catch (InterruptedException e1) {
                        log.info("caught InterruptedException, terminating thread");
                        return;
                    }
                }
			} catch (Throwable e) {
				log.error("run() caught Throwable", e);
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException e1) {
                    log.info("caught InterruptedException, terminating thread");
                    return;
                }
			}
            
            synchronized(shutdownLock) {
                if(shuttingDown){
                    log.info("Got shutdown signal, shutting down...");
                    
                    MessagingServiceFactory.getInstance().closeSessionForThread();
                    
                    shutdownLock.notifyAll();
                    return;
                }
            }
		}
	}

    public void shutdown(boolean wait) throws InterruptedException {
        
        synchronized(shutdownLock) {
            log.debug("Shutting down WorkerTaskRequestDispatcher");
            shuttingDown = true;

            if(wait){
                log.debug("Waiting for shutdown to complete...");
                shutdownLock.wait();
            }
            FileUtil.close(FileStoreClientFactory.getInstance());
        }
    }

    /**
     * @return the taskDispatcher
     */
    public WorkerTaskRequestDispatcher getTaskDispatcher() {
        return taskDispatcher;
    }

    public boolean isUseXa() {
        return useXa;
    }

    public void setUseXa(boolean useXaServices) {
        this.useXa = useXaServices;
    }
}
