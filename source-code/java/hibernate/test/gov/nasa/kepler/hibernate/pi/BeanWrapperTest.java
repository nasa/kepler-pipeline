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

package gov.nasa.kepler.hibernate.pi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertTrue;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.util.HashMap;
import java.util.Map;

import org.junit.Test;

/**
 * @author Todd Klaus tklaus@arc.nasa.gov
 * 
 */
public class BeanWrapperTest {

    @Test
    public void constructFromClass() throws Exception {
        BeanWrapper<TestBean> beanWrapper = new BeanWrapper<TestBean>(
            TestBean.class);

        Map<String, String> expectedProps = new HashMap<String, String>();
        expectedProps.put("a", "1");
        expectedProps.put("b", "foo");
        expectedProps.put("c", "1,2,3");
        expectedProps.put("d", "a,b,c");

        assertEquals("BeanWrapper<TestBean>.beanClassName", TestBean.class,
            beanWrapper.getClazz());
        assertEquals("BeanWrapper<TestBean>.props", expectedProps,
            beanWrapper.getProps());

        TestBean expectedBean = new TestBean();
        TestBean actualBean = beanWrapper.getInstance();

        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(expectedBean, actualBean);
    }

    @Test
    public void constructFromInstance() throws PipelineException {
        TestBean bean = new TestBean(42, "xyzzy", new int[] { 1, 3, 5, 7, 11 },
            new String[] { "latest--planet.txt", "b.1", "c.1" });
        BeanWrapper<TestBean> beanWrapper = new BeanWrapper<TestBean>(bean);

        assertEquals("BeanWrapper<TestBean>.beanClassName", TestBean.class,
            beanWrapper.getClazz());
        assertEquals("BeanWrapper<TestBean>.props.size", 4,
            beanWrapper.getProps()
                .size());
        assertTrue("BeanWrapper<TestBean>.props contains 'a'",
            beanWrapper.getProps()
                .containsKey("a"));
        assertEquals("BeanWrapper<TestBean>.props.get(\"a\")", "42",
            beanWrapper.getProps()
                .get("a"));
        assertTrue("BeanWrapper<TestBean>.props contains 'b'",
            beanWrapper.getProps()
                .containsKey("b"));
        assertEquals("BeanWrapper<TestBean>.props.get(\"b\")", "xyzzy",
            beanWrapper.getProps()
                .get("b"));
        assertTrue("BeanWrapper<TestBean>.props contains 'c'",
            beanWrapper.getProps()
                .containsKey("c"));
        assertEquals("BeanWrapper<TestBean>.props.get(\"c\")", "1,3,5,7,11",
            beanWrapper.getProps()
                .get("c"));
        assertEquals("BeanWrapper<TestBean>.props.get(\"d\")",
            "latest--planet.txt,b.1,c.1", beanWrapper.getProps()
                .get("d"));
    }

    @Test
    public void copyConstructor() throws Exception {
        TestBean bean1 = new TestBean(42, "xyzzy",
            new int[] { 1, 3, 5, 7, 11 }, new String[] { "a", "b", "c" });
        BeanWrapper<TestBean> beanWrapper1 = new BeanWrapper<TestBean>(bean1);
        BeanWrapper<TestBean> beanWrapper2 = new BeanWrapper<TestBean>(
            beanWrapper1);
        TestBean bean2 = beanWrapper2.getInstance();

        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(bean1, bean2);

        assertEquals("BeanWrapper<TestBean>.beanClassName",
            beanWrapper1.getClazz(), beanWrapper2.getClazz());
        assertEquals("BeanWrapper<TestBean>.props", beanWrapper1.getProps(),
            beanWrapper2.getProps());
    }

    /**
     * Simulate construction of the object after loading from the db.
     * 
     * @throws Exception
     */
    @Test
    public void constructFromHibernateLoad() throws Exception {
        Map<String, String> props = new HashMap<String, String>();
        props.put("a", "42");
        props.put("b", "xyzzy");
        props.put("c", "1,3,5,7,11");
        props.put("d", "a--.1,b_.1,c.1");

        BeanWrapper<TestBean> beanWrapper = new BeanWrapper<TestBean>();
        beanWrapper.setClazz(TestBean.class);
        beanWrapper.setProps(props);

        TestBean expectedBean = new TestBean(42, "xyzzy", new int[] { 1, 3, 5,
            7, 11 }, new String[] { "a--.1", "b_.1", "c.1" });
        TestBean actualBean = beanWrapper.getInstance();

        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(expectedBean, actualBean);
    }

    @Test
    public void constructFromHibernateLoadWithNulls() throws Exception {
        Map<String, String> props = new HashMap<String, String>();
        props.put("a", "42");
        props.put("c", "1,3,5,7,11");
        props.put("d", "a--.1,b_.1,c.1");

        BeanWrapper<TestBean> beanWrapper = new BeanWrapper<TestBean>();
        beanWrapper.setClazz(TestBean.class);
        beanWrapper.setProps(props);

        TestBean expectedBean = new TestBean(42, "foo", new int[] { 1, 3, 5, 7,
            11 }, new String[] { "a--.1", "b_.1", "c.1" });
        TestBean actualBean = beanWrapper.getInstance();

        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(expectedBean, actualBean);
    }

    @Test
    public void testPopulate() throws Exception {
        Map<String, String> props = new HashMap<String, String>();
        props.put("a", "42");
        props.put("b", "xyzzy");
        props.put("c", "1,3,5,7,11");
        props.put("d", "a,b,c");

        BeanWrapper<TestBean> beanWrapper = new BeanWrapper<TestBean>(
            TestBean.class);

        beanWrapper.setProps(props);

        TestBean expectedBean = new TestBean(42, "xyzzy", new int[] { 1, 3, 5,
            7, 11 }, new String[] { "a", "b", "c" });
        TestBean actualBean = beanWrapper.getInstance();

        ReflectionEquals comparator = new ReflectionEquals();
        comparator.assertEquals(expectedBean, actualBean);
    }

    @Test
    public void testGetProps() throws Exception {
        Map<String, String> expectedProps = new HashMap<String, String>();
        expectedProps.put("a", "42");
        expectedProps.put("b", "xyzzy");
        expectedProps.put("c", "1,3,5,7,11");
        expectedProps.put("d", "a,b,c");

        TestBean bean = new TestBean(42, "xyzzy", new int[] { 1, 3, 5, 7, 11 },
            new String[] { "a", "b", "c" });
        BeanWrapper<TestBean> beanWrapper = new BeanWrapper<TestBean>(bean);

        assertEquals("BeanWrapper<TestBean>.props", expectedProps,
            beanWrapper.getProps());
    }
}
