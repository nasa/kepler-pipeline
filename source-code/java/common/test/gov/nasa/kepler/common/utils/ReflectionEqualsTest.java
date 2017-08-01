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

package gov.nasa.kepler.common.utils;

import static org.junit.Assert.assertEquals;

import gov.nasa.spiffy.common.junit.ReflectionEquals;

import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.Test;


/**
 * This class tests {@link ReflectionEquals}
 * 
 * @author Todd Klaus tklaus@arc.nasa.gov
 *
 */
public class ReflectionEqualsTest {
    private static final Log log = LogFactory.getLog(ReflectionEqualsTest.class);

    @Test
    public void testEquals() throws Exception{
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);

        ReflectionEquals comparer = new ReflectionEquals();
        comparer.assertEquals("TestOuterClass", expected, actual);
    }
    
    @Test
    public void testPrimitiveNotEquals(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 2);

        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.outerInt expected:<1> but was:<2>", e.getMessage());
        }
    }
    
    @Test
    public void testStringNotEquals(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("2", 1);

        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.outerString expected:<[1]> but was:<[2]>", e.getMessage());
        }
    }
    
    @Test
    public void testArrayNotEqualsNull(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerArray = null;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerArray: actualObject is null, but expectedObject is not!", e.getMessage());
        }
    }
    
    @Test
    public void testArrayNotEqualsSize(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerArray = new TestInnerClass[]{new TestInnerClass("array-1", 1)};
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerArray.length expected:<2> but was:<1>", e.getMessage());
        }
    }
    
    @Test
    public void testArrayNotEqualsContent(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerArray[1].innerInt = 100;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerArray[1].innerInt expected:<2> but was:<100>", e.getMessage());
        }
    }
    
    @Test
    public void testPrimitiveArrayNotEqualsNull(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerPrimitiveArray = null;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerPrimitiveArray: actualObject is null, but expectedObject is not!", e.getMessage());
        }
    }
    
    @Test
    public void testPrimitiveArrayNotEqualsSize(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerPrimitiveArray = new int[]{1,2};
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerPrimitiveArray.length expected:<3> but was:<2>", e.getMessage());
        }
    }
    
    @Test
    public void testPrimitiveArrayNotEqualsContent(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerPrimitiveArray[1] = 100;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerPrimitiveArray[1] expected:<2> but was:<100>", e.getMessage());
        }
    }
    
    @Test
    public void testListNotEqualsNull(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerList = null;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerList: actualObject is null, but expectedObject is not!", e.getMessage());
        }
    }
    
    @Test
    public void testListNotEqualsSize(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerList = new LinkedList<TestInnerClass>();
        actual.innerList.add(new TestInnerClass("list-1", 1));;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerList.size() expected:<2> but was:<1>", e.getMessage());
        }
    }
    
    @Test
    public void testListNotEqualsContent(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerList.get(1).innerInt = 100;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerList[1].innerInt expected:<4> but was:<100>", e.getMessage());
        }
    }
    
    @Test
    public void testMapNotEqualsNull(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerMap = null;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerMap: actualObject is null, but expectedObject is not!", e.getMessage());
        }
    }
    
    @Test
    public void testMapNotEqualsSize(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerMap = new HashMap<String,TestInnerClass>();
        actual.innerMap.put("key3", new TestInnerClass("map-2", 1));;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerMap.size() expected:<2> but was:<1>", e.getMessage());
        }
    }
    
    @Test
    public void testMapNotEqualsContent(){
        
        TestOuterClass expected = new TestOuterClass("1", 1);
        TestOuterClass actual = new TestOuterClass("1", 1);
        
        actual.innerMap.get("key1").innerInt = 100;
        
        ReflectionEquals comparer = new ReflectionEquals();
        try {
            comparer.assertEquals("TestOuterClass", expected, actual);
        } catch (Throwable e) {
            log.debug(e.getMessage());
            assertEquals("exception message", "TestOuterClass.innerMap(key1).innerInt expected:<3> but was:<100>", e.getMessage());
        }
    }
    
    final class TestInnerClass{
        public String innerString;
        public int innerInt;
        
        public TestInnerClass(String innerString, int innerInt) {
            this.innerString = innerString;
            this.innerInt = innerInt;
        }
    }
    
    final class TestOuterClass{
        public String outerString;
        public int outerInt;
        
        public int[] innerPrimitiveArray = new int[]{1,2,3};
        public TestInnerClass[] innerArray = {new TestInnerClass("array-1", 1), new TestInnerClass("array-2", 2)};
        public List<TestInnerClass> innerList = new LinkedList<TestInnerClass>();
        public Map<String, TestInnerClass> innerMap = new HashMap<String, TestInnerClass>();
        
        public TestOuterClass(String outerString, int outerInt) {
            this.outerString = outerString;
            this.outerInt = outerInt;
            
            innerList.add(new TestInnerClass("list-1", 3));
            innerList.add(new TestInnerClass("list-2", 4));

            innerMap.put("key1", new TestInnerClass("map-1", 3));
            innerMap.put("key2", new TestInnerClass("map-2", 4));
        }
    }
}
