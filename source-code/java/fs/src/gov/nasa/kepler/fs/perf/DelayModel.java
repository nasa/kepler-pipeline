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

package gov.nasa.kepler.fs.perf;


import java.io.File;
import java.util.concurrent.ConcurrentMap;
import java.util.concurrent.ExecutionException;
import java.util.concurrent.TimeUnit;

import org.apache.commons.math3.random.MersenneTwister;

import com.google.common.cache.Cache;
import com.google.common.cache.CacheBuilder;
import com.google.common.cache.CacheLoader;

/**
 * How I/O is delayed.
 * 
 * @author Sean McCauliff
 *
 */
public class DelayModel {
    /**
     * This corrects the mean of the actual delay to be more like the expected
     * delay.
     */
    private static final long sleepOffsetNanoS = 90000;
    /**
     * Delays below this threshold are not reliable.  
     */
    private static final long minSleepNanoS = sleepOffsetNanoS;
    
    /** I have no idea if this is correct.  This is just an anecdote from
     * looking at iostat when the 3Par is busy.
     */
    private static final long meanDelayNanoS = 750000;
    private static final long sdDelayNanoS = 250000;
    private static final long LINEAR_SCAN = -1;
    
    private final MersenneTwister rand = new MersenneTwister(8984902982349L);
    
    private final long cachedBytes = 128 * 1024;
    
    private final Cache<File, Cache<Long, Long>> filesAccessed = CacheBuilder.newBuilder()
        .concurrencyLevel(16)
        .maximumSize(1000)
        .expireAfterAccess(1, TimeUnit.MINUTES)
        .build( new CacheLoader<File, Cache<Long, Long>>() {
            public Cache<Long, Long> load(File file) throws Exception {
                return CacheBuilder.newBuilder()
                    .concurrencyLevel(2)
                    .expireAfterAccess(30, TimeUnit.SECONDS)
                    .maximumSize(10)
                    .build(new CacheLoader<Long, Long>() {
                        public Long load(Long fileAddress) {
                            return fileAddress;
                        }
                    });
                }
            });
    
    /**
     * Generate a randomized delay time.
     * @return A non-negative delay time in nanoseconds.
     */
    private long nextDelay() {
        double next = -1;
        synchronized(this) {
            while (next < 0) {
                next = rand.nextGaussian() * sdDelayNanoS + meanDelayNanoS;
            }
        }
        long delay = (long) next;
        if (delay < minSleepNanoS) {
            return 0;
        }
        return delay;
    }
    
    /**
     * 
     * @param f
     * @param address
     */
    public long delayForFileAndAddress(File f, long address) {
        try {
            return delayForFileAndAddressInternal(f, address);
        } catch (ExecutionException ee) {
            throw new IllegalStateException(ee);
        }
    }
    
    private long delayForFileAndAddressInternal(File f, long address) throws ExecutionException {
        long delay = nextDelay();
        Long boxedAddress = address;
        Cache<Long, Long> addressesAccessedForFile = filesAccessed.get(f);
        ConcurrentMap<Long, Long> asMap = addressesAccessedForFile.asMap();
        switch ((int) addressesAccessedForFile.size()) {
            case 0: addressesAccessedForFile.get(boxedAddress); break; //new
            case 1: if (asMap.containsKey(LINEAR_SCAN) && address == LINEAR_SCAN) {
                return 0;
            }
            default:
                //Check if we are accessing some region that would have some
                //reasonable assumption of being cached.
                for (long prevAddr : asMap.values()) {
                    if (address >= prevAddr && address < (prevAddr + cachedBytes)) {
                        return 0;
                    }
                }
                addressesAccessedForFile.get(boxedAddress);
        }
        return delay;
    }
    
    public long delayForFile(File f) {
        return delayForFileAndAddress(f, LINEAR_SCAN);
    }
}
