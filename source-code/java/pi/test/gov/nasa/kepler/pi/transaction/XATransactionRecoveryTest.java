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
import gov.nasa.kepler.fs.FileStoreConstants;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.cm.Kic;
import gov.nasa.kepler.hibernate.cm.KicCrud;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.XANodeNameFactory;
import gov.nasa.kepler.services.messaging.MessageContext;
import gov.nasa.kepler.services.messaging.MessagingService;
import gov.nasa.kepler.services.messaging.MessagingServiceFactory;
import gov.nasa.kepler.services.messaging.PipelineMessage;
import gov.nasa.spiffy.common.pi.PipelineException;

import javax.transaction.HeuristicMixedException;
import javax.transaction.RollbackException;
import javax.transaction.xa.XAException;
import javax.transaction.xa.XAResource;
import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests what happens for some failure modes in the 2PC protocol.
 * @author Sean McCauliff
 *
 */
public class XATransactionRecoveryTest {

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        DatabaseService dbService = DatabaseServiceFactory.getInstance(false);
        dbService.getDdlInitializer().initDB();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        DatabaseService dbService = DatabaseServiceFactory.getInstance(false);
        dbService.getDdlInitializer().cleanDB();
        
        TransactionService xService = TransactionServiceFactory.getInstance(true);
        xService.rollbackTransactionIfActive();
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        ((FileStoreTestInterface)fsClient).cleanFileStore();
    }
    
    
    @Test
    public void dbRollback2PCFailInPrepare() throws Exception {
        TransactionService xService = TransactionServiceFactory.getInstance(true);
        xService.beginTransaction(true, false, false);
        xService.transactionManager().getTransaction().enlistResource(new BogusXAResource(true));
        DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
        
        KicCrud kicCrud = new KicCrud(dbService);
        Kic kic = (new Kic.Builder(123456,1.0, 2.0)).build();
        kicCrud.create(kic);
        
        try {
            xService.commitTransaction();
            assertTrue("Should not have committed successfully.", false);
        } catch (RollbackException rbx) {
            //ok
        }
    
        DatabaseService localDbService = DatabaseServiceFactory.getInstance(false);
        localDbService.clear();
        kicCrud = new KicCrud(localDbService);
        assertFalse(kicCrud.exists(123456));
    }
    
    
    @Test
    public void failDuring2PCPrepare() throws Exception {
        final String queueName = "2PCPrepare";
        MessagingServiceFactory.getInstance(false).createQueue(queueName);

        final PipelineMessage message = new PipelineMessage();
        MessageQueuer queuer = new MessageQueuer(queueName, message);
        
        Thread t = new Thread(queuer);
        t.setDaemon(true);
        t.start();
        t.join();
        assertTrue("Message has not been queued.", queuer.isOk());
        
        
        TransactionService xService = TransactionServiceFactory.getInstance(true);
        xService.beginTransaction();
        
        FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
        MessagingService messagingService = MessagingServiceFactory.getInstance(true);
        MessagingServiceFactory.getInstance(true).createQueue(queueName);
        xService.transactionManager().getTransaction().enlistResource(new BogusXAResource(true));

        
        FsId fsId = new FsId("/xa-failure-test/fail-during-rollback");
        fsClient.writeBlob(fsId, 999, new byte[] {(byte)78});
        KicCrud kicCrud = new KicCrud(dbService);
        Kic kic = (new Kic.Builder(8889, 89.0, 45.0)).build();
        kicCrud.create(kic);
        

        MessageContext mContext = messagingService.receive(queueName, 1000*2);
        assertTrue(mContext != null);
        assertEquals(message, mContext.getPipelineMessage());
        
        try {
            xService.commitTransaction();
            assertTrue("Should not have reached here.", false);
        } catch (RollbackException rx) {
            //ok
        }
        
        //Message should still be on queue.
        xService.beginTransaction();
        //MessagingService localMessagingService = MessagingServiceFactory.getInstance(false);
        //localMessagingService.createQueue(queueName);
        mContext = messagingService.receive(queueName, 500);
            
        assertEquals(message, mContext.getPipelineMessage());
        
        //Blob must not exist.
        assertFalse(fsClient.blobExists(fsId));
        
        //Kic must not exist.
        kicCrud = new KicCrud(DatabaseServiceFactory.getInstance(false));
        assertTrue(kicCrud.retrieveKic(kic.getKeplerId()) == null);
        xService.rollbackTransaction();
    }

     @Test
     public void failDuring2PCCommit() throws Exception {
         final String queueName = "2PCCommit";
         MessagingServiceFactory.getInstance(false).createQueue(queueName);

         final PipelineMessage message = new PipelineMessage();
         MessageQueuer queuer = new MessageQueuer(queueName, message);
         
         Thread t = new Thread(queuer);
         t.setDaemon(true);
         t.start();
         t.join();
         assertTrue("Message has not been queued.", queuer.isOk());
         
         
         TransactionService xService = TransactionServiceFactory.getInstance(true);
         xService.beginTransaction();
         
         FileStoreClient fsClient = FileStoreClientFactory.getInstance();
         DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
         MessagingService messagingService = MessagingServiceFactory.getInstance(true);
         MessagingServiceFactory.getInstance(true).createQueue(queueName);
         xService.transactionManager().getTransaction().enlistResource(new BogusXAResource(false));
        
         FsId fsId = new FsId("/xa-failure-test/fail-during-rollback");
         fsClient.writeBlob(fsId, 999, new byte[] {(byte)78});
         KicCrud kicCrud = new KicCrud(dbService);
         Kic kic = (new Kic.Builder(8889, 89.0, 45.0)).build();
         kicCrud.create(kic);
         

         MessageContext mContext = messagingService.receive(queueName, 1000*2);
         assertTrue(mContext != null);
         assertEquals(message, mContext.getPipelineMessage());
         
         try {
             xService.commitTransaction();
             assertTrue("Transaction should not have committed.", false);
         } catch (HeuristicMixedException hmix) {
             //ok.
         }
     }
     
     @Test
     public void runtimeFileStoreCommitException() throws Exception {
         if (!XANodeNameFactory.isFactorySet()) {
             XANodeNameFactory.setInstance(new XANodeNameFactory("test-runtimeFileStoreCommitException"));
         }
         TransactionService xService = TransactionServiceFactory.getInstance(true);
         
         Configuration config = ConfigurationServiceFactory.getInstance();
         config.setProperty(FileStoreConstants.FS_TEST_MID_COMMIT_ERROR, true);
         
         try {
             
             xService.beginTransaction();
             DatabaseService dbService = DatabaseServiceFactory.getInstance(true);
             
             KicCrud kicCrud = new KicCrud(dbService);
             Kic kic = (new Kic.Builder(333, 45.0, 45.0)).build();
             kicCrud.create(kic);
             
             FileStoreClient fsClient = FileStoreClientFactory.getInstance();
             for (int i=0; i < 10; i++) {
                 FsId id = new FsId("/test/blah/" + i);
                 fsClient.writeBlob(id, 999, new byte[] { (byte) 77});
             }
             xService.commitTransaction();
             assertTrue("Should not have reached here.", false);
         } catch (HeuristicMixedException hmix) {
             //ok
         } finally {
             xService.rollbackTransactionIfActive();
             config.setProperty(FileStoreConstants.FS_TEST_MID_COMMIT_ERROR, false);
         }
     }
     
    /**
     * This XA Resource always fails during prepare/commit().
     *
     */
    private static final class BogusXAResource  implements XAResource {
        private Xid xid;
        private int timeout = 60;
        private final boolean failOnPrepare;
        
        BogusXAResource(boolean failOnPrepare) {
            this.failOnPrepare = failOnPrepare;
        }
        
        @Override
        public void commit(Xid arg0, boolean arg1) throws XAException {
            if (!failOnPrepare) {
                throw new XAException(XAException.XA_HEURMIX);
            }
            //Should never reach here.
            throw new IllegalStateException("Should not have reached commit.");
        }

        @Override
        public void end(Xid arg0, int arg1) throws XAException {
            //This does nothing.,
        }

        @Override
        public void forget(Xid arg0) throws XAException {
            xid = null;
        }

        @Override
        public int getTransactionTimeout() throws XAException {
            return timeout;
        }

        @Override
        public boolean isSameRM(XAResource arg0) throws XAException {
            return arg0 == this;
        }

        @Override
        public int prepare(Xid arg0) throws XAException {
            if (failOnPrepare) {
                throw new XAException(XAException.XA_RBROLLBACK);
            }
            return XA_OK;
        }

        @Override
        public Xid[] recover(int flags) throws XAException {
            if ((flags & TMSTARTRSCAN) == 0) {
                return new Xid[0];
            }
            
            if (xid != null) {
                return new Xid[] {xid};
            }
            
            return new Xid[0];
            
        }

        @Override
        public void rollback(Xid arg0) throws XAException {
            if (arg0 != xid) {
                throw new IllegalArgumentException("Bad xid.");
            }
            xid = null;
        }

        @Override
        public boolean setTransactionTimeout(int arg0) throws XAException {
            timeout = arg0;
            return true;
        }

        @Override
        public void start(Xid arg0, int arg1) throws XAException {
            xid = arg0;
        }

    }
    
    private static class MessageQueuer implements Runnable {
        private final String queueName;
        private final PipelineMessage message;
        private boolean ok = false;
        
        MessageQueuer(String queueName, PipelineMessage message) {
            this.queueName = queueName;
            this.message = message;
        }
        
        public boolean isOk() {
            return ok;
        }
        
        @Override
        public void run() {
            try {
                MessagingService messagingService = MessagingServiceFactory.getInstance(false);
                messagingService.send(queueName, message);
                messagingService.commitTransaction();
                
                ok = true;
               // MessageContext mCtx = messagingService.receive(queueName, 1000*5);
                //assertTrue(mCtx != null);
                
            } catch (PipelineException e) {
                // TODO Auto-generated catch block
                e.printStackTrace();
            }
        }
        
    }
    
}
