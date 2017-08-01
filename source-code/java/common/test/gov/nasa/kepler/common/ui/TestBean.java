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

package gov.nasa.kepler.common.ui;

import gov.nasa.spiffy.common.pi.Parameters;

public class TestBean implements Parameters{

    private int anInt = 1;
    private float aFloat = 2.0f;
    private String aString = "Ja Ja Ja";
    private int[] anIntArray = {1, 2, 3};
    private float[] aFloatArray = {1.0f, 2.0f, 3.0f};
    private float[] aFloatArray2 = {4.0f, 5.0f, 6.0f};
    private String[] aStringArray = {"one", "two", "three"};
    private String[] aStringArrayNull;
    
    public TestBean() {
    }

    public int getAnInt() {
        return anInt;
    }

    public void setAnInt(int anInt) {
        this.anInt = anInt;
    }

    public float getAFloat() {
        return aFloat;
    }

    public void setAFloat(float float1) {
        aFloat = float1;
    }

    public String getAString() {
        return aString;
    }

    public void setAString(String string) {
        aString = string;
    }

    public int[] getAnIntArray() {
        return anIntArray;
    }

    public void setAnIntArray(int[] anIntArray) {
        this.anIntArray = anIntArray;
    }

    public float[] getAFloatArray() {
        return aFloatArray;
    }

    public void setAFloatArray(float[] floatArray) {
        aFloatArray = floatArray;
    }

    public String[] getAStringArray() {
        return aStringArray;
    }

    public void setAStringArray(String[] stringArray) {
        aStringArray = stringArray;
    }

    public float[] getAFloatArray2() {
        return aFloatArray2;
    }

    public void setAFloatArray2(float[] floatArray2) {
        aFloatArray2 = floatArray2;
    }

    /**
     * @return the aStringArrayNull
     */
    public String[] getAStringArrayNull() {
        return aStringArrayNull;
    }

    /**
     * @param stringArrayNull the aStringArrayNull to set
     */
    public void setAStringArrayNull(String[] stringArrayNull) {
        aStringArrayNull = stringArrayNull;
    }

}
