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

package gov.nasa.spiffy.common.pojo;

import gov.nasa.spiffy.common.persistable.ProxyIgnore;

import org.junit.Test;

/**
 * Tests {@link PojoTest}.
 * 
 * @author Miles Cote
 * 
 */
@SuppressWarnings("unused")
public class PojoTestTest {

    @Test
    public void passesForValidFieldsGettersSetters() {
        PojoTest.testGettersSetters(new PojoWithValidFieldsGettersSetters());
    }

    @Test(expected = FieldAccessException.class)
    public void failsIfFieldIsNonPrivate() {
        PojoTest.testGettersSetters(new PojoWithNonPrivateField());
    }

    @Test(expected = FieldNameException.class)
    public void failsIfFieldStartsWithUpperCase() {
        PojoTest.testGettersSetters(new PojoWithFieldStartingWithUpperCase());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfFieldIsMissingGetterAndSetter() {
        PojoTest.testGettersSetters(new PojoWithFieldMissingGetterAndSetter());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfFieldIsMissingGetter() {
        PojoTest.testGettersSetters(new PojoWithFieldMissingGetter());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfFieldIsMissingSetter() {
        PojoTest.testGettersSetters(new PojoWithFieldMissingSetter());
    }

    @Test(expected = GetterSetterNameException.class)
    public void failsIfGetterStartsWithLowerCase() {
        PojoTest.testGettersSetters(new PojoWithFieldWithLowerCaseGetter());
    }

    @Test(expected = GetterSetterNameException.class)
    public void failsIfSetterStartsWithLowerCase() {
        PojoTest.testGettersSetters(new PojoWithFieldWithLowerCaseSetter());
    }

    @Test(expected = GetterSetterNameException.class)
    public void failsIfFieldWithSingleLetterHasGetterStartingWithLowerCase() {
        PojoTest.testGettersSetters(new PojoWithFieldWithSingleLetterWithGetterStartingWithLowerCase());
    }

    @Test(expected = GetterSetterNameException.class)
    public void failsIfFieldWithSingleLetterHasSetterStartingWithLowerCase() {
        PojoTest.testGettersSetters(new PojoWithFieldWithSingleLetterWithSetterStartingWithLowerCase());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfFieldWithUpperCaseSecondLetterHasGetterStartingWithUpperCase() {
        PojoTest.testGettersSetters(new PojoWithFieldWithUpperCaseSecondLetterHasGetterStartingWithUpperCase());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfFieldWithUpperCaseSecondLetterHasSetterStartingWithUpperCase() {
        PojoTest.testGettersSetters(new PojoWithFieldWithUpperCaseSecondLetterHasSetterStartingWithUpperCase());
    }

    @Test(expected = GetterSetterTypeException.class)
    public void failsIfIntFieldHasDoubleGetter() {
        PojoTest.testGettersSetters(new PojoWithIntFieldWithDoubleGetter());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfIntFieldHasDoubleSetter() {
        PojoTest.testGettersSetters(new PojoWithIntFieldWithDoubleSetter());
    }

    @Test(expected = GetterSetterTypeException.class)
    public void failsIfDoubleFieldHasIntGetter() {
        PojoTest.testGettersSetters(new PojoWithDoubleFieldWithIntGetter());
    }

    @Test(expected = GetterSetterExistenceException.class)
    public void failsIfDoubleFieldHasIntSetter() {
        PojoTest.testGettersSetters(new PojoWithDoubleFieldWithIntSetter());
    }

    @Test(expected = GetterSetterValueException.class)
    public void failsIfFieldValueDiffersFromGetterValue() {
        PojoTest.testGettersSetters(new PojoWithEmptyGetter());
    }

    @Test(expected = GetterSetterValueException.class)
    public void failsIfFieldValueDiffersFromSetterValue() {
        PojoTest.testGettersSetters(new PojoWithEmptySetter());
    }

    private static final class PojoWithValidFieldsGettersSetters {

        private int a;
        private int aFieldWithUpperCaseSecondLetter;
        private final int finalField = 1;
        private boolean booleanField;
        private char charField;
        private byte byteField;
        private short shortField;
        private int intField;
        private long longField;
        private float floatField;
        private double doubleField;
        private String stringField;
        private Object objectField;
        @ProxyIgnore
        private Object proxyIngnoredField;

        public int getA() {
            return a;
        }

        public void setA(int a) {
            this.a = a;
        }

        public int getaFieldWithUpperCaseSecondLetter() {
            return aFieldWithUpperCaseSecondLetter;
        }

        public void setaFieldWithUpperCaseSecondLetter(
            int aFieldWithUpperCaseSecondLetter) {
            this.aFieldWithUpperCaseSecondLetter = aFieldWithUpperCaseSecondLetter;
        }

        public boolean isBooleanField() {
            return booleanField;
        }

        public void setBooleanField(boolean booleanField) {
            this.booleanField = booleanField;
        }

        public char getCharField() {
            return charField;
        }

        public void setCharField(char charField) {
            this.charField = charField;
        }

        public byte getByteField() {
            return byteField;
        }

        public void setByteField(byte byteField) {
            this.byteField = byteField;
        }

        public short getShortField() {
            return shortField;
        }

        public void setShortField(short shortField) {
            this.shortField = shortField;
        }

        public int getIntField() {
            return intField;
        }

        public void setIntField(int intField) {
            this.intField = intField;
        }

        public long getLongField() {
            return longField;
        }

        public void setLongField(long longField) {
            this.longField = longField;
        }

        public float getFloatField() {
            return floatField;
        }

        public void setFloatField(float floatField) {
            this.floatField = floatField;
        }

        public double getDoubleField() {
            return doubleField;
        }

        public void setDoubleField(double doubleField) {
            this.doubleField = doubleField;
        }

        public String getStringField() {
            return stringField;
        }

        public void setStringField(String stringField) {
            this.stringField = stringField;
        }

        public Object getObjectField() {
            return objectField;
        }

        public void setObjectField(Object objectField) {
            this.objectField = objectField;
        }

        public int getFinalField() {
            return finalField;
        }
    }

    private static final class PojoWithNonPrivateField {
        public int nonPrivateField;
    }

    private static final class PojoWithFieldStartingWithUpperCase {
        private int FieldStartingWithUpperCase;
    }

    private static final class PojoWithFieldMissingGetterAndSetter {
        private int fieldMissingGetterAndSetter;
    }

    private static final class PojoWithFieldMissingGetter {
        private int fieldMissingGetter;

        public void setFieldMissingGetter(int fieldMissingGetter) {
            this.fieldMissingGetter = fieldMissingGetter;
        }
    }

    private static final class PojoWithFieldMissingSetter {
        private int fieldMissingSetter;

        public int getFieldMissingSetter() {
            return fieldMissingSetter;
        }
    }

    private static final class PojoWithFieldWithLowerCaseGetter {
        private int fieldWithLowerCaseGetter;

        public int getfieldWithLowerCaseGetter() {
            return fieldWithLowerCaseGetter;
        }

        public void setFieldWithLowerCaseGetter(int fieldWithLowerCaseGetter) {
            this.fieldWithLowerCaseGetter = fieldWithLowerCaseGetter;
        }
    }

    private static final class PojoWithFieldWithLowerCaseSetter {
        private int fieldWithLowerCaseSetter;

        public int getFieldWithLowerCaseSetter() {
            return fieldWithLowerCaseSetter;
        }

        public void setfieldWithLowerCaseSetter(int fieldWithLowerCaseSetter) {
            this.fieldWithLowerCaseSetter = fieldWithLowerCaseSetter;
        }
    }

    private static final class PojoWithFieldWithSingleLetterWithGetterStartingWithLowerCase {
        private int a;

        public int geta() {
            return a;
        }

        public void setA(int a) {
            this.a = a;
        }
    }

    private static final class PojoWithFieldWithSingleLetterWithSetterStartingWithLowerCase {
        private int a;

        public int getA() {
            return a;
        }

        public void seta(int a) {
            this.a = a;
        }
    }

    private static final class PojoWithFieldWithUpperCaseSecondLetterHasGetterStartingWithUpperCase {
        private int aFieldWithUpperCaseSecondLetter;

        public int getAFieldWithUpperCaseSecondLetter() {
            return aFieldWithUpperCaseSecondLetter;
        }

        public void setaFieldWithUpperCaseSecondLetter(
            int aFieldWithUpperCaseSecondLetter) {
            this.aFieldWithUpperCaseSecondLetter = aFieldWithUpperCaseSecondLetter;
        }
    }

    private static final class PojoWithFieldWithUpperCaseSecondLetterHasSetterStartingWithUpperCase {
        private int aFieldWithUpperCaseSecondLetter;

        public int getaFieldWithUpperCaseSecondLetter() {
            return aFieldWithUpperCaseSecondLetter;
        }

        public void setAFieldWithUpperCaseSecondLetter(
            int aFieldWithUpperCaseSecondLetter) {
            this.aFieldWithUpperCaseSecondLetter = aFieldWithUpperCaseSecondLetter;
        }
    }

    private static final class PojoWithIntFieldWithDoubleGetter {
        private int intField;

        public double getIntField() {
            return intField;
        }

        public void setIntField(int intField) {
            this.intField = intField;
        }
    }

    private static final class PojoWithIntFieldWithDoubleSetter {
        private int intField;

        public int getIntField() {
            return intField;
        }

        public void setIntField(double intField) {
            this.intField = (int) intField;
        }
    }

    private static final class PojoWithDoubleFieldWithIntGetter {
        private double doubleField;

        public int getDoubleField() {
            return (int) doubleField;
        }

        public void setDoubleField(double doubleField) {
            this.doubleField = doubleField;
        }
    }

    private static final class PojoWithDoubleFieldWithIntSetter {
        private double doubleField;

        public double getDoubleField() {
            return doubleField;
        }

        public void setDoubleField(int doubleField) {
            this.doubleField = doubleField;
        }
    }

    private static final class PojoWithEmptyGetter {
        private int intField;

        public int getIntField() {
            return -1;
        }

        public void setIntField(int intField) {
            this.intField = intField;
        }
    }

    private static final class PojoWithEmptySetter {
        private int intField;

        public int getIntField() {
            return intField;
        }

        public void setIntField(int intField) {
        }
    }

}
