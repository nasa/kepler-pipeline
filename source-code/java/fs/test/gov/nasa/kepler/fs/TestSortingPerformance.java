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

package gov.nasa.kepler.fs;

import java.util.*;

/**
 * This is a sorting performance micro-benchmark.
 * @author Sean McCauliff
 *
 */
public class TestSortingPerformance {

    private static final double NANOS_TO_S = 1000.0 * 1000.0 * 1000.0;
    
    public static void main(String[] argv) throws Exception {
        
        //warmup JVM
        for (int i=0; i < 10000; i++) {
            List<Integer> a = generatePreSortedArray(1024);
            Collections.sort(a);
            checkAscending(a);
            
        }
        System.out.println("Warmup completed.");
        
        for (int n=1; n > 0; n = n << 1) {
            List<Integer> a = generatePreSortedArray(n);
            double start = System.nanoTime();
            checkAscending(a);
            double end = System.nanoTime();
            double checkTime = (end - start) / NANOS_TO_S;
            
            start = System.nanoTime();
            Collections.sort(a);
            end = System.nanoTime();
            double sortTime = (end - start) / NANOS_TO_S;
            
            System.out.println(n + " " + sortTime + " " + checkTime);
            a = null;
            System.gc();
        }
    }
    
    private static void checkAscending(List<Integer> a) {
        if (a.size() <= 1) {
            return;
        }
        
        Integer prev = a.get(0);
        for (int i=1; i < a.size(); i++) {
            if (prev.compareTo(a.get(i)) > 0) {
                throw new IllegalStateException("Unsorted list.");
            }
        }
    }
    
    private static List<Integer> generatePreSortedArray(final int n) {
        List<Integer> a = new ArrayList<Integer>(n);
        
        for (int i=0; i < n; i++) {
            a.add(i);
        }
        return a;
    }
}
