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

package gov.nasa.spiffy.common.persistable;

import static com.google.common.collect.Lists.newArrayList;

import java.util.Arrays;
import java.util.Date;
import java.util.List;

import com.google.common.collect.ImmutableList;

/**
 * @author tklaus
 * 
 */
public class TestPersistable implements Persistable {
    public enum TestPersistableEnum {
        EMPTY, VALUE_1, VALUE_2
    }

    @ProxyIgnore
    private static final byte ignoreEnabled = 1;
    @SuppressWarnings("unused")
    private static final byte ignoreDisabled = 2;

    private byte byte1;
    private short short1;
    private int int1;
    private long long1;
    private float float1;
    private double double1;
    private char char1;
    private boolean boolean1;

    private byte[] byteArray1 = {};
    private short[] shortArray1 = {};
    private int[] intArray1 = {};
    private long[] longArray1 = {};
    private float[] floatArray1 = {};
    private double[] doubleArray1 = {};
    private char[] charArray1 = {};
    private boolean[] booleanArray1 = {};

    private float[] primitiveArray1 = {};
    private float[][] primitiveArray2 = {};
    private float[][][] primitiveArray3 = {};

    private String string1 = "";

    private String[] stringArray1 = {};
    private String[][] stringArray2 = {};
    private String[][][] stringArray3 = {};

    private TestPersistableElement testPersistableElement1 = new TestPersistableElement();

    private List<TestPersistableElement> testPersistableElementList1 = newArrayList();
    private List<List<TestPersistableElement>> testPersistableElementList2 = newArrayList();
    private List<List<List<TestPersistableElement>>> testPersistableElementList3 = newArrayList();

    private TestPersistableElement[] testPersistableElementArray1 = {};
    private TestPersistableElement[][] testPersistableElementArray2 = {};
    private TestPersistableElement[][][] testPersistableElementArray3 = {};

    private Date date1 = new Date(0);

    private TestPersistableEnum testPersistableEnum1 = TestPersistableEnum.EMPTY;

    public TestPersistable(int seed) {
        this.byte1 = (byte) (seed + 1);
        this.short1 = (short) (seed + 2);
        this.int1 = seed + 3;
        this.long1 = seed + 4;
        this.float1 = seed + 5;
        this.double1 = seed + 6;
        this.char1 = (char) (seed + 7);
        this.boolean1 = true;

        this.byteArray1 = new byte[] { (byte) (seed + 8) };
        this.shortArray1 = new short[] { (short) (seed + 9) };
        this.intArray1 = new int[] { seed + 10 };
        this.longArray1 = new long[] { seed + 11 };
        this.floatArray1 = new float[] { seed + 12 };
        this.doubleArray1 = new double[] { seed + 13 };
        this.charArray1 = new char[] { (char) (seed + 14) };
        this.booleanArray1 = new boolean[] { true };

        this.primitiveArray1 = new float[] { seed + 15 };
        this.primitiveArray2 = new float[][] { { seed + 16 } };
        this.primitiveArray3 = new float[][][] { { { seed + 17 } } };

        this.string1 = String.valueOf(seed + 18);

        this.stringArray1 = new String[] { String.valueOf(seed + 19) };
        this.stringArray2 = new String[][] { { String.valueOf(seed + 20) } };
        this.stringArray3 = new String[][][] { { { String.valueOf(seed + 21) } } };

        this.testPersistableElement1 = new TestPersistableElement(seed + 22);

        this.testPersistableElementList1 = ImmutableList.of(new TestPersistableElement(
            seed + 23));

        List<TestPersistableElement> list = ImmutableList.of(new TestPersistableElement(
            seed + 24));
        this.testPersistableElementList2 = ImmutableList.of(list);

        List<TestPersistableElement> list2 = ImmutableList.of(new TestPersistableElement(
            seed + 25));
        List<List<TestPersistableElement>> listList = ImmutableList.of(list2);
        this.testPersistableElementList3 = ImmutableList.of(listList);

        this.testPersistableElementArray1 = new TestPersistableElement[] { new TestPersistableElement(
            seed + 26) };
        this.testPersistableElementArray2 = new TestPersistableElement[][] { { new TestPersistableElement(
            seed + 27) } };
        this.testPersistableElementArray3 = new TestPersistableElement[][][] { { { new TestPersistableElement(
            seed + 28) } } };

        this.date1 = new Date(29 * 60000);

        this.testPersistableEnum1 = TestPersistableEnum.VALUE_1;
    }

    public TestPersistable() {
    }

    public byte getByte1() {
        return byte1;
    }

    public void setByte1(byte byte1) {
        this.byte1 = byte1;
    }

    public short getShort1() {
        return short1;
    }

    public void setShort1(short short1) {
        this.short1 = short1;
    }

    public int getInt1() {
        return int1;
    }

    public void setInt1(int int1) {
        this.int1 = int1;
    }

    public long getLong1() {
        return long1;
    }

    public void setLong1(long long1) {
        this.long1 = long1;
    }

    public float getFloat1() {
        return float1;
    }

    public void setFloat1(float float1) {
        this.float1 = float1;
    }

    public double getDouble1() {
        return double1;
    }

    public void setDouble1(double double1) {
        this.double1 = double1;
    }

    public char getChar1() {
        return char1;
    }

    public void setChar1(char char1) {
        this.char1 = char1;
    }

    public boolean isBoolean1() {
        return boolean1;
    }

    public void setBoolean1(boolean boolean1) {
        this.boolean1 = boolean1;
    }

    public byte[] getByteArray1() {
        return byteArray1;
    }

    public void setByteArray1(byte[] byteArray1) {
        this.byteArray1 = byteArray1;
    }

    public short[] getShortArray1() {
        return shortArray1;
    }

    public void setShortArray1(short[] shortArray1) {
        this.shortArray1 = shortArray1;
    }

    public int[] getIntArray1() {
        return intArray1;
    }

    public void setIntArray1(int[] intArray1) {
        this.intArray1 = intArray1;
    }

    public long[] getLongArray1() {
        return longArray1;
    }

    public void setLongArray1(long[] longArray1) {
        this.longArray1 = longArray1;
    }

    public float[] getFloatArray1() {
        return floatArray1;
    }

    public void setFloatArray1(float[] floatArray1) {
        this.floatArray1 = floatArray1;
    }

    public double[] getDoubleArray1() {
        return doubleArray1;
    }

    public void setDoubleArray1(double[] doubleArray1) {
        this.doubleArray1 = doubleArray1;
    }

    public char[] getCharArray1() {
        return charArray1;
    }

    public void setCharArray1(char[] charArray1) {
        this.charArray1 = charArray1;
    }

    public boolean[] getBooleanArray1() {
        return booleanArray1;
    }

    public void setBooleanArray1(boolean[] booleanArray1) {
        this.booleanArray1 = booleanArray1;
    }

    public float[] getPrimitiveArray1() {
        return primitiveArray1;
    }

    public void setPrimitiveArray1(float[] primitiveArray1) {
        this.primitiveArray1 = primitiveArray1;
    }

    public float[][] getPrimitiveArray2() {
        return primitiveArray2;
    }

    public void setPrimitiveArray2(float[][] primitiveArray2) {
        this.primitiveArray2 = primitiveArray2;
    }

    public float[][][] getPrimitiveArray3() {
        return primitiveArray3;
    }

    public void setPrimitiveArray3(float[][][] primitiveArray3) {
        this.primitiveArray3 = primitiveArray3;
    }

    public String getString1() {
        return string1;
    }

    public void setString1(String string1) {
        this.string1 = string1;
    }

    public String[] getStringArray1() {
        return stringArray1;
    }

    public void setStringArray1(String[] stringArray1) {
        this.stringArray1 = stringArray1;
    }

    public String[][] getStringArray2() {
        return stringArray2;
    }

    public void setStringArray2(String[][] stringArray2) {
        this.stringArray2 = stringArray2;
    }

    public String[][][] getStringArray3() {
        return stringArray3;
    }

    public void setStringArray3(String[][][] stringArray3) {
        this.stringArray3 = stringArray3;
    }

    public TestPersistableElement getTestPersistableElement1() {
        return testPersistableElement1;
    }

    public void setTestPersistableElement1(
        TestPersistableElement testPersistableElement1) {
        this.testPersistableElement1 = testPersistableElement1;
    }

    public List<TestPersistableElement> getTestPersistableElementList1() {
        return testPersistableElementList1;
    }

    public void setTestPersistableElementList1(
        List<TestPersistableElement> testPersistableElementList1) {
        this.testPersistableElementList1 = testPersistableElementList1;
    }

    public List<List<TestPersistableElement>> getTestPersistableElementList2() {
        return testPersistableElementList2;
    }

    public void setTestPersistableElementList2(
        List<List<TestPersistableElement>> testPersistableElementList2) {
        this.testPersistableElementList2 = testPersistableElementList2;
    }

    public List<List<List<TestPersistableElement>>> getTestPersistableElementList3() {
        return testPersistableElementList3;
    }

    public void setTestPersistableElementList3(
        List<List<List<TestPersistableElement>>> testPersistableElementList3) {
        this.testPersistableElementList3 = testPersistableElementList3;
    }

    public TestPersistableElement[] getTestPersistableElementArray1() {
        return testPersistableElementArray1;
    }

    public void setTestPersistableElementArray1(
        TestPersistableElement[] testPersistableElementArray1) {
        this.testPersistableElementArray1 = testPersistableElementArray1;
    }

    public TestPersistableElement[][] getTestPersistableElementArray2() {
        return testPersistableElementArray2;
    }

    public void setTestPersistableElementArray2(
        TestPersistableElement[][] testPersistableElementArray2) {
        this.testPersistableElementArray2 = testPersistableElementArray2;
    }

    public TestPersistableElement[][][] getTestPersistableElementArray3() {
        return testPersistableElementArray3;
    }

    public void setTestPersistableElementArray3(
        TestPersistableElement[][][] testPersistableElementArray3) {
        this.testPersistableElementArray3 = testPersistableElementArray3;
    }

    public Date getDate1() {
        return date1;
    }

    public void setDate1(Date date1) {
        this.date1 = date1;
    }

    public TestPersistableEnum getTestPersistableEnum1() {
        return testPersistableEnum1;
    }

    public void setTestPersistableEnum1(TestPersistableEnum testPersistableEnum1) {
        this.testPersistableEnum1 = testPersistableEnum1;
    }

    @Override
    public String toString() {
        return "TestPersistable [byte1=" + byte1 + ", short1=" + short1
            + ", int1=" + int1 + ", long1=" + long1 + ", float1=" + float1
            + ", double1=" + double1 + ", char1=" + char1 + ", boolean1="
            + boolean1 + ", byteArray1=" + Arrays.toString(byteArray1)
            + ", shortArray1=" + Arrays.toString(shortArray1) + ", intArray1="
            + Arrays.toString(intArray1) + ", longArray1="
            + Arrays.toString(longArray1) + ", floatArray1="
            + Arrays.toString(floatArray1) + ", doubleArray1="
            + Arrays.toString(doubleArray1) + ", charArray1="
            + Arrays.toString(charArray1) + ", booleanArray1="
            + Arrays.toString(booleanArray1) + ", primitiveArray1="
            + Arrays.toString(primitiveArray1) + ", primitiveArray2="
            + Arrays.toString(primitiveArray2) + ", primitiveArray3="
            + Arrays.toString(primitiveArray3) + ", string1=" + string1
            + ", stringArray1=" + Arrays.toString(stringArray1)
            + ", stringArray2=" + Arrays.toString(stringArray2)
            + ", stringArray3=" + Arrays.toString(stringArray3)
            + ", testPersistableElement1=" + testPersistableElement1
            + ", testPersistableElementList1=" + testPersistableElementList1
            + ", testPersistableElementList2=" + testPersistableElementList2
            + ", testPersistableElementList3=" + testPersistableElementList3
            + ", testPersistableElementArray1="
            + Arrays.toString(testPersistableElementArray1)
            + ", testPersistableElementArray2="
            + Arrays.toString(testPersistableElementArray2)
            + ", testPersistableElementArray3="
            + Arrays.toString(testPersistableElementArray3) + ", date1="
            + date1 + ", testPersistableEnum1=" + testPersistableEnum1 + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (boolean1 ? 1231 : 1237);
        result = prime * result + Arrays.hashCode(booleanArray1);
        result = prime * result + byte1;
        result = prime * result + Arrays.hashCode(byteArray1);
        result = prime * result + char1;
        result = prime * result + Arrays.hashCode(charArray1);
        result = prime * result + ((date1 == null) ? 0 : date1.hashCode());
        long temp;
        temp = Double.doubleToLongBits(double1);
        result = prime * result + (int) (temp ^ (temp >>> 32));
        result = prime * result + Arrays.hashCode(doubleArray1);
        result = prime * result + Float.floatToIntBits(float1);
        result = prime * result + Arrays.hashCode(floatArray1);
        result = prime * result + int1;
        result = prime * result + Arrays.hashCode(intArray1);
        result = prime * result + (int) (long1 ^ (long1 >>> 32));
        result = prime * result + Arrays.hashCode(longArray1);
        result = prime * result + Arrays.hashCode(primitiveArray1);
        result = prime * result + Arrays.hashCode(primitiveArray2);
        result = prime * result + Arrays.hashCode(primitiveArray3);
        result = prime * result + short1;
        result = prime * result + Arrays.hashCode(shortArray1);
        result = prime * result + ((string1 == null) ? 0 : string1.hashCode());
        result = prime * result + Arrays.hashCode(stringArray1);
        result = prime * result + Arrays.hashCode(stringArray2);
        result = prime * result + Arrays.hashCode(stringArray3);
        result = prime
            * result
            + ((testPersistableElement1 == null) ? 0
                : testPersistableElement1.hashCode());
        result = prime * result + Arrays.hashCode(testPersistableElementArray1);
        result = prime * result + Arrays.hashCode(testPersistableElementArray2);
        result = prime * result + Arrays.hashCode(testPersistableElementArray3);
        result = prime
            * result
            + ((testPersistableElementList1 == null) ? 0
                : testPersistableElementList1.hashCode());
        result = prime
            * result
            + ((testPersistableElementList2 == null) ? 0
                : testPersistableElementList2.hashCode());
        result = prime
            * result
            + ((testPersistableElementList3 == null) ? 0
                : testPersistableElementList3.hashCode());
        result = prime
            * result
            + ((testPersistableEnum1 == null) ? 0
                : testPersistableEnum1.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (obj == null)
            return false;
        if (getClass() != obj.getClass())
            return false;
        TestPersistable other = (TestPersistable) obj;
        if (boolean1 != other.boolean1)
            return false;
        if (!Arrays.equals(booleanArray1, other.booleanArray1))
            return false;
        if (byte1 != other.byte1)
            return false;
        if (!Arrays.equals(byteArray1, other.byteArray1))
            return false;
        if (char1 != other.char1)
            return false;
        if (!Arrays.equals(charArray1, other.charArray1))
            return false;
        if (date1 == null) {
            if (other.date1 != null)
                return false;
        } else if (!date1.equals(other.date1))
            return false;
        if (Double.doubleToLongBits(double1) != Double.doubleToLongBits(other.double1))
            return false;
        if (!Arrays.equals(doubleArray1, other.doubleArray1))
            return false;
        if (Float.floatToIntBits(float1) != Float.floatToIntBits(other.float1))
            return false;
        if (!Arrays.equals(floatArray1, other.floatArray1))
            return false;
        if (int1 != other.int1)
            return false;
        if (!Arrays.equals(intArray1, other.intArray1))
            return false;
        if (long1 != other.long1)
            return false;
        if (!Arrays.equals(longArray1, other.longArray1))
            return false;
        if (!Arrays.equals(primitiveArray1, other.primitiveArray1))
            return false;
        if (!Arrays.deepEquals(primitiveArray2, other.primitiveArray2))
            return false;
        if (!Arrays.deepEquals(primitiveArray3, other.primitiveArray3))
            return false;
        if (short1 != other.short1)
            return false;
        if (!Arrays.equals(shortArray1, other.shortArray1))
            return false;
        if (string1 == null) {
            if (other.string1 != null)
                return false;
        } else if (!string1.equals(other.string1))
            return false;
        if (!Arrays.equals(stringArray1, other.stringArray1))
            return false;
        if (!Arrays.deepEquals(stringArray2, other.stringArray2))
            return false;
        if (!Arrays.deepEquals(stringArray3, other.stringArray3))
            return false;
        if (testPersistableElement1 == null) {
            if (other.testPersistableElement1 != null)
                return false;
        } else if (!testPersistableElement1.equals(other.testPersistableElement1))
            return false;
        if (!Arrays.equals(testPersistableElementArray1,
            other.testPersistableElementArray1))
            return false;
        if (!Arrays.deepEquals(testPersistableElementArray2,
            other.testPersistableElementArray2))
            return false;
        if (!Arrays.deepEquals(testPersistableElementArray3,
            other.testPersistableElementArray3))
            return false;
        if (testPersistableElementList1 == null) {
            if (other.testPersistableElementList1 != null)
                return false;
        } else if (!testPersistableElementList1.equals(other.testPersistableElementList1))
            return false;
        if (testPersistableElementList2 == null) {
            if (other.testPersistableElementList2 != null)
                return false;
        } else if (!testPersistableElementList2.equals(other.testPersistableElementList2))
            return false;
        if (testPersistableElementList3 == null) {
            if (other.testPersistableElementList3 != null)
                return false;
        } else if (!testPersistableElementList3.equals(other.testPersistableElementList3))
            return false;
        if (testPersistableEnum1 != other.testPersistableEnum1)
            return false;
        return true;
    }

}
