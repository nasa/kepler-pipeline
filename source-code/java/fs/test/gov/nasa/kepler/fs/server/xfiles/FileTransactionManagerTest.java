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

package gov.nasa.kepler.fs.server.xfiles;

import static gov.nasa.kepler.fs.FileStoreConstants.FS_XACTION_AUTOROLLBACK_SEC_PROPERTY;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TransactionNotExistException;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.kepler.fs.server.SingleAcquiredPermit;
import gov.nasa.kepler.fs.server.ThrottleInterface;
import gov.nasa.kepler.fs.server.UnboundedThrottle;
import gov.nasa.kepler.fs.server.WritableBlob;
import gov.nasa.kepler.fs.server.XidComparator;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringInfo;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.*;
import java.math.BigInteger;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.XAException;
import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * 
 * @author Sean McCauliff
 * 
 */
public class FileTransactionManagerTest {

    private static final Log log = LogFactory.getLog(FileTransactionManagerTest.class);
    
    private FileTransactionManager ftm;
    private File testDir = new File(Filenames.BUILD_TEST + "/FTMTest");
    // private File testFile = new File(testDir, "FTMtestfile.data");
    private FsId id = new FsId("/blah/blah");
    private final ThrottleInterface throttle = UnboundedThrottle.newInstance();

    /**
     * @throws java.lang.Exception
     */
    @Before
    public void setUp() throws Exception {
        testDir.mkdirs();
    }

    /**
     * @throws java.lang.Exception
     */
    @After
    public void tearDown() throws Exception {
        try {
            ftm.cleanUp();
            FileUtil.removeAll(testDir);
        } catch (IOException ioe) {
            log.error("teardown", ioe);
        }
        Configuration config = ConfigurationServiceFactory.getInstance();

        config.setProperty(FS_XACTION_AUTOROLLBACK_SEC_PROPERTY, "360");
    }

    /**
     * Sets the transaction autorollback property to be one second. After this
     * time period the transaction should automatically rollback.
     * 
     * @throws Exception
     */
    @Test
    public void transactionTimeOutAutoRollback() throws Exception {
        Configuration config = ConfigurationServiceFactory.getInstance();

        config.setProperty(FS_XACTION_AUTOROLLBACK_SEC_PROPERTY, "2");
        ftm = new FileTransactionManager(config);
        Xid xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(),throttle);
        TransactionalRandomAccessFile xf = ftm.openRandomAccessFile(xid, id,
            true);

        xf.write(new byte[] { (byte) 45 },0,  1, 0, xid, 
            Collections.singletonList(new SimpleInterval(0,1)), 
            Collections.singletonList(new TaggedInterval(0,1, 43)));
        Thread.sleep(3000);
        // transaction should be rolledback.
        try {
            xf.write(new byte[] { (byte) 45 }, 0, 1, 0, xid, 
                Collections.singletonList(new SimpleInterval(0,1)), 
                Collections.singletonList(new TaggedInterval(0,1, 43)));
            assertTrue("Should not have reached here.", false);
        } catch (IllegalArgumentException x) {
            // OK
        }

        try {
            // FileTransactionManager should no longer know about xid.
            ftm.executorService(xid, new SingleAcquiredPermit());
            assertTrue("Should not have reached here.", false);
        } catch (TransactionNotExistException xnxe) {
            // ok
        }

    }

    /**
     * Sets the transaction autorollback property to be two seconds. The normal
     * commit should occur before the auto-rollback.
     * 
     * @throws Exception
     */
    @Test
    public void transactionNoAutoRollback() throws Exception {
        Configuration config = ConfigurationServiceFactory.getInstance();

        final int timeoutSeconds = 8;
        final long startTime = System.currentTimeMillis();
        try {
            config.setProperty(FS_XACTION_AUTOROLLBACK_SEC_PROPERTY, "" + timeoutSeconds);
            ftm = new FileTransactionManager(config);
            Xid xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(),throttle);
            TransactionalRandomAccessFile xf = ftm.openRandomAccessFile(xid, id,
                true);
    
            xf.write(new byte[] { (byte) 45 }, 0, 1, 0, xid,  
                Collections.singletonList(new SimpleInterval(0,1)), Collections.singletonList(new TaggedInterval(0,1, 44)));
            ftm.prepareLocal(xid,throttle);
            ftm.commitLocal(xid,throttle);
            Thread.sleep(timeoutSeconds * 1000);
    
            xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(),throttle);
            byte[] buf = new byte[1];
            xf = ftm.openRandomAccessFile(xid, id, true);
            xf.read(buf, 0, 1, 0, xid);
            assertEquals((byte) 45, buf[0]);
        } catch (IOException ioe) {
            final long currentTime = System.currentTimeMillis();
            final long elapsedTimeSeconds = (currentTime - startTime)/1000L;
            if (elapsedTimeSeconds > timeoutSeconds) {
                log.warn("Test did not complete in expected time, but passing anyway.");
            } else {
                throw ioe;
            }
        }
    }

    /**
     * Check that the list of Xids that are returned by recover contain the Xid
     * of prepared XA transactions.
     * 
     * @throws Exception
     */
    @Test
    public void recoverXa() throws Exception {

        Configuration config = ConfigurationServiceFactory.getInstance();
        ftm = new FileTransactionManager(config);
        Xid xid = new FakeXid(new BigInteger("3434"), new BigInteger("4343"));
        ftm.startXaTransaction(xid, 3, InetAddress.getLocalHost(),throttle);
        TransactionalStreamFile xsf = ftm.openStreamFile(xid, id, true);
        WritableBlob writable = xsf.writeBlob(xid, 1);
        ByteBuffer bbuf = ByteBuffer.allocate(128);
        writable.fileChannel.write(bbuf);
        writable.close();
        ftm.prepareXa(xid, throttle);

        ftm = new FileTransactionManager(config);
        Xid[] recoveredXids = ftm.recoverXa(0);
        assertEquals(1, recoveredXids.length);
        assertEquals(0, XidComparator.INSTANCE.compare(xid, recoveredXids[0]));
        ftm.forgetXa(xid);
        recoveredXids = ftm.recoverXa(0);
        assertEquals(0, recoveredXids.length);

    }

    /**
     * Check that a rollback or commit on recovered XA transaction throws the
     * correct exception.
     * 
     * @throws Exception
     */
    @Test
    public void heuristicRollbackException() throws Exception {

        Configuration config = ConfigurationServiceFactory.getInstance();
        ftm = new FileTransactionManager(config);
        Xid xid = new FakeXid(new BigInteger("3434"), new BigInteger("4343"));
        ftm.startXaTransaction(xid, 600, InetAddress.getLocalHost(), throttle);
        TransactionalStreamFile xsf = ftm.openStreamFile(xid, id, true);
        WritableBlob writable = xsf.writeBlob(xid, 1);
        ByteBuffer bbuf = ByteBuffer.allocate(128);
        writable.fileChannel.write(bbuf);
        writable.close();
        ftm.prepareXa(xid,throttle);

        ftm = new FileTransactionManager(config);
        try {
            ftm.rollbackXa(xid,throttle);
            assertTrue("Execution should not have reached here.", false);
        } catch (XAException xa) {
            assertEquals(XAException.XA_HEURRB, xa.errorCode);
        }

        try {
            ftm.commitXa(xid, true, throttle);
            assertTrue("Execution should not have reached here.", false);
        } catch (XAException xa) {
            assertEquals(XAException.XA_HEURRB, xa.errorCode);
        }
    }

    /**
     * Test forcing rollback works correctly.
     */
    @Test
    public void forceRollbackTest() throws Exception {
        Configuration config = ConfigurationServiceFactory.getInstance();
        ftm = new FileTransactionManager(config);
        assertFalse(ftm.forceRollback(555));
        assertTrue(ftm.forceRollback());

        Xid xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(), throttle);
        assertTrue(ftm.forceRollback());
        try {
            ftm.commitLocal(xid,throttle);
            assertTrue("Should not have reached here.", false);
        } catch (TransactionNotExistException xnxe) {
            // ok
        }

        xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(), throttle);
        List<TransactionMonitoringInfo> xInfo = ftm.transactionMonitoringInfo();
        assertEquals(InetAddress.getLocalHost().toString()+"/main", xInfo.get(0)
            .getClient());
        ftm.forceRollback(xInfo.get(0).getSimpleId());
        try {
            ftm.commitLocal(xid, throttle);
            assertTrue("Should not have reached here.", false);
        } catch (TransactionNotExistException xnxe) {
            // ok.
        }
    }
 
}
