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

import java.util.concurrent.locks.ReentrantReadWriteLock;


/**
 * Exposes more of the debugging methods to find problems.  Note that
 * these methods do not lock the lock itself and therefore will produce
 * inconsistent results.
 * 
 * @author Sean McCauliff
 *
 */
public class DebugReentrantReadWriteLock extends ReentrantReadWriteLock {

    /**
     * 
     */
    private static final long serialVersionUID = -8455403679596750596L;
    
    /**
     * Unfair.
     * @param lockName Used when dumping out lock state.
     */
    public DebugReentrantReadWriteLock() {
        super();
    }

    /**
     * Optionally fair
     * @param fair Set to true when you want to queue threads.
     */
    public DebugReentrantReadWriteLock(boolean fair) {
        super(fair);
    }

    /**
    * @return does not return null
     */
    public String dumpLockState(String lockName) { 
        StringBuilder bldr = new StringBuilder();
        bldr.append("Dump of lock :").append(lockName);
        bldr.append(" Write owner: ").append(super.getOwner());
        bldr.append(" Queue length").append(super.getQueueLength());
        return bldr.toString();
    }
    
    public String getWriteLockOwnerName() {
    	Thread owner = getOwner();
    	if (owner == null) {
    		return "write lock not held";
    	} else {
    		return owner.getName();
    	}
    }
    
    public String getWriteLocksOwnersStack() {
        Thread owner = getOwner();
        if (owner == null) {
            return "no stack";
        }
        
        StackTraceElement[] threadStack = owner.getStackTrace();
        StringBuilder bldr = new StringBuilder(256);
        for (StackTraceElement s : threadStack) {
            bldr.append(s).append('\n');
        }
        return bldr.toString();
    }
}
