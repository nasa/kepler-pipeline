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

import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.TransactionClosedException;
import gov.nasa.kepler.fs.api.TransactionNotExistException;
import gov.nasa.kepler.fs.server.ThrottleInterface;
import gov.nasa.kepler.fs.server.UnboundedThrottle;
import gov.nasa.kepler.fs.server.WritableBlob;
import gov.nasa.kepler.fs.server.jmx.TransactionMonitoringInfo;
import gov.nasa.kepler.hibernate.dbservice.ConfigurationServiceFactory;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.util.List;
import java.util.Random;
import java.util.concurrent.BrokenBarrierException;
import java.util.concurrent.CyclicBarrier;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.Xid;

import org.apache.commons.configuration.Configuration;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

/**
 * Like FileTransactionManagerTest, but for longer tests.
 * 
 * @author Sean McCauliff
 *
 */
public class FileTransactionManagerIntegrationTest {

    private FileTransactionManager ftm;
    private final ThrottleInterface throttle = UnboundedThrottle.newInstance();
    
    
    @Before
    public void setup() {
        
    }
    
    @After
    public void teardown() throws Exception {
        ftm.cleanUp();
    }
    
    
    /**
     * Multi-thread force rollback test.
     */
    @Test
    public void mtForceRollbackTest() throws Exception {
        final int NITER = 128;
        final CyclicBarrier start = new CyclicBarrier(2);
        final CyclicBarrier done = new CyclicBarrier(2);
        final AtomicBoolean ok = new AtomicBoolean(false);
        final AtomicReference<Exception> workerException = new AtomicReference<Exception>();

        Configuration config = ConfigurationServiceFactory.getInstance();
        ftm = new FileTransactionManager(config);

        Runnable r = new Runnable() {

            public void run() {
                try {
                    Xid xid = ftm.beginLocalTransaction(InetAddress.getLocalHost(), throttle);
                    start.await();
                    for (int i = 0; i < Integer.MAX_VALUE; i++) {
                        FsId id = new FsId("/forceRollback/" + i);
                        TransactionalStreamFile xStream = ftm.openStreamFile(
                            xid, id, true);
                        WritableBlob wBlob = null;
                        try {
                            wBlob = xStream.writeBlob(xid, 77);
                            FileChannel fchannel = wBlob.fileChannel;
                            fchannel.write(ByteBuffer.allocate(1024 * 16));
                        } finally {
                            if (wBlob != null) {
                                wBlob.close();
                            }
                        }
                    }
                } catch (TransactionNotExistException xnxe) {
                    // ok
                    ok.set(true);
                } catch (TransactionClosedException xclosed) {
                    ok.set(true);
                } catch (Exception e) {
                    workerException.set(e);
                } finally {
                    try {
                        done.await();
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    } catch (BrokenBarrierException e) {
                        e.printStackTrace();
                    }
                }
            }
        };

        Thread currentThread = null;
        Random rand = new Random(4444);
        try {
            for (int i = 0; i < NITER; i++) {
                currentThread = new Thread(r, "mtForceRollbackTest-" + i);
                currentThread.setDaemon(true);
                currentThread.start();
                start.await();
                Thread.sleep(rand.nextInt(1000));
                List<TransactionMonitoringInfo> xInfo = ftm.transactionMonitoringInfo();
                assertTrue(ftm.forceRollback(xInfo.get(0).getSimpleId()));
                done.await();
                String assertMessage = workerExceptionTrace(workerException.get());
                assertTrue(assertMessage, ok.get());

                start.reset();
                done.reset();
                ok.set(false);
            }
        } finally {
            // Don't leave threads hanging around.
            if (currentThread.isAlive()) {
                currentThread.interrupt();
            }
        }
    }

    private String workerExceptionTrace(Exception e) {
        if (e == null) {
            return "no exception.";
        }

        StringWriter swriter = new StringWriter();
        PrintWriter pwriter = new PrintWriter(swriter);
        e.printStackTrace(pwriter);
        pwriter.flush();
        return swriter.toString();
    }
}
