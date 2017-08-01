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

package gov.nasa.kepler.pi.transaction;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.common.FilenameConstants;
import gov.nasa.kepler.fs.api.BlobResult;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.kepler.hibernate.pi.PipelineInstance;
import gov.nasa.kepler.pi.worker.messages.PipelineInstanceEvent;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.messaging.PipelineMessage;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.util.Date;
import java.util.List;
import java.util.Random;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.InvalidTransactionException;
import javax.transaction.RollbackException;
import javax.transaction.SystemException;
import javax.transaction.Transaction;
import javax.transaction.TransactionManager;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.*;

/**
 * Tests the the TransactionService works correctly.
 * 
 * @author Sean McCauliff
 *
 */
public class TransactionServiceTest {

    private static final Log log = LogFactory.getLog(TransactionServiceTest.class);
    
	private static final Random rand = new Random(4223);
	

    @Before
    public void setUp() throws Exception {
        DatabaseService db = DatabaseServiceFactory.getInstance(false);
        db.getDdlInitializer().initDB();
        //Clear out any mocked stuff and use the real stuff.
        FileStoreClientFactory.setInstance(null);
        MessagingServiceFactory.setInstance(null, true);
        MessagingServiceFactory.setInstance(null,false);
        XANodeNameFactory.setInstance(new XANodeNameFactory("TransactionServiceTest"));
    }
    
    @After
    public void tearDown() throws Exception {
        TransactionService localXService  = 
            TransactionServiceFactory.getInstance(false);
        try {
            localXService.rollbackTransactionIfActive();
        } catch (Exception ignore) {
           //ignored
        }
        
        DatabaseService db = DatabaseServiceFactory.getInstance(false);
        db.getDdlInitializer().cleanDB();
        
    }
    
    @AfterClass
    public static void cleanMq() throws Exception {
        File activemqDir = new File(FilenameConstants.ACTIVEMQ_DATA);
        if (activemqDir.exists()) {
            FileUtil.removeAll(activemqDir);
        }
    }
    
    
    /**
     * This does not work. Don't do it. Hibernate can't do it.
     * @throws Exception
     */
    @Ignore
    public void multipleThreadsInJTATransaction() throws Exception {
        final XATransactionService xService = (XATransactionService)
            TransactionServiceFactory.getInstance(true);
        xService.beginTransaction(true, false, false);
        final Transaction x = xService.transactionManager().suspend();
        xService.transactionManager().resume(x);
        //final Transaction x = xService.currentTransaction();
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        final DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
        final KicCrud kicCrud = new KicCrud(dbService);
        Runnable childRunnable = new Runnable() {
            @Override
            public void run() {
                try {
                    xService.transactionManager().resume(x);
                    Kic.Builder kicBuilder = new Kic.Builder(rand.nextInt(), 77.0, 4.0);
                    Kic kic = kicBuilder.build();
                    kicCrud.create(kic);
                    
                } catch (Throwable t) {
                    error.set(t);
                }
            }
        };
        Thread t = new Thread(childRunnable);
        t.start();
        
        Kic.Builder kicBuilder = new Kic.Builder(rand.nextInt(), 77.0, 4.0);
        Kic kic = kicBuilder.build();
        kicCrud.create(kic);
        t.join();
        
        assertEquals(null, error.get());
        
        xService.commitTransaction();
        xService.beginTransaction();
        List<Kic> kics = kicCrud.retrieveAllKics();
        assertEquals(2, kics.size());
        xService.rollbackTransactionIfActive();
    }
    
    /**
     * Attempt to simulate workers.
     * @throws Exception
     */
    @Test
    public void multiThreadService() throws Exception {
        log.info("Mark test start.");
        
    	final int WORKERS = 8;
    	final CountDownLatch allWorkersStarted = new CountDownLatch(WORKERS);
    	final CountDownLatch done = new CountDownLatch(WORKERS);
    	final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
    	Runnable r = new Runnable() {
    		@Override
            public void run() {
    			try {
	    			allWorkersStarted.countDown();
	    			allWorkersStarted.await();
	    			xaTransactionServiceWithDbAndFs();	
    			} catch (Exception e) {
    				error.compareAndSet(null, e);
				} finally {
					done.countDown();
				}
    		}
    	};
    	
    	for (int i=0; i < WORKERS; i++) {
    		Thread t= new Thread(r,"worker-" + i);
    		t.start();
    	}
    	done.await();
    	if (error.get() != null) {
    		error.get().printStackTrace();
    		assertTrue(false);
    	}
    }
    
    /**
     * Write into the file store and the database and commit.  In a new transaction
     * verify that the data exists.
     * 
     * @throws Exception
     */
    @Test
    public void xaTransactionServiceWithDbAndFs() throws Exception {
        log.info("Mark test start.");
        
        TransactionService xService = TransactionServiceFactory.getInstance(true);
        assertTrue(xService instanceof XATransactionService);
        assertFalse("Should not be in transaction.", xService.transactionIsActive());
        xService.beginTransaction(true, false, true);
        assertTrue("Should be in transaction.", xService.transactionIsActive());
        DatabaseServiceFactory.getInstance(true);
        xService.commitTransaction();
        
        xService.beginTransaction(true, false, true);
        Kic.Builder kicBuilder = new Kic.Builder(rand.nextInt(), 77.0, 4.0);
        Kic kic = kicBuilder.build();
        DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
        KicCrud kicCrud = new KicCrud(dbService);
        kicCrud.create(kic);
        
        ReceiveLog receiveLog = 
            new ReceiveLog(new Date(),"b0gus", "bogussdnm.xml");
        receiveLog.setLastTimestamp("200900100300");
        
        LogCrud logCrud = new LogCrud(dbService);
        logCrud.createReceiveLog(receiveLog);
        
        //dbService.getSession().flush();
        
        FileStoreClient fs = FileStoreClientFactory.getInstance();
        FsId fsId = new FsId("/xatest/blah" + rand.nextInt());
        fs.writeBlob(fsId, 23, new byte[] { (byte) 42});

        xService.commitTransaction();
        
        assertFalse("Should not be in transaction.", xService.transactionIsActive());
        
        xService.beginTransaction();
        Kic newKic = kicCrud.retrieveKic(kic.getKeplerId());
        assertEquals(kic, newKic);
        assertTrue(fs.blobExists(fsId));
        xService.rollbackTransaction();
    }
    
    /**
     * Start/commit a transaction, but nothing should have been changed.
     * @throws Exception
     */
    @Test
    public void localTransactionServiceNothingIgnore() throws Exception {
        log.info("Mark test start.");
        
        TransactionServiceFactory.setXa(false);
        TransactionService xService = TransactionServiceFactory.getInstance();
        assertFalse("Should not be in transaction.", xService.transactionIsActive());
        xService.beginTransaction(true, true, true);
        assertTrue("Should be in transaction.", xService.transactionIsActive());
        xService.commitTransaction();
        assertFalse("Should not be in transaction.", xService.transactionIsActive());
    }
    
    @Test
    public void commitLocalStuff() throws Throwable {
        log.info("Mark test start.");
        commitStuff(false);
    }
    
    @Test
    public void commitXaStuff() throws Throwable {
        log.info("Mark test start.");
        commitStuff(true);
    }
    
    /**
     * Start/commit a transaction, modify some data.
     * 
     * In a new thread create a message on the message queue and commit it.
     * Then read the message from the queue and write into the database
     * and the file store.  Commit the second transaction.  Verify that the
     * message has been removed from the queue and that the file store
     * and database data exist.
     */
    private void commitStuff(final boolean xa) throws Throwable {
        
        final AtomicReference<Throwable> receiverException = 
            new AtomicReference<Throwable>();
        final CountDownLatch receiveThreadDone =
            new CountDownLatch(1);
        final String messageDestination = "messageDest";
        final AtomicBoolean commitHappened = new AtomicBoolean(false);
        final PipelineMessage testMessage =
            new PipelineInstanceEvent(PipelineInstanceEvent.Type.START, 343434343444444L, PipelineInstance.LOWEST_PRIORITY);
        
        Runnable messageServiceListener = new Runnable() {
            @Override
            public void run() {
                try {
                    TransactionService xService = 
                        TransactionServiceFactory.getInstance(xa);
                    xService.beginTransaction(false, true, false);
                    MessagingService messageService =
                        MessagingServiceFactory.getInstance(xa);

                    
                    MessageContext mContext =
                        messageService.receive(messageDestination, 10*1000);
                    
                    xService.commitTransaction();
                    if (!commitHappened.get())  {
                        throw new IllegalStateException("Received message before" +
                                " commit.");
                    }
                    
                    PipelineMessage receivedMessage = 
                        mContext.getPipelineMessage();
                    
                    // close session for this thread so that it doesn't
                    // eat messages intended for subsequent tests
                    messageService.closeSessionForThread();
                    
                    if (!receivedMessage.equals(testMessage)) {
                        throw new IllegalStateException("Received message not " +
                                "equal testMessage.");
                    }

                } catch (Throwable t) {
                    receiverException.set(t);
                } finally {
                    receiveThreadDone.countDown();
                }
            }
        };
        
        TransactionService xService = TransactionServiceFactory.getInstance(xa);
        
        xService.beginTransaction(true, true, true);
        DatabaseService db = DatabaseServiceFactory.getInstance(xa);
        Kic.Builder bldr = new Kic.Builder(99, 1.0, 2.0);
        Kic kic  = bldr.build();
        KicCrud kicCrud = new KicCrud(db);
        kicCrud.create(kic);
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        FsId fsId = new FsId("/Ignore/bl0b");
        fsClient.writeBlob(fsId, 33, new byte[] {(byte) 66});
        
        MessagingService messageService = MessagingServiceFactory.getInstance(xa);
        messageService.createQueue(messageDestination);
        
        Thread messageReceiver = new Thread(messageServiceListener);
        messageReceiver.setDaemon(true);
        messageReceiver.start();
        
        
        try {
            Thread.sleep(500);
        } catch (InterruptedException ie) {
            //ignored.
        }
        
        messageService.send(messageDestination, testMessage);
        
        commitHappened.set(true);
        xService.commitTransaction();
        receiveThreadDone.await();
        
        xService.beginTransaction();
        try {
            Kic readKic = kicCrud.retrieveKic(kic.getKeplerId());
            assertEquals(kic, readKic);
            BlobResult blobResult = fsClient.readBlob(fsId);
            assertEquals(1, blobResult.data().length);
            assertEquals((byte)66, blobResult.data()[0]);
        } finally {
            xService.rollbackTransaction();
        }
        
        if (receiverException.get() != null) {
            throw new IllegalStateException("Embedded receiver thread exception.", 
                                                                   receiverException.get());
        }
        
    }
    
    /**
     * Enlist a service, but access a non-enlisted service and see that an
     * exception is thrown.
     * 
     * @throws Exception
     */
    @Test
    public void failToEnlistService() throws Exception {
        log.info("Mark test start.");
        failToEnlistService(true);
        failToEnlistService(false);
    }
    
    private void failToEnlistService(boolean xa) throws Exception {
        
        TransactionService xService = TransactionServiceFactory.getInstance(xa);
        xService.beginTransaction(true, false, false);
        
        try {
            FileStoreClientFactory.getInstance();
            assertTrue("Should have thrown exception.", false);
        } catch (PipelineException px) {
            //ok
        } finally {
            xService.rollbackTransaction();
        }
        
        xService.beginTransaction(false, false,true);
        try {
            DatabaseServiceFactory.getInstance(xa);
            assertTrue("Should have thrown exception.", false);
        } catch (PipelineException px) {
            //ok
        } finally {
            xService.rollbackTransaction();
        }
        
        xService.beginTransaction(true, false, false);
        try {
            MessagingServiceFactory.getInstance(xa);
        } catch (PipelineException px) {
            //ok
        } finally {
            xService.rollbackTransaction();
        }
    }
    
    /**
     * Read and write into the database and file store with the same transaction
     * in multiple threads.
     * 
     * @throws Exception
     */
    @Test
    public void multipleThreadsPerTransaction() throws Exception {
        log.info("Mark test start.");
        TransactionService xaTransactionService =
            TransactionServiceFactory.getInstance(true);
        
        ExecutorService executorService = 
            Executors.newFixedThreadPool(1, new ThreadFactory() {
                private ThreadGroup tGroup = new ThreadGroup("Test");

                @Override
                public Thread newThread(Runnable r) {
                    return new Thread(tGroup, r);
                }
            });
        
        xaTransactionService.beginTransaction(true,false,true);
        
        final Transaction currentTransaction =
            xaTransactionService.transactionManager().getTransaction();
        
        final TransactionManager transactionManager =
            xaTransactionService.transactionManager();
        
        final CountDownLatch done = new CountDownLatch(1);
        final AtomicReference<Exception> workerException =
            new AtomicReference<Exception>();
        final FsId blobFsId = new FsId("/test/multi-thread-transaction");
        executorService.execute(new Runnable() {

            @Override
            public void run() {
                try {
                    transactionManager.resume(currentTransaction);
                    assertTrue(transactionManager.getTransaction() != null);
                    DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
                    KicCrud kicCrud = new KicCrud(dbService);
                    Kic kic = (new Kic.Builder(99999, 74.0,74.99)).build();
                    kicCrud.create(kic);
                    FileStoreClient fsClient = FileStoreClientFactory.getInstance();
                    currentTransaction.enlistResource(fsClient.getXAResource());

                    fsClient.writeBlob(blobFsId, 
                        789, new byte[] { (byte) 77});
                } catch (InvalidTransactionException e) {
                    workerException.set(e);
                } catch (IllegalStateException e) {
                    workerException.set(e);
                } catch (SystemException e) {
                    workerException.set(e);
                } catch (PipelineException e) {
                    workerException.set(e);
                } catch (RollbackException e) {
                    workerException.set(e);
                } finally {
                    done.countDown();
                }
            }
            
        });
        done.await();
        
        xaTransactionService.commitTransaction();
        
        if (workerException.get() != null) {
            throw workerException.get();
        }
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        BlobResult blobResult = fsClient.readBlob(blobFsId);
        assertEquals(789L, blobResult.originator());
        assertEquals((byte)77, blobResult.data()[0]);
    }
    
    @Test
    public void rollbackTest() throws Exception {
        TransactionService xService = TransactionServiceFactory.getInstance(true);
        xService.beginTransaction();
        xService.rollbackTransactionIfActive();
        assertEquals(null, FileStoreClientFactory.getInstance().xidForCurrentThread());
    }
}
