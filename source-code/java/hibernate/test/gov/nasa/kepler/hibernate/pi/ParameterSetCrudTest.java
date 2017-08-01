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
import gov.nasa.kepler.common.pi.AncillaryPipelineParameters;
import gov.nasa.kepler.hibernate.dbservice.DatabaseService;
import gov.nasa.kepler.hibernate.dbservice.DatabaseServiceFactory;
import gov.nasa.kepler.hibernate.dbservice.TestUtils;
import gov.nasa.spiffy.common.junit.ReflectionEquals;
import gov.nasa.spiffy.common.pi.Parameters;
import gov.nasa.spiffy.common.pi.PipelineException;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.apache.commons.lang.ArrayUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.junit.After;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

/**
 * Tests for {@link ParameterSetCrud}. Tests that objects can be stored,
 * retrieved, and edited and that mapping metadata (associations, cascade rules,
 * etc.) are setup correctly and work as expected.
 * 
 * @author tklaus
 * 
 */
public class ParameterSetCrudTest {

    private static final Log log = LogFactory.getLog(ParameterSetCrudTest.class);

    private DatabaseService databaseService = null;

    private ParameterSetCrud parameterSetCrud;

    private static final String TEST_PARAM_SET_NAME = "test ps1";

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     * @throws ClassNotFoundException
     * @throws IOException
     */
    @Before
    public void setUp() throws SQLException, ClassNotFoundException,
        IOException {

        // System.setProperty("hibernate.show_sql", "true");

        databaseService = DatabaseServiceFactory.getInstance();
        TestUtils.setUpDatabase(databaseService);

        parameterSetCrud = new ParameterSetCrud(databaseService);
    }

    /**
     * 
     * @throws PipelineException
     * @throws SQLException
     */
    @After
    public void tearDown() throws SQLException {
        if (databaseService != null) {
            TestUtils.tearDownDatabase(databaseService);
        }
    }

    private ParameterSet store(String name, Parameters params) {
        databaseService.beginTransaction();

        // create a param set
        ParameterSet paramSet = new ParameterSet(name);
        paramSet.setParameters(new BeanWrapper<Parameters>(params));
        parameterSetCrud.create(paramSet);

        databaseService.commitTransaction();

        return paramSet;
    }

    private void rename(ParameterSet oldParameterSet, String newName) {
        databaseService.beginTransaction();

        parameterSetCrud.rename(oldParameterSet, newName);

        databaseService.commitTransaction();
    }

    private ParameterSet retrieve(String name) {
        databaseService.beginTransaction();

        ParameterSet paramSet = parameterSetCrud.retrieveLatestVersionForName(name);

        databaseService.commitTransaction();

        return paramSet;
    }

    /**
     * Stores a new ParameterSet in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTestBean() throws Exception {
        try {

            TestBean expectedInstance = new TestBean();
            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                expectedInstance);

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            Map<String, String> expectedProps = new HashMap<String, String>();
            expectedProps.put("a", "1");
            expectedProps.put("b", "foo");
            expectedProps.put("c", "1,2,3");
            expectedProps.put("d", "a,b,c");

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new ParameterSet in the db, renames it, then retrieves it with
     * the new name and make sure it matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreRenameRetrieveTestBean() throws Exception {
        try {

            TestBean expectedInstance = new TestBean();
            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                expectedInstance);

            // Rename
            String newName = TEST_PARAM_SET_NAME + " (v2)";
            rename(expectedParamSet, newName);

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(newName);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.excludeField(".*\\.id");
            comparer.excludeField(".*\\.name.name");
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            assertEquals("ParameterSet.name.name", newName,
                actualParamSet.getName()
                    .getName());

            Map<String, String> expectedProps = new HashMap<String, String>();
            expectedProps.put("a", "1");
            expectedProps.put("b", "foo");
            expectedProps.put("c", "1,2,3");
            expectedProps.put("d", "a,b,c");

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new ParameterSet in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTestBeanWithNulls() throws Exception {
        try {

            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                new TestBean(42, null, new int[] { 1, 2, 3 }, null));

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            Map<String, String> expectedProps = new HashMap<String, String>();
            expectedProps.put("a", "42");
            expectedProps.put("c", "1,2,3");

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
            TestBean expectedInstance = new TestBean(42, "", new int[] { 1, 2,
                3 }, new String[] {});
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new ParameterSet in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTestBeanWithEmptyArray() throws Exception {
        try {

            TestBean expectedInstance = new TestBean(42, "", new int[] { 1, 2,
                3 }, new String[] {});
            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                expectedInstance);

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            Map<String, String> expectedProps = new HashMap<String, String>();
            expectedProps.put("a", "42");
            expectedProps.put("c", "1,2,3");

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new ParameterSet in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTestBean2() throws Exception {
        try {

            TestBean2 expectedInstance = new TestBean2();
            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                expectedInstance);

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            Map<String, String> expectedProps = new HashMap<String, String>();
            expectedProps.put("a", "a");
            expectedProps.put("b", "b");

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new ParameterSet in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTestBean2WithNulls() throws Exception {
        try {

            TestBean2 expectedInstance = new TestBean2("", "");
            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                expectedInstance);

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            Map<String, String> expectedProps = new HashMap<String, String>();
            // expect empty

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    /**
     * Stores a new ParameterSet in the db, then retrieves it and makes sure it
     * matches what was put in
     * 
     * @throws Exception
     */
    @Test
    public void testStoreAndRetrieveTestBean2WithNullsThenStore()
        throws Exception {
        try {

            TestBean2 expectedInstance = new TestBean2("", "");
            ParameterSet expectedParamSet = store(TEST_PARAM_SET_NAME,
                expectedInstance);

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            ParameterSet actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            ReflectionEquals comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);
            Parameters actualInstance = actualParamSet.parametersInstance();
            comparer.assertEquals("BeanWrapper<TestBean>.instance",
                expectedInstance, actualInstance);

            Map<String, String> expectedProps = new HashMap<String, String>();
            // expect empty

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());

            databaseService.beginTransaction();

            actualParamSet.setParameters(new BeanWrapper<Parameters>(
                new TestBean2("foo", "bar")));

            databaseService.commitTransaction();

            // clear the cache , detach the objects
            databaseService.closeCurrentSession();

            // Retrieve
            expectedParamSet = actualParamSet;
            actualParamSet = retrieve(TEST_PARAM_SET_NAME);

            comparer = new ReflectionEquals();
            comparer.assertEquals("ParameterSet", expectedParamSet,
                actualParamSet);

            expectedProps = new HashMap<String, String>();
            expectedProps.put("a", "foo");
            expectedProps.put("b", "bar");

            assertEquals("BeanWrapper<TestBean>.props", expectedProps,
                actualParamSet.getParameters()
                    .getProps());
        } finally {
            databaseService.rollbackTransactionIfActive();
        }
    }

    @Test
    public void testEmptyStringArrayIsNotStringArrayOfNull() {
        // Do what megaPipelineSeedData does:
        String name = "ancillaryPipelineParameters";
        AncillaryPipelineParameters ancillaryPipelineParameters = new AncillaryPipelineParameters();
        ancillaryPipelineParameters.setInteractions(ArrayUtils.EMPTY_STRING_ARRAY);

        ParameterSet paramSet = new ParameterSet(name);
        paramSet.setParameters(new BeanWrapper<Parameters>(
            ancillaryPipelineParameters));

        parameterSetCrud.create(paramSet);

        databaseService.closeCurrentSession();

        // Do what pa does:
        ParameterSet retrievedParamSet = parameterSetCrud.retrieveAll()
            .get(0);

        BeanWrapper<Parameters> actualParameters = retrievedParamSet.getParameters();

        String[] interactions = ((AncillaryPipelineParameters) actualParameters.getInstance()).getInteractions();
        log.info("interactions: " + Arrays.toString(interactions));
        Assert.assertTrue(Arrays.equals(ArrayUtils.EMPTY_STRING_ARRAY,
            interactions));
    }

}
