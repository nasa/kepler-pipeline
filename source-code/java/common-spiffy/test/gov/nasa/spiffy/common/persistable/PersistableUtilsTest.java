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

import gov.nasa.spiffy.common.collect.Pair;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.File;
import java.lang.reflect.Field;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class PersistableUtilsTest {

    private static final File TEST_DIR = new File("build/test/PersistableUtilsTest");
    
    @SuppressWarnings("unused")
    private class TestClass implements Persistable {
        // 1-dimensional list
        public List<TestClass> list1;
        // 2-dimensional list
        public List<List<TestClass>> list2;
        // 3-dimensional list
        public List<List<List<TestClass>>> list3;

        // 1-dimensional set
        public Set<TestClass> set1;
        // 2-dimensional set
        public Set<Set<TestClass>> set2;
        // 3-dimensional set
        public Set<Set<Set<TestClass>>> set3;

        public Map<String, TestClass> mapString;
        public Map<TestClass, TestClass> mapTestClass;
        public Map<Map<TestClass, TestClass>, TestClass> mapIllegal;
    }
    
    @Test
    public void testRoundTrip1() throws Exception{
        TestContainer testContainer1 = TestContainer.populatedTestContainerFactory(); 
        TestContainer testContainer2 = new TestContainer();
        
        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test1.bin");
        
        PersistableUtils.writeBinFile(testContainer1, f);
        PersistableUtils.readBinFile(testContainer2, f);
        
        ReflectionEquals comparator = new ReflectionEquals();
        
        comparator.assertEquals(testContainer1, testContainer2);
    }

    @Test
    public void testRoundTrip2() throws Exception{
        TestSimpleContainer t1 = new TestSimpleContainer(); 
        TestSimpleContainer t2 = new TestSimpleContainer();
        t2.clear();
        
        FileUtils.forceMkdir(TEST_DIR);
        File f = new File(TEST_DIR, "test2.bin");
        
        PersistableUtils.writeBinFile(t1, f);
        PersistableUtils.readBinFile(t2, f);
        
        ReflectionEquals comparator = new ReflectionEquals();
        
        comparator.assertEquals(t1, t2);
    }
    
    @Test
    public void testFilteredLevelOneTrimStart() throws Exception{
        TestContainer tc = TestContainer.populatedTestContainerFactory(); 
        TestContainer deserialized = new TestContainer();
        
        FileUtils.forceMkdir(TEST_DIR);
        File file = new File(TEST_DIR, "test3.bin");

        BinaryPersistableFilter filter = new BinaryPersistableFilter("allTimeSeriesData", 1, 1);
        
        PersistableUtils.writeBinFile(tc, file, filter);
        PersistableUtils.readBinFile(deserialized, file);
        
        TestContainer expected = TestContainer.populatedTestContainerFactory();
        expected.getAllTimeSeriesData().remove(0);
        
        ReflectionEquals comparator = new ReflectionEquals();
        
        comparator.assertEquals(expected, deserialized);
    }
    
    @Test
    public void testFilteredLevelOneTrimEnd() throws Exception{
        TestContainer tc = TestContainer.populatedTestContainerFactory(); 
        TestContainer deserialized = new TestContainer();
        
        FileUtils.forceMkdir(TEST_DIR);
        File file = new File(TEST_DIR, "test3.bin");

        BinaryPersistableFilter filter = new BinaryPersistableFilter("allTimeSeriesData", 0, 0);
        
        PersistableUtils.writeBinFile(tc, file, filter);
        PersistableUtils.readBinFile(deserialized, file);
        
        TestContainer expected = TestContainer.populatedTestContainerFactory();
        expected.getAllTimeSeriesData().remove(1);
        
        ReflectionEquals comparator = new ReflectionEquals();
        
        comparator.assertEquals(expected, deserialized);
    }
    
    @Test
    public void testFilteredLevelTwoTrimStart() throws Exception{
        TestContainer tc = TestContainer.populatedTestContainerFactory(); 
        TestContainer deserialized = new TestContainer();
        
        FileUtils.forceMkdir(TEST_DIR);
        File file = new File(TEST_DIR, "test4.bin");

        BinaryPersistableFilter filter = new BinaryPersistableFilter("allTimeSeriesData.timeSeriesData", 1, 1);
        
        PersistableUtils.writeBinFile(tc, file, filter);
        PersistableUtils.readBinFile(deserialized, file);
        
        TestContainer expected = TestContainer.populatedTestContainerFactory();
        expected.getAllTimeSeriesData().get(0).getTimeSeriesData().remove(0);
        expected.getAllTimeSeriesData().get(1).getTimeSeriesData().remove(0);
        
        ReflectionEquals comparator = new ReflectionEquals();
        
        comparator.assertEquals(expected, deserialized);
    }
    
    @Test
    public void testFilteredLevelTwoTrimEnd() throws Exception{
        TestContainer tc = TestContainer.populatedTestContainerFactory(); 
        TestContainer deserialized = new TestContainer();
        
        FileUtils.forceMkdir(TEST_DIR);
        File file = new File(TEST_DIR, "test4.bin");

        BinaryPersistableFilter filter = new BinaryPersistableFilter("allTimeSeriesData.timeSeriesData", 0, 0);
        
        PersistableUtils.writeBinFile(tc, file, filter);
        PersistableUtils.readBinFile(deserialized, file);
        
        TestContainer expected = TestContainer.populatedTestContainerFactory();
        expected.getAllTimeSeriesData().get(0).getTimeSeriesData().remove(1);
        expected.getAllTimeSeriesData().get(1).getTimeSeriesData().remove(1);
        
        ReflectionEquals comparator = new ReflectionEquals();
        
        comparator.assertEquals(expected, deserialized);
    }

    @Test
    public void testDetermineListAttributes() throws Exception {
        Class<?> clazz = TestClass.class;
        Field f1 = clazz.getField("list1");
        Field f2 = clazz.getField("list2");
        Field f3 = clazz.getField("list3");

        ContainerAttributes expected1 = new ContainerAttributes(TestClass.class, 1);
        ContainerAttributes expected2 = new ContainerAttributes(TestClass.class, 2);
        ContainerAttributes expected3 = new ContainerAttributes(TestClass.class, 3);

        ContainerAttributes actual1 = PersistableUtils.determineListAttributes(f1);
        ContainerAttributes actual2 = PersistableUtils.determineListAttributes(f2);
        ContainerAttributes actual3 = PersistableUtils.determineListAttributes(f3);

        ReflectionEquals comparer = new ReflectionEquals();

        comparer.assertEquals("field 1", expected1, actual1);
        comparer.assertEquals("field 2", expected2, actual2);
        comparer.assertEquals("field 3", expected3, actual3);
    }

    @Test
    public void testDetermineSetAttributes() throws Exception {
        Class<?> clazz = TestClass.class;
        Field f1 = clazz.getField("set1");
        Field f2 = clazz.getField("set2");
        Field f3 = clazz.getField("set3");

        ContainerAttributes expected1 = new ContainerAttributes(TestClass.class, 1);
        ContainerAttributes expected2 = new ContainerAttributes(TestClass.class, 2);
        ContainerAttributes expected3 = new ContainerAttributes(TestClass.class, 3);

        ContainerAttributes actual1 = PersistableUtils.determineSetAttributes(f1);
        ContainerAttributes actual2 = PersistableUtils.determineSetAttributes(f2);
        ContainerAttributes actual3 = PersistableUtils.determineSetAttributes(f3);

        ReflectionEquals comparer = new ReflectionEquals();

        comparer.assertEquals("field 1", expected1, actual1);
        comparer.assertEquals("field 2", expected2, actual2);
        comparer.assertEquals("field 3", expected3, actual3);
    }

    @Test
    public void testDetermineMapAttributes() throws Exception {
        Class<?> clazz = TestClass.class;
        Field f1 = clazz.getField("mapString");
        Field f2 = clazz.getField("mapTestClass");

        Pair<ContainerAttributes, ContainerAttributes> expected1 = Pair.of(
            new ContainerAttributes(String.class, 1), new ContainerAttributes(
                TestClass.class, 1));
        Pair<ContainerAttributes, ContainerAttributes> expected2 = Pair.of(
            new ContainerAttributes(TestClass.class, 1),
            new ContainerAttributes(TestClass.class, 1));

        Pair<ContainerAttributes, ContainerAttributes> actual1 = PersistableUtils.determineMapAttributes(f1);
        Pair<ContainerAttributes, ContainerAttributes> actual2 = PersistableUtils.determineMapAttributes(f2);

        ReflectionEquals comparer = new ReflectionEquals();

        comparer.assertEquals("field 1", expected1, actual1);
        comparer.assertEquals("field 2", expected2, actual2);
    }

    @Test(expected=PipelineException.class)
    public void testIllegalMap() throws Exception {
        Class<?> clazz = TestClass.class;
        Field f1 = clazz.getField("mapIllegal");

        @SuppressWarnings("unused")
        // should throw exception because dimensions > 1
        Pair<ContainerAttributes, ContainerAttributes> actual1 = PersistableUtils.determineMapAttributes(f1);
    }
}
