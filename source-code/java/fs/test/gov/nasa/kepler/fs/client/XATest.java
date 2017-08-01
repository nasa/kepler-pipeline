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

package gov.nasa.kepler.fs.client;


import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import gov.nasa.kepler.fs.api.FileStoreClient;
import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreTestInterface;
import gov.nasa.kepler.fs.api.FsId;
import gov.nasa.kepler.fs.api.IntTimeSeries;
import gov.nasa.kepler.fs.api.TimeSeries;
import gov.nasa.kepler.fs.server.FakeXid;
import gov.nasa.spiffy.common.intervals.SimpleInterval;
import gov.nasa.spiffy.common.intervals.TaggedInterval;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

import java.io.*;
import java.math.BigInteger;
import java.util.Arrays;
import java.util.Collections;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

import javax.transaction.xa.XAResource;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

public class XATest {

    private static final Log log = LogFactory.getLog(XATest.class);
    
    private FileStoreClient fsClient;
    private File testRoot;

    @Before
    public void setUp() throws Exception {
        fsClient = FileStoreClientFactory.getInstance();
        testRoot = new File(Filenames.BUILD_TEST, "XATest.test");
        if (testRoot.exists()) {
            FileUtil.cleanDir(testRoot);
        }
        FileUtil.mkdirs(testRoot);
    }

    @After
    public void tearDown() throws Exception {   
        ((FileStoreTestInterface) fsClient).cleanFileStore();
        FileUtil.cleanDir(testRoot);
    }
    
    @Test
    public void xaCommit() throws Exception {
        xaCommit(false);
    }
    
    @Test
    public void xaCommitSinglePhase() throws Exception {
        xaCommit(true);
    }
    
    private void xaCommit(boolean singlePhase) throws Exception {
        FakeXid xid = new FakeXid(new BigInteger("33"), new BigInteger("4"));
        XAResource xaResource = fsClient.getXAResource();
        xaResource.start(xid, XAResource.TMNOFLAGS);
        
        FsId id = new FsId("/blah/gak/1");
        int[] data = new int[45];
        Arrays.fill(data, 1);
        IntTimeSeries its = new IntTimeSeries(id, data, data.length, data.length*2-1, Collections.singletonList(new SimpleInterval(data.length, data.length*2-1)), Collections.singletonList(new TaggedInterval(data.length, data.length*2-1, 55)));
        
        fsClient.writeTimeSeries(new TimeSeries[] { its});
        xaResource.end(xid, XAResource.TMSUCCESS);
        if (singlePhase) {
            xaResource.commit(xid, true);
        } else {
            assertEquals(XAResource.XA_OK, xaResource.prepare(xid));
            xaResource.commit(xid, false);
        }
        
        IntTimeSeries[] read = fsClient.readAllTimeSeriesAsInt(new FsId[]{id});
        assertEquals(1,read.length);
        assertTrue("Arrays must be equals.", Arrays.equals(data, read[0].iseries()));
    }
    
    /**
     * Check that we can associate and disassociate a thread with a
     * transaction.
     * 
     * @throws Exception
     */
    @Test
    public void xaDisassociate() throws Exception {
        FakeXid xid = new FakeXid(new BigInteger("33"), new BigInteger("4"));
        XAResource xaResource = fsClient.getXAResource();
        xaResource.start(xid, XAResource.TMNOFLAGS);
        xaResource.end(xid, XAResource.TMSUSPEND);
        
        FsId id = new FsId("/blah/gak/2");
        int[] data = new int[45];
        Arrays.fill(data, 2);
        IntTimeSeries its = new IntTimeSeries(id, data, data.length, data.length*2-1, Collections.singletonList(new SimpleInterval(data.length, data.length*2-1)), Collections.singletonList(new TaggedInterval(data.length, data.length*2-1, 55)));
        
        try {
            fsClient.writeTimeSeries(new TimeSeries[] { its });
        } catch (FileStoreException x) {
            //OK.
            x.printStackTrace();
        }
        
        xaResource.start(xid, XAResource.TMRESUME);
        
        fsClient.writeTimeSeries(new TimeSeries[] { its });
        
        xaResource.end(xid, XAResource.TMSUCCESS);
        xaResource.prepare(xid);
        xaResource.commit(xid, false);
        
        IntTimeSeries[] read = fsClient.readAllTimeSeriesAsInt(new FsId[]{id});
        assertEquals(1,read.length);
        assertTrue("Arrays must be equals.", Arrays.equals(data, read[0].iseries()));
        
    }
    
    /**
     * 
     */
    @Test
    public void xaRollback() throws Exception {
        FakeXid xid = new FakeXid(new BigInteger("33"), new BigInteger("4"));
        XAResource xaResource = fsClient.getXAResource();
        xaResource.start(xid, XAResource.TMNOFLAGS);
        xaResource.end(xid, XAResource.TMSUSPEND);
        
        FsId id = new FsId("/blah/gak/2");
        int[] data = new int[45];
        Arrays.fill(data, 2);
        IntTimeSeries its = new IntTimeSeries(id, data, data.length, data.length*2-1, Collections.singletonList(new SimpleInterval(data.length, data.length*2-1)), Collections.singletonList(new TaggedInterval(data.length, data.length*2-1, 55)));
        
        try {
            fsClient.writeTimeSeries(new TimeSeries[] { its });
        } catch (FileStoreException x) {
            //OK.
        }
        
        xaResource.start(xid, XAResource.TMRESUME);
        
        fsClient.writeTimeSeries(new TimeSeries[] { its });
        
        xaResource.end(xid, XAResource.TMSUCCESS);
        xaResource.rollback(xid);
        
        IntTimeSeries[] read = fsClient.readAllTimeSeriesAsInt(new FsId[] { id}, false );
        assertFalse(read[0].exists());
    }
    
    @Test
    public void isRmSame() throws Exception {
        RemoteXAAdapter xaAdapter = 
            (RemoteXAAdapter)  fsClient.getXAResource();
        
       RemoteXAAdapter xaAdapter2 = 
           new RemoteXAAdapter(xaAdapter.remoteResource());
       
       assertTrue(xaAdapter.isSameRM(xaAdapter2));
        
    }
    
    @Test
    public void remoteXAAdapterIsSerializable() throws Exception {
        XAResource xaResource = fsClient.getXAResource();
      
        FakeXid xid = new FakeXid(42, 23);
        xaResource.start(xid, XAResource.TMNOFLAGS);
        
        File xaResourceFile = new File(testRoot, "client.ser");
        ObjectOutputStream oos = 
            new ObjectOutputStream(new BufferedOutputStream(new FileOutputStream(xaResourceFile)));
        oos.writeObject(xaResource);
        oos.close();
        
        ObjectInputStream ois = new ObjectInputStream(new BufferedInputStream(new FileInputStream(xaResourceFile)));
        XAResource xaResourceDeSerialized = (XAResource) ois.readObject();
        assertTrue("XAResources should be the same.", xaResourceDeSerialized.isSameRM(xaResource));
        xaResourceDeSerialized.rollback(xid);
    }
    
    @Test
    public void avoidDeadlockOnRead() throws Exception {
        final FsId id = new FsId("/deadlock/test");
        IntTimeSeries its = new IntTimeSeries(id, new int[] { 7}, 0, 0, new boolean[1], 88L);
        fsClient.beginLocalFsTransaction();
        fsClient.writeTimeSeries(new TimeSeries[] { its } );
        fsClient.commitLocalFsTransaction();

        XAResource xaResource = fsClient.getXAResource();

        FakeXid xid = new FakeXid(999,34);
        xaResource.start(xid, XAResource.TMNOFLAGS);
        fsClient.writeTimeSeries(new TimeSeries[] { its } );
        xaResource.prepare(xid);

        final CountDownLatch start = new CountDownLatch(1);
        final AtomicBoolean done = new AtomicBoolean(false);
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        Runnable r = new Runnable() {
            @Override
            public void run() {
                try {
                    fsClient.disassociateThread();
                    start.countDown();
                    fsClient.readTimeSeriesAsInt(new FsId[] { id }, 0, 0);
                } catch (Throwable t) {
                    error.set(t);
                } finally {
                    done.set(true);
                }
            }
        };

        Thread thread = new Thread(r);
        thread.start();
        start.await();
        Thread.sleep(50);
        assertEquals(null, error.get());
        assertFalse(done.get());
        
        xaResource.commit(xid, false);
        thread.join();
        assertEquals(null, error.get());
        assertTrue(done.get());
    }
 
    @Test
    public void avoidDeadlockOnCommit() throws Exception {
        final FsId id1 = new FsId("/deadlock/test/1");
        final FsId id2 = new FsId("/deadlock/test/2");
        
        final IntTimeSeries its1 = new IntTimeSeries(id1, new int[] { 7}, 0, 0, new boolean[1], 88L);
        final IntTimeSeries its2 = new IntTimeSeries(id2, new int[] { 8}, 0, 0, new boolean[1],  88L);
        
        final CountDownLatch start = new CountDownLatch(1);
        final AtomicBoolean done = new AtomicBoolean(false);
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();

        final XAResource xaResource = fsClient.getXAResource();
        final FakeXid threadXid = new FakeXid(1,0);
        xaResource.start(threadXid, XAResource.TMNOFLAGS);
        fsClient.writeTimeSeries(new TimeSeries[] { its1, its2 }); 
        
        Runnable r = new Runnable() {
            @Override
            public void run() {
                try {
                    start.countDown();
                    fsClient.disassociateThread();
                    xaResource.start(threadXid, XAResource.TMJOIN);
                    xaResource.prepare(threadXid);
                    xaResource.commit(threadXid, false);
                } catch (Throwable t) {
                    log.error("avoid deadlock thread had an error", t);
                    error.set(t);
                } finally {
                    done.set(true);
                }
            }
        };
        
        fsClient.disassociateThread();
        FakeXid xid = new FakeXid(2,0);
        xaResource.start(xid, XAResource.TMNOFLAGS);
        fsClient.writeTimeSeries(new TimeSeries[] { its2 });
        xaResource.prepare(xid);
        
        Thread thread = new Thread(r, "avoid deadlock on commit");
        thread.start();
        start.await();
        Thread.sleep(200);
        assertEquals(null, error.get());
        assertFalse(done.get());


        xaResource.commit(xid, false);
        thread.join();
        assertTrue(done.get());
        assertEquals(null, error.get());
        
    }
}
