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
import static com.google.common.collect.Maps.newHashMap;
import static com.google.common.collect.Sets.newHashSet;

import java.util.List;
import java.util.Map;
import java.util.Set;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public class TestPersistableWithCollections extends TestPersistable {

    @ProxyInfo(containerClass = "java.util.LinkedList")
    private List<String> stringList1 = newArrayList();
    private List<TestPersistableElement> testPersistableElementList1 = newArrayList();

    @ProxyInfo(containerClass = "java.util.LinkedHashSet")
    private Set<String> stringSet1 = newHashSet();
    private Set<TestPersistableElement> testPersistableElementSet1 = newHashSet();

    @ProxyInfo(containerClass = "java.util.LinkedHashMap")
    private Map<String, String> stringMap1 = newHashMap();
    private Map<TestPersistableElement, TestPersistableElement> testPersistableElementMap1 = newHashMap();

    public TestPersistableWithCollections(int seed) {
        super(seed);

        this.stringList1 = ImmutableList.of("1");
        this.testPersistableElementList1 = ImmutableList.of(new TestPersistableElement(
            2));

        this.stringSet1 = ImmutableSet.of("3");
        this.testPersistableElementSet1 = ImmutableSet.of(new TestPersistableElement(
            4));

        this.stringMap1 = ImmutableMap.of("5", "6");
        this.testPersistableElementMap1 = ImmutableMap.of(
            new TestPersistableElement(7), new TestPersistableElement(8));
    }

    public TestPersistableWithCollections() {
        super();
    }

    public List<String> getStringList1() {
        return stringList1;
    }

    public void setStringList1(List<String> stringList1) {
        this.stringList1 = stringList1;
    }

    @Override
    public List<TestPersistableElement> getTestPersistableElementList1() {
        return testPersistableElementList1;
    }

    @Override
    public void setTestPersistableElementList1(
        List<TestPersistableElement> testPersistableElementList1) {
        this.testPersistableElementList1 = testPersistableElementList1;
    }

    public Set<String> getStringSet1() {
        return stringSet1;
    }

    public void setStringSet1(Set<String> stringSet1) {
        this.stringSet1 = stringSet1;
    }

    public Set<TestPersistableElement> getTestPersistableElementSet1() {
        return testPersistableElementSet1;
    }

    public void setTestPersistableElementSet1(
        Set<TestPersistableElement> testPersistableElementSet1) {
        this.testPersistableElementSet1 = testPersistableElementSet1;
    }

    public Map<String, String> getStringMap1() {
        return stringMap1;
    }

    public void setStringMap1(Map<String, String> stringMap1) {
        this.stringMap1 = stringMap1;
    }

    public Map<TestPersistableElement, TestPersistableElement> getTestPersistableElementMap1() {
        return testPersistableElementMap1;
    }

    public void setTestPersistableElementMap1(
        Map<TestPersistableElement, TestPersistableElement> testPersistableElementMap1) {
        this.testPersistableElementMap1 = testPersistableElementMap1;
    }

    @Override
    public String toString() {
        return "TestPersistableWithCollections [stringList1=" + stringList1
            + ", testPersistableElementList1=" + testPersistableElementList1
            + ", stringSet1=" + stringSet1 + ", testPersistableElementSet1="
            + testPersistableElementSet1 + ", stringMap1=" + stringMap1
            + ", testPersistableElementMap1=" + testPersistableElementMap1
            + "]";
    }

    @Override
    public int hashCode() {
        final int prime = 31;
        int result = super.hashCode();
        result = prime * result
            + ((stringList1 == null) ? 0 : stringList1.hashCode());
        result = prime * result
            + ((stringMap1 == null) ? 0 : stringMap1.hashCode());
        result = prime * result
            + ((stringSet1 == null) ? 0 : stringSet1.hashCode());
        result = prime
            * result
            + ((testPersistableElementList1 == null) ? 0
                : testPersistableElementList1.hashCode());
        result = prime
            * result
            + ((testPersistableElementMap1 == null) ? 0
                : testPersistableElementMap1.hashCode());
        result = prime
            * result
            + ((testPersistableElementSet1 == null) ? 0
                : testPersistableElementSet1.hashCode());
        return result;
    }

    @Override
    public boolean equals(Object obj) {
        if (this == obj)
            return true;
        if (!super.equals(obj))
            return false;
        if (getClass() != obj.getClass())
            return false;
        TestPersistableWithCollections other = (TestPersistableWithCollections) obj;
        if (stringList1 == null) {
            if (other.stringList1 != null)
                return false;
        } else if (!stringList1.equals(other.stringList1))
            return false;
        if (stringMap1 == null) {
            if (other.stringMap1 != null)
                return false;
        } else if (!stringMap1.equals(other.stringMap1))
            return false;
        if (stringSet1 == null) {
            if (other.stringSet1 != null)
                return false;
        } else if (!stringSet1.equals(other.stringSet1))
            return false;
        if (testPersistableElementList1 == null) {
            if (other.testPersistableElementList1 != null)
                return false;
        } else if (!testPersistableElementList1.equals(other.testPersistableElementList1))
            return false;
        if (testPersistableElementMap1 == null) {
            if (other.testPersistableElementMap1 != null)
                return false;
        } else if (!testPersistableElementMap1.equals(other.testPersistableElementMap1))
            return false;
        if (testPersistableElementSet1 == null) {
            if (other.testPersistableElementSet1 != null)
                return false;
        } else if (!testPersistableElementSet1.equals(other.testPersistableElementSet1))
            return false;
        return true;
    }
}
