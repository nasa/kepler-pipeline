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

package gov.nasa.kepler.fs.server.index.btree;

import gov.nasa.spiffy.common.concurrent.ConcurrentLruCache;

import java.lang.ref.SoftReference;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author Sean McCauliff
 *
 */
public class SoftReferenceTest {

    private static final int N_OBJECTS = 100000000;
    private static final int MAX_CACHE = N_OBJECTS / 5;
    
    public static void main(String argv[]) throws Exception {
        boolean useSoftReference = Boolean.valueOf(argv[0]);
        
      
        final int nThreads = Runtime.getRuntime().availableProcessors();
        final  AtomicInteger nextSlot = new AtomicInteger(0);
        final CountDownLatch done = new CountDownLatch(nThreads);
        double startTime = System.currentTimeMillis();
        
        Runnable r  = null;
        
        if (useSoftReference) {

            final Object[] references = new Object[N_OBJECTS];
            
            r = new Runnable() {
                public void run() {
                    for (int index = nextSlot.getAndIncrement();
                           index < N_OBJECTS;
                           index = nextSlot.getAndIncrement()) {
                        references[index] = new SoftReference<Double>(new Double(index));
                    }
                    done.countDown();
                }
            };
            
        } else {

            final ConcurrentLruCache<Object, Object> lruCache = 
                new ConcurrentLruCache<Object, Object>(MAX_CACHE);
            
            r = new Runnable() {
                public void run() {
                    for (int count=nextSlot.getAndIncrement(); 
                            count < N_OBJECTS; count = 
                            nextSlot.getAndIncrement()) {
                        Double k = new Double(count);
                        Double v = new Double(count);
                        lruCache.put(k, v);
                    }
                    done.countDown();
                }
            };
            
        }
        
        for (int i=0; i < nThreads; i++) {
            Thread t = new Thread(r);
            t.start();
        }
        done.await();
        
        double endTime = System.currentTimeMillis();
        double duration = (endTime - startTime) / 1000.0;
        System.out.println("Duration in seconds " + duration);
    }
}
