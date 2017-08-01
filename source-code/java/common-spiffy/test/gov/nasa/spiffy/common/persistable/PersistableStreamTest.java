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
import static gov.nasa.spiffy.common.io.Filenames.BUILD_TEST;
import static org.junit.Assert.assertEquals;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.io.FileUtils;
import org.junit.Before;
import org.junit.Test;

import com.google.common.collect.ImmutableList;
import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;

/**
 * @author Miles Cote
 * 
 */
public abstract class PersistableStreamTest {
    protected static final File TEST_DIR = new File(BUILD_TEST);

    private PersistableOutputStream outputStream;
    private PersistableInputStream inputStream;

    @Before
    public void setUp() throws IOException {
        FileUtils.forceMkdir(TEST_DIR);

        outputStream = getPersistableOutputStream();
        inputStream = getPersistableInputStream();
    }

    protected abstract PersistableOutputStream getPersistableOutputStream()
        throws FileNotFoundException;

    protected abstract PersistableInputStream getPersistableInputStream()
        throws FileNotFoundException;

    @Test
    public void testSaveLoadEmptyPersistable() throws Exception {
        TestPersistableWithCollections testPersistable = new TestPersistableWithCollections();
        outputStream.save(testPersistable);

        TestPersistableWithCollections actualTestPersistable = new TestPersistableWithCollections();
        inputStream.load(actualTestPersistable);

        assertEquals(testPersistable, actualTestPersistable);
    }

    @Test
    public void testSaveLoadPersistable() throws Exception {
        TestPersistableWithCollections testPersistable = new TestPersistableWithCollections(
            1);
        outputStream.save(testPersistable);

        TestPersistableWithCollections actualTestPersistable = new TestPersistableWithCollections();
        inputStream.load(actualTestPersistable);

        assertEquals(testPersistable, actualTestPersistable);
    }

    @Test
    public void testSaveLoadEmptyList() throws Exception {
        List<String> List = ImmutableList.of();
        outputStream.save(List);

        List<String> actualList = newArrayList();
        inputStream.loadList(actualList, String.class, 1);

        assertEquals(List, actualList);
    }

    @Test
    public void testSaveLoadList() throws Exception {
        List<String> List = ImmutableList.of("1", "2", "3");
        outputStream.save(List);

        List<String> actualList = newArrayList();
        inputStream.loadList(actualList, String.class, 1);

        assertEquals(List, actualList);
    }

    @Test
    public void testSaveLoadEmptySet() throws Exception {
        Set<String> set = ImmutableSet.of();
        outputStream.save(set);

        Set<String> actualSet = newHashSet();
        inputStream.loadSet(actualSet, String.class);

        assertEquals(set, actualSet);
    }

    @Test
    public void testSaveLoadSet() throws Exception {
        Set<String> set = ImmutableSet.of("1", "2", "3");
        outputStream.save(set);

        Set<String> actualSet = newHashSet();
        inputStream.loadSet(actualSet, String.class);

        assertEquals(set, actualSet);
    }

    @Test
    public void testSaveLoadEmptyMap() throws Exception {
        Map<String, String> map = ImmutableMap.of();
        outputStream.save(map);

        Map<String, String> actualMap = newHashMap();
        inputStream.loadMap(actualMap, String.class, String.class);

        assertEquals(map, actualMap);
    }

    @Test
    public void testSaveLoadMap() throws Exception {
        Map<String, String> map = ImmutableMap.of("one", "1", "two", "2",
            "three", "3");
        outputStream.save(map);

        Map<String, String> actualMap = newHashMap();
        inputStream.loadMap(actualMap, String.class, String.class);

        assertEquals(map, actualMap);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSaveWithNull() throws Exception {
        outputStream.save(null);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSaveWithNonPersistableInstance() throws Exception {
        outputStream.save(new Object());
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSaveWithNullField() throws Exception {
        TestPersistableWithCollections testPersistable = new TestPersistableWithCollections(
            1);
        testPersistable.setTestPersistableElement1(null);
        outputStream.save(testPersistable);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testSaveMapWithNullValue() throws Exception {
        Map<String, String> map = new HashMap<String, String>();
        map.put("one", null);
        outputStream.save(map);
    }

    @Test(expected = IllegalArgumentException.class)
    public void testLoadWithNull() throws Exception {
        inputStream.load(null);
    }
}
