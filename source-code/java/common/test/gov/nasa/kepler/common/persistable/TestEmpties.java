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

package gov.nasa.kepler.common.persistable;

import gov.nasa.spiffy.common.persistable.Persistable;
import gov.nasa.spiffy.common.persistable.TestParametersFoo;

import java.util.LinkedList;
import java.util.List;

public class TestEmpties implements Persistable {

    private Boolean emptyBoolean = null;
    private Byte emptyByte = null;
    private Short emptyShort = null;
    private Integer emptyInt = null;
    private Long emptyLong = null;
    private Float emptyFloat = null;
    private Double emptyDouble = null;
    private String emptyString = null;
    private String[] emptyStringArray = null;
    private String[][] emptyString2dArray = null;
    
    private int[] emptyPrimitiveArray = new int[0];
    private int[][] emptyPrimitive2dArray = new int[0][];
    private List<TestParametersFoo> emptyPersistableList = new LinkedList<TestParametersFoo>();
    
    public TestEmpties() {
    }

    public Boolean getEmptyBoolean() {
        return emptyBoolean;
    }

    public void setEmptyBoolean(Boolean emptyBoolean) {
        this.emptyBoolean = emptyBoolean;
    }

    public Byte getEmptyByte() {
        return emptyByte;
    }

    public void setEmptyByte(Byte emptyByte) {
        this.emptyByte = emptyByte;
    }

    public Short getEmptyShort() {
        return emptyShort;
    }

    public void setEmptyShort(Short emptyShort) {
        this.emptyShort = emptyShort;
    }

    public Integer getEmptyInt() {
        return emptyInt;
    }

    public void setEmptyInt(Integer emptyInt) {
        this.emptyInt = emptyInt;
    }

    public Long getEmptyLong() {
        return emptyLong;
    }

    public void setEmptyLong(Long emptyLong) {
        this.emptyLong = emptyLong;
    }

    public Float getEmptyFloat() {
        return emptyFloat;
    }

    public void setEmptyFloat(Float emptyFloat) {
        this.emptyFloat = emptyFloat;
    }

    public Double getEmptyDouble() {
        return emptyDouble;
    }

    public void setEmptyDouble(Double emptyDouble) {
        this.emptyDouble = emptyDouble;
    }

    public String getEmptyString() {
        return emptyString;
    }

    public void setEmptyString(String emptyString) {
        this.emptyString = emptyString;
    }

    public String[] getEmptyStringArray() {
        return emptyStringArray;
    }

    public void setEmptyStringArray(String[] emptyStringArray) {
        this.emptyStringArray = emptyStringArray;
    }

    public String[][] getEmptyString2dArray() {
        return emptyString2dArray;
    }

    public void setEmptyString2dArray(String[][] emptyString2dArray) {
        this.emptyString2dArray = emptyString2dArray;
    }

    public int[] getEmptyPrimitiveArray() {
        return emptyPrimitiveArray;
    }

    public void setEmptyPrimitiveArray(int[] emptyPrimitiveArray) {
        this.emptyPrimitiveArray = emptyPrimitiveArray;
    }

    public List<TestParametersFoo> getEmptyPersistableList() {
        return emptyPersistableList;
    }

    public void setEmptyPersistableList(List<TestParametersFoo> emptyPersistableList) {
        this.emptyPersistableList = emptyPersistableList;
    }

    public int[][] getEmptyPrimitive2dArray() {
        return emptyPrimitive2dArray;
    }

    public void setEmptyPrimitive2dArray(int[][] emptyPrimitive2dArray) {
        this.emptyPrimitive2dArray = emptyPrimitive2dArray;
    }

}
