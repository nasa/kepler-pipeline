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

import static org.junit.Assert.*;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.io.RandomAccessFile;
import java.util.Collections;
import java.util.Date;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicReference;
import java.util.concurrent.locks.ReentrantReadWriteLock;

import javax.swing.JFrame;
import javax.swing.JToggleButton;
import javax.swing.SwingUtilities;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;

import gov.nasa.kepler.fs.api.*;
import gov.nasa.kepler.fs.client.FileStoreClientFactory;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TransactionService;
import gov.nasa.kepler.hibernate.dbservice.TransactionServiceFactory;
import gov.nasa.kepler.hibernate.dr.LogCrud;
import gov.nasa.kepler.hibernate.dr.ReceiveLog;
import gov.nasa.spiffy.common.io.FileUtil;
import gov.nasa.spiffy.common.io.Filenames;

public class ReproduceKSOC {

    private static final File testDir = new File(Filenames.BUILD_TEST, "/RepdoduceKSOC.test");

    private DatabaseService databaseService;
    private ReentrantReadWriteLock pause = new ReentrantReadWriteLock(true);
    
    @Before
    public void setUp() throws Exception  {
        databaseService = DatabaseServiceFactory.getInstance();
        databaseService.getDdlInitializer().initDB();
        FileUtil.mkdirs(testDir);
        
        SwingUtilities.invokeAndWait(new Runnable() {
            @Override
            public void run() {
                final JToggleButton pauseButton = new JToggleButton("Pause", false);
                pauseButton.addActionListener(new ActionListener() {
                    @Override
                    public void actionPerformed(ActionEvent e) {
                        if (pauseButton.isSelected()) {
                            pause.writeLock().lock();
                        } else {
                            pause.writeLock().unlock();
                        }
                    }
                });
                JFrame frame = new JFrame("Reproduce throttle leak.");
                frame.getContentPane().add(pauseButton);
                frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
                frame.pack();
                frame.setVisible(true);
            }
        });
    }

    @After
    public void tearDown() {
        databaseService.closeCurrentSession();
        databaseService.getDdlInitializer().cleanDB();
    }
    
    @Test
    public void leakTest() throws Exception {
        final FileStoreClient fsClient = FileStoreClientFactory.getInstance();
        fsClient.ping();
        
        final int nThreads = 8;
        CountDownLatch done = new CountDownLatch(nThreads);
        AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        
        for (int i=0; i < nThreads; i++) {
            Thread t = new Thread(new TestWorker(i, done, error, pause), "test worker " + i);
            t.start();
        }
        done.await();
        
        assertEquals(error.get() == null ? "" : error.get().toString(), null, error.get());
    }
        
    private static class TestWorker implements Runnable {
        private static final Log log = LogFactory.getLog(TestWorker.class);
        
        private int idCount;
        
        private final long workerId;
        private final CountDownLatch done;
        private final AtomicReference<Throwable> error;
        private final ReentrantReadWriteLock pause;
        
        TestWorker(long workerId, CountDownLatch done, 
            AtomicReference<Throwable> error, ReentrantReadWriteLock pause) {
            this.workerId = workerId;
            this.done = done;
            this.error = error;
            this.pause = pause;
        }
        
        @Override
        public void run() {
            
            try {
                for (int i=0; i < 1000; i++) {
                    if (error.get() != null) {
                        return;
                    }
                    pause.readLock().lockInterruptibly();
                    try {
                        doWork();
                    } finally {
                        pause.readLock().unlock();
                    }
                }
            } catch (Exception x) {
                error.compareAndSet(null, x);
                log.error("Worker " + workerId + " exiting.", x);
            } finally {
                done.countDown();
            }
        }
        
        private void doWork() throws Exception {
            File[] blobs = new File[3];
            for (int i=0; i < blobs.length; i++) {
                blobs[i] = new File(testDir, "blob-" + workerId + "-" + i);
                if (!blobs[i].exists()) {
                    RandomAccessFile raf;
                    raf = new RandomAccessFile(blobs[i], "rw");
                    raf.setLength(1024*1024);
                    raf.write(0xff);
                    raf.close();
                }
            }
            

            TransactionService xService  = TransactionServiceFactory.getInstance(true);
            FileStoreClient fsClient = FileStoreClientFactory.getInstance();
            fsClient.disassociateThread();
            
            xService.beginTransaction(true, false, true);
            
            fsClient.readTimeSeriesBatch(Collections.singletonList(new FsIdSet(0 , 1023, Collections.singleton(new FsId("/not/exist/" + workerId + "-" + idCount++)))), false);
            LogCrud logCrud = new LogCrud();
            logCrud.createReceiveLog(new ReceiveLog(new Date(), "blah", "blah2"));

            for (File blobFile : blobs) {
                fsClient.writeBlob(new FsId("/reproduce/ksoc/" + blobFile.getName()), workerId, blobFile);
            }
            
            FloatMjdTimeSeries mjdSeries = new FloatMjdTimeSeries(new FsId("/reproduce/ksoc/mjd" + workerId + "-" + idCount++), 0.0, 1.0, new double[] { 1.0 }, new float[] { 1.0f }, workerId);
            fsClient.writeMjdTimeSeries(new FloatMjdTimeSeries[] { mjdSeries });
            
            IntTimeSeries intSeries = new IntTimeSeries(new FsId("/reproduce/ksoc/int" + workerId + "-" + idCount++), new int[] { 1 },1, 1, new boolean[1], workerId);
            fsClient.writeTimeSeries(new TimeSeries[] { intSeries } );
            
            DatabaseServiceFactory.getInstance().flush();
            xService.commitTransaction();
        }
    }

}
