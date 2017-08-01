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

import gov.nasa.spiffy.common.metrics.ValueMetric;

import java.util.concurrent.Semaphore;
import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;


/**
 * Prevents clients from thrashing the disk, memory and maximum number of 
 * processes/threads on the machine.  This implmentation uses a semaphore to 
 * dish out permits.
 * 
 * @author Sean McCauliff
 *
 */
public class Throttle implements ThrottleInterface {

    private static final Log log = LogFactory.getLog(Throttle.class);
    
    private static final String QUEUE_LEN_METRIC = "fs.server.throttle-queue-length";

    private static final int MINIMUM_GREEDINESS_CONST = 2;
    
    private final Semaphore semaphore;
    private AtomicInteger readCost;
    private AtomicInteger writeCost;
    private final int initialPermits;
    private AtomicInteger totalPermits;
    private final int minimumGreediness;
    
    public Throttle(int nPermits, int readCost, int writeCost) {
        if (nPermits <=  0) {
            throw new IllegalArgumentException("nPermits must be greater than zero");
        }
        
        if (readCost < 1) {
            throw new IllegalArgumentException("readCost must be greater than zero.");
        }
        
        if (writeCost < 1) {
            throw new IllegalArgumentException("writeCost must be greater than zero.");
        }
        
        if (writeCost > nPermits) {
            throw new IllegalArgumentException("writeCost must be greater than nPermits.");
        }
        
        if (readCost > nPermits) {
            throw new IllegalArgumentException("readCost must be greater than nPermits.");
        }
        
        semaphore = new Semaphore(nPermits, true);
        this.readCost = new AtomicInteger(readCost);
        this.writeCost = new AtomicInteger(writeCost);
        this.initialPermits = nPermits;
        this.totalPermits = new AtomicInteger(nPermits);
        minimumGreediness = Math.min(nPermits, MINIMUM_GREEDINESS_CONST);
    }
    

    public void acquireWritePermit() throws InterruptedException {
        semaphore.acquire(writeCost.get());
        ValueMetric.addValue(QUEUE_LEN_METRIC, semaphore.getQueueLength());
    }
    

    public void releaseWritePermit() {
        semaphore.release(writeCost.get());
        ValueMetric.addValue(QUEUE_LEN_METRIC, semaphore.getQueueLength());
    }
    

    public void acquireReadPermit() throws InterruptedException {
        semaphore.acquire(readCost.get());
        ValueMetric.addValue(QUEUE_LEN_METRIC, semaphore.getQueueLength());
    }
    

    public void releaseReadPermit() throws InterruptedException {
        semaphore.release(readCost.get());
        ValueMetric.addValue(QUEUE_LEN_METRIC, semaphore.getQueueLength());
    }
    

    public AcquiredPermits greedyAcquirePermits() throws InterruptedException {
        int nPermits = semaphore.drainPermits();
        if (nPermits < minimumGreediness) {
            semaphore.release(nPermits);
            semaphore.acquire(minimumGreediness);
            return new AcquiredPermitsImpl(minimumGreediness);
        }
        
        //Leave some permits.
        int permitsWanted = Math.max(minimumGreediness, nPermits/2);
        int giveBackPermits = nPermits - permitsWanted;
        if (giveBackPermits > 0) {
            semaphore.release(giveBackPermits);
        }
        return new AcquiredPermitsImpl(permitsWanted);
    }
    
    

    public int waitQueueLength() {
        return semaphore.getQueueLength();
    }
    

    public int initialPermits() {
        return initialPermits;
    }
    

    public int currentState() {
        return semaphore.availablePermits();
    }
    
    public int totalPermits() {
        return totalPermits.get();
    }
    

    public int readCost() {
        return readCost.get();
    }
    

    public int writeCost() {
        return writeCost.get();
    }
    

    public void addPermits(int additionalPermits) {
        if (additionalPermits < 0) {
            throw new IllegalArgumentException("Can not subtract permits.");
        }
        
        semaphore.release(additionalPermits);
        totalPermits.addAndGet(additionalPermits);
    }
    
    private class AcquiredPermitsImpl implements AcquiredPermits {

        private boolean released = false;
        private final int nPermits;
        
        
        private AcquiredPermitsImpl(int permits) {
            nPermits = permits;
        }

        @Override
        public int nPermits() {
            return nPermits;
        }

        @Override
        public synchronized void releasePermits() {
            if (released) {
                log.warn("Attempting to rerelease permits.");
                return;
            }
            
            semaphore.release(nPermits);
            released = true;
            
            if (semaphore.availablePermits() > totalPermits.get()) {
                assert false: "Added too many pemits.";
                log.warn("Added too many permits.");
             }
        }
        
    }
}
