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

package gov.nasa.kepler.fs.storage;

import static org.junit.Assert.*;

import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.concurrent.atomic.AtomicReference;

import gov.nasa.kepler.fs.server.index.PersistentSequence;
import gov.nasa.kepler.fs.storage.LaneAllocator.Allocation;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class LaneAllocatorTest {

	@Test
	public void laneAllocatTestOrderTest() throws Exception {
        PersistentSequence seq = new PersistentSequence() {
            private int n=0;
            @Override
            public synchronized int next() {
                return n++;
            }
        };
        
        LaneAllocator laneAllocator = new LaneAllocator(seq, (byte) 64);
        Allocation a1 = laneAllocator.allocateLane();
        Allocation a2 = laneAllocator.allocateLane();
        System.out.println(a1.fileNumber + " " + a1.laneNo);
        System.out.println(a2.fileNumber + " " + a2.laneNo);
	}
	
    @Test
    public void laneAllocatorTest() throws Exception {
        PersistentSequence seq = new PersistentSequence() {
            private int n=0;
            @Override
            public synchronized int next() {
                return n++;
            }
        };
        
        final int nAllocations = 256*1024;
        final AtomicInteger nAllocationCountDown = new AtomicInteger(nAllocations);
        final int nThreads = 8;
        
        final AtomicReference<Throwable> error = new AtomicReference<Throwable>();
        final CountDownLatch done = new CountDownLatch(nThreads);
        
        final LaneAllocator lalloc = new LaneAllocator(seq, (byte)2);
        final Map<Allocation, Boolean> seenSet = new ConcurrentHashMap<Allocation, Boolean>();
        
        Runnable r = new Runnable() {
            @Override
            public void run() {
                try {
                    while (nAllocationCountDown.decrementAndGet() >= 0 && error.get() == null) {
                        Allocation allocation = lalloc.allocateLane();
                        seenSet.put(allocation, Boolean.TRUE);
                    }
                } catch (Throwable t) {
                    error.compareAndSet(null, t);
                } finally {
                    done.countDown();
                }
            }
        };
        
        for (int i=0; i < nThreads; i++) {
            Thread thread = new Thread(r, "laneAllocationTest-" + i);
            thread.start();
        }
        
        done.await();
        
        if (error.get() != null) {
            error.get().printStackTrace();
        }
        assertEquals(null, error.get());
        
        assertEquals(nAllocations, seenSet.size());
    }
    

}
