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

/**
 * An interface for a throttle which controls the amount of concurrency in the
 * file store server.
 * 
 * @author Sean McCauliff
 */
public interface ThrottleInterface {

    /**
     * Clients calling this must call releaseWritePermit() to release permits
     * back into the pool.  This method may block indefinitely if no permits
     * are available.
     * @throws InterruptedException
     */
    public void acquireWritePermit() throws InterruptedException;

    /**
     * Releases permits back into the pool after a call to acquireWritePermit().
     * This may not do any checking to see if a call has been made previously
     * to acquireWritePermits().
     * @throws InterruptedException
     */
    public void releaseWritePermit();

    /**
     * Clients calling this must call releaseReadPermit() to release permits
     * back into the pool.  This method may block indefinitely if no permits
     * are available.
     * @throws InterruptedException
     */
    public void acquireReadPermit() throws InterruptedException;

    /**
     * Releases permits back into the pool after a call to acquireReadPermit().
     * This may not do any checking to see if a call has been made previously
     * to acquireReadPermits().
     * @throws InterruptedException
     */
    public void releaseReadPermit() throws InterruptedException;

    /** 
     * Acquire as many permits as possible leaving some permits available for others.
     * There are some floors on this so if only a few permits are remaining then they 
     * will be acquired and the count will be left at zero.
     * 
     * @return More than zero permits.
     * @throws InterruptedException 
     */
    public AcquiredPermits greedyAcquirePermits() throws InterruptedException;

    /**
     * The number of threads waiting to acquire permits.  This number is 
     * unreliable.
     * @return A non-negative integer.
     */
    public int waitQueueLength();

    /**
     * The number of permits available when the ThrottleInterface was initialized.
     * @return A non-negative integer.
     */
    public int initialPermits();

    /**
     * The number of permits available.
     * @return A non-negative integer.
     */
    public int currentState();

    /**
     * The number of permits handed out or available.  This may be greater than
     * initialPermits() since a client may add permits via the addPermits()
     * method.
     * @return A non-negative integer.
     */
    public int totalPermits();

    /**
     * The number of permits consumed when acquireReadPermit() is called.
     * @return A non-negative integer.
     */
    public int readCost();

    /**
     * The number of permits consumed when acquireWritePermit() is called.
     * @return A non-negative integer.
     */
    public int writeCost();

    /**
     * Adds permits to the total number of permits.  There is no way to
     * decrement the number of total permits.
     * @param additionalPermits A non-negative integer.
     */
    public void addPermits(int additionalPermits);

}