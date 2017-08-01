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

package gov.nasa.spiffy.common.collect;

import java.lang.reflect.Array;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

public class ArrayUtils {

    public static int[] fillCopyOf(int[] original, int newLength, int value) {
        int[] array = null;
        if (original == null) {
            array = new int[newLength];
            Arrays.fill(array, value);
        } else if (original.length < newLength) {
            array = Arrays.copyOf(original, newLength);
            Arrays.fill(array, original.length, array.length, value);
        } else if (original.length > newLength) {
            array = Arrays.copyOf(original, newLength);
        } else {
            array = original;
        }
        return array;
    }

    public static float[] fillCopyOf(float[] original, int newLength,
        float value) {
        float[] array = null;
        if (original == null) {
            array = new float[newLength];
            Arrays.fill(array, value);
        } else if (original.length < newLength) {
            array = Arrays.copyOf(original, newLength);
            Arrays.fill(array, original.length, array.length, value);
        } else if (original.length > newLength) {
            array = Arrays.copyOf(original, newLength);
        } else {
            array = original;
        }
        return array;
    }

    public static String[] fillCopyOf(String[] original, int newLength,
        String value) {
        String[] array = null;
        if (original == null) {
            array = new String[newLength];
            Arrays.fill(array, value);
        } else if (original.length < newLength) {
            array = Arrays.copyOf(original, newLength);
            Arrays.fill(array, original.length, array.length, value);
        } else if (original.length > newLength) {
            array = Arrays.copyOf(original, newLength);
        } else {
            array = original;
        }
        return array;
    }

    public static void fill(String[][] a, String[] value) {
        if (a == null) {
            return;
        }
        for (int i = 0; i < a.length; i++) {
            a[i] = value;
        }
    }
    
    public static void fill(float[][] a, float value) {
        if (a == null) {
            return;
        }
        for (int i=0; i < a.length; i++) {
            final int subarrayLength = a[i].length;
            for (int j=0; j < subarrayLength; j++) {
                a[i][j] = value;
            }
        }
    }

    public static boolean arrayEquals(byte[] a, int a_start, byte[] b,
        int b_start, int length) {
        int ai = a_start;
        int bi = b_start;
        int b_end = b_start + length;
        for (; bi < b_end; ai++, bi++) {
            if (a[ai] != b[bi]) {
                return false;
            }
        }
        return true;
    }

    public static boolean arrayEquals(int[] a, int a_start, int[] b,
        int b_start, int length) {
        int ai = a_start;
        int bi = b_start;
        int b_end = b_start + length;
        for (; bi < b_end; ai++, bi++) {
            if (a[ai] != b[bi]) {
                return false;
            }
        }
        return true;
    }

    public static boolean arrayEquals(short[] a, int a_start, short[] b,
        int b_start, int length) {
        int ai = a_start;
        int bi = b_start;
        int b_end = b_start + length;
        for (; bi < b_end; ai++, bi++) {
            if (a[ai] != b[bi]) {
                return false;
            }
        }
        return true;
    }

    public static boolean arrayEquals(float[] a, int a_start, float[] b,
        int b_start, int length) {
        int ai = a_start;
        int bi = b_start;
        int b_end = b_start + length;
        for (; bi < b_end; ai++, bi++) {
            if (a[ai] != b[bi]) {
                return false;
            }
        }
        return true;
    }

    public static boolean arrayEquals(double[] a, int a_start, double[] b,
        int b_start, int length) {
        int ai = a_start;
        int bi = b_start;
        int b_end = b_start + length;
        for (; bi < b_end; ai++, bi++) {
            if (a[ai] != b[bi]) {
                return false;
            }
        }
        return true;
    }

    public static boolean equals(String[][] a, String[][] b) {
        if (a == null && b != null || a != null && b == null) {
            return false;
        }
        if (a == null && b == null) {
            return true;
        }
        
        if (a != null && b != null) {
            if (a.length != b.length) {
                return false;
            }

            for (int i = 0; i < a.length; i++) {
                if (!Arrays.equals(a[i], b[i])) {
                    return false;
                }
            }
        }

        return true;
    }

    public static int hashCode(String[][] a) {
        if (a == null) {
            return 0;
        }

        final int prime = 31;
        int result = 1;
        for (int i = 0; i < a.length; i++) {
            result = prime * result + Arrays.hashCode(a[i]);
        }

        return result;
    }

    public static boolean[] append(boolean[] src, boolean[] suffix) {
        boolean[] rv = new boolean[src.length + suffix.length];
        System.arraycopy(src, 0, rv, 0, src.length);
        System.arraycopy(suffix, 0, rv, src.length, suffix.length);
        return rv;
    }

    public static short[] append(short[] src, short[] suffix) {
        short[] rv = new short[src.length + suffix.length];
        System.arraycopy(src, 0, rv, 0, src.length);
        System.arraycopy(suffix, 0, rv, src.length, suffix.length);
        return rv;
    }

    public static int[] append(int[] src, int[] suffix) {
        int[] rv = new int[src.length + suffix.length];
        System.arraycopy(src, 0, rv, 0, src.length);
        System.arraycopy(suffix, 0, rv, src.length, suffix.length);
        return rv;
    }

    public static float[] append(float[] src, float[] suffix) {
        float[] rv = new float[src.length + suffix.length];
        System.arraycopy(src, 0, rv, 0, src.length);
        System.arraycopy(suffix, 0, rv, src.length, suffix.length);
        return rv;
    }

    public static double[] append(double[] src, double[] suffix) {
        double[] rv = new double[src.length + suffix.length];
        System.arraycopy(src, 0, rv, 0, src.length);
        System.arraycopy(suffix, 0, rv, src.length, suffix.length);
        return rv;
    }

    /**
     * This can copy any kind of array even primitive arrays, hence this is not
     * parameterized.
     * 
     * @param src The source array.
     * @param componentType The element type of the destination array. This may
     * be different from the src component type if the element of the src array
     * are assignable to the componentType.
     * @return An array object which has the specified component type.
     */
    public static Object copyArray(Object src, Class<?> componentType) {
        // Class<?> originalArrayComponentType =
        // originalArray.getClass().getComponentType();
        int originalArrayLength = Array.getLength(src);

        Object newArray = Array.newInstance(componentType, originalArrayLength);

        for (int i = 0; i < originalArrayLength; i++) {
            Array.set(newArray, i, Array.get(src, i));
        }

        return newArray;
    }

    /**
     * Like compareTo() except for byte arrays.
     * 
     * @param ba1
     * @param ba2
     * @return
     */
    public static int compareArray(byte[] ba1, byte[] ba2) {
        int diff = ba1.length - ba2.length;
        if (diff != 0) {
            return diff;
        }

        for (int i = 0; i < ba1.length; i++) {
            diff = ba1[i] - ba2[i];
            if (diff != 0) {
                return diff;
            }
        }

        return 0;
    }

    public static <T> Set<T> toSet(T[] a) {
        Set<T> actual = new HashSet<T>();
        for (T element : a) {
            actual.add(element);
        }
        return actual;
    }
    
    public static float[] doubleToFloat(double[] dbl) {
        float[] flt = new float[dbl.length];
        for (int i=0; i < dbl.length; i++) {
            flt[i] = (float) dbl[i];
        }
        return flt;
    }

}
