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

package gov.nasa.kepler.ar.exporter;

import java.util.Arrays;

/**
 * Testing multidimensional array support in Java.
 * 
 * @author Sean McCauliff
 *
 */
public class ArrayTester {

    /**
     * @param args
     */
    public static void main(String[] argv) {
        double[][][] da = new double[2][3][4];
        double[][][] cpy = new double[2][3][4];
        int count=1;
        for (int i=0; i < da.length; i++) {
            for (int j=0; j < da[i].length; j++) {
                for (int k=0; k < da[i][j].length; k++) {
                    da[i][j][k] = count;
                    cpy[i][j][k] = count++;
                }
            }
        }
        System.out.println("Printing multi-dimensional double toString().");
        System.out.println(da);
        
        System.out.println("Printing multi-dimensional with Arrays.deepToString()");
        System.out.println(Arrays.deepToString(da));
        
        System.out.println("Filling multi-dimensional with Arrays.fill(da, 42.0) should throw exception.");
        try {
            Arrays.fill(da, 42.0);
            System.out.println(da);
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        System.out.println("Clone and compare da == daClone, da.equals(daClone).");
        double[][][] daClone = da.clone();
        System.out.println((da == daClone) + "," + daClone.equals(da));
        
        daClone[0][1][1] = 5555.0;
        System.out.println("Updating daClone with value 5555.0 also updates da.");
        System.out.println("daClone " +Arrays.deepToString(daClone));
        System.out.println("da " + Arrays.deepToString(da));
        
        System.out.println("Three dimensional array class.");
        System.out.println(da.getClass());
        

        System.out.println("Arrays.deepEquals(da,cpy) should be false.");
        System.out.println(Arrays.deepEquals(da, cpy));
        cpy[0][1][1] = 5555.0;
        System.out.println("Arrays.deepEquals(da,cpy) should be true.");
        System.out.println(Arrays.deepEquals(da, cpy));
        
        System.out.println("Arrays.deepHashCode(da),Arrays.hashCode(da),ds.hashCode()");
        System.out.println(Arrays.deepHashCode(da)+","+Arrays.hashCode(da) + "," + da.hashCode());
       
    }

}
