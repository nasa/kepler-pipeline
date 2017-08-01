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

import gov.nasa.kepler.fs.api.FileStoreException;
import gov.nasa.kepler.fs.api.FileStoreTransactionTimeOut;
import gov.nasa.kepler.fs.server.ThrottleInterface;

import java.io.IOException;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

import javax.transaction.xa.Xid;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

/**
 * Rollsback a transaction after a specified time.
 * 
 * @author Sean McCauliff
 *
 */
class AutoRollbackRunnable implements Runnable, AutoRollback {

    private static final Log log = LogFactory.getLog(AutoRollbackRunnable.class);
    
    private final FileTransactionManager ftManager;
    public final Xid xid;
    private final ScheduledThreadPoolExecutor executor;
    private Date autoRollbackTime;
    private ScheduledFuture<?> scheduledFuture;
    private final ThrottleInterface throttle;

    /**
     * 
     * @param xid
     * @param initialScheduleSecs
     * @param exeService  This value is saved by the constructor in case the
     * autorollback time gets pushed back.
     * @param ftManager
     */
    AutoRollbackRunnable(Xid xid, int initialScheduleSecs, 
        ScheduledThreadPoolExecutor executor,
        FileTransactionManager ftManager, ThrottleInterface throttle) {
        this.xid = xid;
        this.throttle = throttle;
        this.ftManager = ftManager;
        this.executor = executor;
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MILLISECOND, initialScheduleSecs * 1000);
        autoRollbackTime = cal.getTime();

        scheduledFuture =
            executor.schedule(this, initialScheduleSecs, TimeUnit.SECONDS);
        
    }

    /**
     * Causes this transaction to automatically rollback.
     */
    @Override
    public void run() {
        log.warn("Transaction auto rollback time reached for \"" + xid
            + "\".");
        try {
            ftManager.rollback(xid, throttle);
        } catch (FileStoreTransactionTimeOut xto) {
            log.warn(
                "Transaction auto rollback failed for \"" + xid + "\"", xto);
        } catch (InterruptedException ie) {
            log.warn(
                "Transaction auto rollback failed for \"" + xid + "\"", ie);
        } catch (IOException ioe) {
            log.warn(
                "Transaction auto rollback failed for \"" + xid + "\"", ioe);
        } catch (FileStoreException e) {
            log.warn(
                "Transaction auto rollback failed for \"" + xid + "\"", e);
        }
    }

    public void reschedule(int rollbackInSecs) {
        if (!scheduledFuture.cancel(false)) {
            throw new IllegalStateException("Failed to cancel auto " +
                "rollback on \"" + xid + "\".");
        }

        scheduledFuture =  executor.schedule(this, rollbackInSecs,
            TimeUnit.SECONDS);
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.MILLISECOND, rollbackInSecs * 1000);
        autoRollbackTime = cal.getTime();
    }

    public Xid xid() {
        return xid;
    }

    public void remove() {
        
        if (log.isDebugEnabled()) {
            long remaining = System.currentTimeMillis() - autoRollbackTime.getTime();
            log.debug("Canceling auto rollback of transaction \""  + xid + 
            "\" with " + remaining + " ms remaining.");
        }
        scheduledFuture.cancel(false);
    }

    public Date autoRollbackTime() {
        return autoRollbackTime;
    }
}

