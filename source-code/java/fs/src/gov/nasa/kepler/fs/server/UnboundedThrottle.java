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
 * Basically no throttling.
 * 
 * This is useful when we don't want to tie into the global throttleing
 * mechanism or when it is safe to give out an unlimited number of permits.
 * 
 * @author Sean McCauliff
 *
 */
public class UnboundedThrottle implements ThrottleInterface {
    
    /**
     * Creates a new unbounded throttle.  Usefule for testing.
     * 
     * @return a new instance of unbounded throttle.
     */
    public static UnboundedThrottle newInstance() {
        return new UnboundedThrottle(2);
    }
    
    private final int permitsPerCall;
    
    public UnboundedThrottle(int permitsPerCall) {
        this.permitsPerCall = permitsPerCall;
    }
    

    @Override
    public void acquireReadPermit() throws InterruptedException {
        //This does nothing.
    }


    @Override
    public void acquireWritePermit() throws InterruptedException {
        //This does nothing.
    }


    @Override
    public void addPermits(int additionalPermits) {
        //This does nothing.
    }

    @Override
    public int currentState() {
        return Integer.MAX_VALUE;
    }


    @Override
    public AcquiredPermits greedyAcquirePermits() throws InterruptedException {
        return new AcquiredPermits() {
            
            @Override
            public void releasePermits() {
                //This does nothing.
            }
            
            @Override
            public int nPermits() {
                return permitsPerCall;
            }
        };
    }


    @Override
    public int initialPermits() {
        return Integer.MAX_VALUE;
    }


    @Override
    public int readCost() {
        return 0;
    }


    @Override
    public void releaseReadPermit() throws InterruptedException {
        //This does nothing.
    }

    @Override
    public void releaseWritePermit() {
        //This does nothing.
    }

    @Override
    public int totalPermits() {
        return Integer.MAX_VALUE;
    }


    @Override
    public int waitQueueLength() {
        return 0;
    }

    @Override
    public int writeCost() {
        return 0;
    }

}
