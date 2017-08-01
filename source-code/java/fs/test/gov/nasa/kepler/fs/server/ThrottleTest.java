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

package gov.nasa.kepler.fs.server;

import static org.junit.Assert.*;

import java.util.concurrent.atomic.AtomicBoolean;

import org.junit.Test;

/**
 * @author Sean McCauliff
 *
 */
public class ThrottleTest {

    @Test
    public void greedyThrottleTest() throws Exception {
        ThrottleInterface t = new Throttle(1, 1, 1);
        AcquiredPermits permits = t.greedyAcquirePermits();
        assertEquals(1, permits.nPermits());
        assertEquals(0, t.currentState());
        permits.releasePermits();
        assertEquals(1, t.currentState());
        
        t = new Throttle(3, 1, 2);
        permits = t.greedyAcquirePermits();
        assertEquals(2, permits.nPermits());
        assertEquals(1, t.currentState());
        permits.releasePermits();
        permits.releasePermits();
        assertEquals(3, t.currentState());
        
        t = new Throttle(13, 1, 2);
        permits = t.greedyAcquirePermits();
        assertEquals(6, permits.nPermits());
        assertEquals(7, t.currentState());
        
    }
    
    /**
     * Check that we block when minimum greediness has not been reached and 
     * we don't leak any permits when this happens.
     */
    @Test
    public void throttleLeakTest() throws Exception {
        final ThrottleInterface threadThrottle = new Throttle(3, 2, 1);
        threadThrottle.acquireReadPermit();
        final AtomicBoolean done = new AtomicBoolean(false);
        Thread blockedThread = new Thread(new Runnable() {
            
            @Override
            public void run() {
                try {
                    threadThrottle.greedyAcquirePermits();
                } catch (InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    return;
                }
                done.set(true);
            }
        });
        
        blockedThread.start();
        
        Thread.yield();
        Thread.sleep(100);
        assertFalse(done.get());
        threadThrottle.releaseReadPermit();
        Thread.yield();
        Thread.sleep(100);
        assertTrue(done.get());
        assertEquals(1, threadThrottle.currentState());
    }
}
